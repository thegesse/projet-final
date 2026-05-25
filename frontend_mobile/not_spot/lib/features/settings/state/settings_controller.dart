import 'package:flutter/material.dart';

import '../../auth/models/domain/user.dart';
import '../../auth/state/auth_controller.dart';
import '../data/settings_api.dart';
import '../requests/change_password_request.dart';
import '../requests/change_username_request.dart';
import '../requests/delete_account_request.dart';
import '../../auth/state/auth_controller.dart';

class SettingsController extends ChangeNotifier{
  final SettingsApi _settingsApi;
  final AuthController _authController;

  SettingsController(AuthController authController)
      : _authController = authController,
      _settingsApi = SettingsApi(authController);

  bool _isUpdating = false;
  bool _isDeleteing = false;

  String? _errorMessage;
  String? _updateError;
  String? _deleteError;

  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleteing;

  String? get errorMessage => _errorMessage;
  String? get updateError => _updateError;
  String? get deleteError => _deleteError;

  Future<bool> changeUsername(String username) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      final changeUsername = await _settingsApi.changeUsername(ChangeUsernameRequest(username: username));
      return true;
    } catch(e) {
      _updateError = 'Failed to change username $e';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  //helper for password validation
  String? _validatePasswordChange({required String currentPassword, required String newPassword, required String confirmPassword}) {
    if(currentPassword.trim().isEmpty){
      return 'Enter your current password';
    }

    if (newPassword.length < 8) {
      return 'New password must be at least 8 characters';
    }

    if(newPassword != confirmPassword) {
      return 'New passwords do not match';
    }

    if(currentPassword == newPassword) {
      return 'New password must be different from current password';
    }

    return null;
  }

  Future<bool> changePassword({required String currentPassword, required String newPassword, required String confirmPassword}) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try{
      final validationError = _validatePasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (validationError != null) {
        _updateError = validationError;
        return false;
      }

      await _settingsApi.changePassword(ChangePasswordRequest(currentPassword: currentPassword, newPassword: newPassword,));
      return true;
    }catch(e){
      _updateError = 'Failed to change password $e';
      return false;
    }finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(String password) async {
    _isDeleteing = true;
    _deleteError = null;
    notifyListeners();

    try {
      if(password.trim().isEmpty) {
        _deleteError = 'Enter your password to confirm account account deletion';
        return false;
      }

      await _settingsApi.deleteAccount(DeleteAccountRequest(password: password),);
      _authController.logout();
      return true;
    }catch(e) {
      _deleteError = 'failed to delete account $e';
      return false;
    } finally{
      _isDeleteing = false;
      notifyListeners();
    }
  }
}
