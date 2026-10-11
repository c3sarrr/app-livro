// T04.13 — o resto do cronômetro que os testes das regras não exercitam: a igualdade por valor dos resultados do
// "Ler agora", do estado e do livro (o `select` dos widgets depende dela), os textos das falhas (sem dado da pessoa), o
// relatório de falhas, o tique de 1 s de verdade e o catálogo do aparelho pelo provedor (sem o `catalog.db`, nada).
// A igualdade por valor só se prova com instâncias novas: aqui elas não são constantes de propósito.
// ignore_for_file: prefer_const_constructors

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart';
import 'package:app_leitura/features/home/application/read_now.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/reading_session/application/paper_timer_controller.dart';
import 'package:app_leitura/features/reading_session/application/second_ticker.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:app_leitura/features/reading_session/data/paper_timer_store.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:app_leitura/features/reading_session/domain/paper_timer_failure.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _bras = Book(
  id: '01925a00-0000-7000-8000-0000000000b1',
  title: 'Memórias Póstumas de Brás Cubas',
  author: 'Machado de Assis',
  cover: PhotoCover(),
);

final _t0 = DateTime.utc(2026, 9, 20, 22, 51, 18);

void main() {
  test('o "Ler agora": cada resultado é igual a ele mesmo (e o hash junto) e diferente dos outros', () {
    final todos = <ReadNowAction>[
      const ResumeSession(),
      const KeepRunning(),
      const StartTimer(_bras),
      const OpenReader(_bras),
      const NoAction(),
    ];
    for (final a in todos) {
      for (final b in todos) {
        expect(a == b, identical(a, b), reason: '$a × $b');
      }
    }
    // instâncias novas (não constantes): iguais por valor, com o mesmo hash
    final copias = <ReadNowAction>[
      ResumeSession(),
      KeepRunning(),
      StartTimer(_bras),
      OpenReader(_bras),
      NoAction(),
    ];
    for (var i = 0; i < todos.length; i++) {
      expect(identical(copias[i], todos[i]), isFalse);
    }
    for (var i = 0; i < todos.length; i++) {
      expect(copias[i], todos[i]);
      expect(copias[i].hashCode, todos[i].hashCode);
    }
  });

  test('o estado e o livro do cronômetro: iguais por valor; o texto do estado não leva o título', () {
    const livro = PaperBook(
      book: _bras,
      pagesTotal: 368,
      isbn13: '9788535910667',
    );
    final sessao = OpenPaperSession.start(
      id: '01925a00-0000-7000-8000-000000000001',
      userBookId: _bras.id,
      now: _t0,
    );
    final a = PaperTimerState(session: sessao, book: livro);
    final b = PaperTimerState(
      session: sessao,
      book: PaperBook(book: _bras, pagesTotal: 368, isbn13: '9788535910667'),
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(PaperTimerState(session: sessao)));
    expect(livro.hashCode, b.book.hashCode);
    expect(
      livro,
      isNot(
        const PaperBook(
          book: _bras,
          pagesTotal: 368,
          lastPage: 1,
          isbn13: '9788535910667',
        ),
      ),
    );
    expect(a.toString(), startsWith('PaperTimerState(OpenPaperSession('));
    expect(a.toString(), isNot(contains('Brás')));
    expect(const PaperTimerState().toString(), 'PaperTimerState(null)');
  });

  test('os textos das falhas não levam dado da pessoa', () {
    expect(
      const PaperBookGone().toString(),
      'PaperBookGone: o livro da sessão não está na estante',
    );
    expect(
      const PaperSessionAlreadyOpen().toString(),
      'PaperSessionAlreadyOpen: já há uma sessão aberta',
    );
  });

  test('o relatório de falhas do cronômetro: o erro e a pilha, na biblioteca "cronômetro"', () {
    final relatos = <FlutterErrorDetails>[];
    final antes = FlutterError.onError;
    FlutterError.onError = relatos.add;
    addTearDown(() => FlutterError.onError = antes);
    final pilha = StackTrace.current;
    reportPaperTimerError(StateError('kv fora do ar'), pilha);
    expect(relatos.single.exception, isA<StateError>());
    expect(relatos.single.stack, pilha);
    expect(relatos.single.library, 'cronômetro');
  });

  test(
    'o tique de verdade: um evento por segundo (o do app, pelo provedor)',
    () async {
      final c = ProviderContainer.test();
      final tique = c.read(secondTickerProvider);
      expect(tique, isA<PeriodicSecondTicker>());
      final relogio = Stopwatch()..start();
      final dois = await tique.ticks
          .take(2)
          .toList()
          .timeout(const Duration(seconds: 10));
      expect(dois, hasLength(2));
      expect(
        relogio.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1900)),
      );
    },
  );

  test('o catálogo do aparelho pelo provedor: fora do cache e sem o catalog.db baixado, nenhuma página (sem rede)', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    var abriuOCatalogo = 0;
    final c = ProviderContainer.test(
      overrides: [
        localDatabaseProvider.overrideWith((ref) async => db),
        catalogUpdaterProvider.overrideWith((ref) async {
          abriuOCatalogo++;
          return null;
        }),
      ],
    );
    final fonte = await c.read(paperBookSourceProvider.future);
    expect(await fonte.catalogPages('9788535910667'), isNull);
    expect(abriuOCatalogo, 1);
  });
}
