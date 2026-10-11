// G11.2 — tela acesa enquanto se lê (D-111): liga a cada interação e desliga [readingIdleLimit] depois da última
// (a mesma regra do tempo automático, D-95), em segundo plano e ao sair do leitor. Depois disso o bloqueio
// automático do aparelho volta a valer.
import 'dart:async';

import 'package:wakelock_plus/wakelock_plus.dart';

import 'reader_errors.dart';
import 'reading_session_tracker.dart' show readingIdleLimit;

/// Manter a tela acesa (o pacote `wakelock_plus` em produção; um dublê nos testes).
abstract interface class ScreenAwake {
  Future<void> enable();
  Future<void> disable();
}

final class WakelockScreenAwake implements ScreenAwake {
  const WakelockScreenAwake();

  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}

final class KeepAwake {
  KeepAwake(
    this._screen, {
    this.idle = readingIdleLimit,
    this._onError = reportReaderError,
  });

  final ScreenAwake _screen;
  final Duration idle;
  final ReaderErrorReporter _onError;
  Timer? _timer;
  bool _on = false;

  bool get on => _on;

  /// Houve interação: liga (se estava desligada) e conta [idle] de novo.
  void touch() {
    _timer?.cancel();
    _timer = Timer(idle, stop);
    if (!_on) {
      _on = true;
      _call(_screen.enable);
    }
  }

  /// Desliga já (parado, segundo plano, sair).
  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_on) {
      _on = false;
      _call(_screen.disable);
    }
  }

  void _call(Future<void> Function() f) {
    // falha do sistema não para a leitura: vai para o relatório de falhas
    unawaited(
      Future.sync(f).catchError((Object e, StackTrace st) => _onError(e, st)),
    );
  }
}
