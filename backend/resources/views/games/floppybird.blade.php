@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-gray-900 flex flex-col items-center justify-center p-4">
    <!-- Game Container with Header -->
    <div class="w-full max-w-2xl bg-gray-800 rounded-lg shadow-2xl overflow-hidden">
        <!-- Game Header -->
        <div class="bg-gray-700 px-4 py-3 flex justify-between items-center">
            <div class="flex items-center space-x-4">
                <!-- Back Button -->
                <a href="{{ url('/games') }}" class="text-white hover:text-yellow-300 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                    </svg>
                </a>
                <h1 class="text-xl font-bold text-white">Floppy Bird</h1>
            </div>
            <div class="flex space-x-2">
                <button id="sound-toggle" class="text-white hover:text-yellow-300 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072M12 6a7.975 7.975 0 015.657 2.343m0 0a7.975 7.975 0 010 11.314m-11.314 0a7.975 7.975 0 010-11.314m0 0a7.975 7.975 0 015.657-2.343" />
                    </svg>
                </button>
            </div>
        </div>

        <!-- Game Frame -->
        <div class="relative aspect-[4/3]">
            <iframe
                src="{{ asset('game/ts-floppybird/index.html') }}"
                class="w-full h-full border-0"
                allow="autoplay; fullscreen"
                allowfullscreen
                id="game-frame">
            </iframe>

            <!-- Loading Overlay -->
            <div id="loading-overlay" class="absolute inset-0 bg-gray-900 flex items-center justify-center">
                <div class="text-center">
                    <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-yellow-400 mx-auto mb-4"></div>
                    <p class="text-white font-medium">Loading game...</p>
                </div>
            </div>
        </div>

        <!-- Game Controls/Info -->
        <div class="bg-gray-700 px-4 py-3 text-sm text-gray-300">
            <p>Controls: Space or Click to jump | Score: <span id="score-display">0</span></p>
        </div>
    </div>

    <!-- Instructions -->
    <div class="mt-6 max-w-2xl w-full bg-gray-800 rounded-lg p-4 text-gray-300">
        <h2 class="text-lg font-semibold text-white mb-2">How to Play</h2>
        <ul class="list-disc pl-5 space-y-1">
            <li>Press SPACE or CLICK to make the bird jump</li>
            <li>Avoid hitting the pipes</li>
            <li>Each successful pass through pipes earns you 1 point</li>
        </ul>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const gameFrame = document.getElementById('game-frame');
    const loadingOverlay = document.getElementById('loading-overlay');
    const fullscreenBtn = document.getElementById('fullscreen-btn');
    const soundToggle = document.getElementById('sound-toggle');

    // Hide loading when game is ready
    gameFrame.addEventListener('load', function() {
        setTimeout(() => {
            loadingOverlay.classList.add('hidden');
        }, 500);
    });

    // Fullscreen functionality
    fullscreenBtn.addEventListener('click', function() {
        if (gameFrame.requestFullscreen) {
            gameFrame.requestFullscreen();
        } else if (gameFrame.webkitRequestFullscreen) {
            gameFrame.webkitRequestFullscreen();
        } else if (gameFrame.msRequestFullscreen) {
            gameFrame.msRequestFullscreen();
        }
    });

    // Sound toggle functionality
    let soundEnabled = true;
    soundToggle.addEventListener('click', function() {
        soundEnabled = !soundEnabled;
        if (soundEnabled) {
            soundToggle.innerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072M12 6a7.975 7.975 0 015.657 2.343m0 0a7.975 7.975 0 010 11.314m-11.314 0a7.975 7.975 0 010-11.314m0 0a7.975 7.975 0 015.657-2.343" />
                </svg>
            `;
        } else {
            soundToggle.innerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" clip-rule="evenodd" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
                </svg>
            `;
        }
    });

    // Listen for messages from the game
    window.addEventListener('message', function(e) {
        if (e.data && e.data.type === 'scoreUpdate') {
            document.getElementById('score-display').textContent = e.data.score;
        }
    });
});
</script>

<style>
    #game-frame {
        transition: opacity 0.3s ease;
    }

    .aspect-\[4\/3\] {
        position: relative;
        padding-bottom: 75%;
    }

    .aspect-\[4\/3\] > * {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
    }
</style>
@endsection
