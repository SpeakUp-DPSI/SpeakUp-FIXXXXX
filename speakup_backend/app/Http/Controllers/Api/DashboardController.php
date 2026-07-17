<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Models\User;
use App\Models\Notification;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function statistics(Request $request)
    {
        $user = $request->user();

        $today = Carbon::today();
        $thisMonth = Carbon::now()->startOfMonth();

        $query = Report::query();

        if ($user->hasRole('siswa')) {
            $query->where('reporter_id', $user->id);
        } elseif ($user->hasRole('ortu')) {
            $childrenIds = $user->children()->pluck('id')->toArray();
            $query->whereIn('reporter_id', $childrenIds);
        }

        $stats = [
            'total' => (clone $query)->count(),
            'today' => (clone $query)->whereDate('created_at', $today)->count(),
            'this_month' => (clone $query)->where('created_at', '>=', $thisMonth)->count(),
            'draft' => (clone $query)->where('status', 'draft')->count(),
            'submitted' => (clone $query)->where('status', 'submitted')->count(),
            'waiting_validation' => (clone $query)->where('status', 'waiting_validation')->count(),
            'valid' => (clone $query)->where('status', 'valid')->count(),
            'processing' => (clone $query)->where('status', 'processing')->count(),
            'mediation' => (clone $query)->where('status', 'mediation')->count(),
            'follow_up' => (clone $query)->where('status', 'follow_up')->count(),
            'completed' => (clone $query)->where('status', 'completed')->count(),
            'rejected' => (clone $query)->where('status', 'rejected')->count(),
            'by_category' => (clone $query)->selectRaw('category, count(*) as count')
                                ->whereNotNull('category')
                                ->groupBy('category')
                                ->get(),
            'by_status' => (clone $query)->selectRaw('status, count(*) as count')
                                ->groupBy('status')
                                ->get(),
            'recent_reports' => (clone $query)->with('reporter')
                                ->latest()
                                ->take(5)
                                ->get(),
            'unread_notifications' => Notification::where('user_id', $user->id)
                                    ->where('is_read', false)
                                    ->count(),
        ];

        return response()->json([
            'success' => true,
            'message' => 'Statistik Laporan',
            'data' => $stats
        ]);
    }
}
