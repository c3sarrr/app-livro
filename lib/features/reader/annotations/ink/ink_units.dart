// G16.1 (D-159) — espessura na escala da prancha 22: a caneta Média de 1,2 mm desenha com 2,2 px, como o traço ao
// vivo da 22 (2,2 px ÷ 1,2 mm = 11/6 dp por mm). O "mm" passa a ser nominal: substitui a escala física da D-28.
// Fina, Média e Grossa = 0,6×, 1× e 1,8× do valor do painel. O traço grava a largura efetiva, depois da espessura
// (a D-59 vale também para a espessura: cada traço guarda a própria largura).
import '../domain/pen_presets.dart';

/// 1 mm do painel = 11/6 dp (D-159).
const double dpPerMm = 11 / 6;

/// Fina, Média e Grossa = 0,6×, 1× e 1,8× do valor do painel.
double sizeFactor(StrokeSize s) => switch (s) {
  StrokeSize.thin => 0.6,
  StrokeSize.medium => 1.0,
  StrokeSize.thick => 1.8,
};

/// A largura do traço na tela (dp) para [widthMm] do painel na espessura [s].
double strokeDp(double widthMm, StrokeSize s) =>
    widthMm * sizeFactor(s) * dpPerMm;

/// A largura efetiva gravada no traço, em centésimos de mm (o `u16` do BNK1).
int widthCentiMm(double widthMm, StrokeSize s) =>
    (widthMm * sizeFactor(s) * 100).round();

/// A largura na tela de um traço gravado com [centiMm].
double dpOfCentiMm(int centiMm) => centiMm / 100 * dpPerMm;

/// Os centésimos de mm de uma largura [dp] na tela (as larguras medidas no arquivo — §7).
int centiMmOfDp(double dp) => (dp / dpPerMm * 100).round();
