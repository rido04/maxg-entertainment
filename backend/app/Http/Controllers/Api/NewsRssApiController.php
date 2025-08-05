<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Services\RssNewsService;
use App\Http\Controllers\Controller;

class NewsRssApiController extends Controller
{
    protected $rssNewsService;

    public function __construct(RssNewsService $rssNewsService)
    {
        $this->rssNewsService = $rssNewsService;
    }

    /**
     * Get all latest news articles
     */
    public function index(Request $request)
    {
        $limit = $request->query('limit', 20);
        $category = $request->query('category');

        $articles = $this->rssNewsService->getLatest($limit, $category);

        return response()->json([
            'success' => true,
            'data' => $articles->map(function ($article) {
                return [
                    'id' => $article->id,
                    'title' => $article->title,
                    'description' => $article->description,
                    'content' => $article->content ?? null,
                    'category' => $article->category,
                    'slug' => $article->slug,
                    'image_url' => $article->urlToImage,
                    'source_url' => $article->url,
                    'published_at' => $article->published_at->toIso8601String(),
                    'created_at' => $article->created_at->toIso8601String(),
                ];
            }),
            'meta' => [
                'count' => $articles->count(),
                'category' => $category,
                'limit' => $limit
            ]
        ]);
    }

    /**
     * Get news by specific category
     */
    public function category(Request $request, $category)
    {
        // Validasi kategori yang diizinkan
        if (!in_array($category, ['sports', 'entertainment', 'politics'])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid category. Available: sports, entertainment, politics'
            ], 400);
        }

        $limit = $request->query('limit', 12);
        $articles = $this->rssNewsService->getLatest($limit, $category);

        return response()->json([
            'success' => true,
            'data' => $articles->map(function ($article) {
                return [
                    'id' => $article->id,
                    'title' => $article->title,
                    'description' => $article->description,
                    'content' => $article->content ?? null,
                    'category' => $article->category,
                    'slug' => $article->slug,
                    'image_url' => $article->urlToImage,
                    'source_url' => $article->url,
                    'published_at' => $article->published_at->toIso8601String(),
                ];
            }),
            'meta' => [
                'category' => $category,
                'count' => $articles->count(),
                'limit' => $limit
            ]
        ]);
    }

    /**
     * Get paginated news articles
     */
    public function paginated(Request $request)
    {
        $perPage = $request->query('per_page', 12);
        $category = $request->query('category');

        $articles = $this->rssNewsService->getPaginated($perPage, $category);

        return response()->json([
            'success' => true,
            'data' => $articles->items()->map(function ($article) {
                return [
                    'id' => $article->id,
                    'title' => $article->title,
                    'description' => $article->description,
                    'content' => $article->content ?? null,
                    'category' => $article->category,
                    'slug' => $article->slug,
                    'image_url' => $article->urlToImage,
                    'source_url' => $article->url,
                    'published_at' => $article->published_at->toIso8601String(),
                ];
            }),
            'meta' => [
                'current_page' => $articles->currentPage(),
                'last_page' => $articles->lastPage(),
                'per_page' => $articles->perPage(),
                'total' => $articles->total(),
                'from' => $articles->firstItem(),
                'to' => $articles->lastItem(),
                'category' => $category
            ]
        ]);
    }

    /**
     * Get popular/trending articles
     */
    public function popular(Request $request)
    {
        $limit = $request->query('limit', 10);
        $category = $request->query('category');

        $articles = $this->rssNewsService->getPopular($limit, $category);

        return response()->json([
            'success' => true,
            'data' => $articles->map(function ($article) {
                return [
                    'id' => $article->id,
                    'title' => $article->title,
                    'description' => $article->description,
                    'category' => $article->category,
                    'slug' => $article->slug,
                    'image_url' => $article->urlToImage,
                    'source_url' => $article->url,
                    'published_at' => $article->published_at->toIso8601String(),
                ];
            }),
            'meta' => [
                'count' => $articles->count(),
                'category' => $category,
                'limit' => $limit,
                'type' => 'popular'
            ]
        ]);
    }

    /**
     * Get single article by slug
     */
    public function show($slug)
    {
        $article = \App\Models\News::where('slug', $slug)->first();

        if (!$article) {
            return response()->json([
                'success' => false,
                'message' => 'Article not found'
            ], 404);
        }

        // Get related articles
        $relatedArticles = $this->rssNewsService->getLatest(5, $article->category);
        $relatedArticles = $relatedArticles->where('id', '!=', $article->id);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $article->id,
                'title' => $article->title,
                'description' => $article->description,
                'content' => $article->content ?? null,
                'category' => $article->category,
                'slug' => $article->slug,
                'image_url' => $article->urlToImage,
                'source_url' => $article->url,
                'published_at' => $article->published_at->toIso8601String(),
                'created_at' => $article->created_at->toIso8601String(),
            ],
            'related' => $relatedArticles->map(function ($related) {
                return [
                    'id' => $related->id,
                    'title' => $related->title,
                    'slug' => $related->slug,
                    'image_url' => $related->urlToImage,
                    'published_at' => $related->published_at->toIso8601String(),
                ];
            })
        ]);
    }

    /**
     * Get news statistics
     */
    public function stats()
    {
        $stats = $this->rssNewsService->getStats();

        return response()->json([
            'success' => true,
            'data' => $stats,
            'generated_at' => now()->toIso8601String()
        ]);
    }

    /**
     * Search articles
     */
    public function search(Request $request)
    {
        $query = $request->query('q');
        $category = $request->query('category');
        $limit = $request->query('limit', 20);

        if (!$query) {
            return response()->json([
                'success' => false,
                'message' => 'Search query is required'
            ], 400);
        }

        $articles = \App\Models\News::where('title', 'LIKE', "%{$query}%")
            ->orWhere('description', 'LIKE', "%{$query}%");

        if ($category) {
            $articles->where('category', $category);
        }

        $articles = $articles->orderBy('published_at', 'desc')
            ->take($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $articles->map(function ($article) {
                return [
                    'id' => $article->id,
                    'title' => $article->title,
                    'description' => $article->description,
                    'category' => $article->category,
                    'slug' => $article->slug,
                    'image_url' => $article->urlToImage,
                    'source_url' => $article->url,
                    'published_at' => $article->published_at->toIso8601String(),
                ];
            }),
            'meta' => [
                'query' => $query,
                'category' => $category,
                'count' => $articles->count(),
                'limit' => $limit
            ]
        ]);
    }
}
