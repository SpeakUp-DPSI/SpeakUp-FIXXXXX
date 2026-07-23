class FollowUpModel {
  final String id;
  final String reportId;
  final String executorId;
  final String actionTaken;
  final DateTime? followUpDate;
  final String? reportCode;
  final String? executorName;

  FollowUpModel({
    required this.id,
    required this.reportId,
    required this.executorId,
    required this.actionTaken,
    this.followUpDate,
    this.reportCode,
    this.executorName,
  });

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: json['id']?.toString() ?? '',
      reportId: json['report_id']?.toString() ?? '',
      executorId: json['executor_id']?.toString() ?? '',
      actionTaken: json['action_taken']?.toString() ?? '',
      followUpDate: json['follow_up_date'] != null ? DateTime.tryParse(json['follow_up_date'].toString()) : null,
      reportCode: json['report']?['report_code']?.toString(),
      executorName: json['executor']?['name']?.toString(),
    );
  }
}
