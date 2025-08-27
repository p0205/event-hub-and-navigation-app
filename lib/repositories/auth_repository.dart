import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';

import '../exceptions/auth_exception.dart';
import '../services/api.dart';
import '../utils/constant.dart';

class AuthRepository {
  Future<String> checkEmail(String email) async {
    try {
      final response =
          await ApiService.get('/auth/check-email', queryParameters: {
        'email': email,
      });
      return response.data['message'] ?? 'Verification code sent successfully';
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 409) {
          throw AuthException('User with this email is already registered.');
        } else if (e.response!.statusCode == 404) {
          throw AuthException('Email not found in university database.');
        }
        throw AuthException(
            e.response!.data['error'] ?? 'Failed to check email.');
      } else {
        throw NetworkException('Please check your internet connection.');
      }
    } catch (e) {
      if (e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw AuthException('An unexpected error occurred while checking email.');
    }
  }

  Future<User?> verifyCode(String email, String code) async {
    try {
      final response =
          await ApiService.get('/auth/verify-code', queryParameters: {
        'email': email,
        'code': code,
      });
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw AuthException(
            e.response?.data ?? 'Invalid or expired verification code.');
      } else {
        throw NetworkException('Please check your internet connection.');
      }
    } catch (e) {
      if (e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw AuthException('An unexpected error occurred while checking email.');
    }
  }

  Future<String> signUp(String email, String phoneNo, String password) async {
    try {
      final response = await ApiService.post('/auth/sign-up', data: {
        'email': email,
        'phoneNo': phoneNo,
        'rawPassword': password,
      });

      if (response.statusCode == 201) {
        return response.data['message'] ?? 'Sign up successful';
      } else {
        throw AuthException(
            'Unexpected response status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 409) {
          throw AuthException('User with this email is already registered.');
        } else if (e.response!.statusCode == 400) {
          throw BadRequestException(
              e.response!.data['error'] ?? 'Invalid sign up data.');
        }
        throw AuthException(e.response!.data['error'] ?? 'Failed to sign up.');
      } else {
        throw NetworkException('Please check your internet connection.');
      }
    } catch (e) {
      if (e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw AuthException('An unexpected error occurred during sign up.');
    }
  }

  Future<User> signIn(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/sign-in', data: {
        'email': email,
        'rawPassword': password,
      });

      if (response.statusCode == 200) {
        User user = User.fromJson(response.data);
        if (user.mustChangePassword == false) {
          await _handleAuthCookies(user);
        }
        return user;
      } else {
        throw AuthException(
            'Sign in failed with status: ${response.statusCode}'); // Use a generic auth exception
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw InvalidCredentialsException(
              'Invalid email or password.'); // More specific message
        } else if (e.response!.statusCode == 400) {
          throw BadRequestException(e.response!.data['error'] ??
              'Bad request.'); // Use custom exception
        }
        throw AuthException(
            'Sign in failed: ${e.response!.data['message'] ?? 'Server error'}'); // Generic for other server errors
      } else {
        throw NetworkException(
            'Please check your internet connection.'); // Use custom exception for network
      }
    } catch (e) {
      throw AuthException(
          'An unexpected error occurred during sign in.'); // Use generic auth exception for others
    }
  }

  Future<bool> validateToken() async {
    try {
      // Make a lightweight authenticated request. /auth/me is a good choice.
      final response = await ApiService.get(
          "/auth/me"); // Using POST, assuming /auth/me expects a token
      // If the request succeeds, it means the token was valid.
      // Optionally update user data if /auth/me returns it.
      if (response.statusCode == 200) {
        // If your /auth/me endpoint returns updated user data, save it:
        // User user = User.fromJson(response.data);
        // await ApiService.persistAndSetUser(user);
        return true; // Token is valid
      }
      return false; // Unexpected status code
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          print('AuthRepository: Token validation failed: 401 Unauthorized.');
          return false; // Token is invalid/expired
        }
        print(
            'AuthRepository: Token validation failed with status: ${e.response!.statusCode}, message: ${e.response!.data}');
        return false; // Other server errors
      } else {
        print(
            'AuthRepository: Network error during token validation: ${e.message}');
        return false; // Network errors
      }
    } catch (e) {
      print(
          'AuthRepository: An unexpected error occurred during token validation: $e');
      return false; // Any other unexpected errors
    }
  }

  Future<void> signOut() async {
    await ApiService.clearToken();
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final response = await ApiService.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response.statusCode != 200) {
        throw AuthException('Failed to change password');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw InvalidCredentialsException('Current password is incorrect');
        } else if (e.response!.statusCode == 400) {
          throw BadRequestException(
              e.response!.data['error'] ?? 'Invalid password data');
        }
        throw AuthException(
            e.response!.data['error'] ?? 'Failed to change password');
      } else {
        throw NetworkException('Please check your internet connection');
      }
    } catch (e) {
      if (e is AuthException || e is NetworkException) {
        rethrow;
      }
      throw AuthException(
          'An unexpected error occurred while changing password');
    }
  }

  Future<bool> updateOutsiderPassword(User user, String newPassword) async {
    try {
      final response = await ApiService.patch(
        '/users/${user.id}/update_temp_password',
        data: {'outsiderNewPassword': newPassword},
      );

      if (response.statusCode == 200) {
        await _handleAuthCookies(user.copyWith(mustChangePassword: false));
        return true;
      } else {
        throw AuthException('Failed to update password');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          throw AuthException('User not found');
        } else if (e.response!.statusCode == 400) {
          throw BadRequestException(
              e.response!.data['error'] ?? 'Invalid password format');
        }
        throw AuthException(
            e.response!.data['error'] ?? 'Failed to update password');
      } else {
        throw NetworkException('Please check your internet connection');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
          'An unexpected error occurred while updating password');
    }
  }

  Future<void> _handleAuthCookies(User user) async {
    final cookieJar = ApiService.dio.interceptors
        .whereType<CookieManager>()
        .map((e) => e.cookieJar)
        .cast<CookieJar>()
        .first;

    final uri = Uri.parse(AppConstants.BaseUrl + AppConstants.BasePort);
    final cookies = await cookieJar.loadForRequest(uri);

    final Cookie? jwtCookie = cookies.cast<Cookie?>().firstWhere(
          (cookie) => cookie?.name == 'jwt',
          orElse: () => null,
        );

    if (jwtCookie != null) {
      final token = jwtCookie.value;
      await ApiService.persistAndSetToken(token);
    }

    await ApiService.persistAndSetUser(user);
  }
}
