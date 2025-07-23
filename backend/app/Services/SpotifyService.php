<?php

namespace App\Services;

use App\Models\Media;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class SpotifyService
{
    public function getAccessToken()
    {
        $clientId = config('services.spotify.client_id');
        $clientSecret = config('services.spotify.client_secret');

        $response = Http::asForm()->withBasicAuth($clientId, $clientSecret)
            ->post('https://accounts.spotify.com/api/token', [
                'grant_type' => 'client_credentials',
            ]);

        return $response->json()['access_token'] ?? null;
    }

    /**
     * Enrich a media model with data from Spotify.
     *
     * @param \App\Models\Media $media
     * @return void
     */
    public function enrich(Media $media)
    {
        $token = $this->getAccessToken();
        if (!$token) return;

        $query = $media->artist
            ? "{$media->title} {$media->artist}"
            : $media->title;

        $response = Http::withToken($token)
            ->get('https://api.spotify.com/v1/search', [
                'q' => $query,
                'type' => 'track',
                'limit' => 1,
            ]);

        $track = $response['tracks']['items'][0] ?? null;

        if ($track) {
            $media->update([
                'artist' => $track['artists'][0]['name'] ?? null,
                'album' => $track['album']['name'] ?? null,
                'thumbnail' => $track['album']['images'][0]['url'] ?? null,
                'release_date' => $track['album']['release_date'] ?? null,
                'description' => 'From album: ' . ($track['album']['name'] ?? ''),
            ]);

            // Download preview URL jika tersedia
            $previewUrl = $track['preview_url'];
            if ($previewUrl) {
                $downloader = new MediaDownloader();
                $result = $downloader->download($previewUrl, 'media/music');
                if ($result['success']) {
                    $media->file_path = $result['path'];
                    $media->checksum = hash_file('sha256', storage_path('app/public/' . Str::after($result['path'], '/storage/')));
                    $media->save(); // Jangan lupa save setelah update file_path dan checksum
                }
            }

            // Fetch artist image
            $artistId = $track['artists'][0]['id'] ?? null;

            if ($artistId) {
                $artistResponse = Http::withToken($token)
                    ->get("https://api.spotify.com/v1/artists/{$artistId}");

                $artistImage = $artistResponse['images'][0]['url'] ?? null;

                $media->update([
                    'artist_image' => $artistImage,
                ]);
                Log::info("Artist Image for {$media->title}: {$artistImage}");
            }
        }
    }
}
