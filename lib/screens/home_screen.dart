import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_controller.dart';
import 'emergency_screen.dart';
import 'login_screen.dart';
import 'medical_card_screen.dart';
import 'profile_screen.dart';
import 'videos_screen.dart';

const _navy = Color(0xFF183B50);
const _blue = Color(0xFF217BA5);
const _muted = Color(0xFF638092);
const _green = Color(0xFF2A9876);
const _red = Color(0xFFE5484D);
const _background = Color(0xFFF3F8FA);
const _border = Color(0xFFD7E5EB);
bool _useLearningDark = false;

class _Lesson {
  const _Lesson(
    this.title,
    this.category,
    this.duration,
    this.level,
    this.icon,
    this.color,
    this.progress,
  );
  final String title;
  final String category;
  final String duration;
  final String level;
  final IconData icon;
  final Color color;
  final int progress;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _lessons = [
    _Lesson(
      'Engasgo: como agir nos primeiros minutos',
      'Emergências',
      '6 min',
      'Essencial',
      Icons.add,
      Color(0xFF0D7797),
      100,
    ),
    _Lesson(
      'RCP: reconheça uma parada cardíaca',
      'Emergências',
      '12 min',
      'Fundamental',
      Icons.favorite,
      Color(0xFFD45A66),
      45,
    ),
    _Lesson(
      'Queimaduras: cuidados imediatos',
      'Casa e família',
      '8 min',
      'Básico',
      Icons.local_fire_department,
      Color(0xFFE4943A),
      0,
    ),
    _Lesson(
      'Quedas: avaliação inicial e segurança',
      'Casa e família',
      '7 min',
      'Básico',
      Icons.person_outline,
      Color(0xFF577CA4),
      0,
    ),
    _Lesson(
      'Kit de primeiros socorros em casa',
      'Prevenção',
      '5 min',
      'Rápido',
      Icons.medical_services_outlined,
      Color(0xFF319875),
      100,
    ),
    _Lesson(
      'Acolhimento em uma crise de ansiedade',
      'Saúde mental',
      '9 min',
      'Guia',
      Icons.cloud_outlined,
      Color(0xFF8A6DAD),
      0,
    ),
  ];
  static const _categories = [
    'Todos',
    'Emergências',
    'Casa e família',
    'Prevenção',
    'Saúde mental',
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _name = 'Usuário';
  String _blood = 'Não informado';
  String _allergies = 'Não informado';
  String _category = 'Todos';
  String _query = '';
  bool _isDarkMode = false;

  Color get _pageBackground =>
      _isDarkMode ? const Color(0xFF071522) : _background;
  Color get _surface => _isDarkMode ? const Color(0xFF102637) : Colors.white;
  Color get _surfaceAlt =>
      _isDarkMode ? const Color(0xFF071B2C) : const Color(0xFFF6FBF8);
  Color get _line => _isDarkMode ? const Color(0xFF294E6B) : _border;
  Color get _primaryText => _isDarkMode ? const Color(0xFFE6F4FF) : _navy;
  Color get _secondaryText => _isDarkMode ? const Color(0xFF9AB9CD) : _muted;

  List<_Lesson> get _visibleLessons => _lessons.where((lesson) {
    return (_category == 'Todos' || lesson.category == _category) &&
        lesson.title.toLowerCase().contains(_query.trim().toLowerCase());
  }).toList();

  @override
  void initState() {
    super.initState();
    _isDarkMode = ThemeController.mode.value == ThemeMode.dark;
    ThemeController.mode.addListener(_syncTheme);
    _loadProfile();
  }

  void _syncTheme() {
    if (!mounted) return;
    setState(() => _isDarkMode = ThemeController.mode.value == ThemeMode.dark);
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final savedName = prefs.getString('nome')?.trim();
      _name = savedName == null || savedName.isEmpty ? 'Usuário' : savedName;
      _blood = _read(prefs, 'sangue');
      _allergies = _read(prefs, 'alergias');
    });
  }

  Future<void> _toggleDarkMode() => ThemeController.toggle();

  String _read(SharedPreferences prefs, String key) {
    final value = prefs.getString(key)?.trim();
    return value == null || value.isEmpty ? 'Não informado' : value;
  }

  void _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    _loadProfile();
  }

  @override
  void dispose() {
    ThemeController.mode.removeListener(_syncTheme);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _useLearningDark = _isDarkMode;
    final page = Scaffold(
      key: _scaffoldKey,
      backgroundColor: _pageBackground,
      endDrawer: _mobileDrawer(),
      drawerScrimColor: const Color(0x99071522),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 900;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (desktop) SizedBox(width: 280, child: _sidebar()),
                          Expanded(
                            child: Scrollbar(
                              controller: _scrollController,
                              thumbVisibility: desktop,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                padding: EdgeInsets.fromLTRB(
                                  desktop ? 26 : 18,
                                  24,
                                  desktop ? 30 : 18,
                                  100,
                                ),
                                child: _content(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    return page;
  }

  Widget _header() => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      color: _surface,
      border: Border(bottom: BorderSide(color: _line)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Row(
          children: [
            Expanded(child: _Brand(dark: _isDarkMode)),
            if (MediaQuery.sizeOf(context).width >= 600)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _name,
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Perfil de usuário',
                    style: TextStyle(color: _secondaryText, fontSize: 10),
                  ),
                ],
              ),
            const SizedBox(width: 9),
            IconButton(
              tooltip: _isDarkMode ? 'Ativar modo claro' : 'Ativar modo escuro',
              onPressed: _toggleDarkMode,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFEDF7FA),
                side: const BorderSide(color: Color(0xFFC6DCE6)),
              ),
              icon: Icon(
                _isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: _blue,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Meu perfil',
              onPressed: _openProfile,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFEDF7FA),
                side: const BorderSide(color: Color(0xFFC6DCE6)),
              ),
              icon: const Icon(Icons.person_outline, color: _blue),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Abrir menu',
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              icon: Icon(Icons.menu_rounded, color: _primaryText, size: 27),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _mobileDrawer() => Drawer(
    backgroundColor: _pageBackground,
    width: MediaQuery.sizeOf(context).width.clamp(290, 360).toDouble(),
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(child: _Brand(dark: _isDarkMode)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _line),
          Expanded(child: _sidebar(inDrawer: true)),
        ],
      ),
    ),
  );

  Widget _sidebar({bool inDrawer = false}) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
    children: [
      _profileSummary(),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: _boxDecoration(),
        child: Column(
          children: [
            _NavTile(
              Icons.video_library_outlined,
              'Biblioteca de primeiros socorros',
              _blue,
              () => _navigate(inDrawer, const VideosScreen()),
            ),
            _NavTile(
              Icons.favorite_outline,
              'Emergência',
              _red,
              () => _navigate(inDrawer, const EmergencyScreen()),
            ),
            _NavTile(
              Icons.workspace_premium_outlined,
              'Meu progresso',
              _muted,
              () => _showProgress(inDrawer),
            ),
            _NavTile(
              Icons.badge_outlined,
              'Cartão de emergência',
              _muted,
              () => _navigate(inDrawer, const MedicalCardScreen()),
            ),
            _NavTile(Icons.person_outline, 'Meu perfil', _muted, () {
              _closeDrawer(inDrawer);
              _openProfile();
            }),
            Divider(color: _line),
            _NavTile(
              Icons.logout,
              'Sair',
              _muted,
              () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite_outline, color: _green, size: 18),
                SizedBox(width: 7),
                Text(
                  'INFORMAÇÕES ESSENCIAIS',
                  style: TextStyle(
                    color: _green,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sidebarData('Tipo sanguíneo', _blood),
            _sidebarData('Alergias', _allergies),
            TextButton(
              onPressed: _openProfile,
              child: const Text('Ver perfil de saúde'),
            ),
          ],
        ),
      ),
    ],
  );

  void _closeDrawer(bool inDrawer) {
    if (inDrawer) Navigator.pop(context);
  }

  void _navigate(bool inDrawer, Widget page) {
    _closeDrawer(inDrawer);
    Future<void>.delayed(const Duration(milliseconds: 200), () => _open(page));
  }

  void _showProgress(bool inDrawer) {
    _closeDrawer(inDrawer);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progresso geral: 41% · 2 aulas concluídas'),
      ),
    );
  }

  Widget _profileSummary() => Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Column(
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE6F5F9),
              child: Icon(Icons.person_outline, color: _blue),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Aluno da trilha de cuidados',
                    style: TextStyle(color: _secondaryText, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Row(
          children: [
            Text(
              'Progresso geral',
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            Text(
              '41%',
              style: TextStyle(
                color: _blue,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        const LinearProgressIndicator(
          value: .41,
          minHeight: 6,
          backgroundColor: Color(0xFFDCEBF0),
          color: _green,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: Color(0xFFD99231),
              size: 17,
            ),
            SizedBox(width: 6),
            Text(
              'Meta semanal: 2/3 aulas',
              style: TextStyle(color: _muted, fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _line),
    boxShadow: const [
      BoxShadow(color: Color(0x0F194E66), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );
  Widget _sidebarData(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(label, style: TextStyle(color: _secondaryText, fontSize: 10)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF315F50),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _content() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _hero(),
      const SizedBox(height: 18),
      _quickActions(),
      const SizedBox(height: 20),
      _metrics(),
    ],
  );

  Widget _hero() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: _isDarkMode
            ? const [Color(0xFF102637), Color(0xFF123044)]
            : const [Color(0xFFFBFEFF), Color(0xFFEAF7FA)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRILHA DE APRENDIZAGEM',
          style: TextStyle(color: _blue, fontSize: 11, letterSpacing: 1.3),
        ),
        const SizedBox(height: 9),
        Text(
          'Olá, ${_name.split(' ').first}! Vamos aprender?',
          style: TextStyle(
            color: _primaryText,
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Conteúdos rápidos para agir com mais segurança em situações reais.',
          style: TextStyle(color: _secondaryText, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _quickActions() => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900
          ? 4
          : constraints.maxWidth >= 520
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: width,
            child: _ActionCard(
              Icons.favorite_outline,
              'Emergência',
              'Orientação rápida e números úteis',
              _red,
              true,
              () => _open(const EmergencyScreen()),
            ),
          ),
          SizedBox(
            width: width,
            child: _ActionCard(
              Icons.person_outline,
              'Meu perfil de saúde',
              'Dados clínicos e contatos',
              _blue,
              false,
              _openProfile,
            ),
          ),
          SizedBox(
            width: width,
            child: _ActionCard(
              Icons.workspace_premium_outlined,
              'Meu progresso',
              'Acompanhe sua evolução',
              _green,
              false,
              () => _showProgress(false),
            ),
          ),
          SizedBox(
            width: width,
            child: _ActionCard(
              Icons.shield_outlined,
              'Cartão de emergência',
              'Seus dados essenciais',
              const Color(0xFF6B76A5),
              false,
              () => _open(const MedicalCardScreen()),
            ),
          ),
        ],
      );
    },
  );

  Widget _metrics() => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth >= 600
          ? (constraints.maxWidth - 24) / 3
          : constraints.maxWidth;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: width,
            child: const _Metric(
              Icons.favorite_outline,
              _red,
              '2',
              'aulas concluídas',
            ),
          ),
          SizedBox(
            width: width,
            child: const _Metric(
              Icons.schedule,
              _blue,
              '38 min',
              'tempo estudado',
            ),
          ),
          SizedBox(
            width: width,
            child: const _Metric(
              Icons.workspace_premium_outlined,
              Color(0xFFD99231),
              'Em progresso',
              'continue sua trilha',
            ),
          ),
        ],
      );
    },
  );

  // ignore: unused_element
  Widget _libraryHeader() => LayoutBuilder(
    builder: (context, constraints) {
      final title = const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biblioteca de primeiros socorros',
            style: TextStyle(
              color: _navy,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Escolha uma categoria ou encontre um tema.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      );
      final search = SizedBox(
        width: constraints.maxWidth >= 620 ? 290 : double.infinity,
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          style: const TextStyle(color: _navy),
          decoration: InputDecoration(
            hintText: 'Buscar aula',
            prefixIcon: const Icon(Icons.search, color: _muted),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
          ),
        ),
      );
      return constraints.maxWidth >= 620
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [title, search],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 14), search],
            );
    },
  );

  // ignore: unused_element
  Widget _categoryFilters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: _categories
          .map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: category == _category,
                showCheckmark: false,
                onSelected: (_) => setState(() => _category = category),
                selectedColor: _blue,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: category == _category
                      ? _blue
                      : const Color(0xFFCBDDE5),
                ),
                labelStyle: TextStyle(
                  color: category == _category
                      ? Colors.white
                      : const Color(0xFF5A7889),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  // ignore: unused_element
  Widget _lessonGrid() {
    if (_visibleLessons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Nenhuma aula encontrada.',
            style: TextStyle(color: _muted),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050
            ? 3
            : constraints.maxWidth >= 580
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: _visibleLessons
              .map(
                (lesson) => SizedBox(
                  width: width,
                  child: _LessonCard(
                    lesson: lesson,
                    onTap: () => _open(const VideosScreen()),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.dark = false});
  final bool dark;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _red,
          borderRadius: BorderRadius.circular(9),
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SOPS 2.0',
            style: GoogleFonts.ibmPlexMono(
              color: dark ? const Color(0xFFE6F4FF) : _navy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const Text(
            'Educação em primeiros socorros',
            style: TextStyle(color: Color(0xFF5D879A), fontSize: 9),
          ),
        ],
      ),
    ],
  );
}

