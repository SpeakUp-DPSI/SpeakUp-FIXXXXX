<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Spatie\Permission\Traits\HasRoles;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles;

    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'avatar',
        'fcm_token',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function reports()
    {
        return $this->hasMany(Report::class, 'reporter_id');
    }

    public function validations()
    {
        return $this->hasMany(Validation::class, 'validator_id');
    }

    public function mediationsAsMediator()
    {
        return $this->hasMany(Mediation::class, 'mediator_id');
    }

    public function mediationParticipations()
    {
        return $this->hasMany(MediationParticipant::class, 'user_id');
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class, 'user_id');
    }

    public function children()
    {
        return $this->belongsToMany(User::class, 'parent_child', 'parent_id', 'child_id');
    }

    public function parents()
    {
        return $this->belongsToMany(User::class, 'parent_child', 'child_id', 'parent_id');
    }
}
