// G03 — instantâneo da prancha 23 (Leitor — ajustes da caneta) — D-34; derivado do mundo de referência.
import 'instantaneo.dart';

final InstantaneoDoLeitor t23 = InstantaneoDoLeitor(
  prancha: '23_ajustes_caneta',
  mundo: mundoSemNotaAMao,
  modo: ModoDoLeitor.anotacao,
  anotacoesNaPagina: anotacoesDaPagina159(mundoSemNotaAMao),
  tintaNaPagina: mundoSemNotaAMao.camadas,
  ferramenta: FerramentaDeAnotacao.caneta,
  painel: PainelDaFerramenta.caneta,
);