class _NavTile extends StatelessWidget {
  const _NavTile(this.icon, this.title, this.color, this.onTap);
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    dense: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    leading: Icon(icon, color: color, size: 19),
    title: Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
    this.icon,
    this.title,
    this.subtitle,
    this.color,
    this.filled,
    this.onTap,
  );
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Ink(
        height: 126,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: filled
              ? color
              : (_useLearningDark ? const Color(0xFF102637) : Colors.white),
          borderRadius: BorderRadius.circular(13),
          border: filled
              ? null
              : Border.all(
                  color: _useLearningDark ? const Color(0xFF294E6B) : _border,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: filled ? Colors.white : color, size: 22),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: filled
                    ? Colors.white
                    : (_useLearningDark ? const Color(0xFFE6F4FF) : _navy),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: filled
                    ? Colors.white.withValues(alpha: .85)
                    : (_useLearningDark ? const Color(0xFF9AB9CD) : _muted),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.color, this.value, this.label);
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: 115,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _useLearningDark ? const Color(0xFF102637) : Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: _useLearningDark ? const Color(0xFF294E6B) : _border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 21),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: _useLearningDark ? const Color(0xFFE6F4FF) : _navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: _useLearningDark ? const Color(0xFF9AB9CD) : _muted,
            fontSize: 10.5,
          ),
        ),
      ],
    ),
  );
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.onTap});
  final _Lesson lesson;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 112,
              decoration: BoxDecoration(
                color: lesson.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Icon(lesson.icon, color: Colors.white70, size: 42),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.play_arrow,
                        color: lesson.color,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.category.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      color: _blue,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: _muted, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '${lesson.duration} · ${lesson.level}',
                        style: const TextStyle(color: _muted, fontSize: 10),
                      ),
                      const Spacer(),
                      Text(
                        '${lesson.progress}%',
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value: lesson.progress / 100,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE5EFF2),
                    color: _green,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
