class DeleteAccountRequest {
  final String password;

  const DeleteAccountRequest({required this.password,});

  Map<String, dynamic> toJson() {
    return{'password': password,};
  }
}