<?php

use App\Models\Media;
use App\Models\NewsArticle;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GameController;
use App\Http\Controllers\MusicController;
use App\Http\Controllers\VideoController;
use App\Http\Controllers\Api\NewsController;
use App\Http\Controllers\Api\MediaController;
use App\Http\Controllers\Api\NewsRssApiController;

// News Route
// Route::get('/news', [NewsController::class, 'index'])->name('news.index');

// Inflight Routes
Route::get('/plane-track', function () {
    $data = json_decode(file_get_contents(public_path('rute.json')), true);

    $index = cache()->get('plane_index', 0);
    $point = $data[$index] ?? end($data);

    // Next index
    $nextIndex = $index + 1;
    if ($nextIndex >= count($data)) {
        $nextIndex = count($data) - 1; // stop di akhir
    }

    cache()->put('plane_index', $nextIndex, now()->addSeconds(5));

    return response()->json($point);
});
Route::get('/games', [GameController::class, 'api']);
Route::get('/games/list', [GameController::class, 'list']);

Route::get('/media', [MediaController::class, 'index']);
Route::get('/download/{filename}', function ($filename) {
    return response()->download(storage_path('app/public/media/videos/' . $filename));
});
Route::get('/download/{filename}', function ($filename) {
    return response()->download(storage_path('app/public/media/musics/' . $filename));
});
Route::get('/news', function () {
    return NewsArticle::latest('published_at')
        ->get()
        ->map(function ($article) {
            return [
                'id' => $article->id,
                'title' => $article->title,
                'description' => $article->description,
                'category' => $article->category,
                'image_url' => $article->image_url,
                'file_url' => $article->file_url,
                'published_at' => $article->published_at->toIso8601String(),
            ];
        });
});

Route::prefix('news')->group(function () {
    // Get all news dengan parameter opsional
    Route::get('/', [NewsRssApiController::class, 'index']);

    // Get news dengan pagination
    Route::get('/paginated', [NewsRssApiController::class, 'paginated']);

    // Get popular/trending news
    Route::get('/popular', [NewsRssApiController::class, 'popular']);

    // Get news statistics
    Route::get('/stats', [NewsRssApiController::class, 'stats']);

    // Search news
    Route::get('/search', [NewsRssApiController::class, 'search']);

    // Get news by category
    Route::get('/category/{category}', [NewsRssApiController::class, 'category']);

    // Get single article by slug
    Route::get('/{slug}', [NewsRssApiController::class, 'show']);
});


