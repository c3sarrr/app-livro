import 'dart:io';

import 'package:app_leitura/features/home/application/formatters.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// F02 2.3: cada formatador produz a saída IDÊNTICA ao arquivo, a partir dos dados do mock.
void main() {
  final snap = const HomeMockRepository().snapshot(
    HomeMockRepository.referenceNow,
  );
  final week = snap.readingDay.week;
  final meeting = snap.club.nextMeeting;

  group('tabela 2.3 (entrada do mock → saída exata)', () {
    test('greeting(20:00) → "Boa noite," e faixas 5–11 / 12–17 / 18–4', () {
      expect(HomeFormatters.greeting(snap.now), 'Boa noite,');
      String at(int h, [int m = 0]) =>
          HomeFormatters.greeting(DateTime(2026, 9, 20, h, m));
      expect(at(5), 'Bom dia,');
      expect(at(11, 59), 'Bom dia,');
      expect(at(12), 'Boa tarde,');
      expect(at(17, 59), 'Boa tarde,');
      expect(at(18), 'Boa noite,');
      expect(at(23, 59), 'Boa noite,');
      expect(at(0), 'Boa noite,');
      expect(at(4, 59), 'Boa noite,');
      for (var h = 0; h < 24; h++) {
        final expected = h >= 5 && h <= 11
            ? 'Bom dia,'
            : h >= 12 && h <= 17
            ? 'Boa tarde,'
            : 'Boa noite,';
        expect(at(h), expected, reason: '$h h');
      }
    });

    test('chapterLabel(92, 148) → "Cap. 92 de 148"', () {
      final c = snap.continueReading;
      expect(
        HomeFormatters.chapterLabel(c.chapter, c.totalChapters),
        'Cap. 92 de 148',
      );
    });

    test('percent(0.62) → "62%"', () {
      expect(HomeFormatters.percent(snap.continueReading.progress), '62%');
      // Demais frações do mock (anéis e clube) também arredondam sem resíduo de ponto flutuante.
      expect(HomeFormatters.percent(snap.alsoReading[0].progress), '34%');
      expect(HomeFormatters.percent(snap.alsoReading[1].progress), '81%');
      expect(HomeFormatters.percent(snap.club.groupProgress), '54%');
      expect(HomeFormatters.percent(snap.club.userProgress), '62%');
    });

    test('durationLabel(130 min, approx: true) → "~2h 10min"', () {
      expect(snap.continueReading.timeLeft, const Duration(minutes: 130));
      expect(
        HomeFormatters.durationLabel(
          snap.continueReading.timeLeft,
          approx: true,
        ),
        '~2h 10min',
      );
    });

    test('durationLabel(240 min) → "4h 00min" → "4h 00min no total"', () {
      final total = week.fold<int>(0, (s, d) => s + d.minutes);
      expect(total, 240); // soma da semana
      expect(
        HomeFormatters.durationLabel(Duration(minutes: total)),
        '4h 00min',
      );
      expect(HomeFormatters.weekTotalLabel(week), '4h 00min no total');
    });

    test('remainingGoal(30, 18) → "Faltam " + **"12 min"** + " para fechar a meta de hoje."', () {
      final d = snap.readingDay;
      expect(HomeFormatters.remainingGoal(d.goalMinutes, d.readMinutes), (
        before: 'Faltam ',
        strong: '12 min',
        after: ' para fechar a meta de hoje.',
      ));
    });

    test('countLabel → "24 páginas", "2 destaques", "12 dias" (singular só para 1)', () {
      final d = snap.readingDay;
      expect(
        HomeFormatters.countLabel(d.pagesToday, 'página', 'páginas'),
        '24 páginas',
      );
      expect(
        HomeFormatters.countLabel(d.highlightsToday, 'destaque', 'destaques'),
        '2 destaques',
      );
      expect(HomeFormatters.countLabel(d.streakDays, 'dia', 'dias'), '12 dias');
      expect(HomeFormatters.countLabel(1, 'página', 'páginas'), '1 página');
      expect(HomeFormatters.countLabel(0, 'página', 'páginas'), '0 páginas');
    });

    test(
      'badgeHint(12, 14) → "Mais " + **"2 dias"** + " para o selo de 14 dias"',
      () {
        final d = snap.readingDay;
        expect(HomeFormatters.badgeHint(d.streakDays, d.badgeTargetDays), (
          before: 'Mais ',
          strong: '2 dias',
          after: ' para o selo de 14 dias',
        ));
      },
    );

    test('weekInitials(seg..sáb) + "Hoje" → "S T Q Q S S Hoje"', () {
      expect(HomeFormatters.weekInitials(week), [
        'S',
        'T',
        'Q',
        'Q',
        'S',
        'S',
        'Hoje',
      ]);
      expect(HomeFormatters.weekInitials(week).join(' '), 'S T Q Q S S Hoje');
    });

    test('weekAria(...) → frase exata', () {
      expect(
        HomeFormatters.weekAria(week, snap.readingDay.goalMinutes),
        'Minutos lidos por dia: segunda 32, terça 45, quarta 30, quinta 22, '
        'sexta 38, sábado 55, hoje 18 de 30',
      );
    });

    test(
      'forYouReason("Machado de Assis") → "Porque você lê Machado de Assis"',
      () {
        expect(
          HomeFormatters.forYouReason(snap.forYou.reasonAuthor),
          'Porque você lê Machado de Assis',
        );
        expect(
          HomeFormatters.forYouReason('Aluísio Azevedo'),
          'Porque você lê Aluísio Azevedo',
        );
      },
    );

    test('participantsExtra(11, 3) → "+8" · aria "11 participantes"', () {
      final c = snap.club;
      expect(
        HomeFormatters.participantsExtra(
          c.participantsCount,
          c.shownParticipants.length,
        ),
        '+8',
      );
      expect(
        HomeFormatters.participantsAria(c.participantsCount),
        '11 participantes',
      );
    });

    test('clubSubtitle(...) → "Dom Casmurro · até o cap. 100" (U+00B7 com espaços)', () {
      final s = HomeFormatters.clubSubtitle(
        snap.club.book,
        snap.club.untilChapter,
      );
      expect(s, 'Dom Casmurro · até o cap. 100');
      final dot = String.fromCharCode(0x00B7);
      expect(s.indexOf(' $dot '), 'Dom Casmurro'.length);
    });

    test('clubName(club) → "Leitoras de Capitu" (espaço no lugar do <br>)', () {
      expect(HomeFormatters.clubName(snap.club), 'Leitoras de Capitu');
    });

    test('groupProgressLabel(0,54) → "Grupo em 54%" · userProgressLabel(0,62) → "Você em 62%"', () {
      expect(
        HomeFormatters.groupProgressLabel(snap.club.groupProgress),
        'Grupo em 54%',
      );
      expect(
        HomeFormatters.userProgressLabel(snap.club.userProgress),
        'Você em 62%',
      );
      // Derivados dos dados (o percentual sai de `percent`).
      expect(HomeFormatters.groupProgressLabel(0.07), 'Grupo em 7%');
      expect(HomeFormatters.userProgressLabel(1), 'Você em 100%');
    });

    test('recentSubtitle(...) → "Mary Shelley · EPUB" · "Machado de Assis · PDF" · "José de Alencar · EPUB"', () {
      expect(snap.recent.map(HomeFormatters.recentSubtitle).toList(), [
        'Mary Shelley · EPUB',
        'Machado de Assis · PDF',
        'José de Alencar · EPUB',
      ]);
    });

    test('recentStatusLabel → "Quero ler" · "Novo"', () {
      expect(
        snap.recent
            .map((r) => HomeFormatters.recentStatusLabel(r.status))
            .toList(),
        ['Quero ler', 'Quero ler', 'Novo'],
      );
    });

    test('weekdayShort(24/09/2026) → "QUI" · monthShort → "SET" · day → "24" · hourLabel(20:00) → "20h"', () {
      expect(HomeFormatters.weekdayShort(meeting), 'QUI');
      expect(HomeFormatters.monthShort(meeting), 'SET');
      expect(HomeFormatters.day(meeting), '24');
      expect(HomeFormatters.hourLabel(meeting), '20h');
    });

    test(
      'meetingAria(...) → "Próximo encontro: quinta, 24 de setembro, às 20h"',
      () {
        expect(
          HomeFormatters.meetingAria(meeting),
          'Próximo encontro: quinta, 24 de setembro, às 20h',
        );
      },
    );

    test('notificationsAria(2) → "Notificações, 2 novas"', () {
      expect(
        HomeFormatters.notificationsAria(snap.user.unreadNotifications),
        'Notificações, 2 novas',
      );
    });

    test('highlightsAria(14) → "Destaques e notas deste livro (14)"', () {
      expect(
        HomeFormatters.highlightsAria(snap.continueReading.highlightsCount),
        'Destaques e notas deste livro (14)',
      );
    });

    test('moreOptionsAria(book) → "Mais opções para Frankenstein" (etc.)', () {
      expect(
        snap.recent.map((r) => HomeFormatters.moreOptionsAria(r.book)).toList(),
        [
          'Mais opções para Frankenstein',
          'Mais opções para O Alienista',
          'Mais opções para Senhora',
        ],
      );
    });

    test('messagesAria(3) → "3 mensagens novas"', () {
      expect(
        HomeFormatters.messagesAria(snap.club.unreadMessages),
        '3 mensagens novas',
      );
    });
  });

  group('abreviações próprias (sem intl: nada de "qui." / "set.")', () {
    test('semana SEG TER QUA QUI SEX SÁB DOM', () {
      // 21/09/2026 é segunda-feira.
      expect(
        [
          for (var i = 0; i < 7; i++)
            HomeFormatters.weekdayShort(DateTime(2026, 9, 21 + i)),
        ],
        ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'],
      );
    });

    test('meses JAN FEV MAR ABR MAI JUN JUL AGO SET OUT NOV DEZ', () {
      expect(
        [
          for (var m = 1; m <= 12; m++)
            HomeFormatters.monthShort(DateTime(2026, m)),
        ],
        [
          'JAN',
          'FEV',
          'MAR',
          'ABR',
          'MAI',
          'JUN',
          'JUL',
          'AGO',
          'SET',
          'OUT',
          'NOV',
          'DEZ',
        ],
      );
    });

    test('rótulos de formato do livro', () {
      expect(HomeFormatters.formatLabel(BookFormat.epub), 'EPUB');
      expect(HomeFormatters.formatLabel(BookFormat.pdf), 'PDF');
    });
  });

  // Conferência contra a fonte da verdade nº 1 (prompt mestre §2): cada saída aparece LITERALMENTE no
  // HTML original. No bundle, o HTML está escapado: aspas = \" e "/" dos fechamentos = /.
  group('as saídas aparecem literalmente no HTML original', () {
    final html = File(
      'design_handoff/referencia/original/Redesign mobile — App de leitura.html',
    ).readAsStringSync();
    const q = r'\"';
    // Fechamento de tag no bundle: "<", barra invertida, "u002F" (montado por código).
    final close = '<${String.fromCharCode(0x5C)}u002F';
    String aria(String label) => 'aria-label=$q$label$q';
    String node(String text) => '>$text<';
    String strong(EmphasisText t) =>
        '${t.before}<strong style=${q}font-weight: 800;$q>${t.strong}${close}strong>${t.after}';

    test('aria-labels', () {
      final c = snap.club;
      for (final label in [
        HomeFormatters.notificationsAria(snap.user.unreadNotifications),
        HomeFormatters.highlightsAria(snap.continueReading.highlightsCount),
        HomeFormatters.weekAria(week, snap.readingDay.goalMinutes),
        HomeFormatters.participantsAria(c.participantsCount),
        HomeFormatters.messagesAria(c.unreadMessages),
        HomeFormatters.meetingAria(c.nextMeeting),
        for (final r in snap.recent) HomeFormatters.moreOptionsAria(r.book),
      ]) {
        expect(html.contains(aria(label)), isTrue, reason: label);
      }
    });

    test('textos visíveis (nós de texto exatos)', () {
      final c = snap.club;
      final d = snap.readingDay;
      for (final text in [
        HomeFormatters.greeting(snap.now),
        HomeFormatters.chapterLabel(
          snap.continueReading.chapter,
          snap.continueReading.totalChapters,
        ),
        HomeFormatters.percent(snap.continueReading.progress),
        HomeFormatters.percent(snap.alsoReading[0].progress),
        HomeFormatters.percent(snap.alsoReading[1].progress),
        HomeFormatters.durationLabel(
          snap.continueReading.timeLeft,
          approx: true,
        ),
        HomeFormatters.weekTotalLabel(week),
        HomeFormatters.countLabel(d.pagesToday, 'página', 'páginas'),
        HomeFormatters.countLabel(d.highlightsToday, 'destaque', 'destaques'),
        HomeFormatters.participantsExtra(
          c.participantsCount,
          c.shownParticipants.length,
        ),
        HomeFormatters.clubSubtitle(c.book, c.untilChapter),
        HomeFormatters.groupProgressLabel(c.groupProgress),
        HomeFormatters.userProgressLabel(c.userProgress),
        for (final r in snap.recent) HomeFormatters.recentSubtitle(r),
        for (final r in snap.recent) HomeFormatters.recentStatusLabel(r.status),
        HomeFormatters.weekdayShort(c.nextMeeting),
        HomeFormatters.monthShort(c.nextMeeting),
        HomeFormatters.day(c.nextMeeting),
        HomeFormatters.hourLabel(c.nextMeeting),
      ]) {
        expect(html.contains(node(text)), isTrue, reason: text);
      }
      // "12 dias" é texto solto depois do ícone da chama (espaços e \n do bundle em volta).
      final streak = HomeFormatters.countLabel(d.streakDays, 'dia', 'dias');
      expect(
        RegExp(r'>(?:\\n| )*' + RegExp.escape(streak) + r'(?:\\n| )*<')
            .hasMatch(html),
        isTrue,
        reason: streak,
      );
      // Motivo de "Para você": texto solto depois do brilho do chip (espaços e \n do bundle em volta).
      final reason = HomeFormatters.forYouReason(snap.forYou.reasonAuthor);
      expect(
        RegExp(r'>(?:\\n| )*' + RegExp.escape(reason) + r'(?:\\n| )*<')
            .hasMatch(html),
        isTrue,
        reason: reason,
      );
      // Nome do clube: um único <h3> com as duas partes separadas por <br> (o nome acessível do
      // `clubName` troca o <br> por um espaço).
      // As duas partes são capturadas do HTML (texto do <h3> até o <br> e o texto do <span> itálico) e
      // comparadas com os dados e com o nome acessível.
      final h3 = RegExp(
        r'>([^<>]+)<br><span style=' +
            RegExp.escape(q) +
            r'[^"\\]*' + // estilo do itálico (sem aspas nem barras)
            RegExp.escape(q) +
            r'>([^<>]+)' +
            RegExp.escape('${close}span>${close}h3>'),
      );
      final match = h3.allMatches(html).toList();
      expect(match, hasLength(1), reason: h3.pattern);
      final (prefix, highlight) = (match.single[1]!, match.single[2]!);
      expect((prefix, highlight), (c.namePrefix, c.nameHighlight));
      expect(HomeFormatters.clubName(c), '$prefix $highlight');
    });

    test('frases com trecho em negrito (<strong>)', () {
      final d = snap.readingDay;
      final goal = strong(
        HomeFormatters.remainingGoal(d.goalMinutes, d.readMinutes),
      );
      final badge = strong(
        HomeFormatters.badgeHint(d.streakDays, d.badgeTargetDays),
      );
      expect(html.contains('$goal${close}p>'), isTrue, reason: goal);
      expect(html.contains('<span>$badge${close}span>'), isTrue, reason: badge);
    });

    test('rótulos da semana (6 iniciais + "Hoje" em destaque)', () {
      final initials = HomeFormatters.weekInitials(week);
      final expected = [
        for (final i in initials.take(6)) '<span>$i${close}span>',
        '<span style=${q}color: #1A1714; font-weight: 800;$q>${initials.last}${close}span>',
      ].join();
      expect(html.contains(expected), isTrue, reason: expected);
    });
  });
}
