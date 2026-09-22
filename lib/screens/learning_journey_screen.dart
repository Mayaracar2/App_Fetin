import '../l10n/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/section_app_bar.dart';
import '../widgets/learning_ui.dart';
import '../widgets/video_quiz_progress.dart';
import '../data/first_aid_videos.dart';
import '../data/learning_stats.dart';
import '../services/learning_progress_service.dart';
import 'video_player_screen.dart';

class LearningJourneyScreen extends StatefulWidget {
  const LearningJourneyScreen({super.key});
  @override
  State<LearningJourneyScreen> createState() => _LearningJourneyScreenState();
}

class _LearningJourneyScreenState extends State<LearningJourneyScreen> {
  final _scroll = ScrollController();
  late final _stream = LearningProgressService.watchData();
  String? _error;
  @override
  void initState() {
    super.initState();
    _sync();
  }

  Future<void> _sync() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await LearningProgressService.syncWeeklyGoal(uid);
      if (mounted) setState(() => _error = null);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível atualizar a meta.');
      }
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: sectionAppBar('Meu progresso'),
    body: SafeArea(
      top: false,
      child: Scrollbar(
        controller: _scroll,
        child: SingleChildScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: StreamBuilder<Map<String, dynamic>?>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const LocalizedText(
                      'Não foi possível carregar o progresso.',
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final data = snapshot.data;
                  final progress = LearningProgressService.decode(data);
                  final completed = LearningProgressService.completedLessons(
                    data,
                  );
                  final stats = LearningStats(data);
                  final goal = LearningProgressService.weeklyGoal(data);
                  final entries = firstAidVideos.asMap().entries;
                  final ongoing = entries
                      .where(
                        (e) =>
                            (progress[e.key + 1] ?? 0) > 0 &&
                            (progress[e.key + 1] ?? 0) < 100,
                      )
                      .toList();
                  final minutes =
                      (entries.fold<double>(0, (sum, e) {
                                final parts = e.value.duration
                                    .split(':')
                                    .map(int.parse)
                                    .toList();
                                return sum +
                                    (parts[0] * 60 + parts[1]) *
                                        (progress[e.key + 1] ?? 0) /
                                        100;
                              }) /
                              60)
                          .round();
                  final overview = [
                    (
                      '${(completed.length / firstAidVideos.length * 100).round()}%',
                      'Conclusão geral',
                      Icons.donut_large_rounded,
                      learningBlue,
                    ),
                    (
                      '${completed.length}/${firstAidVideos.length}',
                      'Aulas concluídas',
                      Icons.check_circle_outline,
                      learningGreen,
                    ),
                    (
                      '${stats.bestScores.length}',
                      'Quizzes realizados',
                      Icons.quiz_outlined,
                      learningBlue,
                    ),
                    (
                      '${stats.medals}',
                      'Medalhas conquistadas',
                      Icons.workspace_premium_outlined,
                      learningGold,
                    ),
                  ];
                  final journey = LearningPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LearningHeading(
                          'Sua jornada',
                          icon: Icons.auto_awesome_outlined,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: LocalizedText(
                                'Nível ${stats.level}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            LocalizedText(
                              '${stats.xp} / ${stats.maxXp} XP',
                              style: const TextStyle(
                                color: learningBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: stats.xp / stats.maxXp,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(height: 12),
                        LocalizedText(
                          stats.xp == stats.maxXp
                              ? 'Pontuação máxima alcançada!'
                              : 'Faltam ${stats.xpToNextLevel} XP para a próxima meta.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 7),
                        LocalizedText(
                          '20 XP por acerto. Vale a melhor tentativa de cada quiz.',
                          style: TextStyle(
                            fontSize: 12,
                            color: learningMuted(context),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                  final weekly = LearningPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LearningHeading(
                          'Meta semanal',
                          icon: Icons.flag_outlined,
                        ),
                        const SizedBox(height: 20),
                        LocalizedText(
                          '${goal.completedIds.length.clamp(0, goal.target)} de ${goal.target} aulas',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (goal.completedIds.length / goal.target).clamp(
                            0,
                            1,
                          ),
                          minHeight: 8,
                          color: learningGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(height: 12),
                        LocalizedText(
                          goal.completedIds.length >= goal.target
                              ? 'Meta cumprida. Continue assim!'
                              : 'Um vídeo de cada vez, no seu ritmo.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 7),
                        LocalizedText(
                          'Segunda a domingo · $minutes min estudados no total',
                          style: TextStyle(
                            fontSize: 12,
                            color: learningMuted(context),
                            height: 1.5,
                          ),
                        ),
                        if (_error != null)
                          TextButton(
                            onPressed: _sync,
                            child: LocalizedText('$_error Tentar novamente'),
                          ),
                      ],
                    ),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LearningHeading(
                        'Cada aula é um novo passo',
                        subtitle:
                            'Acompanhe sua evolução e continue de onde parou.',
                      ),
                      const SizedBox(height: 22),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final count = constraints.maxWidth >= 760 ? 4 : 2;
                          final width =
                              (constraints.maxWidth - 12 * (count - 1)) / count;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final item in overview)
                                SizedBox(
                                  width: width,
                                  child: LearningPanel(
                                    padding: 16,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(item.$3, color: item.$4, size: 23),
                                        const SizedBox(height: 12),
                                        LocalizedText(
                                          item.$1,
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        LocalizedText(
                                          item.$2,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: learningMuted(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 760
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: journey),
                                  const SizedBox(width: 16),
                                  Expanded(child: weekly),
                                ],
                              )
                            : Column(
                                children: [
                                  journey,
                                  const SizedBox(height: 16),
                                  weekly,
                                ],
                              ),
                      ),
                      const SizedBox(height: 20),
                      LearningPanel(
                        padding: 8,
                        child: Column(
                          children: [
                            _lessons('Em andamento', ongoing, progress, true),
                            const Divider(height: 1, indent: 12, endIndent: 12),
                            _lessons(
                              'Aulas concluídas',
                              entries
                                  .where((e) => completed.contains(e.key + 1))
                                  .toList(),
                              progress,
                              false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const VideoQuizProgress(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget _lessons(
    String title,
    List<MapEntry<int, FirstAidVideo>> entries,
    Map<int, int> progress,
    bool ongoing,
  ) => ExpansionTile(
    shape: const Border(),
    collapsedShape: const Border(),
    initiallyExpanded: ongoing && entries.isNotEmpty,
    leading: Icon(
      ongoing ? Icons.play_circle_outline : Icons.task_alt,
      color: ongoing ? learningBlue : learningGreen,
    ),
    title: LocalizedText(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    ),
    subtitle: LocalizedText(
      '${entries.length} aulas',
      style: const TextStyle(fontSize: 12),
    ),
    children: [
      if (entries.isEmpty)
        const Padding(
          padding: EdgeInsets.all(16),
          child: LocalizedText('Nenhuma aula por aqui ainda.'),
        ),
      for (final e in entries)
        ListTile(
          title: LocalizedText(
            e.value.title,
            style: const TextStyle(fontSize: 13),
          ),
          subtitle: LocalizedText(
            ongoing ? '${progress[e.key + 1]}% assistido' : 'Rever aula',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => VideoPlayerScreen(
                video: e.value,
                resumeProgress: ongoing ? progress[e.key + 1]! : 0,
              ),
            ),
          ),
        ),
    ],
  );
}
