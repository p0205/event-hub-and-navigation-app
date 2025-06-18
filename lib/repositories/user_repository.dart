import 'package:dio/dio.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';
import '../services/api.dart';
import '../exceptions/auth_exception.dart';

class UserRepository {

  Future<bool> updateInfo(int userId, {String? phoneNo, String? newPassword}) async {
    try {
      final response = await ApiService.patch(
        '/users/$userId',
        data: {
          if (phoneNo != null) 'phoneNo': phoneNo,
          if (newPassword != null) 'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw AuthException('Failed to update user information');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          throw AuthException('User not found');
        } else if (e.response!.statusCode == 400) {
          throw BadRequestException(e.response!.data['error'] ?? 'Invalid update data');
        }
        throw AuthException(e.response!.data['error'] ?? 'Failed to update user information');
      } else {
        throw NetworkException('Please check your internet connection');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('An unexpected error occurred while updating user information');
    }
  }

  Future<User?> updatePhoneNo(int userId, String phoneNo) async {
    try {
      final response = await ApiService.patch(
        '/users/$userId/phone',
        data: {'phoneNo': phoneNo},
      );
      if (response.statusCode == 200) {
        User user = User.fromJson(response.data);
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update phone number: $e');
    }
  }

  Future<bool> updatePassword(int userId, String currentPassword, String newPassword) async {
    try {
      final response = await ApiService.patch(
        '/users/$userId/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Incorrect current password');
      }
      throw Exception('Failed to update password: $e');
    }
  }



}