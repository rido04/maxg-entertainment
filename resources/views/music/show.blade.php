@extends('layouts.app')

@section('content')
<div class="min-h-screen text-gray-900" style="background-image: url('{{ asset('images/background/Background_Color.png') }}'); background-size: cover; background-position: center;">
  <!-- Top Navigation -->
  <div class="flex items-center justify-between p-4 sm:p-6 pb-2 sm:pb-4">
    <a href="{{ route('music.index') }}" class="flex items-center space-x-2 text-gray-200 hover:text-red-700 transition-colors group">
      <svg class="w-5 h-5 sm:w-6 sm:h-6 transform group-hover:-translate-x-1 transition-transform" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
      </svg>
      <span class="font-medium text-sm sm:text-base">Back to Music</span>
    </a>
  </div>

  <!-- Main Content -->
  <div class="px-4 sm:px-6 pb-32">
    <!-- Hero Section with Modern Gradient Background -->
    <div class="bg-gradient-to-r from-blue-800 via-greeen-800 to-green-600 rounded-xl sm:rounded-2xl p-4 sm:p-6 lg:p-8 mb-6 sm:mb-8 shadow-2xl">
      <div class="flex flex-col items-center text-center space-y-6 sm:space-y-8 lg:flex-row lg:items-end lg:text-left lg:space-y-0 lg:space-x-8">
        <!-- Album Art -->
        <div class="flex-shrink-0">
          <div class="w-48 h-48 sm:w-56 sm:h-56 lg:w-64 lg:h-64 rounded-lg sm:rounded-xl shadow-2xl overflow-hidden group relative ring-2 sm:ring-4 ring-white/20">
            @if($music->thumbnail)
              <img src="{{ $music->thumbnail }}" alt="{{ $music->title }}" class="w-full h-full object-cover">
            @else
              <div class="w-full h-full bg-gradient-to-br from-green-500 to-yellow-600 flex items-center justify-center">
                <svg class="w-16 h-16 sm:w-20 sm:h-20 lg:w-24 lg:h-24 text-white/80" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                </svg>
              </div>
            @endif
            <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-all duration-300 flex items-center justify-center">
              <div class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                <div class="w-12 h-12 sm:w-14 sm:h-14 lg:w-16 lg:h-16 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center hover:bg-white hover:scale-110 transition-all duration-200 shadow-lg">
                  <svg class="w-6 h-6 sm:w-7 sm:h-7 lg:w-8 lg:h-8 text-green-600 ml-1" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
                  </svg>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Song Info -->
        <div class="flex-1 text-white">
          <div class="flex items-center justify-center lg:justify-start mb-2">
            <span class="text-xs sm:text-sm font-medium uppercase tracking-wide text-white/90">Song</span>
            <div id="playingIndicator" class="ml-3 playing-animation hidden">
              <div class="playing-bar bg-white"></div>
              <div class="playing-bar bg-white"></div>
              <div class="playing-bar bg-white"></div>
            </div>
          </div>
          <h1 class="text-2xl sm:text-4xl md:text-5xl lg:text-6xl xl:text-7xl font-black mb-4 sm:mb-6 leading-tight text-white drop-shadow-lg break-words">
            {{ $music->title }}
          </h1>
          <div class="flex flex-wrap items-center justify-center lg:justify-start gap-2 text-xs sm:text-sm mb-4 text-white/90">
            @if($music->artist_avatar)
              <img src="{{ $music->artist_avatar }}" alt="{{ $music->artist }}" class="w-5 h-5 sm:w-6 sm:h-6 rounded-full ring-2 ring-white/30">
            @endif
            <span class="font-medium hover:text-white cursor-pointer transition-colors">{{ $music->artist ?? 'Unknown Artist' }}</span>
            @if($music->album)
              <span class="text-white/70 hidden sm:inline">•</span>
              <span class="text-white/70 hover:text-white cursor-pointer transition-colors">{{ $music->album }}</span>
            @endif
            @if($music->release_date)
              <span class="text-white/70 hidden sm:inline">•</span>
              <span class="text-white/70">{{ $music->release_date }}</span>
            @endif
            @if($music->duration)
              <span class="text-white/70 hidden sm:inline">•</span>
              <span class="text-white/70">{{ gmdate("i:s", $music->duration) }}</span>
            @endif
          </div>
          <div class="flex items-center justify-center lg:justify-start gap-4">
            @if($music->rating)
              <div class="flex items-center bg-white/20 backdrop-blur-sm rounded-full px-3 py-1">
                <svg class="w-3 h-3 sm:w-4 sm:h-4 text-yellow-400 mr-1" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
                <span class="font-medium text-white text-sm">{{ number_format($music->rating, 1) }}</span>
              </div>
            @endif
          </div>
        </div>
      </div>
    </div>

    <!-- Control Section -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 sm:gap-6 mb-6 sm:mb-8">
      <div class="flex items-center space-x-6">
        <!-- Play Button -->
        <button id="mainPlayBtn" class="relative w-12 h-12 sm:w-14 sm:h-14 bg-gradient-to-r from-green-500 to-yellow-600 hover:from-green-600 hover:to-yellow-700 rounded-full flex items-center justify-center shadow-lg transform hover:scale-105 transition-all duration-200">
          <svg id="mainPlayIcon" class="w-5 h-5 sm:w-6 sm:h-6 text-white ml-1" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
          </svg>
          <svg id="mainPauseIcon" class="w-5 h-5 sm:w-6 sm:h-6 text-white hidden" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
          </svg>
          <div class="absolute inset-0 rounded-full border-2 border-green-400 opacity-50 pulse-ring" id="pulseRing" style="display: none;"></div>
        </button>
      </div>

      <!-- Volume Control -->
      <div class="flex items-center space-x-3 sm:space-x-4 volume-container">
        <svg class="w-5 h-5 sm:w-6 sm:h-6 text-gray-200" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.617.816L4.636 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.636l3.747-3.816a1 1 0 011.617.816zM16.657 5.343a1 1 0 010 1.414A4.984 4.984 0 0118 10a4.984 4.984 0 01-1.343 3.243 1 1 0 01-1.414-1.414A2.984 2.984 0 0016 10a2.984 2.984 0 00-.757-1.829 1 1 0 010-1.414z" clip-rule="evenodd" />
        </svg>
        <div class="relative w-24 sm:w-32">
            <input type="range" id="volumeSlider" min="0" max="100" value="70" class="volume-slider w-full h-2 sm:h-3 bg-gray-300 rounded-full appearance-none cursor-pointer">
            <div id="volumeBar" class="absolute top-1/2 left-0 h-2 sm:h-3 bg-gradient-to-r from-green-500 to-yellow-600 rounded-full pointer-events-none transform -translate-y-1/2" style="width: 70%"></div>
        </div>
      </div>
    </div>

    <!-- Progress Section -->
    <div class="mb-6 sm:mb-8">
      <div class="flex items-center justify-between text-xs sm:text-sm text-gray-200 mb-2">
        <span id="currentTime">0:00</span>
        <span id="totalTime">{{ $music->duration ? gmdate("i:s", $music->duration) : '0:00' }}</span>
      </div>
      <div class="relative group">
        <div class="w-full h-1.5 sm:h-2 bg-gray-300 rounded-full overflow-hidden">
          <div id="progressBar" class="h-full bg-gradient-to-r from-green-500 to-yellow-600 rounded-full transition-all duration-100" style="width: 0%"></div>
        </div>
        <input type="range" id="progressSlider" min="0" max="100" value="0" class="absolute inset-0 w-full h-1.5 sm:h-2 opacity-0 cursor-pointer">
      </div>
    </div>

    <!-- Description Section -->
    @if($music->description)
    <div class="bg-white/60 backdrop-blur-sm rounded-lg sm:rounded-xl p-4 sm:p-6 mb-6 sm:mb-8 shadow-lg border border-gray-200">
      <h3 class="text-base sm:text-lg font-semibold mb-3 sm:mb-4 text-gray-900">About This Song</h3>
      <p class="text-sm sm:text-base text-gray-700 leading-relaxed">{{ $music->description }}</p>
    </div>
    @endif

    <!-- Song Details -->
    <div class="bg-white/60 backdrop-blur-sm rounded-lg sm:rounded-xl p-4 sm:p-6 mb-6 sm:mb-8 shadow-lg border border-gray-200">
      <h3 class="text-base sm:text-lg font-semibold mb-3 sm:mb-4 text-gray-900">Song Details</h3>
      <div class="grid grid-cols-1 gap-4 sm:gap-6">
        <div class="space-y-3 sm:space-y-4">
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center border-b border-gray-200 pb-2 gap-1 sm:gap-0">
            <span class="text-gray-600 text-sm sm:text-base">Artist</span>
            <span class="text-gray-900 font-medium text-sm sm:text-base">{{ $music->artist ?? 'Unknown Artist' }}</span>
          </div>
          @if($music->album)
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center border-b border-gray-200 pb-2 gap-1 sm:gap-0">
            <span class="text-gray-600 text-sm sm:text-base">Album</span>
            <span class="text-gray-900 font-medium text-sm sm:text-base">{{ $music->album }}</span>
          </div>
          @endif
          @if($music->category)
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center border-b border-gray-200 pb-2 gap-1 sm:gap-0">
            <span class="text-gray-600 text-sm sm:text-base">Genre</span>
            <span class="text-gray-900 font-medium text-sm sm:text-base">{{ $music->category }}</span>
          </div>
          @endif
          @if($music->release_date)
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center border-b border-gray-200 pb-2 gap-1 sm:gap-0">
            <span class="text-gray-600 text-sm sm:text-base">Release Date</span>
            <span class="text-gray-900 font-medium text-sm sm:text-base">{{ $music->release_date }}</span>
          </div>
          @endif
          @if($music->language)
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center border-b border-gray-200 pb-2 gap-1 sm:gap-0">
            <span class="text-gray-600 text-sm sm:text-base">Language</span>
            <span class="text-gray-900 font-medium text-sm sm:text-base">{{ $music->language }}</span>
          </div>
          @endif
          @if($music->duration)
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center border-b border-gray-200 pb-2 gap-1 sm:gap-0">
            <span class="text-gray-600 text-sm sm:text-base">Duration</span>
            <span class="text-gray-900 font-medium text-sm sm:text-base">{{ gmdate("i:s", $music->duration) }}</span>
          </div>
          @endif
        </div>
      </div>
    </div>
  </div>

  <!-- Hidden Audio Element -->
  <audio id="audioPlayer" preload="metadata">
    <source id="audioSource" src="{{ asset($music->file_path) }}" type="audio/mpeg">
    Your browser does not support the audio element.
  </audio>

  <!-- Mini Player Widget - Responsive -->
  <div id="miniPlayer" class="fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur-sm border-t border-gray-200 p-3 sm:p-4 transform translate-y-full transition-transform duration-300 z-50 hidden shadow-2xl">
    <div class="max-w-7xl mx-auto">
      <!-- Mobile Layout -->
      <div class="flex flex-col space-y-3 sm:hidden">
        <!-- Song Info Row -->
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-3 flex-1 min-w-0">
            <div class="w-12 h-12 rounded-lg bg-gradient-to-br from-green-500 to-yellow-600 flex-shrink-0 shadow-lg">
              <img id="miniThumbnailMobile" src="" alt="" class="w-full h-full object-cover rounded-lg hidden">
              <div id="miniThumbnailPlaceholderMobile" class="w-full h-full flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                </svg>
              </div>
            </div>
            <div class="min-w-0 flex-1">
              <h4 id="miniTitleMobile" class="text-gray-900 font-medium truncate text-sm">Song Title</h4>
              <p id="miniArtistMobile" class="text-gray-600 text-xs truncate">Artist Name</p>
            </div>
          </div>
          <div class="flex items-center space-x-2">
            <button class="text-gray-500 hover:text-red-500 p-1 transition-colors">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" />
              </svg>
            </button>
            <button id="miniCloseBtn" class="text-gray-500 hover:text-gray-700 p-1 transition-colors">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
        </div>
        <!-- Controls Row -->
        <div class="flex items-center justify-center">
          <button id="miniPlayBtn" class="w-10 h-10 bg-gradient-to-r from-green-500 to-yellow-600 text-white rounded-full flex items-center justify-center hover:from-green-600 hover:to-yellow-700 hover:scale-105 transition-all duration-200 shadow-lg">
            <svg id="miniPlayIcon" class="w-4 h-4 ml-0.5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
            </svg>
            <svg id="miniPauseIcon" class="w-4 h-4 hidden" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>

      <!-- Desktop Layout -->
      <div class="hidden sm:flex items-center justify-between">
        <!-- Song Info -->
        <div class="flex items-center space-x-4 flex-1 min-w-0">
          <div class="w-14 h-14 rounded-lg bg-gradient-to-br from-green-500 to-yellow-600 flex-shrink-0 shadow-lg">
            <img id="miniThumbnail" src="" alt="" class="w-full h-full object-cover rounded-lg hidden">
            <div id="miniThumbnailPlaceholder" class="w-full h-full flex items-center justify-center">
              <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
              </svg>
            </div>
          </div>
          <div class="min-w-0 flex-1">
            <h4 id="miniTitle" class="text-gray-900 font-medium truncate">Song Title</h4>
            <p id="miniArtist" class="text-gray-600 text-sm truncate">Artist Name</p>
          </div>
          <button class="text-gray-500 hover:text-red-500 p-2 transition-colors">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" />
            </svg>
          </button>
        </div>

        <!-- Controls -->
        <div class="flex items-center space-x-4 flex-1 justify-end">
          <button id="miniPlayBtnDesktop" class="w-10 h-10 bg-gradient-to-r from-green-500 to-yellow-600 text-white rounded-full flex items-center justify-center hover:from-indigo-600 hover:to-yellow-700 hover:scale-105 transition-all duration-200 shadow-lg">
            <svg id="miniPlayIconDesktop" class="w-4 h-4 ml-0.5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
            </svg>
            <svg id="miniPauseIconDesktop" class="w-4 h-4 hidden" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
          </button>
          <button id="miniCloseBtnDesktop" class="text-gray-500 hover:text-gray-700 p-1 transition-colors">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  </div>
</div>

@push('styles')
<link rel="stylesheet" href="{{ asset('css/music-show.css') }}">
@endpush

@push('scripts')
<script>
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
</script>
@endpush

@endsection
