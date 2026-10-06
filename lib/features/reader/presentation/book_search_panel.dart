// G12.4 — a busca no livro (D-120): painel de tela inteira na cor do papel, com o campo numa ilha igual à de cima
// (← fecha, × limpa) e a lista de resultados embaixo — a contagem, os grupos por capítulo (o título em
// maiúsculas) e cada resultado com "pág. N" e o trecho, a palavra com a cor `brand` por trás das letras (a mesma
// marca da página), separados pelo tracejado das ferramentas. Busca a partir de 2 caracteres, 250 ms depois de
// parar de digitar; "Buscando…" só depois de 300 ms; até 500 resultados; uma busca nova cancela a anterior. A
// última busca fica guardada enquanto o livro está aberto ([BookSearchSession], da tela).
import 'dart:async';

import 'package:flutter/material.dart'
    show InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../application/book_search.dart';
import '../application/reader_document.dart';
import 'bottom_island.dart' show DashedTopBorderPainter;
import 'reader_chrome_palette.dart';
import 'reader_controls.dart' show readerControlsLayout;
import 'reader_palette.dart';

/// A busca começa 250 ms depois de parar de digitar (D-120).
const Duration searchDebounce = Duration(milliseconds: 250);

/// "Buscando…" só aparece depois disso (D-120).
const Duration searchSlow = Duration(milliseconds: 300);

/// A busca do livro aberto: o texto, os resultados e o andamento. Fica com a tela enquanto o livro está aberto
/// (reabrir o painel mostra a última busca).
class BookSearchSession extends ChangeNotifier {
  BookSearchSession(this.document, {this.startTimer = Timer.new});

  final ReaderDocument document;
  final Timer Function(Duration, void Function()) startTimer;

  String _query = '';
  String get query => _query;

  /// O texto da última busca feita (para "Nada encontrado para “x”.").
  String _searched = '';
  String get searched => _searched;

  final List<SearchGroup> _groups = [];
  List<SearchGroup> get groups => List.unmodifiable(_groups);

  int _total = 0;

  /// Resultados mostrados (até 500).
  int get total => _total > searchLimit ? searchLimit : _total;

  /// Passou de 500: "Mais de 500 resultados. Refine a busca."
  bool get overflow => _total > searchLimit;

  bool _running = false;
  bool get running => _running;

  /// Buscando há mais de 300 ms.
  bool _slow = false;
  bool get slow => _slow;

  bool _done = false;

  /// A busca terminou (com ou sem resultado).
  bool get done => _done;

  Timer? _debounce;
  Timer? _slowTimer;
  StreamSubscription<SearchGroup>? _sub;
  bool _disposed = false;

  /// O texto do campo mudou: busca 250 ms depois de parar; menos de 2 caracteres limpa.
  void type(String q) {
    if (q == _query) return;
    _query = q;
    _debounce?.cancel();
    if (foldForSearch(q.trim()).text.length < searchMinChars) {
      _stop();
      _reset();
      _searched = '';
      _changed();
      return;
    }
    _debounce = startTimer(searchDebounce, () => _run(q));
  }

  void _run(String q) {
    _stop();
    _reset();
    _searched = q.trim();
    _running = true;
    _slowTimer = startTimer(searchSlow, () {
      if (_running) {
        _slow = true;
        _changed();
      }
    });
    _sub = document
        .search(q)
        .listen(
          (g) {
            _groups.add(g);
            _total += g.hits.length;
            if (_total > searchLimit) _finish();
            _changed();
          },
          onError: (Object _, StackTrace _) => _finish(),
          onDone: _finish,
        );
    _changed();
  }

  void _finish() {
    _stop();
    _running = false;
    _slow = false;
    _done = true;
    _changed();
  }

  void _stop() {
    _slowTimer?.cancel();
    _slowTimer = null;
    final s = _sub;
    _sub = null;
    if (s != null) unawaited(s.cancel());
  }

  void _reset() {
    _groups.clear();
    _total = 0;
    _running = false;
    _slow = false;
    _done = false;
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _stop();
    super.dispose();
  }
}

/// "7 resultados", "1 resultado", "Mais de 500…", "Nada encontrado…", "Buscando…" ou nada.
String? searchCountText(BookSearchSession s) {
  if (s.overflow) return 'Mais de $searchLimit resultados. Refine a busca.';
  if (s.total == 1) return '1 resultado';
  if (s.total > 1) return '${s.total} resultados';
  if (s.done && s.searched.isNotEmpty) {
    return 'Nada encontrado para “${s.searched}”.';
  }
  if (s.slow) return 'Buscando…';
  return null;
}

class BookSearchPanel extends StatefulWidget {
  const BookSearchPanel({
    super.key,
    required this.session,
    required this.paper,
    required this.palette,
    required this.brand,
    required this.onClose,
    required this.onPick,
  });

  final BookSearchSession session;

  /// O papel (fundo, texto do trecho e "pág. N" na cor do rodapé).
  final ReaderPalette paper;

  /// As cores da ilha do campo (as da ilha de cima do tema).
  final ReaderChromePalette palette;
  final Color brand;
  final VoidCallback onClose;
  final ValueChanged<SearchHit> onPick;

