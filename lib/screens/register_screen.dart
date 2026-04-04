import 'package:flutter/material.dart';

import 'package:my_project/domain/models/user.dart';
import 'package:my_project/data/repositories/local_auth_repository.dart';
import 'package:my_project/widgets/app_btn.dart';
import 'package:my_project/widgets/app_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _repository = LocalAuthRepository();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        password: _passController.text,
      );

      await _repository.saveUser(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Registration')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey, 
            child: Column(children: [
              AppInput(
                'Full Name', 
                Icons.person, 
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 15),
              AppInput(
                'Email', 
                Icons.email, 
                controller: _emailController,
                validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 15),
              AppInput(
                'Password', 
                Icons.lock, 
                controller: _passController,
                isPassword: true,
                validator: 
                (v) => v!.length < 6 ? 'Too short (min 6 symbols)' : null,
              ),
              const SizedBox(height: 15),
              AppInput(
                'Confirm Password', 
                Icons.lock_outline, 
                controller: _confirmPassController,
                isPassword: true,
                validator: 
                (v) => v != _passController.text ? 
                'Passwords do not match' : null,
              ),
              const SizedBox(height: 25),
              AppBtn('Create Account', _register),
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Already have an account? Login'),
              )
            ]),
          ),
        ),
      );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
}
