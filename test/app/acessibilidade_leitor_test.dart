// G20.6 (R6–R8, D-208) — os guias de acessibilidade do Flutter em cada tela do leitor, no mundo de referência:
// - o alvo de toque de 48 (Android) e de 44 (iOS), e todo alvo com rótulo — passam; cada alvo que cresceu recebe o
//   toque 1,5 fora de cada lado do desenho (R7);
// - os rótulos dos controles são os `aria-label` do arquivo (R8, D-15), numa tabela por tela;
// - o contraste do texto é medido e não reprova (D-208): o que fica abaixo de 4,5:1 vai para o relatório
//   (`tools/medicao/tmp/contraste_g20.md`, só com BOOKNEST_CAPTURAS, como as capturas).
// As telas: 19, 20 (Creme e Noite — 26b), 20 com a busca, 21, 22, 23, 23b, 24, 24b, 25 (topo, rolada, Mais opções e
// Exportar), 26, 27, 27b e as folhas da nota, Outra cor e Rótulos.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/tap_target.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/dados_t20.dart';
import '../support/dados_t21.dart';
import '../support/dados_t22.dart';
import '../support/dados_t23.dart';
import '../support/dados_t24.dart';
import '../support/dados_t25.dart';
import '../support/fase_l20.dart';
import '../support/fase_l25.dart';
import '../support/fase_l26.dart';
import '../support/fase_l27.dart';
import '../support/load_fonts.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

