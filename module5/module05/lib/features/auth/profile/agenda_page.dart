import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '/core/services/database_service.dart';
import 'package:diary_app/features/auth/profile/domain/diary_entry.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final DatabaseService _databaseService = DatabaseService();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<DiaryEntry>> _entriesByDate = {};

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    final entries = await _databaseService.getEntries().first;
    setState(() {
      _entriesByDate = {};
      for (var entry in entries) {
        final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
        if (_entriesByDate[date] == null) {
          _entriesByDate[date] = [];
        }
        _entriesByDate[date]!.add(entry);
      }
    });
  }
  void _showEntryDetails(BuildContext context, DiaryEntry entry, VoidCallback onDelete) {
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
              onDelete();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  final Map<String, String> _moodEmotes = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😠',
    'neutral': '😐',
  };

  String _getMoodEmote(String mood) {
    return _moodEmotes[mood] ?? '😐';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Agenda')),
      ),
      body: StreamBuilder<List<DiaryEntry>>(
        stream: _databaseService.getEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading entries'));
          }
          final entries = snapshot.data ?? [];
          final selectedEntries = entries
              .where((entry) => isSameDay(entry.date, _selectedDay))
              .toList();

          return Column(
            children: [
              TableCalendar(
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Colors.purple[100],
                    shape: BoxShape.circle
                  )
                  
                ),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (_entriesByDate[date] != null) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  defaultBuilder: (context, date, _) {
                    if (_entriesByDate[date] != null) {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: selectedEntries.isEmpty
                    ? const Center(child: Text('No entries on this date'))
                    : ListView.builder(
                        itemCount: selectedEntries.length,
                        itemBuilder: (context, index) {
                          final entry = selectedEntries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            color: const Color(0xFFEDE7F6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              title: Text(entry.title),
                              subtitle: Text(
                                  '${DateFormat('HH:mm').format(entry.date)} - ${_getMoodEmote(entry.mood)}'),
                              onTap: () => _showEntryDetails(context, entry, () {
                                _databaseService.deleteEntry(entry.id);
                              }),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}