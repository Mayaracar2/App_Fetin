# Textos do aplicativo

Os catálogos `assets/i18n/{pt,en,es}.json` são empacotados no app. A troca
de idioma funciona sem rede, preserva as rotas abertas e fica salva na
preferência `language`. IDs de vídeos, campos do Firestore e respostas
corretas permanecem independentes do idioma.

`LocalizedText` traduz o texto da interface e constrói um `Text` padrão.
Para tooltips, campos de formulário e outros atributos, use `tr(context, texto)`.
Não use a tradução para IDs, chaves de armazenamento ou valores editáveis.

Para atualizar os catálogos, execute `node tools/localization/build_catalog.cjs`.
Este comando usa Google Translate apenas durante a geração para os textos
estáticos novos do código; não lê contas, dados do Firebase nem formulários.
Revise as traduções antes de publicar. Ajustes de terminologia ficam em
`overrides.json` e têm prioridade sobre a geração automática.

Execute `flutter test test/localization_test.dart` para validar cobertura dos
catálogos, parâmetros, aulas, quizzes, persistência e troca entre rotas.
Os vídeos externos mantêm seu áudio original; o player recebe a preferência
de idioma para os controles e as legendas disponíveis.
