// G19.2 — a regra da nota de um grifo (D-131/D-138), compartilhada pelo leitor e pela tela 25.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/note_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/personal_builders.dart';

void main() {
  final livro = idTeste(50);
  final g = grifoTeste(1, livro: livro);
  Annotation nota(int n, DateTime em, {String texto = 'nota'}) =>
      notaTeste(n, livro: livro, pai: g, texto: texto).copyWith(
        meta: RecordMeta(
          userId: usuarioTeste,
          createdAt: em,
          updatedAt: em,
          version: Hlc(em.millisecondsSinceEpoch, 0, 'aparelhoA'),
        ),
      );
  final cedo = nota(2, DateTime.utc(2026, 9, 1));
  final tarde = nota(3, DateTime.utc(2026, 9, 2));

  test('sem nota: cria com o texto aparado; vazio não faz nada', () {
    final p = planNote([g], g, '  oi  ')! as NoteCreate;
    expect((p.parent, p.text), (g, 'oi'));
    expect(planNote([g], g, '   '), isNull);
  });

  test('com nota: edita a mais antiga; vazio apaga a mais antiga', () {
    final e = planNote([g, tarde, cedo], g, 'novo')! as NoteEdit;
    expect((e.note.id, e.text), (cedo.id, 'novo'));
    final d = planNote([g, tarde, cedo], g, '');
    expect((d! as NoteDelete).note.id, cedo.id);
  });

  test('grifo que não existe ou foi apagado: nada', () {
    expect(planNote([g], null, 'x'), isNull);
    final apagado = grifoTeste(1, livro: livro, apagado: true);
    expect(planNote([apagado], apagado, 'x'), isNull);
  });

  test(
    'a mais antiga: pela criação, depois pelo id; só notas dos pais pedidos',
    () {
      final mesmaHora = nota(4, DateTime.utc(2026, 9, 1));
      expect(firstNoteOf([mesmaHora, cedo], {g.id})!.id, cedo.id);
      expect(firstNoteOf([tarde, cedo, g], {g.id})!.id, cedo.id);
      expect(firstNoteOf([tarde, cedo], {'outro'}), isNull);
      expect(olderFirst(cedo, tarde), lessThan(0));
      expect(olderFirst(tarde, cedo), greaterThan(0));
      expect(olderFirst(cedo, cedo), 0);
    },
  );
}
