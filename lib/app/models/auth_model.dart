class AuthModel {
  final int id;
  final String username;
  final String email;
  final String role;

  AuthModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final userData = json['userData']['user'];
    return AuthModel(
      id: userData['id'],
      username: userData['username'],
      email: userData['email'],
      role: userData['role'],
    );
  }
}

//----------------