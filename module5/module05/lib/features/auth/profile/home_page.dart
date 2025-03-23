import 'package:flutter/material.dart';
import 'package:diary_app/features/auth/profile/profile_page.dart';
import 'package:diary_app/features/auth/profile/agenda_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color backgroundColor = const Color(0xFFEDE7F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProfilePage(),
          AgendaPage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: backgroundColor.withOpacity(0.8),
        height: 80,
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Agenda'),
          ],
        ),
      ),
    );
  }
}