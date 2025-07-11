<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Services\NewsApiService;
use App\Http\Controllers\Controller;

class NewsController extends Controller
{
    public function __construct(protected NewsApiService $news) {}

    public function index(Request $request)
    {
        $category = $request->query('category');

        if (!in_array($category, ['sports', 'entertainment', 'politics'])) {
            return response()->json(['error' => 'Invalid category'], 400);
        }

        if ($category === 'politics') {
            $news = $this->news->getPoliticalNews();
        } else {
            $news = $this->news->getNews($category);
        }

        return response()->json([
            'category' => $category,
            'articles' => $news,
        ]);
    }
}
