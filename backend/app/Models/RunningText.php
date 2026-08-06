<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class RunningText extends Model
{
    protected $fillable = [
        'text',
        'position',
        'priority',
        'is_active',
        'background_color',
        'text_color',
        'font_size',
        'speed',
        'start_date',
        'end_date',
        'start_time',
        'end_time',
        'display_duration',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'priority' => 'integer',
        'font_size' => 'integer',
        'speed' => 'integer',
        'display_duration' => 'integer',
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    /**
     * Scope: hanya yang aktif
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope: filter berdasarkan date range
     */
    public function scopeInDateRange($query)
    {
        $today = Carbon::today();

        return $query->where(function ($q) use ($today) {
            $q->whereNull('start_date')
              ->orWhere('start_date', '<=', $today);
        })->where(function ($q) use ($today) {
            $q->whereNull('end_date')
              ->orWhere('end_date', '>=', $today);
        });
    }

    /**
     * Scope: filter berdasarkan time slot
     */
    public function scopeInTimeSlot($query)
    {
        $currentTime = Carbon::now()->format('H:i:s');

        return $query->where(function ($q) use ($currentTime) {
            // Jika start_time dan end_time null, artinya aktif sepanjang hari
            $q->where(function ($subQ) {
                $subQ->whereNull('start_time')
                     ->whereNull('end_time');
            })
            // Atau dalam range waktu yang ditentukan
            ->orWhere(function ($subQ) use ($currentTime) {
                $subQ->whereNotNull('start_time')
                     ->whereNotNull('end_time')
                     ->whereRaw('? BETWEEN start_time AND end_time', [$currentTime]);
            });
        });
    }

    /**
     * Scope: running text yang currently active
     */
    public function scopeCurrentlyActive($query)
    {
        return $query->active()
                    ->inDateRange()
                    ->inTimeSlot()
                    ->orderBy('priority', 'desc')
                    ->orderBy('created_at', 'desc');
    }

    /**
     * Check apakah running text ini aktif sekarang
     */
    public function isCurrentlyActive(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        // Check date range
        $today = Carbon::today();
        if ($this->start_date && Carbon::parse($this->start_date)->gt($today)) {
            return false;
        }
        if ($this->end_date && Carbon::parse($this->end_date)->lt($today)) {
            return false;
        }

        // Check time slot
        if ($this->start_time && $this->end_time) {
            $currentTime = Carbon::now()->format('H:i:s');
            if ($currentTime < $this->start_time || $currentTime > $this->end_time) {
                return false;
            }
        }

        return true;
    }
}
