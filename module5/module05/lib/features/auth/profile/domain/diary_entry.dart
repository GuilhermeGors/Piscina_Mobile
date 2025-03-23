class DiaryEntry {
  final String id;
  final String userEmail;
  final DateTime date;
  final String title;
  final String mood;
  final String content;

  DiaryEntry({
    required this.id,
    required this.userEmail,
    required this.date,
    required this.title,
    required this.mood,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'userEmail': userEmail,
      'date': date.toIso8601String(),
      'title': title,
      'mood': mood,
      'content': content,
    };
  }

  factory DiaryEntry.fromMap(String id, Map<String, dynamic> data) {
    return DiaryEntry(
      id: id,
      userEmail: data['userEmail'] ?? '',
      date: DateTime.parse(data['date']),
      title: data['title'] ?? '',
      mood: data['mood'] ?? '',
      content: data['content'] ?? '',
    );
  }
}