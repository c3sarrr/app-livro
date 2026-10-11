// G21.5 — a 25 com os clubes (docs/progresso/G21.md §5): o chip ao vivo (relê a cada aviso; fechar a 25 fecha os
// canais) e "Compartilhar no clube" nos 7 casos — sem conta, nenhum clube, os termos, um clube ou a escolha, o id que
// volta para o grifo, o já compartilhado e o item sem texto.
import 'dart:async';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/highlights/application/card_text_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_club_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_controller.dart';
import 'package:app_leitura/features/highlights/application/highlights_file_sink.dart';
import 'package:app_leitura/features/highlights/application/highlights_repository.dart';
import 'package:app_leitura/features/highlights/application/highlights_share.dart';
import 'package:app_leitura/features/highlights/domain/highlight_card.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../support/personal_builders.dart' show idTeste;

const ShareClub _capitu = (
  id: 'c1',
  name: 'Leitoras de Capitu',
  color: '#FFC1C6',
);
const ShareClub _poesia = (
  id: 'c2',
  name: 'Poesia de domingo',
  color: '#ABCF82',
);

/// O chip do cache: muda quando o "servidor" muda.
final class _Chips implements HighlightsClubSource {
  final Map<String, int> respostas = {
    mundoReferencia.clube.postCompartilhadoId: 3,
  };
  @override
  Future<ClubChip?> clubOf(String id) async => switch (respostas[id]) {
    final n? => (clubId: 'c1', name: 'Leitoras de Capitu', replies: n),
    null => null,
  };
}

final class _AoVivo implements ClubChipUpdates {
  final seguidos = <Set<String>>[];
  StreamController<void>? atual;
  int fechados = 0;

  @override
  Stream<void> follow(Set<String> postIds) {
    seguidos.add(postIds);
    final c = StreamController<void>(onCancel: () => fechados++);
    atual = c;
    return c.stream;
  }
}

final class _Compartilhar implements HighlightsShare {
  _Compartilhar(this.chips);
  final _Chips chips;
  List<ShareClub> clubes = const [_capitu];
  ShareTerms termos = (version: '2026-10-provisorio', accepted: true);
  Object? falhaDosClubes;
  Object? falhaDosTermos;
  Object? falha;
  final aceitos = <String>[];
  final feitos = <(String, String)>[];

  @override
  Future<List<ShareClub>> clubsFor(String userBookId) async {
    if (falhaDosClubes case final f?) throw f;
    return clubes;
  }

  @override
  Future<ShareTerms> terms() async {
    if (falhaDosTermos case final f?) throw f;
    return termos;
  }

  /// A versão mudou entre ler e aceitar (o servidor recusa a lida).
  String? versaoNova;

  @override
  Future<void> acceptTerms(String version) async {
    if (versaoNova case final v? when v != version) {
      termos = (version: v, accepted: false);
      throw const SocialTermsRequired();
    }
    aceitos.add(version);
    termos = (version: version, accepted: true);
  }

  @override
  Future<String> share(ShareClub club, Annotation highlight) async {
    if (falha case final f?) {
      falha = null;
      throw f;
    }
    feitos.add((club.id, highlight.id));
    final id = idTeste(990 + feitos.length);
    chips.respostas[id] = 0; // o chip aparece na hora (o cache ganhou o post)
    return id;
  }
}

