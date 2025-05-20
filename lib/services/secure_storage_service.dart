import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _jwtTokenKey = 'jwt';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _jwtTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _jwtTokenKey);
  }
}
