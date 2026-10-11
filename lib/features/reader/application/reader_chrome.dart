// G12.2 — o que as ilhas do leitor mostram (telas 20/26b), vindo do banco e atualizado sozinho: a fita (a página
// de referência mostrada tem marcador vivo?), o contador de Grifos (grifos + notas + à mão + desenhos do livro —
// D-124: some com 0, "99+" acima de 99), os minutos de hoje do chip (atualizados a cada minuto com os controles
// abertos — D-124) e o tempo restante (D-97; some no fim do livro). Se o Pro sincronizar um grifo de outro
// aparelho, o contador muda na hora.
import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../annotations/domain/annotation_stats.dart';
import '../domain/reading_speed.dart' show readerTimeLeftLabel;

/// O número do contador de Grifos (D-124): nada com 0, "99+" acima de 99.
String? readerNotesBadge(int n) => n <= 0
    ? null
    : n > 99
    ? '99+'
    : '$n';

/// De quanto em quanto tempo o chip refaz a conta com os controles abertos.
const Duration readerChipRefresh = Duration(seconds: 60);

class ReaderChrome extends ChangeNotifier {
  ReaderChrome({
    required AppDatabase db,
    required this.userBookId,
    required this.refPage,
    required this.minutes,
    required this.timeLeft,
    this.startTimer = Timer.new,
    this.onError,
  }) : _db = db {
    // relê a cada escrita nas tabelas (marcador, anotações — inclusive as que o Pro sincroniza); sem as consultas
    // "vivas" do drift, que deixam um timer para trás ao cancelar
    _updates = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([db.bookmarks, db.annotations]),
        )
        .listen((_) => unawaited(_reload()), onError: _fail);
    unawaited(_reload());
    unawaited(refreshMinutes());
  }

  final AppDatabase _db;
  final String userBookId;

  /// A página de referência mostrada agora.
  final int Function() refPage;

  /// Os minutos lidos hoje (todos os livros).
  final Future<int> Function() minutes;

  /// O tempo restante do livro; `null` no fim.
  final Duration? Function() timeLeft;
  final Timer Function(Duration, void Function()) startTimer;
  final void Function(Object error, StackTrace stack)? onError;
  late final StreamSubscription<Object?> _updates;
  Set<int> _pages = const {};
  int _count = 0;
  int _minutesToday = 0;
  bool _marksReady = false;
  bool _minutesReady = false;
  bool _disposed = false;
  int _gen = 0;
  Timer? _tick;

  Future<void> _reload() async {
    final gen = ++_gen;
    try {
      final marks = await BookmarksDao(_db).forBook(userBookId);
      final notes = await AnnotationsDao(_db).forBook(userBookId);
      if (_disposed || gen != _gen) return;
      _pages = {for (final b in marks) b.refPage};
      _count = AnnotationStats.countByKind(notes, userBookId: userBookId).all;
      _marksReady = true;
      _changed();
    } on Object catch (e, st) {
      _fail(e, st);
    }
  }

  /// As leituras do banco chegaram (testes).
  bool get ready => _marksReady && _minutesReady;

  /// A página de referência mostrada tem marcador vivo (fita "Página marcada").
  bool get marked => _pages.contains(refPage());

  int get notes => _count;
  String? get badge => readerNotesBadge(_count);

  int get minutesToday => _minutesToday;
  String get chipLabel => '$_minutesToday min hoje · contando sozinho';

  /// "≈ 2 h 10 min"; `null` = não mostrar (fim do livro).
  String? get timeLeftLabel {
    final d = timeLeft();
    return d == null ? null : readerTimeLeftLabel(d);
  }

  /// Controles abertos: refaz os minutos agora e a cada minuto; fechados: para.
  set ticking(bool on) {
    if (on == (_tick != null)) return;
    _tick?.cancel();
    _tick = null;
    if (!on || _disposed) return;
    unawaited(refreshMinutes());
    void again() {
      _tick = startTimer(readerChipRefresh, () {
        unawaited(refreshMinutes());
        if (_tick != null && !_disposed) again();
      });
    }

    again();
  }

  bool get ticking => _tick != null;

  Future<void> refreshMinutes() async {
    try {
      final m = await minutes();
      if (_disposed) return;
      _minutesToday = m;
      _minutesReady = true;
      _changed();
    } on Object catch (e, st) {
      _fail(e, st);
    }
  }

  /// A página mudou: a fita e o tempo restante podem mudar.
  void pageChanged() => _changed();

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void _fail(Object e, StackTrace st) => onError?.call(e, st);

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    _tick = null;
    unawaited(_updates.cancel());
    super.dispose();
  }
}
