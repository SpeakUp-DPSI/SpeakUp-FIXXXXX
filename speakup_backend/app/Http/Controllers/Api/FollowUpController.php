<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FollowUp;
use App\Models\Report;
use App\Models\AuditLog;
use App\Models\Notification;
use App\Models\User;
use App\Services\FirebaseNotificationService;
use Illuminate\Http\Request;

class FollowUpController extends Controller
{
    protected $firebaseService;

    public function __construct(FirebaseNotificationService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    public function store(Request $request, $reportId)
    {
        $request->validate([
            'action_taken' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $user = $request->user();
        if (!$user->hasRole('guru_bk') && !$user->hasRole('admin')) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $report = Report::findOrFail($reportId);

        $followUp = $report->followUps()->create([
            'executor_id' => $user->id,
            'action_taken' => $request->action_taken,
            'follow_up_date' => now(),
        ]);

        $report->statusHistories()->create([
            'user_id' => $user->id,
            'status' => $report->status,
            'notes' => 'Tindak lanjut: ' . $request->action_taken,
        ]);

        AuditLog::create([
            'user_id' => $user->id,
            'action' => 'create_follow_up',
            'model_type' => 'App\Models\FollowUp',
            'model_id' => $followUp->id,
            'changes' => $followUp->toArray(),
            'ip_address' => request()->ip(),
        ]);

        Notification::create([
            'user_id' => $report->reporter_id,
            'title' => 'Tindak Lanjut Dicatat',
            'body' => 'Tindak lanjut untuk laporan ' . $report->report_code . ' telah dicatat.',
            'type' => 'info',
            'reference_id' => $report->id,
            'is_read' => false,
        ]);

        $reporter = User::find($report->reporter_id);
        if ($reporter) {
            $this->firebaseService->sendNotification(
                $reporter,
                'Tindak Lanjut Dicatat',
                'Tindak lanjut untuk laporan ' . $report->report_code . ' telah dicatat.',
                ['report_id' => $report->id, 'type' => 'follow_up']
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Tindak lanjut berhasil dicatat',
            'data' => $followUp
        ]);
    }

    public function index(Request $request, $reportId)
    {
        $followUps = FollowUp::with('executor')
            ->where('report_id', $reportId)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar tindak lanjut',
            'data' => $followUps
        ]);
    }
}
