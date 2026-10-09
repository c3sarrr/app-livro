// G20 (R5) — o canal das saídas da tela 25: entrega a saída de um livro só a quem escuta esse livro; o provedor
// fecha o canal junto com o app.
import 'package:app_leitura/features/highlights/application/highlights_exit.dart';
import 'package:app_leitura/features/highlights/application/highlights_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'o canal entrega a saída de um livro a quem escuta esse livro',
    () async {
      final bus = HighlightsExitBus();
      addTearDown(bus.dispose);
      final a = <HighlightsExit>[];
      final b = <HighlightsExit>[];
      final subA = bus.of('livroA').listen(a.add);
      final subB = bus.of('livroB').listen(b.add);
      addTearDown(subA.cancel);
      addTearDown(subB.cancel);
      bus.post('livroB', const HighlightsContinue());
      bus.post('livroA', const HighlightsOpenAt('x', page: 41));
      await Future<void>.delayed(Duration.zero);
      expect(a, [const HighlightsOpenAt('x', page: 41)]);
      expect(b, [const HighlightsContinue()]);
    },
  );

  test('sem ninguém escutando, a saída se perde sem erro', () async {
    final bus = HighlightsExitBus();
    addTearDown(bus.dispose);
    bus.post('livroA', const HighlightsContinue());
    final a = <HighlightsExit>[];
    final sub = bus.of('livroA').listen(a.add);
    addTearDown(sub.cancel);
    await Future<void>.delayed(Duration.zero);
    expect(a, isEmpty);
  });

  test('o provedor dá um canal por app e o fecha com ele', () async {
    final container = ProviderContainer();
    final bus = container.read(highlightsExitBusProvider);
    expect(container.read(highlightsExitBusProvider), same(bus));
    var fechou = false;
    bus.of('livroA').listen((_) {}, onDone: () => fechou = true);
    container.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(fechou, isTrue);
  });
}
