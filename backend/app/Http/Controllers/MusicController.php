<?php

namespace App\Http\Controllers;

use Exception;
use App\Models\Media;
use Illuminate\Http\Request;
use App\Services\SpotifyService;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

class MusicController extends Controller
{
    protected $spotify;

    public function __construct(SpotifyService $spotify)
    {
        $this->spotify = $spotify;
    }
    public function index()
    {
        $music = Media::where('type', 'audio')->paginate(10);
        return view('music.index', compact('music'));
    }

    public function show(Media $music)
    {
        return view('music.show', compact('music'));
    }

    public function syncMusic()
    {
        try {
            $files = Storage::disk('public')->files('media/musics');

            $syncCount = 0;
            $enrichedCount = 0;
            $failedEnrich = 0;

            foreach ($files as $file) {
                $fileName = basename($file);
                $filePath = 'storage/' . $file;

                // Cek apakah media sudah ada
                $existingMedia = Media::where('file_path', $filePath)->first();

                if ($existingMedia) {
                    // PERBAIKAN: Cek apakah metadata Spotify sudah lengkap
                    if (empty($existingMedia->artist) || empty($existingMedia->album) || empty($existingMedia->thumbnail)) {
                        Log::info("Re-enriching incomplete music metadata: {$existingMedia->title}");

                        if ($this->spotify->enrich($existingMedia)) {
                            $enrichedCount++;
                            Log::info("Successfully enriched: {$existingMedia->title}");
                        } else {
                            $failedEnrich++;
                            Log::warning("Failed to enrich: {$existingMedia->title}");
                        }
                    } else {
                        Log::info("Skipping - metadata already complete: {$existingMedia->title}");
                    }
                    continue;
                }

                $title = pathinfo($fileName, PATHINFO_FILENAME);
                $getID3 = new \getID3;
                $filePathAbsolute = Storage::disk('public')->path($file);
                $info = $getID3->analyze($filePathAbsolute);
                $duration = isset($info['playtime_seconds']) ? intval($info['playtime_seconds']) : null;

                $media = Media::create([
                    'title' => ucfirst(str_replace(['_', '-'], ' ', $title)),
                    'file_path' => $filePath,
                    'type' => 'audio',
                    'thumbnail' => null,
                    'duration' => $duration,
                    'description' => null,
                    'rating' => null,
                    'release_date' => null,
                    'language' => null,
                    'tmdb_id' => null,
                    'artist' => null,
                    'album' => null,
                ]);

                $syncCount++;

                // PERBAIKAN: Cek hasil enrich
                Log::info("Attempting to enrich new music: {$media->title}");

                if ($this->spotify->enrich($media)) {
                    $enrichedCount++;
                    Log::info("Successfully enriched new music: {$media->title}");
                } else {
                    $failedEnrich++;
                    Log::warning("Failed to enrich new music: {$media->title}");
                }
            }

            return response()->json([
                'success' => true,
                'message' => "Music sync completed! New: {$syncCount}, Enriched: {$enrichedCount}, Failed: {$failedEnrich}",
                'stats' => [
                    'new_songs' => $syncCount,
                    'enriched' => $enrichedCount,
                    'failed_enrich' => $failedEnrich
                ]
            ]);
        } catch (Exception $e) {
            Log::error('Music sync failed:', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Sync failed: ' . $e->getMessage()
            ]);
        }
    }

    public function search(Request $request)
    {
        $query = $request->input('q');

        $music = Media::where('type', 'audio')
            ->where(function ($q) use ($query) {
                $q->where('title', 'like', "%{$query}%")
                  ->orWhere('description', 'like', "%{$query}%");
            })
            ->get();

        return view('music.search', compact('music', 'query'));
    }

    public function artist($artist)
    {
        $music = Media::where('artist', $artist)->get();

        return view('music.artist', compact('artist', 'music'));
    }

    public function allArtists(Request $request)
    {
        $search = $request->get('search');
        $perPage = $request->get('per_page', 24);

        $query = Media::select('artist')
            ->distinct()
            ->whereNotNull('artist')
            ->where('artist', '!=', '');

        if ($search) {
            $query->where('artist', 'LIKE', '%' . $search . '%');
        }

        $artists = $query->orderBy('artist', 'asc')
            ->paginate($perPage)
            ->appends($request->query());

        $artists->getCollection()->transform(function ($item) {
            return $item->artist;
        });

        return view('music.all-artist', compact('artists'));
    }

    public function downloadFromYoutube(Request $request)
    {
        $url = $request->input('url');

        $script = base_path('scripts/download_music.py');

        $escapedUrl = escapeshellarg($url);

        $output = shell_exec("python3 $script $escapedUrl");

        return back()->with('status', 'Download in progress or completed!');
    }

    public function verifyPassword(Request $request)
    {
        $inputPassword = trim($request->password);
        $expectedPassword = trim(config('sync.password'));

        Log::info('Input Password: ' . $inputPassword);
        Log::info('Expected Password: ' . $expectedPassword);
        Log::info('Equal?: ' . ($inputPassword === $expectedPassword ? 'YES' : 'NO'));

        if ($inputPassword !== $expectedPassword) {
            return response()->json(['success' => false, 'message' => 'Invalid password.']);
        }

        return response()->json(['success' => true]);
    }



}
