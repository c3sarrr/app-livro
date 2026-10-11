// R00 (D-267) — a camada da prancha 01 no banco do modo demonstração: o que a Início desenha e o mundo do leitor não
// tem (`test/home/t01_divergencias_test.dart` lista as diferenças), gravado como dado de verdade para as regras do app
// chegarem aos números da prancha:
// * o Brás Cubas de papel em leitura, sem página, com 3h 40min já lidos (D-252) — o "play" do cronômetro (01b);
// * o Orgulho e Preconceito em papel, na pág. 344 (D-253), aberto depois da Mrs. Dalloway (a ordem do Também lendo);
// * o O Alienista "Lido" e a Senhora em papel (os Recém-chegados — D-255);
// * o ISBN do Dom Casmurro, o da leitura do clube (o clube "lê" o livro da estante: a faixa do sumário, a R3);
// * as "2 sessões" de hoje: a sessão de 18 min do mundo dividida em 10 + 8 (135 → 147 → 159, as 24 páginas de hoje).
// O que as regras não deixam reproduzir fica como diferença (o "Quero ler" do Frankenstein: a D-88 diz "Novo" a quem
// chegou há menos de 7 dias; "2 destaques": a D-60). Sem flutter_test: entra no app (`main_demonstracao.dart`).
import 'dart:convert';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';
import 'package:crypto/crypto.dart';

import '../mundo_2026_09_20.dart';

/// O ISBN do Brás Cubas da camada (o mesmo do `cronometro_papel_test`) e o total de páginas das notas do design
/// ("Brás Cubas: 208 pág.") — o catálogo do aparelho o oferece na folha da sessão (D-260).
const String isbnBrasCubas = '9788535910667';
const int paginasBrasCubas = 208;

/// O ISBN-13 do Dom Casmurro da leitura do clube (o `my_clubs` da G21): o mundo não guarda o ISBN dos livros; com ele
/// o clube "lê" o Dom Casmurro da estante (R3, a faixa do sumário — D-149).
const String isbnDomCasmurro = '9788535902778';

/// As 6 sessões do Brás Cubas (somam 3h 40min), em agosto: fora da semana do gráfico e da sequência de 12 dias.
const List<int> minutosBrasCubas = [40, 35, 40, 35, 40, 30];

/// Os minutos das duas sessões de hoje (somam os 18 do mundo).
const (int, int) minutosDeHoje = (10, 8);

DateTime _sp(int mes, int dia, [int hora = 0, int minuto = 0]) =>
    DateTime.utc(2026, mes, dia, hora + 3, minuto);

/// UUIDv7 determinístico (instante + bits do sha256 do nome), como o do mundo, noutro espaço de nomes.
String idDaDemonstracao(String nome, DateTime em) {
  final ms = em.millisecondsSinceEpoch.toRadixString(16).padLeft(12, '0');
  final h = sha256.convert(utf8.encode('demonstracao_r00/$nome')).toString();
  final variante = (8 + int.parse(h[3], radix: 16) % 4).toRadixString(16);
  return '${ms.substring(0, 8)}-${ms.substring(8)}-7${h.substring(0, 3)}-'
      '$variante${h.substring(4, 7)}-${h.substring(7, 19)}';
}

RecordMeta _meta(DateTime em) => RecordMeta(
  userId: mundoReferencia.usuarioId,
  createdAt: em,
  updatedAt: em,
  version: Hlc(em.millisecondsSinceEpoch, 0, mundoReferencia.aparelhoId),
);

/// A edição da camada sobre um registro do mundo ([original]): no "agora" de referência, depois de tudo o que o mundo
/// gravou (a guarda de versão da ADR-003 não aceita uma versão menor que a da linha).
RecordMeta _editado(RecordMeta original) {
  final em = mundoReferencia.agora;
  if (original.version.ms >= em.millisecondsSinceEpoch) {
    throw StateError('a versão do mundo (${original.version}) passa do agora');
  }
  return original.edited(
    em,
    Hlc(em.millisecondsSinceEpoch, 0, mundoReferencia.aparelhoId),
  );
}

/// O id do Brás Cubas na estante da demonstração.
final String idBrasCubas = idDaDemonstracao('livro/bras-cubas', _sp(8, 10, 20));

