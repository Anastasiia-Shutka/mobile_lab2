import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_project/domain/models/user.dart';
import 'package:my_project/logic/auth_provider.dart';
import 'package:my_project/widgets/app_btn.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passController = TextEditingController(text: user.password);

    showDialog<void>( 
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty 
              && emailController.text.isNotEmpty) {
                context.read<AuthProvider>().updateUser(
                      newName: nameController.text.trim(),
                      newEmail: emailController.text.trim(),
                      newPassword: passController.text.trim(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 45, color: Colors.white),
            ),
            const SizedBox(height: 10),
 
            Text(
              user?.name ?? 'Guest User',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
   
            Text(
              user?.email ?? 'No email found',
              style: const TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 25),

            Card(
              shape: 
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _item(
                    Icons.edit,
                    'Edit Profile',
                    () {
                      if (user != null) {
                        _showEditDialog(context, user);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _item(Icons.notifications_none, 'Notifications', () {}),
                  const Divider(height: 1),
                  _item(Icons.help_outline, 'Help & Support', () {}),
                  const Divider(height: 1),
                  _item(Icons.security, 'Privacy Policy', () {}),
                ],
              ),
            ),

            const Spacer(),
            AppBtn(
              'Logout',
              () {
                authProvider.logout(); 
                Navigator.pushReplacementNamed(context, '/');
              },
              c: Colors.red[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData i, String t, VoidCallback onTap) => ListTile(
        leading: Icon(i, color: Colors.blue),
        title: Text(t),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      );
}
