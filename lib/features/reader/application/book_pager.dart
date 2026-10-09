// G10.2/G10.3 — as páginas de um livro aberto (Anexo 03 §7.2): abre numa posição (capítulo + caractere),
// vira página para frente e para trás atravessando capítulos (só os itens lineares do spine), e repagina
// voltando ao caractere que a pessoa está lendo quando os ajustes ou o tamanho da tela mudam. O conteúdo de
// cada capítulo vem de um isolate; o layout roda em fatias de ≤ 4 ms ([LayoutScheduler]) — o capítulo atual
// primeiro, depois o seguinte e o anterior; só esses três ficam montados. Com o cache de páginas
// (`page_layout_cache`), a página da posição é montada sozinha antes do resto do capítulo.
//
// Concorrência (revisão da G10): abrir e repaginar valem pela mais recente — uma abertura atrasada não troca
// a página de uma mais nova; virar página espera a abertura em andamento e as viradas anteriores (duas
// viradas rápidas = duas páginas). A página mostrada continua pintável, com os blocos e os ajustes dela,
// até a página nova existir.
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show Listenable, ValueNotifier;

import '../../../core/data/database/daos/content_daos.dart';
import '../content/book_index.dart';
import '../content/chapter_content.dart';
import '../layout/chapter_layout.dart';
import '../layout/display_page.dart';
import '../layout/laid_block.dart';
import '../layout/layout_scheduler.dart';
import '../layout/page_painter.dart' show ReaderImageOf;
import '../layout/page_snapshot.dart';
import '../layout/paginator.dart';
import '../layout/reader_typography.dart';
import '../layout/space_cut.dart';

export '../layout/display_page.dart' show PageDirection;
export '../layout/page_snapshot.dart' show PageSnapshot;

/// Lê o capítulo (item do spine) [spine].
typedef ChapterLoader = Future<ChapterContent> Function(int spine);

/// Lê os capítulos do arquivo [path] num isolate (o fecho leva só o caminho).
ChapterLoader isolateChapterLoader(String path) =>
    (spine) => Isolate.run(() => loadChapter(path, spine));

/// Prioridades das fatias: o capítulo atual, o seguinte, o anterior; os outros esperam.
const int _current = 3;
const int _nextPriority = 2;
const int _previousPriority = 1;
const int _background = 0;

/// O leitor foi fechado ([BookPager.dispose]) com a operação ainda em andamento.
final class PagerClosed implements Exception {
  const PagerClosed();

  @override
  String toString() => 'PagerClosed';
}

/// Onde o leitor está: o capítulo e a página dele.
final class PagerPosition {
  const PagerPosition({
    required this.spine,
    required this.page,
    required this.pageIndex,
  });

  final int spine;
  final ReaderPage page;

  /// Índice da página no capítulo; `null` enquanto ela veio do cache e o capítulo ainda está sendo paginado.
  final int? pageIndex;

  /// 1º caractere visível (no texto canônico do capítulo) — o que a posição salva guarda (D-19).
  int get firstVisible => page.start;
}

/// Chave do cache de páginas de um livro. O tamanho da tela vem dos ajustes ([ReaderTypography]); o
/// [devicePixelRatio] completa a coluna `viewport` (`<largura>x<altura>@<dpr>`).
final class PagerCacheKey {
  const PagerCacheKey({
    required this.userBookId,
    required this.devicePixelRatio,
    required this.dao,
  });

  final String userBookId;
  final double devicePixelRatio;
  final PageLayoutCacheDao dao;
}

/// `390x844@3` (sem ".0" nos inteiros).
String viewportKey(ReaderTypography t, double devicePixelRatio) {
  String n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  return '${n(t.viewportWidth)}x${n(t.viewportHeight)}@${n(devicePixelRatio)}';
}

typedef _Quick = ({ReaderPage page, List<LaidBlock> blocks, int firstBlock});

final class _Chapter {
  _Chapter(this.content);

  final ChapterContent content;
  ChapterLayoutJob? job;
  _Quick? quick;

