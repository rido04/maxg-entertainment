@extends('layouts.app', ['title' => 'Games Zone'] )

@section('content')
<div class="min-h-screen" style="background-image: url('{{ asset('images/background/Background_Color.png') }}'); background-size: cover; background-position: center;">
  <!-- Header Section -->
  <div class="relative px-3 sm:px-6 pt-4 sm:pt-6 pb-3 sm:pb-4">
    <div class="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">

      <!-- Time-based Greeting -->
      <div class="text-center sm:text-left">
        <h1 class="text-xl sm:text-2xl md:text-3xl text-gray-200 font-semibold mb-1" id="greeting">
          Good Evening
        </h1>
        <p class="text-gray-200 text-xs sm:text-sm">Welcome to MaxG Entertainment Hub</p>
      </div>

      <!-- Garuda Logo & Text -->
      <div class="flex items-center space-x-3">
        <div class="flex items-center space-x-3 rounded-lg px-2 sm:px-4 py-2">
          <div class="relative">
            <img src="{{ asset('images/logo/Maxg-ent_white.gif') }}" alt="MaxG Logo" class="w-32 sm:w-48 md:w-64 h-6 sm:h-9 md:h-12 object-contain">
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Main Title Section -->
  <div class="text-center py-4 sm:py-6 md:py-8 px-3 sm:px-6">
    <div class="max-w-4xl mx-auto">
      <h1 class="text-2xl sm:text-3xl md:text-4xl font-bold mb-2 sm:mb-3 text-gray-200">
        Mini Games Collection
      </h1>
      <p class="text-gray-200 text-sm sm:text-base max-w-2xl mx-auto px-4">
        Mainkan MIni Games Seru selama perjalalananmu!
      </p>
    </div>
  </div>

  <!-- Featured/Recommended Games Section -->
  <div class="max-w-7xl mx-auto px-3 sm:px-6 py-4 sm:py-8">
    <div class="mb-8 sm:mb-12">
      <h2 class="text-xl sm:text-2xl font-bold text-gray-200 mb-4 sm:mb-6 flex items-center justify-center sm:justify-start">
        Featured Games
      </h2>
      <div class="grid grid-cols-2 lg:grid-cols-2 gap-4 sm:gap-6 mb-6 sm:mb-8">
        @foreach($games as $game)
          @if($game['status'] === 'active' && isset($game['featured']) && $game['featured'])
            <!-- Featured Game Card with Background Image -->
            <a href="{{ route($game['route']) }}"
               class="group relative bg-gradient-to-br from-white/60 to-slate-50 hover:from-blue-50 hover:to-indigo-50 p-4 sm:p-6 rounded-xl sm:rounded-2xl shadow-md hover:shadow-lg border border-slate-200 hover:border-blue-300 transform hover:scale-105 transition-all duration-300 ease-out overflow-hidden">

              <!-- Background Image with Fade Effect -->
              <div class="absolute inset-0 rounded-xl sm:rounded-2xl overflow-hidden">
                <!-- Background Image - hanya di setengah kanan -->
                <div class="absolute right-0 top-0 w-1/2 h-full bg-cover bg-center bg-no-repeat opacity-80 group-hover:opacity-100 transition-opacity duration-500"
                     style="background-image: url('{{ asset($game['background_image']) }}'); object-fit: contain;">
                </div>

                <!-- Gradient overlay dari kiri ke kanan untuk efek fade -->
                <div class="absolute inset-0 bg-gradient-to-r from-white via-white/70 to-white/30 group-hover:from-white/95 group-hover:via-white/60 group-hover:to-white/20 transition-all duration-500"></div>

                <!-- Additional subtle gradient dari kiri -->
                <div class="absolute inset-0 bg-gradient-to-r from-white/90 via-transparent to-transparent"></div>
              </div>

              <!-- Featured Badge -->
              <div class="absolute top-3 sm:top-4 right-3 sm:right-4 bg-gradient-to-r from-yellow-500 to-orange-500 text-white text-xs font-bold px-2 sm:px-3 py-1 rounded-full shadow-lg z-10">
                FEATURED
              </div>

              <!-- Content -->
              <div class="relative z-10 flex flex-col sm:flex-row items-center sm:items-start space-y-4 sm:space-y-0 sm:space-x-6 text-center sm:text-left">
                <!-- Game Icon -->
                <div class="flex-shrink-0">
                  <div class="text-4xl sm:text-5xl md:text-6xl transform group-hover:scale-110 transition-transform duration-300 drop-shadow-lg">
                    {{ $game['icon'] }}
                  </div>
                </div>

                <!-- Game Info -->
                <div class="flex-grow">
                  <h3 class="text-lg sm:text-xl font-bold text-slate-800 mb-2 group-hover:text-blue-700 transition-colors duration-300 drop-shadow-sm">
                    {{ $game['name'] }}
                  </h3>
                  <p class="text-slate-700 text-sm mb-3 sm:mb-4 leading-relaxed font-medium">
                    {{ $game['description'] }}
                  </p>

                  <!-- Play Button -->
                  <div class="inline-flex items-center px-4 sm:px-6 py-2 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white text-sm font-semibold rounded-lg transform group-hover:scale-105 transition-all duration-300 shadow-lg hover:shadow-xl">
                    <span class="mr-2">▶</span>
                    Play Now
                  </div>
                </div>
              </div>

              <!-- Subtle Glow Effect -->
              <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-r from-blue-400/5 to-indigo-400/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>

              <!-- Border glow effect -->
              <div class="absolute inset-0 rounded-xl sm:rounded-2xl border-2 border-transparent group-hover:border-blue-300/50 transition-all duration-300"></div>
            </a>
          @endif
        @endforeach
      </div>
    </div>

    <!-- All Games Section -->
    <div>
      <h2 class="text-xl sm:text-2xl font-bold text-gray-200 mb-4 sm:mb-6 flex items-center justify-center sm:justify-start">
        All Games
      </h2>

      <div class="grid grid-cols-2 xs:grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 xl:grid-cols-7 2xl:grid-cols-8 gap-2 sm:gap-3 md:gap-4">

      @foreach($games as $game)
        @if($game['status'] === 'active')
          <!-- Active Game Card -->
          <a href="{{ route($game['route']) }}"
             class="group relative bg-gradient-to-br from-white/60 to-slate-50 hover:bg-slate-50 p-3 sm:p-4 rounded-lg sm:rounded-xl shadow-sm hover:shadow-md border border-slate-200 hover:border-blue-300 transform hover:scale-102 transition-all duration-200 ease-out">

            <!-- Subtle Hover Effect -->
            <div class="absolute inset-0 rounded-lg sm:rounded-xl bg-gradient-to-r from-blue-50 to-indigo-50 opacity-0 group-hover:opacity-50 transition-opacity duration-200"></div>

            <!-- Content -->
            <div class="relative z-10 flex flex-col items-center text-center">
              <div class="text-2xl sm:text-3xl mb-2 transform group-hover:scale-105 transition-transform duration-200">
                {{ $game['icon'] }}
              </div>
              <h3 class="text-xs sm:text-sm font-semibold text-slate-800 mb-1 group-hover:text-blue-700 transition-colors duration-200 leading-tight">
                {{ $game['name'] }}
              </h3>
              <p class="text-xs text-slate-500 group-hover:text-slate-600 transition-colors duration-200 line-clamp-2 hidden sm:block">
                {{ $game['description'] }}
              </p>

              <!-- Status Indicator -->
              <div class="mt-1 sm:mt-2 px-2 py-1 bg-green-100 group-hover:bg-green-200 rounded-full text-green-700 text-xs font-medium opacity-0 group-hover:opacity-100 transform translate-y-1 group-hover:translate-y-0 transition-all duration-200 hidden sm:block">
                Available
              </div>
            </div>

            <!-- Corner Badge -->
            <div class="absolute top-1 sm:top-2 right-1 sm:right-2 w-1.5 sm:w-2 h-1.5 sm:h-2 bg-green-400 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-200"></div>
          </a>
        @endif
      @endforeach

    </div>
  </div>

  <!-- Current Time Display -->
  <div class="fixed bottom-2 sm:bottom-4 right-2 sm:right-4 z-20">
    <div class="bg-white/95 backdrop-blur-sm rounded-lg px-2 sm:px-3 py-1 sm:py-2 border border-slate-200 shadow-sm">
      <div class="text-right text-slate-700">
        <div class="text-xs text-blue-600 font-medium">LOCAL TIME</div>
        <div class="text-xs sm:text-sm font-semibold" id="current-time">10:58 AM</div>
      </div>
    </div>
  </div>
