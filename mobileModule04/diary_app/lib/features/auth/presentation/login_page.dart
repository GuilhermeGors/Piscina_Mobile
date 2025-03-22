import 'package:flutter/material.dart';
import 'login_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _handleLogin() {
    debugPrint('Botão de login pressionado');
  }

  void _handleGoogleLogin() {
    debugPrint('Login com Google pressionado');
  }

  void _handleGitHubLogin() {
    debugPrint('Login com GitHub pressionado');
  }

  @override
  Widget build(BuildContext context) {
    return LoginView(
      onLoginPressed: _handleLogin,
      onGoogleLoginPressed: _handleGoogleLogin,
      onGitHubLoginPressed: _handleGitHubLogin,
    );
  }
}