import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/mono_tag.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String nome = '';
  String sangue = '';
  String alergias = '';
  String medicamentos = '';
  String doencas = '';
  String contato = '';

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nome = prefs.getString('nome') ?? 'Não informado';
      sangue = prefs.getString('sangue') ?? 'Não informado';
      alergias = prefs.getString('alergias') ?? 'Não informado';
      medicamentos = prefs.getString('medicamentos') ?? 'Não informado';
      doencas = prefs.getString('doencas') ?? 'Não informado';
      contato = prefs.getString('contato') ?? 'Não informado';
    });
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Widget _infoRow(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accentCyan),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: monoStyle(fontSize: 9.5)),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: color),
              label: Text(label, style: TextStyle(color: color)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'EMERGÊNCIA',
          style: monoStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Card SOS em destaque
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.bgPanelAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.emergencyRed.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.local_hospital,
                          color: AppColors.emergencyRed,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Precisa de ajuda agora?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Toque abaixo para acionar o SAMU (192).',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _actionButton(
                        icon: Icons.local_hospital,
                        label: 'Ligar para o SAMU (192)',
                        color: AppColors.emergencyRed,
                        filled: true,
                        onTap: () =>
                            mostrarMensagem('Ligação para o SAMU simulada'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Card de informações médicas
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MonoTag('Ficha de emergência'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.person_outline, 'Nome', nome),
                      _infoRow(Icons.bloodtype, 'Tipo sanguíneo', sangue),
                      _infoRow(Icons.warning_amber, 'Alergias', alergias),
                      _infoRow(Icons.medication, 'Medicamentos', medicamentos),
                      _infoRow(Icons.medical_information, 'Condições', doencas),
                      _infoRow(Icons.phone, 'Contato', contato),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _actionButton(
                  icon: Icons.location_on,
                  label: 'Compartilhar Localização',
                  color: AppColors.accentBlueLight,
                  onTap: () =>
                      mostrarMensagem('Localização compartilhada simulada'),
                ),
                const SizedBox(height: 12),
                _actionButton(
                  icon: Icons.contact_phone,
                  label: 'Contato de Emergência',
                  color: AppColors.successGreen,
                  onTap: () => mostrarMensagem('Ligando para: $contato'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
