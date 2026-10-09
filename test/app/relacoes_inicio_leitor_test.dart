// G20.1 (R2) — as relações do Anexo 01 §14 com o livro real: o Dom Casmurro do Gutenberg em leitura, a Início
// pela fonte real (o banco), o leitor e a tela 25 sobre o mesmo banco. Com dados reais as asserções da prancha
// viram relações (§14, último parágrafo):
// - o herói e o leitor dizem a mesma posição (a página guardada, o %), o mesmo capítulo (o "Cap. N de M" da Início =
//   a ordem do capítulo atual do sumário entre os numerados) e o mesmo tempo restante;
// - as páginas do sumário não voltam;
// - ler muda o herói como o leitor: o %, o capítulo e os minutos do dia (= o chip "N min hoje");
// - as contagens somam e andam juntas: o herói, o botão Grifos do leitor e o "Tudo" da 25;
// - as páginas dos separadores da 25 crescem e o "você parou aqui" está na página do rodapé.
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/widgets/count_badge.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_com_livro.dart';
import '../support/fase_l25.dart' show esperarTela25;
import '../support/load_fonts.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

Finder _k(String k) => find.byKey(ValueKey<String>(k));

/// As chaves `String` da árvore que casam com [re], na ordem da árvore (a ordem da tela numa coluna).
List<RegExpMatch> _chaves(RegExp re) => [
  for (final e
      in find
          .byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                re.hasMatch((w.key! as ValueKey<String>).value),
          )
          .evaluate())
    re.firstMatch((e.widget.key! as ValueKey<String>).value)!,
];

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Deixa o banco (em memória, com futuros de verdade) gravar e as telas relerem.
Future<void> _banco(WidgetTester tester, [int voltas = 8]) async {
  for (var i = 0; i < voltas; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// "~2h 10min" (Início) ou "≈ 2 h 10 min" / "≈ 45 min" (leitor) → minutos.
int _minutos(String s) {
  final m = RegExp(r'(?:(\d+)\s*h\s*)?(\d+)\s*min').firstMatch(s)!;
  return int.parse(m.group(1) ?? '0') * 60 + int.parse(m.group(2)!);
}

/// "Cap. 32 de 148" → (32, 148).
(int, int) _capitulo(WidgetTester tester) {
  final m = RegExp(r'^Cap\. (\d+) de (\d+)$')
      .firstMatch(textosEm(tester, 'hero.chapterPill'))!;
  return (int.parse(m.group(1)!), int.parse(m.group(2)!));
}

/// 32 → "XXXII".
String _romano(int n) {
  const valores = [100, 90, 50, 40, 10, 9, 5, 4, 1];
  const letras = ['C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
  final b = StringBuffer();
  var r = n;
  for (var i = 0; i < valores.length; i++) {
    while (r >= valores[i]) {
      b.write(letras[i]);
      r -= valores[i];
    }
  }
  return b.toString();
}

/// "pág. 159 de 256" → 159.
int _paginaDoRodape(WidgetTester tester) => int.parse(
  RegExp(r'pág\. (\d+) de')
      .firstMatch(textosEm(tester, 'r19.footer.pageLabel'))!
      .group(1)!,
);

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

/// Abre (ou fecha) os controles com um toque no meio da página.
Future<void> _controles(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await _quadros(tester, 24);
}

/// Vira para a página seguinte (o terço da direita).
Future<void> _seguinte(WidgetTester tester) async {
  await tester.tapAt(const Offset(360, 420));
  await _quadros(tester, 30);
}

Future<void> _anterior(WidgetTester tester) async {
  await tester.tapAt(const Offset(30, 420));
  await _quadros(tester, 30);
}

/// Pressão longa numa palavra de 4 letras ou mais da página e a cor amarela da barra: um grifo.
Future<void> _grifar(WidgetTester tester, {int n = 6}) async {
  final p = _doc(tester).current;
  final s = p.shown!;
  final texto = p.textOf(s.unit, s.from, s.to);
  final m = RegExp(
    r'(?<![\p{L}-])\p{L}{4,}(?![\p{L}-])',
    unicode: true,
  ).allMatches(texto).elementAt(n);
  final caixa = p.boxesOf(s.unit, s.from + m.start, s.from + m.end).first.rect;
  await tester.longPressAt(caixa.center);
  await _quadros(tester, 10);
  expect(_k('r21.toolbar'), findsOneWidget);
  await tester.tap(_k('r21.toolbar.colors.yellow'));
  await tester.pump();
  await _banco(tester);
  await _quadros(tester, 10);
}

/// A linha "você está aqui" do sumário aberto: (o numeral dela, a ordem dela entre as linhas numeradas — 1, 2, …).
(String, int) _capituloDoSumario(WidgetTester tester) {
  final aqui = _chaves(RegExp(r'^toc\.sheet\.chapters\.ch(\d+)\.youAreHere$'))
      .single
      .group(1)!;
  final numerados = [
    for (final m in _chaves(
      RegExp(r'^toc\.sheet\.chapters\.ch(\d+)\.numeral$'),
    ))
      m.group(1)!,
  ];
  return (
    textosEm(tester, 'toc.sheet.chapters.ch$aqui.numeral'),
    numerados.indexOf(aqui) + 1,
  );
}

Future<void> _abrirSumario(WidgetTester tester) async {
  await tester.tap(_k('r20.bottomIsland.tools.toc'));
  await _quadros(tester, 30);
  await _banco(tester, 4);
  expect(_k('toc.sheet'), findsOneWidget);
}

Future<void> _fecharSumario(WidgetTester tester) async {
  await tester.tap(_k('toc.sheet.close'));
  await _quadros(tester, 30);
  expect(_k('toc.sheet'), findsNothing);
}

/// O Voltar do sistema até a Início (cada camada aberta fecha num toque — R3).
Future<void> _voltarAteInicio(WidgetTester tester) async {
  for (var i = 0; i < 6 && _k('hero.title').evaluate().isEmpty; i++) {
    await tester.binding.handlePopRoute();
    await _quadros(tester, 30);
    await _banco(tester, 4);
  }
  expect(_k('hero.title'), findsOneWidget, reason: 'o Voltar levou à Início');
  await esperarInicio(tester);
  await _banco(tester);
  await tester.pumpAndSettle();
}

Future<void> _continuar(WidgetTester tester) async {
  await tester.tap(_k('hero.cta'));
  await tester.pump();
  await esperarLeitor(tester);
  await _banco(tester, 4);
}

String _contagem(WidgetTester tester, String k) =>
    tester.widget<CountBadge>(_k(k)).label;

int _tipo(WidgetTester tester, String t) =>
    int.parse(textosEm(tester, 'hl.types.$t.count'));

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await domCasmurroEmLeitura());
  tearDown(() async => livro.close());

  testWidgets(
    'o herói e o leitor: a mesma posição, o mesmo capítulo, o mesmo tempo restante; o sumário não volta',
    (tester) async {
      final t = await abrirAppComLivro(tester, livro);
      final (n, total) = _capitulo(tester);
      expect(
        (n, total),
        (32, 148),
        reason: 'D-206: a numeração do livro — o cap. XXXII é o 32º de 148',
      );
      final pct = textosEm(tester, 'hero.percent');
      final falta = textosEm(tester, 'hero.timeLeft');

      await _continuar(tester);
      final guardada = await tester.runAsync(
        () => ReadingPositionsDao(livro.db).forBook(livro.userBookId),
      );
      expect(
        _paginaDoRodape(tester),
        guardada!.refPage,
        reason: '"Continuar lendo" abre na página guardada',
      );
      expect(
        textosEm(tester, 'r19.footer.percent'),
        pct,
        reason: 'o % do herói = o % do rodapé',
      );

      await _controles(tester);
      expect(
        _minutos(textosEm(tester, 'r20.bottomIsland.progressRow.timeLeft')),
        _minutos(falta),
        reason: '"~2h 10min" da Início ↔ "≈ 2 h 10 min" do leitor: o mesmo tempo restante',
      );
      await _abrirSumario(tester);
      final (numeral, ordem) = _capituloDoSumario(tester);
      // D-210: a página começa no fim do XXXI e mostra o começo do XXXII — o atual é o último que começa nela
      expect(
        ordem,
        greaterThanOrEqualTo(32),
        reason:
            'o capítulo atual é o XXXII (ou um depois dele na mesma página)',
      );
      expect(
        numeral,
        _romano(ordem),
        reason: 'o numeral do leitor convertido = a ordem entre os numerados',
      );
      expect(
        _chaves(RegExp(r'^toc\.sheet\.chapters\.ch\d+\.numeral$')),
        hasLength(total),
        reason: 'o M do "Cap. N de M" = as linhas numeradas do sumário',
      );
      final paginas = [
        for (final m in _chaves(
          RegExp(r'^toc\.sheet\.chapters\.(ch\d+)\.page$'),
        ))
          int.parse(textosEm(tester, 'toc.sheet.chapters.${m.group(1)}.page')),
      ];
      expect(paginas, isNotEmpty);
      for (var i = 1; i < paginas.length; i++) {
        expect(
          paginas[i],
          greaterThanOrEqualTo(paginas[i - 1]),
          reason: 'as páginas do sumário não voltam (linha $i)',
        );
      }
      await _fecharSumario(tester);
      await _controles(tester);
      await _voltarAteInicio(tester);
      expect(
        _capitulo(tester),
        (ordem, total),
        reason: 'de volta à Início, o N do "Cap. N de M" = a ordem do capítulo atual do sumário (D-210)',
      );
      expect(t.erros, isEmpty);
    },
  );

  testWidgets(
    'ler 3 min e voltar: o herói segue o leitor (%, capítulo, minutos do dia, tempo restante)',
    (tester) async {
      final relogio = RelogioG20();
      final t = await abrirAppComLivro(tester, livro, relogio: relogio);
      expect(textosEm(tester, 'today.dial.value'), '0');
      await _continuar(tester);
      for (var i = 0; i < 5; i++) {
        relogio.andar(const Duration(seconds: 36));
        await _seguinte(tester);
      }
      await _banco(tester);
      await _controles(tester);
      await _banco(tester);
      final chip = int.parse(
        RegExp(r'^(\d+) min hoje')
            .firstMatch(textosEm(tester, 'r20.timeChip'))!
            .group(1)!,
      );
      expect(chip, 3, reason: '5 páginas, 36 s cada: 3 min ativos');
      // a 25 por cima não conta (Anexo 03 §8): 90 s nela e o chip continua em 3
      await tester.tap(_k('r20.bottomIsland.tools.notes'));
      await esperarTela25(tester);
      relogio.andar(const Duration(seconds: 90));
      await tester.binding.handlePopRoute();
      await _quadros(tester, 30);
      await _banco(tester);
      if (_k('r20.topIsland').evaluate().isNotEmpty) await _controles(tester);
      await _controles(tester);
      await _banco(tester);
      expect(
        textosEm(tester, 'r20.timeChip'),
        startsWith('$chip min hoje'),
        reason: 'o tempo com a 25 por cima não entra no "N min hoje"',
      );
      final pct = textosEm(tester, 'r19.footer.percent');
      await _abrirSumario(tester);
      final (_, ordem) = _capituloDoSumario(tester);
      await _fecharSumario(tester);
      await _controles(tester);

      await _voltarAteInicio(tester);
      expect(
        textosEm(tester, 'hero.percent'),
        pct,
        reason: 'o novo % do herói = o do último rodapé',
      );
      expect(
        _capitulo(tester).$1,
        ordem,
        reason: 'o capítulo do herói = o capítulo atual do leitor',
      );
      expect(
        int.parse(textosEm(tester, 'today.dial.value')),
        chip,
        reason: '"N min hoje" do chip = os minutos lidos hoje no "Seu dia de leitura"',
      );
      // com a velocidade nova (a sessão de 3 min), o tempo restante dos dois lados sai da mesma conta (D-97)
      final falta = textosEm(tester, 'hero.timeLeft');
      await _continuar(tester);
      await _controles(tester);
      expect(
        _minutos(textosEm(tester, 'r20.bottomIsland.progressRow.timeLeft')),
        _minutos(falta),
        reason:
            '"~Xh YYmin" da Início ↔ "≈ X h YY min" do leitor depois de ler',
      );
      await _controles(tester);
      expect(t.erros, isEmpty);
    },
  );

  testWidgets(
    'as contagens: herói = botão Grifos do leitor = "Tudo" da 25 = a soma dos tipos; apagar zera as três',
    (tester) async {
      final t = await abrirAppComLivro(tester, livro);
      expect(_contagem(tester, 'hero.notesButton.badge'), '0');
      await _continuar(tester);
      await _grifar(tester);
      await _controles(tester);
      expect(_contagem(tester, 'r20.bottomIsland.tools.notes.badge'), '1');
      await tester.tap(_k('r20.bottomIsland.tools.notes'));
      await esperarTela25(tester);
      expect(
        _tipo(tester, 'all'),
        1,
        reason: '"Tudo" = o botão Grifos do leitor',
      );
      expect(
        _tipo(tester, 'highlights') +
            _tipo(tester, 'notes') +
            _tipo(tester, 'handwritten') +
            _tipo(tester, 'drawings'),
        _tipo(tester, 'all'),
        reason: 'os quatro tipos somam o "Tudo"',
      );
      await _voltarAteInicio(tester);
      expect(
        _contagem(tester, 'hero.notesButton.badge'),
        '1',
        reason: 'o herói conta o mesmo grifo',
      );

      await tester.tap(_k('hero.notesButton'));
      await tester.pump();
      await esperarTela25(tester);
      expect(_tipo(tester, 'all'), 1);
      await tester.tap(_k('hl.list.card1.head.more'));
      await tester.pump();
      await tester.tap(_k('hl.more.delete'));
      await tester.pump();
      await _banco(tester);
      if (_k('hl.types.all.count').evaluate().isNotEmpty) {
        expect(_tipo(tester, 'all'), 0, reason: 'apagado, o "Tudo" volta a 0');
      }
      await _voltarAteInicio(tester);
      expect(
        _contagem(tester, 'hero.notesButton.badge'),
        '0',
        reason: 'apagado pela 25, o herói volta a 0',
      );
      await _continuar(tester);
      await _controles(tester);
      expect(
        _k('r20.bottomIsland.tools.notes.badge'),
        findsNothing,
        reason: 'e o botão Grifos fica sem número',
      );
      await _controles(tester);
      expect(t.erros, isEmpty);
    },
  );

  testWidgets(
    'a 25: as páginas dos separadores crescem e o "você parou aqui" está na página do rodapé',
    (tester) async {
      final t = await abrirAppComLivro(tester, livro);
      await _continuar(tester);
      await _grifar(tester);
      for (var i = 0; i < 2; i++) {
        await _seguinte(tester);
        await _seguinte(tester);
        await _grifar(tester, n: 3);
      }
      await _anterior(tester);
      await _banco(tester);
      final aqui = _paginaDoRodape(tester);
      await _controles(tester);
      expect(_contagem(tester, 'r20.bottomIsland.tools.notes.badge'), '3');
      await tester.tap(_k('r20.bottomIsland.tools.notes'));
      await esperarTela25(tester);

      final separadores = <int, String>{};
      for (var volta = 0; volta < 8; volta++) {
        for (final m in _chaves(RegExp(r'^hl\.list\.sep(\d+)\.label$'))) {
          separadores[int.parse(m.group(1)!)] = textosEm(tester, m.group(0)!);
        }
        await tester.drag(_k('hl.scroll'), const Offset(0, -260));
        await _quadros(tester, 20);
      }
      final ordem = separadores.keys.toList()..sort();
      final paginas = [
        for (final k in ordem)
          int.parse(
            RegExp(r'pág\. (\d+)').firstMatch(separadores[k]!)!.group(1)!,
          ),
      ];
      expect(ordem, [
        for (var i = 1; i <= ordem.length; i++) i,
      ], reason: 'todos os separadores foram lidos');
      for (var i = 1; i < paginas.length; i++) {
        expect(
          paginas[i],
          greaterThan(paginas[i - 1]),
          reason: 'as páginas dos separadores crescem',
        );
      }
      final aquiNa25 = [
        for (final k in ordem)
          if (separadores[k]!.contains('você parou aqui'))
            paginas[ordem.indexOf(k)],
      ];
      expect(aquiNa25, [
        aqui,
      ], reason: '"você parou aqui" uma vez, na página do rodapé do leitor');
      expect(t.erros, isEmpty);
    },
  );
}
