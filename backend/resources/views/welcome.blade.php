@extends('layouts.app', ['title' => 'Welcome'])

@section('content')
<div class="min-h-screen m-0 p-0">
<!-- Background dengan efek gradient -->
<div class="fixed inset-0 bg-gradient-to-br from-slate-900/25 via-blue-900/15 to-slate-800/25 overflow-hidden">
    <!-- Airplane background -->
    <div class="absolute inset-0">
        <img src="{{ asset('images/background/Background_Color.png') }}" alt="bg maxg" class="w-full h-full object-cover">
    </div>
    <!-- Overlay gradient -->
</div>

<!-- Header -->
<header class="relative z-20 flex flex-col sm:flex-row justify-between items-center px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
    <!-- Logo MaxG -->
    <div class="flex items-center space-x-3 mb-4 sm:mb-0">
        <div class="w-60 sm:w-80 lg:w-60 h-12 sm:h-16 lg:h-20 flex items-center justify-center py-1">
            <img src="{{ asset('images/logo/Maxg-ent_white.gif') }}" alt="MaxG Entertainment Hub" class="w-full h-full object-contain">
        </div>
    </div>

    <!-- Top navigation icons -->
    <div class="flex items-center space-x-4">
        <div class="w-60 sm:w-60 lg:w-60 h-12 sm:h-16 lg:h-20 text-sm px-2 sm:px-3 py-1">
            <img src="{{ asset('images/logo/mcm x grab_.png') }}" alt="grab dan mcm logo" class="w-full h-full object-contain">
        </div>
    </div>
</header>

<!-- Main Content -->
<div class="relative z-10 min-h-screen flex flex-col lg:flex-row md-flex-row sm:flex-row xl:flex-row">
    <!-- Left Section - Welcome -->
    <div class="flex-1 flex flex-col justify-center px-4 sm:px-6 lg:px-12 py-8 sm:py-8 lg:py-20 -mt-8 sm:mt-16 lg:-mt-32">
        <div class="max-w-xl fade-in text-left lg:text-left">
            <h2 class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-medium text-white mb-4 sm:mb-6 leading-tight">
                Welcome to
                <span class="text-9xl bg-clip-text block font-bold text-transparent bg-gradient-to-r from-green-300 to-green-500">
                    MaxG
                </span>
                <span class="bg-clip-text block font-medium text-transparent bg-white">
                    Entertainment Hub
                </span>
            </h2>
            <p class="text-base sm:text-lg lg:text-xl text-gray-100 mb-6 sm:mb-8 leading-relaxed px-2 sm:px-0">
                Your Everyday everything App
            </p>
        </div>
    </div>

    <!-- Right Section - Flight Info -->
    <div class="w-full flex flex-col justify-center px-4 lg:px-8 py-8 lg:py-8 -mt-8 lg:-mt-0 mr-44 sm:mt-24">
        <div class="flex justify-center">
            <img src="{{ asset('images/background/Grabcar_MasAdam.gif') }}"
                 alt="Mobil Grab"
                 class="xl:w-1/2 lg:w-full md:w-full sm:w-full h-auto max-w-none -mt-44 -mr-52 xl:-mr-96 animate-fly-in" style="filter: drop-shadow(0 -4px 8px rgba(0,0,0,0.3)) drop-shadow(-4px 0 8px rgba(0,0,0,0.2)) drop-shadow(4px 0 8px rgba(0,0,0,0.2));">
        </div>
    </div>
</div>

<!-- Current Time Display -->
<div class="fixed bottom-6 right-6 z-20">
    <div class="bg-white/60 backdrop-blur-lg border border-white/20 rounded-xl px-4 py-3 shadow-[0_8px_32px_0_rgba(31,38,135,0.37)] hover:bg-white/15 hover:scale-105 transition-all duration-300 opacity-60">
        <div class="text-right flex-col text-gray-700">
            <div class="text-xs text-blue-500 inline-flex font-semibold tracking-wider">NOW</div>
            <div class="text-lg inline-flex font-bold" id="current-time">10:58 AM</div>
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
            overflow: hidden;
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
    animation: fadeInUpDown 2s ease-out;
    }

    @keyframes fadeInUpDown {
    0% {
        opacity: 0;
        transform: translateY(0px);
    }
    50% {
        opacity: 0.5;
        transform: translateY(30px);
    }
    100% {
        opacity: 1;
        transform: translateY(0px);
    }
}

    .slide-up {
        animation: slideUp 1s ease-out 0.3s both;
    }

    @keyframes fly-in {
        0% {
        opacity: 0;
        transform: translateY(0px);
    }
    50% {
        opacity: 0.5;
        transform: translateY(30px);
    }
    100% {
        opacity: 1;
        transform: translateY(0px);
    }
    }

    /* Responsive fly-in animation */
    @media (max-width: 768px) {
        @keyframes fly-in {
            0% {
        opacity: 0;
        transform: translateY(0px);
            }
            50% {
                opacity: 0.5;
                transform: translateY(30px);
            }
            100% {
                opacity: 1;
                transform: translateY(0px);
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
