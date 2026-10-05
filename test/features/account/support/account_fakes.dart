// Dublês da conta para os testes do controller e das telas (sem rede e sem plugins).
import 'dart:async';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/sync/sync_engine.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/account_api.dart';
import 'package:app_leitura/features/account/data/auth_gateway.dart';
import 'package:app_leitura/features/account/data/export_sink.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/account/data/store_age_signals.dart';
import 'package:app_leitura/features/account/domain/account_failure.dart';
import 'package:app_leitura/features/account/domain/account_summary.dart';
import 'package:app_leitura/features/account/domain/age.dart';
import 'package:app_leitura/features/account/domain/auth_status.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'fake_backend.dart';

final DateTime agoraTeste = DateTime.utc(2026, 10, 4, 12);

/// Login de mentira: as ações emitem a sessão como o Supabase faria.
final class FakeGateway implements AuthGateway {
  FakeGateway({AuthStatus inicial = const SignedOut()}) : _current = inicial;

  final _ctrl = StreamController<AuthStatus>.broadcast(sync: true);
  AuthStatus _current;
  final List<String> calls = [];

  /// Próxima ação falha com isto (uma vez).
  AccountFailure? falha;

  /// `signOut` sem rede: a sessão local sai, mas a chamada falha com [OfflineFailure].
  bool saidaSemRede = false;

  @override
  AuthStatus get current => _current;

  @override
  Stream<AuthStatus> watch() => _ctrl.stream;

  void emit(AuthStatus s) {
    _current = s;
    _ctrl.add(s);
  }

  void _talvezFalhe() {
    final f = falha;
    falha = null;
    if (f != null) throw f;
  }

  void _entrar() => emit(const SignedIn(userId: contaTeste, email: emailTeste));

  @override
  Future<void> sendEmailCode(String email) async {
    calls.add('enviar:$email');
    _talvezFalhe();
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    calls.add('conferir:$code');
    _talvezFalhe();
    _entrar();
  }

  @override
  Future<void> signInWithGoogle() async {
    calls.add('google');
    _talvezFalhe();
    _entrar();
  }

  @override
  Future<void> signInWithApple() async {
    calls.add('apple');
    _talvezFalhe();
    _entrar();
  }

  @override
  Future<void> signOut() async {
    calls.add('sair');
    emit(const SignedOut());
    if (saidaSemRede) throw const OfflineFailure();
  }

  Future<void> close() => _ctrl.close();
}

/// Servidor da conta de mentira (o JSON de `my_account` muda com as chamadas).
final class FakeAccountApi implements AccountApi {
  FakeAccountApi({Map<String, Object?>? conta}) : json = conta ?? contaJson();

  Map<String, Object?> json;
  final List<AgeCheck> faixas = [];
  final List<String> calls = [];

  /// O resumo falha com isto enquanto não for nulo.
  AccountFailure? falhaResumo;

  /// Erro que não é falha da conta (ex.: defeito) — o controller não pode travar com ele.
  Object? falhaInesperada;
  AccountFailure? falhaExportacao;

  /// O próximo resumo só responde quando este completer terminar (uma vez).
  Completer<void>? segurarResumo;

  @override
  Future<AccountSummary> summary() async {
    calls.add('resumo');
    final segurar = segurarResumo;
    segurarResumo = null;
    if (segurar != null) await segurar.future;
    if (falhaInesperada != null) throw falhaInesperada!;
    if (falhaResumo != null) throw falhaResumo!;
    return AccountSummary.fromJson(json);
  }

  @override
  Future<void> recordAge(AgeCheck check) async {
    calls.add('idade');
    faixas.add(check);
    json = {...json, 'age_band': json['age_band'] ?? check.band.code};
  }

  @override
  Future<void> setHandle(String handle) async {
    calls.add('arroba:$handle');
    if (handle == 'tomado') throw const HandleTaken();
    json = {...json, 'handle': handle, 'handle_provisional': false};
  }

