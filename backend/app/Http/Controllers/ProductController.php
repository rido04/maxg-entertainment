<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::active();

        // Filter by category if provided
        if ($request->has('category') && $request->category) {
            $query->where('category', $request->category);
        }

        // Search functionality
        if ($request->has('search') && $request->search) {
            $query->search($request->search);
        }

        // Sort options
        $sortBy = $request->get('sort', 'created_at');
        $sortOrder = $request->get('order', 'desc');

        switch ($sortBy) {
            case 'name':
                $query->orderBy('name', $sortOrder);
                break;
            case 'price':
                $query->orderBy('price', $sortOrder);
                break;
            case 'stock':
                $query->orderBy('stock', $sortOrder);
                break;
            default:
                $query->orderBy('created_at', $sortOrder);
        }

        $products = $query->paginate(12);

        // Ganti ini dengan banner dari database
        $banners = $this->getBannersFromDatabase();

        $categories = $this->getCategories();

        return view('catalog.index', compact('products', 'banners', 'categories'));
    }

    public function show($productSlug)
    {
        // Find product by slug (name converted to slug format)
        $productModel = Product::active()
            ->where('name', str_replace('-', ' ', $productSlug))
            ->orWhere('sku', strtoupper($productSlug))
            ->first();

        if (!$productModel) {
            abort(404, 'Product not found');
        }

        // Convert product model to array format expected by view
        $product = [
            'id' => $productModel->id,
            'name' => $productModel->name,
            'description' => $productModel->description ?? $this->generateProductDescription($productModel->name),
            'price' => $productModel->price,
            'stock' => $productModel->stock,
            'sku' => $productModel->sku,
            'category' => $productModel->category,
            'path' => $productModel->image_path ? asset('storage/' . $productModel->image_path) : asset('images/placeholder.jpg'),
            'features' => $this->generateProductFeatures($productModel->category, $productModel->name),
            'is_active' => $productModel->is_active,
        ];

        // Get related products from same category
        $relatedProductsQuery = Product::active()
            ->where('id', '!=', $productModel->id)
            ->where('category', $productModel->category)
            ->inStock()
            ->limit(6)
            ->get();

        // If not enough related products, get random products
        if ($relatedProductsQuery->count() < 6) {
            $additionalProducts = Product::active()
                ->where('id', '!=', $productModel->id)
                ->whereNotIn('id', $relatedProductsQuery->pluck('id'))
                ->inStock()
                ->inRandomOrder()
                ->limit(6 - $relatedProductsQuery->count())
                ->get();

            $relatedProductsQuery = $relatedProductsQuery->merge($additionalProducts);
        }

        // Convert related products to array format
        $relatedProducts = $relatedProductsQuery->map(function ($relatedProduct) {
            return [
                'id' => $relatedProduct->id,
                'name' => $relatedProduct->name,
                'price' => $relatedProduct->price,
                'path' => $relatedProduct->image ? asset('storage/' . $relatedProduct->image) : asset('images/placeholder.jpg'),
                'category' => $relatedProduct->category,
            ];
        })->toArray();

        return view('catalog.show', compact('product', 'relatedProducts'));
    }

    public function category($categorySlug)
    {
        $category = str_replace('-', '_', $categorySlug);

        $products = Product::active()
            ->where('category', $category)
            ->inStock()
            ->orderBy('created_at', 'desc')
            ->paginate(12);

        if ($products->isEmpty()) {
            abort(404, 'Category not found');
        }

        $categoryName = ucwords(str_replace(['_', '-'], ' ', $category));

        return view('catalog.category', compact('products', 'category', 'categoryName'));
    }

    public function search(Request $request)
    {
        $query = $request->get('q');

        if (!$query) {
            return redirect()->route('products.index');
        }

        $products = Product::active()
            ->search($query)
            ->inStock()
            ->orderBy('name')
            ->paginate(12);

        return view('catalog.search', compact('products', 'query'));
    }

    // API endpoint for product suggestions (for search autocomplete)
    public function suggestions(Request $request)
    {
        $query = $request->get('q');

        if (!$query || strlen($query) < 2) {
            return response()->json([]);
        }

        $products = Product::active()
            ->where('name', 'like', '%' . $query . '%')
            ->orWhere('sku', 'like', '%' . $query . '%')
            ->limit(5)
            ->get(['name', 'sku', 'price', 'image_path']);

        return response()->json($products);
    }

    // Get product by SKU (useful for direct access)
    public function showBySku($sku)
    {
        $product = Product::active()->where('sku', $sku)->first();

        if (!$product) {
            abort(404, 'Product not found');
        }

        return redirect()->route('products.show', [
            'productSlug' => str_replace(' ', '-', strtolower($product->name))
        ]);
    }

    // Add to cart functionality (if you have cart system)
    public function addToCart(Request $request, Product $product)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1|max:' . $product->stock
        ]);

        // Check if product is available
        if (!$product->is_active || !$product->isInStock()) {
            return response()->json([
                'success' => false,
                'message' => 'Product is not available'
            ], 400);
        }

        $quantity = $request->get('quantity', 1);

        // Check stock availability
        if ($product->stock < $quantity) {
            return response()->json([
                'success' => false,
                'message' => 'Not enough stock available'
            ], 400);
        }

        // Add to cart logic here (depends on your cart implementation)
        // For example, if using session-based cart:
        $cart = session()->get('cart', []);

        if (isset($cart[$product->id])) {
            $cart[$product->id]['quantity'] += $quantity;
        } else {
            $cart[$product->id] = [
                'product' => $product->toArray(),
                'quantity' => $quantity
            ];
        }

        session()->put('cart', $cart);

        return response()->json([
            'success' => true,
            'message' => 'Product added to cart',
            'cart_count' => collect($cart)->sum('quantity')
        ]);
    }

    // Generate product features based on category
    private function generateProductFeatures($category, $productName)
    {
        $baseFeatures = [
            'Premium Quality Materials',
            'Carefully Selected for Travelers',
            'Exclusive GarudaShop Collection',
            '30-Day Money Back Guarantee'
        ];

        $categoryFeatures = [
            'electronics' => [
                'Latest Technology',
                'Energy Efficient',
                'Compact Design',
                'Travel-Friendly Size'
            ],
            'fashion' => [
                'Trendy Design',
                'Comfortable Fit',
                'Durable Construction',
                'Versatile Style'
            ],
            'beauty' => [
                'Dermatologically Tested',
                'Long-Lasting Formula',
                'Premium Ingredients',
                'Travel Size Available'
            ],
            'clothing' => [
                'Comfortable Fabric',
                'Wrinkle Resistant',
                'Easy Care Instructions',
                'Perfect for Travel'
            ],
            'other' => [
                'High-Quality Construction',
                'Functional Design',
                'Compact and Portable',
                'Great Value'
            ]
        ];

        $features = array_merge(
            $baseFeatures,
            $categoryFeatures[$category] ?? $categoryFeatures['other']
        );

        return array_slice($features, 0, 6); // Return max 6 features
    }

    // Get categories for filter dropdown
    private function getCategories()
    {
        return Product::active()
            ->whereNotNull('category')
            ->distinct()
            ->pluck('category')
            ->map(function ($category) {
                return [
                    'slug' => $category,
                    'name' => ucwords(str_replace(['_', '-'], ' ', $category))
                ];
            })
            ->sortBy('name');
    }

    // Keep the banner functionality from your original code
    private function getBanners()
    {
        $bannerPath = public_path('media/banner');

        if (!File::exists($bannerPath)) {
            return [];
        }

        $files = File::files($bannerPath);
        $banners = [];

        foreach ($files as $file) {
            $filename = $file->getFilename();
            $name = pathinfo($filename, PATHINFO_FILENAME);

            // Skip hidden files and non-image files
            if (str_starts_with($filename, '.') || !in_array(strtolower($file->getExtension()), ['jpg', 'jpeg', 'png', 'gif', 'webp'])) {
                continue;
            }

            $banners[] = [
                'name' => $name,
                'path' => 'media/banner/' . $filename,
                'filename' => $filename
            ];
        }

        return $banners;
    }

    // Admin function to sync products from files (if needed)
    public function syncFromFiles()
    {
        $productPath = storage_path('app/public/products');

        if (!File::exists($productPath)) {
            return response()->json([
                'success' => false,
                'message' => 'Product directory not found'
            ]);
        }

        $files = File::files($productPath);
        $syncedCount = 0;

        foreach ($files as $file) {
            $filename = $file->getFilename();
            $name = pathinfo($filename, PATHINFO_FILENAME);

            // Skip hidden files and non-image files
            if (str_starts_with($filename, '.') || !in_array(strtolower($file->getExtension()), ['jpg', 'jpeg', 'png', 'gif', 'webp'])) {
                continue;
            }

            // Check if product already exists
            $existingProduct = Product::where('name', $name)->first();
            if ($existingProduct) {
                continue;
            }

            // Create new product
            $cleanName = ucwords(str_replace(['_', '-'], ' ', $name));
            $category = $this->detectCategoryFromName($name);

            Product::create([
                'name' => $cleanName,
                'description' => $this->generateProductDescription($cleanName),
                'price' => $this->generateProductPrice(),
                'stock' => rand(10, 100),
                'sku' => strtoupper(str_replace([' ', '_', '-'], '', $name)) . rand(1000, 9999),
                'category' => $category,
                'image_path' => 'products/' . $filename,
                'is_active' => true,
            ]);

            $syncedCount++;
        }

        return response()->json([
            'success' => true,
            'message' => "Synced {$syncedCount} products from files"
        ]);
    }

    private function detectCategoryFromName($name)
    {
        $lowerName = strtolower($name);

        $categoryMapping = [
            'watch' => 'electronics',
            'bag' => 'fashion',
            'perfume' => 'beauty',
            'jewelry' => 'fashion',
            'ring' => 'fashion',
            'necklace' => 'fashion',
            'phone' => 'electronics',
            'tech' => 'electronics',
            'shirt' => 'clothing',
            'dress' => 'clothing',
            'shoe' => 'clothing',
        ];

        foreach ($categoryMapping as $keyword => $category) {
            if (str_contains($lowerName, $keyword)) {
                return $category;
            }
        }

        return 'other';
    }

    private function generateProductDescription($productName)
    {
        $descriptions = [
            'default' => "Experience luxury with the premium {$productName}. Carefully selected for discerning travelers who appreciate quality and sophistication. Available exclusively through GarudaShop's in-flight shopping experience.",
            'electronics' => "State-of-the-art technology designed for modern travelers. Combining functionality with premium aesthetics.",
            'fashion' => "Premium fashion item that combines comfort with contemporary style. Perfect for the fashion-conscious traveler.",
            'beauty' => "Exquisite product that captures the essence of luxury travel. A sophisticated choice for the discerning traveler.",
            'clothing' => "Premium clothing item crafted with attention to detail. Designed for comfort and style during your travels.",
        ];

        return str_replace('{$productName}', $productName, $descriptions['default']);
    }

    private function generateProductPrice()
    {
        $prices = [49.99, 79.99, 99.99, 129.99, 149.99, 199.99, 249.99, 299.99, 349.99, 399.99, 449.99, 499.99];
        return $prices[array_rand($prices)];
    }

    private function getBannersFromDatabase()
    {
        $bannerData = \App\Models\Banner::getHomepageBanners();

        // Konversi ke format yang diharapkan view
        $banners = collect();

        // Main banners (untuk slider utama)
        foreach ($bannerData['main'] as $banner) {
            $banners->push([
                'id' => $banner->id,
                'name' => $banner->title,
                'path' => $banner->image_url,
                'title' => $banner->title,
                'subtitle' => $banner->subtitle,
                'button_text' => $banner->button_text,
                'link_url' => $banner->link_url,
                'position' => $banner->position
            ]);
        }

        // Side banners
        if ($bannerData['side_top']->isNotEmpty()) {
            $banner = $bannerData['side_top']->first();
            $banners->push([
                'id' => $banner->id,
                'name' => $banner->title,
                'path' => $banner->image_url,
                'title' => $banner->title,
                'subtitle' => $banner->subtitle,
                'button_text' => $banner->button_text,
                'link_url' => $banner->link_url,
                'position' => $banner->position
            ]);
        }

        if ($bannerData['side_bottom']->isNotEmpty()) {
            $banner = $bannerData['side_bottom']->first();
            $banners->push([
                'id' => $banner->id,
                'name' => $banner->title,
                'path' => $banner->image_url,
                'title' => $banner->title,
                'subtitle' => $banner->subtitle,
                'button_text' => $banner->button_text,
                'link_url' => $banner->link_url,
                'position' => $banner->position
            ]);
        }

        return $banners;
    }
}
