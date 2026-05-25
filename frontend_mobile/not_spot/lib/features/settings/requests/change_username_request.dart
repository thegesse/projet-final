class ChangeUsernameRequest {
  final String username;

  const ChangeUsernameRequest({required this.username});

  Map<String, dynamic> toJson() {
    return{'username': username,};
  }
}