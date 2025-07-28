<?php

use App\Models\Media;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GameController;
use App\Http\Controllers\MusicController;
use App\Http\Controllers\VideoController;
use App\Http\Controllers\Api\NewsController;
use App\Http\Controllers\Api\MediaController;

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

