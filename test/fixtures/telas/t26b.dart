// G03 — instantâneo da prancha 26b (Leitor — tema Noite (com controles)) — D-34; derivado do mundo de referência.
import 'package:app_leitura/features/reader/domain/reader_settings.dart';

import '../mundo_2026_09_20.dart';
import 'instantaneo.dart';

final InstantaneoDoLeitor t26b = InstantaneoDoLeitor(
  prancha: '26b_tema_noite',
  mundo: mundoReferencia.copyWith(
    ajustes: mundoReferencia.ajustes.copyWith(paper: ReaderPaper.noite),
  ),
  modo: ModoDoLeitor.controles,
);
