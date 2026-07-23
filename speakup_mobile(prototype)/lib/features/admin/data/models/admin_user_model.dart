class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime? lastLogin;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.lastLogin,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      lastLogin: json['last_login_at'] != null ? DateTime.tryParse(json['last_login_at'].toString()) : null,
    );
  }
}
