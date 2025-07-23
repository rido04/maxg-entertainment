@extends('layouts.app', ['title' => 'Catalog'])

@section('content')
<!-- Navbar with Search Bar -->
<div class="sticky top-0 z-50 bg-gradient-to-r from-teal-500 to-blue-500 text-white shadow-lg backdrop-blur-md transition-all duration-300" id="navbar">
    <div class="absolute inset-0 bg-black/10"></div>
    <div class="relative z-10">
        <!-- Top Row: Logo and Display Message -->
        <div class="flex items-center justify-between px-4 py-3 border-b border-white/10">
            <div class="flex items-center space-x-4">
                <!-- Logo -->
                <div class="flex items-center space-x-2">
                    <img src="{{ asset('Logo-Garuda-Animasi.gif') }}" alt="Logo" class="h-8 w-auto object-cover transition-all duration-300" id="navbar-logo">
                    <span class="font-bold text-lg hidden md:block">GarudaShop</span>
                </div>

                <!-- Display Message -->
                <div class="hidden lg:flex items-center space-x-2">
                    <span class="font-medium text-sm">
                        Display Version - Visit
                        <a href="https://garudashop.garuda-indonesia.com/" target="_blank" rel="noopener" class="underline hover:no-underline font-bold transition-all hover:text-yellow-200">
                            www.garudashop.com
                        </a>
                        for Official Website
                    </span>
                </div>
            </div>

            <!-- Mobile Menu Button -->
            <button class="lg:hidden p-2 rounded-lg hover:bg-white/10 transition-colors" id="mobile-menu-btn">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                </svg>
            </button>
        </div>



        <!-- Mobile Menu -->
        <div class="lg:hidden hidden bg-white/10 backdrop-blur-sm border-t border-white/10" id="mobile-menu">
            <div class="px-4 py-3 space-y-2">
                <!-- Search Bar Row -->
                <div class="px-4 py-3">
                    <div class="max-w-4xl mx-auto">
                        <form method="GET" action="{{ route('products.index') }}" class="relative">
                            <input
                                type="text"
                                name="search"
                                value="{{ request('search') }}"
                                placeholder="Search products, brands, etc..."
                                class="w-full py-3 px-6 pr-16 rounded-full border-0 focus:ring-4 focus:ring-white/30 text-gray-800 bg-white/95 backdrop-blur-sm text-base shadow-xl transition-all duration-300 focus:shadow-2xl"
                                autofocus
                            >
                            <button type="submit" class="absolute right-2 top-1/2 transform -translate-y-1/2 bg-teal-600 hover:bg-teal-700 text-white p-2.5 rounded-full transition-all hover:scale-105 shadow-lg">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                </svg>
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Mobile Display Message -->
                <div class="pt-2 border-t border-white/10">
                    <span class="text-xs text-white/80">
                        Display Version - Visit
                        <a href="https://garudashop.garuda-indonesia.com/" target="_blank" rel="noopener" class="underline hover:no-underline font-bold">
                            www.garudashop.com
                        </a>
                    </span>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="min-h-screen bg-gray-50">
    <!-- Hero Banner Grid Section -->
    @if(count($banners) > 0)
    <div class="relative mx-[20px] sm:mx-[30px] md:mx-[40px] lg:mx-[51px] rounded-xl">
        <div class="grid grid-cols-3 gap-2 sm:gap-3 min-h-[70vh] sm:min-h-[70vh] md:min-h-[70vh] lg:min-h-[70vh] w-auto">
   <!-- Main Banner (Left Side - 2 columns) -->
            <div class="col-span-2 relative rounded-xl overflow-hidden mt-2 sm:mt-3 md:mt-4 lg:mt-5">
                <div class="h-full">
                    <div class="swiper-wrapper">
                        @foreach($banners as $index => $banner)
                        @php
                            $fixedPath = ltrim($banner['path'], '/storage/');
                            $fixedPath = str_starts_with($fixedPath, 'banners/') ? $fixedPath : 'banners/' . $fixedPath;
                        @endphp
                        <div class="swiper-slide relative">
                            <!-- Background Image with Better Overlay -->
                            <div class="absolute inset-0">
                                <img
                                    src="{{ asset('storage/' . $fixedPath) }}" alt="{{ $banner['name'] }}"
                                    alt="{{ $banner['name'] }}"
                                    class="w-full h-full object-cover transition-transform duration-700 hover:scale-105"
                                    loading="{{ $index === 0 ? 'eager' : 'lazy' }}"
                                >
                                <div class="absolute inset-0 bg-gradient-to-r from-black/60 via-black/30 to-transparent"></div>
                            </div>

                            <!-- Content Overlay - More Compact -->
                            <div class="relative z-10 h-full flex items-center justify-start p-3 sm:p-4 md:p-6 lg:p-8">
                                <div class="text-left text-white max-w-xs sm:max-w-sm md:max-w-md">
                                    <h2 class="text-sm sm:text-lg md:text-2xl lg:text-4xl xl:text-5xl font-bold mb-1 sm:mb-2 md:mb-3 leading-tight tracking-tight">
                                        {{ $banner['title'] ?? ucwords(str_replace(['_', '-'], ' ', $banner['name'])) }}
                                    </h2>
                                    <p class="text-xs sm:text-sm md:text-base lg:text-lg mb-2 sm:mb-3 md:mb-4 text-white/90 line-clamp-2">
                                        {{ $banner['subtitle'] ?? 'Discover premium products at unbeatable prices' }}
                                    </p>
                                    @if(!empty($banner['link_url']))
                                        <a href="{{ $banner['link_url'] }}"
                                        class="inline-flex items-center bg-white text-gray-800 px-3 py-1.5 sm:px-4 sm:py-2 md:px-6 md:py-2.5 lg:px-8 lg:py-3 rounded-full font-semibold text-xs sm:text-sm md:text-base hover:bg-gray-100 transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl">
                                            {{ $banner['button_text'] ?? 'Shop Now' }}
                                            <svg class="w-3 h-3 sm:w-4 sm:h-4 ml-1 sm:ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                            </svg>
                                        </button>
                                    @endif
                                </div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                </div>
            </div>

            <!-- Side Banners (Right Side - 1 column, 2 rows) -->
            <div class="col-span-1 flex flex-col gap-2 sm:gap-3 mt-2 sm:mt-3 md:mt-4 lg:mt-5">

                @php
                $topSideBanner = $banners->where('position', 'side_top')->first();
                $bottomSideBanner = $banners->where('position', 'side_bottom')->first();
                @endphp

                <!-- Top Side Banner -->
                @if($topSideBanner)
                <div class="flex-1 relative rounded-xl overflow-hidden group cursor-pointer transform transition-all duration-300 hover:scale-[1.02] hover:shadow-xl">
                    @if(!empty($topSideBanner['link_url']))
                        <a href="{{ $topSideBanner['link_url'] }}" class="block h-full">
                    @endif

                    <div class="absolute inset-0">
                        <img
                            src="{{ $topSideBanner['path'] }}"
                            alt="{{ $topSideBanner['title'] ?? $topSideBanner['name'] }}"
                            class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                            loading="lazy"
                        >
                        <div class="absolute inset-0 bg-gradient-to-b from-black/40 via-transparent to-black/60 group-hover:from-black/50 group-hover:to-black/70 transition-all duration-300"></div>
                    </div>

                    <div class="relative z-10 h-full flex items-end justify-center p-2 sm:p-3 md:p-4">
                        <div class="text-center text-white">
                            <h3 class="text-xs sm:text-sm md:text-lg lg:text-xl font-bold mb-0.5 sm:mb-1 leading-tight">
                                {{ $topSideBanner['title'] ?? ucwords(str_replace(['_', '-'], ' ', $topSideBanner['name'])) }}
                            </h3>
                            <p class="text-xs sm:text-xs md:text-sm text-white/80">{{ $topSideBanner['subtitle'] ?? 'Special Collection' }}</p>
                        </div>
                    </div>

                    @if(!empty($topSideBanner['link_url']))
                        </a>
                    @endif
                </div>
                @endif

                <!-- Bottom Side Banner -->
                @if($bottomSideBanner)
                <div class="flex-1 relative rounded-xl overflow-hidden group cursor-pointer transform transition-all duration-300 hover:scale-[1.02] hover:shadow-xl">
                    @if(!empty($bottomSideBanner['link_url']))
                        <a href="{{ $bottomSideBanner['link_url'] }}" class="block h-full">
                    @endif

                    <div class="absolute inset-0">
                        <img
                            src="{{ $bottomSideBanner['path'] }}"
                            alt="{{ $bottomSideBanner['title'] ?? $bottomSideBanner['name'] }}"
                            class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                            loading="lazy"
                        >
                        <div class="absolute inset-0 bg-gradient-to-b from-black/40 via-transparent to-black/60 group-hover:from-black/50 group-hover:to-black/70 transition-all duration-300"></div>
                    </div>

                    <div class="relative z-10 h-full flex items-end justify-center p-2 sm:p-3 md:p-4">
                        <div class="text-center text-white">
                            <h3 class="text-xs sm:text-sm md:text-lg lg:text-xl font-bold mb-0.5 sm:mb-1 leading-tight">
                                {{ $bottomSideBanner['title'] ?? ucwords(str_replace(['_', '-'], ' ', $bottomSideBanner['name'])) }}
                            </h3>
                            <p class="text-xs sm:text-xs md:text-sm text-white/80">{{ $bottomSideBanner['subtitle'] ?? 'New Arrivals' }}</p>
                        </div>
                    </div>

                    @if(!empty($bottomSideBanner['link_url']))
                        </a>
                    @endif
                </div>
                @elseif(count($banners) > 1)
                <!-- Fallback Banner -->
                <div class="flex-1 relative rounded-xl overflow-hidden group cursor-pointer transform transition-all duration-300 hover:scale-[1.02] hover:shadow-xl">
                    <div class="absolute inset-0">
                        <img
                            src="{{ asset($banners[1]['path']) }}"
                            alt="{{ $banners[1]['name'] }}"
                            class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                            loading="lazy"
                        >
                        <div class="absolute inset-0 bg-gradient-to-b from-black/40 via-transparent to-black/60 group-hover:from-black/50 group-hover:to-black/70 transition-all duration-300"></div>
                    </div>

                    <div class="relative z-10 h-full flex items-end justify-center p-2 sm:p-3 md:p-4">
                        <div class="text-center text-white">
                            <h3 class="text-xs sm:text-sm md:text-lg lg:text-xl font-bold mb-0.5 sm:mb-1 leading-tight">
                                {{ ucwords(str_replace(['_', '-'], ' ', $banners[1]['name'])) }}
                            </h3>
                            <p class="text-xs sm:text-xs md:text-sm text-white/80">New Arrivals</p>
                        </div>
                    </div>
                </div>
                @else
                <!-- Gradient Fallback -->
                <div class="flex-1 relative rounded-xl overflow-hidden bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 group cursor-pointer transform transition-all duration-300 hover:scale-[1.02] hover:shadow-xl">
                    <div class="absolute inset-0 bg-gradient-to-b from-transparent to-black/30"></div>
                    <div class="relative z-10 h-full flex items-end justify-center p-2 sm:p-3 md:p-4">
                        <div class="text-center text-white">
                            <h3 class="text-xs sm:text-sm md:text-lg lg:text-xl font-bold mb-0.5 sm:mb-1">New Arrivals</h3>
                            <p class="text-xs sm:text-xs md:text-sm text-white/80">Fresh Collections</p>
                        </div>
                    </div>
                </div>
                @endif

            </div>
        </div>
    </div>
    @endif

    <!-- Enhanced Category Filter Section -->
    <div class="bg-gray-50">
        <div class="max-w-full mx-auto sm:px-6">
            <!-- Section Title -->
            <div class="text-center mb-6">
                <!-- Filter Tags Container with Search Bar -->
                <div class="p-6">
                    <!-- Main container with flex layout -->
                    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">

                        <div class="flex-1">
                            <div class="flex flex-wrap justify-center lg:justify-start gap-3" id="filterTags">
                                <!-- All Products Button -->
                                <a href="{{ route('products.index') }}"
                                class="enhanced-filter-btn {{ !request('category') ? 'active' : '' }}">
                                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                                    </svg>
                                    All Products
                                </a>

                                <!-- Category Buttons with Random Colors -->
                                    @php
                                    $colors = [
                                        // Dari gelap ke terang - Garuda Indonesia theme
                                        ['bg' => '#2563eb', 'hover' => '#3b82f6'],  // Blue (medium terang)
                                        ['bg' => '#BE123C', 'hover' => '#9F1239'],  // Garuda Red (gelap)
                                        ['bg' => '#0e8f75', 'hover' => '#1bcca9'],  // Navy (gelap)
                                        ['bg' => '#0324fc', 'hover' => '#021AA3'],  // Garuda Blue (gelap)
                                        ['bg' => '#7c2d12', 'hover' => '#92400e'],  // Brown (gelap)
                                        ['bg' => '#9f1239', 'hover' => '#be123c'],  // Rose (medium gelap)
                                        ['bg' => '#ea580c', 'hover' => '#f97316'],  // Orange (medium)
                                        ['bg' => '#0f590d', 'hover' => '#3556C1'],  // Royal Blue (medium)
                                        ['bg' => '#dc2626', 'hover' => '#ef4444'],  // Red (medium terang)
                                        ['bg' => '#a16207', 'hover' => '#ca8a04'],  // Amber (medium terang)
                                        ['bg' => '#0f590d', 'hover' => '#0f590d'],  // Light Blue (terang)
                                        ['bg' => '#0d9488', 'hover' => '#14b8a6'],  // Teal (terang)
                                        ['bg' => '#7c3aed', 'hover' => '#8b5cf6'],  // Violet (terang)
                                        ['bg' => '#059669', 'hover' => '#10b981']   // Green (terang)
                                    ];
                                    @endphp

                                    @foreach($categories as $index => $category)
                                    @php
                                    $colorIndex = $index % count($colors);
                                    $color = $colors[$colorIndex];
                                    $isActive = request('category') == $category['slug'];
                                    @endphp

                                    <a href="{{ route('products.index', ['category' => $category['slug']]) }}"
                                    class="enhanced-filter-btn category-btn-{{ $colorIndex }} {{ $isActive ? 'active' : '' }}"
                                    style="
                                    --btn-bg: {{ $color['bg'] }};
                                    --btn-hover: {{ $color['hover'] }};
                                    background: {{ $isActive ? 'linear-gradient(135deg, ' . $color['bg'] . ' 0%, ' . $color['hover'] . ' 100%) !important' : $color['bg'] . ' !important' }};
                                    color: white !important;
                                    border-color: {{ $color['bg'] }} !important;
                                    {{ $isActive ? 'box-shadow: 0 6px 16px rgba(' . hexdec(substr($color['bg'], 1, 2)) . ',' . hexdec(substr($color['bg'], 3, 2)) . ',' . hexdec(substr($color['bg'], 5, 2)) . ', 0.4) !important;' : 'box-shadow: 0 3px 8px rgba(' . hexdec(substr($color['bg'], 1, 2)) . ',' . hexdec(substr($color['bg'], 3, 2)) . ',' . hexdec(substr($color['bg'], 5, 2)) . ', 0.3);' }}
                                    "
                                    onmouseover="
                                    this.style.background='linear-gradient(135deg, {{ $color['bg'] }} 0%, {{ $color['hover'] }} 100%) !important';
                                    this.style.transform='translateY(-3px) scale(1.02)';
                                    this.style.boxShadow='0 8px 20px rgba({{ hexdec(substr($color['bg'], 1, 2)) }}, {{ hexdec(substr($color['bg'], 3, 2)) }}, {{ hexdec(substr($color['bg'], 5, 2)) }}, 0.4)';
                                    "
                                    onmouseout="
                                    this.style.background='{{ $isActive ? 'linear-gradient(135deg, ' . $color['bg'] . ' 0%, ' . $color['hover'] . ' 100%)' : $color['bg'] }} !important';
                                    this.style.transform='translateY(0) scale(1)';
                                    this.style.boxShadow='{{ $isActive ? '0 6px 16px rgba(' . hexdec(substr($color['bg'], 1, 2)) . ',' . hexdec(substr($color['bg'], 3, 2)) . ',' . hexdec(substr($color['bg'], 5, 2)) . ', 0.4)' : '0 3px 8px rgba(' . hexdec(substr($color['bg'], 1, 2)) . ',' . hexdec(substr($color['bg'], 3, 2)) . ',' . hexdec(substr($color['bg'], 5, 2)) . ', 0.3)' }}';
                                    ">
                                    <!-- Dynamic icon based on category -->
                                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
                                    </svg>
                                    {{ $category['name'] }}
                                    </a>
                                    @endforeach
                            </div>
                        </div>

                        <!-- Search Bar Section (Right) -->
                        <div class="lg:w-96 flex-shrink-0">
                            <form method="GET" action="{{ route('products.index') }}" class="relative">
                                <!-- Preserve category filter -->
                                @if(request('category'))
                                    <input type="hidden" name="category" value="{{ request('category') }}">
                                @endif

                                <input
                                    type="text"
                                    name="search"
                                    value="{{ request('search') }}"
                                    placeholder="Search products, brands, etc..."
                                    class="w-full py-3 px-6 pr-14 rounded-full border-2 border-gray-700 focus:ring-4 focus:ring-teal-500/20 focus:border-teal-500 text-gray-800 bg-white text-sm shadow-sm transition-all duration-300 focus:shadow-md"
                                >
                                <button type="submit" class="absolute right-2 top-1/2 transform -translate-y-1/2 bg-teal-600 hover:bg-teal-700 text-white p-2 rounded-full transition-all hover:scale-105 shadow-sm">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                    </svg>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Optional: Product Count Display -->
            <div class="text-center mt-4">
                <span class="text-sm text-gray-500" id="productCount">
                    <!-- This can be populated with JavaScript to show current filter results -->
                </span>
            </div>
        </div>
    </div>

    <!-- Products Section -->
    <div class="pb-12 bg-gray-50">
        <div class="max-w-7xl mx-8 px-4 sm:px-6 lg:px-8">
            <div class="text-left mb-8">
                <h3 class="text-2xl inline font-bold text-gray-900 mb-4">Our Premium Collection |   </h3>
                <p class="text-gray-600 max-w-2xl mx-auto inline">   Discover our curated selection of premium products available during your flight</p>

                @if(request('search'))
                <div class="mt-4">
                    <p class="text-gray-600">
                        Search results for: <span class="font-semibold">"{{ request('search') }}"</span>
                        <a href="{{ route('products.index') }}" class="ml-2 text-teal-600 hover:text-teal-700 underline">Clear search</a>
                    </p>
                </div>
                @endif

                @if(request('category'))
                <div class="mt-4">
                    <p class="text-gray-600">
                        Category: <span class="font-semibold">{{ ucwords(str_replace(['_', '-'], ' ', request('category'))) }}</span>
                        <a href="{{ route('products.index') }}" class="ml-2 text-teal-600 hover:text-teal-700 underline">View all</a>
                    </p>
                </div>
                @endif
            </div>

            <!-- Sort and View Options -->
            <div class="flex flex-col sm:flex-row justify-between items-center mb-8 space-y-4 sm:space-y-0">
                <div class="flex items-center space-x-4">
                    <span class="text-gray-700 font-medium">Sort by:</span>
                    <form method="GET" action="{{ route('products.index') }}" class="inline">
                        <!-- Preserve existing filters -->
                        @if(request('search'))
                            <input type="hidden" name="search" value="{{ request('search') }}">
                        @endif
                        @if(request('category'))
                            <input type="hidden" name="category" value="{{ request('category') }}">
                        @endif

                        <select name="sort" onchange="this.form.submit()" class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent">
                            <option value="created_at" {{ request('sort') == 'created_at' ? 'selected' : '' }}>Latest</option>
                            <option value="name" {{ request('sort') == 'name' ? 'selected' : '' }}>Name (A-Z)</option>
                            <option value="price" {{ request('sort') == 'price' ? 'selected' : '' }}>Price (Low to High)</option>
                            <option value="stock" {{ request('sort') == 'stock' ? 'selected' : '' }}>Stock</option>
                        </select>

                        <select name="order" onchange="this.form.submit()" class="ml-2 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent">
                            <option value="asc" {{ request('order') == 'asc' ? 'selected' : '' }}>Ascending</option>
                            <option value="desc" {{ request('order') == 'desc' ? 'selected' : '' }}>Descending</option>
                        </select>
                    </form>
                </div>

                <div class="flex items-center space-x-2">
                    <span class="text-gray-700 font-medium">View:</span>
                    <button id="gridView" class="p-2 border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors view-btn active">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
                        </svg>
                    </button>
                    <button id="listView" class="p-2 border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors view-btn">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Products Grid -->
            <div id="productsContainer" class="grid grid-cols-5 sm:grid-cols-5 md:grid-cols-5 lg:grid-cols-5 xl:grid-cols-6 gap-6 transition-all duration-300">
                @forelse ($products as $product)
                    <!-- Product Card -->
                    <div class="product-card group" data-name="{{ strtolower($product->name) }}" data-category="{{ $product->category }}">
                        <a href="{{ route('products.show', str_replace(' ', '-', strtolower($product->name))) }}" class="block">
                            <div class="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl hover:scale-105 transition-all duration-300 cursor-pointer border border-gray-100">
                                <div class="relative aspect-square">
                                    <img
                                        src="{{ $product->image_url }}"
                                        alt="{{ $product->name }}"
                                        class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                                        loading="lazy"
                                        onerror="this.src='{{ asset('images/default-product.png') }}'"
                                    >

                                    <!-- Stock badge -->
                                    @if($product->stock <= 0)
                                    <div class="absolute top-2 left-2">
                                        <span class="bg-red-500 text-white text-xs px-2 py-1 rounded-full">Out of Stock</span>
                                    </div>
                                    @elseif($product->stock < 10)
                                    <div class="absolute top-2 left-2">
                                        <span class="bg-orange-500 text-white text-xs px-2 py-1 rounded-full">Low Stock</span>
                                    </div>
                                    @endif

                                    <!-- Overlay pada hover -->
                                    <div class="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>

                                    <!-- Product details overlay -->
                                    <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-3 translate-y-full group-hover:translate-y-0 transition-transform duration-300">
                                        <h3 class="text-white font-medium text-sm mb-1 truncate">{{ $product->name }}</h3>
                                        <p class="text-white/80 text-xs mb-2">{{ $product->sku }}</p>
                                        <div class="flex items-center justify-between">
                                            <span class="text-white font-bold text-sm">Rp {{ number_format($product->price, 0, ',', '.') }}</span>
                                            @if($product->category)
                                            <span class="text-white/70 text-xs bg-white/20 px-2 py-1 rounded-full">
                                                {{ ucwords(str_replace(['_', '-'], ' ', $product->category)) }}
                                            </span>
                                            @endif
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                @empty
                    <div class="col-span-full text-center py-12">
                        <div class="bg-gray-50 rounded-2xl p-8 max-w-md mx-auto border border-gray-200">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-gray-400 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                            </svg>
                            <h3 class="text-gray-600 text-lg font-medium mb-2">No Products Found</h3>
                            <p class="text-gray-500 text-sm">
                                @if(request('search') || request('category'))
                                    Try adjusting your search or filter criteria.
                                @else
                                    Please check later.
                                @endif
                            </p>
                            @if(request('search') || request('category'))
                            <div class="mt-4">
                                <a href="{{ route('products.index') }}" class="inline-flex items-center px-4 py-2 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition-colors">
                                    View All Products
                                </a>
                            </div>
                            @endif
                        </div>
                    </div>
                @endforelse
            </div>

            <!-- Pagination -->
            @if($products->hasPages())
            <div class="mt-12 flex justify-center">
                <div class="bg-white rounded-2xl shadow-lg px-6 py-4">
                    {{ $products->appends(request()->query())->links() }}
                </div>
            </div>
            @endif

            <!-- Product Stats -->
            @if($products->count() > 0)
            <div class="mt-12 text-center">
                <div class="bg-white rounded-2xl shadow-lg p-6 max-w-md mx-auto">
                    <div class="grid grid-cols-3 gap-4">
                        <div>
                            <div class="text-2xl font-bold text-teal-600">{{ $products->total() }}</div>
                            <div class="text-sm text-gray-600">Total Products</div>
                        </div>
                        <div>
                            <div class="text-2xl font-bold text-blue-600">{{ $products->count() }}</div>
                            <div class="text-sm text-gray-600">This Page</div>
                        </div>
                        <div>
                            <div class="text-2xl font-bold text-purple-600">{{ $products->currentPage() }}</div>
                            <div class="text-sm text-gray-600">Page</div>
                        </div>
                    </div>
                </div>
            </div>
            @endif
        </div>
    </div>
</div>

@push('styles')
<link rel="stylesheet" href="{{ asset('css/catalog-index.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/catalog-index.js') }}"></script>
@endpush
@endsection
