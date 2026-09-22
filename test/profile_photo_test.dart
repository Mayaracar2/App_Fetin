import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:socorro_facil/services/profile_photo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Foto local vira imagem persistente independente do caminho', () async {
    final directory = await Directory.systemTemp.createTemp(
      'profile_photo_test',
    );
    addTearDown(() => directory.delete(recursive: true));
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(32, 32);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    final file = await File(
      '${directory.path}/photo.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    final photo = await ProfilePhoto.prepare(file.path);
    await file.delete();
    expect(photo, startsWith('data:image/png;base64,'));
    expect(Uri.parse(photo).data!.contentAsBytes(), isNotEmpty);
    expect(await ProfilePhoto.prepare(photo), photo);
  });

  test('URL remota existente permanece compativel', () async {
    const url = 'https://example.com/avatar.png';
    expect(await ProfilePhoto.prepare(url), url);
  });
}
