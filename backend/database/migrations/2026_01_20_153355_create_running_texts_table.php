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
        Schema::create('running_texts', function (Blueprint $table) {
            $table->id();
            $table->text('text');
            $table->enum('position', ['top', 'bottom'])->default('bottom');
            $table->integer('priority')->default(0);
            $table->boolean('is_active')->default(true);

            // Styling
            $table->string('background_color')->nullable()->comment('e.g., #000000 or rgba(0,0,0,0.5)');
            $table->string('text_color')->nullable()->comment('e.g., #FFFFFF');
            $table->integer('font_size')->default(16);
            $table->integer('speed')->default(50)->comment('Pixels per second');

            // Scheduling - Date Range
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();

            // Scheduling - Daily Time Slot
            $table->time('start_time')->nullable();
            $table->time('end_time')->nullable();

            // Rotation
            $table->integer('display_duration')->default(30)->comment('Seconds per display');

            $table->timestamps();

            // Indexes
            $table->index(['is_active', 'priority']);
            $table->index(['start_date', 'end_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('running_texts');
    }
};
