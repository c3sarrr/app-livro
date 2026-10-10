// T03 (D-241) — o mundo de referência gravado no banco, lido pela fonte real da Início, comparado com a fixture da
// prancha 01 (`t01`): o que bate e, uma a uma, as diferenças (o que a prancha desenhou que o mundo do leitor não tem
// e o que vem de fora do banco). Substitui a lista da D-60 (prancha da v1).
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/features/home/data/local_home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/inicio01.dart';
import '../fixtures/telas/t20.dart';

typedef _Cartao = (
  String,
  BookFormat,
  int? paperPage,
  Duration? readTime,
  double progress,
);

List<_Cartao> _cartoes(List<AlsoReadingItem> a) => [
  for (final x in a)
    (x.book.title, x.format, x.paperPage, x.readTime, x.progress),
];

/// Os dois lados de uma diferença (mundo, prancha), para comparar listas por conteúdo.
List<Object?> _lados(Object? par) {
  final (a, b) = par! as (Object?, Object?);
  return [a, b];
}

bool _iguais<T>(Iterable<T> a, Iterable<T> b) {
  final x = a.toList();
  final y = b.toList();
  if (x.length != y.length) return false;
  for (var i = 0; i < x.length; i++) {
    if (x[i] != y[i]) return false;
  }
  return true;
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false));
  tearDown(() => db.close());

  test('t01 × mundo no banco: o que bate e as diferenças, uma a uma (D-241)', () async {
    final m = mundoReferencia;
    await m.gravarEm(db);
    final s = await LocalHomeRepository(
      database: () async => db,
      owner: () async => m.usuarioId,
      utcOffsetAt: (_) => m.fuso,
    ).read(m.agora);
    final p = TelaInicio01.snapshot(TelaInicio01.agora);

    // ---- o que bate (os números do leitor e do clube — D-241) ----
    final h = s.continueReading!;
    final ph = p.continueReading!;
    expect(
      (h.book.title, h.book.author, h.format, h.refPage, h.refPagesTotal),
      (ph.book.title, ph.book.author, ph.format, ph.refPage, ph.refPagesTotal),
    );
    expect((h.refPage, h.refPagesTotal), (159, 256), reason: 'pág. 159 de 256');
    expect(h.highlightsCount, ph.highlightsCount);
    expect(
      h.highlightsCount,
      t20.contagens.all,
      reason: '12, o número do leitor',
    );
    expect((h.progress * 100).round(), (ph.progress * 100).round());
    final d = s.readingDay;
    final pd = p.readingDay;
    expect(
      (d.readMinutes, d.streakDays, d.goalMinutes, d.badgeTargetDays),
      (pd.readMinutes, pd.streakDays, pd.goalMinutes, pd.badgeTargetDays),
    );
    expect((d.readMinutes, d.streakDays), (18, 12));
    expect(
      d.week.map((w) => (w.date, w.minutes, w.isToday)),
      pd.week.map((w) => (w.date, w.minutes, w.isToday)),
    );
    expect(
      s.recent.map((r) => (r.book.title, r.book.author)),
      p.recent.map((r) => (r.book.title, r.book.author)),
    );
    expect(p.club!.untilChapter, m.clube.metaCapitulo, reason: 'até o cap. 50');
    expect(s.now, p.now);

    // ---- as diferenças ----
    final diferencas = <String, Object?>{
      if (d.highlightsToday != pd.highlightsToday)
        'grifos hoje (a D-60 continua: o mundo tem 1 grifo e 4 itens de tinta)':
            (d.highlightsToday, pd.highlightsToday),
      if (d.sessionsToday != pd.sessionsToday)
        'sessões hoje (o mundo tem uma sessão de 18 min)': (
          d.sessionsToday,
          pd.sessionsToday,
        ),
      if (h.progress != ph.progress)
        'progresso (a prancha arredonda a 2 casas)': (h.progress, ph.progress),
      if (h.timeLeft != ph.timeLeft)
        'tempo restante (o arquivo escreve; a regra é a velocidade pessoal — D-97)':
            (h.timeLeft, ph.timeLeft),
      if (!_iguais(
        d.week.map((w) => w.barHeightPx),
        pd.week.map((w) => w.barHeightPx),
      ))
        'alturas das barras (D-10: arquivo × regra)': true,
      if (!_iguais(_cartoes(s.alsoReading), _cartoes(p.alsoReading)))
        'Também lendo (a 01 tem o Brás Cubas e o Orgulho em papel)': (
          _cartoes(s.alsoReading),
          _cartoes(p.alsoReading),
        ),
      if (!_iguais(
        s.recent.map((r) => r.status),
        p.recent.map((r) => r.status),
      ))
        'recém-chegados: situação ("Novo" da D-88 × "Quero ler" e "Lido" da 01)':
            (
              [for (final r in s.recent) r.status],
              [for (final r in p.recent) r.status],
            ),
      if (!_iguais(
        s.recent.map((r) => r.format),
        p.recent.map((r) => r.format),
      ))
        'recém-chegados: formato (a Senhora em papel na 01)': (
          [for (final r in s.recent) r.format],
          [for (final r in p.recent) r.format],
        ),
      if (s.dailyReview != p.dailyReview)
        'revisão do dia (D-247: só a fixture até a T05)': (
          s.dailyReview,
          p.dailyReview,
        ),
      if (s.forYou == null || s.club == null)
        'Para você e clube (fontes injetadas, fora do banco do leitor — G21)': (
          s.forYou,
          s.club,
        ),
      if (s.user.firstName != p.user.firstName)
        'usuário (vem da conta — D-84)': (s.user.firstName, p.user.firstName),
    };
    expect(diferencas.keys, [
      'grifos hoje (a D-60 continua: o mundo tem 1 grifo e 4 itens de tinta)',
      'sessões hoje (o mundo tem uma sessão de 18 min)',
      'progresso (a prancha arredonda a 2 casas)',
      'tempo restante (o arquivo escreve; a regra é a velocidade pessoal — D-97)',
      'alturas das barras (D-10: arquivo × regra)',
      'Também lendo (a 01 tem o Brás Cubas e o Orgulho em papel)',
      'recém-chegados: situação ("Novo" da D-88 × "Quero ler" e "Lido" da 01)',
      'recém-chegados: formato (a Senhora em papel na 01)',
      'revisão do dia (D-247: só a fixture até a T05)',
      'Para você e clube (fontes injetadas, fora do banco do leitor — G21)',
      'usuário (vem da conta — D-84)',
    ]);
    expect(
      diferencas['grifos hoje (a D-60 continua: o mundo tem 1 grifo e 4 itens de tinta)'],
      (1, 2),
    );
    expect(diferencas['sessões hoje (o mundo tem uma sessão de 18 min)'], (
      1,
      2,
    ));
    // 256 × 1.500 × (1 − 0,62113) ≈ 145 mil caracteres ÷ ≈ 2.000 car./min das sessões do mundo ≈ 70 min
    expect(
      diferencas['tempo restante (o arquivo escreve; a regra é a velocidade pessoal — D-97)'],
      (const Duration(minutes: 70), const Duration(hours: 2, minutes: 10)),
    );
    expect(
      _lados(
        diferencas['Também lendo (a 01 tem o Brás Cubas e o Orgulho em papel)'],
      ),
      [
        <_Cartao>[
          ('Mrs. Dalloway', BookFormat.epub, null, null, 0.34),
          ('Orgulho e Preconceito', BookFormat.epub, null, null, 0.81),
        ],
        <_Cartao>[
          (
            'Memórias Póstumas de Brás Cubas',
            BookFormat.physical,
            null,
            const Duration(hours: 3, minutes: 40),
            0.0,
          ),
          ('Orgulho e Preconceito', BookFormat.physical, 344, null, 0.81),
          ('Mrs. Dalloway', BookFormat.epub, null, null, 0.34),
        ],
      ],
    );
    expect(
      _lados(
        diferencas['recém-chegados: situação ("Novo" da D-88 × "Quero ler" e "Lido" da 01)'],
      ),
      [
        [RecentStatus.isNew, RecentStatus.isNew, RecentStatus.isNew],
        [RecentStatus.wantToRead, RecentStatus.read, RecentStatus.isNew],
      ],
    );
    expect(
      _lados(diferencas['recém-chegados: formato (a Senhora em papel na 01)']),
      [
        [BookFormat.epub, BookFormat.pdf, BookFormat.epub],
        [BookFormat.epub, BookFormat.pdf, BookFormat.physical],
      ],
    );
  });

  test('a fixture é a mesma a cada chamada e a 60 é a 01 (D-241)', () {
    final a = TelaInicio01.snapshot(TelaInicio01.agora);
    final b = TelaInicio01.snapshot(TelaInicio01.agora);
    expect(identical(a.continueReading, b.continueReading), isTrue);
    expect(identical(a.alsoReading, b.alsoReading), isTrue);
    expect(identical(a.dailyReview, b.dailyReview), isTrue);
    expect(
      a.alsoReading,
      hasLength(3),
      reason: 'o contador "3"; a grade mostra 2',
    );
    expect(a.forYou!.items.map((b) => b.title), [
      'Esaú e Jacó',
      'Memorial de Aires',
      'Casa de Pensão',
    ]);
  });
}
