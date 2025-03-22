import 'package:flutter/material.dart';
import 'features/auth/presentation/welcome_page.dart';
import 'styles/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary App',
      theme: appTheme,
      home: const WelcomePage(),
    );
  }
}