  /// O layout deste capítulo quebrou (erro tipado para a tela — D-21).
  Object? error;
  StackTrace? errorStack;

  ChapterLayout? get layout => (job?.done ?? false) ? job!.result : null;

  List<ReaderPage> get pages => job?.pagesSoFar ?? const [];

  void setQuick(_Quick q) {
    disposeQuick();
    quick = q;
  }

  void dispose(LayoutScheduler s) {
    final j = job;
    if (j != null) {
      s.cancel(j);
      j.dispose();
    }
    job = null;
    disposeQuick();
  }

  void disposeQuick() {
    final q = quick;
    if (q != null) {
      for (final b in q.blocks) {
        b.dispose();
      }
    }
    quick = null;
  }
}

/// O que está na tela: a posição, o capítulo dono dos blocos dela e os ajustes com que foi montada.
typedef _Shown = ({PagerPosition pos, _Chapter ch, ReaderTypography t});

final class BookPager {
  BookPager({
    required this.index,
    required this._load,
    required ReaderTypography typography,
    required this._scheduler,
    this._cache,
    DateTime Function()? now,
    this._imageOf,
    this.spaces,
  }) : _t = typography,
       _now = now ?? DateTime.now,
       _linear = [
         for (var i = 0; i < index.spine.length; i++)
           if (index.spine[i].linear) i,
       ];

  final BookIndex index;
  final ChapterLoader _load;
  final LayoutScheduler _scheduler;
  final PagerCacheKey? _cache;
  final DateTime Function() _now;

  /// As imagens do livro para pintar (D-114); sem isto, o lugar delas fica vazio.
  final ReaderImageOf? _imageOf;
  final List<int> _linear;
  ReaderTypography _t;

  /// G18: os espaços abertos de cada capítulo (as notas à mão). Mudou? [respace].
  SpaceCutsOf? spaces;

  List<SpaceCut> _cutsOf(int spine) => spaces?.call(spine, _t) ?? const [];

  /// Capítulos montados com os ajustes de agora.
  Map<int, _Chapter> _chapters = {};
  final Map<int, Future<ChapterContent>> _loading = {};

  /// Capítulos de ajustes anteriores que ainda estão na tela (descartados quando a página nova chega).
  final List<_Chapter> _retired = [];
  _Shown? _shown;

  /// O caractere que a pessoa "está lendo": o pedido em [openAt] ou o 1º da página para onde ela virou. Mudar
  /// os ajustes várias vezes seguidas volta sempre a ele — e não ao começo da página do layout anterior, que
  /// andaria para trás a cada mudança.
  ({int spine, int offset})? _anchor;

  /// Muda a cada abertura, repaginação e no [dispose]: o que foi pedido antes e ainda não terminou desiste.
  int _gen = 0;

  /// Muda a cada mudança de ajustes: o que foi lido ou montado com ajustes antigos não vale mais.
  int _layoutGen = 0;
  Future<PagerPosition>? _pendingOpen;
  Future<void> _turning = Future<void>.value();

  /// Inícios de página do cache para os ajustes de agora ([_breaksGen] = de qual mudança de ajustes).
  PageBreaks? _breaks;
  Future<PageBreaks?>? _breaksLoad;
  int _breaksGen = -1;
  bool _disposed = false;

  ReaderTypography get typography => _t;
  PagerPosition? get position => _shown?.pos;

  /// O caractere que a pessoa está lendo — o que a repaginação mantém na tela. A posição salva continua sendo o
  /// 1º caractere visível ([PagerPosition.firstVisible]).
  ({int spine, int offset})? get anchor => _anchor;

  /// Texto canônico do capítulo [spine], se ele está carregado (citação da posição — G10.3).
  ChapterContent? contentOf(int spine) => _chapters[spine]?.content;

  /// Carrega (sem paginar) o capítulo [spine] — para reencontrar uma posição guardada antes de abrir.
  Future<ChapterContent> content(int spine) async =>
      (await _chapter(spine)).content;

