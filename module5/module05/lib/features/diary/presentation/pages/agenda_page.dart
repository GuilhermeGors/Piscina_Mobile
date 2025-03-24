import 'package:flutter/material.dart';
import '../../domain/usecases/get_diary_entries.dart';
import '../../domain/usecases/delete_diary_entry.dart';
import '../../data/repositories/diary_repository.dart';
import '../../presentation/views/agenda_view.dart';
import '../../domain/models/diary_entry.dart';

class AgendaPage extends StatelessWidget {
  final GetDiaryEntries _getEntries;
  final DeleteDiaryEntry _deleteEntry;

  AgendaPage({super.key})
    : _getEntries = GetDiaryEntries(DiaryRepository()),
      _deleteEntry = DeleteDiaryEntry(DiaryRepository());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _getEntries(),
      builder: (context, AsyncSnapshot<List<DiaryEntry>> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading entries'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return AgendaView(
          entries: snapshot.data!,
          onDelete: (id) => _deleteEntry(id),
        );
      },
    );
  }
}
