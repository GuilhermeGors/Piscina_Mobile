import 'package:flutter/material.dart';
import '/core/services/auth_service.dart';
import 'home_page.dart';
import '../views/login_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  Future<void> _handleGoogleLogin() async {
    final user = await _authService.signInWithGoogle();
    if (!mounted) return;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Goggle login fail :()')));
    }
  }

  Future<void> _handleGitHubLogin() async {
    final user = await _authService.signInWithGitHub(context);
    if (!mounted) return;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Github login fail :()')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginView(
      onGoogleLoginPressed: _handleGoogleLogin,
      onGitHubLoginPressed: _handleGitHubLogin,
    );
  }
}
