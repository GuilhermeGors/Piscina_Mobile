import 'package:flutter/material.dart';
import './domain/diary_entry.dart';

class ProfileView extends StatelessWidget {
  final List<DiaryEntry> entries;
  final VoidCallback onCreateEntryPressed;
  final void Function(String) onDeleteEntry;

  const ProfileView({
    super.key,
    required this.entries,
    required this.onCreateEntryPressed,
    required this.onDeleteEntry,
  });

  void _showEntryDetails(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Humor: ${entry.mood}'),
              const SizedBox(height: 8),
              Text(entry.content),
              const SizedBox(height: 8),
              Text(
                  'Data: ${entry.date.toLocal().toString().substring(0, 16)}'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          // Lista de entradas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: entries.isEmpty
                ? const Center(child: Text('Nenhuma entrada ainda.'))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            entry.mood == 'happy'
                                ? Icons.sentiment_very_satisfied
                                : entry.mood == 'neutral'
                                    ? Icons.sentiment_neutral
                                    : Icons.sentiment_very_dissatisfied,
                            color: entry.mood == 'happy'
                                ? Colors.green
                                : entry.mood == 'neutral'
                                    ? Colors.amber
                                    : Colors.red,
                          ),
                          title: Text(entry.title),
                          subtitle:
                              Text(entry.date.toString().substring(0, 10)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onDeleteEntry(entry.id),
                          ),
                          onTap: () => _showEntryDetails(context, entry),
                        ),
                      );
                    },
                  ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: onCreateEntryPressed,
                child: const Text('Nova Entrada'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}