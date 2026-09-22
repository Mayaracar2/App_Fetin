import 'package:flutter_test/flutter_test.dart';
import 'package:socorro_facil/data/first_aid_videos.dart';
import 'package:socorro_facil/data/learning_stats.dart';

void main() {
  final key = firstAidVideos.first.youtubeId;
  test('XP preserva melhor resultado entre site e app sem duplicação', () {
    final stats = LearningStats({
      'resultadosQuizzes': {
        key: {'bestScore': 3, 'attempts': 4},
      },
      'quizVideos': {
        '1': {'bestScore': 4, 'attempts': 2},
      },
    });
    expect(stats.xp, 80);
    expect(stats.medals, 1);
    expect(stats.bestScores.length, 1);
    expect(stats.attempts[key], 4);
    expect(stats.level, 1);
    expect(stats.xpToNextLevel, 20);
  });
  test('Resultados inválidos não concedem XP nem medalhas', () {
    final stats = LearningStats({
      'resultadosQuizzes': {
        key: {'bestScore': 6},
        firstAidVideos[1].youtubeId: {'bestScore': -1},
        firstAidVideos[2].youtubeId: {'bestScore': 2.5},
        'unknown': {'bestScore': 5},
      },
    });
    expect(stats.xp, 0);
    expect(stats.medals, 0);
    expect(stats.bestScores, isEmpty);
  });
  test('Jornada completa termina em 4000 XP e nível 40', () {
    final stats = LearningStats({
      'resultadosQuizzes': {
        for (final video in firstAidVideos) video.youtubeId: {'bestScore': 5},
      },
    });
    expect(stats.xp, 4000);
    expect(stats.maxXp, 4000);
    expect(stats.level, 40);
    expect(stats.medals, 40);
    expect(stats.xpToNextLevel, 0);
  });
  test('Meta respeita virada de segunda-feira em São Paulo', () {
    expect(
      WeeklyGoal.weekStart(DateTime.parse('2026-09-21T02:59:00Z')),
      '2026-09-14',
    );
    expect(
      WeeklyGoal.weekStart(DateTime.parse('2026-09-21T03:00:00Z')),
      '2026-09-21',
    );
  });
  test('Meta inicial e conclusão repetida não duplicam aulas', () {
    final now = DateTime.utc(2026, 9, 20, 12);
    final first = WeeklyGoal.advance(null, now, 1);
    final again = WeeklyGoal.advance(first.toMap(), now, 1);
    expect(again.target, 3);
    expect(again.completedIds, {1});
  });
  test('Meta cresce se cumprida e diminui após semanas sem atividade', () {
    final saved = {
      'week': '2026-09-14',
      'target': 3,
      'completedIds': [1, 2, 3],
    };
    expect(WeeklyGoal.advance(saved, DateTime.utc(2026, 9, 21, 12)).target, 4);
    expect(WeeklyGoal.advance(saved, DateTime.utc(2026, 10, 12, 12)).target, 1);
    expect(
      WeeklyGoal.advance({
        'week': '2026-09-14',
        'target': 3,
        'completedIds': [1],
      }, DateTime.utc(2026, 9, 21, 12)).target,
      2,
    );
    expect(
      WeeklyGoal.advance(saved, DateTime.utc(2026, 9, 21, 12)).completedIds,
      isEmpty,
    );
  });
  test('Meta permanece entre uma e cinco aulas', () {
    final now = DateTime.utc(2026, 9, 21, 12);
    expect(
      WeeklyGoal.advance({
        'week': '2026-09-14',
        'target': 5,
        'completedIds': [1, 2, 3, 4, 5],
      }, now).target,
      5,
    );
    expect(
      WeeklyGoal.advance({
        'week': '2026-09-14',
        'target': 1,
        'completedIds': [],
      }, now).target,
      1,
    );
  });
}