  /// Hash do que muda o layout ([ReaderTypography.layoutKey]) — coluna `settings_hash` do cache.
  String get settingsHash =>
      sha256.convert(utf8.encode(_t.layoutKey)).toString().substring(0, 32);

  /// Primeiro item linear (onde um livro nunca aberto começa).
  int get firstSpine => _linear.isEmpty ? 0 : _linear.first;

  /// Abre na página que contém o caractere [offset] do capítulo [spine]. Se outra abertura (ou repaginação)
  /// for pedida antes desta terminar, esta devolve o resultado da mais nova.
  Future<PagerPosition> openAt(int spine, int offset) {
    if (_disposed) return Future.error(const PagerClosed());
    _anchor = (spine: spine, offset: offset);
    final gen = ++_gen;
    return _pendingOpen = _open(spine, offset, gen);
  }

  /// Ajustes ou tela mudaram: repagina e volta para a página que contém o caractere que a pessoa está lendo.
  /// A página de agora continua pintável (com os ajustes antigos) até a nova chegar.
  Future<PagerPosition> relayout(ReaderTypography t) {
    if (_disposed) return Future.error(const PagerClosed());
    final anchor = _anchor;
    final old = _chapters;
    _chapters = {for (final e in old.entries) e.key: _Chapter(e.value.content)};
    for (final c in old.values) {
      _retire(c);
    }
    _t = t;
    _layoutGen++;
    _breaks = null;
    _breaksLoad = null;
    final gen = ++_gen;
    return _pendingOpen = _open(
      anchor?.spine ?? firstSpine,
      anchor?.offset ?? 0,
      gen,
    );
  }

  /// G18: os espaços abertos mudaram (uma nota nova, mudada ou apagada): repagina como numa mudança de ajustes —
  /// o cache dos capítulos cujos espaços não mudaram continua valendo (a assinatura de cada um).
  Future<PagerPosition> respace() => relayout(_t);

  /// Próxima página (atravessa capítulos). `false` = fim do livro, ou a virada perdeu a vez para uma
  /// abertura mais nova.
  Future<bool> next() => _turn(_forward);

  /// Página anterior (atravessa capítulos). `false` = começo do livro, ou a virada perdeu a vez.
  Future<bool> previous() => _turn(_backward);

  /// Avisa quando a página mostrada muda — inclusive por dentro (a página do cache vira a do layout completo):
  /// quem pinta a página atual lê [current] de novo.
  Listenable get changes => _changes;
  final _changes = ValueNotifier<int>(0);

  /// A página mostrada, pronta para a tela, com os blocos e os ajustes com que ela foi montada.
  PageSnapshot? get current {
    final s = _shown;
    if (s == null) return null;
    return _snapshot(s.pos.spine, s.pos.page, s.pos.pageIndex, s.ch, s.t);
  }

  /// A página vizinha **sem virar** — para pintar a página que vem atrás do dedo (G11, D-107). `null` = começo
  /// ou fim do livro, ou uma abertura mais nova passou na frente. O capítulo vizinho que não abre dá o erro dele
  /// (não é o fim do livro).
  Future<PageSnapshot?> peek(PageDirection d) async {
    if (_disposed) return null;
    final open = _pendingOpen;
    if (open != null) {
      try {
        await open;
      } on Object {
        return null;
      }
    }
    await _turning;
    final gen = _gen;
    final pos = await _settled(gen);
    if (pos == null || gen != _gen || _disposed) return null;
    final ch = _shown!.ch;
    final i = pos.pageIndex!;
    if (d == PageDirection.backward) {
      if (i > 0) return _snapshot(pos.spine, ch.pages[i - 1], i - 1, ch, _t);
      return _peekCross(pos.spine, -1, gen);
    }
    final job = ch.job;
    if (job == null) return null;
    await _scheduler.waitFor(
      () =>
          gen != _gen ||
          job.done ||
          ch.error != null ||
          job.pagesSoFar.length > i + 1,
    );
    if (gen != _gen || _disposed) return null;
    if (job.pagesSoFar.length > i + 1) {
      return _snapshot(pos.spine, job.pagesSoFar[i + 1], i + 1, ch, _t);
    }
    if (ch.error != null) {
      Error.throwWithStackTrace(ch.error!, ch.errorStack ?? StackTrace.current);
    }
    if (!job.done) return null;
    return _peekCross(pos.spine, 1, gen);
  }

