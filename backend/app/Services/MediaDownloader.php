<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MediaDownloader
{
    public function download(string $url, string $folder = 'media')
    {
        try {
            $response = Http::get($url);

            if ($response->successful()) {
                $filename = basename(parse_url($url, PHP_URL_PATH));
                $path = "$folder/" . Str::random(10) . '-' . $filename;

                Storage::disk('public')->put($path, $response->body());

                return [
                    'success' => true,
                    'path' => Storage::url($path), // URL yang bisa diakses oleh tablet
                ];
            }

            return ['success' => false, 'error' => 'Failed to download: ' . $response->status()];
        } catch (\Throwable $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
}
