@extends('layouts.app')

@section('content')
<div class="min-h-screen text-gray-800" style="background-image: url('{{ asset('images/background/BG1.jpg') }}'); background-size: cover; background-position: center;">
    <div class="flex items-center justify-between p-6 pb-4">
        <a href="{{ route('music.index') }}" class="flex items-center space-x-2 text-gray-200 hover:text-red-700 transition-colors group">
          <svg class="w-6 h-6 transform group-hover:-translate-x-1 transition-transform" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
          </svg>
          <span class="font-medium">Back to Music</span>
        </a>

        <div class="flex items-center space-x-4">
          <button class="p-2 rounded-full hover:bg-gray-200 transition-colors">
            <svg class="w-5 h-5 text-gray-200" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
    </div>

    <!-- Header Section -->
    <div class="px-8 pt-8 pb-6">
        <div class="flex items-center gap-3 mb-2">
            <svg class="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
            <span class="text-sm text-gray-200 uppercase tracking-wide font-semibold">Search Result</span>
        </div>
        <h1 class="text-4xl font-bold mb-2 text-teal-400">{{ $query }}</h1>
        <p class="text-gray-200">{{ $music->count() }} song found</p>
    </div>

    <div class="px-8 py-6">
        <!-- Action Buttons -->
        <div class="flex items-center gap-3">
            <button id="play-all-btn" onclick="playAll()" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-full flex items-center gap-2 transition-all duration-200 hover:scale-105 shadow-lg">
                <svg class="w-4 h-4 play-all-icon" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
                </svg>
                <span class="play-all-text">Play All</span>
            </button>

            <button id="shuffle-btn" onclick="toggleShuffle()" class="bg-white hover:bg-gray-50 text-gray-700 font-medium py-3 px-5 rounded-full flex items-center gap-2 transition-all duration-200 hover:scale-105 shuffle-btn border border-gray-300 shadow-md">
                <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4h6v6H4V4zm10 10h6v6h-6v-6zM4 14h6v6H4v-6zm10-10h6v6h-6V4z"/>
                </svg>
                <span>Shuffle</span>
            </button>
        </div>
    </div>

    @if($music->count())
        <!-- Music List Container -->
        <div class="px-8 pb-32">
            <div class="bg-white/80 backdrop-blur-sm rounded-2xl p-6 shadow-xl border border-gray-200">
                <!-- Table Header -->
                <div class="grid grid-cols-12 gap-4 px-4 py-3 text-sm text-gray-500 uppercase tracking-wide border-b border-gray-200 mb-2 font-semibold">
                    <div class="col-span-1 text-center">#</div>
                    <div class="col-span-6">Title</div>
                    <div class="col-span-3">Album</div>
                    <div class="col-span-2 text-center">Duration</div>
                </div>

                <!-- Music Items -->
                <div class="space-y-1">
                    @foreach($music as $index => $item)
                        <a href="{{ route('music.show', $item) }}" class="music-row group block">
                            <div class="grid grid-cols-12 gap-4 px-4 py-4 rounded-xl hover:bg-blue-50 transition-all duration-200 items-center group-hover:shadow-md">
                                <!-- Index / Play Button -->
                                <div class="col-span-1 text-center">
                                    <div class="relative w-8 h-8 flex items-center justify-center">
                                        <span class="text-gray-500 group-hover:hidden font-medium">{{ $index + 1 }}</span>
                                        <div class="w-8 h-8 bg-blue-600 rounded-full items-center justify-center hidden group-hover:flex text-white hover:bg-blue-700 transition-colors">
                                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                                                <path d="M8 5v14l11-7z"/>
                                            </svg>
                                        </div>
                                    </div>
                                </div>

                                <!-- Title & Thumbnail -->
                                <div class="col-span-6 flex items-center gap-4">
                                    <div class="w-14 h-14 rounded-xl overflow-hidden flex-shrink-0 bg-gray-100 shadow-md">
                                        @if($item->thumbnail)
                                            <img src="{{ asset($item->thumbnail) }}" class="w-full h-full object-cover" alt="{{ $item->title }}">
                                        @else
                                            <div class="w-full h-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
                                                <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 24 24">
                                                    <path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
                                                </svg>
                                            </div>
                                        @endif
                                    </div>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-gray-800 font-semibold truncate group-hover:text-blue-600 transition-colors text-base">
                                            {{ $item->title }}
                                        </p>
                                        <p class="text-sm text-gray-500 truncate">
                                            {{ $item->artist ?? 'Unknown Artist' }}
                                        </p>
                                    </div>
                                </div>

                                <!-- Album -->
                                <div class="col-span-3">
                                    <p class="text-gray-500 text-sm truncate hover:text-blue-600 hover:underline cursor-pointer">
                                        {{ $item->album ?? 'Single' }}
                                    </p>
                                </div>

                                <!-- Duration & Actions -->
                                <div class="col-span-2 flex items-center justify-center gap-3">
                                    <button class="opacity-0 group-hover:opacity-100 transition-all duration-200 hover:text-red-500 p-1 rounded-full hover:bg-red-50">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
                                        </svg>
                                    </button>
                                    <span class="text-gray-500 text-sm min-w-[40px] text-center font-medium">
                                        @if($item->duration)
                                            {{ gmdate('i:s', $item->duration) }}
                                        @else
                                            --:--
                                        @endif
                                    </span>
                                    <button class="opacity-0 group-hover:opacity-100 transition-all duration-200 hover:text-gray-700 p-1 rounded-full hover:bg-gray-100">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h.01M12 12h.01M19 12h.01M6 12a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0z"/>
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </a>
                    @endforeach
                </div>
            </div>
        </div>

    @else
        <!-- Empty State -->
        <div class="flex flex-col items-center justify-center py-24">
            <div class="w-32 h-32 bg-gradient-to-br from-gray-100 to-gray-200 rounded-full flex items-center justify-center mb-6 shadow-lg">
                <svg class="w-16 h-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6-4h6m2 5.291A7.962 7.962 0 0112 15c-2.34 0-4.47-.881-6.08-2.33M12 21l3.5-3.5M12 21l-3.5-3.5"/>
                </svg>
            </div>
            <h3 class="text-3xl font-bold text-gray-700 mb-3">No results found for "{{ $query }}"</h3>
            <p class="text-gray-500 text-center max-w-md mb-8 text-lg">
                Try other keyword or explore our music library.
            </p>
            <button onclick="history.back()" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded-full hover:scale-105 transition-all duration-200 shadow-lg">
                Back to Search
            </button>
        </div>
    @endif

    <!-- Mini Player -->
    <div id="miniPlayer" class="fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur-md border-t border-gray-200 p-4 hidden transform translate-y-full transition-transform duration-300 z-50 shadow-2xl">
        <div class="flex items-center justify-between max-w-6xl mx-auto">
            <!-- Song Info -->
            <div class="flex items-center gap-4 flex-1 min-w-0">
                <div class="w-14 h-14 rounded-xl overflow-hidden flex-shrink-0 bg-gray-100 shadow-md">
                    <img id="miniThumbnail" src="" class="w-full h-full object-cover hidden" alt="">
                    <div id="miniThumbnailPlaceholder" class="w-full h-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
                        <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
                        </svg>
                    </div>
                </div>
                <div class="min-w-0 flex-1">
                    <p id="miniTitle" class="text-gray-800 font-semibold truncate">Select a song</p>
                    <p id="miniArtist" class="text-sm text-gray-500 truncate">Unknown Artist</p>
                </div>
            </div>

            <!-- Control & Close -->
            <div class="flex items-center gap-4 flex-1 justify-end">
                <button onclick="previousSong()" class="text-gray-500 hover:text-gray-700 transition-colors p-2 rounded-full hover:bg-gray-100">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/>
                    </svg>
                </button>

                <button id="miniPlayBtn" onclick="togglePlayPause()" class="bg-blue-600 hover:bg-blue-700 text-white rounded-full p-3 hover:scale-105 transition-all duration-200 shadow-lg">
                    <svg id="miniPlayIcon" class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M8 5v14l11-7z"/>
                    </svg>
                    <svg id="miniPauseIcon" class="w-5 h-5 hidden" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
                    </svg>
                </button>

                <button onclick="nextSong()" class="text-gray-500 hover:text-gray-700 transition-colors p-2 rounded-full hover:bg-gray-100">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/>
                    </svg>
                </button>

                <button id="miniCloseBtn" onclick="closeMiniPlayer()" class="text-gray-500 hover:text-gray-700 transition-colors ml-4 p-2 rounded-full hover:bg-gray-100">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
        </div>
    </div>

    <audio id="audioPlayer" preload="metadata" style="display: none;">
        <source id="audioSource" src="" type="audio/mpeg">
        Your browser does not support the audio element.
    </audio>
