// Sinal de idade das lojas (D-66): Google Play Age Signals (Android) e Apple Declared Age Range (iOS 26+),
// pelo plugin `age_range_signals`. Atrás de interface: o teste com as APIs reais exige aparelho.
import 'package:age_range_signals/age_range_signals.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, immutable;
import 'package:flutter/services.dart'
    show MissingPluginException, PlatformException;

import '../domain/age.dart';

@immutable
sealed class StoreAgeResult {
  const StoreAgeResult();
}

/// A loja informou uma faixa.
final class StoreAgeRange extends StoreAgeResult {
  const StoreAgeRange({required this.lower, this.upper, required this.source});
  final int lower;
  final int? upper;
  final AgeSource source;
}

/// A loja não informa aqui (fora das regiões cobertas, iOS < 26, pessoa recusou, sem Play Services):
/// o app pede a data de nascimento.
final class StoreAgeUnavailable extends StoreAgeResult {
  const StoreAgeUnavailable();
}

/// O Google Play exige que a pessoa confirme a idade na Play Store antes (regiões com verificação
/// obrigatória — o Brasil é uma). O app NÃO substitui isso pela data de nascimento.
final class StoreAgeVerificationNeeded extends StoreAgeResult {
  const StoreAgeVerificationNeeded();
}

abstract interface class StoreAgeSignals {
  Future<StoreAgeResult> read();
}

/// [StoreAgeSignals] real.
final class PluginStoreAgeSignals implements StoreAgeSignals {
  PluginStoreAgeSignals([AgeRangeSignals? plugin])
    : _plugin = plugin ?? AgeRangeSignals.instance;

  final AgeRangeSignals _plugin;

  AgeSource get _source => defaultTargetPlatform == TargetPlatform.iOS
      ? AgeSource.appleSignal
      : AgeSource.playSignal;

  @override
  Future<StoreAgeResult> read() async {
    try {
      await _plugin.initialize(ageGates: ageGates);
      final access = await _plugin.requestAgeSignalsAccess();
      if (access == AgeSignalsAccessStatus.verificationRequired) {
        return const StoreAgeVerificationNeeded();
      }
      if (access != AgeSignalsAccessStatus.shared) {
        return const StoreAgeUnavailable();
      }
      final r = await _plugin.checkAgeSignals();
      final lower = r.ageLower;
      if (lower == null) return const StoreAgeUnavailable();
      return StoreAgeRange(lower: lower, upper: r.ageUpper, source: _source);
    } on AgeSignalsException {
      return const StoreAgeUnavailable();
    } on MissingPluginException {
      return const StoreAgeUnavailable(); // plataforma sem o plugin (ex.: testes no desktop)
    } on PlatformException {
      return const StoreAgeUnavailable();
    }
  }
}
