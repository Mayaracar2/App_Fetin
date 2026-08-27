import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/learning_dashboard.dart';
import 'videos_screen.dart';

class LearningJourneyScreen extends StatefulWidget {
  const LearningJourneyScreen({super.key});

  @override
  State<LearningJourneyScreen> createState() => _LearningJourneyScreenState();
}

class _LearningJourneyScreenState extends State<LearningJourneyScreen> {
  static const _blue = Color(0xFF217BA5);
  static const _gold = Color(0xFFD99231);
  final Map<String, int> _stars = {};

  static const _activities = [
    _QuizActivity(
      id: 'engasgo',
      title: 'Engasgo: primeiros minutos',
      icon: Icons.air_rounded,
      color: Color(0xFF0D7797),
      questions: [
        _Question('Qual sinal deve ser observado primeiro?', [
          'Se a pessoa consegue tossir ou falar',
          'A temperatura',
          'A cor da roupa',
        ], 0),
        _Question('Se a pessoa ainda tosse com força, devemos:', [
          'Dar água',
          'Incentivar a tosse e observar',
          'Deitá-la',
        ], 1),
        _Question('Qual número acionar em uma emergência grave?', [
          '190',
          '192',
          '199',
        ], 1),
      ],
    ),
    _QuizActivity(
      id: 'kit_socorros',
      title: 'Kit de primeiros socorros',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF2A9876),
      questions: [
        _Question('Qual item deve fazer parte do kit?', [
          'Gaze estéril',
          'Medicamento vencido',
          'Objeto cortante solto',
        ], 0),
        _Question('Onde o kit deve ser guardado?', [
          'Em local úmido',
          'Ao alcance de crianças',
          'Em local seco e acessível para adultos',
        ], 2),
        _Question('Qual cuidado é importante?', [
          'Revisar a validade',
          'Misturar itens sem identificação',
          'Deixar o kit aberto',
        ], 0),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStars();
  }

  Future<void> _loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final activity in _activities) {
        _stars[activity.id] = prefs.getInt('video_quiz_${activity.id}') ?? 0;
      }
    });
  }

  Future<void> _openQuiz(_QuizActivity activity) async {
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _VideoQuizDialog(activity: activity),
    );
    if (result == null) return;
    final best = result > (_stars[activity.id] ?? 0)
        ? result
        : (_stars[activity.id] ?? 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('video_quiz_${activity.id}', best);
    if (!mounted) return;
    setState(() => _stars[activity.id] = best);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${activity.title}: $result de 3 estrelas!')),
    );
  }

  void _openLibrary() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const VideosScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? const Color(0xFF071522) : const Color(0xFFF3F8FA);
    final surface = dark ? const Color(0xFF102637) : Colors.white;
    final line = dark ? const Color(0xFF294E6B) : const Color(0xFFD7E5EB);
    final primary = dark ? const Color(0xFFE6F4FF) : const Color(0xFF183B50);
    final secondary = dark ? const Color(0xFF9AB9CD) : const Color(0xFF638092);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text('Minha jornada')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LearningDashboard(onOpenLibrary: _openLibrary),
                const SizedBox(height: 28),
                const Text(
                  'ATIVIDADES POR VÍDEO',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Teste o que aprendeu',
                  style: TextStyle(
                    color: primary,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Cada quiz corresponde a uma aula concluída. Sua melhor pontuação fica salva.',
                  style: TextStyle(color: secondary, fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                ..._activities.map(
                  (activity) => _activityCard(
                    activity,
                    surface,
                    line,
                    primary,
                    secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityCard(
    _QuizActivity activity,
    Color surface,
    Color line,
    Color primary,
    Color secondary,
  ) {
    final stars = _stars[activity.id] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: activity.color.withValues(alpha: .13),
            child: Icon(activity.icon, color: activity.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(color: primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '3 perguntas · Aula concluída',
                  style: TextStyle(color: secondary, fontSize: 11),
                ),
                const SizedBox(height: 7),
                Row(
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _gold,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _openQuiz(activity),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              backgroundColor: Colors.transparent,
              minimumSize: const Size(64, 40),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: const StadiumBorder(),
            ),
            child: Text(stars == 0 ? 'Fazer quiz' : 'Refazer'),
          ),
        ],
      ),
    );
  }
}

class _QuizActivity {
  const _QuizActivity({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final List<_Question> questions;
}

class _Question {
  const _Question(this.text, this.answers, this.correct);
  final String text;
  final List<String> answers;
  final int correct;
}

class _VideoQuizDialog extends StatefulWidget {
  const _VideoQuizDialog({required this.activity});
  final _QuizActivity activity;
  @override
  State<_VideoQuizDialog> createState() => _VideoQuizDialogState();
}

class _VideoQuizDialogState extends State<_VideoQuizDialog> {
  int _index = 0;
  int _score = 0;
  int? _selected;

  void _next() {
    final score =
        _score +
        (_selected == widget.activity.questions[_index].correct ? 1 : 0);
    if (_index == widget.activity.questions.length - 1) {
      Navigator.pop(context, score);
    } else {
      setState(() {
        _score = score;
        _index++;
        _selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.activity.questions[_index];
    return AlertDialog(
      title: Text('${widget.activity.title} · ${_index + 1}/3'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (_index + 1) / 3),
            const SizedBox(height: 18),
            Text(
              question.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              question.answers.length,
              (answer) => ListTile(
                onTap: () => setState(() => _selected = answer),
                leading: Icon(
                  _selected == answer
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _selected == answer ? const Color(0xFF217BA5) : null,
                ),
                title: Text(question.answers[answer]),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selected == null ? null : _next,
          child: Text(_index == 2 ? 'Concluir' : 'Próxima'),
        ),
      ],
    );
  }
}
