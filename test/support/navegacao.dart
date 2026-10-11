// R00.6 (R5) — as ligações das 16 telas prontas, uma entrada por toque da tabela (b) da `docs/NAVEGACAO.md`, e o
// percurso que toca cada uma no app inteiro: ✅ leva à tela certa (a chave do destino aparece, ou a camada fecha), ⏸
// não faz nada por decisão (a rota e a árvore não mudam), 🟡 leva a um placeholder (ou ao aviso "Chega numa próxima
// fase") — alcançado e listado, sem falhar (a R01 passa a falhar por eles). O app é o alvo (2) da D-267: a Início da
// prancha 01 (todas as seções: a revisão, Para você, o clube) e o leitor e os grifos do banco do demo.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/highlights/presentation/highlights_screen.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/placeholder/presentation/placeholder_screen.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'demonstracao_no_app.dart';

/// As três classes da R4.
enum Classe {
  leva('✅'),
  semAcao('⏸'),
  placeholder('🟡');

  const Classe(this.simbolo);
  final String simbolo;

  static Classe doSimbolo(String s) => values.firstWhere((c) => c.simbolo == s);
}

/// Um toque documentado.
final class Ligacao {
  const Ligacao(
    this.origem,
    this.chave,
    this.classe, {
    this.destino,
    this.some,
    this.confere,
    this.titulo,
    this.etapa,
    this.decisao,
    this.tocar,
    this.depois,
  });

  /// De onde sai (as origens de [chegar]).
  final String origem;

  /// A `ValueKey` do widget tocado; um gesto sem chave tem um nome (`r19.pagina@meio`) e o [tocar].
  final String chave;
  final Classe classe;

  /// ✅: o que aparece no destino / o que sai (a camada que fecha) / uma conferência a mais.
  final Finder Function()? destino;
  final Finder Function()? some;
  final Future<void> Function(WidgetTester tester)? confere;

  /// 🟡: o título do `PlaceholderScreen` (ou o texto do aviso) e a etapa que troca.
  final String? titulo;
  final String? etapa;

  /// A decisão que explica (⏸ e algumas ✅).
  final String? decisao;

  /// O gesto, quando não é um toque no centro da chave.
  final Future<void> Function(WidgetTester tester)? tocar;

  /// Arruma depois da conferência (descartar a sessão que o toque abriu, voltar o tema).
  final Future<void> Function(WidgetTester tester)? depois;

  @override
  String toString() => '${classe.simbolo} $origem · $chave';
}

Finder _k(String chave) => find.byKey(ValueKey<String>(chave));

Finder _placeholder(String titulo) =>
    find.byWidgetPredicate((w) => w is PlaceholderScreen && w.title == titulo);

Finder _aviso(String texto) => find.byWidgetPredicate(
  (w) =>
      w is AppText &&
      w.span.toPlainText(includeSemanticsLabels: false) == texto,
);

const String avisoProximaFase = 'Chega numa próxima fase';

Size _tela(WidgetTester t) => t.view.physicalSize / t.view.devicePixelRatio;

/// A rolagem vertical da tela da frente (os grifos ou a Início), para trazer o que a lista ainda não mostrou.
Finder? _rolagem() {
  for (final tela in [find.byType(HighlightsScreen), find.byType(HomeScreen)]) {
    final vertical = find.descendant(
      of: tela,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Scrollable &&
            axisDirectionToAxis(w.axisDirection) == Axis.vertical,
      ),
    );
    if (vertical.evaluate().isNotEmpty) return vertical.first;
  }
  return null;
}

bool _inteiroNaTela(WidgetTester t, Finder f) {
  if (f.evaluate().isEmpty) return false;
  final r = t.getRect(f.first);
  return r.top >= 0 && r.bottom <= _tela(t).height;
}

/// Traz o widget para o meio da área visível (fora da barra flutuante e da mini-barra, que cobrem o pé das abas):
/// [naArvore] acha mesmo fora da tela; [naTela], só o que está na tela. Rola as listas que ainda não o mostraram.
Future<void> _trazer(
  WidgetTester t,
  Finder naArvore,
  Finder naTela,
  String nome,
) async {
  if (naArvore.evaluate().isNotEmpty) {
    await Scrollable.ensureVisible(t.element(naArvore.first), alignment: 0.4);
    await quadros(t, 8);
  }
  final rolagem = _rolagem();
  if (!_inteiroNaTela(t, naTela) && rolagem != null) {
    await t.scrollUntilVisible(
      naTela,
      250,
      scrollable: rolagem,
      maxScrolls: 80,
    );
    await quadros(t, 8);
  }
  await ate(t, achado: naTela, motivo: '"$nome" não está na tela');
  await Scrollable.ensureVisible(t.element(naTela.first), alignment: 0.4);
  await quadros(t, 8);
}

