import 'package:flutter_test/flutter_test.dart';
import 'package:socorro_facil/data/first_aid_videos.dart';

void main() {
  test('Catalogo do site inclui os 40 videos com links validos', () {
    expect(firstAidVideos, hasLength(40));
    expect(firstAidVideos.map((video) => video.category).toSet(), hasLength(4));
    for (final video in firstAidVideos) {
      expect(video.title.trim(), isNotEmpty);
      expect(video.youtubeId, matches(RegExp(r'^[a-zA-Z0-9_-]{11}$')));
      expect(video.youtubeUrl.host, 'www.youtube.com');
      expect(video.youtubeUrl.queryParameters['v'], video.youtubeId);
    }
  });
}
