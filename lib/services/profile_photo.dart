import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

class ProfilePhoto {
  ProfilePhoto._();

  static Future<String> prepare(String source) async {
    final uri = Uri.tryParse(source);
    if (uri?.scheme == 'https' || uri?.scheme == 'http') return source;
    final bytes = uri?.scheme == 'data'
        ? uri!.data!.contentAsBytes()
        : await XFile(source).readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 256,
      allowUpscaling: false,
    );
    try {
      final frame = await codec.getNextFrame();
      try {
        final png = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (png == null || png.lengthInBytes > 600 * 1024) {
          throw const FormatException(
            'Imagem muito grande. Escolha outra foto.',
          );
        }
        return Uri.dataFromBytes(
          png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
          mimeType: 'image/png',
        ).toString();
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }
}
