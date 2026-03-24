import 'package:flutter/material.dart';
import 'package:my_project/widgets/app_btn.dart';
import 'package:my_project/widgets/app_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext bc) => Scaffold(
    backgroundColor: Colors.grey[100],
    body: Padding(
      padding: const EdgeInsets.all(30), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50], 
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2, size: 80, color: Colors.blue[800]),
          ),
          const SizedBox(height: 15),
          Text(
            'Smart Post', 
            style: TextStyle(
              fontSize: 32, 
              fontWeight: FontWeight.bold, 
              color: Colors.blue[900],
              letterSpacing: 1.2
            )
          ),
          const SizedBox(height: 30),
          const AppInput('Your Email', Icons.email),
          const SizedBox(height: 10),
          const AppInput('Password', Icons.lock),
          const SizedBox(height: 25),
          AppBtn('Login', () => Navigator.pushReplacementNamed(bc, '/home')),
          TextButton(
            onPressed: () => Navigator.pushNamed(bc, '/reg'), 
            child: Text('Create new account', 
            style: TextStyle(color: Colors.blue[700]))
          )
        ],
      ),
    ),
  );
}
