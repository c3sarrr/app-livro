// R00 (D-267) — o clube do mundo de referência ("Leitoras de Capitu") no cache do social do banco do modo
// demonstração, pelo mesmo caminho da G21 (sem servidor, o app é só convidado — D-64): a resposta de `my_clubs`
// (no formato da fixture `test/fixtures/clube/my_clubs.json`, com os números do mundo e da prancha 01) guardada pelo
// `ClubsCache.saveClubs`, que refaz o ticket da Início pela regra R3; o chip do grifo compartilhado da 25
// (`savePosts`) e o sininho com 2 novas (`saveNotifications`). Sem flutter_test: entra no app.
import 'dart:convert';
import 'dart:ui' show Color;

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/clubs/domain/club_models.dart';

import '../mundo_2026_09_20.dart';

/// Os ids do livro do clube (a leitura atual do `my_clubs` da fixture da G21).
const String idDaLeituraDoClube = '00000000-0000-7000-8000-00000c300001';
const String idDaEdicaoDoClube = '00000000-0000-7000-8000-00000c0a0003';
const String idDaObraDoClube = '00000000-0000-7000-8000-00000c0a0002';
const String idDoEncontro = '00000000-0000-7000-8000-00000c400002';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// A resposta de `my_clubs` com o clube do mundo: o encontro de qui 24/09 20:00, a semana 2 (caps. 26–50), 11
/// pessoas, o grupo em 54 %, a Marina em 62 % e 3 mensagens novas (01 e 04).
List<Map<String, Object?>> clubesDoMundo() {
  final m = mundoReferencia;
  final c = m.clube;
  final semana = {
    'no': 2,
    'from': 26,
    'to': c.metaCapitulo,
    'from_label': null,
    'to_label': null,
  };
  return [
    {
      'id': c.id,
      'me': {'color': '#FED170', 'initial': c.inicialDaUsuaria},
      'name': '${c.nomePrefixo} ${c.nomeDestaque}',
      'name_highlight': c.nomeDestaque,
      'role': 'member',
      'color': '#FFC1C6',
      'unread': c.mensagensNaoLidas,
      'privacy': 'invite',
      'category': 'Clássicos brasileiros',
      'reading': {
        'id': idDaLeituraDoClube,
        'isbns': ['9788508140912', '9788535902778'],
        'pages': m.domCasmurro.refPagesTotal,
        'title': m.domCasmurro.title,
        'weeks': 6,
        'author': m.domCasmurro.authorDisplay,
        'isbn13': '9788535902778',
        'work_id': idDaObraDoClube,
        'cover_ref': null,
        'edition_id': idDaEdicaoDoClube,
        'current_week': semana,
      },
      'my_progress': double.parse(
        m.posicao(Slugs.domCasmurro).progression.toStringAsFixed(2),
      ),
      'next_meeting': {
        'id': idDoEncontro,
        'mine': 'vou',
        'mode': 'online',
        'weeks': 6,
        'agenda': semana,
        'counts': {'vou': 8, 'talvez': 3, 'nao_vou': 0},
        'starts_at': c.proximoEncontro.toUtc().toIso8601String(),
        'ends_at': c.proximoEncontro
            .add(const Duration(minutes: 90))
            .toUtc()
            .toIso8601String(),
        'week_no': 2,
        'location': null,
        'timezone': 'America/Sao_Paulo',
      },
      'participants': [
        for (final p in c.exibidos)
          {'initial': p.inicial, 'color': _hex(p.cor)},
      ],
      'members_count': c.participantes,
      'group_progress': c.progressoDoGrupo,
      'last_activity_at': m.agora
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
      'spoiler_protection': true,
    },
  ];
}

/// Grava o clube do mundo no cache do social do dono [owner].
Future<void> gravarClubeDemonstracao(AppDatabase db, String owner) async {
  final m = mundoReferencia;
  final cache = ClubsCache(() async => db, now: () => m.agora);
  await cache.saveClubs(owner, jsonEncode(clubesDoMundo()));
  await cache.savePosts(
    owner,
    [m.clube.postCompartilhadoId],
    [
      PostSummary(
        id: m.clube.postCompartilhadoId,
        clubId: m.clube.id,
        clubName: '${m.clube.nomePrefixo} ${m.clube.nomeDestaque}',
        replies: m.clube.respostasDoPost,
      ),
    ],
  );
  await cache.saveNotifications(owner, m.perfil.notificacoesNaoLidas);
}
