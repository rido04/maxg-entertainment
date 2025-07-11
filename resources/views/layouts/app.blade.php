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
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>


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

<div id="loader"
     class="fixed inset-0 bg-white/80 flex flex-col items-center justify-center z-50 gap-4 transition-opacity duration-300">

    <!-- Logo -->
    <img src="{{ asset('images/logo/Logo-MaxG-Green.gif') }}" alt="Logo" class="w-24 h-24 object-contain animate-bounce-slow">

    <!-- Spinner -->
    <div class="animate-spin rounded-full h-10 w-10 border-4 border-green-500 border-t-transparent"></div>

    <!-- Text optional -->
    <p class="text-gray-500 font-medium mt-2 tracking-wide">Loading page...</p>
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
</body>
</html>
