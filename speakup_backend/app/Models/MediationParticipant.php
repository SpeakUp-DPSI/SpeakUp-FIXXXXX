<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MediationParticipant extends Model
{
    use HasFactory;

    protected $fillable = [
        'mediation_id',
        'user_id',
        'status',
    ];

    public function mediation()
    {
        return $this->belongsTo(Mediation::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
