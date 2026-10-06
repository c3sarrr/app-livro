// G11.2 — tela acesa enquanto se lê (D-111): liga na interação, desliga 120 s depois da última (D-95) e ao
// parar; o erro do sistema vai para o relatório de falhas e não para a leitura. (`testWidgets` dá o relógio
// falso: os `Timer` andam com `tester.pump(duração)`.)
import 'package:app_leitura/features/reader/application/screen_awake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_reader.dart';

void main() {
  testWidgets('liga na interação, desliga 120 s depois da última, e ao parar', (
    tester,
  ) async {
    final s = RecordingScreenAwake();
    final k = KeepAwake(s);
    expect(k.on, isFalse);
    k.touch();
    expect(s.log, ['on']);
    await tester.pump(const Duration(seconds: 100));
    k.touch();
    await tester.pump(const Duration(seconds: 119));
    expect(s.log, ['on'], reason: 'a 2ª interação recomeça os 120 s');
    await tester.pump(const Duration(seconds: 1));
    expect((s.log.length, k.on), (2, false));
    expect(s.log, ['on', 'off']);
    k
      ..touch()
      ..touch()
      ..stop()
      ..stop();
    expect(s.log, ['on', 'off', 'on', 'off'], reason: 'sem chamadas repetidas');
    await tester.pump(const Duration(minutes: 5));
    expect(s.log, hasLength(4));
  });

  testWidgets('falha do sistema vai para o relatório e a leitura segue', (
    tester,
  ) async {
    final s = RecordingScreenAwake()..failNext = true;
    final erros = <Object>[];
    final k = KeepAwake(s, onError: (e, _) => erros.add(e));
    k.touch();
    await tester.pump();
    expect(erros.single, isA<StateError>());
    expect(k.on, isTrue);
    k.stop();
    await tester.pump();
    expect(s.log, ['on', 'off']);
    expect(erros, hasLength(1));
  });
}
