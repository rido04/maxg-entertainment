@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800 py-4">
    <div class="container mx-auto px-4 max-w-6xl">
        <!-- Header -->
        <div class="text-center mb-6">
            <h1 class="text-3xl md:text-4xl font-bold text-white mb-2">
                🧩 Tetris
            </h1>
            <p class="text-slate-300 text-sm md:text-base">Susun blok dan raih skor tertinggi!</p>
        </div>

        <!-- Game Layout -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-4 lg:gap-6">

            <!-- Left Panel - Mobile: Row 1, Desktop: Left Column -->
            <div class="lg:col-span-3 order-1 lg:order-1">
                <div class="grid grid-cols-2 lg:grid-cols-1 gap-4">
                    <!-- Next Piece -->
                    <div class="bg-slate-800/50 backdrop-blur rounded-lg p-4 border border-slate-700">
                        <h3 class="text-white font-semibold text-center mb-3">Selanjutnya</h3>
                        <div class="flex justify-center">
                            <canvas id="nextCanvas" width="80" height="80" class="border border-slate-600 rounded bg-slate-900"></canvas>
                        </div>
                    </div>

                    <!-- Hold Piece -->
                    <div class="bg-slate-800/50 backdrop-blur rounded-lg p-4 border border-slate-700">
                        <h3 class="text-white font-semibold text-center mb-3">Simpan</h3>
                        <div class="flex justify-center">
                            <canvas id="holdCanvas" width="80" height="80" class="border border-slate-600 rounded bg-slate-900"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Game Area - Mobile: Row 2, Desktop: Center Column -->
            <div class="lg:col-span-6 order-2 lg:order-2">
                <!-- Score Bar -->
                <div class="grid grid-cols-4 gap-2 mb-4">
                    <div class="bg-slate-800/50 backdrop-blur rounded-lg p-3 border border-slate-700 text-center">
                        <div class="text-lg font-bold text-blue-400" id="scoreDisplay">0</div>
                        <div class="text-xs text-slate-400">Skor</div>
                    </div>
                    <div class="bg-slate-800/50 backdrop-blur rounded-lg p-3 border border-slate-700 text-center">
                        <div class="text-lg font-bold text-green-400" id="levelDisplay">1</div>
                        <div class="text-xs text-slate-400">Level</div>
                    </div>
                    <div class="bg-slate-800/50 backdrop-blur rounded-lg p-3 border border-slate-700 text-center">
                        <div class="text-lg font-bold text-yellow-400" id="linesDisplay">0</div>
                        <div class="text-xs text-slate-400">Baris</div>
                    </div>
                    <div class="bg-slate-800/50 backdrop-blur rounded-lg p-3 border border-slate-700 text-center">
                        <div class="text-lg font-bold text-red-400" id="highScoreDisplay">0</div>
                        <div class="text-xs text-slate-400">Terbaik</div>
                    </div>
                </div>

                <!-- Game Canvas -->
                <div class="relative bg-slate-800/50 backdrop-blur rounded-lg p-4 border border-slate-700">
                    <canvas id="gameCanvas" class="w-full max-w-md mx-auto block" width="300" height="300"></canvas>

                    <!-- Game Status -->
                    <div id="gameStatus" class="absolute top-2 right-2 bg-black/70 text-white px-2 py-1 rounded text-xs">
                        ▶️ Bermain
                    </div>

                    <!-- Pause Overlay -->
                    <div class="pause-overlay" id="pauseOverlay">
                        <div class="text-center text-white">
                            <div class="text-4xl mb-4">⏸️</div>
                            <div class="text-xl font-bold mb-2">GAME BERHENTI</div>
                            <div class="text-sm">Ketuk untuk melanjutkan</div>
                        </div>
                    </div>

                    <!-- Touch hint for mobile -->
                    <div class="mt-3 text-center text-slate-400 text-xs lg:hidden">
                        Ketuk: Putar | Geser: Pindah/Jatuh
                    </div>
                </div>
            </div>

            <!-- Right Panel - Mobile: Row 3, Desktop: Right Column -->
            <div class="lg:col-span-3 order-3 lg:order-3">
                <!-- Game Controls -->
                <div class="bg-slate-800/50 backdrop-blur rounded-lg p-4 border border-slate-700 mb-4">
                    <h3 class="text-white font-semibold text-center mb-3">Kontrol</h3>
                    <div class="space-y-2">
                        <button id="pauseBtn" class="w-full bg-yellow-600 hover:bg-yellow-700 text-white font-semibold py-2 px-4 rounded transition-colors">
                            ⏸️ Jeda
                        </button>
                        <button id="resetBtn" class="w-full bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-4 rounded transition-colors">
                            🔄 Reset
                        </button>
                    </div>
                </div>

                <!-- Mobile Touch Controls -->
                <div class="lg:hidden bg-slate-800/50 backdrop-blur rounded-lg p-4 border border-slate-700">
                    <h3 class="text-white font-semibold text-center mb-3">Kontrol Sentuh</h3>
                    <div class="grid grid-cols-3 gap-2">
                        <button id="rotateBtn" class="control-btn bg-purple-600 text-white">
                            🔄
                        </button>
                        <button id="holdBtn" class="control-btn bg-blue-600 text-white">
                            📥
                        </button>
                        <button id="hardDropBtn" class="control-btn bg-red-600 text-white">
                            ⬇️
                        </button>
                        <button id="leftBtn" class="control-btn bg-gray-600 text-white">
                            ⬅️
                        </button>
                        <button id="downBtn" class="control-btn bg-yellow-600 text-white">
                            ⬇️
                        </button>
                        <button id="rightBtn" class="control-btn bg-gray-600 text-white">
                            ➡️
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@push('styles')
<style>
    /* Control buttons */
    .control-btn {
        user-select: none;
        -webkit-user-select: none;
        transition: all 0.2s ease;
        touch-action: manipulation;
        -webkit-tap-highlight-color: transparent;
        padding: 8px;
        border-radius: 8px;
        font-size: 16px;
        min-height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .control-btn:active {
        transform: scale(0.95);
        filter: brightness(0.8);
    }

    /* Canvas touch settings */
    #gameCanvas {
        touch-action: none;
        -webkit-touch-callout: none;
        -webkit-user-select: none;
        user-select: none;
    }

    /* Pause overlay */
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
        border-radius: 8px;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.3s ease;
    }

    .pause-overlay.active {
        opacity: 1;
        pointer-events: all;
    }

    /* Game Over Modal */
    .game-over-modal {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.9);
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
        background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
        border: 1px solid #475569;
        padding: 1.5rem;
        border-radius: 16px;
        text-align: center;
        max-width: 350px;
        width: 90%;
        margin: 1rem;
        transform: scale(0.8);
        transition: transform 0.3s ease;
    }

    .game-over-modal.active .game-over-content {
        transform: scale(1);
    }

    /* Mobile Portrait */
    @media (max-width: 768px) and (orientation: portrait) {
        #gameCanvas {
            max-width: 280px;
            height: auto;
        }

        .container {
            padding-left: 8px;
            padding-right: 8px;
        }

        .text-3xl {
            font-size: 1.5rem;
        }
    }

    /* Mobile Landscape - Optimized Layout */
    @media (max-width: 896px) and (orientation: landscape) {
        .min-h-screen {
            min-height: 100vh;
            padding: 8px 0;
        }

        /* Header lebih kompak */
        .header-section {
            margin-bottom: 8px;
        }

        .header-section h1 {
            font-size: 1.5rem;
            margin-bottom: 4px;
        }

        .header-section p {
            font-size: 0.75rem;
        }

        /* Layout landscape: horizontal arrangement */
        .landscape-layout {
            display: grid;
            grid-template-columns: 1fr 300px 1fr;
            gap: 12px;
            height: calc(100vh - 80px);
            max-height: 500px;
        }

        /* Left panel - Next dan Hold dalam satu kolom */
        .left-panel {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .preview-box {
            padding: 8px;
            border-radius: 8px;
        }

        .preview-box h3 {
            font-size: 0.75rem;
            margin-bottom: 6px;
        }

        .preview-box canvas {
            width: 50px;
            height: 50px;
        }

        /* Score bar lebih kompak */
        .score-section {
            margin-bottom: 8px;
        }

        .score-item {
            padding: 6px;
            border-radius: 6px;
        }

        .score-item .score-value {
            font-size: 0.875rem;
            font-weight: bold;
        }

        .score-item .score-label {
            font-size: 0.625rem;
        }

        /* Game canvas area */
        .game-area {
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        .game-canvas-container {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 8px;
            border-radius: 8px;
            position: relative;
        }

        #gameCanvas {
            max-width: 240px;
            max-height: 360px;
            width: auto;
            height: auto;
        }

        #gameStatus {
            top: 4px;
            right: 4px;
            font-size: 0.625rem;
            padding: 2px 6px;
        }

        /* Right panel - Controls */
        .right-panel {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .control-section {
            padding: 8px;
            border-radius: 8px;
        }

        .control-section h3 {
            font-size: 0.75rem;
            margin-bottom: 6px;
        }

        .control-section button {
            padding: 6px 8px;
            font-size: 0.75rem;
            border-radius: 6px;
        }

        /* Touch controls untuk landscape */
        .touch-controls {
            padding: 8px;
            border-radius: 8px;
        }

        .touch-controls h3 {
            font-size: 0.75rem;
            margin-bottom: 6px;
        }

        .touch-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 4px;
        }

        .touch-grid .control-btn {
            padding: 6px;
            min-height: 36px;
            font-size: 14px;
        }

        /* Hide mobile touch hint in landscape */
        .mobile-hint {
            display: none;
        }

        /* Game over modal adjustment */
        .game-over-content {
            padding: 1rem;
            max-width: 300px;
        }

        .game-over-content h2 {
            font-size: 1.25rem;
            margin-bottom: 1rem;
        }

        .game-over-content .text-xl {
            font-size: 1rem;
        }

        .game-over-content button {
            padding: 6px 12px;
            font-size: 0.875rem;
        }
    }

    /* Very small landscape screens */
    @media (max-width: 667px) and (orientation: landscape) {
        .landscape-layout {
            grid-template-columns: 0.8fr 260px 0.8fr;
            gap: 8px;
            height: calc(100vh - 60px);
            max-height: 400px;
        }

        #gameCanvas {
            max-width: 200px;
            max-height: 300px;
        }

        .preview-box canvas {
            width: 40px;
            height: 40px;
        }

        .touch-grid .control-btn {
            min-height: 32px;
            font-size: 12px;
        }
    }

    /* iPhone SE landscape and similar */
    @media (max-width: 568px) and (orientation: landscape) {
        .landscape-layout {
            grid-template-columns: 0.7fr 220px 0.7fr;
            gap: 6px;
            height: calc(100vh - 50px);
            max-height: 350px;
        }

        #gameCanvas {
            max-width: 180px;
            max-height: 270px;
        }

        .header-section h1 {
            font-size: 1.25rem;
        }

        .control-section,
        .touch-controls,
        .preview-box {
            padding: 6px;
        }

        .touch-grid .control-btn {
            min-height: 28px;
            font-size: 11px;
            padding: 4px;
        }
    }
