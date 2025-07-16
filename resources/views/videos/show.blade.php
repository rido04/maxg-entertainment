@extends('layouts.app')

@section('content')
<!-- Background with gradient effect -->
<div class="min-h-screen flex text-gray-700 overflow-hidden relative" style="background-image: url('{{ asset('images/background/Background_Color.png') }}'); background-size: cover; background-position: center;">
  <!-- Enhanced overlay pattern -->
  <div class="absolute inset-0 bg-gradient-to-br from-blue-900/20 via-slate-800/10 to-slate-900/30"></div>

  <!-- Animated background elements - Optimized for all devices -->
  <div class="absolute inset-0 overflow-hidden">
    <div class="absolute -top-20 -right-20 sm:-top-32 sm:-right-32 lg:-top-40 lg:-right-40 w-32 h-32 sm:w-60 sm:h-60 lg:w-80 lg:h-80 bg-blue-500/10 rounded-full blur-3xl animate-pulse"></div>
    <div class="absolute -bottom-20 -left-20 sm:-bottom-32 sm:-left-32 lg:-bottom-40 lg:-left-40 w-32 h-32 sm:w-60 sm:h-60 lg:w-80 lg:h-80 bg-slate-500/10 rounded-full blur-3xl animate-pulse delay-1000"></div>
    <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-40 h-40 sm:w-72 sm:h-72 bg-purple-500/5 rounded-full blur-3xl animate-pulse delay-500"></div>
  </div>

  <!-- Logo Space - Enhanced responsive positioning -->
  <div class="absolute top-3 right-3 sm:top-4 sm:right-4 md:top-6 md:right-6 z-30">
    <div class="w-32 h-8 sm:w-48 sm:h-10 md:w-60 md:h-12 lg:w-80 lg:h-16 bg-transparent">
        <img src="{{ asset('images/logo/Logo-MaxG-White.gif') }}" alt="MaxG Logo" class="drop-shadow-lg w-full h-full object-contain">
    </div>
  </div>

  <!-- Main Content - Enhanced responsive layout -->
  <div class="relative z-10 flex-1 flex flex-row lg:flex-row pt-12 sm:pt-16 md:pt-20 pb-6 sm:pb-8 md:pb-12 lg:pb-20">

    <!-- Poster Section - Improved responsive behavior -->
    <div class="w-full lg:w-2/5 xl:w-1/3 p-3 sm:p-4 md:p-6 lg:p-8 order-2 lg:order-1">
        @if($video->thumbnail)
        <div class="relative group max-w-xs sm:max-w-sm md:max-w-md lg:max-w-none mx-auto">
            <img src="{{ $video->thumbnail }}"
                alt="{{ $video->title }}"
                class="w-full h-auto rounded-xl sm:rounded-2xl shadow-2xl fade-in border border-gray-700/50 group-hover:shadow-blue-500/20 transition-all duration-500 transform group-hover:scale-[1.02]">
            <!-- Enhanced glow effect -->
            <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-t from-blue-600/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            <!-- Subtle border glow -->
            <div class="absolute inset-0 rounded-xl sm:rounded-2xl border-2 border-blue-500/0 group-hover:border-blue-500/30 transition-all duration-500"></div>
        </div>
        @else
        <div class="w-full h-48 sm:h-64 md:h-80 lg:h-96 bg-gradient-to-br from-gray-800 to-slate-800 flex items-center justify-center rounded-xl sm:rounded-2xl shadow-2xl fade-in border border-gray-700/50 max-w-xs sm:max-w-sm md:max-w-md lg:max-w-none mx-auto">
            <div class="text-center">
                <svg class="w-8 h-8 sm:w-12 sm:h-12 md:w-16 md:h-16 text-blue-400 mx-auto mb-2" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M8 5v14l11-7z"/>
                </svg>
                <p class="text-gray-400 text-xs sm:text-sm">No Thumbnail</p>
            </div>
        </div>
        @endif
    </div>

    <!-- Content Section - Enhanced responsive design -->
    <div class="w-full lg:w-3/5 xl:w-2/3 p-3 sm:p-4 md:p-6 lg:p-8 flex flex-col justify-center slide-up order-1 lg:order-2 mt-">

        <!-- Title - Improved typography scaling -->
        <h1 class="text-xl sm:text-2xl md:text-3xl lg:text-4xl xl:text-5xl font-bold mb-3 sm:mb-4 md:mb-5 lg:mb-6 bg-gradient-to-r from-white via-gray-100 to-gray-300 bg-clip-text text-transparent leading-tight text-center lg:text-left">
          {{ $video->title }}
        </h1>

        <!-- Rating and Info Tags - Enhanced responsive layout -->
        <div class="flex flex-row justify-center lg:justify-between gap-2 sm:gap-3 md:gap-4 mb-4 sm:mb-5 md:mb-6 flex-wrap py-4 px-6">
            <div class="flex items-center gap-1 px-3 sm:px-4 md:px-5 py-2 sm:py-2.5 md:py-3 bg-gradient-to-b from-amber-500/80 to-amber-700/80 backdrop-blur-sm text-white text-xs sm:text-sm font-bold rounded-xl transition-all duration-300 hover:scale-105 hover:bg-white/30">
              <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
              </svg>
              {{ $video->rating ?? 'N/A' }}/10
            </div>

            <div class="flex items-center gap-1 px-3 sm:px-4 md:px-5 py-2 sm:py-2.5 md:py-3 bg-gradient-to-b from-blue-500/80 to-blue-700/80 backdrop-blur-sm text-white text-xs sm:text-sm font-bold rounded-xl transition-all duration-300 hover:scale-105 hover:bg-white/30">
              <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd"/>
              </svg>
              {{ $video->release_date ? \Carbon\Carbon::parse($video->release_date)->format('Y') : 'N/A' }}
            </div>

            <div class="flex items-center gap-1 px-3 sm:px-4 md:px-5 py-2 sm:py-2.5 md:py-3 bg-gradient-to-b from-green-500/80 to-green-700/80 backdrop-blur-sm text-white text-xs sm:text-sm font-bold rounded-xl transition-all duration-300 hover:scale-105 hover:bg-white/30">
              <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd"/>
              </svg>
              {{ $video->duration ?? 'N/A' }} Min
            </div>

            <div class="flex items-center gap-1 px-3 sm:px-4 md:px-5 py-2 sm:py-2.5 md:py-3 bg-gradient-to-b from-red-500/80 to-red-700/80 backdrop-blur-sm text-white text-xs sm:text-sm font-bold rounded-xl transition-all duration-300 hover:scale-105 hover:bg-white/30">
              <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"/>
              </svg>
              {{ ucfirst($video->category ?? 'N/A') }}
            </div>
          </div>

        <!-- Description Box - Enhanced design -->
        <div class="bg-white/95 backdrop-blur-md border border-gray-300/50 rounded-xl md:rounded-2xl p-3 sm:p-4 md:p-5 lg:p-6 mb-4 sm:mb-5 md:mb-6 lg:mb-8 shadow-xl hover:shadow-2xl transition-all duration-300">
          <div class="flex items-start gap-3 mb-2">
            <div class="w-1 h-6 bg-gradient-to-b from-blue-500 to-blue-700 rounded-full flex-shrink-0 mt-1"></div>
            <h3 class="text-sm sm:text-base font-semibold text-gray-800">Sinopsis</h3>
          </div>
          <p class="text-gray-700 text-sm sm:text-base lg:text-lg leading-relaxed text-justify pl-4">
            {{ $video->description ?? 'No description available for this movie. Please contact support for more information.' }}
          </p>
        </div>

        <!-- Action Buttons - Enhanced responsive design -->
        <div class="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-2 sm:gap-3 md:gap-4">
            @if($video->file_path)
            <button onclick="playFullscreen('{{ asset($video->file_path) }}')"
               class="w-full sm:w-auto flex items-center justify-center gap-2 sm:gap-2.5 md:gap-3 bg-gradient-to-r from-blue-600 via-blue-700 to-blue-800 px-4 sm:px-6 md:px-8 py-2.5 sm:py-3 md:py-4 rounded-xl md:rounded-2xl hover:from-blue-700 hover:via-blue-800 hover:to-blue-900 transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-blue-500/30 border border-blue-500/30 group">
              <svg class="w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 text-white transition-transform group-hover:scale-110" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8 5v14l11-7z"/>
              </svg>
              <span class="font-semibold text-sm sm:text-base md:text-lg text-white">Mainkan</span>
            </button>
            @else
            <button disabled class="w-full sm:w-auto flex items-center justify-center gap-2 sm:gap-2.5 md:gap-3 bg-gray-700/70 px-4 sm:px-6 md:px-8 py-2.5 sm:py-3 md:py-4 rounded-xl md:rounded-2xl cursor-not-allowed opacity-50 border border-gray-600/30">
              <svg class="w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8 5v14l11-7z"/>
              </svg>
              <span class="font-semibold text-sm sm:text-base md:text-lg text-gray-300">Video Not Available</span>
            </button>
            @endif

            <button onclick="history.back()"
                    class="w-full sm:w-auto flex items-center justify-center gap-2 sm:gap-2.5 md:gap-3 px-4 sm:px-6 md:px-8 py-2.5 sm:py-3 md:py-4 bg-gradient-to-r from-red-600 to-red-700 backdrop-blur-sm border border-red-500/30 rounded-xl md:rounded-2xl hover:from-red-700 hover:to-red-800 transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-red-500/20 group">
                <svg class="w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 text-white transition-transform group-hover:-translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
                <span class="font-semibold text-sm sm:text-base md:text-lg text-white">Kembali</span>
            </button>
        </div>
    </div>
  </div>

  <!-- Enhanced Time Display -->
  <div class="fixed bottom-3 right-3 sm:bottom-4 sm:right-4 md:bottom-6 md:right-6 lg:bottom-8 lg:right-8 z-20">
    <div class="bg-gray-900/90 backdrop-blur-md border border-gray-700/50 rounded-lg sm:rounded-xl md:rounded-2xl px-2 sm:px-3 md:px-5 lg:px-6 py-1.5 sm:py-2 md:py-3 lg:py-4 shadow-2xl">
      <div class="text-right text-white">
        <div class="text-xs text-blue-400 font-medium mb-0.5 sm:mb-1 uppercase tracking-wide hidden sm:block">Current Time</div>
        <div class="text-sm sm:text-lg md:text-xl lg:text-2xl font-bold mb-0.5 sm:mb-1 text-white tabular-nums" id="currentTime">--:--</div>
        <div class="text-xs sm:text-sm text-gray-400 hidden sm:block" id="currentDate">--- --</div>
      </div>
    </div>
  </div>
