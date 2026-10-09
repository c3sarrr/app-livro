// G22.4 — os gatilhos do paywall (docs/progresso/G22.md §4, R7): os marcos de valor uma vez cada, o 2º aparelho, no
// máximo 1 espontâneo a cada 7 dias por conta (contado no aparelho), os de toque fora do limite, e o Pro nunca vê.
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/features/billing/application/paywall_triggers.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DateTime agora;
  late PaywallTriggers motor;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    agora = DateTime.utc(2026, 10, 9, 12);
    motor = PaywallTriggers(kv: () async => KvDao(db), now: () => agora);
  });
  tearDown(() => db.close());

  Future<PaywallReason?> inicio(
    String dono, {
    int livros = 0,
    int grifos = 0,
    int dias = 0,
    bool pro = false,
  }) => motor.onHomeShown(
    dono,
    books: livros,
    highlights: grifos,
    streakDays: dias,
    pro: pro,
  );

  /// Avalia e, havendo motivo, mostra (como o gancho faz).
  Future<PaywallReason?> mostrar(
    String dono, {
    int livros = 0,
    int grifos = 0,
    int dias = 0,
  }) async {
    final r = await inicio(dono, livros: livros, grifos: grifos, dias: dias);
    if (r != null) await motor.shown(dono, r);
    return r;
  }

  group('os marcos ao mostrar a Início', () {
    test('10 livros na estante: uma vez', () async {
      expect(await inicio('a', livros: 9), isNull);
      expect(await mostrar('a', livros: 10), PaywallReason.books10);
      agora = agora.add(const Duration(days: 30));
      expect(await inicio('a', livros: 12), isNull);
    });

    test('50 grifos e 30 dias de sequência', () async {
      expect(await inicio('a', grifos: 49, dias: 29), isNull);
      expect(await mostrar('a', grifos: 50), PaywallReason.highlights50);
      agora = agora.add(const Duration(days: 7));
      expect(await mostrar('a', grifos: 50, dias: 30), PaywallReason.streak30);
    });

    test('dois marcos no mesmo dia: só o 1º; o 2º depois de 7 dias', () async {
      final inicial = agora;
      expect(await mostrar('a', livros: 10, grifos: 50), PaywallReason.books10);
      agora = inicial.add(const Duration(days: 1));
      expect(await inicio('a', livros: 10, grifos: 50), isNull);
      agora = inicial.add(const Duration(days: 6, hours: 23));
      expect(await inicio('a', livros: 10, grifos: 50), isNull);
      agora = inicial.add(const Duration(days: 7));
      expect(
        await inicio('a', livros: 10, grifos: 50),
        PaywallReason.highlights50,
      );
    });

    test('avaliar sem mostrar não gasta o marco nem o limite', () async {
      expect(await inicio('a', livros: 10), PaywallReason.books10);
      expect(await inicio('a', livros: 10), PaywallReason.books10);
    });

    test('o limite e os marcos são por conta', () async {
      expect(await mostrar('a', livros: 10), PaywallReason.books10);
      expect(await inicio('b', livros: 10), PaywallReason.books10);
    });
  });

  group('o 2º aparelho', () {
    test('conta Grátis que entra com outra sessão ativa', () async {
      expect(
        await motor.onSignedIn('a', otherSessions: 1, pro: false),
        PaywallReason.secondDevice,
      );
      expect(await motor.onSignedIn('a', otherSessions: 0, pro: false), isNull);
    });

    test('entra no mesmo limite de 7 dias dos marcos', () async {
      await motor.shown('a', PaywallReason.secondDevice);
      expect(await inicio('a', livros: 10), isNull);
      expect(await motor.onSignedIn('a', otherSessions: 2, pro: false), isNull);
      agora = agora.add(const Duration(days: 7));
      expect(await inicio('a', livros: 10), PaywallReason.books10);
    });
  });

  group('os de toque', () {
    test('sempre, fora do limite, e não contam nele', () async {
      expect(await mostrar('a', livros: 10), PaywallReason.books10);
      expect(
        motor.onTap(PaywallReason.otherProfile, pro: false),
        PaywallReason.otherProfile,
      );
      agora = agora.add(const Duration(days: 3));
      await motor.shown('a', PaywallReason.secondClub);
      agora = agora.add(const Duration(days: 4));
      // 7 dias depois do marco (o toque de 3 dias atrás não reiniciou o limite)
      expect(await inicio('a', grifos: 50), PaywallReason.highlights50);
    });
  });

  test('quem é Pro nunca vê', () async {
    expect(
      await inicio('a', livros: 10, grifos: 50, dias: 30, pro: true),
      isNull,
    );
    expect(await motor.onSignedIn('a', otherSessions: 3, pro: true), isNull);
    expect(motor.onTap(PaywallReason.fullStats, pro: true), isNull);
  });

  test('zerar (a tela técnica) esquece só a conta pedida', () async {
    expect(await mostrar('a', livros: 10), PaywallReason.books10);
    expect(await mostrar('b', livros: 10), PaywallReason.books10);
    await motor.resetForTests('a');
    expect(await inicio('a', livros: 10), PaywallReason.books10);
    expect(await inicio('b', livros: 10, grifos: 50), isNull);
  });

  test('o texto do motivo na tela técnica', () {
    expect(PaywallReason.books10.label, 'Marco: 10 livros');
    expect(PaywallReason.highlights50.label, 'Marco: 50 grifos');
    expect(PaywallReason.streak30.label, 'Marco: 30 dias seguidos');
    expect(PaywallReason.secondDevice.label, '2º aparelho');
    expect(PaywallReason.otherProfile.label, 'Perfil de outra pessoa');
    expect(PaywallReason.secondClub.label, '2º clube');
    expect(PaywallReason.fullStats.label, 'Estatísticas completas');
    expect(PaywallReason.fromName('streak30'), PaywallReason.streak30);
    expect(PaywallReason.fromName('outro'), isNull);
  });
}
