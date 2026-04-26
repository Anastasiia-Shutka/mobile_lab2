import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/data/repositories/secure_auth_repository.dart';
import 'package:my_project/logic/app_cubit.dart';
import 'package:my_project/logic/app_state.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/screens/register_screen.dart';

void main() {
  runApp(
    RepositoryProvider(
      create: (context) => SecureAuthRepository(),
      child: BlocProvider(
        create: (context) => AppCubit(context.read<SecureAuthRepository>()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: state.isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : (state.user == null
                  ? const LoginScreen()
                  : const HomeScreen()),
          routes: {
            '/reg': (c) => const RegisterScreen(),
            '/home': (c) => const HomeScreen(),
            '/profile': (c) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