/// Um toque no centro de [chave] (trazida para a área visível antes). [exigirAcerto]: falha se o centro da chave não
/// recebe o toque (um ⏸ que tocasse outra coisa passaria em vão).
Future<void> tocarChave(
  WidgetTester t,
  String chave, {
  bool exigirAcerto = false,
}) async {
  final naTela = _k(chave);
  await _trazer(
    t,
    find.byKey(ValueKey<String>(chave), skipOffstage: false),
    naTela,
    chave,
  );
  if (exigirAcerto) {
    expect(
      naTela.first.hitTestable(),
      findsOneWidget,
      reason: '"$chave": o toque no centro não chega à chave',
    );
  }
  await t.tap(naTela.first, warnIfMissed: false);
  await quadros(t, 8);
}

/// O número da página de um texto "pág. N" (ou "pág. N de M", ou só "N", como no sumário) na chave [chave].
int _paginaEm(WidgetTester t, String chave) {
  final texto = [
    for (final e
        in find
            .descendant(
              of: _k(chave),
              matching: find.byType(AppText),
              matchRoot: true,
            )
            .evaluate())
      (e.widget as AppText).span.toPlainText(includeSemanticsLabels: false),
  ].join(' ');
  final m = RegExp(r'(?:pág.\s*)?(\d+)').firstMatch(texto);
  if (m == null) fail('"$chave" sem "pág. N": "$texto"');
  return int.parse(m.group(1)!);
}

/// A página que o toque de chegada promete (o capítulo, o marcador, o grifo), lida da lista antes do toque.
int? _paginaPrometida;

/// O leitor chegou à página prometida (o rodapé "pág. N de 256").
Future<void> _naPaginaPrometida(WidgetTester t) async {
  final esperada = _paginaPrometida;
  _paginaPrometida = null;
  if (esperada == null) fail('nenhuma página prometida antes do toque');
  await ate(t, chave: 'r19.footer.pageLabel');
  expect(
    _paginaEm(t, 'r19.footer.pageLabel'),
    esperada,
    reason: 'o leitor não chegou à página da lista',
  );
}

/// Um toque na primeira chave que casa com [padrao] (as linhas que dependem do livro: o cartão do clube).
Future<void> tocarPrimeira(WidgetTester t, RegExp padrao) async {
  bool casa(Widget w) =>
      w.key is ValueKey<String> &&
      padrao.hasMatch((w.key! as ValueKey<String>).value);
  final naTela = find.byWidgetPredicate(casa);
  await _trazer(
    t,
    find.byWidgetPredicate(casa, skipOffstage: false),
    naTela,
    padrao.pattern,
  );
  await t.tap(naTela.first, warnIfMissed: false);
  await quadros(t, 8);
}

/// Um toque na última chave visível que casa com [padrao].
Future<void> tocarUltimaVisivel(WidgetTester t, RegExp padrao) async {
  final f = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        padrao.hasMatch((w.key! as ValueKey<String>).value),
  );
  await ate(t, achado: f, motivo: '"${padrao.pattern}" não está na tela');
  final visiveis = [
    for (final e in f.evaluate())
      if (t.getRect(find.byWidget(e.widget)).bottom < _tela(t).height - 40) e,
  ];
  final alvo = (visiveis.last.widget.key! as ValueKey<String>).value;
  final pagina = alvo.replaceFirst(RegExp(r'\.link$'), '.page');
  if (pagina != alvo && _k(pagina).evaluate().isNotEmpty) {
    _paginaPrometida = _paginaEm(t, pagina);
  }
  await t.tap(find.byWidget(visiveis.last.widget), warnIfMissed: false);
  await quadros(t, 8);
}

GoRouter _router(WidgetTester t) =>
    GoRouter.of(t.element(find.byType(MainShell, skipOffstage: false)));

