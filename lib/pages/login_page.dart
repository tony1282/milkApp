import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: 
        ElevatedButton(
          onPressed: () async {
            await _authService.signInWithGoogle();
          },
          child: const Text('Sign in with Google'),
      ),
      ),
    );
  }
}