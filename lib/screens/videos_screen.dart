import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  final List<Map<String, String>> videos = const [
    {
      'titulo': 'Engasgo',
      'descricao': 'Aprenda o que fazer em casos de engasgo.',
      'icone': '😮‍💨',
      'tempo': '6 min',
      'categoria': 'Essencial',
    },
    {
      'titulo': 'RCP',
      'descricao': 'Reanimação cardiopulmonar passo a passo.',
      'icone': '❤️',
      'tempo': '12 min',
      'categoria': 'Fundamental',
    },
    {
      'titulo': 'Queimaduras',
      'descricao': 'Cuidados iniciais em queimaduras leves.',
      'icone': '🔥',
      'tempo': '8 min',
      'categoria': 'Básico',
    },
    {
      'titulo': 'Desmaio',
      'descricao': 'Como agir quando alguém desmaia.',
      'icone': '💫',
      'tempo': '7 min',
      'categoria': 'Básico',
    },
    {
      'titulo': 'Hemorragia',
      'descricao': 'Como controlar sangramentos externos.',
      'icone': '🩸',
      'tempo': '5 min',
      'categoria': 'Essencial',
    },
    {
      'titulo': 'Fraturas',
      'descricao': 'Cuidados básicos até o socorro chegar.',
      'icone': '🦴',
      'tempo': '9 min',
      'categoria': 'Fundamental',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'PRIMEIROS SOCORROS',
          style: monoStyle(fontSize: 11.5, color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Abrindo vídeo: ${video['titulo']}"),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.bgPanelAlt,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          video['icone']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  video['titulo']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgField,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    video['categoria']!.toUpperCase(),
                                    style: monoStyle(
                                      fontSize: 8.5,
                                      color: AppColors.accentCyan,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${video['descricao']} • ${video['tempo']}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.accentBlueLight,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
