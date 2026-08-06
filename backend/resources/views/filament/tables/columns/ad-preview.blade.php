{{-- File: resources/views/filament/tables/columns/ad-preview.blade.php --}}

<div class="flex items-center justify-center">
    @if($getRecord()->type === 'video')
        {{-- Preview untuk Video --}}
        <div class="flex items-center justify-center w-20 h-20 bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg border-2 border-blue-200 shadow-sm">
            <svg class="w-10 h-10 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
            </svg>
        </div>
    @else
        {{-- Preview untuk Image --}}
        @if($getRecord()->file_path)
            <img src="{{ asset('storage/' . $getRecord()->file_path) }}"
                 alt="{{ $getRecord()->title }}"
                 class="w-20 h-20 object-cover rounded-lg shadow-sm border border-gray-200">
        @else
            {{-- Fallback jika tidak ada gambar --}}
            <div class="flex items-center justify-center w-20 h-20 bg-gray-100 rounded-lg border-2 border-gray-200">
                <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                </svg>
            </div>
        @endif
    @endif
</div>
