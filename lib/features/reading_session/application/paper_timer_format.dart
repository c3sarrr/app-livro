// T04 — os textos do cronômetro do livro de papel: o tempo da mini-barra da 01b ("08:42", tabular), o rótulo falado
// ("Sessão em andamento: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro"), o kicker, os botões e a linha da
// folha da sessão (D-256, D-257, R5, R12); e a barrinha da mini-barra (R1): a meta do dia contando a sessão aberta.
import 'dart:math' as math;

abstract final class PaperTimerFormat {
  /// "08:42" (mm:ss) até 59:59; "1:08:42" (h:mm:ss) daí em diante (R5).
  static String clock(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h == 0 ? '${two(m)}:${two(s)}' : '$h:${two(m)}:${two(s)}';
  }

  /// "8 minutos e 42 segundos", "1 hora, 8 minutos e 42 segundos"; as partes zeradas saem ("0 segundos" com tudo
  /// zero).
  static String spoken(int seconds) {
    String unit(int v, String one, String many) => '$v ${v == 1 ? one : many}';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final parts = [
      if (h > 0) unit(h, 'hora', 'horas'),
      if (m > 0) unit(m, 'minuto', 'minutos'),
      if (s > 0 || seconds == 0) unit(s, 'segundo', 'segundos'),
    ];
    if (parts.length == 1) return parts.single;
    return '${parts.sublist(0, parts.length - 1).join(', ')} e ${parts.last}';
  }

  /// "LENDO · PAPEL" (a prancha) / "EM PAUSA · PAPEL" (D-257).
  static String kicker({required bool running}) =>
      running ? 'LENDO · PAPEL' : 'EM PAUSA · PAPEL';

  /// O rótulo da mini-barra (link): o texto da prancha, e o da pausada (D-257).
  static String miniBarLabel({
    required bool running,
    required String title,
    required int seconds,
  }) =>
      '${running ? 'Sessão em andamento' : 'Sessão em pausa'}: $title, '
      '${spoken(seconds)}. Abrir cronômetro';

  /// O botão da sessão no cartão do Também lendo, rodando (a prancha 01b).
  static String pauseAria(String title) => 'Pausar leitura de $title';

  /// O mesmo botão com a sessão pausada (D-257).
  static String resumeAria(String title) => 'Retomar leitura de $title';

  /// O botão da mini-barra e da folha.
  static const String pauseButton = 'Pausar';
  static const String resumeButton = 'Retomar';

  /// A linha do tempo na folha da sessão (D-256).
  static String sheetStatus({required bool running, required int seconds}) =>
      '${running ? 'Sessão em andamento' : 'Sessão em pausa'} · ${clock(seconds)}';

  /// A barrinha da mini-barra (R1): (os minutos do "Seu dia" + a sessão aberta) ÷ a meta, entre 0 e 1. A 01b:
  /// (18 × 60 + 522) ÷ 1800 = 0,89. Meta zerada: cheia se leu algo.
  static double dailyProgress({
    required int readMinutes,
    required int goalMinutes,
    required int openSeconds,
  }) {
    final read = readMinutes * 60 + openSeconds;
    if (goalMinutes <= 0) return read > 0 ? 1 : 0;
    return math.min(1, math.max(0, read / (goalMinutes * 60)));
  }
}
