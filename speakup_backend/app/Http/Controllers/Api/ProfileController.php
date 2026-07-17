<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public function update(Request $request)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'nullable|string|max:20',
            'avatar' => 'nullable|string|max:255',
        ]);

        $user = $request->user();
        $oldData = $user->only(['name', 'phone', 'avatar']);

        $user->update($request->only(['name', 'phone', 'avatar']));

        AuditLog::create([
            'user_id' => $user->id,
            'action' => 'update_profile',
            'model_type' => 'App\Models\User',
            'model_id' => $user->id,
            'changes' => ['old' => $oldData, 'new' => $request->only(['name', 'phone', 'avatar'])],
            'ip_address' => request()->ip(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data' => $user->load('roles')
        ]);
    }

    public function updatePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama tidak sesuai'
            ], 422);
        }

        $user->update(['password' => $request->password]);

        AuditLog::create([
            'user_id' => $user->id,
            'action' => 'change_password',
            'model_type' => 'App\Models\User',
            'model_id' => $user->id,
            'changes' => ['password' => 'changed'],
            'ip_address' => request()->ip(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diperbarui',
            'data' => null
        ]);
    }

    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $user = $request->user();
        $user->update(['fcm_token' => $request->fcm_token]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token berhasil diperbarui',
            'data' => null
        ]);
    }
}
