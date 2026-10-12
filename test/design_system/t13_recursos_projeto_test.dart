// T13 — os recursos das 41 telas das etapas 7–11 no app. T13.10 (R6), as fontes: cada linha de texto que o Chromium mediu
// nas telas a 390, 360 e 430 (`docs/design/medicao/projeto{,_larguras}/validacao_fontes.json`, a largura crua, com 3
// casas) medida pelo Flutter com o `AppFonts`, trecho a trecho como o `validar_fontes.py` a dividiu (as famílias novas
// de `tools/fonts/fontes_projeto.json`, as que já existiam e a reserva do "≈" e da "→" — D-281); as famílias no
// FontManifest, o `AppFonts`, as ligaduras que o espaçamento desliga (D-282: `liga` e `clig`, como o Blink) e a lista
// de licenças, que cobre cada arquivo de `assets/fonts/`.
// T13.11 (R7), os SVGs: as pastas por área (D-284) iguais ao catálogo e às classes da área, no pubspec, abrindo no
// flutter_svg e no tamanho de uso; os reusados (D-283) no pubspec; os gráficos fora dos assets.
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_icons_biblioteca.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_cronometro.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_entrada.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_perfil.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_scanner.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_biblioteca.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_cronometro.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_entrada.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_perfil.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_scanner.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

const _pesos = {
  'Regular': FontWeight.w400,
  'Medium': FontWeight.w500,
  'SemiBold': FontWeight.w600,
  'Bold': FontWeight.w700,
  'ExtraBold': FontWeight.w800,
};

final _nome = RegExp(
  r'^([A-Za-z]+?)(\d+(?:_5)?)?(?:Ext|Vi)?-([A-Za-z]+)\.(?:ttf|otf)$',
);

Map<String, dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// O estilo do app para um trecho medido: a família do arquivo que o validador usou, pelo `AppFonts`, no tamanho,
/// com o espaçamento e os algarismos tabulares do trecho. A reserva (`BookNestApprox`) não é pedida pelo nome: o
/// glifo vem do fallback da Figtree, como no app.
TextStyle estiloDoTrecho(Map<String, dynamic> t) {
  final arquivo = t['fonte'] as String;
  final m = _nome.firstMatch(arquivo)!;
  final familia = m.group(1)!, tamanho = m.group(2), rotulo = m.group(3)!;
  final tam = (t['tamanho'] as num).toDouble();
  final ls = (t['ls'] as num).toDouble();
  final TextStyle s;
  switch (familia) {
    case 'Figtree':
    case 'BookNestApprox':
      s = AppFonts.figtreeReader(tam, _pesos[rotulo]!, letterSpacing: ls);
    case 'Bricolage':
      s = AppFonts.bricolage(
        tam,
        height: 1.2,
        letterSpacing: ls,
        weight: _pesos[rotulo]!,
      );
      expect(s.fontFamily, 'Bricolage$tamanho', reason: arquivo);
    case 'Literata':
      s = AppFonts.literata(tam, _pesos[rotulo]!);
      expect(s.fontFamily, 'Literata$tamanho', reason: arquivo);
    case 'InstrumentSerif':
      s = AppFonts.serif(
        tam,
        height: 1.2,
        italic: rotulo == 'Italic',
        letterSpacing: ls,
      );
    case 'Roboto':
      s = AppFonts.roboto(tam, _pesos[rotulo]!, letterSpacing: ls);
    default:
      throw StateError('família sem estilo no AppFonts: $arquivo');
  }
  return (t['tnum'] as bool) ? s.withTabularFigures() : s;
}

