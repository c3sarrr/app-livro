// Conta no app (G05): convidado por padrão (D-64), checagem de idade antes do login (D-66), login,
// vínculo dos dados do aparelho (D-68), escolha do @, sair, excluir e exportar (D-65).
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/home_providers.dart' show clockProvider;
import '../data/account_api.dart';
import '../data/auth_gateway.dart';
import '../data/local_library.dart';
import '../data/store_age_signals.dart';
import '../domain/account_failure.dart';
import '../domain/account_summary.dart';
import '../domain/age.dart';
import '../domain/auth_status.dart';
import 'account_providers.dart';

@immutable
sealed class AccountView {
  const AccountView();
}

/// Lendo a sessão guardada ou ligando a conta aos dados do aparelho.
final class AccountLoading extends AccountView {
  const AccountLoading();
}

/// Convidado (D-64). [canSignIn] = há servidor nesta versão. [hiddenRows] = linhas guardadas de
/// contas que saíram deste aparelho (D-68) — a pessoa pode apagá-las daqui.
final class GuestView extends AccountView {
  const GuestView({required this.canSignIn, this.hiddenRows = 0});
  final bool canSignIn;
  final int hiddenRows;

  @override
  bool operator ==(Object other) =>
      other is GuestView &&
      other.canSignIn == canSignIn &&
      other.hiddenRows == hiddenRows;

  @override
  int get hashCode => Object.hash(canSignIn, hiddenRows);
}

/// Logado. [summary] nulo = ainda carregando ou o servidor não respondeu ([problem]).
final class MemberView extends AccountView {
  const MemberView({required this.userId, this.summary, this.problem});
  final String userId;
  final AccountSummary? summary;

  /// Por que o resumo da conta não veio (sem internet, erro do servidor…). A tela oferece "Tentar de novo".
  final AccountFailure? problem;

  bool get offline => problem is OfflineFailure;

  /// Falta escolher o @ ou registrar a faixa etária.
  bool get needsOnboarding =>
      summary != null &&
      (summary!.handleProvisional || summary!.ageBand == null);

  @override
  bool operator ==(Object other) =>
      other is MemberView &&
      other.userId == userId &&
      other.summary == summary &&
      other.problem?.runtimeType == problem?.runtimeType;

  @override
  int get hashCode => Object.hash(userId, summary, problem?.runtimeType);
}

/// Resultado da checagem de idade.
@immutable
sealed class AgeGateOutcome {
  const AgeGateOutcome();
}

final class AgeAllowed extends AgeGateOutcome {
  const AgeAllowed(this.check);
  final AgeCheck check;
}

/// A loja não informou: pedir a data de nascimento ([invalid] = a data digitada não vale).
final class AgeNeedsBirthDate extends AgeGateOutcome {
  const AgeNeedsBirthDate({this.invalid = false});
  final bool invalid;
}

/// Menor de 13.
final class AgeBlocked extends AgeGateOutcome {
  const AgeBlocked();
}

/// O Google Play pede a confirmação da idade na Play Store.
final class AgeStoreVerificationNeeded extends AgeGateOutcome {
  const AgeStoreVerificationNeeded();
}

/// Resultado da exportação. [accountMissing] = os dados da conta no servidor ficaram de fora (o
/// arquivo leva só o aparelho e diz o motivo).
@immutable
final class ExportOutcome {
  const ExportOutcome({required this.json, this.accountMissing});
  final String json;
  final AccountFailure? accountMissing;
}

/// Nome do arquivo da exportação ([now] em UTC).
String exportFileName(DateTime now) =>
    'booknest-meus-dados-${now.toUtc().toIso8601String().substring(0, 10)}.json';

/// Vida de um `build` do controller: a fila de sessão para quando o provider é descartado.
final class _Life {
  bool alive = true;
}

class AccountController extends Notifier<AccountView> {
  _Life _life = _Life();
  StreamSubscription<AuthStatus>? _sub;
  Future<void> _queue = Future.value();
  AuthStatus? _handled;
  AgeCheck? _pendingAge;

  @override
  AccountView build() {
    final gw = ref.watch(authGatewayProvider);
    final life = _life = _Life();
    ref.onDispose(() => life.alive = false);
    unawaited(_sub?.cancel());
    _sub = null;
    _handled = null;
    if (gw == null) return const GuestView(canSignIn: false);
    _sub = gw.watch().listen(_enqueue);
    ref.onDispose(() => _sub?.cancel());
    final now = gw.current;
    _enqueue(now);
    return now is SignedIn
        ? const AccountLoading()
        : const GuestView(canSignIn: true);
  }

  AuthGateway get _gateway =>
      ref.read(authGatewayProvider) ?? (throw const ServerNotConfigured());

  AccountApi get _api =>
      ref.read(accountApiProvider) ?? (throw const ServerNotConfigured());

  Future<LocalLibrary> get _library => ref.read(localLibraryProvider.future);

