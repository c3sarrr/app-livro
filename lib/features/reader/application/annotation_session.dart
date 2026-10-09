// G16.3 — a sessão do modo anotação (tela 22, §3): uma por entrada no modo, sobre o retrato da página aberta.
// - Entrada: os eventos crus do `Listener` (coordenadas da tela) passam pelo árbitro de dedos e caneta; os pontos do
//   desenho vão para as coordenadas do leitor limpo (sem os 30 px do modo e sem o deslocamento da página).
// - Caneta: traço suavizado com a ponta, a cor e a espessura do `pen_presets`; com o dedo, a pressão é simulada pela
//   velocidade na captura e gravada no ponto (a caneta do aparelho grava a dela); um toque sem arrastar = 1 ponto.
//   O traço entra no desenho que ele toca, com a folga de meia linha (D-162); o desenho que passaria de 256 KiB
//   fecha e o traço começa outro.
// - Reta: do toque até o dedo, grudada em 15° (menos de 4°); com menos de 4 px não cria nada; grava 2 pontos.
// - Borracha: cada passada (do toque ao soltar) é um passo do desfazer; o que ela toca some já na passada. Só tinta
//   (D-168): os traços e os grifos feitos à mão; o grifo de seleção nem é candidato.
// - Laço: o contorno ao vivo; ao soltar, seleciona os traços com ≥ 50 % dos pontos dentro; arrastar dentro do
//   retângulo (6 px de folga) move ao vivo e grava ao soltar; tocar fora solta; a Borracha com a seleção apaga os
//   selecionados (um passo) e fica ativa (D-46).
// - 2 dedos: a página sobe e desce, com o batente (D-165); ao soltar, volta para dentro dos limites (a tela anima).
// - G18: o Espaço (R1–R9) — o dedo entre as linhas abre o abridor (a costura depois da frase — D-181), o arrasto
//   conta as linhas (1–12 — D-41) e, ao soltar, nasce a nota à mão aberta e a Caneta volta (D-187). A página do modo
//   é refeita com os espaços (`AnnotationPageSource` — R3; o espaço que não cabe fica no pé dela, e a página sobe com
//   2 dedos até ele) e cada desenho anda com as palavras dele — também os que passam do pé, escondidos (pela página
//   mais alta), e o Concluir os ancora nelas. O traço que começa dentro da caixa é da nota (R6, unidade da nota),
//   recortado na borda; o Laço dela move só dentro dela; a nota cheia (256 KiB) não leva mais tinta. A alça (D-186),
//   recolher (D-184) e apagar (D-185) são passos do desfazer (outro passo no meio do arrasto da alça o acaba). Sem a
//   fonte da página, o Espaço não abre (como antes, D-163).
// - G17: os ajustes da caneta e do marca-texto (telas 23 e 23b) gravam o `pen_presets` na hora; os arrastos, ao soltar
//   (R6); as favoritas (D-175); a cor de cada ferramenta e o painel aberto (R1, R2, R4).
// - O Concluir grava as mudanças da sessão numa transação: os desenhos novos e mudados com a âncora refeita sobre o
//   desenho inteiro (D-162), os pontos em em, o grupo dos cartões (Anexo 02 §4.3), os apagados e os grifos à mão
//   apagados. O rascunho vai ao `kv` a cada 5 s com mudanças e no segundo plano (D-166). A falha ao salvar deixa o
//   modo aberto com a pílula (D-21) e o rascunho guardado.
// - Cada toque avisa a sessão de leitura (D-95).
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' show Color, Offset, Rect;

import 'package:flutter/foundation.dart';

import '../../../core/data/ids/uuid_v7.dart';
import '../annotations/domain/annotation.dart'
    show AnnotationSource, FillHeight, HighlightStyle;
import '../annotations/domain/pen_presets.dart';
import '../annotations/ink/bnk1_codec.dart';
import '../annotations/ink/card_groups.dart';
import '../annotations/ink/drawing_anchor.dart';
import '../annotations/ink/drawing_clusters.dart';
import '../annotations/ink/freehand.dart';
import '../annotations/domain/highlight_band.dart';
import '../annotations/ink/gesture_arbiter.dart';
import '../annotations/ink/highlight_desk.dart';
import '../annotations/ink/ink_changes.dart';
import '../annotations/ink/ink_commands.dart';
import '../annotations/ink/ink_geometry.dart';
import '../annotations/ink/ink_stroke.dart';
import '../annotations/ink/ink_tools.dart';
import '../annotations/ink/ink_units.dart';
import '../annotations/ink/marker_snap.dart';
import '../annotations/ink_repository.dart';
import '../annotations/space/hand_note_layout.dart' show inkFrame;
import '../annotations/space/note_ink.dart';
import '../annotations/space/space_metrics.dart';
import '../annotations/space/space_seam.dart';
import '../domain/anchoring.dart' show quoteAt;
import '../domain/locator.dart';
import '../layout/display_page.dart' show DisplayPage, ReaderRange, spacesOf;
import '../layout/space_cut.dart';
import '../presentation/page_marks.dart' show PaintedHighlight;
import 'annotation_anchors.dart';
import 'annotation_page_source.dart';
import 'ink_page_geometry.dart';
import 'reader_errors.dart';

/// O texto desce 30 px no modo anotação (24 da página + 6 do respiro em cima — L22a).
const double annotationTextShift = 30;

/// O rascunho vai ao `kv` a cada tanto, quando há mudanças (D-166).
const Duration inkDraftEvery = Duration(seconds: 5);

/// A folga do retângulo da seleção do Laço (D-21).
const double lassoPadding = 6;

/// As ferramentas da prateleira (L22c), na ordem dela.
enum AnnotationTool { pen, marker, eraser, lasso, line, space }

/// G18 — o id do abridor no fluxo da página (durante o arrasto do Espaço).
const String spaceOpenerId = 'abridor';

/// O abridor durante o arrasto (tela 24): a fresta, as linhas e o dedo (coordenadas do leitor limpo).
typedef SpaceOpening = ({SpaceSeam seam, int lines, InkOffset finger});

/// O dedo precisa andar isto (px) para o abridor aparecer: um toque sem arrastar não abre nada (R2).
const double spaceDragSlop = 8;

/// O limite dos 2 dedos (D-165) com o fim da página em [bottom] (na tela) e a borda de mesa em [deskTop].
double _limitOf(double bottom, double deskTop) =>
    panLimit(lastLineBottom: bottom, deskTop: deskTop);

/// O painel de ajustes aberto (telas 23 e 23b — G17).
enum PanelKind { pen, marker }

/// Quanto fica a pílula "Cor tirada das favoritas" (como "Grifo apagado" — D-132, D-175).
const Duration favoriteUndoLife = Duration(seconds: 4);

/// O painel aberto e a ferramenta de onde ele saiu (a seta aponta para ela).
typedef OpenPanel = ({PanelKind kind, AnnotationTool from});

/// Um desenho salvo na página aberta: o que ele tinha no banco, o trecho dele no texto e os traços já na página
/// (coordenadas do leitor limpo).
typedef PageDrawing = ({
  SavedDrawingRef saved,
  ReaderRange range,
  List<InkStroke> strokes,
});

/// Um grifo da página: o id, se veio da tinta (só esses a Borracha apaga — D-168) e a área pintada em cada linha
/// (coordenadas do leitor limpo).
typedef PageHighlight = ({String id, bool ink, List<InkRect> areas});

/// O que está sendo desenhado agora (coordenadas do leitor limpo).
@immutable
sealed class LiveInk {
  const LiveInk();
}

/// O traço da Caneta, ao vivo.
final class LiveStroke extends LiveInk {
  const LiveStroke(this.stroke);

  final InkStroke stroke;
}

/// O traço do Marca-texto, ao vivo (R20): a linha dos pontos, na largura da faixa da altura e na cor dele a 90 %.
final class LiveMarker extends LiveInk {
  const LiveMarker(this.stroke);

  /// Ferramenta 3, a largura em centésimos de mm (D-159) e a cor com o alfa de 90 %.
  final InkStroke stroke;
}

/// A prévia da Reta (2 pontos, já grudada).
final class LiveLine extends LiveInk {
  const LiveLine(this.stroke);

  final InkStroke stroke;
}

/// O contorno do Laço.
final class LiveLasso extends LiveInk {
  const LiveLasso(this.polygon);

  final List<InkOffset> polygon;
}

/// A seleção do Laço: os traços, a caixa deles e o arrasto em curso ([dx], [dy]).
@immutable
final class LassoSelection {
  const LassoSelection({
    required this.strokes,
    required this.bounds,
    this.dx = 0,
    this.dy = 0,
    this.note,
  });

  final Set<int> strokes;

  /// G18: a nota de onde a seleção saiu (o Laço que começa numa caixa só pega a tinta dela — R6).
  final String? note;

  /// A caixa dos traços selecionados, antes do arrasto.
  final InkRect bounds;
  final double dx;
  final double dy;

  /// O retângulo mostrado (e onde arrastar move): a caixa com a folga, já com o arrasto.
  InkRect get frame {
    final f = bounds.inflate(lassoPadding);
    return InkRect(f.left + dx, f.top + dy, f.right + dx, f.bottom + dy);
  }

  bool get dragging => dx != 0 || dy != 0;

  LassoSelection movedBy(double dx, double dy) => LassoSelection(
    strokes: strokes,
    bounds: bounds,
    dx: dx,
    dy: dy,
    note: note,
  );

