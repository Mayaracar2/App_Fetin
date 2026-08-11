import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/mono_tag.dart';

class MedicalCardScreen extends StatefulWidget {
  const MedicalCardScreen({super.key});

  @override
  State<MedicalCardScreen> createState() => _MedicalCardScreenState();
}

class _MedicalCardScreenState extends State<MedicalCardScreen> {
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

  Widget linha(String titulo, String valor, IconData icon, Color cor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: cor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo.toUpperCase(), style: monoStyle(fontSize: 9.5)),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'CARTEIRA MÉDICA',
          style: monoStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // Cabeçalho estilo "ficha"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgPanelAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'SOCORRO FÁCIL',
                        style: monoStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Carteira Médica de Emergência',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accentCyan,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      linha(
                        "Nome",
                        nome,
                        Icons.person,
                        AppColors.accentBlueLight,
                      ),
                      linha(
                        "Tipo sanguíneo",
                        sangue,
                        Icons.bloodtype,
                        AppColors.emergencyRed,
                      ),
                      linha(
                        "Alergias",
                        alergias,
                        Icons.warning_amber,
                        Colors.orange,
                      ),
                      linha(
                        "Medicamentos",
                        medicamentos,
                        Icons.medication,
                        Colors.purpleAccent,
                      ),
                      linha(
                        "Condições",
                        doencas,
                        Icons.medical_information,
                        AppColors.successGreen,
                      ),
                      linha(
                        "Contato de emergência",
                        contato,
                        Icons.phone,
                        AppColors.accentCyan,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.emergencyRed.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    "Em caso de emergência, utilize estas informações para auxiliar no atendimento inicial.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.emergencyRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
