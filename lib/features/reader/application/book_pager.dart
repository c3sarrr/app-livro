// G10.2/G10.3 — as páginas de um livro aberto (Anexo 03 §7.2): abre numa posição (capítulo + caractere),
// vira página para frente e para trás atravessando capítulos (só os itens lineares do spine), e repagina
// mantendo o 1º caractere visível quando os ajustes ou o tamanho da tela mudam. O conteúdo de cada capítulo
// vem de um isolate; o layout roda em fatias de ≤ 4 ms ([LayoutScheduler]) — o capítulo atual primeiro, depois
// o seguinte e o anterior; só esses três ficam montados. Com o cache de páginas (`page_layout_cache`), a
// página da posição é montada sozinha antes do resto do capítulo.
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';

import '../../../core/data/database/daos/content_daos.dart';
import '../content/book_index.dart';
import '../content/chapter_content.dart';
import '../layout/chapter_layout.dart';
import '../layout/laid_block.dart';
import '../layout/layout_scheduler.dart';
import '../layout/page_painter.dart';
import '../layout/paginator.dart';
import '../layout/reader_typography.dart';

/// Lê o capítulo (item do spine) [spine].
typedef ChapterLoader = Future<ChapterContent> Function(int spine);

/// Lê os capítulos do arquivo [path] num isolate (o fecho leva só o caminho).
ChapterLoader isolateChapterLoader(String path) =>
    (spine) => Isolate.run(() => loadChapter(path, spine));

/// Prioridades das fatias: o capítulo atual, o seguinte, o anterior.
const int _current = 3;
const int _nextPriority = 2;
const int _previousPriority = 1;

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

  /// 1º caractere visível (no texto canônico do capítulo) — o que a posição salva guarda.
  int get firstVisible => page.start;
}

/// Chave do cache de páginas para um livro num viewport.
final class PagerCacheKey {
  const PagerCacheKey({
    required this.userBookId,
    required this.viewport,
    required this.dao,
  });

  final String userBookId;

  /// `<largura>x<altura>@<dpr>`.
  final String viewport;
  final PageLayoutCacheDao dao;
}

final class _Chapter {
  _Chapter(this.content);

  final ChapterContent content;
  ChapterLayoutJob? job;
  ({ReaderPage page, List<LaidBlock> blocks, int firstBlock})? quick;

  ChapterLayout? get layout => (job?.done ?? false) ? job!.result : null;

  List<ReaderPage> get pages => job?.pagesSoFar ?? const [];

  void dispose(LayoutScheduler s) {
    final j = job;
    if (j != null) {
      s.cancel(j);
      j.dispose();
    }
    job = null;
    _disposeQuick();
  }

  void _disposeQuick() {
    final q = quick;
    if (q != null) {
      for (final b in q.blocks) {
        b.dispose();
      }
    }
    quick = null;
  }
}

final class BookPager {
  BookPager({
    required this.index,
    required this._load,
    required ReaderTypography typography,
    required this._scheduler,
    this._cache,
    DateTime Function()? now,
  }) : _t = typography,
       _now = now ?? DateTime.now,
       _linear = [
         for (var i = 0; i < index.spine.length; i++)
           if (index.spine[i].linear) i,
       ];

  final BookIndex index;
  final ChapterLoader _load;
  final LayoutScheduler _scheduler;
  PagerCacheKey? _cache;
  final DateTime Function() _now;
  final List<int> _linear;
  ReaderTypography _t;

  final Map<int, _Chapter> _chapters = {};
  final Map<int, Future<_Chapter>> _loading = {};
  PageBreaks? _breaks;
  bool _breaksRead = false;
  PagerPosition? _position;

  /// O caractere que a pessoa "está lendo": o pedido em [openAt] ou o 1º da página para onde ela virou. Mudar
  /// os ajustes várias vezes seguidas volta sempre a ele — e não ao começo da página do layout anterior, que
  /// andaria para trás a cada mudança.
  ({int spine, int offset})? _anchor;
  bool _disposed = false;

  ReaderTypography get typography => _t;
  PagerPosition? get position => _position;

  /// O caractere que a pessoa está lendo (o que a posição salva deve guardar — ver [_anchor]).
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

  /// Abre na página que contém o caractere [offset] do capítulo [spine].
  Future<PagerPosition> openAt(int spine, int offset) {
    _anchor = (spine: spine, offset: offset);
    return _open(spine, offset);
  }

