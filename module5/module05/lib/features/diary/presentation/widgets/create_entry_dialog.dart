import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/diary_entry.dart';

class CreateEntryDialog extends StatefulWidget {
  @override
  CreateEntryDialogState createState() => CreateEntryDialogState();
}

class CreateEntryDialogState extends State<CreateEntryDialog> {
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
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Humor:'),
            DropdownButton<String>(
              value: _selectedMood,
              onChanged: (value) => setState(() => _selectedMood = value!),
              items:
                  _moods
                      .map(
                        (mood) => DropdownMenuItem(
                          value: mood,
                          child: Row(
                            children: [
                              Text(_getMoodEmote(mood)),
                              const SizedBox(width: 8),
                              Text(mood[0].toUpperCase() + mood.substring(1)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _contentController.text.isNotEmpty) {
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
