{{-- @extends('layouts.app', ['title' => 'Catalog'])

@section('content')
<div class="bg-gradient-to-r from-teal-500 to-blue-500 text-white py-3 px-4 text-center relative overflow-hidden">
    <div class="absolute inset-0 bg-black/10"></div>
    <div class="relative z-10 flex items-center justify-center space-x-2">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 animate-pulse" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
        </svg>
        <span class="font-medium text-sm md:text-base">
            This is a Display Version Only - Visit
            <a href="https://garudashop.garuda-indonesia.com/" target="_blank" rel="noopener" class="underline hover:no-underline font-bold">
                garudashop.com
            </a>
            for the Official Website
        </span>
    </div>
</div>
<div class="min-h-screen">
    <!-- Hero Swiper Section -->
    <div class="relative overflow-hidden">
        <div class="swiper hero-swiper h-[70vh] md:h-[80vh]">
            <div class="swiper-wrapper">
                @foreach($products as $index => $product)
                <div class="swiper-slide relative">
                    <!-- Background Image with Overlay -->
                    <div class="absolute inset-0">
                        <img
                            src="{{ asset($product['path']) }}"
                            alt="{{ $product['name'] }}"
                            class="w-full h-full object-cover"
                        >
                        <div class="absolute inset-0 bg-gradient-to-r from-black/60 via-black/40 to-transparent"></div>
                    </div>

                    <!-- Content Overlay -->
                    <div class="relative z-10 h-full flex items-center">
                        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
                            <div class="max-w-2xl">
                                <!-- Logo -->
                                <div class="flex items-center mb-6">
                                    <img src="{{ asset('Logo-Garuda-Animasi.gif') }}" alt="Logo" class="h-12 md:h-16 w-auto mr-4">
                                    <div class="text-white">
                                        <h1 class="text-2xl md:text-3xl font-bold">GarudaShop</h1>
                                        <p class="text-sm md:text-base opacity-90">Premium In-Flight Shopping</p>
                                    </div>
                                </div>

                                <!-- Product Info -->
                                <div class="glass-effect rounded-2xl p-6 md:p-8">
                                    <span class="inline-block bg-teal-500 text-white text-xs md:text-sm px-3 py-1 rounded-full font-medium mb-4">
                                        Featured Product #{{ $index + 1 }}
                                    </span>
                                    <h2 class="text-3xl md:text-5xl font-bold text-white mb-4">
                                        {{ ucwords(str_replace(['_', '-'], ' ', $product['name'])) }}
                                    </h2>
                                    <p class="text-lg md:text-xl text-white/90 mb-6">
                                        Airplane Shopping Can Now Be Purchased Online
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>

            <!-- Pagination -->
            <div class="swiper-pagination !bottom-8"></div>
        </div>
    </div>

    <!-- Search Section -->
    <div class="bg-gradient-to-r from-teal-600 to-blue-600 py-8">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-6">
                <h3 class="text-2xl font-bold text-white mb-2">Find Your Perfect Product</h3>
                <p class="text-white/90">Search through our premium collection</p>
            </div>

            <!-- Enhanced Search Bar -->
            <div class="max-w-2xl mx-auto">
                <div class="relative">
                    <input
                        type="text"
                        placeholder="Search products, brands, categories..."
                        class="w-full py-4 px-6 pr-16 rounded-2xl border-0 focus:ring-4 focus:ring-white/30 text-gray-800 bg-white/95 backdrop-blur-sm text-lg shadow-xl"
                        autofocus
                    >
                    <button class="absolute right-3 top-1/2 transform -translate-y-1/2 bg-teal-600 hover:bg-teal-700 text-white p-3 rounded-xl transition-all hover:scale-105">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Product Categories Swiper -->
    <div class="py-12 bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-8">
                <h3 class="text-3xl font-bold text-gray-900 mb-4">Featured Products</h3>
                <p class="text-gray-600 max-w-2xl mx-auto">Discover our curated selection of premium products available during your flight</p>
            </div>

            <div class="swiper categories-swiper">
                <div class="swiper-wrapper">
                    @foreach(array_slice($products, 0, 8) as $product)
                    <div class="swiper-slide">
                        <div class="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-all duration-300 group cursor-pointer">
                            <div class="aspect-square relative overflow-hidden">
                                <img
                                    src="{{ asset($product['path']) }}"
                                    alt="{{ $product['name'] }}"
                                    class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                                >
                                <div class="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                                <div class="absolute bottom-4 left-4 right-4 transform translate-y-4 group-hover:translate-y-0 transition-transform duration-300">
                                    <h4 class="text-white font-semibold text-lg line-clamp-2">
                                        {{ ucwords(str_replace(['_', '-'], ' ', $product['name'])) }}
                                    </h4>
                                </div>
                            </div>
                        </div>
                    </div>
                    @endforeach
                </div>
            </div>
        </div>
    </div>

    <!-- Main Product Grid Section -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <!-- Section Header -->
        <div class="text-center mb-12">
            <h2 class="text-4xl font-bold text-gray-700 mb-4">All Products</h2>
            <p class="text-gray-700 max-w-2xl mx-auto">Browse our complete collection of premium in-flight shopping items</p>
        </div>

        <!-- Filters -->
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
            <div class="text-sm text-gray-600 bg-white shadow-md px-4 py-2 rounded-lg border">
                Showing <span class="font-medium text-teal-600">{{ count($products ?? []) }}</span> products
            </div>

            <div class="flex items-center space-x-4">
                <div class="flex items-center bg-white shadow-md rounded-lg px-4 py-2 border">
                    <label for="sort" class="mr-2 text-sm font-medium text-gray-700">Sort by:</label>
                    <select id="sort" class="bg-transparent text-gray-700 border-0 focus:outline-none text-sm">
                        <option>Most Popular</option>
                        <option>Newest</option>
                        <option>Name A-Z</option>
                        <option>Name Z-A</option>
                    </select>
                </div>

                <button class="p-2 rounded-lg bg-white shadow-md hover:shadow-lg transition-all border hover:border-teal-300">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
                    </svg>
                </button>
            </div>
        </div>

        <!-- Product Grid -->
        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6">
            @forelse ($products as $product)
                <!-- Product Card -->
                <div class="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl hover:scale-105 transition-all duration-300 group cursor-pointer border border-gray-100">
                    <div class="relative aspect-square">
                        <img
                            src="{{ asset($product['path']) }}"
                            alt="{{ $product['name'] }}"
                            class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                            loading="lazy"
                        >

                        <!-- Overlay pada hover -->
                        <div class="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>

                        <!-- Product name overlay -->
                        <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-3 translate-y-full group-hover:translate-y-0 transition-transform duration-300">
                            <h3 class="text-white text-sm font-medium truncate">{{ ucwords(str_replace(['_', '-'], ' ', $product['name'])) }}</h3>
                        </div>

                        <!-- Favorite button -->
                        <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                            <button class="bg-white/90 backdrop-blur-sm p-2 rounded-full hover:bg-white hover:scale-110 transition-all">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            @empty
                <div class="col-span-full text-center py-12">
                    <div class="bg-gray-50 rounded-2xl p-8 max-w-md mx-auto border border-gray-200">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-gray-400 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                        </svg>
                        <h3 class="text-gray-600 text-lg font-medium mb-2">No Products Found</h3>
                        <p class="text-gray-500 text-sm">Please add some product images to the public/media/products folder.</p>
                    </div>
                </div>
            @endforelse
        </div>

        @if(count($products ?? []) > 0)
        <!-- Load More Button -->
        <div class="mt-12 flex justify-center">
            <button class="bg-gradient-to-r from-teal-600 to-blue-600 hover:from-teal-700 hover:to-blue-700 text-white px-8 py-4 rounded-xl font-medium transition-all transform hover:scale-105 shadow-lg">
                View All Products ({{ count($products ?? []) }})
            </button>
        </div>
        @endif
    </div>

</div>

<!-- Custom CSS and Swiper Initialization -->
<style>
    /* Swiper Custom Styling */
    .hero-swiper .swiper-pagination-bullet {
        width: 12px;
        height: 12px;
        background: rgba(255, 255, 255, 0.5);
        opacity: 1;
    }

    .hero-swiper .swiper-pagination-bullet-active {
        background: white;
        transform: scale(1.2);
    }

    .hero-swiper .swiper-button-next,
    .hero-swiper .swiper-button-prev {
        background: rgba(255, 255, 255, 0.2);
        border-radius: 50%;
        width: 50px;
        height: 50px;
    }

    .hero-swiper .swiper-button-next:hover,
    .hero-swiper .swiper-button-prev:hover {
        background: rgba(255, 255, 255, 0.3);
    }

    .categories-swiper .swiper-slide {
        width: 280px;
        height: auto;
    }

    .glass-effect {
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        background: rgba(0, 0, 0, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.1);
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    }

    .line-clamp-2 {
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .aspect-square {
        aspect-ratio: 1 / 1;
    }

    /* Custom select styling */
    select {
        appearance: none;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='m6 8 4 4 4-4'/%3e%3c/svg%3e");
        background-position: right 0.5rem center;
        background-repeat: no-repeat;
        background-size: 1.5em 1.5em;
        padding-right: 2.5rem;
    }

    /* Smooth scrolling */
    html {
        scroll-behavior: smooth;
    }
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Hero Swiper
    const heroSwiper = new Swiper('.hero-swiper', {
        loop: true,
        autoplay: {
            delay: 5000,
            disableOnInteraction: false,
        },
        effect: 'fade',
        fadeEffect: {
            crossFade: true
        },
        pagination: {
            el: '.swiper-pagination',
            clickable: true,
        },
        navigation: {
            nextEl: '.swiper-button-next',
            prevEl: '.swiper-button-prev',
        },
    });

    // Categories Swiper
    const categoriesSwiper = new Swiper('.categories-swiper', {
        slidesPerView: 'auto',
        spaceBetween: 20,
        freeMode: true,
        grabCursor: true,
        breakpoints: {
            640: {
                slidesPerView: 2,
                spaceBetween: 20,
            },
            768: {
                slidesPerView: 3,
                spaceBetween: 24,
            },
            1024: {
                slidesPerView: 4,
                spaceBetween: 24,
            },
            1280: {
                slidesPerView: 5,
                spaceBetween: 24,
            },
        }
    });
});
</script>

@endsection --}}
