<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $table = 'product';

    protected $fillable = [
        'name',
        'description',
        'price',
        'stock',
        'sku',
        'category',
        'image_path',
        'is_active',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'stock' => 'integer',
        'is_active' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];


    public function getImageUrlAttribute()
    {
        return $this->image_path
            ? asset("storage/{$this->image_path}")
            : asset('images/default-product.png');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeSearch($query, $term)
    {
        return $query->where('name', 'LIKE', "%{$term}%")
                     ->orWhere('description', 'LIKE', "%{$term}%");
    }

    public function scopeInStock($query)
    {
        return $query->where('stock', '>', 0);
    }
    public function scopeOutOfStock($query)
    {
        return $query->where('stock', 0);
    }
    public function scopePriceRange($query, $min, $max)
    {
        return $query->whereBetween('price', [$min, $max]);
    }
}
