import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import '../utils/role_based_navigation.dart';
// import 'donor_home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Parent';
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => value!.isEmpty ? 'Enter password' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['Parent', 'Childcare Giver']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              ElevatedButton(
                onPressed: _handleRegistration,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

void _handleRegistration() async {
  if (_formKey.currentState!.validate()) {
    final user = await _authService.signUpWithEmail(
      _emailController.text,
      _passwordController.text,
      _selectedRole,
    );
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleBasedNavigation.determineHomeScreen(user),
        ),
      );
    }
  }
}
}

// class RegisterScreen extends StatefulWidget {