class UserModel {
  final String userId;
  final String email;
  final String name;
  final String role;
  final String? profileImageBase64;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    this.profileImageBase64,
  });

  static String _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return '';
    return value.toString();
  }

  static String? _readNullableString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: id,
      email: _readString(map, 'email'),
      name: _readString(map, 'name'),
      role:
          _readString(map, 'role').isEmpty ? 'user' : _readString(map, 'role'),
      profileImageBase64: _readNullableString(map, 'profileImageBase64'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'profileImageBase64': profileImageBase64 ?? '',
    };
  }

  bool get isAdmin => role == 'admin';
}
