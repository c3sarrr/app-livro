// G11 — dublês do leitor: tela acesa e barra de status que só anotam o que foi pedido.
import 'dart:async';

import 'package:app_leitura/features/reader/application/reader_providers.dart'
    show ReaderSystemUi;
import 'package:app_leitura/features/reader/application/screen_awake.dart';

final class RecordingScreenAwake implements ScreenAwake {
  final List<String> log = [];

  /// Faz a próxima chamada falhar (o erro tem de ir para o relatório, não parar a leitura).
  bool failNext = false;

  @override
  Future<void> enable() => _call('on');

  @override
  Future<void> disable() => _call('off');

  Future<void> _call(String what) async {
    log.add(what);
    if (failNext) {
      failNext = false;
      throw StateError('wakelock indisponível');
    }
  }
}

/// Prazos que andam à mão ([avancar]): os `Timer` da tela sem esperar o tempo de verdade.
final class RelogioDePrazos {
  Duration _agora = Duration.zero;
  final List<_Prazo> _prazos = [];

  Timer start(Duration d, void Function() f) {
    final p = _Prazo(_agora + d, f);
    _prazos.add(p);
    return p;
  }

  /// Anda [d] e dispara os prazos vencidos, na ordem.
  void avancar(Duration d) {
    _agora += d;
    final vencidos =
        _prazos.where((p) => p.isActive && p.quando <= _agora).toList()
          ..sort((a, b) => a.quando.compareTo(b.quando));
    for (final p in vencidos) {
      p.disparar();
    }
  }

  int get pendentes => _prazos.where((p) => p.isActive).length;
}

final class _Prazo implements Timer {
  _Prazo(this.quando, this._f);

  final Duration quando;
  final void Function() _f;
  bool _ativo = true;

  void disparar() {
    if (!_ativo) return;
    _ativo = false;
    _f();
  }

  @override
  void cancel() => _ativo = false;

  @override
  bool get isActive => _ativo;

  @override
  int get tick => _ativo ? 0 : 1;
}

/// Barra de status do leitor (D-105): anota o que foi pedido.
final class RecordingSystemUi implements ReaderSystemUi {
  final List<String> log = [];

  @override
  Future<void> immersive() async => log.add('imersivo');

  @override
  Future<void> edgeToEdge() async => log.add('padrão');
}
