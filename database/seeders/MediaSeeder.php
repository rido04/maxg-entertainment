<?php

namespace Database\Seeders;

use App\Models\Media;
use Illuminate\Database\Seeder;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;

class MediaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Media::create([
            'title' => 'Film Garuda 1',
            'file_path' => 'media/videos/film1.mp4',
            'type' => 'video',
            'duration' => 7200,
        ]);
    }
}
