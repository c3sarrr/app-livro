// T04.2 — a sessão aberta do cronômetro mora no `kv` (R8): `paper_timer:<dono>`, só no aparelho, como o rascunho da
// tinta (`ink_draft:`). Ilegível ou de versão desconhecida: some e é relatada, nunca derruba a Início.
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/features/reading_session/data/paper_timer_store.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _dono = '0199a7c4-2f00-7a10-8b20-0000000000aa';
const _outro = '0199a7c4-2f00-7a10-8b20-0000000000bb';
const _livro = '01925a00-0000-7000-8000-0000000000b1';

final _t0 = DateTime.utc(2026, 9, 20, 22, 51, 18);

OpenPaperSession _sessao({
  String id = '01925a00-0000-7000-8000-000000000001',
  DateTime? inicio,
}) => OpenPaperSession.start(id: id, userBookId: _livro, now: inicio ?? _t0);

void main() {
  late AppDatabase db;
  late List<Object> relatados;
  late KvPaperTimerStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    relatados = [];
    store = KvPaperTimerStore(db, onError: (e, _) => relatados.add(e));
  });
  tearDown(() => db.close());

  test('a chave é paper_timer:<dono>', () {
    expect(paperTimerKey(_dono), 'paper_timer:$_dono');
  });

  test('ida e volta: rodando e pausada; sem sessão = null', () async {
    expect(await store.load(_dono), isNull);
    final s = _sessao();
    await store.save(_dono, s);
    expect(await store.load(_dono), s);
    final p = s.pause(_t0.add(const Duration(minutes: 8, seconds: 42)));
    await store.save(_dono, p);
    expect(await store.load(_dono), p);
    expect(
      jsonDecode((await KvDao(db).get(paperTimerKey(_dono)))!),
      p.toJson(),
    );
  });

  test('dois donos não se misturam; limpar apaga só a do dono', () async {
    final a = _sessao();
    final b = _sessao(id: '01925a00-0000-7000-8000-000000000002');
    await store.save(_dono, a);
    await store.save(_outro, b);
    expect(await store.load(_dono), a);
    expect(await store.load(_outro), b);
    await store.clear(_dono);
    expect(await store.load(_dono), isNull);
    expect(await store.load(_outro), b);
    await store.clear(_dono); // limpar o que não existe não faz nada
  });

  test('JSON ilegível ou de versão desconhecida: null, a chave sai e a falha é relatada (sem dado da pessoa)', () async {
    for (final ruim in [
      'não é json',
      '[]',
      jsonEncode({..._sessao().toJson(), 'v': 2}),
    ]) {
      await KvDao(db).set(paperTimerKey(_dono), ruim);
      expect(await store.load(_dono), isNull, reason: ruim);
      expect(await KvDao(db).get(paperTimerKey(_dono)), isNull, reason: ruim);
    }
    expect(relatados, hasLength(3));
    expect(relatados.every((e) => e is PaperTimerUnreadable), isTrue);
    expect(relatados.first.toString(), isNot(contains(_livro)));
  });

  group('adoção (entrar numa conta) e o "apagar deste aparelho"', () {
    test('a sessão do convidado passa para a conta', () async {
      final s = _sessao();
      await store.save(_outro, s);
      await db.transaction(() => adoptPaperTimer(db, from: _outro, to: _dono));
      expect(await store.load(_dono), s);
      expect(await KvDao(db).get(paperTimerKey(_outro)), isNull);
    });

    test('com as duas, fica a que começou por último', () async {
      final velha = _sessao(inicio: _t0);
      final nova = _sessao(
        id: '01925a00-0000-7000-8000-000000000002',
        inicio: _t0.add(const Duration(hours: 1)),
      );
      await store.save(_outro, nova);
      await store.save(_dono, velha);
      await adoptPaperTimer(db, from: _outro, to: _dono);
      expect(await store.load(_dono), nova);
      expect(await KvDao(db).get(paperTimerKey(_outro)), isNull);

      await store.save(_outro, velha);
      await adoptPaperTimer(db, from: _outro, to: _dono);
      expect(await store.load(_dono), nova, reason: 'a da conta é mais nova');
      expect(await KvDao(db).get(paperTimerKey(_outro)), isNull);
    });

    test(
      'a do convidado ilegível sai; a da conta ilegível perde para a legível',
      () async {
        final s = _sessao();
        await KvDao(db).set(paperTimerKey(_outro), 'lixo');
        await store.save(_dono, s);
        await adoptPaperTimer(db, from: _outro, to: _dono);
        expect(await store.load(_dono), s);
        expect(await KvDao(db).get(paperTimerKey(_outro)), isNull);

        await KvDao(db).set(paperTimerKey(_dono), 'lixo');
        await store.save(_outro, s);
        await adoptPaperTimer(db, from: _outro, to: _dono);
        expect(await store.load(_dono), s);
      },
    );

    test('sem sessão do convidado: nada muda', () async {
      final s = _sessao();
      await store.save(_dono, s);
      await adoptPaperTimer(db, from: _outro, to: _dono);
      expect(await store.load(_dono), s);
    });
  });
}
