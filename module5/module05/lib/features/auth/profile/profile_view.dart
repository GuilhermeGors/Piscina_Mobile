import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diary_app/features/auth/profile/domain/diary_entry.dart';

class ProfileView extends StatelessWidget {
  final String userName;
  final String userProfilePhotoUrl;
  final List<DiaryEntry> entries;
  final VoidCallback onCreateEntryPressed;
  final Function(String) onDeleteEntry;
  final VoidCallback onLogoutPressed;

  const ProfileView({
    super.key,
    required this.userName,
    required this.userProfilePhotoUrl,
    required this.entries,
    required this.onCreateEntryPressed,
    required this.onDeleteEntry,
    required this.onLogoutPressed,
  });

  void _showEntryDetails(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFEDE7F6),
        title: Text(entry.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Humor: ', style: TextStyle(fontSize: 16)),
                Text(_getMoodEmote(entry.mood), style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(entry.mood[0].toUpperCase() + entry.mood.substring(1),
                    style: const TextStyle(fontSize: 16)),
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
              onDeleteEntry(entry.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
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

  Map<String, double> _calculateMoodPercentages() {
    if (entries.isEmpty) return {};
    final moodCount = <String, int>{};
    for (var entry in entries) {
      moodCount[entry.mood] = (moodCount[entry.mood] ?? 0) + 1;
    }
    return moodCount.map((mood, count) => MapEntry(mood, (count / entries.length) * 100));
  }

  @override
  Widget build(BuildContext context) {
    final lastTwoEntries = entries.length > 2 ? entries.sublist(0, 2) : entries;
    final moodPercentages = _calculateMoodPercentages();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Row(
          children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(userProfilePhotoUrl),
            backgroundColor: const Color.fromARGB(255, 173, 159, 199),
            child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 46,
              backgroundImage: NetworkImage(userProfilePhotoUrl),
            ),
            ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Center(
            child: Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: onLogoutPressed,
        ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Last two entrys:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (lastTwoEntries.isEmpty)
              const Text('No entry yet :()')
            else
              Column(
              children: lastTwoEntries.map((entry) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                color: const Color(0xFFEDE7F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                title: Text(entry.title),
                subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)} - ${_getMoodEmote(entry.mood)}'),
                onTap: () => _showEntryDetails(context, entry),
                ),
              )).toList(),
              ),
              const SizedBox(height: 16),
                Center(
                child: Container(
                  decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                    ),
                  ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                  'Total entries: ${entries.length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ),

            const SizedBox(height: 16),
            const Text('Mood Percentages:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (moodPercentages.isEmpty)
              const Text('No data available')
            else
              Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD1C4E9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: moodPercentages.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                  Text('${_getMoodEmote(entry.key)} ${entry.key[0].toUpperCase() + entry.key.substring(1)}: '),
                  Text('${entry.value.toStringAsFixed(1)}%'),
                  ],
                ),
                )).toList(),
              ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreateEntryPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}