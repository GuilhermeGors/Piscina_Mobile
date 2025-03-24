import '../../data/repositories/diary_repository.dart';

class DeleteDiaryEntry {
  final DiaryRepository _repository;

  DeleteDiaryEntry(this._repository);

  Future<void> call(String id) async {
    return _repository.deleteEntry(id);
  }
}
