<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Advertisement extends Model
{
    protected $fillable = [
        'title',
        'description',
        'type',
        'video_path',
        'image_path',
        'file_path',
        'thumbnail',
        'duration',
        'priority',
        'target_gender',
        'target_age_group',
        'start_date',
        'end_date',
        'is_active',
        'target_category',
    ];

    protected $casts = [
        'target_gender' => 'array',
        'target_age_group' => 'array',
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'is_active' => 'boolean',
    ];

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
                     ->where(function ($q) {
                         $q->whereNull('start_date')
                           ->orWhere('start_date', '<=', now());
                     })
                     ->where(function ($q) {
                         $q->whereNull('end_date')
                           ->orWhere('end_date', '>=', now());
                     });
    }

    public function scopeForGender($query, string $gender)
    {
        return $query->where(function ($q) use ($gender) {
            $q->whereJsonContains('target_gender', 'all')
              ->orWhereJsonContains('target_gender', $gender);
        });
    }

    public function scopeForAgeGroup($query, string $ageGroup)
    {
        return $query->where(function ($q) use ($ageGroup) {
            $q->whereJsonContains('target_age_group', 'all')
              ->orWhereJsonContains('target_age_group', $ageGroup);
        });
    }

    // Accessors
    public function getFileUrlAttribute(): string
    {
        // Use file_path if exists, otherwise determine from type
        if (!empty($this->attributes['file_path'])) {
            return url('storage/' . $this->attributes['file_path']);
        }

        // Fallback to type-specific paths
        $path = $this->type === 'video'
            ? ($this->attributes['video_path'] ?? '')
            : ($this->attributes['image_path'] ?? '');

        return $path ? url('storage/' . $path) : '';
    }

    public function getThumbnailUrlAttribute(): ?string
    {
        return !empty($this->attributes['thumbnail'])
            ? url('storage/' . $this->attributes['thumbnail'])
            : null;
    }

    public function isCurrentlyActive(): bool
    {
        if (!$this->is_active) return false;

        $now = now();

        if ($this->start_date && $now->lt($this->start_date)) return false;
        if ($this->end_date && $now->gt($this->end_date)) return false;

        return true;
    }
}