  @override
  bool operator ==(Object other) =>
      other is LassoSelection &&
      setEquals(other.strokes, strokes) &&
      other.bounds == bounds &&
      other.dx == dx &&
      other.dy == dy &&
      other.note == note;

  @override
  int get hashCode =>
      Object.hash(Object.hashAllUnordered(strokes), bounds, dx, dy, note);
}

enum _Mode { pen, line, erase, lasso, move, marker, space }

void _nothing() {}

Future<void> _noSave(PenPresets _) async {}

final class AnnotationSession extends ChangeNotifier {
  AnnotationSession({
    required InkPageGeometry geometry,
    required this.anchors,
    required List<PageDrawing> drawings,
    required List<PageHighlight> highlights,
    required PenPresets presets,
    required this.repository,
    required this.owner,
    required this.userBookId,
    this.startTimer = Timer.new,
    DateTime Function()? now,
    UuidV7Generator? ids,
    this.onError = reportReaderError,
    this.onInteraction = _nothing,
    this.savePresets = _noSave,
    this.textShift = annotationTextShift,
    String? draftId,
    List<DeskHighlight>? deskHighlights,
    this.pageSource,
    this._page,
    List<SessionNote> notes = const [],
    this.otherCuts = const [],
    double? lineHeight,
  }) : _geometry = geometry,
       _lineHeight = lineHeight ?? geometry.lineHeight,
       _pen = presets,
       _hasDesk = deskHighlights != null,
       _now = now ?? DateTime.now,
       _ids = ids ?? UuidV7Generator(),
       _draftId = draftId ?? UuidV7Generator().next(),
       _highlights = List.unmodifiable(highlights) {
    final initial = <SessionDrawing>[];
    for (final d in drawings) {
      final id = d.saved.layerId;
      _saved[id] = d;
      _initialStrokes[id] = d.strokes;
      initial.add(
        SessionDrawing(
          id: id,
          order: _nextOrder++,
          strokes: List.unmodifiable([
            for (final s in d.strokes) SessionStroke(_nextStroke++, s),
          ]),
          saved: d.saved,
        ),
      );
    }
    // G18: as notas da página, com ids de traço da sessão
    final pageNotes = [
      for (final n in notes)
        n.copyWith(
          strokes: [
            for (final s in n.strokes) SessionStroke(_nextStroke++, s.stroke),
          ],
        ),
    ];
    _managed.addAll([for (final n in pageNotes) n.id]);
    _initialNotes.addAll({for (final n in pageNotes) n.id: n});
    _copy = InkWorkingCopy(
      initial,
      HighlightDesk(List.unmodifiable(deskHighlights ?? const [])),
      pageNotes,
    );
    _cutsSignature = _baseSignature = _signatureOf(_cuts());
    // a página do leitor sem o espaço de uma nota dela (o leitor o passou para a seguinte — R12): no modo o espaço
    // fica no pé (R3), e a página do modo é refeita já
    final start = _page;
    final shown = start?.shown;
    final missing =
        start != null &&
        shown != null &&
        pageNotes.any(
          (n) =>
              n.unit == shown.unit &&
              n.at > shown.from &&
              n.at <= shown.to &&
              !spacesOf(start).any((s) => s.id == n.id),
        );
    _basePage = missing ? null : start;
    _anchorGeometry = _geometry;
    _initialDesk = _copy.desk;
    _history = InkHistory(_copy);
    if (missing) {
      _cutsSignature = '';
      _relayoutIfNeeded();
    }
    live.addListener(() {
      liveMarker.value = switch (live.value) {
        LiveMarker(:final stroke) => stroke,
        _ => null,
      };
    });
    _armDraft();
  }

  /// As linhas e as palavras da página (coordenadas do leitor limpo); G18: mudam quando um espaço abre.
  InkPageGeometry get geometry => _geometry;
  InkPageGeometry _geometry;

  /// G18: de onde vem a página do modo com os espaços (sem ela, o Espaço não abre).
  final AnnotationPageSource? pageSource;

  /// G18: os espaços salvos do capítulo que não estão nesta página (o layout de baixo os leva em conta).
  final List<SpaceCut> otherCuts;

  /// A página do modo agora (com os espaços), ou `null` quando a tela não deu a fonte.
  DisplayPage? get page => _page;
  DisplayPage? _page;

  /// A altura da linha do texto (a faixa recolhida e o abridor — D-182, D-184).
  final double _lineHeight;
  final AnnotationAnchors anchors;
  final InkRepository repository;
  final String owner;
  final String userBookId;
  final ReaderErrorReporter onError;

  /// Quanto o texto desceu no modo.
  final double textShift;

  /// A chave do rascunho desta sessão (D-166): ela só guarda e apaga o dela.
  final String _draftId;

  final Timer Function(Duration duration, void Function() callback) startTimer;
  final DateTime Function() _now;
  final UuidV7Generator _ids;

  /// Cada toque é interação da leitura (D-95).
  final void Function() onInteraction;

  /// Grava o `pen_presets` (a espessura vale para todos os livros).
  final Future<void> Function(PenPresets presets) savePresets;
  List<PageHighlight> _highlights;

  /// A tela passou os grifos da página (G17): a mesa decide o que se pinta, o que a Borracha alcança e o que o
  /// Concluir grava (D-173).
  final bool _hasDesk;
  late final HighlightDesk _initialDesk;

  final InkGestureArbiter _arbiter = InkGestureArbiter();
  late final InkWorkingCopy _copy;
  late final InkHistory _history;

  /// Os desenhos salvos da página (pelo id da camada) e os traços com que eles chegaram.
  final Map<String, PageDrawing> _saved = {};
  final Map<String, List<InkStroke>> _initialStrokes = {};

  /// A hora de criação e a anotação de cada desenho novo (ficam no desfazer e no refazer).
  final Map<String, DateTime> _createdAt = {};
  final Map<String, String> _annotationOf = {};

  /// G18: as notas que a sessão cuida (as da página e as novas) e como as salvas chegaram.
  final Set<String> _managed = {};
  final Map<String, SessionNote> _initialNotes = {};

  /// A assinatura dos espaços da página de agora, com quem é cada um (refaz a página quando ela muda).
  String _cutsSignature = '';

  /// A página com que a sessão começou e os espaços dela: sem mudança de espaço (os mesmos, das mesmas notas), é ela
  /// que o modo mostra (a de hoje — as telas 22 e 23 não mudam).
  late final DisplayPage? _basePage;
  late final String _baseSignature;

  /// As linhas da página do modo com as que passaram do pé da tela (a mesma página, mais alta): os desenhos cujas
  /// palavras desceram além do pé andam com elas, escondidos, e o Concluir os ancora nelas (R3).
  late InkPageGeometry _anchorGeometry;

  /// Os desenhos cujas palavras estão além do pé da tela: não aparecem nem são alcançados (R3).
  Set<String> _offPage = const {};

  /// O arrasto do Espaço: a fresta, onde o dedo começou e se o abridor já apareceu.
  SpaceSeam? _seam;
  double _spaceStartY = 0;
  bool _spaceShown = false;

  /// A nota onde o traço em curso começou (R6), ou `null`.
  String? _noteTarget;

  /// A alça em curso: a nota, as linhas no começo e as de agora (D-186).
  ({String id, int base, int lines})? _handleDrag;
  Timer? _noteTimer;

  int _nextOrder = 0;
  int _nextStroke = 0;

  PenPresets _pen;
  AnnotationTool _tool = AnnotationTool.pen;

  /// A última ferramenta de tinta usada (Caneta, Reta ou Marca-texto): a cor do poço e o painel com Borracha e Laço
  /// (R2).
  AnnotationTool _ink = AnnotationTool.pen;

  /// Um ajuste mudou durante um arrasto e ainda não foi gravado (R6).
  bool _presetsDirty = false;

  /// O painel de ajustes aberto (`null` = nenhum).
  final ValueNotifier<OpenPanel?> panel = ValueNotifier(null);

  /// A favorita que a pressão longa acabou de tirar e o lugar dela: a pílula "Cor tirada das favoritas" com Desfazer
  /// fica [favoriteUndoLife] (D-175).
  final ValueNotifier<({String hex, int index})?> favoriteRemoved =
      ValueNotifier(null);
  Timer? _favoriteTimer;

  /// O traço ao vivo, a prévia da Reta ou o contorno do Laço.
  final ValueNotifier<LiveInk?> live = ValueNotifier(null);

  /// Só o traço do Marca-texto ao vivo (a folha do Noite repinta com ele, não com a Caneta nem com o Laço — R26).
  final ValueNotifier<InkStroke?> liveMarker = ValueNotifier(null);

  /// Onde está o dedo que desenha (coordenadas da tela), para o indicador de toque; com a caneta, `null`.
  final ValueNotifier<InkOffset?> touch = ValueNotifier(null);

  /// A seleção do Laço.
  final ValueNotifier<LassoSelection?> selection = ValueNotifier(null);

  /// G18: o abridor durante o arrasto do Espaço (tela 24), ou `null`.
  final ValueNotifier<SpaceOpening?> opening = ValueNotifier(null);

  /// G18: a nota que acabou de ser apagada — a pílula "Nota apagada · Desfazer" fica [favoriteUndoLife] (D-185).
  final ValueNotifier<String?> noteDeleted = ValueNotifier(null);

