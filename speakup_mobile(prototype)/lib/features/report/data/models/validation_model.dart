class ValidationModel {
  final String id;
  final String reportId;
  final String validatorId;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final String? validatorName;

  ValidationModel({
    required this.id,
    required this.reportId,
    required this.validatorId,
    required this.status,
    this.notes,
    this.createdAt,
    this.validatorName,
  });

  factory ValidationModel.fromJson(Map<String, dynamic> json) {
    return ValidationModel(
      id: json['id']?.toString() ?? '',
      reportId: json['report_id']?.toString() ?? '',
      validatorId: json['validator_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      validatorName: json['validator']?['name']?.toString(),
    );
  }
}
