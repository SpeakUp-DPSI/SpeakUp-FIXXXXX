<?php

namespace App\Repositories\Contracts;

interface ReportRepositoryInterface
{
    public function getAll(array $filters = []);
    public function getById(int $id);
    public function getByReporter(int $reporterId, array $filters = []);
    public function create(array $data);
    public function update(int $id, array $data);
    public function attachEvidence(int $reportId, array $evidenceData);
}
