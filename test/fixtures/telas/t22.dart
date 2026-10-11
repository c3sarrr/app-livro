// G03 — instantâneo da prancha 22 (Leitor — modo anotação, Caneta) — D-34; derivado do mundo de referência.
// G16: o mundo da 22 é o do começo da sessão da prancha (o grifo à mão e a elipse); o sublinhado duplo e a onda são
// desenhados pelo fluxo da tela (`dados_t22.dart`).
import 'instantaneo.dart';

final InstantaneoDoLeitor t22 = InstantaneoDoLeitor(
  prancha: '22_modo_anotacao',
  mundo: mundoDaTela22,
  modo: ModoDoLeitor.anotacao,
  anotacoesNaPagina: anotacoesDaPagina159(mundoDaTela22),
  tintaNaPagina: mundoDaTela22.camadas,
  ferramenta: FerramentaDeAnotacao.caneta,
);
