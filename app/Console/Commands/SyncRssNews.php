<?php

namespace App\Console\Commands;

use Illuminate\Support\Str;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class SyncRssNews extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:sync-rss-news {--limit=20 : Maximum number of articles to fetch per category}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Sync RSS news from Indonesian news sources';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        Log::info('RSS synchronization started...');
        // Get the limit from command option, default to 20
        $limit = (int) $this->option('limit');

        $feeds = [
            // CNN Indonesia
            // 'politics' => 'https://www.cnnindonesia.com/nasional/rss',
            // 'sports' => 'https://www.cnnindonesia.com/olahraga/rss',
            // 'entertainment' => 'https://www.cnnindonesia.com/hiburan/rss',

            // Detik (Alternative sources)
            'politics' => 'https://news.detik.com/berita/rss',
            'sports' => 'https://sport.detik.com/sepakbola/rss',
            'entertainment' => 'https://hot.detik.com/rss',

            // Kompas (if available)
            // 'news' => 'https://rss.kompas.com/api/feed/social?apikey=bc58c81819dff4b8d5c53540a2fc7ffd83e6314a',

            // Tempo
            // 'politics' => 'http://rss.tempo.co/nasional',
            // 'sports' => 'http://rss.tempo.co/olahraga',
            // 'entertainment' => 'http://rss.tempo.co/tekno',
        ];

        $this->info("Fetching maximum {$limit} articles per category...");

        foreach ($feeds as $category => $url) {
            $this->info("Fetching {$category} from {$url}...");

            try {
                // Set context options for better RSS fetching
                $context = stream_context_create([
                    'http' => [
                        'timeout' => 30,
                        'user_agent' => 'Mozilla/5.0 (compatible; RSS Reader)',
                    ]
                ]);
                $response = Http::timeout(30)
                        ->withHeaders(['User-Agent' => 'Mozilla/5.0 (compatible; RSS Reader)'])
                        ->get($url);

                $rssContent = $response->body();
                $xml = simplexml_load_string($rssContent, "SimpleXMLElement", LIBXML_NOCDATA);

                if ($xml === false) {
                    $this->error("Failed to load RSS from {$url}");
                    continue;
                }

                $json = json_decode(json_encode($xml), true);
                $items = $json['channel']['item'] ?? [];

                if (empty($items)) {
                    $this->warn("No items found in RSS feed for {$category}");
                    continue;
                }

                // Limit the items to process
                $items = array_slice($items, 0, $limit);

                $newArticles = 0;
                $processedArticles = 0;

                foreach ($items as $item) {
                    $title = $item['title'] ?? '';
                    if (empty($title)) continue;

                    $slug = Str::slug($title);

                    // Check if article already exists
                    if (!\App\Models\News::where('slug', $slug)->exists()) {

                        // Parse published date
                        $publishedAt = null;
                        if (isset($item['pubDate'])) {
                            $publishedAt = date('Y-m-d H:i:s', strtotime($item['pubDate']));
                        }

                        // Extract image from description if available
                        $urlToImage = null;
                        $description = $item['description'] ?? '';

                        // Try to extract image URL from description
                        if (preg_match('/<img[^>]+src="([^"]+)"/', $description, $matches)) {
                            $urlToImage = $matches[1];
                        }

                        \App\Models\News::create([
                            'title' => $title,
                            'slug' => $slug,
                            'source' => parse_url($item['link'] ?? $url, PHP_URL_HOST),
                            'author' => $item['author'] ?? null,
                            'description' => strip_tags($description),
                            'content' => null,
                            'url' => $item['link'] ?? '',
                            'urlToImage' => $urlToImage,
                            'published_at' => $publishedAt ?: now(),
                            'category' => $category,
                        ]);

                        $newArticles++;
                    }

                    $processedArticles++;
                }

                $this->info("Processed {$processedArticles} articles, added {$newArticles} new articles for {$category}");
                Log::info('✅ Selesai sync RSS');

            } catch (\Exception $e) {
                $this->error("Error processing {$category}: " . $e->getMessage());
            }
        }

        $this->info("RSS synchronization completed!");
    }
}