</div>

@push('styles')
<style>
    .music-row:hover {
        background: linear-gradient(90deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.05) 100%);
    }

    .music-row:active {
        transform: scale(0.98);
    }

    /* Custom scrollbar */
    ::-webkit-scrollbar {
        width: 12px;
    }

    ::-webkit-scrollbar-track {
        background: transparent;
    }

    ::-webkit-scrollbar-thumb {
        background: rgba(255,255,255,0.2);
        border-radius: 6px;
    }

    ::-webkit-scrollbar-thumb:hover {
        background: rgba(255,255,255,0.3);
    }

    /* Smooth animations */
    * {
        transition: color 0.2s ease, background-color 0.2s ease, border-color 0.2s ease, opacity 0.2s ease;
    }
</style>
@endpush

@push('scripts')
<script>
    // Script yang sudah ada sebelumnya
    document.addEventListener('keydown', function(e) {
        if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
            e.preventDefault();
            const rows = document.querySelectorAll('.music-row');
            const currentFocus = document.querySelector('.music-row:focus');
            let index = Array.from(rows).indexOf(currentFocus);

            if (e.key === 'ArrowDown') {
                index = (index + 1) % rows.length;
            } else {
                index = (index - 1 + rows.length) % rows.length;
            }

            rows[index].focus();
        }
    });

    document.querySelectorAll('.music-row').forEach(row => {
        row.addEventListener('mouseenter', function() {
            this.style.transform = 'translateX(2px)';
        });

        row.addEventListener('mouseleave', function() {
            this.style.transform = 'translateX(0)';
        });
    });
