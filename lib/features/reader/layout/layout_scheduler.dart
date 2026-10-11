// G10.2 — fatias de tempo da paginação (Anexo 03 §7.2): os jobs de layout rodam em tarefas do
// `SchedulerBinding`, até 4 ms por vez, o de maior prioridade primeiro (o capítulo atual, depois o seguinte,
// depois o anterior). Adiantar capítulos roda como tarefa ociosa (não disputa quadro com animação); quando
// alguém espera uma página (abrir, virar), as fatias sobem para a prioridade de animação — senão um
// indicador de "carregando" girando na tela impediria a página de chegar.
import 'dart:async';

import 'package:flutter/scheduler.dart';

import 'chapter_layout.dart';

/// O job saiu da fila antes de terminar (o capítulo foi descartado ou repaginado com outros ajustes).
final class LayoutCancelled implements Exception {
  const LayoutCancelled();

  @override
  String toString() => 'LayoutCancelled';
}

final class _Entry {
  _Entry(this.job, this.priority, {required this.urgent}) {
    // ninguém precisa ouvir o cancelamento: não vira erro solto
    done.future.ignore();
  }

  final ChapterLayoutJob job;
  int priority;
  bool urgent;
  final Completer<ChapterLayout> done = Completer<ChapterLayout>();
}

typedef _Waiter = ({bool Function() ready, Completer<void> done, bool urgent});

final class LayoutScheduler {
  LayoutScheduler({
    SchedulerBinding? binding,
    this.budget = layoutSliceBudget,
    this.priority = Priority.idle,
  }) : _binding = binding ?? SchedulerBinding.instance;

  final SchedulerBinding _binding;
  final Duration budget;

  /// Prioridade das fatias quando ninguém está esperando uma página.
  final Priority priority;
  final List<_Entry> _queue = [];
  final List<_Waiter> _waiters = [];

  /// Prioridade da tarefa já pedida ao `SchedulerBinding` (`null` = nenhuma).
  Priority? _scheduled;

  /// Maior fatia já executada (µs), quantas fatias rodaram e quantas passaram do orçamento (um passo
  /// sozinho maior que ele) — para a medida de desempenho.
  int maxSliceMicros = 0;
  int slices = 0;
  int overBudgetSlices = 0;

  /// Põe [job] na fila; completa quando o capítulo estiver todo paginado, ou com [LayoutCancelled] se ele
  /// sair da fila antes ([cancel]), ou com o erro do layout. Maior [priority] roda antes; [urgent] = alguém
  /// está esperando por ele (prioridade de animação).
  Future<ChapterLayout> run(
    ChapterLayoutJob job, {
    int priority = 0,
    bool urgent = false,
  }) {
    final existing = _find(job);
    if (existing != null) {
      existing
        ..priority = priority
        ..urgent = existing.urgent || urgent;
      _ensureScheduled();
      return existing.done.future;
    }
    if (job.done) return Future.value(job.result);
    final e = _Entry(job, priority, urgent: urgent);
    _queue.add(e);
    _ensureScheduled();
    return e.done.future;
  }

  /// Completa quando [ready] for verdade (conferido depois de cada fatia e de cada cancelamento) ou quando a
  /// fila esvaziar — por exemplo, "a página que contém a posição já fechou" enquanto o resto do capítulo
  /// continua. Quem espera deixa as fatias na prioridade de animação ([urgent]).
  Future<void> waitFor(bool Function() ready, {bool urgent = true}) {
    if (ready() || _queue.isEmpty) return Future.value();
    final c = Completer<void>();
    _waiters.add((ready: ready, done: c, urgent: urgent));
    _ensureScheduled();
    return c.future;
  }

  /// Muda a prioridade de um job que está na fila.
  void prioritize(ChapterLayoutJob job, int priority) {
    _find(job)?.priority = priority;
  }

  /// Tira [job] da fila (o chamador descarta o que ele montou); quem esperava por ele recebe
  /// [LayoutCancelled].
  void cancel(ChapterLayoutJob job) {
    final e = _find(job);
    if (e == null) return;
    _queue.remove(e);
    e.done.completeError(const LayoutCancelled());
    _wake();
  }

  bool get idle => _queue.isEmpty;

  void _wake() {
    final empty = _queue.isEmpty;
    _waiters.removeWhere((w) {
      if (empty || w.ready()) {
        w.done.complete();
        return true;
      }
      return false;
    });
  }

  _Entry? _find(ChapterLayoutJob job) {
    for (final e in _queue) {
      if (identical(e.job, job)) return e;
    }
    return null;
  }

  Priority get _wanted =>
      _waiters.any((w) => w.urgent) || _queue.any((e) => e.urgent)
      ? Priority.animation
      : priority;

  void _ensureScheduled() {
    if (_queue.isEmpty) return;
    final wanted = _wanted;
    final have = _scheduled;
    // já há uma tarefa pedida com prioridade suficiente
    if (have != null && have.value >= wanted.value) return;
    _scheduled = wanted;
    unawaited(_binding.scheduleTask(_slice, wanted));
  }

  void _slice() {
    _scheduled = null;
    if (_queue.isEmpty) return;
    var top = _queue.first;
    for (final e in _queue) {
      if (e.priority > top.priority) top = e;
    }
    final sw = Stopwatch()..start();
    bool finished;
    try {
      finished = top.job.runFor(budget);
    } on Object catch (e, st) {
      // um capítulo que quebra o layout não trava a fila: quem esperava por ele recebe o erro
      _queue.remove(top);
      top.done.completeError(e, st);
      _wake();
      _ensureScheduled();
      return;
    }
    final us = sw.elapsedMicroseconds;
    slices++;
    if (us > maxSliceMicros) maxSliceMicros = us;
    if (us > budget.inMicroseconds) overBudgetSlices++;
    if (finished) {
      _queue.remove(top);
      top.done.complete(top.job.result);
    }
    _wake();
    _ensureScheduled();
  }
}
