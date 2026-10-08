// G03 — instantâneo da prancha 24b (Leitor — nota à mão escrita) — D-34; derivado do mundo de referência.
import '../mundo_2026_09_20.dart';
import 'instantaneo.dart';

final InstantaneoDoLeitor t24b = InstantaneoDoLeitor(
  prancha: '24b_nota_mao',
  mundo: mundoReferencia,
  modo: ModoDoLeitor.anotacao,
  anotacoesNaPagina: anotacoesDaPagina159(mundoReferencia),
  tintaNaPagina: mundoReferencia.camadas,
  // G18 (D-187): depois de soltar o arrasto, a Caneta (a prancha escreve na caixa)
  ferramenta: FerramentaDeAnotacao.caneta,
);