  /// Mudanças de sessão em fila (uma de cada vez, sem repetir a mesma).
  void _enqueue(AuthStatus s) {
    final life = _life;
    _queue = _queue.then((_) async {
      if (!life.alive || s == _handled) return;
      _handled = s;
      try {
        await _apply(s);
      } on Object catch (e, st) {
        if (!life.alive) return; // descartado no meio (ex.: app fechando)
        // Falha inesperada (ex.: banco local): reporta, deixa "Tentar de novo" na tela e mantém a
        // fila andando.
        FlutterError.reportError(
          FlutterErrorDetails(exception: e, stack: st, library: 'conta'),
        );
        if (s is SignedIn) {
          state = MemberView(
            userId: s.userId,
            problem: const ServerFailure('aparelho'),
          );
        }
      }
    });
  }

  /// Espera a fila de mudanças de sessão (testes e ações que dependem do estado novo).
  Future<void> settled() => _queue;

  Future<void> _apply(AuthStatus s) async {
    final lib = await _library;
    switch (s) {
      case SignedOut():
        final guest = await lib.guestOwnerId();
        await lib.setActiveOwner(guest);
        state = GuestView(
          canSignIn: true,
          hiddenRows: await lib.countRowsExcept({guest}),
        );
      case SignedIn(:final userId):
        state = MemberView(userId: userId);
        if (await lib.activeOwnerId() != userId) await lib.clearSocialCache();
        await _refresh(userId);
    }
  }

  /// Busca o resumo da conta. Só com a conta CONFIRMADA pelo servidor o que foi feito como convidado
  /// passa para ela e ela vira a dona ativa (D-68) — senão, uma conta que já não existe levaria os
  /// dados do convidado para um dono que nunca mais entra.
  Future<void> _refresh(String userId) async {
    try {
      var summary = await _api.summary();
      final age = _pendingAge;
      if (age != null) {
        await _api.recordAge(age);
        _pendingAge = null;
        summary = await _api.summary();
      }
      final lib = await _library;
      await lib.adopt(from: await lib.guestOwnerId(), to: userId);
      await lib.setActiveOwner(userId);
      state = MemberView(userId: userId, summary: summary);
    } on AccountGone {
      // Excluída pela página web ou em outro aparelho: o que era dela neste aparelho continua aqui,
      // agora sem conta (como promete a página de exclusão).
      final lib = await _library;
      await lib.adopt(from: userId, to: await lib.guestOwnerId());
      await _endSession();
    } on NotSignedIn {
      // Sessão revogada ("sair de todos", senha trocada): sai deste aparelho; os dados da conta ficam
      // guardados e voltam no próximo login (D-68).
      await _endSession();
    } on AccountFailure catch (f) {
      state = MemberView(userId: userId, problem: f);
    }
  }

  Future<void> _endSession() async {
    try {
      await _gateway.signOut();
    } on AccountFailure {
      // a sessão local já saiu
    }
    _enqueue(const SignedOut());
  }

  /// Tenta de novo o resumo (ex.: voltou a internet).
  Future<void> refresh() async {
    final s = state;
    if (s is MemberView) await _refresh(s.userId);
    await settled();
  }

  // ------------------------------------------------------------------ idade (D-66)

  /// Primeiro o sinal da loja; sem ele, a data de nascimento ([birthDate]). Depois de um "menor de
  /// 13" neste aparelho, outra data digitada não destrava (só o sinal da loja).
  Future<AgeGateOutcome> checkAge({DateTime? birthDate}) async {
    final lib = await _library;
    if (birthDate == null) {
      final r = await ref.read(storeAgeSignalsProvider).read();
      return switch (r) {
        StoreAgeRange(:final lower, :final upper, :final source) => _accept(
          AgeCheck(AgeBand.fromRange(lower, upper)!, source),
        ),
        StoreAgeVerificationNeeded() => const AgeStoreVerificationNeeded(),
        StoreAgeUnavailable() =>
          await lib.isUnderageBlocked()
              ? const AgeBlocked()
              : const AgeNeedsBirthDate(),
      };
    }
    if (await lib.isUnderageBlocked()) return const AgeBlocked();
    final band = bandFromBirthDate(birthDate, ref.read(clockProvider)());
    if (band == null) return const AgeNeedsBirthDate(invalid: true);
    return _accept(AgeCheck(band, AgeSource.birthdate));
  }

  Future<AgeGateOutcome> _accept(AgeCheck check) async {
    final lib = await _library;
    if (!check.allowed) {
      _pendingAge = null; // uma checagem aprovada antes não vale mais
      await lib.setUnderageBlocked(true);
      return const AgeBlocked();
    }
    if (check.source != AgeSource.birthdate) {
      await lib.setUnderageBlocked(false); // a loja informou 13+
    }
    _pendingAge = check;
    final s = state;
    if (s is MemberView) {
      await _refresh(s.userId); // conta sem faixa registrada
      await settled();
    }
    return AgeAllowed(check);
  }

  void _requireAge() {
    if (_pendingAge == null) throw const AgeCheckRequired();
  }

  // ------------------------------------------------------------------ login (D-67)

