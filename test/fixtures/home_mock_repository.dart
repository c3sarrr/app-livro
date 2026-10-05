// G03 — o antigo `HomeMockRepository` de `lib/` agora é fixture de teste (D-34): os mesmos valores
// do arquivo, montados a partir do mundo de referência (`telas/inicio.dart`). Produção não tem dado de
// usuário no código (PROMPT MESTRE §4.3.1): usa a fonte real do banco local (G08, D-85).
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';

import 'telas/inicio.dart';

class HomeMockRepository implements SyncHomeRepository {
  const HomeMockRepository();

  /// "Agora" de referência (D-09): domingo, 20/09/2026, 20:00 — coerente com "Boa noite,",
  /// semana S T Q Q S S + Hoje e encontro na quinta 24/09.
  static final DateTime referenceNow = TelaInicio.agora;

  static const Book domCasmurro = TelaInicio.domCasmurro;
  static const Book mrsDalloway = TelaInicio.mrsDalloway;
  static const Book pridePrejudice = TelaInicio.pridePrejudice;
  static const Book memoriasPostumas = TelaInicio.memoriasPostumas;
  static const Book quincasBorba = TelaInicio.quincasBorba;
  static const Book oCortico = TelaInicio.oCortico;
  static const Book frankenstein = TelaInicio.frankenstein;
  static const Book oAlienista = TelaInicio.oAlienista;
  static const Book senhora = TelaInicio.senhora;

  @override
  HomeSnapshot snapshot(DateTime now) => TelaInicio.snapshot(now);

  /// Dados fixos: nada muda depois do instantâneo inicial (D-09).
  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}
