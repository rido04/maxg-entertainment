<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Media extends Model
{
    protected $fillable = [
        'title',
        'file_path',
        'type',
        'thumbnail',
        'duration',
        'description',
        'category',
        'rating',
        'release_date',
        'language',
        'tmdb_id',
        'artist',
        'artist_image',
        'album',
    ];

    protected $casts = [
        'rating' => 'decimal:1',
        'duration' => 'integer',
        'release_date' => 'date',
    ];
}