</div>

<!-- Enhanced Fullscreen Video Modal -->
<div id="fullscreenModal" class="fixed inset-0 bg-black z-50 hidden flex items-center justify-center">
  <video id="fullscreenVideo" class="w-full h-full object-contain" controls autoplay>
    <source src="" type="video/mp4">
    Your browser does not support the video tag.
  </video>

  <!-- Enhanced Close Button -->
  <button onclick="closeFullscreen()"
          class="absolute top-3 right-3 sm:top-4 sm:right-4 md:top-6 md:right-6 bg-gray-900/90 backdrop-blur-md border border-gray-700/50 text-white p-2 sm:p-3 md:p-4 rounded-full hover:bg-gray-800/95 transition-all duration-300 transform hover:scale-110 shadow-xl group">
    <svg class="w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 transition-transform group-hover:rotate-90" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
    </svg>
  </button>

  <!-- Enhanced Loading Spinner -->
  <div id="videoLoader" class="absolute inset-0 flex items-center justify-center bg-black/95 backdrop-blur-sm">
    <div class="flex flex-col items-center px-4">
      <div class="relative mb-4">
        <div class="animate-spin rounded-full h-12 w-12 sm:h-16 sm:w-16 md:h-20 md:w-20 border-t-4 border-b-4 border-blue-500"></div>
        <div class="animate-spin rounded-full h-12 w-12 sm:h-16 sm:w-16 md:h-20 md:w-20 border-l-4 border-r-4 border-gray-600 absolute top-0 left-0" style="animation-delay: 0.15s;"></div>
        <div class="animate-pulse absolute inset-0 rounded-full bg-blue-500/20"></div>
      </div>
      <p class="text-white text-sm sm:text-base md:text-lg font-medium text-center mb-2">Loading video...</p>
      <p class="text-gray-400 text-xs sm:text-sm text-center">Please wait a moment</p>
    </div>
  </div>
