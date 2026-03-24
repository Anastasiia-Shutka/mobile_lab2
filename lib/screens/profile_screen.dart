import 'package:flutter/material.dart';
import 'package:my_project/widgets/app_btn.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(title: const Text('Profile'), centerTitle: true),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const CircleAvatar(radius: 45, backgroundColor: Colors.blue, 
          child: Icon(Icons.person, size: 45, color: Colors.white)),
        const SizedBox(height: 10),
        const Text('Anastasiia Shutka', style: TextStyle(fontSize: 20, 
        fontWeight: FontWeight.bold)),
        const Text('ID: #77412', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 25),

        Card(
          shape: 
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: [
            _item(Icons.edit, 'Edit Profile'),
            const Divider(height: 1),
            _item(Icons.notifications_none, 'Notifications'),
            const Divider(height: 1),
            _item(Icons.help_outline, 'Help & Support'),
            const Divider(height: 1),
            _item(Icons.security, 'Privacy Policy'),
          ]),
        ),

        const Spacer(),
        AppBtn('Logout', () => Navigator.pushReplacementNamed(c, '/'), c: Colors.red[400]),
      ]),
    ),
  );

  Widget _item(IconData i, String t) => ListTile(
    leading: Icon(i, color: Colors.blue),
    title: Text(t),
    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    onTap: () {}, 
  );
}
