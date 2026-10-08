// G03 — instantâneo da prancha 26b (Leitor — tema Noite (com controles)) — D-34; derivado do mundo de referência.
import 'package:app_leitura/features/reader/domain/reader_settings.dart';

import 'instantaneo.dart';

final InstantaneoDoLeitor t26b = InstantaneoDoLeitor(
  prancha: '26b_tema_noite',
  // D-169
  mundo: mundoSemTintaDeHoje.copyWith(
    ajustes: mundoSemTintaDeHoje.ajustes.copyWith(paper: ReaderPaper.noite),
  ),
  modo: ModoDoLeitor.controles,
);
