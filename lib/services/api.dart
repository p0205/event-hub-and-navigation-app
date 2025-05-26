import 'package:dio/dio.dart';
import 'package:event_hub_and_navigation_app/services/secure_storage_service.dart';
import '../auth/models/user.dart';
import '../utils/constant.dart' as constant;

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: constant.AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  /// Attach token to the Authorization header
  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove the token from the Authorization header
  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  static final SecureStorageService _secureStorage = SecureStorageService();

  /// Loads JWT token from SharedPreferences and attaches it (if found)
  static Future<void> loadTokenFromStorage() async {

    final token = await _secureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      setAuthToken(token);
    }
  }



  /// Save token to secure storage and set header
  static Future<void> persistAndSetToken(String token) async {
    await _secureStorage.saveToken(token);
    setAuthToken(token);
  }

  static Future<void> persistAndSetUser(User user) async {
    await _secureStorage.saveUser(user);

  }

  /// Clear token from secure storage and header
  static Future<void> clearToken() async {
    await _secureStorage.deleteToken();
    clearAuthToken();
  }



  /// Initializes interceptors (e.g., logging)
  static Future<void> initializeDioWithInterceptors() async {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
      logPrint: (o) => print("DIO_LOG: $o"),
    ));
  }

  /// Basic HTTP methods
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return _dio.post(path, data: data);
  }

  static Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return _dio.put(path, data: data);
  }

  static Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  static Dio get dio => _dio;
}
