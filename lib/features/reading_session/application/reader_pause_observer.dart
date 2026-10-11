// T04 — D-263: abrir o leitor (qualquer livro, por qualquer caminho) pausa a sessão do papel que estiver rodando — o
// e-book conta sozinho, e o tempo não conta em dobro. Fica nas rotas (o `createRouter` registra), não no leitor: o
// leitor não conhece o cronômetro. Só age se o cronômetro já existe (o shell sempre o assiste no app) — nunca o cria
// nem o carrega — e a pausa entra na fila dele: a sessão que ainda carrega do `kv` (o leitor aberto na partida) ou que
// um toque acabou de retomar também pausa (sem a sessão rodando, a pausa não faz nada).
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart' show AppRoutes;
import '../data/paper_timer_store.dart' show reportPaperTimerError;
import 'paper_timer_controller.dart';

/// O nome da página do leitor no `createRouter` (o `path` do `GoRoute`).
const String readerRouteName = AppRoutes.leitorPath;

class ReaderPausesPaperTimer extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _maybePause(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _maybePause(newRoute);

  void _maybePause(Route<dynamic>? route) {
    if (route?.settings.name != readerRouteName) return;
    final context = navigator?.context;
    if (context == null) return;
    final container = ProviderScope.containerOf(context, listen: false);
    if (!container.exists(paperTimerProvider)) return;
    unawaited(
      container
          .read(paperTimerProvider.notifier)
          .pauseForReader()
          .catchError(reportPaperTimerError),
    );
  }
}
