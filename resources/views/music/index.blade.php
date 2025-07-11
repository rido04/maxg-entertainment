@extends('layouts.app', ['title' => 'Music Library'])

@section('content')
<div class="min-h-screen text-gray-800" style="background-image: url('{{ asset('images/background/BG1.jpg') }}'); background-size: cover; background-position: center;">

  <!-- Header Section -->
    <div class="relative pt-4 md:pt-8 pb-4 md:pb-6 md:mx-14">
    <div class="max-w-7xl mx-auto flex flex-col md:flex-row items-start md:items-center justify-between gap-4">

        <!-- Time-based Greeting -->
        <div class="w-full mb-4 md:mb-8">
        <div class="flex flex-col sm:flex-row sm:items-center gap-3 sm:gap-5">
            <h1 class="text-xl sm:text-2xl font-bold text-gray-200" id="greeting">
                Good Evening
            </h1>
            <!-- Sync Button -->
            <button type="button"
                onclick="document.getElementById('syncModal').classList.remove('hidden')"
                class="inline-flex items-center text-xs px-3 py-2 bg-gradient-to-r from-blue-600 to-teal-600 hover:from-blue-700 hover:to-teal-700 text-white font-medium rounded-lg shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 w-fit">
                <svg class="w-3 h-3 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                </svg>
                Sync Music
            </button>
        </div>
        <p class="text-gray-200 text-sm sm:text-lg mt-2">Let's find something for you to listen to</p>
        </div>

        <!-- Garuda Logo & Text -->
        <div class="flex items-center justify-between md:justify-end w-full md:w-auto -mt-4 md:-mt-8 -mr-0 md:-mr-7">
            <div class="flex items-center space-x-3 rounded-xl px-2 md:px-4 py-3 group">
                <div class="relative">
                    <img src="{{ asset('Logo-Garuda-Animasi.gif') }}" alt="Garuda Airlines" class="w-40 sm:w-60 md:w-80 h-8 sm:h-10 md:h-14 object-contain">
                </div>
            </div>
        </div>
    </div>
    </div>

    <!-- Search Bar -->
    <div class="px-4 md:px-6 mb-6 md:mb-8 mx-8">
        <div class="max-w-7xl mx-auto">
            <!-- Search Bar -->
            <form action="{{ route('music.search') }}" method="GET" class="relative mb-6">
                <div class="flex items-center bg-white/80 backdrop-blur-sm rounded-xl shadow-lg overflow-hidden border border-gray-300/50">
                    <input type="text" name="q" placeholder="Search for songs..."
                           class="w-full px-4 py-3 bg-white text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-400 text-sm md:text-base"
                           onfocus="this.setAttribute('readonly', false);">
                    <button type="submit" class="px-3 md:px-4 py-3 bg-teal-600 hover:bg-blue-500 text-white rounded-r-xl transition-all duration-300">
                        <svg class="w-4 md:w-5 h-4 md:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                        </svg>
                    </button>
                </div>
            </form>
        </div>
    </div>

  <!-- Quick Access Cards -->
  <div class="px-4 md:px-6 mb-6 md:mb-8 mx-8">
    <div class="max-w-7xl mx-auto">
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 md:gap-4">
        @foreach($music->take(6) as $song)
        <div class="group bg-white/70 hover:bg-white/90 backdrop-blur-sm rounded-xl p-3 flex items-center cursor-pointer transition-all duration-300 border border-gray-300/30 hover:border-blue-400/50 shadow-sm hover:shadow-lg"
        onclick="playAudio('{{ $song->id }}', '{{ $song->file_path }}', '{{ $song->title }}', '{{ $song->artist ?? "Unknown Artist" }}', '{{ $song->thumbnail }}')">
          <!-- Thumbnail -->
          <div class="w-12 sm:w-14 md:w-16 h-12 sm:h-14 md:h-16 rounded-xl bg-gradient-to-br from-blue-500 to-teal-600 flex items-center justify-center mr-3 md:mr-4 flex-shrink-0 shadow-lg">
            @if($song->thumbnail)
              <img src="{{ $song->thumbnail }}" alt="{{ $song->title }}" class="w-full h-full object-cover rounded-xl">
            @else
              <svg class="w-6 md:w-8 h-6 md:h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
              </svg>
            @endif
          </div>

          <!-- Song Info -->
          <div class="flex-1 min-w-0">
            <h4 class="font-semibold text-gray-800 text-sm sm:text-base truncate group-hover:text-blue-600 transition-colors">
              {{ $song->title }}
            </h4>
            <p class="text-xs sm:text-sm text-gray-600 truncate">{{ $song->artist ?? 'Unknown Artist' }}</p>
          </div>

          <!-- More Button -->
          <a href="{{ route('music.show', $song) }}"
            onclick="event.stopPropagation()"
            class="opacity-100 text-blue-600 hover:text-blue-700 text-xs sm:text-sm font-medium transition-all ml-2">
            More
          </a>
              </div>
              @endforeach
            </div>
          </div>
        </div>

        <!-- Featured Artists Section -->
    <div class="px-4 md:px-6 mb-6 md:mb-8 mx-8">
        <div class="max-w-7xl mx-auto">
            <div class="flex items-center justify-between mb-4 md:mb-6">
                <h2 class="text-xl md:text-2xl font-bold text-teal-400 hover:underline cursor-pointer">Featured Artists</h2>
                <a href="{{ route('music.all-artist') }}" class="text-teal-400 hover:text-blue-900 text-xs md:text-sm font-semibold uppercase tracking-wider transition-colors">
                    Show all
                </a>
            </div>

            <!-- Horizontal Scroll Artist Cards -->
            <div class="flex space-x-4 md:space-x-6 overflow-x-auto pb-4 scrollbar-thin scrollbar-thumb-gray-400 scrollbar-track-transparent">
                @php
                    $featuredArtists = $music->pluck('artist')->unique()->filter()->take(10);
                @endphp

                @foreach($featuredArtists as $artist)
                <div class="group min-w-[120px] md:min-w-[160px] max-w-[120px] md:max-w-[160px] cursor-pointer transition-all duration-300 hover:scale-105 flex-shrink-0">
                    <!-- Artist Circle Image -->
                    <div class="relative mb-3 md:mb-4">
                        <div class="w-24 md:w-32 h-24 md:h-32 mx-auto rounded-full bg-gradient-to-br from-teal-500 to-pink-600 flex items-center justify-center shadow-xl overflow-hidden group-hover:shadow-2xl transition-shadow duration-300">
                            @php
                                $artistSong = $music->where('artist', $artist)->first();
                            @endphp
                            @if($artistSong && $artistSong->artist_image)
                                <img src="{{ $artistSong->artist_image }}" alt="{{ $artist }}" class="w-full h-full object-cover rounded-full">
                            @else
                                <div class="w-12 md:w-16 h-12 md:h-16 text-white">
                                    <svg fill="currentColor" viewBox="0 0 20 20" class="w-full h-full">
                                        <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
                                    </svg>
                                </div>
                            @endif
                        </div>

                        <!-- Play Button Overlay -->
                        <button class="absolute bottom-1 md:bottom-2 right-1 md:right-2 bg-green-500 hover:bg-green-400 rounded-full p-1.5 md:p-2 shadow-lg opacity-0 group-hover:opacity-100 transform translate-y-2 group-hover:translate-y-0 transition-all duration-300 hover:scale-110">
                            <svg class="w-3 md:w-4 h-3 md:h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
                            </svg>
                        </button>
                    </div>

                    <!-- Artist Info -->
                    <div class="text-center">
                        <a href="{{ route('artist.show', $artist) }}" class="block">
                            <h4 class="text-gray-200 hover:text-blue-600 transition-colors font-medium text-sm md:text-base leading-tight mb-1 truncate px-2"
                                title="{{ $artist }}">
                                {{ Str::limit($artist, 15) }}
                            </h4>
                            <p class="text-xs text-gray-200 px-2">Artist</p>
                        </a>
                    </div>
                </div>
                @endforeach
            </div>
        </div>
    </div>

  <!-- Recently Played Section -->
    <div class="px-4 md:px-6 mb-6 md:mb-8 mx-8">
        <div class="max-w-7xl mx-auto">
        <div class="flex items-center justify-between mb-4 md:mb-6">
            <h2 class="text-xl md:text-2xl font-bold text-teal-400 hover:underline cursor-pointer">Recently played</h2>
        </div>

        <!-- Horizontal Scroll Cards -->
        <div class="flex space-x-4 md:space-x-6 overflow-x-auto pb-4 scrollbar-thin scrollbar-thumb-gray-400 scrollbar-track-transparent">
            @foreach($music->take(8) as $song)
            <div class="group bg-white/70 hover:bg-white/90 backdrop-blur-sm rounded-xl p-3 md:p-4 min-w-[160px] md:min-w-[200px] max-w-[160px] md:max-w-[200px] cursor-pointer transition-all duration-300 hover:scale-105 flex-shrink-0 border border-gray-300/30 shadow-sm hover:shadow-lg">
            <!-- Album Art -->
            <div class="relative mb-3 md:mb-4">
                <div class="w-full aspect-square rounded-xl bg-gradient-to-br from-blue-500 to-teal-600 flex items-center justify-center shadow-xl overflow-hidden">
                @if($song->thumbnail)
                    <img src="{{ $song->thumbnail }}" alt="{{ $song->title }}" class="w-full h-full object-cover rounded-xl"
                    onclick="playAudio('{{ $song->id }}', '{{ $song->file_path }}', '{{ $song->title }}', '{{ $song->artist ?? "Unknown Artist" }}', '{{ $song->thumbnail }}')">
                @else
                    <svg class="w-12 md:w-16 h-12 md:h-16 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                    </svg>
                @endif
                </div>
            </div>

            <!-- Song Info -->
            <div class="w-full overflow-hidden">
                <div class="flex items-start justify-between space-x-2">
                <button onclick="playAudio('{{ $song->id }}', '{{ addslashes($song->file_path) }}', '{{ addslashes($song->title) }}', '{{ addslashes($song->artist ?? "Unknown Artist") }}', '{{ addslashes($song->thumbnail ?? "") }}')"
                        class="text-left flex-1 min-w-0 overflow-hidden">
                    <h4 class="text-gray-800 hover:text-blue-600 transition-colors font-medium text-sm md:text-base leading-tight mb-1 break-words"
                        title="{{ $song->title }}">
                    {{ Str::limit($song->title, 20) }}
                    </h4>
                    @if($song->artist)
                    <p class="text-xs text-gray-600 mb-1 break-words leading-tight"
                        title="{{ $song->artist }}">
                        {{ Str::limit($song->artist, 15) }}
                    </p>
                    @endif
                    @if($song->album)
                    <p class="text-xs text-gray-600 break-words leading-tight"
                        title="{{ $song->album }}">
                        {{ Str::limit($song->album, 15) }}
                    </p>
                    @endif
                </button>
                <a href="{{ route('music.show', $song) }}"
                    class="opacity-100 text-blue-600 hover:text-blue-700 text-xs font-medium transition-all whitespace-nowrap flex-shrink-0">
                    More
                </a>
                </div>
            </div>
            </div>
            @endforeach
        </div>
        </div>
    </div>

  <!-- All Songs Section -->
