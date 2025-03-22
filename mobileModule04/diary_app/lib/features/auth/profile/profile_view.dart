import 'package:diary_app/features/auth/profile/domain/diary_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileView extends StatelessWidget {
  final List<DiaryEntry> entries;
  final VoidCallback onCreateEntryPressed;
  final Function(String) onDeleteEntry;

  const ProfileView({
    super.key,
    required this.entries,
    required this.onCreateEntryPressed,
    required this.onDeleteEntry,
  });

  void _showEntryDetails(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Humor: ',
                  style: TextStyle(fontSize: 16),
                ),
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
            Text(
              entry.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
        'My Diary',
        style: TextStyle(
          fontFamily: 'ComicSans',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
          ),
        ),
      ),
      body: entries.isEmpty
          ? const Center(child: Text('Nenhuma entrada ainda'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  color: const Color(0xFFEDE7F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () => _showEntryDetails(context, entry),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(entry.date),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _getMoodEmote(entry.mood),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => onDeleteEntry(entry.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreateEntryPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}