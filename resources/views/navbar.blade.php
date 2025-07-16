<!-- Toggle Button -->
<div id="toggleContainer" class="fixed right-4 top-1/2 transform -translate-y-1/2 z-40 transition-all duration-500 ease-in-out">
    <button id="navToggle" class="bg-black/80 rounded-full w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 flex items-center justify-center text-slate-400 hover:text-green-400 transition-all duration-300 hover:scale-110">
        <svg id="toggleIcon" class="w-5 h-5 sm:w-5 sm:h-5 md:w-5 md:h-5 lg:w-5 lg:h-5 xl:w-5 xl:h-5 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 5l-7 7 7 7"></path>
        </svg>
    </button>
</div>

<!-- Slim Navigation Menu -->
<div id="navigationMenu" class="fixed right-4 top-1/2 transform -translate-y-1/2 z-30 transition-all duration-500 ease-in-out opacity-0 translate-x-8 pointer-events-none">
    <div class="bg-black/80 rounded-2xl py-3 card-hover">
        <nav class="flex flex-col space-y-1">
            <div class="nav-item-wrapper">
                <a href="/" class="nav-link flex items-center justify-center w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 text-slate-400 hover:text-green-400 hover:bg-white/10 transition-all duration-300 rounded-lg mx-2 relative group">
                    <svg class="w-5 h-5 sm:w-5 sm:h-5 md:w-5 md:h-5 lg:w-5 lg:h-5 xl:w-5 xl:h-5" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z"/>
                    </svg>
                    <!-- Tooltip -->
                    <div class="tooltip absolute left-[-90px] top-1/2 transform -translate-y-1/2 bg-slate-800 text-white text-sm px-2 py-1 rounded opacity-0 pointer-events-none transition-all duration-200 whitespace-nowrap group-hover:opacity-100 group-hover:left-[-95px] hidden sm:block">
                        Home
                        <div class="tooltip-arrow absolute right-[-4px] top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-slate-800 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                    </div>
                </a>
            </div>

            <div class="nav-item-wrapper">
                <a href="{{ route('videos.index') }}" class="nav-link flex items-center justify-center w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 text-slate-400 hover:text-green-400 hover:bg-white/10 transition-all duration-300 rounded-lg mx-2 relative group">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.375 19.5h17.25m-17.25 0a1.125 1.125 0 0 1-1.125-1.125M3.375 19.5h1.5C5.496 19.5 6 18.996 6 18.375m-3.75 0V5.625m0 12.75v-1.5c0-.621.504-1.125 1.125-1.125m18.375 2.625V5.625m0 12.75c0 .621-.504 1.125-1.125 1.125m1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125m0 3.75h-1.5A1.125 1.125 0 0 1 18 18.375M20.625 4.5H3.375m17.25 0c.621 0 1.125.504 1.125 1.125M20.625 4.5h-1.5C18.504 4.5 18 5.004 18 5.625m3.75 0v1.5c0 .621-.504 1.125-1.125 1.125M3.375 4.5c-.621 0-1.125.504-1.125 1.125M3.375 4.5h1.5C5.496 4.5 6 5.004 6 5.625m-3.75 0v1.5c0 .621.504 1.125 1.125 1.125m0 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125m1.5-3.75C5.496 8.25 6 7.746 6 7.125v-1.5M4.875 8.25C5.496 8.25 6 8.754 6 9.375v1.5m0-5.25v5.25m0-5.25C6 5.004 6.504 4.5 7.125 4.5h9.75c.621 0 1.125.504 1.125 1.125m1.125 2.625h1.5m-1.5 0A1.125 1.125 0 0 1 18 7.125v-1.5m1.125 2.625c-.621 0-1.125.504-1.125 1.125v1.5m2.625-2.625c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125M18 5.625v5.25M7.125 12h9.75m-9.75 0A1.125 1.125 0 0 1 6 10.875M7.125 12C6.504 12 6 12.504 6 13.125m0-2.25C6 11.496 5.496 12 4.875 12M18 10.875c0 .621-.504 1.125-1.125 1.125M18 10.875c0 .621.504 1.125 1.125 1.125m-2.25 0c.621 0 1.125.504 1.125 1.125m-12 5.25v-5.25m0 5.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125m-12 0v-1.5c0-.621-.504-1.125-1.125-1.125M18 18.375v-5.25m0 5.25v-1.5c0-.621.504-1.125 1.125-1.125M18 13.125v1.5c0 .621.504 1.125 1.125 1.125M18 13.125c0-.621.504-1.125 1.125-1.125M6 13.125v1.5c0 .621-.504 1.125-1.125 1.125M6 13.125C6 12.504 5.496 12 4.875 12m-1.5 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125M19.125 12h1.5m0 0c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125m-17.25 0h1.5m14.25 0h1.5" />
                      </svg>

                    <!-- Tooltip -->
                    <div class="tooltip absolute left-[-100px] top-1/2 transform -translate-y-1/2 bg-slate-800 text-white text-sm px-2 py-1 rounded opacity-0 pointer-events-none transition-all duration-200 whitespace-nowrap group-hover:opacity-100 group-hover:left-[-105px] hidden sm:block">
                        Movies
                        <div class="tooltip-arrow absolute right-[-4px] top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-slate-800 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                    </div>
                </a>
            </div>

            <div class="nav-item-wrapper">
                <a href="{{ route('music.index') }}" class="nav-link flex items-center justify-center w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 text-slate-400 hover:text-green-400 hover:bg-white/10 transition-all duration-300 rounded-lg mx-2 relative group">
                    <svg class="w-5 h-5 sm:w-5 sm:h-5 md:w-5 md:h-5 lg:w-5 lg:h-5 xl:w-5 xl:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3"></path>
                    </svg>
                    <!-- Tooltip -->
                    <div class="tooltip absolute left-[-95px] top-1/2 transform -translate-y-1/2 bg-slate-800 text-white text-sm px-2 py-1 rounded opacity-0 pointer-events-none transition-all duration-200 whitespace-nowrap group-hover:opacity-100 group-hover:left-[-100px] hidden sm:block">
                        Music
                        <div class="tooltip-arrow absolute right-[-4px] top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-slate-800 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                    </div>
                </a>
            </div>

            <div class="nav-item-wrapper">
                <a href="{{ route('games.index') }}" class="nav-link flex items-center justify-center w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 text-slate-400 hover:text-green-400 hover:bg-white/10 transition-all duration-300 rounded-lg mx-2 relative group">
                    <svg class="w-5 h-5 sm:w-5 sm:h-5 md:w-5 md:h-5 lg:w-5 lg:h-5 xl:w-5 xl:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 4a2 2 0 114 0v1a1 1 0 001 1h3a1 1 0 011 1v3a1 1 0 01-1 1h-1a2 2 0 100 4h1a1 1 0 011 1v3a1 1 0 01-1 1h-3a1 1 0 01-1-1v-1a2 2 0 10-4 0v1a1 1 0 01-1 1H7a1 1 0 01-1-1v-3a1 1 0 00-1-1H4a1 1 0 01-1-1V9a1 1 0 011-1h1a2 2 0 100-4H4a1 1 0 01-1-1V4a1 1 0 011-1h3a1 1 0 011 1v1z"></path>
                    </svg>
                    <!-- Tooltip -->
                    <div class="tooltip absolute left-[-100px] top-1/2 transform -translate-y-1/2 bg-slate-800 text-white text-sm px-2 py-1 rounded opacity-0 pointer-events-none transition-all duration-200 whitespace-nowrap group-hover:opacity-100 group-hover:left-[-105px] hidden sm:block">
                        Games
                        <div class="tooltip-arrow absolute right-[-4px] top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-slate-800 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                    </div>
                </a>
            </div>

            <div class="nav-item-wrapper">
                <a href="{{ route('news.index') }}" class="nav-link flex items-center justify-center w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 text-slate-400 hover:text-green-400 hover:bg-white/10 transition-all duration-300 rounded-lg mx-2 relative group">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 7.5h1.5m-1.5 3h1.5m-7.5 3h7.5m-7.5 3h7.5m3-9h3.375c.621 0 1.125.504 1.125 1.125V18a2.25 2.25 0 0 1-2.25 2.25M16.5 7.5V18a2.25 2.25 0 0 0 2.25 2.25M16.5 7.5V4.875c0-.621-.504-1.125-1.125-1.125H4.125C3.504 3.75 3 4.254 3 4.875V18a2.25 2.25 0 0 0 2.25 2.25h13.5M6 7.5h3v3H6v-3Z" />
                      </svg>
                    <!-- Tooltip -->
                    <div class="tooltip absolute left-[-90px] top-1/2 transform -translate-y-1/2 bg-slate-800 text-white text-sm px-2 py-1 rounded opacity-0 pointer-events-none transition-all duration-200 whitespace-nowrap group-hover:opacity-100 group-hover:left-[-95px] hidden sm:block">
                        News
                        <div class="tooltip-arrow absolute right-[-4px] top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-slate-800 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                    </div>
                </a>
            </div>

            {{-- <div class="nav-item-wrapper">
                <a href="{{ route('catalog') }}" class="nav-link flex items-center justify-center w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 text-slate-400 hover:text-green-400 hover:bg-white/10 transition-all duration-300 rounded-lg mx-2 relative group">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z" />
                      </svg>
                    <!-- Tooltip -->
                    <div class="tooltip absolute left-[-90px] top-1/2 transform -translate-y-1/2 bg-slate-800 text-white text-sm px-2 py-1 rounded opacity-0 pointer-events-none transition-all duration-200 whitespace-nowrap group-hover:opacity-100 group-hover:left-[-95px] hidden sm:block">
                        Shop
                        <div class="tooltip-arrow absolute right-[-4px] top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-slate-800 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                    </div>
                </a>
            </div> --}}

            <div class="nav-item-wrapper">
                <a href="{{ route('route') }}" class="nav-link flex items-center justify-center w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 text-slate-400 hover:text-green-400 hover:bg-white/10 transition-all duration-300 rounded-lg mx-2 relative group">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 2C8.134 2 5 5.134 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.866-3.134-7-7-7z" />
                        <circle cx="12" cy="9" r="2.5" />
                      </svg>
                    <!-- Tooltip -->
                    <div class="tooltip absolute left-[-95px] top-1/2 transform -translate-y-1/2 bg-slate-800 text-white text-sm px-2 py-1 rounded opacity-0 pointer-events-none transition-all duration-200 whitespace-nowrap group-hover:opacity-100 group-hover:left-[-100px] hidden sm:block">
                        Navigate
                        <div class="tooltip-arrow absolute right-[-4px] top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-slate-800 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                    </div>
                </a>
            </div>

            <div class="nav-item-wrapper">
                <a href="{{ route('about') }}" class="nav-link flex items-center justify-center w-12 h-12 sm:w-12 sm:h-12 md:w-12 md:h-12 lg:w-12 lg:h-12 xl:w-12 xl:h-12 text-slate-400 hover:text-green-400 hover:bg-white/10 transition-all duration-300 rounded-lg mx-2 relative group">
                    <svg class="w-5 h-5 sm:w-5 sm:h-5 md:w-5 md:h-5 lg:w-5 lg:h-5 xl:w-5 xl:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    <!-- Tooltip -->
                    <div class="tooltip absolute left-[-95px] top-1/2 transform -translate-y-1/2 bg-slate-800 text-white text-sm px-2 py-1 rounded opacity-0 pointer-events-none transition-all duration-200 whitespace-nowrap group-hover:opacity-100 group-hover:left-[-100px] hidden sm:block">
                        About
                        <div class="tooltip-arrow absolute right-[-4px] top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-slate-800 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                    </div>
                </a>
            </div>
        </nav>
    </div>
</div>

@push('scripts')
<script src="{{ asset('js/navbar.js') }}"></script>
@endpush
@push('styles')
<link rel="stylesheet" href="{{ asset('css/navbar.css') }}">
@endpush
