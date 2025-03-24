import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/diary_entry.dart';

class EntryDetailsDialog extends StatelessWidget {
  final DiaryEntry entry;
  final Function(String) onDelete;

  const EntryDetailsDialog({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  String _getMoodEmote(String mood) {
    const moodEmotes = {
      'happy': '😊',
      'sad': '😢',
      'angry': '😠',
      'neutral': '😐',
    };
    return moodEmotes[mood] ?? '😐';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFEDE7F6),
      title: Text(
        entry.title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Humor: ', style: TextStyle(fontSize: 16)),
              Text(
                _getMoodEmote(entry.mood),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                entry.mood[0].toUpperCase() + entry.mood.substring(1),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(entry.content, style: const TextStyle(fontSize: 16)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.redAccent)),
        ),
        TextButton(
          onPressed: () {
            onDelete(entry.id);
            Navigator.pop(context);
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
