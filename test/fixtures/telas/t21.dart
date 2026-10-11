// G03 — instantâneo da prancha 21 (Leitor — seleção de texto) — D-34; derivado do mundo de referência.
import '../mundo_2026_09_20.dart';
import 'instantaneo.dart';

final InstantaneoDoLeitor t21 = () {
  final texto = mundoDaTela21.textosDosCapitulos[Slugs.domCasmurro]![31]!;
  const selecionado =
      'como a vaga que se retira da praia, nos dias de ressaca.';
  final inicio = texto.indexOf(selecionado);
  return InstantaneoDoLeitor(
    prancha: '21_selecao_texto',
    mundo: mundoDaTela21,
    modo: ModoDoLeitor.selecao,
    anotacoesNaPagina: anotacoesDaPagina159(mundoDaTela21),
    selecao: (
      inicio: inicio,
      fim: inicio + selecionado.length,
      texto: selecionado,
    ),
  );
}();
