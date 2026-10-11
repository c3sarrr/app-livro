// G18 — as medidas da nota à mão e do abridor do Espaço (pranchas 24 e 24b): a altura de cada um no fluxo do texto
// (D-182), a faixa recolhida (D-184), o n do arrasto em linhas inteiras (R2, D-41), as pautas da caixa e a menor
// caixa que contém a tinta (D-186).

/// Uma linha da nota (24b): a caixa mede 42·n + 24; a 1ª pauta fica em 22 + 42.
const double noteLinePx = 42;
const double noteBoxExtra = 24;
const double noteFirstRuleTop = 22;

/// As margens da caixa no fluxo (24b: `margin: 30px 0 26px`).
const double noteMarginTop = 30;
const double noteMarginBottom = 26;

/// O abridor (24): a área mede n·L − 2, com as margens 14/24 (`margin: 14px 0 24px`).
const double openerMarginTop = 14;
const double openerMarginBottom = 24;

/// A faixa recolhida (D-184): a altura de uma linha do texto, com margens 10/10.
const double stripMargin = 10;

/// A borda tracejada da caixa e da faixa: as peças e a tinta se medem por dentro dela (o `position: absolute` do
/// arquivo).
const double noteBorder = 1.5;

/// D-41: de 1 a 12 linhas.
const int minSpaceLines = 1;
const int maxSpaceLines = 12;

/// A caixa da nota de [n] linhas (sem as margens).
double noteBoxHeight(int n) => noteLinePx * n + noteBoxExtra;

/// A caixa no fluxo: as margens e a caixa.
double noteFlowHeight(int n) =>
    noteMarginTop + noteBoxHeight(n) + noteMarginBottom;

/// A área tracejada do abridor de [n] linhas do texto ([lineHeight] = a altura da linha do livro).
double openerAreaHeight(int n, double lineHeight) => n * lineHeight - 2;

/// O abridor no fluxo: as margens e a área.
double openerFlowHeight(int n, double lineHeight) =>
    openerMarginTop + openerAreaHeight(n, lineHeight) + openerMarginBottom;

/// A faixa recolhida no fluxo.
double stripFlowHeight(double lineHeight) => 2 * stripMargin + lineHeight;

/// R2: as linhas do arrasto, com [dy] = a distância do topo da área até o dedo (o dedo fica na borda de baixo da
/// área de n·L − 2).
int linesOfDrag(double dy, double lineHeight) =>
    ((dy + 2) / lineHeight).round().clamp(minSpaceLines, maxSpaceLines);

/// O y de cada pauta de uma caixa de [n] linhas, a partir do topo da caixa.
List<double> noteRulesY(int n) => [
  for (var k = 1; k < n; k++) noteFirstRuleTop + noteLinePx * k,
];

/// D-186: as linhas da menor caixa que contém a tinta que desce até [inkBottom] (px a partir do topo da caixa por
/// dentro da borda — onde a tinta vive): a de n linhas tem 42·n + 24 − 2·1,5 por dentro.
int linesForInk(double inkBottom) =>
    ((inkBottom - (noteBoxExtra - 2 * noteBorder)) / noteLinePx - 1e-9)
        .ceil()
        .clamp(minSpaceLines, maxSpaceLines);