// Global variables for audio player
let currentAudio = null;
let isPlaying = false;
let isPlayingAll = false;
let isShuffleMode = false;
let playlist = [];
let shuffledPlaylist = [];
let currentSongIndex = -1;

// Initialize playlist (you'll need to populate this from your PHP data)
@if($music->count() > 0)
playlist = [
    @foreach($music as $index => $song)
    {
        index: {{ $index }},
        title: "{{ addslashes($song->title) }}",
        artist: "{{ addslashes($song->artist ?? 'Unknown Artist') }}",
        thumbnail: "{{ $song->thumbnail ? asset($song->thumbnail) : '' }}",
        file_path: "{{ $song->file_path ? asset($song->file_path) : '' }}",
        album: "{{ addslashes($song->album ?? 'Single') }}"
    }{{ $loop->last ? '' : ',' }}
    @endforeach
];
@endif

// Initialize audio player
function initializeAudioPlayer() {
    if (!currentAudio) {
        currentAudio = new Audio();

        // Event listeners for audio
        currentAudio.addEventListener('ended', function() {
            if (isPlayingAll || isShuffleMode) {
                nextSong();
            } else {
                stopPlayback();
            }
        });

        currentAudio.addEventListener('play', function() {
            isPlaying = true;
            updatePlayButtons();
            updatePlayingIndicators();
        });

        currentAudio.addEventListener('pause', function() {
            isPlaying = false;
            updatePlayButtons();
            updatePlayingIndicators();
        });

        currentAudio.addEventListener('error', function(e) {
            console.error('Audio error:', e);
            if (isPlayingAll) {
                nextSong();
            } else {
                stopPlayback();
            }
        });

        // Add time update listener for mini player progress
        currentAudio.addEventListener('timeupdate', function() {
            updateProgressBar();
        });

        // Add loaded metadata listener
        currentAudio.addEventListener('loadedmetadata', function() {
            updateDurationDisplay();
        });
    }
}

// Update progress bar in mini player
function updateProgressBar() {
    const progressBar = document.getElementById('miniProgressBar');
    const currentTimeSpan = document.getElementById('miniCurrentTime');
    const totalTimeSpan = document.getElementById('miniTotalTime');

    if (currentAudio && currentAudio.duration && progressBar) {
        const progress = (currentAudio.currentTime / currentAudio.duration) * 100;
        progressBar.style.width = `${progress}%`;

        if (currentTimeSpan) {
            currentTimeSpan.textContent = formatTime(currentAudio.currentTime);
        }
        if (totalTimeSpan) {
            totalTimeSpan.textContent = formatTime(currentAudio.duration);
        }
    }
}

// Update duration display
function updateDurationDisplay() {
    const totalTimeSpan = document.getElementById('miniTotalTime');
    if (currentAudio && currentAudio.duration && totalTimeSpan) {
        totalTimeSpan.textContent = formatTime(currentAudio.duration);
    }
}

