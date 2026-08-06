<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Casts\AsArrayObject;

class PassengerSession extends Model
{
    protected $fillable = [
        'session_id',
        'device_id',
        'driver_id',
        'start_time',
        'end_time',
        'duration_seconds',
        'gender',
        'age_group',
        'ad_view_count',
        'viewed_ads',
        'metadata',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'viewed_ads' => 'array',  // Ini tetap array
        'metadata' => 'array',
    ];

    // Paksa decode manual di accessor
    protected function viewedAds(): Attribute
    {
        return Attribute::make(
            get: function ($value) {
                // Kalau sudah array, return langsung
                if (is_array($value)) {
                    return $value;
                }

                // Kalau string, decode dulu
                if (is_string($value)) {
                    $decoded = json_decode($value, true);
                    return $decoded ?? [];
                }

                // Kalau null atau lainnya, return empty array
                return [];
            },
            set: fn ($value) => is_array($value) ? json_encode($value) : $value,
        );
    }

    protected function metadata(): Attribute
    {
        return Attribute::make(
            get: function ($value) {
                if (is_array($value)) {
                    return $value;
                }

                if (is_string($value)) {
                    $decoded = json_decode($value, true);
                    return $decoded ?? [];
                }

                return [];
            },
            set: fn ($value) => is_array($value) ? json_encode($value) : $value,
        );
    }

    // Hapus accessor lama yang duplikat

    public function getFormattedDurationAttribute(): string
    {
        $minutes = floor($this->duration_seconds / 60);
        $seconds = $this->duration_seconds % 60;
        return sprintf('%02d:%02d', $minutes, $seconds);
    }

    public function getViewedAdTitlesAttribute(): array
    {
        if (empty($this->viewed_ads)) {
            return [];
        }

        return collect($this->viewed_ads)
            ->pluck('ad_title')
            ->toArray();
    }

    public function getViewedAdIdsAttribute(): array
    {
        if (empty($this->viewed_ads)) {
            return [];
        }

        return collect($this->viewed_ads)
            ->pluck('ad_id')
            ->unique()
            ->values()
            ->toArray();
    }

    public function getUniqueAdsViewedAttribute(): int
    {
        return count($this->viewed_ad_ids);
    }

    public function scopeToday($query)
    {
        return $query->whereDate('start_time', today());
    }

    public function scopeThisWeek($query)
    {
        return $query->whereBetween('start_time', [
            now()->startOfWeek(),
            now()->endOfWeek()
        ]);
    }

    public function scopeThisMonth($query)
    {
        return $query->whereMonth('start_time', now()->month)
                     ->whereYear('start_time', now()->year);
    }

    public function scopeHasViewedAds($query)
    {
        return $query->where('ad_view_count', '>', 0);
    }

    public function scopeByGender($query, string $gender)
    {
        return $query->where('gender', $gender);
    }

    public function scopeByAgeGroup($query, string $ageGroup)
    {
        return $query->where('age_group', $ageGroup);
    }
}
