import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Widget infoItem(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(texto, style: const TextStyle(fontSize: 16)),
    );
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Emergência"),
        backgroundColor: const Color(0xFFD92D20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.medical_information, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            "Informações Médicas",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      infoItem("👤 Nome: $nome"),
                      infoItem("🩸 Tipo Sanguíneo: $sangue"),
                      infoItem("⚠️ Alergias: $alergias"),
                      infoItem("💊 Medicamentos: $medicamentos"),
                      infoItem("🩺 Condições: $doencas"),
                      infoItem("📞 Contato: $contato"),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.local_hospital),
                    label: const Text(
                      "Ligar para o SAMU (192)",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      mostrarMensagem("Ligação para o SAMU simulada");
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.location_on),
                    label: const Text(
                      "Compartilhar Localização",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      mostrarMensagem("Localização compartilhada simulada");
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.contact_phone),
                    label: const Text(
                      "Contato de Emergência",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      mostrarMensagem("Ligando para: $contato");
                    },
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
