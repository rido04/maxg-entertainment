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
        Schema::table('passenger_sessions', function (Blueprint $table) {
            $table->json('viewed_ads')->nullable()->change();
            $table->json('metadata')->nullable()->change();
        });
    }

    public function down()
    {
        Schema::table('passenger_sessions', function (Blueprint $table) {
            $table->longText('viewed_ads')->nullable()->change();
            $table->longText('metadata')->nullable()->change();
        });
    }
};
