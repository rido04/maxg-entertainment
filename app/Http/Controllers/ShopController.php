<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;

class ShopController extends Controller
{
    public function index()
    {
        // Mengambil semua file gambar dari folder public/media/products
        $productPath = public_path('media/products');
        $products = [];
        
        if (File::exists($productPath)) {
            $files = File::files($productPath);
            
            foreach ($files as $file) {
                $filename = $file->getFilename();
                $extension = $file->getExtension();
                
                // Hanya ambil file gambar
                if (in_array(strtolower($extension), ['jpg', 'jpeg', 'png', 'gif', 'webp'])) {
                    $products[] = [
                        'filename' => $filename,
                        'path' => 'media/products/' . $filename,
                        'name' => pathinfo($filename, PATHINFO_FILENAME)
                    ];
                }
            }
        }
        
        // Kirim variabel $products ke view
        return view('shop', compact('products'));
    }
}
