@forelse ($articles as $article)
    <article class="rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow duration-300">
        <div class="flex">
            <!-- Image Section -->
            <div class="w-1/3 flex-shrink-0">
                <div class="h-32 bg-gray-200 relative">
                    @if($article->urlToImage)
                        <img src="{{ $article->urlToImage }}" 
                             alt="{{ $article->title }}" 
                             class="w-full h-full object-cover">
                    @else
                        <div class="w-full h-full flex items-center justify-center text-white">
                            <svg class="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clip-rule="evenodd"/>
                            </svg>
                        </div>
                    @endif
                </div>
            </div>
            
            <!-- Content Section -->
            <div class="flex-1 p-4">
                <div class="flex items-center justify-between mb-2">
                    <span class="inline-block bg-gray-900 text-white px-2 py-1 rounded-full text-xs font-medium">
                        {{ $article->category ?? 'Berita' }}
                    </span>
                    @if($article->published_at)
                        <time class="text-xs text-white">
                            {{ $article->published_at->format('d M Y') }}
                        </time>
                    @endif
                </div>
                
                <h3 class="text-lg font-semibold text-white mb-2 line-clamp-2">
                    <a href="{{ route('news.show', $article->slug) }}" 
                       class="hover:text-blue-600 transition-colors duration-200">
                        {{ $article->title }}
                    </a>
                </h3>
                
                <p class="text-white text-sm mb-3 line-clamp-2">
                    {{ $article->description ?? 'Tidak ada deskripsi tersedia.' }}
                </p>
                
                <div class="flex items-center justify-between">
                    <div class="flex items-center text-xs text-white">
                        @if($article->author)
                            <span class="mr-3">By {{ $article->author }}</span>
                        @endif
                        @if($article->source)
                            <span class="bg-blue-50 text-blue-700 px-2 py-1 rounded-full text-xs">
                                {{ $article->source }}
                            </span>
                        @endif
                    </div>
                    
                    <a href="{{ route('news.show', $article->slug) }}" 
                       class="text-blue-600 hover:text-blue-800 text-sm font-medium flex items-center">
                        Read
                        <svg class="w-3 h-3 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                        </svg>
                    </a>
                </div>
            </div>
        </div>
    </article>
@empty
    <div class="col-span-full text-center py-12">
        <div class="text-white mb-4">
            <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
        </div>
        <h3 class="text-lg font-medium text-white mb-2">There`s no news yet</h3>
        <p class="text-white">There`s no news yet for this category.</p>
    </div>
@endforelse