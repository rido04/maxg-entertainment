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
        'category',
        'is_adult_content',
        'content_rating',
        'duration',
        'description',
        'rating',
        'release_date',
        'language',
        'tmdb_id',
        'artist',
        'artist_image',
        'album',
        'checksum',
        'hash_type',
        'filesize',
        'cast',
        'cast_json',
        'director',
        'writers',
    ];

    protected $casts = [
        'rating' => 'decimal:1',
        'duration' => 'integer',
        'release_date' => 'date',
    ];
}