final class _Arquivos implements HighlightsFileSink {
  @override
  Future<void> share({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {}
}

void main() {
  late AppDatabase db;
  late HighlightsController c;
  late List<Object> erros;
  late _Chips chips;
  late _AoVivo aoVivo;
  late _Compartilhar compartilhar;
  final m = mundoReferencia;
  final livro = m.domCasmurro.id;

  Future<void> ate(bool Function() ok) async {
    for (var i = 0; i < 300 && !ok(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  HighlightsController novo({bool comConta = true}) => HighlightsController(
    userBookId: livro,
    deps: HighlightsDeps(
      db: db,
      repository: HighlightsRepository(
        db: db,
        versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoB')),
        owner: () async => m.usuarioId,
      ),
      textSourceFor: (_) async => const AnchorOnlyCardTextSource(),
      club: chips,
      clubUpdates: comConta ? aoVivo : null,
      share: comConta ? compartilhar : null,
      now: () => DateTime.utc(2026, 10, 9, 15),
      utcOffsetAt: (_) => m.fuso,
      files: _Arquivos(),
      onError: (e, _) => erros.add(e),
    ),
  );

  setUp(() async {
    erros = [];
    chips = _Chips();
    aoVivo = _AoVivo();
    compartilhar = _Compartilhar(chips);
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    await UserBooksDao(db).upsert(m.domCasmurro);
    await ReadingPositionsDao(db).upsert(m.posicao(Slugs.domCasmurro));
    for (final l in m.camadas) {
      await InkLayersDao(db).upsert(l);
    }
    for (final a in m.anotacoes) {
      await AnnotationsDao(db).upsert(a);
    }
    c = novo();
    await c.load();
    await ate(() => !c.state.loading);
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  HighlightCard cartao(bool Function(HighlightCard) ok) =>
      c.state.cards.firstWhere(ok);
  HighlightCard livre() =>
      cartao((x) => shareableHighlight(x) != null && x.clubPostId == null);

  group('o chip ao vivo (D-225)', () {
    test('ao abrir, acompanha os posts compartilhados; um aviso relê: "3 respostas" vira 4', () async {
      final post = m.clube.postCompartilhadoId;
      expect(c.state.clubs[post]!.replies, 3);
      expect(aoVivo.seguidos, [
        {post},
      ]);
      chips.respostas[post] = 4;
      aoVivo.atual!.add(null);
      await ate(() => c.state.clubs[post]!.replies == 4);
      expect(c.state.clubs[post], (
        clubId: 'c1',
        name: 'Leitoras de Capitu',
        replies: 4,
      ));
    });

    test(
      'fechar a 25 fecha o acompanhamento; sem conta, nada é acompanhado',
      () async {
        c.dispose();
        expect(aoVivo.fechados, 1);
        c = novo(comConta: false);
        aoVivo.seguidos.clear();
        await c.load();
        await ate(() => !c.state.loading);
        expect(aoVivo.seguidos, isEmpty);
        expect(c.state.clubs, hasLength(1), reason: 'o chip do cache continua');
      },
    );
  });

  group('compartilhar no clube (§5)', () {
    test('1 · sem conta: a pílula "Entre na sua conta…"; sem rede nos termos: "Sem conexão…"', () async {
      c.dispose();
      c = novo(comConta: false);
      await c.load();
      await ate(() => !c.state.loading);
      expect(
        await c.startShare(livre()),
        isA<ShareNotice>().having((s) => s.text, 'text', shareSignInText),
      );

      c.dispose();
      c = novo();
      await c.load();
      await ate(() => !c.state.loading);
      compartilhar.falhaDosClubes = const SocialNeedsAccount();
      expect(
        (await c.startShare(livre()) as ShareNotice).text,
        shareSignInText,
      );
      compartilhar
        ..falhaDosClubes = null
        ..falhaDosTermos = const SocialOffline();
      expect(
        (await c.startShare(livre()) as ShareNotice).text,
        shareOfflineText,
      );
      expect(compartilhar.feitos, isEmpty);
    });

    test('2 · nenhum clube lê o livro: a pílula', () async {
      compartilhar.clubes = const [];
      expect(
        (await c.startShare(livre()) as ShareNotice).text,
        shareNoClubText,
      );
    });

    test('3 · termos não aceitos: a folha; aceitar leva a versão lida e compartilha', () async {
      compartilhar.termos = (version: '2026-10-provisorio', accepted: false);
      final card = livre();
      final passo = await c.startShare(card);
      expect(passo, isA<ShareNeedsTerms>());
      final t = passo as ShareNeedsTerms;
      expect(t.version, '2026-10-provisorio');
      expect(t.clubs, [_capitu]);
      expect(compartilhar.feitos, isEmpty);
      final fim = await c.acceptTerms(card, t);
      expect(compartilhar.aceitos, ['2026-10-provisorio']);
      expect((fim as ShareNotice).text, 'Compartilhado em Leitoras de Capitu.');
    });

    test(
      '3 · a versão mudou no "Aceitar e continuar": a folha volta com a nova',
      () async {
        compartilhar
          ..termos = (version: '2026-10-provisorio', accepted: false)
          ..versaoNova = '2026-11';
        final card = livre();
        final t = await c.startShare(card) as ShareNeedsTerms;
        final deNovo = await c.acceptTerms(card, t);
        expect(deNovo, isA<ShareNeedsTerms>());
        expect((deNovo as ShareNeedsTerms).version, '2026-11');
        expect(deNovo.clubs, [_capitu]);
        final fim = await c.acceptTerms(card, deNovo);
        expect(
          (fim as ShareNotice).text,
          'Compartilhado em Leitoras de Capitu.',
        );
        expect(compartilhar.aceitos, ['2026-11']);
      },
    );

    test('4 e 5 · um clube: direto; o id do post volta para o grifo e o chip aparece', () async {
      final card = livre();
      final h = shareableHighlight(card)!;
      final fim = await c.startShare(card);
      expect((fim as ShareNotice).text, sharedText('Leitoras de Capitu'));
      expect(compartilhar.feitos, [('c1', h.id)]);
      final gravado = await AnnotationsDao(db).byId(h.id);
      expect(gravado!.sharedClubPostId, idTeste(991));
      await ate(() => c.state.clubs.containsKey(idTeste(991)));
      expect(c.state.clubs[idTeste(991)]!.replies, 0);
      final depois = c.state.cards.firstWhere((x) => x.groupId == card.groupId);
      expect(c.sharedLabel(depois), 'Já está em Leitoras de Capitu');
    });

    test('4 · mais de um clube: a folha "Compartilhar em…"; o toque publica no escolhido', () async {
      compartilhar.clubes = const [_capitu, _poesia];
      final card = livre();
      final passo = await c.startShare(card);
      expect((passo as ShareChoose).clubs, [_capitu, _poesia]);
      final fim = await c.shareTo(card, _poesia);
      expect((fim as ShareNotice).text, 'Compartilhado em Poesia de domingo.');
      expect(compartilhar.feitos.single.$1, 'c2');
    });

    test('a versão dos termos mudou no meio: a folha volta com a nova; sem rede ao publicar: nada muda', () async {
      final card = livre();
      compartilhar
        ..falha = const SocialTermsRequired()
        ..termos = (version: '2026-11', accepted: false);
      final passo = await c.shareTo(card, _capitu);
      expect((passo as ShareNeedsTerms).version, '2026-11');
      expect(passo.clubs, [_capitu]);

      compartilhar.falha = const SocialOffline();
      expect(
        (await c.shareTo(card, _capitu) as ShareNotice).text,
        shareOfflineText,
      );
      final h = shareableHighlight(card)!;
      expect((await AnnotationsDao(db).byId(h.id))!.sharedClubPostId, isNull);

      compartilhar.falha = const SocialUnexpected('pg_500');
      expect(
        (await c.shareTo(card, _capitu) as ShareNotice).text,
        shareFailedText,
      );
    });

    test(
      '6 · já compartilhado: o rótulo "Já está em…" e nada publica de novo',
      () async {
        final shared = cartao((x) => x.clubPostId != null);
        expect(c.sharedLabel(shared), 'Já está em Leitoras de Capitu');
        expect(c.sharedLabel(livre()), isNull);
        expect(
          (await c.startShare(shared) as ShareNotice).text,
          'Já está em Leitoras de Capitu',
        );
        expect(compartilhar.feitos, isEmpty);
        expect(alreadySharedText(null), 'Já está no clube');
      },
    );

    test(
      '7 · item sem texto (tinta, marca-texto à mão): a opção não aparece',
      () async {
        final semTexto = c.state.cards
            .where((x) => shareableHighlight(x) == null)
            .toList();
        expect(semTexto, isNotEmpty);
        for (final x in semTexto) {
          expect(x.highlight == null || x.freehand, isTrue);
          expect(c.canShare(x), isFalse);
        }
        expect(c.canShare(livre()), isTrue);
        expect(
          (await c.startShare(semTexto.first) as ShareNotice).text,
          shareFailedText,
        );
      },
    );
  });
}
