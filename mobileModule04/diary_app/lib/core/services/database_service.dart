import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/auth/profile/domain/diary_entry.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _entriesCollection =>
      _firestore.collection('diary_entries');

  Future<void> createEntry(DiaryEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final entryWithEmail = DiaryEntry(
      id: entry.id,
      userEmail: user.email ?? '',
      date: entry.date,
      title: entry.title,
      mood: entry.mood,
      content: entry.content,
    );

    await _entriesCollection.doc(entry.id).set(entryWithEmail.toMap());
  }

  // read entrys
  Stream<List<DiaryEntry>> getEntries() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _entriesCollection
        .where('userEmail', isEqualTo: user.email)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DiaryEntry.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // deleting a entry
  Future<void> deleteEntry(String id) async {
    await _entriesCollection.doc(id).delete();
  }
}