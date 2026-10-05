// OCR da capa (Anexo 02 §7.4): o reconhecimento de texto roda no aparelho e devolve linhas com a
// altura da caixa; o título costuma ser a letra maior e o autor a maior das restantes. É só um
// palpite para preencher os campos — a pessoa confere e corrige antes de qualquer envio (D-74).
import 'package:flutter/foundation.dart' show immutable;

/// Uma linha lida na capa: o texto e a altura da caixa (px da foto) — maior = letra maior.
@immutable
final class CoverLine {
  const CoverLine(this.text, this.height, {this.top = 0});
  final String text;
  final double height;

  /// Posição vertical (ordem de leitura de um título em várias linhas).
  final double top;
}

/// Palpite de título e autor.
@immutable
final class CoverGuess {
  const CoverGuess({this.title, this.author});
  final String? title;
  final String? author;
}

final RegExp _letra = RegExp(r'\p{L}', unicode: true);

/// Linhas que não são título nem autor: poucas letras, ou só números/símbolos.
bool _util(String s) => _letra.allMatches(s).length >= 2;

/// Títulos de várias linhas: as linhas com até 15 % menos altura que a maior entram juntas.
const double _mesmoCorpo = 0.85;

CoverGuess guessFromCover(List<CoverLine> lines) {
  final uteis = [
    for (final l in lines)
      if (_util(l.text.trim()) && l.height > 0)
        CoverLine(_espacos(l.text), l.height, top: l.top),
  ];
  if (uteis.isEmpty) return const CoverGuess();
  final maior = uteis.map((l) => l.height).reduce((a, b) => a > b ? a : b);
  final titulo = uteis.where((l) => l.height >= maior * _mesmoCorpo).toList()
    ..sort((a, b) => a.top.compareTo(b.top));
  final usadas = titulo.take(3).toSet();
  final resto = uteis.where((l) => !usadas.contains(l)).toList()
    ..sort((a, b) => b.height.compareTo(a.height));
  return CoverGuess(
    title: legible(usadas.map((l) => l.text).join(' ')),
    author: resto.isEmpty ? null : legible(resto.first.text),
  );
}

String _espacos(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

const Set<String> _minusculas = {
  'a', 'à', 'ao', 'aos', 'as', 'com', 'da', 'das', 'de', 'do', 'dos', 'e', //
  'em', 'na', 'nas', 'no', 'nos', 'o', 'os', 'ou', 'para', 'por', 'um',
  'uma', 'the', 'of', 'and', 'to', 'in',
};

/// Capas costumam vir EM CAIXA ALTA: vira "Título Legível" (com as palavras pequenas em minúsculas);
/// texto que já tem minúsculas fica como está.
String legible(String s) {
  final t = _espacos(s);
  if (t != t.toUpperCase()) return t;
  final palavras = t.toLowerCase().split(' ');
  return [
    for (var i = 0; i < palavras.length; i++)
      i > 0 && _minusculas.contains(palavras[i])
          ? palavras[i]
          : _maiuscula(palavras[i]),
  ].join(' ');
}

String _maiuscula(String w) {
  if (w.isEmpty) return w;
  final r = w.runes.toList();
  return String.fromCharCode(r.first).toUpperCase() +
      String.fromCharCodes(r.skip(1));
}
