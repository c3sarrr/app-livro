// R00 (D-267) — o modo demonstração, alvo (2) (`main_mundo_referencia.dart`): a Início da prancha 01 como ela é (a
// fixture `t01` na memória: as capas desenhadas, o cartão da revisão, os números da prancha), o cronômetro do papel
// em memória que anda de verdade (a estante de papel da 01), e o leitor e os grifos abrindo o Dom Casmurro do banco
// do demo (`bancoDaDemonstracao`, semeado com o mundo). A Início da fixture chama os livros pelo slug; o leitor, pelo
// id da estante: o repositório abaixo troca o id dos livros que estão no banco (`mundoReferencia.slugs`). O que se faz
// no leitor não volta para esta Início (ela é a fixture). Sem flutter_test.
import 'dart:io';

import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/reading_session/application/second_ticker.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:path_provider/path_provider.dart';

import '../mundo_2026_09_20.dart';
import '../overrides_do_mundo.dart';
import '../telas/inicio01.dart';
import 'overrides_demonstracao.dart';

/// A Início da prancha 01 com os ids dos livros do mundo trocados pelos da estante (os outros ficam como estão).
final class RepositorioDaPranchaNoBanco implements SyncHomeRepository {
  const RepositorioDaPranchaNoBanco();

  static Book _livro(Book b) {
    final id = mundoReferencia.slugs[b.id];
    return id == null
        ? b
        : Book(
            id: id,
            title: b.title,
            shortTitle: b.shortTitle,
            author: b.author,
            cover: b.cover,
          );
  }

  @override
  HomeSnapshot snapshot(DateTime now) {
    final s = TelaInicio01.snapshot(now);
    final c = s.continueReading;
    return HomeSnapshot(
      now: s.now,
      user: s.user,
      continueReading: c == null
          ? null
          : ContinueReading(
              book: _livro(c.book),
              progress: c.progress,
              timeLeft: c.timeLeft,
              highlightsCount: c.highlightsCount,
              format: c.format,
              refPage: c.refPage,
              refPagesTotal: c.refPagesTotal,
            ),
      alsoReading: [
        for (final a in s.alsoReading)
          AlsoReadingItem(
            book: _livro(a.book),
            progress: a.progress,
            format: a.format,
            paperPage: a.paperPage,
            readTime: a.readTime,
          ),
      ],
      readingDay: s.readingDay,
      dailyReview: s.dailyReview,
      forYou: s.forYou,
      club: s.club,
      recent: [
        for (final r in s.recent)
          RecentItem(book: _livro(r.book), format: r.format, status: r.status),
      ],
      shelfIsEmpty: s.shelfIsEmpty,
    );
  }

  /// Dados fixos, como o `HomeMockRepository`: nada muda depois do instantâneo inicial (D-09).
  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}

/// O alvo (2) no aparelho; [suporte] = a pasta de suporte do app (os testes passam uma temporária).
List<Override> overridesDaPranchaNoAparelho({
  Future<Directory> Function() suporte = getApplicationSupportDirectory,
  SecondTicker tique = const PeriodicSecondTicker(),
}) => [
  ...semServicos,
  relogioDoMundo,
  homeRepositoryProvider.overrideWithValue(const RepositorioDaPranchaNoBanco()),
  ...bancoDaDemonstracao(suporte: suporte),
  ...cronometroDoMundo(tique: tique),
];
