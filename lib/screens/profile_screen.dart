import '../l10n/localized_text.dart';
import '../l10n/language_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/mono_tag.dart';
import '../widgets/section_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nomeController = TextEditingController(),
      emailController = TextEditingController(),
      telefoneController = TextEditingController(),
      nascimentoController = TextEditingController(),
      cidadeController = TextEditingController(),
      sangueController = TextEditingController(),
      alergiasController = TextEditingController(),
      medicamentosController = TextEditingController(),
      doencasController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  final contatos = <_ContactControllers>[_ContactControllers()];
  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    await UserProfileService.syncCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    final saved = await UserProfileService.loadEmergencyContacts();
    if (!mounted) return;
    setState(() {
      _loading = false;
      nomeController.text = prefs.getString('nome') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      telefoneController.text = prefs.getString('telefone') ?? '';
      nascimentoController.text = prefs.getString('nascimento') ?? '';
      cidadeController.text = prefs.getString('cidade') ?? '';
      sangueController.text = prefs.getString('sangue') ?? '';
      alergiasController.text = prefs.getString('alergias') ?? '';
      medicamentosController.text = prefs.getString('medicamentos') ?? '';
      doencasController.text = prefs.getString('doencas') ?? '';
      for (final contact in contatos) {
        contact.dispose();
      }
      contatos
        ..clear()
        ..addAll(
          (saved.isEmpty
                  ? [
                      const EmergencyContact(
                        name: '',
                        phone: '',
                        relationship: '',
                      ),
                    ]
                  : saved)
              .map(_ContactControllers.fromContact),
        );
    });
  }

  Future<void> salvarDados() async {
    if (_loading || _saving) return;
    setState(() => _saving = true);
    try {
      await UserProfileService.saveCurrentProfile(
        nome: nomeController.text,
        email: emailController.text,
        telefone: telefoneController.text,
        nascimento: nascimentoController.text,
        cidade: cidadeController.text,
        sangue: sangueController.text,
        alergias: alergiasController.text,
        medicamentos: medicamentosController.text,
        doencas: doencasController.text,
        contatos: contatos
            .map((item) => item.toContact())
            .where((item) => !item.isEmpty)
            .toList(),
      );
      for (final contact in contatos) {
        contact.savedContact = contact.toContact();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: LocalizedText('Perfil de saúde salvo com sucesso!'),
          ),
        );
      }
    } catch (error) {
      final message =
          error is FirebaseException && error.code == 'permission-denied'
          ? 'Firestore: acesso negado ao salvar o perfil.'
          : 'Falha ao salvar. Verifique a conexão e tente novamente.';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: LocalizedText(message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    nascimentoController.dispose();
    cidadeController.dispose();
    sangueController.dispose();
    alergiasController.dispose();
    medicamentosController.dispose();
    doencasController.dispose();
    for (final contact in contatos) {
      contact.dispose();
    }
    super.dispose();
  }

  Future<void> _removeContact(int index) async {
    if (_saving) return;
    final removed = contatos[index];
    setState(() => _saving = true);
    try {
      final saved = removed.savedContact;
      if (saved != null) {
        await UserProfileService.removeEmergencyContact(saved);
      }
      if (!mounted) return;
      setState(() => contatos.removeAt(index));
      // Dispose after the fields using these controllers leave the tree.
      WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: LocalizedText('Contato removido.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: LocalizedText(
              'Não foi possível remover o contato. Tente novamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = dark ? AppColors.textPrimary : const Color(0xFF183B50);
    final secondary = dark ? AppColors.textMuted : const Color(0xFF638092);
    return Scaffold(
      backgroundColor: dark ? AppColors.bgDark : const Color(0xFFF3F8FA),
      appBar: sectionAppBar('Meu perfil'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AbsorbPointer(
              absorbing: _saving,
              child: Center(
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
                          LocalizedText(
                            'Informações importantes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LocalizedText(
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
                            label: 'E-mail',
                            controller: emailController,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Telefone da vítima',
                            controller: telefoneController,
                            hint: 'Ex: (35) 99999-9999',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Data de nascimento',
                            controller: nascimentoController,
                            hint: 'Ex: 31/12/2000',
                            icon: Icons.cake_outlined,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Cidade',
                            controller: cidadeController,
                            hint: 'Ex: Belo Horizonte',
                            icon: Icons.location_city_outlined,
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
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: LocalizedText(
                                  'Contatos de emergência',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => setState(
                                  () => contatos.add(_ContactControllers()),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const LocalizedText('Adicionar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(
                            contatos.length,
                            (index) => _contactForm(index),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save_outlined, size: 18),
                              label: LocalizedText(
                                _saving ? 'Salvando...' : 'Salvar perfil',
                              ),
                              onPressed: _saving ? null : salvarDados,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _contactForm(int index) => Padding(
    padding: EdgeInsets.only(bottom: index == contatos.length - 1 ? 0 : 16),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LocalizedText(
                  'Contato ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: tr(context, 'Remover contato'),
                onPressed: _saving ? null : () => _removeContact(index),
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.emergencyRed,
              ),
            ],
          ),
          AppTextField(
            label: 'Nome',
            controller: contatos[index].name,
            hint: 'Ex: Maria da Silva',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Telefone',
            controller: contatos[index].phone,
            hint: 'Ex: (35) 99999-9999',
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Grau de parentesco',
            controller: contatos[index].relationship,
            hint: 'Ex: Mãe, pai, cônjuge ou amigo',
            icon: Icons.family_restroom_outlined,
          ),
        ],
      ),
    ),
  );
}

class _ContactControllers {
  _ContactControllers({
    String name = '',
    String phone = '',
    String relationship = '',
  }) : name = TextEditingController(text: name),
       phone = TextEditingController(text: phone),
       relationship = TextEditingController(text: relationship);
  factory _ContactControllers.fromContact(EmergencyContact contact) =>
      _ContactControllers(
        name: contact.name,
        phone: contact.phone,
        relationship: contact.relationship,
      )..savedContact = contact;
  EmergencyContact? savedContact;
  final TextEditingController name, phone, relationship;
  EmergencyContact toContact() => EmergencyContact(
    name: name.text,
    phone: phone.text,
    relationship: relationship.text,
  );
  void dispose() {
    name.dispose();
    phone.dispose();
    relationship.dispose();
  }
}
