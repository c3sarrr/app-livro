// G21.5 — "Compartilhar no clube" na 25 (D-217; docs/progresso/G21.md §5): os 7 casos. Vão o trecho, a cor, a página,
// o capítulo do clube e a fração do livro (o spoiler — D-218); a nota fica no aparelho. Tudo precisa de conta e de
// rede; os textos sem prancha estão em docs/design/estados_sem_design.md.
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/domain/locator.dart';
import '../domain/highlight_card.dart';

/// Um clube para a folha "Compartilhar em…": o nome e a cor.
typedef ShareClub = ({String id, String name, String color});

/// Os termos da comunidade (D-222): a versão atual e se a pessoa aceitou.
typedef ShareTerms = ({String version, bool accepted});

/// O que a 25 precisa dos clubes para compartilhar (a G21 liga; os testes trocam).
abstract interface class HighlightsShare {
  /// Os meus clubes que leem o livro [userBookId] (R1, no aparelho), do encontro mais próximo.
  Future<List<ShareClub>> clubsFor(String userBookId);
  Future<ShareTerms> terms();
  Future<void> acceptTerms(String version);

  /// Publica o grifo [highlight] em [club] e devolve o id do post.
  Future<String> share(ShareClub club, Annotation highlight);
}

/// O passo seguinte do compartilhar.
sealed class ShareStep {
  const ShareStep();
}

/// Uma pílula e fim (feito, ou o motivo de não dar).
final class ShareNotice extends ShareStep {
  const ShareNotice(this.text);
  final String text;
}

/// A folha "Antes de publicar" (os termos — D-222); aceitando, segue para [clubs].
final class ShareNeedsTerms extends ShareStep {
  const ShareNeedsTerms(this.version, this.clubs);
  final String version;
  final List<ShareClub> clubs;
}

/// A folha "Compartilhar em…" (mais de um clube lê o livro).
final class ShareChoose extends ShareStep {
  const ShareChoose(this.clubs);
  final List<ShareClub> clubs;
}

const String shareSignInText = 'Entre na sua conta para compartilhar.';
const String shareOfflineText = 'Sem conexão. Tente de novo.';
const String shareNoClubText = 'Nenhum clube seu está lendo este livro.';
const String shareFailedText = 'Não deu para compartilhar. Tente de novo.';
String sharedText(String club) => 'Compartilhado em $club.';

/// A opção do cartão já compartilhado (§5, caso 6); sem o nome do clube no aparelho, "no clube".
String alreadySharedText(String? club) =>
    club == null ? 'Já está no clube' : 'Já está em $club';

/// O grifo do cartão que pode ir para o clube: um grifo com o trecho (o marca-texto à mão e a tinta não têm texto —
/// §5, caso 7); `null` = a opção não aparece.
Annotation? shareableHighlight(HighlightCard c) {
  if (c.freehand) return null;
  final h = c.noteParent ?? c.highlight;
  if (h == null || h.kind != AnnotationKind.highlight) return null;
  return switch (h.anchor) {
    EpubAnchor(:final quote) when quote.exact.trim().isNotEmpty => h,
    _ => null,
  };
}
