// G17 (D-171) — a frase da prévia do painel do marca-texto: a 1ª frase inteira que começa na página e cabe sozinha na
// linha da prévia (Literata 17, 296 de largura útil), mais as seguintes enquanto couberem; o grifo na palavra mais
// longa da 1ª frase (empate: a 1ª). A frase que começou na página anterior não entra; nenhuma cabe: as primeiras
// palavras da 1ª, com "…"; sem texto, a frase do arquivo. Na pág. 159 do mundo dá a do arquivo.
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/reader/annotations/marker_preview.dart';
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

/// O Literata 17 médio da prancha (259,28 px para "Olhos de ressaca? Vá, de ressaca.", 33 letras).
double _medir(String s) => s.length * 7.86;

MarkerPreview _de(String texto, {int inicio = 0, int? fim}) => markerPreviewOf(
  texto,
  start: inicio,
  end: fim ?? texto.length,
  maxWidth: 296,
  width: _medir,
);

void main() {
  test('as frases que cabem juntas, a partir da 1ª que cabe sozinha; o grifo na palavra mais longa da 1ª', () {
    final p = _de(
      'Era uma vez uma frase muito comprida que não cabe na linha da prévia de jeito nenhum. '
      'Olhos de ressaca? Vá, de ressaca. É o que me dá ideia daquela feição nova.',
    );
    expect(p.text, 'Olhos de ressaca? Vá, de ressaca.');
    expect(p.text.substring(p.from, p.to), 'ressaca');
    expect(p.from, 9);
    expect(p.firstSentence, 'Olhos de ressaca');
  });

  test('a página que começa no meio de uma frase: ela não entra', () {
    const texto = 'ele disse que sim. Fui ver o mar. Voltei cedo.';
    // a página começa em "disse" (no meio da 1ª frase)
    final p = _de(texto, inicio: 4);
    expect(p.text, 'Fui ver o mar. Voltei cedo.');
    expect(p.firstSentence, 'Fui ver o mar');
    expect(p.text.substring(p.from, p.to), 'Fui');
    // a que começa depois de um parágrafo entra
    expect(
      _de('fim do outro\nNovo parágrafo aqui.', inicio: 13).text,
      'Novo parágrafo aqui.',
    );
    // a página que começa logo depois de um fim de frase também
    expect(_de(texto, inicio: 19).text, 'Fui ver o mar. Voltei cedo.');
  });

  test('aspas e parênteses depois do ponto fazem parte da frase', () {
    final p = _de('"Já vou." (Fui.) Ficou. E depois? Nada mais de nada.');
    expect(p.text, '"Já vou." (Fui.) Ficou. E depois?');
    expect(p.firstSentence, '"Já vou');
  });

  test('nenhuma frase cabe: as primeiras palavras da 1ª que começa na página, com "…"', () {
    final p = _de(
      'Capitulina desconfiadíssima atravessava silenciosamente corredores intermináveis, '
      'contemplando melancolicamente.',
    );
    expect(p.text, 'Capitulina desconfiadíssima…');
    expect(_medir(p.text), lessThanOrEqualTo(296));
    expect(p.text.substring(p.from, p.to), 'desconfiadíssima');
    expect(p.firstSentence, 'Capitulina desconfiadíssima');
    // nem a 1ª palavra cabe: ela, cortada pela largura, com "…"
    final longa = _de('${'a' * 50} fim.');
    expect(longa.text, '${'a' * 36}…');
    expect((longa.from, longa.to), (0, 36));
  });

  test(
    'o espaço inseparável vira o espaço comum (a prévia é uma linha só)',
    () {
      final p = _de('Olhos\u00A0de\u00A0ressaca? Vá, de ressaca.');
      expect(p.text, 'Olhos de ressaca? Vá, de ressaca.');
      expect(p.firstSentence, 'Olhos de ressaca');
      expect(p.text.substring(p.from, p.to), 'ressaca');
    },
  );

  test('empate na palavra mais longa: a 1ª; números contam como letras', () {
    final p = _de('Gato pato rato.');
    expect((p.from, p.to), (0, 4));
    final n = _de('Em 1899 foi.');
    expect(n.text.substring(n.from, n.to), '1899');
  });

  test('sem texto (ou só o fim de uma frase de antes): a frase do arquivo', () {
    for (final p in [_de(''), _de('   '), _de('o fim.', inicio: 2)]) {
      expect(p.text, 'Olhos de ressaca? Vá, de ressaca.');
      expect(p.text.substring(p.from, p.to), 'ressaca');
      expect(p.firstSentence, 'Olhos de ressaca');
    }
  });

  test('a cache guarda a última prévia: com o mesmo texto, trecho, largura e letra, não mede de novo', () {
    final cache = MarkerPreviewCache();
    var medidas = 0;
    double medir(String s) {
      medidas++;
      return _medir(s);
    }

    const texto = 'Olhos de ressaca? Vá, de ressaca. Fim.';
    MarkerPreview de({
      int inicio = 0,
      int fim = texto.length,
      double largura = 296,
      Object letra = 'Literata 17',
      String t = texto,
    }) => cache.of(
      t,
      start: inicio,
      end: fim,
      maxWidth: largura,
      style: letra,
      width: medir,
    );

    final p = de();
    final n = medidas;
    expect(n, greaterThan(0));
    expect(identical(de(), p), isTrue);
    expect(medidas, n);
    // cada chave muda a prévia
    for (final outra in [
      () => de(inicio: 18),
      () => de(fim: 34),
      () => de(largura: 200),
      () => de(letra: 'Literata 18'),
      () => de(t: 'Vá, de ressaca. Fim.'),
    ]) {
      final antes = medidas;
      outra();
      expect(medidas, greaterThan(antes));
      de();
    }
    expect(de(), p);
  });

  group('na pág. 159 do mundo, com o Literata 17 de verdade', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setUpAll(loadAppFonts);

    test('dá a frase do arquivo: "Olhos de ressaca? Vá, de ressaca.", o grifo em "ressaca"', () async {
      final livro = await livroDaTela19();
      addTearDown(livro.close);
      final doc = await EpubReaderDocument.open(livro.deps());
      addTearDown(doc.dispose);
      final shown = doc.current.shown!;
      final estilo = AppFonts.literata(17, FontWeight.w400);
      double medir(String s) {
        final tp = TextPainter(
          text: TextSpan(text: s, style: estilo),
          textDirection: TextDirection.ltr,
        )..layout();
        final w = tp.width;
        tp.dispose();
        return w;
      }

      final p = markerPreviewOf(
        doc.anchors.textOf(shown.unit)!,
        start: shown.from,
        end: shown.to,
        maxWidth: 296,
        width: medir,
      );
      expect(p.text, 'Olhos de ressaca? Vá, de ressaca.');
      expect(p.text.substring(p.from, p.to), 'ressaca');
      expect(p.from, 9);
    });
  });
}
