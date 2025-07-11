<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class GameController extends Controller
{
    public function index()
    {
        // Array for game lists (add if there is new game)
        $games = [
            [
                'name' => 'Tic Tac Toe',
                'route' => 'games.tictactoe',
                'icon' => '❌⭕',
                'description' => 'Classic X and O game that never gets boring',
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
            ],
            [
                'name' => 'Snake Game',
                'route' => 'games.snake',
                'icon' => '🐍',
                'description' => 'Collect food and don\'t hit the walls!',
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
                'status' => 'active',
            ],
            [
                'name' => 'Tetris Game',
                'route' => 'games.tetris',
                'icon' => '📱',
                'description' => 'Drop blocks evenly and get the highest score!',
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
            ],
            [
                'name' => 'Dino Game',
                'route' => 'games.dino',
                'icon' => '🦖',
                'description' => 'Play the world\'s most popular jumping dino game!',
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
                'featured' => true
            ],
            [
                'name' => 'Puzzle Game',
                'route' => null,
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
                'icon' => '🐦',
                'description' => 'Classic flappy bird game with addictive gameplay',
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
                'status' => 'active',
                'featured' => true
            ],
            [
                'name' => 'Candy Crush',
                'route' =>  'games.candycrush',
                'icon' => '🍬',
                'description' => 'Hey its a Candy Crush game on your flight',
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
                'status' => 'active',
            ]
        ];

        return view('games.index', compact('games'));
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
}
