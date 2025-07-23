<?php

namespace App\Services;

use App\Models\News;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class NewsApiService
{
    protected $baseUrl = 'https://newsapi.org/v2/top-headlines';

    public function getNews(string $category): array
    {
        // Coba country=id dulu
        $response = Http::get($this->baseUrl, [
            'country' => 'id',
            'category' => $category,
            'apiKey' => config('services.newsapi.key'),
            'pageSize' => 10,
        ]);

        $articles = $response->json('articles') ?? [];

        // Jika kosong, fallback ke global (tanpa country)
        if (count($articles) === 0) {
            $response = Http::get($this->baseUrl, [
                'category' => $category,
                'apiKey' => config('services.newsapi.key'),
                'pageSize' => 10,
            ]);

            $articles = $response->json('articles') ?? [];
        }

        return $articles;
    }


    public function getPoliticalNews(): array
    {
        $response = Http::get($this->baseUrl, [
            'country' => 'id',
            'category' => 'general',
            'apiKey' => config('services.newsapi.key'),
            'pageSize' => 20,
        ]);

        $keywords = ['politik', 'presiden', 'pemilu', 'menteri', 'dpr', 'istana', 'pilkada'];

        return collect($response->json()['articles'] ?? [])->filter(function ($article) use ($keywords) {
            $text = strtolower($article['title'] . ' ' . ($article['description'] ?? ''));
            return collect($keywords)->contains(fn ($word) => str_contains($text, $word));
        })->values()->all();
    }

    public function sync(): void
    {
        // Cek apakah sudah sync dalam 24 jam terakhir
        if (Cache::has('news_last_sync') && now()->diffInHours(Cache::get('news_last_sync')) < 24) {
            return;
        }

        $categories = ['sports', 'entertainment'];

        foreach ($categories as $category) {
            $articles = $this->getNews($category);

            foreach ($articles as $article) {
                News::updateOrCreate(
                    ['slug' => Str::slug(Str::limit($article['title'], 60))],
                    [
                        'title' => $article['title'],
                        'description' => $article['description'] ?? null,
                        'content' => $article['content'] ?? null,
                        'source' => $article['source']['name'] ?? null,
                        'url' => $article['url'],
                        'image' => $article['urlToImage'],
                        'category' => $category,
                        'published_at' => $article['publishedAt'] ?? now(),
                    ]
                );
            }
        }

        // Politik: pakai pemfilteran manual
        $politicalArticles = $this->getPoliticalNews();
        foreach ($politicalArticles as $article) {
            News::updateOrCreate(
                ['slug' => Str::slug(Str::limit($article['title'], 60))],
                [
                    'title' => $article['title'],
                    'description' => $article['description'] ?? null,
                    'content' => $article['content'] ?? null,
                    'source' => $article['source']['name'] ?? null,
                    'url' => $article['url'],
                    'image' => $article['urlToImage'],
                    'category' => 'politics',
                    'published_at' => $article['publishedAt'] ?? now(),
                ]
            );
        }

        Cache::put('news_last_sync', now());
    }
}