</style>
@endpush

<!-- Game Over Modal -->
<div class="game-over-modal" id="gameOverModal">
    <div class="game-over-content">
        <h2 class="text-2xl font-bold text-red-400 mb-4">🎮 Game Over!</h2>
        <div class="grid grid-cols-2 gap-4 mb-6">
            <div class="text-center">
                <div class="text-sm text-slate-400">Skor Akhir</div>
                <div class="text-xl font-bold text-white" id="finalScore">0</div>
            </div>
            <div class="text-center">
                <div class="text-sm text-slate-400">Level</div>
                <div class="text-xl font-bold text-white" id="finalLevel">1</div>
            </div>
            <div class="text-center">
                <div class="text-sm text-slate-400">Baris</div>
                <div class="text-xl font-bold text-white" id="finalLines">0</div>
            </div>
            <div class="text-center">
                <div class="text-sm text-slate-400">Terbaik</div>
                <div class="text-xl font-bold text-white" id="finalHighScore">0</div>
            </div>
        </div>
        <div id="newRecordBadge" class="bg-gradient-to-r from-yellow-500 to-orange-500 text-white px-4 py-2 rounded-full font-bold mb-4" style="display: none;">
            🏆 REKOR BARU!
        </div>
        <div class="flex flex-col sm:flex-row gap-3 justify-center">
            <button id="playAgainBtn" class="bg-purple-600 hover:bg-purple-700 text-white font-semibold py-2 px-6 rounded transition-colors">
                🎯 Main Lagi
            </button>
            <button onclick="history.back()" class="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-6 rounded transition-colors">
                ⬅️ Kembali
            </button>
        </div>
    </div>
