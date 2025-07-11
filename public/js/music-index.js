// Global variables dan functions untuk audio player
let currentSong = null;
let isPlaying = false;

function playAudio(songId, audioUrl, title, artist, thumbnail) {
// Pastikan AudioStorage sudah loaded
if (typeof AudioStorage === 'undefined') {
    console.error('AudioStorage not loaded');
    return;
}

const audioPlayer = document.getElementById('audioPlayer');
const audioSource = document.getElementById('audioSource');

// Update audio source
audioSource.src = audioUrl;
audioPlayer.load();

// Save to storage SEBELUM play
const songData = { songId, audioUrl, title, artist, thumbnail };
AudioStorage.save.currentSong(songData);

// Update mini player
document.getElementById('miniTitle').textContent = title;
document.getElementById('miniArtist').textContent = artist;

// Show mini player
const miniPlayer = document.getElementById('miniPlayer');
if (miniPlayer) {
    const miniPlayerContent = miniPlayer.querySelector('.mini-player-content') ||
                              miniPlayer.querySelector('[class*="flex"][class*="items-center"]:first-child');

    if (miniPlayerContent) {
        miniPlayerContent.style.cursor = 'pointer';

        miniPlayerContent.addEventListener('click', function(e) {
            if (e.target.closest('button') || e.target.closest('[role="button"]')) {
                return;
            }

            const currentSong = AudioStorage.get.currentSong();
            if (currentSong && currentSong.songId) {
                window.location.href = `/music/${currentSong.songId}`;
            }
        });
    }
}
miniPlayer.classList.remove('hidden');
miniPlayer.style.transform = 'translateY(0)';

// Play audio
audioPlayer.play().then(() => {
    AudioStorage.save.playbackState('playing');
    // Update global manager
    if (window.audioManager) {
        window.audioManager.currentSong = songData;
    }
    isPlaying = true;
    currentSong = songId;
    updatePlayButton(true);
}).catch(error => {
    console.error('Error playing audio:', error);
});
}

function updatePlayButton(playing) {
  const playIcon = document.getElementById('miniPlayIcon');
  const pauseIcon = document.getElementById('miniPauseIcon');

  if (playing) {
    playIcon.classList.add('hidden');
    pauseIcon.classList.remove('hidden');
  } else {
    playIcon.classList.remove('hidden');
    pauseIcon.classList.add('hidden');
  }
}

function formatTime(seconds) {
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return mins + ':' + (secs < 10 ? '0' : '') + secs;
}
function togglePasswordVisibility() {
    const passwordInput = document.getElementById('password');
    const eyeOpen = document.getElementById('eye-open');
    const eyeClosed = document.getElementById('eye-closed');

    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        eyeOpen.classList.add('hidden');
        eyeClosed.classList.remove('hidden');
    } else {
        passwordInput.type = 'password';
        eyeOpen.classList.remove('hidden');
        eyeClosed.classList.add('hidden');
    }
}

