<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Feedback extends Model
{
    protected $fillable =[
        'subject',
        'message',
        'category',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $table = 'feedbacks';


    // Helper method untuk mendapatkan label kategori yang lebih readable
    public function getCategoryLabelAttribute(): string
    {
        return match($this->category) {
            'bug' => 'Bug Report',
            'suggestion' => 'Suggestion',
            'complaint' => 'Complaint',
            'general' => 'General',
            default => 'General',
        };
    }

    // Scope untuk feedback berdasarkan kategori
    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }
}
