import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const MyHomePage(),
    );
  } 
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDisplayText(String text) {
    setState(() {
      _displayText = text;
    });
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.blueGrey),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
            Container(
            alignment: Alignment.center,
            width: 200,
            child: TextField(
              decoration: InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.blueGrey),
              prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
              ),
              style: const TextStyle(color: Colors.blueGrey),
              onSubmitted: (text) {
              _updateDisplayText(text);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              _updateDisplayText('Geolocation');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Text(
              'Currently\n$_displayText',
              textAlign: TextAlign.center,
              style: const 
                TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24
                  ),
            ),
          ),
          Center(
            child: Text(
              'Today\n$_displayText',
              textAlign: TextAlign.center,
              style: const 
                TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24
                  ),
            ),
          ),
          Center(
            child: Text(
              'Weekly\n$_displayText',
              textAlign: TextAlign.center,
              style: const 
                TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24
                  ),              
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.cloud), text: 'Currently'),
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.calendar_view_week), text: 'Weekly'),
          ],
        ),
      ),
    );
  }
}
