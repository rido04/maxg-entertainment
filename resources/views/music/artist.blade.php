@extends('layouts.app')

@section('content')
<div class="min-h-screen text-gray-700 bg-gray-200">
    <!-- Artist Hero Section -->
    <div class="relative">
        <!-- Background Gradient -->
        <div class="absolute inset-0 bg-gradient-to-b from-green-400 via-green-800 to-green-950"></div>

        <!-- Artist Header -->
        <div class="relative px-6 pt-16 pb-8">
            <div class="max-w-7xl mx-auto">
                <!-- Back Button -->
                <div class="mb-6">
                    <button onclick="history.back()" class="flex items-center space-x-2 text-gray-200 hover:text-red-600 transition-colors group">
                        <svg class="w-6 h-6 transform group-hover:-translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                        </svg>
                        <span class="font-medium">Back</span>
                    </button>
                </div>

                <div class="flex items-end space-x-6">
                    <!-- Artist Image -->
                    <div class="flex-shrink-0">
                        <div class="w-40 h-40 md:w-56 md:h-56 rounded-full bg-gradient-to-br from-yellow-600 via-yellow-700 to-gray-800 flex items-center justify-center shadow-2xl overflow-hidden border-4 border-blue-500/30">
                            @php
                                $artistSong = $music->first();
                            @endphp
                            @if($artistSong && $artistSong->artist_image)
                                <img src="{{ $artistSong->artist_image }}" alt="{{ $artist }}" class="w-full h-full object-cover rounded-full">
                            @else
                                <div class="w-24 h-24 text-blue-300">
                                    <svg fill="currentColor" viewBox="0 0 20 20" class="w-full h-full">
                                        <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
                                    </svg>
                                </div>
                            @endif
                        </div>
                    </div>

                    <!-- Artist Info -->
                    <div class="flex-1 min-w-0 pb-4">
                        <div class="flex items-center mb-2">
                            <svg class="w-5 h-5 text-teal-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                            </svg>
                            <span class="text-sm font-medium text-teal-400 uppercase tracking-wider">Verified Artist</span>
                        </div>
                        <h1 class="text-5xl md:text-7xl lg:text-8xl font-black mb-6 bg-gradient-to-r from-white via-blue-100 to-gray-300 bg-clip-text text-transparent">
                            {{ $artist }}
                        </h1>
                        <div class="flex items-center space-x-1 text-gray-300">
                            <span class="font-medium">{{ number_format($music->count()) }} songs</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Popular Songs Section -->
    <div class="px-6 pb-8">
        <div class="max-w-7xl mx-auto">
            <h2 class="text-2xl font-bold text-gray-700 mb-6 mt-6">Popular</h2>

            <!-- Songs List -->
            <div class="space-y-2" id="popular-songs-list">
                @forelse($music as $index => $song)
                <div class="group grid grid-cols-12 gap-4 items-center py-2 px-4 rounded-lg hover:bg-gray-800/50 transition-all duration-200 cursor-pointer song-row {{ $index >= 5 ? 'hidden' : '' }}" data-song-index="{{ $index }}">
                    <!-- Track Number / Play Button -->
                    <div class="col-span-1">
                        <span class="group-hover:hidden text-gray-400 text-lg font-medium track-number">{{ $index + 1 }}</span>
                        <button class="hidden group-hover:block text-gray-700 hover:scale-110 transition-all play-btn" onclick="playSong({{ $index }})">
                            <svg class="w-5 h-5 play-icon group-hover:text-white" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
                            </svg>
                            <svg class="w-5 h-5 pause-icon hidden" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                            </svg>
                        </button>
                    </div>

                    <!-- Song Info -->
                    <div class="col-span-8 min-w-0">
                        <div class="flex items-center">
                            <div class="w-10 h-10 rounded bg-gradient-to-br from-blue-600 to-gray-700 flex items-center justify-center mr-4 flex-shrink-0">
                                @if($song->thumbnail)
                                    <img src="{{ $song->thumbnail }}" alt="{{ $song->title }}" class="w-full h-full object-cover rounded">
                                @else
                                    <svg class="w-5 h-5 text-blue-300 group-hover:text-white" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                                    </svg>
                                @endif
                            </div>
                            <div class="min-w-0">
                                <h4 class="text-gray-700 group-hover:text-white hover:underline transition-colors truncate font-medium text-base cursor-pointer song-title">
                                    {{ $song->title }}
                                </h4>
                                @if($song->album)
                                    <p class="text-sm text-gray-400 group-hover:text-white truncate">{{ $song->album }}</p>
                                @endif
                            </div>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="col-span-3 flex items-center justify-end space-x-4">
                        <a href="{{ route('music.show', $song->id) }}" class="text-gray-700 group-hover:text-blue-700 hover:text-blue-400 transition-all duration-200 text-xs font-medium uppercase tracking-wider">
                            Detail
                        </a>
                        <button class="opacity-0 group-hover:opacity-100 text-gray-700 hover:text-red-400 transition-all duration-200">
                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" />
                            </svg>
                        </button>
                        <span class="text-gray-400 text-sm group-hover:text-white transition-colors duration-200">
                            {{ $song->duration ? gmdate("i:s", $song->duration) : rand(2, 5) . ':' . str_pad(rand(0, 59), 2, '0', STR_PAD_LEFT) }}
                        </span>
                    </div>
                </div>
                <!-- Hidden audio element for each song -->
                <audio class="song-audio" data-index="{{ $index }}" preload="none">
                    @if($song->file_path)
                    <source src="{{ asset($song->file_path) }}" type="audio/mpeg">
                    @endif
                </audio>
                @empty
                <div class="text-center py-12">
                    <div class="w-16 h-16 mx-auto mb-4 bg-gray-700 rounded-full flex items-center justify-center">
                        <svg class="w-8 h-8 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                        </svg>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-700 mb-2">No songs found</h3>
                    <p class="text-gray-400">This artist doesn't have any songs yet.</p>
                </div>
                @endforelse
            </div>

            <!-- Show More/Show Less Button -->
            @if($music->count() > 5)
            <div class="mt-6 text-center">
                <button id="show-more-btn" onclick="toggleShowMore()" class="text-gray-400 hover:text-white text-sm font-semibold uppercase tracking-wider transition-colors duration-200 hover:underline">
                    <span id="show-more-text">Show {{ $music->count() - 5 }} more songs</span>
                </button>
            </div>
            @endif
        </div>
    </div>

    <!-- Music Player Controls (Fixed Bottom) -->
    <div id="music-player" class="fixed bottom-0 left-0 right-0 bg-gray-900/95 backdrop-blur-sm border-t border-gray-700/50 px-6 py-4 hidden z-50">
        <div class="max-w-7xl mx-auto">
            <div class="flex items-center justify-between">
                <!-- Current Song Info -->
                <div class="flex items-center space-x-4 flex-1 min-w-0">
                    <div class="w-12 h-12 rounded bg-gradient-to-br from-blue-600 to-gray-700 flex items-center justify-center flex-shrink-0">
                        <img id="current-thumbnail" src="" alt="" class="w-full h-full object-cover rounded hidden">
                        <svg id="default-icon" class="w-6 h-6 text-blue-300" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 3a1 1 0 00-1.447-.894L8.763 6H5a3 3 0 000 6h.28l1.771 5.316A1 1 0 008 18h1a1 1 0 001-1v-4.382l6.553 3.276A1 1 0 0018 15V3z" clip-rule="evenodd" />
                        </svg>
                    </div>
                    <div class="min-w-0">
                        <h4 id="current-title" class="text-white font-medium text-sm truncate">Select a song</h4>
                        <p id="current-artist" class="text-gray-400 text-xs truncate">{{ $artist }}</p>
                    </div>
                </div>

                <!-- Player Controls -->
                <div class="flex items-center space-x-4">
                    <button onclick="previousSong()" class="text-gray-400 hover:text-white transition-colors">
                        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M8.445 14.832A1 1 0 0010 14v-2.798l5.445 3.63A1 1 0 0017 14V6a1 1 0 00-1.555-.832L10 8.798V6a1 1 0 00-1.555-.832l-6 4a1 1 0 000 1.664l6 4z" />
                        </svg>
                    </button>
                    <button id="main-play-btn" onclick="togglePlayPause()" class="bg-blue-500 hover:bg-blue-600 text-white rounded-full p-2 transition-colors">
                        <svg id="main-play-icon" class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
                        </svg>
                        <svg id="main-pause-icon" class="w-5 h-5 hidden" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                        </svg>
                    </button>
                    <button onclick="nextSong()" class="text-gray-400 hover:text-white transition-colors">
                        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M4.555 5.168A1 1 0 003 6v8a1 1 0 001.555.832L10 11.202V14a1 1 0 001.555.832l6-4a1 1 0 000-1.664l-6-4A1 1 0 0010 6v2.798l-5.445-3.63z" />
                        </svg>
                    </button>
                </div>

                <!-- Volume Control -->
                <div class="hidden md:flex items-center space-x-2">
                    <svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.617.776L4.146 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.146l4.237-3.776a1 1 0 011.617.776zM14.657 2.929a1 1 0 011.414 0A9.972 9.972 0 0119 10a9.972 9.972 0 01-2.929 7.071 1 1 0 01-1.414-1.414A7.971 7.971 0 0017 10c0-2.21-.894-4.208-2.343-5.657a1 1 0 010-1.414zm-2.829 2.828a1 1 0 011.415 0A5.983 5.983 0 0115 10a5.984 5.984 0 01-1.757 4.243 1 1 0 01-1.415-1.415A3.984 3.984 0 0013 10a3.983 3.983 0 00-1.172-2.828 1 1 0 010-1.415z" clip-rule="evenodd" />
                    </svg>
                    <input type="range" min="0" max="100" value="50" class="w-20 h-1 bg-gray-600 rounded-lg appearance-none cursor-pointer" id="volume-slider">
                </div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script src="{{ asset('js/music-artist.js') }}"></script>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Prepare playlist data dari PHP
    const playlistData = [
        @if($music->count() > 0)
            @foreach($music as $index => $song)
            {
                index: {{ $index }},
                title: @json($song->title),
                artist: @json($song->artist),
                thumbnail: @json($song->thumbnail ?? ''),
                file_path: @json($song->file_path ? asset($song->file_path) : ''),
                album: @json($song->album ?? '')
            }{{ $loop->last ? '' : ',' }}
            @endforeach
        @endif
    ];

    // Initialize player
    window.artistPlayer = new ArtistPlayer({
        playlist: playlistData,
        totalSongs: {{ $music->count() }}
    });
});
</script>

@endpush

@push('styles')
<link rel="stylesheet" href="{{ asset('css/music-artist.css') }}">
@endpush
@endsection
