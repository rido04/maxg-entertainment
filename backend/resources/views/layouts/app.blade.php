<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ $title ?? 'Your Entertainment Hub' }}</title>

    {{-- <!-- Scripts -->
    <link rel="stylesheet" href="{{ asset('build/assets/app-C-uGQpm3.css', true) }}">
    <script src="{{ asset('build/assets/app-C0y3UHmG.js', true) }}"></script> --}}
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <script src="{{ asset('js/audio-player-global.js') }}"></script>

    @stack('styles')
</head>
<body class="font-sans antialiased min-h-screen m-0 p-0" style="background-image: url('{{ asset('images/background/Background_Color.png') }}'); background-size: cover; background-position: center;">
    @include('navbar')
    <!-- Main Content -->
    <main class="relative z-10">
        @yield('content')
    </main>
    <!-- Footer -->
    <footer class="relative py-0 px-0 w-full">
        @include('footer')
    </footer>

    @stack('scripts')

    <script>
        // Common JavaScript functions can be added here
    </script>

    <!-- Mini Player Widget -->
    <div id="miniPlayer" class="fixed bottom-0 left-0 right-0 bg-gray-900 border-t border-gray-700 p-4 transform translate-y-full transition-transform duration-300 z-50 hidden">
        <div class="max-w-7xl mx-auto flex items-center justify-between">
        <!-- Song Info -->
        <div class="flex items-center space-x-4 flex-1 min-w-0">
            <div class="w-14 h-14 rounded bg-gradient-to-br from-blue-600 to-blue-800 flex-shrink-0">
            <img id="miniThumbnail" src="" alt="" class="w-full h-full object-cover rounded hidden">
            <div id="miniThumbnailPlaceholder" class="w-full h-full flex items-center justify-center">
                <svg class="w-6 h-6 text-blue-300" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                </svg>
            </div>
            </div>
            <div class="min-w-0 flex-1">
            <h4 id="miniTitle" class="text-white font-medium truncate">Song Title</h4>
            <p id="miniArtist" class="text-gray-400 text-sm truncate">Artist Name</p>
            </div>
            <button class="text-gray-400 hover:text-white p-2">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" />
            </svg>
            </button>
        </div>

      <!-- Progress & Volume -->
      <div class="flex items-center space-x-4 flex-1 justify-end">
        <button class="text-gray-400 hover:text-white">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M8.445 14.832A1 1 0 0010 14v-2.798l5.445 3.63A1 1 0 0017 14V6a1 1 0 00-1.555-.832L10 8.798V6a1 1 0 00-1.555-.832l-6 4a1 1 0 000 1.664l6 4z" />
            </svg>
            </button>
            <button id="miniPlayBtn" class="w-8 h-8 bg-white text-black rounded-full flex items-center justify-center hover:scale-105 transition-transform">
            <svg id="miniPlayIcon" class="w-4 h-4 ml-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
            </svg>
            <svg id="miniPauseIcon" class="w-4 h-4 hidden" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
            </button>
            <button class="text-gray-400 hover:text-white">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M4.555 5.168A1 1 0 003 6v8a1 1 0 001.555.832L10 11.202V14a1 1 0 001.555.832l6-4a1 1 0 000-1.664l-6-4A1 1 0 0010 6v2.798l-5.445-3.63z" />
            </svg>
            </button>
        <button id="miniCloseBtn" class="text-gray-400 hover:text-white p-1">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>
    </div>
  </div>

  <!-- Hidden Audio Element -->
  <audio id="audioPlayer" preload="metadata">
    <source id="audioSource" src="" type="audio/mpeg">
    Your browser does not support the audio element.
  </audio>

  <!-- Full Map Modal -->
  <div id="mapModal" class="fixed inset-0 bg-black/70 z-50 hidden opacity-0 transition-opacity duration-300">
    <div class="w-full h-full p-4 flex items-center justify-center">
      <div class="bg-white rounded-lg w-full max-w-6xl h-full max-h-[90vh] overflow-hidden relative transform scale-95 transition-transform duration-300">
        <!-- Modal Header -->
        <div class="bg-green-700 text-white p-4 flex justify-between items-center">
          <h3 class="text-lg font-medium">Live Navigation</h3>
          <button id="closeMapModal" class="text-gray-300 hover:text-white transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>

        <!-- Map Container -->
        <div class="h-full">
          <iframe
            id="modalMapFrame"
            src="/route-minimal"
            class="w-full h-full border-0">
          </iframe>
        </div>
      </div>
    </div>
  </div>

  <!-- Floating Map Trigger Button -->
  <div id="mapTriggerBtn" class="fixed bottom-0 left-1/2 transform -translate-x-1/2 z-30 cursor-pointer group sm:-mb-2">
    <div class="relative transition-all duration-300">
        <img src="{{ asset('images/logo/tarikan.png') }}"
             alt="Tap for map"
             class="w-52 h-auto object-contain transition-opacity duration-300 opacity-70 filter blur-3xl"  style="filter: drop-shadow(0 -4px 8px rgba(0,0,0,0.3)) drop-shadow(-4px 0 8px rgba(0,0,0,0.2)) drop-shadow(4px 0 8px rgba(0,0,0,0.2));">

        <div class="absolute inset-0 flex flex-col items-center justify-center space-y-1">
            <!-- Text -->
            <div class="text-center inline-flex mt-4 items-center mb-2">
                <p class="text-gray-700 font-medium text-xs drop-shadow-sm mr-2 mb-2">Live </p>

                <div class="relative">
                    <div class="absolute inset-0 rounded-full bg-green-400 opacity-75 animate-ping"></div>
                    <div class="absolute inset-0 rounded-full bg-green-400 opacity-50 animate-ping" style="animation-delay: 0.5s;"></div>
                    <div class="relative w-5 h-5 sm:mb-2 bg-green-500 rounded-full flex items-center justify-center animate-pulse">
                        <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                        </svg>
                    </div>
                </div>
                <p class="text-gray-700 font-medium text-xs drop-shadow-sm ml-2 mb-2">Navigation</p>

            </div>
        </div>
    </div>
