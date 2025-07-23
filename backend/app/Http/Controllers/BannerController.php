<?php

namespace App\Http\Controllers;

use App\Models\Banner;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Storage;

class BannerController extends Controller
{
    public function index()
    {
        $banners = Banner::orderBy('position')
                        ->orderBy('sort_order')
                        ->orderBy('created_at', 'desc')
                        ->paginate(15);

        return view('admin.banners.index', compact('banners'));
    }

    public function create()
    {
        return view('admin.banners.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'subtitle' => 'nullable|string|max:255',
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
            'link_url' => 'nullable|url',
            'button_text' => 'required|string|max:50',
            'position' => ['required', Rule::in(['main', 'side_top', 'side_bottom'])],
            'sort_order' => 'required|integer|min:0',
            'is_active' => 'boolean',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        // Upload gambar
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('banners', 'public');
            $validated['image_path'] = $imagePath;
        }

        Banner::create($validated);

        return redirect()->route('admin.banners.index')
                        ->with('success', 'Banner berhasil ditambahkan.');
    }

    public function show(Banner $banner)
    {
        return view('admin.banners.show', compact('banner'));
    }

    public function edit(Banner $banner)
    {
        return view('admin.banners.edit', compact('banner'));
    }

    public function update(Request $request, Banner $banner)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'subtitle' => 'nullable|string|max:255',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'link_url' => 'nullable|url',
            'button_text' => 'required|string|max:50',
            'position' => ['required', Rule::in(['main', 'side_top', 'side_bottom'])],
            'sort_order' => 'required|integer|min:0',
            'is_active' => 'boolean',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        // Upload gambar baru jika ada
        if ($request->hasFile('image')) {
            // Hapus gambar lama
            if ($banner->image_path && Storage::disk('public')->exists($banner->image_path)) {
                Storage::disk('public')->delete($banner->image_path);
            }

            $imagePath = $request->file('image')->store('banners', 'public');
            $validated['image_path'] = $imagePath;
        }

        $banner->update($validated);

        return redirect()->route('admin.banners.index')
                        ->with('success', 'Banner berhasil diupdate.');
    }

    public function destroy(Banner $banner)
    {
        // Hapus file gambar
        if ($banner->image_path && Storage::disk('public')->exists($banner->image_path)) {
            Storage::disk('public')->delete($banner->image_path);
        }

        $banner->delete();

        return redirect()->route('admin.banners.index')
                        ->with('success', 'Banner berhasil dihapus.');
    }

    // Method untuk toggle status aktif
    public function toggleStatus(Banner $banner)
    {
        $banner->update(['is_active' => !$banner->is_active]);

        $status = $banner->is_active ? 'diaktifkan' : 'dinonaktifkan';

        return redirect()->back()
                        ->with('success', "Banner berhasil {$status}.");
    }

    // Method untuk update urutan banner
    public function updateOrder(Request $request)
    {
        $validated = $request->validate([
            'orders' => 'required|array',
            'orders.*.id' => 'required|exists:banners,id',
            'orders.*.sort_order' => 'required|integer|min:0'
        ]);

        foreach ($validated['orders'] as $order) {
            Banner::where('id', $order['id'])
                  ->update(['sort_order' => $order['sort_order']]);
        }

        return response()->json(['success' => true]);
    }
}
