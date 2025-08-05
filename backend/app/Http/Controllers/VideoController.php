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
use Illuminate\Support\Facades\DB;

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
                    ->where('is_adult_content', false)
                    ->get();

        return view('videos.search', [
            'videos' => $videos,
        ]);
    }

    public function index(Request $request)
    {
        $category = $request->input('category');
        $perPage = 4; // 4 items per page (sesuai chunk sebelumnya)

        $query = Media::where('type', 'video')
                    ->where('is_adult_content', false);

        if ($category) {
            $query->where('category', 'LIKE', '%' . $category . '%');
        }

        // Menggunakan paginate dengan append query parameters
        $videos = $query->paginate($perPage, ['*'], 'page', $request->input('page', 1));

        // Append existing query parameters ke pagination links
        $videos->appends($request->query());

        // Ambil semua kategori unik dari database
        $categories = Media::where('type', 'video')
                        ->where('is_adult_content', false)
                        ->whereNotNull('category')
                        ->where('category', '!=', '')
                        ->get()
                        ->pluck('category')
                        ->flatMap(function ($category) {
                            return explode(', ', $category);
                        })
                        ->unique()
                        ->sort()
                        ->values();

        return view('videos.index', compact('videos', 'category', 'categories'));
    }

    public function show(Media $video)
    {
        // Additional check untuk memastikan konten tidak adult
        if ($video->is_adult_content && !config('app.allow_adult_content', false)) {
            abort(403, 'Content not available');
        }

        $tmdbId = $video->tmdb_id ?? null;
        $movieDetail = null;
        $movieCredits = null;

        if ($tmdbId) {
            $movieDetail = $this->tmdb->getMovieDetail($tmdbId);
            $movieCredits = $this->tmdb->getMovieCredits($tmdbId);
        }

        return view('videos.show', compact('video', 'movieDetail', 'movieCredits'));
    }

    public function sync()
    {
        try {
            $files = Storage::disk('public')->files('media/videos');

            $processedCount = 0;
            $skippedCount = 0;
            $errorCount = 0;

            Log::info('Starting sync process', ['total_files' => count($files)]);

            foreach ($files as $file) {
                try {
                    // Wrap setiap file processing dalam transaction terpisah
                    DB::beginTransaction();

                    $result = $this->processVideoFile($file);

                    if ($result['status'] === 'processed') {
                        $processedCount++;
                        DB::commit();
                    } elseif ($result['status'] === 'skipped') {
                        $skippedCount++;
                        DB::rollBack(); // Rollback karena tidak ada perubahan
                    }

                    Log::info('File processed:', [
                        'file' => $file,
                        'status' => $result['status'],
                        'message' => $result['message']
                    ]);

                } catch (Exception $e) {
                    $errorCount++;
                    DB::rollBack();
                    Log::error('Error processing file:', [
                        'file' => $file,
                        'error' => $e->getMessage(),
                        'trace' => $e->getTraceAsString()
                    ]);
                }
            }

            return response()->json([
                'success' => true,
                'message' => "Sync completed! Processed: {$processedCount}, Skipped: {$skippedCount}, Errors: {$errorCount}",
                'stats' => [
                    'processed' => $processedCount,
                    'skipped' => $skippedCount,
                    'errors' => $errorCount
                ]
            ]);

        } catch (Exception $e) {
            Log::error('Sync failed:', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Sync failed: ' . $e->getMessage()
            ], 500);
        }
    }

    private function processVideoFile($file)
    {
        $fileName = basename($file);
        $filePath = 'storage/' . $file;

        Log::info('Processing file:', ['file' => $fileName, 'path' => $filePath]);

        // PERBAIKAN 1: Pengecekan duplikasi yang lebih ketat - prioritas utama file_path
        $existingByPath = Media::where('file_path', $filePath)->first();

        if ($existingByPath) {
            Log::info('File skipped - already exists by path:', ['file' => $fileName]);
            return [
                'status' => 'skipped',
                'message' => 'File already exists in database (same path)'
            ];
        }

        // Extract title dan year dari filename
        $titleData = $this->extractTitleFromFilename($fileName);
        $year = $this->extractYearFromFilename($fileName);

        Log::info('Extracted data:', ['title' => $titleData, 'year' => $year]);

        // PERBAIKAN 2: Pengecekan duplikasi berdasarkan title+year (lebih akurat)
        if (!empty($titleData)) {
            $duplicateQuery = Media::where('title', $titleData)->where('type', 'video');

            if ($year) {
                // Jika ada year, cek kombinasi title+year
                $duplicateQuery->where(function($query) use ($year) {
                    $query->whereYear('release_date', $year)
                          ->orWhereNull('release_date'); // Include records tanpa release_date
                });
            }

            $existingByTitle = $duplicateQuery->first();

            if ($existingByTitle) {
                Log::info('File skipped - duplicate title found:', [
                    'file' => $fileName,
                    'existing_id' => $existingByTitle->id,
                    'existing_path' => $existingByTitle->file_path
                ]);
                return [
                    'status' => 'skipped',
                    'message' => "Movie already exists: '{$titleData}'" . ($year ? " ({$year})" : '')
                ];
            }
        }

        // Get file metadata
        $fileMetadata = $this->getFileMetadata($file);
        Log::info('File metadata:', $fileMetadata);

        // Get TMDB data
        $tmdbData = $this->getTmdbData($titleData, $year);

        if ($tmdbData) {
            Log::info('TMDB data found:', ['tmdb_id' => $tmdbData['tmdb_id']]);
        } else {
            Log::info('No TMDB data found for:', ['title' => $titleData, 'year' => $year]);
        }

        // Validate content appropriateness
        if ($tmdbData && !$this->isContentAppropriate($tmdbData)) {
            Log::info('File skipped - inappropriate content:', ['file' => $fileName]);
            return [
                'status' => 'skipped',
                'message' => 'Content is not appropriate (adult/restricted)'
            ];
        }

        // PERBAIKAN 3: Gunakan updateOrCreate untuk menghindari race condition
        $mediaData = $this->buildMediaData($titleData, $filePath, $fileMetadata, $tmdbData);

        try {
            $savedMedia = Media::updateOrCreate(
                [
                    'file_path' => $filePath // Primary key untuk pengecekan
                ],
                $mediaData
            );

            Log::info('Media saved to DB:', [
                'id' => $savedMedia->id,
                'title' => $savedMedia->title,
                'file_path' => $savedMedia->file_path,
                'tmdb_id' => $savedMedia->tmdb_id,
                'is_adult_content' => $savedMedia->is_adult_content,
                'cast' => $savedMedia->cast,
                'director' => $savedMedia->director,
                'was_recently_created' => $savedMedia->wasRecentlyCreated
            ]);

            return [
                'status' => 'processed',
                'message' => $savedMedia->wasRecentlyCreated ? 'File processed successfully' : 'File updated successfully',
                'media_id' => $savedMedia->id
            ];

        } catch (Exception $e) {
            Log::error('Failed to save media:', [
                'file' => $fileName,
                'error' => $e->getMessage(),
                'data' => $mediaData
            ]);
            throw $e;
        }
    }

    private function extractTitleFromFilename($fileName)
    {
        $rawTitle = pathinfo($fileName, PATHINFO_FILENAME);

        // PERBAIKAN 4: Ekstraksi title yang lebih konsisten
        // Replace underscores, dots, and hyphens with spaces
        $formattedTitle = preg_replace('/[._\-]+/', ' ', $rawTitle);

        // Remove year dalam parentheses
        $formattedTitle = preg_replace('/\s*\(\d{4}\)\s*/', '', $formattedTitle);

        // Remove common quality/source tags
        $formattedTitle = preg_replace('/\s*(1080p|720p|480p|4K|BluRay|WEB-DL|HDRip|BRRip|DVDRip|CAMRip|HDCAM|WEBRIP)\s*/i', ' ', $formattedTitle);

        // Remove extra whitespace and capitalize properly
        $formattedTitle = preg_replace('/\s+/', ' ', $formattedTitle);
        $formattedTitle = trim($formattedTitle);

        // Capitalize first letter of each word
        return ucwords(strtolower($formattedTitle));
    }

    private function extractYearFromFilename($fileName)
    {
        $rawTitle = pathinfo($fileName, PATHINFO_FILENAME);

        // Look for year in parentheses first: (2020)
        if (preg_match('/\((\d{4})\)/', $rawTitle, $matches)) {
            $year = (int) $matches[1];
            // Validate year range (reasonable movie years)
            if ($year >= 1900 && $year <= date('Y') + 2) {
                return $year;
            }
        }

        // Look for year without parentheses: Movie 2020
        if (preg_match('/\s(\d{4})\s/', $rawTitle . ' ', $matches)) {
            $year = (int) $matches[1];
            if ($year >= 1900 && $year <= date('Y') + 2) {
                return $year;
            }
        }

        return null;
    }

    private function getFileMetadata($file)
    {
        try {
            $getID3 = new getID3;
            $filePathAbsolute = Storage::disk('public')->path($file);

            if (!file_exists($filePathAbsolute)) {
                throw new Exception("File not found: {$filePathAbsolute}");
            }

            $info = $getID3->analyze($filePathAbsolute);

            $metadata = [
                'duration' => isset($info['playtime_seconds']) ? intval($info['playtime_seconds'] / 60) : null,
                'file_size' => $info['filesize'] ?? null,
                'video_codec' => $info['video']['codec'] ?? null,
                'audio_codec' => $info['audio']['codec'] ?? null,
            ];

            Log::info('File metadata extracted:', $metadata);
            return $metadata;

        } catch (Exception $e) {
            Log::warning('Failed to get file metadata:', [
                'file' => $file,
                'error' => $e->getMessage()
            ]);

            // Return default values instead of null
            return [
                'duration' => null,
                'file_size' => Storage::disk('public')->size($file) ?? null,
                'video_codec' => null,
                'audio_codec' => null,
            ];
        }
    }

    private function getTmdbData($title, $year = null)
    {
        try {
            if (empty($title)) {
                return null;
            }

            Log::info('Searching TMDB for:', ['title' => $title, 'year' => $year]);

            $search = $this->tmdb->searchMovieWithFilters($title, $year, false);

            if (!$search || !isset($search['results']) || count($search['results']) === 0) {
                Log::info('No TMDB results found');
                return null;
            }

            $movie = $search['results'][0];
            $tmdbId = (string) ($movie['id'] ?? null);

            if (!$tmdbId) {
                Log::warning('TMDB ID not found in search results');
                return null;
            }

            // Get detailed movie info dan credits
            $movieDetail = $this->tmdb->getMovieDetail($tmdbId);
            $credits = $this->tmdb->getMovieCredits($tmdbId);
            $castData = $this->tmdb->processCastData($credits ?? []);
            $contentRating = $this->tmdb->getContentRating($tmdbId);

            $tmdbData = [
                'basic' => $movie,
                'detail' => $movieDetail,
                'credits' => $credits,
                'cast_data' => $castData,
                'content_rating' => $contentRating,
                'tmdb_id' => $tmdbId
            ];

            Log::info('TMDB data retrieved successfully:', [
                'tmdb_id' => $tmdbId,
                'title' => $movie['title'] ?? 'Unknown',
                'cast_count' => count($credits['cast'] ?? []),
                'director' => $castData['director']
            ]);
            return $tmdbData;

        } catch (Exception $e) {
            Log::warning('Failed to get TMDB data:', [
                'title' => $title,
                'year' => $year,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    private function isContentAppropriate($tmdbData)
    {
        if (!$tmdbData) {
            return true; // Allow if no TMDB data
        }

        $movie = $tmdbData['basic'];
        $contentRating = $tmdbData['content_rating'];

        // Check adult flag
        if ($movie['adult'] ?? false) {
            Log::info('Content marked as adult');
            return false;
        }

        // Check content rating
        if ($this->tmdb->isRatingRestricted($contentRating)) {
            Log::info('Content rating is restricted:', ['rating' => $contentRating]);
            return false;
        }

        // Additional check using TMDB service
        if (!$this->tmdb->isContentAppropriate($movie)) {
            Log::info('Content deemed inappropriate by TMDB service');
            return false;
        }

        return true;
    }

    private function buildMediaData($title, $filePath, $fileMetadata, $tmdbData)
    {
        $mediaData = [
            'title' => $title ?: 'Unknown Title',
            'file_path' => $filePath,
            'type' => 'video',
            'duration' => $fileMetadata['duration'],
            'tmdb_id' => null,
            'description' => null,
            'rating' => null,
            'release_date' => null,
            'language' => null,
            'thumbnail' => null,
            'category' => 'Unknown',
            'is_adult_content' => false,
            'content_rating' => null,
            'cast' => null,
            'cast_json' => null,
            'director' => null,
            'writers' => null,
        ];

        if ($tmdbData) {
            $movie = $tmdbData['basic'];
            $movieDetail = $tmdbData['detail'];
            $castData = $tmdbData['cast_data'];
            $contentRating = $tmdbData['content_rating'];

            $mediaData = array_merge($mediaData, [
                'tmdb_id' => $tmdbData['tmdb_id'],
                'title' => $movie['title'] ?? $title, // Prefer TMDB title
                'description' => $movie['overview'] ?? null,
                'rating' => isset($movie['vote_average']) ? round((float) $movie['vote_average'], 1) : null,
                'release_date' => $movie['release_date'] ?? null,
                'language' => $movie['original_language'] ?? null,
                'is_adult_content' => $movie['adult'] ?? false,
                'content_rating' => $contentRating,
                'thumbnail' => $movie['poster_path']
                    ? 'https://image.tmdb.org/t/p/w500' . $movie['poster_path']
                    : null,
                'duration' => $movieDetail['runtime'] ?? $fileMetadata['duration'],
                'cast' => $castData['cast_string'],
                'cast_json' => $castData['cast_json'],
                'director' => $castData['director'],
                'writers' => $castData['writers'],
            ]);

            // Process genres
            $genres = $movie['genre_ids'] ?? [];
            if (count($genres) > 0) {
                $categoryNames = array_map(function ($genreId) {
                    return $this->tmdb->getGenreName($genreId);
                }, $genres);
                $categoryNames = array_filter($categoryNames); // Remove empty values
                $mediaData['category'] = count($categoryNames) > 0 ? implode(', ', $categoryNames) : 'Unknown';
            }
        }

        return $mediaData;
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

    // PERBAIKAN 5: Method cleanup yang lebih aman
    public function cleanupDuplicates()
    {
        try {
            DB::beginTransaction();

            // Find duplicates berdasarkan file_path (yang seharusnya unique)
            $duplicatesByPath = Media::select('file_path', DB::raw('COUNT(*) as count'))
                                   ->where('type', 'video')
                                   ->groupBy('file_path')
                                   ->havingRaw('COUNT(*) > 1')
                                   ->get();

            $cleanedCount = 0;

            foreach ($duplicatesByPath as $duplicate) {
                $entries = Media::where('file_path', $duplicate->file_path)
                              ->where('type', 'video')
                              ->orderBy('updated_at', 'desc') // Keep the most recently updated
                              ->get();

                // Keep the first (most recent), delete the rest
                $entries->skip(1)->each(function ($entry) use (&$cleanedCount) {
                    Log::info('Deleting duplicate entry:', [
                        'id' => $entry->id,
                        'title' => $entry->title,
                        'file_path' => $entry->file_path
                    ]);
                    $entry->delete();
                    $cleanedCount++;
                });
            }

            // Find duplicates berdasarkan title+year (optional cleanup)
            $duplicatesByTitle = Media::select('title', 'release_date', DB::raw('COUNT(*) as count'))
                                    ->where('type', 'video')
                                    ->whereNotNull('title')
                                    ->groupBy('title', 'release_date')
                                    ->havingRaw('COUNT(*) > 1')
                                    ->get();

            foreach ($duplicatesByTitle as $duplicate) {
                $entries = Media::where('title', $duplicate->title)
                              ->where('type', 'video')
                              ->where('release_date', $duplicate->release_date)
                              ->orderBy('tmdb_id', 'desc') // Prefer entries with TMDB data
                              ->orderBy('updated_at', 'desc')
                              ->get();

                if ($entries->count() > 1) {
                    // Keep the first one, delete others only if they have the same file_path pattern
                    $keeper = $entries->first();
                    $entries->skip(1)->each(function ($entry) use ($keeper, &$cleanedCount) {
                        // Only delete if it's clearly a duplicate (similar file paths or no TMDB data)
                        if (!$entry->tmdb_id || dirname($entry->file_path) === dirname($keeper->file_path)) {
                            Log::info('Deleting title duplicate:', [
                                'id' => $entry->id,
                                'title' => $entry->title,
                                'file_path' => $entry->file_path
                            ]);
                            $entry->delete();
                            $cleanedCount++;
                        }
                    });
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => "Cleanup completed. Removed {$cleanedCount} duplicate entries.",
                'cleaned_count' => $cleanedCount
            ]);

        } catch (Exception $e) {
            DB::rollBack();
            Log::error('Cleanup failed:', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Cleanup failed: ' . $e->getMessage()
            ], 500);
        }
    }

    private function convertToStarRating($tmdbRating)
    {
        if (!$tmdbRating || $tmdbRating <= 0) {
            return 0;
        }

        return round($tmdbRating / 2, 1);
    }

    /**
     * Get star rating data for view
     */
    private function getStarRatingData($rating)
    {
        $starRating = $this->convertToStarRating($rating);

        return [
            'star_rating' => $starRating,
            'full_stars' => floor($starRating),
            'has_partial_star' => ($starRating - floor($starRating)) >= 0.5,
            'empty_stars' => 5 - floor($starRating) - (($starRating - floor($starRating)) >= 0.5 ? 1 : 0),
            'percentage' => $starRating > 0 ? ($starRating / 5) * 100 : 0
        ];
    }
    /**
     * Update media yang sudah ada dengan data TMDb yang lebih lengkap
     */
    public function updateExistingMedia()
    {
        try {
            $mediasToUpdate = Media::where('type', 'video')
                                  ->whereNotNull('tmdb_id')
                                  ->where(function($query) {
                                      $query->whereNull('cast')
                                            ->orWhereNull('director')
                                            ->orWhereNull('writers');
                                  })
                                  ->limit(50) // Batch processing
                                  ->get();

            $updatedCount = 0;
            $errorCount = 0;

            foreach ($mediasToUpdate as $media) {
                try {
                    if ($this->tmdb->updateMediaWithTmdbData($media)) {
                        $updatedCount++;
                        Log::info('Updated media with cast/crew data:', [
                            'id' => $media->id,
                            'title' => $media->title
                        ]);
                    }
                } catch (Exception $e) {
                    $errorCount++;
                    Log::error('Failed to update media:', [
                        'id' => $media->id,
                        'error' => $e->getMessage()
                    ]);
                }
            }

            return response()->json([
                'success' => true,
                'message' => "Updated {$updatedCount} media entries with cast/crew data. Errors: {$errorCount}",
                'updated_count' => $updatedCount,
                'error_count' => $errorCount
            ]);

        } catch (Exception $e) {
            Log::error('Update existing media failed:', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Update failed: ' . $e->getMessage()
            ], 500);
        }
    }
}
