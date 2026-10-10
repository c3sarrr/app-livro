// T04.1 — "Ler agora" (`today.readNow`, "Iniciar leitura (cronômetro)"): D-258 e R11 da spec docs/progresso/T04.md.
import 'package:app_leitura/features/home/application/read_now.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:flutter_test/flutter_test.dart';

Book _livro(String n) => Book(
  id: '01925a00-0000-7000-8000-0000000000$n',
  title: 'Livro $n',
  author: 'Autor',
  cover: const PhotoCover(),
);

ContinueReading _heroi(Book b, BookFormat f) =>
    ContinueReading(book: b, progress: 0.5, highlightsCount: 0, format: f);

AlsoReadingItem _tambem(Book b, BookFormat f) =>
    AlsoReadingItem(book: b, progress: 0.2, format: f);

final _t0 = DateTime.utc(2026, 9, 20, 22, 51, 18);

OpenPaperSession _sessao(Book b) => OpenPaperSession.start(
  id: '01925a00-0000-7000-8000-000000000001',
  userBookId: b.id,
  now: _t0,
);

void main() {
  final a = _livro('a1');
  final b = _livro('b2');
  final c = _livro('c3');
  final d = _livro('d4');

  test('sessão pausada: retoma — de qualquer livro', () {
    expect(
      readNowAction(
        hero: _heroi(a, BookFormat.epub),
        alsoReading: [_tambem(b, BookFormat.physical)],
        open: _sessao(c).pause(_t0.add(const Duration(minutes: 1))),
      ),
      const ResumeSession(),
    );
  });

  test('sessão rodando: nada', () {
    expect(
      readNowAction(
        hero: _heroi(a, BookFormat.physical),
        alsoReading: const [],
        open: _sessao(a),
      ),
      const KeepRunning(),
    );
  });

  test('sem sessão e herói de papel: o cronômetro do herói', () {
    expect(
      readNowAction(
        hero: _heroi(a, BookFormat.physical),
        alsoReading: [_tambem(b, BookFormat.physical)],
        open: null,
      ),
      StartTimer(a),
    );
  });

  test('herói e-book: o 1º de papel do Também lendo, na ordem — a prancha 01 começa o Brás Cubas', () {
    expect(
      readNowAction(
        hero: _heroi(a, BookFormat.epub),
        alsoReading: [
          _tambem(b, BookFormat.epub),
          _tambem(c, BookFormat.physical),
          _tambem(d, BookFormat.physical),
        ],
        open: null,
      ),
      StartTimer(c),
    );
  });

  test('o 1º de papel pode estar além dos 2 cartões da grade', () {
    expect(
      readNowAction(
        hero: _heroi(a, BookFormat.pdf),
        alsoReading: [
          _tambem(b, BookFormat.epub),
          _tambem(c, BookFormat.pdf),
          _tambem(d, BookFormat.physical),
        ],
        open: null,
      ),
      StartTimer(d),
    );
  });

  test('nenhum livro de papel em leitura: abre o herói no leitor (o e-book conta sozinho)', () {
    expect(
      readNowAction(
        hero: _heroi(a, BookFormat.pdf),
        alsoReading: [_tambem(b, BookFormat.epub)],
        open: null,
      ),
      OpenReader(a),
    );
  });

  test('nada em leitura: sem ação (R11)', () {
    expect(
      readNowAction(hero: null, alsoReading: const [], open: null),
      const NoAction(),
    );
  });

  test('as ações se comparam por valor', () {
    expect(StartTimer(a), StartTimer(a));
    expect(StartTimer(a).hashCode, StartTimer(a).hashCode);
    expect(StartTimer(a), isNot(StartTimer(b)));
    expect(OpenReader(a), isNot(StartTimer(a)));
    expect(OpenReader(a).hashCode, OpenReader(a).hashCode);
  });
}
