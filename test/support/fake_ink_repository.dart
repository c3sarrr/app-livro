// G16 — o repositório da tinta em memória, para os testes da sessão e da tela: guarda o que cada Concluir pediu e os
// rascunhos, e pode falhar de propósito (a pílula da falha ao salvar, D-21; o rascunho da D-166).
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';

final class FakeInkRepository implements InkRepository {
  FakeInkRepository({List<SavedDrawing> drawings = const []})
    : drawings = [...drawings];

  /// Os desenhos salvos devolvidos por [drawingsOfBook] (de qualquer livro).
  final List<SavedDrawing> drawings;

  /// Cada Concluir que chegou ao fim, em ordem.
  final List<InkChanges> commits = [];

  /// O rascunho de cada chave.
  final Map<String, InkChanges> drafts = {};

  /// Quantas vezes o rascunho foi guardado.
  int draftWrites = 0;

  /// O próximo Concluir (e o rascunho ao abrir) falha.
  bool failCommit = false;

  @override
  Future<List<SavedDrawing>> drawingsOfBook(String userBookId) async => [
    for (final d in drawings)
      if (d.layer.userBookId == userBookId) d,
  ];

  @override
  Future<void> commit(String owner, String userBookId, InkChanges c) async {
    if (failCommit) throw StateError('falha de propósito');
    if (c.isEmpty) return;
    commits.add(c);
  }

  @override
  Future<void> saveDraft(String owner, String userBookId, InkChanges c) async {
    draftWrites++;
    final key = draftKey(owner, userBookId);
    if (c.isEmpty) {
      drafts.remove(key);
    } else {
      drafts[key] = c;
    }
  }

  @override
  Future<InkChanges?> draftOf(String owner, String userBookId) async =>
      drafts[draftKey(owner, userBookId)];

  @override
  Future<void> clearDraft(String owner, String userBookId) async =>
      drafts.remove(draftKey(owner, userBookId));

  @override
  Future<bool> recoverDraft(String owner, String userBookId) async {
    final c = drafts[draftKey(owner, userBookId)];
    if (c == null) return true;
    try {
      await commit(owner, userBookId, c);
    } on Object {
      return false;
    }
    drafts.remove(draftKey(owner, userBookId));
    return true;
  }
}
