import 'dart:ui' show Tristate;

import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/placeholder/presentation/placeholder_screen.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

SemanticsNode _node(WidgetTester tester, String id) =>
    tester.getSemantics(find.byKey(ValueKey<String>(id)));

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

/// Filhos diretos na ordem da árvore (= ordem do documento).
List<SemanticsNode> _children(SemanticsNode n) {
  final out = <SemanticsNode>[];
  n.visitChildren((c) {
    out.add(c);
    return true;
  });
  return out;
}

/// Todos os nós abaixo de [root], em pré-ordem.
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

/// Todos os nós da árvore semântica do app, para provar que não há leitura duplicada.
List<SemanticsNode> _wholeTree(WidgetTester tester) =>
    find.semantics.byPredicate((_) => true).evaluate().toList();

/// Filhos da `<nav aria-label="Navegação principal">`, na ordem do documento: o `<a>` de cada item.
const _items = [
  'Início',
  'Biblioteca',
  'Scanner: escanear livro ou página',
  'Clubes',
  'Perfil',
];

Future<void> _device(WidgetTester tester) async {
  setCanvasView(
    tester,
    logical: const Size(390, 844),
    safeTop: 47,
    safeBottom: 34,
  );
  await pumpApp(tester);
}

/// F11 11.5 — semântica da navegação.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '`<nav aria-label="Navegação principal">`: container com explicitChildNodes e 5 nós-filhos na ordem do documento (Início, Biblioteca, Scanner, Clubes, Perfil); ícones, FAB e fade fora da árvore',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);

      final nav = _node(tester, 'nav');
      expect(nav.label, 'Navegação principal');
      expect(nav.flagsCollection.isHeader, isFalse);
      expect(nav.flagsCollection.isLink, isFalse);
      expect(nav.flagsCollection.isButton, isFalse);
      expect(nav.mergeAllDescendantsIntoThisNode, isFalse);
      expect(nav.value, isEmpty);
      expect(nav.hint, isEmpty);
      expect(nav.rect.size, tester.getSize(find.byKey(const ValueKey('nav'))));
      expect([for (final c in _children(nav)) c.label], _items);
      // A travessia do leitor de tela é geométrica: aqui coincide com a ordem do documento (mesmo topo, esquerda → direita).
      expect(_traversalLabels(nav), _items);
      // Só 5 nós em toda a subárvore: o texto, o ícone e o FAB não criam nós próprios.
      expect([for (final n in _descendants(nav)) n.label], _items);

      // Cada item é o nó do link (o texto do rótulo se funde nele; o ícone é aria-hidden).
      final nodes = _children(nav);
      for (final (i, id) in [
        'nav.home',
        'nav.library',
        'nav.scanner',
        'nav.clubs',
        'nav.profile',
      ].indexed) {
        expect(nodes[i], same(_node(tester, id)), reason: id);
        expect(nodes[i].flagsCollection.isLink, isTrue, reason: id);
        expect(nodes[i].flagsCollection.isButton, isFalse, reason: id);
        expect(nodes[i].flagsCollection.isImage, isFalse, reason: id);
        expect(nodes[i].childrenCount, 0, reason: id);
        expect(nodes[i].value, isEmpty, reason: id);
        expect(nodes[i].hint, isEmpty, reason: id);
        expect(nodes[i].tooltip, isEmpty, reason: id);
        expect(
          nodes[i].rect.size,
          tester.getSize(find.byKey(ValueKey(id))),
          reason: id,
        );
      }
      for (final id in ['home', 'library', 'clubs', 'profile']) {
        expect(
          _node(tester, 'nav.$id.icon'),
          same(_node(tester, 'nav.$id')),
          reason: '$id.icon',
        );
        expect(
          _node(tester, 'nav.$id.label'),
          same(_node(tester, 'nav.$id')),
          reason: '$id.label',
        );
      }
      semantics.dispose();
    },
  );

  testWidgets(
    '`aria-current="page"`: só o item ativo tem o estado "selecionado" (Início); os outros não têm estado nenhum; o nome é o rótulo visível',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);
      final selected = {
        for (final id in ['home', 'library', 'clubs', 'profile'])
          id: _node(tester, 'nav.$id').flagsCollection.isSelected,
      };
      expect(selected, {
        'home': Tristate.isTrue,
        'library': Tristate.none,
        'clubs': Tristate.none,
        'profile': Tristate.none,
      });
      expect(
        _node(tester, 'nav.scanner').flagsCollection.isSelected,
        Tristate.none,
      );
      // O `Semantics(selected: true)` fica DENTRO do `Pressable`: a seleção se funde no nó do link (sem nó extra) e
      // o nome continua sendo o texto do rótulo.
      final home = _node(tester, 'nav.home');
      expect(home.label, 'Início');
      expect(home.flagsCollection.isLink, isTrue);
      expect(_descendants(_node(tester, 'nav')), hasLength(5));
      semantics.dispose();
    },
  );

  testWidgets(
    'o item ativo acompanha a aba: ao trocar de aba o estado "selecionado" passa para ela (D-07) e continua um nó só por item',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _device(tester);
      for (final (path, active) in [
        (AppRoutes.biblioteca, 'library'),
        (AppRoutes.clubes, 'clubs'),
        (AppRoutes.perfil, 'profile'),
        (AppRoutes.inicio, 'home'),
      ]) {
        _router(tester).go(path);
        await tester.pumpAndSettle();
        for (final id in ['home', 'library', 'clubs', 'profile']) {
          expect(
            _node(tester, 'nav.$id').flagsCollection.isSelected,
            id == active ? Tristate.isTrue : Tristate.none,
            reason: '$path → nav.$id',
          );
        }
        expect(
          [for (final c in _children(_node(tester, 'nav'))) c.label],
          _items,
          reason: path,
        );
        expect(_descendants(_node(tester, 'nav')), hasLength(5), reason: path);
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'Scanner: `aria-label` do arquivo em um único nó (link, sem leitura duplicada): o rótulo "Scanner" e o FAB não geram outro nó; em toda a árvore do app só um nó fala de "Scanner"',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _device(tester);
      final scanner = _node(tester, 'nav.scanner');
      expect(scanner.label, 'Scanner: escanear livro ou página');
      expect(scanner.flagsCollection.isLink, isTrue);
      expect(scanner.flagsCollection.isButton, isFalse);
      expect(scanner.childrenCount, 0);
      // O texto "Scanner" do item é excluído (o `aria-label` o substitui).
      expect(_node(tester, 'nav.scanner.label'), same(scanner));
      // O FAB é `ExcludeSemantics`: não tem nó próprio e o ícone tampouco.
      final fab = _node(tester, 'nav.scanner.fab');
      expect(fab, isNot(same(scanner)));
      expect(fab.label, isNot(contains('Scanner')));
      expect(fab.flagsCollection.isLink, isFalse);
      expect(fab.flagsCollection.isButton, isFalse);
      expect(_node(tester, 'nav.scanner.icon'), same(fab));
      final tree = _wholeTree(tester);
      expect(
        [
          for (final n in tree)
            if (n.label.toLowerCase().contains('scanner')) n.label,
        ],
        ['Scanner: escanear livro ou página'],
      );
      // Nenhum nó da árvore cobre a região do FAB que fica fora da barra (acima dela).
      final above = const Offset(195, 730);
      final hits = [
        for (final n in tree)
          if (_globalRect(n).contains(above) && n.label.isNotEmpty) n.label,
      ];
      expect(hits, isNot(contains('Scanner: escanear livro ou página')));
      semantics.dispose();
    },
  );

  testWidgets(
    'papéis na navegação: 1 container, 5 links, nenhum botão/imagem/cabeçalho; só os 5 links têm ação de toque; a barra e os itens não têm hint, valor nem tooltip',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);
      final nav = _node(tester, 'nav');
      final all = [nav, ..._descendants(nav)];
      expect(all.where((n) => n.flagsCollection.isLink), hasLength(5));
      expect(all.where((n) => n.flagsCollection.isButton), isEmpty);
      expect(all.where((n) => n.flagsCollection.isImage), isEmpty);
      expect(all.where((n) => n.flagsCollection.isHeader), isEmpty);
      for (final n in all) {
        expect(n.value, isEmpty, reason: n.label);
        expect(n.hint, isEmpty, reason: n.label);
        expect(n.tooltip, isEmpty, reason: n.label);
      }
      expect(_actionsOf(nav), isEmpty);
      for (final n in _descendants(nav)) {
        expect(_actionsOf(n), {SemanticsAction.tap}, reason: n.label);
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'ações semânticas: tocar um item chama a mesma ação do toque — troca de aba nos 4 itens e push de /scanner no Scanner',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _device(tester);
      // Só os links DA BARRA: o link "Biblioteca" da seção Recém-chegados (F10) tem o mesmo nome.
      SemanticsFinder link(String label) => find.semantics.byPredicate(
        (n) =>
            n.flagsCollection.isLink &&
            n.label == label &&
            n.parent?.label == 'Navegação principal',
      );
      for (final (label, path, title) in [
        ('Biblioteca', AppRoutes.biblioteca, 'Biblioteca'),
        ('Clubes', AppRoutes.clubes, 'Clubes'),
        ('Perfil', AppRoutes.perfil, 'Perfil'),
        ('Início', AppRoutes.inicio, null),
      ]) {
        tester.semantics.tap(link(label));
        await tester.pumpAndSettle();
        expect(_router(tester).state.uri.path, path, reason: label);
        if (title == null) {
          expect(find.byType(HomeScreen), findsOneWidget);
        } else {
          expect(
            find.byWidgetPredicate(
              (w) => w is PlaceholderScreen && w.title == title,
            ),
            findsOneWidget,
            reason: label,
          );
        }
      }
      tester.semantics.tap(link('Scanner: escanear livro ou página'));
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.scanner);
      expect(find.byType(ScannerScreen), findsOneWidget);
      _router(tester).pop();
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.inicio);
      semantics.dispose();
    },
  );
}

/// Retângulo do nó em coordenadas globais (somando as transformações dos ancestrais).
Rect _globalRect(SemanticsNode node) {
  var rect = node.rect;
  var current = node;
  while (current.parent != null) {
    final transform = current.transform;
    if (transform != null) {
      rect = MatrixUtils.transformRect(transform, rect);
    }
    current = current.parent!;
  }
  return rect;
}
