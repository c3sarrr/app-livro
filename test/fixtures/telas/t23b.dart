// G03 — instantâneo da prancha 23b (Leitor — ajustes do marca-texto) — D-34; derivado do mundo de referência.
import 'instantaneo.dart';

final InstantaneoDoLeitor t23b = InstantaneoDoLeitor(
  prancha: '23b_ajustes_marcatexto',
  mundo: mundoSemNotaAMao,
  modo: ModoDoLeitor.anotacao,
  anotacoesNaPagina: anotacoesDaPagina159(mundoSemNotaAMao),
  tintaNaPagina: mundoSemNotaAMao.camadas,
  ferramenta: FerramentaDeAnotacao.marcaTexto,
  painel: PainelDaFerramenta.marcaTexto,
);
