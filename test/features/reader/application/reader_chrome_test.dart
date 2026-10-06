// G12.2 — o que as ilhas mostram vem do banco e muda sozinho: a fita (marcador vivo na página de referência
// mostrada), o contador de Grifos (grifos + notas + à mão + desenhos — D-124: some com 0, "99+" acima de 99), os
// minutos de hoje (refeitos a cada minuto só com os controles abertos — D-124) e o tempo restante (D-97).
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/reader/application/reader_chrome.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_reader.dart';
import '../../../support/personal_builders.dart';

Future<void> _ate(bool Function() ok) async {
  for (var i = 0; i < 200 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(ok(), isTrue);
}

void main() {
  late AppDatabase db;
  final livro = idTeste(7);
  setUp(() => db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false));
  tearDown(() => db.close());

  test('readerNotesBadge: some com 0, número até 99, "99+" acima (D-124)', () {
    expect(readerNotesBadge(0), isNull);
    expect(readerNotesBadge(-1), isNull);
    expect(readerNotesBadge(1), '1');
    expect(readerNotesBadge(12), '12');
    expect(readerNotesBadge(99), '99');
    expect(readerNotesBadge(100), '99+');
  });

  test(
    'fita, contador, minutos e tempo restante vêm do banco e mudam sozinhos',
    () async {
      await BookmarksDao(db)
          .upsert(marcadorTeste(1, livro: livro, pagina: 159));
      await BookmarksDao(db).upsert(marcadorTeste(2, livro: livro, pagina: 3));
      for (var i = 0; i < 12; i++) {
        await AnnotationsDao(db)
            .upsert(grifoTeste(10 + i, livro: livro, inicio: i * 30));
      }
      await AnnotationsDao(db).upsert(grifoTeste(40, livro: idTeste(8)));
      var pagina = 159;
      var minutos = 18;
      Duration? resta = const Duration(minutes: 130);
      final relogio = RelogioDePrazos();
      final c = ReaderChrome(
        db: db,
        userBookId: livro,
        refPage: () => pagina,
        minutes: () async => minutos,
        timeLeft: () => resta,
        startTimer: relogio.start,
      );
      addTearDown(c.dispose);
      var avisos = 0;
      c.addListener(() => avisos++);
      await _ate(() => c.ready);
      expect(
        (c.marked, c.notes, c.badge, c.minutesToday),
        (true, 12, '12', 18),
      );
      expect(c.chipLabel, '18 min hoje · contando sozinho');
      expect(c.timeLeftLabel, '≈ 2 h 10 min');

      // outra página: a fita segue a página mostrada
      pagina = 160;
      c.pageChanged();
      expect(c.marked, isFalse);
      pagina = 3;
      expect(c.marked, isTrue);

      // apagar o marcador no banco (outro aparelho, a fita da tela): o stream avisa
      final m = marcadorTeste(2, livro: livro, pagina: 3);
      await BookmarksDao(db)
          .upsert(m.copyWith(meta: m.meta.deleted(t0Teste, m.meta.version)));
      await _ate(() => !c.marked);

      // grifo novo: 13
      await AnnotationsDao(db)
          .upsert(grifoTeste(60, livro: livro, inicio: 900));
      await _ate(() => c.notes == 13);
      expect(avisos, greaterThan(0));

      // fim do livro: some o tempo
      resta = null;
      expect(c.timeLeftLabel, isNull);

      // minutos: só refaz com os controles abertos, a cada minuto
      minutos = 19;
      relogio.avancar(const Duration(minutes: 5));
      await Future<void>.delayed(Duration.zero);
      expect(c.minutesToday, 18, reason: 'controles fechados: não refaz');
      c.ticking = true;
      await _ate(() => c.minutesToday == 19);
      minutos = 20;
      relogio.avancar(const Duration(seconds: 59));
      await Future<void>.delayed(Duration.zero);
      expect(c.minutesToday, 19);
      relogio.avancar(const Duration(seconds: 1));
      await _ate(() => c.minutesToday == 20);
      c.ticking = false;
      expect(relogio.pendentes, 0);
      minutos = 21;
      relogio.avancar(const Duration(minutes: 3));
      await Future<void>.delayed(Duration.zero);
      expect(c.minutesToday, 20);
    },
  );

  test('100 anotações: "99+"', () async {
    for (var i = 0; i < 100; i++) {
      await AnnotationsDao(db)
          .upsert(grifoTeste(100 + i, livro: livro, inicio: i * 30));
    }
    final c = ReaderChrome(
      db: db,
      userBookId: livro,
      refPage: () => 1,
      minutes: () async => 0,
      timeLeft: () => null,
    );
    addTearDown(c.dispose);
    await _ate(() => c.ready);
    expect((c.notes, c.badge, c.marked), (100, '99+', false));
    expect(c.chipLabel, '0 min hoje · contando sozinho');
  });
}