</div>

@push('styles')
<style>
  /* Custom breakpoint untuk extra small devices */
  @media (min-width: 475px) {
    .xs\:grid-cols-3 {
      grid-template-columns: repeat(3, minmax(0, 1fr));
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

  /* Enhanced background image effects */
  .bg-cover {
    background-size: cover;
  }

  .bg-center {
    background-position: center;
  }

  .bg-no-repeat {
    background-repeat: no-repeat;
  }

  /* Smooth backdrop filter for better image integration */
  .backdrop-blur-sm {
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
  }

  /* Custom scrollbar for webkit browsers */
  ::-webkit-scrollbar {
    width: 6px;
  }

  @media (min-width: 640px) {
    ::-webkit-scrollbar {
      width: 8px;
    }
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

  /* Drop shadow for better text readability over images */
  .drop-shadow-sm {
    filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.1));
  }

  .drop-shadow-lg {
    filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.1));
  }

  /* Mobile-specific optimizations */
  @media (max-width: 640px) {
    .line-clamp-2 {
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    /* Better touch targets on mobile */
    .touch-target {
      min-height: 44px;
      min-width: 44px;
    }

    /* Prevent horizontal scrolling on very small screens */
    body {
      overflow-x: hidden;
    }
  }

  /* Tablet optimizations */
  @media (min-width: 641px) and (max-width: 1024px) {
    .tablet-optimized {
      padding: 1rem;
    }
  }

  /* Ultra-wide screen optimizations */
  @media (min-width: 1920px) {
    .max-w-7xl {
      max-width: 120rem;
    }
  }

  /* High DPI screen optimizations */
  @media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
    .text-rendering-optimized {
      text-rendering: optimizeLegibility;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }
  }

  /* Landscape orientation optimizations for mobile */
  @media (max-height: 500px) and (orientation: landscape) {
    .py-4 {
      padding-top: 0.5rem;
      padding-bottom: 0.5rem;
    }

    .py-6 {
      padding-top: 1rem;
      padding-bottom: 1rem;
    }

    .py-8 {
      padding-top: 1.5rem;
      padding-bottom: 1.5rem;
    }
  }