</div>


<script>
document.addEventListener('DOMContentLoaded', () => {
    // Canvas setup
    const canvas = document.getElementById('gameCanvas');
    const ctx = canvas.getContext('2d');
    const nextCanvas = document.getElementById('nextCanvas');
    const nextCtx = nextCanvas.getContext('2d');
    const holdCanvas = document.getElementById('holdCanvas');
    const holdCtx = holdCanvas.getContext('2d');

    // Game constants
    const BLOCK_SIZE = 30;
    const BOARD_WIDTH = 10;
    const BOARD_HEIGHT = 10;
    const COLORS = {
        I: '#00f5ff', // Cyan
        O: '#ffff00', // Yellow
        T: '#a000f0', // Purple
        S: '#00f000', // Green
        Z: '#f00000', // Red
        J: '#0000f0', // Blue
        L: '#ff8000'  // Orange
    };

    // Tetromino shapes
    const PIECES = {
        I: [
            [1, 1, 1, 1]
        ],
        O: [
            [1, 1],
            [1, 1]
        ],
        T: [
            [0, 1, 0],
            [1, 1, 1]
        ],
        S: [
            [0, 1, 1],
            [1, 1, 0]
        ],
        Z: [
            [1, 1, 0],
            [0, 1, 1]
        ],
        J: [
            [1, 0, 0],
            [1, 1, 1]
        ],
        L: [
            [0, 0, 1],
            [1, 1, 1]
        ]
    };

    // Game state
    let board = Array(BOARD_HEIGHT).fill().map(() => Array(BOARD_WIDTH).fill(0));
    let currentPiece = null;
    let nextPiece = null;
    let holdPiece = null;
    let canHold = true;
    let score = 0;
    let level = 1;
    let lines = 0;
    let highScore = parseInt(localStorage.getItem('tetrisHighScore')) || 0;
    let gameRunning = false;
    let isPaused = false;
    let dropTimer = 0;
    let lastTime = 0;

    // UI elements
    const scoreEl = document.getElementById('scoreDisplay');
    const levelEl = document.getElementById('levelDisplay');
    const linesEl = document.getElementById('linesDisplay');
    const highScoreEl = document.getElementById('highScoreDisplay');
    const gameStatus = document.getElementById('gameStatus');
    const pauseBtn = document.getElementById('pauseBtn');
    const resetBtn = document.getElementById('resetBtn');
    const pauseOverlay = document.getElementById('pauseOverlay');
    const gameOverModal = document.getElementById('gameOverModal');

    // Initialize displays
    updateDisplay();

    class Piece {
        constructor(type, x = Math.floor(BOARD_WIDTH / 2) - 1, y = 0) {
            this.type = type;
            this.shape = PIECES[type];
            this.x = x;
            this.y = y;
            this.color = COLORS[type];
        }

        rotate() {
            const rotated = this.shape[0].map((_, i) =>
                this.shape.map(row => row[i]).reverse()
            );
            const oldShape = this.shape;
            this.shape = rotated;

            if (this.isColliding()) {
                this.shape = oldShape;
                return false;
            }
            return true;
        }

        move(dx, dy) {
            this.x += dx;
            this.y += dy;

            if (this.isColliding()) {
                this.x -= dx;
                this.y -= dy;
                return false;
            }
            return true;
        }

        isColliding() {
            for (let y = 0; y < this.shape.length; y++) {
                for (let x = 0; x < this.shape[y].length; x++) {
                    if (this.shape[y][x]) {
                        const boardX = this.x + x;
                        const boardY = this.y + y;

                        if (boardX < 0 || boardX >= BOARD_WIDTH ||
                            boardY >= BOARD_HEIGHT ||
                            (boardY >= 0 && board[boardY][boardX])) {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        place() {
            for (let y = 0; y < this.shape.length; y++) {
                for (let x = 0; x < this.shape[y].length; x++) {
                    if (this.shape[y][x]) {
                        const boardY = this.y + y;
                        if (boardY >= 0) {
                            board[boardY][this.x + x] = this.color;
                        }
                    }
                }
            }
        }
    }

    function createRandomPiece() {
        const pieces = Object.keys(PIECES);
        const randomType = pieces[Math.floor(Math.random() * pieces.length)];
        return new Piece(randomType);
    }

    function spawnPiece() {
        if (!nextPiece) {
            nextPiece = createRandomPiece();
        }
        currentPiece = nextPiece;
        nextPiece = createRandomPiece();
        canHold = true;

        if (currentPiece.isColliding()) {
            gameOver();
        }
    }

    function holdCurrentPiece() {
        if (!canHold || !currentPiece) return;

        if (holdPiece) {
            [currentPiece, holdPiece] = [holdPiece, currentPiece];
            currentPiece.x = Math.floor(BOARD_WIDTH / 2) - 1;
            currentPiece.y = 0;
        } else {
            holdPiece = currentPiece;
            spawnPiece();
        }
        canHold = false;
    }

    function clearLines() {
        let linesCleared = 0;
        const linesToClear = [];

        for (let y = BOARD_HEIGHT - 1; y >= 0; y--) {
            if (board[y].every(cell => cell !== 0)) {
                linesToClear.push(y);
                linesCleared++;
            }
        }

        if (linesCleared > 0) {
            // Animation for line clearing
            linesToClear.forEach(y => {
                for (let x = 0; x < BOARD_WIDTH; x++) {
                    board[y][x] = '#ffffff';
                }
            });

            draw();

            setTimeout(() => {
                // Remove cleared lines
                linesToClear.sort((a, b) => b - a);
                linesToClear.forEach(y => {
                    board.splice(y, 1);
                    board.unshift(Array(BOARD_WIDTH).fill(0));
                });

                // Update score
                const lineScores = [0, 100, 300, 500, 800];
                score += lineScores[linesCleared] * level;
                lines += linesCleared;
                level = Math.floor(lines / 10) + 1;

                updateDisplay();
            }, 500);
        }
    }

    function hardDrop() {
        if (!currentPiece) return;

        let dropDistance = 0;
        while (currentPiece.move(0, 1)) {
            dropDistance++;
        }

        score += dropDistance * 2;
        currentPiece.place();
        clearLines();
        spawnPiece();
        updateDisplay();
    }

    function softDrop() {
        if (currentPiece && currentPiece.move(0, 1)) {
            score += 1;
            updateDisplay();
        }
    }

    function update(time = 0) {
        if (!gameRunning || isPaused) {
            requestAnimationFrame(update);
            return;
        }

        const deltaTime = time - lastTime;
        lastTime = time;
        dropTimer += deltaTime;

        const dropInterval = Math.max(50, 1000 - (level - 1) * 50);

        if (dropTimer > dropInterval) {
            if (currentPiece) {
                if (!currentPiece.move(0, 1)) {
                    currentPiece.place();
                    clearLines();
                    spawnPiece();
                }
            }
            dropTimer = 0;
        }

        draw();
        requestAnimationFrame(update);
    }

    function draw() {
        // Clear main canvas
        ctx.fillStyle = '#1f2937';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Draw grid
        ctx.strokeStyle = '#374151';
        ctx.lineWidth = 1;
        for (let x = 0; x <= BOARD_WIDTH; x++) {
            ctx.beginPath();
            ctx.moveTo(x * BLOCK_SIZE, 0);
            ctx.lineTo(x * BLOCK_SIZE, BOARD_HEIGHT * BLOCK_SIZE);
            ctx.stroke();
        }
        for (let y = 0; y <= BOARD_HEIGHT; y++) {
            ctx.beginPath();
            ctx.moveTo(0, y * BLOCK_SIZE);
            ctx.lineTo(BOARD_WIDTH * BLOCK_SIZE, y * BLOCK_SIZE);
            ctx.stroke();
        }

        // Draw placed pieces
        for (let y = 0; y < BOARD_HEIGHT; y++) {
            for (let x = 0; x < BOARD_WIDTH; x++) {
                if (board[y][x]) {
                    drawBlock(ctx, x * BLOCK_SIZE, y * BLOCK_SIZE, board[y][x]);
                }
            }
        }

        // Draw current piece
        if (currentPiece) {
            drawPiece(ctx, currentPiece, currentPiece.x * BLOCK_SIZE, currentPiece.y * BLOCK_SIZE);
        }

        // Draw next piece
        drawNextPiece();
        drawHoldPiece();
    }

    function drawBlock(context, x, y, color) {
        context.fillStyle = color;
        context.fillRect(x + 1, y + 1, BLOCK_SIZE - 2, BLOCK_SIZE - 2);

        // Add border effect
        context.strokeStyle = '#ffffff';
        context.lineWidth = 1;
        context.strokeRect(x + 1, y + 1, BLOCK_SIZE - 2, BLOCK_SIZE - 2);
    }

    function drawPiece(context, piece, offsetX, offsetY) {
        piece.shape.forEach((row, y) => {
            row.forEach((cell, x) => {
                if (cell) {
                    drawBlock(context, offsetX + x * BLOCK_SIZE, offsetY + y * BLOCK_SIZE, piece.color);
                }
            });
        });
    }

    function drawNextPiece() {
        nextCtx.fillStyle = '#1f2937';
        nextCtx.fillRect(0, 0, nextCanvas.width, nextCanvas.height);

        if (nextPiece) {
            const offsetX = (nextCanvas.width - nextPiece.shape[0].length * 20) / 2;
            const offsetY = (nextCanvas.height - nextPiece.shape.length * 20) / 2;

            nextPiece.shape.forEach((row, y) => {
                row.forEach((cell, x) => {
                    if (cell) {
                        nextCtx.fillStyle = nextPiece.color;
                        nextCtx.fillRect(offsetX + x * 20, offsetY + y * 20, 18, 18);
                    }
                });
            });
        }
    }

    function drawHoldPiece() {
        holdCtx.fillStyle = '#1f2937';
        holdCtx.fillRect(0, 0, holdCanvas.width, holdCanvas.height);

        if (holdPiece) {
            const offsetX = (holdCanvas.width - holdPiece.shape[0].length * 20) / 2;
            const offsetY = (holdCanvas.height - holdPiece.shape.length * 20) / 2;

            holdPiece.shape.forEach((row, y) => {
                row.forEach((cell, x) => {
                    if (cell) {
                        holdCtx.fillStyle = canHold ? holdPiece.color : '#666666';
                        holdCtx.fillRect(offsetX + x * 20, offsetY + y * 20, 18, 18);
                    }
                });
            });
        }
    }

    function updateDisplay() {
        scoreEl.textContent = score.toLocaleString();
        levelEl.textContent = level;
        linesEl.textContent = lines;
        highScoreEl.textContent = highScore.toLocaleString();
    }

    function startGame() {
        board = Array(BOARD_HEIGHT).fill().map(() => Array(BOARD_WIDTH).fill(0));
        score = 0;
        level = 1;
        lines = 0;
        currentPiece = null;
        nextPiece = null;
        holdPiece = null;
        canHold = true;
        gameRunning = true;
        isPaused = false;

        spawnPiece();
        updateDisplay();
        gameStatus.textContent = '▶️ Playing';
        requestAnimationFrame(update);
    }

    function pauseGame() {
        isPaused = !isPaused;
        if (isPaused) {
            pauseOverlay.classList.add('active');
            pauseBtn.textContent = '▶️ Resume';
            gameStatus.textContent = '⏸️ Paused';
        } else {
            pauseOverlay.classList.remove('active');
            pauseBtn.textContent = '⏸️ Pause';
            gameStatus.textContent = '▶️ Playing';
        }
    }

    function gameOver() {
        gameRunning = false;
        gameStatus.textContent = '💀 Game Over';

        // Update high score
        if (score > highScore) {
            highScore = score;
            localStorage.setItem('tetrisHighScore', highScore);
            document.getElementById('newRecordBadge').style.display = 'block';
        }
                // Tampilkan modal game over
                gameOverModal.classList.add('active');

// Update tampilan skor akhir
document.getElementById('finalScore').textContent = score.toLocaleString();
document.getElementById('finalLevel').textContent = level;
document.getElementById('finalLines').textContent = lines;
document.getElementById('finalHighScore').textContent = highScore.toLocaleString();

// Reset game state
board = Array(BOARD_HEIGHT).fill().map(() => Array(BOARD_WIDTH).fill(0));
currentPiece = null;
nextPiece = null;
holdPiece = null;
canHold = true;
score = 0;
level = 1;
lines = 0;
gameRunning = false;
isPaused = false;

// Update display
updateDisplay();
}

// Event listeners untuk tombol di modal game over
document.getElementById('playAgainBtn').addEventListener('click', () => {
gameOverModal.classList.remove('active');
startGame();
});

// Tombol reset game
resetBtn.addEventListener('click', () => {
gameOverModal.classList.remove('active');
startGame();
});

// Tombol pause game
pauseBtn.addEventListener('click', pauseGame);

// Keyboard controls
document.addEventListener('keydown', (e) => {
if (!gameRunning || isPaused) return;

switch (e.code) {
    case 'ArrowLeft':
        currentPiece && currentPiece.move(-1, 0);
        break;
    case 'ArrowRight':
        currentPiece && currentPiece.move(1, 0);
        break;
    case 'ArrowDown':
        softDrop();
        break;
    case 'Space':
        hardDrop();
        break;
    case 'ArrowUp':
        currentPiece && currentPiece.rotate();
        break;
    case 'KeyC':
        holdCurrentPiece();
        break;
    case 'KeyP':
        pauseGame();
        break;
}

draw();
});
// Tambahkan setelah event listener keyboard
// Touch and gesture controls
let touchStartX = 0;
let touchStartY = 0;
let touchStartTime = 0;
const SWIPE_THRESHOLD = 50;
const TAP_THRESHOLD = 200;

// Mobile button controls
document.getElementById('leftBtn').addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (currentPiece && gameRunning && !isPaused) {
        currentPiece.move(-1, 0);
        draw();
    }
});

document.getElementById('rightBtn').addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (currentPiece && gameRunning && !isPaused) {
        currentPiece.move(1, 0);
        draw();
    }
});

document.getElementById('downBtn').addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (gameRunning && !isPaused) {
        softDrop();
        draw();
    }
});

document.getElementById('rotateBtn').addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (currentPiece && gameRunning && !isPaused) {
        currentPiece.rotate();
        draw();
    }
});

