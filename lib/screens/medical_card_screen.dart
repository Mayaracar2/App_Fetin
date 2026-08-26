import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen.dart';

const _navy = Color(0xFF17354B);
const _deepNavy = Color(0xFF0D2E47);
const _blue = Color(0xFF217BA5);
const _muted = Color(0xFF5F7D8F);
const _background = Color(0xFFF4F9FC);
const _border = Color(0xFFC9DCE7);
const _red = Color(0xFFE5484D);
const _green = Color(0xFF2A9876);
bool _medicalDark = false;

class MedicalCardScreen extends StatefulWidget {
  const MedicalCardScreen({super.key});

  @override
  State<MedicalCardScreen> createState() => _MedicalCardScreenState();
}

class _MedicalCardScreenState extends State<MedicalCardScreen> {
  final _scrollController = ScrollController();
  String nome = 'Não informado';
  String sangue = 'Não informado';
  String alergias = 'Não informado';
  String medicamentos = 'Não informado';
  String doencas = 'Não informado';
  String contato = 'Não informado';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _read(SharedPreferences prefs, String key) {
    final value = prefs.getString(key)?.trim();
    return value == null || value.isEmpty ? 'Não informado' : value;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      nome = _read(prefs, 'nome');
      sangue = _read(prefs, 'sangue');
      alergias = _read(prefs, 'alergias');
      medicamentos = _read(prefs, 'medicamentos');
      doencas = _read(prefs, 'doencas');
      contato = _read(prefs, 'contato');
      loading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _editProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    _medicalDark = Theme.of(context).brightness == Brightness.dark;
    final page = Scaffold(
      backgroundColor: _medicalDark ? const Color(0xFF071522) : _background,
      appBar: AppBar(
        backgroundColor: _medicalDark
            ? const Color(0xFF071522)
            : const Color(0xFFF9FCFE),
        foregroundColor: _medicalDark ? const Color(0xFFE6F4FF) : _navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CARTEIRA MÉDICA',
          style: GoogleFonts.ibmPlexMono(
            color: _navy,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _pageHeading(),
                        const SizedBox(height: 22),
                        _medicalCard(),
                        const SizedBox(height: 18),
                        _qrAccessCard(),
                        const SizedBox(height: 18),
                        _detailPanel(),
                        const SizedBox(height: 18),
                        _emergencyNotice(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _blue,
                              side: const BorderSide(color: _blue),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: _editProfile,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Atualizar informações'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
    return page;
  }

  Widget _pageHeading() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PERFIL DE SAÚDE PROTEGIDO',
        style: GoogleFonts.ibmPlexMono(
          color: _blue,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Sua ficha para situações de emergência.',
        style: TextStyle(
          color: _navy,
          fontSize: 25,
          height: 1.15,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 9),
      const Text(
        'Mantenha estes dados atualizados para ajudar a equipe durante o atendimento.',
        style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
      ),
    ],
  );

  Widget _medicalCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFDFE),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFB9D8E8)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1E1B506A),
          blurRadius: 34,
          offset: Offset(0, 16),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
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
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOPS 2.0',
                    style: GoogleFonts.ibmPlexMono(
                      color: _navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .8,
                    ),
                  ),
                  const Text(
                    'Carteira médica de emergência',
                    style: TextStyle(color: Color(0xFF6F8C9D), fontSize: 9),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF8F4),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'ONLINE',
                style: GoogleFonts.ibmPlexMono(
                  color: _green,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 25, color: Color(0xFFD8E7EE)),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _deepNavy,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERFIL DE SAÚDE',
                style: GoogleFonts.ibmPlexMono(
                  color: const Color(0xFF8BDCFF),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$sangue  ·  $doencas',
                style: const TextStyle(
                  color: Color(0xFFB5DCED),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  ..._tags(alergias, Icons.warning_amber_rounded),
                  ..._tags(medicamentos, Icons.medication_outlined),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            CircleAvatar(radius: 5, backgroundColor: _green),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ficha sincronizada e disponível',
                style: TextStyle(
                  color: _navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.verified_user_outlined, color: _green, size: 19),
          ],
        ),
      ],
    ),
  );

  List<Widget> _tags(String value, IconData icon) {
    if (value == 'Não informado') {
      return [_MedicalTag(label: value, icon: icon)];
    }
    return value
        .split(RegExp(r'[,;]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .take(5)
        .map((item) => _MedicalTag(label: item, icon: icon))
        .toList();
  }

  String get _qrData => [
    'SOPS 2.0 - CARTEIRA MEDICA DE EMERGENCIA',
    'Nome: $nome',
    'Tipo sanguineo: $sangue',
    'Alergias: $alergias',
    'Medicamentos: $medicamentos',
    'Condicoes: $doencas',
    'Contato de emergencia: $contato',
  ].join('\n');

  Widget _qrAccessCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _medicalDark ? const Color(0xFF102637) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x101B506A),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 460;
        final qrCode = Container(
          width: 164,
          height: 164,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB9D8E8)),
          ),
          child: QrImageView(
            data: _qrData,
            version: QrVersions.auto,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: _deepNavy,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: _deepNavy,
            ),
          ),
        );
        final description = Column(
          crossAxisAlignment: compact
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF8FC),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFFB9D8E8)),
              ),
              child: Text(
                'ACESSO RÁPIDO',
                style: GoogleFonts.ibmPlexMono(
                  color: _blue,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .9,
                ),
              ),
            ),
            const SizedBox(height: 11),
            const Text(
              'Escaneie a carteira médica',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'O QR Code reúne os dados essenciais desta ficha para consulta rápida durante um atendimento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, color: _green, size: 16),
                SizedBox(width: 6),
                Text(
                  'Gerado com os dados salvos no aparelho',
                  style: TextStyle(color: _green, fontSize: 10.5),
                ),
              ],
            ),
          ],
        );
        if (compact) {
          return Column(
            children: [description, const SizedBox(height: 20), qrCode],
          );
        }
        return Row(
          children: [
            qrCode,
            const SizedBox(width: 22),
            Expanded(child: description),
          ],
        );
      },
    ),
  );

  Widget _detailPanel() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMAÇÕES PARA O ATENDIMENTO',
          style: GoogleFonts.ibmPlexMono(
            color: _blue,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 18),
        _DataRow(
          icon: Icons.bloodtype_outlined,
          label: 'Tipo sanguíneo',
          value: sangue,
          color: _red,
        ),
        _DataRow(
          icon: Icons.warning_amber_rounded,
          label: 'Alergias',
          value: alergias,
          color: const Color(0xFFA36B1B),
        ),
        _DataRow(
          icon: Icons.medication_outlined,
          label: 'Medicamentos em uso',
          value: medicamentos,
          color: _blue,
        ),
        _DataRow(
          icon: Icons.monitor_heart_outlined,
          label: 'Condições de saúde',
          value: doencas,
          color: _green,
        ),
        _DataRow(
          icon: Icons.phone_outlined,
          label: 'Contato de emergência',
          value: contato,
          color: const Color(0xFF517A92),
          last: true,
        ),
      ],
    ),
  );

  Widget _emergencyNotice() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFF2B3B7)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.emergency_outlined, color: _red, size: 21),
        SizedBox(width: 11),
        Expanded(
          child: Text(
            'Em caso de emergência, apresente esta carteira à equipe. Ligue 192 para acionar o SAMU.',
            style: TextStyle(
              color: Color(0xFFA33B48),
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MedicalTag extends StatelessWidget {
  const _MedicalTag({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF164664),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: const Color(0xFF386889)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFD6ECFB), size: 12),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFD6ECFB), fontSize: 9.5),
        ),
      ],
    ),
  );
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.last = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(bottom: last ? 0 : 15, top: last ? 0 : 0),
    margin: EdgeInsets.only(bottom: last ? 0 : 15),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFE1ECF1))),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.ibmPlexMono(
                  color: const Color(0xFF6F8C9D),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