  @override
  Future<Map<String, Object?>> exportServerData() async {
    calls.add('exportar');
    if (falhaExportacao != null) throw falhaExportacao!;
    return {
      'format_version': 2,
      'profile': {'handle': json['handle']},
    };
  }

  @override
  Future<void> deleteAccount() async => calls.add('excluir');
}

final class FakeStoreAge implements StoreAgeSignals {
  FakeStoreAge([this.resultado = const StoreAgeUnavailable()]);
  StoreAgeResult resultado;
  int leituras = 0;

  @override
  Future<StoreAgeResult> read() async {
    leituras++;
    return resultado;
  }
}

final class FakeExportSink implements ExportSink {
  final List<(String, String)> entregas = [];

  @override
  Future<void> deliver({
    required String fileName,
    required String json,
  }) async => entregas.add((fileName, json));
}

/// Sincronização de mentira: grava o que a conta pediu e quantas linhas da conta havia naquela hora
/// (para conferir a ORDEM: parar a fila antes de mexer nos dados).
final class FakeSync implements SyncPort {
  FakeSync(this._lib);

  final LocalLibrary Function() _lib;
  final List<String> calls = [];
  int pendentes = 0;

  /// `onAccountConfirmed` falha com isto (uma vez).
  Object? falhaConfirmar;

  /// Também anota 'parar' aqui (ex.: as chamadas do login, para conferir a ordem entre os dois).
  List<String>? eco;

  @override
  Future<void> resume(String owner) async => calls.add('retomar:$owner');

  @override
  Future<void> onAccountConfirmed(String owner, {required bool pro}) async {
    final linhas = await _lib().countRows(owner);
    calls.add('confirmada:$owner:${pro ? 'pro' : 'gratis'}:$linhas');
    final f = falhaConfirmar;
    falhaConfirmar = null;
    if (f != null) throw f;
  }

  @override
  Future<void> beforeOwnerChange() async {
    eco?.add('parar');
    calls.add('parar:${await _lib().countRows(contaTeste)}');
  }

  @override
  Future<int> pendingUploads() async => pendentes;
}

/// Tudo da conta ligado aos dublês (banco do aparelho em memória).
final class AccountHarness {
  AccountHarness({
    bool servidor = true,
    AuthStatus inicial = const SignedOut(),
    StoreAgeResult loja = const StoreAgeUnavailable(),
  }) : gateway = servidor ? FakeGateway(inicial: inicial) : null,
       api = servidor ? FakeAccountApi() : null,
       store = FakeStoreAge(loja),
       db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false) {
    library = LocalLibrary(db, removeFile: (p) async => apagados.add(p));
  }

  final FakeGateway? gateway;
  final FakeAccountApi? api;
  final FakeStoreAge store;
  final FakeExportSink sink = FakeExportSink();
  final AppDatabase db;
  late final LocalLibrary library;
  final List<String> apagados = [];
  late final FakeSync sync = FakeSync(() => library);

  List<Override> get overrides => [
    authGatewayProvider.overrideWithValue(gateway),
    accountApiProvider.overrideWithValue(api),
    ...deviceOverrides,
  ];

  /// Só o lado do aparelho (idade da loja, compartilhar, banco e relógio) — o gateway e a API ficam
  /// os reais, montados sobre `supabaseClientProvider`.
  List<Override> get deviceOverrides => [
    storeAgeSignalsProvider.overrideWithValue(store),
    exportSinkProvider.overrideWithValue(sink),
    localLibraryProvider.overrideWith((ref) => library),
    syncPortProvider.overrideWith((ref) async => sync),
  ];

  /// Relógio fixo ([agoraTeste]). Fora das listas acima: o app nos testes de tela já usa o relógio do
  /// mundo de referência (`overridesDoMundo`) e o Riverpod não aceita o mesmo provider duas vezes.
  Override get relogio => clockProvider.overrideWithValue(() => agoraTeste);

  Future<void> close() async {
    await gateway?.close();
    await db.close();
  }
}
