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
  final List<TextEditingController> contatoControllers = [
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    final savedContacts = prefs.getStringList('contatos_emergencia');
    final legacyContact = prefs.getString('contato') ?? '';
    final contacts = savedContacts != null && savedContacts.isNotEmpty
        ? savedContacts
        : [legacyContact];
    if (!mounted) return;
    setState(() {
      nomeController.text = prefs.getString('nome') ?? '';
      sangueController.text = prefs.getString('sangue') ?? '';
      alergiasController.text = prefs.getString('alergias') ?? '';
      medicamentosController.text = prefs.getString('medicamentos') ?? '';
      doencasController.text = prefs.getString('doencas') ?? '';
      for (final controller in contatoControllers) {
        controller.dispose();
      }
      contatoControllers
        ..clear()
        ..addAll(
          contacts.map((contact) => TextEditingController(text: contact)),
        );
    });
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nome', nomeController.text);
    await prefs.setString('sangue', sangueController.text);
    await prefs.setString('alergias', alergiasController.text);
    await prefs.setString('medicamentos', medicamentosController.text);
    await prefs.setString('doencas', doencasController.text);
    final contacts = contatoControllers
        .map((controller) => controller.text.trim())
        .where((contact) => contact.isNotEmpty)
        .toList();
    await prefs.setStringList('contatos_emergencia', contacts);
    // Mantém a chave antiga para as telas que exibem os contatos de emergência.
    await prefs.setString(
      'contato',
      contacts.isEmpty ? '' : contacts.join(' · '),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil de saúde salvo com sucesso!')),
    );
  }

  void _addContact() {
    setState(() => contatoControllers.add(TextEditingController()));
  }

  void _removeContact(int index) {
    if (contatoControllers.length == 1) return;
    final controller = contatoControllers.removeAt(index);
    controller.dispose();
    setState(() {});
  }

  @override
  void dispose() {
    nomeController.dispose();
    sangueController.dispose();
    alergiasController.dispose();
    medicamentosController.dispose();
    doencasController.dispose();
    for (final controller in contatoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = dark ? AppColors.textPrimary : const Color(0xFF183B50);
    final secondary = dark ? AppColors.textMuted : const Color(0xFF638092);
    return Scaffold(
      backgroundColor: dark ? AppColors.bgDark : const Color(0xFFF3F8FA),
      appBar: AppBar(
        title: Text(
          'MEU PERFIL DE SAÚDE',
          style: monoStyle(fontSize: 11.5, color: primary),
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
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Esses dados podem ajudar em uma emergência.',
                    style: TextStyle(fontSize: 13, color: secondary),
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

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Contatos de emergência',
                          style: TextStyle(
                            color: primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addContact,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(contatoControllers.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == contatoControllers.length - 1 ? 0 : 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Contato ${index + 1}',
                              controller: contatoControllers[index],
                              hint: 'Ex: Maria (mãe) · (35) 99999-9999',
                              icon: Icons.phone_outlined,
                            ),
                          ),
                          if (contatoControllers.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Remover contato',
                              onPressed: () => _removeContact(index),
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: AppColors.emergencyRed,
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

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
