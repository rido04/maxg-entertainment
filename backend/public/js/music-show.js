document.addEventListener('DOMContentLoaded', function() {
  // Audio Player Elements
  const audio = document.getElementById('audioPlayer');
  const audioSource = document.getElementById('audioSource'); // Tambahkan ini
  const mainPlayBtn = document.getElementById('mainPlayBtn');
  const mainPlayIcon = document.getElementById('mainPlayIcon');
  const mainPauseIcon = document.getElementById('mainPauseIcon');
  const progressBar = document.getElementById('progressBar');
  const progressSlider = document.getElementById('progressSlider');
  const currentTimeSpan = document.getElementById('currentTime');
  const totalTimeSpan = document.getElementById('totalTime');
  const volumeSlider = document.getElementById('volumeSlider');
  const volumeBar = document.getElementById('volumeBar');
  const playingIndicator = document.getElementById('playingIndicator');
  const pulseRing = document.getElementById('pulseRing');

  // Mini Player Elements
  const miniPlayer = document.getElementById('miniPlayer');
  // Mini player click to navigate
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
  const miniTitle = document.getElementById('miniTitle');
  const miniArtist = document.getElementById('miniArtist');
  const miniThumbnail = document.getElementById('miniThumbnail');
  const miniThumbnailPlaceholder = document.getElementById('miniThumbnailPlaceholder');
  const miniPlayBtn = document.getElementById('miniPlayBtn');
  const miniPlayIcon = document.getElementById('miniPlayIcon');
  const miniPauseIcon = document.getElementById('miniPauseIcon');
  const miniCloseBtn = document.getElementById('miniCloseBtn');
  const miniProgressBar = document.getElementById('miniProgressBar');
  const miniCurrentTime = document.getElementById('miniCurrentTime');
  const miniTotalTime = document.getElementById('miniTotalTime');

  // Global state
  let currentlyPlaying = null;
  let isPlaying = false;
  let currentSong = null; // Tambahkan untuk konsistensi dengan Index

  // TAMBAHKAN: Fungsi playAudio seperti di Index
  function playAudio(songId, audioUrl, title, artist, thumbnail) {
    // Pastikan AudioStorage sudah loaded
    if (typeof AudioStorage === 'undefined') {
        console.error('AudioStorage not loaded');
        return;
    }

    if (!audio || !audioSource) {
        console.error('Audio elements not found');
        return;
    }

    // Update audio source jika berbeda dari current
    if (audioSource.src !== audioUrl) {
        audioSource.src = audioUrl;
        audio.load();
    }

    // Save to storage SEBELUM play
    const songData = { songId, audioUrl, title, artist, thumbnail };
    AudioStorage.save.currentSong(songData);

    // Show mini player dengan data yang benar
    showMiniPlayer(songData);

    // Play audio
    audio.play().then(() => {
        AudioStorage.save.playbackState('playing');
        // Update global manager
        if (window.audioManager) {
            window.audioManager.currentSong = songData;
        }
        isPlaying = true;
        currentSong = songId;
        updatePlayPauseUI(true);
    }).catch(error => {
        console.error('Error playing audio:', error);
    });
  }

  // Initialize audio settings
  function initializeAudio() {
    audio.volume = 0.7;
    if (volumeBar) volumeBar.style.width = '70%';
    if (volumeSlider) volumeSlider.value = 70;
  }

  // Format time helper function
  function formatTime(seconds) {
    if (isNaN(seconds)) return '0:00';
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  }

  // Update play/pause UI
  function updatePlayPauseUI(playing) {
    isPlaying = playing;

    // Main player UI
    if (mainPlayIcon && mainPauseIcon) {
      if (playing) {
        mainPlayIcon.classList.add('hidden');
        mainPauseIcon.classList.remove('hidden');
      } else {
        mainPlayIcon.classList.remove('hidden');
        mainPauseIcon.classList.add('hidden');
      }
    }

    // Playing indicator
    if (playingIndicator) {
      if (playing) {
        playingIndicator.classList.remove('hidden');
      } else {
        playingIndicator.classList.add('hidden');
      }
    }

    // Pulse ring
    if (pulseRing) {
      pulseRing.style.display = playing ? 'block' : 'none';
    }

    // Mini player UI
    if (miniPlayIcon && miniPauseIcon) {
      if (playing) {
        miniPlayIcon.classList.add('hidden');
        miniPauseIcon.classList.remove('hidden');
      } else {
        miniPlayIcon.classList.remove('hidden');
        miniPauseIcon.classList.add('hidden');
      }
    }
  }

  // PERBAIKI: Toggle play/pause
  function togglePlayPause() {
    if (audio.paused) {
        audio.play().then(() => {
            AudioStorage.save.playbackState('playing');

            // Auto-show mini player jika belum ada
            if (currentlyPlaying === null) {
                const songData = {
                    songId: 'current', // Atau ID yang sesuai
                    audioUrl: audioSource.src,
                    title: '{{ $music->title }}',
                    artist: '{{ $music->artist ?? "Unknown Artist" }}',
                    @if($music->thumbnail)
                    thumbnail: '{{ $music->thumbnail }}'
                    @else
                    thumbnail: null
                    @endif
                };
                showMiniPlayer(songData);
                AudioStorage.save.currentSong(songData);

                // Update global manager
                if (window.audioManager) {
                    window.audioManager.currentSong = songData;
                }
            }
        }).catch(error => {
            console.error('Error playing audio:', error);
        });
    } else {
        audio.pause();
        AudioStorage.save.playbackState('paused');
    }
  }

  // Update progress bars
  function updateProgress() {
    if (!audio.duration) return;

    const progress = (audio.currentTime / audio.duration) * 100;

    // Main progress bar
    if (progressBar) progressBar.style.width = progress + '%';
    if (progressSlider) progressSlider.value = progress;


    // Update time displays
    const currentTime = formatTime(audio.currentTime);
    if (currentTimeSpan) currentTimeSpan.textContent = currentTime;
    if (miniCurrentTime) miniCurrentTime.textContent = currentTime;
  }

  // Update total time
  function updateTotalTime() {
    const totalTime = formatTime(audio.duration);
    if (totalTimeSpan) totalTimeSpan.textContent = totalTime;
    if (miniTotalTime) miniTotalTime.textContent = totalTime;
  }

  // Update volume icon
  function updateVolumeIcon(volume) {
    const volumeIcon = document.querySelector('.volume-container svg');
    if (!volumeIcon) return;

    let iconPath = '';
    if (volume === 0) {
      iconPath = '<path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.617.816L4.636 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.636l3.747-3.816a1 1 0 011.617.816z" clip-rule="evenodd" /><path d="M16 8l4 4m0-4l-4 4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>';
    } else if (volume < 0.5) {
      iconPath = '<path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.617.816L4.636 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.636l3.747-3.816a1 1 0 011.617.816zM14.657 7.343a1 1 0 010 1.414A2.984 2.984 0 0116 10a2.984 2.984 0 01-1.343 1.243 1 1 0 01-1.414-1.414A.984.984 0 0014 10a.984.984 0 00-.343-.657 1 1 0 010-1.414z" clip-rule="evenodd" />';
    } else {
      iconPath = '<path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.617.816L4.636 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.636l3.747-3.816a1 1 0 011.617.816zM16.657 5.343a1 1 0 010 1.414A4.984 4.984 0 0118 10a4.984 4.984 0 01-1.343 3.243 1 1 0 01-1.414-1.414A2.984 2.984 0 0016 10a2.984 2.984 0 00-.757-1.829 1 1 0 010-1.414z" clip-rule="evenodd" />';
    }
    volumeIcon.innerHTML = iconPath;
  }

  // Reset player state
  function resetPlayer() {
    updatePlayPauseUI(false);
    if (progressBar) progressBar.style.width = '0%';
    if (progressSlider) progressSlider.value = 0;
    if (miniProgressBar) miniProgressBar.style.width = '0%';
    if (currentTimeSpan) currentTimeSpan.textContent = '0:00';
    if (miniCurrentTime) miniCurrentTime.textContent = '0:00';
  }

  // PERBAIKI: Show Mini Player
  function showMiniPlayer(songData) {
    if (!miniPlayer) return;

    // Update song info
    if (miniTitle) miniTitle.textContent = songData.title || 'Unknown Title';
    if (miniArtist) miniArtist.textContent = songData.artist || 'Unknown Artist';

    // Handle thumbnail
    if (songData.thumbnail && miniThumbnail && miniThumbnailPlaceholder) {
        miniThumbnail.src = songData.thumbnail;
        miniThumbnail.classList.remove('hidden');
        miniThumbnailPlaceholder.classList.add('hidden');
    } else if (miniThumbnail && miniThumbnailPlaceholder) {
        miniThumbnail.classList.add('hidden');
        miniThumbnailPlaceholder.classList.remove('hidden');
    }

    // Save to storage
    AudioStorage.save.currentSong(songData);

    // Show with slide-up animation
    miniPlayer.classList.remove('hidden');
    setTimeout(() => {
        miniPlayer.classList.remove('translate-y-full');
    }, 10);

    currentlyPlaying = songData;

    // Update global manager
    if (window.audioManager) {
        window.audioManager.currentSong = songData;
    }
  }

  function hideMiniPlayer() {
    if (!miniPlayer) return;

    miniPlayer.classList.add('translate-y-full');
    setTimeout(() => {
      miniPlayer.classList.add('hidden');
    }, 300);
    currentlyPlaying = null;
  }

  // Event Listeners

  // Main play button
  if (mainPlayBtn) {
    mainPlayBtn.addEventListener('click', togglePlayPause);
  }

  // Mini play button
  if (miniPlayBtn) {
    miniPlayBtn.addEventListener('click', togglePlayPause);
  }

  // Audio events
  if (audio) {
    audio.addEventListener('play', () => updatePlayPauseUI(true));
    audio.addEventListener('pause', () => updatePlayPauseUI(false));
    audio.addEventListener('timeupdate', updateProgress);
    audio.addEventListener('loadedmetadata', updateTotalTime);
    audio.addEventListener('ended', resetPlayer);
    audio.addEventListener('error', (e) => {
      console.error('Audio error:', e);
      resetPlayer();
    });
  }

  // Progress slider
  if (progressSlider) {
    progressSlider.addEventListener('input', function() {
      if (audio && audio.duration) {
        const seekTime = (this.value / 100) * audio.duration;
        audio.currentTime = seekTime;
      }
    });
  }

  // Volume slider
  if (volumeSlider) {
    volumeSlider.addEventListener('input', function() {
      const volume = this.value / 100;
      if (audio) audio.volume = volume;
      if (volumeBar) volumeBar.style.width = this.value + '%';
      updateVolumeIcon(volume);
    });
  }

  // PERBAIKI: Mini player close button
  if (miniCloseBtn) {
    miniCloseBtn.addEventListener('click', function() {
        if (audio) {
            audio.pause();
            audio.currentTime = 0;
        }

        // Clear storage
        AudioStorage.clear();

        // Clear global manager
        if (window.audioManager) {
            window.audioManager.currentSong = null;
        }

        hideMiniPlayer();
        currentSong = null;
        isPlaying = false;
    });
  }

  // Keyboard shortcuts
  document.addEventListener('keydown', function(e) {
    if (e.code === 'Space' && e.target.tagName !== 'INPUT' && e.target.tagName !== 'TEXTAREA') {
      e.preventDefault();
      togglePlayPause();
    }
  });

  // Initialize
  initializeAudio();

  // TAMBAHKAN: Make functions global untuk compatibility
  window.playAudio = playAudio;
  window.showMiniPlayer = showMiniPlayer;
  window.hideMiniPlayer = hideMiniPlayer;
  window.updatePlayButton = updatePlayPauseUI; // Alias untuk konsistensi dengan Index

  // Public API for external use
  window.AudioPlayer = {
    showMiniPlayer: showMiniPlayer,
    hideMiniPlayer: hideMiniPlayer,
    play: () => audio && audio.play(),
    pause: () => audio && audio.pause(),
    isPlaying: () => isPlaying,
    setVolume: (volume) => {
      if (audio) audio.volume = Math.max(0, Math.min(1, volume));
      if (volumeSlider) volumeSlider.value = volume * 100;
      if (volumeBar) volumeBar.style.width = (volume * 100) + '%';
      updateVolumeIcon(volume);
    }
  };
});
