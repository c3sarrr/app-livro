// G21.8 — capturas dos pontos de clube ligados, para conferência (mandadas na conversa), 390×844 @3x. As fontes são
// as de verdade da G21 (o cache por dono com a resposta de `my_clubs` capturada do mundo das pranchas), não os dublês
// das fases L:
// - a Início com o Dom Casmurro real: o herói com a capa gerada (Q29: "Casmurro" inteiro) e, rolando, o ticket do
//   clube que o ClubsCache escreveu (R3);
// - a faixa do sumário (27) no XXXII pelo ClubsReaderClubSource: "Até o cap. L · faltam 18" (R2);
// - a 25 com o "Só do clube" ligado e o chip "Leitoras de Capitu · 3 respostas" pelo ClubsHighlightsClubSource;
// - as duas folhas sem prancha do compartilhar: "Antes de publicar" e "Compartilhar em…".
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/clubs/application/club_sources.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/clubs/domain/club_models.dart';
import 'package:app_leitura/features/highlights/application/highlights_club_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_share.dart';
import 'package:app_leitura/features/home/data/cached_club_ticket_source.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/clubs/club_models_test.dart' show fixture;
import '../fixtures/mundo_2026_09_20.dart' show mundoReferencia;
import '../support/app_com_livro.dart';
import '../support/dados_t25.dart';
import '../support/fase_l25.dart';
import '../support/fase_l27.dart';
import '../support/load_fonts.dart';
import '../support/personal_builders.dart' show idTeste;
import '../support/reader_harness.dart';

const Size _tela = Size(390, 844);

/// A edição do Dom Casmurro no mundo do clube (a mesma de `my_clubs`): o livro da estante casa pela R1.
const _edicaoDoClube = '00000000-0000-7000-8000-00000c0a0003';

Finder _k(String k) => find.byKey(ValueKey<String>(k), skipOffstage: false);

/// A tela inteira (a camada da view, em pixels físicos — 1170×2532).
Future<ui.Image> _imagem(WidgetTester tester) async {
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final image = await tester.runAsync(() => layer.toImage(view.paintBounds));
  expect((image!.width, image.height), (1170, 2532));
  return image;
}

Future<void> _gravar(WidgetTester tester, String nome) async {
  final image = await _imagem(tester);
  final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
  if (pasta == null) return;
  final png = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.png),
  );
  Directory(pasta).createSync(recursive: true);
  File('$pasta${Platform.pathSeparator}$nome')
      .writeAsBytesSync(png!.buffer.asUint8List());
}

/// O livro da estante passa a ser a edição do clube, e o cache da conta recebe os clubes do mundo (o ticket junto).
Future<ClubsCache> _clubeNoCache(LivroNaEstante livro) async {
  await livro.db.customStatement(
    'UPDATE user_books SET edition_id = ? WHERE id = ?',
    [_edicaoDoClube, livro.userBookId],
  );
  final cache = ClubsCache(() async => livro.db, now: () => agoraG20);
  await cache.saveClubs(livro.leitor, jsonEncode(fixture('my_clubs')));
  return cache;
}

/// O compartilhar com dois clubes que leem o livro e os termos ainda não aceitos.
final class _DoisClubes implements HighlightsShare {
  bool aceitou = false;

