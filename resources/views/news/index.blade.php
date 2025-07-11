@extends('layouts.app', ['title' => 'News'])

@section('content')
<div class="min-h-screen bg-gray-200">
    <!-- Top Header -->
    <header class="bg-gray-200 border-b border-gray-200 sticky top-0 z-50 shadow-sm">
        <div class="max-w-7xl mx-auto px-4">
            <!-- Logo and Navigation -->
            <div class="flex items-center justify-between py-3">
                <!-- Logo -->
                <div class="flex items-center">
                    <img src="{{ asset('images/logo/Logo-MaxG-Green.gif') }}" alt="Garuda Airlines" class="h-8 w-auto">
                    <span class="ml-3 text-xl font-bold text-gray-800">.newspaper</span>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-4 py-6">
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">

            <!-- Left Content - Main News -->
            <div class="lg:col-span-3">
                <!-- Featured News -->
                <div class="mb-8">
                    @if($sports->isNotEmpty())
                        @php $featuredArticle = $sports->first() @endphp
                        <div class="relative group cursor-pointer">
                            <a href="{{ route('news.show', $featuredArticle->slug) }}" class="relative group cursor-pointer">
                                <div class="relative h-80 md:h-96 rounded-lg overflow-hidden">
                                @if($featuredArticle->urlToImage)
                                    <img src="{{ $featuredArticle->urlToImage }}"
                                         alt="{{ $featuredArticle->title }}"
                                         class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                @else
                                    <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                        <span class="text-gray-400">No Image</span>
                                    </div>
                                @endif

                                <!-- Overlay -->
                                <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

                                <!-- Category Badge -->
                                <div class="absolute top-4 left-4">
                                    <span class="bg-green-600 text-white px-3 py-1 rounded text-sm font-medium">
                                        Headline
                                    </span>
                                </div>

                                <!-- Content -->
                                <div class="absolute bottom-0 left-0 right-0 p-6 text-white">
                                    <h1 class="text-2xl md:text-3xl font-bold mb-3 leading-tight">
                                        {{ $featuredArticle->title }}
                                    </h1>
                                    <p class="text-gray-200 mb-3 line-clamp-2">
                                        {{ $featuredArticle->description }}
                                    </p>
                                    <div class="flex items-center text-sm text-gray-300">
                                        <span class="mr-4">{{ $featuredArticle->source ?? 'Garuda News' }}</span>
                                        <span>{{ $featuredArticle->published_at ? $featuredArticle->published_at->diffForHumans() : 'Just now' }}</span>
                                    </div>
                                </div>
                            </div>
                            </a>
                        </div>
                    @endif
                </div>

                <!-- Secondary News Grid -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    @foreach($sports->skip(1)->take(3) as $article)
                    <a href="{{ route('news.show', $article->slug) }}" class="group cursor-pointer">
                    <article class="group cursor-pointer">
                        <div class="relative h-48 rounded-lg overflow-hidden mb-3">
                            @if($article->urlToImage)
                                <img src="{{ $article->urlToImage }}"
                                     alt="{{ $article->title }}"
                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                            @else
                                <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                    <span class="text-gray-400 text-sm">No Image</span>
                                </div>
                            @endif

                            <!-- Category Badge -->
                            <div class="absolute top-3 left-3">
                                <span class="bg-green-600 text-white px-2 py-1 rounded text-xs font-medium">
                                    {{ $article->source ?? 'NEWS' }}
                                </span>
                            </div>
                        </div>

                        <h3 class="font-bold text-gray-900 mb-2 line-clamp-2 group-hover:text-green-600 transition-colors">
                            {{ $article->title }}
                        </h3>

                        <div class="flex items-center text-sm text-gray-500">
                            <span class="mr-3">{{ $article->source ?? 'Garuda News' }}</span>
                            <span>{{ $article->published_at ? $article->published_at->diffForHumans() : 'Just now' }}</span>
                        </div>
                    </article>
                    </a>
                    @endforeach
                </div>

                <!-- Category Sections -->
                <div class="space-y-8 mb-5">
                    <!-- Sports Section -->
                    <section id="sports" class="sports">
                        <div class="flex items-center justify-between mb-6">
                            <div class="flex items-center">
                                <h2 class="text-2xl font-bold text-gray-900 mr-4">Sports</h2>
                                <div class="flex-1 h-px bg-gray-200"></div>
                            </div>
                            <a href="{{ route('news.sports') }}"
                            class="text-green-600 hover:text-green-800 font-medium text-sm whitespace-nowrap ml-4 transition-colors">
                                Read More →
                            </a>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            @foreach($sports->skip(4)->take(2) as $article)
                            <a href="{{ route('news.show', $article->slug) }}" class="flex group cursor-pointer">
                            <article class="flex group cursor-pointer">
                                <div class="flex-shrink-0 w-32 h-24 rounded overflow-hidden mr-4">
                                    @if($article->urlToImage)
                                        <img src="{{ $article->urlToImage }}"
                                            alt="{{ $article->title }}"
                                            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                    @else
                                        <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                            <span class="text-gray-400 text-xs">No Image</span>
                                        </div>
                                    @endif
                                </div>

                                <div class="flex-1">
                                    <h3 class="font-semibold text-gray-900 mb-2 line-clamp-3 group-hover:text-green-600 transition-colors">
                                        {{ $article->title }}
                                    </h3>
                                    <div class="text-sm text-gray-500">
                                        <span class="text-green-600 font-medium">SPORTS</span>
                                    </div>
                                </div>
                            </article>
                            </a>
                            @endforeach
                        </div>
                    </section>

                    <!-- Politics Section -->
                    <section id="politics" class="politics">
                        <div class="flex items-center justify-between mb-6">
                            <div class="flex items-center">
                                <h2 class="text-2xl font-bold text-gray-900 mr-4">Politics</h2>
                                <div class="flex-1 h-px bg-gray-200"></div>
                            </div>
                            <a href="{{ route('news.politics') }}"
                            class="text-green-600 hover:text-green-800 font-medium text-sm whitespace-nowrap ml-4 transition-colors">
                                Read More →
                            </a>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            @foreach($politics->take(2) as $article)
                            <a href="{{ route('news.show', $article->slug) }}" class="flex group cursor-pointer">
                            <article class="flex group cursor-pointer">
                                <div class="flex-shrink-0 w-32 h-24 rounded overflow-hidden mr-4">
                                    @if($article->urlToImage)
                                        <img src="{{ $article->urlToImage }}"
                                            alt="{{ $article->title }}"
                                            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                    @else
                                        <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                            <span class="text-gray-400 text-xs">No Image</span>
                                        </div>
                                    @endif
                                </div>

                                <div class="flex-1">
                                    <h3 class="font-semibold text-gray-900 mb-2 line-clamp-3 group-hover:text-green-600 transition-colors">
                                        {{ $article->title }}
                                    </h3>
                                    <div class="text-sm text-gray-500">
                                        <span class="text-green-600 font-medium">POLITICS</span>
                                    </div>
                                </div>
                            </article>
                            </a>
                            @endforeach
                        </div>
                    </section>

                    <!-- Entertainment Section -->
                    <section id="entertainment" class="entertainment">
                        <div class="flex items-center justify-between mb-6">
                            <div class="flex items-center">
                                <h2 class="text-2xl font-bold text-gray-900 mr-4">Entertainment</h2>
                                <div class="flex-1 h-px bg-gray-200"></div>
                            </div>
                            <a href="{{ route('news.entertainment') }}"
                            class="text-green-600 hover:text-green-800 font-medium text-sm whitespace-nowrap ml-4 transition-colors">
                                Read More →
                            </a>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            @foreach($entertainment->take(2) as $article)
                            <a href="{{ route('news.show', $article->slug) }}" class="flex group cursor-pointer">
                            <article class="flex group cursor-pointer">
                                <div class="flex-shrink-0 w-32 h-24 rounded overflow-hidden mr-4">
                                    @if($article->urlToImage)
                                        <img src="{{ $article->urlToImage }}"
                                            alt="{{ $article->title }}"
                                            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                    @else
                                        <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                            <span class="text-gray-400 text-xs">No Image</span>
                                        </div>
                                    @endif
                                </div>

                                <div class="flex-1">
                                    <h3 class="font-semibold text-gray-900 mb-2 line-clamp-3 group-hover:text-green-600 transition-colors">
                                        {{ $article->title }}
                                    </h3>
                                    <div class="text-sm text-gray-500">
                                        <span class="text-green-600 font-medium">ENTERTAINMENT</span>
                                    </div>
                                </div>
                            </article>
                            </a>
                            @endforeach
                        </div>
                    </section>
                </div>
            </div>

            <!-- Right Sidebar - Popular Articles -->
            <div class="lg:col-span-1">
                <div class="sticky">
                    <!-- Popular Section -->
                    <div class="bg-green-700 border border-gray-200 rounded-lg pb-24 pt-6 px-6">
                        <h3 class="text-xl font-bold text-gray-200 mb-4 flex items-center">
                            <span class="w-1 h-6 bg-gray-200 rounded mr-3"></span>
                            Popular
                        </h3>

                        <div class="space-y-4 mt-8">
                            @foreach($sports->take(5) as $index => $article)
                            <a href="{{ route('news.show', $article->slug) }}" class="flex group cursor-pointer">
                            <article class="flex group cursor-pointer">
                                <div class="flex-shrink-0 w-8 h-8 bg-green-600 text-white rounded flex items-center justify-center text-sm font-bold mr-3 mt-1">
                                    {{ $index + 1 }}
                                </div>

                                <div class="flex-1">
                                    <h4 class="font-semibold text-gray-200 text-sm line-clamp-3 group-hover:text-teal-500 transition-colors mb-2">
                                        {{ $article->title }}
                                    </h4>
                                    <div class="text-xs text-gray-400 uppercase font-medium tracking-wide">
                                        {{ $article->source ?? 'NEWS' }}
                                    </div>
                                </div>
                            </article>

                            @if(!$loop->last)
                            <hr class="border-gray-200">
                            @endif
                            </a>
                            @endforeach
                        </div>
                    </div>

                    <!-- Latest News -->
                    <div class="bg-gray-200 border border-gray-200 rounded-lg p-4">
                        <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center">
                            <span class="w-1 h-6 bg-green-600 rounded mr-3"></span>
                            Latest
                        </h3>

                        <div class="space-y-4">
                            @foreach($politics->take(5) as $article)
                            <a href="{{ route('news.show', $article->slug) }}" class="flex group cursor-pointer">
                            <article class="group cursor-pointer">
                                <h4 class="font-semibold text-gray-900 text-sm line-clamp-2 group-hover:text-green-600 transition-colors mb-2">
                                    {{ $article->title }}
                                </h4>
                                <div class="text-xs text-gray-500">
                                    {{ $article->published_at ? $article->published_at->diffForHumans() : 'Just now' }}
                                </div>
                            </article>

                            @if(!$loop->last)
                            <hr class="border-gray-200">
                            @endif
                            </a>
                            @endforeach
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script src="{{ asset('js/news-index.js') }}"></script>
@endpush

@push('styles')
<link rel="stylesheet" href="{{ asset('css/news-index.css') }}">
@endpush
@endsection
