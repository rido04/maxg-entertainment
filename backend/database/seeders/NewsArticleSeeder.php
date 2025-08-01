<?php

namespace Database\Seeders;

use App\Models\NewsArticle;
use Illuminate\Database\Seeder;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;

class NewsArticleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
    {
        NewsArticle::factory()->count(10)->create();
    }
}
