import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/learning_stats.dart';
import '../data/first_aid_videos.dart';

class LearningProgressService {
  static double overallProgress(Map<int, int> progress) {
    if (firstAidVideos.isEmpty) return 0;
    final total = List.generate(
      firstAidVideos.length,
      (index) => (progress[index + 1] ?? 0).clamp(0, 100),
    ).fold<int>(0, (accumulated, value) => accumulated + value);
    return total / (firstAidVideos.length * 100);
  }

  static Stream<Map<String, dynamic>?> watchData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  static WeeklyGoal weeklyGoal(Map<String, dynamic>? data, [int? lessonId]) {
    final now = DateTime.now();
    dynamic saved = data?['metaSemanal'];
    if (saved == null) {
      final lessons = data?['progressoAulas'];
      final ids = <int>[];
      if (lessons is Map) {
        for (final entry in lessons.entries) {
          final value = entry.value;
          final id = int.tryParse(entry.key.toString());
          if (id == null ||
              id < 1 ||
              id > firstAidVideos.length ||
              value is! Map) {
            continue;
          }
          final date = value['updatedAt'];
          if (value['progress'] == 100 &&
              date is Timestamp &&
              WeeklyGoal.weekStart(date.toDate()) ==
                  WeeklyGoal.weekStart(now)) {
            ids.add(id);
          }
        }
      }
      saved = {
        'week': WeeklyGoal.weekStart(now),
        'target': 3,
        'completedIds': ids,
      };
    }
    return WeeklyGoal.advance(saved, now, lessonId);
  }

  static Future<void> syncWeeklyGoal(String uid) async {
    final document = FirebaseFirestore.instance.collection('users').doc(uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final stats = LearningStats(snapshot.data());
      transaction.set(document, {
        'metaSemanal': weeklyGoal(snapshot.data()).toMap(),
        if (stats.bestScores.isNotEmpty)
          'resultadosQuizzes': {
            for (final entry in stats.bestScores.entries)
              entry.key: {
                'bestScore': entry.value,
                'attempts': stats.attempts[entry.key],
              },
          },
      }, SetOptions(merge: true));
    });
  }

  static Set<int> completedLessons(Map<String, dynamic>? data) {
    final lessons = data?['progressoAulas'];
    if (lessons is! Map) return {};
    return decode(data).entries
        .where(
          (entry) =>
              entry.key >= 1 &&
              entry.key <= firstAidVideos.length &&
              entry.value == 100,
        )
        .map((entry) => entry.key)
        .toSet();
  }

  static Stream<Set<int>> watchCompleted() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value({});
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => completedLessons(snapshot.data()));
  }

  static Future<void> complete(String uid, int id) async {
    final firestore = FirebaseFirestore.instance;
    final document = firestore.collection('users').doc(uid);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      if ((decode(snapshot.data())[id] ?? 0) < 100) {
        throw StateError('Assista ao vídeo inteiro antes de concluir.');
      }
      transaction.set(document, {
        'progressoAulas': {
          '$id': {
            'completed': true,
            'completedAt': FieldValue.serverTimestamp(),
          },
        },
      }, SetOptions(merge: true));
    });
  }

  static Map<int, int> decode(Map<String, dynamic>? data) {
    final lessons = data?['progressoAulas'];
    if (lessons is! Map) return {};
    final result = <int, int>{};
    for (final entry in lessons.entries) {
      final id = int.tryParse(entry.key.toString());
      final value = entry.value is Map ? entry.value['progress'] : entry.value;
      if (id != null && value is num && value.isFinite) {
        result[id] = value.round().clamp(0, 100);
      }
    }
    return result;
  }

  static int? lastAccessedLessonId(Map<String, dynamic>? data) {
    final id = int.tryParse('${data?['ultimaAulaId']}');
    if (id == null || id < 1 || id > firstAidVideos.length) return null;
    return id;
  }

  static Future<void> setLastAccessed(String uid, int id) {
    return FirebaseFirestore.instance.collection('users').doc(uid).set({
      'ultimaAulaId': id,
    }, SetOptions(merge: true));
  }

  static Stream<Map<int, int>> watch() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value({});
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => decode(snapshot.data()));
  }

  static Future<void> save(String uid, int id, int progress) async {
    final firestore = FirebaseFirestore.instance;
    final document = firestore.collection('users').doc(uid);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final saved = decode(snapshot.data())[id] ?? 0;
      final next = progress.clamp(saved, 100);
      transaction.set(document, {
        'ultimaAulaId': id,
        if (next == 100) 'metaSemanal': weeklyGoal(snapshot.data(), id).toMap(),
        'progressoAulas': {
          '$id': {
            'progress': next,
            'completed': next == 100,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        },
      }, SetOptions(merge: true));
    });
  }
}
