// T03 · pendência 5 — a Início só reconstrói a seção cujo recorte do instantâneo mudou. O banco entrega um instantâneo
// novo a cada leitura (objetos novos, mesmo com o mesmo conteúdo); com o `==` dos modelos e o `HomeSnapshot.reusing`
// no controlador, um instantâneo igual não reconstrói nada, e um que muda só o "Seu dia" reconstrói só o "Seu dia".
// A contagem vem do gancho de depuração do Flutter (`debugOnRebuildDirtyWidget`), que vê cada widget reconstruído.
import 'dart:async';

import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/also_reading_section.dart';
import 'package:app_leitura/features/home/presentation/sections/book_club_ticket.dart';
import 'package:app_leitura/features/home/presentation/sections/for_you_section.dart';
import 'package:app_leitura/features/home/presentation/sections/header_section.dart';
import 'package:app_leitura/features/home/presentation/sections/headline_section.dart';
import 'package:app_leitura/features/home/presentation/sections/hero_section.dart';
import 'package:app_leitura/features/home/presentation/sections/recently_added_section.dart';
import 'package:app_leitura/features/home/presentation/sections/review_section.dart';
import 'package:app_leitura/features/home/presentation/sections/today_section.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/inicio01.dart';
import '../support/copia_inicio.dart';
import '../support/fase_inicio.dart';
import '../support/load_fonts.dart';

/// As 9 seções do conteúdo.
const _secoes = {
  HeaderSection,
  HeadlineSection,
  HeroSection,
  AlsoReadingSection,
  TodaySection,
  ReviewSection,
  ForYouSection,
  BookClubTicket,
  RecentlyAddedSection,
};

/// A fixture `t01` como primeira leitura e um canal para as leituras seguintes (o `stream` do banco).
final class _Canal implements SyncHomeRepository {
  _Canal();

  final _leituras = StreamController<HomeSnapshot>.broadcast();

  void entregar(HomeSnapshot s) => _leituras.add(s);

  @override
  HomeSnapshot snapshot(DateTime now) => TelaInicio01.snapshot(now);

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => _leituras.stream;
}

/// Entrega [s] e devolve as seções reconstruídas (cada tipo uma vez).
Future<Set<Type>> _reconstruidas(
  WidgetTester tester,
  _Canal canal,
  HomeSnapshot s,
) async {
  final vistas = <Type>{};
  debugOnRebuildDirtyWidget = (e, _) {
    final t = e.widget.runtimeType;
    if (_secoes.contains(t)) vistas.add(t);
  };
  try {
    canal.entregar(s);
    // o Riverpod propaga a mudança num quadro seguinte: espera até não haver quadro pendente
    await tester.pump();
    for (var i = 0; i < 5 && tester.binding.hasScheduledFrame; i++) {
      await tester.pump();
    }
    expect(tester.binding.hasScheduledFrame, isFalse);
  } finally {
    debugOnRebuildDirtyWidget = null;
  }
  return vistas;
}

ReadingDay _maisUmMinuto(ReadingDay d) => ReadingDay(
  goalMinutes: d.goalMinutes,
  readMinutes: d.readMinutes + 1,
  streakDays: d.streakDays,
  highlightsToday: d.highlightsToday,
  sessionsToday: d.sessionsToday,
  week: d.week,
  badgeTargetDays: d.badgeTargetDays,
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'uma leitura igual (objetos novos, 1 min depois, a mesma saudação) não reconstrói nenhuma seção; '
    'a que muda o "Seu dia" reconstrói só o "Seu dia"; a que muda a saudação, só o cabeçalho',
    (tester) async {
      final canal = _Canal();
      await abrirInicio01(tester, repositorio: canal);
      final agora = TelaInicio01.agora; // 20h: "Boa noite,"
      final contexto = tester.element(find.byType(TodaySection));
      HomeSnapshot naTela() =>
          ProviderScope.containerOf(contexto).read(homeSnapshotProvider);
      final base = naTela();
      expect(base.now, agora);

      final igual = copiaProfunda(
        base,
        now: agora.add(const Duration(minutes: 1)),
      );
      expect(await _reconstruidas(tester, canal, igual), isEmpty);
      // o instantâneo na tela é o novo (o relógio andou), com as partes do anterior
      expect(naTela().now, igual.now);
      expect(naTela().readingDay, same(base.readingDay));
      expect(naTela().alsoReading, same(base.alsoReading));

      final hoje = copiaProfunda(
        base,
        now: agora.add(const Duration(minutes: 2)),
        readingDay: _maisUmMinuto(base.readingDay),
      );
      expect(await _reconstruidas(tester, canal, hoje), {TodaySection});
      expect(naTela().readingDay, same(hoje.readingDay));

      // 4h59 ainda é "Boa noite" (sem reconstruir); 5h vira "Bom dia" (só o cabeçalho)
      final madrugada = DateTime(2026, 9, 21, 4, 59);
      expect(
        await _reconstruidas(
          tester,
          canal,
          copiaProfunda(naTela(), now: madrugada),
        ),
        isEmpty,
      );
      expect(
        await _reconstruidas(
          tester,
          canal,
          copiaProfunda(naTela(), now: DateTime(2026, 9, 21, 5)),
        ),
        {HeaderSection},
      );
    },
  );

  testWidgets('cada recorte reconstrói só a sua seção: Também lendo (a lista, item a item), revisão, Para você, '
      'clube e Recém-chegados', (tester) async {
    final canal = _Canal();
    await abrirInicio01(tester, repositorio: canal);
    final base = ProviderScope.containerOf(
      tester.element(find.byType(TodaySection)),
    ).read(homeSnapshotProvider);
    // as seções conferem a ordem das capas da prancha: muda-se um valor, não a ordem
    final [a, b, ...resto] = base.alsoReading;
    final [r1, ...rs] = base.recent;
    final k = base.club!;
    final r = base.dailyReview!;

    final casos = <(String, HomeSnapshot, Type)>[
      (
        'Também lendo (o 2º item)',
        copiaProfunda(
          base,
          alsoReading: [
            a,
            AlsoReadingItem(
              book: b.book,
              progress: b.progress + 0.01,
              format: b.format,
              paperPage: b.paperPage,
              readTime: b.readTime,
            ),
            ...resto,
          ],
        ),
        AlsoReadingSection,
      ),
      (
        'revisão',
        copiaProfunda(
          base,
          dailyReview: DailyReview(
            highlights: r.highlights + 1,
            minutes: r.minutes,
            bookTitles: r.bookTitles,
          ),
        ),
        ReviewSection,
      ),
      (
        'Para você',
        copiaProfunda(
          base,
          forYou: ForYou(
            reasonAuthor: 'Aluísio Azevedo',
            items: base.forYou!.items,
          ),
        ),
        ForYouSection,
      ),
      (
        'clube',
        copiaProfunda(base, club: k.comMensagens(k.unreadMessages + 1)),
        BookClubTicket,
      ),
      (
        'Recém-chegados',
        copiaProfunda(
          base,
          recent: [
            RecentItem(
              book: r1.book,
              format: r1.format,
              status: RecentStatus.isNew,
            ),
            ...rs,
          ],
        ),
        RecentlyAddedSection,
      ),
    ];
    for (final (nome, s, secao) in casos) {
      // volta à base (só a seção que mudou reconstrói de volta) e então muda o recorte
      await _reconstruidas(tester, canal, copiaProfunda(base));
      expect(await _reconstruidas(tester, canal, s), {secao}, reason: nome);
    }
  });
}
