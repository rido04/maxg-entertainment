<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PassengerSession;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SessionController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'session_id' => 'required|uuid',
            'device_id' => 'required|string',
            'driver_id' => 'nullable|string',
            'start_time' => 'required|date',
            'end_time' => 'required|date|after:start_time',
            'duration_seconds' => 'required|integer|min:0',
            'gender' => 'required|in:male,female,unknown',
            'age_group' => 'nullable|string',
            'ad_view_count' => 'required|integer|min:0',
            'viewed_ads' => 'nullable|array',
            'viewed_ads.*.ad_id' => 'required|integer',
            'viewed_ads.*.ad_title' => 'required|string',
            'viewed_ads.*.viewed_at' => 'required|date',
            'viewed_ads.*.duration_seconds' => 'nullable|integer',

            'metadata' => 'nullable|array',
        ]);

        $session = PassengerSession::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Session logged successfully',
            'data' => $session,
        ], 201);
    }

    public function index(Request $request)
    {
        $query = PassengerSession::query();

        // Filter by device
        if ($request->has('device_id')) {
            $query->where('device_id', $request->device_id);
        }

        // Filter by date range
        if ($request->has('from') && $request->has('to')) {
            $query->whereBetween('start_time', [
                $request->from,
                $request->to
            ]);
        }

        $sessions = $query->latest('start_time')
                          ->paginate(50);

        return response()->json($sessions);
    }

    public function stats(Request $request)
    {
        $deviceId = $request->input('device_id');
        $period = $request->input('period', 'today'); // today, week, month

        $query = PassengerSession::query();

        if ($deviceId) {
            $query->where('device_id', $deviceId);
        }

        switch ($period) {
            case 'week':
                $query->thisWeek();
                break;
            case 'month':
                $query->thisMonth();
                break;
            default:
                $query->today();
        }

        return response()->json([
            'total_sessions' => $query->count(),
            'total_duration' => $query->sum('duration_seconds'),
            'avg_duration' => $query->avg('duration_seconds'),
            'gender_distribution' => [
                'male' => $query->clone()->where('gender', 'male')->count(),
                'female' => $query->clone()->where('gender', 'female')->count(),
                'unknown' => $query->clone()->where('gender', 'unknown')->count(),
            ],
            'total_ad_views' => $query->sum('ad_view_count'),
        ]);
    }
}