document.getElementById('holdBtn').addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (gameRunning && !isPaused) {
        holdCurrentPiece();
        draw();
    }
});

document.getElementById('hardDropBtn').addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (gameRunning && !isPaused) {
        hardDrop();
    }
});

// Canvas touch controls (gesture)
canvas.addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (!gameRunning || isPaused) return;

    const touch = e.touches[0];
    touchStartX = touch.clientX;
    touchStartY = touch.clientY;
    touchStartTime = Date.now();
});

canvas.addEventListener('touchend', (e) => {
    e.preventDefault();
    if (!gameRunning || isPaused) return;

    const touch = e.changedTouches[0];
    const touchEndX = touch.clientX;
    const touchEndY = touch.clientY;
    const touchEndTime = Date.now();

    const deltaX = touchEndX - touchStartX;
    const deltaY = touchEndY - touchStartY;
    const deltaTime = touchEndTime - touchStartTime;

    // Tap (quick touch) - rotate
    if (Math.abs(deltaX) < 30 && Math.abs(deltaY) < 30 && deltaTime < TAP_THRESHOLD) {
        if (currentPiece) {
            currentPiece.rotate();
            draw();
        }
        return;
    }

    // Swipe gestures
    if (Math.abs(deltaX) > Math.abs(deltaY)) {
        // Horizontal swipe
        if (Math.abs(deltaX) > SWIPE_THRESHOLD) {
            if (deltaX > 0) {
                // Swipe right
                currentPiece && currentPiece.move(1, 0);
            } else {
                // Swipe left
                currentPiece && currentPiece.move(-1, 0);
            }
        }
    } else {
        // Vertical swipe
        if (Math.abs(deltaY) > SWIPE_THRESHOLD) {
            if (deltaY > 0) {
                // Swipe down - soft drop
                softDrop();
            } else {
                // Swipe up - hard drop
                hardDrop();
                return; // Hard drop sudah memanggil draw
            }
        }
    }

    draw();
});

