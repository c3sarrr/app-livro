// R00 (D-267) — o relógio do modo demonstração: parte do "agora" de referência (dom 20/09/2026 20:00 em São Paulo,
// D-09) e anda de verdade a partir da abertura do app — a Início abre com os números do mundo e o cronômetro corre.
/// Um relógio que devolve [inicio] mais o tempo que o [cronometro] mediu (por padrão, um que começa agora).
DateTime Function() relogioDemonstracao(
  DateTime inicio, {
  Stopwatch? cronometro,
}) {
  final c = cronometro ?? (Stopwatch()..start());
  return () => inicio.add(c.elapsed);
}