Finder _k(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// O que ficou abaixo de 4,5:1, por tela (para o relatório).
final List<String> _contraste = [];

/// As falhas do teste em curso (todas as telas dele, para ver a lista inteira de uma vez).
final List<String> _falhas = [];

/// Os alvos de toque menores que [minimo] — a regra do guia do Flutter (`MinimumTapTargetGuideline`), refeita aqui com
/// duas folgas a mais: um nó cortado pela borda de uma lista rolável (a linha do sumário meio fora da folha) está
/// "rolado para fora", como o guia já trata a borda da tela; e os controles deslizantes também contam (o guia só olha
/// o toque e o toque longo).
List<String> _pequenos(WidgetTester tester, double minimo) {
  final out = <String>[];
  for (final view in tester.binding.renderViews) {
    final dpr = view.flutterView.devicePixelRatio;
    final tela = view.flutterView.physicalSize;
    Rect global(SemanticsNode n) {
      var r = n.rect;
      for (SemanticsNode? c = n; c != null; c = c.parent) {
        final t = c.transform;
        if (t != null) r = MatrixUtils.transformRect(t, r);
      }
      return r;
    }

    bool cortadoPorLista(SemanticsNode n, Rect r) {
      for (var p = n.parent; p != null; p = p.parent) {
        if (!p.getSemanticsData().flagsCollection.hasImplicitScrolling) {
          continue;
        }
        final v = global(p);
        const d = 0.5;
        return (r.top - v.top).abs() <= d * dpr ||
            (r.bottom - v.bottom).abs() <= d * dpr ||
            (r.left - v.left).abs() <= d * dpr ||
            (r.right - v.right).abs() <= d * dpr;
      }
      return false;
    }

    void visitar(SemanticsNode n) {
      n.visitChildren((c) {
        visitar(c);
        return true;
      });
      if (n.isMergedIntoParent) return;
      final data = n.getSemanticsData();
      if (data.flagsCollection.isHidden) return;
      // os controles deslizantes (aumentar/diminuir) também são alvos: a barra de posição, a espessura, o brilho
      if (!data.hasAction(SemanticsAction.tap) &&
          !data.hasAction(SemanticsAction.longPress) &&
          !data.hasAction(SemanticsAction.increase) &&
          !data.hasAction(SemanticsAction.decrease)) {
        return;
      }
      if (data.flagsCollection.isLink) return;
      final r = global(n);
      const delta = 0.001;
      if (r.left <= delta ||
          r.top <= delta ||
          (r.bottom - tela.height).abs() <= delta ||
          (r.right - tela.width).abs() <= delta) {
        return;
      }
      if (cortadoPorLista(n, r)) return;
      final w = r.width / dpr;
      final h = r.height / dpr;
      if (w < minimo - delta || h < minimo - delta) {
        out.add(
          '"${data.label}" ${w.toStringAsFixed(1)}×${h.toStringAsFixed(1)} em '
          '(${(r.left / dpr).toStringAsFixed(1)}, ${(r.top / dpr).toStringAsFixed(1)})',
        );
      }
    }

    final raiz = view.owner?.semanticsOwner?.rootSemanticsNode;
    if (raiz != null) visitar(raiz);
  }
  return out;
}

/// R7: o toque a 1,5 da borda de cada alvo que cresceu (em cada lado onde ele cresceu) chega a ele — mesmo onde o pai
/// é justo. Alvos escondidos, sem toque ou fora da tela ficam de fora.
void _bordas(WidgetTester tester, String tela) {
  final alvos = <RenderTapTarget>[];
  void visitar(RenderObject o) {
    if (o is RenderTapTarget) alvos.add(o);
    o.visitChildren(visitar);
  }

  for (final v in tester.binding.renderViews) {
    visitar(v);
  }
  final telaRect =
      Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio;
  Rect retangulo(RenderTapTarget t) =>
      MatrixUtils.transformRect(t.getTransformTo(null), Offset.zero & t.size);
  double distancia(Rect r, Offset p) {
    final dx = [
      r.left - p.dx,
      0.0,
      p.dx - r.right,
    ].reduce((a, b) => a > b ? a : b);
    final dy = [
      r.top - p.dy,
      0.0,
      p.dy - r.bottom,
    ].reduce((a, b) => a > b ? a : b);
    return dx * dx + dy * dy;
  }

  final vivos = <RenderTapTarget>[];
  for (final a in alvos) {
    if (!a.attached || !a.hasSize) continue;
    var escondido = false;
    for (var p = a.parent; p != null; p = p.parent) {
      if ((p is RenderOffstage && p.offstage) ||
          (p is RenderIgnorePointer && p.ignoring) ||
          (p is RenderAbsorbPointer && p.absorbing)) {
        escondido = true;
        break;
      }
    }
    if (escondido) continue;
    // coberto por outra camada (o painel da busca sobre a ilha, a folha da nota sobre a barra): fica de fora
    final centro = a.localToGlobal(a.size.center(Offset.zero));
    if (!telaRect.contains(centro) ||
        !tester
            .hitTestOnBinding(centro)
            .path
            .any((e) => identical(e.target, a))) {
      continue;
    }
    vivos.add(a);
  }
  for (final a in vivos) {
    final g = a.hitArea;
    final s = a.size;
    const d = 1.5;
    final pontos = <(String, Offset)>[
      if (g.left < 0) ('esquerda', Offset(-d, s.height / 2)),
      if (g.right > s.width) ('direita', Offset(s.width + d, s.height / 2)),
      if (g.top < 0) ('em cima', Offset(s.width / 2, -d)),
      if (g.bottom > s.height) ('embaixo', Offset(s.width / 2, s.height + d)),
    ];
    final nome = a.debugSemantics?.getSemanticsData().label ?? '?';
    for (final (lado, local) in pontos) {
      final global = a.localToGlobal(local);
      if (!telaRect.contains(global)) continue;
      // o vizinho mais perto (ou com o desenho ali) fica com o toque: a divisa é no meio do vão
      final meu = distancia(retangulo(a), global);
      if (vivos.any(
        (o) => !identical(o, a) && distancia(retangulo(o), global) <= meu,
      )) {
        continue;
      }
      final r = tester.hitTestOnBinding(global);
      if (!r.path.any((e) => identical(e.target, a))) {
        _falhas.add('$tela [borda] "$nome" $lado: o toque não chega');
      } else if (!r.path.any(
        (e) => e.target is RenderPointerListener && _dentro(e.target, a),
      )) {
        // chegou ao alvo, mas a ninguém que age dentro dele (a borda de uma caixa em volta de um campo)
        _falhas.add(
          '$tela [borda] "$nome" $lado: o toque não chega a quem age',
        );
      }
    }
  }
}

/// R8 (D-15): os rótulos dos controles = os `aria-label` do arquivo (os botões, os links, os campos e os controles
/// deslizantes das fases L20a–L27b), por tela. Duas decisões mudaram o arquivo: a legenda da Atkinson é "baixa visão"
/// (D-147), e o cartão das Marcadas é lido inteiro, com "Abrir na página N" como a ação (D-158) — `dica:` = o hint.
const List<String> _ilhas = [
  'Fechar o livro',
  'Buscar no livro',
  'Página marcada',
  'Posição no livro',
  'Anotar à mão',
];
const Map<String, List<String>> _ariaLabels = {
  '20': _ilhas,
  '26b': _ilhas,
  '21': [
    'Grifar em amarelo',
    'Grifar em rosa',
    'Grifar em verde',
    'Grifar em lavanda',
    'Escolher outra cor',
    'Sublinhar',
  ],
  '22': [
    'Caneta',
    'Marca-texto',
    'Borracha',
    'Laço — selecionar e mover traços',
    'Linha reta',
    'Espaço — arrastar entre as linhas para abrir lugar de escrever',
    'Cor da caneta: coral. Toque para escolher qualquer cor',
    'Fina',
    'Média',
    'Grossa',
    'Desfazer',
    'Refazer',
  ],
  '23': [
    'Fechar ajustes',
    'Espessura',
    'Coral',
    'Roxo',
    'Azul',
    'Verde',
    'Dourado',
    'Tinta preta',
    'Salvar a cor atual nas favoritas',
    'Roda de cores: tom e intensidade',
    'Brilho',
  ],
  '23b': [
    'Fechar ajustes',
    'amarelo, rótulo lindo, 5 grifos',
    'rosa, rótulo personagem, 3 grifos',
    'verde, rótulo ideia, 2 grifos',
    'lavanda, rótulo pro clube, 2 grifos',
  ],
  '24b': [
    'Recolher a nota',
    'Apagar a nota',
    'Arrastar para mudar a altura do espaço',
  ],
  '25 topo': [
    'Voltar ao livro',
    'Exportar grifos e notas',
    'Buscar nos grifos e notas',
    'Amarelo',
    'Rosa',
    'Verde',
    'Lavanda',
    'Tinta coral',
    'Mais opções',
  ],
  '26': [
    'Fechar',
    'Diminuir a letra',
    'Tamanho da letra',
    'Aumentar a letra',
    'Literata, tela',
    'Lora, clássica',
    'Figtree, sem serifa',
    'Atkinson, baixa visão',
    'Tema Creme',
    'Tema Branco',
    'Tema Sépia',
    'Tema Noite',
  ],
  '27': ['Fechar'],
  '27b': [
    'Fechar',
    'dica: Abrir na página 3',
    'Tirar a marca da página 3',
    'dica: Abrir na página 6',
    'Tirar a marca da página 6',
    'dica: Abrir na página 159',
    'Tirar a marca da página 159',
  ],
};

/// Os rótulos dos nós da tela (os nós juntados entram pelo de cima) e as dicas, com `dica: `.
Set<String> _rotulos(WidgetTester tester) {
  final out = <String>{};
  void visitar(SemanticsNode n) {
    if (!n.isMergedIntoParent) {
      final d = n.getSemanticsData();
      if (d.label.isNotEmpty) out.add(d.label);
      if (d.hint.isNotEmpty) out.add('dica: ${d.hint}');
    }
    n.visitChildren((c) {
      visitar(c);
      return true;
    });
  }

  for (final v in tester.binding.renderViews) {
    final raiz = v.owner?.semanticsOwner?.rootSemanticsNode;
    if (raiz != null) visitar(raiz);
  }
  return out;
}

/// [o] é [alvo] ou fica dentro dele.
bool _dentro(Object o, RenderObject alvo) {
  if (o is! RenderObject) return false;
  for (RenderObject? p = o; p != null; p = p.parent) {
    if (identical(p, alvo)) return true;
  }
  return false;
}

/// Onde o guia do Flutter, como ele é, não passa e por quê (a regra refeita em [_pequenos] confere essas telas).
const Map<String, String> _guiaComMotivo = {
  '23 android': 'um nó na borda da tela (x 0, y −7), cortado por ela: o guia não o trata como fora da tela',
  '27 android': 'a linha do sumário cortada pela borda da lista (7,5 de altura à vista): rolada para fora',
  '27 iOS': 'a linha do sumário cortada pela borda da lista (7,5 de altura à vista): rolada para fora',
};

/// O resultado dos guias do Flutter como eles são (`androidTapTargetGuideline`, `iOSTapTargetGuideline`), por tela:
/// vai para o relatório ao lado da regra refeita em [_pequenos].
final List<String> _guiasDoFlutter = [];

/// Os três guias de toque (reprovam), os rótulos do arquivo e o contraste (só medido).
Future<void> _guias(WidgetTester tester, String tela) async {
  await _quadros(tester, 4);
  final esperados = _ariaLabels[tela];
  if (esperados != null) {
    final tem = _rotulos(tester);
    for (final r in esperados) {
      if (!tem.contains(r)) _falhas.add('$tela [aria-label] sem o nó "$r"');
    }
  }
  _bordas(tester, tela);
  for (final (nome, minimo) in [('android 48', 48.0), ('iOS 44', 44.0)]) {
    for (final f in _pequenos(tester, minimo)) {
      _falhas.add('$tela [$nome] $f');
    }
  }
  for (final (nome, guia) in [
    ('android', androidTapTargetGuideline),
    ('iOS', iOSTapTargetGuideline),
  ]) {
    final g = await guia.evaluate(tester);
    final porque = _guiaComMotivo['$tela $nome'];
    _guiasDoFlutter.add(
      '| $tela | $nome | ${g.passed ? 'passa' : 'não passa — ${porque ?? '?'}'} |',
    );
    if (!g.passed) {
      // ignore: avoid_print
      print('G20GUIA $tela $nome ${g.reason?.replaceAll('\n', ' | ')}');
      // o guia como ele é reprova nas telas sem um motivo conhecido (a regra refeita em [_pequenos] cobre essas)
      if (porque == null) {
        _falhas.add('$tela [guia do Flutter, $nome] ${g.reason}');
      }
    }
  }
  final r = await labeledTapTargetGuideline.evaluate(tester);
  if (!r.passed) {
    _falhas.add('$tela [rótulo] ${r.reason}'.replaceAll('\n', ' | '));
  }
  final c = await textContrastGuideline.evaluate(tester);
  if (!c.passed) {
    _contraste.add(
      '## $tela (o guia do Flutter, nos nós do leitor de tela)\n\n${c.reason}\n',
    );
  }
  await _contrasteDosTextos(tester, tela);
}

/// As linhas da tabela do contraste dos textos que se veem, sem repetir (texto, cor, fundo).
final Map<String, String> _textosBaixos = {};

String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

double _luminancia(int argb) {
  double canal(int v) {
    final c = v / 255;
    return c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * canal((argb >> 16) & 0xFF) +
      0.7152 * canal((argb >> 8) & 0xFF) +
      0.0722 * canal(argb & 0xFF);
}

double _razao(int a, int b) {
  final la = _luminancia(a);
  final lb = _luminancia(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// A cor e o estilo da letra de [texto]: o do 1º trecho com letras e cor.
TextStyle? _estilo(InlineSpan texto) {
  TextStyle? achado;
  void visitar(InlineSpan s, TextStyle acima) {
    if (achado != null) return;
    final aqui = acima.merge(s.style);
    if (s is TextSpan &&
        (s.text?.trim().isNotEmpty ?? false) &&
        aqui.color != null) {
      achado = aqui;
      return;
    }
    if (s is TextSpan) {
      for (final f in s.children ?? const <InlineSpan>[]) {
        visitar(f, aqui);
      }
    }
  }

  visitar(texto, const TextStyle());
  return achado;
}

/// D-208: o contraste de cada texto que se vê na tela (não só o dos nós do leitor de tela), medido na imagem: a letra é
/// a cor declarada do texto (o texto escurecido por um véu ou esmaecido não aparece com ela e fica de fora), o fundo é
/// a cor mais comum no retângulo do texto. Abaixo de 4,5:1 (3:1 no texto grande — 18 ou mais, ou 14 em negrito) vai
/// para a lista do design.
Future<void> _contrasteDosTextos(WidgetTester tester, String tela) async {
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final dpr = tester.view.devicePixelRatio;
  final imagem = (await tester.runAsync(
    () => layer.toImage(view.paintBounds),
  ))!;
  final dados = (await tester.runAsync(
    () => imagem.toByteData(format: ui.ImageByteFormat.rawStraightRgba),
  ))!;
  final w = imagem.width;
  final h = imagem.height;
  imagem.dispose();
  int px(int x, int y) {
    final i = (y * w + x) * 4;
    return 0xFF000000 |
        (dados.getUint8(i) << 16) |
        (dados.getUint8(i + 1) << 8) |
        dados.getUint8(i + 2);
  }

  bool perto(int a, int b) =>
      ((a >> 16 & 0xFF) - (b >> 16 & 0xFF)).abs() <= 6 &&
      ((a >> 8 & 0xFF) - (b >> 8 & 0xFF)).abs() <= 6 &&
      ((a & 0xFF) - (b & 0xFF)).abs() <= 6;

  // os textos: o `AppText` do app (o desenho dele não é um RenderParagraph) e os `Text` (os campos, as dicas)
  final textos = <(InlineSpan, RenderBox)>[
    for (final e in find.byType(AppText).evaluate())
      if (e.renderObject case final RenderBox b)
        ((e.widget as AppText).span, b),
  ];
  void visitar(RenderObject o) {
    if (o is RenderParagraph) textos.add((o.text, o));
    o.visitChildren(visitar);
  }

  visitar(view);
  for (final (span, p) in textos) {
    if (!p.attached || !p.hasSize || p.size.isEmpty) continue;
    final estilo = _estilo(span);
    final cor = estilo?.color;
    if (estilo == null || cor == null || cor.a < 1) continue;
    final letra = cor.toARGB32() | 0xFF000000;
    final r = MatrixUtils.transformRect(
      p.getTransformTo(null),
      Offset.zero & p.size,
    );
    final x0 = math.max(0, (r.left * dpr).floor());
    final y0 = math.max(0, (r.top * dpr).floor());
    final x1 = math.min(w, (r.right * dpr).ceil());
    final y1 = math.min(h, (r.bottom * dpr).ceil());
    if (x1 - x0 < 2 || y1 - y0 < 2) continue;
    final contagem = <int, int>{};
    var daLetra = 0;
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        final c = px(x, y);
        if (perto(c, letra)) {
          daLetra++;
        } else {
          contagem[c] = (contagem[c] ?? 0) + 1;
        }
      }
    }
    // a letra não aparece com a cor dela: coberta, escurecida por um véu ou esmaecida
    if (daLetra < 3 || contagem.isEmpty) continue;
    final fundo = contagem.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final tamanho = estilo.fontSize ?? 14;
    final negrito = (estilo.fontWeight?.value ?? 400) >= 700;
    final grande = tamanho >= 18 || (negrito && tamanho >= 14);
    final minimo = grande ? 3.0 : 4.5;
    final razao = _razao(letra, fundo);
    if (razao >= minimo) continue;
    var texto = span
        .toPlainText(includeSemanticsLabels: false)
        .replaceAll('\n', ' ')
        .trim();
    if (texto.length > 40) texto = '${texto.substring(0, 39)}…';
    final chave = '$texto|${_hex(letra)}|${_hex(fundo)}';
    _textosBaixos.putIfAbsent(
      chave,
      () =>
          '| $tela | "$texto" | ${_hex(letra)} sobre ${_hex(fundo)} | '
          '${razao.toStringAsFixed(2).replaceAll('.', ',')}:1 | '
          '${minimo.toStringAsFixed(1).replaceAll('.', ',')}:1 (${tamanho.toStringAsFixed(1).replaceAll('.', ',')}'
          '${negrito ? ', negrito' : ''}) |',
    );
  }
}

/// No fim de cada teste: a lista inteira das falhas.
void _semFalhas() {
  for (final f in _falhas) {
    // ignore: avoid_print
    print('G20A11Y $f');
  }
  final todas = [..._falhas];
  _falhas.clear();
  expect(todas, isEmpty);
}

void main() {
  setUpAll(loadAppFonts);
  tearDownAll(() {
    final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
    if (pasta == null) return;
    File('tools/medicao/tmp/contraste_g20.md').writeAsStringSync(
      '# Contraste abaixo do mínimo nas telas do leitor (G20, D-208)\n\n'
      '## Os textos que se veem (a cor declarada sobre o fundo medido na tela)\n\n'
      '${_textosBaixos.isEmpty ? 'Nenhum.\n' : '| Tela | Texto | Cores | Razão | Mínimo (tamanho) |\n|---|---|---|---|---|\n${_textosBaixos.values.join('\n')}\n'}'
      '\n## Os nós do leitor de tela (o guia do Flutter)\n\n'
      '${_contraste.isEmpty ? 'Nenhum.\n' : _contraste.join('\n')}',
    );
    File('tools/medicao/tmp/guias_g20.md').writeAsStringSync(
      '# Os guias de alvo de toque do Flutter, como eles são (G20, R6)\n\n'
      '| Tela | Guia | Resultado |\n|---|---|---|\n${_guiasDoFlutter.join('\n')}\n',
    );
  });

  testWidgets(
    'o medidor do contraste acusa o rodapé do arquivo (#A89D8B sobre #F7F0E3) e não o texto escuro',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ColoredBox(
            color: const Color(0xFFF7F0E3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // o rodapé como o app desenha (o AppText) e um texto escuro comum
                AppText(
                  'pág. 159 de 256',
                  style: AppTextStyles.readerFooter.copyWith(
                    color: const Color(0xFFA89D8B),
                  ),
                ),
                const Text(
                  'Dom Casmurro',
                  style: TextStyle(color: Color(0xFF1A1714), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
      await _contrasteDosTextos(tester, 'medidor');
      final achados = {..._textosBaixos.values};
      _textosBaixos.clear();
      expect(achados, hasLength(1));
      expect(
        achados.single,
        contains('"pág. 159 de 256" | #A89D8B sobre #F7F0E3 | 2,36:1 | 4,5:1'),
      );
    },
  );

  testWidgets('19 — a leitura limpa', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela19();
    addTearDown(livro.close);
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _guias(tester, '19');
    _semFalhas();
    h.dispose();
  });

  for (final papel in [ReaderPaper.creme, ReaderPaper.noite]) {
    testWidgets('20 — os controles (${papel.name})', (tester) async {
      final h = tester.ensureSemantics();
      final livro = await livroDaTela20(papel: papel);
      addTearDown(livro.close);
      await abrirTela20(tester, livro);
      await _guias(tester, papel == ReaderPaper.noite ? '26b' : '20');
      _semFalhas();
      h.dispose();
    });
  }

  testWidgets('20 — a busca', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela20();
    addTearDown(livro.close);
    await abrirTela20(tester, livro);
    await tester.tap(_k('r20.topIsland.search'));
    await _quadros(tester, 20);
    await _guias(tester, '20 busca');
    _semFalhas();
    h.dispose();
  });

  testWidgets('21 — a seleção, a nota e Outra cor', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela21();
    addTearDown(livro.close);
    await abrirTela21(tester, livro);
    await _guias(tester, '21');
    await tester.tap(_k('r21.toolbar.actions.note'));
    await _quadros(tester, 20);
    await _guias(tester, '21 nota');
    await tester.binding.handlePopRoute();
    await _quadros(tester, 20);
    await tester.tap(_k('r21.toolbar.colors.other'));
    await _quadros(tester, 20);
    await _guias(tester, '21 outra cor');
    _semFalhas();
    h.dispose();
  });

  testWidgets('22 — o modo anotação', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela22();
    addTearDown(livro.close);
    await abrirTela22(tester, livro);
    await dedoDaTela22!.up();
    dedoDaTela22 = null;
    await _guias(tester, '22');
    _semFalhas();
    h.dispose();
  });

  testWidgets('23 e 23b — os painéis e os Rótulos', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela23();
    addTearDown(livro.close);
    await abrirTela23(tester, livro);
    await _guias(tester, '23');
    _semFalhas();
    h.dispose();
  });

  testWidgets('23b — o marca-texto e os Rótulos', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela23();
    addTearDown(livro.close);
    await abrirTela23b(tester, livro);
    await _guias(tester, '23b');
    await tester.tap(_k('ann.markerPanel.colorsHeader.editLabels'));
    await _quadros(tester, 20);
    await _guias(tester, '23b rótulos');
    _semFalhas();
    h.dispose();
  });

  testWidgets('24 e 24b — o Espaço e a nota à mão', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela24();
    addTearDown(livro.close);
    final (_, dedo) = await abrirTela24(tester, livro);
    await dedo.up();
    await _quadros(tester, 10);
    await _guias(tester, '24');
    _semFalhas();
    h.dispose();
  });

  testWidgets('24b — a nota à mão', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela24b();
    addTearDown(livro.close);
    await abrirTela24b(tester, livro);
    await _guias(tester, '24b');
    _semFalhas();
    h.dispose();
  });

  testWidgets('25 — o topo, rolada, Mais opções e Exportar', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela25();
    addTearDown(livro.close);
    await abrirTela25(tester, livro, tela: const Size(390, 844));
    await _guias(tester, '25 topo');
    await tester.drag(_k('hl.scroll'), const Offset(0, -700));
    await tester.pumpAndSettle();
    await _guias(tester, '25 rolada');
    await tester.drag(_k('hl.scroll'), const Offset(0, 700));
    await tester.pumpAndSettle();
    await tester.tap(_k('hl.list.card1.head.more'));
    await tester.pumpAndSettle();
    await _guias(tester, '25 mais opções');
    await tester.tap(_k('hl.more.close'));
    await tester.pumpAndSettle();
    await tester.tap(_k('hl.topBar.export'));
    await tester.pumpAndSettle();
    await _guias(tester, '25 exportar');
    _semFalhas();
    h.dispose();
  });

  testWidgets('26 — os ajustes', (tester) async {
    final h = tester.ensureSemantics();
    final livro = await livroDaTela26();
    addTearDown(livro.close);
    await abrirTela26(tester, livro);
    await _guias(tester, '26');
    _semFalhas();
    h.dispose();
  });

  for (final marcadas in [false, true]) {
    testWidgets('27${marcadas ? 'b — as marcadas' : ' — o sumário'}', (
      tester,
    ) async {
      final h = tester.ensureSemantics();
      final livro = await livroDaTela27();
      addTearDown(livro.close);
      await abrirTela27(tester, livro, marcadas: marcadas);
      await _guias(tester, marcadas ? '27b' : '27');
      _semFalhas();
      h.dispose();
    });
  }
}
