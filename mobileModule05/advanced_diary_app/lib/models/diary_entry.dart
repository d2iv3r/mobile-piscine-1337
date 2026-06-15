import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntry {
  final String id;
  final String userEmail;
  final DateTime date;
  final String title;
  final String feeling; // "happy", "sad", "satisfied", "angry", "neutral"
  final String content;

  DiaryEntry({
    required this.id,
    required this.userEmail,
    required this.date,
    required this.title,
    required this.feeling,
    required this.content,
  });

  factory DiaryEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DiaryEntry(
      id: doc.id,
      userEmail: data['usermail'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      title: data['title'] as String? ?? '',
      feeling: data['icon'] as String? ?? 'neutral',
      content: data['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usermail': userEmail,
      'date': Timestamp.fromDate(date),
      'title': title,
      'icon': feeling,
      'text': content,
    };
  }
}

class Feeling {
  final String key;
  final String label;
  final String emoji;

  const Feeling(this.key, this.label, this.emoji);

  static const List<Feeling> all = [
    Feeling('happy', 'Happy', '😄'),
    Feeling('satisfied', 'Satisfied', '🙂'),
    Feeling('neutral', 'Neutral', '😐'),
    Feeling('sad', 'Sad', '😢'),
    Feeling('angry', 'Angry', '😠'),
  ];

  static Feeling fromKey(String key) {
    return all.firstWhere(
      (f) => f.key == key,
      orElse: () => all[2],
    );
  }
}