import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/mono_tag.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nomeController = TextEditingController();
  final sangueController = TextEditingController();
  final alergiasController = TextEditingController();
  final medicamentosController = TextEditingController();
  final doencasController = TextEditingController();
  final contatoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nomeController.text = prefs.getString('nome') ?? '';
      sangueController.text = prefs.getString('sangue') ?? '';
      alergiasController.text = prefs.getString('alergias') ?? '';
      medicamentosController.text = prefs.getString('medicamentos') ?? '';
      doencasController.text = prefs.getString('doencas') ?? '';
      contatoController.text = prefs.getString('contato') ?? '';
    });
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nome', nomeController.text);
    await prefs.setString('sangue', sangueController.text);
    await prefs.setString('alergias', alergiasController.text);
    await prefs.setString('medicamentos', medicamentosController.text);
    await prefs.setString('doencas', doencasController.text);
    await prefs.setString('contato', contatoController.text);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil de saúde salvo com sucesso!')),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    sangueController.dispose();
    alergiasController.dispose();
    medicamentosController.dispose();
    doencasController.dispose();
    contatoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'MEU PERFIL DE SAÚDE',
          style: monoStyle(fontSize: 11.5, color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MonoTag('Ficha de saúde'),
                  const SizedBox(height: 8),
                  Text(
                    'Informações importantes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Esses dados podem ajudar em uma emergência.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),

                  const SizedBox(height: 24),

                  AppTextField(
                    label: 'Nome completo',
                    controller: nomeController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Tipo sanguíneo',
                    controller: sangueController,
                    hint: 'Ex: O+, A-, B+',
                    icon: Icons.bloodtype,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Alergias',
                    controller: alergiasController,
                    hint: 'Ex: Penicilina, Dipirona',
                    icon: Icons.warning_amber,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Medicamentos em uso',
                    controller: medicamentosController,
                    hint: 'Ex: Losartana, Insulina',
                    icon: Icons.medication_outlined,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Doenças ou condições',
                    controller: doencasController,
                    hint: 'Ex: Diabetes, Hipertensão, Asma',
                    icon: Icons.health_and_safety_outlined,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Contato de emergência',
                    controller: contatoController,
                    hint: 'Ex: (35) 99999-9999',
                    icon: Icons.phone_outlined,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Salvar Perfil'),
                      onPressed: salvarDados,
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
}
