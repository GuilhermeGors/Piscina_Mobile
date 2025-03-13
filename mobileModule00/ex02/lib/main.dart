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
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Calculator'),
        toolbarHeight: 50,
        titleTextStyle: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        backgroundColor: Colors.black,
        shape: const Border(
          top: BorderSide(color: Colors.greenAccent, width: 2),
          bottom: BorderSide(color: Colors.greenAccent, width: 2),
          left: BorderSide(color: Colors.greenAccent, width: 2),
          right: BorderSide(color: Colors.greenAccent, width: 2),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller1,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.greenAccent),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                  labelText: 'Input',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 74, 187, 132)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 74, 187, 132)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 74, 187, 132)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller2,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Color.fromARGB(255, 74, 187, 132)),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 74, 187, 132)),
                  ),
                  labelText: 'Result',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 74, 187, 132)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 74, 187, 132)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 74, 187, 132)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: 19,
                itemBuilder: (context, index) {
                  final buttons = [
                    '7', '8', '9', 'C', 'AC',
                    '4', '5', '6', '+', '-',
                    '1', '2', '3', '*', '/',
                    '0', '.', '00', '='
                  ];
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: const Color.fromARGB(255, 74, 187, 132),
                      side: const BorderSide(color: Color.fromARGB(255, 74, 187, 132)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () {
                      String buttonText = buttons[index];
                      if (buttonText == 'C') {
                        _controller1.clear();
                        _controller2.clear();
                      } else if (buttonText == 'AC') {
                        _controller1.clear();
                        _controller2.clear();
                      } else if (buttonText == '=') {
                      } else {
                        _controller1.text += buttonText;
                      }
                      debugPrint('Button pressed: $buttonText');
                    },
                    child: Text(
                      buttons[index],
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
