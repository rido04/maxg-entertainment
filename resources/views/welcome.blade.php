@extends('layouts.app', ['title' => 'Welcome Aboard'])

@section('content')
<div class="min-h-screen m-0 p-0">
<!-- Background dengan efek gradient -->
<div class="fixed inset-0 bg-gradient-to-br from-slate-900/25 via-blue-900/15 to-slate-800/25 overflow-hidden">
    <!-- Airplane background -->
    <div class="absolute inset-0">
        <img src="{{asset('images/background/Background_Color.png')}}"
             alt="Langit" class="w-full h-full object-cover">
    </div>
    <!-- Overlay gradient -->
    <div class="absolute inset-0 bg-gradient-to-r"></div>
</div>

<!-- Header -->
<header class="relative z-20 flex flex-col sm:flex-row justify-between items-center px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
    <!-- Logo Garuda -->
    <div class="flex items-center -ml-14 space-x-3 mb-4 sm:mb-0">
        <div class="w-72 sm:w-96 lg:w-[500px] h-12 sm:h-16 lg:h-20 flex items-center justify-center">
            <img src="{{ asset('Logo-Garuda-Animasi.gif') }}" alt="Garuda Airlines" class="w-full h-full object-contain">
        </div>
    </div>

    <!-- Top navigation icons -->
    <div class="flex items-center space-x-4">
        <div class="w-36 sm:w-48 lg:w-60 h-12 sm:h-16 lg:h-20 text-sm px-2 sm:px-3 py-1">
            <img src="{{ asset('5 Star Airline White.png') }}" alt="5 star skytrax" class="w-full h-full object-contain">
        </div>
    </div>
</header>

<!-- Main Content -->
<div class="relative z-10 min-h-screen flex flex-col lg:flex-row">
    <!-- Left Section - Welcome -->
    <div class="flex-1 flex flex-col justify-center px-4 sm:px-6 lg:px-12 py-8 sm:py-12 lg:py-20 -mt-8 sm:-mt-16 lg:-mt-32">
        <div class="max-w-xl fade-in text-center lg:text-left">
            <h2 class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-4 sm:mb-6 leading-tight">
                Welcome Aboard
                <span class="bg-blue-400 bg-clip-text block font-bold text-transparent bg-gradient-to-r from-blue-300 to-blue-500">
                    Garuda Indonesia
                </span>
            </h2>
            <p class="text-base sm:text-lg lg:text-xl text-gray-100 mb-6 sm:mb-8 leading-relaxed px-2 sm:px-0">
                Enjoy your entertainment journey with the best experience in movies, music, games, etc.
            </p>
        </div>
    </div>

    <!-- Right Section - Flight Info -->
    <div class="w-full lg:w-1/2 flex flex-col justify-center px-4 sm:px-6 lg:px-8 py-8 sm:py-12 lg:py-20 -mt-8 sm:-mt-16 lg:-mt-0">
        <div class="flex justify-center lg:justify-start">
            <img src="{{ asset('Pesawat Garuda.png') }}"
                 alt="Pesawat Garuda"
                 class="w-64 sm:w-80 md:w-96 lg:w-full h-auto max-w-md lg:max-w-none lg:-mt-44 lg:-ml-12 animate-fly-in">
        </div>
    </div>
</div>

<!-- Current Time Display -->
<div class="fixed bottom-4 sm:bottom-6 right-4 sm:right-6 z-20">
    <div class="bg-white/90 backdrop-blur-sm rounded-lg px-2 sm:px-3 py-1 sm:py-2 border border-gray-200 shadow-lg">
      <div class="text-right text-gray-800">
        <div class="text-xs text-blue-600 font-medium">NOW</div>
        <div class="text-xs sm:text-sm font-bold" id="current-time">10:58 AM</div>
      </div>
    </div>
  </div>
</div>
@endsection

