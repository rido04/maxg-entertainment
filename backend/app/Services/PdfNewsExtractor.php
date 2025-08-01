<?php
// app/Services/PdfNewsExtractor.php
namespace App\Services;

use Smalot\PdfParser\Parser;
use Spatie\PdfToImage\Pdf;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class PdfNewsExtractor
{
    public function extract(string $pdfPath): array
    {
        // Full path
        $fullPath = storage_path('app/' . $pdfPath);

        // === Extract Text ===
        $parser = new Parser();
        $pdf = $parser->parseFile($fullPath);
        $text = $pdf->getText();

        $lines = array_filter(explode("\n", $text));
        $title = Str::limit($lines[0] ?? 'Untitled', 100);
        $description = Str::limit(implode(' ', array_slice($lines, 1, 3)), 200);

        // === Generate Thumbnail ===
        $imageName = 'news_images/' . uniqid() . '.jpg';
        $pdfToImage = new Pdf($fullPath);
        $pdfToImage->saveImage(storage_path('app/public/' . $imageName));

        return [
            'title' => $title,
            'description' => $description,
            'image_path' => $imageName,
        ];
    }
}
