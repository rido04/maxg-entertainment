<?php

namespace App\Services;

use App\Models\Media;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class TmdbService
{
    protected $apiKey;
    protected $baseUrl = 'https://api.themoviedb.org/3/';

    // Daftar genre yang dianggap family-friendly
    protected $familyFriendlyGenres = [
        16,     // Animation
        10751,  // Family
        12,     // Adventure
        35,     // Comedy
        99,     // Documentary
        10402,  // Music
        36,     // History
        878,    // Science Fiction (selective)
        14,     // Fantasy (selective)
    ];

    // Daftar rating yang diizinkan (US rating system)
    protected $allowedRatings = [
        'G',        // General Audiences
        'PG',       // Parental Guidance Suggested
        'TV-Y',     // Children
        'TV-Y7',    // Children 7+
        'TV-G',     // General Audiences
        'TV-PG',    // Parental Guidance
    ];

    // Rating yang dibatasi
    protected $restrictedRatings = [
        // 'PG-13',    // Parents Strongly Cautioned
        // 'R',        // Restricted
        // 'NC-17',    // Adults Only
        // 'TV-14',    // Parents Strongly Cautioned
        // 'TV-MA',    // Mature Audiences
        'X',        // Adults Only (old system)
    ];

    public function __construct()
    {
        $this->apiKey = config('services.tmdb.api_key');
    }

    public function searchMovie(string $query, ?int $year = null)
    {
        $params = [
            'api_key' => $this->apiKey,
            'query' => $query,
        ];

        if ($year) {
            $params['year'] = $year;
        }

        $response = Http::get('https://api.themoviedb.org/3/search/movie', $params);

        return $response->successful() ? $response->json() : null;
    }

    public function searchMovieWithFilters(string $query, ?int $year = null, bool $includeAdult = false)
    {
        $params = [
            'api_key' => $this->apiKey,
            'query' => $query,
            'include_adult' => $includeAdult ? 'true' : 'false',
        ];

        if ($year) {
            $params['year'] = $year;
        }

        $response = Http::get('https://api.themoviedb.org/3/search/movie', $params);
        $results = $response->successful() ? $response->json() : null;

        // Additional filtering untuk memastikan content appropriate
        if ($results && isset($results['results']) && !$includeAdult) {
            $results['results'] = array_filter($results['results'], function($movie) {
                return $this->isContentAppropriate($movie);
            });
            $results['results'] = array_values($results['results']); // Re-index array
        }

        return $results;
    }

    public function getMovieDetail($id)
    {
        $response = Http::get("https://api.themoviedb.org/3/movie/{$id}", [
            'api_key' => $this->apiKey,
        ]);

        return $response->successful() ? $response->json() : null;
    }

    /**
     * Cek apakah konten appropriate untuk semua umur
     */
    public function isContentAppropriate(array $movieData): bool
    {
        // Cek adult flag
        if ($movieData['adult'] ?? false) {
            return false;
        }

        // Cek genre - harus mengandung minimal satu genre family-friendly
        $genreIds = $movieData['genre_ids'] ?? [];
        if (!empty($genreIds)) {
            $hasAppropriatGenre = !empty(array_intersect($genreIds, $this->familyFriendlyGenres));

            // Genres yang harus dihindari
            $adultGenres = [27, 53, 80]; // Horror, Thriller, Crime
            $hasAdultGenre = !empty(array_intersect($genreIds, $adultGenres));

            return $hasAppropriatGenre && !$hasAdultGenre;
        }

        // Jika tidak ada genre info, cek rating
        $rating = $movieData['vote_average'] ?? 0;
        return $rating >= 6.0; // Minimal rating 6.0 untuk konten tanpa genre info
    }

    /**
     * Get content rating (G, PG, PG-13, R, etc.) dari TMDb
     */
    public function getContentRating(string $tmdbId): ?string
    {
        try {
            $response = Http::get("https://api.themoviedb.org/3/movie/{$tmdbId}/release_dates", [
                'api_key' => $this->apiKey,
            ]);

            if (!$response->successful()) {
                return null;
            }

            $data = $response->json();
            $results = $data['results'] ?? [];

            // Cari rating untuk US terlebih dahulu
            foreach ($results as $result) {
                if ($result['iso_3166_1'] === 'US') {
                    $releaseDates = $result['release_dates'] ?? [];
                    foreach ($releaseDates as $releaseDate) {
                        if (!empty($releaseDate['certification'])) {
                            return $releaseDate['certification'];
                        }
                    }
                }
            }

            // Jika tidak ada US rating, cari rating lain
            foreach ($results as $result) {
                $releaseDates = $result['release_dates'] ?? [];
                foreach ($releaseDates as $releaseDate) {
                    if (!empty($releaseDate['certification'])) {
                        return $releaseDate['certification'];
                    }
                }
            }

            return null;
        } catch (\Exception $e) {
            Log::error('Error getting content rating:', ['tmdb_id' => $tmdbId, 'error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * Cek apakah rating termasuk yang dibatasi
     */
    public function isRatingRestricted(?string $rating): bool
    {
        if (!$rating) {
            return false; // Jika tidak ada rating, anggap aman
        }

        return in_array($rating, $this->restrictedRatings);
    }

    /**
     * Cek apakah rating termasuk yang diizinkan
     */
    public function isRatingAllowed(?string $rating): bool
    {
        if (!$rating) {
            return true; // Jika tidak ada rating, anggap aman
        }

        return in_array($rating, $this->allowedRatings);
    }

    public function storeMovieFromTmdb(array $tmdbData)
    {
        // Cek age restriction terlebih dahulu
        if (!$this->isContentAppropriate($tmdbData)) {
            return 'Movie content is not appropriate for all audiences.';
        }

        if (Media::where('tmdb_id', $tmdbData['id'])->exists()) {
            return 'Movie already exists.';
        }

        if (!isset($tmdbData['poster_path']) || !$tmdbData['poster_path']) {
            return 'No poster available for this movie.';
        }

        // Download poster menggunakan MediaDownloader
        $posterUrl = 'https://image.tmdb.org/t/p/original' . $tmdbData['poster_path'];
        $downloader = new MediaDownloader();
        $result = $downloader->download($posterUrl, 'media/posters');

        $thumbnailPath = null;
        if ($result['success']) {
            $thumbnailPath = $result['path'];
        } else {
            return 'Failed to download poster.';
        }

        $genres = $tmdbData['genres'] ?? [];
        $category = count($genres) > 0 ? implode(', ', array_column($genres, 'name')) : 'Unknown';

        // Get content rating
        $contentRating = $this->getContentRating($tmdbData['id']);

        Media::create([
            'title' => $tmdbData['title'],
            'file_path' => '/media/videos/INCEPTION.mp4',
            'type' => 'video',
            'thumbnail' => $thumbnailPath, // Menggunakan path dari MediaDownloader
            'description' => $tmdbData['overview'],
            'rating' => $tmdbData['vote_average'],
            'release_date' => $tmdbData['release_date'],
            'language' => $tmdbData['original_language'],
            'tmdb_id' => $tmdbData['id'],
            'category' => $category,
            'is_adult_content' => $tmdbData['adult'] ?? false,
            'content_rating' => $contentRating,
        ]);

        return 'Movie stored successfully.';
    }

    public function getGenreName($genreId)
    {
        $response = Http::get('https://api.themoviedb.org/3/genre/movie/list', [
            'api_key' => $this->apiKey,
        ]);

        $genres = $response->json()['genres'] ?? [];
        foreach ($genres as $genre) {
            if ($genre['id'] === $genreId) {
                return $genre['name'];
            }
        }

        return 'Unknown';
    }

    /**
     * Search khusus untuk konten family-friendly dengan filter ketat
     */
    public function searchFamilyMovie(string $query, ?int $year = null)
    {
        $results = $this->searchMovieWithFilters($query, $year, false);

        if (!$results || !isset($results['results'])) {
            return null;
        }

        // Filter hasil dengan kriteria yang lebih ketat
        $familyFriendlyResults = array_filter($results['results'], function($movie) {
            // Harus lolos semua filter
            if (!$this->isContentAppropriate($movie)) {
                return false;
            }

            // Cek genre harus family-friendly
            $genreIds = $movie['genre_ids'] ?? [];
            $hasGoodGenre = !empty(array_intersect($genreIds, $this->familyFriendlyGenres));

            // Cek rating minimal
            $rating = $movie['vote_average'] ?? 0;
            $hasGoodRating = $rating >= 6.0;

            // Cek tahun rilis (prioritas konten yang lebih baru)
            $releaseDate = $movie['release_date'] ?? '';
            $year = $releaseDate ? (int) substr($releaseDate, 0, 4) : 0;
            $isRecentEnough = $year >= 1990; // Film dari tahun 1990 ke atas

            return $hasGoodGenre && $hasGoodRating && $isRecentEnough;
        });

        // Sort berdasarkan popularity dan rating
        usort($familyFriendlyResults, function($a, $b) {
            $popularityA = $a['popularity'] ?? 0;
            $popularityB = $b['popularity'] ?? 0;
            $ratingA = $a['vote_average'] ?? 0;
            $ratingB = $b['vote_average'] ?? 0;

            // Kombinasi popularity dan rating
            $scoreA = ($popularityA * 0.3) + ($ratingA * 0.7);
            $scoreB = ($popularityB * 0.3) + ($ratingB * 0.7);

            return $scoreB <=> $scoreA; // Descending order
        });

        $results['results'] = array_values($familyFriendlyResults);
        return $results;
    }

    /**
     * Get family-friendly genres list
     */
    public function getFamilyFriendlyGenres(): array
    {
        return $this->familyFriendlyGenres;
    }

    /**
     * Get allowed ratings list
     */
    public function getAllowedRatings(): array
    {
        return $this->allowedRatings;
    }

    /**
     * Get restricted ratings list
     */
    public function getRestrictedRatings(): array
    {
        return $this->restrictedRatings;
    }
}