  @override
  Future<List<ShareClub>> clubsFor(String userBookId) async => const [
    (id: 'c1', name: 'Leitoras de Capitu', color: '#FFC1C6'),
    (id: 'c2', name: 'Poesia de domingo', color: '#ABCF82'),
  ];
  @override
  Future<ShareTerms> terms() async => (version: 'v1', accepted: aceitou);
  @override
  Future<void> acceptTerms(String version) async => aceitou = true;
  @override
  Future<String> share(ShareClub club, Annotation highlight) async =>
      idTeste(990);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'a Início: a capa gerada inteira (Q29) e o ticket do clube (R3)',
    (tester) async {
      final livro = await domCasmurroEmLeitura();
      addTearDown(livro.close);
      await _clubeNoCache(livro);
      await abrirAppComLivro(
        tester,
        livro,
        tela: _tela,
        clube: CachedClubTicketSource(
          () async => livro.db,
          utcOffsetAt: (_) => const Duration(hours: -3),
        ),
      );
      expect(_k('hero.title'), findsOneWidget);
      await _gravar(tester, 'g21_01_inicio_capa.png');
      await tester.ensureVisible(_k('club.ticket'));
      await tester.pumpAndSettle();
      expect(textosEm(tester, 'club'), contains('Capitu'));
      await _gravar(tester, 'g21_02_inicio_ticket.png');
    },
  );

  testWidgets('a faixa do sumário no XXXII pelo cache do clube (R2)', (
    tester,
  ) async {
    final livro = await livroDaTela27();
    addTearDown(livro.close);
    final cache = await _clubeNoCache(livro);
    await abrirTela27(tester, livro, clube: ClubsReaderClubSource(cache));
    expect(_k('toc.sheet.club'), findsOneWidget);
    expect(textosEm(tester, 'toc.sheet.club.goal'), 'Até o cap. L · faltam 18');
    await _gravar(tester, 'g21_03_sumario_faixa.png');
  });

  testWidgets('a 25: o chip do clube pelo cache e o "Só do clube"', (
    tester,
  ) async {
    final livro = await livroDaTela25();
    addTearDown(livro.close);
    final cache = ClubsCache(() async => livro.db);
    final post = mundoReferencia.clube.postCompartilhadoId;
    await cache.savePosts(
      livro.leitor,
      [post],
      [
        PostSummary(
          id: post,
          clubId: mundoReferencia.clube.id,
          clubName: 'Leitoras de Capitu',
          replies: 3,
        ),
      ],
    );
    final HighlightsClubSource clube = ClubsHighlightsClubSource(
      owner: () async => livro.leitor,
      cache: cache,
    );
    await abrirTela25(
      tester,
      livro,
      deps: depsDaTela25(livro, clube: clube),
      tela: _tela,
    );
    // "Só do clube": fica só o cartão compartilhado (o 5 do mundo, pág. 152), com o chip lido do cache
    await tester.tap(hl('hl.filters.clubOnly'));
    await tester.pump();
    await banco25(tester);
    await tester.pumpAndSettle();
    expect(cartoes25(tester).map((v) => v.card.clubPostId), [post]);
    final chip = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.endsWith('.body.club.chip'),
    );
    expect(chip, findsOneWidget);
    expect(
      textosEm(tester, (tester.widget(chip).key! as ValueKey<String>).value),
      contains('Leitoras de Capitu'),
    );
    await _gravar(tester, 'g21_04_destaques_so_do_clube_chip.png');
  });

  testWidgets(
    'as folhas do compartilhar: "Antes de publicar" e "Compartilhar em…"',
    (tester) async {
      final livro = await livroDaTela25();
      addTearDown(livro.close);
      final share = _DoisClubes();
      await abrirTela25(
        tester,
        livro,
        deps: depsDaTela25(livro, compartilhar: share),
        tela: _tela,
      );
      final n =
          cartoes25(tester).indexWhere(
            (v) =>
                shareableHighlight(v.card) != null && v.card.clubPostId == null,
          ) +
          1;
      await tester.ensureVisible(hl('hl.list.card$n.head.more'));
      await tester.pumpAndSettle();
      await tester.tap(hl('hl.list.card$n.head.more'));
      await tester.pump();
      await banco25(tester);
      await tester.tap(hl('hl.more.share'));
      await tester.pump();
      await banco25(tester);
      await tester.pumpAndSettle();
      expect(hl('hl.terms'), findsOneWidget);
      await _gravar(tester, 'g21_05_folha_antes_de_publicar.png');
      await tester.tap(hl('hl.terms.accept'));
      await tester.pump();
      await banco25(tester);
      await tester.pumpAndSettle();
      expect(hl('hl.shareTo'), findsOneWidget);
      await _gravar(tester, 'g21_06_folha_compartilhar_em.png');
    },
  );
}
