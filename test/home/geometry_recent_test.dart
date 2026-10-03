import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/features/home/presentation/covers/frankenstein_mini_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/o_alienista_mini_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/senhora_mini_cover.dart';
import 'package:app_leitura/features/home/presentation/sections/recently_added_section.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// Retângulo relativo ao canto superior esquerdo da seção (a tabela da F10 usa essa origem).
Rect _rel(WidgetTester tester, String id) =>
    _rect(tester, id).shift(-_rect(tester, 'recent').topLeft);

/// Alturas e posições que somam alturas de texto carregam o ruído float32 do SkParagraph (±1e-3).
const _eps = 1e-3;

/// Larguras medidas de texto: as fontes estáticas foram validadas contra o navegador com desvio
/// ≤ 0,05 px (§6.1 do prompt mestre).
const _textW = 0.05;

/// Retângulo (relativo à seção) do `AppText` sem Key dentro do widget com a Key [id].
Rect _textIn(WidgetTester tester, String id) => tester
    .getRect(
      find.descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(AppText),
      ),
    )
    .shift(-_rect(tester, 'recent').topLeft);

/// Tabela "Especificação pixel a pixel" da F10 (x, y, w, h relativos à seção), na ordem do arquivo.
const _table = [
  ('recent', 0.0, 0.0, 350.0, 334.0),
  ('recent.header', 0.0, 0.0, 350.0, 44.0),
  ('recent.title', 0.0, 7.6, 195.47, 28.8),
  ('recent.libraryLink', 263.81, 0.0, 86.19, 44.0),
  ('recent.libraryLink.icon', 332.0, 13.0, 18.0, 18.0),
  ('recent.list', 0.0, 54.0, 350.0, 280.0),
  ('recent.row0', 14.0, 58.0, 328.0, 91.0),
  ('recent.row0.cover', 14.0, 70.0, 44.0, 66.0),
  ('recent.row0.cover.moon', 25.2, 81.2, 22.0, 22.0),
  ('recent.row0.cover.bar', 23.2, 124.8, 27.6, 3.0),
  ('recent.row0.textBlock', 72.0, 84.7, 126.54, 36.6),
  ('recent.row0.title', 72.0, 84.7, 126.54, 18.0),
  ('recent.row0.subtitle', 72.0, 105.7, 126.54, 15.6),
  ('recent.row0.tag', 212.54, 90.8, 71.46, 24.4),
  ('recent.row0.more', 298.0, 81.0, 44.0, 44.0),
  ('recent.row0.more.icon', 310.0, 93.0, 20.0, 20.0),
  ('recent.row1', 14.0, 149.0, 328.0, 91.0),
  ('recent.row1.cover', 14.0, 161.0, 44.0, 66.0),
  ('recent.row1.cover.spine', 15.2, 162.2, 4.0, 63.6),
  ('recent.row1.cover.ring', 27.2, 174.2, 20.0, 20.0),
  ('recent.row1.cover.dot', 33.2, 180.2, 8.0, 8.0),
  ('recent.row1.textBlock', 72.0, 167.9, 129.83, 52.2),
  ('recent.row1.title', 72.0, 167.9, 129.83, 18.0),
  ('recent.row1.subtitle', 72.0, 188.9, 129.83, 31.2),
  ('recent.row1.tag', 215.83, 174.6, 68.17, 38.8),
  ('recent.row1.more', 298.0, 172.0, 44.0, 44.0),
  ('recent.row1.more.icon', 310.0, 184.0, 20.0, 20.0),
  ('recent.row2', 14.0, 240.0, 328.0, 90.0),
  ('recent.row2.cover', 14.0, 252.0, 44.0, 66.0),
  ('recent.row2.cover.spine', 15.2, 253.2, 4.0, 63.6),
  ('recent.row2.cover.arch', 25.2, 265.2, 23.6, 26.0),
  ('recent.row2.textBlock', 72.0, 266.7, 148.56, 36.6),
  ('recent.row2.title', 72.0, 266.7, 148.56, 18.0),
  ('recent.row2.subtitle', 72.0, 287.7, 148.56, 15.6),
  ('recent.row2.tag', 234.56, 272.8, 49.44, 24.4),
  ('recent.row2.more', 298.0, 263.0, 44.0, 44.0),
  ('recent.row2.more.icon', 310.0, 275.0, 20.0, 20.0),
];

