import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../support/html_prancha01.dart';

void main() {
  group('2.1 modelos imutáveis, sem strings formatadas', () {
    final source = File('lib/features/home/domain/models.dart')
        .readAsStringSync();
    final classes = RegExp(r'class (\w+) \{')
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toList();

    test('os tipos da 2.1 existem (12 classes + 2 enums, e o enum cru BookFormat) — G08: capa selada', () {
      expect(classes, [
        'BookCover',
        'Book',
        'UserSummary',
        'ContinueReading',
        'AlsoReadingItem',
        'WeekDayStat',
        'ReadingDay',
        'ForYou',
        'ClubParticipant',
        'BookClub',
        'RecentItem',
        'DailyReview',
        'HomeSnapshot',
      ]);
      expect(CoverArt.values.map((e) => e.name), [
        'domCasmurro',
        'pridePrejudice',
        'frankenstein',
        'oAlienista',
        'senhora',
        // T03: as artes da prancha 01
        'brasCubas',
        'esauEJaco',
        'memorialDeAires',
        'casaDePensao',
      ]);
      // T03 (D-255): "Lido"
      expect(RecentStatus.values.map((e) => e.name), [
        'wantToRead',
        'isNew',
        'read',
      ]);
      // G08 (D-85): exemplar físico escaneado.
      expect(BookFormat.values.map((e) => e.name), ['epub', 'pdf', 'physical']);
    });

    test(
      'toda classe é @immutable, tem construtor const e só campos final',
      () {
        // G08 (D-79): a capa é selada, com duas variantes finais e const.
        expect(source.contains('@immutable\nsealed class BookCover {'), isTrue);
        expect(source.contains('const BookCover();'), isTrue);
        for (final sub in ['DesignedCover', 'PhotoCover']) {
          expect(
            source.contains('final class $sub extends BookCover {'),
            isTrue,
            reason: sub,
          );
          expect(source.contains('const $sub('), isTrue, reason: sub);
        }
        for (final name in classes.where((c) => c != 'BookCover')) {
          expect(
            source.contains('@immutable\nclass $name {'),
            isTrue,
            reason: '$name sem @immutable',
          );
          expect(
            source.contains('const $name({'),
            isTrue,
            reason: '$name sem construtor const',
          );
        }
        // Declarações de campo: toda linha "  <Tipo> <nome>;" dentro das classes começa com "final".
        final fieldDecl = RegExp(
          r'^  (?!const |static )([\w<>?, ]+) (\w+);$',
          multiLine: true,
        );
        final nonFinal = fieldDecl
            .allMatches(source)
            .where((m) => !m.group(0)!.trimLeft().startsWith('final '))
            .map((m) => m.group(0))
            .toList();
        expect(nonFinal, isEmpty, reason: nonFinal.join('\n'));
        // 1 + 3 (capas) + 5 + 3 + 7 + 5 + 4 + 7 + 2 + 2 + 12 + 3 + 3 + 10 campos, na ordem das classes
        // (G08: capa desenhada/foto e `shelfIsEmpty`; G09: a capa do arquivo — `fileSha`, D-90; G12: o formato do
        // "Continuar lendo" — o físico vai à página do livro, D-123; T03: a página do herói, o livro de papel do
        // Também lendo, as sessões de hoje e a revisão do dia — D-252…D-254, D-247; a troca da T03.15 tirou os
        // capítulos do herói e as páginas do dia, que só a v1 desenhava).
        expect(
          RegExp(r'^  final ', multiLine: true).allMatches(source).length,
          67,
        );
      },
    );

    test('únicos campos String são nomes, títulos, ids e iniciais (nenhum texto formatado)', () {
      final stringFields = RegExp(
        r'^  final String\?? (\w+);$',
        multiLine: true,
      ).allMatches(source).map((m) => m.group(1)).toSet();
      expect(stringFields, {
        'id',
        'ref',
        'isbn13',
        'fileSha',
        'title',
        'shortTitle',
        'author',
        'firstName',
        'initial',
        'reasonAuthor',
        'namePrefix',
        'nameHighlight',
        'userInitial',
      });
    });

    test('construtores const utilizáveis em expressões constantes', () {
      const book = Book(
        id: 'x',
        title: 'T',
        author: 'A',
        cover: DesignedCover(CoverArt.senhora),
      );
      const items = [
        UserSummary(firstName: 'N', initial: 'N', unreadNotifications: 0),
        ContinueReading(
          book: book,
          refPage: 1,
          refPagesTotal: 2,
          progress: 0.5,
          timeLeft: Duration(minutes: 1),
          highlightsCount: 0,
        ),
        AlsoReadingItem(book: book, progress: 0.1, format: BookFormat.epub),
        ForYou(reasonAuthor: 'A', items: [book]),
        ClubParticipant(initial: 'A', color: AppColors.lavender),
        RecentItem(
          book: book,
          format: BookFormat.pdf,
          status: RecentStatus.isNew,
        ),
      ];
      expect(items, hasLength(6));
    });
  });

  // Desde a T03 (D-240) o mock é a prancha 01 (`TelaInicio01`, montada do mundo de referência).
  group('2.2 mock com os dados EXATOS da prancha 01', () {
    final snap = const HomeMockRepository().snapshot(
      HomeMockRepository.referenceNow,
    );

    test('agora de referência = domingo 20/09/2026 20:00 (D-09)', () {
      final now = HomeMockRepository.referenceNow;
      expect(now, DateTime(2026, 9, 20, 20));
      expect(now.weekday, DateTime.sunday);
      expect(snap.now, now);
      // O "agora" vem do chamador (relógio), não é fixo no snapshot.
      final morning = DateTime(2026, 9, 20, 9);
      expect(const HomeMockRepository().snapshot(morning).now, morning);
    });

    test('usuário: Marina, inicial M, 2 notificações não lidas', () {
      expect(snap.user.firstName, 'Marina');
      expect(snap.user.initial, 'M');
      expect(snap.user.unreadNotifications, 2);
    });

    test('continuar lendo: Dom Casmurro — Machado de Assis, EPUB, pág. 159 de 256, 0,62, ~2h10min, 12 anotações', () {
      final c = snap.continueReading!;
      expect(c.book.title, 'Dom Casmurro');
      expect(c.book.author, 'Machado de Assis');
      expect(c.book.cover, const DesignedCover(CoverArt.domCasmurro));
      expect(c.format, BookFormat.epub);
      expect((c.refPage, c.refPagesTotal), (159, 256));
      expect(c.progress, 0.62);
      expect(c.timeLeft, const Duration(hours: 2, minutes: 10));
      expect(c.highlightsCount, 12);
    });

    test('também lendo: Brás Cubas em papel (3h 40min, sem página) · Orgulho e Preconceito em papel (pág. 344, 0,81) · '
        'Mrs. Dalloway (só no contador)', () {
      expect(snap.alsoReading, hasLength(3));
      final [a, b, c] = snap.alsoReading;
      expect(
        (a.book.title, a.book.shortTitle, a.book.author, a.book.cover),
        (
          'Memórias Póstumas de Brás Cubas',
          'Brás Cubas',
          'Machado de Assis',
          const DesignedCover(CoverArt.brasCubas),
        ),
      );
      expect(
        (a.format, a.paperPage, a.readTime),
        (BookFormat.physical, null, const Duration(hours: 3, minutes: 40)),
      );
      expect(
        (b.book.title, b.book.author, b.book.cover, b.progress),
        (
          'Orgulho e Preconceito',
          'Jane Austen',
          const DesignedCover(CoverArt.pridePrejudice),
          0.81,
        ),
      );
      expect(
        (b.format, b.paperPage, b.readTime),
        (BookFormat.physical, 344, null),
      );
      expect(
        (c.book.title, c.book.author, c.book.cover, c.progress),
        (
          'Mrs. Dalloway',
          'Virginia Woolf',
          // o 3º livro não aparece na grade da 01: sem arte do arquivo, a capa gerada (D-79)
          const PhotoCover(),
          0.34,
        ),
      );
    });

    test('dia de leitura: meta 30, lidos 18, sequência 12, 2 sessões, 2 destaques, selo aos 14', () {
      final d = snap.readingDay;
      expect(d.goalMinutes, 30);
      expect(d.readMinutes, 18);
      expect(d.streakDays, 12);
      expect(d.sessionsToday, 2);
      expect(d.highlightsToday, 2);
      expect(d.badgeTargetDays, 14);
    });

    test('revisão do dia (D-247, só fixture até a T05): 5 grifos, 2 min, Dom Casmurro, Quincas Borba e Iracema', () {
      final r = snap.dailyReview!;
      expect((r.highlights, r.minutes), (5, 2));
      expect(r.bookTitles, ['Dom Casmurro', 'Quincas Borba', 'Iracema']);
    });

    test(
      'semana seg→hoje: minutos, alturas (D-10), datas e hoje = domingo',
      () {
        final w = snap.readingDay.week;
        expect(w.map((d) => d.minutes), [32, 45, 30, 22, 38, 55, 18]);
        expect(w.map((d) => d.barHeightPx), [43, 60, 40, 30, 51, 73, 24]);
        expect(w.map((d) => d.date), [
          for (var day = 14; day <= 20; day++) DateTime(2026, 9, day),
        ]);
        expect(w.map((d) => d.date.weekday), [1, 2, 3, 4, 5, 6, 7]);
        expect(w.map((d) => d.isToday), [
          false,
          false,
          false,
          false,
          false,
          false,
          true,
        ]);
        expect(
          w.last.minutes,
          snap.readingDay.readMinutes,
        ); // hoje = lidos hoje
      },
    );

    test('para você: motivo Machado de Assis; Esaú e Jacó, Memorial de Aires, Casa de Pensão', () {
      final f = snap.forYou!;
      expect(f.reasonAuthor, 'Machado de Assis');
      expect(
        f.items.map((b) => (b.id, b.title, b.shortTitle, b.author, b.cover)),
        [
          (
            'esau-e-jaco',
            'Esaú e Jacó',
            null,
            'Machado de Assis',
            const DesignedCover(CoverArt.esauEJaco),
          ),
          (
            'memorial-de-aires',
            'Memorial de Aires',
            null,
            'Machado de Assis',
            const DesignedCover(CoverArt.memorialDeAires),
          ),
          (
            'casa-de-pensao',
            'Casa de Pensão',
            null,
            'Aluísio Azevedo',
            const DesignedCover(CoverArt.casaDePensao),
          ),
        ],
      );
    });

    test('clube: "Leitoras de" + "Capitu", Dom Casmurro até o cap. 50, A/J/L, 11, 0,54, 0,62 (M), 3, 24/09 20:00', () {
      final c = snap.club!;
      expect(c.namePrefix, 'Leitoras de');
      expect(c.nameHighlight, 'Capitu');
      expect(c.book, same(HomeMockRepository.domCasmurro));
      expect(c.untilChapter, 50);
      expect(c.shownParticipants.map((p) => (p.initial, p.color.toARGB32())), [
        ('A', 0xFFB6ACE4),
        ('J', 0xFFABCF82),
        ('L', 0xFFFFC1C6),
      ]);
      expect(c.participantsCount, 11);
      expect(c.groupProgress, 0.54);
      expect(c.userProgress, 0.62);
      expect(c.userInitial, 'M');
      expect(c.unreadMessages, 3);
      expect(c.nextMeeting, DateTime(2026, 9, 24, 20));
      expect(c.nextMeeting.weekday, DateTime.thursday);
    });

    test('recém-chegados: Frankenstein EPUB quero ler · O Alienista PDF lido · Senhora papel novo (D-255)', () {
      expect(
        snap.recent.map(
          (r) =>
              (r.book.title, r.book.author, r.format, r.status, r.book.cover),
        ),
        [
          (
            'Frankenstein',
            'Mary Shelley',
            BookFormat.epub,
            RecentStatus.wantToRead,
            const DesignedCover(CoverArt.frankenstein),
          ),
          (
            'O Alienista',
            'Machado de Assis',
            BookFormat.pdf,
            RecentStatus.read,
            const DesignedCover(CoverArt.oAlienista),
          ),
          (
            'Senhora',
            'José de Alencar',
            BookFormat.physical,
            RecentStatus.isNew,
            const DesignedCover(CoverArt.senhora),
          ),
        ],
      );
    });

    test(
      'ids dos livros únicos (destinos /leitor/:bookId e /livro/:bookId)',
      () {
        final books = [
          snap.continueReading!.book,
          ...snap.alsoReading.map((a) => a.book),
          ...snap.forYou!.items,
          ...snap.recent.map((r) => r.book),
        ];
        expect(books, hasLength(10));
        expect(books.map((b) => b.id).toSet(), hasLength(10));
        // as 9 artes da prancha 01, uma por livro desenhado; o 3º livro do Também lendo (fora da grade) tem a capa
        // gerada
        expect(books.map((b) => b.cover).toSet(), {
          for (final a in CoverArt.values) DesignedCover(a),
          const PhotoCover(),
        });
      },
    );

    test('listas do snapshot são imutáveis', () {
      expect(
        () => snap.readingDay.week.add(snap.readingDay.week.first),
        throwsUnsupportedError,
      );
      expect(() => snap.alsoReading.clear(), throwsUnsupportedError);
      expect(() => snap.forYou!.items.clear(), throwsUnsupportedError);
      expect(
        () => snap.club!.shownParticipants.clear(),
        throwsUnsupportedError,
      );
      expect(() => snap.recent.clear(), throwsUnsupportedError);
    });

    // Conferência com a fonte da verdade nº 1: alturas das barras e cores dos avatares no HTML da prancha 01.
    test('alturas das barras e cores dos avatares = HTML da prancha 01', () {
      final html = htmlDaPrancha01();
      final bars = RegExp(
        r'height: (\d+)px; background: (?:\{\{weekColor\}\}|#FF552E); border-top: 1\.5px solid #1A1714',
      ).allMatches(html).map((m) => double.parse(m.group(1)!)).toList();
      expect(bars, snap.readingDay.week.map((d) => d.barHeightPx).toList());
      final avatars =
          RegExp(
                r'background: #([0-9A-F]{6}); border: 1\.5px solid #1A1714; box-sizing: border-box; display: flex; '
                r'align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">([AJL])<',
              )
              .allMatches(html)
              .map(
                (m) => (
                  m.group(2),
                  0xFF000000 | int.parse(m.group(1)!, radix: 16),
                ),
              )
              .toList();
      expect(
        avatars,
        snap.club!.shownParticipants
            .map((p) => (p.initial, p.color.toARGB32()))
            .toList(),
      );
    });
  });
}
