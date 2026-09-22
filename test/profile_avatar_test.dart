import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socorro_facil/widgets/profile_avatar.dart';

void main() {
  testWidgets('Foto persistida em data URI usa imagem em memoria', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileAvatar(
          photo:
              'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
        ),
      ),
    );
    expect(tester.widget<Image>(find.byType(Image)).image, isA<MemoryImage>());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Avatar sem foto preserva tamanho e icone', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileAvatar(radius: 27))),
    );
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(tester.getSize(find.byType(CircleAvatar)), const Size(54, 54));
  });

  testWidgets('Foto remota usa rede e falha retorna ao avatar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(photo: 'https://example.com/avatar.png'),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
