import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';

class SecureAuthRepository implements AuthRepository {
  final _storage = const FlutterSecureStorage();

  static const String _userKey = 'registered_user';
  static const String _sessionKey = 'is_logged_in';

  @override
  Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    await _storage.write(key: _sessionKey, value: 'true');
  }

  @override
  Future<User?> getUser() async {
    final String? userStr = await _storage.read(key: _userKey);
    if (userStr == null) return null;
    return User.fromJson(jsonDecode(userStr) as Map<String, dynamic>);
  }

  @override
  Future<bool> hasSession() async {
    final String? sessionStr = await _storage.read(key: _sessionKey);
    return sessionStr == 'true';
  }

  @override
  Future<void> clearData() async {
    await _storage.delete(key: _sessionKey);
  }
}
