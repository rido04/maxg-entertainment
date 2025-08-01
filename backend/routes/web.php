<?php

use App\Models\Media;
use Spatie\PdfToImage\Pdf;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Artisan;
use App\Http\Controllers\GameController;
use App\Http\Controllers\AboutController;
use App\Http\Controllers\MusicController;
use App\Http\Controllers\RouteController;
use App\Http\Controllers\VideoController;
use App\Http\Controllers\NewsRssController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\FeedbackController;
use App\Http\Controllers\NewsPageController;

Route::get('/', function () {
    $media = Media::all();
    return view('welcome', compact('media'));
});

// Movies Route
Route::get('/videos', [VideoController::class, 'index'])->name('videos.index');
Route::get('/videos/{video}', [VideoController::class, 'show'])->name('videos.show');
Route::get('/search-movie', [VideoController::class, 'search']);
Route::get('/sync-videos', [VideoController::class, 'sync']);
Route::get('/update-videos', [VideoController::class, 'updateFromTmdb'])->name('videos.update');
Route::post('/videos/verify-password', [VideoController::class, 'verifyPassword']);

// Music Route
Route::get('/music/sync', [MusicController::class, 'syncMusic']);
Route::get('/music', [MusicController::class, 'index'])->name('music.index');
Route::get('/music/{music}', [MusicController::class, 'show'])->name('music.show');
Route::get('/artist/all', [MusicController::class, 'allArtists'])->name('music.all-artist');
Route::get('/artist/{artist}', [MusicController::class, 'artist'])->name('artist.show');
// Route::get('/music/{id}', [MusicController::class, 'show'])->name('music.show');
Route::get('/search-music', [MusicController::class, 'search'])->name('music.search');
Route::post('/music/verify-password', [MusicController::class, 'verifyPassword']);

// Game Route
Route::get('/games', [GameController::class, 'index'])->name('games.index');
Route::get('/games/tictactoe', [GameController::class, 'tictactoe'])->name('games.tictactoe');
Route::get('/games/snake', [GameController::class, 'snake'])->name('games.snake');
Route::get('/games/tetris', [GameController::class, 'tetris'])->name('games.tetris');
Route::get('/games/dino', [GameController::class, 'dino'])->name('games.dino');
Route::get('/games/floppybird', [GameController::class, 'floppybird'])->name('games.floppybird');
Route::get('/games/candy-crush', [GameController::class, 'candycrush'])->name('games.candycrush');
Route::get('games/2048', [GameController::class, 'the2048'])->name('games.2048');
// About Route
Route::get('/about', [AboutController::class, 'index'])->name('about');

// News Route
Route::prefix('news')->name('news.')->group(function () {
    Route::get('/', [NewsRssController::class, 'index'])->name('index');
    Route::get('/search', [NewsRssController::class, 'search'])->name('search');
    Route::get('/sports', [NewsRssController::class, 'sports'])->name('sports');
    Route::get('/politics', [NewsRssController::class, 'politics'])->name('politics');
    Route::get('/entertainment', [NewsRssController::class, 'entertainment'])->name('entertainment');
    Route::get('/category/{category}', [NewsRssController::class, 'category'])->name('category');
    Route::get('/{slug}', [NewsRssController::class, 'show'])->name('show');
});

// Shop Routes - Products
Route::prefix('products')->name('products.')->group(function () {
    Route::get('/', [ProductController::class, 'index'])->name('products.index');
    // Halaman utama katalog produk
    Route::get('/', [ProductController::class, 'index'])->name('index');

    // Pencarian produk (harus di atas route detail produk untuk menghindari konflik)
    Route::get('/search', [ProductController::class, 'search'])->name('search');

    // API untuk autocomplete pencarian
    Route::get('/suggestions', [ProductController::class, 'suggestions'])->name('suggestions');

    // Filter produk berdasarkan kategori
    Route::get('/category/{categorySlug}', [ProductController::class, 'category'])->name('category');

    // Redirect ke detail produk berdasarkan SKU
    Route::get('/sku/{sku}', [ProductController::class, 'showBySku'])->name('showBySku');

    // Detail produk berdasarkan slug (harus di paling bawah untuk menghindari konflik)
    Route::get('/{productSlug}', [ProductController::class, 'show'])->name('show');

    // Tambahkan produk ke keranjang
    Route::post('/add-to-cart/{product}', [ProductController::class, 'addToCart'])->name('addToCart');
});

// Route alias untuk backward compatibility
Route::get('/catalog', [ProductController::class, 'index'])->name('catalog');

// Admin Routes (untuk sinkronisasi produk)
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    // Sinkronisasi produk dari file
    Route::post('/products/sync-from-files', [ProductController::class, 'syncFromFiles'])->name('products.sync-from-files');
});
//Route route
Route::get('/route', function () {return view('route');})->name('route');
Route::get('route-minimal', [RouteController::class, 'minimal'])->name('route-minimal');

//Scheduler Route
Route::get('/run-scheduler', function () {
    Artisan::call('schedule:run');
    return response()->json(['status' => 'scheduler triggered']);
});

// Leaflet Map Route
Route::get('/map', function () {
    return view('map');
});


// Feedback Routes
Route::get('/feedback', [FeedbackController::class, 'create'])->name('feedback.create');
Route::post('/feedback', [FeedbackController::class, 'store'])->name('feedback.store');


// testing route
Route::get('/test-thumbnail', function () {
    $sourcePdf = storage_path('app/public/news_files/sample.pdf');
    $outputImage = storage_path('app/public/news_images/sample.jpg');

    $pdf = new Pdf($sourcePdf);
    $pdf->setOutputFormat('jpg');
    $pdf->saveImage($outputImage);

    return 'Thumbnail created: ' . asset('storage/news_images/sample.jpg');
});

