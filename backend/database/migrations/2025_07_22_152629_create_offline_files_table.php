<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('offline_files', function (Blueprint $table) {
            $table->id();
            $table->enum('type', ['video', 'music']);
            $table->string('title');
            $table->string('filename'); // nama file asli
            $table->string('path');     // misal: media/videos/nama.mp4
            $table->string('thumbnail')->nullable(); // optional gambar
            $table->integer('duration')->nullable(); // dalam detik, opsional
            $table->timestamps();
        });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('offline_files');
    }
};
