<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mediation extends Model
{
    use HasFactory;

    protected $fillable = [
        'report_id',
        'mediator_id',
        'schedule_date',
        'location',
        'status',
        'result',
    ];

    protected $casts = [
        'schedule_date' => 'datetime',
    ];

    public function report()
    {
        return $this->belongsTo(Report::class);
    }

    public function mediator()
    {
        return $this->belongsTo(User::class, 'mediator_id');
    }

    public function participants()
    {
        return $this->hasMany(MediationParticipant::class);
    }
}
