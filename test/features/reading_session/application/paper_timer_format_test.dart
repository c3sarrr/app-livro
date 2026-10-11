// T04.1 — os textos do cronômetro da 01b (L01b) e da folha (D-256, D-257), e a barrinha da mini-barra (R1, R5).
import 'package:app_leitura/features/reading_session/application/paper_timer_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o relógio: mm:ss até 59:59, h:mm:ss daí em diante (R5)', () {
    expect(PaperTimerFormat.clock(0), '00:00');
    expect(PaperTimerFormat.clock(9), '00:09');
    expect(PaperTimerFormat.clock(522), '08:42'); // a prancha 01b
    expect(PaperTimerFormat.clock(3599), '59:59');
    expect(PaperTimerFormat.clock(3600), '1:00:00');
    expect(PaperTimerFormat.clock(4122), '1:08:42');
    expect(PaperTimerFormat.clock(86400), '24:00:00');
  });

  test('o tempo falado: singular, plural, horas, partes zeradas saem (R5)', () {
    expect(
      PaperTimerFormat.spoken(522),
      '8 minutos e 42 segundos',
    ); // a prancha 01b
    expect(PaperTimerFormat.spoken(0), '0 segundos');
    expect(PaperTimerFormat.spoken(1), '1 segundo');
    expect(PaperTimerFormat.spoken(59), '59 segundos');
    expect(PaperTimerFormat.spoken(60), '1 minuto');
    expect(PaperTimerFormat.spoken(61), '1 minuto e 1 segundo');
    expect(PaperTimerFormat.spoken(120), '2 minutos');
    expect(PaperTimerFormat.spoken(3600), '1 hora');
    expect(PaperTimerFormat.spoken(3601), '1 hora e 1 segundo');
    expect(PaperTimerFormat.spoken(3660), '1 hora e 1 minuto');
    expect(PaperTimerFormat.spoken(4122), '1 hora, 8 minutos e 42 segundos');
    expect(PaperTimerFormat.spoken(7200), '2 horas');
  });

  test('o kicker da mini-barra: lendo × em pausa (D-257)', () {
    expect(PaperTimerFormat.kicker(running: true), 'LENDO · PAPEL');
    expect(PaperTimerFormat.kicker(running: false), 'EM PAUSA · PAPEL');
  });

  test('o rótulo da mini-barra: o texto literal da prancha e o pausado (R12, D-257)', () {
    expect(
      PaperTimerFormat.miniBarLabel(
        running: true,
        title: 'Brás Cubas',
        seconds: 522,
      ),
      'Sessão em andamento: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro',
    );
    expect(
      PaperTimerFormat.miniBarLabel(
        running: false,
        title: 'Brás Cubas',
        seconds: 61,
      ),
      'Sessão em pausa: Brás Cubas, 1 minuto e 1 segundo. Abrir cronômetro',
    );
  });

  test('os botões: o literal da prancha, o retomar e a linha da folha (D-256, D-257)', () {
    expect(
      PaperTimerFormat.pauseAria('Brás Cubas'),
      'Pausar leitura de Brás Cubas',
    );
    expect(
      PaperTimerFormat.resumeAria('Brás Cubas'),
      'Retomar leitura de Brás Cubas',
    );
    expect(PaperTimerFormat.pauseButton, 'Pausar');
    expect(PaperTimerFormat.resumeButton, 'Retomar');
    expect(
      PaperTimerFormat.sheetStatus(running: true, seconds: 522),
      'Sessão em andamento · 08:42',
    );
    expect(
      PaperTimerFormat.sheetStatus(running: false, seconds: 4122),
      'Sessão em pausa · 1:08:42',
    );
  });

  test(
    'a barrinha: a meta do dia contando a sessão aberta — 89 % na 01b (R1)',
    () {
      expect(
        PaperTimerFormat.dailyProgress(
          readMinutes: 18,
          goalMinutes: 30,
          openSeconds: 522,
        ),
        closeTo(0.89, 1e-12),
      );
      expect(
        PaperTimerFormat.dailyProgress(
          readMinutes: 0,
          goalMinutes: 30,
          openSeconds: 0,
        ),
        0,
      );
      // nunca passa de 1 (meta batida)
      expect(
        PaperTimerFormat.dailyProgress(
          readMinutes: 40,
          goalMinutes: 30,
          openSeconds: 600,
        ),
        1,
      );
      // meta zerada: cheia se leu algo, vazia se não
      expect(
        PaperTimerFormat.dailyProgress(
          readMinutes: 0,
          goalMinutes: 0,
          openSeconds: 1,
        ),
        1,
      );
      expect(
        PaperTimerFormat.dailyProgress(
          readMinutes: 0,
          goalMinutes: 0,
          openSeconds: 0,
        ),
        0,
      );
    },
  );
}
