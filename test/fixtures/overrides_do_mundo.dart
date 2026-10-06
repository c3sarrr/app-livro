// G03 — liga a Início ao mundo de referência (D-34): relógio no "agora" de referência (D-09) e o
// repositório da fixture. Sem `flutter_test` aqui: também serve ao app de desenvolvimento
// (`main_mundo_referencia.dart`).
import 'package:app_leitura/core/preferences/brand_preference.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
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

final List<Override> overridesDoMundo = List.unmodifiable([
  relogioDoMundo,
  repositorioDoMundo,
  brandDoMundo,
]);