// Play specific song by index
function playSong(index) {
    if (index < 0 || index >= playlist.length || !playlist[index]) {
        console.error('Invalid song index:', index);
        return;
    }

    initializeAudioPlayer();

    const song = playlist[index];
    if (!song.file_path) {
        console.error('No audio file path for:', song.title);
        if (isPlayingAll) {
            nextSong();
        }
        return;
    }

    currentAudio.src = song.file_path;
    currentSongIndex = index;

    // Update mini player UI
    updateMiniPlayer(song);

    currentAudio.play().catch(error => {
        console.error('Error playing audio:', error);
        if (isPlayingAll) {
            nextSong();
        }
    });

    console.log(`Playing: ${song.title} by ${song.artist}`);
}

// Play All function
function playAll() {
    if (playlist.length === 0) {
        console.warn('No songs in playlist');
        return;
    }

    initializeAudioPlayer();

    if (isPlayingAll && isPlaying) {
        // Stop play all mode
        currentAudio.pause();
        isPlayingAll = false;
        updatePlayAllButton(false);
    } else {
        // Start play all mode
        isPlayingAll = true;

        // Determine first song index
        let firstSongIndex = 0;
        if (isShuffleMode && shuffledPlaylist.length > 0) {
            firstSongIndex = shuffledPlaylist[0].index;
        }

        playSong(firstSongIndex);
        updatePlayAllButton(true);
    }
}

// Toggle Shuffle function
function toggleShuffle() {
    isShuffleMode = !isShuffleMode;

    if (isShuffleMode) {
        // Create shuffled playlist
        shuffledPlaylist = [...playlist]
            .map((song, index) => ({ ...song, originalIndex: index }))
            .sort(() => Math.random() - 0.5);
        updateShuffleButton(true);
        console.log('Shuffle mode ON');
    } else {
        shuffledPlaylist = [];
        updateShuffleButton(false);
        console.log('Shuffle mode OFF');
    }
}

// Toggle play/pause
function togglePlayPause() {
    initializeAudioPlayer();

    if (!currentAudio.src && playlist.length > 0) {
        // No song loaded, play first song
        playSong(0);
        return;
    }

    if (isPlaying) {
        currentAudio.pause();
    } else {
        currentAudio.play().catch(error => {
            console.error('Error playing audio:', error);
        });
    }
}

// Next song function
function nextSong() {
    if (playlist.length === 0) {
        stopPlayback();
        return;
    }

    let nextIndex = -1;

    if (isShuffleMode && shuffledPlaylist.length > 0) {
        const currentShuffledIndex = shuffledPlaylist.findIndex(song =>
            song.index === currentSongIndex || song.originalIndex === currentSongIndex
        );

        if (currentShuffledIndex >= 0 && currentShuffledIndex < shuffledPlaylist.length - 1) {
            const nextShuffledSong = shuffledPlaylist[currentShuffledIndex + 1];
            nextIndex = nextShuffledSong.index || nextShuffledSong.originalIndex;
        } else if (isPlayingAll) {
            // Loop back to first song in shuffle
            nextIndex = shuffledPlaylist[0].index || shuffledPlaylist[0].originalIndex;
        }
    } else {
        // Normal playlist mode
        if (currentSongIndex < playlist.length - 1) {
            nextIndex = currentSongIndex + 1;
        } else if (isPlayingAll) {
            // Loop back to first song
            nextIndex = 0;
        }
    }

    if (nextIndex >= 0) {
        playSong(nextIndex);
    } else {
        stopPlayback();
    }
}

// Previous song function
function previousSong() {
    if (playlist.length === 0) return;

    let prevIndex = -1;

    if (isShuffleMode && shuffledPlaylist.length > 0) {
        const currentShuffledIndex = shuffledPlaylist.findIndex(song =>
            song.index === currentSongIndex || song.originalIndex === currentSongIndex
        );

        if (currentShuffledIndex > 0) {
            const prevShuffledSong = shuffledPlaylist[currentShuffledIndex - 1];
            prevIndex = prevShuffledSong.index || prevShuffledSong.originalIndex;
        } else {
            // Go to last song in shuffle
            const lastShuffledSong = shuffledPlaylist[shuffledPlaylist.length - 1];
            prevIndex = lastShuffledSong.index || lastShuffledSong.originalIndex;
        }
    } else {
        // Normal playlist mode
        if (currentSongIndex > 0) {
            prevIndex = currentSongIndex - 1;
        } else {
            // Go to last song
            prevIndex = playlist.length - 1;
        }
    }

    if (prevIndex >= 0) {
        playSong(prevIndex);
    }
}

