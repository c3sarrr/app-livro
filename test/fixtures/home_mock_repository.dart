// G03 — o antigo `HomeMockRepository` de `lib/` agora é fixture de teste (D-34): os valores da prancha, montados a
// partir do mundo de referência. Desde a T03 (D-240) é a Início da prancha 01 (`telas/inicio01.dart`, a `t01`).
// Produção não tem dado de usuário no código (PROMPT MESTRE §4.3.1): usa a fonte real do banco local (G08, D-85).
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';

import 'telas/inicio01.dart';

class HomeMockRepository implements SyncHomeRepository {
  const HomeMockRepository();

  /// "Agora" de referência (D-09): domingo, 20/09/2026, 20:00 — coerente com "Boa noite,",
  /// semana S T Q Q S S + Hoje e encontro na quinta 24/09.
  static final DateTime referenceNow = TelaInicio01.agora;

  static const Book domCasmurro = TelaInicio01.domCasmurro;
  static const Book brasCubas = TelaInicio01.brasCubas;
  static const Book orgulho = TelaInicio01.orgulho;
  static const Book mrsDalloway = TelaInicio01.mrsDalloway;
  static const Book frankenstein = TelaInicio01.frankenstein;
  static const Book oAlienista = TelaInicio01.oAlienista;
  static const Book senhora = TelaInicio01.senhora;

  @override
  HomeSnapshot snapshot(DateTime now) => TelaInicio01.snapshot(now);

  /// Dados fixos: nada muda depois do instantâneo inicial (D-09).
  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}
