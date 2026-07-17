class DashboardStatsModel {
  final int total;
  final int today;
  final int thisMonth;
  final int valid;
  final int processing;
  final int mediation;
  final int completed;

  DashboardStatsModel({
    required this.total,
    required this.today,
    required this.thisMonth,
    required this.valid,
    required this.processing,
    required this.mediation,
    required this.completed,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      total: json['total'] ?? 0,
      today: json['today'] ?? 0,
      thisMonth: json['this_month'] ?? 0,
      valid: json['valid'] ?? 0,
      processing: json['processing'] ?? 0,
      mediation: json['mediation'] ?? 0,
      completed: json['completed'] ?? 0,
    );
  }
}
