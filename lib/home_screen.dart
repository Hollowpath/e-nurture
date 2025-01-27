import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Nurture Home'),
        actions: [
          IconButton(
            icon: Row(
              children: const [
              Icon(Icons.logout),
              SizedBox(width: 5),
              Text('Logout'),
              ],
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome to E-Nurture!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}