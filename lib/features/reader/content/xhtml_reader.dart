// G09.1 — XHTML de um item do spine → blocos + texto canônico (Anexo 03 §4, D-93). O texto canônico é a régua
// de todas as âncoras: NFC, `\n` entre blocos, unidades UTF-16; imagem e `<hr>` = U+FFFC; `<br>` = U+2028;
// espaços colapsados como no navegador (`white-space: normal`), `pre` preservado; NBSP e hífen suave ficam;
// `display:none`, `hidden`, `<head>`, `<script>`, `<style>` ficam fora. Leitura por eventos (tolera tag sem
// fechar); se nem isso der, um recuo que tira as tags e mantém o texto.
import 'package:unorm_dart/unorm_dart.dart' as unorm;
import 'package:xml/xml.dart' show XmlDefaultEntityMapping, XmlException;
import 'package:xml/xml_events.dart';

import 'content_blocks.dart';
import 'css_subset.dart';
import 'markup.dart';

/// Conteúdo de uma folha de estilo do livro pelo caminho no ZIP (`null` = não existe).
typedef CssLoader = String? Function(String path);

enum _Kind { paragraph, heading, listItem, pre, row }

const Set<String> _skip = {
  'head',
  'script',
  'style',
  'title',
  'noscript',
  'template',
  'object',
  'video',
  'audio',
};
const Set<String> _containers = {
  'html',
  'body',
  'div',
  'section',
  'article',
  'aside',
  'header',
  'footer',
  'main',
  'nav',
  'figure', //
  'blockquote',
  'ul',
  'ol',
  'dl',
  'table',
  'thead',
  'tbody',
  'tfoot',
  'hgroup',
  'details',
  'center', //
  'fieldset', 'form', 'menu',
};
const Map<String, _Kind> _textBlocks = {
  'p': _Kind.paragraph,
  'dt': _Kind.paragraph,
  'dd': _Kind.paragraph,
  'caption': _Kind.paragraph, //
  'address': _Kind.paragraph,
  'figcaption': _Kind.paragraph,
  'summary': _Kind.paragraph, //
  'legend': _Kind.paragraph,
  'li': _Kind.listItem,
  'pre': _Kind.pre,
  'tr': _Kind.row, //
  'h1': _Kind.heading, 'h2': _Kind.heading, 'h3': _Kind.heading, //
  'h4': _Kind.heading, 'h5': _Kind.heading, 'h6': _Kind.heading,
};
const Set<String> _void = {
  'br',
  'img',
  'hr',
  'image',
  'meta',
  'link',
  'input',
  'col',
  'wbr',
  'area',
  'base',
  'source',
};

final class _Frame {
  const _Frame({
    required this.tag,
    required this.decls,
    required this.run,
    required this.hidden,
    this.link,
    this.align,
    this.indentEm,
    this.quoteDepth = 0,
    this.listDepth = 0,
    this.inPre = false,
    this.inSvg = false,
    this.kind,
  });

  final String tag;

  /// Declarações próprias (margens e quebra antes não herdam).
  final CssDeclarations decls;
  final RunStyle run;
  final bool hidden;
  final String? link;
  final BlockAlign? align;
  final double? indentEm;
  final int quoteDepth;
  final int listDepth;
  final bool inPre;
  final bool inSvg;
  final _Kind? kind;
}

final class XhtmlReader {
  XhtmlReader({required this.css});

  /// Folhas de estilo do livro pelo caminho no ZIP.
  final CssLoader css;
  final Map<String, StyleSheet> _sheets = {};

  /// Lê o XHTML [bytes] do item em [path] (caminho no ZIP: base dos `href`/`src` relativos).
  ParsedItem parse(List<int> bytes, {required String path}) {
    final text = decodeMarkup(bytes);
    final List<XmlEvent> events;
    try {
      events = parseEvents(
        text,
        entityMapping: const XmlDefaultEntityMapping.html5(),
      ).toList();
    } on XmlException {
      return _fallback(text);
    } on FormatException {
      return _fallback(text);
    }
    return _Walker(path, _sheetsOf(events, path)).run(events);
  }