@push('scripts')
<script>
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

  // Dynamic greeting based on time
  function updateGreeting() {
    const hour = new Date().getHours();
    const greeting = document.getElementById('greeting');

    if (greeting) {
      if (hour < 12) {
        greeting.textContent = 'Good morning';
      } else if (hour < 17) {
        greeting.textContent = 'Good afternoon';
      } else {
        greeting.textContent = 'Good evening';
      }
    }
  }

  updateGreeting();

  // Add click handlers for play buttons
  document.querySelectorAll('button').forEach(button => {
    if (button.querySelector('svg path[fill-rule="evenodd"]')) {
      button.addEventListener('click', function(e) {
        e.preventDefault();
        // Add your play logic here
        console.log('Play button clicked');
      });
    }
  });

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

  // Add touch support for mobile devices
  document.querySelectorAll('.overflow-x-auto').forEach(container => {
    let startX;
    let scrollLeft;

    container.addEventListener('touchstart', (e) => {
      startX = e.touches[0].pageX - container.offsetLeft;
      scrollLeft = container.scrollLeft;
    });

    container.addEventListener('touchmove', (e) => {
      if (!startX) return;
      e.preventDefault();
      const x = e.touches[0].pageX - container.offsetLeft;
      const walk = (x - startX) * 2;
      container.scrollLeft = scrollLeft - walk;
    });

    container.addEventListener('touchend', () => {
      startX = null;
    });
  });
});
</script>
@endpush
@push('styles')
<style>
    body{
        overflow: hidden;
    }

    /* Responsive overflow handling */
    @media (max-width: 768px) {
        body {
            overflow-x: hidden;
            overflow-y: auto;
        }
    }

    .glass-effect {
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        background: rgba(0, 0, 0, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.1);
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    }

    .card-hover {
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .card-hover:hover {
        box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
    }

    .fade-in {
        animation: fadeIn 1.2s ease-out;
    }

    .slide-up {
        animation: slideUp 1s ease-out 0.3s both;
    }

    @keyframes fly-in {
        0% {
            transform: translateX(-100px) translateY(20px) rotate(-5deg);
            opacity: 0;
        }
        100% {
            transform: translateX(0) translateY(0) rotate(0deg);
            opacity: 1;
        }
    }

    /* Responsive fly-in animation */
    @media (max-width: 768px) {
        @keyframes fly-in {
            0% {
                transform: translateX(-50px) translateY(20px) rotate(-3deg);
                opacity: 0;
            }
            100% {
                transform: translateX(0) translateY(0) rotate(0deg);
                opacity: 1;
            }
        }
    }

    .animate-fly-in {
        animation: fly-in 2s ease-out 0.5s both;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(40px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    @keyframes float {
        0%, 100% {
            transform: translateY(0);
        }
        50% {
            transform: translateY(-10px);
        }
    }

    /* Mobile-specific styles */
    @media (max-width: 640px) {
        .min-h-screen {
            min-height: 100vh;
            min-height: 100dvh; /* Dynamic viewport height for mobile */
        }

        /* Ensure text is readable on mobile */
        .text-white {
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        }

        .text-gray-100 {
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
        }
    }

    /* Tablet-specific styles */
    @media (min-width: 641px) and (max-width: 1024px) {
        .lg\:flex-row {
            flex-direction: column;
        }

        .lg\:w-1\/2 {
            width: 100%;
        }

        .lg\:text-left {
            text-align: center;
        }
    }

    /* Improve touch targets for mobile */
    @media (max-width: 768px) {
        button, .cursor-pointer {
            min-height: 44px;
            min-width: 44px;
        }
    }

    /* Responsive background image */
    @media (max-width: 768px) {
        .fixed.inset-0 img {
            object-position: center center;
        }
    }

    /* Safe area handling for mobile devices with notches */
    @supports (padding: max(0px)) {
        .px-4 {
            padding-left: max(1rem, env(safe-area-inset-left));
            padding-right: max(1rem, env(safe-area-inset-right));
        }

        .fixed.bottom-4 {
            bottom: max(1rem, env(safe-area-inset-bottom));
        }
    }
</style>
@endpush
