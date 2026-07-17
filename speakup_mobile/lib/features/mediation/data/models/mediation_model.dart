class MediationModel {
  final String id;
  final String reportId;
  final String mediatorId;
  final DateTime scheduleDate;
  final String location;
  final String status;
  final String? result;
  final String? reportCode;
  final String? mediatorName;
  final List<MediationParticipantModel> participants;

  MediationModel({
    required this.id,
    required this.reportId,
    required this.mediatorId,
    required this.scheduleDate,
    required this.location,
    required this.status,
    this.result,
    this.reportCode,
    this.mediatorName,
    this.participants = const [],
  });

  String myStatus(String userId) {
    try {
      final p = participants.firstWhere((p) => p.userId == userId);
      return p.status;
    } catch (e) {
      return 'pending';
    }
  }

  factory MediationModel.fromJson(Map<String, dynamic> json) {
    return MediationModel(
      id: json['id']?.toString() ?? '',
      reportId: json['report_id']?.toString() ?? '',
      mediatorId: json['mediator_id']?.toString() ?? '',
      scheduleDate: DateTime.parse(json['schedule_date']),
      location: json['location'] ?? '',
      status: json['status'] ?? 'scheduled',
      result: json['result']?.toString(),
      reportCode: json['report']?['report_code']?.toString(),
      mediatorName: json['mediator']?['name']?.toString(),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => MediationParticipantModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MediationParticipantModel {
  final String id;
  final String userId;
  final String status;
  final String? userName;

  MediationParticipantModel({
    required this.id,
    required this.userId,
    required this.status,
    this.userName,
  });

  factory MediationParticipantModel.fromJson(Map<String, dynamic> json) {
    return MediationParticipantModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      userName: json['user']?['name']?.toString(),
    );
  }
}
