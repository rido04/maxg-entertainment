@extends('layouts.app', ['title' => 'About Garuda Indonesia'])

@section('content')
<div class="min-h-screen text-gray-700 relative overflow-hidden about-page" style="background-image: url('{{ asset('images/background/BG7.jpg') }}'); background-size: cover; background-position: center;">
    <!-- Background Elements -->
    <div class="absolute inset-0">
        <div class="absolute top-20 right-20 w-64 h-64 bg-blue-600/10 rounded-full blur-3xl"></div>
        <div class="absolute bottom-20 left-20 w-96 h-96 bg-blue-500/5 rounded-full blur-3xl"></div>
    </div>

    <div class="relative max-w-6xl mx-auto px-8 py-20">
        <!-- Header Section -->
        <div class="text-center mb-1">
            <div class="inline-flex items-center justify-center mb-10">
                <img src="{{ asset('Logo-Garuda-Color-Gift.gif') }}" alt="Logo Garuda" class="w-[500px] object-contain">
            </div>
        </div>

        <!-- Main Swiper Container -->
        <div class="swiper aboutSwiper mb-0 mt-12">
            <div class="swiper-wrapper">

                <!-- Slide 1: Direktur Utama -->
                <div class="swiper-slide">
                    <div class="p-8">
                        <div class="flex flex-col lg:flex-row items-center gap-8">
                            <!-- Bio Section -->
                            <div class="flex-1">
                                <h2 class="text-right text-lg font-medium text-gray-700 mb-6">President Director Profile</h2>
                                <div class="text-gray-700 leading-relaxed space-y-4">
                                    <p>
                                        <span class="text-blue-500">Wamildan Tsani Panjaitan</span> is the President Director of Garuda Indonesia who has extensive experience in the aviation industry. He led the transformation of Garuda Indonesia into a world-class airline with 5-star service standards.
                                    </p>
                                    <p>
                                        With a strong vision to make Garuda Indonesia the pride of Indonesia, he focuses on technological innovation, improving service quality, and expanding international flight routes.
                                    </p>
                                    <p>
                                        Under his leadership, Garuda Indonesia continues to maintain its reputation as a national airline that elevates Indonesia's image in the international arena through operational excellence and Indonesian hospitality.
                                    </p>
                                </div>
                            </div>
                            <!-- Photo Section -->
                            <div class="flex-shrink-0">
                                <div class="w-64 h-64 overflow-hidden ml-5">
                                    <img src="{{ asset('wamildan-tsani-panjaitan.png') }}"
                                            alt="Wamildan Tsani Panjaitan"
                                            class="w-full h-full object-cover object-top">
                                </div>
                                <div class="text-center mt-4">
                                    <h3 class="text-xl font-medium text-gray-700 mb-1">Wamildan Tsani Panjaitan</h3>
                                    <p class="text-gray-700 font-normal">President Director of Garuda Indonesia</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Slide 2: Image/GIF Placeholder -->
                <div class="swiper-slide">
                    <div class="bg-[#002859] rounded-3xl p-8 border border-white/10">
                        <div class="text-center">
                            <div class="flex justify-center items-center">
                                <div class="w-full max-w-4xl h-96 flex items-center justify-center">
                                    <!-- Placeholder for Image/GIF -->
                                    <div class="text-center">
                                    </div>
                                    <video preload="auto" autoplay loop muted playsinline>
                                        <source src="{{ asset('OurFleet Garuda_3 (1).mp4') }}" type="video/mp4">
                                        <source src="OurFleet.webm" type="video/webm">
                                        <!-- Fallback ke GIF jika video tidak support -->
                                        <img src="OurFleet.gif" alt="Fallback" class="w-full h-full object-cover">
                                      </video>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Slide 3: Horizontal Scrollable Container -->
                <div class="swiper-slide">
                    <div class="p-8">
                        <div class="text-center mb-8">
                            <p class="text-gray-700 text-xl font-light">Subsidiaries and Business Divisions</p>
                        </div>

                        <!-- Horizontal Scrollable container -->
                        <div class="scroll-container relative">
                            <div class="overflow-x-auto horizontal-scroll pb-4">
                                <div class="flex gap-6 min-w-max px-4">
                                    @foreach($subsidiariesChunks as $chunk)
                                        @foreach($chunk as $subsidiary)
                                        <div class="flex-shrink-0 w-80 relative rounded-2xl overflow-hidden transition-all duration-300 subsidiary-card">
                                            <!-- Background image -->
                                            <img src="{{ asset('images/background/rectangle.png') }}" alt="blur background"
                                                class="absolute inset-0 w-full h-full object-cover z-0">

                                            <!-- Content -->
                                            <div class="relative z-10 p-6 text-center text-gray-800 h-full">
                                                <div class="mb-4">
                                                    <div class="w-24 h-24 mx-auto flex items-center justify-center mb-4">
                                                        <img src="{{ asset($subsidiary['logo']) }}"
                                                            alt="logo {{ strtolower($subsidiary['name']) }}"
                                                            class="w-20 h-20 object-contain image-glow">
                                                    </div>
                                                    <h3 class="text-gray-800 font-bold text-lg mb-3">{{ $subsidiary['name'] }}</h3>
                                                </div>
                                                <p class="text-gray-700 text-sm leading-relaxed">
                                                    {{ $subsidiary['description'] }}
                                                </p>
                                            </div>
                                        </div>
                                        @endforeach
                                    @endforeach
                                </div>
                            </div>
                        </div>

                        <!-- Scroll hint -->
                        <div class="text-center mt-4">
                            <p class="text-gray-500 text-xs">← Scroll horizontally to see more →</p>
                        </div>
                    </div>
                </div>
        </div>
        <!-- Main Navigation -->
        <div class="swiper-button-next main-next"></div>
        <div class="swiper-button-prev main-prev"></div>
    </div>
</div>

@push('styles')
<link rel="stylesheet" href="{{ asset('css/about.css') }}">
<style>
/* Custom Glow Effects for Images */
.image-glow:hover {
    filter: drop-shadow(0 0 20px rgba(59, 130, 246, 0.5));
    transform: scale(1.05);
}

/* Nested Swiper Pagination Styling */
.subsidiary-pagination .swiper-pagination-bullet {
    background: #3b82f6;
    opacity: 0.3;
}

.subsidiary-pagination .swiper-pagination-bullet-active {
    opacity: 1;
    background: #1d4ed8;
}

/* Nested Swiper Navigation Styling */
.subsidiary-next,
.subsidiary-prev {
    background: rgba(59, 130, 246, 0.1);
    border-radius: 50%;
    width: 40px !important;
    height: 40px !important;
    margin-top: -20px !important;
}

.subsidiary-next:hover,
.subsidiary-prev:hover {
    background: rgba(59, 130, 246, 0.2);
}
</style>
@endpush

@push('scripts')
<script src="{{ asset('js/about.js') }}"></script>
@endpush
@endsection
