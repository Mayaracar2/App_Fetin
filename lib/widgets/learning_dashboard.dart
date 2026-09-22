import '../l10n/localized_text.dart';
import 'dart:async';
import '../data/first_aid_videos.dart';
import '../screens/video_player_screen.dart';
import '../services/learning_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningDashboard extends StatefulWidget {
  const LearningDashboard({super.key, required this.onOpenLibrary});

  final VoidCallback onOpenLibrary;

  @override
  State<LearningDashboard> createState() => _LearningDashboardState();
}

class _LearningDashboardState extends State<LearningDashboard> {
  static const _blue = Color(0xFF217BA5);
  static const _green = Color(0xFF2A9876);
  static const _gold = Color(0xFFD99231);
  Map<int, int> _progress = {};
  Set<int> _completedIds = {};
  StreamSubscription<Set<int>>? _completedSubscription;
  StreamSubscription<Map<String, dynamic>?>? _subscription;
  int? _lastLessonId;
  int get _completed => _completedIds.length;
  int get _minutes =>
      (firstAidVideos.asMap().entries.fold<double>(0, (sum, entry) {
                final parts = entry.value.duration.split(':');
                return sum +
                    (int.parse(parts[0]) * 60 + int.parse(parts[1])) *
                        (_progress[entry.key + 1] ?? 0) /
                        100;
              }) /
              60)
          .round();
  @override
  void dispose() {
    _completedSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  int _bestStars = 0;
  int _quizzesCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
    _completedSubscription = LearningProgressService.watchCompleted().listen((
      ids,
    ) {
      if (mounted) setState(() => _completedIds = ids);
    }, onError: (Object error) {});
    _subscription = LearningProgressService.watchData().listen(
      (data) {
        if (!mounted) return;
        setState(() {
          _progress = LearningProgressService.decode(data);
          _lastLessonId = LearningProgressService.lastAccessedLessonId(data);
        });
      },
      onError: (Object error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: LocalizedText('Falha ao carregar progresso.'),
            ),
          );
        }
      },
    );
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bestStars = prefs.getInt('learning_quiz_best_stars') ?? 0;
      _quizzesCompleted = prefs.getInt('learning_quizzes_completed') ?? 0;
    });
  }

  Future<void> _startQuiz() async {
    final stars = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LearningQuizDialog(),
    );
    if (stars == null) return;
    final prefs = await SharedPreferences.getInstance();
    final best = stars > _bestStars ? stars : _bestStars;
    final completed = _quizzesCompleted + 1;
    await prefs.setInt('learning_quiz_best_stars', best);
    await prefs.setInt('learning_quizzes_completed', completed);
    if (!mounted) return;
    setState(() {
      _bestStars = best;
      _quizzesCompleted = completed;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: LocalizedText(
          'Quiz concluído: $stars de 3 ${stars == 1 ? 'estrela' : 'estrelas'}!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF102637) : Colors.white;
    final line = dark ? const Color(0xFF294E6B) : const Color(0xFFD7E5EB);
    final primary = dark ? const Color(0xFFE6F4FF) : const Color(0xFF183B50);
    final secondary = dark ? const Color(0xFF9AB9CD) : const Color(0xFF638092);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocalizedText(
                    'MINHA JORNADA',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  LocalizedText(
                    'Seu aprendizado em um só lugar',
                    style: TextStyle(
                      color: primary,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: widget.onOpenLibrary,
              icon: const Icon(Icons.video_library_outlined, size: 18),
              label: const LocalizedText('Ver biblioteca'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _progressCard(surface, line, primary, secondary),
      ],
    );
  }

  Widget _progressCard(
    Color surface,
    Color line,
    Color primary,
    Color secondary,
  ) {
    final video = _lastLessonId == null
        ? null
        : firstAidVideos[_lastLessonId! - 1];
    final videoProgress = video == null ? 0 : _progress[_lastLessonId!] ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _decoration(surface, line),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _summary(
                Icons.check_circle_outline,
                _green,
                '$_completed de ${firstAidVideos.length}',
                'concluídas',
                primary,
                secondary,
              ),
              const SizedBox(width: 12),
              _summary(
                Icons.schedule,
                _blue,
                '$_minutes min',
                'estudados',
                primary,
                secondary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          LocalizedText(
            'Aulas que você concluiu',
            style: TextStyle(color: primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 11),
          if (_completed == 0)
            const LocalizedText('Nenhuma aula concluída ainda.'),
          for (final entry in firstAidVideos.asMap().entries)
            if (_completedIds.contains(entry.key + 1))
              _completedLesson(
                entry.value.title,
                entry.value.duration,
                primary,
                secondary,
              ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _blue.withValues(alpha: .25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.play_circle_outline,
                      color: _blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LocalizedText(
                        'Em progresso',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    LocalizedText(
                      '$videoProgress%',
                      style: TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                LocalizedText(
                  video?.title ?? 'Escolha uma aula para começar.',
                  style: TextStyle(color: primary, fontSize: 13),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: videoProgress / 100,
                  minHeight: 6,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: video == null
                        ? widget.onOpenLibrary
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => VideoPlayerScreen(
                                video: video,
                                resumeProgress: videoProgress < 100
                                    ? videoProgress
                                    : 0,
                              ),
                            ),
                          ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const LocalizedText('Continuar aula'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mantido isolado para não afetar a lógica existente de quiz e conquistas.
  // ignore: unused_element
  Widget _goalsCard(Color surface, Color line, Color primary, Color secondary) {
    final quizUnlocked = _bestStars > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _decoration(surface, line),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: _gold),
              const SizedBox(width: 8),
              LocalizedText(
                'Meta semanal',
                style: TextStyle(color: primary, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              LocalizedText(
                '2/3 aulas',
                style: TextStyle(color: _green, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const LinearProgressIndicator(
            value: 2 / 3,
            color: _green,
            minHeight: 7,
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          const SizedBox(height: 7),
          LocalizedText(
            'Falta apenas uma aula para cumprir sua meta.',
            style: TextStyle(color: secondary, fontSize: 11.5),
          ),
          const SizedBox(height: 20),
          LocalizedText(
            'Desafio das aulas concluídas',
            style: TextStyle(color: primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          LocalizedText(
            'Responda ao quiz e conquiste até 3 estrelas.',
            style: TextStyle(color: secondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  index < _bestStars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: _gold,
                  size: 25,
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _startQuiz,
              icon: const Icon(Icons.quiz_outlined),
              label: LocalizedText(
                _quizzesCompleted == 0 ? 'Começar quiz' : 'Refazer quiz',
              ),
            ),
          ),
          const SizedBox(height: 18),
          LocalizedText(
            'Suas medalhas',
            style: TextStyle(color: primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _medal(
                Icons.play_lesson_outlined,
                'Primeiros passos',
                true,
                primary,
                secondary,
              ),
              _medal(
                Icons.psychology_outlined,
                'Mente afiada',
                quizUnlocked,
                primary,
                secondary,
              ),
              _medal(
                Icons.local_fire_department_outlined,
                '3 dias seguidos',
                false,
                primary,
                secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summary(
    IconData icon,
    Color color,
    String value,
    String label,
    Color primary,
    Color secondary,
  ) => Expanded(
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocalizedText(
                value,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              LocalizedText(
                label,
                style: TextStyle(color: secondary, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _completedLesson(
    String title,
    String duration,
    Color primary,
    Color secondary,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: _green, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: LocalizedText(
            title,
            style: TextStyle(color: primary, fontSize: 12.5),
          ),
        ),
        LocalizedText(
          duration,
          style: TextStyle(color: secondary, fontSize: 10.5),
        ),
      ],
    ),
  );

  Widget _medal(
    IconData icon,
    String label,
    bool unlocked,
    Color primary,
    Color secondary,
  ) => Container(
    width: 104,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    decoration: BoxDecoration(
      color: unlocked
          ? _gold.withValues(alpha: .10)
          : secondary.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: unlocked
            ? _gold.withValues(alpha: .35)
            : secondary.withValues(alpha: .15),
      ),
    ),
    child: Column(
      children: [
        Icon(
          unlocked ? icon : Icons.lock_outline_rounded,
          color: unlocked ? _gold : secondary,
          size: 25,
        ),
        const SizedBox(height: 6),
        LocalizedText(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: unlocked ? primary : secondary,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  BoxDecoration _decoration(Color surface, Color line) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: line),
  );
}

class _LearningQuizDialog extends StatefulWidget {
  const _LearningQuizDialog();

  @override
  State<_LearningQuizDialog> createState() => _LearningQuizDialogState();
}

class _LearningQuizDialogState extends State<_LearningQuizDialog> {
  static const _questions = [
    (
      'Ao ajudar uma pessoa engasgada e consciente, o que deve ser avaliado primeiro?',
      [
        'Se ela consegue tossir ou falar',
        'A temperatura corporal',
        'Se está com sede',
      ],
      0,
    ),
    (
      'Qual item é apropriado em um kit de primeiros socorros?',
      ['Antibiótico sem receita', 'Gaze estéril', 'Alimento energético'],
      1,
    ),
    (
      'Após acionar ajuda em uma emergência, qual atitude é mais segura?',
      [
        'Abandonar o local',
        'Oferecer qualquer remédio',
        'Acompanhar a vítima e seguir as orientações',
      ],
      2,
    ),
  ];
  int _index = 0;
  int _correct = 0;
  int? _selected;

  void _next() {
    if (_selected == null) return;
    if (_selected == _questions[_index].$3) _correct++;
    if (_index == _questions.length - 1) {
      Navigator.pop(context, _correct);
    } else {
      setState(() {
        _index++;
        _selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    return AlertDialog(
      title: LocalizedText('Quiz rápido · ${_index + 1}/${_questions.length}'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (_index + 1) / _questions.length),
            const SizedBox(height: 18),
            LocalizedText(
              question.$1,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...List.generate(question.$2.length, (answer) {
              final selected = _selected == answer;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selected = answer),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: .10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: LocalizedText(question.$2[answer])),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const LocalizedText('Cancelar'),
        ),
        FilledButton(
          onPressed: _selected == null ? null : _next,
          child: LocalizedText(
            _index == _questions.length - 1 ? 'Concluir' : 'Próxima',
          ),
        ),
      ],
    );
  }
}