  List<StyleSheet> _sheetsOf(List<XmlEvent> events, String path) {
    final out = <StyleSheet>[];
    var inStyle = false;
    final styleText = StringBuffer();
    for (final e in events) {
      if (e is XmlStartElementEvent) {
        final tag = e.localName.toLowerCase();
        if (tag == 'body') break;
        if (tag == 'link') {
          final rel = (_attr(e, 'rel') ?? '').toLowerCase();
          final href = _attr(e, 'href');
          final p = href == null ? null : resolveHref(dirOf(path), href);
          if (rel.contains('stylesheet') && p != null) {
            out.add(_sheets[p] ??= StyleSheet.parse(css(p) ?? ''));
          }
        } else if (tag == 'style' && !e.isSelfClosing) {
          inStyle = true;
          styleText.clear();
        }
      } else if (inStyle && (e is XmlTextEvent || e is XmlCDATAEvent)) {
        styleText.write(
          e is XmlTextEvent ? e.value : (e as XmlCDATAEvent).value,
        );
      } else if (inStyle &&
          e is XmlEndElementEvent &&
          e.localName.toLowerCase() == 'style') {
        inStyle = false;
        out.add(StyleSheet.parse(styleText.toString()));
      }
    }
    return out;
  }

  /// Recuo para XHTML que nem a leitura por eventos aceita: tira as tags, mantém o texto por bloco.
  static ParsedItem _fallback(String text) {
    var t = text.replaceAll(
      RegExp(r'<(head|script|style)\b[\s\S]*?</\1\s*>', caseSensitive: false),
      ' ',
    );
    t = t.replaceAll(
      RegExp(
        r'</?(p|div|h[1-6]|li|tr|br|hr|blockquote|section|pre|dt|dd)\b[^>]*>',
        caseSensitive: false,
      ),
      '\n',
    );
    t = t.replaceAll(RegExp(r'<[^>]*>'), ' ');
    t = const XmlDefaultEntityMapping.html5().decode(t);
    final b = _Builder();
    for (final line in t.split('\n')) {
      final s = line.replaceAll(RegExp(r'[ \t\r\f]+'), ' ').trim();
      if (s.isEmpty) continue;
      b.addTextBlock(
        _Kind.paragraph,
        0,
        [_RawRun(s, RunStyle.plain, null)],
        BlockStyle.none,
        const [],
      );
    }
    return b.finish();
  }
}

String? _attr(XmlStartElementEvent e, String local) {
  for (final a in e.attributes) {
    if (a.localName == local) return a.value;
  }
  return null;
}

final class _RawRun {
  _RawRun(this.text, this.style, this.link);

  String text;
  final RunStyle style;
  final String? link;
}

/// Percorre os eventos do `<body>` montando os blocos.
final class _Walker {
  _Walker(this.path, this.sheets);

  final String path;
  final List<StyleSheet> sheets;
  final List<_Frame> frames = [];
  final List<CssElement> els = [];
  final _Builder out = _Builder();

  // bloco em montagem
  _Frame? owner;
  final List<_RawRun> runs = [];
  int rawLen = 0;
  bool pendingSpace = false;
  _Frame? spaceFrame;
  bool pendingCell = false;
  bool rowHasCell = false;
  bool skipLeadingNewline = false;
  final List<(String, int)> pendingIds = [];

  _Frame get top => frames.isEmpty ? _root : frames.last;

  static const _Frame _root = _Frame(
    tag: '#root',
    decls: CssDeclarations.empty,
    run: RunStyle.plain,
    hidden: false,
  );

  ParsedItem run(List<XmlEvent> events) {
    var inBody = !events.any(
      (e) => e is XmlStartElementEvent && e.localName.toLowerCase() == 'body',
    );
    for (final e in events) {
      if (e is XmlStartElementEvent) {
        final tag = e.localName.toLowerCase();
        if (!inBody) {
          if (tag == 'body') inBody = true;
          if (!inBody) continue;
        }
        _start(e, tag);
        if (e.isSelfClosing || _void.contains(tag)) {
          _end(tag, selfClosing: true);
        }
      } else if (!inBody) {
        continue;
      } else if (e is XmlEndElementEvent) {
        _end(e.localName.toLowerCase());
      } else if (e is XmlTextEvent) {
        _text(e.value);
      } else if (e is XmlCDATAEvent) {
        _text(e.value);
      }
    }
    _flush();
    return out.finish();
  }

