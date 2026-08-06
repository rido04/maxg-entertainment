<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Advertisement;
use Illuminate\Http\Request;

class AdvertisementController extends Controller
{
    public function index(Request $request)
    {
        $query = Advertisement::active()
                              ->orderBy('priority', 'desc')
                              ->orderBy('created_at', 'desc');

        // Filter by gender
        if ($request->has('gender')) {
            $query->forGender($request->gender);
        }

        // Filter by age group
        if ($request->has('age_group')) {
            $query->forAgeGroup($request->age_group);
        }

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $ads = $query->get();

        return response()->json([
            'success' => true,
            'data' => $ads->map(function ($ad) {
                return [
                    'id' => $ad->id,
                    'title' => $ad->title,
                    'description' => $ad->description,
                    'type' => $ad->type,
                    'file_url' => $ad->file_url,
                    'thumbnail_url' => $ad->thumbnail_url,
                    'duration' => $ad->duration,
                    'priority' => $ad->priority,
                    'target_gender' => $ad->target_gender,
                    'target_age_group' => $ad->target_age_group,
                ];
            }),
        ]);
    }

    public function active(Request $request)
    {
        // Hanya ads yang benar-benar aktif sekarang
        $ads = Advertisement::query()
            ->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('start_date')
                  ->orWhere('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                  ->orWhere('end_date', '>=', now());
            })
            ->orderBy('priority', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'count' => $ads->count(),
            'data' => $ads,
        ]);
    }
}
