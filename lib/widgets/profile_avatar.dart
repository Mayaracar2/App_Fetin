import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.photo,
    this.radius = 20,
    this.backgroundColor,
    this.icon = Icons.person,
    this.iconColor,
    this.iconSize = 24,
  });

  final String? photo;
  final double radius;
  final Color? backgroundColor;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(icon, color: iconColor, size: iconSize);
    final source = photo?.trim() ?? '';
    final uri = Uri.tryParse(source);
    Widget content = fallback;
    if (source.isNotEmpty) {
      if (uri?.scheme == 'https' ||
          uri?.scheme == 'http' ||
          (kIsWeb && uri?.scheme == 'blob')) {
        content = Image.network(
          source,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stack) => fallback,
        );
      } else if (!kIsWeb) {
        content = FutureBuilder<Uint8List>(
          future: XFile(source).readAsBytes(),
          builder: (context, snapshot) => snapshot.hasData
              ? Image.memory(
                  snapshot.data!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stack) => fallback,
                )
              : fallback,
        );
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(child: content),
    );
  }
}
