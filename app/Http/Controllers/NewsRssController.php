<?php

namespace App\Http\Controllers;

use App\Models\News;
use Illuminate\Http\Request;
use App\Services\RssNewsService;

class NewsRssController extends Controller
{
    protected $rssNewsService;

    public function __construct(RssNewsService $rssNewsService)
    {
        $this->rssNewsService = $rssNewsService;
    }

    /**
     * Display the main news page
     */
    public function index()
    {
        // Get articles by category for the homepage
        $sports = $this->rssNewsService->getLatest(12, 'sports');
        $politics = $this->rssNewsService->getLatest(10, 'politics');
        $entertainment = $this->rssNewsService->getLatest(10, 'entertainment');

        return view('news.index', compact('sports', 'politics', 'entertainment'));
    }

    /**
     * Display a single news article
     */
    public function show($slug)
    {
        $article = News::where('slug', $slug)->firstOrFail();

        // Get related articles from the same category
        $relatedArticles = News::where('category', $article->category)
            ->where('id', '!=', $article->id)
            ->orderBy('published_at', 'desc')
            ->take(5)
            ->get();

        return view('news.show', compact('article', 'relatedArticles'));
    }

    /**
     * Display articles by category
     */
    public function category($category)
    {
        $articles = News::where('category', $category)
            ->orderBy('published_at', 'desc')
            ->paginate(12);

        $categoryName = ucfirst($category);

        // Gunakan view spesifik berdasarkan kategori
        switch($category) {
            case 'sports':
                return view('news.sports', compact('articles'));
            case 'politics':
                return view('news.politics', compact('articles'));
            case 'entertainment':
                return view('news.entertainment', compact('articles'));
            default:
                // Fallback ke view umum atau redirect
                return redirect()->route('news.index');
        }
    }

    /**
     * Display sports articles
     */
    public function sports()
    {
        $articles = News::where('category', 'sports')
            ->orderBy('published_at', 'desc')
            ->paginate(12);

        return view('news.sports', compact('articles'));
    }

    /**
     * Display politics articles
     */
    public function politics()
    {
        $articles = News::where('category', 'politics')
            ->orderBy('published_at', 'desc')
            ->paginate(12);

        return view('news.politics', compact('articles'));
    }

    /**
     * Display entertainment articles
     */
    public function entertainment()
    {
        $articles = News::where('category', 'entertainment')
            ->orderBy('published_at', 'desc')
            ->paginate(12);

        return view('news.entertainment', compact('articles'));
    }

    /**
     * Search articles
     */
    public function search(Request $request)
    {
        $query = $request->get('q');

        $articles = News::where('title', 'LIKE', "%{$query}%")
            ->orWhere('description', 'LIKE', "%{$query}%")
            ->orderBy('published_at', 'desc')
            ->paginate(12);

        return view('news.search', compact('articles', 'query'));
    }
}