/// Grava a camada da 01 por cima do mundo já gravado ([db]).
Future<void> gravarCamadaDaPrancha01(AppDatabase db) async {
  final m = mundoReferencia;
  final livros = UserBooksDao(db);

  await livros.upsert(
    UserBook(
      id: idBrasCubas,
      meta: _meta(_sp(8, 10, 20)),
      title: 'Memórias Póstumas de Brás Cubas',
      authorDisplay: 'Machado de Assis',
      format: BookFileFormat.physical,
      status: ShelfStatus.reading,
      isbn13: isbnBrasCubas,
      addedAt: _sp(8, 10, 20),
      startedAt: _sp(8, 10, 21),
      // depois do Orgulho (19/09 20:00) e antes do Dom Casmurro (20/09 19:20): o 1º do Também lendo
      lastOpenedAt: _sp(9, 19, 22),
    ),
  );
  for (var i = 0; i < minutosBrasCubas.length; i++) {
    final inicio = _sp(8, 10 + i, 21);
    final fim = inicio.add(Duration(minutes: minutosBrasCubas[i]));
    await ReadingSessionsDao(db).upsert(
      ReadingSession(
        id: idDaDemonstracao('sessao/bras-cubas/$i', inicio),
        meta: _meta(fim),
        userBookId: idBrasCubas,
        startedAt: inicio,
        endedAt: fim,
        activeSeconds: minutosBrasCubas[i] * 60,
        source: SessionSource.timer,
        deviceId: m.aparelhoId,
      ),
    );
  }
  await CatalogCacheDao(db).putBook(
    const CatalogBook(
      isbn13: isbnBrasCubas,
      title: 'Memórias Póstumas de Brás Cubas',
      pages: paginasBrasCubas,
      source: 'openlibrary',
    ),
    _sp(8, 10, 20),
  );

  final dc = m.domCasmurro;
  await livros.upsert(
    dc.copyWith(
      meta: _editado(dc.meta),
      isbn13: const Nullable(isbnDomCasmurro),
    ),
  );

  final orgulho = m.livro(Slugs.orgulho);
  await livros.upsert(
    orgulho.copyWith(
      meta: _editado(orgulho.meta),
      format: BookFileFormat.physical,
      lastOpenedAt: Nullable(_sp(9, 19, 20)),
    ),
  );
  final alienista = m.livro(Slugs.alienista);
  await livros.upsert(
    alienista.copyWith(
      meta: _editado(alienista.meta),
      status: ShelfStatus.finished,
    ),
  );
  final senhora = m.livro(Slugs.senhora);
  await livros.upsert(
    senhora.copyWith(
      meta: _editado(senhora.meta),
      format: BookFileFormat.physical,
      contentSha256: const Nullable(null),
    ),
  );

  // a sessão de hoje do mundo (18 min, 135 → 159) vira duas: 10 min (135 → 147) e 8 min (147 → 159)
  final hoje = m.sessoes.singleWhere(
    (s) => s.startedAt.isAfter(m.agora.subtract(const Duration(hours: 12))),
  );
  final (primeira, segunda) = minutosDeHoje;
  await ReadingSessionsDao(db).upsert(
    hoje.copyWith(
      meta: _editado(hoje.meta),
      endedAt: hoje.startedAt.add(Duration(minutes: primeira)),
      activeSeconds: primeira * 60,
      refPageTo: const Nullable(147),
      pagesViewed: const Nullable(12),
    ),
  );
  final inicio2 = hoje.startedAt.add(Duration(minutes: primeira + 2));
  await ReadingSessionsDao(db).upsert(
    ReadingSession(
      id: idDaDemonstracao('sessao/hoje/2', inicio2),
      meta: _meta(inicio2.add(Duration(minutes: segunda))),
      userBookId: hoje.userBookId,
      startedAt: inicio2,
      endedAt: inicio2.add(Duration(minutes: segunda)),
      activeSeconds: segunda * 60,
      refPageFrom: 147,
      refPageTo: 159,
      pagesViewed: 12,
      source: SessionSource.auto,
      deviceId: m.aparelhoId,
    ),
  );
}
