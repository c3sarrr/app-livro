// G03.1 — relógio lógico híbrido (Anexo 02 §3.4; ADR-003: `receive` da versão lida antes do `send`).
import 'dart:math';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final referenciaMs = DateTime.utc(2026, 9, 20, 23).millisecondsSinceEpoch;
  // Mesma regra da RPC `sync_apply_changes` (handoff_v2/sql/01_schema_booknest.sql §8.1).
  final formatoDoServidor = RegExp(r'^[0-9]{16}-[0-9]{4}-[A-Za-z0-9_-]{1,64}$');

  group('Hlc (valor)', () {
    test(
      'texto ordenável "<ms 16 dígitos>-<contador 4 dígitos>-<aparelho>"',
      () {
        final h = Hlc(referenciaMs, 7, 'a1B2-c_3');
        expect(h.toString(), '000${referenciaMs.toString()}-0007-a1B2-c_3');
        expect(h.toString(), matches(formatoDoServidor));
        expect(Hlc.parse(h.toString()), h);
        expect(Hlc.parse(h.toString()).hashCode, h.hashCode);
      },
    );

    test('aparelho com UUID (hífens) é aceito; com espaço, acento ou vazio é recusado', () {
      expect(
        Hlc(1, 0, '0192f6c1-8a00-7b3c-8d2e-1f0a9b8c7d6e').deviceId,
        hasLength(36),
      );
      for (final ruim in ['', 'meu celular', 'aparelhoÁ', 'a' * 65, 'a/b']) {
        expect(() => Hlc(1, 0, ruim), throwsArgumentError, reason: ruim);
      }
      expect(() => Hlc(-1, 0, 'a'), throwsArgumentError);
      expect(() => Hlc(1, 10000, 'a'), throwsArgumentError);
      expect(() => Hlc(10000000000000000, 0, 'a'), throwsArgumentError);
    });

    test('parse recusa texto fora do formato', () {
      for (final ruim in [
        '',
        '1790000000000-0000-a', // ms sem os 16 dígitos
        '0001790000000000-000-a',
        '0001790000000000-0000-',
        '0001790000000000-0000-a b',
        '0001790000000000_0000_a',
      ]) {
        expect(() => Hlc.parse(ruim), throwsFormatException, reason: ruim);
        expect(Hlc.tryParse(ruim), isNull, reason: ruim);
      }
    });

    test('a ordem do texto (byte a byte, COLLATE "C") é a mesma de (ms, contador, aparelho)', () {
      final rnd = Random(42);
      const aparelhos = ['A', 'B', 'a', 'b', 'b-1', 'b_1', '0', 'Z9'];
      final hs = [
        for (var i = 0; i < 3000; i++)
          Hlc(
            referenciaMs + rnd.nextInt(5),
            rnd.nextInt(3),
            aparelhos[rnd.nextInt(aparelhos.length)],
          ),
      ];
      final porValor = [...hs]..sort();
      final porTexto = [...hs]
        ..sort((a, b) => a.toString().compareTo(b.toString()));
      expect(
        porValor.map((h) => h.toString()),
        porTexto.map((h) => h.toString()),
      );
      final a = Hlc(5, 1, 'A');
      final b = Hlc(5, 2, 'A');
      expect(a < b && b > a && a <= a && a >= a && !(a > b), isTrue);
    });
  });

  group('HlcClock', () {
    test('send: mesmo milissegundo soma o contador; relógio andando zera', () {
      var agora = referenciaMs;
      final r = HlcClock(deviceId: 'A', nowMs: () => agora);
      expect(r.send().toString(), Hlc(referenciaMs, 0, 'A').toString());
      expect(r.send(), Hlc(referenciaMs, 1, 'A'));
      agora += 5;
      expect(r.send(), Hlc(referenciaMs + 5, 0, 'A'));
      expect(r.last, Hlc(referenciaMs + 5, 0, 'A'));
    });

    test('send: relógio que volta não faz o HLC voltar', () {
      var agora = referenciaMs;
      final r = HlcClock(deviceId: 'A', nowMs: () => agora);
      final a = r.send();
      agora -= 60000;
      final b = r.send();
      expect(b > a, isTrue);
      expect(b.ms, referenciaMs);
    });

    test('contador no limite (9999) passa para o milissegundo seguinte', () {
      final r = HlcClock(
        deviceId: 'A',
        nowMs: () => referenciaMs,
        last: Hlc(referenciaMs, 9999, 'A'),
      );
      expect(r.send(), Hlc(referenciaMs + 1, 0, 'A'));
    });

    test('receive de um HLC à frente: o próximo send fica depois dele', () {
      final r = HlcClock(deviceId: 'A', nowMs: () => referenciaMs);
      final remoto = Hlc(referenciaMs + 120000, 3, 'B');
      r.receive(remoto);
      final h = r.send();
      expect(h > remoto, isTrue);
      expect(h, Hlc(referenciaMs + 120000, 4, 'A'));
    });

    test('receive de um HLC atrasado não faz o relógio voltar', () {
      final r = HlcClock(deviceId: 'A', nowMs: () => referenciaMs);
      final a = r.send();
      r.receive(Hlc(referenciaMs - 300000, 50, 'B'));
      expect(r.last, a);
      expect(r.send(), Hlc(referenciaMs, 1, 'A'));
    });

    test('mesmo milissegundo e mesmo contador de outro aparelho: o send ainda vence', () {
      final r = HlcClock(deviceId: 'A', nowMs: () => referenciaMs);
      r.send(); // (ms, 0, A)
      final remoto = Hlc(referenciaMs, 0, 'Z'); // 'Z' > 'A' no desempate
      final h = r.sendAfterReading([remoto.toString()]);
      expect(h > remoto, isTrue);
    });

    test('sendAfterReading: recebe todas as versões lidas (ignora nulas) antes do send', () {
      final r = HlcClock(deviceId: 'A', nowMs: () => referenciaMs);
      final lidas = [
        Hlc(referenciaMs + 10, 2, 'B').toString(),
        null,
        Hlc(referenciaMs + 300000, 0, 'C').toString(),
      ];
      final h = r.sendAfterReading(lidas);
      for (final v in lidas.nonNulls) {
        expect(h > Hlc.parse(v), isTrue, reason: v);
      }
      expect(() => r.sendAfterReading(['lixo']), throwsFormatException);
    });

    test('retoma do último HLC salvo mesmo com o relógio 1 h atrasado', () {
      final salvo = Hlc(referenciaMs + 3600000, 7, 'A');
      final r = HlcClock(deviceId: 'A', nowMs: () => referenciaMs, last: salvo);
      expect(r.send() > salvo, isTrue);
    });

    test('avisa cada avanço (para persistir o último HLC no kv)', () {
      final avisos = <Hlc>[];
      final r = HlcClock(
        deviceId: 'A',
        nowMs: () => referenciaMs,
        onAdvance: avisos.add,
      );
      final a = r.send();
      r.receive(
        Hlc(referenciaMs - 1, 0, 'B'),
      ); // atrasado: não avança, não avisa
      r.receive(Hlc(referenciaMs + 1, 0, 'B'));
      final c = r.send();
      expect(avisos, [a, Hlc(referenciaMs + 1, 0, 'B'), c]);
    });

    test('aparelho inválido é recusado na criação do relógio', () {
      expect(() => HlcClock(deviceId: 'meu celular'), throwsArgumentError);
    });

    test('o relógio padrão usa a hora do sistema', () {
      final antes = DateTime.now().millisecondsSinceEpoch;
      final h = HlcClock(deviceId: 'A').send();
      expect(h.ms, greaterThanOrEqualTo(antes));
      expect(h.toString(), matches(formatoDoServidor));
    });
  });

  group(
    'simulação: 10 mil eventos em 3 aparelhos com relógios defasados ±5 min',
    () {
      const aparelhos = ['aparelhoA', 'aparelhoB', 'aparelhoC'];
      const defasagens = {
        'aparelhoA': -300000,
        'aparelhoB': 0,
        'aparelhoC': 300000,
      };

      test('ordem total estável, monotônica por aparelho e respeitando o que cada um recebeu', () {
        final rnd = Random(20260920);
        var real = referenciaMs;
        final relogios = {
          for (final a in aparelhos)
            a: HlcClock(deviceId: a, nowMs: () => real + defasagens[a]!),
        };
        final caixas = {for (final a in aparelhos) a: <Hlc>[]};
        final maiorRecebido = <String, Hlc>{};
        final porAparelho = {for (final a in aparelhos) a: <Hlc>[]};
        final todos = <Hlc>[];
        final falhas = <String>[];

        for (var i = 0; i < 10000; i++) {
          real += rnd.nextInt(40);
          final a = aparelhos[rnd.nextInt(3)];
          final relogio = relogios[a]!;
          if (rnd.nextInt(4) == 0) {
            // sincronizou: recebe tudo o que os outros publicaram desde a última vez
            for (final m in caixas[a]!) {
              relogio.receive(m);
              final atual = maiorRecebido[a];
              if (atual == null || m > atual) maiorRecebido[a] = m;
            }
            caixas[a]!.clear();
          }
          final e = relogio.send();
          final recebido = maiorRecebido[a];
          if (recebido != null && !(e > recebido)) falhas.add('causalidade $i');
          if (porAparelho[a]!.isNotEmpty && !(e > porAparelho[a]!.last)) {
            falhas.add('monotonia $i');
          }
          if (e.ms > real + 300000) {
            falhas.add('futuro demais $i'); // a RPC recusaria
          }
          if (!formatoDoServidor.hasMatch(e.toString())) {
            falhas.add('formato $i');
          }
          porAparelho[a]!.add(e);
          todos.add(e);
          for (final outro in aparelhos) {
            if (outro != a) caixas[outro]!.add(e);
          }
        }

        expect(falhas, isEmpty);
        expect(todos, hasLength(10000));
        expect(todos.map((h) => h.toString()).toSet(), hasLength(10000));
        final porValor = [...todos]..sort();
        final porTexto = [...todos]
          ..sort((x, y) => x.toString().compareTo(y.toString()));
        expect(porValor, porTexto);
        for (final a in aparelhos) {
          expect(porAparelho[a]!.length, greaterThan(3000), reason: a);
        }
      });

      int editarLinha({required bool comRegra}) {
        final rnd = Random(7);
        var real = referenciaMs;
        final relogios = {
          for (final a in aparelhos)
            a: HlcClock(deviceId: a, nowMs: () => real + defasagens[a]!),
        };
        var versaoNoServidor = Hlc(0, 0, 'servidor');
        var perdidas = 0;
        for (var i = 0; i < 3000; i++) {
          real += rnd.nextInt(40);
          final relogio = relogios[aparelhos[rnd.nextInt(3)]]!;
          // o aparelho está sincronizado: lê a versão atual da linha antes de editar
          final lida = versaoNoServidor.toString();
          final nova = comRegra
              ? relogio.sendAfterReading([lida])
              : relogio.send();
          if (nova > versaoNoServidor) {
            versaoNoServidor = nova; // last-writer-wins da RPC
          } else {
            perdidas++; // a edição mais recente perdeu para uma versão anterior
          }
        }
        return perdidas;
      }

      test(
        'com a regra receive-antes-de-send, nenhuma edição se perde no LWW',
        () {
          expect(editarLinha(comRegra: true), 0);
        },
      );

      test(
        'controle negativo: sem a regra, o aparelho atrasado perde edições',
        () {
          expect(editarLinha(comRegra: false), greaterThan(500));
        },
      );
    },
  );
}
