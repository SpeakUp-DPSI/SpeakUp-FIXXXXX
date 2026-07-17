<?php

namespace App\Services;

use App\Repositories\Contracts\ReportRepositoryInterface;
use App\Models\AuditLog;
use App\Models\Notification;
use App\Models\User;
use App\Services\FirebaseNotificationService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\UploadedFile;

class ReportService
{
    protected $reportRepo;
    protected $firebaseService;

    public function __construct(ReportRepositoryInterface $reportRepo, FirebaseNotificationService $firebaseService)
    {
        $this->reportRepo = $reportRepo;
        $this->firebaseService = $firebaseService;
    }

    public function createReport(array $data, $user)
    {
        return DB::transaction(function () use ($data, $user) {
            $datePrefix = now()->format('Ymd');
            $randomStr = strtoupper(substr(uniqid(), -4));
            $reportCode = "REP-{$datePrefix}-{$randomStr}";

            $reportData = [
                'report_code' => $reportCode,
                'reporter_id' => $user->id,
                'title' => $data['title'],
                'category' => $data['category'] ?? null,
                'description' => $data['description'] ?? '',
                'is_anonymous' => $data['is_anonymous'] ?? false,
                'incident_location' => $data['incident_location'] ?? null,
                'incident_date' => $data['incident_date'] ?? null,
                'status' => 'waiting_validation',
            ];

            $report = $this->reportRepo->create($reportData);

            if (isset($data['participants']) && is_array($data['participants'])) {
                foreach ($data['participants'] as $p) {
                    $report->participants()->create([
                        'role' => $p['role'],
                        'name' => $p['name'] ?? null,
                        'class_name' => $p['class_name'] ?? null,
                        'notes' => $p['notes'] ?? null,
                    ]);
                }
            }

            if (isset($data['evidences']) && is_array($data['evidences'])) {
                foreach ($data['evidences'] as $file) {
                    if ($file instanceof UploadedFile) {
                        $path = $file->store('evidences', 'public');
                        
                        $this->reportRepo->attachEvidence($report->id, [
                            'file_path' => Storage::disk('public')->url($path),
                            'file_type' => $file->getClientMimeType(),
                            'original_name' => $file->getClientOriginalName()
                        ]);
                    }
                }
            }

            $report->statusHistories()->create([
                'user_id' => $user->id,
                'status' => 'waiting_validation',
                'notes' => 'Laporan baru dibuat oleh siswa.',
            ]);

            AuditLog::create([
                'user_id' => $user->id,
                'action' => 'create_report',
                'model_type' => 'App\Models\Report',
                'model_id' => $report->id,
                'changes' => ['status' => 'waiting_validation', 'report_code' => $reportCode],
                'ip_address' => request()->ip(),
            ]);

            $guruBks = User::whereHas('roles', function($q) {
                $q->where('name', 'guru_bk');
            })->get();

            foreach ($guruBks as $guruBk) {
                Notification::create([
                    'user_id' => $guruBk->id,
                    'title' => 'Laporan Baru',
                    'body' => 'Ada laporan baru yang membutuhkan validasi: ' . $reportCode,
                    'type' => 'info',
                    'reference_id' => $report->id,
                    'is_read' => false,
                ]);

                $this->firebaseService->sendNotification(
                    $guruBk,
                    'Laporan Baru',
                    'Ada laporan baru yang membutuhkan validasi: ' . $reportCode,
                    ['report_id' => $report->id, 'type' => 'new_report']
                );
            }

            return $report;
        });
    }

    public function updateStatus($reportId, $status, $userId, $notes = null)
    {
        return DB::transaction(function () use ($reportId, $status, $userId, $notes) {
            $report = $this->reportRepo->getById($reportId);
            $oldStatus = $report->status;
            
            $report->update(['status' => $status]);

            $report->statusHistories()->create([
                'user_id' => $userId,
                'status' => $status,
                'notes' => $notes,
            ]);

            AuditLog::create([
                'user_id' => $userId,
                'action' => 'update_report_status',
                'model_type' => 'App\Models\Report',
                'model_id' => $report->id,
                'changes' => [
                    'old_status' => $oldStatus,
                    'new_status' => $status,
                ],
                'ip_address' => request()->ip(),
            ]);

            Notification::create([
                'user_id' => $report->reporter_id,
                'title' => 'Status Laporan Diperbarui',
                'body' => "Laporan Anda ($report->report_code) kini berstatus: " . ucfirst($status),
                'type' => 'info',
                'reference_id' => $report->id,
                'is_read' => false,
            ]);

            $reporter = User::find($report->reporter_id);
            if ($reporter) {
                $this->firebaseService->sendNotification(
                    $reporter,
                    'Status Laporan Diperbarui',
                    "Laporan Anda ($report->report_code) kini berstatus: " . ucfirst($status),
                    ['report_id' => $report->id, 'type' => 'status_update']
                );
            }

            return $report;
        });
    }
}
