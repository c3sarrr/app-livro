// Resumo da conta (`public.my_account()`) e a regra do @ (CHECK de `public.profiles.handle`).
import 'package:app_leitura/features/account/domain/account_summary.dart';
import 'package:app_leitura/features/account/domain/age.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_backend.dart';

void main() {
  test('fromJson lê o que o servidor devolve', () {
    final s = AccountSummary.fromJson(contaJson());
    expect(s.id, contaTeste);
    expect(s.handle, 'leitor_0199a7c42f007a10');
    expect(s.displayName, 'Leitora');
    expect(s.isPrivate, isFalse);
    expect(s.handleProvisional, isTrue);
    expect(s.ageBand, AgeBand.adult);
    expect(s.pro, isFalse);

    final menor = AccountSummary.fromJson({
      ...contaJson(handle: 'ana.lima', provisorio: false, faixa: '13_15'),
      'visibility': 'private',
    });
    expect(menor.isPrivate, isTrue);
    expect(menor.handleProvisional, isFalse);
    expect(menor.ageBand, AgeBand.from13to15);
    expect(AccountSummary.fromJson(contaJson(faixa: null)).ageBand, isNull);
    expect(
      AccountSummary.fromJson(contaJson()),
      AccountSummary.fromJson(contaJson()),
    );
  });

  test('G22 (R7): as outras sessões ativas da conta; sem o campo (o servidor antigo), nenhuma', () {
    expect(
      AccountSummary.fromJson({...contaJson(), 'other_sessions': 2})
          .otherSessions,
      2,
    );
    expect(AccountSummary.fromJson(contaJson()).otherSessions, 0);
    expect(
      AccountSummary.fromJson({...contaJson(), 'other_sessions': 1}),
      isNot(AccountSummary.fromJson(contaJson())),
    );
  });

  group('normalizeHandle', () {
    test('minúsculas, sem @ e sem espaços nas pontas', () {
      expect(normalizeHandle('Ana.Lima'), 'ana.lima');
      expect(normalizeHandle('  @leitora_99 '), 'leitora_99');
      expect(normalizeHandle('abc'), 'abc');
      expect(normalizeHandle('a' * 30), 'a' * 30);
    });

    test(
      'fora da regra → null (tamanho, caracteres, acento, espaço no meio)',
      () {
        for (final h in [
          'ab',
          'a' * 31,
          'ana lima',
          'ana-lima',
          'joão',
          '@',
          '',
          'ana!',
        ]) {
          expect(normalizeHandle(h), isNull, reason: h);
        }
      },
    );

    test('"leitor_…" é reservado ao servidor (o @ provisório do cadastro)', () {
      expect(normalizeHandle('leitor_0199a7c42f007a10'), isNull);
      expect(normalizeHandle('Leitor_ana'), isNull);
      expect(normalizeHandle('leitora'), 'leitora');
    });
  });
}
