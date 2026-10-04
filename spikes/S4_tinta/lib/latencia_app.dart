// G02 · S4 — app de medição da latência do traço. Rodar em APARELHO real, em modo profile:
//
//   cd spikes/S4_tinta
//   flutter create --platforms=android,ios --project-name spike_s4_tinta .   # só na 1ª vez
//   flutter run --profile -d <id-do-aparelho> -t lib/latencia_app.dart
//
// Desenhe ~20 traços (dedo e, se houver, caneta). A tela mostra a taxa de quadros e a latência
// p50/p95/máx (evento de ponteiro → fim da rasterização do quadro que o mostra); o console recebe
// o JSON a cada traço ("S4LAT {...}"). Meta (Anexo 03 §12): p95 ≤ 16,7 ms a 60 Hz e ≤ 8,3 ms a 120 Hz.
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'latencia/medidor.dart';
import 'suavizacao.dart';

void main() => runApp(const AppLatencia());

class TracoVivo extends ChangeNotifier {
  final pontos = <(double, double, double?)>[];
  final prontos = <ui.Path>[];
  final eventosUs = <int>[];

  void adicionar(PointerEvent e) {
    pontos.add((
      e.localPosition.dx,
      e.localPosition.dy,
      e.kind == PointerDeviceKind.stylus ? e.pressure : null,
    ));
    eventosUs.add(e.timeStamp.inMicroseconds);
    notifyListeners();
  }

  void terminar() {
    if (pontos.isNotEmpty) {
      prontos.add(caminho(contorno(pontos, _opcoes(completo: true))));
      pontos.clear();
    }
    notifyListeners();
  }
}

OpcoesTraco _opcoes({bool completo = false}) => Ponta.esferografica.opcoes
    .copyWith(tamanho: 1.2 * dpPorMm, completo: completo);

ui.Path caminho(List<Vec> c) {
  final p = ui.Path();
  if (c.isEmpty) return p;
  p.moveTo(c.first.$1, c.first.$2);
  for (final v in c.skip(1)) {
    p.lineTo(v.$1, v.$2);
  }
  return p..close();
}

class PintorTinta extends CustomPainter {
  PintorTinta(this.traco) : super(repaint: traco);
  final TracoVivo traco;
  static final _tinta = ui.Paint()..color = const ui.Color(0xFFE4572E);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    for (final p in traco.prontos) {
      canvas.drawPath(p, _tinta);
    }
    if (traco.pontos.isNotEmpty) {
      canvas.drawPath(caminho(contorno(traco.pontos, _opcoes())), _tinta);
    }
  }

  @override
  bool shouldRepaint(PintorTinta old) => false;
}

class AppLatencia extends StatefulWidget {
  const AppLatencia({super.key});

  @override
  State<AppLatencia> createState() => _AppLatenciaState();
}

class _AppLatenciaState extends State<AppLatencia> {
  final traco = TracoVivo();
  final quadros = <QuadroMedido>[];
  final intervalosUs = <int>[];
  String resumo = 'desenhe para medir';

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_aoReceberTempos);
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_aoReceberTempos);
    traco.dispose();
    super.dispose();
  }

  void _aoReceberTempos(List<ui.FrameTiming> ts) {
    for (final t in ts) {
      final v = t.timestampInMicroseconds(ui.FramePhase.vsyncStart);
      if (quadros.isNotEmpty) intervalosUs.add(v - quadros.last.vsyncUs);
      quadros.add(
        QuadroMedido(v, t.timestampInMicroseconds(ui.FramePhase.rasterFinish)),
      );
    }
  }

  void _fimDoTraco() {
    traco.terminar();
    final r = calcularLatencia(traco.eventosUs, quadros);
    final iv = [...intervalosUs]..sort();
    final hz = iv.isEmpty ? 0 : 1e6 / iv[iv.length ~/ 2];
    final tela = ui.PlatformDispatcher.instance.views.first.display.refreshRate;
    final json = {
      'tela_hz': tela,
      'quadros_hz_mediana': hz.round(),
      ...r.toJson(),
      'meta_ms': tela > 90 ? 8.3 : 16.7,
    };
    debugPrint('S4LAT ${jsonEncode(json)}');
    setState(() {
      resumo =
          '${tela.round()} Hz · ${r.amostras} eventos · p50 ${r.p50Ms.toStringAsFixed(1)} · '
          'p95 ${r.p95Ms.toStringAsFixed(1)} · máx ${r.maxMs.toStringAsFixed(1)} ms';
    });
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: const Color(0xFFF8F1E4),
      child: Stack(
        children: [
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: traco.adicionar,
              onPointerMove: traco.adicionar,
              onPointerUp: (_) => _fimDoTraco(),
              onPointerCancel: (_) => _fimDoTraco(),
              child: CustomPaint(painter: PintorTinta(traco)),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 48,
            child: Text(
              resumo,
              key: const Key('resumo'),
              style: const TextStyle(color: Color(0xFF2A2520), fontSize: 14),
            ),
          ),
        ],
      ),
    ),
  );
}
