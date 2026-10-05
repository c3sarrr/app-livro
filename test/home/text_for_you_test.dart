import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/home/application/formatters.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/for_you_section.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// Todos os textos da seção, na ordem da tabela "Linhas de texto" da F08.
const _textIds = [
  'forYou.title',
  'forYou.seeAll',
  'forYou.reasonChip',
  'forYou.item1.cover.title',
  'forYou.item1.cover.author',
  'forYou.item1.title',
  'forYou.item1.author',
  'forYou.item2.cover.title',
  'forYou.item2.cover.author',
  'forYou.item2.title',
  'forYou.item2.author',
  'forYou.item3.cover.title',
  'forYou.item3.cover.author',
  'forYou.item3.title',
  'forYou.item3.author',
];

/// Linhas da tabela da F08 (relativas à seção): texto, baseline, início, fim e largura.
const _tableLines = <String, List<(String, double, double, double, double)>>{
  'forYou.title': [('Para você', 29.92, 0, 109.35, 109.35)],
  'forYou.seeAll': [('Ver tudo', 26.9, 272.01, 328, 55.99)],
  'forYou.reasonChip': [
    ('Porque você lê Machado de Assis', 78.85, 31.5, 227.78, 196.28),
  ],
  'forYou.item1.cover.title': [
    ('Memórias', 141.58, 17.5, 81.53, 64.03),
    ('Póstumas de', 159.63, 17.5, 98.48, 80.98),
    ('Brás Cubas', 177.68, 17.5, 88.31, 70.81),
  ],
  'forYou.item1.cover.author': [
    ('MACHADO DE ASSIS', 267.46, 17.5, 95.83, 78.33),
  ],
  'forYou.item1.title': [('Memórias Póstu…', 305.9, 0, 112.88, 112.88)],
  'forYou.item1.author': [('Machado de Assis', 323.75, 0, 105.31, 105.31)],
  'forYou.item2.cover.title': [
    ('Quincas', 229.03, 147.5, 218.35, 70.85),
    ('Borba', 252.43, 147.5, 200.9, 53.4),
  ],
  'forYou.item2.cover.author': [
    ('MACHADO DE ASSIS', 267.46, 147.5, 225.82, 78.32),
  ],
  'forYou.item2.title': [('Quincas Borba', 305.9, 130, 223.39, 93.39)],
  'forYou.item2.author': [('Machado de Assis', 323.75, 130, 235.31, 105.31)],
  'forYou.item3.cover.title': [('O Cortiço', 252.43, 277.5, 359.27, 81.77)],
  'forYou.item3.cover.author': [
    ('ALUÍSIO AZEVEDO', 267.46, 277.5, 348.99, 71.49),
  ],
  'forYou.item3.title': [('O Cortiço', 305.9, 260, 323.01, 63.01)],
  'forYou.item3.author': [('Aluísio Azevedo', 323.75, 260, 353.41, 93.41)],
};

Offset _sectionOrigin(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(const ValueKey('forYou')));

AppText _textWidget(WidgetTester tester, String id) => tester.widget<AppText>(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  ),
);

/// Texto puro do span inteiro (raiz e filhos): é o que o `AppText` diagrama e pinta.
String _textOf(WidgetTester tester, String id) =>
    _textWidget(tester, id).span.toPlainText();

RenderAppText _renderOf(WidgetTester tester, String id) =>
    tester.renderObject<RenderAppText>(
      find.descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(AppText),
        matchRoot: true,
      ),
    );

/// Dados que a seção lê (o mesmo `homeSnapshotProvider` do app montado).
ForYou _forYouData(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(ForYouSection)),
  listen: false,
).read(homeSnapshotProvider).forYou!;

