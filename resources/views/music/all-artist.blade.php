@extends('layouts.app')

@section('content')
<div class="min-h-screen text-gray-200" style="background-image: url('{{ asset('images/background/BG1.jpg') }}'); background-size: cover; background-position: center;">
    <div class="flex items-center justify-between p-6 pb-4 inset-0 bg-gradient-to-r from-white/10 via-white/20 to-white/20">
        <a href="{{ route('music.index') }}" class="flex items-center space-x-2 text-gray-200 hover:text-red-500 transition-colors group">
        <svg class="w-6 h-6 transform group-hover:-translate-x-1 transition-transform" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
        </svg>
        <span class="font-medium">Back to Music</span>
        </a>
    </div>

    <!-- Header Section -->
    <div class="relative overflow-hidden">
        <div class="absolute inset-0"></div>
        <div class="relative px-6 pt-16 pb-12  bg-gradient-to-r from-white/10 via-white/20 to-white/20">
            <div class="max-w-7xl mx-auto">
                <div class="flex items-center space-x-4 mb-6">
                    <div class="w-16 h-16 bg-gradient-to-br from-teal-600 to-teal-800 rounded-full flex items-center justify-center shadow-xl">
                        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.196-.98l-10 2A1 1 0 006 5v9.114A4.369 4.369 0 005 14c-1.657 0-3 .895-3 2s1.343 2 3 2 3-.895 3-2V7.82l8-1.6v5.894A4.369 4.369 0 0015 12c-1.657 0-3 .895-3 2s1.343 2 3 2 3-.895 3-2V3z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                    <div>
                        <h1 class="text-4xl md:text-6xl lg:text-7xl font-medium mb-2 bg-gradient-to-br from-teal-400 to-teal-600 bg-clip-text text-transparent">
                            All Artists
                        </h1>
                    </div>
                </div>
                <p class="text-gray-200 text-lg md:text-xl max-w-2xl leading-relaxed">
                    Discover and explore our amazing collection of talented artists. From rising stars to established legends.
                </p>
                <div class="flex items-center space-x-6 mt-8">
                    <div class="flex items-center space-x-2 text-sm text-gray-200">
                        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"/>
                        </svg>
                        <span>Page {{ $artists->currentPage() }} of {{ $artists->lastPage() }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Search and Filter Section -->
    <div class="px-6 mb-8 mt-5">
        <div class="max-w-7xl mx-auto">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div class="relative flex-1 max-w-md">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg class="h-5 w-5 text-gray-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                        </svg>
                    </div>
                    <form method="GET" action="{{ route('music.all-artist') }}" id="searchForm">
                        <input type="text"
                            name="search"
                            id="artistSearch"
                            value="{{ request('search') }}"
                            placeholder="Search artists..."
                            class="w-full pl-10 pr-4 py-3 bg-gray-200 border border-gray-700 rounded-full text-gray-700 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300">
                    </form>
                </div>
                <div class="flex items-center space-x-4">
                    <div class="flex items-center space-x-2 text-sm text-gray-200">
                        <span>Per page:</span>
                        <select onchange="changePerPage(this.value)" class="bg-gray-200 border border-gray-700 rounded-lg px-2 py-1 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
                            <option value="24" {{ request('per_page', 24) == 24 ? 'selected' : '' }}>24</option>
                            <option value="48" {{ request('per_page') == 48 ? 'selected' : '' }}>48</option>
                            <option value="96" {{ request('per_page') == 96 ? 'selected' : '' }}>96</option>
                        </select>
                    </div>
                    <div class="flex items-center space-x-2 text-sm text-gray-400">
                        <button class="p-2 hover:bg-gray-800/60 rounded-lg transition-colors" title="Grid View">
                            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M5 3a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2V5a2 2 0 00-2-2H5zM5 11a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2v-2a2 2 0 00-2-2H5zM11 5a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V5zM11 13a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Artists Grid -->
    <div class="px-6 pb-8">
        <div class="max-w-7xl mx-auto">
            @if($artists->count() > 0)
                <div id="artistsGrid" class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-8 gap-4 md:gap-6">
                    @foreach($artists as $artist)
                    <div class="artist-card group cursor-pointer" data-artist-name="{{ strtolower($artist) }}">
                        <a href="{{ route('artist.show', $artist) }}" class="block">
                            <div class="p-4 transition-all duration-300 hover:scale-105">
                                <!-- Artist Image -->
                                <div class="relative mb-4 group-hover:mb-3 transition-all duration-300">
                                    <div class="aspect-square rounded-full bg-gradient-to-br from-blue-600 to-blue-800 p-0.5 shadow-lg group-hover:shadow-xl transition-all duration-300">
                                        <div class="w-full h-full rounded-full bg-gray-900 flex items-center justify-center overflow-hidden">
                                            @php
                                                $artistSong = \App\Models\Media::where('artist', $artist)->first();
                                            @endphp
                                            @if($artistSong && $artistSong->artist_image)
                                                <img src="{{ $artistSong->artist_image }}"
                                                    alt="{{ $artist }}"
                                                    class="w-full h-full object-cover rounded-full group-hover:scale-110 transition-transform duration-500"
                                                    loading="lazy">
                                            @else
                                                <div class="w-12 h-12 text-gray-200 group-hover:text-blue-400 transition-colors duration-300">
                                                    <svg fill="currentColor" viewBox="0 0 20 20" class="w-full h-full">
                                                        <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"/>
                                                    </svg>
                                                </div>
                                            @endif
                                        </div>
                                    </div>

                                    <!-- Play Button Overlay -->
                                    <div class="absolute bottom-2 right-2 w-12 h-12 bg-blue-600 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transform translate-y-2 group-hover:translate-y-0 transition-all duration-300 shadow-lg hover:scale-110 hover:bg-blue-500">
                                        <svg class="w-5 h-5 text-white ml-0.5" fill="currentColor" viewBox="0 0 20 20">
                                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd"/>
                                        </svg>
                                    </div>
                                </div>

                                <!-- Artist Info -->
                                <div class="text-center">
                                    <h4 class="text-gray-200 font-semibold text-sm md:text-base leading-tight mb-1 truncate group-hover:text-blue-400 transition-colors duration-300"
                                        title="{{ $artist }}">
                                        {{ Str::limit($artist, 16) }}
                                    </h4>
                                </div>
                            </div>
                        </a>
                    </div>
                    @endforeach
                </div>
            @else
                <!-- Empty State -->
                <div class="text-center py-16">
                    <div class="max-w-md mx-auto">
                        <div class="w-24 h-24 mx-auto mb-6 bg-gray-800 rounded-full flex items-center justify-center">
                            <svg class="w-12 h-12 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                            </svg>
                        </div>
                        <h3 class="text-xl font-semibold text-gray-700 mb-2">No artists found</h3>
                        <p class="text-gray-400">
                            @if(request('search'))
                                No artists match your search "{{ request('search') }}". Try a different search term.
                            @else
                                No artists available at the moment.
                            @endif
                        </p>
                        @if(request('search'))
                            <a href="{{ route('music.all-artist') }}" class="inline-flex items-center space-x-2 mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg text-white transition-colors">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                                </svg>
                                <span>Clear Search</span>
                            </a>
                        @endif
                    </div>
                </div>
            @endif
        </div>
    </div>

    <!-- Pagination -->
    @if($artists->hasPages())
    <div class="px-6 pb-16">
        <div class="max-w-7xl mx-auto">
            <div class="flex flex-col items-center space-y-4">

                <!-- Pagination Links -->
                <nav class="flex items-center space-x-2">
                    {{-- Previous Page Link --}}
                    @if ($artists->onFirstPage())
                        <span class="px-3 py-2 text-gray-400 bg-white rounded-lg cursor-not-allowed">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                            </svg>
                        </span>
                    @else
                        <a href="{{ $artists->appends(request()->query())->previousPageUrl() }}"
                        class="px-3 py-2 text-gray-400 bg-white hover:text-white hover:bg-teal-700/80 rounded-lg transition-colors">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                            </svg>
                        </a>
                    @endif

                    {{-- Pagination Elements --}}
                    @foreach ($artists->appends(request()->query())->getUrlRange(1, $artists->lastPage()) as $page => $url)
                        @if ($page == $artists->currentPage())
                            <span class="px-4 py-2 bg-teal-600 text-white rounded-lg font-medium">{{ $page }}</span>
                        @else
                            <a href="{{ $url }}" class="px-4 py-2 text-gray-400 bg-white hover:bg-teal-700/80 hover:text-white rounded-lg transition-colors">{{ $page }}</a>
                        @endif
                    @endforeach

                    {{-- Next Page Link --}}
                    @if ($artists->hasMorePages())
                        <a href="{{ $artists->appends(request()->query())->nextPageUrl() }}"
                        class="px-3 py-2 text-gray-400 bg-white hover:bg-teal-700/80 hover:text-white rounded-lg transition-colors">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                            </svg>
                        </a>
                    @else
                        <span class="px-3 py-2 text-gray-500 bg-gray-800/40 rounded-lg cursor-not-allowed">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                            </svg>
                        </span>
                    @endif
                </nav>

                <!-- Quick Page Jump -->
                @if($artists->lastPage() > 10)
                <div class="flex items-center space-x-2 text-sm">
                    <span class="text-gray-400">Jump to page:</span>
                    <select onchange="jumpToPage(this.value)" class="bg-gray-800/60 border border-gray-700 rounded px-2 py-1 text-white focus:outline-none focus:ring-2 focus:ring-blue-500">
                        @for($i = 1; $i <= $artists->lastPage(); $i++)
                            <option value="{{ $i }}" {{ $i == $artists->currentPage() ? 'selected' : '' }}>{{ $i }}</option>
                        @endfor
                    </select>
                </div>
                @endif
            </div>
        </div>
    </div>
    @endif
</div>


<!-- Scroll to Top Button -->
<button id="scrollToTop" class="fixed bottom-6 right-6 w-12 h-12 bg-teal-600 hover:bg-teal-700 rounded-full flex items-center justify-center text-white shadow-lg opacity-0 pointer-events-none transition-all duration-300 z-50">
    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18"/>
    </svg>
</button>

@push('scripts')
<script src="{{ asset('js/music-all-artist.js') }}"></script>
@endpush

@push('styles')
<link rel="stylesheet" href="{{ asset('css/music-all-artist.css') }}">
@endpush
@endsection
