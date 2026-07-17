<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FirebaseNotificationService
{
    protected $serverKey;

    public function __construct()
    {
        // Secara ideal, Laravel 11/12 Firebase disarankan memakai paket kreait/firebase-php
        // atau API v1 Google Cloud Auth. 
        // Untuk mock/skeleton ini, kita asumsikan menggunakan Http request standar.
        $this->serverKey = env('FIREBASE_SERVER_KEY', 'your-server-key-here');
    }

    public function sendNotification(User $user, $title, $body, $data = [])
    {
        if (!$user->fcm_token) {
            return false;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'key=' . $this->serverKey,
                'Content-Type'  => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', [
                'to' => $user->fcm_token,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => $data,
            ]);

            return $response->successful();
        } catch (\Exception $e) {
            Log::error('FCM Error: ' . $e->getMessage());
            return false;
        }
    }
}
