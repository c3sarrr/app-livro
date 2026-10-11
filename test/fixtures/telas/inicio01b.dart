// T04 — instantâneo da prancha 01b ("Início — lendo agora (cronômetro ativo)", D-241): a Início da 01 SEM o cartão
// da revisão (a 01b não o desenha; com dados reais ele some até a T05 — D-247) e com a sessão do cronômetro do Brás
// Cubas de papel rodando há 8 min 42 s ("08:42" às 20:00 da prancha). A barrinha de 89 % não é escrita aqui: sai do
// cálculo ((18 × 60 + 522) ÷ 1800 — R1). O Para você é o da 01 (Esaú e Jacó, Memorial de Aires, Casa de Pensão): a
// 01b troca os dois últimos por Quincas Borba e O Cortiço abaixo da dobra — os 5 ids dessa troca estão listados em
// `test/home/t01b_divergencias_test.dart`.
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';

import 'inicio01.dart';

abstract final class TelaInicio01b {
  /// "Agora" de referência: o da 01 (domingo 20/09/2026 20:00).
  static final DateTime agora = TelaInicio01.agora;

  /// "08:42" — o tempo da sessão aberta na prancha.
  static const Duration tempoDaSessao = Duration(minutes: 8, seconds: 42);

  /// A sessão do Brás Cubas, rodando desde 19:51:18 (o id da linha que ela gravará é o do teste).
  static final OpenPaperSession sessao = OpenPaperSession.start(
    id: '01925a00-0000-7000-8000-0000000001b0',
    userBookId: TelaInicio01.brasCubas.id,
    now: agora.subtract(tempoDaSessao),
  );

  /// O livro da sessão como a mini-barra o mostra: o Brás Cubas da 01 (capa desenhada, sem página — D-253).
  static const PaperBook livroDaSessao = PaperBook(
    book: TelaInicio01.brasCubas,
  );

  /// O Orgulho e Preconceito de papel, na pág. 344 de 425 (a 01 mostra 81 %): o livro de papel com página.
  static const PaperBook orgulho = PaperBook(
    book: TelaInicio01.orgulho,
    pagesTotal: 425,
    lastPage: 344,
  );

  static HomeSnapshot snapshot(DateTime now) => HomeSnapshot(
    now: now,
    user: TelaInicio01.usuario,
    continueReading: TelaInicio01.continuarLendo,
    alsoReading: TelaInicio01.tambemLendo,
    readingDay: TelaInicio01.diaDeLeitura(),
    // a 01b não tem o cartão da revisão
    dailyReview: null,
    forYou: TelaInicio01.paraVoce,
    club: TelaInicio01.clube(),
    recent: TelaInicio01.recentes,
  );
}
