<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Banner extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'subtitle',
        'image_path',
        'link_url',
        'button_text',
        'position',
        'sort_order',
        'is_active',
        'start_date',
        'end_date'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'start_date' => 'datetime',
        'end_date' => 'datetime',
    ];
    // Scope untuk banner aktif
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
                    ->where(function($q) {
                        $q->whereNull('start_date')
                          ->orWhere('start_date', '<=', now());
                    })
                    ->where(function($q) {
                        $q->whereNull('end_date')
                          ->orWhere('end_date', '>=', now());
                    });
    }

    // Scope untuk posisi banner
    public function scopePosition($query, $position)
    {
        return $query->where('position', $position);
    }

    // Accessor untuk URL gambar
    public function getImageUrlAttribute()
    {
        if (filter_var($this->image_path, FILTER_VALIDATE_URL)) {
            return $this->image_path;
        }

        return Storage::url($this->image_path);
    }

    // Method untuk mendapatkan banner berdasarkan posisi
    public static function getByPosition($position, $limit = null)
    {
        $query = self::active()
                    ->position($position)
                    ->orderBy('sort_order')
                    ->orderBy('created_at', 'desc');

        if ($limit) {
            $query->limit($limit);
        }

        return $query->get();
    }

    // Method untuk mendapatkan semua banner untuk homepage
    public static function getHomepageBanners()
    {
        return [
            'main' => self::getByPosition('main', 3),
            'side_top' => self::getByPosition('side_top', 1),
            'side_bottom' => self::getByPosition('side_bottom', 1)
        ];
    }
}
