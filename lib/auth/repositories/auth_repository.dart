import 'package:dio/dio.dart';

import '../../services/api.dart';
import '../../services/secure_storage_service.dart';

class AuthRepository {
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<void> signIn(String email, String password) async {
    print("Sign IN");
    try {
      final response = await ApiService.post('/auth/sign-in', data: {
        'email': email,
        'rawPassword': password,
      });

      // Optional: Print the Set-Cookie header for debugging, but don't try to parse it for HttpOnly
      String? allSetCookie = response.headers['Set-cookie']?.first;
      print("Set-Cookie Header: $allSetCookie");

      // Check if the login was successful based on the status code
      if (response.statusCode == 200) {
        // The HttpOnly JWT cookie has been automatically saved by Dio's CookieManager
        // and will be sent with subsequent requests to the same domain.
        print("Login successful! JWT cookie handled automatically.");
        // If your backend were to send a separate, non-HttpOnly token in the body,
        // you would handle it here:
        // if (response.data['otherAccessToken'] != null) {
        //   await _secureStorage.saveToken(response.data['otherAccessToken']);
        // }
      } else {
        // Handle unexpected non-200 status codes if your backend returns them for errors
        throw Exception('Sign in failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Re-throw specific errors for the BLoC to handle (e.g., InvalidCredentialsException)
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw Exception('Invalid credentials provided.');
        } else if (e.response!.statusCode == 400) {
          throw Exception('Bad request: ${e.response!.data['error'] ?? 'Unknown error'}');
        }
        // General error for other server responses
        throw Exception('Sign in failed: ${e.response!.data['message'] ?? 'Server error'}');
      } else {
        // Network errors (e.g., no internet, DNS issue)
        throw Exception('Network error during sign in: ${e.message}');
      }
    } catch (e) {
      // Any other unexpected errors
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> signOut() async {
    await _secureStorage.deleteToken();
  }

  Future<String?> getSavedToken() async {
    return await _secureStorage.getToken();
  }
}