  Future<PagerPosition> _open(int spine, int offset) async {
    final ch = await _chapter(spine);
    _ensureJob(ch, _current);
    final starts = await _cachedStarts(spine);
    if (starts != null && ch.layout == null && starts.isNotEmpty) {
      var k = 0;
      for (var i = 0; i < starts.length; i++) {
        if (starts[i] <= offset) k = i;
      }
      final q = layoutPageFrom(ch.content, _t, starts[k]);
      if (q != null) {
        ch.quick = q;
        _position = PagerPosition(spine: spine, page: q.page, pageIndex: null);
        _neighbors(spine);
        return _position!;
      }
    }
    final job = ch.job!;
    await _scheduler.waitFor(
      () =>
          job.done ||
          (job.pagesSoFar.isNotEmpty && job.pagesSoFar.last.end > offset),
    );
    if (ch.pages.isEmpty) {
      // capítulo sem nada para mostrar: o seguinte (ou o anterior, no fim do livro)
      _position = PagerPosition(
        spine: spine,
        page: const ReaderPage([], start: 0, end: 0),
        pageIndex: 0,
      );
      if (await next() || await previous()) return _position!;
      throw StateError('livro sem texto para mostrar');
    }
    _position = _containing(spine, ch, offset);
    _neighbors(spine);
    return _position!;
  }

  /// Próxima página (atravessa capítulos). `false` = fim do livro.
  Future<bool> next() async {
    final pos = await _settled();
    final ch = _chapters[pos.spine]!;
    final i = pos.pageIndex!;
    final job = ch.job!;
    await _scheduler.waitFor(() => job.done || job.pagesSoFar.length > i + 1);
    if (ch.pages.length > i + 1) {
      _turnedTo(
        PagerPosition(
          spine: pos.spine,
          page: ch.pages[i + 1],
          pageIndex: i + 1,
        ),
      );
      return true;
    }
    var s = pos.spine;
    while (true) {
      final n = _neighbor(s, 1);
      if (n == null) return false;
      final nc = await _chapter(n);
      final nj = _ensureJob(nc, _current);
      await _scheduler.waitFor(() => nj.done || nj.pagesSoFar.isNotEmpty);
      if (nc.pages.isNotEmpty) {
        _turnedTo(PagerPosition(spine: n, page: nc.pages.first, pageIndex: 0));
        _neighbors(n);
        return true;
      }
      s = n; // capítulo sem texto: segue
    }
  }

  /// Página anterior (atravessa capítulos). `false` = começo do livro.
  Future<bool> previous() async {
    final pos = await _settled();
    final i = pos.pageIndex!;
    final ch = _chapters[pos.spine]!;
    if (i > 0) {
      _turnedTo(
        PagerPosition(
          spine: pos.spine,
          page: ch.pages[i - 1],
          pageIndex: i - 1,
        ),
      );
      return true;
    }
    var s = pos.spine;
    while (true) {
      final p = _neighbor(s, -1);
      if (p == null) return false;
      final pc = await _chapter(p);
      final layout = await _scheduler.run(
        _ensureJob(pc, _current),
        priority: _current,
      );
      if (layout.pages.isNotEmpty) {
        _turnedTo(
          PagerPosition(
            spine: p,
            page: layout.pages.last,
            pageIndex: layout.pages.length - 1,
          ),
        );
        _neighbors(p);
        return true;
      }
      s = p;
    }
  }

  /// Ajustes ou tela mudaram: repagina e volta para a página que contém o caractere que a pessoa está lendo
  /// (o 1º visível quando ela chegou nesta página).
  Future<PagerPosition> relayout(ReaderTypography t, {String? viewport}) {
    final anchor = _anchor;
    for (final c in _chapters.values) {
      c.dispose(_scheduler);
    }
    _t = t;
    final cache = _cache;
    if (viewport != null && cache != null) {
      _cache = PagerCacheKey(
        userBookId: cache.userBookId,
        viewport: viewport,
        dao: cache.dao,
      );
    }
    _breaks = null;
    _breaksRead = false;
    return _open(anchor?.spine ?? firstSpine, anchor?.offset ?? 0);
  }

  /// Pinta a página atual (sem o papel e o rodapé, que são da tela).
  void paintCurrent(ui.Canvas c, {ReaderImageOf? imageOf}) {
    final pos = _position;
    if (pos == null) return;
    final ch = _chapters[pos.spine]!;
    final q = ch.quick;
    paintReaderPage(
      c,
      pos.page,
      (b) => q != null && pos.pageIndex == null
          ? q.blocks[b - q.firstBlock]
          : ch.job!.blocksSoFar[b],
      _t,
      imageOf: imageOf,
    );
  }

  /// Espera o capítulo atual ficar todo paginado (testes e medidas).
  Future<ChapterLayout?> settle() async {
    final pos = _position;
    if (pos == null) return null;
    await _settled();
    final job = _chapters[pos.spine]?.job;
    return job == null ? null : _scheduler.run(job, priority: _current);
  }

  void dispose() {
    _disposed = true;
    for (final c in _chapters.values) {
      c.dispose(_scheduler);
    }
    _chapters.clear();
  }

  // ------------------------------------------------------------------------------------------------------

  /// Virou página: a posição nova e o caractere que a pessoa passa a ler.
  void _turnedTo(PagerPosition p) {
    _position = p;
    _anchor = (spine: p.spine, offset: p.firstVisible);
  }

