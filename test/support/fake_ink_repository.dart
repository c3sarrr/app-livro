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

  /// O rascunho de cada chave (`draftKey` com a sessão).
  final Map<String, InkChanges> drafts = {};

  /// Quantas vezes o rascunho foi guardado.
  int draftWrites = 0;

  /// O próximo Concluir (e o rascunho ao abrir) falha.
  bool failCommit = false;

  /// O Concluir espera isto antes de gravar (o meio de uma gravação lenta).
  Future<void>? gate;

  @override
  Future<List<SavedDrawing>> drawingsOfBook(String userBookId) async => [
    for (final d in drawings)
      if (d.layer.userBookId == userBookId) d,
  ];

  @override
  Future<void> commit(String owner, String userBookId, InkChanges c) async {
    await gate;
    if (failCommit) throw StateError('falha de propósito');
    if (c.isEmpty) return;
    commits.add(c);
  }

  @override
  Future<void> saveDraft(
    String owner,
    String userBookId,
    InkChanges c, {
    required String session,
  }) async {
    draftWrites++;
    final key = draftKey(owner, userBookId, session);
    if (c.isEmpty) {
      drafts.remove(key);
    } else {
      drafts[key] = c;
    }
  }

  List<String> _keys(String owner, String userBookId) => [
    for (final k in drafts.keys)
      if (k.startsWith('${draftKey(owner, userBookId)}:')) k,
  ]..sort();

  @override
  Future<List<InkChanges>> draftsOf(String owner, String userBookId) async => [
    for (final k in _keys(owner, userBookId)) drafts[k]!,
  ];

  @override
  Future<void> clearDraft(
    String owner,
    String userBookId, {
    required String session,
  }) async => drafts.remove(draftKey(owner, userBookId, session));

  @override
  Future<bool> recoverDraft(String owner, String userBookId) async {
    var ok = true;
    for (final k in _keys(owner, userBookId)) {
      try {
        await commit(owner, userBookId, drafts[k]!);
        drafts.remove(k);
      } on Object {
        ok = false;
      }
    }
    return ok;
  }
}
