import 'package:flutter/material.dart';
import '/core/services/auth_service.dart';
import '/core/services/database_service.dart';
import '/features/auth/presentation/pages/welcome_page.dart';
import '/features/diary/domain/models/diary_entry.dart';
import '../views/profile_view.dart';
import '../widgets/create_entry_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    if (_authService.currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  void _showCreateEntryDialog() async {
    final newEntry = await showDialog<DiaryEntry>(
      context: context,
      builder: (context) => CreateEntryDialog(),
    );

    if (newEntry != null) {
      await _databaseService.createEntry(newEntry);
    }
  }

  void _deleteEntry(String id) async {
    await _databaseService.deleteEntry(id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DiaryEntry>>(
      stream: _databaseService.getEntries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading entries')),
          );
        }
        final entries = snapshot.data ?? [];
        return ProfileView(
          userName: _authService.currentUser?.displayName ?? 'User',
          userProfilePhotoUrl: _authService.currentUser?.photoURL ?? '',
          entries: entries,
          onCreateEntryPressed: _showCreateEntryDialog,
          onDeleteEntry: _deleteEntry,
          onLogoutPressed: _logout,
        );
      },
    );
  }
}
