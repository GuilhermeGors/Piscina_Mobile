import 'package:flutter/material.dart';
import 'package:diary_app/features/diary/presentation/pages/profile_page.dart';
import 'package:diary_app/features/diary/presentation/pages/agenda_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
        children: [ProfilePage(), AgendaPage()],
      ),
      bottomNavigationBar: Container(
        color: backgroundColor.withAlpha((0.8 * 255).toInt()),
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
