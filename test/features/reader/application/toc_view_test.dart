// G15.2 — tudo o que a folha do sumário mostra (telas 27/27b), a partir dos dados: linhas (partes — D-153 —,
// capítulos com numeral — D-150 —, página, marcas — Anexo 02 §4.2, "1 marca" —, "lido", atual e anel), a faixa do
// clube (D-149), os cartões das Marcadas (D-152) e as datas no fuso; EPUB e PDF; sem sumário (D-21).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation_stats.dart';
import 'package:app_leitura/features/reader/application/reader_club_source.dart';
import 'package:app_leitura/features/reader/application/toc_view.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/domain/bookmark.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

const Duration _sp = Duration(hours: -3);
Duration _fuso(DateTime _) => _sp;

/// 20/09 22:00 em São Paulo.
final DateTime _agora = DateTime.utc(2026, 9, 21, 1);
final String _livro = idTeste(1);

BookIndex _indice({List<TocPoint>? toc}) => BookIndex(
  contentSha256: 'a' * 64,
  layout: 'reflowable',
  spine: const [
    SpineInfo(path: 'a', linear: true, chars: 3000),
    SpineInfo(path: 'b', linear: true, chars: 3000),
    SpineInfo(path: 'c', linear: true, chars: 3000),
  ],
  toc:
      toc ??
      const [
        TocPoint(title: 'Parte I', spine: 0, offset: 0, depth: 0, leaf: false),
        TocPoint(title: 'I. Um', spine: 0, offset: 0, depth: 1, leaf: true),
        TocPoint(title: 'II. Dois.', spine: 1, offset: 0, depth: 1, leaf: true),
        TocPoint(title: 'Sem lugar', depth: 1, leaf: true),
        TocPoint(title: 'III. Três', spine: 2, offset: 0, depth: 1, leaf: true),
      ],
  refPages: RefPageMap.synthetic(const [0, 1500, 3000, 4500, 6000, 7500]),
);

Annotation _nota(
  int n,
  int capitulo,
  AnnotationKind kind, {
  String? cor,
  bool apagada = false,
}) => Annotation(
  id: idTeste(n),
  meta: metaTeste(apagado: apagada),
  userBookId: _livro,
  kind: kind,
  groupId: idTeste(n),
  anchor: ancoraTeste(inicio: n),
  refPage: 1 + capitulo,
  chapterIndex: capitulo,
  color: cor,
  style: kind == AnnotationKind.highlight ? HighlightStyle.fill : null,
  fillHeight: kind == AnnotationKind.highlight ? FillHeight.medium : null,
  noteText: kind == AnnotationKind.note ? 'nota' : null,
  inkLayerId:
      kind == AnnotationKind.drawing || kind == AnnotationKind.handwriting
      ? idTeste(900 + n)
      : null,
);

Bookmark _marca(
  int n, {
  required int pagina,
  int capitulo = 0,
  required DateTime em,
  Locator? onde,
  String? excerto = 'Uma noite destas…',
}) => Bookmark(
  id: idTeste(n),
  meta: RecordMeta(
    userId: usuarioTeste,
    createdAt: em,
    updatedAt: em,
    version: Hlc(em.millisecondsSinceEpoch, 0, 'aparelhoA'),
  ),
  userBookId: _livro,
  locator:
      onde ??
      EpubLocator(
        sha: shaTeste,
        spine: 1,
        offset: n,
        refPage: pagina,
        progression: 0.1,
      ),
  refPage: pagina,
  chapterIndex: capitulo,
  excerpt: excerto,
);

TocView _view({
  BookIndex? index,
  bool semIndice = false,
  ({int spine, int offset}) at = (spine: 1, offset: 750),
  int refPage = 3,
  List<Annotation> notas = const [],
  List<Bookmark> marcas = const [],
  List<Bookmark> tiradas = const [],
  ReaderClubGoal? clube,
}) => buildTocView(
  bookTitle: 'Livro',
  index: semIndice ? null : index ?? _indice(),
  at: at,
  refPage: refPage,
  annotations: notas,
  bookmarks: marcas,
  removed: tiradas,
  club: clube,
  now: _agora,
  utcOffsetAt: _fuso,
);

