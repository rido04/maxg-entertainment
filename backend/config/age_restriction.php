<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Age Restriction Settings
    |--------------------------------------------------------------------------
    |
    | Configure age restriction and content filtering for your media library
    |
    */

    // Apakah mengizinkan konten dewasa (default: false)
    'allow_adult_content' => env('ALLOW_ADULT_CONTENT', false),

    // Rating yang diizinkan (US Rating System)
    'allowed_ratings' => [
        'G',        // General Audiences
        'PG',       // Parental Guidance Suggested
        'TV-Y',     // Children
        'TV-Y7',    // Children 7+
        'TV-G',     // General Audiences
        'TV-PG',    // Parental Guidance
    ],

    // Rating yang dibatasi
    'restricted_ratings' => [
        'PG-13',    // Parents Strongly Cautioned
        'R',        // Restricted
        'NC-17',    // Adults Only
        'TV-14',    // Parents Strongly Cautioned
        'TV-MA',    // Mature Audiences
        'X',        // Adults Only (old system)
    ],

    // Genre yang dianggap family-friendly (TMDb Genre IDs)
    'family_friendly_genres' => [
        16,     // Animation
        10751,  // Family
        12,     // Adventure
        35,     // Comedy
        99,     // Documentary
        10402,  // Music
        36,     // History
        878,    // Science Fiction (selective)
        14,     // Fantasy (selective)
    ],

    // Genre yang harus dihindari (TMDb Genre IDs)
    'restricted_genres' => [
        27,     // Horror
        53,     // Thriller
        80,     // Crime
        18,     // Drama (selective - could contain mature themes)
    ],

    // Minimal rating TMDb untuk konten tanpa info genre
    'minimum_tmdb_rating' => 6.0,

    // Tahun rilis minimal (untuk menghindari konten lawas yang mungkin tidak sesuai)
    'minimum_release_year' => 1990,

    // Strict mode - jika true, hanya konten dengan rating yang jelas diizinkan yang akan masuk
    'strict_mode' => env('AGE_RESTRICTION_STRICT_MODE', true),

    // Apakah menampilkan peringatan untuk konten PG
    'show_pg_warning' => env('SHOW_PG_WARNING', true),
];