  void _start(XmlStartElementEvent e, String tag) {
    final parent = top;
    final classes = {
      for (final c in (_attr(e, 'class') ?? '').split(RegExp(r'\s+')))
        if (c.isNotEmpty) c,
    };
    final id = _attr(e, 'id');
    final el = (tag: tag, classes: classes, id: id);
    final hidden0 =
        parent.hidden || _skip.contains(tag) || _attrPresent(e, 'hidden');
    final decls = hidden0
        ? CssDeclarations.empty
        : cascade(sheets, el, els, inlineStyle: _attr(e, 'style'));
    final hidden = hidden0 || decls.display == 'none';

    if (!hidden && !parent.inSvg) {
      if (_textBlocks.containsKey(tag) ||
          _containers.contains(tag) ||
          tag == 'hr') {
        // tag de bloco dentro de um <p> aberto (HTML mal formado): o <p> fecha antes
        final openP = frames.lastIndexWhere((f) => f.tag == 'p');
        if (openP >= 0 && tag != 'hr') _popTo(openP);
        _flush();
      }
    }
    final p2 = top;
    if (!hidden && id != null && !p2.inSvg) pendingIds.add((id, _idPrefix()));

    if (!hidden && (tag == 'img' || (tag == 'image' && p2.inSvg))) {
      final src = tag == 'img' ? _attr(e, 'src') : (_attr(e, 'href'));
      final p = src == null ? null : resolveHref(dirOf(path), src);
      if (p != null) {
        _flush();
        out.addObject(
          ImageBlock(
            path: p,
            alt: tag == 'img' ? _attr(e, 'alt') : null,
            width: _int(_attr(e, 'width')),
            height: _int(_attr(e, 'height')),
            style: _blockStyle(p2, anonymous: true),
          ),
        );
      }
    } else if (!hidden && tag == 'hr' && !p2.inSvg) {
      out.addObject(
        SceneBreakBlock(
          _blockStyle(
            _frameFor(tag, decls, parent, false, el),
            anonymous: false,
          ),
        ),
      );
    } else if (!hidden && tag == 'br' && !p2.inSvg) {
      if (rawLen > 0) {
        pendingSpace = false;
        _append(lineBreakChar, p2);
      }
    }

    if (_void.contains(tag)) return;
    if (!hidden && (tag == 'td' || tag == 'th')) {
      if (rowHasCell) pendingCell = true;
      rowHasCell = true;
    }
    final f = _frameFor(
      tag,
      decls,
      parent,
      hidden,
      el,
      href: tag == 'a' ? _attr(e, 'href') : null,
    );
    if (f.kind == _Kind.pre) skipLeadingNewline = true;
    if (f.kind == _Kind.row) rowHasCell = false;
    frames.add(f);
    els.add(el);
  }

  _Frame _frameFor(
    String tag,
    CssDeclarations d,
    _Frame parent,
    bool hidden,
    CssElement el, {
    String? href,
  }) {
    var run = parent.run;
    switch (tag) {
      case 'i' || 'em' || 'cite' || 'var' || 'dfn':
        run = run.copyWith(italic: true);
      case 'b' || 'strong':
        run = run.copyWith(bold: true);
      case 'sup':
        run = run.copyWith(superscript: true);
      case 'sub':
        run = run.copyWith(subscript: true);
    }
    run = run.copyWith(italic: d.italic, bold: d.bold, smallCaps: d.smallCaps);
    String? link = parent.link;
    if (href != null) {
      final h = href.trim();
      if (h.startsWith('#')) {
        link = h.length > 1 ? '$path$h' : null;
      } else {
        final p = resolveHref(dirOf(path), h);
        final frag = fragmentOf(h);
        link = p == null ? null : (frag == null ? p : '$p#$frag');
      }
    }
    return _Frame(
      tag: tag,
      decls: d,
      run: run,
      hidden: hidden,
      link: link,
      align: d.align ?? parent.align,
      indentEm: d.indentEm ?? parent.indentEm,
      quoteDepth: parent.quoteDepth + (tag == 'blockquote' ? 1 : 0),
      listDepth: parent.listDepth + (tag == 'ul' || tag == 'ol' ? 1 : 0),
      inPre: parent.inPre || tag == 'pre',
      inSvg: parent.inSvg || tag == 'svg',
      kind: _textBlocks[tag],
    );
  }