void main() {
  group('linhas', () {
    test('parte, capítulos com numeral, página, lido, atual com o anel, entrada sem lugar', () {
      final v = _view();
      expect(v.subtitle, 'Livro · 4 capítulos');
      expect(v.chapters, 4);
      expect(v.rows.map((r) => r.kind), [
        TocRowKind.part,
        TocRowKind.chapter,
        TocRowKind.chapter,
        TocRowKind.chapter,
        TocRowKind.chapter,
      ]);
      final [parte, um, dois, semLugar, tres] = v.rows;
      expect(parte.title, 'PARTE I');
      expect(parte.page, isNull);
      expect(parte.chapter, isNull);
      expect(parte.read, isFalse);
      expect(parte.target, (spine: 0, offset: 0));
      expect((um.numeral, um.title, um.page, um.chapter), ('I', 'Um', 1, 0));
      expect((dois.numeral, dois.title, dois.page), ('II', 'Dois', 3));
      expect((tres.numeral, tres.title, tres.page), ('III', 'Três', 5));
      expect(um.read, isTrue);
      expect(um.current, isFalse);
      expect(dois.current, isTrue);
      expect(dois.read, isFalse);
      expect(dois.progress, closeTo(0.25, 1e-9));
      expect(dois.target, (spine: 1, offset: 0));
      expect(semLugar.page, isNull);
      expect(semLugar.target, isNull);
      expect(semLugar.read, isFalse);
      expect(semLugar.numeral, isNull);
      expect(tres.read, isFalse);
      expect(tres.current, isFalse);
      expect(v.currentRow, 2);
      expect(v.refPage, 3);
    });

    test('antes do 1º capítulo: nenhum atual, nada lido; no fim do livro: o último atual com o anel cheio', () {
      final antes = _view(
        index: _indice(
          toc: const [
            TocPoint(title: 'I. Um', spine: 1, offset: 0, depth: 0, leaf: true),
            TocPoint(
              title: 'II. Dois',
              spine: 2,
              offset: 0,
              depth: 0,
              leaf: true,
            ),
          ],
        ),
        at: (spine: 0, offset: 10),
      );
      expect(antes.currentRow, isNull);
      expect(antes.rows.any((r) => r.read || r.current), isFalse);
      final fim = _view(at: (spine: 2, offset: 3000));
      expect(fim.currentRow, 4);
      expect(fim.rows[4].progress, 1.0);
      expect(fim.rows[2].read, isTrue);
    });

    test('marcas por capítulo (Anexo 02 §4.2): "1 marca", "3 marcas"; apagada não conta', () {
      final notas = [
        _nota(1, 0, AnnotationKind.highlight, cor: '#FED170'),
        _nota(2, 1, AnnotationKind.highlight, cor: '#B6ACE4'),
        _nota(3, 1, AnnotationKind.note),
        _nota(4, 1, AnnotationKind.drawing, cor: '#FF552E'),
        _nota(5, 3, AnnotationKind.highlight, cor: '#FED170', apagada: true),
      ];
      final v = _view(notas: notas);
      expect(
        v.rows[1].marks,
        AnnotationStats.chapterMarks(notas, chapterIndex: 0),
      );
      expect(v.rows[1].marksLabel, '1 marca');
      expect(v.rows[2].marks.count, 3);
      expect(v.rows[2].marksLabel, '3 marcas');
      expect(v.rows[4].marks.count, 0);
      expect(v.rows[0].marks.count, 0, reason: 'a parte não tem marcas');
    });

    test('"1 capítulo"; sem sumário (D-21): sem linhas, sem número na aba, só o título', () {
      final um = _view(
        index: _indice(
          toc: const [
            TocPoint(title: 'Único', spine: 0, offset: 0, depth: 0, leaf: true),
          ],
        ),
      );
      expect(um.subtitle, 'Livro · 1 capítulo');
      for (final v in [
        _view(index: _indice(toc: const [])),
        _view(semIndice: true),
      ]) {
        expect(v.rows, isEmpty);
        expect(v.chapters, isNull);
        expect(v.subtitle, 'Livro');
        expect(v.currentRow, isNull);
      }
    });

    test(
      'PDF: a estrutura do PDF, páginas do PDF, "lido" e o anel em páginas',
      () {
        final pdf = BookIndex(
          contentSha256: 'a' * 64,
          layout: 'pdf',
          spine: const [],
          toc: const [
            TocPoint(
              title: '1. Capa',
              spine: 0,
              offset: 0,
              depth: 0,
              leaf: true,
            ),
            TocPoint(
              title: 'Cap. 2: Meio',
              spine: 0,
              offset: 4,
              depth: 0,
              leaf: true,
            ),
            TocPoint(title: 'Fora', spine: 0, offset: 99, depth: 0, leaf: true),
          ],
          refPages: RefPageMap.pdf(10),
        );
        final v = _view(index: pdf, at: (spine: 0, offset: 6), refPage: 7);
        expect(v.rows.map((r) => r.page), [1, 5, null]);
        expect(v.rows[0].read, isTrue);
        expect(v.rows[1].current, isTrue);
        expect(v.rows[1].progress, closeTo(2 / 6, 1e-9));
        expect((v.rows[1].numeral, v.rows[1].title), ('2', 'Meio'));
        expect(v.rows[1].target, (spine: 0, offset: 4));
        expect(v.rows[2].target, isNull, reason: 'página fora do PDF');
      },
    );
  });

  group('faixa do clube (D-149)', () {
    ReaderClubGoal clube(int meta, {DateTime? encontro}) =>
        (name: 'Leitoras de Capitu', nextMeeting: encontro, goalChapter: meta);

    test('nome e o próximo encontro no fuso; meta pelo numeral; "falta 1"; na meta e depois, só a meta', () {
      final v = _view(clube: clube(4, encontro: DateTime.utc(2026, 9, 25, 1)));
      // 25/09 01:00 UTC = quinta 24/09 22:00 em São Paulo
      expect(v.club!.kicker, 'LEITORAS DE CAPITU · QUI 24/9');
      expect(v.club!.goal, 'Até o cap. III · faltam 2');
      expect(
        _view(clube: clube(3)).club!.goal,
        'Até o cap. 3 · falta 1',
        reason: 'a meta sem numeral vai em número',
      );
      expect(_view(clube: clube(3)).club!.kicker, 'LEITORAS DE CAPITU');
      expect(_view(clube: clube(2)).club!.goal, 'Até o cap. II');
      expect(_view(clube: clube(1)).club!.goal, 'Até o cap. I');
      expect(_view(clube: clube(9)).club!.goal, 'Até o cap. 9 · faltam 7');
      expect(_view().club, isNull);
    });

    test('antes do 1º capítulo, falta a meta inteira', () {
      final v = _view(
        index: _indice(
          toc: const [
            TocPoint(title: 'I. Um', spine: 1, offset: 0, depth: 0, leaf: true),
            TocPoint(
              title: 'II. Dois',
              spine: 2,
              offset: 0,
              depth: 0,
              leaf: true,
            ),
          ],
        ),
        at: (spine: 0, offset: 0),
        clube: clube(2),
      );
      expect(v.club!.goal, 'Até o cap. II · faltam 2');
    });
  });

  group('Marcadas (D-152)', () {
    test('ordem do livro, capítulo, "você está aqui", datas no fuso, sem excerto, alvos', () {
      final hoje = _marca(
        1,
        pagina: 3,
        capitulo: 1,
        em: DateTime.utc(2026, 9, 20, 4),
      );
      final setembro = _marca(
        2,
        pagina: 1,
        capitulo: 0,
        em: DateTime.utc(2026, 9, 2, 15),
      );
      final anoPassado = _marca(
        3,
        pagina: 5,
        capitulo: 2,
        em: DateTime.utc(2025, 9, 2, 15),
        onde: PdfLocator(sha: shaTeste, page: 4, refPage: 5, progression: 0.5),
      );
      final ontemLocal = _marca(
        4,
        pagina: 5,
        capitulo: 9,
        em: DateTime.utc(2026, 9, 20, 2),
        excerto: null,
        onde: RawLocator(const {'v': 9}),
      );
      final v = _view(marcas: [hoje, setembro, anoPassado, ontemLocal]);
      expect(v.bookmarks, 4);
      expect(v.cards.map((c) => c.bookmark.id), [
        setembro.id,
        hoje.id,
        anoPassado.id,
        ontemLocal.id,
      ]);
      final [c1, c2, c3, c4] = v.cards;
      expect(
        (c1.page, c1.chapter, c1.here, c1.date),
        (1, 'cap. I · Um', false, 'marcada em 2 set'),
      );
      expect(
        (c2.page, c2.chapter, c2.here, c2.date),
        (3, 'cap. II · Dois', true, 'marcada hoje'),
      );
      expect((c3.chapter, c3.date), ('Sem lugar', 'marcada em 2 set 2025'));
      // 20/09 02:00 UTC = 19/09 23:00 em São Paulo
      expect(
        (c4.chapter, c4.date, c4.excerpt),
        (null, 'marcada em 19 set', null),
      );
      expect(c1.excerpt, 'Uma noite destas…');
      expect(c1.target, (spine: 1, offset: 2));
      expect(c3.target, (spine: 0, offset: 4));
      expect(c4.target, isNull);
      expect(v.cards.every((c) => c.marked), isTrue);
    });

    test('a tirada nesta abertura fica com a fita vazia; a viva vence a tirada; o contador conta só as vivas', () {
      final viva = _marca(1, pagina: 3, em: DateTime.utc(2026, 9, 2, 15));
      final tirada = _marca(2, pagina: 1, em: DateTime.utc(2026, 9, 3, 15));
      final v = _view(marcas: [viva], tiradas: [tirada, viva]);
      expect(v.bookmarks, 1);
      expect(v.cards.map((c) => (c.bookmark.id, c.marked)), [
        (tirada.id, false),
        (viva.id, true),
      ]);
    });

    test('sem marcadores: nenhum cartão', () {
      expect(_view().cards, isEmpty);
      expect(_view().bookmarks, 0);
    });
  });
}