  /// Posição com o índice da página conhecido (a página do cache vira a do layout completo).
  Future<PagerPosition> _settled() async {
    final pos = _position!;
    if (pos.pageIndex != null) return pos;
    final ch = _chapters[pos.spine]!;
    final layout = await _scheduler.run(ch.job!, priority: _current);
    final cur = _position!;
    if (cur.pageIndex == null && cur.spine == pos.spine) {
      final i = layout.pageAt(cur.page.start);
      _position = PagerPosition(
        spine: cur.spine,
        page: layout.pages[i],
        pageIndex: i,
      );
      ch._disposeQuick();
    }
    return _position!;
  }

  PagerPosition _containing(int spine, _Chapter ch, int offset) {
    final pages = ch.pages;
    if (pages.isEmpty) {
      throw StateError('capítulo $spine sem páginas');
    }
    var i = 0;
    for (var k = 0; k < pages.length; k++) {
      if (pages[k].start <= offset) i = k;
    }
    return PagerPosition(spine: spine, page: pages[i], pageIndex: i);
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

  /// Mantém montados só o capítulo atual e os vizinhos; põe os vizinhos na fila com prioridade menor.
  void _neighbors(int spine) {
    final next = _neighbor(spine, 1);
    final prev = _neighbor(spine, -1);
    final keep = {spine, ?next, ?prev};
    for (final s in _chapters.keys.toList()) {
      if (!keep.contains(s)) _chapters.remove(s)!.dispose(_scheduler);
    }
    final cur = _chapters[spine];
    if (cur?.job case final j?) _scheduler.prioritize(j, _current);
    if (next != null) unawaited(_prefetch(next, _nextPriority));
    if (prev != null) unawaited(_prefetch(prev, _previousPriority));
  }

  Future<void> _prefetch(int spine, int priority) async {
    try {
      final c = await _chapter(spine);
      final pos = _position;
      final still =
          pos != null &&
          (spine == _neighbor(pos.spine, 1) ||
              spine == _neighbor(pos.spine, -1));
      if (_disposed || !still) {
        // a pessoa já saiu daqui enquanto o capítulo carregava
        if (pos?.spine != spine) _chapters.remove(spine)?.dispose(_scheduler);
        return;
      }
      _ensureJob(c, priority);
    } on Object {
      // capítulo vizinho que não abre: o erro aparece quando a pessoa chegar nele
    }
  }

  Future<_Chapter> _chapter(int spine) {
    final have = _chapters[spine];
    if (have != null) return Future.value(have);
    return _loading[spine] ??= _load(spine).then(
      (content) {
        _loading.remove(spine);
        return _chapters[spine] ??= _Chapter(content);
      },
      onError: (Object e, StackTrace st) {
        _loading.remove(spine);
        return Future<_Chapter>.error(e, st);
      },
    );
  }

  ChapterLayoutJob _ensureJob(_Chapter ch, int priority) {
    var job = ch.job;
    if (job == null) {
      job = ChapterLayoutJob(ch.content, _t);
      ch.job = job;
      final spine = ch.content.spineIndex;
      final mine = job;
      unawaited(
        _scheduler
            .run(job, priority: priority)
            .then((layout) => _laidOut(spine, mine, layout)),
      );
    } else {
      _scheduler.prioritize(job, priority);
    }
    return job;
  }

  Future<void> _laidOut(
    int spine,
    ChapterLayoutJob job,
    ChapterLayout layout,
  ) async {
    final ch = _chapters[spine];
    // o capítulo foi descartado ou repaginado (outros ajustes) antes desta conclusão chegar
    if (ch == null || !identical(ch.job, job)) return;
    final pos = _position;
    if (pos != null && pos.spine == spine && pos.pageIndex == null) {
      final i = layout.pageAt(pos.page.start);
      _position = PagerPosition(
        spine: spine,
        page: layout.pages[i],
        pageIndex: i,
      );
      ch._disposeQuick();
    }
    await _saveStarts(spine, layout.pageStarts);
  }

  Future<List<int>?> _cachedStarts(int spine) async {
    final key = _cache;
    if (key == null) return null;
    if (!_breaksRead) {
      _breaksRead = true;
      final b = await key.dao.get(
        userBookId: key.userBookId,
        settingsHash: settingsHash,
        viewport: key.viewport,
        fontsVersion: readerFontsVersion,
      );
      _breaks = b != null && b.sha == index.contentSha256 ? b : null;
    }
    return _breaks?.chapters[spine];
  }

  Future<void> _saveStarts(int spine, List<int> starts) async {
    final key = _cache;
    if (key == null || _disposed) return;
    final current = _breaks;
    final merged = PageBreaks(
      sha: index.contentSha256,
      chapters: {...?current?.chapters, spine: starts},
    );
    _breaks = merged;
    _breaksRead = true;
    try {
      await key.dao.put(
        userBookId: key.userBookId,
        settingsHash: settingsHash,
        viewport: key.viewport,
        fontsVersion: readerFontsVersion,
        breaks: merged,
        now: _now(),
      );
    } on Object {
      // cache é só atalho: sem ele, o próximo abrir pagina o capítulo
    }
  }
}
