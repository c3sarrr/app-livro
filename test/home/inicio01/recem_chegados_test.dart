// T03.13 — fase L01a8 ("Recém-chegados") contra a prancha 01 (`kRef01`) e as larguras 360/430: Frankenstein
// ("Quero ler"), O Alienista (agora "Lido", a pílula verde nova — D-255) e Senhora (agora "Papel"). A seção mudou no
// lugar (só os dados e a pílula "Lido"). Recorte do gate visual: y 2130,12–2480,12
// (`docs/design/fases/L01a8_recem_chegados.md`).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/home/presentation/sections/recently_added_section.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/telas/inicio01.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../reference/inicio2_larguras/referencias_inicio2_larguras.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

const _secoes = ['i01.recent'];

Future<void> _abrir(WidgetTester tester, {LeitorRefPrancha prancha = kRef01}) =>
    abrirInicio01(tester, prancha: prancha);

/// Voltar do sistema: fecha a rota do topo (de volta à Início).
Future<void> _voltar(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

String _texto(WidgetTester tester, String key) =>
    tester.widget<AppText>(find.byKey(ValueKey(key))).span.toPlainText();

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01a8 geometria: os 37 ids da seção (cabeçalho, lista, as 3 linhas com mini-capa, texto, pílula e ⋯)',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01, _secoes), hasLength(37));
      expect(geometria01(tester, _secoes), isEmpty);
    },
  );

  testWidgets(
    'L01a8 texto: "Recém-chegados", "Biblioteca", títulos, subtítulos ("· EPUB", "· PDF", "· Papel") e '
    'as pílulas ("Quero ler", "Lido", "Novo") nas baselines da prancha',
    (tester) async {
      await _abrir(tester);
      expect(texto01(tester, _secoes), isEmpty);
    },
  );

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'L01a8 a ${tela.substring(3)} px: geometria e texto da prancha medida nessa largura ("Quero / ler" '
      'quebra a 360; "Lido" não quebra)',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await _abrir(tester, prancha: ref);
        expect(geometria01(tester, _secoes, prancha: ref), isEmpty);
        expect(texto01(tester, _secoes, prancha: ref), isEmpty);
      },
    );
  }

  testWidgets(
    'L01a8 "Lido": pílula #E1EDD0 com o texto #2E5314 (Figtree 12/700, padding 5/10) — cores novas da 01',
    (tester) async {
      await _abrir(tester);
      final p = tester.widget<Pill>(
        find.byKey(const ValueKey('recent.row1.tag')),
      );
      expect(
        (p.color, p.padding),
        (
          AppColors.tagReadBg,
          const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        ),
      );
      expect(AppColors.tagReadBg, const Color(0xFFE1EDD0));
      final t = appText01(tester, 'i01.recent.row1.tag');
      expect(
        (t.span.toPlainText(), t.span.style),
        ('Lido', AppTextStyles.tagRead),
      );
      final s = t.span.style!;
      expect(
        (s.fontFamily, s.fontSize, s.fontWeight, s.color),
        ('Figtree', 12.0, FontWeight.w700, AppColors.tagReadFg),
      );
      expect(AppColors.tagReadFg, const Color(0xFF2E5314));
    },
  );

  testWidgets('L01a8 dados (D-255): Frankenstein "Quero ler" · EPUB, O Alienista "Lido" · PDF, Senhora "Novo" · '
      'Papel — da fixture t01', (tester) async {
    await _abrir(tester);
    final r = TelaInicio01.snapshot(TelaInicio01.agora).recent;
    expect(r.map((i) => i.status), [
      RecentStatus.wantToRead,
      RecentStatus.read,
      RecentStatus.isNew,
    ]);
    expect(r.map((i) => i.format), [
      BookFormat.epub,
      BookFormat.pdf,
      BookFormat.physical,
    ]);
    for (final (i, (titulo, sub, tag)) in [
      ('Frankenstein', 'Mary Shelley · EPUB', 'Quero ler'),
      ('O Alienista', 'Machado de Assis · PDF', 'Lido'),
      ('Senhora', 'José de Alencar · Papel', 'Novo'),
    ].indexed) {
      expect(_texto(tester, 'recent.row$i.title'), titulo);
      expect(_texto(tester, 'recent.row$i.subtitle'), sub);
      expect(appText01(tester, 'i01.recent.row$i.tag').span.toPlainText(), tag);
    }
  });

  testWidgets(
    'L01a8 semântica: a seção, o h3, "Biblioteca", os 3 blocos de texto como links e os 3 "Mais opções"',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(tester);
      expect(
        find.semantics.byLabel('Adicionados recentemente'),
        findsAtLeast(1),
      );
      for (final l in [
        'Mais opções para Frankenstein',
        'Mais opções para O Alienista',
        'Mais opções para Senhora',
      ]) {
        final n = find.semantics
            .byLabel(l)
            .evaluate()
            .single
            .getSemanticsData();
        expect(n.flagsCollection.isButton, isTrue, reason: l);
      }
      final links = linksDaSecao('Adicionados recentemente')
          .map((n) => n.label)
          .toList();
      expect(links, hasLength(4));
      expect(links, contains('Biblioteca'));
      expect(
        links.where((l) => l.contains('Machado de Assis · PDF')),
        hasLength(1),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'L01a8 toques: os blocos abrem a página do livro e "Biblioteca" troca de aba; o ⋯ continua sem ação (C20)',
    (tester) async {
      await _abrir(tester);
      expect(
        tester
            .widget<RecentlyAddedSection>(find.byType(RecentlyAddedSection))
            .onMoreTap,
        HomeScreen.onMoreOptions,
      );
      for (final i in [0, 1, 2]) {
        await tocar01(tester, 'i01.recent.row$i.more');
        expect(rotaAtual(tester), '/inicio');
      }
      for (final (i, slug) in [
        (0, 'frankenstein'),
        (1, 'o-alienista'),
        (2, 'senhora'),
      ]) {
        await tocar01(tester, 'i01.recent.row$i.textBlock');
        expect(rotaAtual(tester), '/livro/$slug');
        await _voltar(tester);
      }
      await tocar01(tester, 'i01.recent.libraryLink');
      expect(rotaAtual(tester), '/biblioteca');
    },
  );

  testWidgets(
    'L01a8 captura: a seção no canvas da prancha (gate visual fora do teste)',
    (tester) async {
      await _abrir(tester);
      final image = await capturar01(tester, 't03_L01a8');
      expect((image.width, image.height), (1170, 7950));
    },
  );
}
