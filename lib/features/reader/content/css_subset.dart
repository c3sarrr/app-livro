// G09.1 — o subconjunto do CSS do livro que o leitor usa (Anexo 03 §4): `display:none`, itálico, negrito,
// versalete, alinhamento, recuo da 1ª linha, margens verticais (em), quebra antes. Seletores simples
// (elemento, `.classe`, `#id`, `*`) e descendentes; pseudo-classes, atributos, `>`/`+`/`~` e `@regras`
// ficam de fora (melhor não aplicar do que esconder texto por engano). Fontes do editor são ignoradas.
import 'content_blocks.dart';

/// Declarações reconhecidas (nulo = não definido nesta regra).
final class CssDeclarations {
  const CssDeclarations({
    this.display,
    this.italic,
    this.bold,
    this.smallCaps,
    this.align,
    this.indentEm,
    this.marginTopEm,
    this.marginBottomEm,
    this.pageBreakBefore,
  });

  static const CssDeclarations empty = CssDeclarations();

  final String? display;
  final bool? italic;
  final bool? bold;
  final bool? smallCaps;
  final BlockAlign? align;
  final double? indentEm;
  final double? marginTopEm;
  final double? marginBottomEm;
  final bool? pageBreakBefore;

  /// [other] por cima desta.
  CssDeclarations merge(CssDeclarations other) => CssDeclarations(
    display: other.display ?? display,
    italic: other.italic ?? italic,
    bold: other.bold ?? bold,
    smallCaps: other.smallCaps ?? smallCaps,
    align: other.align ?? align,
    indentEm: other.indentEm ?? indentEm,
    marginTopEm: other.marginTopEm ?? marginTopEm,
    marginBottomEm: other.marginBottomEm ?? marginBottomEm,
    pageBreakBefore: other.pageBreakBefore ?? pageBreakBefore,
  );

  /// Declarações de um bloco `prop: valor; …` (também o atributo `style`).
  static CssDeclarations parse(String block) {
    String? display;
    bool? italic;
    bool? bold;
    bool? smallCaps;
    BlockAlign? align;
    double? indent;
    double? top;
    double? bottom;
    bool? breakBefore;
    for (final decl in block.split(';')) {
      final i = decl.indexOf(':');
      if (i <= 0) continue;
      final prop = decl.substring(0, i).trim().toLowerCase();
      final value = decl
          .substring(i + 1)
          .replaceAll(RegExp(r'!\s*important', caseSensitive: false), '')
          .trim()
          .toLowerCase();
      if (value.isEmpty) continue;
      switch (prop) {
        case 'display':
          display = value;
        case 'font-style':
          italic = value == 'italic' || value == 'oblique';
        case 'font-weight':
          final n = int.tryParse(value);
          bold =
              value == 'bold' || value == 'bolder' || (n != null && n >= 600);
        case 'font-variant' || 'font-variant-caps':
          smallCaps = value.contains('small-caps');
        case 'text-align':
          align = switch (value) {
            'left' => BlockAlign.left,
            'right' => BlockAlign.right,
            'center' => BlockAlign.center,
            'justify' => BlockAlign.justify,
            'start' => BlockAlign.start,
            'end' => BlockAlign.end,
            _ => align,
          };
        case 'text-indent':
          indent = lengthToEm(value) ?? indent;
        case 'margin-top':
          top = lengthToEm(value) ?? top;
        case 'margin-bottom':
          bottom = lengthToEm(value) ?? bottom;
        case 'margin':
          final v = value.split(RegExp(r'\s+'));
          final t = lengthToEm(v[0]);
          final b = lengthToEm(v.length >= 3 ? v[2] : v[0]);
          top = t ?? top;
          bottom = b ?? bottom;
        case 'page-break-before' || 'break-before':
          breakBefore = const {
            'always',
            'page',
            'left',
            'right',
            'recto',
            'verso',
          }.contains(value);
      }
    }
    return CssDeclarations(
      display: display,
      italic: italic,
      bold: bold,
      smallCaps: smallCaps,
      align: align,
      indentEm: indent,
      marginTopEm: top,
      marginBottomEm: bottom,
      pageBreakBefore: breakBefore,
    );
  }
}

/// Comprimento CSS → em (16 px = 1 em; 12 pt = 1 em); `%` e o resto → nulo.
double? lengthToEm(String v) {
  final s = v.trim();
  if (s == '0') return 0;
  final m = RegExp(r'^(-?\d*\.?\d+)(em|rem|px|pt|ex)$').firstMatch(s);
  if (m == null) return null;
  final n = double.parse(m[1]!);
  return switch (m[2]) {
    'em' || 'rem' => n,
    'px' => n / 16,
    'pt' => n / 12,
    'ex' => n / 2,
    _ => null,
  };
}

/// Um elemento visto pelo seletor: nome, classes e id.
typedef CssElement = ({String tag, Set<String> classes, String? id});

