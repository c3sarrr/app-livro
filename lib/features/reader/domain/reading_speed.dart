// G10.4 — velocidade pessoal e tempo restante (Anexo 03 §8, D-97): caracteres por minuto das sessões de 3 min
// ou mais, em média móvel exponencial (α = 0,2, a primeira sessão começa a média), em ordem de início;
// sem sessão assim, 1.000 car./min. Tempo restante = caracteres que faltam ÷ velocidade, arredondado a 10 min
// acima de 1 h e a 5 min abaixo.
import '../content/ref_pages.dart';

/// Velocidade quando ainda não há sessão de 3 min (≈ 180 palavras/min em português — calibrar no beta).
const double defaultCharsPerMinute = 1000;

/// Peso da sessão mais nova na média.
const double speedAlpha = 0.2;

/// Sessão mais curta que entra na velocidade.
const int minSpeedSessionSeconds = 180;

/// O que uma sessão diz da velocidade: tempo ativo, páginas de referência lidas e o tamanho médio da página
/// de referência do livro dela (caracteres).
typedef SpeedSample = ({
  int activeSeconds,
  int? pagesViewed,
  double charsPerRefPage,
});

/// Caracteres por página de referência de um livro: total ÷ páginas; sem índice, o N das páginas sintéticas.
double charsPerRefPage({int? totalChars, int? refPagesTotal}) =>
    totalChars != null &&
        totalChars > 0 &&
        refPagesTotal != null &&
        refPagesTotal > 0
    ? totalChars / refPagesTotal
    : refPageChars.toDouble();

/// Velocidade pessoal (caracteres por minuto) das [samples] em ordem de início.
double personalSpeed(Iterable<SpeedSample> samples) {
  double? ema;
  for (final s in samples) {
    final pages = s.pagesViewed ?? 0;
    if (s.activeSeconds < minSpeedSessionSeconds || pages <= 0) continue;
    final cpm = pages * s.charsPerRefPage / (s.activeSeconds / 60);
    ema = ema == null ? cpm : speedAlpha * cpm + (1 - speedAlpha) * ema;
  }
  return ema ?? defaultCharsPerMinute;
}

/// Tempo para ler [remainingChars] na velocidade [charsPerMinute], já arredondado (D-97).
Duration timeLeftFor(int remainingChars, double charsPerMinute) {
  if (remainingChars <= 0 || charsPerMinute <= 0) return Duration.zero;
  final minutes = remainingChars / charsPerMinute;
  final step = minutes >= 60 ? 10 : 5;
  final rounded = (minutes / step).round() * step;
  return Duration(minutes: rounded < step ? step : rounded);
}

/// "≈ 2 h 10 min" (leitor, Anexo 03 §8); abaixo de 1 h, "≈ 45 min".
String readerTimeLeftLabel(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return h > 0 ? '≈ $h h ${m.toString().padLeft(2, '0')} min' : '≈ $m min';
}
