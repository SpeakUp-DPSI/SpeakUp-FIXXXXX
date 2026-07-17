<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\MediationController;
use App\Http\Controllers\Api\FollowUpController;
use App\Http\Controllers\Api\ValidationController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\AuditLogController;
use App\Http\Controllers\Api\ProfileController;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::put('/profile/password', [ProfileController::class, 'updatePassword']);
    Route::post('/profile/fcm-token', [ProfileController::class, 'updateFcmToken']);

    // Reports
    Route::apiResource('reports', ReportController::class)->only(['index', 'store', 'show']);
    Route::put('/reports/{report}/status', [ReportController::class, 'updateStatus']);

    // Validations
    Route::get('/reports/{report}/validations', [ValidationController::class, 'index']);
    Route::post('/reports/{report}/validations', [ValidationController::class, 'store']);

    // Mediations (nested under reports + standalone)
    Route::get('/reports/{report}/mediations', [MediationController::class, 'index']);
    Route::post('/reports/{report}/mediations', [MediationController::class, 'store']);
    Route::get('/mediations', [MediationController::class, 'myMediations']);
    Route::get('/mediations/{id}', [MediationController::class, 'show']);
    Route::put('/mediations/{id}/status', [MediationController::class, 'updateStatus']);
    Route::put('/mediations/{id}/participant-status', [MediationController::class, 'updateParticipantStatus']);
    Route::post('/mediations/{id}/contact', [MediationController::class, 'contactParticipant']);

    // Follow-ups
    Route::get('/reports/{report}/follow-ups', [FollowUpController::class, 'index']);
    Route::post('/reports/{report}/follow-ups', [FollowUpController::class, 'store']);

    // Notifications (static routes BEFORE parameterized routes)
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);

    // Audit Logs (Admin only)
    Route::get('/audit-logs', [AuditLogController::class, 'index']);
    Route::get('/audit-logs/{id}', [AuditLogController::class, 'show']);

    // Dashboard
    Route::get('/dashboard/statistics', [DashboardController::class, 'statistics']);
});
