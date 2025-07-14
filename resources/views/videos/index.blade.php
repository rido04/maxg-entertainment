@extends('layouts.app', ['title' => 'Maxg Cinema'])

@section('content')
<div class="min-h-screen text-gray-800" style="background-image: url('{{ asset('images/background/Background_Color.png') }}'); background-size: cover; background-position: center;">
    <!-- Header Section -->
    <div class="relative px-4 md:px-6 pt-6 md:pt-8 pb-4 md:pb-6 mx-4 md:mx-8 lg:mx-14">
        <div class="max-w-7xl mx-auto flex flex-col md:flex-row items-start md:items-center justify-between gap-4">

            <!-- Time-based Greeting -->
            <div class="mb-4 md:mb-8 flex-1">
                <div class="flex flex-col sm:flex-row sm:items-center gap-3">
                    <h1 class="text-xl md:text-2xl font-bold text-gray-200" id="greeting">
                        Good Evening
                    </h1>
                    <!-- Sync Button -->
                    <button type="button"
                    onclick="document.getElementById('syncModal').classList.remove('hidden')"
                    class="inline-flex items-center text-xs px-3 py-1.5 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-xl shadow-md hover:shadow-lg transform hover:scale-105 transition-all duration-300 border border-blue-400/20 w-fit">
                    <svg class="w-3 h-3 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    Sync Movies
                </button>
                </div>
                <p class="text-gray-200 text-sm md:text-md mt-2">
                    Biar ga bosen di jalan, yuk nonton film seru di MaxG Cinema!
                </p>
            </div>

            <!-- Grab Logo -->
            <div class="flex items-center space-x-6 -mt-2 md:-mt-8 -mr-2 md:-mr-7">
                <div class="flex items-center space-x-3 rounded-xl px-2 md:px-4 py-2 md:py-3 group">
                    <div class="relative">
                        <img src="{{ asset('images/logo/Maxg-ent_white.gif') }}" alt="MaxG Entertainment Hub" class="w-32 sm:w-48 md:w-64 lg:w-80 h-auto object-contain">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Search and Filter Section -->
    <div class="flex flex-col lg:flex-row items-stretch gap-4 px-4 md:px-8 lg:px-8 mx-4 md:mx-8 lg:mx-14 mb-6">
        <!-- Search Bar -->
        <div class="flex-1">
            <form action="/search-movie" method="GET" class="relative max-w-full lg:max-w-lg">
                <input type="text" name="q" placeholder="Lagi mau nonton apa nih?...."
                    class="w-full px-4 py-2.5 md:py-3 bg-white border border-gray-300 rounded-3xl text-gray-800 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-300 shadow-sm text-sm md:text-base"
                    value="{{ old('q') }}"
                    onfocus="this.setAttribute('readonly', false);">
                <button type="submit" class="absolute right-3 top-1/2 transform -translate-y-1/2 p-2 text-green-500 hover:text-green-600 transition-colors duration-300">
                    <svg class="w-4 h-4 md:w-5 md:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                </button>
            </form>
        </div>

        <!-- Filter Bar -->
        <div class="flex-shrink-0">
            <form action="{{ route('videos.index') }}" method="GET" class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                <!-- Category Filter -->
                <div class="flex flex-col space-y-1">
                    <label class="text-xs font-medium text-gray-200 uppercase tracking-wider">Genre</label>
                    <select name="category" class="px-3 md:px-4 py-2.5 md:py-3 bg-white/50 border border-gray-300 rounded-lg text-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-300 hover:bg-gray-50 min-w-[120px] md:min-w-[150px] shadow-sm text-sm">
                        <option value="">Semua Genre's</option>
                        @foreach($categories as $cat)
                            <option value="{{ $cat }}" {{ request('category') == $cat ? 'selected' : '' }}>
                                {{ $cat }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <!-- Action Buttons -->
                <div class="flex items-end space-x-2 sm:space-x-3 sm:ml-auto mt-3 sm:mt-5">
                    <!-- Filter Button -->
                    <button type="submit" class="px-4 md:px-6 py-2.5 md:py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-lg hover:from-blue-600 hover:to-blue-700 transition-all duration-300 font-semibold shadow-md hover:shadow-lg hover:scale-105 flex items-center space-x-2 text-sm">
                        <svg class="w-3 h-3 md:w-4 md:h-4" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M3 3a1 1 0 011-1h12a1 1 0 011 1v3a1 1 0 01-.293.707L12 11.414V15a1 1 0 01-.293.707l-2 2A1 1 0 018 17v-5.586L3.293 6.707A1 1 0 013 6V3z" clip-rule="evenodd" />
                        </svg>
                        <span class="hidden sm:inline">Terapkan filter</span>
                        <span class="sm:hidden">Filter</span>
                    </button>

                    <!-- Clear Button -->
                    @if(request()->hasAny(['category', 'genre', 'year', 'rating']))
                    <a href="{{ route('videos.index') }}" class="px-3 md:px-4 py-2.5 md:py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 hover:text-gray-800 transition-all duration-300 font-medium flex items-center space-x-2 border border-gray-300 shadow-sm text-sm">
                        <svg class="w-3 h-3 md:w-4 md:h-4" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                        </svg>
                        <span>Hapus filter</span>
                    </a>
                    @endif
                </div>
            </form>

            <!-- Active Filters Display -->
            @if(request()->hasAny(['category', 'genre', 'year', 'rating']))
            <div class="mt-3 flex flex-wrap items-center gap-2">
                <span class="text-sm text-gray-200 font-medium">Filter aktif:</span>

                @if(request('category'))
                <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800 border border-blue-200">
                    Genre: {{ request('category') }}
                    <a href="{{ request()->fullUrlWithQuery(['category' => null]) }}" class="ml-2 hover:text-blue-600">
                        <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                        </svg>
                    </a>
                </span>
                @endif
            </div>
            @endif
        </div>
    </div>

    <!-- Category Result Info -->
    @if($category)
        <div class="px-4 md:px-8 py-2 text-white mx-4 md:mx-8 lg:mx-14">
            <p class="text-sm md:text-base">Hasil untuk Genre: <span class="font-bold text-white">{{ $category }}</span></p>
        </div>
    @endif

    <!-- Browse All Movies Section -->
    <div class="px-4 md:px-8 mx-4 md:mx-8 lg:mx-14">
        <h2 class="text-lg md:text-xl font-bold text-gray-200 flex items-center">
            <span class="w-1 h-5 md:h-6 bg-gradient-to-b from-blue-500 to-blue-600 rounded-full mr-3"></span>
            List semua film
        </h2>
    </div>

    <!-- RESPONSIVE MAIN CONTENT -->
    <div class="px-4 md:px-8 lg:px-8 mx-4 md:mx-8 lg:mx-14">
        <!-- Mobile Layout (sm and below) -->
        <div class="block lg:hidden">
            <!-- Featured Movie Display -->
            <div class="mb-6">
                <div id="mobile-featured-movie" class="relative rounded-2xl overflow-hidden h-48 sm:h-64">
                    <!-- Default State -->
                    <div id="mobile-default-thumbnail" class="absolute inset-0 flex items-center justify-center">
                        <div class="text-center text-white/70">
                            <img src="{{ asset('images/logo/Logo-MaxG-White.gif') }}" alt="Logo Grab" class="w-32 sm:w-48 mx-auto">
                        </div>
                    </div>

                    <!-- Dynamic Thumbnail -->
                    <div id="mobile-movie-thumbnail" class="absolute inset-0 opacity-0 transition-all duration-500">
                        <div id="mobile-thumbnail-bg" class="absolute inset-0 bg-cover bg-center"></div>
                        <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent"></div>

                        <div class="absolute bottom-0 left-0 right-0 p-4">
                            <span id="mobile-thumbnail-category" class="inline-block px-3 py-1 bg-red-500/90 text-xs font-medium rounded-full text-white mb-2">
                                Featured
                            </span>
                            <h3 id="mobile-thumbnail-title" class="text-white font-bold text-lg mb-1">Judul Film</h3>
                            <div class="flex items-center gap-2 text-gray-200">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.414-1.415L11 9.586V6z" clip-rule="evenodd"/>
                                </svg>
                                <span id="mobile-thumbnail-duration" class="text-sm">Durasi</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Mobile Movies List -->
            <div class="space-y-3 max-h-96 overflow-y-auto scrollbar-thin scrollbar-thumb-blue-500 scrollbar-track-gray-300">

                @foreach($videos as $video)
                <div class="mobile-movie-item group relative bg-gradient-to-r from-blue-200 to-blue-400
                hover:bg-gradient-to-r hover:from-green-950 hover:to-green-950 rounded-e-full hover:shadow-slate-100 hover:shadow-2xl overflow-hidden transition-all duration-300 border border-gray-200 cursor-pointer"
                     data-thumbnail="{{ $video->thumbnail }}"
                     data-title="{{ $video->title }}"
                     data-description="{{ $video->description ?? 'Movie description...' }}"
                     data-category="{{ $video->category }}"
                     data-duration="{{ $video->duration }}">

                    <a href="{{ route('videos.show', $video) }}" class="block p-4">
                        <div class="flex items-center gap-3">
                            <!-- Thumbnail -->
                            <div class="w-12 h-12 bg-gradient-to-br from-red-500 to-red-600 rounded-lg flex-shrink-0 overflow-hidden">
                                <img src="{{ $video->thumbnail }}" alt="" class="w-full h-full object-cover">
                            </div>

                            <!-- Content -->
                            <div class="flex-1 min-w-0">
                                <div class="flex items-center gap-2 mb-1">
                                    <span class="text-xs text-gray-600 group-hover:text-gray-200 uppercase font-medium">
                                        {{ ucfirst($video->category ?? 'Entertainment') }}
                                    </span>
                                </div>

                                <h3 class="font-bold text-gray-800 group-hover:text-white text-sm leading-tight truncate">
                                    {{ $video->title }}
                                </h3>

                                <div class="flex items-center gap-2 text-sm text-gray-600 group-hover:text-gray-200 mt-1">
                                    <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                                    <span>{{ $video->duration ? $video->duration . ' min' : 'Live' }}</span>
                                </div>
                            </div>

                            <!-- Arrow -->
                            <div class="opacity-100 group-hover:opacity-0 transition-opacity duration-300 -ml-36 mr-10 mb-5">
                                <img src="{{ asset('images/logo/Logo-MaxG-Green.gif') }}" alt="MaxG Logo" class="w-24 h-auto">
                            </div>

                            <div class="opacity-0 group-hover:opacity-100 transition-opacity duration-300 -ml-36 mr-10 mb-5">
                                <img src="{{ asset('images/logo/Logo-MaxG-White.gif') }}" alt="MaxG white Logo" class="w-20 h-auto">
                            </div>
                        </div>
                    </a>
                </div>
                @endforeach
            </div>
        </div>

        <!-- Desktop/Tablet Layout (lg and above) -->
        <div class="hidden lg:block">
            <div class="main-content-scroll hide-scrollbar mb-5">
                @php
                    $chunkedVideos = $videos->chunk(4);
                @endphp

                @foreach($chunkedVideos as $videoChunk)
                <div class="scroll-section" data-section="{{ $loop->index }}">
                    <div class="flex gap-8 min-h-[600px]">
                        <!-- Left Grid - Movie List -->
                        <div class="w-1/2 space-y-4" id="movies-container-section-{{ $loop->index }}">
                            @foreach($videoChunk as $video)
                            <div class="group relative bg-blue-400 hover:bg-green-700 rounded-xl overflow-hidden transition-all duration-500 hover:scale-[1.02] border border-gray-200 cursor-pointer movie-item mt-5"
                                data-thumbnail="{{ $video->thumbnail }}"
                                data-title="{{ $video->title }}"
                                data-description="{{ $video->description ?? 'Movie description...' }}"
                                data-category="{{ $video->category }}"
                                data-duration="{{ $video->duration }}"
                                data-section="{{ $loop->parent->index }}">

                                <a href="{{ route('videos.show', $video) }}" class="block p-6">
                                    <div class="flex items-center gap-4">
                                        <!-- Thumbnail -->
                                        <div class="w-12 h-12 bg-gradient-to-br from-red-500 to-red-600 rounded-lg flex-shrink-0">
                                            <img src="{{ $video->thumbnail }}" alt="" class="w-full h-full object-cover rounded-lg">
                                        </div>

                                        <!-- Content -->
                                        <div class="flex-1 min-w-0">
                                            <div class="flex items-center gap-3 mb-2">
                                                <span class="category text-xs text-gray-700 group-hover:text-gray-200 uppercase tracking-wider font-medium">
                                                    {{ ucfirst($video->category ?? 'Entertainment') }}
                                                </span>
                                            </div>

                                            <h3 class="text-lg font-bold text-gray-800 mb-2 leading-tight group-hover:text-gray-200 transition-colors duration-300 truncate">
                                                {{ $video->title }}
                                            </h3>

                                            <div class="duration flex items-center gap-4 text-sm text-gray-600 group-hover:text-gray-200">
                                                <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                                                <span>{{ $video->duration ? $video->duration . ' min' : 'Live' }}</span>
                                            </div>
                                        </div>

                                        <!-- Grab Icons -->
                                        <div class="opacity-100 group-hover:opacity-0 transition-opacity duration-300 -ml-36 mr-10 mb-5">
                                            <img src="{{ asset('images/logo/Logo-MaxG-Green.gif') }}" alt="MaxG Logo" class="w-24 h-auto">
                                        </div>

                                        <div class="opacity-0 group-hover:opacity-100 transition-opacity duration-300 -ml-36 mr-10 mb-5">
                                            <img src="{{ asset('images/logo/Logo-MaxG-White.gif') }}" alt="MaxG Logo" class="w-20 h-auto">
                                        </div>
                                    </div>
                                </a>
                            </div>
                            @endforeach
                        </div>

                        <!-- Right Side - Thumbnail Display -->
                        <div class="w-1/2 relative rounded-2xl overflow-hidden mt-5">
                            <!-- Default State -->
                            <div id="default-thumbnail-{{ $loop->index }}" class="default-thumbnail-section absolute inset-0 flex items-center justify-center">
                                <div class="text-center text-white/70">
                                    <img src="{{ asset('images/logo/Logo-MaxG-White.gif') }}" alt="Logo Grab" class="w-96 mx-auto">
                                </div>
                            </div>

                            <!-- Dynamic Thumbnail -->
                            <div id="movie-thumbnail-{{ $loop->index }}" class="movie-thumbnail-section absolute inset-0 opacity-0 transition-all duration-500 ease-in-out">
                                <div id="thumbnail-bg-{{ $loop->index }}" class="thumbnail-bg absolute inset-0 bg-cover bg-center transition-all duration-700"></div>
                                <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent"></div>

                                <div class="absolute bottom-0 left-0 right-0 p-8">
                                    <div class="max-w-md">
                                        <span id="thumbnail-category-{{ $loop->index }}" class="thumbnail-category inline-block px-3 py-1 bg-red-500/90 backdrop-blur-sm text-xs font-medium rounded-full text-white border border-red-400/50 mb-3">
                                            Featured
                                        </span>

                                        <h3 id="thumbnail-title-{{ $loop->index }}" class="text-2xl font-bold text-white mb-2">Judul film</h3>

                                        <div class="flex items-center gap-2 text-gray-200">
                                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.414-1.415L11 9.586V6z" clip-rule="evenodd"/>
                                            </svg>
                                            <span id="thumbnail-duration-{{ $loop->index }}" class="thumbnail-duration text-sm font-medium">Durasi</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Play Button -->
                                <div class="absolute inset-0 flex items-center justify-center">
                                    <div class="w-20 h-20 bg-white/20 backdrop-blur-sm rounded-full border border-white/30 flex items-center justify-center transform scale-0 group-hover:scale-100 transition-transform duration-500">
                                        <svg class="w-10 h-10 text-white ml-1" fill="currentColor" viewBox="0 0 24 24">
                                            <path d="M8 5v14l11-7z"/>
                                        </svg>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
        </div>
</div>
<!-- Current Time Display -->
<div class="fixed bottom-6 right-6 z-20">
    <div class="bg-white/90 backdrop-blur-sm rounded-lg px-3 py-2 border border-gray-200 shadow-lg">
        <div class="text-right text-gray-800">
            <div class="text-xs text-blue-600 font-medium">NOW</div>
            <div class="text-sm font-bold" id="current-time">10:58 AM</div>
        </div>
    </div>
</div>

<!-- Sync Modal -->
<div id="syncModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 transform transition-all duration-300 scale-100">
        <!-- Header -->
        <div class="flex items-center justify-between p-6 border-b border-gray-200">
            <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-gradient-to-r from-blue-500 to-blue-600 rounded-full flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                    </svg>
                </div>
                <div>
                    <h3 class="text-lg font-semibold text-gray-700">Admin Verification</h3>
                    <p class="text-sm text-gray-500">Authentication required to proceed</p>
                </div>
            </div>
            <button type="button"
                    onclick="document.getElementById('syncModal').classList.add('hidden')"
                    class="text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full p-2 transition-colors duration-200">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </div>

        <!-- Form -->
        <form id="syncForm" class="p-6">
            <div class="space-y-4">
                <!-- Password Input -->
                <div class="space-y-2">
                    <label for="password" class="block text-sm font-medium text-gray-700">
                        ! Make sure you have internet connection before syncing.
                    </label>
                    <div class="relative">
                        <input type="password"
                               id="password"
                               name="password"
                               required
                               autofocus
                               class="w-full px-4 py-3 border text-gray-800 border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 pr-12"
                               placeholder="Enter your password">
                        <button type="button"
                                onclick="togglePasswordVisibility()"
                                class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600">
                            <svg id="eye-open" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                            </svg>
                            <svg id="eye-closed" class="w-5 h-5 hidden" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L8.464 8.464l-1.415-1.415M9.878 9.878l4.242 4.242m0 0L12.536 12.536l1.415 1.415M14.12 14.12l1.415 1.415"></path>
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Error Message -->
                <div id="error-message" class="hidden text-red-600 bg-red-50 border border-red-200 rounded-lg p-4">
                    <div class="flex items-center">
                        <svg class="w-5 h-5 text-red-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <span class="text-sm text-red-700" id="error-text"></span>
                    </div>
                </div>

                <!-- Success Message -->
                <div id="success-message" class="hidden bg-green-50 border border-green-200 rounded-lg p-4">
                    <div class="flex items-center">
                        <svg class="w-5 h-5 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <span class="text-sm text-green-700" id="success-text"></span>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex justify-end space-x-3 mt-6 pt-4 border-t border-gray-200">
                <button type="button"
                        onclick="document.getElementById('syncModal').classList.add('hidden')"
                        class="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors duration-200 font-medium">
                    Cancel
                </button>
                <button type="submit"
                        id="syncBtn"
                        class="px-6 py-2 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white rounded-lg transition-all duration-200 font-medium shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none">
                    <span id="sync-btn-text">Start Sync</span>
                    <svg id="sync-loading" class="hidden animate-spin w-4 h-4 ml-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                </button>
            </div>
            <!-- Success Modal -->
            <div id="successModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
                <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 transform transition-all duration-300 scale-100">
                    <!-- Header -->
                    <div class="flex items-center justify-between p-6 border-b border-gray-200">
                        <h3 class="text-lg font-semibold text-gray-900">Sync Completed</h3>
                        <button type="button"
                                onclick="document.getElementById('successModal').classList.add('hidden')"
                                class="text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full p-2 transition-colors duration-200">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>

                    <!-- Body -->
                    <div class="p-6">
                        <p class="text-gray-700">Sync completed successfully! Please refresh the page to see the updates.</p>
                    </div>

                    <!-- Footer -->
                    <div class="flex justify-end space-x-3 p-6 border-t border-gray-200">
                        <button type="button"
                                onclick="location.reload()"
                                class="px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg transition-all duration-200 font-medium shadow-md hover:shadow-lg">
                            Refresh Page
                        </button>
                        <button type="button"
                                onclick="document.getElementById('successModal').classList.add('hidden')"
                                class="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg transition-all duration-200 font-medium">
                            Close
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
@push('scripts')
<script src="{{ asset('js/videos-index.js') }}"></script>
@endpush

@push('styles')
<link rel="stylesheet" href="{{ asset('css/videos-index.css') }}">
@endpush
@endsection
