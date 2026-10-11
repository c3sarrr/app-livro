// R00.7 (D-267) — o build de loja é o `lib/`: nenhum arquivo dele importa algo de fora do `lib/` (os alvos do modo
// demonstração, as fixtures e o mundo de referência moram em `test/`), nem os pacotes de teste, e nenhum código dele
// fala do banco ou das pastas do demo. Assim o demo nunca entra no app da loja.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _import = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Os pacotes que só os testes usam (as `dev_dependencies` de teste).
const _pacotesDeTeste = [
  'package:flutter_test/',
  'package:integration_test/',
  'package:flutter_driver/',
  'package:test/',
  'package:mocktail/',
  'package:mockito/',
];

/// Os nomes do modo demonstração (`test/fixtures/demonstracao/overrides_demonstracao.dart`).
const _nomesDoDemo = [
  'booknest_demo',
  'livros_demo',
  'capas_demo',
  'capas_arquivo_demo',
  'catalogo_demo',
  'BOOKNEST_DEMO_RECOMECAR',
  'demonstracao',
];

List<File> _dartEm(String pasta) => [
  for (final e in Directory(pasta).listSync(recursive: true))
    if (e is File && e.path.endsWith('.dart')) e,
];

String _normal(String caminho) =>
    File(caminho).absolute.uri.normalizePath().toFilePath();

/// O código sem os comentários de linha (o `lib/main.dart` cita o alvo do mundo num comentário).
String _semComentarios(String fonte) => fonte
    .split('\n')
    .map((l) {
      final i = l.indexOf('//');
      return i < 0 ? l : l.substring(0, i);
    })
    .join('\n');

void main() {
  final lib = _normal('lib');
  final arquivos = _dartEm('lib');
  bool dentroDeLib(String caminho) =>
      caminho.startsWith('$lib${Platform.pathSeparator}');

  test('há código em lib/ para conferir', () {
    expect(arquivos.length, greaterThan(100));
  });

  test('nenhum import de lib/ sai de lib/ nem usa pacote de teste', () {
    final fora = <String>[];
    for (final f in arquivos) {
      for (final m in _import.allMatches(f.readAsStringSync())) {
        final alvo = m.group(1)!;
        if (alvo.startsWith('dart:')) continue;
        if (_pacotesDeTeste.any(alvo.startsWith)) {
          fora.add('${f.path}: $alvo');
          continue;
        }
        if (alvo.startsWith('package:')) continue;
        final resolvido = _normal(
          File(f.path).parent.uri.resolve(alvo).toFilePath(),
        );
        if (!dentroDeLib(resolvido)) fora.add('${f.path}: $alvo');
      }
    }
    expect(fora, isEmpty);
  });

  test(
    'nenhum código de lib/ fala do banco, das pastas ou do recomeço do demo',
    () {
      final achados = <String>[];
      for (final f in arquivos) {
        final codigo = _semComentarios(f.readAsStringSync());
        for (final nome in _nomesDoDemo) {
          if (codigo.contains(nome)) achados.add('${f.path}: $nome');
        }
      }
      expect(achados, isEmpty);
    },
  );

  test('os alvos do demo moram em test/fixtures e recusam o release', () {
    for (final alvo in [
      'test/fixtures/main_demonstracao.dart',
      'test/fixtures/main_mundo_referencia.dart',
    ]) {
      final fonte = File(alvo).readAsStringSync();
      expect(fonte, contains('if (kReleaseMode)'), reason: alvo);
      expect(fonte, contains('throw StateError('), reason: alvo);
    }
  });

  test('o guarda pega o que deve: um import para test/ e um nome do demo', () {
    // o mesmo cálculo dos testes acima, sobre um arquivo inventado em lib/features/x/
    final f = File('lib/features/x/y.dart');
    final alvo = File(
      f.parent.uri.resolve('../../../test/fixtures/mundo.dart').toFilePath(),
    );
    expect(dentroDeLib(_normal(alvo.path)), isFalse);
    expect(dentroDeLib(_normal('lib/features/x/z.dart')), isTrue);
    expect(dentroDeLib(_normal('libx/y.dart')), isFalse);
    expect(
      _semComentarios("final p = 'booknest_demo.db'; // ok")
          .contains('booknest_demo'),
      isTrue,
    );
    expect(
      _semComentarios('// test/fixtures/main_demonstracao.dart')
          .contains('demonstracao'),
      isFalse,
    );
  });
}
