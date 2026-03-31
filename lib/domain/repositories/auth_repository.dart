import 'package:my_project/domain/models/user.dart';

abstract class AuthRepository {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clearData();
}
