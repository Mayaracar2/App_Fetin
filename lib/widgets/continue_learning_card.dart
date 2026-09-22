import '../l10n/localized_text.dart';
import 'package:flutter/material.dart';
import '../data/first_aid_videos.dart';
import '../services/learning_progress_service.dart';
import '../screens/video_player_screen.dart';
import 'learning_ui.dart';

class ContinueLearningCard extends StatefulWidget {
  const ContinueLearningCard({super.key});
  @override
  State<ContinueLearningCard> createState() => _ContinueLearningCardState();
}

class _ContinueLearningCardState extends State<ContinueLearningCard> {
  late final _stream = LearningProgressService.watchData();
  @override
  Widget build(BuildContext context) => StreamBuilder<Map<String, dynamic>?>(
    stream: _stream,
    builder: (context, snapshot) {
      final progress = LearningProgressService.decode(snapshot.data);
      final lastId = LearningProgressService.lastAccessedLessonId(
        snapshot.data,
      );
      final next = lastId == null ? null : firstAidVideos[lastId - 1];
      final percentage = lastId == null ? 0 : progress[lastId] ?? 0;
      return LearningPanel(
        tint: learningBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LearningHeading(
              'Continuar aprendendo',
              icon: Icons.play_circle_outline,
            ),
            const SizedBox(height: 14),
            if (snapshot.hasError)
              const LocalizedText('Não foi possível carregar sua última aula.')
            else if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator()
            else if (next == null)
              LocalizedText(
                'Escolha um vídeo abaixo para começar uma nova aula.',
                style: TextStyle(color: learningMuted(context), fontSize: 13),
              )
            else ...[
              LocalizedText(
                next.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              LocalizedText(
                '$percentage% assistido · ${next.duration}',
                style: TextStyle(color: learningMuted(context), fontSize: 12),
              ),
              const SizedBox(height: 14),
              LearningAction(
                label: 'Continuar aula',
                icon: Icons.play_arrow_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => VideoPlayerScreen(
                      video: next,
                      resumeProgress: percentage < 100 ? percentage : 0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
