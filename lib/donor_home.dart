import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class DonorHome extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _handleLogout() async {
    await _authService.signOut();
    Get.offAll(() => LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Nurture - Donor'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          )
        ],
      ),
      body: const Center(
        child: Text('Donor Dashboard'),
      ),
    );
  }
}