// T04.4 — o controlador da sessão do cronômetro (spec docs/progresso/T04.md §2): carrega a sessão do dono ao abrir o
// app (acertada pelo relógio; a de livro apagado sai), começa (uma por vez — D-262), pausa, retoma (outro dia divide —
// R4), encerra (o writer grava) e descarta; a abertura do leitor pausa (D-263).
import 'dart:async';

import 'package:app_leitura/features/home/application/home_providers.dart'
    show clockProvider;
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/reading_session/application/paper_timer_controller.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:app_leitura/features/reading_session/domain/paper_timer_failure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/paper_timer_fakes.dart';

const _bras = '01925a00-0000-7000-8000-0000000000b1';
const _orgulho = '01925a00-0000-7000-8000-0000000000b2';

const _livroBras = PaperBook(
  book: Book(
    id: _bras,
    title: 'Memórias Póstumas de Brás Cubas',
    author: 'Machado de Assis',
    cover: PhotoCover(),
  ),
  pagesTotal: 368,
  lastPage: 96,
);

const _livroOrgulho = PaperBook(
  book: Book(
    id: _orgulho,
    title: 'Orgulho e Preconceito',
    author: 'Jane Austen',
    cover: PhotoCover(),
  ),
);

/// 20/09/2026 19:51:18 em São Paulo.
final _t0 = DateTime.utc(2026, 9, 20, 22, 51, 18);