</style>
@endpush

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        // Update greeting based on time
        function updateGreeting() {
            const hour = new Date().getHours();
            const greetingElement = document.getElementById('greeting');

            if (hour < 12) {
                greetingElement.textContent = 'Good Morning';
            } else if (hour < 17) {
                greetingElement.textContent = 'Good Afternoon';
            } else {
                greetingElement.textContent = 'Good Evening';
            }
        }

        // Update time display
        function updateTimeDisplay() {
            const now = new Date();
            const options = { timeZone: 'Asia/Jakarta', hour: '2-digit', minute: '2-digit', hour12: true };
            const timeString = now.toLocaleTimeString('en-US', options).replace(/^0/, '');

            const timeElement = document.getElementById('current-time');
            if (timeElement) {
                timeElement.textContent = timeString;
            }
        }

        // Initialize greeting and time display
        updateGreeting();
        updateTimeDisplay();
        setInterval(updateTimeDisplay, 1000);

        // Add responsive behavior for very small screens
        function handleResize() {
            const width = window.innerWidth;
            const gamesGrid = document.querySelector('.grid');

            if (width < 380) {
                // Very small screens - adjust grid
                if (gamesGrid && gamesGrid.classList.contains('grid-cols-2')) {
                    gamesGrid.classList.remove('grid-cols-2');
                    gamesGrid.classList.add('grid-cols-2');
                }
            }
        }

        // Listen for window resize
        window.addEventListener('resize', handleResize);
        handleResize(); // Initial call

        // Optimize for touch devices
        if ('ontouchstart' in window) {
            document.body.classList.add('touch-device');

            // Add touch-friendly styles
            const style = document.createElement('style');
            style.textContent = `
                .touch-device .group:hover {
                    transform: none;
                }
                .touch-device .group:active {
                    transform: scale(0.98);
                }
            `;
            document.head.appendChild(style);
        }
    });
</script>
@endpush
@endsection
