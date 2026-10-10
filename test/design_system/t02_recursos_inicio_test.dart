// T02 — os recursos da Início nova e da revisão registrados no app antes das T03–T05: os ícones e as capas
// exportados (`assets/icons/inicio2/`, `assets/illustrations/inicio2/`) e as famílias novas (Bricolage 14 e 32,
// Literata 22 e 15/400 — D-246); e a D-249 (as estáticas da v1 refeitas com os avanços do HVAR). As larguras são as
// medidas no Chromium nas pranchas 01, 61, 62 e 63 (`docs/design/medicao/inicio2/validacao_fontes.json`).
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

/// Largura da linha como o Chromium mede (`right − left` do retângulo do texto): a do SkParagraph, sem arredondar.
double largura(String texto, TextStyle estilo) {
  final p = TextPainter(
    text: TextSpan(text: texto, style: estilo),
    textDirection: TextDirection.ltr,
  )..layout();
  final linhas = p.computeLineMetrics();
  p.dispose();
  expect(linhas, hasLength(1), reason: texto);
  return linhas.single.width;
}

TextStyle estilo(
  String familia,
  double tamanho,
  FontWeight peso, {
  double ls = 0,
  List<String> reserva = const [],
}) => TextStyle(
  fontFamily: familia,
  fontFamilyFallback: reserva,
  fontSize: tamanho,
  fontWeight: peso,
  letterSpacing: ls,
);

typedef Linha = ({String texto, TextStyle estilo, double chromium, String id});

final List<Linha> _novas = [
  (
    texto: 'Dom Casmurro',
    estilo: estilo('Bricolage14', 14, FontWeight.w800),
    chromium: 104.09,
    id: 'rv63.sheet.preview.book',
  ),
  (
    texto: 'O meu fim evidente era atar',
    estilo: estilo('Literata22', 22, FontWeight.w400),
    chromium: 284.88,
    id: 'rv61.deck.card.quote.mark',
  ),
  (
    texto: 'restaurar na velhice a',
    estilo: estilo('Literata22', 22, FontWeight.w400),
    chromium: 223.23,
    id: 'rv61.deck.card.quote.mark',
  ),
  (
    texto: 'adolescência.',
    estilo: estilo(
      'Literata22',
      22,
      FontWeight.w400,
      reserva: ['Literata22Ext'],
    ),
    chromium: 139.44,
    id: 'rv61.deck.card.quote.mark',
  ),
  (
    texto: 'O meu fim evidente era atar as duas pontas',
    estilo: estilo('Literata15', 15, FontWeight.w400),
    chromium: 299.58,
    id: 'rv62.summary.newNote.quote.mark',
  ),
  (
    texto: 'da vida…',
    estilo: estilo('Literata15', 15, FontWeight.w400),
    chromium: 64.61,
    id: 'rv62.summary.newNote.quote.mark',
  ),
];

