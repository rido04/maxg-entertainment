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
                'thumbnail' => $item->thumbnail ? url(ltrim($item->thumbnail, '/')) : null, // ✅ Tambah ini
                'duration' => $item->duration,  // ✅ Tambah ini juga
                'artist' => $item->artist,      // ✅ Dan ini
                'album' => $item->album,        // ✅ Dan ini
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $media
        ]);
    }

}
