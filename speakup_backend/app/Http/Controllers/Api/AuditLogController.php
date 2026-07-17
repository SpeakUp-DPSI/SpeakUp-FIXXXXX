<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use Illuminate\Http\Request;

class AuditLogController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user->hasRole('admin')) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $logs = AuditLog::with('user')
            ->when($request->has('action'), function ($query) use ($request) {
                $query->where('action', $request->action);
            })
            ->when($request->has('model_type'), function ($query) use ($request) {
                $query->where('model_type', $request->model_type);
            })
            ->when($request->has('user_id'), function ($query) use ($request) {
                $query->where('user_id', $request->user_id);
            })
            ->latest()
            ->paginate($request->get('limit', 20));

        return response()->json([
            'success' => true,
            'message' => 'Daftar audit log',
            'data' => $logs
        ]);
    }

    public function show($id, Request $request)
    {
        $user = $request->user();
        if (!$user->hasRole('admin')) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $log = AuditLog::with('user')->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Detail audit log',
            'data' => $log
        ]);
    }
}
