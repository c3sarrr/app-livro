// G10.2 — fatias de tempo (Anexo 03 §7.2 e §12): os capítulos são paginados em tarefas ociosas do
// SchedulerBinding, até 4 ms por fatia (mais no máximo um passo), o de maior prioridade primeiro; dá para
// esperar uma condição (a página da posição fechou) antes do fim; job cancelado não completa.
import 'dart:async';

import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/chapter_layout.dart';
import 'package:app_leitura/features/reader/layout/layout_scheduler.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import '../../../support/medida.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  const t = ReaderTypography();
  late EpubBook livro;
  setUpAll(() => livro = EpubBook.open('test/fixtures/livros/pg55752.epub'));
  tearDownAll(() => livro.close());
  // a 1ª vez que o Skia usa a fonte (e cada eixo) custa dezenas de ms: aquece antes de medir
  setUpAll(() => ChapterLayoutJob(chapterOf(livro, 4), t).runAll().dispose());

  test('maior prioridade primeiro; cada fatia ≤ 4 ms + um passo; mesmas páginas', () async {
    final s = LayoutScheduler();
    final baixa = ChapterLayoutJob(chapterOf(livro, 1), t);
    final alta = ChapterLayoutJob(chapterOf(livro, 2), t);
    addTearDown(() {
      baixa.dispose();
      alta.dispose();
    });
    final ordem = <String>[];
    final fb = s.run(baixa).then((_) => ordem.add('baixa'));
    final fa = s.run(alta, priority: 3).then((_) => ordem.add('alta'));
    await Future.wait([fa, fb]);
    expect(ordem, ['alta', 'baixa']);
    expect(s.idle, isTrue);
    expect(s.slices, greaterThan(10));
    final passo = baixa.maxStepMicros > alta.maxStepMicros
        ? baixa.maxStepMicros
        : alta.maxStepMicros;
    // ignore: avoid_print
    print(
      'G10.2 fatias: ${s.slices}, ${s.overBudgetSlices} acima de 4 ms, maior ${s.maxSliceMicros} µs '
      '(maior passo $passo µs)',
    );
    expect(
      s.overBudgetSlices,
      lessThanOrEqualTo(medindo ? s.slices ~/ 20 : s.slices ~/ 2),
      reason: 'só quando um passo sozinho passa da previsão',
    );
    expect(s.maxSliceMicros, lessThanOrEqualTo(4000 + passo + 1000));
    expect(
      passo,
      lessThan(orcamento(4000, folga: 20000)),
      reason: 'pedaços de 1.200 caracteres',
    );
    // rodar de novo um job pronto devolve o mesmo resultado
    expect(identical(await s.run(alta), alta.result), isTrue);
  });

  test('esperar uma condição antes do fim; cancelar tira da fila', () async {
    final s = LayoutScheduler();
    final job = ChapterLayoutJob(chapterOf(livro, 2), t);
    addTearDown(job.dispose);
    final fim = s.run(job);
    await s.waitFor(() => job.pagesSoFar.length >= 3);
    expect(job.done, isFalse);
    expect(job.pagesSoFar.length, greaterThanOrEqualTo(3));
    await fim;

    final outro = ChapterLayoutJob(chapterOf(livro, 1), t);
    addTearDown(outro.dispose);
    var completou = false;
    unawaited(s.run(outro).then((_) => completou = true));
    final espera = s.waitFor(() => false);
    s.cancel(outro);
    await espera; // fila vazia acorda quem espera
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(completou, isFalse);
    expect(s.idle, isTrue);
  });
}
