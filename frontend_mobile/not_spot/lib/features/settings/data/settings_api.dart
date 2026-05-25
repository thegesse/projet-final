import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

import '../../auth/state/auth_controller.dart';
import '../../auth/models/domain/user.dart';
import '../../auth/models/dto/user_dto.dart';

import '../requests/change_password_request.dart';
import '../requests/change_username_request.dart';
import '../requests/delete_account_request.dart';


class SettingsApi {
  final AuthController authController;
  SettingsApi(this.authController);

  Future<User> changeUsername(ChangeUsernameRequest request) async{
    final user = authController.currentUser;
    if(user == null) throw 'Not authenticated';
    
    final response = await ApiClient.patch(
      AppConfig.changeUsernameUri(userId: user.id),
      request.toJson(),
    );

    final dto = UserDTO.fromJson(response as Map<String, dynamic>);
    return User.fromDTO(dto);
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final user = authController.currentUser;
    if(user == null) throw 'Not authenticated';

    await ApiClient.patch(
      AppConfig.changePasswordUri(userId: user.id),
      request.toJson(),
    );
  }

  Future<void> deleteAccount(DeleteAccountRequest request) async {
    final user = authController.currentUser;
    if(user == null) throw 'Not authenticated';

    await ApiClient.delete(
      AppConfig.deleteAccountUri(userId: user.id),
      body: request.toJson(),
    );
  }
}