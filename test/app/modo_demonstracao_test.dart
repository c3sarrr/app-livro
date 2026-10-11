// R00.7 (D-267) — o modo demonstração no app inteiro, sobre o banco do demo (o PowerSync de verdade, num arquivo de
// uma pasta de suporte temporária onde já mora um app normal — banco e pastas — que fica byte a byte como estava):
// * alvo (1), `main_demonstracao.dart`: a Início lê o banco semeado pela fonte real (os números da prancha 01 que as
//   regras do app alcançam; as diferenças que ficam estão em `semear_mundo_test.dart`);
// * alvo (2), `main_mundo_referencia.dart`: a Início é a prancha 01 como ela é (a fixture);
// e nos dois o "Continuar lendo" abre o Dom Casmurro do banco do demo no leitor, na pág. 159 de 256, e volta. Na rede,
// só pedidos de capa a hosts públicos de capa (nada de servidor, conta, catálogo ou loja).
import 'dart:io';

import 'package:app_leitura/features/home/data/cover_store.dart'
    show coverHostAllowed;
import 'package:app_leitura/features/reading_session/application/second_ticker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/demonstracao/overrides_demonstracao.dart';
import '../fixtures/demonstracao/prancha_no_aparelho.dart';
import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/paper_timer_fakes.dart' show ManualTicker;
import '../support/app_com_livro.dart' show textosEm;
import '../support/app_normal_ao_lado.dart';
import '../support/demonstracao_no_app.dart';
import '../support/load_fonts.dart';

/// "Continuar lendo" → o leitor na pág. 159 de 256 → voltar à Início.
Future<void> _continuarLendoEVoltar(WidgetTester tester) async {
  expect(textosEm(tester, 'hero.cta'), 'Continuar lendo');
  await tester.tap(find.byKey(const ValueKey('hero.cta')));
  await ate(tester, chave: 'r19.footer.pageLabel');
  await quadros(tester, 30);
  expect(textosEm(tester, 'r19.footer.pageLabel'), 'pág. 159 de 256');
  await tester.binding.handlePopRoute();
  await quadros(tester, 60);
  expect(find.byKey(const ValueKey('r19.footer.pageLabel')), findsNothing);
  await ate(tester, chave: 'hero.title');
  expect(textosEm(tester, 'hero.pagePill'), 'pág. 159 de 256');
}

Future<void> _desmontar(WidgetTester tester, Directory suporte) async {
  await desmontarDemonstracao(tester);
  conferirAppNormal(suporte);
  expect(
    nomesNaRaiz(suporte).difference(nomesDoAppNormal).every(ehDaDemonstracao),
    isTrue,
    reason: 'só o demo apareceu na pasta de suporte',
  );
  await tester.runAsync(() => apagarPasta(suporte));
}

void _soCapasPublicas(List<Uri> pedidos) {
  expect(
    [
      for (final u in pedidos)
        if (u.scheme != 'https' || !coverHostAllowed(u.host)) u,
    ],
    isEmpty,
    reason: 'na rede, só capas de hosts públicos',
  );
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'alvo (1): o app de verdade sobre o banco do demo — a Início lida do banco, o "Continuar lendo" abre o '
    'leitor na pág. 159 de 256 e volta; o app normal ao lado não muda',
    (tester) async {
      final suporte = suporteComAppNormal();
      final pedidos = await montarDemonstracao(tester, [
        ...overridesDemonstracao(
          suporte: () async => suporte,
          relogio: () => mundoReferencia.agora,
        ),
        secondTickerProvider.overrideWithValue(ManualTicker()),
      ]);

      expect(textosEm(tester, 'header.greeting'), 'Boa noite,');
      expect(textosEm(tester, 'header.name'), 'Marina');
      expect(find.byKey(const ValueKey('header.bell.dot')), findsOneWidget);
      expect(textosEm(tester, 'hero.title'), 'Dom Casmurro');
      expect(textosEm(tester, 'hero.pagePill'), 'pág. 159 de 256');
      expect(textosEm(tester, 'hero.percent'), '62%');
      expect(textosEm(tester, 'hero.timeLeft'), '~1h 20min');
      expect(textosEm(tester, 'hero.notesButton'), '12');
      expect(textosEm(tester, 'today.streakPill'), '12 dias');
      expect(textosEm(tester, 'today.dial'), contains('18 de 30 min'));
      expect(textosEm(tester, 'today.chip.sessions'), '2 sessões');
      expect(textosEm(tester, 'today.chip.highlights'), '1 destaque');
      expect(textosEm(tester, 'today.week.total'), '4h 00min no total');
      expect(textosEm(tester, 'alsoReading.count'), '3');
      expect(
        textosEm(tester, 'alsoReading.card1'),
        contains(
          'Memórias Póstumas de Brás Cubas Machado de Assis Papel · 3h 40min',
        ),
      );
      expect(
        textosEm(tester, 'alsoReading.card2'),
        contains('Orgulho e Preconceito Jane Austen Papel · pág. 344'),
      );
      expect(textosEm(tester, 'club.title'), 'Leitoras de Capitu');
      expect(
        textosEm(tester, 'club'),
        allOf(
          contains('Dom Casmurro · até o cap. 50'),
          contains('Grupo em 54%'),
          contains('Você em 62%'),
          contains('ENCONTRO QUI 24 SET 20h'),
        ),
      );
      expect(
        textosEm(tester, 'recent'),
        contains(
          'Frankenstein Mary Shelley · EPUB Novo O Alienista Machado de Assis · PDF Lido '
          'Senhora José de Alencar · Papel Novo',
        ),
      );
      // as diferenças que as regras mantêm (semear_mundo_test.dart): sem revisão (D-247) e sem "Para você" (sem catálogo)
      expect(find.byKey(const ValueKey('review')), findsNothing);
      expect(find.byKey(const ValueKey('forYou')), findsNothing);

      await _continuarLendoEVoltar(tester);
      _soCapasPublicas(pedidos);
      await _desmontar(tester, suporte);
    },
  );

  testWidgets('alvo (2): a Início da prancha 01 como ela é, e o "Continuar lendo" abre o Dom Casmurro do banco do demo '
      'na pág. 159 de 256', (tester) async {
    final suporte = suporteComAppNormal();
    final pedidos = await montarDemonstracao(
      tester,
      overridesDaPranchaNoAparelho(
        suporte: () async => suporte,
        tique: ManualTicker(),
      ),
    );

    expect(textosEm(tester, 'header.name'), 'Marina');
    expect(textosEm(tester, 'hero.pagePill'), 'pág. 159 de 256');
    expect(textosEm(tester, 'hero.timeLeft'), '~2h 10min');
    expect(textosEm(tester, 'today.chip.highlights'), '2 destaques');
    expect(find.byKey(const ValueKey('review')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('forYou'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      textosEm(tester, 'recent'),
      contains('Frankenstein Mary Shelley · EPUB Quero ler'),
    );

    await _continuarLendoEVoltar(tester);
    _soCapasPublicas(pedidos);
    await _desmontar(tester, suporte);
  });
}
