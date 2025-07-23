<?php

namespace App\Console\Commands;

use App\Models\News;
use Illuminate\Support\Str;
use Illuminate\Console\Command;
use App\Services\NewsApiService;
use Illuminate\Support\Facades\Http;

class SyncNews extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:sync-news';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */

    public function handle()
    {
        try{
            Http::timeout(2)->get('https://1.1.1.1');
            $this->info('Koneksi internet tersedia, mulai sinkronisasi berita...');
        } catch (\Exception $e) {
            $this->error('Tidak ada koneksi internet, lewati sinkronisasi berita.');
            return;
        }
        $categories = ['sports', 'entertainment', 'politics'];

        foreach ($categories as $category) {
            $response = Http::get('https://newsapi.org/v2/top-headlines', [
                'country' => 'id',
                'category' => $category,
                'apiKey' => config('services.newsapi.key'),
                'pageSize' => 10,
            ]);

            $articles = $response->json('articles') ?? [];

            if (count($articles) === 0) {
                $response = Http::get('https://newsapi.org/v2/top-headlines', [
                    'category' => $category,
                    'apiKey' => config('services.newsapi.key'),
                    'pageSize' => 10,
                ]);
                $articles = $response->json('articles') ?? [];
            }

            foreach ($articles as $article) {
                $slug = Str::slug($article['title']);

                if (!News::where('slug', $slug)->exists()) {
                    News::create([
                        'title' => $article['title'],
                        'slug' => $slug,
                        'source' => $article['source']['name'] ?? null,
                        'author' => $article['author'] ?? null,
                        'description' => $article['description'] ?? null,
                        'content' => $article['content'] ?? null,
                        'url' => $article['url'],
                        'urlToImage' => $article['urlToImage'],
                        'published_at' => $article['publishedAt'] ?? now(),
                        'category' => $category,
                    ]);
                }
            }
        }

        $this->info('✅ Sinkronisasi berita selesai.');
    }

}
