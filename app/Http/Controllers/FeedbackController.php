<?php

namespace App\Http\Controllers;

use App\Models\Feedback;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;

class FeedbackController extends Controller
{
    /**
     * Display the feedback form.
     */
    public function create(): View
    {
        return view('feedback.create');
    }

    /**
     * Store a newly created feedback.
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'subject' => 'required|string|max:255',
            'message' => 'required|string|max:1000',
            'category' => 'required|in:bug,suggestion,complaint,general',
        ]);

        Feedback::create($validated);

        return redirect()->route('feedback.create')
            ->with('success', 'Thank you! Your feedback has been sent successfully.');
    }
}
