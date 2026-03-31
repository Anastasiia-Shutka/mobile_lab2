import 'dart:convert';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository implements AuthRepository {
  static const String _userKey = 'registered_user';

  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return User.fromJson(jsonDecode(userStr) as Map<String, dynamic>);
  }

  @override
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