// Stop playback function
function stopPlayback() {
    if (currentAudio) {
        currentAudio.pause();
        currentAudio.currentTime = 0;
    }
    isPlaying = false;
    isPlayingAll = false;
    updatePlayButtons();
    updatePlayAllButton(false);
    updatePlayingIndicators();
    console.log('Playback stopped');
}

// Update Play All button appearance
function updatePlayAllButton(playing) {
    const playAllBtn = document.getElementById('play-all-btn');
    if (!playAllBtn) return;

    const playAllIcon = playAllBtn.querySelector('.play-all-icon');
    const playAllText = playAllBtn.querySelector('.play-all-text');

    if (playing) {
        playAllIcon.innerHTML = '<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />';
        playAllText.textContent = 'Pause All';
        playAllBtn.classList.remove('bg-green-500', 'hover:bg-green-400');
        playAllBtn.classList.add('bg-red-500', 'hover:bg-red-400');
    } else {
        playAllIcon.innerHTML = '<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />';
        playAllText.textContent = 'Play All';
        playAllBtn.classList.remove('bg-red-500', 'hover:bg-red-400');
        playAllBtn.classList.add('bg-green-500', 'hover:bg-green-400');
    }
}

// Update Shuffle button appearance
function updateShuffleButton(active) {
    const shuffleBtn = document.getElementById('shuffle-btn');
    if (!shuffleBtn) return;

    if (active) {
        shuffleBtn.classList.remove('bg-slate-700', 'hover:bg-slate-600');
        shuffleBtn.classList.add('bg-green-500', 'hover:bg-green-400', 'shuffle-active');
    } else {
        shuffleBtn.classList.remove('bg-green-500', 'hover:bg-green-400', 'shuffle-active');
        shuffleBtn.classList.add('bg-slate-700', 'hover:bg-slate-600');
    }
}

// Update playing indicators
function updatePlayingIndicators() {
    const rows = document.querySelectorAll('.music-row');
    rows.forEach((row, index) => {
        const playIcon = row.querySelector('svg');
        if (index === currentSongIndex && isPlaying) {
            row.classList.add('playing');
            // You can add visual indicators here like changing the play icon
        } else {
            row.classList.remove('playing');
        }
    });
}

// Update play buttons (for individual song rows and mini player)
function updatePlayButtons() {
    updateMiniPlayerButton(isPlaying);
    console.log('Play buttons updated, isPlaying:', isPlaying);
}

// Update mini player UI
function updateMiniPlayer(song) {
    const miniPlayer = document.getElementById('miniPlayer');
    const miniTitle = document.getElementById('miniTitle');
    const miniArtist = document.getElementById('miniArtist');
    const miniThumbnail = document.getElementById('miniThumbnail');
    const miniThumbnailPlaceholder = document.getElementById('miniThumbnailPlaceholder');

    if (!miniPlayer) {
        console.warn('Mini player elements not found');
        return;
    }

    // Update song info
    if (miniTitle) miniTitle.textContent = song.title;
    if (miniArtist) miniArtist.textContent = song.artist;

    // Update thumbnail
    if (song.thumbnail && miniThumbnail && miniThumbnailPlaceholder) {
        miniThumbnail.src = song.thumbnail;
        miniThumbnail.classList.remove('hidden');
        miniThumbnailPlaceholder.classList.add('hidden');
    } else if (miniThumbnail && miniThumbnailPlaceholder) {
        miniThumbnail.classList.add('hidden');
        miniThumbnailPlaceholder.classList.remove('hidden');
    }

    // Show mini player
    miniPlayer.classList.remove('hidden');
    miniPlayer.style.transform = 'translateY(0)';
}

// Update mini player play button
function updateMiniPlayerButton(playing) {
    const playIcon = document.getElementById('miniPlayIcon');
    const pauseIcon = document.getElementById('miniPauseIcon');

    if (playIcon && pauseIcon) {
        if (playing) {
            playIcon.classList.add('hidden');
            pauseIcon.classList.remove('hidden');
        } else {
            playIcon.classList.remove('hidden');
            pauseIcon.classList.add('hidden');
        }
    }
}

