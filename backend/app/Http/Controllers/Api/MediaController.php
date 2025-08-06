<?php

namespace App\Http\Controllers\Api;

use App\Models\Media;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class MediaController extends Controller
{
    public function index(Request $request)
    {
        $query = Media::query();

        if ($request->has('type')) {
            $query->where('type', $request->input('type')); // audio/video
        }

        if ($request->has('category')) {
            $query->where('category', $request->input('category'));
        }

        if ($request->has('search')) {
            $query->where('title', 'like', '%' . $request->input('search') . '%');
        }

        $media = $query->orderByDesc('id')->get()->map(function ($item) {
            return [
                'id' => $item->id,
                'title' => $item->title,
                'type' => $item->type,
                'category' => $item->category,
                'file_path' => $item->file_path,
                'download_url' => url(ltrim($item->file_path, '/')),
                'thumbnail' => $item->thumbnail ? url(ltrim($item->thumbnail, '/')) : null, 
                'duration' => $item->duration, 
                'artist' => $item->artist,      
                'description' => $item->description,      
                'rating' => $item->rating,      
                'album' => $item->album,        
                'cast' => $item->cast,        
                'cast_json' => $item->cast_json,        
                'director' => $item->director,        
                'writers' => $item->writers,        
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $media
        ]);
    }

}