/// O retrato de "nada mudou": a rota e as chaves na tela.
String _retrato(WidgetTester t) {
  final chaves = [
    for (final e
        in find.byWidgetPredicate((w) => w.key is ValueKey<String>).evaluate())
      (e.widget.key! as ValueKey<String>).value,
  ]..sort();
  return '${_router(t).state.uri}\n${chaves.join('\n')}';
}

bool _naInicioLimpa() =>
    find.byType(HomeScreen).evaluate().isNotEmpty &&
    find.byType(ReaderScreen).evaluate().isEmpty &&
    find.byType(HighlightsScreen).evaluate().isEmpty &&
    find.byType(ScannerScreen).evaluate().isEmpty &&
    find.byType(PlaceholderScreen).evaluate().isEmpty &&
    _k('session.sheet').evaluate().isEmpty &&
    _k('hero.title').evaluate().isNotEmpty;

/// Há o que voltar no navigator raiz (o leitor, os grifos, o scanner, um placeholder de tela cheia, a folha da sessão).
bool _podeVoltar(WidgetTester t) => Navigator.of(
  t.element(find.byType(MainShell, skipOffstage: false)),
  rootNavigator: true,
).canPop();

/// Volta à Início no topo, sem camada aberta e sem sessão do papel. O "voltar" do sistema só com o que voltar: na raiz
/// ele fecha o app no Android (no teste de widget não faz nada) — numa aba de placeholder, a Início é pela barra.
Future<void> voltarAoInicio(WidgetTester t) async {
  for (var i = 0; i < 16 && !_naInicioLimpa(); i++) {
    if (_podeVoltar(t)) {
      await t.binding.handlePopRoute();
    } else {
      await t.tap(_k('nav.home'), warnIfMissed: false);
    }
    await quadros(t, 24);
  }
  expect(_naInicioLimpa(), isTrue, reason: 'não voltou à Início');
  if (_k('miniBar').evaluate().isNotEmpty) await descartarSessao(t);
  final rolagem = find
      .descendant(
        of: find.byType(HomeScreen),
        matching: find.byType(Scrollable),
      )
      .first;
  t.state<ScrollableState>(rolagem).position.jumpTo(0);
  await quadros(t, 4);
}

/// Descarta a sessão do papel aberta (a folha: Descartar → Descartar).
Future<void> descartarSessao(WidgetTester t) async {
  await tocarChave(t, 'miniBar.title');
  await ate(t, chave: 'session.sheet.discard');
  await tocarChave(t, 'session.sheet.discard');
  await tocarChave(t, 'session.sheet.confirmDiscard');
  await ateSumir(t, _k('miniBar'));
}

Future<void> _abrirSessao(WidgetTester t) async {
  if (_k('miniBar').evaluate().isNotEmpty) return;
  await tocarChave(t, 'alsoReading.card1.play');
  await ate(t, chave: 'miniBar');
}

Future<void> _tocarNoMeio(WidgetTester t) async {
  final s = _tela(t);
  await t.tapAt(Offset(s.width / 2, s.height / 2));
  await quadros(t, 24);
}

/// Segura uma palavra do texto (a seleção da 21): no terço de cima da página, onde sempre há texto (o fim de um
/// capítulo pode deixar o meio em branco).
Future<void> _segurarPalavra(WidgetTester t) async {
  final s = _tela(t);
  for (final y in const [0.3, 0.25, 0.35, 0.2]) {
    await t.longPressAt(Offset(s.width / 2, s.height * y));
    await quadros(t, 24);
    if (_k('r21.toolbar').evaluate().isNotEmpty) return;
  }
}

/// Toca a ferramenta e, se o painel dela não abriu (o 1º toque só a escolhe), toca de novo.
Future<void> Function(WidgetTester) _abrirPainel(
  String ferramenta,
  String painel,
) => (t) async {
  await tocarChave(t, ferramenta);
  await quadros(t, 16);
  if (_k(painel).evaluate().isEmpty) await tocarChave(t, ferramenta);
};

