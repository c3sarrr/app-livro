// G16.2 — os cartões dos desenhos (Anexo 02 §4.3), no Concluir: um desenho novo entra no `group_id` do desenho da
// mesma página cuja linha de âncora está a até 2 linhas da dele; havendo mais de um, o mais perto, e no empate o mais
// antigo (a hora de criação, depois o id). Senão, o grupo é o próprio id (como os grifos da G13). Grupos já gravados
// não mudam: só os desenhos novos passam por aqui, em ordem de criação. Dart puro.

/// Um desenho da página que pode emprestar o grupo: o id, o grupo dele, a linha da âncora e a hora de criação.
typedef CardCandidate = ({
  String id,
  String group,
  int line,
  DateTime createdAt,
});

/// A distância máxima, em linhas, para entrar no grupo de outro desenho.
const int cardGroupMaxLines = 2;

/// O grupo do desenho novo [id], preso à linha [line], contra os desenhos [others] da mesma página.
String cardGroup({
  required String id,
  required int line,
  required List<CardCandidate> others,
}) {
  CardCandidate? best;
  for (final c in others) {
    if (c.id == id) continue;
    final d = (c.line - line).abs();
    if (d > cardGroupMaxLines) continue;
    if (best == null) {
      best = c;
      continue;
    }
    final bd = (best.line - line).abs();
    if (d < bd || (d == bd && _older(c, best))) best = c;
  }
  return best?.group ?? id;
}

bool _older(CardCandidate a, CardCandidate b) {
  final c = a.createdAt.compareTo(b.createdAt);
  return c != 0 ? c < 0 : a.id.compareTo(b.id) < 0;
}
