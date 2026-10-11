// G19.2 — a regra da nota de um grifo (D-131/D-138), usada pelo leitor (G13) e pela tela 25: com texto, edita a nota
// mais antiga do grifo ou cria uma; vazia, apaga a mais antiga (o grifo fica); grifo que não existe ou foi apagado,
// nada. Dart puro: quem chama grava.
import 'annotation.dart';

sealed class NotePlan {
  const NotePlan();
}

final class NoteCreate extends NotePlan {
  const NoteCreate(this.parent, this.text);
  final Annotation parent;
  final String text;
}

final class NoteEdit extends NotePlan {
  const NoteEdit(this.note, this.text);
  final Annotation note;
  final String text;
}

final class NoteDelete extends NotePlan {
  const NoteDelete(this.note);
  final Annotation note;
}

/// A ordem de criação (desempate pelo id): a "mais antiga" das notas.
int olderFirst(Annotation a, Annotation b) {
  final c = a.meta.createdAt.compareTo(b.meta.createdAt);
  return c != 0 ? c : a.id.compareTo(b.id);
}

/// A nota mais antiga de algum dos [parents] em [rows].
Annotation? firstNoteOf(Iterable<Annotation> rows, Set<String> parents) {
  Annotation? first;
  for (final a in rows) {
    if (a.kind != AnnotationKind.note || !parents.contains(a.parentId)) {
      continue;
    }
    if (first == null || olderFirst(a, first) < 0) first = a;
  }
  return first;
}

/// O que gravar para a nota [text] do grifo [parent] (as linhas do livro em [rows]).
NotePlan? planNote(Iterable<Annotation> rows, Annotation? parent, String text) {
  if (parent == null || parent.meta.isDeleted) return null;
  final t = text.trim();
  final note = firstNoteOf(rows, {parent.id});
  if (t.isEmpty) return note == null ? null : NoteDelete(note);
  return note == null ? NoteCreate(parent, t) : NoteEdit(note, t);
}
