<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Report extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'report_code',
        'category',
        'reporter_id',
        'title',
        'description',
        'status',
        'is_anonymous',
        'incident_location',
        'incident_date',
    ];

    protected $casts = [
        'is_anonymous' => 'boolean',
        'incident_date' => 'date',
    ];

    public function reporter()
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    public function evidences()
    {
        return $this->hasMany(Evidence::class);
    }

    public function validations()
    {
        return $this->hasMany(Validation::class);
    }

    public function mediations()
    {
        return $this->hasMany(Mediation::class);
    }

    public function followUps()
    {
        return $this->hasMany(FollowUp::class);
    }

    public function participants()
    {
        return $this->hasMany(ReportParticipant::class);
    }

    public function statusHistories()
    {
        return $this->hasMany(ReportStatusHistory::class);
    }
}
