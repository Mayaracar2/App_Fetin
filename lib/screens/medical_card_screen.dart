import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cor.withValues(alpha: 0.12),
            child: Icon(icon, color: cor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Carteira Médica"),
        backgroundColor: const Color(0xFFD92D20),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD92D20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 55,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "SOCORRO FÁCIL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Carteira Médica de Emergência",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                linha("Nome", nome, Icons.person, Colors.blue),
                linha("Tipo sanguíneo", sangue, Icons.bloodtype, Colors.red),
                linha("Alergias", alergias, Icons.warning_amber, Colors.orange),
                linha(
                  "Medicamentos",
                  medicamentos,
                  Icons.medication,
                  Colors.purple,
                ),
                linha(
                  "Condições",
                  doencas,
                  Icons.medical_information,
                  Colors.green,
                ),
                linha(
                  "Contato de emergência",
                  contato,
                  Icons.phone,
                  Colors.teal,
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Text(
                    "Em caso de emergência, utilize estas informações para auxiliar no atendimento inicial.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD92D20),
                      fontWeight: FontWeight.w600,
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
