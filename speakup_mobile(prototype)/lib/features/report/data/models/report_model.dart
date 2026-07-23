class ReportParticipant {
  final String id;
  final String role;
  final String? userId;
  final String? name;
  final String? className;
  final String? notes;

  ReportParticipant({
    required this.id,
    required this.role,
    this.userId,
    this.name,
    this.className,
    this.notes,
  });

  factory ReportParticipant.fromJson(Map<String, dynamic> json) {
    return ReportParticipant(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      name: json['name']?.toString(),
      className: json['class_name']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}

class ReportModel {
  final String id;
  final String reportCode;
  final String title;
  final String description;
  final String status;
  final String? incidentLocation;
  final String? incidentDate;
  final String? category;
  final bool isAnonymous;
  final String? bkNote;
  final String? reporterId;
  final String? reportedId;
  final List<ReportParticipant> participants;
  final Map<String, dynamic>? reporter;
  final List<dynamic>? statusHistories;

  ReportModel({
    required this.id,
    required this.reportCode,
    required this.title,
    required this.description,
    required this.status,
    this.incidentLocation,
    this.incidentDate,
    this.category,
    this.isAnonymous = false,
    this.bkNote,
    this.reporterId,
    this.reportedId,
    this.participants = const [],
    this.reporter,
    this.statusHistories,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      reportCode: json['report_code']?.toString() ?? 'SPK-${json['id']}',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'submitted',
      incidentLocation: json['incident_location']?.toString(),
      incidentDate: json['incident_date']?.toString(),
      category: json['category']?.toString(),
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous'] == 1,
      bkNote: json['bk_note']?.toString(),
      reporterId: json['reporter_id']?.toString(),
      reportedId: json['reported_id']?.toString(),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => ReportParticipant.fromJson(e))
              .toList() ??
          [],
      reporter: json['reporter'] as Map<String, dynamic>?,
      statusHistories: json['status_histories'] as List<dynamic>?,
    );
  }

  ReportParticipant? get korban =>
      participants.where((p) => p.role == 'korban').firstOrNull;

  ReportParticipant? get terlapor =>
      participants.where((p) => p.role == 'terlapor').firstOrNull;

  List<ReportParticipant> get saksi =>
      participants.where((p) => p.role == 'saksi').toList();

  ReportModel copyWith({
    String? id,
    String? reportCode,
    String? title,
    String? description,
    String? status,
    String? incidentLocation,
    String? incidentDate,
    String? category,
    bool? isAnonymous,
    String? bkNote,
    String? reporterId,
    String? reportedId,
    List<ReportParticipant>? participants,
    Map<String, dynamic>? reporter,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reportCode: reportCode ?? this.reportCode,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      incidentDate: incidentDate ?? this.incidentDate,
      category: category ?? this.category,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      bkNote: bkNote ?? this.bkNote,
      reporterId: reporterId ?? this.reporterId,
      reportedId: reportedId ?? this.reportedId,
      participants: participants ?? this.participants,
      reporter: reporter ?? this.reporter,
      statusHistories: statusHistories ?? this.statusHistories,
    );
  }
}
