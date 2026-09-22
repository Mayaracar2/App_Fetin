import '../l10n/localized_text.dart';
import 'package:flutter/material.dart';
import '../data/first_aid_videos.dart';
import '../data/video_quizzes.dart';
import '../data/learning_stats.dart';
import '../services/learning_progress_service.dart';
import '../screens/video_quiz_screen.dart';
import 'learning_ui.dart';

class VideoQuizProgress extends StatefulWidget {
  const VideoQuizProgress({super.key});
  @override
  State<VideoQuizProgress> createState() => _VideoQuizProgressState();
}

class _VideoQuizProgressState extends State<VideoQuizProgress> {
  late final stream = LearningProgressService.watchData();
  @override
  Widget build(BuildContext context) => StreamBuilder<Map<String, dynamic>?>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const LocalizedText('Não foi possível carregar os quizzes.');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      final completed = LearningProgressService.completedLessons(snapshot.data);
      final stats = LearningStats(snapshot.data);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LearningHeading(
            'Trilha de medalhas',
            icon: Icons.workspace_premium_outlined,
            subtitle:
                'Conclua a aula e acerte 4 de 5 perguntas para conquistar sua medalha.',
          ),
          const SizedBox(height: 18),
          for (var start = 0; start < firstAidVideos.length; start += 5)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LearningPanel(
                padding: 4,
                child: ExpansionTile(
                  key: PageStorageKey('medal-stage-$start'),
                  initiallyExpanded: start == 0,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: learningBlue.withValues(alpha: .08),
                    child: LocalizedText(
                      '${start ~/ 5 + 1}',
                      style: const TextStyle(
                        color: learningBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  title: LocalizedText(
                    firstAidVideos[start].category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: LocalizedText(
                    'Etapa ${start ~/ 5 + 1} · ${List.generate(5, (i) => start + i).where((i) => completed.contains(i + 1)).length}/5 quizzes liberados',
                    style: TextStyle(
                      color: learningMuted(context),
                      fontSize: 11,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 900
                            ? 3
                            : constraints.maxWidth >= 540
                            ? 2
                            : 1;
                        final width =
                            (constraints.maxWidth - (columns - 1) * 12) /
                            columns;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (
                              var i = start;
                              i < start + 5 && i < firstAidVideos.length;
                              i++
                            )
                              SizedBox(
                                width: width,
                                child: _quiz(context, i, completed, stats),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
  Widget _quiz(
    BuildContext context,
    int index,
    Set<int> completed,
    LearningStats stats,
  ) {
    final video = firstAidVideos[index];
    final unlocked = completed.contains(index + 1);
    final score = stats.bestScores[video.youtubeId];
    final total = videoQuizzes[video.youtubeId]!.length;
    final earned = score != null && score / total >= .8;
    final color = earned
        ? learningGold
        : unlocked
        ? learningBlue
        : learningMuted(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: !unlocked
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => VideoQuizScreen(video: video),
                ),
              ),
        child: LearningPanel(
          padding: 16,
          tint: earned ? learningGold : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    !unlocked
                        ? Icons.lock_outline
                        : earned
                        ? Icons.workspace_premium
                        : Icons.quiz_outlined,
                    color: color,
                    size: 23,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LocalizedText(
                      earned
                          ? 'Medalha conquistada'
                          : unlocked
                          ? 'Disponível para você'
                          : 'Quiz bloqueado',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LocalizedText(
                video.title,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              LocalizedText(
                score != null
                    ? 'Melhor: $score/$total · ${score * 20} XP'
                    : '$total perguntas · até ${total * 20} XP',
                style: TextStyle(fontSize: 12, color: learningMuted(context)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: LocalizedText(
                      !unlocked
                          ? 'Conclua a aula para liberar'
                          : score != null
                          ? 'Refazer quiz'
                          : 'Iniciar quiz',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (unlocked)
                    Icon(Icons.arrow_forward_rounded, color: color, size: 17),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
