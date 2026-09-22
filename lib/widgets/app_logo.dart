import 'package:flutter/material.dart';
import '../l10n/language_controller.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * 0.2),
    child: Image.asset(
      'assets/icons/logo_header.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: tr(context, 'Logo SOPS'),
    ),
  );
}
