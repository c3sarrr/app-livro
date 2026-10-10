// T04.1 — o localizador do livro de papel (R7): só a página informada no fim da sessão do cronômetro.
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o JSON do papel vira PaperLocator e volta igual', () {
    const json = {'v': 1, 'kind': 'paper', 'refPage': 344};
    final l = Locator.fromJson(json);
    expect(l, PaperLocator(344));
    expect(l.toJson(), json);
    expect(Locator.fromJson(l.toJson()), l);
    expect(PaperLocator(344).hashCode, PaperLocator(344).hashCode);
    expect(PaperLocator(344), isNot(PaperLocator(345)));
  });

  test('fora da regra: guardado como veio (RawLocator), nunca lança', () {
    for (final ruim in <Map<String, Object?>>[
      {'v': 1, 'kind': 'paper', 'refPage': 0},
      {'v': 2, 'kind': 'paper', 'refPage': 3},
      {'v': 1, 'kind': 'papel', 'refPage': 3},
      {'v': 1, 'kind': 'paper', 'refPage': '3'},
      {'v': 1, 'kind': 'paper', 'refPage': 3, 'extra': true},
    ]) {
      expect(Locator.fromJson(ruim), isA<RawLocator>(), reason: '$ruim');
    }
  });

  test('a página precisa ser ≥ 1', () {
    expect(() => PaperLocator(0), throwsArgumentError);
  });

  test('um localizador de EPUB não vira papel', () {
    final epub = {
      'v': 1,
      'sha': 'a' * 64,
      'spine': 12,
      'offset': 5321,
      'refPage': 159,
      'progression': 0.62113,
    };
    expect(Locator.fromJson(epub), isA<EpubLocator>());
  });
}
