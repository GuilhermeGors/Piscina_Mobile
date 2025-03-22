import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  final VoidCallback onGoogleLoginPressed;
  final VoidCallback onGitHubLoginPressed;

  const LoginView({
    super.key,
    required this.onGoogleLoginPressed,
    required this.onGitHubLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login with',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 50),
                
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Entrar com Google'),
                onPressed: onGoogleLoginPressed,
              ),
              const SizedBox(height: 10),
              const Text('or'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.code),
                label: const Text('Entrar com GitHub'),
                onPressed: onGitHubLoginPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}