document.addEventListener('DOMContentLoaded', function() {
  // Update time display
  function updateTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true
    });
    document.getElementById('current-time').textContent = timeString;
  }

  updateTime();
  setInterval(updateTime, 1000);

  document.querySelector('input[name="q"]').addEventListener('focus', function () {
    this.removeAttribute('readonly'); // Pastikan readonly dihapus
});

  // Dynamic greeting based on time
  function updateGreeting() {
    const hour = new Date().getHours();
    const greeting = document.getElementById('greeting');

    if (hour < 12) {
      greeting.textContent = 'Good morning';
    } else if (hour < 17) {
      greeting.textContent = 'Good afternoon';
    } else {
      greeting.textContent = 'Good evening';
    }
  }

  updateGreeting();

  // Add smooth scrolling for horizontal sections
  document.querySelectorAll('.overflow-x-auto').forEach(container => {
    let isDown = false;
    let startX;
    let scrollLeft;

    container.addEventListener('mousedown', (e) => {
      isDown = true;
      startX = e.pageX - container.offsetLeft;
      scrollLeft = container.scrollLeft;
      container.style.cursor = 'grabbing';
    });

    container.addEventListener('mouseleave', () => {
      isDown = false;
      container.style.cursor = 'grab';
    });

    container.addEventListener('mouseup', () => {
      isDown = false;
      container.style.cursor = 'grab';
    });

    container.addEventListener('mousemove', (e) => {
      if (!isDown) return;
      e.preventDefault();
      const x = e.pageX - container.offsetLeft;
      const walk = (x - startX) * 2;
      container.scrollLeft = scrollLeft - walk;
    });
  });

  // Mini player controls
  document.getElementById('miniPlayBtn').addEventListener('click', function() {
    const audioPlayer = document.getElementById('audioPlayer');

    if (isPlaying) {
      audioPlayer.pause();
      isPlaying = false;
      updatePlayButton(false);
    } else {
      audioPlayer.play();
      isPlaying = true;
      updatePlayButton(true);
    }
  });

  document.getElementById('miniCloseBtn').addEventListener('click', function() {
  const audioPlayer = document.getElementById('audioPlayer');
  const miniPlayer = document.getElementById('miniPlayer');

  audioPlayer.pause();
  audioPlayer.currentTime = 0;
  isPlaying = false;
  currentSong = null;

  // CLEAR STORAGE saat close
  AudioStorage.clear();

  // Clear global manager
  if (window.audioManager) {
      window.audioManager.currentSong = null;
  }

  miniPlayer.style.transform = 'translateY(100%)';
  setTimeout(() => {
      miniPlayer.classList.add('hidden');
  }, 300);
});

  // Update progress bar
  document.getElementById('audioPlayer').addEventListener('timeupdate', function() {
    const audioPlayer = this;
    const progressBar = document.getElementById('miniProgressBar');
    const currentTimeSpan = document.getElementById('miniCurrentTime');
    const totalTimeSpan = document.getElementById('miniTotalTime');

    if (audioPlayer.duration) {
      const progress = (audioPlayer.currentTime / audioPlayer.duration) * 100;
    }
  });

  // Auto-play next song when current ends
  document.getElementById('audioPlayer').addEventListener('ended', function() {
    isPlaying = false;
    updatePlayButton(false);
  });
    document.getElementById('syncForm').addEventListener('submit', function(e) {
    e.preventDefault();

    const password = document.getElementById('password').value;
    const syncBtn = document.getElementById('syncBtn');
    const errorDiv = document.getElementById('error-message');
    const syncBtnText = document.getElementById('sync-btn-text');
    const syncLoading = document.getElementById('sync-loading');
    const errorText = document.getElementById('error-text');
    const successDiv = document.getElementById('success-message');
    const successText = document.getElementById('success-text');

    // Reset error
    errorDiv.classList.add('hidden');
    successDiv.classList.add('hidden');

    // Show loading
    syncBtn.disabled = true;
    syncBtn.innerHTML = 'Verifying...';
    syncLoading.classList.remove('hidden');

    // Verify password first
    fetch('/music/verify-password', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ password: password })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Password correct, proceed with sync
            syncBtn.innerHTML = 'Syncing...';
            return fetch('/music/sync', {
                method: 'GET',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                }
            });
        } else {
            throw new Error('Invalid password');
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            document.getElementById('successModal').classList.remove('hidden');
            bootstrap.Modal.getInstance(document.getElementById('syncModal')).hide();
        } else {
            throw new Error(data.message || 'Sync failed');
        }
    })
    .catch(error => {
        errorDiv.textContent = error.message;
        errorDiv.classList.remove('hidden');
    })
    .finally(() => {
        syncBtn.disabled = false;
        syncBtn.innerHTML = 'Start Sync';
        document.getElementById('password').value = '';
    });
});
});
