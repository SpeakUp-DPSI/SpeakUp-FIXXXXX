<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reporter_id')->constrained('users')->onDelete('cascade');
            $table->string('title');
            $table->text('description');
            $table->enum('status', ['draft', 'submitted', 'waiting_validation', 'valid', 'processing', 'mediation', 'follow_up', 'completed', 'rejected'])->default('submitted');
            $table->boolean('is_anonymous')->default(false);
            $table->string('incident_location')->nullable();
            $table->date('incident_date')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};
