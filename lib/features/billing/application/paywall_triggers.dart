// G22.4 — o motor dos gatilhos do paywall (docs/progresso/G22.md §4, R7). Recebe o que aconteceu (a Início com os
// números, a entrada na conta, um toque) e devolve o gatilho a mostrar, ou nenhum:
// - os marcos de valor (10 livros, 50 grifos, 30 dias seguidos) aparecem uma vez cada;
// - o 2º aparelho: uma conta Grátis que entra com outra sessão ativa;
// - no máximo 1 espontâneo (marcos e 2º aparelho) a cada 7 dias por conta, contado no aparelho; o de toque não conta;
// - quem é Pro nunca vê.
// O que já foi mostrado fica no `kv` do aparelho, por dono (`pro.gatilho.<dono>.…`). Até o paywall ter design, só a
// depuração mostra (D-230).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/local_database.dart';
import '../../home/application/home_providers.dart';
import '../../home/data/home_repository.dart';
import '../data/paywall_counts.dart';

export '../data/paywall_counts.dart' show PaywallNumbers;

enum PaywallReason {
  books10('Marco: 10 livros', spontaneous: true),
  highlights50('Marco: 50 grifos', spontaneous: true),
  streak30('Marco: 30 dias seguidos', spontaneous: true),
  secondDevice('2º aparelho', spontaneous: true),
  otherProfile('Perfil de outra pessoa'),
  secondClub('2º clube'),
  fullStats('Estatísticas completas');

  const PaywallReason(this.label, {this.spontaneous = false});

  /// O motivo na tela técnica.
  final String label;

  /// Conta no limite de 7 dias (os de toque, não).
  final bool spontaneous;

  static PaywallReason? fromName(String? name) {
    for (final r in values) {
      if (r.name == name) return r;
    }
    return null;
  }
}

/// No máximo 1 gatilho espontâneo nesse intervalo (R7).
const paywallGap = Duration(days: 7);

final class PaywallTriggers {
  PaywallTriggers({required this.kv, required this.now});

  /// O `kv` do aparelho (o banco abre só quando preciso).
  final Future<KvDao> Function() kv;
  final DateTime Function() now;

  static String _prefix(String owner) => 'pro.gatilho.$owner.';

  Future<bool> _withinGap(KvDao store, String owner) async {
    final last = DateTime.tryParse(
      await store.get('${_prefix(owner)}ultimo') ?? '',
    );
    return last != null && now().toUtc().difference(last) < paywallGap;
  }

  /// A Início apareceu com estes números da conta.
  Future<PaywallReason?> onHomeShown(
    String owner, {
    required int books,
    required int highlights,
    required int streakDays,
    required bool pro,
  }) async {
    if (pro) return null;
    final store = await kv();
    if (await _withinGap(store, owner)) return null;
    for (final (reason, reached) in [
      (PaywallReason.books10, books >= 10),
      (PaywallReason.highlights50, highlights >= 50),
      (PaywallReason.streak30, streakDays >= 30),
    ]) {
      if (reached &&
          await store.get('${_prefix(owner)}${reason.name}') == null) {
        return reason;
      }
    }
    return null;
  }

  /// A pessoa entrou na conta (não é abrir o app com a sessão guardada).
  Future<PaywallReason?> onSignedIn(
    String owner, {
    required int otherSessions,
    required bool pro,
  }) async {
    if (pro || otherSessions <= 0) return null;
    final store = await kv();
    return await _withinGap(store, owner) ? null : PaywallReason.secondDevice;
  }

  /// Os de toque: sempre, fora do limite, menos para o Pro.
  PaywallReason? onTap(PaywallReason reason, {required bool pro}) =>
      pro ? null : reason;

  /// O gatilho apareceu: o marco fica gasto e, sendo espontâneo, começa o limite.
  Future<void> shown(String owner, PaywallReason reason) async {
    final store = await kv();
    final at = now().toUtc().toIso8601String();
    await store.set('${_prefix(owner)}${reason.name}', at);
    if (reason.spontaneous) await store.set('${_prefix(owner)}ultimo', at);
  }

  /// Só a tela técnica: esquece o que foi mostrado a esta conta.
  Future<void> resetForTests(String owner) async {
    final store = await kv();
    for (final (key, _) in await store.withPrefix(_prefix(owner))) {
      await store.delete(key);
    }
  }
}

final paywallTriggersProvider = Provider<PaywallTriggers>(
  (ref) => PaywallTriggers(
    kv: () async => KvDao(await ref.read(localDatabaseProvider.future)),
    now: ref.watch(clockProvider),
  ),
);

/// Os números dos marcos de uma conta (o banco do aparelho e a sequência da Início — G08).
final paywallCountsProvider =
    Provider<Future<PaywallNumbers> Function(String owner)>(
      (ref) => PaywallCounts(
        database: () => ref.read(localDatabaseProvider.future),
        streak: () async {
          final home = ref.read(homeRepositoryProvider);
          final now = ref.read(clockProvider);
          // a fonte que já tem o instantâneo (a fixture do app de desenvolvimento — D-34) não transmite
          final snapshot = home is SyncHomeRepository
              ? home.snapshot(now())
              : await home.watch(now).first;
          return snapshot.readingDay.streakDays;
        },
      ).of,
    );
