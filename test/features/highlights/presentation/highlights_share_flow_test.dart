// G21.5 — "Compartilhar no clube" pela rota real da 25 (docs/progresso/G21.md §5): um clube (direto, a pílula e o
// chip no cartão), os termos (a folha "Antes de publicar": aceitar segue, "Agora não" fecha sem publicar), mais de um
// clube (a folha "Compartilhar em…" com a cor e o nome) e nenhum clube.
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/highlights/application/highlights_club_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_share.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/dados_t25.dart';
import '../../../support/fase_l25.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart' show idTeste;
import '../../../support/reader_harness.dart';

const ShareClub _capitu = (
  id: 'c1',
  name: 'Leitoras de Capitu',
  color: '#FFC1C6',
);
const ShareClub _poesia = (
  id: 'c2',
  name: 'Poesia de domingo',
  color: '#ABCF82',
);

/// O "servidor" do compartilhar e o chip que ele deixa no cache.
final class _Clubes implements HighlightsShare, HighlightsClubSource {
  List<ShareClub> clubes = const [_capitu];
  bool aceitou = true;
  final feitos = <String>[];
  final chips = <String, ClubChip>{};

  @override
  Future<List<ShareClub>> clubsFor(String userBookId) async => clubes;
  @override
  Future<ShareTerms> terms() async => (version: 'v1', accepted: aceitou);
  @override
  Future<void> acceptTerms(String version) async => aceitou = true;
  @override
  Future<String> share(ShareClub club, Annotation highlight) async {
    feitos.add(club.id);
    final id = idTeste(990 + feitos.length);
    chips[id] = (clubId: club.id, name: club.name, replies: 0);
    return id;
  }

  @override
  Future<ClubChip?> clubOf(String id) async =>
      chips[id] ?? await const ClubeDaTela25().clubOf(id);
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late _Clubes clubes;
  setUp(() async {
    livro = await livroDaTela25();
    clubes = _Clubes();
  });
  tearDown(() async => livro.close());

  Future<void> abrir(WidgetTester tester) => abrirTela25(
    tester,
    livro,
    deps: depsDaTela25(livro, clube: clubes, compartilhar: clubes),
  );

  /// O 1º cartão com texto ainda não compartilhado, com a folha "Mais opções" aberta.
  Future<int> maisDoLivre(WidgetTester tester) async {
    final n =
        cartoes25(tester).indexWhere(
          (v) =>
              shareableHighlight(v.card) != null && v.card.clubPostId == null,
        ) +
        1;
    await tester.ensureVisible(hl('hl.list.card$n.head.more'));
    await tester.pumpAndSettle();
    await tester.tap(hl('hl.list.card$n.head.more'));
    await tester.pump();
    return n;
  }

  String aviso(WidgetTester tester) =>
      appText25(tester, 'leitor.aviso', '').span.toPlainText();

  testWidgets(
    'um clube: publica direto, "Compartilhado em Leitoras de Capitu." e o chip no cartão',
    (tester) async {
      await abrir(tester);
      final n = await maisDoLivre(tester);
      await tester.tap(hl('hl.more.share'));
      await tester.pump();
      await banco25(tester);
      expect(clubes.feitos, ['c1']);
      expect(aviso(tester), 'Compartilhado em Leitoras de Capitu.');
      expect(cartoes25(tester)[n - 1].card.clubPostId, idTeste(991));
      expect(hl('hl.list.card$n.body.club'), findsOneWidget);
    },
  );

  testWidgets(
    'os termos: "Antes de publicar"; "Agora não" fecha sem publicar; aceitar segue e publica',
    (tester) async {
      clubes.aceitou = false;
      await abrir(tester);
      await maisDoLivre(tester);
      await tester.tap(hl('hl.more.share'));
      await tester.pump();
      await banco25(tester);
      expect(hl('hl.terms'), findsOneWidget);
      expect(
        appText25(tester, 'hl.terms.title', '').span.toPlainText(),
        'ANTES DE PUBLICAR',
      );
      expect(hl('hl.terms.rule3'), findsOneWidget);
      await tester.tap(hl('hl.terms.later'));
      await tester.pump();
      expect(hl('hl.terms'), findsNothing);
      expect(clubes.feitos, isEmpty);

      await maisDoLivre(tester);
      await tester.tap(hl('hl.more.share'));
      await tester.pump();
      await banco25(tester);
      await tester.tap(hl('hl.terms.accept'));
      await tester.pump();
      await banco25(tester);
      expect(hl('hl.terms'), findsNothing);
      expect(clubes.feitos, ['c1']);
      expect(aviso(tester), 'Compartilhado em Leitoras de Capitu.');
    },
  );

  testWidgets(
    'mais de um clube: "Compartilhar em…" com a cor e o nome; o toque publica no escolhido',
    (tester) async {
      clubes.clubes = const [_capitu, _poesia];
      await abrir(tester);
      await maisDoLivre(tester);
      await tester.tap(hl('hl.more.share'));
      await tester.pump();
      await banco25(tester);
      expect(hl('hl.shareTo'), findsOneWidget);
      expect(
        appText25(tester, 'hl.shareTo.title', '').span.toPlainText(),
        'COMPARTILHAR EM…',
      );
      expect(
        tester.widget<NeoBox>(hl('hl.shareTo.club1.dot')).color,
        AppColors.leaf,
      );
      await tester.tap(hl('hl.shareTo.club1'));
      await tester.pump();
      await banco25(tester);
      expect(hl('hl.shareTo'), findsNothing);
      expect(clubes.feitos, ['c2']);
      expect(aviso(tester), 'Compartilhado em Poesia de domingo.');
    },
  );

  testWidgets('nenhum clube lê o livro: a pílula', (tester) async {
    clubes.clubes = const [];
    await abrir(tester);
    await maisDoLivre(tester);
    await tester.tap(hl('hl.more.share'));
    await tester.pump();
    await banco25(tester);
    expect(aviso(tester), 'Nenhum clube seu está lendo este livro.');
  });
}
