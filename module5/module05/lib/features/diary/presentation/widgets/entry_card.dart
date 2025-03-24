import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diary_app/features/diary/domain/models/diary_entry.dart';

class EntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      color: const Color(0xFFEDE7F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(entry.title),
        subtitle: Text(
          '${DateFormat('HH:mm').format(entry.date)} - ${_getMoodEmote(entry.mood)}',
        ),
        onTap: onTap, // Agora o EntryCard pode abrir os detalhes corretamente
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }

  String _getMoodEmote(String mood) {
    const moodEmotes = {
      'happy': '😊',
      'sad': '😢',
      'angry': '😠',
      'neutral': '😐',
    };
    return moodEmotes[mood] ?? '😐';
  }
}