</div>

@push('styles')
<link rel="stylesheet" href="{{ asset('css/video-show.css') }}">
<style>
  /* Enhanced responsive animations */
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }

  @keyframes slideUp {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .fade-in {
    animation: fadeIn 0.6s ease-out;
  }

  .slide-up {
    animation: slideUp 0.8s ease-out;
  }

  /* Mobile optimizations */
  @media (max-width: 640px) {
    .fade-in, .slide-up {
      animation-duration: 0.4s;
    }

    /* Optimize for small screens */
    .min-h-screen {
      padding-bottom: 60px;
    }
  }

  /* Tablet optimizations */
  @media (min-width: 641px) and (max-width: 1024px) {
    .tablet-landscape .flex-col {
      flex-direction: row;
    }
  }

  /* Landscape orientation adjustments */
  @media (max-height: 500px) and (orientation: landscape) {
    .pt-12 { padding-top: 0.5rem; }
    .pb-6 { padding-bottom: 0.5rem; }
    .fixed.bottom-3 { bottom: 0.5rem; }

    /* Hide time display on very small landscape screens */
    .fixed.bottom-3.right-3 {
      display: none;
    }
  }

  /* High DPI display optimizations */
  @media (-webkit-min-device-pixel-ratio: 2) {
    .shadow-2xl {
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
    }
  }

  /* Smooth scrolling for better UX */
  html {
    scroll-behavior: smooth;
  }

  /* Enhanced hover effects for desktop */
  @media (hover: hover) {
    .group:hover .group-hover\:scale-\[1\.02\] {
      transform: scale(1.02);
    }
  }

  /* Touch device optimizations */
  @media (hover: none) {
    .hover\:scale-105:hover {
      transform: none;
    }

    .touch-active {
      transform: scale(0.98);
    }
  }
</style>
@endpush

@push('scripts')
<script src="{{ asset('js/video-show.js') }}"></script>
<script>
  // Enhanced responsive functionality
  function initializeResponsiveFeatures() {
    // Device detection
    const isMobile = window.innerWidth < 640;
    const isTablet = window.innerWidth >= 641 && window.innerWidth < 1024;
    const isDesktop = window.innerWidth >= 1024;

    // Adjust layout based on device
    adjustLayoutForDevice(isMobile, isTablet, isDesktop);

    // Handle orientation changes
    handleOrientationChange();

    // Initialize touch interactions for mobile/tablet
    if (isMobile || isTablet) {
      initializeTouchInteractions();
    }
  }

  function adjustLayoutForDevice(isMobile, isTablet, isDesktop) {
    const body = document.body;

    // Remove all device classes
    body.classList.remove('mobile-device', 'tablet-device', 'desktop-device');

    // Add appropriate class
    if (isMobile) {
      body.classList.add('mobile-device');
    } else if (isTablet) {
      body.classList.add('tablet-device');
    } else {
      body.classList.add('desktop-device');
    }
  }

  function handleOrientationChange() {
    const isLandscape = window.innerHeight < window.innerWidth;
    const isMobile = window.innerWidth < 640;

    if (isMobile && isLandscape) {
      document.body.classList.add('mobile-landscape');
    } else {
      document.body.classList.remove('mobile-landscape');
    }
  }

  function initializeTouchInteractions() {
    // Enhanced touch handling for buttons
    const buttons = document.querySelectorAll('button, a');
    buttons.forEach(button => {
      button.addEventListener('touchstart', function() {
        this.classList.add('touch-active');
      });

      button.addEventListener('touchend', function() {
        setTimeout(() => {
          this.classList.remove('touch-active');
        }, 150);
      });
    });

    // Optimize poster image interaction for touch devices
    const posterImage = document.querySelector('.group img');
    if (posterImage) {
      posterImage.addEventListener('touchstart', function() {
        this.parentElement.classList.add('touch-active');
      });

      posterImage.addEventListener('touchend', function() {
        setTimeout(() => {
          this.parentElement.classList.remove('touch-active');
        }, 300);
      });
    }
  }

  // Enhanced video player functions
  window.playFullscreen = function(videoSrc) {
    const modal = document.getElementById('fullscreenModal');
    const video = document.getElementById('fullscreenVideo');
    const loader = document.getElementById('videoLoader');

    modal.classList.remove('hidden');
    loader.style.display = 'flex';

    // Optimize video for device
    video.setAttribute('preload', 'metadata');
    video.setAttribute('playsinline', 'true');

    if (window.innerWidth < 1024) {
      video.setAttribute('controls', 'true');
    }

    video.src = videoSrc;

    video.addEventListener('loadeddata', function() {
      loader.style.display = 'none';
    });

    video.addEventListener('error', function() {
      loader.innerHTML = `
        <div class="text-center">
          <p class="text-white text-lg mb-2">Error loading video</p>
          <p class="text-gray-400 text-sm">Please try again later</p>
          <button onclick="closeFullscreen()" class="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
            Close
          </button>
        </div>
      `;
    });
  };

  window.closeFullscreen = function() {
    const modal = document.getElementById('fullscreenModal');
    const video = document.getElementById('fullscreenVideo');
    const loader = document.getElementById('videoLoader');

    modal.classList.add('hidden');
    video.pause();
    video.src = '';
    loader.style.display = 'flex';
    loader.innerHTML = `
      <div class="flex flex-col items-center px-4">
        <div class="relative mb-4">
          <div class="animate-spin rounded-full h-12 w-12 sm:h-16 sm:w-16 md:h-20 md:w-20 border-t-4 border-b-4 border-blue-500"></div>
          <div class="animate-spin rounded-full h-12 w-12 sm:h-16 sm:w-16 md:h-20 md:w-20 border-l-4 border-r-4 border-gray-600 absolute top-0 left-0" style="animation-delay: 0.15s;"></div>
          <div class="animate-pulse absolute inset-0 rounded-full bg-blue-500/20"></div>
        </div>
        <p class="text-white text-sm sm:text-base md:text-lg font-medium text-center mb-2">Loading video...</p>
        <p class="text-gray-400 text-xs sm:text-sm text-center">Please wait a moment</p>
      </div>
    `;
  };

  // Event listeners
  window.addEventListener('orientationchange', function() {
    setTimeout(() => {
      initializeResponsiveFeatures();
    }, 100);
  });

  window.addEventListener('resize', function() {
    initializeResponsiveFeatures();
  });

  // Initialize on page load
  document.addEventListener('DOMContentLoaded', function() {
    initializeResponsiveFeatures();
  });

  // Enhanced time display with better formatting
  function updateTime() {
    const now = new Date();
    const timeElement = document.getElementById('currentTime');
    const dateElement = document.getElementById('currentDate');

    if (timeElement) {
      timeElement.textContent = now.toLocaleTimeString('en-US', {
        hour12: false,
        hour: '2-digit',
        minute: '2-digit'
      });
    }

    if (dateElement) {
      dateElement.textContent = now.toLocaleDateString('en-US', {
        weekday: 'short',
        day: '2-digit'
      });
    }
  }

  // Update time every second
  setInterval(updateTime, 1000);
  updateTime(); // Initial call
</script>
@endpush

@endsection
