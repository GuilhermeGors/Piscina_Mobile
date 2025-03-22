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
        title: Text(entry.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)}'),
            Text('Humor: ${entry.mood}'),
            const SizedBox(height: 8),
            Text(entry.content),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Diário')),
      body: entries.isEmpty
          ? const Center(child: Text('Nenhuma entrada ainda'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text(entry.title),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(entry.date), // Formata data e hora
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDeleteEntry(entry.id),
                  ),
                  onTap: () => _showEntryDetails(context, entry),
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