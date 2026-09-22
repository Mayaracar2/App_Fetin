import '../l10n/localized_text.dart';
import '../l10n/language_controller.dart';
import '../widgets/section_app_bar.dart';
import '../services/learning_progress_service.dart';
import 'dart:async';
import '../data/first_aid_videos.dart';
import 'video_player_screen.dart';
import '../widgets/app_logo.dart';
import '../widgets/continue_learning_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _navy = Color(0xFF17354B);
const _blue = Color(0xFF217BA5);
const _muted = Color(0xFF5F7D8F);
const _background = Color(0xFFF4F9FC);
const _border = Color(0xFFC9DCE7);
bool _videosDark = false;

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  static const _videos = firstAidVideos;

  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'Todos';
  Map<int, int> _progress = {};
  StreamSubscription<Map<int, int>>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _progressSubscription = LearningProgressService.watch().listen(
      (values) {
        if (mounted) setState(() => _progress = values);
      },
      onError: (Object error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: LocalizedText(
              'Não foi possível carregar o progresso dos vídeos.',
            ),
          ),
        );
      },
    );
  }

  List<String> get _categories => [
    'Todos',
    ..._videos.map((video) => video.category).toSet(),
  ];

  List<FirstAidVideo> get _filteredVideos {
    final normalizedQuery = _query.trim().toLowerCase();
    return _videos.where((video) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          LanguageController.translate(
            video.title,
          ).toLowerCase().contains(normalizedQuery) ||
          LanguageController.translate(
            video.description,
          ).toLowerCase().contains(normalizedQuery) ||
          LanguageController.translate(
            video.category,
          ).toLowerCase().contains(normalizedQuery);
      return matchesQuery &&
          (_category == 'Todos' || video.category == _category);
    }).toList();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openVideo(FirstAidVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => VideoPlayerScreen(
          video: video,
          resumeProgress: (_progress[_videos.indexOf(video) + 1] ?? 0) < 100
              ? (_progress[_videos.indexOf(video) + 1] ?? 0)
              : 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _videosDark = Theme.of(context).brightness == Brightness.dark;
    final videos = _filteredVideos;
    final page = Scaffold(
      backgroundColor: _videosDark ? const Color(0xFF071522) : _background,
      appBar: sectionAppBar(
        'Biblioteca de primeiros socorros',
        logo: const AppLogo(size: 34),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ContinueLearningCard(),
            ),
          ),
          SliverToBoxAdapter(child: _filters()),
          if (videos.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _emptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 160),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent >= 760
                      ? 3
                      : constraints.crossAxisExtent >= 520
                      ? 2
                      : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent:
                          ((constraints.crossAxisExtent - 16 * (columns - 1)) /
                                  columns) *
                              9 /
                              16 +
                          40 +
                          MediaQuery.textScalerOf(context).scale(160),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _VideoCard(
                        video: videos[index],
                        progress:
                            _progress[_videos.indexOf(videos[index]) + 1] ?? 0,
                        onTap: () => _openVideo(videos[index]),
                      ),
                      childCount: videos.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
    return page;
  }

  Widget _filters() => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 940),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: TextStyle(
                color: _videosDark ? Colors.white : _navy,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: tr(
                  context,
                  'Buscar por engasgo, RCP, queimaduras...',
                ),
                hintStyle: const TextStyle(color: Color(0xFF7893A3)),
                prefixIcon: const Icon(Icons.search_rounded, color: _blue),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: tr(context, 'Limpar busca'),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded, color: _muted),
                      ),
                filled: true,
                fillColor: _videosDark ? const Color(0xFF071B2C) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _blue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: _blue, size: 18),
                const SizedBox(width: 7),
                LocalizedText(
                  'Categorias',
                  style: TextStyle(
                    color: _videosDark ? Colors.white : _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                LocalizedText(
                  '${_filteredVideos.length} vídeos',
                  style: TextStyle(
                    color: _videosDark ? const Color(0xFF9AB9CD) : _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final category in _categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 9),
                      child: ChoiceChip(
                        label: LocalizedText(category),
                        selected: _category == category,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _category = category),
                        selectedColor: const Color(0xFF0D2E47),
                        backgroundColor: _videosDark
                            ? const Color(0xFF102637)
                            : Colors.white,
                        side: BorderSide(
                          color: _category == category ? _blue : _border,
                        ),
                        labelStyle: TextStyle(
                          color: _category == category
                              ? Colors.white
                              : _videosDark
                              ? const Color(0xFF9AB9CD)
                              : _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFFEAF5F9),
            child: Icon(Icons.search_off_rounded, color: _blue, size: 30),
          ),
          const SizedBox(height: 16),
          const LocalizedText(
            'Nenhum vídeo encontrado',
            style: TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          const LocalizedText(
            'Tente outro termo ou selecione uma categoria diferente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _query = '';
                _category = 'Todos';
              });
            },
            child: const LocalizedText('Limpar filtros'),
          ),
        ],
      ),
    ),
  );
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.video,
    required this.onTap,
    required this.progress,
  });
  final int progress;
  final FirstAidVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: _videosDark ? const Color(0xFF102637) : Colors.white,
          border: Border.all(
            color: _videosDark ? const Color(0xFF294E6B) : _border,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final preview = Container(
              clipBehavior: Clip.antiAlias,
              width: double.infinity,
              height: constraints.maxWidth * 9 / 16,
              decoration: BoxDecoration(
                color: video.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(13),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(video.icon, color: Colors.white70, size: 43),
                  Positioned.fill(
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                  const Positioned(
                    right: 11,
                    top: 11,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: _navy,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 11,
                    bottom: 11,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: LocalizedText(
                        video.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
            final details = Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LocalizedText(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _videosDark ? const Color(0xFFE6F4FF) : _navy,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    LocalizedText(
                      video.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _videosDark ? const Color(0xFF9AB9CD) : _muted,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LocalizedText(
                          progress == 100
                              ? 'Concluído · Rever aula'
                              : progress > 0
                              ? 'Continuar aula'
                              : 'Começar aula',
                          style: TextStyle(
                            color: _videosDark ? Colors.white70 : _muted,
                            fontSize: 11,
                          ),
                        ),
                        LocalizedText(
                          '$progress%',
                          style: TextStyle(
                            color: _videosDark ? Colors.white70 : _blue,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 9),
                    LocalizedText(
                      '${video.duration} · ${video.level}',
                      style: GoogleFonts.ibmPlexMono(
                        color: const Color(0xFF6F8C9D),
                        fontSize: 8,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
              ),
            );
            return Column(children: [preview, details]);
          },
        ),
      ),
    ),
  );
}
