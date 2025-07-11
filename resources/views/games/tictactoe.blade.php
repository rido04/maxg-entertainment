@extends('layouts.app')

@section('content')
<style>
    @font-face {
    font-family: "Orbitron";
    font-style: normal;
    font-weight: 400;
    src: url("../fonts/Orbitron-Regular.woff2") format("woff2"),
        url("../fonts/Orbitron-Regular.ttf") format("truetype");
    }

    @font-face {
        font-family: "Orbitron";
        font-style: normal;
        font-weight: 700;
        src: url("../fonts/Orbitron-Bold.woff2") format("woff2"),
            url("../fonts/Orbitron-Bold.ttf") format("truetype");
    }

    @font-face {
        font-family: "Orbitron";
        font-style: normal;
        font-weight: 900;
        src: url("../fonts/Orbitron-Black.woff2") format("woff2"),
            url("../fonts/Orbitron-Black.ttf") format("truetype");
    }
  .game-container {
    font-family: 'Orbitron', monospace;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    padding: 2rem;
  }

  .game-card {
    backdrop-filter: blur(15px);
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
    border-radius: 20px;
  }

  .cell {
    background: linear-gradient(145deg, #2a2a40, #1a1a30);
    border: 2px solid rgba(255, 255, 255, 0.1);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    border-radius: 12px;
    position: relative;
    overflow: hidden;
  }

  .cell:hover {
    background: linear-gradient(145deg, #3a3a50, #2a2a40);
    border-color: rgba(255, 255, 255, 0.3);
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
  }

  .cell::before {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.1), transparent);
    transform: translateX(-100%);
    transition: transform 0.6s;
  }

  .cell:hover::before {
    transform: translateX(100%);
  }

  .cell-content {
    font-size: 3rem;
    font-weight: 900;
    text-shadow: 0 0 20px currentColor;
    animation: fadeInScale 0.3s ease-out;
  }

  .cell-x {
    color: #ff6b6b;
    text-shadow: 0 0 20px #ff6b6b;
  }

  .cell-o {
    color: #4ecdc4;
    text-shadow: 0 0 20px #4ecdc4;
  }

  .winning-cell {
    background: linear-gradient(145deg, #ffd93d, #ff6b6b) !important;
    animation: winPulse 1s infinite alternate;
  }

  .winning-cell .cell-content {
    color: #2a2a40 !important;
    text-shadow: none !important;
  }

  .game-button {
    background: linear-gradient(145deg, #667eea, #764ba2);
    border: 2px solid rgba(255, 255, 255, 0.2);
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
  }

  .game-button:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  }

  .game-button::before {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    transform: translateX(-100%);
    transition: transform 0.6s;
  }

  .game-button:hover::before {
    transform: translateX(100%);
  }

  .status-text {
    background: linear-gradient(45deg, #ff6b6b, #4ecdc4, #45b7d1, #96c93d);
    background-size: 300% 300%;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: gradientShift 3s ease infinite;
  }

  .difficulty-selector {
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 12px;
    padding: 1rem;
    margin-bottom: 1.5rem;
  }

  .difficulty-btn {
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    transition: all 0.3s ease;
  }

  .difficulty-btn.active {
    background: linear-gradient(145deg, #667eea, #764ba2);
    border-color: rgba(255, 255, 255, 0.4);
  }

  @keyframes fadeInScale {
    from {
      opacity: 0;
      transform: scale(0.5);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }

  @keyframes winPulse {
    from {
      transform: scale(1);
      box-shadow: 0 0 20px rgba(255, 215, 61, 0.5);
    }
    to {
      transform: scale(1.05);
      box-shadow: 0 0 30px rgba(255, 215, 61, 0.8);
    }
  }

  @keyframes gradientShift {
    0% {
      background-position: 0% 50%;
    }
    50% {
      background-position: 100% 50%;
    }
    100% {
      background-position: 0% 50%;
    }
  }

  .game-grid {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 16px;
    padding: 1rem;
    border: 2px solid rgba(255, 255, 255, 0.1);
  }

  .score-board {
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 12px;
    padding: 1rem;
    margin-bottom: 1.5rem;
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

<div class="game-container flex flex-col items-center">
    <div class="game-card p-8 max-w-md w-full">
      <!-- Back Button -->
      <div class="mb-4">
        <button onclick="history.back()" class="game-button px-4 py-2 rounded-lg text-white font-bold flex items-center gap-2 text-sm">
          ⬅️ Back
        </button>
      </div>

      <h1 class="text-4xl font-black mb-6 text-center text-white">
        🎮 <span class="status-text">Tic Tac Toe</span>
      </h1>

    <!-- Score Board -->
    <div class="score-board text-center">
      <h3 class="text-white text-lg font-bold mb-2">Score Board</h3>
      <div class="flex justify-between text-white">
        <div>
          <span class="cell-x">Player X:</span>
          <span id="scoreX" class="font-bold">0</span>
        </div>
        <div>
          <span class="cell-o">Player O:</span>
          <span id="scoreO" class="font-bold">0</span>
        </div>
        <div>
          <span class="text-yellow-400">Draws:</span>
          <span id="scoreDraw" class="font-bold">0</span>
        </div>
      </div>
    </div>

    <!-- Difficulty Selector -->
    <div class="difficulty-selector hidden" id="difficultySelector">
      <h3 class="text-white text-lg font-bold mb-3 text-center">Select Difficulty</h3>
      <div class="flex gap-2 justify-center">
        <button onclick="setDifficulty('easy')" class="difficulty-btn px-3 py-2 rounded text-white text-sm" data-difficulty="easy">Easy</button>
        <button onclick="setDifficulty('medium')" class="difficulty-btn active px-3 py-2 rounded text-white text-sm" data-difficulty="medium">Medium</button>
        <button onclick="setDifficulty('hard')" class="difficulty-btn px-3 py-2 rounded text-white text-sm" data-difficulty="hard">Hard</button>
      </div>
    </div>

    <!-- Game Mode Buttons -->
    <div class="mb-6 flex gap-4 justify-center">
      <button onclick="startGame('human')" class="game-button px-6 py-3 rounded-lg text-white font-bold">
        👥 Play with Friend
      </button>
      <button onclick="startGame('bot')" class="game-button px-6 py-3 rounded-lg text-white font-bold">
        🤖 Play vs Computer
      </button>
    </div>

    <!-- Game Board -->
    <div class="game-grid hidden" id="gameContainer">
      <div id="game" class="grid grid-cols-3 gap-3 w-[300px] h-[300px] mx-auto">
        @for ($i = 0; $i < 9; $i++)
          <div class="cell text-white flex items-center justify-center cursor-pointer" data-index="{{ $i }}">
            <span class="cell-content"></span>
          </div>
        @endfor
      </div>
    </div>

    <!-- Status and Reset -->
    <div id="status" class="mt-6 text-white text-xl font-bold text-center">
      Choose a game mode above
    </div>

    <div class="flex gap-4 justify-center mt-4">
      <button onclick="resetGame()" class="game-button px-6 py-2 rounded-lg text-white font-bold hidden" id="resetBtn">
        🔄 Play Again
      </button>
      <button onclick="resetScore()" class="game-button px-6 py-2 rounded-lg text-white font-bold hidden" id="resetScoreBtn">
        📊 Reset Score
      </button>
    </div>
  </div>
</div>

<script>
  const cells = document.querySelectorAll('.cell');
  const cellContents = document.querySelectorAll('.cell-content');
  const status = document.getElementById('status');
  const gameContainer = document.getElementById('gameContainer');
  const resetBtn = document.getElementById('resetBtn');
  const resetScoreBtn = document.getElementById('resetScoreBtn');
  const difficultySelector = document.getElementById('difficultySelector');

  let board = Array(9).fill(null);
  let currentPlayer = 'X';
  let gameActive = true;
  let vsBot = false;
  let botDifficulty = 'medium';
  let scores = { X: 0, O: 0, draw: 0 };

  const winningCombos = [
    [0,1,2],[3,4,5],[6,7,8],
    [0,3,6],[1,4,7],[2,5,8],
    [0,4,8],[2,4,6]
  ];

  function startGame(mode) {
    vsBot = (mode === 'bot');
    gameContainer.classList.remove('hidden');
    resetBtn.classList.remove('hidden');
    resetScoreBtn.classList.remove('hidden');

    if (vsBot) {
      difficultySelector.classList.remove('hidden');
    } else {
      difficultySelector.classList.add('hidden');
    }

    resetGame();
  }

  function setDifficulty(difficulty) {
    botDifficulty = difficulty;
    document.querySelectorAll('.difficulty-btn').forEach(btn => {
      btn.classList.remove('active');
    });
    document.querySelector(`[data-difficulty="${difficulty}"]`).classList.add('active');
  }

  function checkWin() {
    for (const combo of winningCombos) {
      const [a, b, c] = combo;
      if (board[a] && board[a] === board[b] && board[a] === board[c]) {
        gameActive = false;
        status.innerHTML = `🎉 Player ${board[a]} wins!`;
        highlightWinningCells(combo);
        updateScore(board[a]);
        return board[a];
      }
    }

    if (!board.includes(null)) {
      gameActive = false;
      status.innerHTML = '🤝 It\'s a draw!';
      updateScore('draw');
      return 'draw';
    }
    return null;
  }

  function highlightWinningCells(combo) {
    combo.forEach(index => {
      cells[index].classList.add('winning-cell');
    });
  }

  function updateScore(winner) {
    if (winner === 'draw') {
      scores.draw++;
      document.getElementById('scoreDraw').textContent = scores.draw;
    } else {
      scores[winner]++;
      document.getElementById(`score${winner}`).textContent = scores[winner];
    }
  }

  function resetScore() {
    scores = { X: 0, O: 0, draw: 0 };
    document.getElementById('scoreX').textContent = '0';
    document.getElementById('scoreO').textContent = '0';
    document.getElementById('scoreDraw').textContent = '0';
  }

  function handleClick(e) {
    if (!gameActive) return;

    const index = e.currentTarget.dataset.index;
    if (board[index]) return;

    makeMove(index, currentPlayer);

    const winner = checkWin();
    if (winner || !gameActive) return;

    if (vsBot) {
      currentPlayer = 'O';
      status.innerHTML = '🤖 Computer is thinking...';

      setTimeout(() => {
        makeBotMove();
      }, Math.random() * 1000 + 500); // Random delay for realism
    } else {
      currentPlayer = currentPlayer === 'X' ? 'O' : 'X';
      status.innerHTML = `Player ${currentPlayer}'s turn`;
    }
  }

  function makeMove(index, player) {
    board[index] = player;
    const cellContent = cellContents[index];
    cellContent.textContent = player;
    cellContent.classList.add(player === 'X' ? 'cell-x' : 'cell-o');
  }

  function makeBotMove() {
    if (!gameActive) return;

    let index;

    if (botDifficulty === 'easy') {
      index = getRandomMove();
    } else if (botDifficulty === 'medium') {
      index = getSmartMove();
    } else {
      index = getBestMove();
    }

    makeMove(index, 'O');

    const winner = checkWin();
    if (winner) return;

    currentPlayer = 'X';
    status.innerHTML = `Player ${currentPlayer}'s turn`;
  }

  function getRandomMove() {
    const emptyCells = board.map((cell, index) => cell === null ? index : null).filter(val => val !== null);
    return emptyCells[Math.floor(Math.random() * emptyCells.length)];
  }

  function getSmartMove() {
    // Try to win
    for (let i = 0; i < 9; i++) {
      if (board[i] === null) {
        board[i] = 'O';
        if (checkWinCondition('O')) {
          board[i] = null;
          return i;
        }
        board[i] = null;
      }
    }

    // Block player from winning
    for (let i = 0; i < 9; i++) {
      if (board[i] === null) {
        board[i] = 'X';
        if (checkWinCondition('X')) {
          board[i] = null;
          return i;
        }
        board[i] = null;
      }
    }

    // Take center if available
    if (board[4] === null) return 4;

    // Take corners
    const corners = [0, 2, 6, 8];
    const availableCorners = corners.filter(i => board[i] === null);
    if (availableCorners.length > 0) {
      return availableCorners[Math.floor(Math.random() * availableCorners.length)];
    }

    return getRandomMove();
  }

  function checkWinCondition(player) {
    return winningCombos.some(combo => {
      const [a, b, c] = combo;
      return board[a] === player && board[b] === player && board[c] === player;
    });
  }

  function getBestMove() {
    let bestScore = -Infinity;
    let move;

    for (let i = 0; i < 9; i++) {
      if (board[i] === null) {
        board[i] = 'O';
        let score = minimax(board, 0, false);
        board[i] = null;
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }

    return move;
  }

  function minimax(board, depth, isMaximizing) {
    if (checkWinCondition('O')) return 10 - depth;
    if (checkWinCondition('X')) return depth - 10;
    if (!board.includes(null)) return 0;

    if (isMaximizing) {
      let bestScore = -Infinity;
      for (let i = 0; i < 9; i++) {
        if (board[i] === null) {
          board[i] = 'O';
          let score = minimax(board, depth + 1, false);
          board[i] = null;
          bestScore = Math.max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      let bestScore = Infinity;
      for (let i = 0; i < 9; i++) {
        if (board[i] === null) {
          board[i] = 'X';
          let score = minimax(board, depth + 1, true);
          board[i] = null;
          bestScore = Math.min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  function resetGame() {
    board = Array(9).fill(null);
    cells.forEach((cell, index) => {
      const cellContent = cellContents[index];
      cellContent.textContent = '';
      cellContent.classList.remove('cell-x', 'cell-o');
      cell.classList.remove('winning-cell');
    });

    currentPlayer = 'X';
    gameActive = true;

    if (gameContainer.classList.contains('hidden')) {
      status.innerHTML = 'Choose a game mode above';
    } else {
      status.innerHTML = vsBot ? 'You are X, make your move!' : `Player ${currentPlayer}'s turn`;
    }
  }

  // Add event listeners
  cells.forEach(cell => cell.addEventListener('click', handleClick));
</script>
@endsection
