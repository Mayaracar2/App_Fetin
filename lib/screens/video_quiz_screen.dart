import '../l10n/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/first_aid_videos.dart';
import '../data/video_quizzes.dart';
import '../data/learning_stats.dart';
import '../services/learning_progress_service.dart';
import '../widgets/section_app_bar.dart';
import '../widgets/learning_ui.dart';
import 'video_player_screen.dart';
import 'learning_journey_screen.dart';

class VideoQuizScreen extends StatefulWidget {
  const VideoQuizScreen({super.key, required this.video});
  final FirstAidVideo video;
  @override
  State<VideoQuizScreen> createState() => _VideoQuizScreenState();
}

class _VideoQuizScreenState extends State<VideoQuizScreen> {
  late final questions = videoQuizzes[widget.video.youtubeId]!;
  late final answers = List<int?>.filled(questions.length, null);
  late final confirmed = List<bool>.filled(questions.length, false);
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toTop() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  int index = 0;
  bool saving = false, finished = false;
  String? error;
  int get score => List.generate(
    questions.length,
    (i) => i,
  ).where((i) => answers[i] == questions[i].answer).length;

  Future<void> finish() async {
    if (saving || uid == null || answers.contains(null)) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final document = FirebaseFirestore.instance.collection('users').doc(uid);
      final id = firstAidVideos.indexOf(widget.video) + 1;
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(document);
        if (!LearningProgressService.completedLessons(
          snapshot.data(),
        ).contains(id)) {
          throw StateError('Aula ainda não concluída.');
        }
        final stats = LearningStats(snapshot.data());
        final best = stats.bestScores[widget.video.youtubeId] ?? 0;
        final attempts = stats.attempts[widget.video.youtubeId] ?? 0;
        transaction.set(document, {
          'resultadosQuizzes': {
            widget.video.youtubeId: {
              'bestScore': score > best ? score : best,
              'attempts': attempts + 1,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          },
          'quizVideos': {
            '$id': {
              'youtubeId': widget.video.youtubeId,
              'score': score,
              'total': questions.length,
              'bestScore': score > best ? score : best,
              'attempts': attempts + 1,
              'answers': answers,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          },
        }, SetOptions(merge: true));
      });
      if (mounted) setState(() => finished = true);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Não foi possível salvar. Confirme a conclusão da aula e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: sectionAppBar('Quiz da aula'),
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
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LearningHeading(
                    finished
                        ? 'Mais um passo na sua jornada'
                        : 'Hora de praticar',
                    subtitle: widget.video.title,
                    icon: Icons.quiz_outlined,
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: saving
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  VideoPlayerScreen(video: widget.video),
                            ),
                          ),
                    icon: const Icon(Icons.play_circle_outline, size: 19),
                    label: const LocalizedText('Revisar vídeo'),
                  ),
                  const SizedBox(height: 16),
                  if (finished) _result() else _question(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _question() => LearningPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LocalizedText(
                'PERGUNTA ${index + 1} DE ${questions.length}',
                style: const TextStyle(
                  color: learningBlue,
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            LocalizedText(
              '${((index + 1) / questions.length * 100).round()}%',
              style: TextStyle(fontSize: 12, color: learningMuted(context)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (index + 1) / questions.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 26),
        LocalizedText(
          questions[index].text,
          style: const TextStyle(
            fontSize: 21,
            height: 1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        LocalizedText(
          'Selecione uma alternativa e confirme sua resposta.',
          style: TextStyle(
            color: learningMuted(context),
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        for (var option = 0; option < questions[index].options.length; option++)
          _option(option),
        if (confirmed[index]) ...[
          const SizedBox(height: 8),
          LearningPanel(
            padding: 14,
            tint: answers[index] == questions[index].answer
                ? learningGreen
                : const Color(0xFFC84C55),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  answers[index] == questions[index].answer
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: answers[index] == questions[index].answer
                      ? learningGreen
                      : const Color(0xFFC84C55),
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LocalizedText(
                        answers[index] == questions[index].answer
                            ? 'Muito bem! Resposta correta.'
                            : 'Vamos aprender com esta resposta.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      LocalizedText(
                        'Gabarito: ${questions[index].options[questions[index].answer]}',
                        style: const TextStyle(fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: LocalizedText(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 24),
        LearningAction(
          label: saving
              ? 'Salvando...'
              : !confirmed[index]
              ? 'Confirmar resposta'
              : index == questions.length - 1
              ? 'Ver resultado'
              : 'Próxima pergunta',
          icon: saving
              ? Icons.hourglass_top
              : confirmed[index]
              ? Icons.arrow_forward_rounded
              : Icons.check_rounded,
          onPressed: saving || answers[index] == null
              ? null
              : () {
                  if (!confirmed[index]) {
                    setState(() => confirmed[index] = true);
                  } else if (index == questions.length - 1) {
                    finish().then((_) {
                      if (mounted && finished) _toTop();
                    });
                  } else {
                    setState(() => index++);
                    _toTop();
                  }
                },
        ),
        if (index > 0)
          Center(
            child: TextButton.icon(
              onPressed: saving
                  ? null
                  : () {
                      setState(() => index--);
                      _toTop();
                    },
              icon: const Icon(Icons.arrow_back, size: 17),
              label: const LocalizedText('Pergunta anterior'),
            ),
          ),
      ],
    ),
  );

  Widget _option(int option) {
    final selected = answers[index] == option;
    final revealed = confirmed[index];
    final correct = option == questions[index].answer;
    final color = revealed && correct
        ? learningGreen
        : revealed && selected
        ? const Color(0xFFC84C55)
        : learningBlue;
    final highlighted = selected || (revealed && correct);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: saving || revealed
                ? null
                : () => setState(() => answers[index] = option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: highlighted
                    ? color.withValues(alpha: .09)
                    : (dark
                          ? const Color(0xFF0B2030)
                          : const Color(0xFFF8FBFD)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: highlighted
                      ? color
                      : (dark
                            ? const Color(0xFF294E6B)
                            : const Color(0xFFD7E5EB)),
                  width: highlighted ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 29,
                    height: 29,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: highlighted ? color : color.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: revealed && (selected || correct)
                        ? Icon(
                            correct ? Icons.check : Icons.close,
                            size: 18,
                            color: Colors.white,
                          )
                        : LocalizedText(
                            String.fromCharCode(65 + option),
                            style: TextStyle(
                              color: highlighted ? Colors.white : color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: LocalizedText(
                        questions[index].options[option],
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _result() => Column(
    children: [
      LearningPanel(
        child: Column(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: learningGold.withValues(alpha: .12),
              child: Icon(
                score / questions.length >= .8
                    ? Icons.workspace_premium
                    : Icons.school_outlined,
                color: learningGold,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            LocalizedText(
              '$score de ${questions.length}',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: learningBlue,
              ),
            ),
            LocalizedText(
              'respostas corretas',
              style: TextStyle(color: learningMuted(context), fontSize: 13),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(
                  label: LocalizedText(
                    '${(score / questions.length * 100).round()}% de acertos',
                  ),
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                ),
                Chip(
                  label: LocalizedText('${score * 20} XP nesta tentativa'),
                  avatar: const Icon(Icons.auto_awesome, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LocalizedText(
              score / questions.length >= .8
                  ? 'Você conquistou a medalha!'
                  : 'Continue praticando para conquistar sua medalha.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            LocalizedText(
              'Resultado salvo. Apenas sua melhor tentativa conta no total de XP.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: learningMuted(context),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            LearningAction(
              label: 'Meu progresso',
              icon: Icons.insights_outlined,
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const LearningJourneyScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            LearningAction(
              label: 'Refazer quiz',
              icon: Icons.refresh_rounded,
              onPressed: () {
                setState(() {
                  answers.fillRange(0, answers.length, null);
                  confirmed.fillRange(0, confirmed.length, false);
                  index = 0;
                  finished = false;
                });
                _toTop();
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      LearningPanel(
        padding: 8,
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          leading: const Icon(Icons.fact_check_outlined, color: learningBlue),
          title: const LocalizedText(
            'Revisar minhas respostas',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          children: [
            for (var i = 0; i < questions.length; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          answers[i] == questions[i].answer
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          color: answers[i] == questions[i].answer
                              ? learningGreen
                              : const Color(0xFFC84C55),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: LocalizedText(
                            questions[i].text,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LocalizedText(
                      'Sua resposta: ${questions[i].options[answers[i]!]}'
                      '\nGabarito: ${questions[i].options[questions[i].answer]}',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: learningMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
