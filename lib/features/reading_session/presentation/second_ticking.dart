import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import '../application/second_ticker.dart';

/// O tique do cronômetro na tela (a mini-barra e a folha da sessão): refaz [builder] a cada segundo enquanto [running]
/// e o widget está à vista — o app em primeiro plano (o `AppLifecycleListener` solta o tique em segundo plano) e a
/// rota dele por cima (sob uma tela empilhada opaca, o `TickerMode` desliga). Ao voltar, refaz pela parede: o tempo
/// sai sempre do relógio, não da contagem de tiques. Só o que [builder] devolve é refeito. [onTick] corre a cada tique
/// (antes de refazer) e [onHidden], quando o app sai da frente.
class SecondTicking extends StatefulWidget {
  const SecondTicking({
    super.key,
    required this.running,
    required this.ticker,
    required this.builder,
    this.onTick,
    this.onHidden,
  });

  final bool running;
  final SecondTicker ticker;
  final WidgetBuilder builder;
  final VoidCallback? onTick;
  final VoidCallback? onHidden;

  @override
  State<SecondTicking> createState() => _SecondTickingState();
}

class _SecondTickingState extends State<SecondTicking> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<void>? _ticks;
  late bool _visible;
  ValueListenable<TickerModeData>? _tickerMode;

  /// À vista: em primeiro plano ou só inativo (a cortina de notificações por cima).
  static bool _isVisible(AppLifecycleState? s) =>
      s == null ||
      s == AppLifecycleState.resumed ||
      s == AppLifecycleState.inactive;

  @override
  void initState() {
    super.initState();
    _visible = _isVisible(WidgetsBinding.instance.lifecycleState);
    _lifecycle = AppLifecycleListener(
      onStateChange: (s) {
        final visible = _isVisible(s);
        if (visible == _visible) return;
        if (!visible) widget.onHidden?.call();
        // ao voltar, o tempo é refeito pela parede (o que passou em segundo plano conta)
        setState(() => _visible = visible);
        _sync();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mode = TickerMode.getValuesNotifier(context);
    if (!identical(mode, _tickerMode)) {
      _tickerMode?.removeListener(_onTickerMode);
      _tickerMode = mode..addListener(_onTickerMode);
    }
    _sync();
  }

  /// A rota voltou a ficar por cima (ou foi coberta): refaz pela parede e liga ou solta o tique.
  void _onTickerMode() {
    if (!mounted) return;
    setState(() {});
    _sync();
  }

  @override
  void didUpdateWidget(SecondTicking old) {
    super.didUpdateWidget(old);
    if (old.ticker != widget.ticker) _stop();
    _sync();
  }

  void _sync() {
    if (widget.running && _visible && (_tickerMode?.value.enabled ?? true)) {
      _ticks ??= widget.ticker.ticks.listen((_) {
        if (!mounted) return;
        widget.onTick?.call();
        setState(() {});
      });
    } else {
      _stop();
    }
  }

  void _stop() {
    unawaited(_ticks?.cancel());
    _ticks = null;
  }

  @override
  void dispose() {
    _stop();
    _tickerMode?.removeListener(_onTickerMode);
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
