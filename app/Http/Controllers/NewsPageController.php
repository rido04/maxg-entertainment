<?php

namespace App\Http\Controllers;

use App\Models\News;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use App\Services\NewsApiService;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class NewsPageController extends Controller
{
    public function __construct(protected NewsApiService $news) {}

    public function index()
    {
            // Coba cek koneksi internet
        try {
            Http::timeout(2)->get('https://1.1.1.1');
            $this->news->sync();
        } catch (\Exception $e) {
            // Tidak ada koneksi, lewati sync
        }

        return view('news.index', [
            'sports' => News::where('category', 'sports')->latest('published_at')->take(5)->get(),
            'entertainment' => News::where('category', 'entertainment')->latest('published_at')->take(5)->get(),
            'politics' => News::where('category', 'politics')->latest('published_at')->take(5)->get(),
        ]);
    }

    public function show($slug)
    {
        $article = News::where('slug', $slug)->firstOrFail();

        // Get recommended articles
        $relatedArticles = $this->getRelatedArticles($article);

        return view('news.show', compact('article', 'relatedArticles'));
    }

    /**
     * Get related/recommended articles based on current article
     */
    private function getRelatedArticles($currentArticle, $limit = 5)
{
    // Strategy 1: Get 2-3 random articles from same category
    $sameCategory = News::where('category', $currentArticle->category)
        ->where('id', '!=', $currentArticle->id)
        ->inRandomOrder()
        ->take(2)
        ->get();

    // Strategy 2: Get remaining slots with completely random articles
    $remainingSlots = $limit - $sameCategory->count();

    $randomArticles = News::where('id', '!=', $currentArticle->id)
        ->whereNotIn('id', $sameCategory->pluck('id'))
        ->inRandomOrder()
        ->take($remainingSlots)
        ->get();

    // Combine results
    $relatedArticles = $sameCategory->merge($randomArticles);

    // Shuffle the final collection for more randomness
    return $relatedArticles->shuffle();
}
}
