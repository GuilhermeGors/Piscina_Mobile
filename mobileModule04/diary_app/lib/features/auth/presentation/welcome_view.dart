import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const WelcomeView({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo ao Diary App!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onLoginPressed,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}