  void _end(String tag, {bool selfClosing = false}) {
    if (_void.contains(tag)) return;
    final i = frames.lastIndexWhere((f) => f.tag == tag);
    if (i < 0) return;
    _popTo(i);
  }

  /// Fecha os quadros a partir de [i] (inclusive); fechar bloco ou contêiner termina o bloco em montagem.
  void _popTo(int i) {
    while (frames.length > i) {
      final f = frames.removeLast();
      els.removeLast();
      if (!f.hidden && (f.kind != null || _containers.contains(f.tag))) {
        _flush();
      }
    }
  }

  void _text(String s) {
    final f = top;
    if (f.hidden || f.inSvg || s.isEmpty) return;
    if (f.inPre) {
      var t = s;
      if (skipLeadingNewline) {
        if (t.startsWith('\n')) t = t.substring(1);
        skipLeadingNewline = false;
      }
      final lines = t.split('\n');
      for (var k = 0; k < lines.length; k++) {
        if (k > 0) _flush();
        if (lines[k].isNotEmpty) _append(lines[k], f);
      }
      return;
    }
    skipLeadingNewline = false;
    final buf = StringBuffer();
    void emit() {
      if (buf.isEmpty) return;
      _append(buf.toString(), f);
      buf.clear();
    }

    for (final c in s.codeUnits) {
      if (c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D || c == 0x0C) {
        if (rawLen + buf.length > 0 && !_atLineStart(buf)) {
          emit();
          if (!pendingSpace) spaceFrame = f;
          pendingSpace = true;
        }
        continue;
      }
      if (pendingCell) {
        emit();
        if (rawLen > 0) _append(' · ', f);
        pendingCell = false;
        pendingSpace = false;
      }
      if (pendingSpace) {
        emit();
        // o espaço colapsado fica com o estilo de onde ele apareceu (como no navegador)
        if (rawLen > 0) _append(' ', spaceFrame ?? f);
        pendingSpace = false;
      }
      buf.writeCharCode(c);
    }
    emit();
  }

  bool _atLineStart(StringBuffer buf) {
    if (buf.isNotEmpty) return false;
    return runs.isNotEmpty && runs.last.text.endsWith(lineBreakChar);
  }

  void _append(String s, _Frame f) {
    if (rawLen == 0 && owner == null) {
      owner = frames.lastWhere((x) => x.kind != null, orElse: () => top);
    }
    final last = runs.isEmpty ? null : runs.last;
    if (last != null && last.style == f.run && last.link == f.link) {
      last.text += s;
    } else {
      runs.add(_RawRun(s, f.run, f.link));
    }
    rawLen += s.length;
  }

  int _idPrefix() => rawLen + (pendingSpace && rawLen > 0 ? 1 : 0);

  BlockStyle _blockStyle(_Frame f, {required bool anonymous}) => BlockStyle(
    align: f.align,
    indentEm: f.indentEm,
    marginTopEm: anonymous ? null : f.decls.marginTopEm,
    marginBottomEm: anonymous ? null : f.decls.marginBottomEm,
    pageBreakBefore: !anonymous && (f.decls.pageBreakBefore ?? false),
    quoteDepth: f.quoteDepth,
    listDepth: f.listDepth,
  );

  void _flush() {
    pendingSpace = false;
    pendingCell = false;
    final o = owner;
    if (rawLen == 0 || o == null) {
      out.carry([for (final (id, _) in pendingIds) id]);
    } else {
      final kind = o.kind ?? _Kind.paragraph;
      out.addTextBlock(
        kind,
        kind == _Kind.heading ? int.parse(o.tag.substring(1)) : 0,
        List.of(runs),
        _blockStyle(o, anonymous: o.kind == null),
        List.of(pendingIds),
      );
    }
    pendingIds.clear();
    runs.clear();
    rawLen = 0;
    owner = null;
  }

