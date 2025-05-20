// lib/services/api_service.dart
import 'package:dio/dio.dart';
// Remove: import '../services/secure_storage_service.dart'; // No longer needed here
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

  // Remove: static final SecureStorageService _secureStorage = SecureStorageService();
  // Remove: static Future<void> init() async { ... } // Remove this entire method
  static Future<void> initializeDioWithInterceptors() async {
    // This part should be called once, typically in your main() function or app initialization
    // For HttpOnly cookies, you need CookieManager.
    // If you already have this in your `Api().init()` from a previous setup, ensure it's there.

    // Get the application documents directory for storing cookies persistently
    // final appDocDir = await getApplicationDocumentsDirectory();
    // final appDocPath = appDocDir.path;
    // final cookieJar = PersistCookieJar(storage: FileStorage("$appDocPath/.cookies/"));

    // Add CookieManager to Dio's interceptors
    // _dio.interceptors.add(CookieManager(cookieJar));

    // Add LogInterceptor for debugging purposes
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,    // Log request body
      responseBody: true,   // Log response body
      requestHeader: true,  // Log request headers
      responseHeader: true, // Log response headers
      error: true,          // Log errors
      logPrint: (o) => print("DIO_LOG: $o"), // Custom logger for easy filtering
    ));

    // Remove any logic related to manually setting Authorization header from SecureStorage
    // if this JWT cookie is HttpOnly.
    // final token = await _secureStorage.getToken();
    // if (token != null) {
    //   _dio.options.headers['Authorization'] = 'Bearer $token';
    // }
  }

  static Dio get dio => _dio;

  // Your other methods no longer need to call await init();
  static Future<Response> get(String path,Map<String, dynamic>? queryParameters) async {
    print("Sending request to $path");
    return _dio.get(path,queryParameters: queryParameters);
  }

  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    print("Sending POST request to $path");
    print("Data $data" );
    return _dio.post(path, data: data);
  }

  static Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    print("Sending request to $path");
    return _dio.put(path, data: data);
  }

  static Future<Response> delete(String path) async {
    print("Sending request to $path");
    return _dio.delete(path);
  }
}

// Keep: final api = ApiService(); (or prefer using the singleton Api() directly)