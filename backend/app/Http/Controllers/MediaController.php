<?php

namespace App\Http\Controllers;

use App\Models\Media;
use Illuminate\Http\Request;

class MediaController extends Controller
{
    public function index()
    {
        $media = Media::latest()->get();

        return response()->json([
            'success' => true,
            'data' => $media
        ]);
    }
}
