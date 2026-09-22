import '../l10n/localized_text.dart';
import 'package:flutter/material.dart';

const learningBlue = Color(0xFF217BA5);
const learningGreen = Color(0xFF2A9876);
const learningGold = Color(0xFFD99231);

Color learningMuted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF9AB9CD)
    : const Color(0xFF638092);

class LearningPanel extends StatelessWidget {
  const LearningPanel({
    super.key,
    required this.child,
    this.tint,
    this.padding = 20,
  });
  final Widget child;
  final Color? tint;
  final double padding;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color:
            tint?.withValues(alpha: dark ? .13 : .06) ??
            (dark ? const Color(0xFF102637) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              tint?.withValues(alpha: .25) ??
              (dark ? const Color(0xFF294E6B) : const Color(0xFFD7E5EB)),
        ),
      ),
      child: child,
    );
  }
}

class LearningAction extends StatelessWidget {
  const LearningAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: learningBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: LocalizedText(label, textAlign: TextAlign.center),
    ),
  );
}

class LearningHeading extends StatelessWidget {
  const LearningHeading(this.title, {super.key, this.subtitle, this.icon});
  final String title;
  final String? subtitle;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (icon != null) ...[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: learningBlue.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: learningBlue, size: 22),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocalizedText(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              LocalizedText(
                subtitle!,
                style: TextStyle(
                  color: learningMuted(context),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
