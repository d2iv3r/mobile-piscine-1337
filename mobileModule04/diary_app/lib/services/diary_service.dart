import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diary_entry.dart';

class DiaryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'notes';

  String? get _currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  Stream<List<DiaryEntry>> watchEntries() {
    final email = _currentUserEmail;
    if (email == null) return Stream.value([]);

    return _db
        .collection(_collection)
        .where('usermail', isEqualTo: email)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DiaryEntry.fromDoc(doc)).toList());
  }

  Future<void> addEntry({
    required String title,
    required String feeling,
    required String content,
    DateTime? date,
  }) async {
    final email = _currentUserEmail;
    if (email == null) throw Exception('No user logged in');

    final entry = DiaryEntry(
      id: '',
      userEmail: email,
      date: date ?? DateTime.now(),
      title: title,
      feeling: feeling,
      content: content,
    );

    await _db.collection(_collection).add(entry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await _db.collection(_collection).doc(entry.id).update(entry.toMap());
  }
}