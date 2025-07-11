@extends('layouts.app')

@section('content')
<div class="min-h-screen" style="background-image: url('{{ asset('images/background/BG1.jpg') }}'); background-size: cover; background-position: center;">
    <!-- Logo Section -->
    <div class="flex justify-center pt-6 pb-4 animate-fade-in">
        <div class="w-64 h-24 sm:w-80 sm:h-32 flex items-center justify-center">
            <div class="p-4 animate-float">
                <img src="{{ asset('Logo-Garuda-Animasi.gif') }}"
                     alt="Garuda Indonesia Logo"
                     class="max-w-full max-h-full object-contain drop-shadow-lg">
            </div>
        </div>
    </div>

    <!-- Main Content Container -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12">
        <!-- Hero Title -->
        <div class="text-center mb-8 animate-slide-up">
            <h1 class="text-3xl sm:text-4xl lg:text-6xl font-bold hero-title mb-4 leading-tight">
                Explore Flight Routes
                <span class="block text-garuda-teal text-2xl sm:text-3xl lg:text-4xl mt-2">
                    Connecting Indonesia to the World
                </span>
            </h1>
            <p class="text-lg sm:text-xl text-gray-300 max-w-3xl mx-auto leading-relaxed mb-6">
                Experience world-class service with our extensive flight network connecting major cities across Indonesia and international destinations.
            </p>
        </div>

        <!-- Hero Video Section -->
        <div class="video-container mb-12 animate-scale-in">
            <div class="relative pt-[56.25%]"> <!-- 16:9 Aspect Ratio -->
                <video
                    id="routeVideo"
                    class="absolute top-0 left-0 w-full h-full object-cover rounded-2xl"
                    autoplay
                    muted
                    loop
                    playsinline
                    disablePictureInPicture
                    controlsList="nodownload nofullscreen noremoteplaybook"
                >
                    <source src="{{ asset('Rute Pesawat.mp4') }}" type="video/mp4">
                    <div class="absolute inset-0 flex items-center justify-center text-white">
                        <p>Your browser does not support the video tag.</p>
                    </div>
                </video>

                <!-- Video Overlay -->
                <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent pointer-events-none rounded-2xl"></div>

                <!-- Play Button Fallback -->
                <button id="playButton" class="absolute inset-0 flex items-center justify-center bg-black/30 opacity-0 transition-opacity duration-300 hover:opacity-100 hidden">
                    <div class="w-20 h-20 glass-effect rounded-full flex items-center justify-center">
                        <svg class="w-8 h-8 text-white ml-1" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M8 5v14l11-7z"/>
                        </svg>
                    </div>
                </button>

                <!-- Video Info Overlay -->
                <div class="absolute bottom-4 left-4 right-4 text-white">
                    <div class="glass-effect rounded-lg p-4">
                        <h3 class="text-lg font-semibold mb-1">Our Flight Network</h3>
                        <p class="text-sm text-gray-200">Discover our extensive route network connecting you to amazing destinations</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Network Statistics -->
        <div class="mb-12 animate-slide-up">
            <div class="section-divider"></div>
            <h2 class="text-3xl sm:text-4xl font-bold text-center mb-8">
                <span class="hero-title">Our Network at a Glance</span>
            </h2>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div class="group feature-card bg-white/10 backdrop-blur-sm p-8 rounded-2xl text-center border border-white/20">
                    <div class="stats-circle w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 relative">
                        <span class="text-3xl font-bold text-white relative z-10">96</span>
                    </div>
                    <h3 class="group-hover:text-white font-bold text-xl mb-2 text-gray-200 transition-colors">Total Destinations</h3>
                    <p class="text-gray-400 group-hover:text-gray-200 transition-colors">Airports across 12 countries</p>
                    <div class="mt-4 text-garuda-teal text-sm font-semibold">
                        ✈️ Worldwide Coverage
                    </div>
                </div>

                <div class="group feature-card bg-white/10 backdrop-blur-sm p-8 rounded-2xl text-center border border-white/20">
                    <div class="stats-circle w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 relative">
                        <span class="text-3xl font-bold text-white relative z-10">72</span>
                    </div>
                    <h3 class="group-hover:text-white font-bold text-xl mb-2 text-gray-200 transition-colors">Domestic Routes</h3>
                    <p class="text-gray-400 group-hover:text-gray-200 transition-colors">Connecting cities across Indonesia</p>
                    <div class="mt-4 text-garuda-teal text-sm font-semibold">
                        🏝️ Archipelago Network
                    </div>
                </div>

                <div class="group feature-card bg-white/10 backdrop-blur-sm p-8 rounded-2xl text-center border border-white/20">
                    <div class="stats-circle w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 relative">
                        <span class="text-3xl font-bold text-white relative z-10">24</span>
                    </div>
                    <h3 class="group-hover:text-white font-bold text-xl mb-2 text-gray-200 transition-colors">International Routes</h3>
                    <p class="text-gray-400 group-hover:text-gray-200 transition-colors">To Asia, Australia & Europe</p>
                    <div class="mt-4 text-garuda-teal text-sm font-semibold">
                        🌏 Global Connections
                    </div>
                </div>
            </div>
        </div>

        <!-- Popular Routes Section -->
        <div class="mb-12 animate-slide-up">
            <h2 class="text-3xl font-bold text-center mb-8">
                <span class="hero-title">Popular Flight Routes</span>
            </h2>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <!-- Domestic Routes -->
                <div class="feature-card bg-white/10 backdrop-blur-sm p-8 rounded-2xl border border-white/20">
                    <div class="flex items-center mb-6">
                        <div class="w-12 h-12 bg-gradient-to-r from-green-400 to-green-600 rounded-xl flex items-center justify-center mr-4">
                            <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                            </svg>
                        </div>
                        <div>
                            <h3 class="font-bold text-xl text-gray-200">Popular Domestic Routes</h3>
                            <p class="text-gray-400 text-sm">Connecting Indonesian cities</p>
                        </div>
                    </div>
                    <div class="space-y-4">
                        <div class="route-item flex justify-between items-center p-4 glass-effect rounded-xl border border-white/10">
                            <div class="flex items-center">
                                <div class="w-3 h-3 bg-garuda-teal rounded-full mr-3"></div>
                                <span class="text-gray-200 font-medium">Jakarta ↔ Bali (Denpasar)</span>
                            </div>
                            <span class="text-garuda-teal text-sm font-medium bg-garuda-teal/20 px-3 py-1 rounded-full">Daily</span>
                        </div>
                        <div class="route-item flex justify-between items-center p-4 glass-effect rounded-xl border border-white/10">
                            <div class="flex items-center">
                                <div class="w-3 h-3 bg-garuda-teal rounded-full mr-3"></div>
                                <span class="text-gray-200 font-medium">Jakarta ↔ Surabaya</span>
                            </div>
                            <span class="text-garuda-teal text-sm font-medium bg-garuda-teal/20 px-3 py-1 rounded-full">Multiple Daily</span>
                        </div>
                        <div class="route-item flex justify-between items-center p-4 glass-effect rounded-xl border border-white/10">
                            <div class="flex items-center">
                                <div class="w-3 h-3 bg-garuda-teal rounded-full mr-3"></div>
                                <span class="text-gray-200 font-medium">Jakarta ↔ Makassar</span>
                            </div>
                            <span class="text-garuda-teal text-sm font-medium bg-garuda-teal/20 px-3 py-1 rounded-full">Daily</span>
                        </div>
                        <div class="route-item flex justify-between items-center p-4 glass-effect rounded-xl border border-white/10">
                            <div class="flex items-center">
                                <div class="w-3 h-3 bg-garuda-teal rounded-full mr-3"></div>
                                <span class="text-gray-200 font-medium">Jakarta ↔ Medan</span>
                            </div>
                            <span class="text-garuda-teal text-sm font-medium bg-garuda-teal/20 px-3 py-1 rounded-full">Daily</span>
                        </div>
                    </div>
                </div>

                <!-- International Routes -->
                <div class="feature-card bg-white/10 backdrop-blur-sm p-8 rounded-2xl border border-white/20">
                    <div class="flex items-center mb-6">
                        <div class="w-12 h-12 bg-gradient-to-r from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mr-4">
                            <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zM11 19.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
                            </svg>
                        </div>
                        <div>
                            <h3 class="font-bold text-xl text-gray-200">International Routes</h3>
                            <p class="text-gray-400 text-sm">Connecting to the world</p>
                        </div>
                    </div>
                    <div class="space-y-4">
                        <div class="route-item flex justify-between items-center p-4 glass-effect rounded-xl border border-white/10">
                            <div class="flex items-center">
                                <div class="w-3 h-3 bg-garuda-gold rounded-full mr-3"></div>
                                <span class="text-gray-200 font-medium">Jakarta ↔ Singapore</span>
                            </div>
                            <span class="text-garuda-gold text-sm font-medium bg-garuda-gold/20 px-3 py-1 rounded-full">Multiple Daily</span>
                        </div>
                        <div class="route-item flex justify-between items-center p-4 glass-effect rounded-xl border border-white/10">
                            <div class="flex items-center">
                                <div class="w-3 h-3 bg-garuda-gold rounded-full mr-3"></div>
                                <span class="text-gray-200 font-medium">Jakarta ↔ Tokyo</span>
                            </div>
                            <span class="text-garuda-gold text-sm font-medium bg-garuda-gold/20 px-3 py-1 rounded-full">Daily</span>
                        </div>
                        <div class="route-item flex justify-between items-center p-4 glass-effect rounded-xl border border-white/10">
                            <div class="flex items-center">
                                <div class="w-3 h-3 bg-garuda-gold rounded-full mr-3"></div>
                                <span class="text-gray-200 font-medium">Jakarta ↔ Amsterdam</span>
                            </div>
                            <span class="text-garuda-gold text-sm font-medium bg-garuda-gold/20 px-3 py-1 rounded-full">Daily</span>
                        </div>
                        <div class="route-item flex justify-between items-center p-4 glass-effect rounded-xl border border-white/10">
                            <div class="flex items-center">
                                <div class="w-3 h-3 bg-garuda-gold rounded-full mr-3"></div>
                                <span class="text-gray-200 font-medium">Jakarta ↔ Sydney</span>
                            </div>
                            <span class="text-garuda-gold text-sm font-medium bg-garuda-gold/20 px-3 py-1 rounded-full">Daily</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Hub Cities -->
        <div class="mb-12 animate-slide-up">
            <div class="section-divider"></div>
            <h2 class="text-3xl font-bold text-center mb-8">
                <span class="hero-title">Main Hub Cities</span>
            </h2>

            <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
                <div class="hub-card feature-card bg-white/10 backdrop-blur-sm p-6 rounded-2xl text-center border border-white/20">
                    <div class="w-16 h-16 bg-gradient-to-r from-garuda-teal to-cyan-500 rounded-full flex items-center justify-center mx-auto mb-4">
                        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
                        </svg>
                    </div>
                    <h4 class="font-bold text-lg text-gray-200 mb-1">Jakarta</h4>
                    <p class="text-garuda-teal text-sm font-medium">Main Hub</p>
                    <p class="text-gray-400 text-xs mt-1">CGK Airport</p>
                </div>

                <div class="hub-card feature-card bg-white/10 backdrop-blur-sm p-6 rounded-2xl text-center border border-white/20">
                    <div class="w-16 h-16 bg-gradient-to-r from-green-400 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
                        </svg>
                    </div>
                    <h4 class="font-bold text-lg text-gray-200 mb-1">Denpasar</h4>
                    <p class="text-green-400 text-sm font-medium">Tourism Hub</p>
                    <p class="text-gray-400 text-xs mt-1">DPS Airport</p>
                </div>

                <div class="hub-card feature-card bg-white/10 backdrop-blur-sm p-6 rounded-2xl text-center border border-white/20">
                    <div class="w-16 h-16 bg-gradient-to-r from-blue-400 to-indigo-500 rounded-full flex items-center justify-center mx-auto mb-4">
                        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
                        </svg>
                    </div>
                    <h4 class="font-bold text-lg text-gray-200 mb-1">Makassar</h4>
                    <p class="text-blue-400 text-sm font-medium">Eastern Hub</p>
                    <p class="text-gray-400 text-xs mt-1">UPG Airport</p>
                </div>

                <div class="hub-card feature-card bg-white/10 backdrop-blur-sm p-6 rounded-2xl text-center border border-white/20">
                    <div class="w-16 h-16 bg-gradient-to-r from-purple-400 to-pink-500 rounded-full flex items-center justify-center mx-auto mb-4">
                        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
                        </svg>
                    </div>
                    <h4 class="font-bold text-lg text-gray-200 mb-1">Medan</h4>
                    <p class="text-purple-400 text-sm font-medium">Northern Hub</p>
                    <p class="text-gray-400 text-xs mt-1">KNO Airport</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('styles')
