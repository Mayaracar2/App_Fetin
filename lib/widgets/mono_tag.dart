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
    final label = Text(
      text.toUpperCase(),
      style: monoStyle(fontSize: fontSize, color: color),
    );

    if (!asChip) return label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgField,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.border),
      ),
      child: label,
    );
  }
}
