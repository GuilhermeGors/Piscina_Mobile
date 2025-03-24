import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diary_app/features/diary/domain/models/diary_entry.dart';
import 'package:diary_app/styles/colors.dart';
import '../../../auth/profile/sales_graph.dart';

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
      builder:
          (context) => AlertDialog(
            title: Text(entry.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Mood: ', style: TextStyle(fontSize: 16)),
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
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  onDeleteEntry(entry.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: accentColor),
                ),
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
    return moodCount.map(
      (mood, count) => MapEntry(mood, (count / entries.length) * 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastTwoEntries =
        entries.length >= 2 ? entries.sublist(0, 2) : entries;
    final moodPercentages = _calculateMoodPercentages();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userProfilePhotoUrl),
              backgroundColor: backgroundColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Center(
                child: Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: accentColor),
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
            Text(
              'Last two entries:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (lastTwoEntries.isEmpty)
              const Text('No entry yet :()')
            else
              Column(
                children:
                    lastTwoEntries
                        .map(
                          (entry) => Card(
                            child: ListTile(
                              title: Text(entry.title),
                              subtitle: Text(
                                '${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)} - ${_getMoodEmote(entry.mood)}',
                              ),
                              onTap: () => _showEntryDetails(context, entry),
                            ),
                          ),
                        )
                        .toList(),
              ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withAlpha((0.2 * 255).toInt()),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Your mood for your ${entries.length} entries',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlutterSalesGraph(
                          salesData: moodPercentages.values.toList(),
                          labels:
                              moodPercentages.keys
                                  .map((mood) => _getMoodEmote(mood))
                                  .toList(),
                          maxBarHeight: 250.0,
                          barWidth: 40.0,
                          colors: const [
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                            Colors.yellow,
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children:
                              moodPercentages.entries
                                  .map(
                                    (entry) => Text(
                                      '${entry.value.toStringAsFixed(1)}%',
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
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
