@extends('layouts.app', ['title' => ucwords(str_replace(['_', '-'], ' ', $product['name']))])

@push('styles')
<meta name="csrf-token" content="{{ csrf_token() }}">
@endpush

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

            <!-- Desktop Navigation -->
            <div class="hidden lg:flex items-center space-x-6">
                <!-- Search Bar Row -->
                <div class="px-4 py-3">
                    <div class="max-w-4xl mx-auto">
                        <form method="GET" action="{{ route('products.index') }}" class="relative">
                            <input
                                type="text"
                                name="search"
                                value="{{ request('search') }}"
                                placeholder="Search products, brands, categories..."
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
            </div>
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
                                placeholder="Search products, brands, categories..."
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

<!-- Back Button -->
<div class="bg-gray-50 py-4">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <button onclick="history.back()" class="flex items-center space-x-2 text-teal-600 hover:text-teal-700 font-medium transition-colors duration-200">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
            <span>Kembali</span>
        </button>
    </div>
</div>

<div class="min-h-screen bg-white">
    <!-- Product Detail Section -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
            <!-- Product Image -->
            <div class="space-y-4">
                <div class="aspect-square bg-gray-100 rounded-2xl overflow-hidden shadow-lg">
                    <img
                        src="{{ $product['path'] }}"
                        alt="{{ $product['name'] }}"
                        class="w-full h-full object-cover hover:scale-105 transition-transform duration-500"
                        id="mainImage"
                        onerror="this.src='{{ asset('images/placeholder.jpg') }}'"
                    >
                </div>

                <!-- Thumbnail Images (simulated) -->
                <div class="flex space-x-3 overflow-x-auto">
                    @for($i = 0; $i < 1; $i++)
                    <div class="flex-shrink-0 w-20 h-20 bg-gray-100 rounded-lg overflow-hidden cursor-pointer border-2 {{ $i == 0 ? 'border-teal-500' : 'border-transparent' }} hover:border-teal-300 transition-colors">
                        <img
                            src="{{ $product['path'] }}"
                            alt="Thumbnail {{ $i + 1 }}"
                            class="w-full h-full object-cover"
                            onclick="changeMainImage('{{ $product['path'] }}')"
                            onerror="this.src='{{ asset('images/placeholder.jpg') }}'"
                        >
                    </div>
                    @endfor
                </div>
            </div>

            <!-- Product Info -->
            <div class="space-y-6">
                <!-- Product Title & Price -->
                <div>
                    <h1 class="text-3xl md:text-4xl font-bold text-gray-900 mb-2">
                        {{ ucwords(str_replace(['_', '-'], ' ', $product['name'])) }}
                    </h1>

                    <!-- SKU Display -->
                    @if(isset($product['sku']))
                    <p class="text-sm text-gray-500 mb-3">SKU: {{ $product['sku'] }}</p>
                    @endif

                    <div class="flex items-center space-x-4 mb-4">
                        <span class="text-3xl font-bold text-teal-600">Rp.{{ number_format($product['price'], 2) }}</span>
                        <span class="text-lg text-gray-500 line-through">Rp.{{ number_format($product['price'] * 1.3, 2) }}</span>
                        <span class="bg-red-500 text-white px-3 py-1 rounded-full text-sm font-medium">
                            {{ round((1 - $product['price'] / ($product['price'] * 1.3)) * 100) }}% OFF
                        </span>
                    </div>

                    <!-- Stock Status -->
                    <div class="mb-4">
                        @if($product['stock'] > 0)
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                <svg class="w-2 h-2 mr-1" fill="currentColor" viewBox="0 0 8 8">
                                    <circle cx="4" cy="4" r="3"/>
                                </svg>
                                In Stock ({{ $product['stock'] }} available)
                            </span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                <svg class="w-2 h-2 mr-1" fill="currentColor" viewBox="0 0 8 8">
                                    <circle cx="4" cy="4" r="3"/>
                                </svg>
                                Out of Stock
                            </span>
                        @endif
                    </div>
                </div>

                <!-- Product Description -->
                <div class="prose prose-gray max-w-none">
                    <p class="text-gray-700 text-lg leading-relaxed">{{ $product['description'] }}</p>
                </div>

                <!-- Product Features -->
                @if(isset($product['features']) && count($product['features']) > 0)
                <div>
                    <h3 class="text-lg font-semibold text-gray-900 mb-3">Key Features</h3>
                    <ul class="grid grid-cols-1 md:grid-cols-2 gap-2">
                        @foreach($product['features'] as $feature)
                        <li class="flex items-center space-x-2">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-teal-500 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                            </svg>
                            <span class="text-gray-700">{{ $feature }}</span>
                        </li>
                        @endforeach
                    </ul>
                </div>
                @endif

                <!-- Buy Section -->
                @if($product['stock'] > 0)
                <div class="space-y-4">
                    <!-- Action Buttons -->
                    <div class="flex flex-col sm:flex-row space-y-3 sm:space-y-0 sm:space-x-4">
                        <a
                            href="#"
                            class="flex-1 bg-gradient-to-r from-teal-600 to-blue-600 hover:from-teal-700 hover:to-blue-700 text-white px-8 py-4 rounded-xl font-medium transition-all transform hover:scale-105 shadow-lg flex items-center justify-center space-x-2 text-center"
                            onclick="showPurchaseMessage()"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4m0 0L7 13m0 0l-2.5 5M7 13l2.5 5m0 0h8.5" />
                            </svg>
                            <span>Buy Now</span>
                        </a>
                    </div>
                </div>
                @else
                <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                    <p class="text-red-800 font-medium">This product is currently out of stock.</p>
                    <p class="text-red-600 text-sm mt-1">Please check back later or contact us for availability.</p>
                </div>
                @endif
            </div>
        </div>
    </div>
</div>

<!-- Success/Error Messages -->
<div id="message" class="fixed top-4 right-4 z-50 hidden">
    <div class="bg-blue-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span id="messageText">This is a demo version. Visit the official website to purchase!</span>
    </div>
</div>

@push('scripts')
<script src="{{ asset('js/catalog-show.js') }}"></script>
@endpush
@endsection
