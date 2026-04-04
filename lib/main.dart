import 'package:flutter/material.dart';
import 'package:my_project/data/repositories/secure_auth_repository.dart';
import 'package:my_project/logic/auth_provider.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/screens/register_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(SecureAuthRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: authProvider.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (authProvider.currentUser == null
                ? const LoginScreen()
                : const HomeScreen()),
      routes: {
        '/reg': (c) => const RegisterScreen(),
        '/home': (c) => const HomeScreen(),
        '/profile': (c) => const ProfileScreen(),
      },
    );
  }
}