  /// A 1ª página do capítulo seguinte ([step] = 1) ou a última do anterior (-1), pulando os sem texto, sem
  /// virar. `null` = começo/fim do livro ou desistiu; o capítulo que não abre dá o erro dele.
  Future<PageSnapshot?> _peekCross(int from, int step, int gen) async {
    var s = from;
    while (true) {
      final n = _neighbor(s, step);
      if (n == null) return null;
      final nc = await _chapter(n);
      if (gen != _gen || _disposed) return null;
      final job = _ensureJob(nc, step > 0 ? _nextPriority : _previousPriority);
      if (step > 0) {
        await _scheduler.waitFor(
          () =>
              gen != _gen ||
              job.done ||
              nc.error != null ||
              job.pagesSoFar.isNotEmpty,
        );
        if (gen != _gen || _disposed) return null;
        if (job.pagesSoFar.isNotEmpty) {
          return _snapshot(n, job.pagesSoFar.first, 0, nc, _t);
        }
      } else {
        final ChapterLayout layout;
        try {
          layout = await _scheduler.run(
            job,
            priority: _previousPriority,
            urgent: true,
          );
        } on LayoutCancelled {
          return null;
        }
        if (gen != _gen || _disposed) return null;
        if (layout.pages.isNotEmpty) {
          return _snapshot(
            n,
            layout.pages.last,
            layout.pages.length - 1,
            nc,
            _t,
          );
        }
      }
      if (nc.error != null) {
        Error.throwWithStackTrace(
          nc.error!,
          nc.errorStack ?? StackTrace.current,
        );
      }
      s = n; // capítulo sem texto: segue
    }
  }

  /// A página [page] do capítulo [ch]: vale enquanto os blocos dela existirem (o job, ou a página do cache,
  /// ainda são os mesmos — descartar o capítulo ou repaginar a mata).
  PageSnapshot _snapshot(
    int spine,
    ReaderPage page,
    int? pageIndex,
    _Chapter ch,
    ReaderTypography t,
  ) {
    final q = ch.quick;
    final job = ch.job;
    final fromQuick = pageIndex == null && q != null;
    return PageSnapshot(
      spine: spine,
      page: page,
      typography: t,
      item: ch.content.item,
      blockOf: (b) =>
          fromQuick ? q.blocks[b - q.firstBlock] : job!.blocksSoFar[b],
      alive: () =>
          !_disposed &&
          (fromQuick ? identical(ch.quick, q) : identical(ch.job, job)),
      imageOf: _imageOf,
    );
  }

