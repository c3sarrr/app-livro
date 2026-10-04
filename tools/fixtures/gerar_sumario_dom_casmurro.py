"""G03 · sumário de Dom Casmurro para a fixture do mundo de referência (D-34).

Gera test/fixtures/sumario_dom_casmurro.dart: os 148 capítulos com numeral romano, título e página
de início (páginas de referência do arquivo — "de 256").

* Títulos: ortografia atual. Os 13 que aparecem na tela 27 (XXV–XXXVII) são os do arquivo, LITERAIS
  (inclusive "Ideia sem pernas", que o arquivo abrevia); os demais são os do livro (domínio público),
  atualizados à ortografia de hoje.
* Páginas: os números do arquivo são ilustrativos (Anexo 01 §14, D-19). Os 13 visíveis são literais e
  o cap. I começa na pág. 3 (marcador "pág. 3 · cap. I" da tela 27b); os outros são interpolados pela
  posição do capítulo no texto do Projeto Gutenberg (eBook #55752, domínio público) entre esses pontos
  e o fim (256). Conferido: pág. 6 cai no cap. II, pág. 41 no IX, 121 no XXV, 152 no XXXI, 159 no XXXII.

Uso:  python3 tools/fixtures/gerar_sumario_dom_casmurro.py [caminho/do/pg55752.txt]
      (padrão: spikes/_dados/pg55752.txt, baixado pelo spike S3 da G02)
"""
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parents[2]
SAIDA = RAIZ / 'test' / 'fixtures' / 'sumario_dom_casmurro.dart'

TITULOS = [
    'Do título', 'Do livro', 'A denúncia', 'Um dever amaríssimo!', 'O agregado', 'Tio Cosme',
    'D. Glória', 'É tempo!', 'A ópera', 'Aceito a teoria', 'A promessa', 'Na varanda', 'Capitu',
    'A inscrição', 'Outra voz repentina', 'O administrador interino', 'Os vermes', 'Um plano',
    'Sem falta', 'Mil padre-nossos e mil ave-marias', 'Prima Justina', 'Sensações alheias',
    'Prazo dado', 'De mãe e de servo',
    # XXV–XXXVII: literais do arquivo (tela 27)
    'No Passeio Público', 'As leis são belas', 'Ao portão', 'Na rua', 'O imperador', 'O Santíssimo',
    'As curiosidades de Capitu', 'Olhos de ressaca', 'O penteado', 'Sou homem!',
    'O protonotário apostólico', 'Ideia sem pernas', 'A alma é cheia de mistérios',
    # XXXVIII em diante
    'Que susto, meu Deus!', 'A vocação', 'Uma égua', 'A audiência secreta', 'Capitu refletindo',
    'Você tem medo?', 'O primeiro filho', 'Abane a cabeça, leitor', 'As pazes', '“A senhora saiu”',
    'Juramento do poço', 'Uma vela aos sábados', 'Um meio-termo', 'Entre luz e fusco',
    'O velho Pádua', 'A caminho!', 'Panegírico de Santa Mônica', 'Um soneto', 'Um seminarista',
    'De preparação', 'O tratado', 'Convivas de boa memória', 'Querido opúsculo!', 'A vaca de Homero',
    'Uma ponta de Iago', 'Metades de um sonho', 'Uma ideia e um escrúpulo', 'A dissimulação',
    'Intimidade', 'Um pecado', 'Adiemos a virtude', 'A missa', 'Depois da missa',
    'Visita de Escobar', 'Uma reforma dramática', 'O contrarregra', 'A presilha', 'O desespero',
    'Explicação', 'Prazer das dores velhas', 'Segredo por segredo', 'Vamos ao capítulo',
    'Venhamos ao capítulo', 'Uma palavra', 'O canapé', 'O retrato', 'Chamado', 'O defunto',
    'Amai, rapazes!', 'A sege', 'Um pretexto honesto', 'A recusa', 'A polêmica',
    'Achado que consola', 'O diabo não é tão feio como se pinta', 'Um amigo por um defunto',
    'Ideias aritméticas', 'O papa', 'Um substituto', 'A saída', 'Cinco anos',
    'O filho é a cara do pai', '“Tu serás feliz, Bentinho!”', 'No céu', 'De casada',
    'A felicidade tem boa alma', 'As pirâmides', 'Os braços', 'Dez libras esterlinas',
    'Ciúmes do mar', 'Um filho', 'Um filho único', 'Rasgos da infância', 'Contado depressa',
    'As imitações de Ezequiel', 'Embargos de terceiro', 'Em que se explica o explicado',
    'Dúvidas sobre dúvidas', 'Filho do homem', 'Amigos próximos', 'A mão de Sancha',
    'Não faça isso, querida', 'Os autos', 'A catástrofe', 'O enterro', 'Olhos de ressaca',
    'O discurso', 'Uma comparação', 'Cismando', 'O barbeiro', 'Punhado de sucessos', 'A D. Sancha',
    'Um dia...', 'Anterior ao anterior', 'O debuxo e o colorido', 'Uma ideia', 'O dia de sábado',
    'Otelo', 'A xícara de café', 'Segundo impulso', 'Capitu que entra', 'A fotografia',
    'Volta da igreja', 'A solução', 'Uma santa', 'O último superlativo', 'Uma pergunta tardia',
    'O regresso', 'Não houve lepra', 'A exposição retrospectiva', 'E bem, e o resto?',
]

