import 'package:flutter/material.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  final List<Map<String, String>> videos = const [
    {
      'titulo': 'Engasgo',
      'descricao': 'Aprenda o que fazer em casos de engasgo.',
      'icone': '😮‍💨',
      'tempo': '6 min',
    },
    {
      'titulo': 'RCP',
      'descricao': 'Reanimação cardiopulmonar passo a passo.',
      'icone': '❤️',
      'tempo': '12 min',
    },
    {
      'titulo': 'Queimaduras',
      'descricao': 'Cuidados iniciais em queimaduras leves.',
      'icone': '🔥',
      'tempo': '8 min',
    },
    {
      'titulo': 'Desmaio',
      'descricao': 'Como agir quando alguém desmaia.',
      'icone': '💫',
      'tempo': '7 min',
    },
    {
      'titulo': 'Hemorragia',
      'descricao': 'Como controlar sangramentos externos.',
      'icone': '🩸',
      'tempo': '5 min',
    },
    {
      'titulo': 'Fraturas',
      'descricao': 'Cuidados básicos até o socorro chegar.',
      'icone': '🦴',
      'tempo': '9 min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Primeiros Socorros"),
        backgroundColor: const Color(0xFFD92D20),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFEE4E2),
                child: Text(
                  video['icone']!,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              title: Text(
                video['titulo']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text('${video['descricao']} • ${video['tempo']}'),
              trailing: const Icon(
                Icons.play_circle_fill,
                color: Color(0xFFD92D20),
                size: 34,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Abrindo vídeo: ${video['titulo']}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