<style>
    .gradient-bg {
        background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #334155 100%);
    }

    .glass-effect {
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
    }

    .feature-card {
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        overflow: hidden;
    }

    .feature-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
        transition: left 0.6s;
    }

    .feature-card:hover::before {
        left: 100%;
    }

    .feature-card:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        background: linear-gradient(135deg, #14b8a6, #0891b2);
    }

    .route-item {
        transition: all 0.3s ease;
    }

    .route-item:hover {
        background: rgba(20, 184, 166, 0.1);
        transform: translateX(8px);
    }

    .video-container {
        position: relative;
        overflow: hidden;
        border-radius: 1rem;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
    }

    .hero-title {
        background: linear-gradient(135deg, #f8fafc, #14b8a6);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }

    .stats-circle {
        background: linear-gradient(135deg, #3b82f6, #1d4ed8);
        position: relative;
        overflow: hidden;
    }

    .stats-circle::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 80%;
        height: 80%;
        background: rgba(255,255,255,0.1);
        border-radius: 50%;
        transform: translate(-50%, -50%);
    }

    .hub-card {
        transition: all 0.3s ease;
        cursor: pointer;
    }

    .hub-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(20, 184, 166, 0.3);
    }

    .section-divider {
        height: 2px;
        background: linear-gradient(90deg, transparent, #14b8a6, transparent);
        margin: 2rem 0;
    }

    @keyframes float {
        0%, 100% { transform: translateY(0px); }
        50% { transform: translateY(-10px); }
    }

    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(50px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }

    @keyframes scaleIn {
        from {
            opacity: 0;
            transform: scale(0.9);
        }
        to {
            opacity: 1;
            transform: scale(1);
        }
    }

    .animate-float {
        animation: float 3s ease-in-out infinite;
    }

    .animate-slide-up {
        animation: slideUp 0.8s ease-out;
    }

    .animate-fade-in {
        animation: fadeIn 1s ease-out;
    }

    .animate-scale-in {
        animation: scaleIn 0.6s ease-out;
    }

    :root {
        --garuda-blue: #1e40af;
        --garuda-teal: #14b8a6;
        --garuda-gold: #f59e0b;
    }

    @media (max-width: 768px) {
        .hero-title {
            font-size: 2rem;
            line-height: 1.2;
        }

        .feature-card {
            margin-bottom: 1rem;
        }

        .stats-circle {
            width: 4rem;
            height: 4rem;
        }

        .stats-circle span {
            font-size: 1.5rem;
        }
    }
</style>
@endpush

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Enhanced video controls
        const video = document.getElementById('routeVideo');
        const playButton = document.getElementById('playButton');

        if (video && playButton) {
            // Show play button if video fails to autoplay
            video.addEventListener('loadstart', function() {
                setTimeout(() => {
                    if (video.paused) {
                        playButton.classList.remove('hidden');
                    }
                }, 1000);
            });

            // Handle play button click
            playButton.addEventListener('click', function() {
                if (video.paused) {
                    video.play();
                    playButton.classList.add('hidden');
                } else {
                    video.pause();
                    playButton.classList.remove('hidden');
                }
            });

            // Hide play button when video starts playing
            video.addEventListener('play', function() {
                playButton.classList.add('hidden');
            });

            // Show play button when video is paused
            video.addEventListener('pause', function() {
                playButton.classList.remove('hidden');
            });
        }

        // Smooth scrolling for better UX
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, {
            threshold: 0.1
        });

        // Observe all animated elements
        document.querySelectorAll('.animate-slide-up, .animate-fade-in, .animate-scale-in').forEach(el => {
            el.style.opacity = '0';
            el.style.transform = 'translateY(30px)';
            el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(el);
        });

        // Add loading state for better performance
        window.addEventListener('load', function() {
            document.body.classList.add('loaded');
        });
    });
</script>
<script src="{{ asset('js/route.js') }}"></script>
@endpush
