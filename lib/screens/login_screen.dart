
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user = await authService.signInWithGoogle();
            if (user != null) {
              print('Logged in as ${user.displayName}');
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
