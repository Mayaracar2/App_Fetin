import '../l10n/localized_text.dart';
import '../l10n/language_controller.dart';
import 'dart:async';
import 'video_quiz_screen.dart';
import '../widgets/learning_ui.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/learning_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../data/first_aid_videos.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.resumeProgress = 0,
  });

  final FirstAidVideo video;
  final int resumeProgress;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  late final YoutubePlayerController _controller;

  Timer? _timer;
  StreamSubscription<Map<int, int>>? _progressSubscription;
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  int _progress = 0, _saved = 0;
  bool _polling = false;
  bool _completed = false, _completing = false;
  StreamSubscription<Set<int>>? _completedSubscription;

  Future<void> _complete() async {
    if (_uid == null || _completing) return;
    setState(() => _completing = true);
    try {
      await LearningProgressService.save(_uid, _lessonId, 100);
      await LearningProgressService.complete(_uid, _lessonId);
      if (mounted) {
        setState(() {
          _completed = true;
          _progress = 100;
          _saved = 100;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Falha ao confirmar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  double get _resumeSeconds {
    final parts = widget.video.duration.split(':').map(int.parse).toList();
    return (parts[0] * 60 + parts[1]) *
        widget.resumeProgress.clamp(0, 99) /
        100;
  }

  String? _error;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  int get _lessonId => firstAidVideos.indexOf(widget.video) + 1;

  void _report(int value, {bool force = false, bool playbackEnded = false}) {
    _progress = math.max(_progress, value);
    if (mounted) setState(() {});
    if (_uid == null ||
        (_progress <= _saved && !playbackEnded) ||
        (!force && _progress < 100 && _progress - _saved < 5)) {
      return;
    }
    final previous = _saved;
    _saved = _progress;
    LearningProgressService.save(_uid, _lessonId, _progress)
        .then((_) {
          if (mounted) setState(() => _error = null);
        })
        .catchError((Object error) {
          _saved = previous;
          if (mounted) {
            setState(
              () => _error = 'Falha ao salvar. Toque em tentar novamente.',
            );
          }
        });
  }

  Future<void> _sample() async {
    if (_polling) return;
    _polling = true;
    try {
      final duration = await _controller.duration;
      final position = await _controller.currentTime;
      if (mounted && duration > 0) {
        _report((position / duration * 100).floor().clamp(0, 99));
      }
    } catch (_) {
      // The player may still be loading or already closing.
    } finally {
      _polling = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_uid != null) {
      unawaited(
        LearningProgressService.setLastAccessed(
          _uid,
          _lessonId,
        ).catchError((Object _) {}),
      );
    }
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeId,
      autoPlay: true,
      startSeconds: _resumeSeconds,
      params: YoutubePlayerParams(
        showFullscreenButton: true,
        interfaceLanguage: LanguageController.locale.value.languageCode,
        captionLanguage: LanguageController.locale.value.languageCode,
      ),
    );
    _progressSubscription = LearningProgressService.watch().listen(
      (values) {
        if (!mounted) return;
        setState(() {
          _progress = math.max(_progress, values[_lessonId] ?? 0);
          _saved = math.max(_saved, values[_lessonId] ?? 0);
        });
      },
      onError: (Object error) {
        if (mounted) setState(() => _error = 'Falha ao carregar o progresso.');
      },
    );
    _completedSubscription = LearningProgressService.watchCompleted().listen(
      (ids) {
        if (mounted) setState(() => _completed = ids.contains(_lessonId));
      },
      onError: (Object error) {
        if (mounted) setState(() => _error = 'Falha ao carregar a conclusao.');
      },
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _sample());
    _playerSubscription = _controller.stream.listen((value) {
      if (value.playerState == PlayerState.ended) {
        _report(100, force: true, playbackEnded: true);
      }
      if (value.playerState == PlayerState.paused) {
        _report(_progress, force: true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _controller.pauseVideo();
    }
  }

  @override
  void dispose() {
    _completedSubscription?.cancel();
    _timer?.cancel();
    _progressSubscription?.cancel();
    _playerSubscription?.cancel();
    if (_uid != null && _progress > _saved) {
      unawaited(
        LearningProgressService.save(
          _uid,
          _lessonId,
          _progress,
        ).catchError((Object _) {}),
      );
    }
    WidgetsBinding.instance.removeObserver(this);
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const LocalizedText('Treinamento')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 140),
        children: [
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(
                  '${widget.video.category} · ${widget.video.duration} · ${widget.video.level}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                LocalizedText(
                  widget.video.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LocalizedText('Progresso'),
                    LocalizedText('$_progress%'),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: _progress / 100, minHeight: 8),
                const SizedBox(height: 20),
                LearningAction(
                  label: _completing
                      ? 'Salvando...'
                      : _completed
                      ? 'Concluído'
                      : 'Marcar como concluído',
                  icon: Icons.check_circle_outline,
                  onPressed:
                      _uid == null ||
                          _completed ||
                          _completing ||
                          _progress < 100
                      ? null
                      : _complete,
                ),
                const SizedBox(height: 10),
                LearningAction(
                  label: _lessonId < firstAidVideos.length
                      ? 'Ir para a próxima aula'
                      : 'Última aula da lista',
                  icon: Icons.skip_next_rounded,
                  onPressed: _lessonId >= firstAidVideos.length
                      ? null
                      : () async {
                          await _controller.pauseVideo();
                          if (!context.mounted) return;
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => VideoPlayerScreen(
                                video: firstAidVideos[_lessonId],
                              ),
                            ),
                          );
                        },
                ),
                const SizedBox(height: 10),
                LearningAction(
                  label: 'Fazer quiz',
                  icon: Icons.quiz_outlined,
                  onPressed: () async {
                    await _controller.pauseVideo();
                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => VideoQuizScreen(video: widget.video),
                      ),
                    );
                  },
                ),
                if (_error != null)
                  TextButton(
                    onPressed: () => _report(_progress, force: true),
                    child: LocalizedText(_error!),
                  ),
                const SizedBox(height: 20),
                LocalizedText(
                  widget.video.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                LocalizedText(
                  'Resumo do conteúdo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const LocalizedText(
                  'Este conteúdo apresenta os cuidados iniciais e o momento de buscar atendimento especializado. Pratique apenas em contexto seguro e siga sempre orientações profissionais.',
                ),
                const SizedBox(height: 12),
                LocalizedText(
                  'Tópicos principais',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const LocalizedText(
                  '• Reconhecer sinais de alerta\n• Agir com segurança e pedir ajuda\n• Evitar condutas que possam agravar a situação',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
