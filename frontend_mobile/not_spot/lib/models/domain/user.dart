import "../dto/user_dto.dart";

class User {
  final int id;
  final String username;
  final String email;

  const User({
    required this.id,
    required this.username,
    required this.email
  });
  // factory == constructor but doesnt always createes a instance, can also create a cached instance, subclass or null
  factory User.fromDTO(UserDTO dto) {
    return User(
      id: dto.id,
      username: dto.username,
      email:dto.email,
    );
  }
}