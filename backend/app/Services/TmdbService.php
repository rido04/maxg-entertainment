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

    // Genre yang benar-benar harus dihindari (sensual/adult content)
    protected $explicitlyAdultGenres = [
        10749,  // Romance (bisa sensual)
        // Hapus Horror, Thriller, Crime karena banyak film bagus non-sensual
    ];

    // Genre yang aman untuk semua umur
    protected $safeFamilyGenres = [
        16,     // Animation
        10751,  // Family
        12,     // Adventure
        35,     // Comedy
        99,     // Documentary
        10402,  // Music
        36,     // History
        878,    // Science Fiction
        14,     // Fantasy
        18,     // Drama
        28,     // Action
        53,     // Thriller (dikembalikan)
        27,     // Horror (dikembalikan)
        80,     // Crime (dikembalikan)
        9648,   // Mystery
        10752,  // War
        37,     // Western
    ];

    // Rating yang diizinkan (US rating system)
    protected $allowedRatings = [
        'G',        // General Audiences
        'PG',       // Parental Guidance Suggested
        'PG-13',    // Parents Strongly Cautioned (dikembalikan)
        'TV-Y',     // Children
        'TV-Y7',    // Children 7+
        'TV-G',     // General Audiences
        'TV-PG',    // Parental Guidance
        'TV-14',    // Parents Strongly Cautioned (dikembalikan)
    ];

    // Rating yang benar-benar dibatasi (hanya yang explicit)
    protected $restrictedRatings = [
        // 'R',        // Restricted (bisa sensual)
        'NC-17',    // Adults Only
        // 'TV-MA',    // Mature Audiences (bisa sensual)
        'X',        // Adults Only (old system)
    ];

    public function __construct()
    {
        $this->apiKey = config('services.tmdb.api_key');
    }

    /**
     * Search movie dengan multiple language support
     */
    public function searchMovie(string $query, ?int $year = null)
    {
        $results = [];

        // Search dengan query original
        $originalResults = $this->performSearch($query, $year);
        if ($originalResults) {
            $results = array_merge($results, $originalResults['results'] ?? []);
        }

        // Jika tidak ada hasil dan query mengandung karakter Indonesia, coba search internasional
        if (empty($results) && $this->isIndonesianTitle($query)) {
            $englishQuery = $this->tryTranslateToEnglish($query);
            if ($englishQuery !== $query) {
                $englishResults = $this->performSearch($englishQuery, $year);
                if ($englishResults) {
                    $results = array_merge($results, $englishResults['results'] ?? []);
                }
            }
        }

        // Remove duplicates berdasarkan TMDb ID
        $uniqueResults = [];
        $seenIds = [];
        foreach ($results as $result) {
            if (!in_array($result['id'], $seenIds)) {
                $uniqueResults[] = $result;
                $seenIds[] = $result['id'];
            }
        }

        return [
            'results' => $uniqueResults,
            'total_results' => count($uniqueResults),
            'total_pages' => 1
        ];
    }

    /**
     * Perform actual search ke TMDb API
     */
    private function performSearch(string $query, ?int $year = null)
    {
        $params = [
            'api_key' => $this->apiKey,
            'query' => $query,
            'include_adult' => 'false', // Tetap false untuk filter adult
        ];

        if ($year) {
            $params['year'] = $year;
        }

        $response = Http::get('https://api.themoviedb.org/3/search/movie', $params);
        return $response->successful() ? $response->json() : null;
    }

    /**
     * Check if title is likely Indonesian
     */
    private function isIndonesianTitle(string $title): bool
    {
        $indonesianWords = [
            'setan', 'hantu', 'pocong', 'kuntilanak', 'danur', 'pengabdi',
            'jailangkung', 'rumah', 'dilan', 'iqro', 'habibie', 'ainun',
            'laskar', 'pelangi', 'ayat', 'cinta', 'negeri', 'bawah', 'angin'
        ];

        $lowerTitle = strtolower($title);
        foreach ($indonesianWords as $word) {
            if (strpos($lowerTitle, $word) !== false) {
                return true;
            }
        }
        return false;
    }

    /**
     * Simple title translation attempts
     */
    private function tryTranslateToEnglish(string $title): string
    {
        $translations = [
            'pengabdi setan' => 'satan slave',
            'danur' => 'danur',
            'jailangkung' => 'jailangkung',
            'kuntilanak' => 'kuntilanak',
            'dilan' => 'dilan',
            'laskar pelangi' => 'rainbow troops',
            'ayat ayat cinta' => 'verses of love',
            'habibie ainun' => 'habibie ainun',
        ];

        $lowerTitle = strtolower($title);
        foreach ($translations as $indonesian => $english) {
            if (strpos($lowerTitle, $indonesian) !== false) {
                return str_replace($indonesian, $english, $lowerTitle);
            }
        }

        return $title;
    }

    public function searchMovieWithFilters(string $query, ?int $year = null, bool $includeAdult = false)
    {
        $results = $this->searchMovie($query, $year);

        // Filter untuk konten yang benar-benar inappropriate (bukan berdasarkan genre horror/thriller)
        if ($results && isset($results['results']) && !$includeAdult) {
            $results['results'] = array_filter($results['results'], function($movie) {
                return $this->isContentAppropriate($movie);
            });
            $results['results'] = array_values($results['results']);
        }

        return $results;
    }

    /**
     * IMPROVED: Cek konten yang lebih fokus pada sensual/adult content
     */
    public function isContentAppropriate(array $movieData): bool
    {
        // Cek adult flag (ini yang paling penting)
        if ($movieData['adult'] ?? false) {
            return false;
        }

        // Cek kata kunci sensual dalam judul
        $title = strtolower($movieData['title'] ?? '');
        $originalTitle = strtolower($movieData['original_title'] ?? '');

        $sensualKeywords = [
            'porn', 'sex', 'erotic', 'adult', 'xxx', 'naked', 'nude', 'sensual',
            'pornographic', 'actress', 'stripper', 'seduction', 'temptation',
            'desire', 'lust', 'passion', 'intimate', 'sensuality', 'pozzi',
            'cicciolina', 'staller', 'moana pozzi', 'biography', 'biopic'
        ];

        foreach ($sensualKeywords as $keyword) {
            if (strpos($title, $keyword) !== false || strpos($originalTitle, $keyword) !== false) {
                Log::warning('Blocked by keyword filter:', [
                    'title' => $movieData['title'],
                    'keyword' => $keyword
                ]);
                return false;
            }
        }

        // Cek overview/sinopsis untuk kata kunci sensual
        $overview = strtolower($movieData['overview'] ?? '');
        $explicitOverviewKeywords = [
            'pornographic', 'porn', 'adult film', 'erotic', 'sex', 'nude',
            'naked', 'stripper', 'prostitute', 'escort', 'sensual', 'seduction',
            'iconic pornographic actress', 'adult actress', 'xxx'
        ];

        foreach ($explicitOverviewKeywords as $keyword) {
            if (strpos($overview, $keyword) !== false) {
                Log::warning('Blocked by overview filter:', [
                    'title' => $movieData['title'],
                    'keyword' => $keyword,
                    'overview' => substr($overview, 0, 100) . '...'
                ]);
                return false;
            }
        }

        // Cek genre - tolak genre yang bisa sensual
        $genreIds = $movieData['genre_ids'] ?? [];
        if (!empty($genreIds)) {
            $sensualGenres = [
                10749,  // Romance (bisa sensual)
                // Tambahkan genre ID lain yang sering sensual
            ];

            $hasExplicitGenre = !empty(array_intersect($genreIds, $sensualGenres));
            if ($hasExplicitGenre) {
                // Double check - jika romance tapi rating tinggi dan tahun baru, mungkin aman
                $rating = $movieData['vote_average'] ?? 0;
                $releaseDate = $movieData['release_date'] ?? '';
                $year = $releaseDate ? (int) substr($releaseDate, 0, 4) : 0;

                // Jika romance rating rendah atau tahun lama, blokir
                if ($rating < 7.0 || $year < 2000) {
                    Log::warning('Blocked romance with low rating/old year:', [
                        'title' => $movieData['title'],
                        'rating' => $rating,
                        'year' => $year
                    ]);
                    return false;
                }
            }
        }

        // Cek rating untuk memastikan tidak ada konten sensual
        $rating = $movieData['vote_average'] ?? 0;

        // Jika rating terlalu rendah, mungkin film berkualitas buruk
        if ($rating < 3.0) {
            return false;
        }

        // Cek tahun rilis - tolak film yang terlalu lama (mungkin standar berbeda)
        $releaseDate = $movieData['release_date'] ?? '';
        if ($releaseDate) {
            $year = (int) substr($releaseDate, 0, 4);
            if ($year < 1970) { // Film terlalu lama
                return false;
            }
        }

        return true;
    }

    public function getMovieDetail($id)
    {
        $response = Http::get("https://api.themoviedb.org/3/movie/{$id}", [
            'api_key' => $this->apiKey,
        ]);

        return $response->successful() ? $response->json() : null;
    }

    /**
     * Get movie credits (cast dan crew)
     */
    public function getMovieCredits($id)
    {
        $response = Http::get("https://api.themoviedb.org/3/movie/{$id}/credits", [
            'api_key' => $this->apiKey,
        ]);

        return $response->successful() ? $response->json() : null;
    }

    /**
     * Process cast data dari TMDb credits
     */
    public function processCastData($credits): array
    {
        $cast = $credits['cast'] ?? [];
        $crew = $credits['crew'] ?? [];

        // Ambil cast utama (top 10)
        $mainCast = array_slice($cast, 0, 10);
        $castNames = array_map(function($actor) {
            return $actor['name'] ?? 'Unknown';
        }, $mainCast);

        // Cari director
        $director = null;
        $writers = [];

        foreach ($crew as $member) {
            if (($member['job'] ?? '') === 'Director') {
                $director = $member['name'] ?? null;
            }
            if (in_array($member['job'] ?? '', ['Writer', 'Screenplay', 'Story'])) {
                $writers[] = $member['name'] ?? 'Unknown';
            }
        }

        return [
            'cast_string' => implode(', ', $castNames),
            'cast_json' => json_encode($mainCast),
            'director' => $director,
            'writers' => implode(', ', array_unique($writers))
        ];
    }

    /**
     * Get content rating dengan lebih banyak fallback
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

            // Priority: US, then ID (Indonesia), then any other
            $priorities = ['US', 'ID', 'GB', 'AU', 'CA'];

            foreach ($priorities as $country) {
                foreach ($results as $result) {
                    if ($result['iso_3166_1'] === $country) {
                        $releaseDates = $result['release_dates'] ?? [];
                        foreach ($releaseDates as $releaseDate) {
                            if (!empty($releaseDate['certification'])) {
                                return $releaseDate['certification'];
                            }
                        }
                    }
                }
            }

            // Fallback ke rating negara manapun
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
     * IMPROVED: Cek rating yang lebih permisif
     */
    public function isRatingRestricted(?string $rating): bool
    {
        if (!$rating) {
            return false;
        }

        return in_array($rating, $this->restrictedRatings);
    }

    /**
     * IMPROVED: Lebih permisif terhadap rating
     */
    public function isRatingAllowed(?string $rating): bool
    {
        if (!$rating) {
            return true; // Tidak ada rating = boleh
        }

        // Sekarang PG-13 dan TV-14 diizinkan
        return in_array($rating, $this->allowedRatings) || !$this->isRatingRestricted($rating);
    }

    public function storeMovieFromTmdb(array $tmdbData, string $filePath = null)
    {
        if (!$this->isContentAppropriate($tmdbData)) {
            return 'Movie content is not appropriate.';
        }

        $existingMedia = Media::where('tmdb_id', $tmdbData['id'])
                             ->orWhere('title', $tmdbData['title'])
                             ->first();

        if ($existingMedia) {
            return 'Movie already exists.';
        }

        if (!isset($tmdbData['poster_path']) || !$tmdbData['poster_path']) {
            return 'No poster available for this movie.';
        }

        $posterUrl = 'https://image.tmdb.org/t/p/w300' . $tmdbData['poster_path'];
        $posterResponse = Http::get($posterUrl);

        if (!$posterResponse->successful()) {
            return 'Failed to download poster.';
        }

        $posterContents = $posterResponse->body();
        $posterFilename = 'poster_' . $tmdbData['id'] . '.jpg';
        Storage::disk('public')->put("media/thumbnails/{$posterFilename}", $posterContents);

        $genres = $tmdbData['genres'] ?? [];
        $category = count($genres) > 0 ? implode(', ', array_column($genres, 'name')) : 'Unknown';

        // Get detailed movie info dan credits
        $movieDetail = $this->getMovieDetail($tmdbData['id']);
        $credits = $this->getMovieCredits($tmdbData['id']);
        $castData = $this->processCastData($credits ?? []);
        $contentRating = $this->getContentRating($tmdbData['id']);
        $defaultFilePath = $filePath ?? 'media/videos/default.mp4';

        Media::create([
            'title' => $tmdbData['title'],
            'file_path' => $defaultFilePath,
            'type' => 'video',
            'thumbnail' => "media/thumbnails/{$posterFilename}",
            'description' => $tmdbData['overview'],
            'rating' => $tmdbData['vote_average'],
            'release_date' => $tmdbData['release_date'],
            'language' => $tmdbData['original_language'],
            'tmdb_id' => $tmdbData['id'],
            'category' => $category,
            'is_adult_content' => $tmdbData['adult'] ?? false,
            'content_rating' => $contentRating,
            'duration' => $movieDetail['runtime'] ?? null,
            'cast' => $castData['cast_string'],
            'cast_json' => $castData['cast_json'],
            'director' => $castData['director'],
            'writers' => $castData['writers'],
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
     * Update existing media dengan data TMDb yang lebih lengkap
     */
    public function updateMediaWithTmdbData(Media $media)
    {
        if (!$media->tmdb_id) {
            return false;
        }

        try {
            $movieDetail = $this->getMovieDetail($media->tmdb_id);
            $credits = $this->getMovieCredits($media->tmdb_id);
            $castData = $this->processCastData($credits ?? []);
            $contentRating = $this->getContentRating($media->tmdb_id);

            $updateData = [
                'content_rating' => $contentRating,
            ];

            if ($movieDetail) {
                $updateData['duration'] = $movieDetail['runtime'] ?? $media->duration;
            }

            if (!empty($castData['cast_string'])) {
                $updateData['cast'] = $castData['cast_string'];
                $updateData['cast_json'] = $castData['cast_json'];
            }

            if ($castData['director']) {
                $updateData['director'] = $castData['director'];
            }

            if ($castData['writers']) {
                $updateData['writers'] = $castData['writers'];
            }

            $media->update($updateData);
            return true;

        } catch (\Exception $e) {
            Log::error('Failed to update media with TMDb data:', [
                'media_id' => $media->id,
                'tmdb_id' => $media->tmdb_id,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }
}
