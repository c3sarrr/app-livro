// G18 — um espaço aberto no fluxo de um item do livro (Anexo 03 §7.2 e §9.5, D-181): depois do caractere [SpaceCut.at]
// (a âncora, o fim de uma frase ou de um parágrafo), um bloco de [SpaceCut.height] px — a nota à mão, a faixa dela
// recolhida ou o abridor durante o arrasto. O parágrafo da âncora é partido nela e o resto segue sem recuo.
import 'package:flutter/foundation.dart';

import 'reader_typography.dart';

@immutable
final class SpaceCut {
  const SpaceCut({required this.at, required this.height, required this.id});

  /// A âncora: posição no texto canônico do item.
  final int at;

  /// A altura do bloco no fluxo (com as margens).
  final double height;

  /// A camada da nota (ou o abridor).
  final String id;

  @override
  bool operator ==(Object other) =>
      other is SpaceCut &&
      other.at == at &&
      other.height == height &&
      other.id == id;

  @override
  int get hashCode => Object.hash(at, height, id);

  @override
  String toString() => 'SpaceCut($at, $height, $id)';
}

/// Os espaços de cada item do livro, com a tipografia de agora (a faixa recolhida tem a altura de uma linha).
typedef SpaceCutsOf = List<SpaceCut> Function(int spine, ReaderTypography t);

/// O corte dentro de um bloco: a posição a partir do começo dele.
typedef BlockCut = ({int at, double height, String id});

/// Os cortes do bloco que começa em [start] e tem [length] caracteres: os de âncora depois do começo até o fim dele
/// (o fim conta: é o espaço depois do parágrafo), na posição dentro do bloco e em ordem.
List<BlockCut> cutsIn(
  List<SpaceCut> cuts, {
  required int start,
  required int length,
}) => [
  for (final c in [...cuts]..sort((a, b) => a.at.compareTo(b.at)))
    if (c.at > start && c.at <= start + length)
      (at: c.at - start, height: c.height, id: c.id),
];

/// A assinatura dos espaços de um capítulo, para o cache das páginas: a âncora e a altura (2 casas) de cada um.
String spaceSignature(List<SpaceCut> cuts) =>
    ([...cuts]..sort((a, b) => a.at.compareTo(b.at)))
        .map((c) => '${c.at}:${c.height.toStringAsFixed(2)}')
        .join(',');
