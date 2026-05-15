import 'package:flutter/material.dart';
import '../models/domain/user.dart';
import '../models/requests/login_request.dart';
import '../models/requests/register_request.dart';
import '../data/auth_api.dart';

class AuthController extends ChangeNotifier {
  final AuthApi _authService = AuthApi();

//states
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

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
      _currentUser = await _authService.login(request);
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
      _currentUser = await _authService.register(request);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    _clearError();
    notifyListeners();
  }
}