void main() {
  late DateTime agora;
  late MemoryPaperTimerStore store;
  late RecordingPaperSessionWriter writer;
  late StreamController<String> donos;

  setUp(() {
    agora = _t0;
    store = MemoryPaperTimerStore();
    writer = RecordingPaperSessionWriter();
    donos = StreamController<String>();
  });
  // sem ouvinte, o futuro do close() nunca completa: fecha sem esperar
  tearDown(() => unawaited(donos.close()));

  ProviderContainer abrir({String dono = donoDaSessao, bool donoFixo = true}) {
    final c = ProviderContainer.test(
      overrides: [
        clockProvider.overrideWithValue(() => agora),
        ...overridesDaSessao(
          store: store,
          writer: writer,
          livros: FixedPaperBookSource({
            _bras: _livroBras,
            _orgulho: _livroOrgulho,
          }),
          dono: dono,
          donos: donoFixo ? null : donos.stream,
        ),
      ],
    );
    // no Riverpod 3 um provedor só lido (sem ouvinte) fica pausado: na tela, a mini-barra assiste
    final sub = c.listen(paperTimerProvider, (_, _) {});
    addTearDown(sub.close);
    return c;
  }

  Future<PaperTimerState> estado(ProviderContainer c) =>
      c.read(paperTimerProvider.future);

  PaperTimerController ctl(ProviderContainer c) =>
      c.read(paperTimerProvider.notifier);

  test('sem sessão guardada: nenhuma', () async {
    final c = abrir();
    expect(await estado(c), const PaperTimerState());
    expect((await estado(c)).session, isNull);
  });

  test('começar: grava no kv e o estado tem a sessão e o livro', () async {
    final c = abrir();
    await estado(c);
    await ctl(c).start(_bras);
    final s = (await estado(c)).session!;
    expect(s.userBookId, _bras);
    expect(s.isRunning, isTrue);
    expect(s.startedAt, _t0);
    expect(s.id, '01925a00-0000-7000-8000-000000000001');
    expect((await estado(c)).book, _livroBras);
    expect(store.sessoes[donoDaSessao], s);
  });

  test('com outra aberta, começar é recusado e nada muda (D-262)', () async {
    final c = abrir();
    await estado(c);
    await ctl(c).start(_bras);
    final antes = await estado(c);
    await expectLater(
      ctl(c).start(_orgulho),
      throwsA(isA<PaperSessionAlreadyOpen>()),
    );
    expect(await estado(c), antes);
  });

  test('livro que não está na estante: PaperBookGone, nada começa', () async {
    final c = abrir();
    await estado(c);
    await expectLater(
      ctl(c).start('01925a00-0000-7000-8000-0000000000ff'),
      throwsA(isA<PaperBookGone>()),
    );
    expect((await estado(c)).session, isNull);
    expect(store.sessoes, isEmpty);
  });

  test('pausar, retomar e alternar; a pausada não anda', () async {
    final c = abrir();
    await estado(c);
    await ctl(c).start(_bras);
    agora = _t0.add(const Duration(minutes: 8, seconds: 42));
    await ctl(c).pause();
    var s = (await estado(c)).session!;
    expect(s.isRunning, isFalse);
    expect(s.activeSeconds, 522);
    expect(store.sessoes[donoDaSessao], s);

    agora = agora.add(const Duration(minutes: 10));
    await ctl(c).pause(); // pausada: nada
    expect((await estado(c)).session, s);
    await ctl(c).toggle();
    s = (await estado(c)).session!;
    expect(s.isRunning, isTrue);
    expect(s.runningSince, agora);
    expect(s.activeSeconds, 522);

    agora = agora.add(const Duration(seconds: 30));
    await ctl(c).toggle();
    expect((await estado(c)).session!.activeSeconds, 552);
    await ctl(c).resume();
    expect((await estado(c)).session!.isRunning, isTrue);
    await ctl(c).resume(); // rodando: nada
    expect((await estado(c)).session!.isRunning, isTrue);
  });

  test('retomar noutro dia: o writer grava a de ontem (só a sessão) e roda uma nova (R4)', () async {
    final c = abrir();
    await estado(c);
    await ctl(c).start(_bras);
    agora = _t0.add(const Duration(minutes: 5));
    await ctl(c).pause();
    agora = DateTime.utc(2026, 9, 21, 12); // 09:00 do dia seguinte
    await ctl(c).resume();
    expect(writer.divisoes, [
      PaperSessionRecord(
        id: '01925a00-0000-7000-8000-000000000001',
        userBookId: _bras,
        startedAt: _t0,
        endedAt: _t0.add(const Duration(minutes: 5)),
        activeSeconds: 300,
      ),
    ]);
    final s = (await estado(c)).session!;
    expect(s.id, '01925a00-0000-7000-8000-000000000002');
    expect(s.startedAt, agora);
    expect(s.activeSeconds, 0);
    expect(s.isRunning, isTrue);
  });

  test('encerrar: o writer recebe o registro, a página e o total; o kv e o estado esvaziam', () async {
    final c = abrir();
    await estado(c);
    await ctl(c).start(_bras);
    agora = _t0.add(const Duration(minutes: 8, seconds: 42));
    await ctl(c).end(page: 120, pagesTotal: 368);
    expect(writer.fins.single.userBookId, _bras);
    expect(writer.fins.single.record!.activeSeconds, 522);
    expect(writer.fins.single.at, agora);
    expect(writer.fins.single.page, 120);
    expect(writer.fins.single.pagesTotal, 368);
    expect(store.sessoes, isEmpty);
    expect((await estado(c)).session, isNull);
  });

  test('encerrar com menos de 10 s: o registro vai nulo (o writer decide o que gravar — R3)', () async {
    final c = abrir();
    await estado(c);
    await ctl(c).start(_bras);
    agora = _t0.add(const Duration(seconds: 4));
    await ctl(c).end();
    expect(writer.fins.single.record, isNull);
    expect(store.sessoes, isEmpty);
  });

  test(
    'encerrar com a página recusada: o erro volta e a sessão continua aberta',
    () async {
      final c = abrir();
      await estado(c);
      await ctl(c).start(_bras);
      writer.falha = ArgumentError.value(400, 'page');
      await expectLater(ctl(c).end(page: 400), throwsArgumentError);
      expect((await estado(c)).session, isNotNull);
      expect(store.sessoes, isNotEmpty);
    },
  );

  test('encerrar com o livro apagado: a sessão sai (não tem onde gravar) e a falha volta', () async {
    final c = abrir();
    await estado(c);
    await ctl(c).start(_bras);
    writer.falha = const PaperBookGone();
    await expectLater(ctl(c).end(), throwsA(isA<PaperBookGone>()));
    expect((await estado(c)).session, isNull);
    expect(store.sessoes, isEmpty);
  });

  test('descartar: nada gravado, o kv e o estado esvaziam', () async {
    final c = abrir();
    await estado(c);
    await ctl(c).start(_bras);
    agora = _t0.add(const Duration(minutes: 30));
    await ctl(c).discard();
    expect(writer.fins, isEmpty);
    expect(store.sessoes, isEmpty);
    expect((await estado(c)).session, isNull);
  });

  test(
    'abrir o leitor pausa a que roda; a pausada fica como está (D-263)',
    () async {
      final c = abrir();
      await estado(c);
      await ctl(c).pauseForReader(); // sem sessão: nada
      await ctl(c).start(_bras);
      agora = _t0.add(const Duration(minutes: 2));
      await ctl(c).pauseForReader();
      final s = (await estado(c)).session!;
      expect(s.isRunning, isFalse);
      expect(s.activeSeconds, 120);
      agora = agora.add(const Duration(minutes: 1));
      await ctl(c).pauseForReader();
      expect((await estado(c)).session, s);
    },
  );

  test(
    'o app reabre: a sessão rodando continua pelo relógio de parede',
    () async {
      store.sessoes[donoDaSessao] = OpenPaperSession.start(
        id: '01925a00-0000-7000-8000-000000000009',
        userBookId: _bras,
        now: _t0,
      );
      agora = _t0.add(const Duration(hours: 1, minutes: 8, seconds: 42));
      final c = abrir();
      final s = (await estado(c)).session!;
      expect(s.isRunning, isTrue);
      expect(s.elapsedAt(agora), 4122);
      expect((await estado(c)).book, _livroBras);
    },
  );

  test(
    'o app reabre 25 h depois: pausada no limite de 24 h (e gravada assim)',
    () async {
      store.sessoes[donoDaSessao] = OpenPaperSession.start(
        id: '01925a00-0000-7000-8000-000000000009',
        userBookId: _bras,
        now: _t0,
      );
      agora = _t0.add(const Duration(hours: 25));
      final c = abrir();
      final s = (await estado(c)).session!;
      expect(s.isRunning, isFalse);
      expect(s.activeSeconds, 86400);
      expect(store.sessoes[donoDaSessao], s);
    },
  );

  test(
    'a sessão de um livro que saiu da estante é descartada ao carregar (R8)',
    () async {
      store.sessoes[donoDaSessao] = OpenPaperSession.start(
        id: '01925a00-0000-7000-8000-000000000009',
        userBookId: '01925a00-0000-7000-8000-0000000000ff',
        now: _t0,
      );
      final c = abrir();
      expect((await estado(c)).session, isNull);
      expect(store.sessoes, isEmpty);
    },
  );

  test('outro dono entra (a conta): recarrega a sessão dele', () async {
    const conta = '0199a7c4-2f00-7a10-8b20-0000000000aa';
    store.sessoes[donoDaSessao] = OpenPaperSession.start(
      id: '01925a00-0000-7000-8000-000000000009',
      userBookId: _bras,
      now: _t0,
    );
    final c = abrir(donoFixo: false);
    donos.add(donoDaSessao);
    expect((await estado(c)).session, isNotNull);
    donos.add(conta);
    await pumpEventQueue();
    // a estante fixa só conhece os livros do dono do teste: a conta não tem sessão
    expect((await estado(c)).session, isNull);
  });

  group('D-264 a troca de dono', () {
    const conta = '0199a7c4-2f00-7a10-8b20-0000000000aa';

    test('a sessão do dono que sai (sair da conta) pausa no instante da troca; ao voltar, está em pausa com o tempo até '
        'ali — as 8 h fora não contam', () async {
      final c = abrir(donoFixo: false);
      donos.add(donoDaSessao);
      await estado(c);
      await ctl(c).start(_bras);
      agora = _t0.add(const Duration(minutes: 5));
      donos.add(conta);
      await pumpEventQueue();
      expect((await estado(c)).session, isNull);
      final saiu = store.sessoes[donoDaSessao]!;
      expect(saiu.isRunning, isFalse);
      expect(saiu.activeSeconds, 300);
      expect(saiu.pausedAt, agora);
      expect(store.sessoes.containsKey(conta), isFalse);

      agora = agora.add(const Duration(hours: 8));
      donos.add(donoDaSessao);
      await pumpEventQueue();
      final volta = (await estado(c)).session!;
      expect(volta.isRunning, isFalse);
      expect(volta.elapsedAt(agora), 300);
    });

    test('a pausada do dono que sai fica como estava', () async {
      final pausada = OpenPaperSession.start(
        id: '01925a00-0000-7000-8000-000000000009',
        userBookId: _bras,
        now: _t0,
      ).pause(_t0.add(const Duration(minutes: 1)));
      store.sessoes[donoDaSessao] = pausada;
      final c = abrir(donoFixo: false);
      donos.add(donoDaSessao);
      await estado(c);
      final gravacoes = store.gravacoes;
      agora = _t0.add(const Duration(hours: 2));
      donos.add(conta);
      await pumpEventQueue();
      expect(store.sessoes[donoDaSessao], pausada);
      expect(store.gravacoes, gravacoes);
    });

    test('sem sessão do dono que sai (a adoção já a passou para a conta), nada é criado para ele e a do dono novo '
        'continua rodando', () async {
      final c = abrir(donoFixo: false);
      donos.add(conta);
      await estado(c);
      // a adoção passou a sessão rodando do convidado (a conta, aqui) para o dono do teste antes da troca
      final rodando = OpenPaperSession.start(
        id: '01925a00-0000-7000-8000-00000000000a',
        userBookId: _bras,
        now: _t0,
      );
      store.sessoes[donoDaSessao] = rodando;
      agora = _t0.add(const Duration(minutes: 3));
      donos.add(donoDaSessao);
      await pumpEventQueue();
      expect(store.sessoes.containsKey(conta), isFalse);
      expect((await estado(c)).session, rodando);
      expect(store.sessoes[donoDaSessao], rodando);
    });
  });

  test('D-264 o kv fora do ar ao pausar a de quem sai: a falha vai ao relatório e a troca segue (o dono novo carrega)', () async {
    const conta = '0199a7c4-2f00-7a10-8b20-0000000000aa';
    final relatos = <FlutterErrorDetails>[];
    final antes = FlutterError.onError;
    FlutterError.onError = relatos.add;
    addTearDown(() => FlutterError.onError = antes);
    final banco = LojaQueFalha(store);
    final c = ProviderContainer.test(
      overrides: [
        clockProvider.overrideWithValue(() => agora),
        ...overridesDaSessao(
          store: banco,
          writer: writer,
          livros: FixedPaperBookSource({_bras: _livroBras}),
          donos: donos.stream,
        ),
      ],
    );
    final sub = c.listen(paperTimerProvider, (_, _) {});
    addTearDown(sub.close);
    donos.add(donoDaSessao);
    await estado(c);
    await ctl(c).start(_bras);
    banco.falharAoGravar = true;
    agora = _t0.add(const Duration(minutes: 5));
    donos.add(conta);
    await pumpEventQueue();
    expect((await estado(c)).session, isNull);
    expect(relatos.single.exception, isA<StateError>());
    expect(relatos.single.library, 'cronômetro');
    expect(
      store.sessoes[donoDaSessao]!.isRunning,
      isTrue,
      reason: 'nada gravado',
    );
  });

  group('D-265 as que perderam na adoção', () {
    OpenPaperSession perdeu(int n, int segundos) => OpenPaperSession.start(
      id: '01925a00-0000-7000-8000-0000000000f$n',
      userBookId: _bras,
      now: _t0,
    ).pause(_t0.add(Duration(seconds: segundos)));

    test('ao carregar, são gravadas sem página até a pausa (menos de 10 s não) e saem da espera', () async {
      store.fechadas[donoDaSessao] = [perdeu(1, 300), perdeu(2, 5)];
      final c = abrir();
      await estado(c);
      expect(writer.divisoes, [
        PaperSessionRecord(
          id: '01925a00-0000-7000-8000-0000000000f1',
          userBookId: _bras,
          startedAt: _t0,
          endedAt: _t0.add(const Duration(seconds: 300)),
          activeSeconds: 300,
        ),
      ]);
      expect(store.fechadas[donoDaSessao], isNull);
    });

    test(
      'o livro que saiu da estante leva a sua (nada gravado, sai da espera)',
      () async {
        store.fechadas[donoDaSessao] = [perdeu(1, 300)];
        writer.falha = livroSumiu;
        final c = abrir();
        await estado(c);
        expect(writer.divisoes, isEmpty);
        expect(store.fechadas[donoDaSessao], isNull);
      },
    );

    test('outra falha vai ao relatório, elas esperam a próxima abertura e a sessão aberta carrega igual', () async {
      final relatos = <FlutterErrorDetails>[];
      final antes = FlutterError.onError;
      FlutterError.onError = relatos.add;
      addTearDown(() => FlutterError.onError = antes);
      store.fechadas[donoDaSessao] = [perdeu(1, 300)];
      store.sessoes[donoDaSessao] = OpenPaperSession.start(
        id: '01925a00-0000-7000-8000-000000000009',
        userBookId: _bras,
        now: _t0,
      );
      writer.falha = StateError('banco fora do ar');
      final c = abrir();
      expect((await estado(c)).session, isNotNull);
      expect(relatos.single.exception, isA<StateError>());
      expect(relatos.single.library, 'cronômetro');
      expect(store.fechadas[donoDaSessao], hasLength(1));
    });
  });

  group('R2 com o app aberto (o tique da mini-barra)', () {
    OpenPaperSession quase24h() => OpenPaperSession(
      id: '01925a00-0000-7000-8000-000000000009',
      userBookId: _bras,
      startedAt: _t0.subtract(const Duration(days: 1)),
      activeSeconds: 86000,
      runningSince: _t0,
    );

    test('nas 24 h a sessão pausa sozinha no instante do limite — o estado na hora, o kv na fila', () async {
      store.sessoes[donoDaSessao] = quase24h();
      final c = abrir();
      await estado(c);
      agora = _t0.add(const Duration(seconds: 401));
      ctl(c).tick();
      final s = c.read(paperTimerProvider).value!.session!;
      expect(s.isRunning, isFalse);
      expect(s.activeSeconds, 86400);
      expect(s.pausedAt, _t0.add(const Duration(seconds: 400)));
      await pumpEventQueue();
      expect(store.sessoes[donoDaSessao], s);
    });

    test('o relógio que volta um pouco (30 s) com o app aberto não desconta: o que contou até o último tique fica', () async {
      final c = abrir();
      await estado(c);
      await ctl(c).start(_bras);
      agora = _t0.add(const Duration(seconds: 522));
      ctl(c).tick();
      final gravacoes = store.gravacoes;
      expect(
        c.read(paperTimerProvider).value!.session!.runningSince,
        _t0,
        reason: 'o tique só anota',
      );
      agora = _t0.add(const Duration(seconds: 492));
      ctl(c).tick();
      final s = c.read(paperTimerProvider).value!.session!;
      expect(s.activeSeconds, 522);
      expect(s.runningSince, agora);
      expect(s.elapsedAt(agora.add(const Duration(seconds: 10))), 532);
      await pumpEventQueue();
      expect(store.gravacoes, gravacoes + 1);
      expect(store.sessoes[donoDaSessao], s);
    });

    test('pausar e encerrar logo depois do relógio voltar (antes do próximo tique) também não descontam', () async {
      final c = abrir();
      await estado(c);
      await ctl(c).start(_bras);
      agora = _t0.add(const Duration(seconds: 522));
      ctl(c).tick();
      agora = _t0.add(const Duration(seconds: 492));
      await ctl(c).pause();
      expect((await estado(c)).session!.activeSeconds, 522);
      await ctl(c).resume();
      agora = agora.add(const Duration(seconds: 100));
      ctl(c).tick();
      agora = agora.subtract(const Duration(seconds: 50));
      await ctl(c).end();
      expect(writer.fins.single.record!.activeSeconds, 622);
    });

    test('sem nada a acertar, o tique não muda o estado nem o kv; a pausada e sem sessão, nada', () async {
      final c = abrir();
      await estado(c);
      ctl(c).tick();
      await ctl(c).start(_bras);
      final antes = c.read(paperTimerProvider).value;
      final gravacoes = store.gravacoes;
      agora = _t0.add(const Duration(minutes: 1));
      ctl(c).tick();
      expect(identical(c.read(paperTimerProvider).value, antes), isTrue);
      await ctl(c).pause();
      final pausada = c.read(paperTimerProvider).value;
      ctl(c).tick();
      await pumpEventQueue();
      expect(identical(c.read(paperTimerProvider).value, pausada), isTrue);
      expect(store.gravacoes, gravacoes + 1, reason: 'só a pausa gravou');
    });

    test('o app sai da frente: a marca vai ao kv — o relógio que volta com o app fechado não desconta', () async {
      final c = abrir();
      await estado(c);
      await ctl(c).start(_bras);
      agora = _t0.add(const Duration(seconds: 60));
      ctl(c).appHidden();
      await pumpEventQueue();
      expect(store.sessoes[donoDaSessao]!.seenAt, agora);
      // o app reabre com o relógio 30 s para trás
      agora = _t0.add(const Duration(seconds: 30));
      final outro = abrir();
      final s = (await estado(outro)).session!;
      expect(s.elapsedAt(agora), 60);
      expect(s.runningSince, agora);
      // pausada, sair da frente não grava nada
      await ctl(outro).pause();
      final gravacoes = store.gravacoes;
      ctl(outro).appHidden();
      await pumpEventQueue();
      expect(store.gravacoes, gravacoes);
    });
  });

  group('retomar noutro dia — a fiação', () {
    test('o dia é o local (o fuso do provedor): pausa às 20:05 e volta às 22:30 do mesmo dia em São Paulo — o dia UTC '
        'mudou, mas nada divide', () async {
      final c = abrir();
      await estado(c);
      agora = DateTime.utc(2026, 9, 20, 23); // 20:00 em São Paulo
      await ctl(c).start(_bras);
      agora = DateTime.utc(2026, 9, 20, 23, 5); // 20:05
      await ctl(c).pause();
      agora = DateTime.utc(
        2026,
        9,
        21,
        1,
        30,
      ); // 22:30 do mesmo dia local; 21/09 em UTC
      await ctl(c).resume();
      expect(writer.divisoes, isEmpty);
      final s = (await estado(c)).session!;
      expect(s.id, '01925a00-0000-7000-8000-000000000001');
      expect(s.activeSeconds, 300);
      expect(s.isRunning, isTrue);
    });

    test('noutro dia com o livro apagado: a sessão sai e nada roda', () async {
      final c = abrir();
      await estado(c);
      await ctl(c).start(_bras);
      agora = _t0.add(const Duration(minutes: 5));
      await ctl(c).pause();
      agora = DateTime.utc(2026, 9, 21, 12);
      writer.falha = livroSumiu;
      await ctl(c).resume();
      expect((await estado(c)).session, isNull);
      expect(store.sessoes, isEmpty);
    });

    test('noutro dia com outra falha: ela volta e a sessão continua pausada como estava', () async {
      final c = abrir();
      await estado(c);
      await ctl(c).start(_bras);
      agora = _t0.add(const Duration(minutes: 5));
      await ctl(c).pause();
      final pausada = (await estado(c)).session;
      agora = DateTime.utc(2026, 9, 21, 12);
      writer.falha = StateError('banco fora do ar');
      await expectLater(ctl(c).resume(), throwsStateError);
      expect((await estado(c)).session, pausada);
      expect(store.sessoes[donoDaSessao], pausada);
    });
  });

  test('as mudanças ficam em ordem mesmo com toques seguidos (cada uma vê a anterior)', () async {
    final c = abrir();
    await estado(c);
    await Future.wait([
      ctl(c).start(_bras),
      ctl(c).pause(),
      ctl(c).resume(),
      ctl(c).pause(),
    ]);
    final s = (await estado(c)).session!;
    expect(s.isRunning, isFalse);
    expect(store.sessoes[donoDaSessao], s);
  });
}
