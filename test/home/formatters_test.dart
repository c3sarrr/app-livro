import 'package:app_leitura/features/home/application/formatters.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../support/html_prancha01.dart';

/// F02 2.3: cada formatador produz a saída IDÊNTICA à prancha, a partir dos dados do mock — desde a T03 a prancha
/// 01 (D-240) e o mock dela (`TelaInicio01`); os formatadores novos da T03 têm os casos à parte em
/// `formatters_t03_test.dart`.
void main() {
  final snap = const HomeMockRepository().snapshot(
    HomeMockRepository.referenceNow,
  );
  final week = snap.readingDay.week;
  final meeting = snap.club!.nextMeeting;

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

    test(
      'pageLabel(159, 256) → "pág. 159 de 256" · formatBadge(epub) → "E-BOOK"',
      () {
        final c = snap.continueReading!;
        expect(
          HomeFormatters.pageLabel(c.refPage!, c.refPagesTotal!),
          'pág. 159 de 256',
        );
        expect(HomeFormatters.formatBadge(c.format), 'E-BOOK');
      },
    );

    test('percent(0.62) → "62%"', () {
      expect(HomeFormatters.percent(snap.continueReading!.progress), '62%');
      // Demais frações do mock (o anel do Orgulho e o clube) também arredondam sem resíduo de ponto flutuante.
      expect(HomeFormatters.percent(snap.alsoReading[1].progress), '81%');
      expect(HomeFormatters.percent(snap.club!.groupProgress), '54%');
      expect(HomeFormatters.percent(snap.club!.userProgress), '62%');
    });

    test('durationLabel(130 min, approx: true) → "~2h 10min"', () {
      expect(snap.continueReading!.timeLeft, const Duration(minutes: 130));
      expect(
        HomeFormatters.durationLabel(
          snap.continueReading!.timeLeft!,
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

    test('paperMeta: "Papel · 3h 40min" (Brás Cubas) · "Papel · pág. 344" (Orgulho)', () {
      final [bras, orgulho, _] =
          snap.alsoReading; // o 3º não tem cartão (o contador diz 3)
      expect(
        HomeFormatters.paperMeta(page: bras.paperPage, readTime: bras.readTime),
        'Papel · 3h 40min',
      );
      expect(
        HomeFormatters.paperMeta(
          page: orgulho.paperPage,
          readTime: orgulho.readTime,
        ),
        'Papel · pág. 344',
      );
    });

    test('remainingGoal(30, 18) → "Faltam " + **"12 min"** + " para fechar a meta de hoje."', () {
      final d = snap.readingDay;
      expect(HomeFormatters.remainingGoal(d.goalMinutes, d.readMinutes), (
        before: 'Faltam ',
        strong: '12 min',
        after: ' para fechar a meta de hoje.',
      ));
    });

    test('sessionsLabel/countLabel → "2 sessões", "2 destaques", "12 dias" (singular só para 1)', () {
      final d = snap.readingDay;
      expect(HomeFormatters.sessionsLabel(d.sessionsToday), '2 sessões');
      expect(
        HomeFormatters.countLabel(d.highlightsToday, 'destaque', 'destaques'),
        '2 destaques',
      );
      expect(HomeFormatters.countLabel(d.streakDays, 'dia', 'dias'), '12 dias');
      expect(HomeFormatters.countLabel(1, 'dia', 'dias'), '1 dia');
      expect(HomeFormatters.countLabel(0, 'dia', 'dias'), '0 dias');
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

    test('reviewKicker(5, 2) → "REVISÃO · 5 GRIFOS · 2 MIN" · reviewSubtitle → "De Dom Casmurro, Quincas Borba e Iracema."', () {
      final r = snap.dailyReview!;
      expect(
        HomeFormatters.reviewKicker(r.highlights, r.minutes),
        'REVISÃO · 5 GRIFOS · 2 MIN',
      );
      expect(
        HomeFormatters.reviewSubtitle(r.bookTitles),
        'De Dom Casmurro, Quincas Borba e Iracema.',
      );
    });

    test(
      'forYouReason("Machado de Assis") → "Porque você lê Machado de Assis"',
      () {
        expect(
          HomeFormatters.forYouReason(snap.forYou!.reasonAuthor),
          'Porque você lê Machado de Assis',
        );
        expect(
          HomeFormatters.forYouReason('Aluísio Azevedo'),
          'Porque você lê Aluísio Azevedo',
        );
      },
    );

    test('participantsExtra(11, 3) → "+8" · aria "11 participantes"', () {
      final c = snap.club!;
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

    test(
      'clubSubtitle(...) → "Dom Casmurro · até o cap. 50" (U+00B7 com espaços)',
      () {
        final s = HomeFormatters.clubSubtitle(
          snap.club!.book,
          snap.club!.untilChapter,
        );
        expect(s, 'Dom Casmurro · até o cap. 50');
        final dot = String.fromCharCode(0x00B7);
        expect(s.indexOf(' $dot '), 'Dom Casmurro'.length);
      },
    );

    test('clubName(club) → "Leitoras de Capitu" (espaço no lugar do <br>)', () {
      expect(HomeFormatters.clubName(snap.club!), 'Leitoras de Capitu');
    });

    test('groupProgressLabel(0,54) → "Grupo em 54%" · userProgressLabel(0,62) → "Você em 62%"', () {
      expect(
        HomeFormatters.groupProgressLabel(snap.club!.groupProgress),
        'Grupo em 54%',
      );
      expect(
        HomeFormatters.userProgressLabel(snap.club!.userProgress),
        'Você em 62%',
      );
      // Derivados dos dados (o percentual sai de `percent`).
      expect(HomeFormatters.groupProgressLabel(0.07), 'Grupo em 7%');
      expect(HomeFormatters.userProgressLabel(1), 'Você em 100%');
    });

    test('recentSubtitle(...) → "Mary Shelley · EPUB" · "Machado de Assis · PDF" · "José de Alencar · Papel"', () {
      expect(snap.recent.map(HomeFormatters.recentSubtitle).toList(), [
        'Mary Shelley · EPUB',
        'Machado de Assis · PDF',
        'José de Alencar · Papel',
      ]);
    });

    test('recentStatusLabel → "Quero ler" · "Lido" · "Novo"', () {
      expect(
        snap.recent
            .map((r) => HomeFormatters.recentStatusLabel(r.status))
            .toList(),
        ['Quero ler', 'Lido', 'Novo'],
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

    test('highlightsAria(12) → "Destaques e notas deste livro (12)"', () {
      expect(
        HomeFormatters.highlightsAria(snap.continueReading!.highlightsCount),
        'Destaques e notas deste livro (12)',
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
        HomeFormatters.messagesAria(snap.club!.unreadMessages),
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
      expect(HomeFormatters.formatLabel(BookFormat.physical), 'Papel');
    });
  });

  // Conferência contra a fonte da verdade nº 1 (prompt mestre §2): cada saída aparece LITERALMENTE no HTML da
  // prancha 01 (as fases L01a1…L01a9; até a T03, o HTML original da v1).
  group('as saídas aparecem literalmente na prancha 01', () {
    final html = htmlDaPrancha01();
    String aria(String label) => 'aria-label="$label"';
    String node(String text) => '>$text<';
    // Texto solto entre tags (depois de um ícone, com a indentação do HTML em volta).
    bool loose(String text) =>
        RegExp('>\\s*${RegExp.escape(text)}\\s*<').hasMatch(html);
    String strong(EmphasisText t) =>
        '${t.before}<strong style="font-weight: 800;">${t.strong}</strong>${t.after}';

    test('aria-labels', () {
      final c = snap.club!;
      for (final label in [
        HomeFormatters.notificationsAria(snap.user.unreadNotifications),
        HomeFormatters.highlightsAria(snap.continueReading!.highlightsCount),
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
      final c = snap.club!;
      final d = snap.readingDay;
      final hero = snap.continueReading!;
      final r = snap.dailyReview!;
      for (final text in [
        HomeFormatters.greeting(snap.now),
        HomeFormatters.pageLabel(hero.refPage!, hero.refPagesTotal!),
        HomeFormatters.formatBadge(hero.format),
        HomeFormatters.percent(hero.progress),
        HomeFormatters.percent(snap.alsoReading[1].progress),
        HomeFormatters.durationLabel(hero.timeLeft!, approx: true),
        HomeFormatters.weekTotalLabel(week),
        HomeFormatters.sessionsLabel(d.sessionsToday),
        HomeFormatters.countLabel(d.highlightsToday, 'destaque', 'destaques'),
        HomeFormatters.reviewKicker(r.highlights, r.minutes),
        HomeFormatters.reviewSubtitle(r.bookTitles),
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
      // Soltos depois de um ícone: "12 dias" (a chama), o motivo de "Para você" (o brilho do chip) e as pílulas
      // do papel (o livro de papel).
      for (final text in [
        HomeFormatters.countLabel(d.streakDays, 'dia', 'dias'),
        HomeFormatters.forYouReason(snap.forYou!.reasonAuthor),
        for (final i in snap.alsoReading.take(2))
          HomeFormatters.paperMeta(page: i.paperPage, readTime: i.readTime),
      ]) {
        expect(loose(text), isTrue, reason: text);
      }
      // Nome do clube: um único <h3> com as duas partes separadas por <br> (o nome acessível do `clubName`
      // troca o <br> por um espaço). As duas partes são capturadas do HTML (o texto do <h3> até o <br> e o texto
      // do <span> itálico) e comparadas com os dados e com o nome acessível.
      final h3 = RegExp(
        r'>\s*([^<>]+?)<br><span style="[^"]*">([^<>]+)</span></h3>',
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
      expect(html.contains('>$goal</p>'), isTrue, reason: goal);
      expect(html.contains('<span>$badge</span>'), isTrue, reason: badge);
    });

    test('rótulos da semana (6 iniciais + "Hoje" em destaque)', () {
      final initials = HomeFormatters.weekInitials(week);
      final expected = [
        for (final i in initials.take(6)) '<span>$i</span>',
        '<span style="color: #1A1714; font-weight: 800;">${initials.last}</span>',
      ].join();
      expect(html.contains(expected), isTrue, reason: expected);
    });
  });
}