<div class="px-4 md:px-6 pb-20 mx-8">
    <div class="max-w-7xl mx-auto">
      <div class="flex items-center justify-between mb-4 md:mb-6">
        <h2 class="text-xl md:text-2xl font-bold text-teal-400">Made for you</h2>
        <div class="flex items-center space-x-4">
          <button class="text-gray-600 hover:text-gray-900 text-sm">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd" />
            </svg>
          </button>
          <button class="text-gray-600 hover:text-gray-900 text-sm">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm3 2h6v4H7V5zm8 8v2h1v-2h-1zm-2-2H4v4h9v-4z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>

      <!-- Songs List -->
      <div class="bg-white/80 backdrop-blur-sm rounded-xl border border-gray-300/50 shadow-lg overflow-hidden">
        <!-- List Header - Desktop Only -->
        <div class="hidden md:block sticky top-0 px-6 py-3 bg-gray-50/90 backdrop-blur-sm border-b border-gray-300/50 text-gray-700 text-sm font-medium uppercase tracking-wide">
          <div class="grid grid-cols-12 gap-4 items-center">
            <div class="col-span-1 text-center">#</div>
            <div class="col-span-6">Title</div>
            <div class="col-span-3">Artist</div>
            <div class="col-span-2 text-center">
              <svg class="w-4 h-4 mx-auto" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.414-1.414L11 9.586V6z" clip-rule="evenodd" />
              </svg>
            </div>
          </div>
        </div>

        <!-- Songs -->
        <div class="p-2">
          @forelse($music as $index => $song)
          <!-- Desktop Layout -->
          <div class="hidden md:grid group grid-cols-12 gap-4 items-center py-3 px-4 rounded-lg hover:bg-gray-100/70 transition-all duration-200 cursor-pointer">
            <!-- Track Number / Play Button -->
            <div class="col-span-1 text-center">
              <span class="group-hover:hidden text-gray-700 text-sm font-medium">{{ ($music->currentPage() - 1) * $music->perPage() + $index + 1 }}</span>
              <a href="{{ route('music.show', $song) }}" class="hidden group-hover:block text-blue-600 hover:text-blue-700 hover:scale-110 transition-all">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
                </svg>
              </a>
            </div>

            <!-- Song Info with Thumbnail -->
            <div class="col-span-6 min-w-0">
              <div class="flex items-center">
                <!-- Mini Thumbnail -->
                <div class="w-10 h-10 rounded bg-gradient-to-br from-blue-500 to-teal-600 flex items-center justify-center mr-3 flex-shrink-0">
                  @if($song->thumbnail)
                    <img src="{{ $song->thumbnail }}" alt="{{ $song->title }}" class="w-full h-full object-cover rounded">
                  @else
                    <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                    </svg>
                  @endif
                </div>

                <div class="min-w-0">
                  <a href="{{ route('music.show', $song) }}" class="block">
                    <h4 class="text-gray-900 hover:text-blue-600 transition-colors truncate font-medium text-base">
                      {{ $song->title }}
                    </h4>
                    @if($song->album)
                      <p class="text-xs text-gray-600 truncate mt-1">{{ $song->album }}</p>
                    @endif
                  </a>
                </div>
              </div>
            </div>

            <!-- Artist -->
            <div class="col-span-3 text-gray-700 truncate hover:text-gray-900 hover:underline cursor-pointer transition-colors">
              {{ $song->artist ?? 'Unknown Artist' }}
            </div>

            <!-- Duration with Actions -->
            <div class="col-span-2 flex items-center justify-center space-x-3">
              <button class="opacity-0 group-hover:opacity-100 text-gray-600 hover:text-red-500 transition-all duration-200 hover:scale-110">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" />
                </svg>
              </button>
              <span class="text-gray-600 text-sm font-medium">
                {{ $song->duration ? gmdate("i:s", $song->duration) : rand(2, 5) . ':' . str_pad(rand(0, 59), 2, '0', STR_PAD_LEFT) }}
              </span>
              <button class="opacity-0 group-hover:opacity-100 text-gray-600 hover:text-gray-900 transition-all duration-200 hover:scale-110">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                </svg>
              </button>
            </div>
          </div>

          <!-- Mobile Layout -->
          <div class="md:hidden group bg-white/70 hover:bg-white/90 backdrop-blur-sm rounded-xl p-4 mb-3 border border-gray-300/30 shadow-sm hover:shadow-lg transition-all duration-200">
            <div class="flex items-center space-x-3">
              <!-- Thumbnail -->
              <div class="w-12 h-12 rounded bg-gradient-to-br from-blue-500 to-teal-600 flex items-center justify-center flex-shrink-0">
                @if($song->thumbnail)
                  <img src="{{ $song->thumbnail }}" alt="{{ $song->title }}" class="w-full h-full object-cover rounded">
                @else
                  <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                  </svg>
                @endif
              </div>

              <!-- Song Info -->
              <div class="flex-1 min-w-0">
                <a href="{{ route('music.show', $song) }}" class="block">
                  <h4 class="text-gray-900 hover:text-blue-600 transition-colors truncate font-medium text-base">
                    {{ $song->title }}
                  </h4>
                  <p class="text-sm text-gray-600 truncate">{{ $song->artist ?? 'Unknown Artist' }}</p>
                  @if($song->album)
                    <p class="text-xs text-gray-500 truncate mt-1">{{ $song->album }}</p>
                  @endif
                </a>
              </div>

              <!-- Actions -->
              <div class="flex flex-col items-center space-y-2">
                <button class="text-gray-600 hover:text-red-500 transition-all duration-200">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" />
                  </svg>
                </button>
                <span class="text-gray-600 text-xs font-medium">
                  {{ $song->duration ? gmdate("i:s", $song->duration) : rand(2, 5) . ':' . str_pad(rand(0, 59), 2, '0', STR_PAD_LEFT) }}
                </span>
              </div>
            </div>
          </div>
          @empty
          <div class="text-center py-20">
            <div class="w-16 md:w-24 h-16 md:h-24 mx-auto mb-6 bg-gray-300 rounded-full flex items-center justify-center">
              <svg class="w-8 md:w-12 h-8 md:h-12 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
              </svg>
            </div>
            <h3 class="text-lg md:text-xl font-semibold text-gray-800 mb-2">No music found</h3>
            <p class="text-gray-600 text-sm md:text-base">Add some songs to start listening!</p>
          </div>
          @endforelse
        </div>
      </div>

        <!-- Pagination -->
        @if($music->hasPages())
        <div class="mt-8 flex justify-center">
            <nav class="flex items-center space-x-1">
            {{-- Previous Page Link --}}
            @if ($music->onFirstPage())
            <span class="px-3 py-2 text-gray-500 bg-gray-300 rounded-lg cursor-not-allowed">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
                </svg>
            </span>
        @else
            <a href="{{ $music->previousPageUrl() }}" class="px-3 py-2 text-gray-700 bg-white hover:bg-gray-100 hover:text-gray-900 rounded-lg transition-all duration-200 border border-gray-300">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
                </svg>
            </a>
        @endif

            {{-- Pagination Elements --}}
            @foreach ($music->getUrlRange(1, $music->lastPage()) as $page => $url)
            @if ($page == 1 || $page == $music->lastPage() || ($page >= $music->currentPage() - 2 && $page <= $music->currentPage() + 2))
                @if ($page == $music->currentPage())
                    <span class="px-4 py-2 bg-teal-600 text-white rounded-lg font-medium">{{ $page }}</span>
                @else
                    <a href="{{ $url }}" class="px-4 py-2 text-gray-700 bg-white hover:bg-gray-100 hover:text-gray-900 rounded-lg transition-all duration-200 border border-gray-300">{{ $page }}</a>
                @endif
            @elseif ($page == $music->currentPage() - 3 || $page == $music->currentPage() + 3)
                <span class="px-3 py-2 text-gray-500">...</span>
            @endif
        @endforeach

          {{-- Next Page Link --}}
          @if ($music->hasMorePages())
            <a href="{{ $music->nextPageUrl() }}" class="px-3 py-2 text-gray-700 bg-white hover:bg-gray-100 hover:text-gray-900 rounded-lg transition-all duration-200 border border-gray-300">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </a>
          @else
            <span class="px-3 py-2 text-gray-500 bg-gray-300 rounded-lg cursor-not-allowed">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </span>
          @endif
        </nav>
      </div>

      <!-- Pagination Info -->
      <div class="mt-4 text-center text-gray-200 text-sm">
        Showing {{ $music->lastItem() }} of {{ $music->total() }} songs
      </div>
      @endif
    </div>

    <audio id="audioPlayer" preload="metadata" style="display: none;">
      <source id="audioSource" src="" type="audio/mpeg">
      Your browser does not support the audio element.
    </audio>
  </div>

  <!-- Current Time Display -->
  <div class="fixed bottom-6 right-6 z-20">
    <div class="bg-white/80 backdrop-blur-sm rounded-lg px-3 py-2 border border-gray-300/50 shadow-lg">
      <div class="text-right text-gray-800">
        <div class="text-xs text-blue-600 font-medium">NOW</div>
        <div class="text-sm font-bold" id="current-time">10:58 AM</div>
      </div>
    </div>
  </div>

  <!-- Mini Player Widget -->
    <div id="miniPlayer" class="fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur-sm border-t border-gray-200 p-4 transform translate-y-full transition-transform duration-300 z-50 hidden">
        <div class="max-w-7xl mx-auto flex items-center justify-between">
        <!-- Song Info -->
        <div class="flex items-center space-x-4 flex-1 min-w-0">
            <div class="w-14 h-14 rounded bg-gradient-to-br from-blue-600 to-blue-800 flex-shrink-0">
            <img id="miniThumbnail" src="" alt="" class="w-full h-full object-cover rounded hidden">
            <div id="miniThumbnailPlaceholder" class="w-full h-full flex items-center justify-center">
                <svg class="w-6 h-6 text-blue-300" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                </svg>
            </div>
            </div>
            <div class="min-w-0 flex-1">
            <h4 id="miniTitle" class="text-gray-700 font-medium truncate">Song Title</h4>
            <p id="miniArtist" class="text-gray-400 text-sm truncate">Artist Name</p>
            </div>
            <button class="text-gray-400 hover:text-gray-700 p-2">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" />
            </svg>
            </button>
        </div>

      <!-- Progress & Volume -->
      <div class="flex items-center space-x-4 flex-1 justify-end">
        <button class="text-gray-400 hover:text-gray-700">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M8.445 14.832A1 1 0 0010 14v-2.798l5.445 3.63A1 1 0 0017 14V6a1 1 0 00-1.555-.832L10 8.798V6a1 1 0 00-1.555-.832l-6 4a1 1 0 000 1.664l6 4z" />
            </svg>
            </button>
            <button id="miniPlayBtn" class="w-8 h-8 bg-gradient-to-r from-blue-500 to-teal-600 text-white rounded-full flex items-center justify-center hover:scale-105 transition-transform">
            <svg id="miniPlayIcon" class="w-4 h-4 ml-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
            </svg>
            <svg id="miniPauseIcon" class="w-4 h-4 hidden" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
            </button>
            <button class="text-gray-400 hover:text-gray-700">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M4.555 5.168A1 1 0 003 6v8a1 1 0 001.555.832L10 11.202V14a1 1 0 001.555.832l6-4a1 1 0 000-1.664l-6-4A1 1 0 0010 6v2.798l-5.445-3.63z" />
            </svg>
            </button>
        <button id="miniCloseBtn" class="text-gray-400 hover:text-gray-700 p-1">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>
    </div>
  </div>
</div>

    {{-- Sync Modal --}}
<div id="syncModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 transform transition-all duration-300 scale-100">
        <!-- Header -->
        <div class="flex items-center justify-between p-6 border-b border-gray-200">
            <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-gradient-to-r from-blue-600 to-teal-600 rounded-full flex items-center justify-center">
                    <svg class="w-5 h-5 text-gray-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                    </svg>
                </div>
                <div>
                    <h3 class="text-lg font-semibold text-gray-900">Admin Verification</h3>
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
                               class="w-full px-4 py-3 border text-black border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 pr-12"
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
                        class="px-6 py-2 bg-gradient-to-r from-blue-600 to-teal-600 hover:from-blue-700 hover:to-teal-700 text-gray-200 rounded-lg transition-all duration-200 font-medium shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none">
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

@push('styles')
<link rel="stylesheet" href="{{ asset('css/music-index.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/music-index.js') }}"></script>
@endpush
@endsection