// D-249: as estáticas da v1 (Figtree 400–700, Bricolage 12…42) nas linhas da Início nova.
final List<Linha> _v1 = [
  (
    texto: 'Continuar lendo',
    estilo: estilo('Figtree', 16, FontWeight.w700),
    chromium: 117.88,
    id: 'i01.hero.cta.label',
  ),
  (
    texto: 'Machado de Assis · PDF',
    estilo: estilo('Figtree', 13, FontWeight.w500),
    chromium: 138.68,
    id: 'i01.recent.row1.subtitle',
  ),
  (
    texto: 'Biblioteca',
    estilo: estilo('Figtree', 11, FontWeight.w600),
    chromium: 49.8,
    id: 'i01.nav.library.label',
  ),
  (
    texto: 'M',
    estilo: estilo('Bricolage18', 18, FontWeight.w800),
    chromium: 17.06,
    id: 'i01.header.avatar',
  ),
  (
    texto: 'Leitoras de',
    estilo: estilo('Bricolage22', 22, FontWeight.w800, ls: -0.5),
    chromium: 112.98,
    id: 'i01.club.title',
  ),
  (
    texto: 'Recém-chegados',
    estilo: estilo('Bricolage24', 24, FontWeight.w800, ls: -0.6),
    chromium: 195.47,
    id: 'i01.recent.title',
  ),
  (
    texto: '18',
    estilo: estilo('Bricolage34', 34, FontWeight.w800, ls: -1),
    chromium: 31.86,
    id: 'i01.today.dial.value',
  ),
  (
    texto: 'Continue',
    estilo: estilo('Bricolage42', 42, FontWeight.w800, ls: -1.4),
    chromium: 170.69,
    id: 'i01.headline',
  ),
  (
    texto: 'BookNest',
    estilo: estilo('Bricolage12', 11, FontWeight.w800),
    chromium: 53.56,
    id: 'rv63.sheet.preview.footer.brand',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  // O Chromium dá o retângulo com 2 casas (±0,005) e cada avanço da estática é arredondado na UPM 10000 (≤ 0,005 px
  // por linha nestes tamanhos): 0,01 px. Com as estáticas antigas da v1, "Continuar lendo" saía 0,053 mais largo.
  const tolerancia = 0.01;

  test(
    'famílias novas: o Flutter mede as linhas como o Chromium (≤ 0,01 px)',
    () {
      for (final l in _novas) {
        expect(
          largura(l.texto, l.estilo),
          closeTo(l.chromium, tolerancia),
          reason: '${l.id} «${l.texto}»',
        );
      }
    },
  );

  test(
    'D-249: as estáticas da v1 refeitas medem como o Chromium (≤ 0,01 px)',
    () {
      for (final l in _v1) {
        expect(
          largura(l.texto, l.estilo),
          closeTo(l.chromium, tolerancia),
          reason: '${l.id} «${l.texto}»',
        );
      }
    },
  );

  test('ícones e capas: os arquivos da pasta, sem sobra nem falta, únicos, no pubspec e abrindo', () async {
    final manifesto = await AssetManifest.loadFromAssetBundle(rootBundle);
    final declarados = manifesto.listAssets().toSet();
    for (final (lista, pasta) in [
      (AppIconsInicio.all, 'assets/icons/inicio2'),
      (AppIllustrationsInicio.all, 'assets/illustrations/inicio2'),
    ]) {
      expect(lista.toSet(), hasLength(lista.length), reason: pasta);
      final naPasta = Directory(pasta)
          .listSync()
          .whereType<File>()
          .map((f) => f.path.replaceAll(r'\', '/'))
          .toSet();
      expect(lista.toSet(), naPasta, reason: pasta);
      for (final a in lista) {
        expect(declarados, contains(a), reason: a);
        final info = await vg.loadPicture(
          SvgStringLoader(File(a).readAsStringSync()),
          null,
        );
        expect(info.size.width, greaterThan(0), reason: a);
        info.picture.dispose();
      }
    }
  });

  test('cada SVG novo tem o tamanho de uso do catálogo da T02', () {
    final catalogo = json.decode(
      File('docs/design/medicao/inicio2/svg_catalogo.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final tamanhos = <String, Set<String>>{};
    for (final porPrancha
        in (catalogo['usos'] as Map<String, dynamic>).values) {
      for (final uso in (porPrancha as Map<String, dynamic>).values) {
        final u = uso as Map<String, dynamic>;
        final t = (u['tamanho'] as List).map((v) => (v as num).toDouble());
        tamanhos.putIfAbsent(u['arquivo'] as String, () => {}).add(t.join('×'));
      }
    }
    for (final a in [...AppIconsInicio.all, ...AppIllustrationsInicio.all]) {
      final svg = File(a).readAsStringSync();
      final m = RegExp(r'<svg[^>]* width="([\d.]+)" height="([\d.]+)"')
          .firstMatch(svg)!;
      final declarado =
          '${double.parse(m.group(1)!)}×${double.parse(m.group(2)!)}';
      expect(tamanhos[a], {declarado}, reason: a);
    }
  });

  test('famílias novas no FontManifest e no AppFonts (D-246)', () async {
    final manifesto = (json.decode(
      await rootBundle.loadString('FontManifest.json'),
    ) as List).cast<Map<String, dynamic>>();
    final pesos = {
      for (final m in manifesto)
        m['family'] as String: {
          for (final f in (m['fonts'] as List).cast<Map<String, dynamic>>())
            f['asset'] as String: f['weight'],
        },
    };
    for (final sfx in ['', 'Ext', 'Vi']) {
      expect(pesos['Bricolage14$sfx'], {
        'assets/fonts/Bricolage14$sfx-ExtraBold.ttf': 800,
      });
      expect(pesos['Bricolage32$sfx'], {
        'assets/fonts/Bricolage32$sfx-ExtraBold.ttf': 800,
      });
      expect(pesos['Literata22$sfx'], {
        'assets/fonts/Literata22$sfx-Regular.ttf': 400,
      });
      expect(pesos['Literata15$sfx'], {
        'assets/fonts/Literata15$sfx-Regular.ttf': 400,
        'assets/fonts/Literata15$sfx-Medium.ttf': 500,
      });
    }
    expect(AppFonts.bricolage(14, height: 1.2).fontFamily, 'Bricolage14');
    expect(AppFonts.bricolage(32, height: 1.2).fontFamily, 'Bricolage32');
    expect(AppFonts.bricolage(32, height: 1.2).fontFamilyFallback, [
      'Bricolage32Ext',
      'Bricolage32Vi',
    ]);
    expect(AppFonts.literata(22, FontWeight.w400).fontFamily, 'Literata22');
    expect(AppFonts.literata(15, FontWeight.w400).fontFamily, 'Literata15');
    expect(AppFonts.literataStatic[15], {400, 500});
    expect(AppFonts.literataStatic[22], {400});
  });
}
