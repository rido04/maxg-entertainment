@extends('layouts.app')

@section('title', 'Sports News')

@section('content')
<div class="min-h-screen bg-gray-50">
    <div class="max-w-6xl mx-auto px-4 py-8">
        <!-- Header -->
        <div class="mb-8">
            <div class="flex items-center mb-4">
                <a href="{{ route('news.index') }}" class="text-blue-600 hover:text-blue-800 mr-2">
                    ← Back to Home
                </a>
            </div>
            <h1 class="text-4xl font-bold text-gray-900 mb-2">Sports</h1>
            <p class="text-gray-600">Latest Sports news and updates</p>
        </div>

        <!-- Articles Grid -->
        @if($articles->count() > 0)
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
                @foreach($articles as $article)
                    <article class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300">
                        <a href="{{ route('news.show', $article->slug) }}" class="block">
                            <!-- Image -->
                            <div class="aspect-video overflow-hidden">
                                @if($article->urlToImage)
                                    <img src="{{ $article->urlToImage }}"
                                         alt="{{ $article->title }}"
                                         class="w-full h-full object-cover hover:scale-105 transition-transform duration-300">
                                @else
                                    <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                        <span class="text-gray-400">No Image</span>
                                    </div>
                                @endif
                            </div>

                            <!-- Content -->
                            <div class="p-6">
                                <!-- Category Badge -->
                                <div class="mb-3">
                                    <span class="inline-block px-3 py-1 text-xs font-semibold text-purple-600 bg-purple-100 rounded-full uppercase">
                                        Sports
                                    </span>
                                </div>

                                <!-- Title -->
                                <h2 class="text-xl font-semibold text-gray-900 mb-3 line-clamp-2 hover:text-blue-600 transition-colors">
                                    {{ $article->title }}
                                </h2>

                                <!-- Description -->
                                @if($article->description)
                                    <p class="text-gray-600 text-sm mb-4 line-clamp-3">
                                        {{ $article->description }}
                                    </p>
                                @endif

                                <!-- Meta Info -->
                                <div class="flex items-center justify-between text-sm text-gray-500">
                                    @if($article->author)
                                        <span>By {{ $article->author }}</span>
                                    @else
                                        <span>{{ optional($article->source)->name ?? 'Unknown Source' }}</span>
                                    @endif
                                    <span>{{ $article->published_at->diffForHumans() }}</span>
                                </div>
                            </div>
                        </a>
                    </article>
                @endforeach
            </div>

            <!-- Pagination -->
            <div class="flex justify-center">
                {{ $articles->links() }}
            </div>
        @else
            <!-- No Articles Found -->
            <div class="text-center py-12">
                <div class="mb-4">
                    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3v8m0 0V9a2 2 0 00-2-2H9a2 2 0 00-2 2v8a2 2 0 002 2h2a2 2 0 002-2z" />
                    </svg>
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">No entertainment articles found</h3>
                <p class="text-gray-600">There are no entertainment articles available at the moment.</p>
                <a href="{{ route('news.index') }}" class="inline-block mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                    Back to Home
                </a>
            </div>
        @endif
    </div>
</div>
@endsection
