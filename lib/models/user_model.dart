class UserModel {
  final String userId;
  final String email;
  final String name;
  final String role;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
}