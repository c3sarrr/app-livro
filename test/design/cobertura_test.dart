// R00 (R1, R2) — a cobertura das 128 telas (`docs/design/projeto/COBERTURA.md`) coerente com o catálogo do projeto
// (`CATALOGO.md`) e com a fila do `docs/ROTEIRO.md` §3: cada tela uma vez, com o título e o arquivo do catálogo, uma
// situação válida e uma etapa que cita aquela tela; as 16 telas do app ✅; as 9 que faltam (D-268) com a etapa que as
// cita.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Uma linha da tabela Markdown, sem as bordas (`| a | b |` → `[a, b]`).
List<String> _celulas(String linha) {
  final s = linha.trim();
  return s.substring(1, s.length - 1).split('|').map((c) => c.trim()).toList();
}

/// As linhas da 1ª tabela depois do título [secao] (até o próximo `## `), sem o cabeçalho e o separador.
List<List<String>> _tabela(String texto, String secao) {
  final linhas = texto.split('\n');
  final inicio = linhas.indexWhere((l) => l.trim() == secao);
  if (inicio < 0) throw StateError('seção "$secao" não encontrada');
  final out = <List<String>>[];
  var cabecalho = 0;
  for (final l in linhas.skip(inicio + 1)) {
    if (l.startsWith('## ')) break;
    if (!l.trimLeft().startsWith('|')) {
      if (out.isNotEmpty) break;
      continue;
    }
    if (cabecalho < 2) {
      cabecalho++;
      continue;
    }
    out.add(_celulas(l));
  }
  return out;
}

final class _Tela {
  const _Tela(this.numero, this.titulo, this.arquivo);
  final String numero;
  final String titulo;
  final String arquivo;
}

List<_Tela> _catalogo() {
  final re = RegExp(
    r'^\| Page \d+ \| (\d{2,3}[a-d]?) · (.*?) \| `(telas/[^`]+)` \|',
  );
  return [
    for (final l in File('docs/design/projeto/CATALOGO.md').readAsLinesSync())
      if (re.firstMatch(l) case final m? when m.group(1) != '00')
        _Tela(m.group(1)!, m.group(2)!, m.group(3)!),
  ];
}

/// O número sem os zeros à esquerda e com o sufixo ('01b' → (1, 'b')).
(int, String) _partes(String n) {
  final m = RegExp(r'^0*(\d+)([a-d]?)$').firstMatch(n)!;
  return (int.parse(m.group(1)!), m.group(2)!);
}

/// Por etapa (`'<#> · <ID>'`), o texto da coluna "O que entrega" e os números de tela citados nela — os avulsos e
/// os intervalos (`19–27b` = as telas do catálogo de 19 a 27, com sufixo). [numeros] = os números do catálogo.
Map<String, ({String texto, Set<String> telas})> _roteiro(Set<String> numeros) {
  final texto = File('docs/ROTEIRO.md').readAsStringSync();
  final secao = texto.substring(
    texto.indexOf('## 3. Todas as etapas'),
    texto.indexOf('Regras da fila:'),
  );
  final avulso = RegExp(r'(?<![\w\-./])(\d{2,3}[a-d]?)(?![\w%])');
  final intervalo = RegExp(r'(\d{2})–(\d{2})([a-d]?)');
  final out = <String, ({String texto, Set<String> telas})>{};
  for (final l in secao.split('\n')) {
    if (!RegExp(r'^\| \d+ \|').hasMatch(l)) continue;
    final c = _celulas(l);
    final telas = <String>{
      for (final m in avulso.allMatches(c[2]))
        if (numeros.contains(m.group(1))) m.group(1)!,
    };
    for (final m in intervalo.allMatches(c[2])) {
      final de = int.parse(m.group(1)!), ate = int.parse(m.group(2)!);
      telas.addAll(
        numeros.where((n) {
          final v = _partes(n).$1;
          return v >= de && v <= ate;
        }),
      );
    }
    out['${c[0]} · ${c[1]}'] = (texto: c[2], telas: telas);
  }
  return out;
}

