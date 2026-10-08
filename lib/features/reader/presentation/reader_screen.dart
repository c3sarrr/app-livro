// G11.3 — tela 19, o leitor limpo (`/leitor/:bookId`, L19): a página do livro sobre o papel, o rodapé
// "pág. X de Y · %" e nada mais. Por trás, a sessão de leitura (abrir, falhas, tempo, posição, tela acesa,
// links). A barra de status some com a página na tela (D-105) e volta no "abrindo", nos erros e ao sair; o
// Voltar do Android fecha gravando a posição; segundo plano pausa o tempo e grava (ciclo de vida). Leitor de
// tela: "Título, página X de Y", o texto da página e as ações Próxima/Anterior (Anexo 03 §11).
// G12.3 — telas 20/26b: o toque no centro abre os controles (D-117) por cima da página — véu, ilha de cima, chip
// de tempo e ilha de baixo —; o toque fora das ilhas e o arrasto fecham; o Voltar fecha primeiro os controles
// (D-42). Com os controles abertos a barra de status volta; no Noite, com ícones claros (D-124). O Tema troca o
// papel e as ilhas em 220 ms (D-121); a barra de posição salta (D-119); os botões das próximas fases mostram
// "Chega numa próxima fase" por 2 s (D-118). G12.4 — a lupa abre a busca no livro (D-120): o Voltar fecha
// primeiro o painel, depois os controles.
// G13.3 — tela 21: a pressão longa seleciona a palavra (com um toque de vibração) e mostra as alças e a barra de
// ações; com a seleção na tela, o toque fora fecha, o arrasto fecha e vira, o Voltar fecha (D-136). O toque num
// grifo abre a barra dele com a cor marcada (D-132), sem alças nem fundo (D-137). Os grifos do livro são pintados
// por trás das letras. As ações da barra vão uma de cada vez; "Grifo apagado · Desfazer" some na próxima ação (com o
// leitor de tela, só nela — D-139).
// G14.4 — tela 26: "Aa Fonte" abre a folha de ajustes por cima (os controles somem e voltam ao fechar — D-142);
// fecha pelo ×, pelo Voltar, pelo toque na página de cima ou puxando a alça (D-141); cada toque grava e repagina
// (D-144). No PDF a Fonte segue desabilitada (D-122).
// G16.6 — tela 22: "Anotar" (no EPUB) fecha os controles e abre o modo anotação sobre a página atual, em modo
// imersivo; no PDF e na página sem texto (só imagem — a tinta não tem onde se prender), "Chega numa próxima fase"
// (D-164, D-170). No modo, a página de baixo não responde (D-167 19) e o rodapé,
// a fita, o chip e a pílula da volta somem (o prazo dela não corre — D-125). Concluir e o Voltar gravam e saem
// (D-42); sem mudanças, só saem; se a gravação falhar, o modo fica com a pílula (D-21) e tocar de novo tenta de novo.
// Marca-texto, Espaço, o poço de cor e o 2º toque na ativa mostram o aviso (D-163). A tinta salva aparece na página
// (`ReaderInk`, junto dos grifos); o rascunho de uma sessão que morreu é gravado ao abrir o livro (D-166) e o do modo
// aberto vai ao banco quando o app vai para o segundo plano.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/semantics.dart'
    show CustomSemanticsAction, SemanticsService;
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, HapticFeedback, SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/preferences/brand_preference.dart';
import '../../shell/presentation/main_shell.dart';
import '../annotations/domain/annotation.dart' show HighlightStyle;
import '../annotations/ink/ink_geometry.dart' show InkRect;
import '../annotations/ink_repository.dart';
import '../application/annotation_session.dart';
import '../application/ink_page_geometry.dart';
import '../application/pdf_reader_document.dart';
import '../application/highlight_labels_store.dart';
import '../application/pen_presets_store.dart';
import '../application/reader_annotations.dart';
import '../application/reader_chrome.dart';
import '../application/reader_document.dart';
import '../application/reader_errors.dart';
import '../application/reader_ink.dart';
import '../application/reader_providers.dart';
import '../application/reader_session_controller.dart';
import '../application/reader_toc.dart';
import '../application/toc_view.dart';
import '../domain/reader_settings.dart';
import 'annotation_island.dart' show AnnotationIsland;
import 'annotation_mode.dart';
import 'book_search_panel.dart';
import 'bottom_island.dart';
import 'highlight_toolbar.dart';
import 'ink_painter.dart' show handHighlightBoxes;
import 'labels_sheet.dart';
import 'note_sheet.dart';
import 'other_color_sheet.dart';
import 'page_marks.dart' show PaintedHighlight;
import 'reader_actions.dart';
import 'reader_chrome_palette.dart';
import 'reader_chrome_scope.dart';
import 'reader_controls.dart';
import 'reader_footer.dart';
import 'reader_overlays.dart';
import 'reader_page_view.dart';
import 'reader_palette.dart';
import 'reader_settings_sheet.dart';
import 'reader_states.dart';
import 'selection_controller.dart';
import 'selection_layer.dart';
import 'time_chip.dart';
import 'toc_sheet.dart';
import 'top_island.dart';

