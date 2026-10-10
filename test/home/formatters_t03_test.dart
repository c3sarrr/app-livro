import 'dart:io';

import 'package:app_leitura/features/home/application/formatters.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// O HTML literal das seções da prancha 01 (as fases L01a1…L01a9, geradas da extração na T02).
String _htmlDaPrancha01() {
  final html = StringBuffer();
  final fases =
      Directory('docs/design/fases')
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'L01a\d_[^/\\]+\.md$').hasMatch(f.path))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (fases.length != 9) {
    throw StateError('as fases L01a1…L01a9: ${fases.length}');
  }
  for (final f in fases) {
    final m = RegExp(
      r'```html\n(.*?)\n```',
      dotAll: true,
    ).firstMatch(f.readAsStringSync().replaceAll('\r\n', '\n'));
    html.writeln(m!.group(1));
  }
  return html.toString();
}

const Book _brasCubas = Book(
  id: 'memorias-postumas-de-bras-cubas',
  title: 'Memórias Póstumas de Brás Cubas',
  shortTitle: 'Brás Cubas',
  author: 'Machado de Assis',
  cover: PhotoCover(),
);

/// T03 — os textos novos da Início 01 (D-252…D-255 e as fases L01a1…L01a8).
void main() {
  group('T03 (prancha 01)', () {
    test('pageLabel(159, 256) → "pág. 159 de 256" (D-254)', () {
      expect(HomeFormatters.pageLabel(159, 256), 'pág. 159 de 256');
      expect(HomeFormatters.pageLabel(1, 1), 'pág. 1 de 1');
    });

    test('formatBadge: EPUB "E-BOOK" · PDF "PDF" · físico "PAPEL" (D-254)', () {
      expect(HomeFormatters.formatBadge(BookFormat.epub), 'E-BOOK');
      expect(HomeFormatters.formatBadge(BookFormat.pdf), 'PDF');
      expect(HomeFormatters.formatBadge(BookFormat.physical), 'PAPEL');
    });

    test('paperMeta: página, tempo já lido ou só "Papel" (D-252, D-253)', () {
      expect(HomeFormatters.paperMeta(page: 344), 'Papel · pág. 344');
      expect(
        HomeFormatters.paperMeta(readTime: const Duration(minutes: 220)),
        'Papel · 3h 40min',
      );
      // a página vale mais que o tempo (o cartão com página tem o anel)
      expect(
        HomeFormatters.paperMeta(
          page: 12,
          readTime: const Duration(minutes: 220),
        ),
        'Papel · pág. 12',
      );
      expect(
        HomeFormatters.paperMeta(readTime: const Duration(seconds: 59)),
        'Papel · 0h 00min',
      );
      expect(HomeFormatters.paperMeta(), 'Papel');
    });

    test('sessões de hoje: "2 sessões" · "1 sessão" · "0 sessões"', () {
      expect(HomeFormatters.sessionsLabel(2), '2 sessões');
      expect(HomeFormatters.sessionsLabel(1), '1 sessão');
      expect(HomeFormatters.sessionsLabel(0), '0 sessões');
    });

    test(
      'reviewKicker(5, 2) → "REVISÃO · 5 GRIFOS · 2 MIN" (singular para 1)',
      () {
        expect(HomeFormatters.reviewKicker(5, 2), 'REVISÃO · 5 GRIFOS · 2 MIN');
        expect(HomeFormatters.reviewKicker(1, 1), 'REVISÃO · 1 GRIFO · 1 MIN');
      },
    );

    test('reviewSubtitle: "De A.", "De A e B.", "De A, B e C."', () {
      expect(
        HomeFormatters.reviewSubtitle(['Dom Casmurro']),
        'De Dom Casmurro.',
      );
      expect(
        HomeFormatters.reviewSubtitle(['Dom Casmurro', 'Iracema']),
        'De Dom Casmurro e Iracema.',
      );
      expect(
        HomeFormatters.reviewSubtitle([
          'Dom Casmurro',
          'Quincas Borba',
          'Iracema',
        ]),
        'De Dom Casmurro, Quincas Borba e Iracema.',
      );
      expect(
        () => HomeFormatters.reviewSubtitle(const []),
        throwsA(isA<AssertionError>()),
      );
    });

    test('recentStatusLabel(read) → "Lido"; formatLabel(physical) → "Papel" (D-255)', () {
      expect(HomeFormatters.recentStatusLabel(RecentStatus.read), 'Lido');
      expect(HomeFormatters.formatLabel(BookFormat.physical), 'Papel');
      expect(
        HomeFormatters.recentSubtitle(
          const RecentItem(
            book: Book(
              id: 'senhora',
              title: 'Senhora',
              author: 'José de Alencar',
              cover: PhotoCover(),
            ),
            format: BookFormat.physical,
            status: RecentStatus.isNew,
          ),
        ),
        'José de Alencar · Papel',
      );
    });

    test('rótulos de acessibilidade novos', () {
      expect(HomeFormatters.searchAria, 'Buscar livros');
      expect(HomeFormatters.readNowAria, 'Iniciar leitura (cronômetro)');
      expect(
        HomeFormatters.startReadingAria(_brasCubas),
        'Iniciar leitura de Brás Cubas',
      );
      expect(HomeFormatters.bookTitleShort(_brasCubas), 'Brás Cubas');
      expect(
        HomeFormatters.bookTitleShort(
          const Book(
            id: 'x',
            title: 'Orgulho e Preconceito',
            author: 'Jane Austen',
            cover: PhotoCover(),
          ),
        ),
        'Orgulho e Preconceito',
      );
    });
  });

  // Fonte da verdade nº 1 (prompt mestre §2): cada saída aparece literalmente na prancha 01.
  group('as saídas aparecem literalmente na prancha 01', () {
    final html = _htmlDaPrancha01();
    String node(String text) => '>$text<';
    String aria(String label) => 'aria-label="$label"';

    test('textos visíveis', () {
      for (final text in [
        HomeFormatters.pageLabel(159, 256),
        HomeFormatters.formatBadge(BookFormat.epub),
        HomeFormatters.sessionsLabel(2),
        HomeFormatters.reviewKicker(5, 2),
        HomeFormatters.reviewSubtitle([
          'Dom Casmurro',
          'Quincas Borba',
          'Iracema',
        ]),
        HomeFormatters.recentStatusLabel(RecentStatus.read),
        HomeFormatters.bookTitleShort(_brasCubas),
      ]) {
        expect(html.contains(node(text)), isTrue, reason: text);
      }
      // a pílula do papel tem o ícone antes do texto (`…</svg>Papel · 3h 40min</span>`)
      for (final text in [
        HomeFormatters.paperMeta(readTime: const Duration(minutes: 220)),
        HomeFormatters.paperMeta(page: 344),
      ]) {
        expect(html.contains('</svg>$text</span>'), isTrue, reason: text);
      }
      expect(
        html.contains(
          node(
            HomeFormatters.recentSubtitle(
              const RecentItem(
                book: Book(
                  id: 'senhora',
                  title: 'Senhora',
                  author: 'José de Alencar',
                  cover: PhotoCover(),
                ),
                format: BookFormat.physical,
                status: RecentStatus.isNew,
              ),
            ),
          ),
        ),
        isTrue,
      );
    });

    test('aria-labels', () {
      for (final label in [
        HomeFormatters.searchAria,
        HomeFormatters.readNowAria,
        HomeFormatters.startReadingAria(_brasCubas),
        _brasCubas.title,
      ]) {
        expect(html.contains(aria(label)), isTrue, reason: label);
      }
    });
  });
}
