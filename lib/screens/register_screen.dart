import 'package:flutter/material.dart';
import 'package:my_project/widgets/app_btn.dart';
import 'package:my_project/widgets/app_input.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Registration')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const AppInput('Full Name', Icons.person), const SizedBox(height: 15),
        const AppInput('Email', Icons.email), const SizedBox(height: 15),
        const AppInput('Password', Icons.lock), const SizedBox(height: 15),
        const AppInput('Confirm Password', Icons.lock_outline), 
        const SizedBox(height: 25),
        AppBtn('Create Account', () => Navigator.pop(c)),
        TextButton(onPressed: () => Navigator.pop(c), 
        child: const Text('Already have an account? Login'))
      ]),
    ));
}
