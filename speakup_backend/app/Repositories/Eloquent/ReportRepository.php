<?php

namespace App\Repositories\Eloquent;

use App\Models\Report;
use App\Models\Evidence;
use App\Repositories\Contracts\ReportRepositoryInterface;

class ReportRepository implements ReportRepositoryInterface
{
    private array $defaultIncludes = ['reporter', 'evidences', 'participants', 'mediations', 'followUps', 'statusHistories'];

    public function getAll(array $filters = [])
    {
        return Report::with($this->defaultIncludes)
            ->when(isset($filters['status']) && $filters['status'] !== '', function ($query) use ($filters) {
                return $query->where('status', $filters['status']);
            })
            ->when(isset($filters['category']) && $filters['category'] !== '', function ($query) use ($filters) {
                return $query->where('category', $filters['category']);
            })
            ->when(isset($filters['search']) && $filters['search'] !== '', function ($query) use ($filters) {
                $search = $filters['search'];
                return $query->where(function ($q) use ($search) {
                    $q->where('title', 'like', "%{$search}%")
                      ->orWhere('description', 'like', "%{$search}%")
                      ->orWhere('report_code', 'like', "%{$search}%");
                });
            })
            ->when(isset($filters['sort']) && $filters['sort'] !== '', function ($query) use ($filters) {
                switch ($filters['sort']) {
                    case 'oldest':
                        return $query->oldest();
                    case 'status':
                        return $query->orderBy('status');
                    default:
                        return $query->latest();
                }
            }, function ($query) {
                return $query->latest();
            })
            ->paginate($filters['limit'] ?? 10);
    }

    public function getById(int $id)
    {
        return Report::with(array_merge($this->defaultIncludes, ['validations.validator', 'mediations.mediator', 'followUps.executor']))->findOrFail($id);
    }

    public function getByReporter(int $reporterId, array $filters = [])
    {
        return Report::with($this->defaultIncludes)
            ->where('reporter_id', $reporterId)
            ->when(isset($filters['status']) && $filters['status'] !== '', function ($query) use ($filters) {
                return $query->where('status', $filters['status']);
            })
            ->when(isset($filters['search']) && $filters['search'] !== '', function ($query) use ($filters) {
                $search = $filters['search'];
                return $query->where(function ($q) use ($search) {
                    $q->where('title', 'like', "%{$search}%")
                      ->orWhere('description', 'like', "%{$search}%")
                      ->orWhere('report_code', 'like', "%{$search}%");
                });
            })
            ->latest()
            ->paginate($filters['limit'] ?? 10);
    }

    public function create(array $data)
    {
        return Report::create($data);
    }

    public function update(int $id, array $data)
    {
        $report = Report::findOrFail($id);
        $report->update($data);
        return $report;
    }

    public function attachEvidence(int $reportId, array $evidenceData)
    {
        return Evidence::create(array_merge($evidenceData, ['report_id' => $reportId]));
    }
}
