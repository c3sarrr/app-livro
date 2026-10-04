import 'dart:typed_data';

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/for_you_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// Só a seção, na largura toda (390: o carrossel sangra de 0 a 390), com os callbacks (a tela liga
/// `/livro/:bookId` e `/para-voce` na F12).
Future<void> _pumpSection(
  WidgetTester tester, {
  ValueChanged<Book>? onBookTap,
  VoidCallback? onSeeAllTap,
}) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overridesDoMundo,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 390,
            child: ForYouSection(
              onBookTap: onBookTap,
              onSeeAllTap: onSeeAllTap,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SemanticsNode _node(WidgetTester tester, String id) =>
    tester.getSemantics(find.byKey(ValueKey<String>(id)));

/// Nó da `<section aria-label="Para você">`. A Key `forYou` fica no `SizedBox.expand` do `_fullBleed`
/// (irmão da seção, 20→370), não num ancestral dela; o cabeçalho não tem nó próprio, então o nó mais
/// próximo acima de `forYou.header` é o `Semantics` da seção.
SemanticsNode _section(WidgetTester tester) => _node(tester, 'forYou.header');

/// Nó do AppText sob [id] (a pílula do chip não tem nó próprio).
SemanticsNode _textNode(WidgetTester tester, String id) => tester.getSemantics(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  ),
);

/// Nó da rolagem horizontal do carrossel (D-03): o único nó rolável DA SEÇÃO (buscar só na subárvore
/// da seção, e não na árvore inteira, deixa o teste imune a outros roláveis da tela).
SemanticsNode _scrollNode(WidgetTester tester) =>
    _descendants(_section(tester))
        .where((n) => n.getSemanticsData().scrollExtentMax != null)
        .single;

ScrollPosition _carouselPosition(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byKey(const ValueKey('forYou.carousel')),
        matching: find.byType(Scrollable),
      ),
    )
    .position;

Set<SemanticsAction> _actionsOf(SemanticsNode n) {
  final data = n.getSemanticsData();
  return {
    for (final a in SemanticsAction.values)
      if (data.hasAction(a)) a,
  };
}

/// Todos os nós abaixo de [root], em pré-ordem (ordem da árvore = ordem do documento).
List<SemanticsNode> _descendants(SemanticsNode root) {
  final out = <SemanticsNode>[];
  void visit(SemanticsNode n) {
    n.visitChildren((c) {
      out.add(c);
      visit(c);
      return true;
    });
  }

  visit(root);
  return out;
}

/// Filhos diretos na ordem da árvore.
List<SemanticsNode> _children(SemanticsNode n) {
  final out = <SemanticsNode>[];
  n.visitChildren((c) {
    out.add(c);
    return true;
  });
  return out;
}

/// Rótulos dos filhos diretos na ordem da árvore e na ordem de travessia do leitor de tela.
List<String> _childLabels(SemanticsNode n) => [
  for (final c in _children(n)) c.label,
];

List<String> _traversalLabels(SemanticsNode n) => [
  for (final c in n.debugListChildrenInOrder(
    DebugSemanticsDumpOrder.traversalOrder,
  ))
    c.label,
];

String _show(String label) => label.replaceAll('\n', r'\n');

const _reason = 'Porque você lê Machado de Assis';

/// Nome de cada link = textos do item na ordem do documento (como o nome calculado de um `<a>`); o
/// Flutter junta os rótulos dos filhos fundidos com "\n": título da capa, autor da capa, título do item
/// INTEIRO (as reticências de "Memórias Póstu…" são só da pintura) e autor. A capa do Quincas mantém o
/// `<br>` do arquivo.
const _itemNames = {
  'forYou.item1': 'Memórias Póstumas de Brás Cubas\nMACHADO DE ASSIS\nMemórias Póstumas\nMachado de Assis',
  'forYou.item2':
      'Quincas\nBorba\nMACHADO DE ASSIS\nQuincas Borba\nMachado de Assis',
  'forYou.item3': 'O Cortiço\nALUÍSIO AZEVEDO\nO Cortiço\nAluísio Azevedo',
};

/// Livro de cada item (o callback recebe o livro do item tocado).
const _itemBooks = {
  'forYou.item1': HomeMockRepository.memoriasPostumas,
  'forYou.item2': HomeMockRepository.quincasBorba,
  'forYou.item3': HomeMockRepository.oCortico,
};

