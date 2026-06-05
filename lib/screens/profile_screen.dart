import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Widget campo({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon == null ? null : Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Meu Perfil de Saúde"),
        backgroundColor: const Color(0xFFD92D20),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.medical_information,
                  color: Color(0xFFD92D20),
                  size: 70,
                ),

                const SizedBox(height: 10),

                const Text(
                  "Informações importantes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Esses dados podem ajudar em uma emergência.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                campo(
                  label: "Nome completo",
                  controller: nomeController,
                  icon: Icons.person,
                ),

                campo(
                  label: "Tipo sanguíneo",
                  controller: sangueController,
                  hint: "Ex: O+, A-, B+",
                  icon: Icons.bloodtype,
                ),

                campo(
                  label: "Alergias",
                  controller: alergiasController,
                  hint: "Ex: Penicilina, Dipirona",
                  icon: Icons.warning_amber,
                ),

                campo(
                  label: "Medicamentos em uso",
                  controller: medicamentosController,
                  hint: "Ex: Losartana, Insulina",
                  icon: Icons.medication,
                ),

                campo(
                  label: "Doenças ou condições",
                  controller: doencasController,
                  hint: "Ex: Diabetes, Hipertensão, Asma",
                  icon: Icons.health_and_safety,
                ),

                campo(
                  label: "Contato de emergência",
                  controller: contatoController,
                  hint: "Ex: (35) 99999-9999",
                  icon: Icons.phone,
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Salvar Perfil",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD92D20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: salvarDados,
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
