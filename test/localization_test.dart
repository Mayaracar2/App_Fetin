import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socorro_facil/data/first_aid_videos.dart';
import 'package:socorro_facil/data/video_quizzes.dart';
import 'package:socorro_facil/l10n/language_controller.dart';
import 'package:socorro_facil/l10n/localized_text.dart';
import 'package:socorro_facil/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LanguageController.initialize();
  });

  test(
    'Catálogos completos: aulas, perguntas, alternativas e parâmetros',
    () async {
      final source =
          jsonDecode(await rootBundle.loadString('assets/i18n/pt.json')) as Map;
      for (final code in ['en', 'es']) {
        final target =
            jsonDecode(await rootBundle.loadString('assets/i18n/$code.json'))
                as Map;
        for (final key in source.keys.cast<String>()) {
          expect(target[key], isA<String>(), reason: '$code: $key');
          expect((target[key] as String).trim(), isNotEmpty, reason: key);
          final args = RegExp(r'\{\d+\}');
          expect(
            args.allMatches(target[key]).map((m) => m[0]).toSet(),
            args.allMatches(key).map((m) => m[0]).toSet(),
            reason: key,
          );
        }
        for (final video in firstAidVideos) {
          for (final text in [
            video.title,
            video.description,
            video.category,
            video.level,
          ]) {
            expect(target.containsKey(text), isTrue, reason: '$code: $text');
          }
          for (final question in videoQuizzes[video.youtubeId]!) {
            for (final text in [question.text, ...question.options]) {
              if (RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(text)) {
                expect(
                  target.containsKey(text),
                  isTrue,
                  reason: '$code: $text',
                );
              } else {
                expect(LanguageController.translate(text, code), text);
              }
            }
          }
        }
      }
    },
  );

  test('Idioma persistido e código inválido volta ao português', () async {
    await LanguageController.setLanguage('es_ES');
    expect(
      (await SharedPreferences.getInstance()).getString('language'),
      'es_ES',
    );
    LanguageController.locale.value = const Locale('pt', 'BR');
    await LanguageController.initialize();
    expect(LanguageController.locale.value.languageCode, 'es');
    await LanguageController.setLanguage('invalid');
    expect(LanguageController.locale.value.languageCode, 'pt');
  });

  test('Mensagens dinâmicas traduzem gabarito sem alterar dados do perfil', () {
    expect(
      LanguageController.translate('Maria de Souza', 'en'),
      'Maria de Souza',
    );
    expect(
      LanguageController.translate('PERGUNTA 2 DE 5', 'en'),
      'QUESTION 2 OF 5',
    );
    expect(
      LanguageController.translate('3 de 40 aulas', 'es'),
      '3 de 40 lecciones',
    );
    expect(
      LanguageController.translate('Gabarito: Não informado', 'en'),
      'Correct answer: Not provided',
    );
    expect(
      LanguageController.translate('Matheus Silva (Tati · 35999999999)', 'es'),
      'Matheus Silva (Tati · 35999999999)',
    );
    expect(LanguageController.translate('Digite EXCLUIR', 'en'), 'Type DELETE');
    expect(LanguageController.translate('EXCLUIR', 'es'), 'ELIMINAR');
  });

  testWidgets('Seleção atualiza tela aberta e rota anterior sem reiniciar', (
    tester,
  ) async {
    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: LanguageController.locale,
        builder: (context, locale, _) => MaterialApp(
          locale: locale,
          supportedLocales: LanguageController.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  const LocalizedText('Meu perfil'),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LanguageScreen(),
                      ),
                    ),
                    child: const Text('Open language'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Meu perfil'), findsOneWidget);
    await tester.tap(find.text('Open language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('My profile'), findsOneWidget);
    await tester.tap(find.text('Open language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Mi perfil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
