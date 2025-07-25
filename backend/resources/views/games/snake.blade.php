@extends('layouts.app')

@section('content')
<div class="max-w-4xl mx-auto mt-10 px-4">
    <!-- Game Header -->
    <div class="text-center mb-8">
        <h1 class="text-4xl font-bold mb-2 bg-gradient-to-r from-green-400 to-emerald-600 bg-clip-text text-transparent">
            🐍 Snake Game
        </h1>
        <p class="text-gray-600">Make your highest score!</p>
    </div>

    <!-- Score Display -->
    <div class="flex justify-between items-center mb-6 bg-white/80 backdrop-blur-sm rounded-xl p-4 shadow-lg">
        <div class="text-center">
            <div class="text-2xl font-bold text-green-600" id="currentScore">0</div>
            <div class="text-sm text-gray-500">Current score</div>
        </div>
        <div class="text-center">
            <div class="text-2xl font-bold text-purple-600" id="highScoreDisplay">0</div>
            <div class="text-sm text-gray-500">Highest score</div>
        </div>
        <div class="text-center">
            <div class="text-2xl font-bold text-blue-600" id="gameSpeed">Normal</div>
            <div class="text-sm text-gray-500">Speed</div>
        </div>
    </div>

    <!-- Game Area -->
    <div class="grid grid-cols-1 lg:grid-cols-4 gap-6 mb-6">
        <!-- Canvas Area -->
        <div class="lg:col-span-3">
            <div class="relative bg-gradient-to-br from-gray-900 to-gray-800 rounded-xl p-4 shadow-2xl">
                <canvas id="gameCanvas" class="w-full border-2 border-gray-700 rounded-lg bg-gray-900" width="400" height="300"></canvas>

                <!-- Game Status Overlay -->
                <div id="gameStatus" class="absolute top-4 right-4 bg-black/70 text-white px-3 py-1 rounded-full text-sm font-medium">
                    ▶️ Playing
                </div>
            </div>
        </div>

        <!-- Controls Panel -->
        <div class="lg:col-span-1 space-y-4">
            <!-- D-Pad Controls -->
            <div class="bg-white/80 backdrop-blur-sm rounded-xl p-4 shadow-lg">
                <h3 class="text-lg font-semibold mb-3 text-center">Control</h3>
                <div class="flex justify-center">
                    <div class="grid grid-cols-3 gap-2 w-32">
                        <div></div>
                        <button data-dir="UP" class="control-btn bg-gradient-to-b from-blue-400 to-blue-500 hover:from-blue-500 hover:to-blue-600 text-white rounded-lg p-3 transition-all duration-200 transform hover:scale-105 active:scale-95 shadow-lg">
                            ⬆️
                        </button>
                        <div></div>
                        <button data-dir="LEFT" class="control-btn bg-gradient-to-b from-blue-400 to-blue-500 hover:from-blue-500 hover:to-blue-600 text-white rounded-lg p-3 transition-all duration-200 transform hover:scale-105 active:scale-95 shadow-lg">
                            ⬅️
                        </button>
                        <div></div>
                        <button data-dir="RIGHT" class="control-btn bg-gradient-to-b from-blue-400 to-blue-500 hover:from-blue-500 hover:to-blue-600 text-white rounded-lg p-3 transition-all duration-200 transform hover:scale-105 active:scale-95 shadow-lg">
                            ➡️
                        </button>
                        <div></div>
                        <button data-dir="DOWN" class="control-btn bg-gradient-to-b from-blue-400 to-blue-500 hover:from-blue-500 hover:to-blue-600 text-white rounded-lg p-3 transition-all duration-200 transform hover:scale-105 active:scale-95 shadow-lg">
                            ⬇️
                        </button>
                        <div></div>
                    </div>
                </div>
            </div>

            <!-- Game Controls -->
            <div class="bg-white/80 backdrop-blur-sm rounded-xl p-4 shadow-lg">
                <h3 class="text-lg font-semibold mb-3 text-center">Setting</h3>
                <div class="space-y-3">
                    <button id="pauseBtn" class="w-full bg-gradient-to-r from-yellow-400 to-orange-500 hover:from-yellow-500 hover:to-orange-600 text-white font-semibold py-2 px-4 rounded-lg transition-all duration-200 transform hover:scale-105">
                        ⏸️ Pause
                    </button>
                    <button id="resetBtn" class="w-full bg-gradient-to-r from-red-400 to-red-500 hover:from-red-500 hover:to-red-600 text-white font-semibold py-2 px-4 rounded-lg transition-all duration-200 transform hover:scale-105">
                        🔄 Reset
                    </button>
                    <select id="speedSelect" class="w-full bg-white border border-gray-300 rounded-lg px-3 py-2 text-sm">
                        <option value="200">Slow</option>
                        <option value="150" selected>Normal</option>
                        <option value="100">Fast</option>
                        <option value="50">Super fast</option>
                    </select>
                </div>
            </div>

            <!-- Instructions -->
            <div class="bg-white/80 backdrop-blur-sm rounded-xl p-4 shadow-lg">
                <h3 class="text-lg font-semibold mb-3 text-center">How to play</h3>
                <div class="text-sm text-gray-600 space-y-2">
                    <p>🎮 Use D-Pad for direction</p>
                    <p>📱 Swipe on screen to move</p>
                    <p>🍎 Eat the fruit for grow!</p>
                    <p>⚠️ Avoid wall</p>
                </div>
            </div>
        </div>
    </div>
