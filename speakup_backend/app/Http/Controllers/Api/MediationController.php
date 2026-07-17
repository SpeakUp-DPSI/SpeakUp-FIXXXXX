<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mediation;
use App\Models\Report;
use App\Models\AuditLog;
use App\Models\Notification;
use App\Models\User;
use App\Services\FirebaseNotificationService;
use Illuminate\Http\Request;

class MediationController extends Controller
{
    protected $firebaseService;

    public function __construct(FirebaseNotificationService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    public function store(Request $request, $reportId)
    {
        $request->validate([
            'schedule_date' => 'required|date',
            'location' => 'required|string',
        ]);

        $user = $request->user();
        if (!$user->hasRole('guru_bk') && !$user->hasRole('admin')) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $report = Report::findOrFail($reportId);

        $mediation = $report->mediations()->create([
            'mediator_id' => $user->id,
            'schedule_date' => $request->schedule_date,
            'location' => $request->location,
            'status' => 'scheduled'
        ]);

        $report->update(['status' => 'mediation']);

        $report->statusHistories()->create([
            'user_id' => $user->id,
            'status' => 'mediation',
            'notes' => 'Mediasi dijadwalkan pada ' . $request->schedule_date . ' di ' . $request->location,
        ]);

        AuditLog::create([
            'user_id' => $user->id,
            'action' => 'schedule_mediation',
            'model_type' => 'App\Models\Mediation',
            'model_id' => $mediation->id,
            'changes' => $mediation->toArray(),
            'ip_address' => request()->ip(),
        ]);

        Notification::create([
            'user_id' => $report->reporter_id,
            'title' => 'Mediasi Dijadwalkan',
            'body' => 'Mediasi untuk laporan ' . $report->report_code . ' dijadwalkan pada ' . $request->schedule_date,
            'type' => 'info',
            'reference_id' => $report->id,
            'is_read' => false,
        ]);

        $reporter = User::find($report->reporter_id);
        if ($reporter) {
            $this->firebaseService->sendNotification(
                $reporter,
                'Mediasi Dijadwalkan',
                'Mediasi untuk laporan ' . $report->report_code . ' dijadwalkan.',
                ['report_id' => $report->id, 'type' => 'mediation']
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Jadwal mediasi berhasil dibuat',
            'data' => $mediation
        ]);
    }

    public function index(Request $request, $reportId)
    {
        $mediations = Mediation::with(['mediator', 'participants'])
            ->where('report_id', $reportId)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar mediasi',
            'data' => $mediations
        ]);
    }

    public function show($id)
    {
        $mediation = Mediation::with(['mediator', 'participants', 'report'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Detail mediasi',
            'data' => $mediation
        ]);
    }

    public function updateStatus($id, Request $request)
    {
        $request->validate([
            'status' => 'required|in:scheduled,ongoing,completed,cancelled',
            'result' => 'nullable|string',
        ]);

        $user = $request->user();
        if (!$user->hasRole('guru_bk') && !$user->hasRole('admin')) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $mediation = Mediation::findOrFail($id);
        $mediation->update([
            'status' => $request->status,
            'result' => $request->result ?? $mediation->result,
        ]);

        if ($request->status === 'completed') {
            $mediation->report->update(['status' => 'follow_up']);
            $mediation->report->statusHistories()->create([
                'user_id' => $user->id,
                'status' => 'follow_up',
                'notes' => 'Mediasi selesai. ' . ($request->result ?? ''),
            ]);
        }

        AuditLog::create([
            'user_id' => $user->id,
            'action' => 'update_mediation_status',
            'model_type' => 'App\Models\Mediation',
            'model_id' => $mediation->id,
            'changes' => ['status' => $request->status],
            'ip_address' => request()->ip(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Status mediasi berhasil diperbarui',
            'data' => $mediation
        ]);
    }

    public function contactParticipant(Request $request, $id)
    {
        $user = auth()->user();

        // Only Guru BK can contact participants for mediation
        if ($user->role->name !== 'guru_bk') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $mediation = Mediation::with(['participants.user'])->findOrFail($id);

        // Find the non-mediator participants (like parent or student)
        foreach ($mediation->participants as $participant) {
            if ($participant->user_id !== $user->id) {
                // Create a notification for them
                \App\Models\Notification::create([
                    'user_id' => $participant->user_id,
                    'title' => 'Panggilan Mediasi',
                    'message' => 'Guru BK sedang menghubungi Anda untuk mediasi.',
                    'type' => 'mediation_call',
                    'related_id' => $mediation->id,
                ]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi berhasil dikirim ke pihak terlibat'
        ]);
    }
    public function myMediations(Request $request)
    {
        $user = auth()->user();
        
        $mediations = Mediation::with(['mediator', 'participants', 'report'])
            ->whereHas('participants', function($q) use ($user) {
                $q->where('user_id', $user->id);
            })
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $mediations
        ]);
    }

    public function updateParticipantStatus(Request $request, $id)
    {
        $user = auth()->user();
        
        $mediation = Mediation::findOrFail($id);
        $participant = $mediation->participants()->where('user_id', $user->id)->first();
        
        if (!$participant) {
            return response()->json(['success' => false, 'message' => 'Not a participant'], 403);
        }

        $participant->update(['status' => $request->status]);

        return response()->json([
            'success' => true,
            'message' => 'Status partisipasi diperbarui'
        ]);
    }
}
