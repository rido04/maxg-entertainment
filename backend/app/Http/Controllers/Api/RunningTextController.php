<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RunningText;
use Illuminate\Http\Request;

class RunningTextController extends Controller
{
    /**
     * Get all active running texts (currently active based on date & time)
     */
    public function active(Request $request)
    {
        $runningTexts = RunningText::currentlyActive()->get();

        return response()->json([
            'success' => true,
            'count' => $runningTexts->count(),
            'data' => $runningTexts->map(function ($rt) {
                return [
                    'id' => $rt->id,
                    'text' => $rt->text,
                    'position' => $rt->position,
                    'priority' => $rt->priority,
                    'background_color' => $rt->background_color ?? '#000000',
                    'text_color' => $rt->text_color ?? '#FFFFFF',
                    'font_size' => $rt->font_size,
                    'speed' => $rt->speed,
                    'display_duration' => $rt->display_duration,
                    'start_date' => $rt->start_date ? \Carbon\Carbon::parse($rt->start_date)->format('Y-m-d') : null,
                    'end_date' => $rt->end_date ? \Carbon\Carbon::parse($rt->end_date)->format('Y-m-d') : null,
                    'start_time' => $rt->start_time,
                    'end_time' => $rt->end_time,
                ];
            }),
        ]);
    }

    /**
     * Get all running texts (for admin panel)
     */
    public function index(Request $request)
    {
        $query = RunningText::query()
            ->orderBy('priority', 'desc')
            ->orderBy('created_at', 'desc');

        // Filter by active status
        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        // Filter by position
        if ($request->has('position')) {
            $query->where('position', $request->position);
        }

        $runningTexts = $query->get();

        return response()->json([
            'success' => true,
            'data' => $runningTexts,
        ]);
    }

    /**
     * Store a new running text
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'text' => 'required|string',
            'position' => 'required|in:top,bottom',
            'priority' => 'nullable|integer',
            'is_active' => 'nullable|boolean',
            'background_color' => 'nullable|string',
            'text_color' => 'nullable|string',
            'font_size' => 'nullable|integer|min:10|max:100',
            'speed' => 'nullable|integer|min:10|max:200',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'start_time' => 'nullable|date_format:H:i:s',
            'end_time' => 'nullable|date_format:H:i:s',
            'display_duration' => 'nullable|integer|min:5|max:300',
        ]);

        $runningText = RunningText::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Running text created successfully',
            'data' => $runningText,
        ], 201);
    }

    /**
     * Update running text
     */
    public function update(Request $request, $id)
    {
        $runningText = RunningText::findOrFail($id);

        $validated = $request->validate([
            'text' => 'sometimes|required|string',
            'position' => 'sometimes|required|in:top,bottom',
            'priority' => 'nullable|integer',
            'is_active' => 'nullable|boolean',
            'background_color' => 'nullable|string',
            'text_color' => 'nullable|string',
            'font_size' => 'nullable|integer|min:10|max:100',
            'speed' => 'nullable|integer|min:10|max:200',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'start_time' => 'nullable|date_format:H:i:s',
            'end_time' => 'nullable|date_format:H:i:s',
            'display_duration' => 'nullable|integer|min:5|max:300',
        ]);

        $runningText->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Running text updated successfully',
            'data' => $runningText,
        ]);
    }

    /**
     * Delete running text
     */
    public function destroy($id)
    {
        $runningText = RunningText::findOrFail($id);
        $runningText->delete();

        return response()->json([
            'success' => true,
            'message' => 'Running text deleted successfully',
        ]);
    }
}
