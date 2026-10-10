// T04 — o play de um livro de papel (o cartão do "Também lendo" e o "Ler agora" — D-258): começa a sessão do
// cronômetro; com outra sessão aberta, a folha dela com este livro à espera (D-262). As falhas vão para o relatório
// do cronômetro (o toque não quebra a tela).
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/domain/models.dart';
import '../application/paper_timer_controller.dart';
import '../data/paper_timer_store.dart' show reportPaperTimerError;
import '../domain/paper_timer_failure.dart';
import 'session_sheet.dart';

/// Começa a sessão de [book]. Com outra aberta, a folha dela (D-262); com a deste livro já aberta (o toque chegou
/// antes de a sessão carregar), retoma-a.
Future<void> startPaperSession(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  try {
    final timer = ref.read(paperTimerProvider.notifier);
    try {
      await timer.start(book.id);
      return;
    } on PaperSessionAlreadyOpen {
      // abaixo: a folha da sessão aberta
    }
    if (!context.mounted) return;
    final open = ref.read(paperTimerProvider).value?.session;
    if (open?.userBookId == book.id) {
      await timer.resume();
      return;
    }
    await showSessionSheet(context, pending: book);
  } on Object catch (e, st) {
    reportPaperTimerError(e, st);
  }
}
