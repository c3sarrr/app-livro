// G17 (D-172) — a faixa do fundo de um grifo em cada altura, em frações da altura da letra (do topo da letra à base
// dela): Baixa = a metade de baixo (50–92 %, pelas amostras de 6, 11 e 16 px do painel 23b), Média = 12–92 % (a da
// tela 21) e Alta = a letra toda. A prévia do painel 23b usa 14–92 % na Média, como o arquivo (`previewBand`). Dart
// puro: a sessão (a largura do traço do marca-texto — R20) e a pintura usam as mesmas frações.
import 'annotation.dart' show FillHeight;

/// O topo e a base do fundo de [h] na letra (0 = topo da letra, 1 = base).
(double, double) fillBand(FillHeight? h) => switch (h) {
  FillHeight.low => (0.50, 0.92),
  FillHeight.high => (0.0, 1.0),
  _ => (0.12, 0.92),
};

/// A faixa da prévia do painel 23b (o `linear-gradient(transparent 14%, … 92%)` do arquivo na Média).
(double, double) previewBand(FillHeight? h) => switch (h) {
  FillHeight.low => (0.50, 0.92),
  FillHeight.high => (0.0, 1.0),
  _ => (0.14, 0.92),
};
