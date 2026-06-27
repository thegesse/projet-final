import "../dto/user_dto.dart";

class User {
  final int id;
  final String username;
  final String email;
  final String role;

  const User({required this.id, required this.username, required this.email, required this.role});
  // factory == constructor but doesnt always createes a instance, can also create a cached instance, subclass or null
  factory User.fromDTO(UserDTO dto) {
    return User(
      id: dto.id,
      username: dto.username,
      email: dto.email,
      role: dto.role,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final int roleIndex = json['role'] as int;
    String roleString = "USER";
    if(roleIndex == 1 ) roleString = "ADMIN";

    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: roleString,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }
}