/// Leva o app até a [origem].
Future<void> chegar(WidgetTester t, String origem) async {
  switch (origem) {
    case 'abas' || 'inicio':
      await voltarAoInicio(t);
    case 'inicio01b':
      await voltarAoInicio(t);
      await _abrirSessao(t);
    case 'folha':
      await chegar(t, 'inicio01b');
      await tocarChave(t, 'miniBar.title');
      await ate(t, chave: 'session.sheet.toggle');
    case 'folha.confirmar':
      await chegar(t, 'folha');
      await tocarChave(t, 'session.sheet.discard');
      await ate(t, chave: 'session.sheet.confirm');
    case 'leitor19':
      await voltarAoInicio(t);
      await tocarChave(t, 'hero.cta');
      await ate(t, chave: 'r19.footer.pageLabel');
      await quadros(t, 30);
    case 'leitor20':
      await chegar(t, 'leitor19');
      await _tocarNoMeio(t);
      await ate(t, chave: 'r20.bottomIsland');
    case 'leitor21':
      await chegar(t, 'leitor19');
      await _segurarPalavra(t);
      await ate(t, chave: 'r21.toolbar');
    case 'leitor22':
      await chegar(t, 'leitor20');
      await tocarChave(t, 'r20.bottomIsland.tools.annotate');
      await ate(t, chave: 'ann.done');
      await quadros(t, 30);
    case 'leitor23':
      await chegar(t, 'leitor22');
      await _abrirPainel('ann.toolShelf.pen', 'ann.penPanel')(t);
      await ate(t, chave: 'ann.penPanel.close');
    case 'leitor23b':
      await chegar(t, 'leitor22');
      await _abrirPainel('ann.toolShelf.marker', 'ann.markerPanel')(t);
      await ate(t, chave: 'ann.markerPanel.close');
    case 'leitor26':
      await chegar(t, 'leitor20');
      await tocarChave(t, 'r20.bottomIsland.tools.font');
      await ate(t, chave: 'rs.sheet.close');
      await quadros(t, 20);
    case 'leitor27':
      await chegar(t, 'leitor20');
      await tocarChave(t, 'r20.bottomIsland.tools.toc');
      await ate(t, chave: 'toc.sheet.close');
      await quadros(t, 20);
    case 'leitor27b':
      await chegar(t, 'leitor27');
      await tocarChave(t, 'toc.sheet.tabs.bookmarks');
      await ate(t, chave: 'bm.sheet.close');
      await quadros(t, 20);
    case 'grifos':
      await chegar(t, 'leitor20');
      await tocarChave(t, 'r20.bottomIsland.tools.notes');
      await ate(t, chave: 'hl.topBar.back');
      await quadros(t, 30);
    case 'grifos.mais':
      await chegar(t, 'grifos');
      await tocarChave(t, 'hl.list.card1.head.more');
      await ate(t, chave: 'hl.more.close');
      await quadros(t, 20);
    case 'grifos.exportar':
      await chegar(t, 'grifos');
      await tocarChave(t, 'hl.topBar.export');
      await ate(t, chave: 'hl.export.cancel');
      await quadros(t, 20);
    default:
      throw ArgumentError.value(origem, 'origem');
  }
}

/// As origens, na ordem em que a NAVEGACAO.md as mostra.
const List<String> origens = [
  'abas',
  'inicio',
  'inicio01b',
  'folha',
  'folha.confirmar',
  'leitor19',
  'leitor20',
  'leitor21',
  'leitor22',
  'leitor23',
  'leitor23b',
  'leitor26',
  'leitor27',
  'leitor27b',
  'grifos',
  'grifos.mais',
  'grifos.exportar',
];

Finder _leitor() => _k('r19.footer.pageLabel');
Finder _inicio() => _k('hero.title');

Ligacao _livro(String origem, String chave) => Ligacao(
  origem,
  chave,
  Classe.placeholder,
  titulo: 'Livro',
  etapa: 'T14',
  decisao: 'D-79',
);

