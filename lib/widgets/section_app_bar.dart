import '../l10n/localized_text.dart';
import 'package:flutter/material.dart';

AppBar sectionAppBar(String title, {List<Widget>? actions, Widget? logo}) =>
    AppBar(
      backgroundColor: const Color(0xFF17354B),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          if (logo != null) ...[logo, const SizedBox(width: 10)],
          Expanded(
            child: LocalizedText(
              title,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: actions,
    );
