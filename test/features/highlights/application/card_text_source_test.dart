// G19.2 — de onde vem o texto dos cartões (R3) e quem está sem lugar (D-199): o texto dos itens do EPUB (num isolate,
// com cache) e a reancoragem do leitor; sem o arquivo, o recuo pela citação guardada.
import 'dart:io';

import 'package:app_leitura/features/highlights/application/card_text_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_club_source.dart';
import 'package:app_leitura/features/highlights/domain/card_text.dart';
import 'package:app_leitura/features/highlights/domain/highlight_card.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../support/epub_builder.dart';
import '../../../support/mundo_epub.dart';
import '../support/ordem_do_livro.dart';

String plano(List<CardSpan> s) =>
    s.map((x) => x.annotationId == null ? x.text : '[${x.text}]').join();

void main() {
  late Directory dir;
  late String caminho;
  final cartoes = buildCards(itensDoMundo());
  final outroSha = 'f' * 64;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('booknest_g19_texto_');
    caminho = writeTemp(
      dir,
      'dc.epub',
      mundoEpub(Slugs.domCasmurro, completo: true),
    );
  });
  tearDownAll(() => dir.deleteSync(recursive: true));

  test('do livro: os cartões 7 e 8 saem do texto do capítulo, como o arquivo; ninguém sem lugar', () async {
    final r = await EpubCardTextSource(
      path: caminho,
      sha: outroSha,
    ).textsFor(cartoes);
    expect(r.byGroup, hasLength(8));
    expect(
      plano(r.byGroup[cartoes[7].groupId]!),
      'Traziam não sei que [fluido misterioso] e enérgico, uma força que arrastava para dentro, como [a vaga que se retira] da praia…',
    );
    expect(
      plano(r.byGroup[cartoes[6].groupId]!),
      '[Olhos de ressaca?] Vá, de ressaca.',
    );
    expect(
      plano(r.byGroup[cartoes[5].groupId]!),
      endsWith('[olhos de Capitu].'),
    );
    expect(r.orphans, isEmpty);
    expect(
      r.byGroup[cartoes[1].groupId]!
          .where((s) => s.annotationId != null)
          .map((s) => s.annotationId),
      [cartoes[1].highlight!.id],
      reason: 'a nota de texto não marca o texto (fica no post-it)',
    );
  });

  test(
    'o mesmo arquivo usa os deslocamentos guardados (sem procurar)',
    () async {
      final sha = (cartoes[7].items.first.anchor as EpubAnchor).sha;
      final r = await EpubCardTextSource(
        path: caminho,
        sha: sha,
      ).textsFor([cartoes[7]]);
      expect(
        plano(r.byGroup[cartoes[7].groupId]!),
        contains('[fluido misterioso]'),
      );
    },
  );

  test('abre o livro uma vez por pedido e guarda os textos', () async {
    final pedidos = <List<int>>[];
    final f = EpubCardTextSource(
      path: caminho,
      sha: outroSha,
      spineTexts: (p, s) {
        pedidos.add(s);
        return isolateSpineTexts(p, s);
      },
    );
    await f.textsFor(cartoes);
    await f.textsFor(cartoes);
    expect(pedidos, hasLength(1));
    expect(pedidos.single, orderedEquals([...pedidos.single]..sort()));
  });

  test(
    'âncora de outro arquivo que não volta: sem lugar, com o texto da citação',
    () async {
      final p3 = cartoes[0].highlight!;
      final a = p3.anchor as EpubAnchor;
      final perdida = p3.copyWith(
        anchor: EpubAnchor(
          sha: 'e' * 64,
          spine: a.spine,
          start: a.start,
          end: a.start + 20,
          quote: const TextQuote(
            prefix: 'zzz ',
            exact: 'frase que não existe',
            suffix: '.',
          ),
          refPage: 3,
        ),
      );
      final r = await EpubCardTextSource(
        path: caminho,
        sha: outroSha,
      ).textsFor(buildCards([perdida]));
      expect(r.orphans, {p3.groupId});
      expect(plano(r.byGroup[p3.groupId]!), 'zzz [frase que não existe].');
    },
  );

  test(
    'sem o arquivo (ou com erro ao ler): o recuo, e ninguém sem lugar',
    () async {
      final semCaminho = await EpubCardTextSource(
        path: null,
        sha: outroSha,
      ).textsFor(cartoes);
      final erro = await EpubCardTextSource(
        path: '${dir.path}${Platform.pathSeparator}nao_existe.epub',
        sha: outroSha,
      ).textsFor(cartoes);
      for (final r in [semCaminho, erro]) {
        expect(r.orphans, isEmpty);
        expect(r.byGroup, hasLength(8));
        expect(
          r.byGroup[cartoes[0].groupId]!
              .singleWhere((s) => s.annotationId != null)
              .text,
          'que eu conheço de vista e de chapéu.',
        );
      }
    },
  );

  test(
    'só a citação: cada trecho marcado; a nota à mão sem texto não entra',
    () async {
      final r = await const AnchorOnlyCardTextSource().textsFor(cartoes);
      expect(r.orphans, isEmpty);
      expect(
        r.byGroup[cartoes[6].groupId]!
            .where((s) => s.annotationId != null)
            .map((s) => s.text),
        ['Olhos de ressaca?'],
      );
      expect(markedItems(cartoes[1]).map((a) => a.kind), [
        AnnotationKind.highlight,
      ]);
    },
  );

  test('o clube: nenhum até a G21', () async {
    expect(await const NoHighlightsClub().clubOf('x'), isNull);
  });
}
