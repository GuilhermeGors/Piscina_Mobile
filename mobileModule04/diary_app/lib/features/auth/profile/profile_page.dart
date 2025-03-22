import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import './domain/diary_entry.dart';
import 'profile_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //simula banco de dados
  List<DiaryEntry> _entries = [];

  void _showCreateEntryDialog() async {
    final newEntry = await showDialog<DiaryEntry>(
      context: context,
      builder: (context) => _CreateEntryDialog(),
    );

    if (newEntry != null) {
      setState(() {
        _entries.add(newEntry);
      });
    }
  }

  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileView(
      entries: _entries,
      onCreateEntryPressed: _showCreateEntryDialog,
      onDeleteEntry: _deleteEntry,
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
                title: _titleController.text,
                mood: _selectedMood,
                content: _contentController.text,
                date: DateTime.now(),
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