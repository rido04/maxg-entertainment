<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('advertisements', function (Blueprint $table) {
            // Ubah video_path jadi lebih generic (support image juga)
            $table->renameColumn('video_path', 'file_path');

            // Tambah kolom baru
            $table->string('type')->default('video')->after('title');
            // 'video' atau 'image'

            $table->text('description')->nullable()->after('type');

            $table->string('thumbnail')->nullable()->after('file_path');
            // Thumbnail untuk preview

            $table->integer('duration')->default(15)->after('thumbnail');
            // Duration in seconds (untuk image)

            $table->integer('priority')->default(0)->after('duration');
            // Higher = show first

            // Demographic targeting (replace target_category dengan yang lebih specific)
            $table->json('target_gender')->nullable()->after('is_active');
            // ['male', 'female', 'all']

            $table->json('target_age_group')->nullable()->after('target_gender');
            // ['child', 'teen', 'adult', 'senior', 'all']

            // Schedule
            $table->timestamp('start_date')->nullable()->after('target_age_group');
            $table->timestamp('end_date')->nullable()->after('start_date');
        });
    }

    public function down(): void
    {
        Schema::table('advertisements', function (Blueprint $table) {
            $table->renameColumn('file_path', 'video_path');

            $table->dropColumn([
                'type',
                'description',
                'thumbnail',
                'duration',
                'priority',
                'target_gender',
                'target_age_group',
                'start_date',
                'end_date',
            ]);
        });
    }
};