  static bool _attrPresent(XmlStartElementEvent e, String local) =>
      e.attributes.any((a) => a.localName == local);

  static int? _int(String? v) =>
      v == null ? null : int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
}

/// Monta o texto canônico bloco a bloco (NFC, `\n` entre blocos) e as posições dos `id`.
final class _Builder {
  final List<ContentBlock> blocks = [];
  final List<int> starts = [];
  final Map<String, int> ids = {};
  final StringBuffer text = StringBuffer();
  final List<String> carried = [];
  int length = 0;

  int _nextStart() => blocks.isEmpty ? 0 : length + 1;

  void carry(List<String> idList) => carried.addAll(idList);

  void _place(int start, String piece, ContentBlock block) {
    for (final id in carried) {
      ids.putIfAbsent(id, () => start);
    }
    carried.clear();
    if (blocks.isNotEmpty) text.write('\n');
    text.write(piece);
    blocks.add(block);
    starts.add(start);
    length = start + piece.length;
  }

  void addObject(ContentBlock block) => _place(_nextStart(), block.text, block);

  void addTextBlock(
    _Kind kind,
    int level,
    List<_RawRun> raw,
    BlockStyle style,
    List<(String, int)> pendingIds,
  ) {
    final rawText = raw.map((r) => r.text).join();
    final runs = _normalize(raw);
    if (runs.isEmpty) {
      carry([for (final (id, _) in pendingIds) id]);
      return;
    }
    final block = switch (kind) {
      _Kind.heading => HeadingBlock(level, runs, style),
      _Kind.listItem => ListItemBlock(runs, style),
      _Kind.pre => PreformattedBlock(runs, style),
      _Kind.paragraph || _Kind.row => ParagraphBlock(runs, style),
    };
    final start = _nextStart();
    final piece = block.text;
    _place(start, piece, block);
    for (final (id, prefix) in pendingIds) {
      final p = prefix >= rawText.length
          ? rawText
          : rawText.substring(0, prefix);
      final n = unorm.nfc(p).length;
      ids.putIfAbsent(id, () => start + (n < piece.length ? n : piece.length));
    }
  }

  ParsedItem finish() {
    for (final id in carried) {
      ids.putIfAbsent(id, () => length);
    }
    carried.clear();
    return ParsedItem(
      blocks: List.unmodifiable(blocks),
      text: text.toString(),
      blockStarts: List.unmodifiable(starts),
      idOffsets: Map.unmodifiable(ids),
    );
  }

  /// NFC por trecho: marcas combinantes no começo de um trecho vão para o fim do anterior (a composição não
  /// atravessa trechos); trechos vazios somem; vizinhos com o mesmo estilo e link se juntam.
  static List<TextRun> _normalize(List<_RawRun> raw) {
    final texts = [for (final r in raw) r.text];
    for (var i = 1; i < texts.length; i++) {
      var k = 0;
      while (k < texts[i].length && _isCombining(texts[i].codeUnitAt(k))) {
        k++;
      }
      if (k > 0) {
        texts[i - 1] += texts[i].substring(0, k);
        texts[i] = texts[i].substring(k);
      }
    }
    final out = <TextRun>[];
    for (var i = 0; i < raw.length; i++) {
      if (texts[i].isEmpty) continue;
      final t = unorm.nfc(texts[i]);
      if (out.isNotEmpty &&
          out.last.style == raw[i].style &&
          out.last.link == raw[i].link) {
        out[out.length - 1] = TextRun(
          out.last.text + t,
          style: raw[i].style,
          link: raw[i].link,
        );
      } else {
        out.add(TextRun(t, style: raw[i].style, link: raw[i].link));
      }
    }
    return out;
  }

  static bool _isCombining(int c) =>
      (c >= 0x0300 && c <= 0x036F) ||
      (c >= 0x1AB0 && c <= 0x1AFF) ||
      (c >= 0x1DC0 && c <= 0x1DFF) ||
      (c >= 0x20D0 && c <= 0x20FF) ||
      (c >= 0xFE20 && c <= 0xFE2F);
}
