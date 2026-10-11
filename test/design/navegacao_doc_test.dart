// R00.6 (R4, R5) — a documentação e a prova andam juntas: a tabela (b) da `docs/NAVEGACAO.md` tem exatamente as
// ligações que o percurso toca (`test/support/navegacao.dart`), na mesma ordem e com a mesma classe; a etapa de cada 🟡
// e a decisão de cada ⏸ batem; e a tabela (a) tem todas as rotas do roteador.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/navegacao.dart';

final _doc = File('docs/NAVEGACAO.md').readAsStringSync();

/// As linhas de tabela da seção que começa em [inicio] e acaba no próximo título.
List<List<String>> _tabela(String inicio) {
  final a = _doc.indexOf(inicio);
  if (a < 0) throw StateError('NAVEGACAO.md sem a seção "$inicio"');
  final resto = _doc.substring(a + inicio.length);
  final fim = RegExp(r'^#{2,3} ', multiLine: true).firstMatch(resto)?.start;
  final secao = fim == null ? resto : resto.substring(0, fim);
  return [
    for (final l in secao.split('\n'))
      if (l.startsWith('|') && !l.startsWith('|---'))
        [for (final c in l.split('|').skip(1).toList()..removeLast()) c.trim()],
  ].skip(1).toList(); // sem o cabeçalho
}

String _codigo(String celula) {
  final m = RegExp(r'^`([^`]+)`$').firstMatch(celula);
  if (m == null) throw StateError('esperava `código`: "$celula"');
  return m.group(1)!;
}

void main() {
  final linhas = _tabela('## (b) Os toques das telas prontas');

  test('a tabela (b) tem as ligações do percurso, na ordem, com a classe', () {
    expect(
      [for (final l in linhas) '${l[2]} ${_codigo(l[0])} · ${_codigo(l[1])}'],
      [for (final l in ligacoes) '$l'],
    );
  });

  test('toda origem da tabela é uma origem do percurso', () {
    expect({for (final l in linhas) _codigo(l[0])}, origens.toSet());
    expect({for (final l in ligacoes) l.origem}, origens.toSet());
  });

  test(
    'cada 🟡 tem a etapa que troca, e cada ⏸ a decisão (as do percurso)',
    () {
      for (var i = 0; i < ligacoes.length; i++) {
        final l = ligacoes[i];
        final celula = linhas[i][4];
        switch (l.classe) {
          case Classe.placeholder:
            expect(l.etapa, matches(RegExp(r'^T\d{2}$')), reason: '$l');
            expect(celula, startsWith(l.etapa!), reason: '$l');
            expect(l.titulo, isNotNull, reason: '$l');
          case Classe.semAcao:
            expect(l.decisao, isNotNull, reason: '$l');
            expect(celula, contains(l.decisao!), reason: '$l');
          case Classe.leva:
            expect(l.destino ?? l.some ?? l.confere, isNotNull, reason: '$l');
        }
      }
    },
  );

  test('a tabela (a) tem todas as rotas do roteador', () {
    final routes = File('lib/app/routes.dart').readAsStringSync();
    final router = File('lib/app/router.dart').readAsStringSync();
    final constantes = {
      for (final m in RegExp(
        r"static const (\w+) = '([^']+)';",
      ).allMatches(routes))
        m.group(1)!: m.group(2)!,
    };
    final rotas = <String>{
      for (final m in RegExp(r'AppRoutes\.(\w+)').allMatches(router))
        ?constantes[m.group(1)],
      for (final m in RegExp(r"'(/[^']*)'").allMatches(router)) m.group(1)!,
    };
    expect(rotas, containsAll(['/inicio', '/leitor/:bookId', '/_pro']));
    final tabela = {
      for (final l in _tabela('## (a) As rotas'))
        if (RegExp(r'^`([^`]+)`').firstMatch(l[0]) case final m?) m.group(1)!,
    };
    expect(tabela, containsAll(rotas));
  });

  test('o leitor da tabela acha o que não bate (a mutação do documento)', () {
    final trocada = [
      for (final l in linhas)
        l[1] == '`header.search`' ? [l[0], l[1], '✅', l[3], l[4]] : l,
    ];
    expect([
      for (final l in trocada) '${l[2]} ${_codigo(l[0])} · ${_codigo(l[1])}',
    ], isNot([for (final l in ligacoes) '$l']));
    expect(() => _codigo('header.search'), throwsStateError);
  });
}
