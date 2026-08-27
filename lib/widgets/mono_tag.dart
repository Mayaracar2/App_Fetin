import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class MonoTag extends StatelessWidget {
  const MonoTag(
    this.text, {
    super.key,
    this.color = AppColors.accentCyan,
    this.fontSize = 10,
    this.asChip = false,
  });

  final String text;
  final Color color;
  final double fontSize;
  final bool asChip;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = !dark && color == AppColors.accentCyan
        ? AppColors.accentBlue
        : color;
    final label = Text(
      text.toUpperCase(),
      style: monoStyle(fontSize: fontSize, color: effectiveColor),
    );

    if (!asChip) return label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? AppColors.bgField : const Color(0xFFEDF8FC),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: dark ? AppColors.border : const Color(0xFFC9DCE7),
        ),
      ),
      child: label,
    );
  }
}
