import 'package:flutter/material.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  User? _currentUser;
  bool _isLoading = true;

  AuthProvider(this.repository) {
    loadUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    _currentUser = await repository.getUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(User user) async {
    await repository.saveUser(user);
    _currentUser = user;
    notifyListeners(); 
  }

Future<bool> login(String email, String password) async {
  if (email == 'anna@gmail.com' && password == '12345678') {
    _currentUser = User(
      name: 'Anna', 
      email: 'anna@gmail.com', 
      password: '12345678'
    );
    notifyListeners();
    return true; 
  }

  final savedUser = await repository.getUser();
  if (savedUser != null &&
      savedUser.email == email &&
      savedUser.password == password) {
    _currentUser = savedUser;
    notifyListeners();
    return true;
  }
  return false;
}

  Future<void> updateUser({
    required String newName,
    required String newEmail,
    required String newPassword,
  }) async {
    if (_currentUser != null) {
      _currentUser!.name = newName;
      _currentUser!.email = newEmail;
      _currentUser!.password = newPassword;
      await repository.saveUser(_currentUser!);
      notifyListeners(); 
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await repository.clearData();
    notifyListeners();
  }
}