/// F10 — camada 1 (geometria) e construção da seção `recent`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F10 geometria: os 37 ids da seção recent dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = idsOfSection('recent').toList();
      expect(ids, [for (final row in _table) row.$1]);
      expect(ids, hasLength(37));
      expectGeometry(tester, ids);
      reportGeometry(tester, ids);
    },
  );

  testWidgets(
    'posições da tabela da F10 relativas à seção (37 linhas, ≤ 0,05 px)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      var worst = ('', 0.0);
      for (final (id, x, y, w, h) in _table) {
        final got = _rel(tester, id);
        for (final (what, g, e) in [
          ('x', got.left, x),
          ('y', got.top, y),
          ('w', got.width, w),
          ('h', got.height, h),
        ]) {
          final d = (g - e).abs();
          if (d > worst.$2) worst = ('$id.$what', d);
          expect(g, moreOrLessEquals(e, epsilon: 0.05), reason: '$id.$what');
        }
      }
      debugPrint(
        '[tabela F10] 37 linhas; maior desvio ${worst.$1} = ${worst.$2.toStringAsFixed(4)}',
      );
    },
  );

  testWidgets(
    '10.1/10.2 construção: Semantics(seção) > Column(recent, gap 10)[header 44, NeoBox(recent.list: #FFFAF1, raio 24, padding 14 4 8 4, sem borda/sombra/recorte) > Column(3 linhas)]; 40 abaixo do clube',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final sectionFinder = find.byType(RecentlyAddedSection);
      final section = tester.widget<Semantics>(
        find
            .descendant(of: sectionFinder, matching: find.byType(Semantics))
            .first,
      );
      // O Semantics da seção é a raiz do build de RecentlyAddedSection (nada por fora dele).
      Widget? root;
      tester.element(sectionFinder).visitChildElements((e) => root = e.widget);
      expect(root, same(section));
      expect(section.container, isTrue);
      expect(section.explicitChildNodes, isTrue);
      expect(section.properties.label, 'Adicionados recentemente');

      final column = section.child! as Column;
      expect(column.key, const ValueKey('recent'));
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(column.spacing, 10);
      expect(column.children, hasLength(2));
      // O cabeçalho é a altura fixa de 44 (a Key fica no SizedBox dentro do widget do cabeçalho).
      expect(
        tester
            .widget<SizedBox>(find.byKey(const ValueKey('recent.header')))
            .height,
        44,
      );

      // Lista: sem borda, sem sombra, sem recorte (nenhum ClipRRect entre a lista e as linhas).
      final list = column.children[1] as NeoBox;
      expect(list.key, const ValueKey('recent.list'));
      expect(list.color, AppColors.surface);
      expect(list.color!.toARGB32(), 0xFFFFFAF1);
      expect(list.border, isNull);
      expect(list.shadow, isNull);
      expect(list.clip, isFalse);
      expect(list.radius, BorderRadius.circular(24));
      expect(list.padding, const EdgeInsets.fromLTRB(14, 4, 8, 4));
      final rows = list.child! as Column;
      expect(rows.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(rows.mainAxisSize, MainAxisSize.min);
      expect(rows.spacing, 0);
      expect(rows.children, hasLength(3));

      // Na tela: dentro do padding lateral 20 (`_gutter`), 40 abaixo do clube.
      final club = _rect(tester, 'club');
      final recent = _rect(tester, 'recent');
      expect(recent.top - club.bottom, moreOrLessEquals(40, epsilon: _eps));
      expect(recent.left, 20);
      expect(recent.width, 350);
      expect(recent.height, moreOrLessEquals(334, epsilon: _eps));
    },
  );

  testWidgets(
    '10.1 cabeçalho: 44 de altura, space-between, centralizado; "Recém-chegados" 195,47 × 28,8 (y + 7,6) à esquerda e o link "Biblioteca" (86,19 × 44: texto 14/700 + gap 4 + seta 18) encostado à direita',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final header = _rel(tester, 'recent.header');
      final title = _rel(tester, 'recent.title');
      final link = _rel(tester, 'recent.libraryLink');
      final icon = _rel(tester, 'recent.libraryLink.icon');
      expect(header, const Rect.fromLTWH(0, 0, 350, 44));
      expect(title.left, 0);
      expect(title.width, moreOrLessEquals(195.47, epsilon: _textW));
      expect(title.height, moreOrLessEquals(28.8, epsilon: _eps));
      // Centralizado na linha de 44.
      expect(title.center.dy, moreOrLessEquals(22, epsilon: _eps));
      expect(title.top, moreOrLessEquals(7.6, epsilon: _eps));
      expect(link.right, 350);
      expect(link.height, 44);
      expect(link.width, moreOrLessEquals(86.19, epsilon: _textW));
      expect(icon.size, const Size(18, 18));
      expect(icon.right, 350);
      expect(icon.center.dy, 22);
      final label = _textIn(tester, 'recent.libraryLink');
      expect(label.left, moreOrLessEquals(link.left, epsilon: 1e-9));
      expect(icon.left - label.right, moreOrLessEquals(4, epsilon: 1e-9));
      expect(label.width, moreOrLessEquals(64.19, epsilon: _textW));

      final row = tester.widget<Row>(
        find
            .descendant(
              of: find.byKey(const ValueKey('recent.header')),
              matching: find.byType(Row),
            )
            .first,
      );
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      final linkPressable = tester.widget<Pressable>(
        find.ancestor(
          of: find.byKey(const ValueKey('recent.libraryLink')),
          matching: find.byType(Pressable),
        ),
      );
      expect(linkPressable.isLink, isTrue);
      expect(linkPressable.semanticsLabel, isNull);
    },
  );

  testWidgets(
    '10.2 alturas das linhas = 12 + 66 + 12 (+ 1 de divisor nas duas primeiras) = 91, 91 e 90; lista = 4 + 91 + 91 + 90 + 4 = 280; o divisor ocupa a largura da linha (328, de x = 34 a 362) e fica DENTRO do retângulo da linha',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final list = _rel(tester, 'recent.list');
      final rows = [for (var i = 0; i < 3; i++) _rel(tester, 'recent.row$i')];
      expect([for (final r in rows) r.height], [91.0, 91.0, 90.0]);
      for (final r in rows) {
        expect(r.left, 14);
        expect(r.width, 328);
      }
      expect(rows[0].top, 58);
      expect(rows[1].top, rows[0].bottom);
      expect(rows[2].top, rows[1].bottom);
      expect(rows[0].top - list.top, 4);
      expect(list.bottom - rows[2].bottom, 4);
      expect(list.size, const Size(350, 280));
      // O retângulo da linha vai de x = 14 a 342 na seção (34 a 362 no canvas): é a largura do divisor.
      final abs = _rect(tester, 'recent.row0');
      expect((abs.left, abs.right), (34.0, 362.0));

      // Padding 12 em cima e embaixo; capa 66; o divisor (1) só nas linhas 0 e 1.
      for (var i = 0; i < 3; i++) {
        final container = tester.widget<Container>(
          find.byKey(ValueKey('recent.row$i')),
        );
        expect(
          container.padding,
          const EdgeInsets.symmetric(vertical: 12),
          reason: 'linha $i',
        );
        final decoration = container.decoration as BoxDecoration?;
        if (i < 2) {
          expect(
            decoration!.border,
            const Border(
              bottom: BorderSide(width: 1, color: AppColors.divider),
            ),
            reason: 'linha $i',
          );
        } else {
          expect(decoration, isNull, reason: 'última linha sem divisor');
        }
        final cover = _rel(tester, 'recent.row$i.cover');
        expect(cover.top - rows[i].top, 12, reason: 'linha $i');
        expect(cover.size, const Size(44, 66), reason: 'linha $i');
        expect(cover.left, 14, reason: 'linha $i');
        // A linha de 66 cobre as três alturas de conteúdo (capa, textos e selo) e o 44 do botão.
        final more = _rel(tester, 'recent.row$i.more');
        expect(
          more.center.dy,
          moreOrLessEquals(cover.center.dy, epsilon: _eps),
        );
        expect(more.size, const Size(44, 44));
        expect(more.right, 342);
      }
    },
  );

  testWidgets(
    '10.3 mini-capas: 44 × 66, filhos dentro da borda 1,2 (padding box) nas posições do arquivo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // (id, deslocamento a partir do canto da capa, largura, altura): left/top + borda 1,2.
      const b = 1.2;
      final expected = <String, (double, double, double, double)>{
        'recent.row0.cover.moon': (b + 10, b + 10, 22, 22),
        'recent.row0.cover.bar': (b + 8, 66 - b - 7 - 3, 44 - 2 * b - 8 - 6, 3),
        'recent.row1.cover.spine': (b, b, 4, 66 - 2 * b),
        'recent.row1.cover.ring': (b + 12, b + 12, 20, 20),
        'recent.row1.cover.dot': (b + 18, b + 18, 8, 8),
        'recent.row2.cover.spine': (b, b, 4, 66 - 2 * b),
        'recent.row2.cover.arch': (b + 10, b + 12, 44 - 2 * b - 10 - 8, 26),
      };
      for (final MapEntry(key: id, value: (dx, dy, w, h)) in expected.entries) {
        final cover = _rel(tester, id.substring(0, id.lastIndexOf('.')));
        final got = _rel(tester, id);
        expect(
          got.left - cover.left,
          moreOrLessEquals(dx, epsilon: 1e-9),
          reason: id,
        );
        expect(
          got.top - cover.top,
          moreOrLessEquals(dy, epsilon: 1e-9),
          reason: id,
        );
        expect(got.width, moreOrLessEquals(w, epsilon: 1e-9), reason: id);
        expect(got.height, moreOrLessEquals(h, epsilon: 1e-9), reason: id);
      }
      // Larguras que vêm de left/right: 27,6 (barra) e 23,6 (arco).
      expect(_rel(tester, 'recent.row0.cover.bar').width, closeTo(27.6, 1e-9));
      expect(_rel(tester, 'recent.row2.cover.arch').width, closeTo(23.6, 1e-9));
      // Cada capa é o primeiro filho da linha (44 × 66), antes do bloco de texto.
      for (var i = 0; i < 3; i++) {
        final row = tester.widget<Row>(
          find
              .descendant(
                of: find.byKey(ValueKey('recent.row$i')),
                matching: find.byType(Row),
              )
              .first,
        );
        expect(row.children, hasLength(4));
        expect(row.crossAxisAlignment, CrossAxisAlignment.center);
        expect(row.spacing, 14);
        // A Key `recent.rowN.cover` fica no NeoBox da própria arte (a capa recebe só o prefixo).
        expect(
          switch (row.children[0]) {
            final FrankensteinMiniCover c => (i, c.id),
            final OAlienistaMiniCover c => (i, c.id),
            final SenhoraMiniCover c => (i, c.id),
            _ => null,
          },
          (i, 'recent.row$i.cover'),
        );
      }
    },
  );

  testWidgets(
    '10.4/10.5 flex-shrink do CSS: capa 44 + gap 14 + texto + gap 14 + selo + gap 14 + botão 44 = 328 em cada linha (texto + selo = 198); sem Expanded/Flexible; linha 1 reproduz o arquivo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (var i = 0; i < 3; i++) {
        final row = _rel(tester, 'recent.row$i');
        final block = _rel(tester, 'recent.row$i.textBlock');
        final tag = _rel(tester, 'recent.row$i.tag');
        final more = _rel(tester, 'recent.row$i.more');
        // As larguras fecham a linha: 44 + 14 + texto + 14 + selo + 14 + 44.
        expect(block.left, row.left + 44 + 14, reason: 'linha $i');
        expect(tag.left, moreOrLessEquals(block.right + 14, epsilon: 1e-9));
        expect(more.left, moreOrLessEquals(tag.right + 14, epsilon: 1e-9));
        expect(block.width + tag.width, moreOrLessEquals(198, epsilon: 1e-9));
        // Texto e selo centralizados na altura da capa.
        final cover = _rel(tester, 'recent.row$i.cover');
        expect(
          block.center.dy,
          moreOrLessEquals(cover.center.dy, epsilon: _eps),
        );
        expect(tag.center.dy, moreOrLessEquals(cover.center.dy, epsilon: _eps));
        // Estrutura: nenhum Expanded/Flexible na linha (o algoritmo é explícito).
        expect(
          find.descendant(
            of: find.byKey(ValueKey('recent.row$i')),
            matching: find.byType(Flexible),
          ),
          findsNothing,
          reason: 'linha $i',
        );
        final sizedBlock = tester.widget<SizedBox>(
          find
              .ancestor(
                of: find.byKey(ValueKey('recent.row$i.textBlock')),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(sizedBlock.width, moreOrLessEquals(block.width, epsilon: 1e-9));
        final tagBox = tester.widget<SizedBox>(
          find
              .ancestor(
                of: find.byKey(ValueKey('recent.row$i.tag')),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(tagBox.width, moreOrLessEquals(tag.width, epsilon: 1e-9));
      }
      // Linhas 0 e 2: o texto cresce (126,54 e 148,56) e o selo mantém a largura natural.
      expect(
        _rel(tester, 'recent.row0.textBlock').width,
        closeTo(126.54, _textW),
      );
      expect(_rel(tester, 'recent.row0.tag').width, closeTo(71.46, _textW));
      expect(
        _rel(tester, 'recent.row2.textBlock').width,
        closeTo(148.56, _textW),
      );
      expect(_rel(tester, 'recent.row2.tag').width, closeTo(49.44, _textW));
      // Linha 1 (D-12): o estouro de ≈ 12,13 é repartido → texto 129,83 e selo 68,17.
      final block = _rel(tester, 'recent.row1.textBlock');
      final tag = _rel(tester, 'recent.row1.tag');
      expect(block.width, closeTo(129.83, _textW));
      expect(tag.width, closeTo(68.17, _textW));
      // Subtítulo em 2 linhas (31,2) e selo com o texto em 2 linhas (38,8), centralizado na linha.
      expect(_rel(tester, 'recent.row1.subtitle').height, closeTo(31.2, _eps));
      expect(block.height, closeTo(52.2, _eps));
      expect(tag.height, closeTo(38.8, _eps));
      expect(
        tag.height,
        closeTo(5 + 2 * 14.4 + 5, _eps),
        reason: 'selo: padding 5 + 2 linhas de 14,4 + padding 5',
      );
      // Texto do selo: dentro do padding 5 10.
      final tagText = _textIn(tester, 'recent.row1.tag');
      expect(tagText.left - tag.left, closeTo(10, 1e-9));
      expect(tag.right - tagText.right, closeTo(10, 1e-9));
      expect(tagText.top - tag.top, closeTo(5, 1e-9));
    },
  );

  testWidgets(
    '10.5 selo: Pill(padding 5 10, raio 999) dentro de SizedBox(largura do algoritmo); texto "Quero ler" mede 51,46 e sua maior palavra 34,45; o selo "Novo" mede 29,44',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (var i = 0; i < 3; i++) {
        final pill = tester.widget<Pill>(
          find.byKey(ValueKey('recent.row$i.tag')),
        );
        expect(
          pill.padding,
          const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        );
        expect(pill.border, isNull);
      }
      // Larguras do texto nas linhas sem estouro: 51,46 e 29,44 (a tabela de linhas de texto).
      expect(_textIn(tester, 'recent.row0.tag').width, closeTo(51.46, _textW));
      expect(_textIn(tester, 'recent.row2.tag').width, closeTo(29.44, _textW));
    },
  );

  testWidgets(
    '10.6 botão "mais opções": CircleIconButton 44 × 44 com o ícone SVG de 20 centrado (x + 12, y + 12), à direita da linha; Pressable de botão com o rótulo do arquivo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (var i = 0; i < 3; i++) {
        final more = _rel(tester, 'recent.row$i.more');
        final icon = _rel(tester, 'recent.row$i.more.icon');
        expect(more.size, const Size(44, 44));
        expect(icon.size, const Size(20, 20));
        expect(icon.left - more.left, 12);
        expect(icon.top - more.top, 12);
        final button = tester.widget<CircleIconButton>(
          find.byKey(ValueKey('recent.row$i.more')),
        );
        expect(button.size, 44);
        expect(button.color, isNull);
        expect(button.border, isNull);
        expect(button.overlays, isEmpty);
        expect(button.icon, isA<AppSvg>());
        expect((button.icon as AppSvg).size, 20);
      }
      expect(
        [
          for (var i = 0; i < 3; i++)
            tester
                .widget<CircleIconButton>(
                  find.byKey(ValueKey('recent.row$i.more')),
                )
                .semanticsLabel,
        ],
        [
          'Mais opções para Frankenstein',
          'Mais opções para O Alienista',
          'Mais opções para Senhora',
        ],
      );
    },
  );
}
