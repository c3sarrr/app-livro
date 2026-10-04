import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/recently_added_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// Só a seção, na largura do conteúdo (350), com os callbacks (a tela liga `/livro/:bookId`, o menu do livro e
/// `/biblioteca` na F12).
Future<void> _pumpSection(
  WidgetTester tester, {
  ValueChanged<Book>? onBookTap,
  ValueChanged<Book>? onMoreTap,
  VoidCallback? onLibraryTap,
  List<Override> overrides = const [],
}) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overridesDoMundo, ...overrides],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 350,
            child: RecentlyAddedSection(
              onBookTap: onBookTap,
              onMoreTap: onMoreTap,
              onLibraryTap: onLibraryTap,
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

/// Nó da `<section aria-label="Adicionados recentemente">`: o `Semantics` raiz da seção (a Key `recent` fica
/// na `Column` logo abaixo, sem nó próprio).
SemanticsNode _section(WidgetTester tester) => _node(tester, 'recent');

/// Nó do AppText sob [id] (texto solto dentro da seção).
SemanticsNode _textNode(WidgetTester tester, String id) => tester.getSemantics(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  ),
);

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

List<String> _childLabels(SemanticsNode n) => [
  for (final c in _children(n)) c.label,
];

/// Ordem de travessia do leitor de tela (a do Flutter ordena por geometria).
List<String> _traversalLabels(SemanticsNode n) => [
  for (final c in n.debugListChildrenInOrder(
    DebugSemanticsDumpOrder.traversalOrder,
  ))
    c.label,
];

Set<SemanticsAction> _actionsOf(SemanticsNode n) {
  final data = n.getSemanticsData();
  return {
    for (final a in SemanticsAction.values)
      if (data.hasAction(a)) a,
  };
}

String _show(String label) => label.replaceAll('\n', r'\n');

/// Filhos diretos da seção, na ordem do documento: cabeçalho, link da biblioteca e, por linha, o `<a>` (nome =
/// título + subtítulo), o selo (texto solto) e o botão.
const _sectionChildren = [
  'Recém-chegados',
  'Biblioteca',
  'Frankenstein\nMary Shelley · EPUB',
  'Quero ler',
  'Mais opções para Frankenstein',
  'O Alienista\nMachado de Assis · PDF',
  'Quero ler',
  'Mais opções para O Alienista',
  'Senhora\nJosé de Alencar · EPUB',
  'Novo',
  'Mais opções para Senhora',
];