  _Mode? _mode;
  int _t0 = 0;
  double _size = 0;
  final List<InkPoint> _points = [];
  InkOffset? _lineStart;
  InkOffset? _lineEnd;
  int _lineMs = 0;
  InkOffset? _erasePrev;
  final Set<int> _pendingStrokes = {};
  final Set<String> _pendingHighlights = {};
  final List<InkOffset> _polygon = [];
  InkOffset? _moveFrom;

  double _panRaw = 0;
  double _panOffset = 0;
  bool _panning = false;

  /// O topo da borda de mesa na tela (a tela informa): com ele, o limite da página sai da página de agora — a nota que
  /// cresce além do pé da tela também sobe (G18, R3).
  double? deskTop;
  double _panLimit = 0;

  /// Quanto a página pode subir: até o fim dela (a última linha ou o pé da última nota) passar do topo da borda de
  /// mesa (D-165); sem a borda, o que foi dado.
  double get panLimit {
    final top = deskTop;
    if (top == null) return _panLimit;
    return _limitOf(contentBottom + textShift, top);
  }

  set panLimit(double v) => _panLimit = v;

  bool _failed = false;
  bool _saving = false;
  int _revision = 0;
  bool _unsaved = false;
  Timer? _timer;
  bool _disposed = false;

  AnnotationTool get tool => _tool;
  PenPresets get presets => _pen;
  StrokeSize get strokeSize => _pen.strokeSize;

  /// A cor da ferramenta (ARGB): a da caneta com Caneta e Reta, a do marca-texto com o Marca-texto; com Borracha e
  /// Laço, a da última ferramenta de tinta (R2).
  int get color => argbOfHex(
    inkTool == AnnotationTool.marker ? _pen.highlighterColor : _pen.penColor,
  );

  /// A ferramenta de tinta em uso: a ativa, se for de tinta; senão, a última usada (R2).
  AnnotationTool get inkTool => _ink;

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  /// O deslocamento vertical da página (negativo = subiu).
  double get panOffset => _panOffset;

  /// Os dedos estão movendo a página agora (sem animação); ao soltar, a tela anima a volta do batente.
  bool get panning => _panning;

  /// A gravação do Concluir falhou: a pílula "Não deu para salvar as anotações agora." (D-21).
  bool get failed => _failed;

  /// O Concluir está gravando: a página não aceita tinta nem move (o que viesse agora não entraria na gravação).
  bool get saving => _saving;

  /// Sobe a cada mudança da tinta mostrada (o cache da pintura).
  int get revision => _revision;

  /// A [revision] para ouvir: a página do modo repinta com ela, não com cada aviso da sessão.
  ValueListenable<int> get revisions => _revisions;
  final ValueNotifier<int> _revisions = ValueNotifier(0);

  /// Os desenhos da cópia de trabalho, em ordem de criação.
  List<SessionDrawing> get drawings => _copy.drawings.toList();

  /// Os traços que a página pinta: sem o que a Borracha está apagando e sem a seleção que está sendo arrastada.
  List<InkStroke> get visibleStrokes {
    final moving = selection.value?.dragging ?? false
        ? selection.value!.strokes
        : const <int>{};
    return [
      for (final d in _copy.drawings)
        if (!_offPage.contains(d.id))
          for (final s in d.strokes)
            if (!_pendingStrokes.contains(s.id) && !moving.contains(s.id))
              s.stroke,
    ];
  }

  /// Os traços selecionados pelo Laço, onde estão (sem o arrasto em curso); os de uma nota, na página.
  List<InkStroke> get selectedStrokes {
    final sel = selection.value;
    if (sel == null) return const [];
    final note = sel.note;
    if (note != null) {
      final box = noteInkFrame(note);
      final n = _copy.note(note);
      if (box == null || n == null) return const [];
      return [
        for (final s in n.strokes)
          if (sel.strokes.contains(s.id)) fromNote(s.stroke, box),
      ];
    }
    return [
      for (final d in _copy.drawings)
        for (final s in d.strokes)
          if (sel.strokes.contains(s.id)) s.stroke,
    ];
  }

  // ---- notas à mão (G18) -------------------------------------------------------------------------------------

  /// As notas à mão da página (as salvas e as novas, sem as apagadas), com a alça em curso.
  List<SessionNote> get notes => [
    for (final n in _copy.notes)
      if (_handleDrag case (:final id, :final lines, base: _) when id == n.id)
        n.copyWith(lines: lines)
      else
        n,
  ];

  /// Até onde a página do modo vai: a base da última linha ou o pé do último espaço (a nota que passa do pé da tela
  /// — R3); a página sobe com 2 dedos até ele passar do topo da borda de mesa (D-165).
  double get contentBottom {
    var bottom = _geometry.lines.isEmpty ? 0.0 : _geometry.lines.last.bottom;
    final page = _page;
    if (page != null) {
      for (final s in spacesOf(page)) {
        bottom = math.max(bottom, s.rect.bottom);
      }
    }
    return bottom;
  }

  /// O bloco de [id] na página do modo (com as margens), ou `null`.
  Rect? _blockOf(String id) {
    final page = _page;
    if (page == null) return null;
    for (final s in spacesOf(page)) {
      if (s.id == id) return s.rect;
    }
    return null;
  }

  /// A caixa da nota [id] na página (coordenadas do leitor limpo): a caixa da 24b, ou a faixa se recolhida.
  Rect? noteBox(String id) {
    final block = _blockOf(id);
    final n = _noteNow(id);
    if (block == null || n == null) return null;
    return n.collapsed
        ? Rect.fromLTWH(
            block.left,
            block.top + stripMargin,
            block.width,
            _lineHeight,
          )
        : Rect.fromLTWH(
            block.left,
            block.top + noteMarginTop,
            block.width,
            noteBoxHeight(n.lines),
          );
  }

  /// R6: onde a tinta da nota [id] vive na página — a caixa por dentro da borda (a unidade da nota mede daqui); `null`
  /// recolhida ou fora da página.
  Rect? noteInkFrame(String id) {
    final n = _noteNow(id);
    final box = noteBox(id);
    if (n == null || box == null || n.collapsed) return null;
    return inkFrame(box);
  }

  /// A área do abridor na página (coordenadas do leitor limpo), durante o arrasto.
  Rect? get openerArea {
    final o = opening.value;
    final block = _blockOf(spaceOpenerId);
    if (o == null || block == null) return null;
    return Rect.fromLTWH(
      block.left,
      block.top + openerMarginTop,
      block.width,
      openerAreaHeight(o.lines, _lineHeight),
    );
  }

