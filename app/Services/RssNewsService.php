<?php

namespace App\Services;

use App\Models\News;

class RssNewsService
{
    /**
     * Create a new class instance.
     */
    public function __construct()
    {
        //
    }

    /**
     * Get latest articles with optional category filter
     */
    public function getLatest($limit = 10, $category = null)
    {
        $query = News::orderBy('published_at', 'desc');

        if ($category) {
            $query->where('category', $category);
        }

        return $query->take($limit)->get();
    }

    /**
     * Get articles by multiple categories
     */
    public function getByCategories(array $categories, $limit = 10)
    {
        return News::whereIn('category', $categories)
            ->orderBy('published_at', 'desc')
            ->take($limit)
            ->get();
    }

    /**
     * Get popular articles (most recent for now, can be enhanced with view counts)
     */
    public function getPopular($limit = 5, $category = null)
    {
        $query = News::orderBy('published_at', 'desc');

        if ($category) {
            $query->where('category', $category);
        }

        return $query->take($limit)->get();
    }

    /**
     * Get articles with pagination
     */
    public function getPaginated($perPage = 12, $category = null)
    {
        $query = News::orderBy('published_at', 'desc');

        if ($category) {
            $query->where('category', $category);
        }

        return $query->paginate($perPage);
    }

    /**
     * Get article statistics
     */
    public function getStats()
    {
        return [
            'total' => News::count(),
            'sports' => News::where('category', 'sports')->count(),
            'politics' => News::where('category', 'politics')->count(),
            'entertainment' => News::where('category', 'entertainment')->count(),
            'today' => News::whereDate('published_at', today())->count(),
        ];
    }
}