  /// Espera o capítulo atual ficar todo paginado (testes e medidas).
  Future<ChapterLayout?> settle() async {
    final open = _pendingOpen;
    if (open != null) {
      try {
        await open;
      } on Object {
        return null;
      }
    }
    await _turning;
    final gen = _gen;
    if (_shown == null || await _settled(gen) == null) return null;
    final job = _shown?.ch.job;
    if (job == null) return null;
    try {
      return await _scheduler.run(job, priority: _current, urgent: true);
    } on LayoutCancelled {
      return null;
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _gen++;
    _layoutGen++;
    for (final c in _chapters.values) {
      c.dispose(_scheduler);
    }
    _chapters.clear();
    for (final c in _retired) {
      c.dispose(_scheduler);
    }
    _retired.clear();
    _shown = null;
    _changes.dispose();
  }

  // ------------------------------------------------------------------------------------------------------

  Future<PagerPosition> _open(int spine, int offset, int gen) async {
    final ch = await _chapter(spine);
    if (gen != _gen) return _superseded();
    _focus(ch);
    final job = ch.job!;
    final starts = await _cachedStarts(spine);
    if (gen != _gen) return _superseded();
    if (starts != null && !job.done) {
      final q = _quickPage(ch, starts, offset);
      if (q != null) {
        ch.setQuick(q);
        _show(PagerPosition(spine: spine, page: q.page, pageIndex: null), ch);
        _neighbors(spine);
        return _shown!.pos;
      }
    }
    await _scheduler.waitFor(
      () =>
          gen != _gen ||
          job.done ||
          ch.error != null ||
          (job.pagesSoFar.isNotEmpty && job.pagesSoFar.last.end > offset),
    );
    if (gen != _gen) return _superseded();
    if (ch.error != null) {
      Error.throwWithStackTrace(ch.error!, ch.errorStack ?? StackTrace.current);
    }
    if (!job.done && job.pagesSoFar.isEmpty) {
      // a fila esvaziou sem o capítulo terminar (não deveria): vale como superada
      return _superseded();
    }
    if (job.pagesSoFar.isEmpty) {
      // capítulo sem nada para mostrar: o primeiro seguinte com texto (ou o último anterior, no fim do livro)
      final forward = await _cross(spine, 1, gen);
      if (forward == null) return _superseded();
      if (forward) return _shown!.pos;
      final backward = await _cross(spine, -1, gen);
      if (backward == null) return _superseded();
      if (backward) return _shown!.pos;
      throw StateError('livro sem texto para mostrar');
    }
    _show(_containing(spine, job.pagesSoFar, offset), ch);
    _neighbors(spine);
    return _shown!.pos;
  }

  /// A abertura foi superada por uma mais nova: devolve o resultado dela.
  Future<PagerPosition> _superseded() {
    if (_disposed) return Future.error(const PagerClosed());
    return _pendingOpen!;
  }

  /// A página do cache que contém [offset] — só se os inícios guardados estiverem em ordem, a página montada
  /// sozinha começar num começo de linha e contiver o caractere.
  _Quick? _quickPage(_Chapter ch, List<int> starts, int offset) {
    if (starts.isEmpty) return null;
    for (var i = 1; i < starts.length; i++) {
      if (starts[i] <= starts[i - 1]) return null;
    }
    var k = 0;
    for (var i = 0; i < starts.length; i++) {
      if (starts[i] <= offset) k = i;
    }
    final q = layoutPageFrom(
      ch.content,
      _t,
      starts[k],
      cuts: _cutsOf(ch.content.spineIndex),
    );
    if (q == null) return null;
    final contains =
        q.page.end > offset || q.page.end >= ch.content.item.text.length;
    final next = k + 1 < starts.length ? starts[k + 1] : null;
    if (!contains || (next != null && q.page.end > next)) {
      for (final b in q.blocks) {
        b.dispose();
      }
      return null;
    }
    return q;
  }

  /// Vira página em fila: espera a abertura em andamento e as viradas anteriores.
  Future<bool> _turn(Future<bool?> Function(int gen) step) {
    if (_disposed) return Future.value(false);
    final run = _turning.then((_) async {
      final open = _pendingOpen;
      if (open != null) {
        try {
          await open;
        } on Object {
          return false;
        }
      }
      final gen = _gen;
      if (_disposed || _shown == null) return false;
      return await step(gen) ?? false;
    });
    _turning = run.then((_) {}, onError: (Object _) {});
    return run;
  }

  /// `null` = desistiu (uma abertura mais nova chegou).
  Future<bool?> _forward(int gen) async {
    final pos = await _settled(gen);
    if (pos == null) return null;
    final ch = _shown!.ch;
    final i = pos.pageIndex!;
    final job = ch.job;
    if (job == null) return null;
    await _scheduler.waitFor(
      () =>
          gen != _gen ||
          job.done ||
          ch.error != null ||
          job.pagesSoFar.length > i + 1,
    );
    if (gen != _gen) return null;
    if (job.pagesSoFar.length > i + 1) {
      _turnedTo(
        PagerPosition(
          spine: pos.spine,
          page: job.pagesSoFar[i + 1],
          pageIndex: i + 1,
        ),
        ch,
      );
      return true;
    }
    if (ch.error != null) {
      Error.throwWithStackTrace(ch.error!, ch.errorStack ?? StackTrace.current);
    }
    if (!job.done) return null;
    return _cross(pos.spine, 1, gen);
  }

  Future<bool?> _backward(int gen) async {
    final pos = await _settled(gen);
    if (pos == null) return null;
    final i = pos.pageIndex!;
    final ch = _shown!.ch;
    if (i > 0) {
      _turnedTo(
        PagerPosition(
          spine: pos.spine,
          page: ch.pages[i - 1],
          pageIndex: i - 1,
        ),
        ch,
      );
      return true;
    }
    return _cross(pos.spine, -1, gen);
  }

  /// Atravessa para o capítulo seguinte ([step] = 1, 1ª página) ou anterior (-1, última página), pulando os
  /// sem texto. `false` = fim/começo do livro; `null` = desistiu.
  Future<bool?> _cross(int from, int step, int gen) async {
    var s = from;
    while (true) {
      final n = _neighbor(s, step);
      if (n == null) return false;
      final nc = await _chapter(n);
      if (gen != _gen) return null;
      _focus(nc);
      final job = nc.job!;
      if (step > 0) {
        await _scheduler.waitFor(
          () =>
              gen != _gen ||
              job.done ||
              nc.error != null ||
              job.pagesSoFar.isNotEmpty,
        );
        if (gen != _gen) return null;
        if (job.pagesSoFar.isNotEmpty) {
          _turnedTo(
            PagerPosition(spine: n, page: job.pagesSoFar.first, pageIndex: 0),
            nc,
          );
          _neighbors(n);
          return true;
        }
      } else {
        final ChapterLayout layout;
        try {
          layout = await _scheduler.run(job, priority: _current, urgent: true);
        } on LayoutCancelled {
          return null;
        }
        if (gen != _gen) return null;
        if (layout.pages.isNotEmpty) {
          _turnedTo(
            PagerPosition(
              spine: n,
              page: layout.pages.last,
              pageIndex: layout.pages.length - 1,
            ),
            nc,
          );
          _neighbors(n);
          return true;
        }
      }
      if (nc.error != null) {
        Error.throwWithStackTrace(
          nc.error!,
          nc.errorStack ?? StackTrace.current,
        );
      }
      s = n; // capítulo sem texto: segue
    }
  }

  /// Virou página: a posição nova e o caractere que a pessoa passa a ler.
  void _turnedTo(PagerPosition p, _Chapter ch) {
    _show(p, ch);
    _anchor = (spine: p.spine, offset: p.firstVisible);
  }

  /// Troca o que está na tela; os capítulos de ajustes antigos e a página rápida que saíram da tela são
  /// descartados.
  void _show(PagerPosition p, _Chapter ch) {
    final before = _shown;
    _shown = (pos: p, ch: ch, t: _t);
    if (!_disposed) _changes.value++;
    for (final r in _retired) {
      r.dispose(_scheduler);
    }
    _retired.clear();
    if (before != null &&
        identical(before.ch, ch) &&
        before.pos.pageIndex == null &&
        p.pageIndex != null) {
      ch.disposeQuick();
    }
  }

  /// Capítulo de ajustes antigos: para de paginar; se está na tela, fica até a página nova chegar.
  void _retire(_Chapter c) {
    if (identical(_shown?.ch, c)) {
      if (c.job case final j?) _scheduler.cancel(j);
      _retired.add(c);
    } else {
      c.dispose(_scheduler);
    }
  }

  /// Posição com o índice da página conhecido (a página do cache vira a do layout completo). `null` =
  /// desistiu.
  Future<PagerPosition?> _settled(int gen) async {
    final s = _shown;
    if (s == null) return null;
    if (s.pos.pageIndex != null) return s.pos;
    final job = s.ch.job;
    if (job == null) return null;
    final ChapterLayout layout;
    try {
      layout = await _scheduler.run(job, priority: _current, urgent: true);
    } on LayoutCancelled {
      return null;
    }
    if (gen != _gen) return null;
    _resolveQuick(s.ch, layout);
    return _shown!.pos;
  }

  /// A página do cache (sem índice) vira a página do layout completo que contém o caractere que a pessoa
  /// está lendo.
  void _resolveQuick(_Chapter ch, ChapterLayout layout) {
    final s = _shown;
    if (s == null || !identical(s.ch, ch) || s.pos.pageIndex != null) return;
    final a = _anchor;
    final at = a != null && a.spine == s.pos.spine
        ? a.offset
        : s.pos.page.start;
    final i = layout.pageAt(at);
    _show(
      PagerPosition(spine: s.pos.spine, page: layout.pages[i], pageIndex: i),
      ch,
    );
  }

  PagerPosition _containing(int spine, List<ReaderPage> pages, int offset) {
    var lo = 0;
    var hi = pages.length - 1;
    while (lo < hi) {
      final m = (lo + hi + 1) >> 1;
      if (pages[m].start <= offset) {
        lo = m;
      } else {
        hi = m - 1;
      }
    }
    return PagerPosition(spine: spine, page: pages[lo], pageIndex: lo);
  }

  int? _neighbor(int spine, int step) {
    final i = _linear.indexOf(spine);
    if (i < 0) {
      // fora da ordem de leitura (nota aberta por link): o vizinho é o linear mais próximo
      for (final s in step > 0 ? _linear : _linear.reversed) {
        if (step > 0 ? s > spine : s < spine) return s;
      }
      return null;
    }
    final j = i + step;
    return j < 0 || j >= _linear.length ? null : _linear[j];
  }

  /// O capítulo [ch] passa a ser o que a pessoa espera: o job dele na frente, os outros esperam.
  void _focus(_Chapter ch) {
    for (final o in _chapters.values) {
      if (!identical(o, ch) && o.job != null) {
        _scheduler.prioritize(o.job!, _background);
      }
    }
    _ensureJob(ch, _current);
  }

  /// Mantém montados só o capítulo atual e os vizinhos; põe os vizinhos na fila com prioridade menor.
  void _neighbors(int spine) {
    final next = _neighbor(spine, 1);
    final prev = _neighbor(spine, -1);
    final keep = {spine, ?next, ?prev};
    for (final s in _chapters.keys.toList()) {
      if (!keep.contains(s)) _chapters.remove(s)!.dispose(_scheduler);
    }
    if (_chapters[spine]?.job case final j?) _scheduler.prioritize(j, _current);
    if (next != null) unawaited(_prefetch(next, _nextPriority));
    if (prev != null) unawaited(_prefetch(prev, _previousPriority));
  }

  Future<void> _prefetch(int spine, int priority) async {
    try {
      final c = await _chapter(spine);
      final pos = _shown?.pos;
      final still =
          pos != null &&
          (spine == _neighbor(pos.spine, 1) ||
              spine == _neighbor(pos.spine, -1));
      // a pessoa já saiu daqui enquanto o capítulo carregava: o próximo `_neighbors` o descarta
      if (_disposed || !still || !identical(_chapters[spine], c)) return;
      _ensureJob(c, priority);
    } on Object {
      // capítulo vizinho que não abre: o erro aparece quando a pessoa chegar nele
    }
  }

  /// O capítulo [spine] dos ajustes de agora (carrega o conteúdo uma vez, num isolate).
  Future<_Chapter> _chapter(int spine) async {
    final have = _chapters[spine];
    if (have != null) return have;
    // (o fecho não devolve o Future removido: o whenComplete esperaria por ele mesmo)
    final content = await (_loading[spine] ??= _load(spine).whenComplete(() {
      _loading.remove(spine);
    }));
    if (_disposed) throw const PagerClosed();
    return _chapters[spine] ??= _Chapter(content);
  }

  ChapterLayoutJob _ensureJob(_Chapter ch, int priority) {
    var job = ch.job;
    if (job == null) {
      job = ChapterLayoutJob(
        ch.content,
        _t,
        cuts: _cutsOf(ch.content.spineIndex),
      );
      ch.job = job;
      final spine = ch.content.spineIndex;
      final mine = job;
      final layoutGen = _layoutGen;
      unawaited(
        _scheduler
            .run(job, priority: priority)
            .then(
              (layout) => _laidOut(spine, ch, mine, layout, layoutGen),
              onError: (Object e, StackTrace st) {
                if (e is LayoutCancelled) return;
                // o layout deste capítulo quebrou: quem espera por ele recebe o erro
                if (identical(ch.job, mine)) {
                  ch
                    ..error = e
                    ..errorStack = st;
                }
              },
            ),
      );
    } else {
      _scheduler.prioritize(job, priority);
    }
    return job;
  }

  Future<void> _laidOut(
    int spine,
    _Chapter ch,
    ChapterLayoutJob job,
    ChapterLayout layout,
    int layoutGen,
  ) async {
    // o capítulo foi descartado ou repaginado (outros ajustes) antes desta conclusão chegar
    if (!identical(ch.job, job) || layoutGen != _layoutGen) return;
    _resolveQuick(ch, layout);
    await _saveStarts(spine, layout.pageStarts, layoutGen);
  }

  Future<List<int>?> _cachedStarts(int spine) async {
    final key = _cache;
    if (key == null) return null;
    final layoutGen = _layoutGen;
    await _loadBreaks(key);
    // os ajustes mudaram enquanto o cache era lido
    if (layoutGen != _layoutGen) return null;
    // G18: só com os mesmos espaços abertos
    if ((_breaks?.spaces[spine] ?? '') != spaceSignature(_cutsOf(spine))) {
      return null;
    }
    return _breaks?.chapters[spine];
  }

  /// Lê do banco (uma vez por mudança de ajustes) os inícios de página guardados para os ajustes de agora.
  Future<void> _loadBreaks(PagerCacheKey key) async {
    final layoutGen = _layoutGen;
    if (_breaksGen != layoutGen || _breaksLoad == null) {
      _breaksGen = layoutGen;
      _breaksLoad = _readBreaks(key);
    }
    final loaded = await _breaksLoad!;
    if (layoutGen == _layoutGen) _breaks ??= loaded;
  }

  Future<PageBreaks?> _readBreaks(PagerCacheKey key) async {
    try {
      final b = await key.dao.get(
        userBookId: key.userBookId,
        settingsHash: settingsHash,
        viewport: viewportKey(_t, key.devicePixelRatio),
        fontsVersion: readerFontsVersion,
        now: _now(),
      );
      return b != null && b.sha == index.contentSha256 ? b : null;
    } on Object {
      return null; // cache é só atalho: sem ele, o capítulo é paginado do começo
    }
  }

  Future<void> _saveStarts(int spine, List<int> starts, int layoutGen) async {
    final key = _cache;
    if (key == null || _disposed || layoutGen != _layoutGen) return;
    // junta com o que já está guardado (lido antes, para não apagar os outros capítulos)
    await _loadBreaks(key);
    if (_disposed || layoutGen != _layoutGen) return;
    final signature = spaceSignature(_cutsOf(spine));
    final merged = PageBreaks(
      sha: index.contentSha256,
      chapters: {...?_breaks?.chapters, spine: starts},
      spaces: {
        for (final e in {...?_breaks?.spaces}.entries)
          if (e.key != spine) e.key: e.value,
        if (signature.isNotEmpty) spine: signature,
      },
    );
    _breaks = merged;
    try {
      await key.dao.put(
        userBookId: key.userBookId,
        settingsHash: settingsHash,
        viewport: viewportKey(_t, key.devicePixelRatio),
        fontsVersion: readerFontsVersion,
        breaks: merged,
        now: _now(),
      );
    } on Object {
      // cache é só atalho: sem ele, o próximo abrir pagina o capítulo
    }
  }
}
