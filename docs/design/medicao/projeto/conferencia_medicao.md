# Conferência — as telas já medidas, medidas de novo pelo projeto (`.dc.html`)

> Gerado por `tools/medicao/comparar_conferencia.py` (T13.3, R3). Não editar à mão: rodar de novo.
> As telas extraídas do projeto por `extrair_dc.py` e medidas com o pipeline da G01/T02 (`CONJUNTO=projeto_conferencia_<grupo> ATE=referencias`), contra o que está commitado. Os layouts são comparados campo a campo sem o que muda pelo método (a origem, a frase do método e a lista `fontFaces`, descrita abaixo); as fontes que cada nó usa de fato (`platformFonts`) entram na comparação.

| Grupo | Telas | Layouts iguais | PNGs iguais | PNGs com diferença explicada | idmaps iguais | Referências Dart iguais |
|---|---|---|---|---|---|---|
| inicio2 | 6 | 8/8 | 33/47 | 14 | 6/6 | 7/7 |
| leitor | 13 | 15/15 | 87/87 | 0 | 13/13 | 15/15 |

## inicio2

O que muda por definição (a origem é outro arquivo):

- measuredWith: Chromium 141 (Playwright 1.56), --font-r → Chromium 141 (Playwright 1.56), --font-render-hinting=none, 
- referencias_inicio2.dart: a linha do título cita o projeto
- source: Redesign_mobile___App_de_leitura__1_.htm → telas/Main.dc.html
- source: Redesign_mobile___App_de_leitura__1_.htm → telas/MainLendo.dc.html
- source: Redesign_mobile___App_de_leitura__1_.htm → telas/MainRevisao.dc.html
- source: Redesign_mobile___App_de_leitura__1_.htm → telas/RevisaoCompartilhar.dc.html
- source: Redesign_mobile___App_de_leitura__1_.htm → telas/RevisaoFim.dc.html
- source: Redesign_mobile___App_de_leitura__1_.htm → telas/RevisaoGrifo.dc.html

As faces com binário local (`fontFaces`), antes → agora (só as telas em que mudam):

- 001_inicio: 11 → 7; só antes: Figtree normal 400 (latin-ext), Figtree normal 500 (latin-ext), Figtree normal 600 (latin-ext), Figtree normal 700 (latin-ext)
- 001b_inicio_lendo_agora: 11 → 7; só antes: Figtree normal 400 (latin-ext), Figtree normal 500 (latin-ext), Figtree normal 600 (latin-ext), Figtree normal 700 (latin-ext)
- 060_inicio_grifos_de_hoje: 11 → 7; só antes: Figtree normal 400 (latin-ext), Figtree normal 500 (latin-ext), Figtree normal 600 (latin-ext), Figtree normal 700 (latin-ext)
- 061_revisao_grifo_2_de_5: 15 → 11; só antes: Figtree normal 400 (latin-ext), Figtree normal 500 (latin-ext), Figtree normal 600 (latin-ext), Figtree normal 700 (latin-ext), Figtree normal 800 (latin-ext); só agora: Literata italic 400 (latin)
- 062_revisao_fim: 15 → 11; só antes: Figtree normal 400 (latin-ext), Figtree normal 500 (latin-ext), Figtree normal 600 (latin-ext), Figtree normal 700 (latin-ext), Figtree normal 800 (latin-ext); só agora: Literata italic 400 (latin)
- 063_revisao_imagem_compartilhar: 15 → 11; só antes: Figtree normal 400 (latin-ext), Figtree normal 500 (latin-ext), Figtree normal 600 (latin-ext), Figtree normal 700 (latin-ext), Figtree normal 800 (latin-ext); só agora: Literata italic 400 (latin)

A face dos números dos redlines (a 1ª Figtree do layout, `recortar.py`): Figtree normal 400 (latin-ext), **sem** os dígitos → Figtree normal 400 (latin), com os dígitos.

Diferenças explicadas (todo pixel diferente dentro de um rótulo numerado do redline):

- png/redline/L01a1_cabecalho_redline@3x.png: 6951 px diferentes, 0 fora dos rótulos
- png/redline/L01a2_heroi_redline@3x.png: 14693 px diferentes, 0 fora dos rótulos
- png/redline/L01a3_tambem_lendo_redline@3x.png: 20052 px diferentes, 0 fora dos rótulos
- png/redline/L01a4_seu_dia_redline@3x.png: 38804 px diferentes, 0 fora dos rótulos
- png/redline/L01a5_revisao_redline@3x.png: 17698 px diferentes, 0 fora dos rótulos
- png/redline/L01a6_para_voce_redline@3x.png: 23510 px diferentes, 0 fora dos rótulos
- png/redline/L01a7_clube_redline@3x.png: 22134 px diferentes, 0 fora dos rótulos
- png/redline/L01a8_recem_chegados_redline@3x.png: 25378 px diferentes, 0 fora dos rótulos
- png/redline/L01a9_barra_redline@3x.png: 12998 px diferentes, 0 fora dos rótulos
- png/redline/L01b_lendo_agora_redline@3x.png: 42725 px diferentes, 0 fora dos rótulos
- png/redline/L60_grifos_de_hoje_redline@3x.png: 34924 px diferentes, 0 fora dos rótulos
- png/redline/L61_revisao_grifo_redline@3x.png: 32714 px diferentes, 0 fora dos rótulos
- png/redline/L62_revisao_fim_redline@3x.png: 60334 px diferentes, 0 fora dos rótulos
- png/redline/L63_compartilhar_grifo_redline@3x.png: 40832 px diferentes, 0 fora dos rótulos

Diferenças sem explicação: nenhuma.

## leitor

O que muda por definição (a origem é outro arquivo):

- measuredWith: Chromium 141 (Playwright 1.56), --font-r → Chromium 141 (Playwright 1.56), --font-render-hinting=none, 
- source: Redesign mobile — App de leitura (1).htm → telas/Grifos.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorAjustes.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorAnotacao.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorCaneta.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorControles.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorEspaco.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorEspacoAbrir.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorLimpo.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorMarcadas.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorMarcador.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorNoite.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorSelecao.dc.html
- source: Redesign mobile — App de leitura (1).htm → telas/LeitorSumario.dc.html

As faces com binário local (`fontFaces`), antes → agora (só as telas em que mudam):

- 19_leitor_limpo: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 20_leitor_controles: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 21_selecao_texto: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 22_modo_anotacao: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 23_ajustes_caneta: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 23b_ajustes_marcatexto: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 24_abrindo_espaco: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 24b_nota_mao: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 25_grifos_notas: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 26_ajustes_leitura: 12 → 15; só agora: Atkinson Hyperlegible normal 700 (latin), Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 26b_tema_noite: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 27_sumario: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)
- 27b_sumario_marcadas: 9 → 11; só agora: Instrument Serif normal 400 (latin), Literata italic 400 (latin)

A face dos números dos redlines (a 1ª Figtree do layout, `recortar.py`): Figtree normal 400 (latin), com os dígitos → Figtree normal 400 (latin), com os dígitos.

Diferenças sem explicação: nenhuma.
