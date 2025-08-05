<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('media', function (Blueprint $table) {
            $table->id();
            $table->string('title')->nullable();
            $table->string('file_path');
            $table->enum('type', ['video', 'audio']);
            $table->string('thumbnail')->nullable();
            $table->string('category')->nullable();
            $table->boolean('is_adult_content')->default(false);
            $table->string('content_rating', 10)->nullable();
            $table->integer('duration')->nullable(); // dalam detik
            $table->text('description')->nullable(); // overview
            $table->decimal('rating', 3, 1)->nullable(); // vote_average
            $table->string('release_date')->nullable(); // release_date
            $table->string('language')->nullable(); // original_language
            $table->string('tmdb_id')->nullable(); // untuk referensi ID TMDb
            $table->string('artist')->nullable();
            $table->string('artist_image')->nullable();
            $table->text('cast')->nullable();
            $table->json('cast_json')->nullable();
            $table->string('director')->nullable();
            $table->text('writers')->nullable();
            $table->string('album')->nullable();
            $table->index('is_adult_content');
            $table->index('content_rating');
            $table->string('checksum', 64)->nullable(); // SHA-256 hash
            $table->enum('hash_type', ['md5', 'sha1', 'sha256'])->default('sha256');
            $table->unsignedBigInteger('filesize')->nullable();
            $table->timestamps();
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('media');
    }
};