/// As ligações, uma por linha da tabela (b) da NAVEGACAO.md.
final List<Ligacao> ligacoes = List.unmodifiable([
  // ---- a barra das abas (D-01, D-07, D-08) ----
  Ligacao(
    'abas',
    'nav.home',
    Classe.leva,
    destino: _inicio,
    decisao: 'D-07',
    tocar: (t) async {
      await tocarChave(t, 'nav.library');
      await tocarChave(t, 'nav.home');
    },
  ),
  const Ligacao(
    'abas',
    'nav.library',
    Classe.placeholder,
    titulo: 'Biblioteca',
    etapa: 'T14',
    decisao: 'D-87',
  ),
  const Ligacao(
    'abas',
    'nav.clubs',
    Classe.placeholder,
    titulo: 'Clubes',
    etapa: 'T07',
  ),
  const Ligacao(
    'abas',
    'nav.profile',
    Classe.placeholder,
    titulo: 'Perfil',
    etapa: 'T17',
    decisao: 'D-69',
  ),
  Ligacao(
    'abas',
    'nav.scanner.fab',
    Classe.leva,
    destino: () => find.byType(ScannerScreen),
    decisao: 'D-08, D-76',
  ),
  Ligacao(
    'abas',
    'nav.scanner.label',
    Classe.leva,
    destino: () => find.byType(ScannerScreen),
    decisao: 'D-08, D-76',
  ),

  // ---- a Início (01, 60) ----
  const Ligacao(
    'inicio',
    'header.bell',
    Classe.placeholder,
    titulo: 'Notificações',
    etapa: 'T17',
  ),
  const Ligacao('inicio', 'header.search', Classe.semAcao, decisao: 'D-243 b'),
  const Ligacao(
    'inicio',
    'hero.cta',
    Classe.leva,
    destino: _leitor,
    decisao: 'D-123',
  ),
  Ligacao(
    'inicio',
    'hero.notesButton',
    Classe.leva,
    destino: () => _k('hl.topBar.back'),
    decisao: 'D-195',
  ),
  _livro('inicio', 'alsoReading.card1.cover'),
  _livro('inicio', 'alsoReading.card2'),
  Ligacao(
    'inicio',
    'alsoReading.card1.play',
    Classe.leva,
    destino: () => _k('miniBar'),
    decisao: 'D-253, D-262',
    depois: descartarSessao,
  ),
  Ligacao(
    'inicio',
    'today.readNow',
    Classe.leva,
    destino: () => _k('miniBar'),
    decisao: 'D-258',
    depois: descartarSessao,
  ),
  const Ligacao('inicio', 'review.cta', Classe.semAcao, decisao: 'D-243 b'),
  const Ligacao(
    'inicio',
    'forYou.seeAll',
    Classe.placeholder,
    titulo: 'Para você',
    etapa: 'T14',
    decisao: 'D-268',
  ),
  _livro('inicio', 'forYou.item1'),
  _livro('inicio', 'forYou.item2'),
  _livro('inicio', 'forYou.item3'),
  const Ligacao(
    'inicio',
    'club.cta',
    Classe.placeholder,
    titulo: 'Discussão',
    etapa: 'T08',
  ),
  const Ligacao(
    'inicio',
    'recent.libraryLink',
    Classe.placeholder,
    titulo: 'Biblioteca',
    etapa: 'T14',
  ),
  _livro('inicio', 'recent.row0.textBlock'),
  _livro('inicio', 'recent.row1.textBlock'),
  _livro('inicio', 'recent.row2.textBlock'),
  const Ligacao(
    'inicio',
    'recent.row0.more',
    Classe.semAcao,
    decisao: 'D-243 b',
  ),
  const Ligacao(
    'inicio',
    'recent.row1.more',
    Classe.semAcao,
    decisao: 'D-243 b',
  ),
  const Ligacao(
    'inicio',
    'recent.row2.more',
    Classe.semAcao,
    decisao: 'D-243 b',
  ),

  // ---- a Início lendo agora (01b) e a folha da sessão (D-256) ----
  Ligacao(
    'inicio01b',
    'miniBar',
    Classe.leva,
    destino: () => _k('session.sheet.toggle'),
    decisao: 'D-256',
    tocar: (t) => tocarChave(t, 'miniBar.title'),
  ),
  Ligacao(
    'folha',
    'session.sheet.close',
    Classe.leva,
    some: () => _k('session.sheet'),
    destino: () => _k('miniBar'),
    decisao: 'D-262',
  ),
  Ligacao(
    'folha',
    'session.sheet.veil',
    Classe.leva,
    some: () => _k('session.sheet'),
    destino: () => _k('miniBar'),
    tocar: (t) async {
      await t.tapAt(const Offset(20, 60));
      await quadros(t, 16);
    },
  ),
  Ligacao(
    'folha',
    'session.sheet.discard',
    Classe.leva,
    destino: () => _k('session.sheet.confirm'),
  ),
  Ligacao(
    'folha',
    'session.sheet.end',
    Classe.leva,
    some: () => _k('miniBar'),
    decisao: 'D-256, D-260',
    tocar: (t) async {
      await t.enterText(_k('session.sheet.page'), '12');
      if (_k('session.sheet.total').evaluate().isNotEmpty) {
        await t.enterText(_k('session.sheet.total'), '208');
      }
      await quadros(t, 8);
      await tocarChave(t, 'session.sheet.end');
    },
  ),
  Ligacao(
    'folha.confirmar',
    'session.sheet.back',
    Classe.leva,
    destino: () => _k('session.sheet.toggle'),
  ),
  Ligacao(
    'folha.confirmar',
    'session.sheet.confirmDiscard',
    Classe.leva,
    some: () => _k('miniBar'),
    decisao: 'D-262',
  ),

  // ---- o leitor (19, 20, 26b) ----
  Ligacao(
    'leitor19',
    'r19.pagina@meio',
    Classe.leva,
    destino: () => _k('r20.bottomIsland'),
    decisao: 'D-117',
    tocar: _tocarNoMeio,
  ),
  Ligacao(
    'leitor19',
    'r19.pagina@segurar',
    Classe.leva,
    destino: () => _k('r21.toolbar'),
    decisao: 'D-45, D-136',
    tocar: _segurarPalavra,
  ),
  Ligacao(
    'leitor20',
    'r20.topIsland.close',
    Classe.leva,
    destino: _inicio,
    some: () => find.byType(ReaderScreen),
    decisao: 'D-117',
  ),
  Ligacao(
    'leitor20',
    'r20.topIsland.search',
    Classe.leva,
    destino: () => _k('leitor.busca.fechar'),
    decisao: 'D-120, D-268',
  ),
  Ligacao(
    'leitor20',
    'r20.bottomIsland.tools.font',
    Classe.leva,
    destino: () => _k('rs.sheet.close'),
    decisao: 'D-141',
  ),
  Ligacao(
    'leitor20',
    'r20.bottomIsland.tools.theme',
    Classe.leva,
    decisao: 'D-121',
    confere: (t) async {
      final noite = ReaderPalette.of(ReaderPaper.noite).paper;
      for (var i = 0; i < 120 && _papel(t) != noite; i++) {
        await quadro(t);
      }
      expect(_papel(t), noite, reason: 'o Tema Noite (26b)');
      expect(_k('r20.bottomIsland'), findsOneWidget);
    },
    depois: (t) async {
      await tocarChave(t, 'r20.bottomIsland.tools.theme');
      await quadros(t, 30);
    },
  ),
  Ligacao(
    'leitor20',
    'r20.bottomIsland.tools.notes',
    Classe.leva,
    destino: () => _k('hl.topBar.back'),
    decisao: 'R13',
  ),
  Ligacao(
    'leitor20',
    'r20.bottomIsland.tools.annotate',
    Classe.leva,
    destino: () => _k('ann.done'),
    decisao: 'D-164',
  ),
  Ligacao(
    'leitor20',
    'r20.bottomIsland.tools.toc',
    Classe.leva,
    destino: () => _k('toc.sheet.close'),
  ),

  // ---- a seleção (21) ----
  Ligacao(
    'leitor21',
    'r21.toolbar.actions.note',
    Classe.leva,
    destino: () => _k('leitor.nota.campo'),
    decisao: 'D-131',
  ),
  Ligacao(
    'leitor21',
    'r21.toolbar.colors.other',
    Classe.leva,
    destino: () => _k('leitor.outraCor.grifar'),
    decisao: 'D-178',
  ),
  Ligacao(
    'leitor21',
    'r21.toolbar.actions.search',
    Classe.leva,
    destino: () => _k('leitor.busca.fechar'),
    decisao: 'D-23',
  ),

  // ---- o modo anotação (22) e os painéis (23, 23b) ----
  Ligacao(
    'leitor22',
    'ann.done',
    Classe.leva,
    some: () => _k('ann.done'),
    destino: _leitor,
    decisao: 'D-42',
  ),
  Ligacao(
    'leitor22',
    'ann.toolShelf.pen',
    Classe.leva,
    destino: () => _k('ann.penPanel.close'),
    decisao: 'R1, R4',
    tocar: _abrirPainel('ann.toolShelf.pen', 'ann.penPanel'),
  ),
  Ligacao(
    'leitor22',
    'ann.toolShelf.marker',
    Classe.leva,
    destino: () => _k('ann.markerPanel.close'),
    decisao: 'R1, R4',
    tocar: _abrirPainel('ann.toolShelf.marker', 'ann.markerPanel'),
  ),
  Ligacao(
    'leitor22',
    'ann.island.colorWell',
    Classe.leva,
    destino: () => _k('ann.penPanel.close'),
    decisao: 'R2',
  ),
  Ligacao(
    'leitor23',
    'ann.penPanel.close',
    Classe.leva,
    some: () => _k('ann.penPanel'),
    destino: () => _k('ann.done'),
  ),
  Ligacao(
    'leitor23',
    'ann.fade',
    Classe.leva,
    some: () => _k('ann.penPanel'),
    destino: () => _k('ann.done'),
    decisao: 'R3',
    // fora do painel (o véu cobre a página; o painel engole os toques)
    tocar: (t) async {
      final painel = t.getRect(_k('ann.penPanel'));
      await t.tapAt(Offset(6, painel.bottom + 16));
      await quadros(t, 24);
    },
  ),
  Ligacao(
    'leitor23b',
    'ann.markerPanel.close',
    Classe.leva,
    some: () => _k('ann.markerPanel'),
    destino: () => _k('ann.done'),
  ),
  Ligacao(
    'leitor23b',
    'ann.markerPanel.colorsHeader.editLabels',
    Classe.leva,
    destino: () => _k('ann.labels.save'),
    decisao: 'D-177',
  ),

  // ---- os ajustes (26) ----
  Ligacao(
    'leitor26',
    'rs.sheet.close',
    Classe.leva,
    some: () => _k('rs.sheet'),
    destino: () => _k('r20.bottomIsland'),
    decisao: 'D-141',
  ),
  Ligacao(
    'leitor26',
    'rs.backdrop',
    Classe.leva,
    some: () => _k('rs.sheet'),
    decisao: 'D-141',
    tocar: (t) async {
      await t.tapAt(const Offset(195, 40));
      await quadros(t, 24);
    },
  ),

  // ---- o sumário (27, 27b) ----
  Ligacao(
    'leitor27',
    'toc.sheet.tabs.bookmarks',
    Classe.leva,
    destino: () => _k('bm.sheet.close'),
    decisao: 'D-154',
  ),
  Ligacao(
    'leitor27',
    'toc.sheet.close',
    Classe.leva,
    some: () => _k('toc.sheet.close'),
  ),
  Ligacao(
    'leitor27',
    'toc.fade',
    Classe.leva,
    some: () => _k('toc.sheet.close'),
    decisao: 'D-141',
    tocar: (t) async {
      await t.tapAt(const Offset(195, 40));
      await quadros(t, 24);
    },
  ),
  Ligacao(
    'leitor27',
    'toc.sheet.chapters.chN',
    Classe.leva,
    some: () => _k('toc.sheet.close'),
    destino: _leitor,
    confere: _naPaginaPrometida,
    decisao: 'D-151',
    // a lista abre no capítulo atual (o XXXII): o último outro capítulo que aparece; o leitor vai à página dele
    tocar: (t) => tocarUltimaVisivel(
      t,
      RegExp(r'^toc\.sheet\.chapters\.ch(?!32\.)\d+\.link$'),
    ),
  ),
  const Ligacao(
    'leitor27',
    'toc.sheet.club',
    Classe.placeholder,
    titulo: avisoProximaFase,
    etapa: 'T08',
    decisao: 'D-149',
  ),
  Ligacao(
    'leitor27b',
    'bm.sheet.tabs.chapters',
    Classe.leva,
    destino: () => _k('toc.sheet.close'),
    decisao: 'D-154',
  ),
  Ligacao(
    'leitor27b',
    'bm.sheet.close',
    Classe.leva,
    some: () => _k('bm.sheet.close'),
  ),
  Ligacao(
    'leitor27b',
    'bm.sheet.bookmarks.item1.link',
    Classe.leva,
    some: () => _k('bm.sheet.close'),
    destino: _leitor,
    confere: _naPaginaPrometida,
    decisao: 'D-151, D-158',
    // o leitor vai à página do marcador ("pág. 3")
    tocar: (t) async {
      _paginaPrometida = _paginaEm(t, 'bm.sheet.bookmarks.item1.head.page');
      await tocarChave(t, 'bm.sheet.bookmarks.item1.link');
    },
  ),

  // ---- os grifos (25, abertos pelo leitor) ----
  Ligacao(
    'grifos',
    'hl.topBar.back',
    Classe.leva,
    some: () => find.byType(HighlightsScreen),
    destino: _leitor,
    decisao: 'R13',
  ),
  Ligacao(
    'grifos',
    'hl.topBar.export',
    Classe.leva,
    destino: () => _k('hl.export.cancel'),
    decisao: 'D-194',
  ),
  Ligacao(
    'grifos',
    'hl.list.card1.body.quote',
    Classe.leva,
    some: () => find.byType(HighlightsScreen),
    destino: _leitor,
    confere: _naPaginaPrometida,
    decisao: 'D-195',
    // o leitor vai à página do grifo: a do separador acima do 1º cartão ("pág. 3")
    tocar: (t) async {
      _paginaPrometida = _paginaEm(t, 'hl.list.sep1.label');
      await tocarChave(t, 'hl.list.card1.body.quote');
    },
  ),
  Ligacao(
    'grifos',
    'hl.list.card1.head.more',
    Classe.leva,
    destino: () => _k('hl.more.close'),
    decisao: 'D-192',
  ),
  Ligacao(
    'grifos',
    'hl.list.cardN.body.club.chip',
    Classe.placeholder,
    titulo: 'Discussão',
    etapa: 'T08',
    // o cartão do grifo compartilhado no clube (a lista o constrói ao rolar)
    tocar: (t) =>
        tocarPrimeira(t, RegExp(r'^hl\.list\.card\d+\.body\.club\.chip$')),
  ),
  Ligacao(
    'grifos',
    'hl.end.cta',
    Classe.leva,
    some: () => find.byType(HighlightsScreen),
    destino: _leitor,
    decisao: 'D-198',
  ),
  Ligacao(
    'grifos.mais',
    'hl.more.note',
    Classe.leva,
    destino: () => _k('leitor.nota.campo'),
  ),
  Ligacao(
    'grifos.mais',
    'hl.more.close',
    Classe.leva,
    some: () => _k('hl.more.close'),
  ),
  Ligacao(
    'grifos.exportar',
    'hl.export.cancel',
    Classe.leva,
    some: () => _k('hl.export.cancel'),
  ),
  const Ligacao(
    'grifos.exportar',
    'hl.export.formats.pdf',
    Classe.placeholder,
    titulo: avisoProximaFase,
    etapa: 'T19',
    decisao: 'D-65',
  ),
]);

