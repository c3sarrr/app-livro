// G03.1 — UUIDv7 gerado no aparelho (Anexo 02 §1.6 e §3.4; RFC 9562 §5.7 e §6.2).
import 'dart:math';

import 'package:app_leitura/core/data/ids/uuid_v7.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Domingo 20/09/2026 20:00 em São Paulo (D-09) = 23:00 UTC.
  final referenciaMs = DateTime.utc(2026, 9, 20, 23).millisecondsSinceEpoch;

  group('formato', () {
    test('8-4-4-4-12 em hexadecimal minúsculo, versão 7 e variante RFC', () {
      final gerador = UuidV7Generator(clockMs: () => referenciaMs);
      for (var i = 0; i < 1000; i++) {
        final id = gerador.next();
        expect(
          id,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            ),
          ),
        );
        expect(UuidV7.isValid(id), isTrue);
      }
    });

    test('os 48 bits iniciais são o instante em milissegundos', () {
      final gerador = UuidV7Generator(clockMs: () => referenciaMs);
      final id = gerador.next();
      expect(UuidV7.timestampMs(id), referenciaMs);
      expect(
        id.substring(0, 8),
        referenciaMs.toRadixString(16).padLeft(12, '0').substring(0, 8),
      );
    });

    test('recusa o que não é UUIDv7', () {
      for (final ruim in [
        '',
        '0192f6c1-8a00-4b3c-8d2e-1f0a9b8c7d6e', // versão 4
        '0192f6c1-8a00-7b3c-cd2e-1f0a9b8c7d6e', // variante errada
        '0192F6C1-8A00-7B3C-8D2E-1F0A9B8C7D6E', // maiúsculas
        '0192f6c18a007b3c8d2e1f0a9b8c7d6e', // sem hífens
        '0192f6c1-8a00-7b3c-8d2e-1f0a9b8c7d6', // curto
      ]) {
        expect(UuidV7.isValid(ruim), isFalse, reason: ruim);
        expect(
          () => UuidV7.timestampMs(ruim),
          throwsFormatException,
          reason: ruim,
        );
      }
    });
  });

  group('ordem', () {
    test(
      '10 mil ids no mesmo milissegundo saem únicos e em ordem crescente',
      () {
        final gerador = UuidV7Generator(clockMs: () => referenciaMs);
        final ids = [for (var i = 0; i < 10000; i++) gerador.next()];
        expect(ids.toSet(), hasLength(ids.length));
        for (var i = 1; i < ids.length; i++) {
          expect(
            ids[i].compareTo(ids[i - 1]),
            greaterThan(0),
            reason: 'posição $i',
          );
        }
      },
    );

    test('estouro do contador de 12 bits avança o instante em 1 ms (sem repetir nem voltar)', () {
      final gerador = UuidV7Generator(clockMs: () => referenciaMs);
      final ids = [for (var i = 0; i < 5000; i++) gerador.next()];
      expect(UuidV7.timestampMs(ids.first), referenciaMs);
      expect(UuidV7.timestampMs(ids.last), greaterThan(referenciaMs));
      for (var i = 1; i < ids.length; i++) {
        expect(ids[i].compareTo(ids[i - 1]), greaterThan(0));
      }
    });

    test('relógio que volta para trás não faz o id voltar', () {
      var agora = referenciaMs;
      final gerador = UuidV7Generator(clockMs: () => agora);
      final a = gerador.next();
      agora -= 3600 * 1000; // o usuário atrasou o relógio em 1 h
      final b = gerador.next();
      expect(b.compareTo(a), greaterThan(0));
      expect(UuidV7.timestampMs(b), greaterThanOrEqualTo(referenciaMs));
    });

    test('com o relógio andando, a ordem do texto é a ordem do tempo', () {
      var agora = referenciaMs;
      final gerador = UuidV7Generator(clockMs: () => agora);
      final ids = <String>[];
      for (var i = 0; i < 2000; i++) {
        agora += i % 3; // 0, 1 ou 2 ms entre ids
        ids.add(gerador.next());
      }
      final ordenados = [...ids]..sort();
      expect(ordenados, ids);
    });
  });

  test(
    'dois aparelhos no mesmo milissegundo não colidem (62 bits aleatórios)',
    () {
      final a = UuidV7Generator(clockMs: () => referenciaMs, random: Random(1));
      final b = UuidV7Generator(clockMs: () => referenciaMs, random: Random(2));
      final ids = <String>{};
      for (var i = 0; i < 10000; i++) {
        ids
          ..add(a.next())
          ..add(b.next());
      }
      expect(ids, hasLength(20000));
    },
  );

  test('o gerador padrão usa o relógio do sistema e aleatoriedade segura', () {
    final antes = DateTime.now().millisecondsSinceEpoch;
    final id = UuidV7Generator().next();
    final depois = DateTime.now().millisecondsSinceEpoch;
    expect(UuidV7.timestampMs(id), inInclusiveRange(antes, depois + 1));
  });
}
