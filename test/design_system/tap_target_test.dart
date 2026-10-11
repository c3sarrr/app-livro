// G20 (R7, D-208) — o alvo de toque que cresce por dentro: o nó semântico e a área de toque com o mínimo de 48,
// centrados no desenho, sem mudar o layout; o toque na área nova chega ao desenho pelo escopo (mesmo com o pai justo),
// vai ao vizinho mais perto e não passa por cima do que cobre o alvo; os guias do Flutter passam com ele e falham sem
// ele.
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/core/design_system/widgets/tap_target.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/semantics.dart' show SemanticsAction, SemanticsRole;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _caixa(
  String id,
  List<String> toques, {
  bool alvo = true,
  EdgeInsets? limite,
}) {
  final desenho = Pressable(
    semanticsLabel: id,
    onTap: () => toques.add(id),
    child: SizedBox(key: ValueKey(id), width: 28, height: 28),
  );
  return alvo ? TapTarget(hitLimit: limite, child: desenho) : desenho;
}

Widget _tela(Widget filho) => Directionality(
  textDirection: TextDirection.ltr,
  child: TapTargetScope(
    child: Center(
      child: SizedBox(width: 200, height: 200, child: Center(child: filho)),
    ),
  ),
);

Finder _id(String id) => find.byKey(ValueKey(id));

