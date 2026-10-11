// G03 — instantâneo da prancha 24 (Leitor — abrindo espaço (arrastar)) — D-34; derivado do mundo de referência.
import 'instantaneo.dart';

final InstantaneoDoLeitor t24 = InstantaneoDoLeitor(
  prancha: '24_abrindo_espaco',
  mundo: mundoSemNotaAMao,
  modo: ModoDoLeitor.anotacao,
  anotacoesNaPagina: anotacoesDaPagina159(mundoSemNotaAMao),
  tintaNaPagina: mundoSemNotaAMao.camadas,
  ferramenta: FerramentaDeAnotacao.espaco,
  abrindoEspacoLinhas: 3,
);