final class _Compound {
  const _Compound(this.tag, this.classes, this.id);

  final String? tag;
  final Set<String> classes;
  final String? id;

  bool matches(CssElement e) =>
      (tag == null || tag == e.tag) &&
      (id == null || id == e.id) &&
      classes.every(e.classes.contains);
}

final class CssRule {
  const CssRule._(
    this._compounds,
    this.specificity,
    this.order,
    this.declarations,
  );

  /// Do ancestral mais distante ao próprio elemento (combinador descendente entre eles).
  final List<_Compound> _compounds;
  final int specificity;
  final int order;
  final CssDeclarations declarations;

  /// [ancestors] = do mais externo ao pai.
  bool matches(CssElement e, List<CssElement> ancestors) {
    if (!_compounds.last.matches(e)) return false;
    var a = ancestors.length - 1;
    for (var c = _compounds.length - 2; c >= 0; c--) {
      while (a >= 0 && !_compounds[c].matches(ancestors[a])) {
        a--;
      }
      if (a < 0) return false;
      a--;
    }
    return true;
  }
}

final class StyleSheet {
  const StyleSheet(this.rules);

  static const StyleSheet empty = StyleSheet([]);

  final List<CssRule> rules;

  static final RegExp _compoundRe = RegExp(
    r'^(\*|[a-zA-Z][\w-]*)?((?:[.#][\w-]+)*)$',
  );

  /// Regras de [css], na ordem do texto (entre folhas, vale a ordem delas no documento — [cascade]).
  static StyleSheet parse(String css) {
    final src = css.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), ' ');
    final rules = <CssRule>[];
    var order = 0;
    var i = 0;
    while (i < src.length) {
      final open = src.indexOf('{', i);
      if (open < 0) break;
      final prelude = src.substring(i, open).trim();
      // fim do bloco, respeitando chaves aninhadas (@media { … { … } })
      var depth = 1;
      var j = open + 1;
      while (j < src.length && depth > 0) {
        final c = src.codeUnitAt(j);
        if (c == 0x7B) depth++;
        if (c == 0x7D) depth--;
        j++;
      }
      final body = src.substring(open + 1, depth == 0 ? j - 1 : j);
      i = j;
      // `@charset …;` antes de uma regra fica no prelúdio: só o último trecho depois de `;` é o seletor
      final selectorText = prelude.contains(';')
          ? prelude.substring(prelude.lastIndexOf(';') + 1).trim()
          : prelude;
      if (selectorText.startsWith('@') || selectorText.isEmpty) continue;
      final decls = CssDeclarations.parse(body);
      for (final sel in selectorText.split(',')) {
        final parsed = _selector(sel.trim());
        if (parsed == null) continue;
        rules.add(CssRule._(parsed.$1, parsed.$2, order++, decls));
      }
    }
    return StyleSheet(rules);
  }

  static (List<_Compound>, int)? _selector(String sel) {
    if (sel.isEmpty || RegExp(r'[:\[>+~()]').hasMatch(sel)) return null;
    final compounds = <_Compound>[];
    var spec = 0;
    for (final part in sel.split(RegExp(r'\s+'))) {
      final m = _compoundRe.firstMatch(part);
      if (m == null || part.isEmpty) return null;
      final tagRaw = m[1];
      final tag = tagRaw == null || tagRaw == '*' ? null : tagRaw.toLowerCase();
      final classes = <String>{};
      String? id;
      for (final x in RegExp(r'([.#])([\w-]+)').allMatches(m[2] ?? '')) {
        if (x[1] == '.') {
          classes.add(x[2]!);
        } else {
          id = x[2];
        }
      }
      spec +=
          (id == null ? 0 : 100) + classes.length * 10 + (tag == null ? 0 : 1);
      compounds.add(_Compound(tag, classes, id));
    }
    return compounds.isEmpty ? null : (compounds, spec);
  }
}

/// As declarações que valem para [e] (cascata: especificidade, depois ordem; `style` por cima de tudo).
CssDeclarations cascade(
  List<StyleSheet> sheets,
  CssElement e,
  List<CssElement> ancestors, {
  String? inlineStyle,
}) {
  final hits =
      <(CssRule, int)>[
        for (var i = 0; i < sheets.length; i++)
          for (final r in sheets[i].rules)
            if (r.matches(e, ancestors)) (r, i),
      ]..sort((a, b) {
        var c = a.$1.specificity.compareTo(b.$1.specificity);
        if (c != 0) return c;
        c = a.$2.compareTo(b.$2);
        return c != 0 ? c : a.$1.order.compareTo(b.$1.order);
      });
  var out = CssDeclarations.empty;
  for (final (r, _) in hits) {
    out = out.merge(r.declarations);
  }
  if (inlineStyle != null) out = out.merge(CssDeclarations.parse(inlineStyle));
  return out;
}