void main() {
  final catalogo = _catalogo();
  final numeros = {for (final t in catalogo) t.numero};
  final cobertura = File('docs/design/projeto/COBERTURA.md')
      .readAsStringSync()
      .replaceAll('\r\n', '\n');
  final linhas = _tabela(cobertura, '## As 128 telas');
  final roteiro = _roteiro(numeros);

  test('o catálogo tem as 128 telas (sem o mapa)', () {
    expect(catalogo, hasLength(128));
  });

  test('cada tela do catálogo aparece uma vez, na ordem, com o título e o arquivo do catálogo', () {
    expect(linhas, hasLength(catalogo.length));
    for (var i = 0; i < catalogo.length; i++) {
      final t = catalogo[i];
      expect(linhas[i][0], t.numero, reason: 'linha ${i + 1}');
      expect(linhas[i][1], t.titulo, reason: 'tela ${t.numero}');
      expect(linhas[i][2], '`${t.arquivo}`', reason: 'tela ${t.numero}');
    }
    final arquivos = [for (final l in linhas) l[2]];
    expect(
      arquivos.toSet(),
      hasLength(arquivos.length),
      reason: 'arquivo repetido',
    );
  });

  test('a situação é ✅, 🟠 ou ⬜, e a 🟠 diz o que existe hoje', () {
    for (final l in linhas) {
      expect(['✅', '🟠', '⬜'], contains(l[4]), reason: 'tela ${l[0]}');
      if (l[4] == '🟠') {
        expect(
          l[6],
          isNotEmpty,
          reason: 'tela ${l[0]}: a 🟠 diz o que a rota mostra',
        );
        expect(
          l[3],
          isNot('—'),
          reason: 'tela ${l[0]}: a 🟠 tem onde aparecer',
        );
      }
    }
  });

  test('a etapa da linha existe no ROTEIRO e cita aquela tela', () {
    for (final l in linhas) {
      final etapa = roteiro[l[5]];
      expect(
        etapa,
        isNotNull,
        reason: 'tela ${l[0]}: etapa "${l[5]}" não está no ROTEIRO §3',
      );
      expect(
        etapa!.telas,
        contains(l[0]),
        reason: 'tela ${l[0]}: a etapa ${l[5]} não a cita',
      );
    }
  });

  test('toda tela do catálogo é citada por alguma etapa do ROTEIRO', () {
    final citadas = {for (final e in roteiro.values) ...e.telas};
    expect(numeros.difference(citadas), isEmpty);
  });

  test('as 16 telas do app (Início 01, 01b, 60 e o leitor 19–27b) estão ✅, e só elas', () {
    const prontas = {
      '01', '01b', '60', '19', '20', '21', '22', '23', '23b', '24', '24b', //
      '25', '26', '26b', '27', '27b',
    };
    final feitas = {
      for (final l in linhas)
        if (l[4] == '✅') l[0],
    };
    expect(feitas, prontas);
  });

  test('o resumo soma a tabela', () {
    final resumo = _tabela(cobertura, '## Resumo');
    final todas = resumo.last;
    int conta(String s) => linhas.where((l) => l[4] == s).length;
    expect(todas[1], '**${conta('✅')}**');
    expect(todas[2], '**${conta('🟠')}**');
    expect(todas[3], '**${conta('⬜')}**');
    expect(todas[4], '**128**');
    for (final r in resumo.take(resumo.length - 1)) {
      final daEtapa = linhas.where((l) => l[5] == r[0]).toList();
      expect(int.parse(r[4]), daEtapa.length, reason: r[0]);
      expect(
        int.parse(r[1]),
        daEtapa.where((l) => l[4] == '✅').length,
        reason: r[0],
      );
      expect(
        int.parse(r[2]),
        daEtapa.where((l) => l[4] == '🟠').length,
        reason: r[0],
      );
      expect(
        int.parse(r[3]),
        daEtapa.where((l) => l[4] == '⬜').length,
        reason: r[0],
      );
    }
  });

  test('as 9 que faltam (D-268) têm "abre de" e uma etapa do ROTEIRO que as cita pelo nome', () {
    final faltando = _tabela(
      cobertura,
      '## As 9 que faltam no projeto (D-268)',
    );
    expect(faltando, hasLength(9));
    for (final f in faltando) {
      final nome = f[0].split(' (').first;
      expect(f[1], isNotEmpty, reason: nome);
      for (final n in f[1].split(', ')) {
        expect(numeros, contains(n), reason: '$nome abre de $n');
      }
      final etapa = roteiro[f[3]];
      expect(etapa, isNotNull, reason: '$nome: etapa "${f[3]}"');
      expect(
        etapa!.texto,
        contains(nome),
        reason: '$nome: a etapa ${f[3]} não a cita',
      );
    }
  });
}