// Format time helper function
function formatTime(seconds) {
    if (isNaN(seconds)) return '--:--';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs < 10 ? '0' : ''}${secs}`;
}

// Individual song click handler (call this from your music row clicks)
function handleSongClick(index, event) {
    event.preventDefault();
    if (index >= 0 && index < playlist.length) {
        playSong(index);
        // If not in play all mode, start it
        if (!isPlayingAll) {
            isPlayingAll = true;
            updatePlayAllButton(true);
        }
    }
}

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    // Don't interfere with input fields
    if (e.target.tagName.toLowerCase() === 'input' || e.target.tagName.toLowerCase() === 'textarea') {
        return;
    }

    switch(e.code) {
        case 'Space':
            e.preventDefault();
            togglePlayPause();
            break;
        case 'ArrowLeft':
            if (e.ctrlKey || e.metaKey) {
                e.preventDefault();
                previousSong();
            }
            break;
        case 'ArrowRight':
            if (e.ctrlKey || e.metaKey) {
                e.preventDefault();
                nextSong();
            }
            break;
        case 'KeyS':
            if (e.ctrlKey || e.metaKey) {
                e.preventDefault();
                toggleShuffle();
            }
            break;
        case 'KeyP':
            if (e.ctrlKey || e.metaKey) {
                e.preventDefault();
                playAll();
            }
            break;
    }
});

// Navigation keyboard shortcuts (separate from media controls)
document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
        // Only handle if not combined with Ctrl (which is used for media controls)
        if (!e.ctrlKey && !e.metaKey) {
            e.preventDefault();
            const rows = document.querySelectorAll('.music-row');
            const currentFocus = document.querySelector('.music-row:focus');
            let index = Array.from(rows).indexOf(currentFocus);

            if (e.key === 'ArrowDown') {
                index = (index + 1) % rows.length;
            } else {
                index = (index - 1 + rows.length) % rows.length;
            }

            if (rows[index]) {
                rows[index].focus();
            }
        }
    }

    // Enter key to play focused song
    if (e.key === 'Enter') {
        const focusedRow = document.querySelector('.music-row:focus');
        if (focusedRow) {
            const rows = document.querySelectorAll('.music-row');
            const index = Array.from(rows).indexOf(focusedRow);
            if (index >= 0) {
                handleSongClick(index, e);
            }
        }
    }
});

// Mouse hover effects and mini player event listeners
document.addEventListener('DOMContentLoaded', function() {
    const rows = document.querySelectorAll('.music-row');
    rows.forEach((row, index) => {
        row.addEventListener('mouseenter', function() {
            this.style.transform = 'translateX(2px)';
        });

        row.addEventListener('mouseleave', function() {
            this.style.transform = 'translateX(0)';
        });

        // Add click handler for each row
        row.addEventListener('click', function(e) {
            handleSongClick(index, e);
        });
    });

    // Mini player event listeners
    const miniPlayBtn = document.getElementById('miniPlayBtn');
    const miniCloseBtn = document.getElementById('miniCloseBtn');

    if (miniPlayBtn) {
        miniPlayBtn.addEventListener('click', function() {
            togglePlayPause();
        });
    }

    if (miniCloseBtn) {
        miniCloseBtn.addEventListener('click', function() {
            closeMiniPlayer();
        });
    }

    console.log('Music player initialized');
    console.log('Playlist length:', playlist.length);
});

// Close mini player function
function closeMiniPlayer() {
    if (currentAudio) {
        currentAudio.pause();
        currentAudio.currentTime = 0;
    }

    isPlaying = false;
    currentSongIndex = -1;

    const miniPlayer = document.getElementById('miniPlayer');
    if (miniPlayer) {
        miniPlayer.style.transform = 'translateY(100%)';
        setTimeout(() => {
            miniPlayer.classList.add('hidden');
        }, 300);
    }

    updatePlayButtons();
    updatePlayingIndicators();
}
</script>
@endpush

@push('styles')
<style>
    /* Tambahkan CSS untuk animasi shuffle button */
    .shuffle-btn {
        transition: all 0.3s ease;
    }

    .shuffle-active {
        animation: shuffle-pulse 2s infinite;
    }

    @keyframes shuffle-pulse {
        0% {
            box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.4);
        }
        70% {
            box-shadow: 0 0 0 10px rgba(34, 197, 94, 0);
        }
        100% {
            box-shadow: 0 0 0 0 rgba(34, 197, 94, 0);
        }
    }

    /* Hover effects untuk buttons */
    #play-all-btn:hover {
        transform: scale(1.05) !important;
    }

    #shuffle-btn:hover {
        transform: scale(1.05) !important;
    }

    /* Responsive adjustments */
    @media (max-width: 640px) {
        #play-all-btn, #shuffle-btn {
            padding: 8px 16px;
            font-size: 14px;
        }

        .flex.items-center.gap-3 {
            gap: 8px;
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
@endsection
