import 'package:flutter/material.dart';

// Source: S.O.P.S.-Fetin-project-2026/frontend/src/data/lessons.js
// Commit: 26a0e870a2933fd63c862013917f8d837bfd4dc2
class FirstAidVideo {
  const FirstAidVideo({
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.icon,
    required this.color,
    required this.youtubeId,
  });

  final String youtubeId;
  String get level => switch (category) {
    'Emergências' => 'Essencial',
    'Casa e família' => 'Prático',
    'Prevenção' => 'Prevenção',
    _ => 'Bem-estar',
  };
  String get thumbnailUrl => 'https://i.ytimg.com/vi/$youtubeId/hqdefault.jpg';
  Uri get youtubeUrl =>
      Uri.https('www.youtube.com', '/watch', {'v': youtubeId});
  final String title;
  final String description;
  final String duration;
  final String category;
  final IconData icon;
  final Color color;
}

const firstAidVideos = [
  FirstAidVideo(
    title: 'RCP em adultos: o que fazer?',
    description:
        'Aprenda orientações educativas sobre ressuscitação cardiopulmonar (rcp) e saiba quando buscar ajuda profissional.',
    duration: '2:45',
    category: 'Emergências',
    youtubeId: 'gGE18Z2IaBk',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'Como salvar uma pessoa engasgada',
    description:
        'Aprenda orientações educativas sobre engasgo em adultos e saiba quando buscar ajuda profissional.',
    duration: '3:39',
    category: 'Emergências',
    youtubeId: 'C2c0BIJygYI',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'O que fazer quando um bebê está engasgado?',
    description:
        'Aprenda orientações educativas sobre engasgo em bebês e saiba quando buscar ajuda profissional.',
    duration: '2:35',
    category: 'Emergências',
    youtubeId: 'HBKRny2tAus',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'O que fazer durante uma convulsão?',
    description:
        'Aprenda orientações educativas sobre convulsão e saiba quando buscar ajuda profissional.',
    duration: '2:45',
    category: 'Emergências',
    youtubeId: 'H9rpKcW22fg',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'Primeiros socorros em caso de desmaio',
    description:
        'Aprenda orientações educativas sobre desmaio e saiba quando buscar ajuda profissional.',
    duration: '0:44',
    category: 'Emergências',
    youtubeId: 'Q8T2ukSKnDQ',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'Primeiros socorros para queimaduras',
    description:
        'Aprenda orientações educativas sobre queimaduras e saiba quando buscar ajuda profissional.',
    duration: '1:41',
    category: 'Emergências',
    youtubeId: 'hDGkiZD_f7k',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'Choque elétrico ou eletrocussão',
    description:
        'Aprenda orientações educativas sobre choque elétrico e saiba quando buscar ajuda profissional.',
    duration: '2:03',
    category: 'Emergências',
    youtubeId: 'g4-hHMjkeR4',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'Afogamento: primeiros socorros',
    description:
        'Aprenda orientações educativas sobre afogamento e saiba quando buscar ajuda profissional.',
    duration: '2:32',
    category: 'Emergências',
    youtubeId: 'CiBaKoPl4IM',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'Como ajudar alguém durante um AVC?',
    description:
        'Aprenda orientações educativas sobre acidente vascular cerebral (avc) e saiba quando buscar ajuda profissional.',
    duration: '1:59',
    category: 'Emergências',
    youtubeId: 'd2seL0rlEq8',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'Hemorragia: primeiros socorros',
    description:
        'Aprenda orientações educativas sobre hemorragia e saiba quando buscar ajuda profissional.',
    duration: '1:35',
    category: 'Emergências',
    youtubeId: '2IEJyLwoxpw',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF0D7797),
  ),
  FirstAidVideo(
    title: 'Como montar um kit de primeiros socorros',
    description:
        'Aprenda orientações educativas sobre kit de primeiros socorros e saiba quando buscar ajuda profissional.',
    duration: '3:37',
    category: 'Casa e família',
    youtubeId: 'y7NNuF9YszQ',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Acidentes domésticos envolvendo crianças',
    description:
        'Aprenda orientações educativas sobre acidentes domésticos com crianças e saiba quando buscar ajuda profissional.',
    duration: '4:30',
    category: 'Casa e família',
    youtubeId: 'VoVzWeUmLp8',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'O que fazer em casos de intoxicação',
    description:
        'Aprenda orientações educativas sobre intoxicação doméstica e saiba quando buscar ajuda profissional.',
    duration: '2:55',
    category: 'Casa e família',
    youtubeId: 'g5YkyLPEESA',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Prevenção contra o risco de quedas',
    description:
        'Aprenda orientações educativas sobre quedas dentro de casa e saiba quando buscar ajuda profissional.',
    duration: '2:44',
    category: 'Casa e família',
    youtubeId: 'V1jrfejrkcc',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Como evitar queimaduras domésticas',
    description:
        'Aprenda orientações educativas sobre queimaduras domésticas e saiba quando buscar ajuda profissional.',
    duration: '2:00',
    category: 'Casa e família',
    youtubeId: '4A9Px8ZNCvg',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Onde guardar seus medicamentos',
    description:
        'Aprenda orientações educativas sobre armazenamento de medicamentos e saiba quando buscar ajuda profissional.',
    duration: '1:03',
    category: 'Casa e família',
    youtubeId: 'q71tj-xqpPg',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Picada de inseto: o que fazer?',
    description:
        'Aprenda orientações educativas sobre picadas de insetos e saiba quando buscar ajuda profissional.',
    duration: '0:45',
    category: 'Casa e família',
    youtubeId: 'vUhBvsuoCoM',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Febre em crianças: dicas importantes',
    description:
        'Aprenda orientações educativas sobre febre em crianças e saiba quando buscar ajuda profissional.',
    duration: '1:44',
    category: 'Casa e família',
    youtubeId: 'iTkamAwtCeI',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Como prevenir afogamentos de crianças',
    description:
        'Aprenda orientações educativas sobre afogamento de bebês e crianças e saiba quando buscar ajuda profissional.',
    duration: '5:08',
    category: 'Casa e família',
    youtubeId: 'pxYJBRpMo48',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Cuidados ao brincar perto da rede elétrica',
    description:
        'Aprenda orientações educativas sobre segurança elétrica para crianças e saiba quando buscar ajuda profissional.',
    duration: '1:02',
    category: 'Casa e família',
    youtubeId: 'ic5UVLXemaE',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFFE4943A),
  ),
  FirstAidVideo(
    title: 'Como higienizar as mãos corretamente?',
    description:
        'Aprenda orientações educativas sobre higienização das mãos e saiba quando buscar ajuda profissional.',
    duration: '2:07',
    category: 'Prevenção',
    youtubeId: 'ErLIEZuP_4g',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'Dengue: como prevenir',
    description:
        'Aprenda orientações educativas sobre prevenção da dengue e saiba quando buscar ajuda profissional.',
    duration: '1:13',
    category: 'Prevenção',
    youtubeId: '1sRy50J5eeU',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'A importância das vacinas',
    description:
        'Aprenda orientações educativas sobre vacinação e saiba quando buscar ajuda profissional.',
    duration: '1:47',
    category: 'Prevenção',
    youtubeId: 'UebqmrQLI7M',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'Prevenção e tratamento da pressão alta',
    description:
        'Aprenda orientações educativas sobre hipertensão e saiba quando buscar ajuda profissional.',
    duration: '4:28',
    category: 'Prevenção',
    youtubeId: 'vdcBaZffavg',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'Prevenção e tratamento do diabetes',
    description:
        'Aprenda orientações educativas sobre diabetes e saiba quando buscar ajuda profissional.',
    duration: '4:41',
    category: 'Prevenção',
    youtubeId: 'HroD07UGp2E',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'Filtro solar previne câncer de pele?',
    description:
        'Aprenda orientações educativas sobre câncer de pele e saiba quando buscar ajuda profissional.',
    duration: '0:33',
    category: 'Prevenção',
    youtubeId: 'OfnKXTL_X1M',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'Prevenção combinada de IST, HIV e AIDS',
    description:
        'Aprenda orientações educativas sobre infecções sexualmente transmissíveis e saiba quando buscar ajuda profissional.',
    duration: '3:03',
    category: 'Prevenção',
    youtubeId: 'gxr9cXUi7jc',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'Como escovar os dentes corretamente',
    description:
        'Aprenda orientações educativas sobre saúde bucal e saiba quando buscar ajuda profissional.',
    duration: '1:25',
    category: 'Prevenção',
    youtubeId: 'L_lbIz_Bv3Y',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'Por que a atividade física faz bem?',
    description:
        'Aprenda orientações educativas sobre atividade física e saiba quando buscar ajuda profissional.',
    duration: '1:49',
    category: 'Prevenção',
    youtubeId: 'I5AGYOjfZiE',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: '10 passos para uma alimentação saudável',
    description:
        'Aprenda orientações educativas sobre alimentação saudável e saiba quando buscar ajuda profissional.',
    duration: '2:34',
    category: 'Prevenção',
    youtubeId: '4RGr1lcUSq0',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF319875),
  ),
  FirstAidVideo(
    title: 'Exercício respiratório para controlar a ansiedade',
    description:
        'Aprenda orientações educativas sobre ansiedade e saiba quando buscar ajuda profissional.',
    duration: '0:53',
    category: 'Saúde mental',
    youtubeId: 'ZuOFypJrrXo',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Síndrome do pânico: como reconhecer',
    description:
        'Aprenda orientações educativas sobre síndrome do pânico e saiba quando buscar ajuda profissional.',
    duration: '4:01',
    category: 'Saúde mental',
    youtubeId: 'thsBnZyUJns',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Depressão: sinais de alerta',
    description:
        'Aprenda orientações educativas sobre depressão e saiba quando buscar ajuda profissional.',
    duration: '1:11',
    category: 'Saúde mental',
    youtubeId: 'gUNgaol0vPk',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Cuidados com a saúde mental',
    description:
        'Aprenda orientações educativas sobre autocuidado e saiba quando buscar ajuda profissional.',
    duration: '0:37',
    category: 'Saúde mental',
    youtubeId: 'zq8HBFySxow',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Dicas para aliviar o estresse',
    description:
        'Aprenda orientações educativas sobre estresse e saiba quando buscar ajuda profissional.',
    duration: '2:28',
    category: 'Saúde mental',
    youtubeId: 'lzfz3OUzFp8',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Higiene do sono: como dormir melhor',
    description:
        'Aprenda orientações educativas sobre qualidade do sono e saiba quando buscar ajuda profissional.',
    duration: '0:58',
    category: 'Saúde mental',
    youtubeId: 'Bs_16H4swao',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Burnout: como reconhecer os sinais?',
    description:
        'Aprenda orientações educativas sobre síndrome de burnout e saiba quando buscar ajuda profissional.',
    duration: '2:07',
    category: 'Saúde mental',
    youtubeId: 'Eqjqwrm1mfA',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Pessoas precisam de pessoas',
    description:
        'Aprenda orientações educativas sobre apoio emocional e saiba quando buscar ajuda profissional.',
    duration: '2:08',
    category: 'Saúde mental',
    youtubeId: 'eP_eQ0lCY40',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Mindfulness no cuidado com a saúde',
    description:
        'Aprenda orientações educativas sobre mindfulness e saiba quando buscar ajuda profissional.',
    duration: '4:20',
    category: 'Saúde mental',
    youtubeId: 'd4PombPnT3k',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
  FirstAidVideo(
    title: 'Diferença entre psicologia e psiquiatria',
    description:
        'Aprenda orientações educativas sobre psicologia e psiquiatria e saiba quando buscar ajuda profissional.',
    duration: '3:03',
    category: 'Saúde mental',
    youtubeId: 'APreIaZhmuM',
    icon: Icons.play_lesson_outlined,
    color: Color(0xFF8A6DAD),
  ),
];