</div>

@push('styles')
<style>
    body {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
    }

    .control-btn {
        user-select: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
    }

    /* Game Over Modal */
    .game-over-modal {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(45deg, rgba(0,0,0,0.8), rgba(0,0,0,0.9));
        backdrop-filter: blur(10px);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 1000;
        opacity: 0;
        pointer-events: none;
        transition: all 0.3s ease;
    }

    .game-over-modal.active {
        opacity: 1;
        pointer-events: all;
    }

    .game-over-content {
        background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
        padding: 3rem 2rem;
        border-radius: 20px;
        text-align: center;
        max-width: 400px;
        width: 90%;
        box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
        transform: scale(0.8);
        transition: transform 0.3s ease;
    }

    .game-over-modal.active .game-over-content {
        transform: scale(1);
    }

    .game-over-content h2 {
        color: #ef4444;
        font-size: 2rem;
        margin-bottom: 1rem;
        font-weight: bold;
    }

    .game-over-content .final-score {
        font-size: 1.5rem;
        font-weight: bold;
        color: #059669;
        margin: 1rem 0;
    }

    .game-over-content .record-badge {
        background: linear-gradient(45deg, #fbbf24, #f59e0b);
        color: white;
        padding: 0.5rem 1rem;
        border-radius: 50px;
        font-weight: bold;
        display: inline-block;
        margin: 0.5rem 0;
        animation: pulse 2s infinite;
    }

    @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
    }

    .modal-buttons {
        display: flex;
        gap: 1rem;
        justify-content: center;
        margin-top: 2rem;
    }

    .modal-buttons button {
        padding: 0.75rem 1.5rem;
        border: none;
        border-radius: 10px;
        font-weight: bold;
        cursor: pointer;
        transition: all 0.2s ease;
        transform: translateY(0);
    }

    .modal-buttons button:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
    }

    .play-again-btn {
        background: linear-gradient(45deg, #4ade80, #22c55e);
        color: white;
    }

    .back-btn {
        background: linear-gradient(45deg, #6b7280, #4b5563);
        color: white;
    }

    /* Pause Overlay */
    .pause-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.8);
        display: flex;
        justify-content: center;
        align-items: center;
        color: white;
        font-size: 2rem;
        font-weight: bold;
        border-radius: 10px;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.3s ease;
    }

    .pause-overlay.active {
        opacity: 1;
        pointer-events: all;
    }

    /* Responsive Design */
    @media (max-width: 768px) {
        .game-container {
            padding: 1rem;
        }

        .control-btn {
            padding: 0.75rem;
        }

        .game-over-content {
            padding: 2rem 1.5rem;
        }

        .modal-buttons {
            flex-direction: column;
        }
    }
    @keyframes float {
    0%, 100% { transform: translateY(0px); }
    50% { transform: translateY(-10px); }
  }

  .animate-float {
    animation: float 3s ease-in-out infinite;
  }

  /* Glass effect */
  .glass-effect {
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  }

  /* Custom scrollbar for webkit browsers */
  ::-webkit-scrollbar {
    width: 8px;
  }

  ::-webkit-scrollbar-track {
    background: rgb(51 65 85 / 0.3);
    border-radius: 4px;
  }

  ::-webkit-scrollbar-thumb {
    background: rgb(100 116 139 / 0.6);
    border-radius: 4px;
  }

  ::-webkit-scrollbar-thumb:hover {
    background: rgb(100 116 139 / 0.8);
  }

  /* Smooth animations */
  * {
    scroll-behavior: smooth;
  }

  /* Enhanced hover effects */
  .group:hover .group-hover\:scale-110 {
    transform: scale(1.1);
  }
