// G12.5 — FASE L26b (handoff_v2/fases/L26b_tema_noite.md): a tela 26b — os controles no tema Noite — pela rota
// real, no mundo de referência com o papel Noite, contra as medidas da prancha (`kRef26b`) e as cores da 26b.
import 'package:app_leitura/features/reader/domain/reader_settings.dart';

import '../../../fixtures/telas/t26b.dart';
import '../../../reference/leitor/reference_layout_26b_tema_noite.dart';
import '../../../support/fase_l20.dart';

void main() => faseL20(
  nome: 'L26b',
  ref: kRef26b,
  papel: ReaderPaper.noite,
  instantaneo: t26b,
);
