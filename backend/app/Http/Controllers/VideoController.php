<?php

namespace App\Http\Controllers;

use getID3;
use Exception;
use App\Models\Media;
use Illuminate\Http\Request;
use App\Services\TmdbService;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

class VideoController extends Controller
{
    protected $tmdb;

    public function __construct(TmdbService $tmdb)
    {
        $this->tmdb = $tmdb;
    }

    public function search(Request $request)
    {
        $query = $request->input('q');

        $videos = Media::where('title', 'LIKE', '%' . $query . '%')
                    ->where('type', 'video')
                    ->where('is_adult_content', false) // Filter adult content
                    ->get();

        return view('videos.search', [
            'videos' => $videos,
        ]);
    }

    // Di Controller Anda, ubah method index seperti ini:

    public function index(Request $request)
    {
        $query = Media::query();

        // Filter berdasarkan kategori jika ada
        if ($request->has('category') && $request->category != '') {
            $query->where('category', $request->category);
        }

        // Tentukan jumlah item per halaman (default 8)
        $perPage = $request->get('per_page', 4);

        // Validasi per_page value
        if (!in_array($perPage, [4, 8, 12, 16, 20])) {
            $perPage = 4;
        }

        // Ambil data dengan pagination
        $videos = $query->latest()->paginate($perPage);

        // Append query parameters ke pagination links
        $videos->appends($request->query());

        // Ambil semua kategori untuk filter dropdown
        $categories = Media::distinct()->pluck('category')->filter()->sort();

        return view('videos.index', [
            'videos' => $videos,
            'categories' => $categories,
            'category' => $request->category ?? null,
        ]);
    }

    public function show(Media $video)
    {
        // Additional check untuk memastikan konten tidak adult
        if ($video->is_adult_content && !config('app.allow_adult_content', false)) {
            abort(403, 'Content not available');
        }

        $tmdbId = $video->tmdb_id ?? null;
        $movieDetail = null;

        if ($tmdbId) {
            $movieDetail = $this->tmdb->getMovieDetail($tmdbId);
        }

        return view('videos.show', compact('video', 'movieDetail'));
    }

    public function sync()
    {
        $folder = storage_path('app/public/media/videos');
        $files = File::files($folder);

        try {
            $files = Storage::disk('public')->files('media/videos');

            foreach ($files as $file) {
                $fileName = basename($file);
                $filePath = 'storage/' . $file;

                if (Media::where('file_path', $filePath)->exists()) {
                    continue;
                }

                $rawTitle = pathinfo($fileName, PATHINFO_FILENAME);
                $formattedTitle = ucfirst(str_replace(['_', '-', '.'], ' ', $rawTitle));

                // Extract year dari filename jika ada (format: Movie Title (2023))
                $year = null;
                if (preg_match('/\((\d{4})\)/', $formattedTitle, $matches)) {
                    $year = (int) $matches[1];
                    $formattedTitle = trim(preg_replace('/\(\d{4}\)/', '', $formattedTitle));
                }

                $getID3 = new getID3;
                $filePathAbsolute = Storage::disk('public')->path($file);
                $info = $getID3->analyze($filePathAbsolute);
                $duration = isset($info['playtime_seconds']) ? intval($info['playtime_seconds'] / 60) : null;

                // Initialize default values
                $tmdbId = null;
                $description = null;
                $rating = null;
                $releaseDate = null;
                $language = null;
                $thumbnail = null;
                $category = null;
                $isAdultContent = false;
                $contentRating = null;

                $tmdbService = app(TmdbService::class);

                // Gunakan search dengan filter age restriction
                $search = $tmdbService->searchMovieWithFilters($formattedTitle, $year, false);

                if ($search && isset($search['results'][0])) {
                    $movie = $search['results'][0];

                    // Validasi age restriction
                    if (!$tmdbService->isContentAppropriate($movie)) {
                        Log::warning('Skipping adult content:', [
                            'title' => $formattedTitle,
                            'adult' => $movie['adult'] ?? false
                        ]);
                        continue; // Skip file ini jika adult content
                    }

                    $tmdbId = (string) ($movie['id'] ?? null);
                    $description = $movie['overview'] ?? null;
                    $rating = isset($movie['vote_average']) ? round((float) $movie['vote_average'], 1) : null;
                    $releaseDate = $movie['release_date'] ?? null;
                    $language = $movie['original_language'] ?? null;
                    $isAdultContent = $movie['adult'] ?? false;
                    $thumbnail = $movie['poster_path']
                        ? 'https://image.tmdb.org/t/p/w500' . $movie['poster_path']
                        : null;

                    $genres = $movie['genre_ids'] ?? [];
                    $category = count($genres) > 0 ? implode(', ', array_map(function ($genreId) use ($tmdbService) {
                        return $tmdbService->getGenreName($genreId);
                    }, $genres)) : 'Unknown';

                    // Get detailed movie info untuk rating dan duration
                    $movieDetail = $tmdbService->getMovieDetail($tmdbId);
                    $tmdbDuration = $movieDetail['runtime'] ?? null;

                    // Get content rating (G, PG, PG-13, R, etc.)
                    $contentRating = $tmdbService->getContentRating($tmdbId);

                    // Double check dengan content rating
                    if ($tmdbService->isRatingRestricted($contentRating)) {
                        Log::warning('Skipping restricted content:', [
                            'title' => $formattedTitle,
                            'rating' => $contentRating
                        ]);
                        continue;
                    }

                    Log::info('TMDb Data Found (Age Appropriate):', [
                        'title' => $formattedTitle,
                        'tmdb_id' => $tmdbId,
                        'rating' => $rating,
                        'content_rating' => $contentRating,
                        'release_date' => $releaseDate,
                        'thumbnail' => $thumbnail,
                        'category' => $category,
                        'duration' => $tmdbDuration,
                        'is_adult' => $isAdultContent,
                    ]);
                } else {
                    Log::warning('No TMDb data found for:', ['title' => $formattedTitle]);
                }

                $savedMedia = Media::create([
                    'title' => $formattedTitle,
                    'file_path' => $filePath,
                    'type' => 'video',
                    'duration' => $tmdbDuration ?? $duration,
                    'tmdb_id' => $tmdbId,
                    'description' => $description,
                    'rating' => $rating,
                    'release_date' => $releaseDate,
                    'language' => $language,
                    'thumbnail' => $thumbnail,
                    'category' => $category,
                    'is_adult_content' => $isAdultContent,
                    'content_rating' => $contentRating,
                ]);

                Log::info('Media saved to DB:', [
                    'id' => $savedMedia->id,
                    'title' => $savedMedia->title,
                    'file_path' => $savedMedia->file_path,
                    'rating' => $savedMedia->rating,
                    'content_rating' => $savedMedia->content_rating,
                    'thumbnail' => $savedMedia->thumbnail,
                    'tmdb_id' => $savedMedia->tmdb_id,
                    'category' => $savedMedia->category,
                    'duration' => $savedMedia->duration,
                    'is_adult_content' => $savedMedia->is_adult_content,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Video sync completed successfully with age restrictions applied!'
            ]);

        } catch (Exception $e) {
            Log::error('Sync failed:', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Sync failed: ' . $e->getMessage()
            ]);
        }
    }

    public function verifyPassword(Request $request)
    {
        $password = $request->input('password');
        $correctPassword = trim(config('sync.password'));

        if ($password === $correctPassword) {
            return response()->json(['success' => true]);
        }

        return response()->json(['success' => false, 'message' => 'Invalid password']);
    }
}
