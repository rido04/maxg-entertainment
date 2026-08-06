// database/migrations/xxxx_create_passenger_sessions_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('passenger_sessions', function (Blueprint $table) {
            $table->id();
            $table->uuid('session_id')->unique();
            $table->string('device_id'); // Tablet identifier
            $table->string('driver_id')->nullable(); // Optional
            $table->timestamp('start_time');
            $table->timestamp('end_time')->nullable();
            $table->integer('duration_seconds')->default(0);
            $table->enum('gender', ['male', 'female', 'unknown'])->default('unknown');
            $table->string('age_group')->nullable(); // 'child', 'teen', 'adult', 'senior'
            $table->integer('ad_view_count')->default(0);
            $table->json('viewed_ads')->nullable(); // Array of ad IDs
            $table->json('metadata')->nullable(); // Extra data
            $table->timestamps();

            $table->index(['device_id', 'start_time']);
            $table->index('gender');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('passenger_sessions');
    }
};
