import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '/core/services/auth_service.dart';
import '/core/services/database_service.dart';
import '/features/auth/presentation/welcome_page.dart';
import 'package:diary_app/features/auth/profile/domain/diary_entry.dart';
import 'profile_view.dart';

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
      builder: (context) => _CreateEntryDialog(),
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text('Error loading entries')));
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

class _CreateEntryDialog extends StatefulWidget {
  @override
  __CreateEntryDialogState createState() => __CreateEntryDialogState();
}

class __CreateEntryDialogState extends State<_CreateEntryDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'happy';
  final List<String> _moods = ['happy', 'sad', 'angry', 'neutral'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getMoodEmote(String mood) {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'neutral':
        return '😐';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFEDE7F6),
      title: const Text('New entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Humor:'),
            DropdownButton<String>(
              value: _selectedMood,
              onChanged: (value) => setState(() => _selectedMood = value!),
              items: _moods
                  .map((mood) => DropdownMenuItem(
                        value: mood,
                        child: Row(
                          children: [
                            Text(_getMoodEmote(mood)),
                            const SizedBox(width: 8),
                            Text(mood[0].toUpperCase() + mood.substring(1)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
              final entry = DiaryEntry(
                id: const Uuid().v4(),
                userEmail: '',
                date: DateTime.now(),
                title: _titleController.text,
                mood: _selectedMood,
                content: _contentController.text,
              );
              Navigator.pop(context, entry);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}