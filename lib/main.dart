import 'package:flutter/material.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/screens/register_screen.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (c) => const LoginScreen(),
      '/reg': (c) => const RegisterScreen(),
      '/home': (c) => const HomeScreen(),
      '/profile': (c) => const ProfileScreen(),
    },
  ),
);
