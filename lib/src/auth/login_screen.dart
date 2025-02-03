import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import '../utils/role_based_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Sign In'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
void _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    final user = await _authService.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (user == null) {
      Get.snackbar('Error', 'Login failed');
    } else {
      Get.off(() => RoleBasedNavigation.determineHomeScreen(user));
    }
  }
}
}