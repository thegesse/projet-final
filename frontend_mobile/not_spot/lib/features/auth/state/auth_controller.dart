import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/domain/user.dart';
import '../models/requests/login_request.dart';
import '../models/requests/register_request.dart';
import '../data/auth_api.dart';

class AuthController extends ChangeNotifier {
  final AuthApi _authService = AuthApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // Prevents issues with automated OS backups corrupting encryption keys
      resetOnError: true,
    ),
  );

//states
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get username => _currentUser?.username;
  String? get email => _currentUser?.email;

  AuthController() {
    tryToLoadSavedUser();
  }

  Future<void> tryToLoadSavedUser() async {
    _setLoading(true);
    try {
      String? userJson = await _storage.read(key: 'saved_user_session');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      await _storage.delete(key: 'saved_user_session');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final request = LoginRequest(username: username, password: password);
      final user = await _authService.login(request);
      _currentUser = user;
      await _storage.write(
        key: 'saved_user_session',
        value: jsonEncode(user.toJson()),
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final request =
          RegisterRequest(username: username, email: email, password: password);
      final user = await _authService.register(request);
      _currentUser = user;
      await _storage.write(
        key: 'saved_user_session',
        value: jsonEncode(user.toJson()),
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() async {
    _currentUser = null;
    _clearError();
    await _storage.delete(key: 'saved_user_session');
    notifyListeners();
  }
}
