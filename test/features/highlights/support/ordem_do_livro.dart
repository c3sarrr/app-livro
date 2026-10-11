// G19 — a ordem do `AnnotationsDao.forBook` para os testes do domínio: página, início da âncora, criação, id.
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';

import '../../../fixtures/mundo_2026_09_20.dart';

int _start(Annotation a) => switch (a.anchor) {
  EpubAnchor(:final start) => start,
  _ => 0,
};

List<Annotation> naOrdemDoLivro(Iterable<Annotation> xs) =>
    [...xs]..sort((a, b) {
      for (final c in [
        a.refPage.compareTo(b.refPage),
        _start(a).compareTo(_start(b)),
        a.meta.createdAt.compareTo(b.meta.createdAt),
        a.id.compareTo(b.id),
      ]) {
        if (c != 0) return c;
      }
      return 0;
    });

/// Os 12 itens de Dom Casmurro no mundo de referência, na ordem do livro.
List<Annotation> itensDoMundo() =>
    naOrdemDoLivro(mundoReferencia.anotacoesDo(Slugs.domCasmurro));

/// O item de [kind] na página [pagina] (o 1º, na ordem do livro).
Annotation itemDoMundo(int pagina, AnnotationKind kind, {int nth = 0}) =>
    itensDoMundo()
        .where((a) => a.refPage == pagina && a.kind == kind)
        .elementAt(nth);
