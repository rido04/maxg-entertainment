@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-gray-200">
    <!-- Background Pattern -->
    <div class="absolute inset-0 bg-gradient-to-r from-blue-800/5 to-purple-600/5"></div>
    <div class="absolute inset-0 bg-[url('data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%23ffffff" fill-opacity="0.02"%3E%3Cpath d="M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zm0 60v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4z"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E')] opacity-10"></div>

    <!-- Navigation Bar -->
    <nav class="bg-gray-200 backdrop-blur-md border-b border-white/10 shadow-lg sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <a href="{{ route('news.index') }}" class="inline-flex items-center text-black hover:text-blue-800 transition-colors group">
                    <svg class="w-5 h-5 mr-2 transform group-hover:-translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                    </svg>
                    <span class="font-medium">Back to News</span>
                </a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="grid grid-cols-3 sm:grid-cols-4 lg:grid-cols-3 gap-8">
            <!-- Main Article Content -->
            <div class="lg:col-span-2 sm:col-span-2">
                <article class="relative">
                    <!-- Article Header -->
                    <header class="mb-8">
                        <div class="mb-6">
                            <span class="inline-block bg-blue-800/20 text-blue-800 px-3 py-1 rounded-full text-sm font-medium backdrop-blur-sm border border-blue-800/30">
                                {{ $article->source ?? 'Breaking News' }}
                            </span>
                        </div>

                        <h1 class="text-4xl md:text-5xl font-bold text-black mb-6 leading-tight">
                            {{ $article['title'] }}
                        </h1>

                        <!-- Article Meta -->
                        <div class="flex flex-wrap items-center gap-6 text-sm text-black">
                            <div class="flex items-center">
                                <svg class="w-4 h-4 mr-2 text-blue-800" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                </svg>
                                <time class="font-medium">
                                    {{ \Carbon\Carbon::parse($article->published_at)->translatedFormat('d M Y, H:i') }}
                                </time>
                            </div>

                            <div class="flex items-center">
                                <svg class="w-4 h-4 mr-2 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                </svg>
                                <span>Verified Source</span>
                            </div>

                            <div class="flex items-center">
                                <svg class="w-4 h-4 mr-2 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                </svg>
                                <span>{{ rand(150, 2500) }} views</span>
                            </div>
                        </div>
                    </header>

                    <!-- Featured Image - Made Larger -->
                    @if($article->urlToImage)
                    <div class="mb-8 group">
                        <div class="relative overflow-hidden shadow-2xl bg-gradient-to-br from-gray-800 to-gray-900">
                            <img src="{{ $article->urlToImage }}"
                                 alt="{{ $article['title'] }}"
                                 class="w-full h-80 md:h-[500px] object-cover transition-transform duration-700 group-hover:scale-105">
                            <div class="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent"></div>

                            <!-- Image Caption -->
                            <div class="absolute bottom-4 left-4 right-4">
                                <div class="bg-black/50 backdrop-blur-sm p-4 border border-white/10">
                                    <p class="text-white text-sm font-medium">
                                        {{ $article['title'] }}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                    @endif

                    <!-- Article Body -->
                    <div class="prose prose-lg prose-invert max-w-none">
                        <div class="bg-white/5">
                            <!-- Article Content -->
                            <div class="text-black leading-relaxed space-y-6">
                                @if($article->description && $article->description !== $article->content)
                                <div class="text-xl text-black font-medium italic border-l-4 border-blue-800 pl-6 py-2 bg-blue-800/10 rounded-r-lg">
                                    "{{ $article->description }}"
                                </div>
                                @endif

                                <p class="text-black text-sm mb-4">
                                    Source: {{ $article->source }} |
                                    Published at: {{ $article->published_at->translatedFormat('d M Y H:i') }}
                                </p>

                                <p class="mb-4 text-lg leading-relaxed">
                                    {{ $article->content ?? $article->description ?? 'Tidak ada konten tersedia.' }}
                                </p>
                            </div>

                            <!-- Read More Section -->
                            <div class="mt-8 pt-6 border-t border-white/10">
                                <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                                    <div>
                                        <h3 class="text-black font-semibold mb-1">Continue Reading</h3>
                                        <p class="text-black text-sm">Read the complete article at the original source</p>
                                    </div>

                                    <a href="{{ $article->url }}"
                                       target="_blank"
                                       rel="noopener noreferrer"
                                       class="inline-flex items-center px-6 py-3 bg-gradient-to-r from-blue-800 to-blue-800 hover:from-blue-800 hover:to-blue-800 text-black font-semibold rounded-lg transition-all duration-300 transform hover:scale-105 hover:shadow-lg group">
                                        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                                        </svg>
                                        Read Full Article
                                        <svg class="w-4 h-4 ml-2 transform group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                                        </svg>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </article>
            </div>

            <!-- Sidebar - Recommended Articles -->
            <div class="lg:col-span-1">
                <div class="sticky top-24">
                    @if($relatedArticles && $relatedArticles->count() > 0)
                    <section class="bg-white/5 p-6">
                        <div class="mb-6">
                            <h2 class="text-2xl font-bold text-black mb-2">
                                Related Articles
                            </h2>
                        </div>

                        <div class="space-y-4">
                            @foreach($relatedArticles->take(3) as $index => $relatedArticle)
                            <article class="group bg-white/5 backdrop-blur-sml overflow-hidden transition-all duration-300">
                                <!-- Article Image -->
                                <div class="aspect-video bg-gradient-to-br from-gray-800 to-gray-900 relative overflow-hidden">
                                    @if($relatedArticle->urlToImage)
                                        <img src="{{ $relatedArticle->urlToImage }}"
                                             alt="{{ $relatedArticle->title }}"
                                             class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105">
                                        <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
                                    @else
                                        <div class="w-full h-full flex items-center justify-center text-black/40">
                                            <svg class="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clip-rule="evenodd"/>
                                            </svg>
                                        </div>
                                    @endif

                                    <!-- Category Badge -->
                                    <div class="absolute top-2 left-2">
                                        <span class="bg-blue-800/90 backdrop-blur-sm text-white px-2 py-1 rounded-md text-xs font-medium">
                                            {{ ucfirst($relatedArticle->category ?? 'News') }}
                                        </span>
                                    </div>

                                    <!-- Reading Time Badge -->
                                    <div class="absolute top-2 right-2">
                                        <div class="bg-black/50 backdrop-blur-sm text-white px-2 py-1 rounded-md text-xs flex items-center">
                                            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                            </svg>
                                            {{ rand(2, 5) }}m
                                        </div>
                                    </div>
                                </div>

                                <!-- Article Content -->
                                <div class="p-4">
                                    <!-- Article Meta -->
                                    <div class="flex items-center text-xs text-black mb-2">
                                        <time>{{ $relatedArticle->published_at ? $relatedArticle->published_at->diffForHumans() : 'Just now' }}</time>
                                        <span class="mx-1">•</span>
                                        <span class="truncate">{{ $relatedArticle->source ?? 'News' }}</span>
                                    </div>

                                    <!-- Article Title -->
                                    <h3 class="text-sm font-bold text-black mb-2 line-clamp-2 group-hover:text-blue-800 transition-colors leading-tight">
                                        {{ $relatedArticle->title }}
                                    </h3>

                                    <!-- Article Description -->
                                    <p class="text-black text-xs line-clamp-2 mb-3 leading-relaxed">
                                        {{ $relatedArticle->description ?? 'Stay informed with the latest updates and breaking news.' }}
                                    </p>

                                    <!-- Read More Button -->
                                    <a href="{{ route('news.show', $relatedArticle->slug) }}"
                                       class="inline-flex items-center text-blue-800 hover:text-blue-800 font-medium text-xs transition-colors group">
                                        Read More
                                        <svg class="w-3 h-3 ml-1 transform group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                                        </svg>
                                    </a>
                                </div>
                            </article>
                            @endforeach
                        </div>
                    </section>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
    <script src="{{ asset('js/news-show.js') }}"></script>
@endpush

@push('styles')
    <link rel="stylesheet" href="{{ asset('css/news-show.css') }}">
@endpush
@endsection
