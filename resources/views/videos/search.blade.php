@extends('layouts.app')

@section('content')
<!-- Background with enhanced gradient matching app theme -->
<div class="min-h-screen relative overflow-hidden" style="background-image: url('{{ asset('images/background/BG1.jpg') }}'); background-size: cover; background-position: center;">
  <!-- Animated background particles with softer colors -->
  <div class="absolute inset-0 overflow-hidden">
    <div class="absolute -top-40 -left-40 w-80 h-80 bg-blue-500/10 rounded-full blur-3xl animate-pulse"></div>
    <div class="absolute top-1/2 -right-40 w-96 h-96 bg-purple-500/8 rounded-full blur-3xl animate-pulse" style="animation-delay: 2s;"></div>
    <div class="absolute -bottom-40 left-1/3 w-72 h-72 bg-indigo-500/8 rounded-full blur-3xl animate-pulse" style="animation-delay: 4s;"></div>
  </div>

  <!-- Overlay gradient with subtle animation -->
  <div class="absolute inset-0"></div>

  <div class="absolute top-4 right-4">
    <img src="{{ asset('images/logo/Maxg-ent_white.gif') }}" alt="Logo" class="w-80 h-auto">
    </div>
  <!-- Main Content -->
  <div class="relative z-10 p-6">
    <!-- Enhanced Back Button -->
    <div class="mb-8">
      <button onclick="history.back()" class="group flex items-center gap-3 px-6 py-3 bg-red-800/60 backdrop-blur-sm rounded-xl border border-gray-700/50 hover:bg-red-700/70 hover:border-gray-600/50 transition-all duration-300 transform hover:scale-105 hover:shadow-lg">
        <div class="w-8 h-8 bg-blue-500/20 rounded-full flex items-center justify-center group-hover:bg-blue-500/30 transition-colors">
          <svg class="w-4 h-4 text-blue-400 group-hover:text-blue-300 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
        </div>
        <span class="font-medium text-gray-200 group-hover:text-white transition-colors">Kembali</span>
      </button>
    </div>

    <!-- Enhanced Title with animated underline -->
    <div class="mb-12 text-center">
      <h2 class="text-4xl md:text-5xl font-bold mb-4 bg-gray-200 bg-clip-text text-transparent">
        Hasil Pencarian
      </h2>
      <div class="w-24 h-1 bg-gradient-to-r from-blue-500 to-blue-500 mx-auto rounded-full"></div>
    </div>

    @if($videos->isNotEmpty())
      <!-- Results count with animation -->
      <div class="mb-8 text-center">
        <div class="inline-flex items-center gap-2 px-4 py-2 bg-gray-200 backdrop-blur-sm rounded-full border border-gray-700/30">
          <div class="w-2 h-2 bg-blue-700 rounded-full animate-pulse"></div>
          <span class="text-gray-900 text-sm font-medium">{{ $videos->count() }} Hasil Ditemukan</span>
        </div>
      </div>

      <!-- Enhanced Grid with staggered animations -->
      <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6">
        @foreach($videos as $index => $video)
          <div class="group relative rounded-2xl overflow-hidden bg-gray-200 backdrop-blur-sm border border-gray-700/30 shadow-xl hover:shadow-2xl hover:bg-gray-800/50 hover:border-gray-600/50 transition-all duration-500 transform hover:scale-105 hover:-translate-y-2"
               style="animation: slideInUp 0.6s ease-out forwards; animation-delay: {{ $index * 0.1 }}s; opacity: 0;">
            <a href="{{ route('videos.show', $video) }}" class="block">
              <div class="relative overflow-hidden">
                @if($video->thumbnail)
                  <img src="{{ $video->thumbnail }}"
                       alt="{{ $video->title }}"
                       class="w-full h-72 object-cover transition-all duration-500 group-hover:scale-110">
                @else
                  <div class="w-full h-72 bg-gradient-to-br from-gray-800 to-gray-900 flex items-center justify-center">
                    <div class="w-16 h-16 bg-blue-500/20 rounded-full flex items-center justify-center">
                      <svg class="w-8 h-8 text-blue-400" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M8 5v14l11-7z"/>
                      </svg>
                    </div>
                  </div>
                @endif

                <!-- Enhanced overlay with gradient -->
                <div class="absolute inset-0 bg-gradient-to-t from-gray-900/90 via-transparent to-gray-900/20 opacity-0 group-hover:opacity-100 transition-all duration-300"></div>

                <!-- Play button with pulsing effect -->
                <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-300">
                  <div class="w-14 h-14 bg-blue-500/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-lg hover:bg-blue-500 hover:scale-110 transition-all duration-300">
                    <svg class="w-6 h-6 text-white ml-1" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M8 5v14l11-7z"/>
                    </svg>
                  </div>
                </div>

                <!-- Rating badge -->
                @if($video->rating)
                  <div class="absolute top-3 right-3 px-2 py-1 bg-gray-900/80 backdrop-blur-sm rounded-lg border border-gray-700/50">
                    <div class="flex items-center gap-1">
                      <svg class="w-3 h-3 text-yellow-400" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                      </svg>
                      <span class="text-xs text-white font-medium">{{ $video->rating }}</span>
                    </div>
                  </div>
                @endif
              </div>

              <!-- Enhanced card content -->
              <div class="p-4">
                <h3 class="text-sm font-semibold text-gray-700 truncate mb-2 group-hover:text-white transition-colors">
                  {{ $video->title }}
                </h3>
                <div class="flex items-center justify-between">
                  <p class="text-xs text-gray-400 group-hover:text-gray-300 transition-colors">
                    {{ $video->rating ? 'Rating: ' . $video->rating . '/10' : 'No rating yet' }}
                  </p>
                  <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <div class="w-1 h-1 bg-blue-400 rounded-full animate-pulse"></div>
                    <div class="w-1 h-1 bg-green-400 rounded-full animate-pulse" style="animation-delay: 0.2s;"></div>
                    <div class="w-1 h-1 bg-yellow-400 rounded-full animate-pulse" style="animation-delay: 0.4s;"></div>
                  </div>
                </div>
              </div>
            </a>
          </div>
        @endforeach
      </div>
    @else
      <!-- Enhanced empty state -->
      <div class="text-center py-20">
        <div class="bg-gray-800/40 backdrop-blur-sm border border-gray-700/30 rounded-3xl p-12 max-w-md mx-auto">
          <div class="w-20 h-20 bg-blue-500/20 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
            </svg>
          </div>
          <h3 class="text-2xl font-bold text-white mb-3">Hasil tidak ditemukan</h3>
          <p class="text-gray-200 mb-6">Yah konten yang kamu cari tidak ada...., coba kata kunci lain yaa</p>
          <button onclick="history.back()" class="px-6 py-3 bg-gradient-to-r from-yellow-600 to-green-600 hover:from-blue-500 hover:to-green-500 text-white rounded-xl font-medium transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-xl">
            Cari yang lain
          </button>
        </div>
      </div>
    @endif
  </div>

  <!-- Enhanced Time Display with live update -->
  <div class="fixed bottom-6 right-6 z-auto">
    <div class="bg-white/90 backdrop-blur-sm rounded-lg px-3 py-2 border border-gray-200 shadow-lg">
      <div class="text-right text-gray-800">
        <div class="text-xs text-blue-600 font-medium">Now</div>
        <div class="text-sm font-bold" id="current-time">
          11:32 AM
        </div>
      </div>
    </div>
  </div>
