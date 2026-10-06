// G03 — liga a Início ao mundo de referência (D-34): relógio no "agora" de referência (D-09) e o
// repositório da fixture. Sem `flutter_test` aqui: também serve ao app de desenvolvimento
// (`main_mundo_referencia.dart`).
import 'dart:async';

import 'package:app_leitura/core/preferences/brand_preference.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/reader/application/reader_providers.dart';
import 'package:app_leitura/features/reader/application/reader_session_controller.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'home_mock_repository.dart';

final Override relogioDoMundo = clockProvider.overrideWithValue(
  () => HomeMockRepository.referenceNow,
);

final Override repositorioDoMundo = homeRepositoryProvider.overrideWithValue(
  const HomeMockRepository(),
);

/// A cor `brand` (D-33) fica na memória: a fixture não abre banco.
final Override brandDoMundo = brandStoreProvider.overrideWith(
  (ref) => MemoryBrandStore(),
);

/// O leitor (G11) abre livros da estante do aparelho; a Início da fixture não tem banco: a tela do leitor fica
/// no "abrindo" (os testes da Início só conferem que ela abre — os do leitor montam um livro de verdade).
final Override leitorDoMundo = readerDepsProvider.overrideWith(
  (ref) => Completer<ReaderDeps>().future,
);

final List<Override> overridesDoMundo = List.unmodifiable([
  relogioDoMundo,
  repositorioDoMundo,
  brandDoMundo,
  leitorDoMundo,
]);