# Páginas literais do arquivo (capítulo 1-based → página de início).
PAGINAS_DO_ARQUIVO = {
    1: 3, 25: 121, 26: 126, 27: 131, 28: 136, 29: 141, 30: 146, 31: 152, 32: 157, 33: 163,
    34: 166, 35: 170, 36: 175, 37: 179,
}
TOTAL_DE_PAGINAS = 256


def romano(n):
    valores = [(100, 'C'), (90, 'XC'), (50, 'L'), (40, 'XL'), (10, 'X'), (9, 'IX'), (5, 'V'),
               (4, 'IV'), (1, 'I')]
    s = ''
    for v, r in valores:
        while n >= v:
            s += r
            n -= v
    return s


def main():
    origem = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else RAIZ / 'spikes' / '_dados' / 'pg55752.txt'
    texto = origem.read_text(encoding='utf-8')
    cabecalhos = list(re.finditer(r'\n\n\n+([IVXLC]+)\.?\n\n', texto))
    assert [m.group(1) for m in cabecalhos] == [romano(i) for i in range(1, 149)], 'capítulos'
    assert len(TITULOS) == 148
    inicios = [m.start() for m in cabecalhos]
    fim = texto.index('\nFIM')
    pontos = [(inicios[c - 1], p) for c, p in sorted(PAGINAS_DO_ARQUIVO.items())]
    pontos.append((fim, TOTAL_DE_PAGINAS + 1))

    def pagina(c):
        for (c0, p0), (c1, p1) in zip(pontos, pontos[1:]):
            if c0 <= c <= c1:
                return p0 + (p1 - p0) * (c - c0) / (c1 - c0)
        raise ValueError(c)

    paginas = [PAGINAS_DO_ARQUIVO.get(i, int(pagina(inicios[i - 1]))) for i in range(1, 149)]
    assert all(a <= b for a, b in zip(paginas, paginas[1:])), 'páginas crescentes'
    assert paginas[-1] <= TOTAL_DE_PAGINAS

    def capitulo_da_pagina(p):
        return max(i for i in range(148) if paginas[i] <= p) + 1

    for p, c in [(3, 1), (6, 2), (41, 9), (121, 25), (152, 31), (159, 32)]:
        assert capitulo_da_pagina(p) == c, (p, c, capitulo_da_pagina(p))

    linhas = [
        '// GERADO por tools/fixtures/gerar_sumario_dom_casmurro.py — não editar à mão.',
        '// Sumário de Dom Casmurro do mundo de referência (D-34): numeral, título e página de início.',
        '// XXV–XXXVII e a pág. 3 do cap. I são literais do arquivo; o resto é interpolado (ver o script).',
        '',
        'typedef CapituloDoSumario = ({String numeral, String titulo, int pagina});',
        '',
        'const List<CapituloDoSumario> sumarioDomCasmurro = [',
    ]
    for i, (t, p) in enumerate(zip(TITULOS, paginas), start=1):
        titulo = t.replace('\\', '\\\\').replace("'", "\\'")
        linha = f"  (numeral: '{romano(i)}', titulo: '{titulo}', pagina: {p}),"
        if len(linha) <= 80:
            linhas.append(linha)
        else:  # como o `dart format` quebra (largura 80)
            linhas += ['  (', f"    numeral: '{romano(i)}',", f"    titulo: '{titulo}',",
                       f'    pagina: {p},', '  ),']
    linhas.append('];')
    SAIDA.write_text('\n'.join(linhas) + '\n', encoding='utf-8', newline='\n')
    print(f'{SAIDA.relative_to(RAIZ)}: 148 capítulos; XXXII começa na pág. {paginas[31]}')


if __name__ == '__main__':
    main()
