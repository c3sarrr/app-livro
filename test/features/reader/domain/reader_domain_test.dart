// G03.2 — leitor: localizador/âncora (Anexo 03 §5), posição, sessões, marcadores e ajustes.
import 'dart:convert';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/reader/domain/bookmark.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/domain/reading_position.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usuario = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';
  const livroId = '0199a7c4-2f00-7a10-8b20-000000000001';
  const sha =
      'a3f1c2d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90';
  final t0 = DateTime.utc(2026, 9, 20, 23);
  final meta = RecordMeta(
    userId: usuario,
    createdAt: t0,
    updatedAt: t0,
    version: Hlc(t0.millisecondsSinceEpoch, 0, 'aparelhoA'),
  );

  // Exemplo literal do Anexo 03 §5.1.
  const locatorJson = {
    'v': 1,
    'sha': sha,
    'spine': 12,
    'offset': 5321,
    'quote': {
      'prefix': '…32 caracteres',
      'exact': 'Retórica dos namorados',
      'suffix': '32 caracteres…',
    },
    'refPage': 159,
    'progression': 0.62113,
  };

  group('Locator e TextAnchor (jsonb)', () {
    test('localizador de EPUB: ida e volta do JSON do Anexo 03 §5.1', () {
      final l = Locator.fromJson(locatorJson);
      expect(l, isA<EpubLocator>());
      final e = l as EpubLocator;
      expect(e.spine, 12);
      expect(e.offset, 5321);
      expect(e.quote!.exact, 'Retórica dos namorados');
      expect(e.refPage, 159);
      expect(e.progression, 0.62113);
      expect(e.toJson(), locatorJson);
      expect(
        Locator.fromJson(
          jsonDecode(jsonEncode(e.toJson())) as Map<String, Object?>,
        ),
        e,
      );
    });

    test(
      'formato desconhecido (PDF, versão futura) é preservado sem perda',
      () {
        const pdf = {
          'v': 1,
          'sha': sha,
          'page': 12,
          'quads': [
            [0.1, 0.2, 0.3, 0.4],
          ],
        };
        final l = Locator.fromJson(pdf);
        expect(l, isA<RawLocator>());
        expect(l.toJson(), pdf);
        expect(Locator.fromJson(pdf), l);
        final a = TextAnchor.fromJson(pdf);
        expect(a, isA<RawAnchor>());
        expect(a.toJson(), pdf);
        expect(a, TextAnchor.fromJson(pdf));
      },
    );

    test('âncora de intervalo (Anexo 03 §5.2) com início ≤ fim', () {
      const json = {
        'v': 1,
        'sha': sha,
        'spine': 12,
        'start': 5390,
        'end': 5413,
        'quote': {
          'prefix': 'para dizer o que foram ',
          'exact': 'aqueles olhos de Capitu',
          'suffix': '. Não me acode imagem',
        },
        'refPage': 159,
      };
      final a = TextAnchor.fromJson(json) as EpubAnchor;
      expect(a.end - a.start, 'aqueles olhos de Capitu'.length);
      expect(a.toJson(), json);
      expect(
        () => EpubAnchor(
          sha: sha,
          spine: 1,
          start: 10,
          end: 9,
          quote: const TextQuote(exact: 'x'),
          refPage: 1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ReadingPosition', () {
    ReadingPosition pos({double progression = 0.62113, int refPage = 159}) =>
        ReadingPosition(
          id: livroId,
          meta: meta,
          locator: Locator.fromJson(locatorJson),
          refPage: refPage,
          chapterIndex: 31,
          progression: progression,
          deviceId: 'aparelhoA',
        );

    test('CHECKs: progressão 0–1, página > 0, capítulo ≥ 0', () {
      expect(pos().progression, 0.62113);
      expect(() => pos(progression: 1.00001), throwsArgumentError);
      expect(() => pos(progression: -0.1), throwsArgumentError);
      expect(() => pos(refPage: 0), throwsArgumentError);
      expect(pos(), pos());
      expect(pos().copyWith(refPage: 160).refPage, 160);
      expect(pos().copyWith(deviceId: const Nullable(null)).deviceId, isNull);
    });
  });

  group('ReadingSession', () {
    ReadingSession sessao(DateTime inicio, int segundos, {DateTime? fim}) =>
        ReadingSession(
          id: '0199a7c4-2f00-7a10-8b20-0000000000aa',
          meta: meta,
          userBookId: livroId,
          startedAt: inicio,
          endedAt: fim ?? inicio.add(Duration(seconds: segundos)),
          activeSeconds: segundos,
          source: SessionSource.auto,
        );

    test('códigos e CHECKs: fim ≥ início, 0–86.400 s', () {
      expect(SessionSource.values.map((s) => s.code), [
        'auto',
        'timer',
        'manual',
      ]);
      expect(
        () => sessao(t0, 60, fim: t0.subtract(const Duration(seconds: 1))),
        throwsArgumentError,
      );
      expect(() => sessao(t0, 86401), throwsArgumentError);
      // RPC: started_at_out_of_range (partição histórica começa em 2024)
      expect(
        () => sessao(DateTime.utc(2023, 12, 31, 23), 60),
        throwsArgumentError,
      );
      expect(sessao(DateTime.utc(2024), 60).startedAt, DateTime.utc(2024));
      expect(sessao(t0, 60), sessao(t0, 60));
    });

    test('minutos de um dia no fuso do usuário (São Paulo, UTC−3)', () {
      const sp = Duration(hours: -3);
      final sessoes = [
        sessao(DateTime.utc(2026, 9, 20, 12), 600), // 09:00 em SP, dia 20
        sessao(
          DateTime.utc(2026, 9, 21, 1, 30),
          480,
        ), // 22:30 em SP, ainda dia 20
        sessao(DateTime.utc(2026, 9, 20, 2), 900), // 23:00 em SP do dia 19
        sessao(DateTime.utc(2026, 9, 20, 15), 300).copyWith(
          meta: meta.deleted(
            t0,
            Hlc(t0.millisecondsSinceEpoch, 1, 'aparelhoA'),
          ),
        ), // apagada
      ];
      expect(
        ReadingTime.minutesOn(
          sessoes,
          localDay: DateTime.utc(2026, 9, 20),
          utcOffset: sp,
        ),
        18,
      );
      expect(
        ReadingTime.minutesOn(
          sessoes,
          localDay: DateTime.utc(2026, 9, 19),
          utcOffset: sp,
        ),
        15,
      );
    });
  });

  group('Bookmark', () {
    test('excerto até 280 caracteres', () {
      Bookmark b(String? excerpt) => Bookmark(
        id: '0199a7c4-2f00-7a10-8b20-0000000000bb',
        meta: meta,
        userBookId: livroId,
        locator: Locator.fromJson(locatorJson),
        refPage: 159,
        chapterIndex: 31,
        excerpt: excerpt,
      );
      expect(
        b('Retórica dos namorados, dá-me uma comparação exata e poética…')
            .refPage,
        159,
      );
      expect(() => b('x' * 281), throwsArgumentError);
      expect(b(null), b(null));
      expect(b(null).copyWith(excerpt: const Nullable('a')).excerpt, 'a');
    });
  });

  group('ReaderSettings', () {
    test(
      'padrões da tela 26 (SQL): tamanho 4, Literata, Creme, Médio, Média',
      () {
        final s = ReaderSettings(id: usuario, meta: meta);
        expect(s.fontStep, 4);
        expect(s.fontFamily, ReaderFontFamily.literata);
        expect(s.paper, ReaderPaper.creme);
        expect(s.lineSpacing, ReaderLineSpacing.medio);
        expect(s.margins, ReaderMargins.media);
        expect(ReaderPaper.values.map((p) => p.code), [
          'creme',
          'branco',
          'sepia',
          'noite',
        ]);
        expect(ReaderFontFamily.values.map((p) => p.code), [
          'literata',
          'lora',
          'figtree',
          'atkinson',
        ]);
        expect(ReaderLineSpacing.values.map((p) => p.code), [
          'justo',
          'medio',
          'solto',
        ]);
        expect(ReaderMargins.values.map((p) => p.code), [
          'estreita',
          'media',
          'larga',
        ]);
      },
    );

    test('CHECKs: tamanho 1–7 e id = dono', () {
      expect(
        () => ReaderSettings(id: usuario, meta: meta, fontStep: 8),
        throwsArgumentError,
      );
      expect(
        () => ReaderSettings(id: livroId, meta: meta),
        throwsArgumentError,
      );
      final s = ReaderSettings(
        id: usuario,
        meta: meta,
      ).copyWith(paper: ReaderPaper.noite);
      expect(s.paper, ReaderPaper.noite);
      expect(
        s,
        ReaderSettings(id: usuario, meta: meta, paper: ReaderPaper.noite),
      );
    });
  });

  group('ReaderLook (G14)', () {
    test('padrões = tela 26; copyWith; igualdade por valor', () {
      const l = ReaderLook();
      expect(
        (l.fontStep, l.fontFamily, l.paper, l.lineSpacing, l.margins),
        (
          4,
          ReaderFontFamily.literata,
          ReaderPaper.creme,
          ReaderLineSpacing.medio,
          ReaderMargins.media,
        ),
      );
      expect(l.copyWith(fontStep: 7), const ReaderLook(fontStep: 7));
      expect(l.copyWith(fontStep: 7), isNot(l));
      expect(
        l.copyWith(paper: ReaderPaper.noite).hashCode,
        const ReaderLook(paper: ReaderPaper.noite).hashCode,
      );
      expect(
        l.copyWith(fontFamily: ReaderFontFamily.atkinson).toString(),
        'ReaderLook(4, atkinson, creme, medio, media)',
      );
    });

    test('sameLayout: o papel não muda as quebras; tamanho, fonte, entrelinha e margens mudam', () {
      const l = ReaderLook();
      expect(l.sameLayout(l), isTrue);
      expect(l.sameLayout(l.copyWith(paper: ReaderPaper.sepia)), isTrue);
      for (final o in [
        l.copyWith(fontStep: 5),
        l.copyWith(fontFamily: ReaderFontFamily.lora),
        l.copyWith(lineSpacing: ReaderLineSpacing.solto),
        l.copyWith(margins: ReaderMargins.larga),
      ]) {
        expect(l.sameLayout(o), isFalse, reason: '$o');
      }
    });

    test('ReaderSettings.look e withLook: os 5 ajustes vão e voltam; id e meta ficam', () {
      final s = ReaderSettings(
        id: usuario,
        meta: meta,
        fontStep: 2,
        paper: ReaderPaper.sepia,
      );
      expect(s.look, const ReaderLook(fontStep: 2, paper: ReaderPaper.sepia));
      const outro = ReaderLook(
        fontStep: 6,
        fontFamily: ReaderFontFamily.atkinson,
        paper: ReaderPaper.noite,
        lineSpacing: ReaderLineSpacing.justo,
        margins: ReaderMargins.estreita,
      );
      final t = s.withLook(outro);
      expect((t.id, t.meta, t.look), (s.id, s.meta, outro));
      final m2 = meta.edited(
        meta.updatedAt.add(const Duration(seconds: 1)),
        meta.version,
      );
      expect(s.withLook(outro, meta: m2).meta, m2);
      expect(
        () => s.withLook(const ReaderLook().copyWith(fontStep: 9)),
        throwsArgumentError,
      );
    });
  });
}
