// T13 — os recursos das 41 telas das etapas 7–11 no app. T13.10 (R6), as fontes: cada linha de texto que o Chromium mediu
// nas telas a 390, 360 e 430 (`docs/design/medicao/projeto{,_larguras}/validacao_fontes.json`, a largura crua, com 3
// casas) medida pelo Flutter com o `AppFonts`, trecho a trecho como o `validar_fontes.py` a dividiu (as famílias novas
// de `tools/fonts/fontes_projeto.json`, as que já existiam e a reserva do "≈" e da "→" — D-281); as famílias no
// FontManifest, o `AppFonts`, as ligaduras que o espaçamento desliga (D-282: `liga` e `clig`, como o Blink) e a lista
// de licenças, que cobre cada arquivo de `assets/fonts/`.
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
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
}
