import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single diary entry stored in Firestore.
class DiaryEntry {
  final String id;
  final String userEmail;
  final DateTime date;
  final String title;
  final String feeling; // e.g. "happy", "sad", "satisfied", "angry", "neutral"
  final String content;

  DiaryEntry({
    required this.id,
    required this.userEmail,
    required this.date,
    required this.title,
    required this.feeling,
    required this.content,
  });

  /// Build a DiaryEntry from a Firestore document.
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

  /// Convert this entry to a map matching the Firestore structure
  /// shown in the subject (date, title, icon, text, usermail).
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

/// Available "feeling of the day" options with matching icons/colors.
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
      orElse: () => all[2], // neutral
    );
  }
}