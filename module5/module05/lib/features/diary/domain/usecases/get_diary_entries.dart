import '../../data/repositories/diary_repository.dart';
import '../models/diary_entry.dart';

class GetDiaryEntries {
  final DiaryRepository _repository;

  GetDiaryEntries(this._repository);

  Stream<List<DiaryEntry>> call() {
    return _repository.getEntries();
  }
}
