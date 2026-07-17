<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Validation as ValidationModel;
use App\Models\Report;
use App\Models\AuditLog;
use App\Models\Notification;
use App\Models\User;
use App\Services\FirebaseNotificationService;
use Illuminate\Http\Request;

class ValidationController extends Controller
{
    protected $firebaseService;

    public function __construct(FirebaseNotificationService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    public function store(Request $request, $reportId)
    {
        $request->validate([
            'status' => 'required|in:valid,rejected',
            'notes' => 'nullable|string',
        ]);

        $user = $request->user();
        if (!$user->hasRole('guru_bk') && !$user->hasRole('admin')) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $report = Report::findOrFail($reportId);

        $validation = ValidationModel::create([
            'report_id' => $reportId,
            'validator_id' => $user->id,
            'status' => $request->status,
            'notes' => $request->notes,
        ]);

        $newStatus = $request->status === 'valid' ? 'processing' : 'rejected';
        $report->update(['status' => $newStatus]);

        $report->statusHistories()->create([
            'user_id' => $user->id,
            'status' => $newStatus,
            'notes' => 'Validasi: ' . ucfirst($request->status) . '. ' . ($request->notes ?? ''),
        ]);

        AuditLog::create([
            'user_id' => $user->id,
            'action' => 'validate_report',
            'model_type' => 'App\Models\Validation',
            'model_id' => $validation->id,
            'changes' => ['status' => $request->status, 'report_id' => $reportId],
            'ip_address' => request()->ip(),
        ]);

        Notification::create([
            'user_id' => $report->reporter_id,
            'title' => 'Laporan ' . ucfirst($request->status),
            'body' => "Laporan Anda ($report->report_code) telah " . ($request->status === 'valid' ? 'divalidasi' : 'ditolak') . '.',
            'type' => $request->status === 'valid' ? 'info' : 'warning',
            'reference_id' => $report->id,
            'is_read' => false,
        ]);

        $reporter = User::find($report->reporter_id);
        if ($reporter) {
            $this->firebaseService->sendNotification(
                $reporter,
                'Laporan ' . ucfirst($request->status),
                "Laporan Anda ($report->report_code) telah " . ($request->status === 'valid' ? 'divalidasi' : 'ditolak') . '.',
                ['report_id' => $report->id, 'type' => 'validation']
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Validasi berhasil dicatat',
            'data' => $validation
        ]);
    }

    public function index(Request $request, $reportId)
    {
        $validations = ValidationModel::with('validator')
            ->where('report_id', $reportId)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar validasi',
            'data' => $validations
        ]);
    }
}
