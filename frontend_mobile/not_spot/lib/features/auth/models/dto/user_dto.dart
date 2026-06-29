class UserDTO {
  final int id;
  final String username;
  final String email;
  final String role;

  const UserDTO({
    required this.id,
    required this.username,
    required this.email,
    required this.role
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}