/// Ids internos de cada item (da tabela da F08): 9, 13 e 11.
const _itemIdCounts = {
  'forYou.item1': 9,
  'forYou.item2': 13,
  'forYou.item3': 11,
};

/// F08 — semântica e toques da seção `forYou`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'seção "Para você" (container + explicitChildNodes): h3, link "Ver tudo", chip do motivo e o carrossel com 3 links, na ordem do documento',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);

      // <section aria-label="Para você">: nó próprio que NÃO absorve os filhos.
      final section = _section(tester);
      expect(section.label, 'Para você');
      expect(section.flagsCollection.isHeader, isFalse);
      expect(section.flagsCollection.isLink, isFalse);
      expect(section.flagsCollection.isButton, isFalse);
      expect(section.mergeAllDescendantsIntoThisNode, isFalse);
      // O mesmo nó achado pelo rótulo (o que não é cabeçalho).
      expect(
        find.semantics
            .byPredicate(
              (n) => n.label == 'Para você' && !n.flagsCollection.isHeader,
            )
            .evaluate()
            .single,
        same(section),
      );
      // A Key `forYou` (retângulo 20→370 do `_fullBleed`) não pertence à subárvore da seção.
      expect(_node(tester, 'forYou'), isNot(same(section)));
      // O `Semantics` envolve a coluna de largura toda (o carrossel sangra de 0 a 390); a Key `forYou`
      // tem 350 de largura, como o `<section>` do arquivo.
      final keyRect = tester.getRect(find.byKey(const ValueKey('forYou')));
      debugPrint(
        '[semântica] seção: nó ${section.rect.size} · Key forYou $keyRect',
      );
      expect(section.rect.size, tester.getSize(find.byType(ForYouSection)));
      expect(section.rect.width, 390);
      expect(keyRect.width, 350);

      // Filhos diretos na ordem do documento: <h3>, <a>Ver tudo</a>, o texto do chip e o carrossel
      // (nó de rolagem, sem rótulo) com os 3 <a>.
      const sectionChildren = ['Para você', 'Ver tudo', _reason, ''];
      debugPrint(
        '[semântica] filhos da seção: ${_childLabels(section).map(_show).join(' | ')}',
      );
      expect(_childLabels(section), sectionChildren);
      expect(_traversalLabels(section), sectionChildren);
      // Os filhos são exatamente os nós do <h3>, do link "Ver tudo", do texto do chip e da rolagem —
      // não só nós com os mesmos rótulos.
      final scroll = _scrollNode(tester);
      final sectionNodes = _children(section);
      expect(sectionNodes, hasLength(4));
      expect(sectionNodes[0], same(_node(tester, 'forYou.title')));
      expect(sectionNodes[1], same(_node(tester, 'forYou.seeAll')));
      expect(sectionNodes[2], same(_textNode(tester, 'forYou.reasonChip')));
      expect(sectionNodes[3], same(scroll));
      debugPrint(
        '[semântica] filhos do carrossel: ${_childLabels(scroll).map(_show).join(' | ')}',
      );
      expect(_childLabels(scroll), _itemNames.values.toList());
      expect(_traversalLabels(scroll), _itemNames.values.toList());
      final scrollNodes = _children(scroll);
      expect(scrollNodes, hasLength(3));
      for (final (i, item) in _itemNames.keys.indexed) {
        expect(scrollNodes[i], same(_node(tester, item)), reason: item);
      }
      // Nada além disso na subárvore: 4 filhos diretos + 3 links = 7 nós (nenhum texto dos itens,
      // nenhum ícone e nenhuma forma das capas vira nó solto).
      final all = _descendants(section);
      expect(all.map((n) => n.label).toList(), [
        'Para você',
        'Ver tudo',
        _reason,
        '',
        ..._itemNames.values,
      ]);
      // Papéis na seção inteira (a própria seção incluída): 1 cabeçalho (o <h3>, nível 3), 4 links
      // ("Ver tudo" + 3 itens), nenhum botão; nenhum nó de imagem (os 2 svgs ficam fora da árvore: a seta
      // do link não põe o flag de imagem no nó do link, e o brilho aria-hidden do chip não vira nó); e nenhum
      // valor, dica ou tooltip (o arquivo não tem aria-valuetext, aria-description nem title).
      final withSection = [section, ...all];
      expect(
        [
          for (final n in withSection)
            if (n.flagsCollection.isHeader) n.label,
        ],
        ['Para você'],
      );
      expect(
        [
          for (final n in withSection)
            if (n.getSemanticsData().headingLevel != 0)
              (n.label, n.getSemanticsData().headingLevel),
        ],
        [('Para você', 3)],
      );
      expect(
        [
          for (final n in withSection)
            if (n.flagsCollection.isLink) n.label,
        ],
        ['Ver tudo', ..._itemNames.values],
      );
      expect(withSection.where((n) => n.flagsCollection.isButton), isEmpty);
      expect(withSection.where((n) => n.flagsCollection.isImage), isEmpty);
      for (final n in withSection) {
        expect(n.value, isEmpty, reason: _show(n.label));
        expect(n.hint, isEmpty, reason: _show(n.label));
        expect(n.tooltip, isEmpty, reason: _show(n.label));
        // As reticências de "Memórias Póstu…" são só da pintura: nenhum nome as contém.
        expect(n.label, isNot(contains('…')), reason: _show(n.label));
      }

      // <h3>Para você</h3>.
      final title = _node(tester, 'forYou.title');
      expect(title.label, 'Para você');
      expect(title.flagsCollection.isHeader, isTrue);
      expect(title.getSemanticsData().headingLevel, 3);
      expect(title.flagsCollection.isLink, isFalse);
      expect(title.flagsCollection.isButton, isFalse);
      expect(title.childrenCount, 0);
      expect(
        title.rect.size,
        tester.getSize(find.byKey(const ValueKey('forYou.title'))),
      );
      expect(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isHeader && n.label == 'Para você',
        ),
        findsOne,
      );
      // "Para você" aparece 2 vezes: o rótulo da seção e o cabeçalho.
      expect(find.semantics.byLabel('Para você'), findsNWidgets(2));

      // <a href>Ver tudo <svg/></a>: link (não botão) cujo nome é só o texto — a seta é um svg decorativo
      // sem nome acessível (no Flutter, `ExcludeSemantics` do AppSvg): cai no mesmo nó sem acrescentar
      // rótulo nem o flag de imagem. Retângulo = alvo de toque 77,99 × 44.
      final seeAll = _node(tester, 'forYou.seeAll');
      expect(seeAll.label, 'Ver tudo');
      expect(seeAll.flagsCollection.isLink, isTrue);
      expect(seeAll.flagsCollection.isButton, isFalse);
      expect(seeAll.flagsCollection.isHeader, isFalse);
      expect(seeAll.flagsCollection.isImage, isFalse);
      expect(seeAll.childrenCount, 0);
      expect(_node(tester, 'forYou.seeAll.icon'), same(seeAll));
      final seeAllSize = tester.getSize(
        find.byKey(const ValueKey('forYou.seeAll')),
      );
      debugPrint(
        '[semântica] "Ver tudo": ${seeAll.rect.size} (Key $seeAllSize)',
      );
      expect(seeAll.rect.size, seeAllSize);
      expect(seeAll.rect.height, 44);

      // Chip do motivo: <span> com o texto visível → nó de texto próprio, sem papel de botão/link; o
      // brilho (aria-hidden) não gera nó (a Key cai no nó da seção), e a pílula também não.
      final chip = _textNode(tester, 'forYou.reasonChip');
      expect(chip.label, _reason);
      expect(chip, isNot(same(section)));
      expect(chip.flagsCollection.isButton, isFalse);
      expect(chip.flagsCollection.isLink, isFalse);
      expect(chip.flagsCollection.isHeader, isFalse);
      expect(chip.flagsCollection.isImage, isFalse);
      expect(chip.childrenCount, 0);
      expect(_actionsOf(chip), isEmpty);
      expect(_node(tester, 'forYou.reasonChip'), same(section));
      expect(_node(tester, 'forYou.reasonChip.icon'), same(section));
      expect(find.semantics.byLabel(_reason), findsOne);

      // Os 3 <a href> do carrossel: sem aria-label → o nome é o texto do item; tudo do item cai nesse nó.
      final carouselRect = tester.getRect(
        find.byKey(const ValueKey('forYou.carousel')),
      );
      for (final MapEntry(key: item, value: name) in _itemNames.entries) {
        final link = _node(tester, item);
        final visible = tester
            .getRect(find.byKey(ValueKey(item)))
            .intersect(carouselRect);
        debugPrint(
          '[semântica] $item: link "${_show(link.label)}" · ${link.rect.size} (visível $visible)',
        );
        expect(link.label, name, reason: item);
        expect(link.flagsCollection.isLink, isTrue, reason: item);
        expect(link.flagsCollection.isButton, isFalse, reason: item);
        expect(link.flagsCollection.isHeader, isFalse, reason: item);
        expect(link.childrenCount, 0, reason: item);
        // Retângulo do nó = parte visível do item (o 3º é recortado em 390: 280→390 = 110).
        expect(link.rect.size, visible.size, reason: item);
        final ids = idsOfSection('forYou')
            .where((id) => id == item || id.startsWith('$item.'))
            .toList();
        expect(ids, hasLength(_itemIdCounts[item]), reason: item);
        for (final id in ids) {
          expect(_node(tester, id), same(link), reason: id);
        }
      }
      expect(_node(tester, 'forYou.item3').rect.width, 110);

      // Nenhum texto dos itens vira nó solto na seção (nem o "…" da pintura).
      final sectionLabels = all.map((n) => n.label).toSet();
      for (final text in [
        'Memórias Póstumas de Brás Cubas',
        'MACHADO DE ASSIS',
        'Memórias Póstumas',
        'Memórias Póstu…',
        'Machado de Assis',
        'Quincas\nBorba',
        'Quincas Borba',
        'O Cortiço',
        'ALUÍSIO AZEVEDO',
        'Aluísio Azevedo',
      ]) {
        expect(sectionLabels, isNot(contains(text)), reason: text);
      }

      // Carrossel: nó de rolagem sem rótulo nem papel, 390 × 218,4, em repouso no 0 com extensão 26,
      // pai dos 3 links. A Key `forYou.carousel` fica no `SingleChildScrollView`, cujo primeiro render
      // object está ACIMA do nó de rolagem do `Scrollable`: `getSemantics` da Key sobe até a seção.
      expect(_node(tester, 'forYou.carousel'), same(section));
      for (final item in _itemNames.keys) {
        expect(_node(tester, item).parent, same(scroll), reason: item);
      }
      expect(scroll.parent, same(section));
      expect(scroll.label, '');
      expect(scroll.flagsCollection.isLink, isFalse);
      expect(scroll.flagsCollection.isButton, isFalse);
      expect(scroll.flagsCollection.isHeader, isFalse);
      expect(scroll.rect.size, carouselRect.size);
      final scrollData = scroll.getSemanticsData();
      debugPrint(
        '[semântica] carrossel: posição ${scrollData.scrollPosition} de '
        '${scrollData.scrollExtentMin}…${scrollData.scrollExtentMax}, '
        'implicitScrolling ${scroll.flagsCollection.hasImplicitScrolling}, '
        'ações ${_actionsOf(scroll).map((a) => a.name).toList()}',
      );
      expect(scrollData.scrollPosition, 0);
      expect(scrollData.scrollExtentMin, 0);
      expect(scrollData.scrollExtentMax, 26);
      // A física da plataforma permite rolagem implícita (é isso que expõe o scrollToOffset).
      expect(scroll.flagsCollection.hasImplicitScrolling, isTrue);

      // Desde a F12 a tela liga os destinos: os 4 links ("Ver tudo" e os 3 itens) têm a ação de toque e a
      // única outra ação da seção é a rolagem horizontal do carrossel (avançar = scrollLeft; scrollToOffset do iOS).
      final withActions = {
        for (final n in [section, ...all])
          if (_actionsOf(n).isNotEmpty) n.label: _actionsOf(n),
      };
      final links = all.where((n) => n.flagsCollection.isLink).toList();
      expect(links, hasLength(4));
      expect(withActions, {
        '': {SemanticsAction.scrollLeft, SemanticsAction.scrollToOffset},
        for (final n in links) n.label: {SemanticsAction.tap},
      });
      semantics.dispose();
    },
  );

  testWidgets(
    'toques: cada item (o <a> inteiro, 116 × 218,4) chama onBookTap com o seu livro (toque e ação semântica); "Ver tudo" (alvo de 44) chama onSeeAllTap; título, chip e vãos não disparam nada',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final tapped = <Book>[];
      var seeAll = 0;
      await _pumpSection(
        tester,
        onBookTap: tapped.add,
        onSeeAllTap: () => seeAll++,
      );
      for (final id in ['forYou.seeAll', ..._itemNames.keys]) {
        expect(
          _node(tester, id).getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason: id,
        );
      }

      Rect rect(String id) => tester.getRect(find.byKey(ValueKey(id)));
      final carousel = rect('forYou.carousel');

      // Toque real no centro de cada item (o 3º, 280→396, só na parte visível 280→390).
      await tester.tap(find.byKey(const ValueKey('forYou.item1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('forYou.item2')));
      await tester.pumpAndSettle();
      final item3Visible = rect('forYou.item3').intersect(carousel);
      debugPrint(
        '[toque] item3 ${rect('forYou.item3')} · visível $item3Visible',
      );
      expect(item3Visible.right, 390);
      await tester.tapAt(item3Visible.center);
      await tester.pumpAndSettle();
      expect(tapped, [
        HomeMockRepository.memoriasPostumas,
        HomeMockRepository.quincasBorba,
        HomeMockRepository.oCortico,
      ]);
      // O <a> é o item inteiro: capa e legendas também tocam o link.
      await tester.tap(find.byKey(const ValueKey('forYou.item1.cover.title')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('forYou.item2.author')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('forYou.item3.cover.textBlock')),
      );
      await tester.pumpAndSettle();
      expect(tapped.skip(3).toList(), _itemBooks.values.toList());
      // … inclusive os pontos do <a> sem conteúdo pintado: o vão de 10 entre a capa e as legendas, o
      // canto inferior direito (à direita do autor, que é mais curto que 116) e o canto superior esquerdo
      // da parte visível do 3º item.
      final item1 = rect('forYou.item1');
      final item2 = rect('forYou.item2');
      final item3 = rect('forYou.item3');
      final item1Gap = Offset(
        item1.center.dx,
        (rect('forYou.item1.cover').bottom +
                rect('forYou.item1.textBlock').top) /
            2,
      );
      for (final (what, point) in [
        ('vão capa→legendas do item1', item1Gap),
        (
          'canto inferior direito do item2',
          item2.bottomRight - const Offset(2, 2),
        ),
        (
          'canto superior esquerdo do item3',
          item3.topLeft + const Offset(2, 2),
        ),
      ]) {
        debugPrint('[toque] dentro do <a>: $what em $point');
        await tester.tapAt(point);
        await tester.pumpAndSettle();
      }
      expect(item1Gap.dy, closeTo(287.6, 1e-3));
      expect(tapped.skip(6).toList(), _itemBooks.values.toList());

      // Ação semântica de toque em cada link (achado pelo nome).
      for (final name in _itemNames.values) {
        tester.semantics.tap(
          find.semantics.byPredicate(
            (n) => n.flagsCollection.isLink && n.label == name,
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(tapped.map((b) => b.id), [
        for (var i = 0; i < 4; i++) ...[
          'memorias-postumas-de-bras-cubas',
          'quincas-borba',
          'o-cortico',
        ],
      ]);
      expect(seeAll, 0);

      // "Ver tudo": texto e seta (toque real), o alvo de 44 de altura acima do texto, o vão de 4 entre
      // o texto e a seta, e a ação semântica.
      final seeAllRect = rect('forYou.seeAll');
      final seeAllIcon = rect('forYou.seeAll.icon');
      await tester.tap(find.byKey(const ValueKey('forYou.seeAll')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('forYou.seeAll.icon')));
      await tester.pumpAndSettle();
      for (final (what, point) in [
        ('topo do alvo de 44', seeAllRect.topLeft + const Offset(2, 2)),
        ('vão texto→seta', Offset(seeAllIcon.left - 2, seeAllIcon.center.dy)),
      ]) {
        debugPrint('[toque] dentro de "Ver tudo": $what em $point');
        await tester.tapAt(point);
        await tester.pumpAndSettle();
      }
      tester.semantics.tap(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isLink && n.label == 'Ver tudo',
        ),
      );
      await tester.pumpAndSettle();
      expect(seeAll, 5);
      expect(tapped, hasLength(12));

      // Título h3, chip do motivo e os vãos: nenhum callback.
      final header = rect('forYou.header');
      final title = rect('forYou.title');
      final chip = rect('forYou.reasonChip');
      await tester.tap(find.byKey(const ValueKey('forYou.title')));
      await tester.tap(find.byKey(const ValueKey('forYou.reasonChip')));
      await tester.tap(find.byKey(const ValueKey('forYou.reasonChip.icon')));
      for (final (what, point) in [
        // recuo de 20 à esquerda e à direita do cabeçalho (fora do retângulo 20→370 da seção)
        ('à esquerda do título', Offset(10, header.center.dy)),
        ('à direita de "Ver tudo"', Offset(380, header.center.dy)),
        // abaixo do título, ainda no cabeçalho de 44 (o h3 não é link)
        ('abaixo do título', Offset(title.left + 20, header.bottom - 2)),
        // entre o título e "Ver tudo" (space-between)
        ('cabeçalho', Offset(200, header.center.dy)),
        // à direita do chip (align-self: flex-start)
        ('ao lado do chip', Offset(chip.right + 20, chip.center.dy)),
        // os 18 px entre o chip e o carrossel (gap 14 + margem 4)
        ('entre chip e carrossel', Offset(60, chip.bottom + 9)),
        // padding esquerdo do carrossel (0→20)
        ('padding do carrossel', Offset(10, item1.center.dy)),
        // gaps de 14 entre os itens
        ('entre item1 e item2', Offset(item1.right + 7, item1.center.dy)),
        ('entre item2 e item3', Offset(item2.right + 7, item2.center.dy)),
        // a parte cortada do 3º item (390→396) fica fora do carrossel
        ('parte cortada do item3', Offset(393, item3.center.dy)),
      ]) {
        debugPrint('[toque] sem efeito: $what em $point');
        await tester.tapAt(point);
      }
      await tester.pumpAndSettle();
      expect(tapped, hasLength(12));
      expect(seeAll, 5);
      semantics.dispose();
    },
  );

  testWidgets(
    'ações semânticas da seção: só o toque dos 4 links e a rolagem horizontal do carrossel (D-03), que funciona sem disparar toques; os toques acompanham a rolagem',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final tapped = <Book>[];
      var seeAll = 0;
      await _pumpSection(
        tester,
        onBookTap: tapped.add,
        onSeeAllTap: () => seeAll++,
      );
      final section = _section(tester);
      final all = [section, ..._descendants(section)];
      final withActions = {
        for (final n in all)
          if (_actionsOf(n).isNotEmpty) n.label: _actionsOf(n),
      };
      for (final MapEntry(key: label, value: actions) in withActions.entries) {
        debugPrint(
          '[semântica] ações de "${_show(label)}": ${actions.map((a) => a.name).toList()}',
        );
      }
      expect(withActions, {
        'Ver tudo': {SemanticsAction.tap},
        for (final name in _itemNames.values) name: {SemanticsAction.tap},
        '': {SemanticsAction.scrollLeft, SemanticsAction.scrollToOffset},
      });
      // Só 5 nós com ação (os 4 links e o carrossel); seção, h3 e chip sem nenhuma.
      expect(all.where((n) => _actionsOf(n).isNotEmpty), hasLength(5));

      // Rolagem semântica (física da plataforma de teste): avançar leva ao fim (26), voltar leva ao 0.
      final position = _carouselPosition(tester);
      final carousel = tester.getRect(
        find.byKey(const ValueKey('forYou.carousel')),
      );
      Size visible(String id) =>
          tester.getRect(find.byKey(ValueKey(id))).intersect(carousel).size;

      tester.semantics.scrollLeft(
        scrollable: find.semantics.scrollable(axis: Axis.horizontal),
      );
      await tester.pumpAndSettle();
      debugPrint(
        '[semântica] scrollLeft → ${position.pixels} de ${position.maxScrollExtent}; '
        'item1 ${_node(tester, 'forYou.item1').rect.size} · item3 ${_node(tester, 'forYou.item3').rect.size}',
      );
      expect(position.pixels, 26);
      expect(position.maxScrollExtent, 26);
      final atEnd = _scrollNode(tester);
      expect(atEnd.getSemanticsData().scrollPosition, 26);
      expect(_actionsOf(atEnd), {
        SemanticsAction.scrollRight,
        SemanticsAction.scrollToOffset,
      });
      // No fim, o 1º item é que fica cortado (−6→110) e o 3º aparece inteiro (254→370).
      expect(_node(tester, 'forYou.item1').rect.size, visible('forYou.item1'));
      expect(_node(tester, 'forYou.item1').rect.width, 110);
      expect(_node(tester, 'forYou.item3').rect.width, 116);

      tester.semantics.scrollRight(
        scrollable: find.semantics.scrollable(axis: Axis.horizontal),
      );
      await tester.pumpAndSettle();
      expect(position.pixels, 0);
      expect(_actionsOf(_scrollNode(tester)), {
        SemanticsAction.scrollLeft,
        SemanticsAction.scrollToOffset,
      });
      expect(_node(tester, 'forYou.item3').rect.width, 110);

      // scrollToOffset (foco do iOS): salta para o deslocamento pedido.
      tester.semantics.performAction(
        find.semantics.scrollable(axis: Axis.horizontal),
        SemanticsAction.scrollToOffset,
        args: Float64List.fromList([13, 0]),
      );
      await tester.pumpAndSettle();
      expect(position.pixels, 13);
      expect(_actionsOf(_scrollNode(tester)), {
        SemanticsAction.scrollLeft,
        SemanticsAction.scrollRight,
        SemanticsAction.scrollToOffset,
      });
      tester.semantics.performAction(
        find.semantics.scrollable(axis: Axis.horizontal),
        SemanticsAction.scrollToOffset,
        args: Float64List.fromList([0, 0]),
      );
      await tester.pumpAndSettle();
      expect(position.pixels, 0);

      // Rolar não toca em nenhum item.
      expect(tapped, isEmpty);
      expect(seeAll, 0);

      // Arrastar o carrossel começando sobre um item também não é toque: a rolagem vence a disputa de
      // gestos, o carrossel vai ao fim (26) e o callback não é chamado.
      await tester.drag(
        find.byKey(const ValueKey('forYou.item2')),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();
      expect(position.pixels, 26);
      expect(tapped, isEmpty);
      // No fim, os toques acompanham a rolagem: o 3º item inteiro (254→370), a parte visível do 1º
      // (−6→110, recortado em 0) e nada no padding direito do carrossel (370→390).
      final item3AtEnd = tester.getRect(
        find.byKey(const ValueKey('forYou.item3')),
      );
      debugPrint('[toque] no fim da rolagem: item3 $item3AtEnd');
      expect(item3AtEnd.left, 254);
      expect(item3AtEnd.right, 370);
      await tester.tapAt(item3AtEnd.center);
      await tester.pumpAndSettle();
      await tester.tapAt(Offset(5, item3AtEnd.center.dy));
      await tester.pumpAndSettle();
      await tester.tapAt(Offset(380, item3AtEnd.center.dy));
      await tester.pumpAndSettle();
      expect(tapped, [
        HomeMockRepository.oCortico,
        HomeMockRepository.memoriasPostumas,
      ]);
      await tester.drag(
        find.byKey(const ValueKey('forYou.item2')),
        const Offset(100, 0),
      );
      await tester.pumpAndSettle();
      expect(position.pixels, 0);
      expect(tapped, hasLength(2));
      expect(seeAll, 0);
      semantics.dispose();
    },
  );

  testWidgets(
    'sem callbacks (tela antes da F12): os links existem sem ação de toque e tocar não quebra nada',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpSection(tester);
      for (final id in ['forYou.seeAll', ..._itemNames.keys]) {
        final link = _node(tester, id);
        expect(link.flagsCollection.isLink, isTrue, reason: id);
        expect(
          link.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
          reason: id,
        );
      }
      final carousel = tester.getRect(
        find.byKey(const ValueKey('forYou.carousel')),
      );
      await tester.tap(find.byKey(const ValueKey('forYou.item1')));
      await tester.tap(find.byKey(const ValueKey('forYou.item2')));
      await tester.tapAt(
        tester
            .getRect(find.byKey(const ValueKey('forYou.item3')))
            .intersect(carousel)
            .center,
      );
      await tester.tap(find.byKey(const ValueKey('forYou.seeAll')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // A rolagem continua disponível.
      expect(_actionsOf(_scrollNode(tester)), {
        SemanticsAction.scrollLeft,
        SemanticsAction.scrollToOffset,
      });
      semantics.dispose();
    },
  );
}