// Prevent default touch behavior on canvas
canvas.addEventListener('touchmove', (e) => {
    e.preventDefault();
});

// Haptic feedback untuk mobile (jika didukung)
function hapticFeedback() {
    if (navigator.vibrate) {
        navigator.vibrate(50);
    }
}

// Tambahkan haptic feedback ke fungsi-fungsi game
const originalRotate = Piece.prototype.rotate;
Piece.prototype.rotate = function() {
    const result = originalRotate.call(this);
    if (result) hapticFeedback();
    return result;
};

const originalClearLines = clearLines;
function clearLines() {
    let linesCleared = 0;
    const linesToClear = [];

    for (let y = BOARD_HEIGHT - 1; y >= 0; y--) {
        if (board[y].every(cell => cell !== 0)) {
            linesToClear.push(y);
            linesCleared++;
        }
    }

    if (linesCleared > 0) {
        // Animation for line clearing
        linesToClear.forEach(y => {
            for (let x = 0; x < BOARD_WIDTH; x++) {
                board[y][x] = '#ffffff';
            }
        });

        draw();

        // Haptic feedback untuk line clear
        if (navigator.vibrate) {
            navigator.vibrate([100, 50, 100]);
        }

        setTimeout(() => {
            // Remove cleared lines
            linesToClear.sort((a, b) => b - a);
            linesToClear.forEach(y => {
                board.splice(y, 1);
                board.unshift(Array(BOARD_WIDTH).fill(0));
            });

            // Update score
            const lineScores = [0, 100, 300, 500, 800];
            score += lineScores[linesCleared] * level;
            lines += linesCleared;
            level = Math.floor(lines / 10) + 1;

            updateDisplay();
        }, 500);
    }

    return linesCleared; // Return jumlah baris yang dibersihkan
}

// Mulai game saat halaman dimuat
startGame();
});
</script>