/// F10 — semântica e toques da seção `recent`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'seção "Adicionados recentemente" (container + explicitChildNodes): 11 nós na ordem do documento — h3 "Recém-chegados", link "Biblioteca" e, em cada linha, o link (título + subtítulo), o selo e o botão "Mais opções para …"; capas, ícones e divisores fora da árvore',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);

      final section = _section(tester);
      expect(section.label, 'Adicionados recentemente');
      expect(section.flagsCollection.isHeader, isFalse);
      expect(section.flagsCollection.isLink, isFalse);
      expect(section.flagsCollection.isButton, isFalse);
      expect(section.mergeAllDescendantsIntoThisNode, isFalse);
      expect(
        section.rect.size,
        tester.getSize(find.byKey(const ValueKey('recent'))),
      );
      debugPrint(
        '[semântica] filhos da seção: ${_childLabels(section).map(_show).join(' | ')}',
      );
      expect(_childLabels(section), _sectionChildren);
      // A travessia do leitor de tela é a ordenação GEOMÉTRICA padrão do Flutter (não a da árvore). Fixada aqui
      // como lista para que qualquer mudança (por exemplo, sort keys na F12) seja consciente.
      final traversal = _traversalLabels(section);
      debugPrint(
        '[semântica] travessia da seção: ${traversal.map(_show).join(' | ')}',
      );
      expect(traversal, _sectionChildren);

      final nodes = _children(section);
      expect(nodes, hasLength(11));
      // O `<h3>` e o link do cabeçalho.
      expect(nodes[0], same(_node(tester, 'recent.title')));
      expect(nodes[1], same(_node(tester, 'recent.libraryLink')));
      for (var i = 0; i < 3; i++) {
        // Tudo do `<a>` (bloco de texto, título, subtítulo) cai no nó do link.
        expect(nodes[2 + 3 * i], same(_node(tester, 'recent.row$i.textBlock')));
        expect(nodes[2 + 3 * i], same(_node(tester, 'recent.row$i.title')));
        expect(nodes[2 + 3 * i], same(_node(tester, 'recent.row$i.subtitle')));
        // O selo é texto solto na seção (o `<span>` fica fora do `<a>`).
        expect(nodes[3 + 3 * i], same(_textNode(tester, 'recent.row$i.tag')));
        expect(nodes[4 + 3 * i], same(_node(tester, 'recent.row$i.more')));
      }
      // Subárvore inteira: os 11 filhos, sem netos.
      final all = _descendants(section);
      expect(all.map((n) => n.label).toList(), _sectionChildren);

      // aria-hidden / decoração sem nome não geram nós: as Keys caem no nó da seção.
      for (final id in [
        'recent.list',
        'recent.row0',
        'recent.row1',
        'recent.row2',
        'recent.row0.cover',
        'recent.row1.cover',
        'recent.row2.cover',
        'recent.row0.cover.moon',
        'recent.row1.cover.ring',
        'recent.row2.cover.arch',
      ]) {
        expect(_node(tester, id), same(section), reason: id);
      }
      // Os ícones são SVG sem nome acessível (aria-hidden): caem no nó do link / do botão, sem criar nó.
      expect(_node(tester, 'recent.libraryLink.icon'), same(nodes[1]));
      for (var i = 0; i < 3; i++) {
        expect(
          _node(tester, 'recent.row$i.more.icon'),
          same(nodes[4 + 3 * i]),
          reason: '$i',
        );
      }

      // Papéis: 1 cabeçalho (h3, nível 3), 4 links (biblioteca + 3 linhas), 3 botões, nenhuma imagem; sem valores.
      final withSection = [section, ...all];
      expect(
        [
          for (final n in withSection)
            if (n.flagsCollection.isHeader)
              (n.label, n.getSemanticsData().headingLevel),
        ],
        [('Recém-chegados', 3)],
      );
      expect(
        [
          for (final n in withSection)
            if (n.flagsCollection.isLink) _show(n.label),
        ],
        [
          'Biblioteca',
          r'Frankenstein\nMary Shelley · EPUB',
          r'O Alienista\nMachado de Assis · PDF',
          r'Senhora\nJosé de Alencar · EPUB',
        ],
      );
      expect(
        [
          for (final n in withSection)
            if (n.flagsCollection.isButton) n.label,
        ],
        [
          'Mais opções para Frankenstein',
          'Mais opções para O Alienista',
          'Mais opções para Senhora',
        ],
      );
      expect(withSection.where((n) => n.flagsCollection.isImage), isEmpty);
      for (final n in withSection) {
        expect(n.value, isEmpty, reason: _show(n.label));
        expect(n.hint, isEmpty, reason: _show(n.label));
        expect(n.tooltip, isEmpty, reason: _show(n.label));
      }
      // Links e botões não têm filhos (o conteúdo cai neles); botão e link não se misturam.
      for (final n in all.where(
        (n) => n.flagsCollection.isLink || n.flagsCollection.isButton,
      )) {
        expect(n.childrenCount, 0, reason: _show(n.label));
        expect(
          n.flagsCollection.isLink && n.flagsCollection.isButton,
          isFalse,
          reason: _show(n.label),
        );
      }

      // <h3>: nó de cabeçalho do tamanho do título.
      expect(
        nodes[0].rect.size,
        tester.getSize(find.byKey(const ValueKey('recent.title'))),
      );
      // O link da biblioteca: 86,19 × 44 (texto + seta); os botões: 44 × 44.
      expect(
        nodes[1].rect.size,
        tester.getSize(find.byKey(const ValueKey('recent.libraryLink'))),
      );
      for (var i = 0; i < 3; i++) {
        expect(nodes[4 + 3 * i].rect.size, const Size(44, 44), reason: '$i');
        // O link da linha mede o bloco de texto.
        expect(
          nodes[2 + 3 * i].rect.size,
          tester.getSize(find.byKey(ValueKey('recent.row$i.textBlock'))),
          reason: '$i',
        );
      }

      // Nenhum texto interno vira nó solto além dos selos (título/subtítulo/cabeçalho estão em nós próprios).
      final labels = {for (final n in all) n.label};
      for (final label in [
        'Frankenstein',
        'Mary Shelley · EPUB',
        'O Alienista',
        'Machado de Assis · PDF',
        'Senhora',
        'José de Alencar · EPUB',
      ]) {
        expect(labels.contains(label), isFalse, reason: label);
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'rótulos acessíveis derivados dos DADOS: com outros livros mudam o nome do link, o selo e o botão "Mais opções para …"',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      final base = const HomeMockRepository().snapshot(
        HomeMockRepository.referenceNow,
      );
      final data = [
        const RecentItem(
          book: Book(
            id: 'outro',
            title: 'Memórias de Um Sargento de Milícias',
            author: 'Manuel Antônio de Almeida',
            cover: CoverArt.frankenstein,
          ),
          format: BookFormat.pdf,
          status: RecentStatus.isNew,
        ),
        base.recent[1],
        base.recent[2],
      ];
      await _pumpSection(
        tester,
        overrides: [
          homeSnapshotProvider.overrideWithValue(
            HomeSnapshot(
              now: base.now,
              user: base.user,
              continueReading: base.continueReading,
              alsoReading: base.alsoReading,
              readingDay: base.readingDay,
              forYou: base.forYou,
              club: base.club,
              recent: data,
            ),
          ),
        ],
      );
      final labels = _childLabels(_section(tester));
      expect(
        labels[2],
        'Memórias de Um Sargento de Milícias\nManuel Antônio de Almeida · PDF',
      );
      expect(labels[3], 'Novo');
      expect(labels[4], 'Mais opções para Memórias de Um Sargento de Milícias');
      // O resto continua igual.
      expect(labels.sublist(5), _sectionChildren.sublist(5));
      semantics.dispose();
    },
  );

  testWidgets(
    'toques: o link da linha (bloco de texto) chama onBookTap com o livro, o botão chama onMoreTap e "Biblioteca" chama onLibraryTap — cada um só no próprio alvo (capa, selo, título do cabeçalho, divisores e fundo da lista não disparam); as ações semânticas fazem o mesmo',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final books = <String>[], more = <String>[];
      var library = 0;
      await _pumpSection(
        tester,
        onBookTap: (b) => books.add(b.id),
        onMoreTap: (b) => more.add(b.id),
        onLibraryTap: () => library++,
      );
      Rect rect(String id) => tester.getRect(find.byKey(ValueKey(id)));
      // Com os callbacks: as ações de toque ficam nos 4 links e nos 3 botões; mais nenhum nó tem ação.
      final section = _section(tester);
      final withActions = [
        for (final n in _descendants(section))
          if (_actionsOf(n).isNotEmpty) (_show(n.label), _actionsOf(n)),
      ];
      expect(withActions.map((e) => e.$1).toList(), [
        'Biblioteca',
        r'Frankenstein\nMary Shelley · EPUB',
        'Mais opções para Frankenstein',
        r'O Alienista\nMachado de Assis · PDF',
        'Mais opções para O Alienista',
        r'Senhora\nJosé de Alencar · EPUB',
        'Mais opções para Senhora',
      ]);
      for (final (_, actions) in withActions) {
        expect(actions, {SemanticsAction.tap});
      }
      expect(_actionsOf(section), isEmpty);

      // Cada linha: toca em vários pontos do bloco de texto (título, subtítulo, meio).
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(ValueKey('recent.row$i.title')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('recent.row$i.subtitle')));
        await tester.pumpAndSettle();
        await tester.tapAt(rect('recent.row$i.textBlock').center);
        await tester.pumpAndSettle();
      }
      expect(books, [
        'frankenstein', 'frankenstein', 'frankenstein', //
        'o-alienista', 'o-alienista', 'o-alienista',
        'senhora', 'senhora', 'senhora',
      ]);
      expect(more, isEmpty);
      expect(library, 0);

      // Botões "mais opções": no centro, no ícone e perto da borda do círculo (12 px para dentro do canto).
      for (var i = 0; i < 3; i++) {
        final r = rect('recent.row$i.more');
        await tester.tap(find.byKey(ValueKey('recent.row$i.more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('recent.row$i.more.icon')));
        await tester.pumpAndSettle();
        await tester.tapAt(r.center + const Offset(18, 0));
        await tester.pumpAndSettle();
      }
      expect(more, [
        'frankenstein', 'frankenstein', 'frankenstein', //
        'o-alienista', 'o-alienista', 'o-alienista',
        'senhora', 'senhora', 'senhora',
      ]);
      expect(books, hasLength(9)); // o botão não aciona o link

      // Link "Biblioteca": no texto, na seta e na área de toque de 44.
      await tester.tap(find.byKey(const ValueKey('recent.libraryLink')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('recent.libraryLink.icon')));
      await tester.pumpAndSettle();
      expect(library, 2);

      // Ações semânticas.
      tester.semantics.tap(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isLink && n.label == 'Biblioteca',
        ),
      );
      tester.semantics.tap(
        find.semantics.byPredicate(
          (n) =>
              n.flagsCollection.isButton &&
              n.label == 'Mais opções para Senhora',
        ),
      );
      tester.semantics.tap(
        find.semantics.byPredicate(
          (n) => n.flagsCollection.isLink && n.label.startsWith('O Alienista'),
        ),
      );
      await tester.pumpAndSettle();
      expect(library, 3);
      expect(more.last, 'senhora');
      expect(more, hasLength(10));
      expect(books.last, 'o-alienista');
      expect(books, hasLength(10));

      // Nada mais dispara: capa, selo, título do cabeçalho, divisores, fundo da lista e o espaço entre o texto e o
      // selo.
      final before = (books.length, more.length, library);
      for (final id in [
        'recent.row0.cover',
        'recent.row1.cover',
        'recent.row2.cover',
        'recent.row0.tag',
        'recent.row1.tag',
        'recent.row2.tag',
        'recent.title',
        'recent.header',
      ]) {
        await tester.tap(find.byKey(ValueKey(id)), warnIfMissed: false);
      }
      final list = rect('recent.list');
      final row0 = rect('recent.row0');
      for (final (what, point) in [
        ('divisor da linha 0', Offset(row0.center.dx, row0.bottom - 0.5)),
        ('fundo da lista, à esquerda', Offset(list.left + 6, list.center.dy)),
        ('fundo da lista, à direita', Offset(list.right - 4, list.center.dy)),
        ('abaixo da lista', Offset(list.center.dx, list.bottom + 8)),
        (
          'entre o texto e o selo (gap 14)',
          Offset(
            rect('recent.row0.tag').left - 7,
            rect('recent.row0').center.dy,
          ),
        ),
      ]) {
        debugPrint('[toque] sem efeito: $what em $point');
        await tester.tapAt(point);
      }
      await tester.pumpAndSettle();
      expect((books.length, more.length, library), before);
      semantics.dispose();
    },
  );

  testWidgets(
    'sem callbacks (antes da F12) nada tem ação semântica e tocar não faz nada',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpSection(tester);
      for (final n in _descendants(_section(tester))) {
        expect(_actionsOf(n), isEmpty, reason: _show(n.label));
      }
      await tester.tap(find.byKey(const ValueKey('recent.row1.textBlock')));
      await tester.tap(find.byKey(const ValueKey('recent.row1.more')));
      await tester.tap(find.byKey(const ValueKey('recent.libraryLink')));
      await tester.pumpAndSettle();
      semantics.dispose();
    },
  );
}
