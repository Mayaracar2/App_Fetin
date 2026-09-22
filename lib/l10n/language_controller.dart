import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController {
  static final locale = ValueNotifier(const Locale('pt', 'BR'));
  static const supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('es', 'ES'),
  ];
  static final _catalogs = <String, Map<String, String>>{};
  static final _templates = <String, List<_Template>>{};

  static Future<void> initialize() async {
    for (final code in ['pt', 'en', 'es']) {
      final json =
          jsonDecode(await rootBundle.loadString('assets/i18n/$code.json'))
              as Map;
      _catalogs[code] = json.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
      _templates[code] =
          _catalogs[code]!.entries
              .where((entry) => RegExp(r'\{\d+\}').hasMatch(entry.key))
              .map((entry) => _Template(entry.key, entry.value))
              .toList()
            ..sort((a, b) => b.source.length.compareTo(a.source.length));
    }
    final prefs = await SharedPreferences.getInstance();
    locale.value = fromCode(prefs.getString('language') ?? 'pt_BR');
  }

  static Locale fromCode(String code) => supportedLocales.firstWhere(
    (value) => value.toString() == code,
    orElse: () => supportedLocales.first,
  );

  static Future<void> setLanguage(String code) async {
    final next = fromCode(code);
    await (await SharedPreferences.getInstance()).setString(
      'language',
      next.toString(),
    );
    locale.value = next;
  }

  static String translate(String value, [String? language]) {
    final code = language ?? locale.value.languageCode;
    if (code == 'pt' || value.isEmpty) return value;
    final catalog = _catalogs[code];
    if (catalog == null) return value;
    final exact = catalog[value];
    if (exact != null) return exact;
    if (value.contains('\n')) {
      return value.split('\n').map((line) => translate(line, code)).join('\n');
    }
    // Labels rendered in uppercase still use the same source translation.
    if (value == value.toUpperCase()) {
      for (final entry in catalog.entries) {
        if (entry.key.toUpperCase() == value) return entry.value.toUpperCase();
      }
    }
    for (final template in _templates[code] ?? <_Template>[]) {
      final match = template.pattern.firstMatch(value);
      if (match != null) {
        return template.target.replaceAllMapped(RegExp(r'\{(\d+)\}'), (token) {
          final index = int.parse(token[1]!);
          final argument = match.group(index + 1) ?? '';
          return catalog[argument] ?? argument;
        });
      }
    }
    // Preserve separators used in compact labels and emergency card headings.
    for (final separator in [' · ', '\n']) {
      if (value.contains(separator)) {
        return value
            .split(separator)
            .map((part) => translate(part, code))
            .join(separator);
      }
    }
    return value;
  }
}

String tr(BuildContext context, String value) => LanguageController.translate(
  value,
  Localizations.localeOf(context).languageCode,
);

/// User-provided health data and names are never translated.
String profileText(BuildContext context, String value) =>
    value == 'Não informado' || value == 'Usuário' ? tr(context, value) : value;

class _Template {
  _Template(this.source, this.target) {
    final buffer = StringBuffer('^');
    var end = 0;
    for (final match in RegExp(r'\{\d+\}').allMatches(source)) {
      buffer.write(RegExp.escape(source.substring(end, match.start)));
      buffer.write(source == '{0} de {1}' ? r'(\d+)' : '(.*?)');
      end = match.end;
    }
    buffer.write(RegExp.escape(source.substring(end)));
    buffer.write(r'$');
    pattern = RegExp(buffer.toString(), dotAll: true);
  }
  final String source, target;
  late final RegExp pattern;
}