</div>

<!-- Custom CSS for enhanced animations -->
<style>
/* Enhanced pulse animation */
@keyframes enhanced-pulse {
    0%, 100% {
        transform: scale(1);
        opacity: 1;
    }
    50% {
        transform: scale(1.1);
        opacity: 0.8;
    }
}

/* Ring animation */
@keyframes ring-animation {
    0% {
        transform: scale(1);
        opacity: 1;
    }
    100% {
        transform: scale(2);
        opacity: 0;
    }
}

/* Custom animation classes */
.animate-enhanced-pulse {
    animation: enhanced-pulse 2s ease-in-out infinite;
}

.animate-ring {
    animation: ring-animation 1.5s ease-out infinite;
}

/* Hover effects for trigger button */
#mapTriggerBtn:hover .animate-ping {
    animation-duration: 0.8s;
}

#mapTriggerBtn:hover .animate-pulse {
    animation-duration: 1.2s;
}

/* Modal animation enhancement */
.modal-enter {
    transform: scale(0.9);
    opacity: 0;
}

.modal-enter-active {
    transform: scale(1);
    opacity: 1;
    transition: all 0.3s ease-out;
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const mapTriggerBtn = document.getElementById('mapTriggerBtn');
    const mapModal = document.getElementById('mapModal');
    const closeMapModal = document.getElementById('closeMapModal');
    const modalMapFrame = document.getElementById('modalMapFrame');

    // Show modal directly when trigger button is clicked
    mapTriggerBtn.addEventListener('click', function() {
        openModal();
    });

    // Function to open modal with animation
    function openModal() {
        mapModal.classList.remove('hidden');

        // Add entrance animation
        const modalContent = mapModal.querySelector('.bg-white');
        modalContent.classList.add('scale-95');

        setTimeout(() => {
            mapModal.classList.remove('opacity-0');
            modalContent.classList.remove('scale-95');
            modalContent.classList.add('scale-100');
        }, 10);

        // Reload iframe to fix any sizing issues
        modalMapFrame.src = modalMapFrame.src;

        // Add some visual feedback to trigger button
        mapTriggerBtn.style.transform = 'translateX(-50%) scale(0.95)';
        setTimeout(() => {
            mapTriggerBtn.style.transform = 'translateX(-50%) scale(1)';
        }, 150);
    }

    // Function to close modal
    function closeModal() {
        const modalContent = mapModal.querySelector('.bg-white');
        modalContent.classList.add('scale-95');
        mapModal.classList.add('opacity-0');

        setTimeout(() => {
            mapModal.classList.add('hidden');
            modalContent.classList.remove('scale-95', 'scale-100');
        }, 300);
    }

    // Close modal when close button is clicked
    closeMapModal.addEventListener('click', closeModal);

    // Close modal when clicking outside
    mapModal.addEventListener('click', function(e) {
        if (e.target === mapModal) {
            closeModal();
        }
    });

    // Close modal with Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && !mapModal.classList.contains('hidden')) {
            closeModal();
        }
    });
});
</script>

