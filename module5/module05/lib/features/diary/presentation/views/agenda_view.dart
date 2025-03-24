import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../widgets/entry_details_dialog.dart';

class AgendaView extends StatefulWidget {
  final List<DiaryEntry> entries;
  final Function(String) onDelete;

  const AgendaView({super.key, required this.entries, required this.onDelete});

  @override
  AgendaViewState createState() => AgendaViewState();
}

class AgendaViewState extends State<AgendaView> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late CalendarFormat _calendarFormat;
  bool _isFirstBuild = true;

  void _showEntryDetails(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder:
          (context) =>
              EntryDetailsDialog(entry: entry, onDelete: widget.onDelete),
    );
  }

  List<DiaryEntry> _getEventsForDay(DateTime day) {
    return widget.entries.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      final compareDate = DateTime(day.year, day.month, day.day);
      return isSameDay(entryDate, compareDate);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.week; // Começa em week
  }

  final Map<CalendarFormat, CalendarFormat> _formatMap = {
    CalendarFormat.week: CalendarFormat.twoWeeks, // week -> twoWeeks
    CalendarFormat.twoWeeks: CalendarFormat.month, // twoWeeks -> month
    CalendarFormat.month: CalendarFormat.week, // month -> week
  };

  CalendarFormat _getNextFormat(CalendarFormat currentFormat) {
    return _formatMap[currentFormat] ?? CalendarFormat.week; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntries =
        widget.entries
            .where((entry) => isSameDay(entry.date, _selectedDay))
            .toList();

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (_isFirstBuild) {
            _calendarFormat = CalendarFormat.week; // Sempre começa em week
            _isFirstBuild = false;
          }

          return Column(
            children: [
              // Usando LayoutBuilder com AnimatedSwitcher e SizeTransition
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 300,
                    ), // Duração da animação
                    transitionBuilder: (child, animation) {
                      return SizeTransition(
                        sizeFactor: animation, // Anima a altura
                        axis: Axis.vertical, // Transição vertical
                        child: child,
                      );
                    },
                    child: ConstrainedBox(
                      key: ValueKey(
                        _calendarFormat,
                      ), // Chave única para cada formato
                      constraints: BoxConstraints(
                        maxHeight:
                            _calendarFormat == CalendarFormat.month
                                ? constraints.maxHeight *
                                    0.5 // 50% da altura para month
                                : _calendarFormat == CalendarFormat.twoWeeks
                                ? 250 // Altura fixa para twoWeeks
                                : 180, // Altura fixa para week
                        minHeight: 180,
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate:
                            (day) => isSameDay(day, _selectedDay),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = _getNextFormat(
                              _calendarFormat,
                            ); // Ordem personalizada
                          });
                        },
                        eventLoader: _getEventsForDay,
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: true,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(
                            border: Border.all(color: Colors.purple),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: Colors.purple,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: Colors.purple,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.purple[300],
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.purple[500],
                            shape: BoxShape.circle,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isNotEmpty) {
                              return Positioned(
                                right: 1,
                                bottom: 1,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${events.length}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    selectedEntries.isEmpty
                        ? const Center(child: Text('No entries on this date'))
                        : ListView.builder(
                          itemCount: selectedEntries.length,
                          itemBuilder: (context, index) {
                            final entry = selectedEntries[index];
                            return EntryCard(
                              entry: entry,
                              onTap: () => _showEntryDetails(context, entry),
                              onDelete: () => widget.onDelete(entry.id),
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