  @override
  State<BookSearchPanel> createState() => _BookSearchPanelState();
}

class _BookSearchPanelState extends State<BookSearchPanel> {
  late final TextEditingController _field = TextEditingController(
    text: widget.session.query,
  );

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _clear() {
    _field.clear();
    widget.session.type('');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final at = readerControlsLayout(MediaQuery.viewPaddingOf(context));
    final side = BorderSide(width: AppStrokes.regular, color: p.border);
    return ColoredBox(
      key: const ValueKey('leitor.busca'),
      color: widget.paper.paper,
      child: Stack(
        children: [
          Positioned.fill(
            top: at.top + 62 + 16,
            child: ListenableBuilder(
              listenable: widget.session,
              builder: (context, _) => _Results(
                session: widget.session,
                paper: widget.paper,
                palette: p,
                brand: widget.brand,
                onPick: widget.onPick,
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            top: at.top,
            child: NeoBox(
              key: const ValueKey('leitor.busca.ilha'),
              height: 62,
              color: p.island,
              border: side,
              radius: BorderRadius.circular(31),
              shadow: AppShadows.hard3,
              shadowColor: p.shadow,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                spacing: 10,
                children: [
                  CircleIconButton(
                    key: const ValueKey('leitor.busca.fechar'),
                    size: 44,
                    color: p.well,
                    border: side,
                    icon: AppSvg(
                      p.night
                          ? AppIconsLeitor.arrowLeftNight
                          : AppIconsLeitor.arrowLeft,
                      size: 20,
                    ),
                    semanticsLabel: 'Fechar a busca',
                    onTap: widget.onClose,
                  ),
                  Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: TextField(
                        key: const ValueKey('leitor.busca.campo'),
                        controller: _field,
                        autofocus: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.search,
                        onChanged: (q) {
                          widget.session.type(q);
                          setState(() {});
                        },
                        style: AppTextStyles.readerSearchField.copyWith(
                          color: p.title,
                        ),
                        cursorColor: p.title,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Buscar no livro',
                          hintStyle: AppTextStyles.readerSearchField.copyWith(
                            color: p.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_field.text.isNotEmpty)
                    Pressable(
                      key: const ValueKey('leitor.busca.limpar'),
                      semanticsLabel: 'Limpar a busca',
                      onTap: () => setState(_clear),
                      child: SizedBox.square(
                        dimension: 44,
                        child: Center(
                          child: AppSvg(
                            AppIconsLeitor.close,
                            size: 20,
                            color: p.title,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.session,
    required this.paper,
    required this.palette,
    required this.brand,
    required this.onPick,
  });

  final BookSearchSession session;
  final ReaderPalette paper;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<SearchHit> onPick;

  @override
  Widget build(BuildContext context) {
    final count = searchCountText(session);
    final rows = <Widget>[];
    var left = searchLimit;
    for (final g in session.groups) {
      if (left <= 0) break;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 6),
          child: Semantics(
            header: true,
            child: AppText(
              g.title.toUpperCase(),
              style: AppTextStyles.readerSearchGroup.copyWith(
                color: palette.muted,
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < g.hits.length && left > 0; i++, left--) {
        if (i > 0) {
          rows.add(
            SizedBox(
              height: AppStrokes.regular,
              child: CustomPaint(
                painter: DashedTopBorderPainter(color: palette.dash),
              ),
            ),
          );
        }
        rows.add(
          _Hit(
            hit: g.hits[i],
            paper: paper,
            brand: brand,
            onTap: () => onPick(g.hits[i]),
          ),
        );
      }
    }
    return ListView(
      key: const ValueKey('leitor.busca.lista'),
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
      children: [
        if (count != null)
          Semantics(
            liveRegion: true,
            child: AppText(
              count,
              key: const ValueKey('leitor.busca.contagem'),
              style: AppTextStyles.readerSearchCount.copyWith(
                color: palette.muted,
              ),
            ),
          ),
        ...rows,
      ],
    );
  }
}

class _Hit extends StatelessWidget {
  const _Hit({
    required this.hit,
    required this.paper,
    required this.brand,
    required this.onTap,
  });

  final SearchHit hit;
  final ReaderPalette paper;
  final Color brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = hit.excerpt;
    final style = AppTextStyles.readerSearchExcerpt.copyWith(color: paper.text);
    return Pressable(
      key: ValueKey(
        'leitor.busca.resultado.${hit.found.unit}.${hit.found.from}',
      ),
      semanticsLabel: 'pág. ${hit.refPage}, $e',
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 2,
          children: [
            AppText(
              'pág. ${hit.refPage}',
              style: AppTextStyles.readerSearchPage.copyWith(
                color: paper.footer,
              ),
            ),
            AppText.rich(
              TextSpan(
                style: style,
                children: [
                  TextSpan(text: e.substring(0, hit.matchStart)),
                  TextSpan(
                    text: e.substring(hit.matchStart, hit.matchEnd),
                    style: style.copyWith(background: Paint()..color = brand),
                  ),
                  TextSpan(text: e.substring(hit.matchEnd)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
