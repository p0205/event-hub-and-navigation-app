import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';

import '../exceptions/auth_exception.dart';
import '../services/api.dart';
import 'package:event_hub_and_navigation_app/utils/constant.dart' as constant;

class AuthRepository {


  Future<User> signIn(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/sign-in', data: {
        'email': email,
        'rawPassword': password,
      });

      if (response.statusCode == 200) {
        // ... (your existing cookie and user persistence logic) ...
        final cookieJar = ApiService.dio.interceptors
            .whereType<CookieManager>()
            .map((e) => e.cookieJar)
            .cast<CookieJar>()
            .first;

        final uri = Uri.parse(constant.AppConstants.baseUrl);
        final cookies = await cookieJar.loadForRequest(uri);

        final Cookie? jwtCookie = cookies.cast<Cookie?>().firstWhere(
              (cookie) => cookie?.name == 'jwt',
          orElse: () => null,
        );

        if (jwtCookie != null) {
          final token = jwtCookie.value;
          await ApiService.persistAndSetToken(token);
        }
        User user = User.fromJson(response.data);
        await ApiService.persistAndSetUser(user);
        return user;
      } else {
        throw AuthException('Sign in failed with status: ${response.statusCode}'); // Use a generic auth exception
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw InvalidCredentialsException('Invalid email or password.'); // More specific message
        } else if (e.response!.statusCode == 400) {
          throw BadRequestException(e.response!.data['error'] ?? 'Bad request.'); // Use custom exception
        }
        throw AuthException('Sign in failed: ${e.response!.data['message'] ?? 'Server error'}'); // Generic for other server errors
      } else {
        throw NetworkException('Please check your internet connection.'); // Use custom exception for network
      }
    } catch (e) {
      throw AuthException('An unexpected error occurred during sign in.'); // Use generic auth exception for others
    }
  }

  Future<bool> validateToken() async {
    try {
      // Make a lightweight authenticated request. /auth/me is a good choice.
      final response = await ApiService.get("/auth/me"); // Using POST, assuming /auth/me expects a token
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
        print('AuthRepository: Token validation failed with status: ${e.response!.statusCode}, message: ${e.response!.data}');
        return false; // Other server errors
      } else {
        print('AuthRepository: Network error during token validation: ${e.message}');
        return false; // Network errors
      }
    } catch (e) {
      print('AuthRepository: An unexpected error occurred during token validation: $e');
      return false; // Any other unexpected errors
    }
  }

  Future<void> signOut() async {
    await ApiService.clearToken();
  }
}
