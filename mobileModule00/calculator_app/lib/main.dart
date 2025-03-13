import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const ExApp());
}

class ExApp extends StatelessWidget {
  const ExApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
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

  void _evaluateExpression() {
    String expression = _controller1.text;
    expression = expression.replaceAll('x', '*');
    expression = expression.replaceAll('÷', '/');
    try {
      final ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _controller2.text = eval.toString();
    } catch (e) {
      _controller2.text = 'Error';
    }
  }

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
        actions: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(),
          ),
        ],
        shape: const RoundedRectangleBorder(

          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
          side: BorderSide(color: Colors.greenAccent),
        ),
        ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                readOnly: true,
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
                readOnly: true,
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
                        _evaluateExpression();
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
