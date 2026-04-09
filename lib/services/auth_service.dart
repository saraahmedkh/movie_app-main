import 'package:dio/dio.dart';

import '../api/api_manager.dart';

class AuthService {
  final ApiManager _apiManager = ApiManager();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiManager.dio.post(
        'auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['data']?['token'] != null) {
        _apiManager.setToken(response.data['data']['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _apiManager.extractErrorMessage(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required int avaterId,
  }) async {
    try {
      final response = await ApiManager.dio.post(
        'auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'phone': phone,
          'avaterId': avaterId,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _apiManager.extractErrorMessage(e);
    }
  }

  /// Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiManager.dio.patch(
        'auth/reset-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _apiManager.extractErrorMessage(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    _apiManager.removeToken();
  }
}