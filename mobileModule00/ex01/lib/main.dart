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
  String _displayText = 'A Scream';

  void _toggleText() {
    setState(() {
      if (_displayText == 'A Scream') {
        _displayText = 'Agnus Dei';
      } else {
        _displayText = 'A Scream';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_displayText, style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleText,
              child: const Text('Press here'),
            ),
          ],
        ),
      ),
    );
  }
}
