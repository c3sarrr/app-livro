// G08.1 — modelo da Início com dados reais: seções que podem faltar (D-78), capa desenhada × foto (D-79),
// exemplar físico (D-85), convidado sem nome (D-84) e as frases de concluído (D-83).
import 'package:app_leitura/features/home/application/formatters.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _semFoto = Book(
  id: 'b1',
  title: 'A hora da estrela',
  author: 'Clarice Lispector',
  cover: PhotoCover(),
);

ReadingDay _dia({int lidos = 0, int meta = 30, int seq = 0, int selo = 7}) =>
    ReadingDay(
      goalMinutes: meta,
      readMinutes: lidos,
      streakDays: seq,
      highlightsToday: 0,
      sessionsToday: 0,
      week: const [],
      badgeTargetDays: selo,
    );

void main() {
  group('capa (D-79)', () {
    test('a arte desenhada e a foto comparam pelo valor', () {
      expect(
        const DesignedCover(CoverArt.senhora),
        const DesignedCover(CoverArt.senhora),
      );
      expect(
        const DesignedCover(CoverArt.senhora),
        isNot(const DesignedCover(CoverArt.frankenstein)),
      );
      expect(
        const PhotoCover(ref: 'ol:123', isbn13: '9788535914849'),
        const PhotoCover(ref: 'ol:123', isbn13: '9788535914849'),
      );
      expect(
        const PhotoCover(ref: 'ol:123'),
        isNot(const PhotoCover(ref: 'ol:124')),
      );
      expect(
        const PhotoCover(ref: 'ol:1').hashCode,
        const PhotoCover(ref: 'ol:1').hashCode,
      );
    });

    test(
      'uma foto sem ref nem ISBN é válida (a capa gerada usa título e autor)',
      () {
        expect(_semFoto.cover, const PhotoCover());
        expect((_semFoto.cover as PhotoCover).ref, isNull);
        expect((_semFoto.cover as PhotoCover).isbn13, isNull);
      },
    );
  });

  group('instantâneo sem dados (D-78)', () {
    test(
      'as seções opcionais podem faltar e o Dia de leitura existe sempre',
      () {
        final s = HomeSnapshot(
          now: DateTime(2026, 10, 5, 20),
          user: const UserSummary(unreadNotifications: 0),
          continueReading: null,
          alsoReading: const [],
          readingDay: _dia(),
          dailyReview: null,
          forYou: null,
          club: null,
          recent: const [],
          shelfIsEmpty: true,
        );
        expect(s.continueReading, isNull);
        expect(s.forYou, isNull);
        expect(s.club, isNull);
        expect(s.shelfIsEmpty, isTrue);
        expect(s.user.firstName, isNull);
        expect(s.user.initial, isNull);
      },
    );

    test('estante com livros por padrão (o caminho da fixture não muda)', () {
      final s = HomeSnapshot(
        now: DateTime(2026, 10, 5, 20),
        user: const UserSummary(unreadNotifications: 0),
        continueReading: null,
        alsoReading: const [],
        readingDay: _dia(),
        dailyReview: null,
        forYou: null,
        club: null,
        recent: const [],
      );
      expect(s.shelfIsEmpty, isFalse);
    });

    test('livro em leitura sem página de referência nem estimativa (PDF; sem sessões) — a pílula "pág." some (D-254)', () {
      const c = ContinueReading(
        book: _semFoto,
        progress: 0.4,
        highlightsCount: 0,
      );
      expect(c.refPage, isNull);
      expect(c.refPagesTotal, isNull);
      expect(c.format, BookFormat.epub);
      expect(c.timeLeft, isNull);
    });
  });

  group('textos novos', () {
    test('livro de papel: "Papel" (D-85; nome da prancha 01 — D-255)', () {
      expect(HomeFormatters.formatLabel(BookFormat.physical), 'Papel');
      expect(
        HomeFormatters.recentSubtitle(
          const RecentItem(
            book: _semFoto,
            format: BookFormat.physical,
            status: RecentStatus.wantToRead,
          ),
        ),
        'Clarice Lispector · Papel',
      );
    });

    test('convidado: saudação sem vírgula (D-84)', () {
      expect(HomeFormatters.greeting(DateTime(2026, 10, 5, 8)), 'Bom dia,');
      expect(
        HomeFormatters.greeting(DateTime(2026, 10, 5, 8), named: false),
        'Bom dia',
      );
      expect(
        HomeFormatters.greeting(DateTime(2026, 10, 5, 14), named: false),
        'Boa tarde',
      );
      expect(
        HomeFormatters.greeting(DateTime(2026, 10, 5, 23), named: false),
        'Boa noite',
      );
    });

    test('meta batida: "Meta de hoje cumprida." (D-83)', () {
      expect(HomeFormatters.remainingGoal(30, 18), (
        before: 'Faltam ',
        strong: '12 min',
        after: ' para fechar a meta de hoje.',
      ));
      for (final lidos in [30, 31, 90]) {
        expect(HomeFormatters.remainingGoal(30, lidos), (
          before: 'Meta de hoje cumprida.',
          strong: '',
          after: '',
        ), reason: '$lidos min');
      }
    });

    test('selo alcançado: "Selo de N dias conquistado" (D-83)', () {
      expect(HomeFormatters.badgeHint(12, 14), (
        before: 'Mais ',
        strong: '2 dias',
        after: ' para o selo de 14 dias',
      ));
      expect(HomeFormatters.badgeHint(0, 7), (
        before: 'Mais ',
        strong: '7 dias',
        after: ' para o selo de 7 dias',
      ));
      for (final seq in [7, 8, 40]) {
        expect(HomeFormatters.badgeHint(seq, 7), (
          before: 'Selo de ',
          strong: '7 dias',
          after: ' conquistado',
        ), reason: '$seq dias');
      }
      expect(HomeFormatters.badgeHint(1, 1), (
        before: 'Selo de ',
        strong: '1 dia',
        after: ' conquistado',
      ));
    });

    test('sininho sem novidades: só "Notificações"', () {
      expect(HomeFormatters.notificationsAria(0), 'Notificações');
      expect(HomeFormatters.notificationsAria(2), 'Notificações, 2 novas');
    });
  });
}