</style>
@endpush

<!-- Game Over Modal -->
<div class="game-over-modal" id="gameOverModal">
    <div class="game-over-content">
        <h2>🎮 Game Over!</h2>
        <div class="final-score" id="finalScore">Skor: 0</div>
        <div id="recordBadge" class="record-badge" style="display: none;">
            🏆 NEW RECORD!
        </div>
        <p id="gameOverMessage" class="text-gray-600 mt-2"></p>
        <div class="modal-buttons">
            <button id="playAgainBtn" class="play-again-btn">
                🎯 Play Again
            </button>
            <button onclick="history.back()" class="back-btn">
                ⬅️ Back
            </button>
        </div>
    </div>
</div>

<!-- Pause Overlay -->
<div class="pause-overlay" id="pauseOverlay">
    ⏸️ GAME PAUSED, TAP ANYWHERE TO RESUME
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    const canvas = document.getElementById('gameCanvas');
    const ctx = canvas.getContext('2d');
    const scale = 20;
    const rows = canvas.height / scale;
    const columns = canvas.width / scale;

    // UI Elements
    const gameOverModal = document.getElementById('gameOverModal');
    const gameOverMessage = document.getElementById('gameOverMessage');
    const finalScore = document.getElementById('finalScore');
    const recordBadge = document.getElementById('recordBadge');
    const playAgainBtn = document.getElementById('playAgainBtn');
    const pauseBtn = document.getElementById('pauseBtn');
    const resetBtn = document.getElementById('resetBtn');
    const speedSelect = document.getElementById('speedSelect');
    const pauseOverlay = document.getElementById('pauseOverlay');
    const gameStatus = document.getElementById('gameStatus');
    const currentScoreEl = document.getElementById('currentScore');
    const highScoreEl = document.getElementById('highScoreDisplay');
    const gameSpeedEl = document.getElementById('gameSpeed');

    // Game Variables
    let snake;
    let fruit;
    let direction = 'RIGHT';
    let touchStartX, touchStartY;
    let score = 0;
    let gameInterval;
    let isPaused = false;
    let gameSpeed = 150;
    let highScore = parseInt(localStorage.getItem('snakeHighScore')) || 0;

    // Initialize high score display
    highScoreEl.textContent = highScore;

    // Enhanced fruit types
    const fruitTypes = [
        { emoji: '🍎', points: 1, color: '#ef4444' },
        { emoji: '🍊', points: 2, color: '#f97316' },
        { emoji: '🍇', points: 3, color: '#8b5cf6' },
        { emoji: '🍓', points: 5, color: '#ec4899' }
    ];

    // D-Pad Controls with haptic feedback
    document.querySelectorAll('button[data-dir]').forEach(button => {
        button.addEventListener('click', (e) => {
            const newDir = button.getAttribute('data-dir');
            changeDirection(newDir);

            // Visual feedback
            button.style.transform = 'scale(0.95)';
            setTimeout(() => {
                button.style.transform = 'scale(1)';
            }, 100);
        });
    });

    // Game Controls
    pauseBtn.addEventListener('click', togglePause);
    resetBtn.addEventListener('click', resetGame);
    speedSelect.addEventListener('change', (e) => {
        gameSpeed = parseInt(e.target.value);
        updateSpeedDisplay();
        if (!isPaused && gameInterval) {
            clearInterval(gameInterval);
            startGameLoop();
        }
    });

    function changeDirection(newDir) {
        if (isPaused) return;

        if (
            (newDir === 'UP' && direction !== 'DOWN') ||
            (newDir === 'DOWN' && direction !== 'UP') ||
            (newDir === 'LEFT' && direction !== 'RIGHT') ||
            (newDir === 'RIGHT' && direction !== 'LEFT')
        ) {
            direction = newDir;
        }
    }

    function togglePause() {
        if (isPaused) {
            resumeGame();
        } else {
            pauseGame();
        }
    }

    function pauseGame() {
        isPaused = true;
        clearInterval(gameInterval);
        pauseOverlay.classList.add('active');
        pauseBtn.innerHTML = '▶️ Resume';
        gameStatus.innerHTML = '⏸️ Paused';
    }

    function resumeGame() {
        isPaused = false;
        startGameLoop();
        pauseOverlay.classList.remove('active');
        pauseBtn.innerHTML = '⏸️ Pause';
        gameStatus.innerHTML = '▶️ Playing';
    }

    function updateSpeedDisplay() {
        const speedMap = {
            200: 'Lambat',
            150: 'Normal',
            100: 'Cepat',
            50: 'Super'
        };
        gameSpeedEl.textContent = speedMap[gameSpeed] || 'Normal';
    }

    function showGameOver() {
        clearInterval(gameInterval);

        finalScore.textContent = `Skor: ${score}`;

        if (score > highScore) {
            highScore = score;
            localStorage.setItem('snakeHighScore', highScore);
            recordBadge.style.display = 'inline-block';
            gameOverMessage.textContent = 'Selamat! Anda memecahkan rekor!';
            highScoreEl.textContent = highScore;
        } else {
            recordBadge.style.display = 'none';
            gameOverMessage.textContent = `Rekor tertinggi: ${highScore}`;
        }

        gameOverModal.classList.add('active');
        gameStatus.innerHTML = '💀 Game Over';
    }

    function hideGameOver() {
        gameOverModal.classList.remove('active');
    }

    function resetGame() {
        clearInterval(gameInterval);
        snake = [{ x: 10 * scale, y: 10 * scale }];
        fruit = generateFruit();
        direction = 'RIGHT';
        score = 0;
        isPaused = false;

        updateScore();
        hideGameOver();
        pauseOverlay.classList.remove('active');
        pauseBtn.innerHTML = '⏸️ Pause';
        gameStatus.innerHTML = '▶️ Playing';

        startGameLoop();
    }

    function generateFruit() {
        const type = fruitTypes[Math.floor(Math.random() * fruitTypes.length)];
        return {
            x: Math.floor(Math.random() * columns) * scale,
            y: Math.floor(Math.random() * rows) * scale,
            type: type
        };
    }

    function updateScore() {
        currentScoreEl.textContent = score;
    }

    function startGameLoop() {
        gameInterval = setInterval(() => {
            if (!isPaused) {
                update();
                draw();
            }
        }, gameSpeed);
    }

    playAgainBtn.addEventListener('click', () => {
        resetGame();
    });

    // Initialize game
    (function setup() {
        resetGame();
        updateSpeedDisplay();
    })();

    function update() {
        const head = { ...snake[0] };

        // Move snake
        if (direction === 'LEFT') head.x -= scale;
        if (direction === 'UP') head.y -= scale;
        if (direction === 'RIGHT') head.x += scale;
        if (direction === 'DOWN') head.y += scale;

        snake.unshift(head);

        // Check fruit collision
        if (head.x === fruit.x && head.y === fruit.y) {
            score += fruit.type.points;
            updateScore();
            fruit = generateFruit();

            // Add visual effect for eating
            canvas.style.filter = 'brightness(1.2)';
            setTimeout(() => {
                canvas.style.filter = 'brightness(1)';
            }, 100);
        } else {
            snake.pop();
        }

        // Check collisions
        if (
            head.x < 0 || head.x >= canvas.width ||
            head.y < 0 || head.y >= canvas.height ||
            snake.slice(1).some(s => s.x === head.x && s.y === head.y)
        ) {
            showGameOver();
        }
    }

    function draw() {
        // Clear canvas with gradient background
        const gradient = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
        gradient.addColorStop(0, '#1f2937');
        gradient.addColorStop(1, '#111827');
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Draw grid
        ctx.strokeStyle = '#374151';
        ctx.lineWidth = 0.5;
        for (let i = 0; i <= columns; i++) {
            ctx.beginPath();
            ctx.moveTo(i * scale, 0);
            ctx.lineTo(i * scale, canvas.height);
            ctx.stroke();
        }
        for (let i = 0; i <= rows; i++) {
            ctx.beginPath();
            ctx.moveTo(0, i * scale);
            ctx.lineTo(canvas.width, i * scale);
            ctx.stroke();
        }

        // Draw snake with gradient and glow effect
        snake.forEach((part, index) => {
            if (index === 0) {
                // Snake head with glow
                ctx.shadowColor = '#4ade80';
                ctx.shadowBlur = 10;
                ctx.fillStyle = '#22c55e';
            } else {
                // Snake body with gradient
                ctx.shadowBlur = 0;
                const intensity = 1 - (index / snake.length) * 0.5;
                ctx.fillStyle = `rgba(34, 197, 94, ${intensity})`;
            }

            ctx.fillRect(part.x + 1, part.y + 1, scale - 2, scale - 2);

            // Add border to snake segments
            ctx.strokeStyle = '#16a34a';
            ctx.lineWidth = 2;
            ctx.strokeRect(part.x + 1, part.y + 1, scale - 2, scale - 2);
        });

        // Reset shadow
        ctx.shadowBlur = 0;

        // Draw fruit with emoji and glow
        ctx.shadowColor = fruit.type.color;
        ctx.shadowBlur = 15;
        ctx.fillStyle = fruit.type.color;
        ctx.fillRect(fruit.x + 2, fruit.y + 2, scale - 4, scale - 4);

        // Draw fruit emoji
        ctx.shadowBlur = 0;
        ctx.font = `${scale - 4}px Arial`;
        ctx.textAlign = 'center';
        ctx.fillText(fruit.type.emoji, fruit.x + scale/2, fruit.y + scale - 3);
    }

    // Keyboard controls
    window.addEventListener('keydown', e => {
    e.preventDefault();

    if (e.key === 'ArrowUp') changeDirection('UP');
    if (e.key === 'ArrowDown') changeDirection('DOWN');
    if (e.key === 'ArrowLeft') changeDirection('LEFT');
    if (e.key === 'ArrowRight') changeDirection('RIGHT');
    if (e.key === ' ') togglePause(); // Spacebar to pause/resume
    if (e.key === 'r' || e.key === 'R') resetGame(); // R to reset

    // Tambahkan logic untuk resume dengan tombol Enter
    if (e.key === 'Enter' && isPaused) {
        resumeGame();
    }
});

