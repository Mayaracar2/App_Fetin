import 'dart:math' as math;
import 'first_aid_videos.dart';
import 'video_quizzes.dart';

// Rules mirrored from S.O.P.S.-Fetin-project-2026 at d30e8ef:
// frontend/src/data/learningProgress.js and weeklyGoal.js.

class LearningStats {
  LearningStats(Map<String, dynamic>? data) {
    final current = data?['resultadosQuizzes'];
    final legacy = data?['quizVideos'];
    for (final entry in firstAidVideos.asMap().entries) {
      final key = entry.value.youtubeId;
      final total = videoQuizzes[key]!.length;
      final candidates = [
        if (current is Map) current[key],
        if (legacy is Map) legacy['${entry.key + 1}'],
      ];
      for (final result in candidates) {
        if (result is! Map) continue;
        final score = result['bestScore'];
        if (score is! int || score < 0 || score > total) continue;
        bestScores[key] = math.max(bestScores[key] ?? 0, score);
        final count = result['attempts'];
        attempts[key] = math.max(
          attempts[key] ?? 0,
          count is int && count > 0 ? count : 1,
        );
      }
    }
  }
  final bestScores = <String, int>{};
  final attempts = <String, int>{};
  int get xp => bestScores.values.fold(0, (sum, score) => sum + score * 20);
  int get maxXp => firstAidVideos.fold(
    0,
    (sum, video) => sum + videoQuizzes[video.youtubeId]!.length * 20,
  );
  int get maxLevel => (maxXp / 100).ceil();
  int get level => math.min(maxLevel, xp ~/ 100 + 1);
  int get xpToNextLevel => xp == maxXp ? 0 : level * 100 - xp;
  int get medals => bestScores.entries
      .where((entry) => entry.value / videoQuizzes[entry.key]!.length >= .8)
      .length;
}

// Same calendar and adaptive target as the reference site's weeklyGoal.js.
class WeeklyGoal {
  const WeeklyGoal(this.week, this.target, this.completedIds);
  final String week;
  final int target;
  final Set<int> completedIds;

  static String weekStart(DateTime now) {
    final brazil = now.toUtc().subtract(const Duration(hours: 3));
    final day = DateTime.utc(brazil.year, brazil.month, brazil.day);
    return day
        .subtract(Duration(days: day.weekday - 1))
        .toIso8601String()
        .substring(0, 10);
  }

  static WeeklyGoal advance(dynamic saved, DateTime now, [int? lessonId]) {
    final week = weekStart(now);
    final valid =
        saved is Map &&
        saved['week'] is String &&
        DateTime.tryParse(saved['week']) != null &&
        saved['target'] is int &&
        saved['target'] >= 1 &&
        saved['target'] <= 5;
    var target = valid ? saved['target'] as int : 3;
    var ids = valid && saved['completedIds'] is List
        ? (saved['completedIds'] as List).whereType<int>().toSet()
        : <int>{};
    if (valid && saved['week'] != week) {
      final elapsed = math.max(
        1,
        DateTime.parse(week).difference(DateTime.parse(saved['week'])).inDays ~/
            7,
      );
      target = (target + (ids.length >= target ? 1 : -1)).clamp(1, 5);
      target = math.max(1, target - elapsed + 1);
      ids = {};
    }
    if (lessonId != null) ids.add(lessonId);
    return WeeklyGoal(week, target, ids);
  }

  Map<String, dynamic> toMap() => {
    'week': week,
    'target': target,
    'completedIds': completedIds.toList(),
  };
}
