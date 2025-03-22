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

  void _showCreateEntryDialog() async {
    final newEntry = await showDialog<DiaryEntry>(
      context: context,
      builder: (context) => _CreateEntryDialog(),
    );

    if (newEntry != null) {
      await _databaseService.createEntry(newEntry);
      // StreamBuilder updating ProfileView
    }
  }

  void _deleteEntry(String id) async {
    await _databaseService.deleteEntry(id);
    // StreamBuilder updating
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
            body: Center(child: Text('Erro ao carregar entradas')),
          );
        }
        final entries = snapshot.data ?? [];
        return ProfileView(
          entries: entries,
          onCreateEntryPressed: _showCreateEntryDialog,
          onDeleteEntry: _deleteEntry,
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Entrada'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Humor:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.sentiment_very_satisfied),
                  color: _selectedMood == 'happy' ? Colors.green : null,
                  onPressed: () => setState(() => _selectedMood = 'happy'),
                ),
                IconButton(
                  icon: const Icon(Icons.sentiment_neutral),
                  color: _selectedMood == 'neutral' ? Colors.amber : null,
                  onPressed: () => setState(() => _selectedMood = 'neutral'),
                ),
                IconButton(
                  icon: const Icon(Icons.sentiment_very_dissatisfied),
                  color: _selectedMood == 'sad' ? Colors.red : null,
                  onPressed: () => setState(() => _selectedMood = 'sad'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _contentController.text.isNotEmpty) {
              final entry = DiaryEntry(
                id: const Uuid().v4(),
                userEmail: '', // fillig by DatabaseService
                date: DateTime.now(),
                title: _titleController.text,
                mood: _selectedMood,
                content: _contentController.text,
              );
              Navigator.pop(context, entry);
            }
          },
          child: const Text('Criar'),
        ),
      ],
    );
  }
}