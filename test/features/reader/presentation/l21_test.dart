// G13.5 — FASES L21a e L21b (handoff_v2/fases/L21*.md): a tela 21 (Creme) pela rota real, no mundo da tela 21, com
// a seleção feita pelos gestos, contra as medidas da prancha (`kRef21`). As conferências estão em
// `test/support/fase_l21.dart`.
import '../../../fixtures/telas/t21.dart';
import '../../../reference/leitor/reference_layout_21_selecao_texto.dart';
import '../../../support/fase_l21.dart';

void main() => faseL21(nome: 'L21', ref: kRef21, instantaneo: t21);