// Modifikasi touch event untuk canvas
canvas.addEventListener('touchend', e => {
    e.preventDefault();

    if (!touchStartX || !touchStartY) return;
    if (Date.now() - touchStartTime > 500) return;

    const touch = e.changedTouches[0];
    const diffX = touch.clientX - touchStartX;
    const diffY = touch.clientY - touchStartY;
    const minSwipeDistance = 30;

    if (Math.abs(diffX) < minSwipeDistance && Math.abs(diffY) < minSwipeDistance) {
        // Tap to pause/resume
        togglePause();
        return;
    }

    // Jika game sedang pause, tap apapun akan resume
    if (isPaused) {
        resumeGame();
        return;
    }

    if (Math.abs(diffX) > Math.abs(diffY)) {
        // Horizontal swipe
        if (diffX > 0) changeDirection('RIGHT');
        else changeDirection('LEFT');
    } else {
        // Vertical swipe
        if (diffY > 0) changeDirection('DOWN');
        else changeDirection('UP');
    }

    touchStartX = null;
    touchStartY = null;
});

// Tambahkan event listener untuk pause overlay
pauseOverlay.addEventListener('click', () => {
    if (isPaused) {
        resumeGame();
    }
});

    // Enhanced touch controls
    let touchStartTime;

    canvas.addEventListener('touchstart', e => {
        e.preventDefault();
        const touch = e.touches[0];
        touchStartX = touch.clientX;
        touchStartY = touch.clientY;
        touchStartTime = Date.now();
    });

    canvas.addEventListener('touchmove', e => {
        e.preventDefault();
    });

    canvas.addEventListener('touchend', e => {
        e.preventDefault();

        if (!touchStartX || !touchStartY) return;
        if (Date.now() - touchStartTime > 500) return; // Ignore long touches

        const touch = e.changedTouches[0];
        const diffX = touch.clientX - touchStartX;
        const diffY = touch.clientY - touchStartY;
        const minSwipeDistance = 30;

        if (Math.abs(diffX) < minSwipeDistance && Math.abs(diffY) < minSwipeDistance) {
            // Tap to pause
            togglePause();
            return;
        }

        if (Math.abs(diffX) > Math.abs(diffY)) {
            // Horizontal swipe
            if (diffX > 0) changeDirection('RIGHT');
            else changeDirection('LEFT');
        } else {
            // Vertical swipe
            if (diffY > 0) changeDirection('DOWN');
            else changeDirection('UP');
        }

        touchStartX = null;
        touchStartY = null;
    });

    // Prevent context menu on long press
    canvas.addEventListener('contextmenu', e => {
        e.preventDefault();
    });
});
</script>
@endsection
