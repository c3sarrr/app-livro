// G10.2 — fatias de tempo da paginação (Anexo 03 §7.2): os jobs de layout rodam em tarefas ociosas do
// `SchedulerBinding` (que não disputam quadro com animação), até 4 ms por vez, o de maior prioridade primeiro
// (o capítulo atual, depois o seguinte, depois o anterior).
import 'dart:async';

import 'package:flutter/scheduler.dart';

import 'chapter_layout.dart';

final class _Entry {
  _Entry(this.job, this.priority);

  final ChapterLayoutJob job;
  int priority;
  final Completer<ChapterLayout> done = Completer<ChapterLayout>();
}

final class LayoutScheduler {
  LayoutScheduler({
    SchedulerBinding? binding,
    this.budget = layoutSliceBudget,
    this.priority = Priority.idle,
  }) : _binding = binding ?? SchedulerBinding.instance;

  final SchedulerBinding _binding;
  final Duration budget;
  final Priority priority;
  final List<_Entry> _queue = [];
  final List<(bool Function(), Completer<void>)> _waiters = [];
  bool _scheduled = false;

  /// Maior fatia já executada (µs), quantas fatias rodaram e quantas passaram do orçamento (um passo
  /// sozinho maior que ele) — para a medida de desempenho.
  int maxSliceMicros = 0;
  int slices = 0;
  int overBudgetSlices = 0;

  /// Põe [job] na fila; completa quando o capítulo estiver todo paginado. Maior [priority] roda antes.
  Future<ChapterLayout> run(ChapterLayoutJob job, {int priority = 0}) {
    final existing = _find(job);
    if (existing != null) {
      existing.priority = priority;
      return existing.done.future;
    }
    if (job.done) return Future.value(job.result);
    final e = _Entry(job, priority);
    _queue.add(e);
    _ensureScheduled();
    return e.done.future;
  }

  /// Completa quando [ready] for verdade (conferido depois de cada fatia) ou quando a fila esvaziar — por
  /// exemplo, "a página que contém a posição já fechou" enquanto o resto do capítulo continua.
  Future<void> waitFor(bool Function() ready) {
    if (ready() || _queue.isEmpty) return Future.value();
    final c = Completer<void>();
    _waiters.add((ready, c));
    return c.future;
  }

  /// Muda a prioridade de um job que está na fila.
  void prioritize(ChapterLayoutJob job, int priority) {
    _find(job)?.priority = priority;
  }

  /// Tira [job] da fila (o chamador descarta o que ele montou). O `Future` dele não completa mais.
  void cancel(ChapterLayoutJob job) {
    _queue.removeWhere((e) => identical(e.job, job));
    _wake();
  }

  void _wake() {
    final empty = _queue.isEmpty;
    _waiters.removeWhere((w) {
      if (empty || w.$1()) {
        w.$2.complete();
        return true;
      }
      return false;
    });
  }

  bool get idle => _queue.isEmpty;

  _Entry? _find(ChapterLayoutJob job) {
    for (final e in _queue) {
      if (identical(e.job, job)) return e;
    }
    return null;
  }

  void _ensureScheduled() {
    if (_scheduled || _queue.isEmpty) return;
    _scheduled = true;
    unawaited(_binding.scheduleTask(_slice, priority));
  }

  void _slice() {
    _scheduled = false;
    if (_queue.isEmpty) return;
    var top = _queue.first;
    for (final e in _queue) {
      if (e.priority > top.priority) top = e;
    }
    final sw = Stopwatch()..start();
    final finished = top.job.runFor(budget);
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