  Future<void> sendEmailCode(String email) async {
    _requireAge();
    await _gateway.sendEmailCode(email);
  }

  Future<void> verifyEmailCode(String email, String code) async {
    _requireAge();
    await _gateway.verifyEmailCode(email, code);
    await _syncWithGateway();
  }

  Future<void> signInWithGoogle() async {
    _requireAge();
    await _gateway.signInWithGoogle();
    await _syncWithGateway();
  }

  Future<void> signInWithApple() async {
    _requireAge();
    await _gateway.signInWithApple();
    await _syncWithGateway();
  }

  /// A sessão nova é aplicada antes de a ação terminar (o aviso do Supabase chega depois, assíncrono,
  /// e é ignorado por ser igual). No Apple pelo navegador ainda não há sessão: nada muda aqui.
  Future<void> _syncWithGateway() async {
    _enqueue(_gateway.current);
    await settled();
  }

  // ------------------------------------------------------------------ @ (onboarding)

  Future<void> chooseHandle(String raw) async {
    final s = state;
    if (s is! MemberView) throw const NotSignedIn();
    final handle = normalizeHandle(raw);
    if (handle == null) throw const HandleInvalid();
    await _api.setHandle(handle);
    await _refresh(s.userId);
    await settled();
  }

  // ------------------------------------------------------------------ sair / excluir (D-68)

  /// Sai da conta. Os dados dela ficam guardados (escondidos) neste aparelho, ou são apagados se
  /// [eraseLocal].
  Future<void> signOut({required bool eraseLocal}) async {
    final s = state;
    if (s is! MemberView) return;
    try {
      await _gateway.signOut();
    } on AccountFailure {
      // sem rede ou erro do servidor: a sessão local já foi removida (o Supabase remove antes de avisar
      // o servidor) e o token vence sozinho
    }
    final lib = await _library;
    await lib.clearSocialCache();
    if (eraseLocal) await lib.erase(s.userId);
    _enqueue(const SignedOut());
    await settled();
  }

  /// Exclui a conta no servidor (imediato — LGPD). Os dados do aparelho são apagados ([eraseLocal])
  /// ou continuam no aparelho, sem conta.
  Future<void> deleteAccount({required bool eraseLocal}) async {
    final s = state;
    if (s is! MemberView) throw const NotSignedIn();
    await _api.deleteAccount();
    final lib = await _library;
    if (eraseLocal) {
      await lib.erase(s.userId);
    } else {
      await lib.adopt(from: s.userId, to: await lib.guestOwnerId());
    }
    try {
      await _gateway.signOut();
    } on AccountFailure {
      // a conta já não existe: o servidor recusa o logout; a sessão local foi removida
    }
    await lib.clearSocialCache();
    _enqueue(const SignedOut());
    await settled();
  }

  // ------------------------------------------------------------------ exportar (D-65)

  /// Tudo o que é da pessoa: o que o servidor guarda (se houver conta) + o que está no aparelho. Se
  /// a parte do servidor não vier (sem internet, limite do dia…), o aparelho é exportado mesmo assim e
  /// o arquivo diz o que ficou de fora (`account_unavailable`).
  Future<ExportOutcome> buildExport() async {
    final lib = await _library;
    final owner = await lib.activeOwnerId();
    final now = ref.read(clockProvider)().toUtc();
    final s = state;
    Map<String, Object?>? server;
    AccountFailure? missing;
    if (s is MemberView) {
      try {
        server = await _api.exportServerData();
      } on AccountFailure catch (f) {
        missing = f;
      }
    }
    final json = const JsonEncoder.withIndent('  ').convert({
      'format_version': 1,
      'app': 'BookNest',
      'generated_at': now.toIso8601String(),
      'account': server,
      if (missing != null) 'account_unavailable': _missingCode(missing),
      'device': await lib.export(owner),
    });
    return ExportOutcome(json: json, accountMissing: missing);
  }

  static String _missingCode(AccountFailure f) => switch (f) {
    OfflineFailure() => 'sem_conexao',
    ExportLimitReached() => 'limite_diario',
    NotSignedIn() || AccountGone() => 'sem_sessao',
    _ => 'erro_do_servidor',
  };

  /// Gera e entrega o arquivo. Devolve o motivo se a parte da conta ficou de fora.
  Future<AccountFailure?> exportMyData() async {
    final out = await buildExport();
    await ref
        .read(exportSinkProvider)
        .deliver(
          fileName: exportFileName(ref.read(clockProvider)()),
          json: out.json,
        );
    return out.accountMissing;
  }

  /// Apaga deste aparelho os dados guardados de contas que saíram (D-68) — opção do convidado.
  Future<void> eraseHiddenData() async {
    final lib = await _library;
    final guest = await lib.guestOwnerId();
    for (final owner in await lib.ownersExcept({guest})) {
      await lib.erase(owner);
    }
    if (state is GuestView) {
      state = GuestView(canSignIn: (state as GuestView).canSignIn);
    }
  }
}

final accountControllerProvider =
    NotifierProvider<AccountController, AccountView>(AccountController.new);
