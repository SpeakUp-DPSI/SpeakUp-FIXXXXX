<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FollowUp extends Model
{
    use HasFactory;

    protected $fillable = [
        'report_id',
        'executor_id',
        'action_taken',
        'follow_up_date',
    ];

    protected $casts = [
        'follow_up_date' => 'datetime',
    ];

    public function report()
    {
        return $this->belongsTo(Report::class);
    }

    public function executor()
    {
        return $this->belongsTo(User::class, 'executor_id');
    }
}