</div>

@push('styles')
<style>
  .glass-effect {
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    background: rgba(255, 4, 4, 0.925);
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  }

  @keyframes gradient-shift {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.8; }
  }

  @keyframes gradient-text {
    0%, 100% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
  }

  .animate-gradient-shift {
    animation: gradient-shift 8s ease-in-out infinite;
  }

  .animate-gradient-text {
    background-size: 200% 200%;
    animation: gradient-text 3s ease-in-out infinite;
  }

  .film-card {
    animation: slideInUp 0.6s ease-out forwards;
    opacity: 0;
    transform: translateY(30px);
  }

  @keyframes slideInUp {
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  /* Custom scrollbar */
  ::-webkit-scrollbar {
    width: 8px;
  }

  ::-webkit-scrollbar-track {
    background: rgba(30, 41, 59, 0.3);
  }

  ::-webkit-scrollbar-thumb {
    background: linear-gradient(to bottom, #14b8a6, #06b6d4);
    border-radius: 4px;
  }

  ::-webkit-scrollbar-thumb:hover {
    background: linear-gradient(to bottom, #0d9488, #0891b2);
  }
</style>
@endpush

@push('scripts')
<script>
  // Live time update
  function updateTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('id-ID', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });
    document.getElementById('current-time').textContent = timeString;
  }

  setInterval(updateTime, 1000);
  updateTime(); // Initial call

  // Scroll to top functionality
  const scrollTopBtn = document.getElementById('scrollTop');

  window.addEventListener('scroll', () => {
    if (window.pageYOffset > 300) {
      scrollTopBtn.classList.remove('opacity-0', 'translate-y-16');
      scrollTopBtn.classList.add('opacity-100', 'translate-y-0');
    } else {
      scrollTopBtn.classList.add('opacity-0', 'translate-y-16');
      scrollTopBtn.classList.remove('opacity-100', 'translate-y-0');
    }
  });

  scrollTopBtn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });

  // Add loading states for images
  document.querySelectorAll('img').forEach(img => {
    img.addEventListener('load', function() {
      this.classList.add('loaded');
    });
  });
</script>
@endpush

@endsection