/// Largura natural (uma linha) de [text] no parágrafo do SkParagraph (inclui o letter-spacing final).
double _naturalWidth(TextStyle style, String text) {
  final builder =
      ui.ParagraphBuilder(
          style.getParagraphStyle(
            textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        )
        ..pushStyle(style.getTextStyle())
        ..addText(text);
  final p = builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
  final w = p.maxIntrinsicWidth;
  p.dispose();
  return w;
}

String _f(double v) => v.toStringAsFixed(3);

/// F08 — camada 4 (texto) da seção `forYou`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F08 texto: quebras, baselines e extensões dos 15 textos da seção (item1.title: reticências)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final id in _textIds) {
        expectTextLines(tester, id);
        reportTextLines(tester, id);
      }
    },
  );

  testWidgets(
    'a tabela "Linhas de texto" da F08 (relativa à seção) é a mesma referência — e o Flutter fica a ≤ 0,05 px dela (maior desvio medido: 0,042)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // Origem da seção na especificação (x=20, y=1207,56) = retângulo `forYou` do JSON do arquivo.
      final refOrigin = kRefLayout['forYou']!.rect.topLeft;
      expect(refOrigin, const Offset(20, 1207.56));
      final origin = _sectionOrigin(tester);
      // y soma alturas de texto (float32 do SkParagraph): ±1e-3.
      expect(origin.dx, 20);
      expect(origin.dy, moreOrLessEquals(1207.56, epsilon: 1e-3));
      expect(_tableLines.keys.toList(), _textIds);
      var worst = ('', 0.0);
      for (final MapEntry(key: id, value: lines) in _tableLines.entries) {
        final ref = kRefLayout[id]!.lines;
        final got = _renderOf(tester, id).debugLines();
        final ellipsized = kEllipsized.contains(id);
        expect(got, hasLength(lines.length), reason: id);
        expect(ref, hasLength(lines.length), reason: id);
        for (final (i, (text, baseline, left, right, width)) in lines.indexed) {
          // Tabela da fase = JSON do arquivo menos a origem da seção: os dois têm 2 casas decimais, então a
          // diferença é exata (só ruído de double); a largura da tabela é fim − início.
          expect(ref[i].text, text, reason: '$id L${i + 1}');
          expect(
            ref[i].baseline - refOrigin.dy,
            moreOrLessEquals(baseline, epsilon: 1e-6),
            reason: '$id L${i + 1} baseline (tabela)',
          );
          expect(
            ref[i].left - refOrigin.dx,
            moreOrLessEquals(left, epsilon: 1e-6),
            reason: '$id L${i + 1} início (tabela)',
          );
          expect(
            ref[i].right - refOrigin.dx,
            moreOrLessEquals(right, epsilon: 1e-6),
            reason: '$id L${i + 1} fim (tabela)',
          );
          expect(
            right - left,
            moreOrLessEquals(width, epsilon: 1e-6),
            reason: '$id L${i + 1} largura (tabela)',
          );
          // A linha truncada devolve os caracteres visíveis; o "…" é da pintura.
          expect(
            ellipsized ? '${got[i].text}…' : got[i].text,
            text,
            reason: '$id L${i + 1}',
          );
          final deltas = [
            ('baseline', got[i].baseline - origin.dy - baseline),
            ('início', got[i].left - origin.dx - left),
            ('fim', got[i].right - origin.dx - right),
            ('largura', got[i].right - got[i].left - width),
          ];
          debugPrint(
            '[tabela] $id L${i + 1} "$text": '
            '${deltas.map((d) => 'Δ ${d.$1} ${_f(d.$2)}').join(' | ')}',
          );
          for (final (what, d) in deltas) {
            if (d.abs() > worst.$2.abs()) worst = ('$id L${i + 1} $what', d);
            // O gate da §7 é ±0,5 (expectTextLines, 1º teste); aqui o desvio medido, bem menor.
            expect(
              d.abs(),
              lessThanOrEqualTo(0.05),
              reason: '$id L${i + 1} $what',
            );
          }
        }
      }
      debugPrint('[tabela] maior desvio: ${worst.$1} = ${_f(worst.$2)}');
    },
  );

  testWidgets(
    'strings exatas do arquivo, derivadas dos dados (motivo, título curto do item 1, títulos e autores)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final data = _forYouData(tester);
      expect(data.items, hasLength(3));
      final [memorias, quincas, cortico] = data.items;
      // Motivo: formatador sobre o autor dos dados.
      expect(data.reasonAuthor, 'Machado de Assis');
      expect(
        _textOf(tester, 'forYou.reasonChip'),
        HomeFormatters.forYouReason(data.reasonAuthor),
      );
      final expected = {
        'forYou.title': 'Para você',
        'forYou.seeAll': 'Ver tudo',
        'forYou.reasonChip': 'Porque você lê Machado de Assis',
        'forYou.item1.cover.title': 'Memórias Póstumas de Brás Cubas',
        'forYou.item1.cover.author': 'MACHADO DE ASSIS',
        'forYou.item1.title': 'Memórias Póstumas',
        'forYou.item1.author': 'Machado de Assis',
        // O <br> do arquivo.
        'forYou.item2.cover.title': 'Quincas\nBorba',
        'forYou.item2.cover.author': 'MACHADO DE ASSIS',
        'forYou.item2.title': 'Quincas Borba',
        'forYou.item2.author': 'Machado de Assis',
        'forYou.item3.cover.title': 'O Cortiço',
        'forYou.item3.cover.author': 'ALUÍSIO AZEVEDO',
        'forYou.item3.title': 'O Cortiço',
        'forYou.item3.author': 'Aluísio Azevedo',
      };
      expect(expected.keys.toList(), _textIds);
      for (final MapEntry(key: id, value: text) in expected.entries) {
        // Um único trecho (sem filhos): nenhum texto da seção mistura estilos no arquivo.
        final span = _textWidget(tester, id).span as TextSpan;
        expect(span.children, isNull, reason: id);
        expect(span.text, text, reason: id);
        expect(_textOf(tester, id), text, reason: id);
      }
      // Legendas = dados: o 1º item usa o título curto (o arquivo abrevia e ainda corta com "…"); os
      // outros não têm título curto e usam o título.
      expect(memorias.shortTitle, 'Memórias Póstumas');
      expect(_textOf(tester, 'forYou.item1.title'), memorias.shortTitle);
      expect(memorias.title, isNot(memorias.shortTitle));
      expect((quincas.shortTitle, cortico.shortTitle), (null, null));
      expect(_textOf(tester, 'forYou.item2.title'), quincas.title);
      expect(_textOf(tester, 'forYou.item3.title'), cortico.title);
      for (final (i, book) in data.items.indexed) {
        expect(
          _textOf(tester, 'forYou.item${i + 1}.author'),
          book.author,
          reason: 'item ${i + 1}',
        );
      }
      // As artes repetem o título e o autor do livro (título completo no item 1; autor em caixa alta).
      expect(_textOf(tester, 'forYou.item1.cover.title'), memorias.title);
      expect(
        _textOf(tester, 'forYou.item2.cover.title').replaceAll('\n', ' '),
        quincas.title,
      );
      expect(_textOf(tester, 'forYou.item3.cover.title'), cortico.title);
      for (final (i, book) in data.items.indexed) {
        expect(
          _textOf(tester, 'forYou.item${i + 1}.cover.author'),
          book.author.toUpperCase(),
          reason: 'item ${i + 1}',
        );
      }

      const lineCounts = {
        'forYou.item1.cover.title': 3,
        'forYou.item2.cover.title': 2,
      };
      for (final id in _textIds) {
        final render = _renderOf(tester, id);
        expect(render.debugLines(), hasLength(lineCounts[id] ?? 1), reason: id);
        // "\n" só no título da capa do Quincas (o <br> do arquivo); nenhum outro texto quebra à força.
        expect(
          _textOf(tester, id).contains('\n'),
          id == 'forYou.item2.cover.title',
          reason: id,
        );
        final text = _textWidget(tester, id);
        if (id == 'forYou.item1.title') {
          // `white-space: nowrap; overflow: hidden; text-overflow: ellipsis` só no 1º título.
          expect((text.maxLines, text.ellipsis), (1, true), reason: id);
          expect(render.debugDidExceedMaxLines, isTrue, reason: id);
        } else {
          // Sem limite de linhas nem reticências no arquivo.
          expect((text.maxLines, text.ellipsis), (null, false), reason: id);
          expect(render.debugDidExceedMaxLines, isFalse, reason: id);
        }
      }
      expect(kEllipsized.where((id) => id.startsWith('forYou.')), [
        'forYou.item1.title',
      ]);
    },
  );

  testWidgets(
    '8.7 reticências: "Memórias Póstumas" em 116 → exatamente "Memórias Póstu…" (com "m" a mais estouraria 116)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.item1.title';
      final render = _renderOf(tester, id);
      // Largura do contêiner (coluna esticada no item de 116).
      expect(render.constraints.hasTightWidth, isTrue);
      expect(render.size.width, 116);
      expect(render.debugDidExceedMaxLines, isTrue);
      final line = render.debugLines().single;
      final ref = kRefLayout[id]!.lines.single;
      expect(ref.text, 'Memórias Póstu…');
      // Caracteres que sobram antes do "…" e a extensão da linha pintada (com o "…").
      expect(line.text, 'Memórias Póstu');
      expect(line.left, moreOrLessEquals(ref.left, epsilon: 0.5));
      expect(line.right, moreOrLessEquals(ref.right, epsilon: 0.5));
      expect(line.baseline, moreOrLessEquals(ref.baseline, epsilon: 0.5));
      final painted = line.right - line.left;
      final full = _naturalWidth(
        AppTextStyles.label14Bold,
        'Memórias Póstumas',
      );
      final cut = _naturalWidth(AppTextStyles.label14Bold, 'Memórias Póstu…');
      final next = _naturalWidth(AppTextStyles.label14Bold, 'Memórias Póstum…');
      // Sem o "…" e com três pontos no lugar dele: a extensão medida distingue os dois casos.
      final bare = _naturalWidth(AppTextStyles.label14Bold, 'Memórias Póstu');
      final dots = _naturalWidth(
        AppTextStyles.label14Bold,
        'Memórias Póstu...',
      );
      debugPrint(
        '[reticências] linha ${_f(line.left)}–${_f(line.right)} '
        '(${_f(painted)}; arquivo ${(ref.right - ref.left).toStringAsFixed(2)}) | '
        '"Memórias Póstumas" = ${_f(full)} (estoura 116 por ${_f(full - 116)}) | '
        '"Memórias Póstu…" = ${_f(cut)} | "Memórias Póstum…" = ${_f(next)} '
        '(estoura 116 por ${_f(next - 116)}) | sem o "…" ${_f(bare)} | '
        'com "..." ${_f(dots)}',
      );
      // O título inteiro não cabe nos 116 …
      expect(full, greaterThan(116));
      // … a linha pintada é exatamente "Memórias Póstu…" …
      expect(painted, moreOrLessEquals(cut, epsilon: 0.01));
      expect(painted, moreOrLessEquals(112.88, epsilon: 0.05));
      expect(cut, lessThanOrEqualTo(116));
      // … e com mais uma letra não caberia nos 116.
      expect(next, greaterThan(116));
      // A extensão inclui o "…" (um glifo só): sem ele a linha teria 9,928 a menos, e três pontos mediriam
      // 0,504 a mais — os dois casos ficariam fora do ±0,01 acima.
      expect(painted - bare, greaterThan(0.01));
      expect((dots - painted).abs(), greaterThan(0.01));
    },
  );

  testWidgets(
    '8.4 capa Memórias em 87: "Memórias" / "Póstumas de" / "Brás Cubas" ("Memórias Póstumas" e "Póstumas de Brás" não cabem)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.item1.cover.title';
      final render = _renderOf(tester, id);
      // left 16 / right 10 numa capa de 116 com borda 1,5 → 113 − 26 = 87.
      expect(render.constraints.hasTightWidth, isTrue);
      expect(render.size.width, 87);
      final lines = render.debugLines();
      expect(lines.map((l) => l.text), [
        'Memórias',
        'Póstumas de',
        'Brás Cubas',
      ]);
      final style = AppTextStyles.coverTitle19;
      // Larguras das 3 linhas na tabela da F08: 64,03 / 80,98 / 70,81.
      const fileWidths = [64.03, 80.98, 70.81];
      // Cada linha cabe nos 87, com a largura do arquivo …
      for (final (i, l) in lines.indexed) {
        final w = _naturalWidth(style, l.text);
        debugPrint(
          '[capa Memórias] "${l.text}" = ${_f(w)} (arquivo ${fileWidths[i]}; sobra ${_f(87 - w)} em 87)',
        );
        expect(w, lessThanOrEqualTo(87), reason: l.text);
        expect(
          w,
          moreOrLessEquals(fileWidths[i], epsilon: 0.05),
          reason: l.text,
        );
        expect(
          l.right - l.left,
          moreOrLessEquals(w, epsilon: 1e-3),
          reason: l.text,
        );
      }
      // … e juntar a palavra seguinte a qualquer uma das duas primeiras estouraria.
      for (final candidate in ['Memórias Póstumas', 'Póstumas de Brás']) {
        final w = _naturalWidth(style, candidate);
        debugPrint(
          '[capa Memórias] "$candidate" = ${_f(w)} (estoura 87 por ${_f(w - 87)})',
        );
        expect(w, greaterThan(87), reason: candidate);
      }
    },
  );

  testWidgets(
    'autores das capas: Memórias (só left/bottom) abraça o texto — 78,33 com o letter-spacing final; capas 2 e 3 esticadas a 87',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ref = kRefLayout['forYou.item1.cover.author']!;
      final render = _renderOf(tester, 'forYou.item1.cover.author');
      // Sem `right` → restrição frouxa: shrink-to-fit do CSS.
      expect(render.constraints.hasTightWidth, isFalse);
      final natural = _naturalWidth(
        AppTextStyles.coverAuthorFlame,
        'MACHADO DE ASSIS',
      );
      final line = render.debugLines().single;
      debugPrint(
        '[autor capa 1] caixa ${_f(render.size.width)} (arquivo ${ref.rect.width}) | '
        'natural ${_f(natural)} | linha ${_f(line.right - line.left)}',
      );
      // A caixa é a largura natural do texto, que inclui o letter-spacing após o último "S" …
      expect(render.size.width, natural);
      expect(render.size.width, moreOrLessEquals(ref.rect.width, epsilon: 0.5));
      // … e a extensão da linha é a mesma largura (como no navegador).
      expect(
        line.right - line.left,
        moreOrLessEquals(render.size.width, epsilon: 1e-3),
      );
      // Os 16 caracteres levam 0,91 cada (0,14em × 6,5), inclusive o último: sem o letter-spacing final a
      // caixa teria 0,91 a menos e sairia da tolerância de ±0,5 em torno dos 78,33 do arquivo.
      final style = AppTextStyles.coverAuthorFlame;
      expect(style.letterSpacing, 0.91);
      final glyphs = _naturalWidth(
        style.copyWith(letterSpacing: 0),
        'MACHADO DE ASSIS',
      );
      debugPrint(
        '[autor capa 1] sem letter-spacing ${_f(glyphs)} + 16 × 0,91 = ${_f(glyphs + 16 * 0.91)} | '
        'sem o último 0,91: ${_f(render.size.width - 0.91)} (Δ ${_f(render.size.width - 0.91 - ref.rect.width)} do arquivo)',
      );
      expect(
        render.size.width,
        moreOrLessEquals(glyphs + 16 * 0.91, epsilon: 1e-3),
      );
      expect(
        (render.size.width - 0.91 - ref.rect.width).abs(),
        greaterThan(0.5),
      );
      for (final (id, text) in [
        ('forYou.item2.cover.author', 'MACHADO DE ASSIS'),
        ('forYou.item3.cover.author', 'ALUÍSIO AZEVEDO'),
      ]) {
        final r = _renderOf(tester, id);
        final l = r.debugLines().single;
        final w = _naturalWidth(AppTextStyles.coverAuthorSurface, text);
        final refLine = kRefLayout[id]!.lines.single;
        debugPrint(
          '[autor capa] $id caixa ${_f(r.size.width)} | texto ${_f(l.right - l.left)} '
          '(natural ${_f(w)}; arquivo ${(refLine.right - refLine.left).toStringAsFixed(2)})',
        );
        // Coluna `stretch` do bloco inferior (left 16 / right 10): a caixa tem os 87 …
        expect(r.constraints.hasTightWidth, isTrue, reason: id);
        expect(r.size.width, 87, reason: id);
        // … e o texto ocupa só a largura natural, alinhado à esquerda.
        expect(
          l.right - l.left,
          moreOrLessEquals(w, epsilon: 1e-3),
          reason: id,
        );
        expect(
          w,
          moreOrLessEquals(refLine.right - refLine.left, epsilon: 0.05),
          reason: id,
        );
        expect(w, lessThan(87), reason: id);
      }
    },
  );

  testWidgets(
    'títulos dos itens 2 e 3 cabem numa linha em 116 (sem limite de linhas e sem reticências)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final (id, text) in [
        ('forYou.item2.title', 'Quincas Borba'),
        ('forYou.item3.title', 'O Cortiço'),
      ]) {
        final render = _renderOf(tester, id);
        final widget = _textWidget(tester, id);
        expect(render.constraints.hasTightWidth, isTrue, reason: id);
        expect(render.size.width, 116, reason: id);
        expect((widget.maxLines, widget.ellipsis), (null, false), reason: id);
        expect(render.debugDidExceedMaxLines, isFalse, reason: id);
        final line = render.debugLines().single;
        expect(line.text, text, reason: id);
        final w = _naturalWidth(AppTextStyles.label14Bold, text);
        debugPrint(
          '[legenda] $id "$text" = ${_f(w)} (sobra ${_f(116 - w)} em 116) | '
          'linha ${_f(line.right - line.left)}',
        );
        expect(w, lessThanOrEqualTo(116), reason: id);
        expect(
          line.right - line.left,
          moreOrLessEquals(w, epsilon: 1e-3),
          reason: id,
        );
        final refLine = kRefLayout[id]!.lines.single;
        expect(
          w,
          moreOrLessEquals(refLine.right - refLine.left, epsilon: 0.05),
          reason:
              '$id (arquivo ${(refLine.right - refLine.left).toStringAsFixed(2)})',
        );
      }
    },
  );

  testWidgets(
    'textos derivados dos dados: com outros dados mudam o motivo, as legendas e os autores; só o 1º título corta com "…" — os títulos 2 e 3 e os autores quebram linha',
    (tester) async {
      setCanvasView(tester);
      final base = const HomeMockRepository().snapshot(
        HomeMockRepository.referenceNow,
      );
      // Mesmas artes de capa (a seção só desenha as três do arquivo); textos longos e diferentes.
      const forYou = ForYou(
        reasonAuthor: 'Aluísio Azevedo',
        items: [
          // Sem título curto → a legenda usa o título inteiro.
          Book(
            id: 'teste-1',
            title: 'Memórias Póstumas de Brás Cubas',
            author: 'Joaquim Maria Machado de Assis',
            cover: DesignedCover(CoverArt.memoriasPostumas),
          ),
          Book(
            id: 'teste-2',
            title: 'Quincas Borba, o Filósofo do Humanitismo',
            author: 'M. de Assis',
            cover: DesignedCover(CoverArt.quincasBorba),
          ),
          Book(
            id: 'teste-3',
            title: 'O Mulato',
            author: 'Aluísio Tancredo Gonçalves de Azevedo',
            cover: DesignedCover(CoverArt.oCortico),
          ),
        ],
      );
      await pumpApp(
        tester,
        overrides: [
          homeSnapshotProvider.overrideWithValue(
            HomeSnapshot(
              now: base.now,
              user: base.user,
              continueReading: base.continueReading,
              alsoReading: base.alsoReading,
              readingDay: base.readingDay,
              forYou: forYou,
              club: base.club,
              recent: base.recent,
            ),
          ),
        ],
      );
      expect(_forYouData(tester), same(forYou));
      // Motivo: o formatador sobre o autor dos dados (não o texto fixo do arquivo).
      expect(
        _textOf(tester, 'forYou.reasonChip'),
        'Porque você lê Aluísio Azevedo',
      );
      expect(
        _textOf(tester, 'forYou.reasonChip'),
        HomeFormatters.forYouReason(forYou.reasonAuthor),
      );
      for (final (i, book) in forYou.items.indexed) {
        expect(
          _textOf(tester, 'forYou.item${i + 1}.title'),
          book.title,
          reason: 'item ${i + 1}',
        );
        expect(
          _textOf(tester, 'forYou.item${i + 1}.author'),
          book.author,
          reason: 'item ${i + 1}',
        );
      }

      // 1º título: `nowrap` + `ellipsis` → uma linha só, cortada com "…" dentro dos 116.
      final title1 = _renderOf(tester, 'forYou.item1.title');
      final cut = title1.debugLines().single;
      debugPrint(
        '[dados] forYou.item1.title "${forYou.items[0].title}" → "${cut.text}…" '
        '(${_f(cut.right - cut.left)} em 116)',
      );
      expect(title1.debugDidExceedMaxLines, isTrue);
      expect(forYou.items[0].title.startsWith(cut.text), isTrue);
      expect(cut.text.length, lessThan(forYou.items[0].title.length));
      expect(cut.right - cut.left, lessThanOrEqualTo(116));

      // Títulos 2 e 3 e os 3 autores: sem `nowrap` no arquivo → quebram normalmente, sem perder nada.
      for (final (id, text, wraps) in [
        ('forYou.item1.author', forYou.items[0].author, true),
        ('forYou.item2.title', forYou.items[1].title, true),
        ('forYou.item2.author', forYou.items[1].author, false),
        ('forYou.item3.title', forYou.items[2].title, false),
        ('forYou.item3.author', forYou.items[2].author, true),
      ]) {
        final render = _renderOf(tester, id);
        final lines = render.debugLines();
        debugPrint(
          '[dados] $id: ${lines.map((l) => '"${l.text}" ${_f(l.right - l.left)}').join(' / ')}',
        );
        expect(render.size.width, 116, reason: id);
        expect(render.debugDidExceedMaxLines, isFalse, reason: id);
        expect(lines.length, wraps ? greaterThan(1) : equals(1), reason: id);
        expect(lines.map((l) => l.text).join(' '), text, reason: id);
        for (final l in lines) {
          expect(
            l.right - l.left,
            lessThanOrEqualTo(116),
            reason: '$id "${l.text}"',
          );
        }
      }
    },
  );
}
