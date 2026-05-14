import "../../../core/config/app_config.dart";
import "../../../core/network/api_client.dart";
import "../models/requests/login_request.dart";
import '../models/requests/register_request.dart';
import '../models/domain/user.dart';
import '../models/dto/user_dto.dart';


class AuthApi {
  Future<User> login(LoginRequest request) async {
    final response = await ApiClient.post(AppConfig.loginUri(), request.toJson());

    final UserDto = UserDTO.fromJson(response['user']);
    return User.fromDTO(UserDto);
  }

  Future<User> register(RegisterRequest request) async {
    final response = await ApiClient.post(AppConfig.registerUri(), request.toJson());

    final UserDto = UserDTO.fromJson(response['user']);
    return User.fromDTO(UserDto);
  }
}