/// Largura da linha como o Chromium mede (do 1º ao último glifo): a do SkParagraph, numa linha só.
double largura(List<Map<String, dynamic>> trechos) {
  final p = TextPainter(
    text: TextSpan(
      children: [
        for (final t in trechos)
          TextSpan(text: t['texto'] as String, style: estiloDoTrecho(t)),
      ],
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final linhas = p.computeLineMetrics();
  p.dispose();
  expect(linhas, hasLength(1));
  return linhas.single.width;
}

/// `a{b,c}d` → `abd`, `acd` (os nomes da lista de licenças).
Iterable<String> expandir(String s) sync* {
  final i = s.indexOf('{');
  if (i < 0) {
    yield s;
    return;
  }
  final j = s.indexOf('}', i);
  for (final op in s.substring(i + 1, j).split(',')) {
    yield* expandir(s.substring(0, i) + op + s.substring(j + 1));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  // O Chromium dá a largura crua com 3 casas (±0,0005) e cada avanço da estática é arredondado na UPM 10000 (≤ 0,005
  // px por linha nestes tamanhos); o HarfBuzz com as mesmas estáticas fica a ≤ 0,0048 de todas as linhas.
  const tolerancia = 0.01;

  for (final (conjunto, linhas) in [
    ('projeto', 1216),
    ('projeto_larguras', 2438),
  ]) {
    test(
      '$conjunto: as $linhas linhas medidas pelo Flutter como o Chromium (≤ 0,01 px), trecho a trecho',
      () {
        final v = _json('docs/design/medicao/$conjunto/validacao_fontes.json');
        final itens = (v['linhas'] as List).cast<Map<String, dynamic>>();
        expect(itens, hasLength(linhas));
        final fora = <String>[];
        for (final it in itens) {
          final trechos = (it['trechos'] as List).cast<Map<String, dynamic>>();
          expect(
            trechos.map((t) => t['texto']).join(),
            it['texto'],
            reason: '${it['prancha']} ${it['id']}',
          );
          final w = largura(trechos) + ((it['recuo'] as num?)?.toDouble() ?? 0);
          final d = w - (it['chromium'] as num).toDouble();
          if (d.abs() > tolerancia) {
            fora.add(
              '${it['prancha']} ${it['id']} L${it['linha']} «${it['texto']}» '
              '${d.toStringAsFixed(4)}',
            );
          }
        }
        expect(fora, isEmpty);
      },
    );
  }

  test('a reserva do "≈" e da "→" no peso do texto (D-281)', () {
    final v = _json('docs/design/medicao/projeto/validacao_fontes.json');
    final reserva = {
      for (final it in (v['linhas'] as List).cast<Map<String, dynamic>>())
        for (final t in (it['trechos'] as List).cast<Map<String, dynamic>>())
          if ((t['fonte'] as String).startsWith('BookNestApprox'))
            '${it['id']}|${t['texto']}|${t['fonte']}',
    };
    expect(reserva, {
      'd17b.progress.timeLeft|≈|BookNestApprox-SemiBold.otf',
      for (final n in [1, 2, 3])
        'bu28c.tips.tip$n.arrow|→|BookNestApprox-ExtraBold.otf',
      'n30b.quiet.range.arrow|→|BookNestApprox-ExtraBold.otf',
    });
    expect(AppFonts.figtreeReader(13, FontWeight.w600).fontFamilyFallback, [
      'FigtreeExt',
      'BookNestApprox',
    ]);
  });

  test(
    'famílias novas no FontManifest (tools/fonts/fontes_projeto.json)',
    () async {
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
      final novos =
          (_json('tools/fonts/fontes_projeto.json')['arquivos'] as List)
              .map((a) => (a as Map<String, dynamic>)['arquivo'] as String)
              .toList();
      expect(novos, hasLength(60));
      for (final arquivo in novos) {
        final m = _nome.firstMatch(arquivo)!;
        final familia = arquivo.substring(0, arquivo.indexOf('-'));
        expect(
          pesos[familia]?['assets/fonts/$arquivo'],
          _pesos[m.group(3)]!.value,
          reason: arquivo,
        );
      }
      expect(pesos['BookNestApprox'], {
        'assets/fonts/BookNestApprox-SemiBold.otf': 600,
        'assets/fonts/BookNestApprox-Bold.ttf': 700,
        'assets/fonts/BookNestApprox-ExtraBold.otf': 800,
      });
      for (final sfx in ['', 'Ext', 'Vi']) {
        expect(pesos['Bricolage15$sfx'], {
          'assets/fonts/Bricolage15$sfx-Bold.ttf': 700,
          'assets/fonts/Bricolage15$sfx-ExtraBold.ttf': 800,
        });
        expect(pesos['Literata24$sfx'], {
          'assets/fonts/Literata24$sfx-Regular.ttf': 400,
          'assets/fonts/Literata24$sfx-SemiBold.ttf': 600,
        });
        expect(pesos['Literata16$sfx'], {
          'assets/fonts/Literata16$sfx-Regular.ttf': 400,
          'assets/fonts/Literata16$sfx-SemiBold.ttf': 600,
        });
        expect(pesos['Literata18$sfx'], {
          'assets/fonts/Literata18$sfx-Regular.ttf': 400,
          'assets/fonts/Literata18$sfx-Medium.ttf': 500,
        });
        expect(pesos['Roboto$sfx'], {
          'assets/fonts/Roboto$sfx-Medium.ttf': 500,
        });
      }
    },
  );

  test('AppFonts: os tamanhos, os pesos e o que não existe', () {
    expect(
      AppFonts.bricolageOpsz,
      containsAll([15, 19, 21, 25, 27, 28, 30, 36, 38, 40, 46, 58, 74]),
    );
    final b = AppFonts.bricolage(15, height: 1.2, weight: FontWeight.w700);
    expect(b.fontFamily, 'Bricolage15');
    expect(b.fontWeight, FontWeight.w700);
    expect(b.fontFamilyFallback, ['Bricolage15Ext', 'Bricolage15Vi']);
    expect(AppFonts.bricolage(74, height: 1).fontFamily, 'Bricolage74');
    expect(AppFonts.bricolage(74, height: 1).fontWeight, FontWeight.w800);
    expect(() => AppFonts.bricolage(16, height: 1.2), throwsAssertionError);
    expect(
      () => AppFonts.bricolage(17, height: 1.2, weight: FontWeight.w700),
      throwsAssertionError,
    );
    expect(AppFonts.literataStatic[14], {600});
    expect(AppFonts.literataStatic[16], {400, 600});
    expect(AppFonts.literataStatic[18], {400, 500});
    expect(AppFonts.literataStatic[24], {400, 600});
    expect(AppFonts.literata(24, FontWeight.w600).fontFamily, 'Literata24');
    expect(() => AppFonts.literata(24, FontWeight.w500), throwsAssertionError);
    final r = AppFonts.roboto(15, FontWeight.w500, letterSpacing: 0.1);
    expect(r.fontFamily, 'Roboto');
    expect(r.fontFamilyFallback, ['RobotoExt', 'RobotoVi']);
    expect(r.letterSpacing, 0.1);
    expect(() => AppFonts.roboto(15, FontWeight.w400), throwsAssertionError);
  });

  test(
    'D-282: com espaçamento ≠ 0 o AppFonts desliga liga e clig, como o Blink',
    () {
      const sem = [FontFeature.disable('liga'), FontFeature.disable('clig')];
      expect(AppFonts.commonLigaturesOff, sem);
      for (final s in [
        AppFonts.bricolage(24, height: 1.2, letterSpacing: -0.6),
        AppFonts.figtree(12, FontWeight.w700, letterSpacing: 1.2),
        AppFonts.figtreeReader(11, FontWeight.w800, letterSpacing: 0.9),
        AppFonts.serif(30, height: 1.1, italic: true, letterSpacing: -0.6),
        AppFonts.roboto(15, FontWeight.w500, letterSpacing: 0.1),
      ]) {
        expect(s.fontFeatures, sem, reason: '${s.fontFamily}');
      }
      for (final s in [
        AppFonts.bricolage(24, height: 1.2),
        AppFonts.figtree(12, FontWeight.w700),
        AppFonts.figtreeReader(11, FontWeight.w800),
        AppFonts.serif(30, height: 1.1, italic: true),
        AppFonts.roboto(15, FontWeight.w500),
        AppFonts.literata(24, FontWeight.w600),
      ]) {
        expect(s.fontFeatures, isNull, reason: '${s.fontFamily}');
      }
      // o tnum soma às features: a mini-barra (ls −0,6) continua sem as ligaduras; o sumário (ls 0) só com o tnum
      expect(AppTextStyles.miniBarTime.fontFeatures, [
        ...sem,
        const FontFeature.tabularFigures(),
      ]);
      expect(AppTextStyles.readerTocPage.fontFeatures, [
        const FontFeature.tabularFigures(),
      ]);
      // o efeito: o "fi" do "definem" da 64 (Instrument Serif itálica 22, −0,4) com e sem a D-282 (−0,92 px sem)
      double w(TextStyle st) {
        final p = TextPainter(
          text: TextSpan(text: 'definem', style: st),
          textDirection: TextDirection.ltr,
        )..layout();
        final r = p.width;
        p.dispose();
        return r;
      }

      final serif = AppFonts.serif(
        22,
        height: 1.1,
        italic: true,
        letterSpacing: -0.4,
      );
      expect(
        w(serif) - w(serif.copyWith(fontFeatures: const [])),
        greaterThan(0.5),
      );
    },
  );

  test('a lista de licenças cobre cada arquivo de assets/fonts/', () {
    final texto = File('assets/fonts/LICENCAS_FONTES_OFL.txt')
        .readAsStringSync();
    final listados = {
      for (final m in RegExp(r'[\w{},-]+\.(?:ttf|otf)').allMatches(texto))
        ...expandir(m.group(0)!),
    };
    final arquivos = [
      for (final f in Directory('assets/fonts').listSync().whereType<File>())
        if (RegExp(r'\.(ttf|otf)$').hasMatch(f.path)) f.uri.pathSegments.last,
    ];
    expect(arquivos, isNotEmpty);
    expect(listados, containsAll(arquivos));
    expect(
      texto,
      contains('Roboto — Copyright 2011 The Roboto Project Authors'),
    );
  });

  // T13.11 (R7) — os SVGs das 41 telas: os novos na pasta da área da 1ª etapa que os usa (D-284), com a classe da área;
  // os reusados (desenho igual a um asset que já existia, D-283) apontam para o arquivo antigo; os gráficos de dado ou
  // de referência (`svg_graficos/`) ficam fora dos assets do app.
  final catalogo = _json('docs/design/medicao/projeto/svg_catalogo.json');
  final arquivos = (catalogo['arquivos'] as Map<String, dynamic>)
      .cast<String, Map<String, dynamic>>();
  final areas =
      (_json('tools/medicao/conjuntos.json')['projeto']
              as Map<String, dynamic>)['areas']
          as Map<String, dynamic>;
  final classes = <String, List<String>>{
    'assets/icons/biblioteca': AppIconsBiblioteca.all,
    'assets/icons/scanner': AppIconsScanner.all,
    'assets/icons/entrada': AppIconsEntrada.all,
    'assets/icons/perfil': AppIconsPerfil.all,
    'assets/icons/cronometro': AppIconsCronometro.all,
    'assets/illustrations/biblioteca': AppIllustrationsBiblioteca.all,
    'assets/illustrations/scanner': AppIllustrationsScanner.all,
    'assets/illustrations/entrada': AppIllustrationsEntrada.all,
    'assets/illustrations/perfil': AppIllustrationsPerfil.all,
    'assets/illustrations/cronometro': AppIllustrationsCronometro.all,
  };
  final comTexto = <String, Set<String>>{
    'assets/illustrations/biblioteca': AppIllustrationsBiblioteca.withText,
    'assets/illustrations/scanner': AppIllustrationsScanner.withText,
    'assets/illustrations/entrada': AppIllustrationsEntrada.withText,
    'assets/illustrations/perfil': AppIllustrationsPerfil.withText,
    'assets/illustrations/cronometro': AppIllustrationsCronometro.withText,
  };
  String pastaDe(String arquivo) =>
      arquivo.substring(0, arquivo.lastIndexOf('/'));
  final novos = [
    for (final e in arquivos.entries)
      if (e.value['reuso'] != true && e.value['categoria'] != 'graf') e.key,
  ];
  final reusados = [
    for (final e in arquivos.entries)
      if (e.value['reuso'] == true) e.key,
  ];
  final graficos = [
    for (final e in arquivos.entries)
      if (e.value['categoria'] == 'graf') e.key,
  ];

  test('T13.11: cada pasta de área tem os arquivos do catálogo, sem sobra nem falta, e a classe da área lista todos', () {
    expect(areas.values.toSet(), {
      'biblioteca',
      'scanner',
      'entrada',
      'perfil',
      'cronometro',
    });
    expect(
      classes.keys.map((p) => p.split('/').last).toSet(),
      areas.values.toSet(),
    );
    // D-284: o arquivo novo fica na pasta da área que o catálogo diz, e a categoria escolhe ícone ou ilustração
    for (final a in novos) {
      final cat = arquivos[a]!['categoria'];
      final raiz = cat == 'ic' ? 'assets/icons' : 'assets/illustrations';
      expect(pastaDe(a), '$raiz/${arquivos[a]!['area']}', reason: a);
    }
    for (final MapEntry(key: pasta, value: lista) in classes.entries) {
      final naPasta = Directory(pasta)
          .listSync()
          .whereType<File>()
          .map((f) => f.path.replaceAll(Platform.pathSeparator, '/'))
          .toSet();
      expect(
        lista.toSet(),
        hasLength(lista.length),
        reason: '$pasta: constantes repetidas',
      );
      expect(
        naPasta,
        novos.where((a) => pastaDe(a) == pasta).toSet(),
        reason: pasta,
      );
      expect(lista.toSet(), naPasta, reason: pasta);
    }
    expect(classes.values.fold<int>(0, (n, l) => n + l.length), novos.length);
  });

  test('T13.11: os SVGs novos e os reusados estão no pubspec e abrem no flutter_svg', () async {
    final declarados = (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets()
        .toSet();
    expect(reusados, isNotEmpty);
    for (final a in [...novos, ...reusados]) {
      expect(declarados, contains(a), reason: a);
      final info = await vg.loadPicture(
        SvgStringLoader(File(a).readAsStringSync()),
        null,
      );
      expect(info.size.width, greaterThan(0), reason: a);
      expect(info.size.height, greaterThan(0), reason: a);
      info.picture.dispose();
    }
  });

  test('T13.11: cada SVG novo declara um dos tamanhos do catálogo (de uso ou dos atributos)', () {
    final tamanhos = <String, Set<String>>{};
    for (final porPrancha
        in (catalogo['usos'] as Map<String, dynamic>).values) {
      for (final uso in (porPrancha as Map<String, dynamic>).values) {
        final u = uso as Map<String, dynamic>;
        // o tamanho de uso (layout) e, quando o flex o mudou, o dos atributos do <svg> (o do arquivo)
        for (final chave in ['tamanho', 'atributos']) {
          if (u[chave] == null) continue;
          final t = (u[chave] as List).map((v) => (v as num).toDouble());
          tamanhos
              .putIfAbsent(u['arquivo'] as String, () => {})
              .add(t.join('×'));
        }
      }
    }
    for (final a in novos) {
      final m = RegExp(r'<svg[^>]* width="([0-9.]+)" height="([0-9.]+)"')
          .firstMatch(File(a).readAsStringSync());
      expect(m, isNotNull, reason: a);
      expect(
        tamanhos[a],
        contains('${double.parse(m!.group(1)!)}×${double.parse(m.group(2)!)}'),
        reason: a,
      );
    }
  });

  test('T13.11: withText são exatamente as ilustrações com <text> (e nenhum ícone novo tem texto)', () {
    for (final MapEntry(key: pasta, value: lista) in classes.entries) {
      final comT = lista
          .where((a) => File(a).readAsStringSync().contains('<text'))
          .toSet();
      if (pasta.startsWith('assets/icons/')) {
        expect(comT, isEmpty, reason: pasta);
      } else {
        expect(comTexto[pasta], comT, reason: pasta);
      }
    }
  });

  test('T13.11: a AppSvg lê sem os <text> todo SVG com texto das telas (o carregador dela, com chave própria), e só '
      'eles; o único outro, o ic_underline do leitor, é pintado', () {
    final comTextoNoArquivo = {
      for (final f in Directory('assets').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('.svg') &&
            f.readAsStringSync().contains('<text'))
          f.path.replaceAll(Platform.pathSeparator, '/'),
    };
    expect(comTextoNoArquivo.difference(svgsWithText), {
      'assets/icons/leitor/ic_underline.svg',
    });
    expect(svgsWithText.difference(comTextoNoArquivo), isEmpty);
    for (final a in svgsWithText) {
      expect(
        appSvgLoader(a).cacheKey(null),
        isNot(SvgAssetLoader(a).cacheKey(null)),
        reason: a,
      );
    }
    for (final lista in comTexto.values) {
      expect(svgsWithText, containsAll(lista));
    }
  });

  test('T13.11: os gráficos de svg_graficos existem e ficam fora dos assets do app', () async {
    final declarados = (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets()
        .toSet();
    expect(graficos, hasLength(15));
    for (final g in graficos) {
      expect(g, startsWith('docs/design/medicao/projeto/svg_graficos/'));
      expect(File(g).existsSync(), isTrue, reason: g);
      expect(declarados, isNot(contains(g)), reason: g);
    }
  });
}
