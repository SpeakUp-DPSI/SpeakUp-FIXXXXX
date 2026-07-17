<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReportParticipant extends Model
{
    use HasFactory;

    protected $fillable = [
        'report_id',
        'role',
        'user_id',
        'name',
        'class_name',
        'notes',
    ];

    public function report()
    {
        return $this->belongsTo(Report::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
