// G21.3 — o tempo real dos clubes (D-225): avisos seguidos viram uma releitura; trocar os clubes ouvidos abre e
// fecha os canais certos; fechar não deixa canal aberto nem aviso saindo. (O relógio é o falso do `testWidgets`.)
import 'dart:async';

import 'package:app_leitura/features/clubs/data/club_pings.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canais de mentira: guarda quem está aberto e deixa o teste mandar avisos.
final class _Canais {
  final Map<String, void Function()> abertos = {};
  final List<String> fechados = [];

  /// Fechar um canal espera isto (o servidor demora a responder).
  Completer<void>? fecharDevagar;

  Future<void> Function() abrir(String topic, void Function() onPing) {
    abertos[topic] = onPing;
    return () async {
      if (fecharDevagar case final f?) await f.future;
      abertos.remove(topic);
      fechados.add(topic);
    };
  }

  void avisar(String clubId) => abertos[clubTopic(clubId)]?.call();
}

void main() {
  testWidgets('3 avisos em 1 s viram 1 releitura, 2 s depois do último', (
    t,
  ) async {
    final canais = _Canais();
    final pings = ClubPings(canais.abrir);
    addTearDown(pings.close);
    final mudou = <String>[];
    pings.changes.listen(mudou.add);
    await pings.watch({'c1'});
    expect(canais.abertos.keys, ['club:c1']);

    canais.avisar('c1');
    await t.pump(const Duration(milliseconds: 400));
    canais.avisar('c1');
    await t.pump(const Duration(milliseconds: 400));
    canais.avisar('c1');
    await t.pump(const Duration(milliseconds: 1900));
    expect(mudou, isEmpty);
    await t.pump(const Duration(milliseconds: 200));
    expect(mudou, ['c1']);

    canais.avisar('c1');
    await t.pump(const Duration(seconds: 3));
    expect(mudou, ['c1', 'c1']);
  });

  testWidgets('cada clube tem a sua espera', (t) async {
    final canais = _Canais();
    final pings = ClubPings(canais.abrir, settle: const Duration(seconds: 1));
    addTearDown(pings.close);
    final mudou = <String>[];
    pings.changes.listen(mudou.add);
    await pings.watch({'c1', 'c2'});
    canais.avisar('c1');
    canais.avisar('c2');
    await t.pump(const Duration(seconds: 2));
    expect(mudou..sort(), ['c1', 'c2']);
  });

  testWidgets(
    'trocar os clubes ouvidos: abre os novos, fecha os que saíram, mantém os que ficaram',
    (t) async {
      final canais = _Canais();
      final pings = ClubPings(canais.abrir);
      addTearDown(pings.close);
      await pings.watch({'c1', 'c2'});
      final c1 = canais.abertos['club:c1'];
      final c2 = canais.abertos['club:c2'];
      await pings.watch({'c2', 'c3'});
      expect(canais.abertos.keys.toSet(), {'club:c2', 'club:c3'});
      expect(canais.fechados, ['club:c1']);
      expect(pings.watching, {'c2', 'c3'});
      expect(
        identical(canais.abertos['club:c2'], c2),
        isTrue,
        reason: 'o canal que ficou não reabre',
      );

      // um aviso atrasado do canal fechado não sai
      final mudou = <String>[];
      pings.changes.listen(mudou.add);
      c1!();
      await t.pump(const Duration(seconds: 3));
      expect(mudou, isEmpty);
    },
  );

  testWidgets(
    'fechar: todos os canais fecham, a espera pendente não sai e nada mais abre',
    (t) async {
      final canais = _Canais();
      final pings = ClubPings(canais.abrir);
      final mudou = <String>[];
      var fim = false;
      pings.changes.listen(mudou.add, onDone: () => fim = true);
      await pings.watch({'c1', 'c2'});
      canais.avisar('c1');
      await pings.close();
      expect(canais.abertos, isEmpty);
      expect(canais.fechados.toSet(), {'club:c1', 'club:c2'});
      await t.pump(const Duration(seconds: 3));
      expect(mudou, isEmpty);
      expect(fim, isTrue);
      await pings.watch({'c3'});
      expect(canais.abertos, isEmpty);
      await pings.close();
    },
  );

  test('o tópico do clube', () {
    expect(
      clubTopic('00000000-0000-7000-8000-00000c200001'),
      'club:00000000-0000-7000-8000-00000c200001',
    );
  });

  testWidgets(
    'fechar enquanto troca os clubes: o canal novo não abre depois de fechado',
    (t) async {
      final canais = _Canais();
      final pings = ClubPings(canais.abrir);
      await pings.watch({'c1'});
      final devagar = canais.fecharDevagar = Completer<void>();
      final troca = pings.watch({
        'c2',
      }); // fecha o c1 (devagar) e depois abriria o c2
      final fim = pings.close();
      devagar.complete();
      await troca;
      await fim;
      expect(canais.abertos, isEmpty);
    },
  );
}
