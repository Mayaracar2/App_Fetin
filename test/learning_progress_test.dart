import 'package:flutter_test/flutter_test.dart';
import 'package:socorro_facil/data/first_aid_videos.dart';
import 'package:socorro_facil/services/learning_progress_service.dart';

void main() {
  test('Progresso geral inclui videos parciais e nao assistidos', () {
    expect(LearningProgressService.overallProgress({}), 0);
    expect(
      LearningProgressService.overallProgress({1: 100, 2: 50, 9999: 100}),
      closeTo(150 / (firstAidVideos.length * 100), .000001),
    );
    expect(
      LearningProgressService.overallProgress({
        for (var id = 1; id <= firstAidVideos.length; id++) id: 100,
      }),
      1,
    );
  });
  test('100% conclui a aula como no site, incluindo dados antigos', () {
    expect(
      LearningProgressService.completedLessons({
        'progressoAulas': {
          '1': {'progress': 100, 'completed': false},
          '2': {'progress': 100, 'completed': true},
          '3': 100,
        },
      }),
      {1, 2, 3},
    );
  });
  test('Le progresso do site nos formatos antigo e atual', () {
    expect(
      LearningProgressService.decode({
        'progressoAulas': {
          '1': {'progress': 65, 'completed': false},
          '2': {'progress': 100, 'completed': true},
          '3': 20,
          'invalid': {'progress': 80},
          '4': {'progress': 'invalid'},
        },
      }),
      {1: 65, 2: 100, 3: 20},
    );
  });
  test('Perfil novo e valores fora do intervalo', () {
    expect(LearningProgressService.decode(null), isEmpty);
    expect(
      LearningProgressService.decode({
        'progressoAulas': {'1': -10, '2': 120},
      }),
      {1: 0, 2: 100},
    );
  });
}