  SessionNote? _noteNow(String id) {
    for (final n in notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  /// Os traços da nota [id] que a página pinta (unidade da nota), sem o que a Borracha está apagando nem a seleção
  /// que está sendo arrastada.
  List<InkStroke> noteStrokes(String id) {
    final n = _copy.note(id);
    if (n == null) return const [];
    final sel = selection.value;
    final moving = sel != null && sel.note == id && sel.dragging
        ? sel.strokes
        : const <int>{};
    return [
      for (final s in n.strokes)
        if (!_pendingStrokes.contains(s.id) && !moving.contains(s.id)) s.stroke,
    ];
  }

  /// A nota aberta cuja caixa contém [at] (R6).
  String? _noteAt(InkOffset at) {
    for (final n in notes) {
      if (n.collapsed) continue;
      final box = noteBox(n.id);
      if (box != null && box.contains(Offset(at.x, at.y))) return n.id;
    }
    return null;
  }

  /// O bloco de alguma nota (aberta ou recolhida) contém [at] (R5).
  bool _inSomeNote(InkOffset at) {
    for (final n in notes) {
      final block = _blockOf(n.id);
      if (block != null && block.contains(Offset(at.x, at.y))) return true;
    }
    return false;
  }

  /// Os espaços da página: os do capítulo que a sessão não cuida, as notas e o abridor.
  List<SpaceCut> _cuts() {
    final o = opening.value;
    return [
      for (final c in otherCuts)
        if (!_managed.contains(c.id)) c,
      for (final n in notes)
        SpaceCut(
          at: n.at,
          height: n.collapsed
              ? stripFlowHeight(_lineHeight)
              : noteFlowHeight(n.lines),
          id: n.id,
        ),
      if (o != null)
        SpaceCut(
          at: o.seam.at,
          height: openerFlowHeight(o.lines, _lineHeight),
          id: spaceOpenerId,
        ),
    ];
  }

  /// A assinatura dos espaços [cuts] com a nota de cada um: a mesma âncora e altura de outra nota não é a mesma
  /// página (o espaço leva o id dela).
  static String _signatureOf(List<SpaceCut> cuts) =>
      ([...cuts]..sort(
            (a, b) =>
                a.at != b.at ? a.at.compareTo(b.at) : a.id.compareTo(b.id),
          ))
          .map((c) => '${c.id}@${c.at}:${c.height.toStringAsFixed(2)}')
          .join(',');

  /// Os espaços mudaram: a página do modo é refeita e cada desenho anda com as palavras dele (R3) — também os que
  /// passam do pé da tela (pela mesma página mais alta: até a soma dos espaços e uma linha a mais por espaço).
  void _relayoutIfNeeded() {
    final source = pageSource;
    if (source == null) return;
    final cuts = _cuts();
    final signature = _signatureOf(cuts);
    if (signature == _cutsSignature) return;
    _cutsSignature = signature;
    final base = _basePage;
    final next = base != null && signature == _baseSignature
        ? base
        : source.pageWith(cuts);
    var extra = (cuts.length + 1) * _lineHeight;
    for (final c in cuts) {
      extra += c.height;
    }
    final tall = source.tallPageWith(cuts, extra);
    final where = tall?.page ?? next;
    // onde cada desenho se prendia: nas linhas da tela; os escondidos, nas de baixo do pé
    final oldVisible = _geometry;
    final oldTall = _anchorGeometry;
    final oldOff = _offPage;
    final places = <String, ({int unit, DrawingPlace place})?>{};
    ({int unit, DrawingPlace place})? placeBefore(
      String id,
      List<SessionStroke> strokes,
    ) => places.putIfAbsent(id, () {
      if (strokes.isEmpty) return null;
      final g = oldOff.contains(id) ? oldTall : oldVisible;
      final p = placeDrawing(
        drawingBox([for (final s in strokes) s.stroke]),
        g,
      );
      return p == null ? null : (unit: g.lines[p.line].unit, place: p);
    });
    final shifts = <String, ({double dx, double dy})?>{};
    ({double dx, double dy})? shift(String id, List<SessionStroke> strokes) =>
        shifts.putIfAbsent(id, () => _shiftOf(placeBefore(id, strokes), where));
    _copy.remap(shift);
    _history.remap(shift);
    for (final e in _initialStrokes.entries.toList()) {
      final s = shift(e.key, [for (final x in e.value) SessionStroke(-1, x)]);
      if (s != null) {
        _initialStrokes[e.key] = [
          for (final x in e.value) x.translated(s.dx, s.dy),
        ];
      }
    }
    _page = next;
    _geometry = inkGeometryOf(next);
    _anchorGeometry = tall == null ? _geometry : inkGeometryOf(tall.page);
    tall?.dispose();
    // os desenhos cujas palavras não estão mais na tela (passaram do pé)
    _offPage = {
      for (final d in _copy.drawings)
        if (places[d.id] case (:final unit, :final place))
          if (next.boxesOf(unit, place.from, place.to).isEmpty) d.id,
    };
    _highlights = List.unmodifiable(source.highlightsOn(next));
    selection.value = null;
    _repaint();
  }

  /// O deslocamento de um desenho: o trecho dele na página velha ([at], de `placeDrawing`) e o mesmo trecho na nova
  /// [next] — mesma letra, mesmo trecho: só anda.
  static ({double dx, double dy})? _shiftOf(
    ({int unit, DrawingPlace place})? at,
    DisplayPage next,
  ) {
    if (at == null) return null;
    final (:unit, :place) = at;
    final frame = placedFrame([
      for (final b in next.boxesOf(unit, place.from, place.to))
        (
          left: b.rect.left,
          right: b.rect.right,
          baseline: b.baseline,
          em: b.em,
        ),
    ], place.frame.w);
    if (frame == null) return null;
    final dx = frame.x - place.frame.x;
    final dy = frame.baseline - place.frame.baseline;
    return dx == 0 && dy == 0 ? null : (dx: dx, dy: dy);
  }

  /// [v] entre [lo] e [hi] (sem limite quando a faixa não existe — a seleção maior que a caixa).
  static double _within(double v, double lo, double hi) =>
      lo > hi ? v : v.clamp(lo, hi).toDouble();

  /// R7 (D-186): a alça da nota [id] andou [dy] px desde o toque: as linhas mudam de 42 em 42, de 1 a 12, sem subir
  /// além da última linha escrita; a página acompanha.
  void dragNoteHandle(String id, double dy) {
    final n = _copy.note(id);
    if (n == null || n.collapsed) return;
    final drag = _handleDrag;
    final base = drag != null && drag.id == id ? drag.base : n.lines;
    final min = math.max(
      minLinesFor([for (final s in n.strokes) s.stroke]),
      minSpaceLines,
    );
    final lines = math.min(
      maxSpaceLines,
      math.max(min, base + (dy / noteLinePx).round()),
    );
    final before = drag?.lines;
    _handleDrag = (id: id, base: base, lines: lines);
    if (before != lines) {
      _relayoutIfNeeded();
      notifyListeners();
    }
  }

  /// A alça soltou: um passo do desfazer, se as linhas mudaram.
  void endNoteHandle(String id) {
    final h = _handleDrag;
    _handleDrag = null;
    final n = _copy.note(id);
    if (h == null || h.id != id || n == null) return;
    if (h.lines == n.lines) {
      _relayoutIfNeeded();
      return;
    }
    _push(
      ChangeNote(
        before: n,
        after: n.copyWith(lines: h.lines),
      ),
    );
  }

  /// R8 (D-184): recolhe a nota aberta ou abre a recolhida (um passo).
  void toggleNote(String id) {
    final n = _copy.note(id);
    if (n == null) return;
    _push(
      ChangeNote(
        before: n,
        after: n.copyWith(collapsed: !n.collapsed),
      ),
    );
  }

  /// R9 (D-185): apaga a nota na hora (um passo) e mostra a pílula "Nota apagada · Desfazer".
  void deleteNote(String id) {
    if (_copy.note(id) == null) return;
    _push(DeleteNote(id));
    noteDeleted.value = id;
    _noteTimer?.cancel();
    _noteTimer = startTimer(favoriteUndoLife, () {
      _noteTimer = null;
      noteDeleted.value = null;
    });
  }

  /// O Desfazer da pílula: só se o último passo é apagar essa nota.
  bool undoNoteDeletion() {
    final id = noteDeleted.value;
    _noteTimer?.cancel();
    _noteTimer = null;
    noteDeleted.value = null;
    final last = _history.last;
    if (id == null || last is! DeleteNote || last.id != id) return false;
    undo();
    return true;
  }

  /// Os grifos que não aparecem: os apagados na sessão e os que a Borracha está apagando.
  Set<String> get hiddenHighlights => {
    ..._copy.erasedHighlights,
    ..._pendingHighlights,
  };

  /// A mesa de grifos de agora (D-173).
  HighlightDesk get desk => _copy.desk;

  /// Os grifos de seleção que a página pinta, pela mesa (sem os que a Borracha está apagando); sem a mesa, `null` (a
  /// tela pinta os dela).
  List<PaintedHighlight>? get paintedHighlights => _painted(ink: false);

  /// Os grifos à mão (a mancha da D-161), pela mesa.
  List<PaintedHighlight>? get paintedInkHighlights => _painted(ink: true);

  List<PaintedHighlight>? _painted({required bool ink}) => !_hasDesk
      ? null
      : [
          for (final h in _copy.desk.items)
            if (h.ink == ink && !_pendingHighlights.contains(h.id))
              PaintedHighlight(
                id: h.id,
                range: (unit: h.unit, from: h.start, to: h.end),
                color: Color(argbOfHex(h.color)),
                style: h.style,
                height: h.height ?? FillHeight.medium,
              ),
        ];

  Map<String, String> _labels = const {};
  Map<String, int> _counts = const {};

  /// Os rótulos das cores do marca-texto (`highlight_labels` — D-177), pela cor em `#RRGGBB` maiúsculo.
  Map<String, String> get labels => _labels;

  /// Os grifos vivos de cada cor em todos os livros, como estavam ao abrir o modo (D-40); a 23b soma o [countDelta].
  Map<String, int> get savedCounts => _counts;

  /// Os rótulos e as contagens lidos do banco (ao abrir o modo e ao salvar os rótulos).
  void setLabelData({Map<String, String>? labels, Map<String, int>? counts}) {
    if (labels != null) {
      _labels = Map.unmodifiable({
        for (final e in labels.entries) e.key.toUpperCase(): e.value,
      });
    }
    if (counts != null) {
      _counts = Map.unmodifiable({
        for (final e in counts.entries) e.key.toUpperCase(): e.value,
      });
    }
    notifyListeners();
  }

  /// Os grifos de cada cor que a 23b mostra: os do banco mais o saldo da sessão (D-40).
  int colorCount(String hex) {
    final c = hex.toUpperCase();
    var n = _counts[c] ?? 0;
    for (final e in countDelta.entries) {
      if (e.key.toUpperCase() == c) n += e.value;
    }
    return n;
  }

  /// Quantos grifos de cada cor a sessão pôs ou tirou (as contagens da 23b — D-40).
  Map<String, int> get countDelta {
    final now = _copy.desk.counts();
    final before = _initialDesk.counts();
    return {
      for (final c in {...now.keys, ...before.keys})
        if ((now[c] ?? 0) != (before[c] ?? 0))
          c: (now[c] ?? 0) - (before[c] ?? 0),
    };
  }

  // ---- entrada --------------------------------------------------------------------------------------------

  void pointerDown(InkPointer p) {
    onInteraction();
    _handle(_arbiter.down(p));
  }

  void pointerMove(InkPointer p) => _handle(_arbiter.move(p));

  void pointerUp(InkPointer p) => _handle(_arbiter.up(p));

  void pointerCancel(InkPointer p) => _handle(_arbiter.cancel(p));

  void _handle(List<InkGesture> gestures) {
    for (final g in gestures) {
      // gravando: só o fim do movimento da página passa (o traço em curso já fechou no Concluir)
      if (_saving && g is! PanEnd) continue;
      switch (g) {
        case DrawStart(:final p):
          _drawStart(p);
        case DrawMove(:final p):
          _drawMove(p);
        case DrawEnd():
          _drawEnd();
        case DrawDiscard():
          _drawDiscard();
        case PanStart():
          _panning = true;
          _panRaw = _panOffset;
          notifyListeners();
        case PanMove(:final dy):
          _panRaw += dy;
          _panOffset = rubberBand(_panRaw, panLimit);
          notifyListeners();
        case PanEnd():
          _panRaw = _panRaw.clamp(-panLimit, 0).toDouble();
          _panOffset = _panRaw;
          _panning = false;
          notifyListeners();
      }
    }
  }

  /// [p] nas coordenadas do leitor limpo.
  InkOffset _pageOf(InkPointer p) => (x: p.x, y: p.y - textShift - _panOffset);

  void _showTouch(InkPointer p) =>
      touch.value = p.kind == InkPointerKind.touch ? (x: p.x, y: p.y) : null;

  void _drawStart(InkPointer p) {
    final at = _pageOf(p);
    _showTouch(p);
    _t0 = p.tMs;
    _noteTarget = _tool == AnnotationTool.space ? null : _noteAt(at);
    switch (_tool) {
      case AnnotationTool.pen:
        _mode = _Mode.pen;
        _size = strokeDp(_pen.penWidthMm, strokeSize);
        _points
          ..clear()
          ..add(
            InkPoint(
              at.x,
              at.y,
              p.kind == InkPointerKind.stylus
                  ? p.pressure.clamp(0, 1).toDouble()
                  : firstPressure,
              0,
            ),
          );
        live.value = LiveStroke(_liveStroke());
      case AnnotationTool.line:
        _mode = _Mode.line;
        _lineStart = at;
        _lineEnd = null;
        _lineMs = 0;
        live.value = LiveLine(_lineStroke(at, at, 0));
      case AnnotationTool.eraser:
        _mode = _Mode.erase;
        _erasePrev = at;
        _eraseAlong(at, at);
      case AnnotationTool.lasso:
        final sel = selection.value;
        if (sel != null && _inside(at, sel.frame)) {
          _mode = _Mode.move;
          _moveFrom = at;
          return;
        }
        if (sel != null) _release();
        _mode = _Mode.lasso;
        _polygon
          ..clear()
          ..add(at);
        live.value = LiveLasso(UnmodifiableListView(_polygon));
      case AnnotationTool.marker:
        _mode = _Mode.marker;
        _size = _markerWidth(at);
        _points
          ..clear()
          ..add(InkPoint(at.x, at.y, 0.5, 0));
        live.value = LiveMarker(_markerStroke());
      case AnnotationTool.space:
        _mode = null;
        // R1 e R5: a fresta mais perto, fora das notas e numa âncora sem nota
        if (_inSomeNote(at)) return;
        final seam = seamAt(geometry, at.y, anchors.textOf);
        if (seam == null) return;
        if (notes.any((n) => n.unit == seam.unit && n.at == seam.at)) return;
        _mode = _Mode.space;
        _seam = seam;
        _spaceStartY = at.y;
        _spaceShown = false;
    }
  }

  void _drawMove(InkPointer p) {
    final at = _pageOf(p);
    _showTouch(p);
    switch (_mode) {
      case _Mode.pen:
        final last = _points.last;
        if (last.x == at.x && last.y == at.y) return;
        final dx = at.x - last.x;
        final dy = at.y - last.y;
        final distance = math.sqrt(dx * dx + dy * dy);
        _points.add(
          InkPoint(
            at.x,
            at.y,
            p.kind == InkPointerKind.stylus
                ? p.pressure.clamp(0, 1).toDouble()
                : simulatedPressure(last.pressure, distance, _size),
            // o tempo do traço não volta (o BNK1 grava o Δt sem sinal)
            math.max(last.tMs, p.tMs - _t0),
          ),
        );
        live.value = LiveStroke(_liveStroke());
      case _Mode.marker:
        final last = _points.last;
        if (last.x == at.x && last.y == at.y) return;
        _points.add(InkPoint(at.x, at.y, 0.5, math.max(last.tMs, p.tMs - _t0)));
        live.value = LiveMarker(_markerStroke());
      case _Mode.line:
        final start = _lineStart!;
        _lineEnd = snapLineEnd(start, at);
        _lineMs = math.max(_lineMs, p.tMs - _t0);
        live.value = LiveLine(_lineStroke(start, _lineEnd!, _lineMs));
      case _Mode.erase:
        _eraseAlong(_erasePrev!, at);
        _erasePrev = at;
      case _Mode.lasso:
        _polygon.add(at);
        live.value = LiveLasso(UnmodifiableListView(_polygon));
      case _Mode.space:
        final seam = _seam!;
        if (!_spaceShown && (at.y - _spaceStartY).abs() < spaceDragSlop) {
          return;
        }
        _spaceShown = true;
        // R2: as linhas pelo dedo, a partir do topo da área (a fresta + a margem de cima)
        final n = linesOfDrag(at.y - (seam.y + openerMarginTop), _lineHeight);
        final before = opening.value?.lines;
        opening.value = (seam: seam, lines: n, finger: at);
        if (before != n) _relayoutIfNeeded();
      case _Mode.move:
        // a seleção saiu no meio do arrasto (outra ferramenta, desfazer): o arrasto acaba
        final sel = selection.value;
        if (sel == null) {
          _mode = null;
          return;
        }
        final from = _moveFrom!;
        final wasDragging = sel.dragging;
        var dx = at.x - from.x;
        var dy = at.y - from.y;
        // R6: a tinta da nota anda só dentro da caixa
        final frame = sel.note == null ? null : noteInkFrame(sel.note!);
        if (frame != null) {
          final b = sel.bounds;
          dx = _within(dx, frame.left - b.left, frame.right - b.right);
          dy = _within(dy, frame.top - b.top, frame.bottom - b.bottom);
        }
        selection.value = sel.movedBy(dx, dy);
        if (wasDragging != selection.value!.dragging) _repaint();
      case null:
        break;
    }
  }

  void _drawEnd() {
    touch.value = null;
    final mode = _mode;
    _mode = null;
    switch (mode) {
      case _Mode.pen:
        live.value = null;
        _addInk(
          InkStroke(
            tool: InkTool.pen.code,
            tip: tipCode(_pen.penTip),
            argb: color,
            widthCentiMm: widthCentiMm(_pen.penWidthMm, strokeSize),
            points: List.unmodifiable(_points),
          ),
        );
        _points.clear();
      case _Mode.marker:
        live.value = null;
        if (_noteTarget != null) {
          // R6: dentro da nota não há palavra — fica tinta translúcida da nota
          _addInk(_markerStroke());
        } else {
          _markerEnd();
        }
        _points.clear();
      case _Mode.line:
        live.value = null;
        final start = _lineStart!;
        final end = _lineEnd;
        if (end != null && !lineTooShort(start, end)) {
          _addInk(_lineStroke(start, end, _lineMs));
        }
      case _Mode.erase:
        if (_pendingStrokes.isEmpty && _pendingHighlights.isEmpty) return;
        final strokes = {..._pendingStrokes};
        final highlights = {..._pendingHighlights};
        _pendingStrokes.clear();
        _pendingHighlights.clear();
        _push(Erase(strokeIds: strokes, highlightIds: highlights));
      case _Mode.lasso:
        live.value = null;
        _select(List.of(_polygon));
        _polygon.clear();
      case _Mode.space:
        final seam = _seam!;
        final o = opening.value;
        _seam = null;
        if (!_spaceShown || o == null) return;
        // D-187: a nota nasce aberta com as linhas do arrasto e a Caneta volta
        final id = _ids.next();
        _managed.add(id);
        _annotationOf[id] = _ids.next();
        opening.value = null;
        _push(
          OpenNote(
            SessionNote(
              id: id,
              unit: seam.unit,
              at: seam.at,
              lines: o.lines,
              collapsed: false,
              strokes: const [],
              createdAt: _now().toUtc(),
            ),
          ),
        );
        setTool(AnnotationTool.pen);
      case _Mode.move:
        final sel = selection.value;
        if (sel == null || !sel.dragging) return;
        final note = sel.note;
        if (note != null) {
          final box = noteInkFrame(note);
          selection.value = null;
          if (box == null) return;
          // R6: o Laço da nota move dentro dela (na unidade da nota)
          _push(
            MoveNoteStrokes(
              noteId: note,
              strokeIds: sel.strokes,
              dx: sel.dx / box.width,
              dy: sel.dy / noteLinePx,
            ),
          );
          return;
        }
        // juntos num desenho só, os traços passariam do teto da camada: ficam onde estavam
        if (!_fits([
          for (final s in selectedStrokes) s.translated(sel.dx, sel.dy),
        ])) {
          selection.value = sel.movedBy(0, 0);
          _repaint();
          return;
        }
        selection.value = LassoSelection(
          strokes: sel.strokes,
          bounds: InkRect(
            sel.bounds.left + sel.dx,
            sel.bounds.top + sel.dy,
            sel.bounds.right + sel.dx,
            sel.bounds.bottom + sel.dy,
          ),
        );
        _push(
          MoveStrokes(
            strokeIds: sel.strokes,
            dx: sel.dx,
            dy: sel.dy,
            newDrawingId: _newDrawing(),
            order: _nextOrder++,
          ),
        );
      case null:
        break;
    }
  }

  void _drawDiscard() {
    touch.value = null;
    final mode = _mode;
    _mode = null;
    switch (mode) {
      case _Mode.pen:
      case _Mode.marker:
        _points.clear();
        live.value = null;
      case _Mode.line:
      case _Mode.lasso:
        _polygon.clear();
        live.value = null;
      case _Mode.erase:
        if (_pendingStrokes.isEmpty && _pendingHighlights.isEmpty) return;
        _pendingStrokes.clear();
        _pendingHighlights.clear();
        _repaint();
      case _Mode.move:
        final sel = selection.value;
        if (sel == null || !sel.dragging) return;
        selection.value = sel.movedBy(0, 0);
        _repaint();
      case _Mode.space:
        // os 2 dedos ou o cancelamento: o abridor some e a página volta
        _seam = null;
        if (opening.value == null) return;
        opening.value = null;
        _relayoutIfNeeded();
      case null:
        break;
    }
  }

  /// R6: o traço vai para a nota onde ele começou (na unidade dela) ou para os desenhos.
  void _addInk(InkStroke s) {
    final note = _noteTarget;
    _noteTarget = null;
    final box = note == null ? null : noteInkFrame(note);
    if (note == null || box == null) {
      _addStroke(s);
      return;
    }
    // recortado na borda; a nota que passaria do teto da camada (256 KiB) não leva mais tinta
    final pieces = [for (final p in clipToFrame(s, box)) toNote(p, box)];
    final n = _copy.note(note);
    if (pieces.isEmpty ||
        n == null ||
        !fitsBnk1([
          for (final x in n.strokes) x.stroke,
          ...pieces,
        ], Bnk1Unit.box)) {
      return;
    }
    _push(
      AddNoteStroke(note, [
        for (final p in pieces) SessionStroke(_nextStroke++, p),
      ]),
    );
  }

  /// R20: a largura do marca-texto = a faixa da altura escolhida na letra da linha mais perto do toque.
  double _markerWidth(InkOffset at) {
    final lines = geometry.lines;
    if (lines.isEmpty) return 0;
    var best = lines.first;
    for (final l in lines) {
      if ((l.refY - at.y).abs() < (best.refY - at.y).abs()) best = l;
    }
    final (top, bottom) = fillBand(_pen.highlighterHeight);
    return (bottom - top) * (best.textBottom - best.textTop);
  }

  /// O traço do Marca-texto: ferramenta 3, a cor dele a 90 % (como a mancha — D-161), a largura da faixa.
  InkStroke _markerStroke() => InkStroke(
    tool: InkTool.marker.code,
    tip: 0,
    argb: markerInkArgb(argbOfHex(_pen.highlighterColor)),
    widthCentiMm: centiMmOfDp(_size),
    points: List.unmodifiable(_points),
  );

  /// Ao soltar o Marca-texto (Anexo 03 §9.4): sobre palavras, os trechos grifados pela D-32 num passo só (R21, R23);
  /// sem palavra, a tinta translúcida num desenho, como a caneta (R22).
  void _markerEnd() {
    final runs = markedRuns(
      [for (final p in _points) (x: p.x, y: p.y)],
      geometry,
      textOf: anchors.textOf,
    );
    if (runs.isEmpty) {
      _addStroke(_markerStroke());
      return;
    }
    final before = _copy.desk;
    var desk = before;
    final at = _now().toUtc();
    String? group;
    for (final r in runs) {
      final id = _ids.next();
      desk = desk.mark(
        r,
        color: _pen.highlighterColor,
        style: _pen.highlighterStyle,
        height: _pen.highlighterHeight,
        id: id,
        groupId: group ?? id,
        at: at,
        newId: _ids.next,
      );
      // o grupo do traço = o do grifo que ficou com o 1º trecho (o mais antigo, se a D-32 juntou os dois)
      group ??= _holderOf(desk, r)?.groupId ?? id;
    }
    if (desk != before) _push(MarkHighlights(before: before, after: desk));
  }

  /// O grifo vivo da mesa [desk] que cobre o trecho [r].
  static DeskHighlight? _holderOf(HighlightDesk desk, MarkedRun r) {
    for (final h in desk.items) {
      if (h.unit == r.unit && h.start <= r.from && h.end >= r.to) return h;
    }
    return null;
  }

  InkStroke _liveStroke() => InkStroke(
    tool: InkTool.pen.code,
    tip: tipCode(_pen.penTip),
    argb: color,
    widthCentiMm: widthCentiMm(_pen.penWidthMm, strokeSize),
    points: UnmodifiableListView(_points),
  );

  InkStroke _lineStroke(InkOffset a, InkOffset b, int ms) => InkStroke(
    tool: InkTool.line.code,
    tip: tipCode(_pen.penTip),
    argb: color,
    widthCentiMm: widthCentiMm(_pen.penWidthMm, strokeSize),
    points: List.unmodifiable([
      InkPoint(a.x, a.y, 0.5, 0),
      InkPoint(b.x, b.y, 0.5, ms),
    ]),
  );

  static bool _inside(InkOffset p, InkRect r) =>
      p.x >= r.left && p.x <= r.right && p.y >= r.top && p.y <= r.bottom;

  /// Um desenho novo: o id da camada, a anotação e a hora de criação.
  String _newDrawing() {
    final id = _ids.next();
    _annotationOf[id] = _ids.next();
    _createdAt[id] = _now().toUtc();
    return id;
  }

  /// O traço [s] entra no desenho que ele toca (D-162) ou começa outro; o desenho que passaria de 256 KiB fecha.
  void _addStroke(InkStroke s) {
    final drawings = [
      for (final d in _copy.drawings)
        if (!_offPage.contains(d.id)) d,
    ];
    final touched = touchedDrawing(strokeBox(s), [
      for (final d in drawings)
        (
          order: d.order,
          box: drawingBox([for (final x in d.strokes) x.stroke]),
        ),
    ], lineHeight: geometry.lineHeight);
    final into = touched == null
        ? null
        : drawings.firstWhere((d) => d.order == touched);
    if (into != null && _fits([for (final x in into.strokes) x.stroke, s])) {
      _push(
        AddStroke(
          SessionStroke(_nextStroke++, s),
          into: into.id,
          newDrawingId: into.id,
          order: into.order,
        ),
      );
      return;
    }
    _push(
      AddStroke(
        SessionStroke(_nextStroke++, s),
        into: null,
        newDrawingId: _newDrawing(),
        order: _nextOrder++,
      ),
    );
  }

  /// Os traços [strokes] cabem numa camada, em em na moldura deles.
  bool _fits(List<InkStroke> strokes) {
    final place = placeDrawing(drawingBox(strokes), geometry);
    if (place == null) return true;
    return fitsBnk1([
      for (final s in strokes) toFrame(s, place.frame),
    ], Bnk1Unit.em);
  }

  /// A Borracha andou de [a] a [b]: o que ela toca some já (e é apagado ao soltar).
  void _eraseAlong(InkOffset a, InkOffset b) {
    var changed = false;
    for (final d in _copy.drawings) {
      if (_offPage.contains(d.id)) continue;
      for (final s in d.strokes) {
        if (_pendingStrokes.contains(s.id)) continue;
        if (eraserTouchesStroke(a, b, s.stroke)) {
          _pendingStrokes.add(s.id);
          changed = true;
        }
      }
    }
    // G18: a tinta das notas abertas, na página
    for (final n in notes) {
      final box = noteInkFrame(n.id);
      if (box == null) continue;
      for (final s in n.strokes) {
        if (_pendingStrokes.contains(s.id)) continue;
        if (eraserTouchesStroke(a, b, fromNote(s.stroke, box))) {
          _pendingStrokes.add(s.id);
          changed = true;
        }
      }
    }
    final erased = _copy.erasedHighlights;
    for (final h in _erasable()) {
      if (erased.contains(h.id) || _pendingHighlights.contains(h.id)) {
        continue;
      }
      if (h.areas.any((r) => eraserTouchesRect(a, b, r))) {
        _pendingHighlights.add(h.id);
        changed = true;
      }
    }
    if (changed) _repaint();
  }

  /// O que a Borracha alcança nos grifos: só os à mão (D-168). Com a mesa, os vivos dela — as caixas da tela para os
  /// que não mudaram, as das palavras para os novos e os cortados; sem a mesa, os da tela.
  Iterable<({String id, List<InkRect> areas})> _erasable() sync* {
    if (!_hasDesk) {
      for (final h in _highlights) {
        if (h.ink) yield (id: h.id, areas: h.areas);
      }
      return;
    }
    final screen = {for (final h in _highlights) h.id: h};
    for (final h in _copy.desk.items) {
      if (!h.ink) continue;
      final first = _initialDesk.byId(h.id);
      final kept =
          first != null && first.start == h.start && first.end == h.end;
      final onScreen = screen[h.id];
      yield (
        id: h.id,
        // sem caixas da tela (o sublinhado e o ondulado não têm mancha), as das palavras
        areas: kept && onScreen != null && onScreen.areas.isNotEmpty
            ? onScreen.areas
            : _areasOf(h),
      );
    }
  }

  /// As caixas das letras de [h] em cada linha da página.
  List<InkRect> _areasOf(DeskHighlight h) {
    final out = <InkRect>[];
    for (final l in geometry.lines) {
      if (l.unit != h.unit) continue;
      double? left;
      double? right;
      for (final w in l.words) {
        if (w.to <= h.start || w.from >= h.end) continue;
        left = left == null ? w.left : math.min(left, w.left);
        right = right == null ? w.right : math.max(right, w.right);
      }
      if (left != null && right != null) {
        out.add(InkRect(left, l.textTop, right, l.textBottom));
      }
    }
    return out;
  }

  /// O Laço de contorno [polygon] seleciona os traços com ≥ 50 % dos pontos dentro.
  void _select(List<InkOffset> polygon) {
    if (polygon.length < 3) return;
    final picked = <int>{};
    final strokes = <InkStroke>[];
    // G18 (R6): o Laço que começa numa caixa só pega a tinta dela
    final note = _noteAt(polygon.first);
    if (note != null) {
      final box = noteInkFrame(note)!;
      for (final s in _copy.note(note)!.strokes) {
        final onPage = fromNote(s.stroke, box);
        if (lassoSelects(onPage, polygon)) {
          picked.add(s.id);
          strokes.add(onPage);
        }
      }
      if (picked.isEmpty) return;
      selection.value = LassoSelection(
        strokes: picked,
        bounds: drawingBox(strokes),
        note: note,
      );
      return;
    }
    for (final d in _copy.drawings) {
      if (_offPage.contains(d.id)) continue;
      for (final s in d.strokes) {
        if (lassoSelects(s.stroke, polygon)) {
          picked.add(s.id);
          strokes.add(s.stroke);
        }
      }
    }
    if (picked.isEmpty) return;
    selection.value = LassoSelection(
      strokes: picked,
      bounds: drawingBox(strokes),
    );
  }

  void _release() {
    if (selection.value == null) return;
    selection.value = null;
    _repaint();
  }

  // ---- ferramentas e espessura ------------------------------------------------------------------------------

  /// Troca a ferramenta. O Marca-texto e o Espaço (D-163) devolvem `false` e a atual continua. A Borracha com a
  /// seleção do Laço apaga os selecionados (um passo) e fica ativa.
  bool setTool(AnnotationTool t) {
    // sem a página do modo (a tela não deu a fonte), o Espaço não abre (D-163)
    if (t == AnnotationTool.space && pageSource == null) {
      closePanel();
      return false;
    }
    if (t != _tool) closePanel();
    if (t == AnnotationTool.pen ||
        t == AnnotationTool.line ||
        t == AnnotationTool.marker) {
      _ink = t;
    }
    final sel = selection.value;
    if (sel != null && t != AnnotationTool.lasso) {
      selection.value = null;
      if (t == AnnotationTool.eraser) {
        _push(Erase(strokeIds: sel.strokes, highlightIds: const {}));
      } else {
        _repaint();
      }
    }
    if (t != _tool) {
      _tool = t;
      notifyListeners();
    }
    return true;
  }

  /// Fina, Média ou Grossa: vale para o próximo traço e grava no `pen_presets` na hora (todos os livros).
  void setStrokeSize(StrokeSize s) => _setPresets(_pen.copyWith(strokeSize: s));

  // ---- ajustes da caneta e do marca-texto (telas 23 e 23b — G17) --------------------------------------------

  void setPenTip(PenTip t) => _setPresets(_pen.copyWith(penTip: t));

  /// [mm] com 1 casa (0,3–4,0). Durante o arrasto, [save] = `false`: só muda; ao soltar grava (R6).
  void setPenWidth(double mm, {bool save = true}) =>
      _setPresets(_pen.copyWith(penWidthMm: mm), save: save);

  /// [hex] = `#RRGGBB`. Durante o arrasto na roda ou no brilho, [save] = `false` (R6).
  void setPenColor(String hex, {bool save = true}) =>
      _setPresets(_pen.copyWith(penColor: hex.toUpperCase()), save: save);

  /// "+": junta a cor atual no fim das favoritas; `false` se ela já está ou se já são 12 (D-175).
  bool addFavorite() {
    final favs = _pen.favoriteColors;
    final c = _pen.penColor.toUpperCase();
    if (favs.length >= maxFavoriteColors ||
        favs.any((f) => f.toUpperCase() == c)) {
      return false;
    }
    _setPresets(_pen.copyWith(favoriteColors: [...favs, c]));
    return true;
  }

  /// Tira a favorita [hex] e devolve onde ela estava (para o Desfazer da pílula); -1 se ela não está (D-175).
  int removeFavorite(String hex) {
    final favs = _pen.favoriteColors;
    final i = favs.indexWhere((f) => f.toUpperCase() == hex.toUpperCase());
    if (i < 0) return -1;
    _setPresets(_pen.copyWith(favoriteColors: [...favs]..removeAt(i)));
    favoriteRemoved.value = (hex: favs[i].toUpperCase(), index: i);
    _favoriteTimer?.cancel();
    _favoriteTimer = startTimer(favoriteUndoLife, () {
      _favoriteTimer = null;
      favoriteRemoved.value = null;
    });
    return i;
  }

  /// O Desfazer da pílula: a favorita volta ao lugar dela e a pílula some.
  void undoFavoriteRemoval() {
    final r = favoriteRemoved.value;
    if (r == null) return;
    _favoriteTimer?.cancel();
    _favoriteTimer = null;
    favoriteRemoved.value = null;
    restoreFavorite(r.hex, r.index);
  }

  /// O Desfazer da pílula: põe [hex] de volta no lugar [index].
  void restoreFavorite(String hex, int index) {
    final favs = [..._pen.favoriteColors];
    if (favs.length >= maxFavoriteColors ||
        favs.any((f) => f.toUpperCase() == hex.toUpperCase())) {
      return;
    }
    favs.insert(index.clamp(0, favs.length), hex.toUpperCase());
    _setPresets(_pen.copyWith(favoriteColors: favs));
  }

  void setHighlighterStyle(HighlightStyle s) =>
      _setPresets(_pen.copyWith(highlighterStyle: s));

  void setHighlighterColor(String hex) =>
      _setPresets(_pen.copyWith(highlighterColor: hex.toUpperCase()));

  void setHighlighterHeight(FillHeight h) =>
      _setPresets(_pen.copyWith(highlighterHeight: h));

  /// Troca o `pen_presets` da sessão e grava (todos os livros); sem mudança, só grava o que um arrasto deixou.
  void _setPresets(PenPresets next, {bool save = true}) {
    if (next != _pen) {
      _pen = next;
      notifyListeners();
      if (!save) {
        _presetsDirty = true;
        return;
      }
    } else if (!save || !_presetsDirty) {
      return;
    }
    _presetsDirty = false;
    unawaited(
      savePresets(_pen).catchError((Object e, StackTrace st) {
        onError(e, st);
      }),
    );
  }

  // ---- painéis (R1, R2) ---------------------------------------------------------------------------------------

  /// Abre o painel da ferramenta [from]: Caneta e Reta → o da caneta; Marca-texto → o dele; Borracha e Laço → o da
  /// última de tinta (R2); o Espaço não tem.
  void openPanel(AnnotationTool from) {
    final source = switch (from) {
      AnnotationTool.eraser || AnnotationTool.lasso => _ink,
      _ => from,
    };
    panel.value = switch (source) {
      AnnotationTool.pen ||
      AnnotationTool.line => (kind: PanelKind.pen, from: source),
      AnnotationTool.marker => (kind: PanelKind.marker, from: source),
      _ => null,
    };
  }

  void closePanel() => panel.value = null;

  // ---- desfazer -----------------------------------------------------------------------------------------------

  void undo() {
    if (_history.undo()) _changed();
  }

  void redo() {
    if (_history.redo()) _changed();
  }

  void _push(InkCommand c) {
    _history.push(c);
    _changed();
  }

  void _changed() {
    _unsaved = true;
    // um passo no meio de um arrasto da alça (outro dedo recolheu, apagou, desfez): o arrasto acaba ali
    _handleDrag = null;
    _relayoutIfNeeded();
    final sel = selection.value;
    if (sel != null && sel.note != null) {
      selection.value = null;
    } else if (sel != null) {
      // a seleção segue os traços (o desfazer de um movimento os devolve)
      final strokes = [
        for (final d in _copy.drawings)
          for (final s in d.strokes)
            if (sel.strokes.contains(s.id)) s.stroke,
      ];
      selection.value = strokes.isEmpty
          ? null
          : LassoSelection(strokes: sel.strokes, bounds: drawingBox(strokes));
    }
    _repaint();
  }

  void _repaint() {
    _revision++;
    _revisions.value = _revision;
    notifyListeners();
  }

  // ---- o que o Concluir grava -----------------------------------------------------------------------------------

  /// A linha da página que contém o caractere [offset] do item [unit] (com as de além do pé, que vêm depois — R3).
  int? _lineOf(int unit, int offset) {
    final g = _anchorGeometry;
    for (var i = 0; i < g.lines.length; i++) {
      final l = g.lines[i];
      if (l.unit == unit && offset >= l.from && offset < l.to) return i;
    }
    return null;
  }

  /// G18: a linha onde a âncora [at] de [unit] está (a de cima da costura): a última que começa antes dela.
  int? _lineAbove(int unit, int at) {
    int? found;
    final g = _anchorGeometry;
    for (var i = 0; i < g.lines.length; i++) {
      final l = g.lines[i];
      if (l.unit == unit && l.from < at) found = i;
    }
    return found;
  }

  /// As mudanças da sessão: os desenhos novos e mudados (âncora refeita sobre o desenho inteiro — D-162), os salvos
  /// que ficaram sem traços e os grifos à mão apagados.
  InkChanges changes() {
    final present = {for (final d in _copy.drawings) d.id: d};
    final cards = <CardCandidate>[
      for (final d in present.values)
        if (d.saved case final saved?)
          if (_lineOf(_saved[d.id]!.range.unit, _saved[d.id]!.range.from)
              case final line?)
            (
              id: d.id,
              group: saved.groupId,
              line: line,
              createdAt: saved.createdAt,
            ),
    ];
    final rows = <DrawingRow>[];
    for (final d in present.values) {
      final strokes = [for (final s in d.strokes) s.stroke];
      final saved = d.saved;
      if (saved != null && listEquals(strokes, _initialStrokes[d.id])) {
        continue;
      }
      // o escondido além do pé: pelas linhas de baixo (as palavras dele — R3)
      final g = _offPage.contains(d.id) ? _anchorGeometry : geometry;
      final place = placeDrawing(drawingBox(strokes), g);
      if (place == null) continue;
      final unit = g.lines[place.line].unit;
      final text = anchors.textOf(unit);
      if (text == null) continue;
      final where = anchors.placeOf(unit, place.from);
      final range = EpubAnchor(
        sha: anchors.sha,
        spine: unit,
        start: place.from,
        end: place.to,
        quote: quoteAt(text, place.from, place.to),
        refPage: where.refPage,
      );
      final annotationId = saved?.annotationId ?? _annotationOf[d.id]!;
      final createdAt = saved?.createdAt ?? _createdAt[d.id]!;
      final group =
          saved?.groupId ??
          cardGroup(id: annotationId, line: place.line, others: cards);
      if (saved == null) {
        cards.add((
          id: d.id,
          group: group,
          line: place.line,
          createdAt: createdAt,
        ));
      }
      rows.add(
        DrawingRow(
          layerId: d.id,
          annotationId: annotationId,
          createdAt: createdAt,
          anchor: inkLayerAnchor(range, place.frame.w),
          range: range,
          refPage: where.refPage,
          chapterIndex: where.chapterIndex,
          groupId: group,
          color: colorHex(strokes.first.argb),
          strokesB64: encodeStrokesB64([
            for (final s in strokes) toFrame(s, place.frame),
          ], Bnk1Unit.em),
          strokeCount: strokes.length,
        ),
      );
    }
    final notes = _noteChanges(cards);
    final marks = _highlightChanges();
    return InkChanges(
      notes: notes.rows,
      deletedNotes: notes.deleted,
      layers: rows,
      deletedLayers: {
        for (final id in _saved.keys)
          if (!present.containsKey(id)) id,
      },
      erasedHighlights: marks.erased,
      highlights: marks.highlights,
      moved: marks.moved,
      removed: marks.removed,
    );
  }

  /// G18 (R10, D-188): as notas novas e mudadas (com traço) e as salvas apagadas ou que ficaram sem traço. O grupo
  /// da nota nova vem dos cartões da página, como o dos desenhos (Anexo 02 §4.3).
  ({List<NoteRow> rows, Set<String> deleted}) _noteChanges(
    List<CardCandidate> cards,
  ) {
    final rows = <NoteRow>[];
    final deleted = <String>{};
    for (final n in _copy.notes) {
      final first = _initialNotes[n.id];
      final strokes = [for (final s in n.strokes) s.stroke];
      if (strokes.isEmpty) {
        if (first != null) deleted.add(n.id);
        continue;
      }
      if (first != null &&
          first.lines == n.lines &&
          first.collapsed == n.collapsed &&
          listEquals([for (final s in first.strokes) s.stroke], strokes)) {
        continue;
      }
      final text = anchors.textOf(n.unit);
      if (text == null) continue;
      final where = anchors.placeOf(n.unit, n.at);
      final annotationId = n.saved?.annotationId ?? _annotationOf[n.id]!;
      final line = _lineAbove(n.unit, n.at);
      final group =
          n.saved?.groupId ??
          (line == null
              ? annotationId
              : cardGroup(id: annotationId, line: line, others: cards));
      if (n.saved == null && line != null) {
        cards.add((id: n.id, group: group, line: line, createdAt: n.createdAt));
      }
      rows.add(
        NoteRow(
          layerId: n.id,
          annotationId: annotationId,
          createdAt: n.saved?.createdAt ?? n.createdAt,
          anchor: EpubAnchor(
            sha: anchors.sha,
            spine: n.unit,
            start: n.at,
            end: n.at,
            quote: quoteAt(text, n.at, n.at),
            refPage: where.refPage,
          ),
          refPage: where.refPage,
          chapterIndex: where.chapterIndex,
          groupId: group,
          lines: n.lines,
          collapsed: n.collapsed,
          strokesB64: encodeStrokesB64(strokes, Bnk1Unit.box),
          strokeCount: strokes.length,
        ),
      );
    }
    for (final id in _initialNotes.keys) {
      if (_copy.note(id) == null) deleted.add(id);
    }
    return (rows: rows, deleted: deleted);
  }

  /// Os grifos da mesa (G17, R24): os novos (o traço do marca-texto e os pedaços cortados), os salvos que a D-32
  /// moveu, os salvos que ela tirou com o destino final das notas (`null` se a Borracha apagou o destino) e os salvos
  /// apagados pela Borracha. O que nunca foi gravado e saiu na sessão não vai. Sem a mesa, os do marca-texto são
  /// todos novos e os apagados vêm da tela.
  ({
    List<HighlightRow> highlights,
    List<MovedHighlight> moved,
    Map<String, String?> removed,
    Set<String> erased,
  })
  _highlightChanges() {
    final desk = _copy.desk;
    bool saved(String id) => _initialDesk.byId(id) != null;
    final highlights = <HighlightRow>[];
    final moved = <MovedHighlight>[];
    for (final h in desk.items) {
      final first = _initialDesk.byId(h.id);
      if (first != null && first.start == h.start && first.end == h.end) {
        continue;
      }
      final text = anchors.textOf(h.unit);
      if (text == null) continue;
      final where = anchors.placeOf(h.unit, h.start);
      final range = EpubAnchor(
        sha: anchors.sha,
        spine: h.unit,
        start: h.start,
        end: h.end,
        quote: quoteAt(text, h.start, h.end),
        refPage: where.refPage,
      );
      if (first != null) {
        moved.add(
          MovedHighlight(
            id: h.id,
            range: range,
            refPage: where.refPage,
            chapterIndex: where.chapterIndex,
          ),
        );
        continue;
      }
      highlights.add(
        HighlightRow(
          id: h.id,
          createdAt: h.createdAt,
          range: range,
          refPage: where.refPage,
          chapterIndex: where.chapterIndex,
          groupId: h.groupId,
          color: h.color,
          style: h.style,
          fillHeight: h.style == HighlightStyle.fill
              ? (h.height ?? FillHeight.medium)
              : null,
          source: h.ink ? AnnotationSource.ink : AnnotationSource.selection,
        ),
      );
    }
    return (
      highlights: highlights,
      moved: moved,
      removed: {
        for (final id in desk.removed.keys)
          if (saved(id))
            id: switch (desk.targetOf(id)) {
              final t when desk.erased.contains(t) => null,
              final t => t,
            },
      },
      // sem a mesa, os apagados são os da tela
      erased: !_hasDesk
          ? _copy.erasedHighlights
          : {
              for (final id in desk.erased)
                if (saved(id)) id,
            },
    );
  }

  /// Concluir: grava numa transação e apaga o rascunho (`true`); sem mudanças, só apaga um rascunho velho. A falha
  /// deixa o modo aberto com a pílula e o rascunho guardado (`false`).
  Future<bool> conclude() async {
    if (_saving) return false;
    // o traço em curso (a caneta ainda no papel) fecha e entra no que é gravado
    if (_mode != null) _drawEnd();
    _saving = true;
    notifyListeners();
    try {
      return await _conclude();
    } finally {
      _saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> _conclude() async {
    final InkChanges c;
    try {
      c = changes();
    } on Object catch (e, st) {
      onError(InkNotSaved('${e.runtimeType}'), st);
      _setFailed(true);
      return false;
    }
    if (c.isEmpty) {
      try {
        await repository.clearDraft(owner, userBookId, session: _draftId);
      } on Object catch (e, st) {
        onError(InkNotSaved('${e.runtimeType}'), st);
      }
      _unsaved = false;
      _setFailed(false);
      return true;
    }
    try {
      await repository.commit(owner, userBookId, c);
      await repository.clearDraft(owner, userBookId, session: _draftId);
      _unsaved = false;
      _setFailed(false);
      return true;
    } on Object catch (e, st) {
      onError(InkNotSaved('${e.runtimeType}'), st);
      _setFailed(true);
      try {
        await repository.saveDraft(owner, userBookId, c, session: _draftId);
      } on Object catch (e2, st2) {
        onError(InkNotSaved('${e2.runtimeType}'), st2);
      }
      return false;
    }
  }

  void _setFailed(bool v) {
    if (_failed == v) return;
    _failed = v;
    if (!_disposed) notifyListeners();
  }

  // ---- rascunho -------------------------------------------------------------------------------------------------

  void _armDraft() => _timer = startTimer(inkDraftEvery, _tick);

  void _tick() {
    if (_disposed) return;
    _armDraft();
    if (_unsaved) unawaited(_saveDraft());
  }

  /// O app foi para o segundo plano: o rascunho vai já.
  Future<void> toBackground() async {
    if (_unsaved) await _saveDraft();
  }

  Future<void> _saveDraft() async {
    _unsaved = false;
    try {
      await repository.saveDraft(
        owner,
        userBookId,
        changes(),
        session: _draftId,
      );
    } on Object catch (e, st) {
      _unsaved = true;
      onError(InkNotSaved('${e.runtimeType}'), st);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    live.dispose();
    liveMarker.dispose();
    _revisions.dispose();
    touch.dispose();
    selection.dispose();
    panel.dispose();
    _favoriteTimer?.cancel();
    favoriteRemoved.dispose();
    _noteTimer?.cancel();
    opening.dispose();
    noteDeleted.dispose();
    super.dispose();
  }
}