<div id="loader"
     class="fixed inset-0 bg-white/80 flex flex-col items-center justify-center z-50 gap-4 transition-opacity duration-300">

    <img src="{{ asset('images/logo/Logo-MaxG-Green.gif') }}" alt="Logo" class="w-24 h-24 object-contain animate-bounce-slow">

    <div class="animate-spin rounded-full h-10 w-10 border-4 border-green-500 border-t-transparent"></div>

    <p class="text-gray-500 font-medium mt-2 tracking-wide">Loading page...</p>
</div>

<div id="screensaver" class="fixed inset-0 bg-black z-[9999] hidden flex items-center justify-center ">
    <!-- Video -->
    <video id="screensaverVideo" class="w-full h-full object-cover absolute inset-0" style="bottom: -50px;" autoplay></video>
    <!-- Reminder Text -->
    <div class="absolute bottom-5 flex w-full justify-between px-4">
        <p class="text-white text-sm sm:text-base font-medium opacity-70">
            Tap di mana saja untuk keluar dari screensaver
        </p>
        <p class="text-white text-sm sm:text-base font-medium opacity-70 text-right">
            For placement advertising contact us: 082121212
        </p>
    </div>
</div>




<script>
window.addEventListener("load", function () {
    const loader = document.getElementById("loader");
    if (loader) loader.classList.add("hidden");
});
window.addEventListener("pageshow", function () {
    const loader = document.getElementById("loader");
    if (loader) loader.classList.add("hidden");
});
window.addEventListener("beforeunload", function () {
    const loader = document.getElementById("loader");
    if (loader) loader.classList.remove("hidden");
});

// Deteksi WebView - versi sederhana
if (navigator.userAgent.includes('GarudaApp') || navigator.userAgent.includes('Chrome/115')) {
    console.log('Detected WebView, forcing desktop layout');

    // Simple viewport override tanpa auto-scaling
    var viewport = document.querySelector('meta[name="viewport"]');
    if (viewport) {
        viewport.content = 'width=1024, user-scalable=yes';
    } else {
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=1024, user-scalable=yes';
        document.getElementsByTagName('head')[0].appendChild(meta);
    }

    // Force desktop layout
    document.documentElement.style.minWidth = '1024px';
    document.body.style.minWidth = '1024px';

    // Override CSS responsive
    var style = document.createElement('style');
    style.innerHTML = `
        @media screen and (max-width: 1024px) {
            .container, .container-fluid {
                max-width: none !important;
                width: 1024px !important;
                min-width: 1024px !important;
            }
            .navbar-collapse {
                display: flex !important;
            }
            .navbar-toggler {
                display: none !important;
            }
            .d-md-block {
                display: block !important;
            }
            .d-md-none {
                display: none !important;
            }
        }

        body {
            overflow-x: auto !important;
            min-width: 1024px !important;
        }
    `;
    document.head.appendChild(style);

    document.body.classList.add('webview-desktop-mode');
}
</script>

<script>
    const screensaver = document.getElementById("screensaver");
    const video = document.getElementById("screensaverVideo");

    const videoSources = [
        "{{ asset('video/Bebas Seenaknya Pasti Diskon Grabfood.mp4') }}",
        "{{ asset('video/GrabMart Beauty Ready.mp4') }}",
        // "{{ asset('video/jurassic-world.mp4') }}"
    ];

    let currentIndex = 0;

    function playNextVideo() {
        video.src = videoSources[currentIndex];
        video.play();
        currentIndex = (currentIndex + 1) % videoSources.length;
    }

    // Putar video pertama saat screensaver aktif
    function showScreensaver() {
        screensaver.classList.remove("hidden");
        currentIndex = 0;
        playNextVideo();
    }

    function hideScreensaver() {
        screensaver.classList.add("hidden");
        video.pause();
    }

    // Ganti video saat yang sekarang selesai
    video.addEventListener('ended', () => {
        playNextVideo();
    });

    // Inactivity detection (60 detik)
    let inactivityTimeout;
    function resetInactivityTimer() {
        clearTimeout(inactivityTimeout);
        inactivityTimeout = setTimeout(showScreensaver, 30000); // 1 menit
    }

    ['mousemove', 'keydown', 'touchstart'].forEach(evt => {
        window.addEventListener(evt, () => {
            hideScreensaver();
            resetInactivityTimer();
        });
    });

    resetInactivityTimer();
</script>


</body>
</html>
