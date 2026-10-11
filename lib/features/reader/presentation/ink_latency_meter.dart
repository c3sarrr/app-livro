// G16.7 — o medidor de latência do S4 ligado ao modo anotação, só com `--dart-define=BOOKNEST_MEDIR_TINTA=true` (a
// medição no aparelho, em modo profile): o canvas passa o `timeStamp` de cada evento do dedo ou da caneta que mudou
// o que a tela mostra (o traço ao vivo, a tinta ou a página); os tempos dos quadros chegam em lotes
// (`addTimingsCallback`); a cada lote que cobre eventos novos, o resumo acumulado vai ao console como "G16LAT {json}"
// (p50, p95 e máx. contra 16,7 ms a 60 Hz ou 8,3 ms a 120 Hz). Guardados os mais novos, os eventos de antes do 1º
// quadro que ficou saem junto (não casam com um quadro que não é o deles). Sem o define, nada disso existe no app.
import 'dart:convert';
import 'dart:ui' show FrameTiming, FramePhase, PlatformDispatcher;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/scheduler.dart' show SchedulerBinding, TimingsCallback;

import '../annotations/ink/ink_latency.dart';

/// O medidor só existe com `--dart-define=BOOKNEST_MEDIR_TINTA=true`.
const bool inkLatencyMeterOn = bool.fromEnvironment('BOOKNEST_MEDIR_TINTA');

/// Acima disto a tela é de 120 Hz (a meta passa a 8,3 ms).
const double _fastScreenHz = 90;

final class InkLatencyMeter {
  InkLatencyMeter({
    void Function(TimingsCallback)? addTimings,
    void Function(TimingsCallback)? removeTimings,
    void Function(String)? log,
    double Function()? refreshRate,
    this.keep = 20000,
  }) : _add = addTimings ?? SchedulerBinding.instance.addTimingsCallback,
       _remove =
           removeTimings ?? SchedulerBinding.instance.removeTimingsCallback,
       _log = log ?? debugPrint,
       _hz =
           refreshRate ??
           (() => PlatformDispatcher.instance.views.first.display.refreshRate);

  /// Quantos eventos e quadros ficam guardados (os mais novos).
  final int keep;
  final void Function(TimingsCallback) _add;
  final void Function(TimingsCallback) _remove;
  final void Function(String) _log;
  final double Function() _hz;
  final List<int> _events = [];
  final List<FrameTimes> _frames = [];
  int _reported = 0;

  /// Os eventos guardados (µs).
  List<int> get eventsUs => List.unmodifiable(_events);

  /// O mesmo objeto para ligar e desligar (uma referência ao método é outra a cada vez).
  late final TimingsCallback _listener = _onTimings;

  void start() => _add(_listener);

  /// Um evento de ponteiro do modo (o `timeStamp` dele).
  void event(Duration timeStamp) {
    _events.add(timeStamp.inMicroseconds);
    if (_events.length > keep) _events.removeRange(0, _events.length - keep);
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _frames.add((
        vsyncUs: t.timestampInMicroseconds(FramePhase.vsyncStart),
        rasterEndUs: t.timestampInMicroseconds(FramePhase.rasterFinish),
      ));
    }
    if (_frames.length > keep) {
      _frames.removeRange(0, _frames.length - keep);
      final first = _frames.first.vsyncUs;
      _events.removeWhere((e) => e < first);
    }
    final r = inkLatency(_events, _frames);
    if (r.samples == _reported) return;
    _reported = r.samples;
    final hz = _hz();
    _log(
      'G16LAT ${jsonEncode({'tela_hz': hz, ...r.toJson(), 'meta_ms': hz > _fastScreenHz ? 8.3 : 16.7})}',
    );
  }

  void dispose() => _remove(_listener);
}
