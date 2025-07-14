<div class="w-full bg-[#005234] text-white py-6 sm:py-8 relative overflow-hidden">
    {{-- hijau gelap 005234 --}}
    {{-- Biru Hijau 005572 --}}
    <!-- Subtle background overlay -->
    <div class="absolute inset-0"></div>

    <!-- Footer Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <!-- Logo Section -->
        <div class="grid grid-cols-2 lg:grid-cols-2 gap-6 lg:gap-8 items-center mb-6 sm:mb-8">
            <!-- Left Logo - Garuda Indonesia -->
            <div class="flex justify-start lg:justify-start items-start order-first">
                <div class="logo-container flex flex-col sm:flex-col items-start justify-start lg:justify-start gap-2 sm:gap-2 lg:ml-8">
                    <img src="{{ asset('images/logo/mcm x grab_.png') }}" alt="Grab Indonesia"
                         class="h-12 w-auto object-contain filter brightness-110">
                </div>
            </div>

            <!-- Right Text - Developer Info -->
            <div class="flex flex-col justify-center items-ends lg:items-end text-right lg:text-right  lg:order-last lg:mr-8">
                <p class="text-xs font-arial sm:text-sm text-gray-200 font-medium tracking-wider mb-1 sm:mb-2">
                    Developed & Maintained by
                </p>
                <h3 class="text-sm sm:text-base font-medium font-arial">
                    Grab Indonesia | MCMMedia Networks
                </h3>
            </div>
        </div>

        {{-- Feedback Section --}}
        <div class="border-t border-gray-400/30 pt-4 sm:pt-6 mt-4">
            <div class="text-center">
                <div class="flex flex-wrap justify-center items-center gap-x-4 sm:gap-x-6 gap-y-2 text-sm">
                    <a href="{{ route('feedback.create') }}"
                       class="flex items-center text-gray-300 hover:text-white transition-colors duration-300 group">
                        <svg class="w-4 h-4 sm:w-5 sm:h-5 mr-2 text-blue-600 group-hover:text-blue-300 transition-colors duration-300"
                             fill="currentColor" viewBox="0 0 24 24">
                            <path d="M20 2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h4l4 4 4-4h4c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/>
                        </svg>
                        <span class="font-medium text-xs sm:text-sm">Punya Masukkan?, Kirim ke sini aja!</span>
                    </a>
                    <span class="text-gray-500 hidden sm:inline">•</span>
                </div>
            </div>
        </div>

        <!-- API Credits Section -->
        <div class="border-t border-gray-400/30 pt-4 sm:pt-6 mt-4">
            <div class="text-center">
                <p class="text-xs sm:text-sm text-gray-300 font-medium tracking-wider uppercase mb-2 sm:mb-3">
                    Data Sources & APIs
                </p>
                <div class="flex flex-col sm:flex-row sm:flex-wrap justify-center items-center gap-x-4 sm:gap-x-6 lg:gap-x-8 gap-y-2 sm:gap-y-1 text-xs sm:text-sm text-gray-300">
                    <span class="flex items-center justify-center">
                        <svg class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-1.5 text-green-400 flex-shrink-0"
                             fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.84-.179-.84-.599 0-.36.24-.66.54-.78 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.242 1.019zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.42 1.56-.299.421-1.02.599-1.559.3z"/>
                        </svg>
                        <span class="text-center">Music by Spotify Web API</span>
                    </span>

                    <span class="flex items-center justify-center">
                        <svg class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-1.5 text-yellow-400 flex-shrink-0"
                             fill="currentColor" viewBox="0 0 24 24">
                            <path d="M21.147 2.853a.5.5 0 00-.708 0L12 11.293 3.56 2.853a.5.5 0 00-.707.707L11.293 12l-8.44 8.44a.5.5 0 00.707.707L12 12.707l8.44 8.44a.5.5 0 00.707-.707L12.707 12l8.44-8.44a.5.5 0 000-.707z"/>
                        </svg>
                        <span class="text-center">Movies by TMDB</span>
                    </span>

                    <span class="flex items-center justify-center">
                        <svg class="w-3 h-3 sm:w-4 sm:h-4 mr-1 sm:mr-1.5 text-orange-400 flex-shrink-0"
                             fill="currentColor" viewBox="0 0 24 24">
                            <path d="M3.429 2.857A.571.571 0 004 2.286h16a.571.571 0 01.571.571v1.715a.571.571 0 01-.571.571H4a.571.571 0 01-.571-.571V2.857zm0 4.572A.571.571 0 004 6.857h16a.571.571 0 01.571.571v1.715a.571.571 0 01-.571.571H4a.571.571 0 01-.571-.571V7.428zm0 4.571A.571.571 0 004 11.43h16a.571.571 0 01.571.571v1.714a.571.571 0 01-.571.571H4a.571.571 0 01-.571-.571V12zm0 4.571A.571.571 0 004 16h16a.571.571 0 01.571.571v1.715A.571.571 0 0120 18.857H4a.571.571 0 01-.571-.571V16.57z"/>
                        </svg>
                        <span class="text-center">News by Detik RSS</span>
                    </span>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    /* Gradient text effect */
    .gradient-text {
        background: linear-gradient(135deg, #3b82f6, #06b6d4, #10b981);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        color: transparent;
    }

    /* Logo container responsive styling */
    .logo-container {
        transition: all 0.3s ease;
        border-radius: 8px;
    }

    /* Enhanced responsive hover effects */
    .flex.items-center:hover {
        transform: translateY(-1px);
        opacity: 0.8;
        transition: all 0.3s ease;
    }

    /* Improved mobile text wrapping */
    @media (max-width: 640px) {
        .logo-container {
            gap: 0.75rem;
        }

        .logo-container img {
            max-width: 100%;
            height: auto;
        }

        /* Better text spacing on mobile */
        .text-center span {
            word-break: break-word;
            hyphens: auto;
        }
    }

    /* Tablet optimizations */
    @media (min-width: 641px) and (max-width: 1024px) {
        .grid {
            gap: 2rem;
        }

        .logo-container {
            justify-content: center;
        }
    }
</style>
