// T04.1 — a sessão do cronômetro do livro de papel (spec docs/progresso/T04.md, R2–R4, R8): o tempo corre pelo
// relógio de parede a partir do "rodando desde" (sobrevive ao app fechado), relógio que volta não desconta nem
// inventa, 24 h de tempo ativo pausam sozinhas (o CHECK do banco), menos de 10 s não grava e retomar noutro dia
// grava a sessão anterior e abre outra (D-85, G10).
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:flutter_test/flutter_test.dart';

const _id = '01925a00-0000-7000-8000-000000000001';
const _id2 = '01925a00-0000-7000-8000-000000000002';
const _livro = '01925a00-0000-7000-8000-0000000000b1';

/// 20/09/2026 19:51:18 em São Paulo (−3 h): 08:42 antes das 20:00 da prancha 01b.
final _t0 = DateTime.utc(2026, 9, 20, 22, 51, 18);

Duration _saoPaulo(DateTime utc) => const Duration(hours: -3);

OpenPaperSession _rodando({int acumulado = 0, DateTime? desde}) =>
    OpenPaperSession(
      id: _id,
      userBookId: _livro,
      startedAt: _t0,
      activeSeconds: acumulado,
      runningSince: desde ?? _t0,
    );

void main() {
  group('começar, pausar e retomar', () {
    test('começar: rodando desde agora, 0 s; 8 min 42 s depois = 522 s', () {
      final s = OpenPaperSession.start(id: _id, userBookId: _livro, now: _t0);
      expect(s.isRunning, isTrue);
      expect(s.startedAt, _t0);
      expect(s.activeSeconds, 0);
      expect(s.runningSince, _t0);
      expect(s.pausedAt, isNull);
      expect(
        s.elapsedAt(_t0.add(const Duration(minutes: 8, seconds: 42))),
        522,
      );
    });

    test('o início vira UTC (o relógio local de quem chamou não vaza)', () {
      final local = _t0.toLocal();
      final s = OpenPaperSession.start(id: _id, userBookId: _livro, now: local);
      expect(s.startedAt.isUtc, isTrue);
      expect(s.startedAt, _t0);
    });

    test('pausar guarda o tempo e o instante; depois o tempo não anda', () {
      final pausa = _t0.add(const Duration(seconds: 522));
      final s = _rodando().pause(pausa);
      expect(s.isRunning, isFalse);
      expect(s.activeSeconds, 522);
      expect(s.pausedAt, pausa);
      expect(s.elapsedAt(pausa.add(const Duration(hours: 3))), 522);
      // pausar de novo não muda nada
      expect(s.pause(pausa.add(const Duration(minutes: 1))), s);
    });

    test('retomar: roda desde agora com os 522 guardados', () {
      final pausa = _t0.add(const Duration(seconds: 522));
      final volta = pausa.add(const Duration(minutes: 30));
      final s = _rodando().pause(pausa).resume(volta);
      expect(s.isRunning, isTrue);
      expect(s.runningSince, volta);
      expect(s.pausedAt, isNull);
      expect(s.activeSeconds, 522);
      expect(s.elapsedAt(volta.add(const Duration(seconds: 60))), 582);
      // retomar a que já roda não muda nada
      expect(s.resume(volta.add(const Duration(minutes: 1))), s);
    });
  });

  group('relógio de parede (R2)', () {
    test('relógio que volta: o trecho negativo conta 0 e o "desde" passa a ser agora', () {
      final antes = _t0.subtract(const Duration(seconds: 30));
      final s = _rodando(acumulado: 100);
      expect(s.elapsedAt(antes), 100);
      final acertada = s.settle(antes);
      expect(acertada.runningSince, antes);
      expect(acertada.activeSeconds, 100);
      // e daí em diante conta a partir do novo "desde"
      expect(acertada.elapsedAt(antes.add(const Duration(seconds: 5))), 105);
    });

    test('24 h de tempo ativo pausam sozinhas no instante do limite', () {
      final s = _rodando(acumulado: 86000);
      final depois = _t0.add(const Duration(hours: 1));
      expect(s.elapsedAt(depois), maxPaperSessionSeconds);
      final acertada = s.settle(depois);
      expect(acertada.isRunning, isFalse);
      expect(acertada.activeSeconds, 86400);
      expect(acertada.pausedAt, _t0.add(const Duration(seconds: 400)));
      // no limite, retomar continua pausada
      expect(acertada.resume(depois), acertada);
      // pausar depois do limite pausa no limite, não agora
      expect(s.pause(depois).pausedAt, _t0.add(const Duration(seconds: 400)));
    });

    test('antes do limite, acertar não muda nada', () {
      final s = _rodando(acumulado: 10);
      expect(s.settle(_t0.add(const Duration(minutes: 5))), s);
      final pausada = s.pause(_t0.add(const Duration(seconds: 5)));
      expect(pausada.settle(_t0.add(const Duration(days: 3))), pausada);
    });
  });

  group('o registro do fim (R3)', () {
    test('menos de 10 s: nada a gravar', () {
      expect(_rodando().record(_t0.add(const Duration(seconds: 9))), isNull);
    });

    test('10 s rodando: o fim é agora', () {
      final fim = _t0.add(const Duration(seconds: 10));
      expect(
        _rodando().record(fim),
        PaperSessionRecord(
          id: _id,
          userBookId: _livro,
          startedAt: _t0,
          endedAt: fim,
          activeSeconds: 10,
        ),
      );
    });

    test(
      'pausada: o fim é o instante da pausa, não a hora do encerramento',
      () {
        final pausa = _t0.add(const Duration(seconds: 522));
        final r = _rodando()
            .pause(pausa)
            .record(pausa.add(const Duration(hours: 2)));
        expect(r!.endedAt, pausa);
        expect(r.activeSeconds, 522);
      },
    );

    test(
      'relógio para trás: o fim nunca fica antes do início (CHECK do banco)',
      () {
        final r = _rodando(acumulado: 60)
            .record(_t0.subtract(const Duration(minutes: 5)));
        expect(r!.endedAt, _t0);
        expect(r.activeSeconds, 60);
      },
    );

    test('24 h estouradas: grava 86 400 e o fim no limite', () {
      final r = _rodando(acumulado: 86000)
          .record(_t0.add(const Duration(days: 2)));
      expect(r!.activeSeconds, 86400);
      expect(r.endedAt, _t0.add(const Duration(seconds: 400)));
    });
  });

  group('o dia local (D-85, R1, R4)', () {
    test('a sessão das 23:59 locais não é "hoje" à 00:00 seguinte', () {
      final s = OpenPaperSession.start(
        id: _id,
        userBookId: _livro,
        now: DateTime.utc(2026, 9, 21, 2, 59), // 23:59 do dia 20 em São Paulo
      );
      expect(
        s.isOnLocalDay(DateTime.utc(2026, 9, 21, 2, 59, 59), _saoPaulo),
        isTrue,
      );
      expect(s.isOnLocalDay(DateTime.utc(2026, 9, 21, 3), _saoPaulo), isFalse);
    });

    test('o deslocamento é o de cada instante (dia com troca de horário)', () {
      Duration verao(DateTime utc) => utc.isBefore(DateTime.utc(2026, 11, 1, 3))
          ? const Duration(hours: -3)
          : const Duration(hours: -2);
      final s = OpenPaperSession.start(
        id: _id,
        userBookId: _livro,
        now: DateTime.utc(2026, 11, 1, 2, 30), // 23:30 do dia 31/10 (−3)
      );
      // 03:30Z já é −2 → 01:30 do dia 01/11 (outro dia); 02:59Z ainda é −3 → 23:59 do dia 31/10
      expect(s.isOnLocalDay(DateTime.utc(2026, 11, 1, 3, 30), verao), isFalse);
      expect(s.isOnLocalDay(DateTime.utc(2026, 11, 1, 2, 59), verao), isTrue);
    });

    test('retomar no mesmo dia: nada a gravar, a mesma sessão roda', () {
      final pausa = _t0.add(const Duration(minutes: 5));
      final volta = pausa.add(const Duration(minutes: 30));
      final r = _rodando()
          .pause(pausa)
          .resumeOnAnotherDay(volta, _saoPaulo, _id2);
      expect(r.closed, isNull);
      expect(r.next.id, _id);
      expect(r.next.isRunning, isTrue);
      expect(r.next.activeSeconds, 300);
    });

    test('retomar noutro dia: grava a de ontem até a pausa e abre outra, 0 s, com outro id', () {
      final pausa = _t0.add(const Duration(minutes: 5));
      final amanha = DateTime.utc(2026, 9, 21, 12); // 09:00 do dia 21
      final r = _rodando()
          .pause(pausa)
          .resumeOnAnotherDay(amanha, _saoPaulo, _id2);
      expect(
        r.closed,
        PaperSessionRecord(
          id: _id,
          userBookId: _livro,
          startedAt: _t0,
          endedAt: pausa,
          activeSeconds: 300,
        ),
      );
      expect(r.next.id, _id2);
      expect(r.next.userBookId, _livro);
      expect(r.next.startedAt, amanha);
      expect(r.next.activeSeconds, 0);
      expect(r.next.isRunning, isTrue);
    });

    test('retomar noutro dia com menos de 10 s: só abre a nova', () {
      final pausa = _t0.add(const Duration(seconds: 4));
      final r = _rodando()
          .pause(pausa)
          .resumeOnAnotherDay(DateTime.utc(2026, 9, 22, 12), _saoPaulo, _id2);
      expect(r.closed, isNull);
      expect(r.next.id, _id2);
    });

    test('a que já roda não é retomada (nem dividida)', () {
      final s = _rodando();
      final r = s.resumeOnAnotherDay(
        DateTime.utc(2026, 9, 22),
        _saoPaulo,
        _id2,
      );
      expect(r.closed, isNull);
      expect(r.next, s);
    });
  });

  group('guardar e ler (R8)', () {
    test('ida e volta, rodando e pausada', () {
      final rodando = _rodando(acumulado: 42);
      expect(OpenPaperSession.fromJson(rodando.toJson()), rodando);
      final pausada = rodando.pause(_t0.add(const Duration(seconds: 3)));
      expect(OpenPaperSession.fromJson(pausada.toJson()), pausada);
      expect(rodando.toJson(), {
        'v': 1,
        'id': _id,
        'book': _livro,
        'startedAt': '2026-09-20T22:51:18.000Z',
        'activeSeconds': 42,
        'runningSince': '2026-09-20T22:51:18.000Z',
        'pausedAt': null,
      });
    });

    test(
      'versão desconhecida, campos faltando ou errados: null, nunca lança',
      () {
        final ok = _rodando().toJson();
        for (final ruim in <Object?>[
          null,
          'texto',
          42,
          <String, Object?>{...ok, 'v': 2},
          <String, Object?>{...ok}..remove('book'),
          <String, Object?>{...ok, 'id': 'não é uuid'},
          <String, Object?>{...ok, 'book': ''},
          <String, Object?>{...ok, 'activeSeconds': -1},
          <String, Object?>{...ok, 'activeSeconds': 86401},
          <String, Object?>{...ok, 'activeSeconds': '42'},
          <String, Object?>{...ok, 'startedAt': 'ontem'},
          <String, Object?>{...ok, 'runningSince': 7},
        ]) {
          expect(OpenPaperSession.fromJson(ruim), isNull, reason: '$ruim');
        }
      },
    );

    test('valida na construção: ids, UTC e o limite', () {
      expect(
        () => OpenPaperSession(
          id: 'x',
          userBookId: _livro,
          startedAt: _t0,
          activeSeconds: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => OpenPaperSession(
          id: _id,
          userBookId: _livro,
          startedAt: _t0.toLocal(),
          activeSeconds: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => OpenPaperSession(
          id: _id,
          userBookId: _livro,
          startedAt: _t0,
          activeSeconds: 86401,
        ),
        throwsArgumentError,
      );
    });

    test('igualdade por valor', () {
      expect(_rodando(), _rodando());
      expect(_rodando().hashCode, _rodando().hashCode);
      expect(_rodando(), isNot(_rodando(acumulado: 1)));
      final r = _rodando().record(_t0.add(const Duration(minutes: 1)))!;
      expect(r, _rodando().record(_t0.add(const Duration(minutes: 1))));
      expect(
        r.hashCode,
        _rodando().record(_t0.add(const Duration(minutes: 1)))!.hashCode,
      );
    });
  });
}
