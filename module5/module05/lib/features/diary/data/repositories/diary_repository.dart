import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/diary_entry.dart';

class DiaryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _entriesCollection =>
      _firestore.collection('diary_entries');

  Stream<List<DiaryEntry>> getEntries() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _entriesCollection
        .where('userEmail', isEqualTo: user.email)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => DiaryEntry.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
        );
  }

  Future<void> deleteEntry(String id) async {
    await _entriesCollection.doc(id).delete();
  }
}