/// No Noite a barra de status tem ícones claros (D-124); nos claros, o padrão do app (D-13).
/// A região vale para a tela toda: no Android, a barra de navegação (transparente, sem véu) também ganha ícones
/// claros, senão os botões somem no papel escuro.
const SystemUiOverlayStyle readerNightOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Color(0x00000000),
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0x00000000),
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.bookId});

  /// `user_books.id` do livro na estante.
  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  ReaderSessionController? _c;
  AppLifecycleListener? _life;
  ReaderSystemUi? _ui;
  ReaderViewport? _viewport;
  bool _started = false;
  bool _depsFailed = false;
  bool _showOpening = false;
  Timer? _openingTimer;
  bool _immersive = false;

  /// Os controles da tela 20 estão abertos (D-117).
  bool _controls = false;

  /// O que as ilhas mostram, do documento aberto agora.
  ReaderChrome? _chrome;
  ReaderDocument? _chromeDoc;

  /// "Chega numa próxima fase" na tela (D-118) e se ele nasceu com os controles abertos (fica dentro deles e some
  /// com eles); senão fica 12 acima do rodapé ("Trecho copiado", "Outra cor" — G13).
  String? _toast;
  Timer? _toastTimer;
  bool _toastWithControls = false;

  /// "Grifo apagado · Desfazer" (D-132): o que o apagar levou, por 4 s ou até a próxima ação (D-139).
  RemovedHighlight? _undo;
  Timer? _undoTimer;

  /// Uma ação da barra em curso: as outras esperam (dois toques rápidos não gravam duas vezes).
  bool _busy = false;

  /// A pressão longa em curso criou a seleção: só então arrastar sem soltar cresce o trecho.
  bool _pressSelected = false;

  /// A folha da nota aberta (D-131): o trecho, o grifo existente (se houver) e o texto da nota dele.
  ({ReaderRange range, String? highlightId, String initial})? _note;

  /// A folha "Outra cor" aberta (D-178): o trecho, o grifo tocado e a cor de começo.
  ({ReaderRange range, String? highlightId, String initial})? _otherColor;

  /// O Tema anima (D-121) só depois que a primeira página apareceu: abrir já no Noite não passa pelo Creme.
  bool _themeAnimates = false;

  /// O painel da busca está aberto (D-120) e a busca do documento aberto (a última fica guardada).
  bool _search = false;
  BookSearchSession? _searchSession;

  /// A folha de ajustes da tela 26 está aberta (G14): os controles ficam por baixo, escondidos (D-142).
  bool _settings = false;

  /// A folha do sumário (telas 27/27b — G15) está aberta, e os dados dela (um por abertura; os controles ficam por
  /// baixo, escondidos, como com a folha de ajustes).
  bool _toc = false;
  ReaderToc? _tocData;

  /// O que a folha do sumário ouve quando não há dados (fechada).
  final ChangeNotifier _noToc = ChangeNotifier();
  bool _leaving = false;
  ReaderState? _lastState;

  /// A seleção da tela 21 (G13) e os grifos do livro aberto (só no EPUB — D-134).
  final SelectionController _selection = SelectionController();
  ReaderAnnotations? _annotations;

  /// A tinta salva do livro aberto e onde ela grava (G16 — só no EPUB).
  ReaderInk? _ink;
  InkRepository? _inkRepository;

  /// O modo anotação (tela 22 — G16): a sessão sobre o retrato da página. [_annOpen] fica `false` enquanto a camada
  /// sai (o texto sobe 30 px); [_annStarting] e [_annSaving] seguram toques repetidos.
  _Annotating? _ann;
  bool _annOpen = false;

  /// A folha "Rótulos" aberta sobre o painel do marca-texto (D-177).
  bool _labelsOpen = false;
  bool _annStarting = false;
  bool _annSaving = false;

  /// O documento na tela, quando há um.
  ReaderDocument? get _doc => switch (_c?.state) {
    ReaderReady(:final document) => document,
    _ => null,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _ui = ref.read(readerSystemUiProvider);
    _armOpening();
    // só o que a página usa (MediaQuery.of inteira refaria a tela a cada quadro do teclado da busca)
    final v = _viewport = (
      size: MediaQuery.sizeOf(context),
      padding: MediaQuery.viewPaddingOf(context),
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    unawaited(_start(v));
  }

  /// "Abrindo o livro…" só depois de 300 ms (D-113) — de novo a cada abertura ("Tentar de novo").
  void _armOpening() {
    _openingTimer?.cancel();
    _showOpening = false;
    _openingTimer = Timer(readerOpeningDelay, () {
      if (mounted) setState(() => _showOpening = true);
    });
  }

  Future<void> _start(ReaderViewport v) async {
    final ReaderDeps deps;
    try {
      deps = await ref.read(readerDepsProvider.future);
    } on Object catch (e, st) {
      reportReaderError(e, st);
      if (mounted) setState(() => _depsFailed = true);
      return;
    }
    if (!mounted) return;
    final c = ReaderSessionController(userBookId: widget.bookId, deps: deps)
      ..addListener(_changed);
    _life = AppLifecycleListener(
      onStateChange: (s) {
        unawaited(c.lifecycle(s));
        // o rascunho do modo anotação vai ao banco no segundo plano (D-166)
        if (s != AppLifecycleState.resumed) {
          unawaited(_ann?.session.toBackground());
        }
      },
    );
    setState(() => _c = c);
    await c.open(v);
  }

  /// As dependências do leitor não vieram (banco, pasta): "Tentar de novo" pede de novo.
  void _retryDeps() {
    final v = _viewport;
    if (v == null) return;
    ref.invalidate(readerDepsProvider);
    setState(() => _depsFailed = false);
    _armOpening();
    unawaited(_start(v));
  }

  void _changed() {
    if (!mounted) return;
    final state = _c?.state;
    final before = _lastState;
    _lastState = state;
    final ready = state is ReaderReady;
    if (state is ReaderReady) {
      _ensureChrome(state.document);
      _chrome?.pageChanged();
      _keepSelectionOn(state.document.current);
    } else {
      _selection.clear();
      _note = null;
      _otherColor = null;
      _dropAnnotation();
    }
    if (state is! ReaderReady && (_controls || _search || _settings || _toc)) {
      // o livro deixou de estar na tela (erro, reabertura): os controles, a busca e as folhas fecham
      _controls = false;
      _search = false;
      _settings = false;
      _toc = false;
      _tocData?.dispose();
      _tocData = null;
      _chrome?.ticking = false;
      _clearToast();
    }
    if (ready && !_themeAnimates) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _themeAnimates = true,
      );
    }
    if (ready && before is! ReaderReady) {
      // a página apareceu: conta como leitura e liga a tela acesa (depois, só toques e o ciclo de vida)
      _openingTimer?.cancel();
      _c!.setVisible(true);
    }
    if (state is ReaderOpening && before != null && before is! ReaderOpening) {
      _armOpening();
    }
    if (state is ReaderReady &&
        state.back != null &&
        (before is! ReaderReady || before.back == null)) {
      _announceBack(state.back!.refPage);
    }
    _systemUi(
      immersive: ready && !_controls && !_search && !_settings && !_toc,
    );
    _holdBack();
    setState(() {});
  }

  /// Um `ReaderChrome` (e uma busca) por documento aberto ("Tentar de novo" abre outro).
  void _ensureChrome(ReaderDocument doc) {
    final c = _c;
    if (c == null || identical(_chromeDoc, doc)) return;
    _chrome?.dispose();
    _searchSession?.dispose();
    _searchSession = BookSearchSession(
      doc,
      startTimer: c.deps.startTimer,
      onError: c.deps.onError,
    );
    _chromeDoc = doc;
    _selection.clear();
    _annotations?.dispose();
    final anchors = doc.anchors;
    _annotations = anchors == null
        ? null
        : ReaderAnnotations(
            db: c.deps.db,
            versioning: c.deps.versioning,
            owner: c.deps.owner,
            userBookId: widget.bookId,
            anchors: anchors,
            onError: c.deps.onError,
          );
    unawaited(_annotations?.load());
    // a tinta salva (G16): ao abrir, o rascunho de uma sessão que morreu é gravado (D-166)
    _dropAnnotation();
    _ink?.dispose();
    final notes = _annotations;
    final repo = _inkRepository ??=
        c.deps.inkRepository ??
        DriftInkRepository(
          c.deps.db,
          c.deps.versioning,
          now: c.deps.now,
          onError: c.deps.onError,
        );
    _ink = anchors == null || notes == null
        ? null
        : ReaderInk(
            db: c.deps.db,
            repository: repo,
            owner: c.deps.owner,
            userBookId: widget.bookId,
            anchors: anchors,
            annotations: notes,
            onError: c.deps.onError,
          );
    unawaited(_ink?.load());
    _chrome = ReaderChrome(
      db: c.deps.db,
      userBookId: widget.bookId,
      refPage: () => doc.numbers.refPage,
      minutes: c.minutesToday,
      timeLeft: c.timeLeft,
      startTimer: c.deps.startTimer,
      onError: c.deps.onError,
    )..ticking = _controls;
  }

  /// A seleção fica presa à página (D-47): a página mudou e ela não está mais nela → some. O grifo existente pode
  /// passar da página: basta tocá-la.
  void _keepSelectionOn(DisplayPage page) {
    final s = _selection.selection;
    if (s == null) return;
    final r = s.range;
    final shown = page.shown;
    final keep =
        shown != null &&
        r.unit == shown.unit &&
        (s.highlightId == null
            ? r.from >= shown.from && r.to <= shown.to
            : r.from < shown.to && r.to > shown.from);
    if (!keep) _selection.clear();
  }

  // ---- seleção (G13) ------------------------------------------------------------------------------------

  /// Pressão longa (D-45, D-136): com os controles abertos só os fecha; numa palavra, seleciona com um toque de
  /// vibração; fora das letras, nada.
  void _longPressStart(Offset p) {
    _pressSelected = false;
    if (_controls) {
      _setControls(false);
      return;
    }
    final w = _doc?.current.wordAt(p);
    if (w == null) return;
    _dismissUndo();
    unawaited(HapticFeedback.selectionClick());
    _selection.selectWord(w);
    _pressSelected = true;
  }

  /// Arrastar sem soltar: o fim vai por palavra; o começo fica (D-136). Só quando esta pressão selecionou.
  void _longPressMove(Offset p) {
    final s = _selection.selection;
    final anchor = s?.anchor;
    final doc = _doc;
    if (!_pressSelected || s == null || anchor == null || doc == null) return;
    _selection.setRange(extendFrom(doc.current, anchor, p));
  }

  /// Com a seleção na tela, tocar fora dela fecha; dentro, nada (D-136).
  void _tapSelecting(Offset p) {
    final r = _selection.value;
    final doc = _doc;
    if (r == null || doc == null) return;
    final inside = doc.current
        .boxesOf(r.unit, r.from, r.to)
        .any((b) => b.rect.contains(p));
    if (!inside) _selection.clear();
  }

  /// O toque num grifo abre a barra dele (D-132); `false` = não era grifo (valem os terços).
  bool _tapHighlight(Offset p) {
    final notes = _annotations;
    final page = _doc?.current;
    final s = page?.spotAt(p);
    if (notes == null || page == null || s == null) return false;
    for (final o in [s.offset, s.offset - 1]) {
      final h = notes.highlightAt((unit: s.unit, offset: o));
      if (h == null) continue;
      final over = page
          .boxesOf(h.range.unit, h.range.from, h.range.to)
          .any((b) => b.rect.contains(p));
      if (!over) continue;
      _dismissUndo();
      _selection.showHighlight(h.id, h.range);
      return true;
    }
    return false;
  }

  /// A barra de ações da seleção (L21b); no grifo existente, a cor dele marcada (D-132).
  Widget _toolbar(ReaderChromePalette islands) {
    final id = _selection.selection?.highlightId;
    final a = id == null ? null : _annotations?.byId(id);
    return HighlightToolbar(
      palette: islands,
      marked: a == null ? null : (color: a.color!, style: a.style!),
      onColor: (hex) => _act(() => _color(hex)),
      // a folha "Outra cor" com o seletor da tela 23 (D-178)
      onOtherColor: () => _act(_openOtherColor),
      onUnderline: () => _act(_underline),
      onNote: () => _act(_openNote),
      onCopy: () => _act(_copy),
      onShare: (origin) => _act(() => _share(origin)),
      onSearch: _searchSelection,
    );
  }

  /// Uma ação da barra de cada vez: enquanto uma grava, as outras não fazem nada.
  void _act(Future<void> Function() f) {
    if (_busy) return;
    _busy = true;
    unawaited(
      f().whenComplete(() {
        _busy = false;
      }),
    );
  }

  // ---- ações da barra (G13.4) ---------------------------------------------------------------------------

  /// Uma cor: na seleção nova, grifa e guarda a última cor (D-130); no grifo existente, troca a cor ou, na cor
  /// marcada, apaga com desfazer (D-132).
  Future<void> _color(String hex) async {
    final notes = _annotations;
    final s = _selection.selection;
    if (notes == null || s == null) return;
    _dismissUndo();
    final id = s.highlightId;
    if (id != null) {
      final a = notes.byId(id);
      if (a == null) return;
      if (a.style == HighlightStyle.fill && a.color == hex) {
        await _remove(id);
        return;
      }
      await notes.restyle(id, color: hex, style: HighlightStyle.fill);
    } else {
      await notes.addHighlight(s.range, color: hex, style: HighlightStyle.fill);
    }
    await notes.setLastColor(hex);
    if (mounted) _selection.clear();
  }

  /// Sublinhar (D-130): na seleção nova, na última cor; no grifo existente, vira sublinhado na cor dele ou, já
  /// sublinhado, apaga com desfazer (D-132).
  Future<void> _underline() async {
    final notes = _annotations;
    final s = _selection.selection;
    if (notes == null || s == null) return;
    _dismissUndo();
    final id = s.highlightId;
    if (id != null) {
      final a = notes.byId(id);
      if (a == null) return;
      if (a.style == HighlightStyle.underline) {
        await _remove(id);
        return;
      }
      await notes.restyle(id, color: a.color!, style: HighlightStyle.underline);
    } else {
      await notes.addHighlight(
        s.range,
        color: await notes.lastColor(),
        style: HighlightStyle.underline,
      );
    }
    if (mounted) _selection.clear();
  }

  /// Nota (D-131): a folha com o trecho; num grifo existente, com o texto da nota dele; numa seleção nova que vai
  /// unir ou cobrir um grifo com nota, com a nota que vai ficar (D-138).
  Future<void> _openNote() async {
    final s = _selection.selection;
    final notes = _annotations;
    if (s == null || notes == null) return;
    final id = s.highlightId;
    final initial = id != null
        ? notes.noteOf(id)
        : await notes.notePreview(
            s.range,
            color: await notes.lastColor(),
            style: HighlightStyle.fill,
          );
    // a seleção mudou enquanto lia: a folha não abre
    if (!mounted || !identical(_selection.selection, s)) return;
    setState(
      () => _note = (range: s.range, highlightId: id, initial: initial ?? ''),
    );
  }

  /// Cancelar ou Voltar: a folha fecha e a seleção continua.
  void _closeNote() => setState(() => _note = null);

  /// "Outra cor" (D-178): a folha com o seletor, na cor do grifo tocado (D-132) ou na última de grifo (D-130).
  Future<void> _openOtherColor() async {
    final s = _selection.selection;
    final notes = _annotations;
    if (s == null || notes == null) return;
    final id = s.highlightId;
    final initial =
        (id == null ? null : notes.byId(id)?.color) ?? await notes.lastColor();
    // a seleção mudou enquanto lia: a folha não abre
    if (!mounted || !identical(_selection.selection, s)) return;
    setState(
      () => _otherColor = (range: s.range, highlightId: id, initial: initial),
    );
  }

  /// Cancelar ou Voltar: a folha fecha e a seleção continua (com a barra).
  void _closeOtherColor() => setState(() => _otherColor = null);

  /// "Grifar" (D-178): na seleção nova, o fundo Médio na cor pela D-32 (D-173); no grifo tocado, a cor dele troca
  /// (D-132). A cor fica como a última de grifo (D-130).
  Future<void> _applyOtherColor(String hex) async {
    final o = _otherColor;
    final notes = _annotations;
    if (o == null || notes == null) return;
    _dismissUndo();
    final id = o.highlightId;
    if (id != null) {
      await notes.restyle(id, color: hex, style: HighlightStyle.fill);
    } else {
      await notes.addHighlight(o.range, color: hex, style: HighlightStyle.fill);
    }
    await notes.setLastColor(hex);
    if (!mounted) return;
    setState(() => _otherColor = null);
    _selection.clear();
  }

  /// Salvar (D-131): na seleção nova, o grifo de fundo na última cor + a nota; no grifo existente, a nota dele
  /// (vazia apaga só a nota).
  /// Se gravar falhar (relatado), a folha fica aberta com o texto.
  Future<void> _saveNote(String text) async {
    final n = _note;
    final notes = _annotations;
    if (n == null || notes == null) return;
    _dismissUndo();
    var id = n.highlightId;
    if (id == null) {
      id = await notes.addHighlight(
        n.range,
        color: await notes.lastColor(),
        style: HighlightStyle.fill,
      );
      if (id == null) return;
      // o grifo já existe: tentar de novo só grava a nota
      if (identical(_note, n)) {
        _note = (range: n.range, highlightId: id, initial: n.initial);
      }
    }
    if (!await notes.saveNote(id, text) || !mounted) return;
    setState(() => _note = null);
    _selection.clear();
  }

  /// Apaga o grifo e mostra "Grifo apagado · Desfazer" por 4 s (D-132); com o leitor de tela, até a próxima ação
  /// (D-139). Não apagou (o grifo já não existia, ou falhou): nada a desfazer.
  Future<void> _remove(String id) async {
    final notes = _annotations;
    final c = _c;
    if (notes == null || c == null) return;
    final token = await notes.remove(id);
    if (!mounted) return;
    _selection.clear();
    if (token == null) return;
    _undoTimer?.cancel();
    _undoTimer = null;
    setState(() => _undo = token);
    if (!MediaQuery.accessibleNavigationOf(context)) {
      _undoTimer = c.deps.startTimer(readerUndoLife, () {
        if (mounted) setState(() => _undo = null);
      });
    }
    _announce(readerRemovedText);
  }

  /// A próxima ação tira o "Desfazer" (D-139): ele não volta um grifo por cima do que veio depois.
  void _dismissUndo() {
    if (_undo == null) return;
    _undoTimer?.cancel();
    _undoTimer = null;
    setState(() => _undo = null);
  }

  /// "Desfazer": o grifo volta com as notas.
  Future<void> _undoRemove() async {
    final token = _undo;
    if (token == null) return;
    _undoTimer?.cancel();
    setState(() => _undo = null);
    await _annotations?.restore(token);
  }

  /// O texto da seleção: do item inteiro (o grifo existente pode passar da página).
  String _selectedText() {
    final r = _selection.value;
    return r == null ? '' : _textOf(r);
  }

  String _textOf(ReaderRange r) {
    final doc = _doc;
    if (doc == null) return '';
    final full = doc.anchors?.textOf(r.unit);
    if (full == null) return doc.current.textOf(r.unit, r.from, r.to);
    return full.substring(
      math.min(r.from, full.length),
      math.min(r.to, full.length),
    );
  }

  /// A citação da D-39, com a página de referência da 1ª letra.
  String? _quote() {
    final r = _selection.value;
    final doc = _doc;
    final anchors = doc?.anchors;
    if (r == null || doc == null || anchors == null) return null;
    return quoteForSharing(
      excerpt: _selectedText(),
      author: doc.author,
      title: doc.title,
      refPage: anchors.placeOf(r.unit, r.from).refPage,
    );
  }

  /// Copiar (D-39): a citação no teclado do sistema e "Trecho copiado" por 2 s; se falhar, relata e não avisa.
  Future<void> _copy() async {
    final text = _quote();
    if (text == null) return;
    _selection.clear();
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } on Object catch (e, st) {
      _c?.deps.onError(e, st);
      return;
    }
    if (mounted) _showToast(readerCopiedText);
  }

  /// Compartilhar (D-39): a mesma citação na folha do sistema (no iPad, saindo do botão).
  Future<void> _share(Rect? origin) async {
    final text = _quote();
    if (text == null) return;
    _selection.clear();
    try {
      await ref.read(readerShareProvider)(text, origin);
    } on Object catch (e, st) {
      _c?.deps.onError(e, st);
    }
  }

  /// Buscar (D-23): o painel da busca com o trecho no campo.
  void _searchSelection() {
    final q = searchPrefill(_selectedText());
    _selection.clear();
    _searchSession?.type(q);
    _openSearch();
  }

  /// Com o leitor de tela, a pílula que apareceu é anunciada (D-116).
  void _announceBack(int refPage) {
    if (!MediaQuery.accessibleNavigationOf(context)) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Voltar à pág. $refPage, no rodapé',
        TextDirection.ltr,
      ),
    );
  }

  /// Esconde a barra de status com a página na tela; devolve o padrão do app (D-13) só se escondeu.
  void _systemUi({required bool immersive}) {
    if (_immersive == immersive) return;
    _immersive = immersive;
    final ui = _ui;
    if (ui == null) return;
    unawaited(immersive ? ui.immersive() : ui.edgeToEdge());
  }

  // ---- fechar ----------------------------------------------------------------------------------------

  /// Abre ou fecha os controles (D-117): a barra de status volta com eles (D-105); o chip conta os minutos
  /// enquanto estão abertos (D-124).
  void _setControls(bool open) {
    if (_controls == open || _leaving) return;
    if (open) {
      _selection.clear();
      _dismissUndo();
    }
    setState(() => _controls = open);
    _chrome?.ticking = open;
    if (!open && _toastWithControls) _clearToast();
    _systemUi(
      immersive:
          _c?.state is ReaderReady && !open && !_search && !_settings && !_toc,
    );
    _holdBack();
  }

  /// A pílula da volta fica escondida com os controles, a busca ou a folha de ajustes por cima: o prazo dela só
  /// conta à vista (D-125).
  void _holdBack() =>
      _c?.holdBack(_controls || _search || _settings || _toc || _ann != null);

  void _tool(ReaderTool t) {
    final c = _c;
    if (c == null) return;
    switch (t) {
      case ReaderTool.theme:
        unawaited(c.toggleTheme());
      case ReaderTool.font:
        _openSettings();
      case ReaderTool.toc:
        _openToc();
      case ReaderTool.annotate:
        // Anotar (G16): o modo anotação no EPUB; no PDF, o aviso (D-164)
        if (_doc is PdfReaderDocument || _ink == null) {
          _showToast(readerSoonText);
        } else {
          unawaited(_openAnnotation());
        }
      case ReaderTool.notes:
        // Grifos → G19 (D-118)
        _showToast(readerSoonText);
    }
  }

  // ---- modo anotação (G16) ------------------------------------------------------------------------------

  /// "Anotar": fecha os controles e abre a sessão sobre a página atual — os desenhos e os grifos dela e o
  /// `pen_presets` —, em modo imersivo; o leitor de tela ouve "Modo anotação. Caneta, ‹cor›.".
  Future<void> _openAnnotation() async {
    final c = _c;
    final doc = _doc;
    final ink = _ink;
    final notes = _annotations;
    final anchors = doc?.anchors;
    final repo = _inkRepository;
    if (c == null ||
        doc == null ||
        ink == null ||
        notes == null ||
        anchors == null ||
        repo == null ||
        _ann != null ||
        _annStarting ||
        _leaving) {
      return;
    }
    _annStarting = true;
    try {
      final owner = await c.deps.owner();
      final store = PenPresetsStore(
        c.deps.db,
        c.deps.versioning,
        now: c.deps.now,
      );
      final presets = await store.load(owner);
      // G17 (D-40, D-177): os rótulos das cores e as contagens de todos os livros, para a 23b
      final labels = HighlightLabelsStore(c.deps.db, c.deps.versioning);
      final labelData = await labels.load(owner);
      if (!mounted || _leaving || !identical(_doc, doc)) return;
      final page = doc.current;
      final shown = page.shown;
      final geometry = inkGeometryOf(page);
      // D-170: sem texto na página, a tinta não tem onde se prender
      if (shown == null || geometry.lines.isEmpty) {
        _showToast(readerSoonText);
        return;
      }
      final highlights = notes.highlightsIn(shown);
      final inkHighlights = notes.inkHighlightsIn(shown);
      final session = AnnotationSession(
        geometry: geometry,
        anchors: anchors,
        drawings: ink.drawingsOn(page),
        highlights: [
          for (final h in highlights)
            (
              id: h.id,
              ink: false,
              areas: [
                for (final b in page.boxesOf(
                  h.range.unit,
                  h.range.from,
                  h.range.to,
                ))
                  InkRect(b.rect.left, b.textTop, b.rect.right, b.textBottom),
              ],
            ),
          for (final h in inkHighlights)
            (
              id: h.id,
              ink: true,
              // a mancha (o fundo); o sublinhado e o ondulado à mão, pela caixa das letras (R23)
              areas: h.style == HighlightStyle.fill
                  ? [
                      for (final (:box, color: _) in handHighlightBoxes(page, [
                        h,
                      ]))
                        InkRect(box.left, box.top, box.right, box.bottom),
                    ]
                  : [
                      for (final b in page.boxesOf(
                        h.range.unit,
                        h.range.from,
                        h.range.to,
                      ))
                        InkRect(
                          b.rect.left,
                          b.textTop,
                          b.rect.right,
                          b.textBottom,
                        ),
                    ],
            ),
        ],
        // G17 (D-173): a mesa — os grifos que tocam a página, para o Marca-texto passar pela D-32
        deskHighlights: notes.deskIn(shown),
        presets: presets,
        repository: repo,
        owner: owner,
        userBookId: widget.bookId,
        startTimer: c.deps.startTimer,
        now: c.deps.now,
        onError: c.deps.onError,
        onInteraction: c.interaction,
        savePresets: store.save,
      )..setLabelData(labels: labelData.labels, counts: labelData.counts);
      _selection.clear();
      _dismissUndo();
      _clearToast();
      _setControls(false);
      setState(() {
        _ann = _Annotating(
          session: session,
          page: page,
          highlights: highlights,
          inkHighlights: inkHighlights,
          owner: owner,
          labels: labels,
        );
        _annOpen = true;
      });
      _systemUi(immersive: true);
      _holdBack();
      _announce(
        'Modo anotação. Caneta, '
        '${AnnotationIsland.colorName(Color(session.color))}.',
      );
    } on Object catch (e, st) {
      c.deps.onError(e, st);
    } finally {
      _annStarting = false;
    }
  }

  /// Concluir e o Voltar (D-42): grava a sessão numa transação e sai (o texto sobe 30 px); sem mudanças, só sai. Se a
  /// gravação falhar, o modo fica com a pílula (D-21) e o rascunho guardado; tocar de novo tenta de novo.
  Future<void> _concludeAnnotation() async {
    final a = _ann;
    if (a == null || !_annOpen || _annSaving) return;
    _annSaving = true;
    try {
      final ok = await a.session.conclude();
      if (!ok || !mounted || !identical(_ann, a)) return;
      _clearToast();
      setState(() => _annOpen = false);
    } finally {
      _annSaving = false;
    }
  }

  void _closeLabels() => setState(() => _labelsOpen = false);

  /// "Salvar" na folha "Rótulos" (D-177): grava, relê e volta ao painel com os rótulos novos.
  Future<void> _saveLabels(_Annotating a, Map<String, String> next) async {
    try {
      await a.labels.save(a.owner, next);
      final d = await a.labels.load(a.owner);
      a.session.setLabelData(labels: d.labels, counts: d.counts);
    } on Object catch (e, st) {
      _c?.deps.onError(e, st);
    }
    if (mounted && identical(_ann, a)) _closeLabels();
  }

  /// A camada terminou de sair: a sessão acaba e o leitor limpo volta a responder.
  void _annotationExited() {
    final a = _ann;
    if (a == null || _annOpen) return;
    _labelsOpen = false;
    setState(() => _ann = null);
    a.session.dispose();
    _holdBack();
    _systemUi(
      immersive:
          _c?.state is ReaderReady &&
          !_controls &&
          !_search &&
          !_settings &&
          !_toc,
    );
  }

  /// O livro saiu da tela com o modo aberto (erro, reabertura, sair): o que estava na sessão vai ao rascunho
  /// (D-166) e ela acaba.
  void _dropAnnotation() {
    final a = _ann;
    if (a == null) return;
    _ann = null;
    _annOpen = false;
    _labelsOpen = false;
    unawaited(a.session.toBackground().whenComplete(a.session.dispose));
  }

  void _showToast(String text) {
    final c = _c;
    if (c == null) return;
    _toastTimer?.cancel();
    setState(() {
      _toast = text;
      _toastWithControls = _controls;
    });
    _toastTimer = c.deps.startTimer(readerToastLife, () {
      if (mounted) setState(() => _toast = null);
    });
    _announce(text);
  }

  /// Com o leitor de tela, o aviso que apareceu é lido.
  void _announce(String text) {
    if (!MediaQuery.accessibleNavigationOf(context)) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        text,
        TextDirection.ltr,
      ),
    );
  }

  void _clearToast() {
    _toastTimer?.cancel();
    _toastTimer = null;
    _toast = null;
  }

  /// A lupa da ilha de cima: o painel da busca por cima de tudo (D-120).
  void _openSearch() {
    if (_searchSession == null || _leaving) return;
    _clearToast();
    _dismissUndo();
    setState(() => _search = true);
    _systemUi(immersive: false);
    _holdBack();
  }

  /// ← do painel ou o Voltar: volta aos controles, que continuam abertos.
  void _closeSearch() {
    if (!_search) return;
    setState(() => _search = false);
    _systemUi(
      immersive: _c?.state is ReaderReady && !_controls && !_settings && !_toc,
    );
    _holdBack();
  }

  /// "Aa Fonte" (G14): a folha de ajustes por cima; os controles somem e voltam ao fechar (D-142); a barra de
  /// status fica (D-105). No PDF a Fonte está desabilitada e a folha não abre (D-122).
  void _openSettings() {
    if (_leaving || _doc is PdfReaderDocument) return;
    // só pela ferramenta Fonte: os controles continuam abertos por baixo (a pílula e a barra de status já seguem
    // por eles; o `_settings` ali é só a garantia)
    assert(_controls, 'a folha abre pela ferramenta Fonte, com os controles');
    _clearToast();
    _dismissUndo();
    setState(() => _settings = true);
    _systemUi(immersive: false);
    _holdBack();
  }

  /// ×, Voltar, o toque na página de cima ou puxar a folha (D-141): cada toque já aplicou e gravou o ajuste;
  /// fechar só volta aos controles.
  void _closeSettings() {
    if (!_settings) return;
    setState(() => _settings = false);
    _systemUi(
      immersive: _c?.state is ReaderReady && !_controls && !_search && !_toc,
    );
    _holdBack();
  }

  /// "Sumário" (G15): a folha das telas 27/27b por cima, sempre na aba Capítulos; os controles somem e voltam ao
  /// fechar (como a folha de ajustes — D-141/D-142); a barra de status fica (D-105).
  void _openToc() {
    final c = _c;
    final doc = _doc;
    if (_leaving || c == null || doc == null) return;
    _clearToast();
    _dismissUndo();
    _tocData?.dispose();
    _tocData = ReaderToc(
      db: c.deps.db,
      userBookId: widget.bookId,
      bookTitle: doc.title,
      place: () {
        final d = _doc ?? doc;
        return (mark: d.mark, refPage: d.numbers.refPage);
      },
      owner: c.deps.owner,
      club: c.deps.club,
      now: () => (c.deps.now ?? DateTime.now)().toUtc(),
      utcOffsetAt: c.deps.utcOffsetAt,
      onError: c.deps.onError,
    );
    setState(() => _toc = true);
    _systemUi(immersive: false);
    _holdBack();
  }

  /// ×, Voltar, o véu ou a alça: volta aos controles. A marca tirada na aba Marcadas some da lista na próxima
  /// abertura (D-152).
  void _closeToc() {
    if (!_toc) return;
    _tocData?.dispose();
    _tocData = null;
    setState(() => _toc = false);
    _systemUi(
      immersive:
          _c?.state is ReaderReady && !_controls && !_search && !_settings,
    );
    _holdBack();
  }

  /// Tocar num capítulo, numa parte ou num cartão (D-151): fecha a folha e os controles e salta para lá, com a volta
  /// (D-119, D-126); o capítulo atual só fecha.
  void _tocGo(ReaderMark? to) {
    final c = _c;
    if (c == null) return;
    final timed = !MediaQuery.accessibleNavigationOf(context);
    _closeToc();
    _setControls(false);
    if (to != null) unawaited(c.jumpTo(to, timed: timed));
  }

  /// A fita do cartão (D-152): tira (o cartão fica com a fita vazia até a folha fechar) ou devolve a mesma marca. A
  /// fita muda na hora (o 2º toque seguido vale o que ela mostra); quando a gravação termina, a folha volta a seguir o
  /// banco (na hora, se falhou).
  void _tocRibbon(TocBookmarkCard card) {
    final c = _c;
    if (c == null) return;
    final on = !card.marked;
    final toc = _tocData;
    final id = card.bookmark.id;
    toc?.want(card.bookmark, on: on);
    unawaited(
      c.setBookmark(card.bookmark, on: on).then((ok) {
        toc?.settle(id, ok: ok);
      }),
    );
  }

  /// Tocar num resultado: fecha o painel e os controles, salta para a ocorrência, marca a palavra e guarda a
  /// volta (D-119, D-120).
  void _pick(SearchHit hit) {
    final c = _c;
    if (c == null) return;
    setState(() => _search = false);
    _setControls(false);
    _systemUi(immersive: c.state is ReaderReady && !_controls);
    _holdBack();
    unawaited(
      c.jumpTo(
        hit.at,
        found: hit.found,
        timed: !MediaQuery.accessibleNavigationOf(context),
      ),
    );
  }

  /// Virar a página (toque, arrasto ou o leitor de tela) também é a próxima ação (D-139).
  Future<bool> _turn(PageDirection d) {
    _dismissUndo();
    return _c!.turn(d);
  }

  /// Fecha o livro: grava, devolve a barra de status já na saída (não no fim da animação) e volta.
  void _leave() {
    if (_leaving) return;
    _leaving = true;
    _systemUi(immersive: false);
    unawaited(_c?.close());
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.inicio);
    }
  }

  @override
  void dispose() {
    _openingTimer?.cancel();
    _toastTimer?.cancel();
    _undoTimer?.cancel();
    _chrome?.dispose();
    _tocData?.dispose();
    _noToc.dispose();
    _searchSession?.dispose();
    _dropAnnotation();
    _ink?.dispose();
    _annotations?.dispose();
    _selection.dispose();
    _life?.dispose();
    _systemUi(immersive: false);
    final c = _c;
    if (c != null) {
      c
        ..removeListener(_changed)
        ..setVisible(false)
        // fecha (grava a posição e o tempo) e solta o livro quando terminar
        ..dispose();
    }
    super.dispose();
  }

  // ---- montagem --------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final paper = c?.paper ?? ReaderPaper.creme;
    final target = c?.palette ?? ReaderPalette.of(ReaderPaper.creme);
    final chrome = c == null ? null : ReaderChromePalette.of(paper);
    final state = c?.state;
    // o Voltar do sistema fecha primeiro os controles (D-42); sem eles, pelo mesmo caminho do "Fechar o livro";
    // sem o gesto de voltar da borda (no iOS ele roubaria o arrasto para a página anterior)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      key: const ValueKey('leitor.barraDeStatus'),
      value: paper == ReaderPaper.noite
          ? readerNightOverlayStyle
          : MainShell.overlayStyle,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_ann != null && _labelsOpen) {
            // a folha "Rótulos" fecha antes do painel (D-42 por camadas)
            _closeLabels();
          } else if (_ann case final a? when a.session.panel.value != null) {
            // com um painel aberto (telas 23 e 23b), o Voltar fecha o painel (D-42 por camadas — R3)
            a.session.closePanel();
          } else if (_ann != null) {
            // no modo anotação, o Voltar é o Concluir (D-42)
            unawaited(_concludeAnnotation());
          } else if (_note != null) {
            _closeNote();
          } else if (_otherColor != null) {
            _closeOtherColor();
          } else if (_search) {
            _closeSearch();
          } else if (_settings) {
            _closeSettings();
          } else if (_toc) {
            _closeToc();
          } else if (_controls) {
            _setControls(false);
          } else if (_selection.active) {
            _selection.clear();
          } else {
            _leave();
          }
        },
        // papel e ilhas trocam em 220 ms no Tema (D-121)
        child: TweenAnimationBuilder<ReaderPalette>(
          tween: ReaderPaletteTween(end: target),
          duration: _themeAnimates ? readerThemeDuration : Duration.zero,
          builder: (context, palette, _) => ColoredBox(
            color: palette.paper,
            child: switch (state) {
              ReaderReady() => _ready(c!, state, palette),
              ReaderFailed(:final failure) => ReaderFailureView(
                failure: failure,
                onBack: _leave,
                onRetry: c!.retry,
                palette: chrome,
              ),
              _ when _depsFailed => ReaderFailureView(
                failure: ReaderFailure.unexpected,
                onBack: _leave,
                onRetry: _retryDeps,
                palette: chrome,
              ),
              ReaderOpening(:final preparing) => ReaderOpeningView(
                visible: _showOpening,
                preparing: preparing,
                palette: chrome,
              ),
              null => ReaderOpeningView(visible: _showOpening),
            },
          ),
        ),
      ),
    );
  }

  Widget _ready(
    ReaderSessionController c,
    ReaderReady state,
    ReaderPalette palette,
  ) {
    final doc = state.document;
    final n = doc.numbers;
    final insets = c.insets;
    final t = c.typography!;
    final back = state.back;
    final brand = ref.watch(brandProvider);
    final chrome = _chrome;
    final search = _searchSession;
    // com o leitor de tela a volta fica até as 2 viradas (D-116)
    final timed = !MediaQuery.accessibleNavigationOf(context);
    return TweenAnimationBuilder<ReaderChromePalette>(
      tween: ReaderChromePaletteTween(end: ReaderChromePalette.of(c.paper)),
      duration: _themeAnimates ? readerThemeDuration : Duration.zero,
      builder: (context, islands, _) => Stack(
        children: [
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _selection,
              builder: (context, _) => ReaderPageView(
                document: doc,
                onTurn: _turn,
                onCenter: () => _setControls(!_controls),
                onLink: (hit) => c.follow(hit, timed: timed),
                onInteraction: c.interaction,
                controlsOpen: _controls,
                onDragStarted: () {
                  _setControls(false);
                  _selection.clear();
                  _dismissUndo();
                },
                foundColor: brand,
                foundLightText: c.palette.lightText,
                highlights: _annotations,
                ink: _ink,
                // no grifo existente, sem fundo de seleção (D-137)
                selection: _selection.fill,
                selectionColor: brand,
                selecting: _selection.active,
                onTapSelecting: _tapSelecting,
                onTapHighlight: _tapHighlight,
                onLongPressStart: _longPressStart,
                onLongPressMove: _longPressMove,
                onLongPressEnd: () => _pressSelected = false,
              ),
            ),
          ),
          // a caixa da página (r19.page): o nó do leitor de tela (sem filho que pegue toque: os toques passam
          // para a página embaixo)
          Positioned(
            left: t.sideMargin,
            top: insets.top,
            width: t.contentWidth,
            height: t.contentHeight,
            child: Semantics(
              key: const ValueKey('r19.page'),
              container: true,
              label: '${doc.title}, página ${n.refPage} de ${n.refTotal}',
              value: doc.current.spokenText,
              customSemanticsActions: {
                const CustomSemanticsAction(label: 'Próxima página'): () =>
                    unawaited(_turn(PageDirection.forward)),
                const CustomSemanticsAction(label: 'Página anterior'): () =>
                    unawaited(_turn(PageDirection.backward)),
                // o centro não é tocável pelo leitor de tela (D-116, D-117)
                CustomSemanticsAction(
                  label: _controls
                      ? 'Esconder os controles'
                      : 'Mostrar os controles',
                ): () =>
                    _setControls(!_controls),
                const CustomSemanticsAction(label: 'Fechar o livro'): _leave,
              },
              child: const SizedBox.expand(),
            ),
          ),
          ReaderFooter(
            numbers: n,
            palette: palette,
            bottom: insets.footerBottom,
          ),
          if (back != null)
            ReaderFooterGap(
              numbers: n,
              bottom: insets.footerBottom,
              // com os controles abertos a pílula fica sob a ilha de baixo: fora do leitor de tela também
              child: ExcludeSemantics(
                excluding: _controls,
                child: BackToPagePill(
                  refPage: back.refPage,
                  onTap: () => unawaited(c.back()),
                  palette: islands,
                ),
              ),
            ),
          // a seleção (G13): alças, lupa e a barra de ações, por cima da página e abaixo dos controles
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _selection,
              builder: (context, _) => SelectionLayer(
                page: doc.current,
                controller: _selection,
                palette: islands,
                paper: palette.paper,
                sideMargin: t.sideMargin,
                contentWidth: t.contentWidth,
                safeTop: MediaQuery.viewPaddingOf(context).top,
                safeBottom: MediaQuery.viewPaddingOf(context).bottom,
                startTimer: c.deps.startTimer,
                pages: () => ReaderPagesPainter(
                  document: doc,
                  dx: 0,
                  dir: null,
                  neighbor: null,
                  foundColor: brand,
                  foundLightText: c.palette.lightText,
                  highlights: _annotations,
                  ink: _ink,
                  selection: _selection.fill,
                  selectionColor: brand,
                ),
                toolbar: _toolbar(islands),
              ),
            ),
          ),
          // os avisos com os controles fechados: 12 acima do rodapé, nas cores das ilhas
          if (!_controls && _ann == null && (_undo != null || _toast != null))
            Positioned(
              left: 14,
              right: 14,
              bottom: insets.footerBottom + readerFooterLine + 12,
              child: ReaderChromeScope(
                palette: islands,
                brand: brand,
                a: 1,
                child: Center(
                  child: _undo != null
                      ? ReaderUndoPill(
                          text: readerRemovedText,
                          onUndo: () => unawaited(_undoRemove()),
                        )
                      : ReaderToastPill(text: _toast!),
                ),
              ),
            ),
          if (chrome != null)
            Positioned.fill(
              child: ListenableBuilder(
                listenable: chrome,
                builder: (context, _) {
                  final toast = _toast;
                  return ReaderControls(
                    open: _controls && !_settings && !_toc,
                    palette: islands,
                    brand: brand,
                    top: TopIsland(
                      title: doc.title,
                      author: doc.author,
                      marked: chrome.marked,
                      onClose: _leave,
                      onSearch: _openSearch,
                      onBookmark: () => unawaited(c.toggleBookmark()),
                    ),
                    chip: TimeChip(label: chrome.chipLabel),
                    bottom: BottomIsland(
                      numbers: n,
                      timeLeftLabel: chrome.timeLeftLabel,
                      notes: chrome.notes,
                      isPdf: doc is PdfReaderDocument,
                      onJump: (page) =>
                          unawaited(c.jumpToPage(page, timed: timed)),
                      onTool: _tool,
                    ),
                    toast: toast == null || !_toastWithControls
                        ? null
                        : ReaderToastPill(text: toast),
                  );
                },
              ),
            ),
          // a folha de ajustes (tela 26): por cima dos controles; a página de cima é a prévia (sem véu)
          if (doc is! PdfReaderDocument)
            Positioned.fill(
              child: ReaderSettingsSheet(
                open: _settings,
                look: c.look,
                palette: islands,
                paper: palette.paper,
                brand: brand,
                page: (
                  left: t.sideMargin,
                  top: insets.top,
                  width: t.contentWidth,
                ),
                pageText: doc.current.spokenText,
                onChange: (change) => unawaited(c.applySettings(change)),
                onClose: _closeSettings,
              ),
            ),
          // a folha do sumário (telas 27/27b): por cima dos controles, com o véu sobre a página
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _tocData ?? _noToc,
              builder: (context, _) => TocSheet(
                open: _toc,
                view: _tocData?.view,
                palette: islands,
                brand: brand,
                onClose: _closeToc,
                onChapter: (r) => _tocGo(r.current ? null : r.target),
                onBookmark: (card) => _tocGo(card.target),
                onRibbon: _tocRibbon,
                // a faixa do clube só existe com clube (a G21 liga); até lá, o aviso da D-118
                onClub: () => _showToast(readerSoonText),
              ),
            ),
          ),
          // o aviso por cima da folha do sumário, 12 acima da base dela
          if (_toc && _toast != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: readerSheetBottom(MediaQuery.viewPaddingOf(context)) + 12,
              child: ReaderChromeScope(
                palette: islands,
                brand: brand,
                a: 1,
                child: Center(child: ReaderToastPill(text: _toast!)),
              ),
            ),
          if (_note case final n?)
            Positioned.fill(
              // a folha cobre a página: o leitor de tela fica nela
              child: BlockSemantics(
                child: NoteSheet(
                  excerpt: cleanExcerpt(_textOf(n.range)),
                  initial: n.initial,
                  palette: islands,
                  paper: palette,
                  brand: brand,
                  onCancel: _closeNote,
                  onSave: (text) => _act(() => _saveNote(text)),
                ),
              ),
            ),
          if (_otherColor case final o?)
            Positioned.fill(
              // a folha cobre a página: o leitor de tela fica nela
              child: BlockSemantics(
                child: OtherColorSheet(
                  initial: o.initial,
                  palette: islands,
                  brand: brand,
                  onCancel: _closeOtherColor,
                  onApply: (hex) => _act(() => _applyOtherColor(hex)),
                ),
              ),
            ),
          if (_search && search != null)
            Positioned.fill(
              // o painel cobre a tela: o leitor de tela não chega ao que está embaixo
              child: BlockSemantics(
                child: BookSearchPanel(
                  session: search,
                  paper: palette,
                  palette: islands,
                  brand: brand,
                  onClose: _closeSearch,
                  onPick: _pick,
                ),
              ),
            ),
          // o modo anotação (tela 22): por cima de tudo; a página de baixo não recebe toque nem enquanto a camada
          // entra e sai (D-167 19)
          if (_ann case final a?) ...[
            const Positioned.fill(
              child: AbsorbPointer(child: SizedBox.expand()),
            ),
            Positioned.fill(
              child: BlockSemantics(
                // a camada repinta sozinha: o leitor limpo embaixo não é repintado a cada quadro do traço
                child: RepaintBoundary(
                  child: AnnotationMode(
                    open: _annOpen,
                    session: a.session,
                    page: a.page,
                    paper: c.paper,
                    brand: brand,
                    sideMargin: t.sideMargin,
                    semanticsLabel:
                        '${doc.title}, página ${n.refPage} de ${n.refTotal} '
                        '— modo anotação',
                    highlights: a.highlights,
                    inkHighlights: a.inkHighlights,
                    toast: _toast,
                    onDone: () => unawaited(_concludeAnnotation()),
                    onSoon: () => _showToast(readerSoonText),
                    onExited: _annotationExited,
                    onEditLabels: () => setState(() => _labelsOpen = true),
                  ),
                ),
              ),
            ),
            if (_labelsOpen)
              Positioned.fill(
                child: BlockSemantics(
                  child: LabelsSheet(
                    labels: a.session.labels,
                    palette: islands,
                    brand: brand,
                    onCancel: _closeLabels,
                    onSave: (m) => unawaited(_saveLabels(a, m)),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// O modo anotação aberto: a sessão, a página travada e os grifos que ela pinta.
final class _Annotating {
  _Annotating({
    required this.session,
    required this.page,
    required this.highlights,
    required this.inkHighlights,
    required this.owner,
    required this.labels,
  });

  final AnnotationSession session;
  final DisplayPage page;
  final List<PaintedHighlight> highlights, inkHighlights;

  /// O dono e os rótulos das cores (a folha "Rótulos" grava por eles — D-177).
  final String owner;
  final HighlightLabelsStore labels;
}
