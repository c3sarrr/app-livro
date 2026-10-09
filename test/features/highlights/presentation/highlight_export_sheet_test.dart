// G19.7 — Exportar (D-194, R12) pela rota real, no mundo de referência: a folha com o livro e quantos itens vão, os
// três formatos (Markdown marcado; o PDF do Pro avisa e não muda a escolha), o arquivo entregue pela folha de
// compartilhar (nome, tipo e conteúdo), o erro que deixa a folha aberta e o livro sem nada para exportar.
import 'dart:async';

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/dados_t25.dart';
import '../../../support/fase_l25.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

String _visto(WidgetTester tester, String id) =>
    tester.widget<AppText>(hl(id)).span.toPlainText();

Future<void> _abrir(WidgetTester tester) async {
  await tester.tap(hl('hl.topBar.export'));
  await tester.pump();
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela25());
  tearDown(() async => livro.close());

  testWidgets(
    'a folha: título, "Dom Casmurro · 8 grifos e notas de texto" e Markdown marcado',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela25(tester, livro);
      await _abrir(tester);
      expect(_visto(tester, 'hl.export.title'), 'Exportar grifos e notas');
      expect(
        _visto(tester, 'hl.export.subtitle'),
        'Dom Casmurro · 8 grifos e notas de texto',
      );
      expect(
        no25(tester, (d) => d.label == 'Formato')!.role,
        SemanticsRole.radioGroup,
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Markdown')),
        isSemantics(
          label: 'Markdown',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      expect(hl('hl.export.formats.pdf.pro'), findsOneWidget);
      h.dispose();
    },
  );

  testWidgets(
    'CSV marca; o PDF avisa "Chega numa próxima fase" e a escolha não muda',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela25(tester, livro);
      await _abrir(tester);
      await tester.tap(hl('hl.export.formats.csv'));
      await tester.pump();
      await tester.tap(hl('hl.export.formats.pdf'));
      await tester.pump();
      expect(
        appText25(tester, 'leitor.aviso', '').span.toPlainText(),
        'Chega numa próxima fase',
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('CSV')),
        isSemantics(
          label: 'CSV',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      expect(hl('hl.export'), findsOneWidget);
      h.dispose();
    },
  );

  testWidgets(
    'Exportar em CSV entrega o arquivo do livro todo e fecha a folha',
    (tester) async {
      final arquivos = ArquivosDeTeste();
      await abrirTela25(
        tester,
        livro,
        deps: depsDaTela25(livro, arquivos: arquivos),
      );
      await _abrir(tester);
      await tester.tap(hl('hl.export.formats.csv'));
      await tester.pump();
      await tester.tap(hl('hl.export.go'));
      await tester.pump();
      await banco25(tester, voltas: 2);
      expect(hl('hl.export'), findsNothing);
      final f = arquivos.feitos.single;
      expect(
        (f.fileName, f.mimeType),
        ('dom-casmurro-grifos-e-notas.csv', 'text/csv'),
      );
      expect(
        f.content,
        startsWith('﻿pagina;capitulo;tipo;cor;trecho;nota;criado_em\r\n'),
      );
      // 6 grifos (a nota vai na linha do grifo)
      expect('\r\n'.allMatches(f.content), hasLength(7));
    },
  );

  testWidgets('dois toques seguidos em Exportar entregam um arquivo só', (
    tester,
  ) async {
    final arquivos = ArquivosDeTeste();
    await abrirTela25(
      tester,
      livro,
      deps: depsDaTela25(livro, arquivos: arquivos),
    );
    await _abrir(tester);
    // a folha de compartilhar do sistema fica aberta: o 2º toque chega com a 1ª entrega no ar
    final segurar = arquivos.segurar = Completer<void>();
    await tester.tap(hl('hl.export.go'));
    await tester.pump();
    await tester.tap(hl('hl.export.go'));
    await tester.pump();
    segurar.complete();
    await banco25(tester, voltas: 2);
    expect(arquivos.feitos, hasLength(1));
    expect(hl('hl.export'), findsNothing);
  });

  testWidgets('Exportar em Markdown (o padrão) entrega o .md', (tester) async {
    final arquivos = ArquivosDeTeste();
    await abrirTela25(
      tester,
      livro,
      deps: depsDaTela25(livro, arquivos: arquivos),
    );
    await _abrir(tester);
    await tester.tap(hl('hl.export.go'));
    await tester.pump();
    await banco25(tester, voltas: 2);
    final f = arquivos.feitos.single;
    expect(
      (f.fileName, f.mimeType),
      ('dom-casmurro-grifos-e-notas.md', 'text/markdown'),
    );
    expect(f.content, startsWith('# Dom Casmurro — grifos e notas\n'));
    expect(f.content, contains('**Nota:** É o livro todo nessa frase.'));
  });

  testWidgets(
    'erro ao gravar: "Não deu para exportar" e a folha continua aberta',
    (tester) async {
      final arquivos = ArquivosDeTeste()..falhar = true;
      final erros = <Object>[];
      await abrirTela25(
        tester,
        livro,
        deps: depsDaTela25(livro, arquivos: arquivos, erros: erros),
      );
      await _abrir(tester);
      await tester.tap(hl('hl.export.go'));
      await tester.pump();
      await banco25(tester, voltas: 2);
      expect(hl('hl.export'), findsOneWidget);
      expect(
        appText25(tester, 'leitor.aviso', '').span.toPlainText(),
        'Não deu para exportar',
      );
      expect(erros, hasLength(1));
    },
  );

  testWidgets(
    'R12: sem grifos nem notas de texto, "Nada para exportar…" e o Exportar apagado',
    (tester) async {
      final h = tester.ensureSemantics();
      final vazio = await livroDaTela25(comAnotacoes: false);
      addTearDown(vazio.close);
      final arquivos = ArquivosDeTeste();
      await abrirTela25(
        tester,
        vazio,
        deps: depsDaTela25(vazio, arquivos: arquivos),
      );
      await _abrir(tester);
      expect(
        _visto(tester, 'hl.export.subtitle'),
        'Nada para exportar em Markdown ou CSV ainda',
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Exportar')),
        isSemantics(
          label: 'Exportar',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      await tester.tap(hl('hl.export.go'), warnIfMissed: false);
      await tester.pump();
      expect(arquivos.feitos, isEmpty);
      h.dispose();
    },
  );

  testWidgets('Cancelar e o véu fecham', (tester) async {
    await abrirTela25(tester, livro);
    await _abrir(tester);
    await tester.tap(hl('hl.export.cancel'));
    await tester.pump();
    expect(hl('hl.export'), findsNothing);
    await _abrir(tester);
    await tester.tapAt(const Offset(195, 60));
    await tester.pump();
    expect(hl('hl.export'), findsNothing);
  });
}
