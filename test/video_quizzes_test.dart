import 'package:flutter_test/flutter_test.dart';
import 'package:socorro_facil/data/first_aid_videos.dart';
import 'package:socorro_facil/data/video_quizzes.dart';

void main() {
  test(
    'Planilha cobre os 40 videos, com cinco questoes e gabaritos validos',
    () {
      expect(videoQuizzes.length, firstAidVideos.length);
      for (final video in firstAidVideos) {
        final questions = videoQuizzes[video.youtubeId]!;
        expect(questions, hasLength(5));
        for (final question in questions) {
          expect(question.text, isNotEmpty);
          expect(question.options, hasLength(4));
          expect(question.answer, inInclusiveRange(0, 3));
          expect(question.options.every((value) => value.isNotEmpty), isTrue);
        }
      }
    },
  );
}
