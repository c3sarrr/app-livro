// T04 — o tique de 1 s do cronômetro (a mini-barra e a folha refazem o tempo a cada tique). É uma interface porque um
// `Timer.periodic` real nunca deixa o `pumpAndSettle` dos testes assentar: os testes usam um tique manual. O tempo em
// si sai sempre do relógio de parede (`OpenPaperSession.elapsedAt`), não da contagem de tiques.
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class SecondTicker {
  /// Um evento por segundo enquanto alguém escuta.
  Stream<void> get ticks;
}

/// O tique do app: `Stream.periodic`, que só corre enquanto há quem escute (a mini-barra rodando e em primeiro
/// plano — ela cancela a assinatura ao pausar, ao ir para o segundo plano e ao sair da tela).
final class PeriodicSecondTicker implements SecondTicker {
  const PeriodicSecondTicker();

  @override
  Stream<void> get ticks => Stream<void>.periodic(const Duration(seconds: 1));
}

final secondTickerProvider = Provider<SecondTicker>(
  (ref) => const PeriodicSecondTicker(),
);
