import 'package:flutter/material.dart';

void main() {
  runApp(const ExApp());
}

class ExApp extends StatelessWidget {
  const ExApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Scream',
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: const MyScream(),
    );
  }
}

class MyScream extends StatefulWidget {
  const MyScream({super.key});

  @override
  MyScreamState createState() => MyScreamState();
}

class MyScreamState extends State<MyScream> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('A Scream', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint('button pressed');
              },
              child: const Text('Press here'),
            ),
          ],
        ),
      ),
    );
  }
}