void main() {
  testWidgets(
    'o nó mede 48 centrado; o toque a 9 da borda chega, a 30 não; o layout fica 28',
    (tester) async {
      final toques = <String>[];
      final h = tester.ensureSemantics();
      await tester.pumpWidget(_tela(_caixa('a', toques)));
      final caixa = tester.getRect(_id('a'));
      expect(caixa.size, const Size(28, 28));
      final no = tester.getSemantics(_id('a'));
      expect(no.rect.size, const Size(48, 48));
      expect(
        no.getSemanticsData().label,
        'a',
        reason: 'o nó junta o rótulo do desenho',
      );
      expect(no.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      await tester.tapAt(caixa.centerRight + const Offset(9, 0));
      await tester.tapAt(caixa.topCenter - const Offset(0, 9));
      await tester.tapAt(caixa.center);
      expect(toques, ['a', 'a', 'a']);
      await tester.tapAt(caixa.centerRight + const Offset(30, 0));
      expect(toques, hasLength(3));
      h.dispose();
    },
  );

  testWidgets(
    'o pai justo (uma fileira da altura do desenho) não segura o toque da área nova',
    (tester) async {
      final toques = <String>[];
      await tester.pumpWidget(
        _tela(
          SizedBox(
            height: 28,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_caixa('a', toques)],
            ),
          ),
        ),
      );
      final a = tester.getRect(_id('a'));
      await tester.tapAt(a.topCenter - const Offset(0, 8));
      await tester.tapAt(a.bottomCenter + const Offset(0, 8));
      expect(toques, ['a', 'a']);
    },
  );

  testWidgets(
    'vizinhos a 34: o toque no vão vai ao mais perto; os nós continuam com 48',
    (tester) async {
      final toques = <String>[];
      final h = tester.ensureSemantics();
      await tester.pumpWidget(
        _tela(
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [_caixa('a', toques), _caixa('b', toques)],
          ),
        ),
      );
      final a = tester.getRect(_id('a'));
      final b = tester.getRect(_id('b'));
      await tester.tapAt(Offset(a.right + 2, a.center.dy));
      await tester.tapAt(Offset(b.left - 2, b.center.dy));
      await tester.tapAt(Offset(a.right + 4, a.center.dy));
      await tester.tapAt(Offset(a.left - 9, a.center.dy));
      expect(toques, ['a', 'b', 'b', 'a']);
      expect(tester.getSemantics(_id('a')).rect.size, const Size(48, 48));
      expect(tester.getSemantics(_id('b')).rect.size, const Size(48, 48));
      h.dispose();
    },
  );

  testWidgets('o que cobre o alvo (um véu, uma folha) fica com o toque', (
    tester,
  ) async {
    final toques = <String>[];
    var veu = 0;
    await tester.pumpWidget(
      _tela(
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              Center(child: _caixa('a', toques)),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 36, // cobre a faixa de cima da área nova
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => veu++,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final a = tester.getRect(_id('a'));
    await tester.tapAt(Offset(a.center.dx, a.top - 4)); // em cima: o véu
    await tester.tapAt(Offset(a.center.dx, a.bottom + 8)); // embaixo: o alvo
    expect(veu, 1);
    expect(toques, ['a']);
  });

  testWidgets(
    'o alvo coberto (a ilha embaixo do painel da busca) não pega o toque nem segura o do alvo de cima',
    (tester) async {
      final toques = <String>[];
      Widget baixo(String id, double lado) => TapTarget(
        child: Pressable(
          semanticsLabel: id,
          onTap: () => toques.add(id),
          child: SizedBox(key: ValueKey(id), width: lado, height: lado),
        ),
      );
      await tester.pumpWidget(
        _tela(
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                Positioned(left: 10, top: 46, child: baixo('grande', 60)),
                Positioned(left: 80, top: 46, child: baixo('pequeno', 28)),
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0xFFFFFFFF),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 46,
                          top: 46,
                          child: _caixa('cima', toques),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final cima = tester.getRect(_id('cima'));
      // à esquerda: dentro do desenho do 'grande', coberto; à direita: na área nova do 'pequeno', coberto
      await tester.tapAt(cima.centerLeft - const Offset(9, 0));
      await tester.tapAt(cima.centerRight + const Offset(9, 0));
      expect(toques, ['cima', 'cima']);
      // longe do de cima, em cima do 'pequeno' coberto: ninguém
      await tester.tapAt(
        tester.getRect(_id('pequeno')).center + const Offset(0, 4),
      );
      expect(toques, ['cima', 'cima']);
    },
  );

  testWidgets(
    'o fundo que pega toques (a página, a superfície da tinta) fica embaixo: a área nova é do alvo',
    (tester) async {
      final toques = <String>[];
      var fundo = 0;
      await tester.pumpWidget(
        _tela(
          Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => fundo++,
                  child: const SizedBox.expand(),
                ),
              ),
              Center(child: _caixa('a', toques)),
            ],
          ),
        ),
      );
      final a = tester.getRect(_id('a'));
      await tester.tapAt(a.centerRight + const Offset(9, 0));
      await tester.tapAt(a.topCenter - const Offset(0, 9));
      expect(toques, ['a', 'a']);
      await tester.tapAt(a.centerRight + const Offset(30, 0));
      expect(fundo, 1);
    },
  );

  testWidgets(
    'a rolagem logo abaixo (o corpo do painel) não segura o toque da área nova; outro botão ao lado sim',
    (tester) async {
      final toques = <String>[];
      var outro = 0;
      await tester.pumpWidget(
        _tela(
          SizedBox(
            width: 160,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 28,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _caixa('a', toques),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => outro++,
                        child: const SizedBox(
                          key: ValueKey('outro'),
                          width: 40,
                          height: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 160,
                  height: 60,
                  child: SingleChildScrollView(child: SizedBox(height: 200)),
                ),
              ],
            ),
          ),
        ),
      );
      final a = tester.getRect(_id('a'));
      await tester.tapAt(a.bottomCenter + const Offset(0, 8));
      expect(toques, ['a']);
      await tester.tapAt(a.centerRight + const Offset(4, 0));
      expect(outro, 1, reason: 'o desenho do outro botão é dele');
      expect(toques, ['a']);
    },
  );

  testWidgets(
    'no desenho de um alvo, o toque é dele, mesmo quando quem age é a linha em volta (o vizinho perto não o leva)',
    (tester) async {
      final toques = <String>[];
      var linha = 0;
      await tester.pumpWidget(
        _tela(
          GestureDetector(
            onTap: () => linha++,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // o alvo sem gesto próprio: quem age é a linha
                const TapTarget(
                  child: SizedBox(
                    key: ValueKey('a'),
                    width: 28,
                    height: 28,
                    child: ColoredBox(color: Color(0xFF000000)),
                  ),
                ),
                const SizedBox(width: 6),
                _caixa('b', toques),
              ],
            ),
          ),
        ),
      );
      final a = tester.getRect(_id('a'));
      final b = tester.getRect(_id('b'));
      // o ponto está no desenho de 'a' e na área nova de 'b' (que começa 10 antes dele)
      final p = Offset(a.right - 2, a.center.dy);
      expect(p.dx, greaterThan(b.left - 10));
      await tester.tapAt(p);
      expect(toques, isEmpty);
      expect(linha, 1);
    },
  );

  testWidgets(
    'a borda do desenho coberta: o toque na área nova, fora do que cobre, não vai a ninguém',
    (tester) async {
      final toques = <String>[];
      var capa = 0;
      await tester.pumpWidget(
        _tela(
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                Positioned(left: 46, top: 46, child: _caixa('a', toques)),
                // cobre a borda esquerda do desenho (x 40 a 60), não o ponto do toque
                Positioned(
                  left: 40,
                  top: 0,
                  width: 20,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => capa++,
                    child: const ColoredBox(color: Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final a = tester.getRect(_id('a'));
      final pai = tester.getTopLeft(find.byType(Stack).first);
      // 8 à esquerda do desenho, 2 fora da capa
      final p = Offset(a.left - 8, a.center.dy);
      expect(p.dx, lessThan(pai.dx + 40));
      await tester.tapAt(p);
      expect(toques, isEmpty);
      expect(capa, 0, reason: 'o toque fora da capa não vai para ela');
      // o lado de fora, sem capa: o alvo
      await tester.tapAt(a.centerRight + const Offset(9, 0));
      expect(toques, ['a']);
    },
  );

  testWidgets('o hitLimit corta a área de toque; o nó continua com 48', (
    tester,
  ) async {
    final toques = <String>[];
    final h = tester.ensureSemantics();
    await tester.pumpWidget(
      _tela(
        _caixa('a', toques, limite: const EdgeInsets.fromLTRB(4, 0, 10, 10)),
      ),
    );
    final a = tester.getRect(_id('a'));
    await tester.tapAt(Offset(a.center.dx, a.top - 4)); // acima: o limite é 0
    // à esquerda: o limite é 4
    await tester.tapAt(Offset(a.left - 7, a.center.dy));
    await tester.tapAt(Offset(a.center.dx, a.bottom + 8));
    await tester.tapAt(Offset(a.right + 9, a.center.dy));
    await tester.tapAt(Offset(a.left - 3, a.center.dy));
    expect(toques, ['a', 'a', 'a']);
    expect(tester.getSemantics(_id('a')).rect.size, const Size(48, 48));
    h.dispose();
  });

  testWidgets(
    'escondido (Offstage) ou com os toques desligados, a área nova não pega o toque',
    (tester) async {
      final toques = <String>[];
      await tester.pumpWidget(_tela(IgnorePointer(child: _caixa('a', toques))));
      final a = tester.getRect(_id('a'));
      await tester.tapAt(a.centerRight + const Offset(9, 0));
      expect(toques, isEmpty);
      await tester.pumpWidget(_tela(Offstage(child: _caixa('a', toques))));
      await tester.tapAt(a.centerRight + const Offset(9, 0));
      await tester.tapAt(a.center);
      expect(toques, isEmpty);
    },
  );

  testWidgets('um link no texto ao lado fica com o toque dele', (tester) async {
    final toques = <String>[];
    var link = 0;
    final reconhecedor = TapGestureRecognizer()..onTap = () => link++;
    addTearDown(reconhecedor.dispose);
    await tester.pumpWidget(
      _tela(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _caixa('a', toques),
            Text.rich(
              TextSpan(
                text: 'ver',
                recognizer: reconhecedor,
                style: const TextStyle(fontSize: 28, height: 1),
              ),
              key: const ValueKey('link'),
            ),
          ],
        ),
      ),
    );
    final a = tester.getRect(_id('a'));
    expect(tester.getRect(find.byKey(const ValueKey('link'))).left, a.right);
    await tester.tapAt(a.centerRight + const Offset(4, 0));
    expect(link, 1);
    expect(toques, isEmpty);
  });

  testWidgets('os guias de toque passam com o alvo e falham sem ele', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await tester.pumpWidget(_tela(_caixa('a', [])));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await tester.pumpWidget(_tela(_caixa('a', [], alvo: false)));
    final sem = await androidTapTargetGuideline.evaluate(tester);
    expect(sem.passed, isFalse);
    h.dispose();
  });

  testWidgets('o mínimo e o papel trocados na reconstrução mudam o nó', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    Widget alvo(double minimo, SemanticsRole? papel) => _tela(
      TapTarget(
        minSize: minimo,
        role: papel,
        // a aba precisa do estado de selecionada
        child: Semantics(
          selected: true,
          child: Pressable(
            semanticsLabel: 'a',
            onTap: () {},
            child: const SizedBox(key: ValueKey('a'), width: 28, height: 28),
          ),
        ),
      ),
    );
    await tester.pumpWidget(alvo(48, null));
    expect(tester.getSemantics(_id('a')).rect.size, const Size(48, 48));
    await tester.pumpWidget(alvo(60, SemanticsRole.tab));
    final no = tester.getSemantics(_id('a'));
    expect(no.rect.size, const Size(60, 60));
    expect(no.getSemanticsData().role, SemanticsRole.tab);
    h.dispose();
  });

  testWidgets('o alvo já grande não muda', (tester) async {
    final h = tester.ensureSemantics();
    await tester.pumpWidget(
      _tela(
        TapTarget(
          child: Pressable(
            semanticsLabel: 'g',
            onTap: () {},
            child: const SizedBox(key: ValueKey('g'), width: 60, height: 50),
          ),
        ),
      ),
    );
    expect(tester.getSemantics(_id('g')).rect.size, const Size(60, 50));
    h.dispose();
  });
}
