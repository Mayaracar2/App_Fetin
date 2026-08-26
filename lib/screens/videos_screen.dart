import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _navy = Color(0xFF17354B);
const _deepNavy = Color(0xFF0D2E47);
const _blue = Color(0xFF217BA5);
const _muted = Color(0xFF5F7D8F);
const _background = Color(0xFFF4F9FC);
const _border = Color(0xFFC9DCE7);
bool _videosDark = false;

class _FirstAidVideo {
  const _FirstAidVideo({
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final String duration;
  final String category;
  final IconData icon;
  final Color color;
}

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  static const _videos = [
    _FirstAidVideo(
      title: 'Engasgo: como agir nos primeiros minutos',
      description:
          'Aprenda a reconhecer uma obstrução e realizar as manobras corretas.',
      duration: '6 min',
      category: 'Essencial',
      icon: Icons.air_rounded,
      color: Color(0xFF0D5D82),
    ),
    _FirstAidVideo(
      title: 'RCP: reconheça e inicie o atendimento',
      description: 'Reanimação cardiopulmonar explicada passo a passo.',
      duration: '12 min',
      category: 'Fundamental',
      icon: Icons.favorite_outline_rounded,
      color: Color(0xFFA33B48),
    ),
    _FirstAidVideo(
      title: 'Queimaduras: condutas seguras em casa',
      description: 'Cuidados iniciais e atitudes que devem ser evitadas.',
      duration: '8 min',
      category: 'Básico',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFA36B1B),
    ),
    _FirstAidVideo(
      title: 'Desmaio: como proteger a vítima',
      description: 'Saiba como posicionar e acompanhar uma pessoa desacordada.',
      duration: '7 min',
      category: 'Básico',
      icon: Icons.airline_seat_flat_outlined,
      color: Color(0xFF517A92),
    ),
    _FirstAidVideo(
      title: 'Hemorragia: controle de sangramentos',
      description: 'Técnicas seguras para controlar sangramentos externos.',
      duration: '5 min',
      category: 'Essencial',
      icon: Icons.bloodtype_outlined,
      color: Color(0xFFB23A48),
    ),
    _FirstAidVideo(
      title: 'Fraturas: cuidados até o socorro chegar',
      description: 'Como imobilizar e evitar o agravamento da lesão.',
      duration: '9 min',
      category: 'Fundamental',
      icon: Icons.healing_outlined,
      color: Color(0xFF476B5D),
    ),
  ];

  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'Todos';

  List<String> get _categories => const [
    'Todos',
    'Essencial',
    'Fundamental',
    'Básico',
  ];

  List<_FirstAidVideo> get _filteredVideos {
    final normalizedQuery = _query.trim().toLowerCase();
    return _videos.where((video) {
      final matchesCategory =
          _category == 'Todos' || video.category == _category;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          video.title.toLowerCase().contains(normalizedQuery) ||
          video.description.toLowerCase().contains(normalizedQuery) ||
          video.category.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openVideo(_FirstAidVideo video) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VideoDetails(video: video),
    );
  }

  @override
  Widget build(BuildContext context) {
    _videosDark = Theme.of(context).brightness == Brightness.dark;
    final videos = _filteredVideos;
    final page = Scaffold(
      backgroundColor: _videosDark ? const Color(0xFF071522) : _background,
      appBar: AppBar(
        backgroundColor: _videosDark
            ? const Color(0xFF071522)
            : const Color(0xFFF9FCFE),
        foregroundColor: _videosDark ? const Color(0xFFE6F4FF) : _navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF294E6B)),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE5484D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '+',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'TREINAMENTOS',
              style: GoogleFonts.ibmPlexMono(
                color: _navy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _filters()),
          if (videos.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _emptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
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
                      childAspectRatio: columns == 1 ? 1.7 : .92,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _VideoCard(
                        video: videos[index],
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

  Widget _header() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: _videosDark
            ? const [Color(0xFF102637), Color(0xFF123044)]
            : const [Color(0xFFF9FCFE), Color(0xFFEAF5F9)],
      ),
    ),
    padding: const EdgeInsets.fromLTRB(20, 34, 20, 26),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BIBLIOTECA DE PRIMEIROS SOCORROS',
              style: GoogleFonts.ibmPlexMono(
                color: _blue,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Conhecimento para agir com segurança.',
              style: TextStyle(
                color: _videosDark ? const Color(0xFFE6F4FF) : _navy,
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Encontre orientações objetivas para reconhecer situações comuns e saber qual é o próximo passo.',
              style: TextStyle(
                color: _videosDark ? const Color(0xFF9AB9CD) : _muted,
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    ),
  );

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
              style: const TextStyle(color: _navy, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por engasgo, RCP, queimaduras...',
                hintStyle: const TextStyle(color: Color(0xFF7893A3)),
                prefixIcon: const Icon(Icons.search_rounded, color: _blue),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
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
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: _blue, size: 18),
                const SizedBox(width: 7),
                const Text(
                  'Categorias',
                  style: TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredVideos.length} conteúdos',
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 11),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final selected = category == _category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 9),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _category = category),
                      backgroundColor: _videosDark
                          ? const Color(0xFF102637)
                          : Colors.white,
                      selectedColor: _deepNavy,
                      side: BorderSide(color: selected ? _deepNavy : _border),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
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
          const Text(
            'Nenhum vídeo encontrado',
            style: TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
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
            child: const Text('Limpar filtros'),
          ),
        ],
      ),
    ),
  );
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onTap});
  final _FirstAidVideo video;
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
            final horizontal =
                constraints.maxWidth > constraints.maxHeight * 1.25;
            final preview = Container(
              width: horizontal ? 132 : double.infinity,
              height: horizontal ? double.infinity : null,
              decoration: BoxDecoration(
                color: video.color,
                borderRadius: horizontal
                    ? const BorderRadius.horizontal(left: Radius.circular(13))
                    : const BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(video.icon, color: Colors.white70, size: 43),
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
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
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
                    Text(
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
                    Text(
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
                    Text(
                      '${video.duration} DE CONTEÚDO',
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
            return horizontal
                ? Row(children: [preview, details])
                : Column(
                    children: [
                      Expanded(child: preview),
                      details,
                    ],
                  );
          },
        ),
      ),
    ),
  );
}

class _VideoDetails extends StatelessWidget {
  const _VideoDetails({required this.video});
  final _FirstAidVideo video;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: video.color.withValues(alpha: .12),
                child: Icon(video.icon, color: video.color),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            video.category.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              color: _blue,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            style: const TextStyle(
              color: _navy,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            video.description,
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Abrindo conteúdo: ${video.title}')),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Assistir agora · ${video.duration}'),
            ),
          ),
        ],
      ),
    ),
  );
}
