import 'package:flutter/material.dart';
import 'package:my_project/logic/auth_provider.dart';
import 'package:my_project/widgets/app_btn.dart';
import 'package:my_project/widgets/app_input.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext bc) => Scaffold(
    backgroundColor: Colors.grey[100],
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 80,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Smart Post',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),

              AppInput(
                'Your Email',
                Icons.email,
                controller: _emailController,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter your email' : null,
              ),

              const SizedBox(height: 10),

              AppInput(
                'Password',
                Icons.lock,
                controller: _passController,
                isPassword: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter your password' : null,
              ),

              const SizedBox(height: 25),
              AppBtn('Login', _handleLogin),

              TextButton(
                onPressed: () => Navigator.pushNamed(bc, '/reg'),
                child: Text(
                  'Create new account',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();

      // 1. ПЕРЕВІРЯЄМО ІНТЕРНЕТ
      if (auth.isOnline == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No Internet Connection!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await auth.login(
        _emailController.text,
        _passController.text,
      );

      if (success) {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
