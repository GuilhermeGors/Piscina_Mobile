import 'package:uuid/uuid.dart';
import 'package:diary_app/features/diary/domain/models/diary_entry.dart';

class CreateEntryUseCase {
  DiaryEntry execute(String title, String mood, String content) {
    return DiaryEntry(
      id: const Uuid().v4(),
      userEmail: '',
      date: DateTime.now(),
      title: title,
      mood: mood,
      content: content,
    );
  }
}
