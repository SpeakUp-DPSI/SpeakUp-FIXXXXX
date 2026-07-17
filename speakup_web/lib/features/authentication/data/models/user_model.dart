class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final List<String> roles;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var rolesList = <String>[];
    if (json['roles'] != null) {
      rolesList = (json['roles'] as List).map((role) {
        if (role is String) return role;
        return role['name'].toString();
      }).toList();
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      roles: rolesList,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    List<String>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
    );
  }
}