Color _papel(WidgetTester t) => t
    .widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(ReaderScreen),
            matching: find.byType(ColoredBox),
          )
          .first,
    )
    .color;

/// Percorre [lista]: chega à origem de cada uma, toca e confere a classe. Devolve as linhas 🟡 alcançadas; as
/// falhas vão juntas no fim (com a ligação de cada uma).
Future<List<String>> percorrer(
  WidgetTester t,
  List<Ligacao> lista, {
  void Function(String linha) log = print,
}) async {
  final amarelas = <String>[];
  final falhas = <String>[];
  for (final l in lista) {
    log('NAV $l');
    try {
      await chegar(t, l.origem);
      final semAcao = l.classe == Classe.semAcao;
      final antes = semAcao ? _retrato(t) : null;
      await (l.tocar ?? (t) => tocarChave(t, l.chave, exigirAcerto: semAcao))(
        t,
      );
      switch (l.classe) {
        case Classe.leva:
          if (l.destino != null) {
            await ate(
              t,
              achado: l.destino!(),
              motivo: '$l: o destino não apareceu',
            );
          }
          if (l.some != null) {
            await ateSumir(t, l.some!(), motivo: '$l: a camada não fechou');
          }
          await l.confere?.call(t);
        case Classe.semAcao:
          await quadros(t, 30);
          expect(_retrato(t), antes, reason: '$l: algo mudou');
          expect(
            _aviso(avisoProximaFase),
            findsNothing,
            reason: '$l: apareceu o aviso de próxima fase (seria 🟡)',
          );
        case Classe.placeholder:
          final titulo = l.titulo!;
          await ate(
            t,
            achado: titulo == avisoProximaFase
                ? _aviso(titulo)
                : _placeholder(titulo),
            motivo: '$l: o placeholder "$titulo" não apareceu',
          );
          amarelas.add('🟡 ${l.origem} · ${l.chave} → $titulo (${l.etapa})');
      }
      await l.depois?.call(t);
    } on Object catch (e) {
      // uma falha (ou um erro) numa ligação não esconde as outras
      final msg = e is TestFailure ? e.message : '$e';
      falhas.add('$l\n  $msg');
      log('NAV FALHOU $l: $msg');
    }
  }
  try {
    await voltarAoInicio(t);
  } finally {
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  }
  return amarelas;
}
