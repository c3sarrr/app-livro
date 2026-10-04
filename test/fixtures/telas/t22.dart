// G03 — instantâneo da prancha 22 (Leitor — modo anotação, Caneta) — D-34; derivado do mundo de referência.
import 'instantaneo.dart';

final InstantaneoDoLeitor t22 = InstantaneoDoLeitor(
  prancha: '22_modo_anotacao',
  mundo: mundoSemNotaAMao,
  modo: ModoDoLeitor.anotacao,
  anotacoesNaPagina: anotacoesDaPagina159(mundoSemNotaAMao),
  tintaNaPagina: mundoSemNotaAMao.camadas,
  ferramenta: FerramentaDeAnotacao.caneta,
);
