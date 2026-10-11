// G12.5 — FASES L20a, L20b e L20c (handoff_v2/fases/L20*.md): a tela 20 (Creme) com os controles abertos pela rota
// real, no mundo de referência, contra as medidas da prancha (`kRef20`). As conferências estão em
// `test/support/fase_l20.dart` (as mesmas da L26b, com o papel Noite).
import 'package:app_leitura/features/reader/domain/reader_settings.dart';

import '../../../fixtures/telas/t20.dart';
import '../../../reference/leitor/reference_layout_20_leitor_controles.dart';
import '../../../support/fase_l20.dart';

void main() => faseL20(
  nome: 'L20',
  ref: kRef20,
  papel: ReaderPaper.creme,
  instantaneo: t20,
);
