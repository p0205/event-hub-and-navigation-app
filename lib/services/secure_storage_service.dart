import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/models/user.dart';

class SecureStorageService {
  static const _jwtTokenKey = 'jwt';
  static const _userKey = 'user';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtTokenKey, value: token);
  }

  Future<void> saveUser(User user) async {
    final jsonString = jsonEncode(user);
    await _storage.write(key: _userKey, value: jsonString);
  }

  Future<User?> getUser() async {

    final jsonString  = await _storage.read(key: _userKey);
    if(jsonString==null) return null;
    final Map<String,dynamic> jsonMap = jsonDecode(jsonString);
    return User.fromJson(jsonMap);
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _jwtTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _jwtTokenKey);
  }
}
