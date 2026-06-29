import 'package:flutter_secure_storage/flutter_secure_storage.dart'; //reminder to run flutter pub add flutter_secure_storage

class AuthStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _storage.write(key: 'is_logged_in', value: isLoggedIn.toString());
  }

  Future<bool> checkLoginStatus() async {
    String? status = await _storage.read(key: 'is_logged_in');
    return status == 'true';
  }

  Future<void> clearSessions() async {
    await _storage.delete(key: 'is_logged_in');
  }
}
