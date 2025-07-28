<?php

namespace App\Http\Controllers;

use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class GameController extends Controller
{
    private function indexData()
    {
        // Array for game lists (add if there is new game)
        $games = [
            [
                'name' => 'Tic Tac Toe',
                'route' => 'games.tictactoe',
                'background_image' => 'images/background/bg-tixtactoe.png',
                'icon' => '❌⭕',
                'description' => 'Game klasik X and O',
                'colors' => [
                    'hover_from' => 'blue-800',
                    'hover_to' => 'blue-900',
                    'border' => 'blue-500',
                    'glow_from' => 'blue-600',
                    'glow_to' => 'blue-600',
                    'button' => 'blue-600',
                    'button_hover' => 'blue-500',
                    'text_hover' => 'blue-300',
                    'corner' => 'blue-500'
                ],
                'status' => 'active'
                // featured akan diset random nanti
            ],
            [
                'name' => 'Snake Game',
                'route' => 'games.snake',
                'background_image' => 'images/background/bg-snake-game.png',
                'icon' => '🐍',
                'description' => 'Makan terus dan jangan tabrak tembok!',
                'colors' => [
                    'hover_from' => 'green-800',
                    'hover_to' => 'green-900',
                    'border' => 'green-500',
                    'glow_from' => 'green-600',
                    'glow_to' => 'emerald-600',
                    'button' => 'green-600',
                    'button_hover' => 'green-500',
                    'text_hover' => 'green-300',
                    'corner' => 'green-500'
                ],
                'status' => 'coming_soon'
                // featured akan diset random nanti
            ],
            [
                'name' => 'Tetris Game',
                'route' => 'games.tetris',
                'background_image' => 'images/background/bg-tetris.png', // Fixed typo
                'icon' => '📱',
                'description' => 'Jatuhkan balok dengan rapi dan dapatkan skor tertinggi!',
                'colors' => [
                    'hover_from' => 'purple-800',
                    'hover_to' => 'purple-900',
                    'border' => 'purple-500',
                    'glow_from' => 'purple-600',
                    'glow_to' => 'violet-600',
                    'button' => 'purple-600',
                    'button_hover' => 'purple-500',
                    'text_hover' => 'purple-300',
                    'corner' => 'purple-500'
                ],
                'status' => 'active'
                // featured akan diset random nanti
            ],
            [
                'name' => 'Dino Game',
                'route' => 'games.dino',
                'background_image' => 'images/background/bg-dino-game.png', // Fixed field name
                'icon' => '🦖',
                'description' => 'Mainkan game dino lompat yang paling populer di dunia!',
                'colors' => [
                    'hover_from' => 'orange-800',
                    'hover_to' => 'orange-900',
                    'border' => 'orange-500',
                    'glow_from' => 'orange-600',
                    'glow_to' => 'red-600',
                    'button' => 'orange-600',
                    'button_hover' => 'orange-500',
                    'text_hover' => 'orange-300',
                    'corner' => 'orange-500'
                ],
                'status' => 'active',
                // featured akan diset random nanti
            ],
            [
                'name' => 'Puzzle Game',
                'route' => null,
                'background_image' => 'images/background/bg-puzzle-game.png', // Fixed field name
                'icon' => '🧩',
                'description' => 'Sharpen your mind with challenging puzzles',
                'colors' => [
                    'hover_from' => 'blue-800',
                    'hover_to' => 'blue-900',
                    'border' => 'blue-500',
                    'glow_from' => 'blue-600',
                    'glow_to' => 'cyan-600',
                    'button' => 'gray-600',
                    'button_hover' => 'gray-600',
                    'text_hover' => 'blue-300',
                    'corner' => 'blue-500'
                ],
                'status' => 'coming_soon'
            ],
            [
                'name' => 'Memory Game',
                'route' => null,
                'background_image' => 'images/background/bg-memory-game.png', // Changed from external URL
                'icon' => '🧠',
                'description' => 'Test your memory with card matching games',
                'colors' => [
                    'hover_from' => 'pink-800',
                    'hover_to' => 'pink-900',
                    'border' => 'pink-500',
                    'glow_from' => 'pink-600',
                    'glow_to' => 'rose-600',
                    'button' => 'gray-600',
                    'button_hover' => 'gray-600',
                    'text_hover' => 'pink-300',
                    'corner' => 'pink-500'
                ],
                'status' => 'coming_soon'
            ],
            [
                'name' => 'Floppy Bird',
                'route' =>  'games.floppybird',
                'background_image' => 'images/background/bg-flappy-bird.png', // Fixed field name
                'icon' => '🐦',
                'description' => 'Ini dia game flappy bird yang populer dan adiktif!',
                'colors' => [
                    'hover_from' => 'sky-800',
                    'hover_to' => 'sky-900',
                    'border' => 'sky-500',
                    'glow_from' => 'sky-600',
                    'glow_to' => 'cyan-600',
                    'button' => 'sky-600',
                    'button_hover' => 'sky-500',
                    'text_hover' => 'sky-300',
                    'corner' => 'sky-500'
                ],
                'status' => 'active'
                // featured akan diset random nanti
            ],
            [
                'name' => 'Candy Crush',
                'route' =>  'games.candycrush',
                'background_image' => 'images/background/bg-candy-crush.png',
                'icon' => '🍬',
                'description' => 'Cocokan permen warna warni yang lezat!',
                'colors' => [
                    'hover_from' => 'sky-800',
                    'hover_to' => 'sky-900',
                    'border' => 'sky-500',
                    'glow_from' => 'sky-600',
                    'glow_to' => 'cyan-600',
                    'button' => 'sky-600',
                    'button_hover' => 'sky-500',
                    'text_hover' => 'sky-300',
                    'corner' => 'sky-500'
                ],
                'status' => 'active'
                // featured akan diset random nanti
            ],
            [
                'name' => '2048',
                'route' =>  'games.2048',
                'background_image' => 'images/background/bg-2048.png',
                'icon' => '🔢',
                'description' => 'Bisakah kamu mencapai 2048?',
                'colors' => [
                    'hover_from' => 'sky-800',
                    'hover_to' => 'sky-900',
                    'border' => 'sky-500',
                    'glow_from' => 'sky-600',
                    'glow_to' => 'cyan-600',
                    'button' => 'sky-600',
                    'button_hover' => 'sky-500',
                    'text_hover' => 'sky-300',
                    'corner' => 'sky-500'
                ],
                'status' => 'active'
                // featured akan diset random nanti
            ]
        ];
        return $games;
    }


        public function index()
        {
            $games = $this->indexData();

            // Sama seperti sebelumnya: random featured
            $activeGames = array_filter($games, fn($g) => $g['status'] === 'active');

            foreach ($games as &$game) {
                $game['featured'] = false;
            }

            $activeGameKeys = array_keys($activeGames);
            $randomKeys = array_rand($activeGameKeys, min(2, count($activeGameKeys)));

            if (!is_array($randomKeys)) {
                $randomKeys = [$randomKeys];
            }

            foreach ($randomKeys as $keyIndex) {
                $actualKey = $activeGameKeys[$keyIndex];
                $games[$actualKey]['featured'] = true;
            }

            return view('games.index', compact('games'));
        }



        public function api()
        {
            $games = $this->indexData(); // ambil data game yang sama dari method index

            // Random featured logic (sama seperti di method index)
            $activeGames = array_filter($games, fn($g) => $g['status'] === 'active');

            foreach ($games as &$game) {
                $game['featured'] = false;
            }

            $activeGameKeys = array_keys($activeGames);
            if (count($activeGameKeys) > 0) {
                $randomKeys = array_rand($activeGameKeys, min(2, count($activeGameKeys)));

                if (!is_array($randomKeys)) {
                    $randomKeys = [$randomKeys];
                }

                foreach ($randomKeys as $keyIndex) {
                    $actualKey = $activeGameKeys[$keyIndex];
                    $games[$actualKey]['featured'] = true;
                }
            }

            // Tambahkan URL untuk akses dari Flutter
            foreach ($games as &$game) {
                if ($game['route']) {
                    $slug = explode('.', $game['route'])[1]; // ambil 'tictactoe' dari 'games.tictactoe'
                    $game['url'] = url("game/$slug/index.html");
                } else {
                    $game['url'] = null;
                }
            }

            return response()->json($games);
        }
        public function list()
        {
            $files = Storage::disk('public')->files('games');

            $games = collect($files)->filter(fn ($file) => Str::endsWith($file, '.html'))
                ->map(fn ($file) => [
                    'title' => Str::headline(basename($file, '.html')),
                    'slug' => basename($file, '.html'),
                    'url' => asset("storage/games/" . basename($file))
                ])
                ->values();

            return response()->json($games);
        }


    public function tictactoe()
    {
        return view('games.tictactoe');
    }

    public function snake()
    {
        return view('games.snake');
    }

    public function tetris()
    {
        return view('games.tetris');
    }

    public function dino()
    {
        return view('games.dino');
    }

    public function floppybird()
    {
        return view('games.floppybird');
    }

    public function candycrush()
    {
        return view('games.candycrush');
    }

    public function the2048()
    {
        return view('games.2048');
    }

}
