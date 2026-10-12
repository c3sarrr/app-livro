# FASE L28c — Busca (nada encontrado) — o desenho, o texto, Escanear e Adicionar à mão, e as dicas

> Tela 28c · prancha `028c_busca_nada_encontrado` (28c · Busca — nada encontrado, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28c_nada_encontrado@3x.png` · `docs/design/medicao/projeto/png/redline/L28c_nada_encontrado_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028c_busca_nada_encontrado_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028c_busca_nada_encontrado.json` · `test/reference/projeto/reference_layout_028c_busca_nada_encontrado.dart` (`kRef28c`).
> Arquivos sugeridos: `lib/features/search/presentation/search_nothing_found.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Nada encontrado (28c): a figurinha do livro com a lupa, "Nada por aqui… ainda.", o texto com o termo buscado ("receitas da vó cida"), "Escanear o código de barras" (amarelo), "Adicionar à mão" (preto) e o quadro tracejado das dicas.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- sticker: a book with a magnifier finding nothing -->
<svg aria-hidden="true" width="210" height="170" viewBox="0 0 210 170" style="display: block; margin: 26px auto 0; overflow: visible;">
  <g transform="rotate(-8 90 90)">
    <rect x="44" y="26" width="96" height="128" rx="8" fill="#1A1714" transform="translate(5 5)"></rect>
    <rect x="44" y="26" width="96" height="128" rx="8" fill="#FFC1C6" stroke="#1A1714" stroke-width="1.6"></rect>
    <path d="M56 26v128" stroke="#1A1714" stroke-width="1.6"></path>
    <rect x="68" y="44" width="58" height="10" rx="3" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.4"></rect>
    <rect x="68" y="60" width="40" height="7" rx="3" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.4"></rect>
    <text x="97" y="122" text-anchor="middle" font-family="'Instrument Serif', Georgia, serif" font-style="italic" font-size="44" fill="#1A1714">?</text>
  </g>
  <circle cx="150" cy="104" r="30" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.8"></circle>
  <circle cx="150" cy="104" r="21" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.6"></circle>
  <path d="M171 126l20 20" stroke="#1A1714" stroke-width="7" stroke-linecap="round"></path>
  <path d="M171 126l20 20" stroke="#FED170" stroke-width="3.5" stroke-linecap="round"></path>
  <g transform="translate(16 18) scale(1.1)"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></g>
  <g transform="translate(180 30) scale(.7)"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></g>
</svg>

<h1 style="margin: 18px 0 0; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 30px; line-height: 1; letter-spacing: -0.8px;">Nada por aqui<span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 36px;">… ainda.</span></h1>

<p style="margin: 10px auto 0; max-width: 300px; text-align: center; font-size: 14.5px; font-weight: 600; line-height: 1.45; color: #5B544B; text-wrap: pretty;">Não achamos <strong style="font-weight: 800; color: #1A1714;">“receitas da vó cida”</strong>. Livro de família, edição antiga ou independente? Dá para adicionar mesmo assim.</p>

<a href="#" style="margin-top: 22px; height: 56px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16"></path><path d="M8 8v8M11 8v8M14 8v8M17 8v8"></path></svg>Escanear o código de barras</a>

<a href="#" style="margin-top: 12px; height: 56px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg><span style="color: #F7F0E3;">Adicionar à mão</span></a>

<div style="margin-top: 24px; padding: 14px 16px; border-radius: 18px; border: 1.5px dashed #1A1714;">
  <span style="display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">DICAS</span>
  <ul style="margin: 8px 0 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 7px; font-size: 14px; font-weight: 600; line-height: 1.35;">
    <li style="display: flex; gap: 8px;"><span style="color: #FF552E; font-weight: 800;">→</span>Confira a grafia ou use menos palavras</li>
    <li style="display: flex; gap: 8px;"><span style="color: #FF552E; font-weight: 800;">→</span>Tente pelo nome do autor ou pelo ISBN</li>
    <li style="display: flex; gap: 8px;"><span style="color: #FF552E; font-weight: 800;">→</span>O ISBN fica no verso, perto do código de barras</li>
  </ul>
</div>
```

## Especificação pixel a pixel

Seção `bu28c.illustration` — retângulo absoluto no canvas 390×844: **x=90, y=148, w=210, h=170**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28c.illustration` | icon | 0 | 0 | 210 | 170 | `display: block; margin: 26px auto 0; overflow: visible` | Figtree 16/normal peso 400 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28c.illustration` *(composto)* | 1 | ? | 120.04 | 87.52 | 111.08 | 23.56 |

Seção `bu28c.title` — retângulo absoluto no canvas 390×844: **x=16, y=336, w=358, h=36**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `bu28c.title` | text | 0 | 0 | 358 | 36 | `margin: 18px 0 0; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 30px; line-height: 1; letter-spacing: -0.8px` | Bricolage (opsz 30) 30/30px peso 800 ls -0.8px #1A1714 |
| 3 | `bu28c.title.serif` ±1 | inline | 222.26 | -5.4 | 107.32 | 46.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 36px` | Instrument Serif itálico 36/36px peso 400 ls -0.8px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28c.title` *(composto)* | 1 | Nada por aqui… ainda. | 30.24 | 28.41 | 329.58 | 301.17 |

Seção `bu28c.body` — retângulo absoluto no canvas 390×844: **x=45, y=382, w=300, h=63.08**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `bu28c.body` | text | 0 | 0 | 300 | 63.08 | `margin: 10px auto 0; max-width: 300px; text-align: center; font-size: 14.5px; font-weight: 600; line-height: 1.45; color: #5B544B; text-wrap: pretty` | Figtree 14.5/21.025px peso 600 ls normal #5B544B |
| 5 | `bu28c.body.query` ±1 | inline | 97 | 1.8 | 139.4 | 17.41 | `font-weight: 800; color: #1A1714` | Figtree 14.5/21.025px peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28c.body` *(composto)* | 1 | Não achamos “receitas da vó cida”. Livro de | 15.58 | 3.83 | 296.17 | 292.34 |
| `bu28c.body` *(composto)* | 2 | família, edição antiga ou independente? Dá | 36.61 | 8.32 | 291.68 | 283.36 |
| `bu28c.body` *(composto)* | 3 | para adicionar mesmo assim. | 57.63 | 55.39 | 244.61 | 189.22 |

Seção `bu28c.actions` — retângulo absoluto no canvas 390×844: **x=16, y=467.07, w=358, h=124**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `bu28c.actions.scan` | box+text | 0 | 0 | 358 | 56 | `margin-top: 22px; height: 56px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800` | Figtree 16/normal peso 800 ls normal #1A1714 |
| 7 | `bu28c.actions.scan.icon` ±1 | icon | 58.57 | 17 | 22 | 22 | `—` |  |
| 8 | `bu28c.actions.manual` | box | 0 | 68.01 | 358 | 56 | `margin-top: 12px; height: 56px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 9 | `bu28c.actions.manual.icon` ±1 | icon | 103.86 | 86.01 | 20 | 20 | `—` |  |
| 10 | `bu28c.actions.manual.label` ±1 | text | 133.86 | 86.41 | 120.27 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28c.actions.scan` | 1 | Escanear o código de barras | 33.61 | 90.57 | 299.43 | 208.86 |
| `bu28c.actions.manual.label` | 1 | Adicionar à mão | 101.6 | 133.86 | 254.14 | 120.28 |

Seção `bu28c.tips` — retângulo absoluto no canvas 390×844: **x=16, y=615.08, w=358, h=141.8**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 11 | `bu28c.tips` | box | 0 | 0 | 358 | 141.8 | `margin-top: 24px; padding: 14px 16px; border-radius: 18px; border: 1.5px dashed #1A1714` |  |
| 12 | `bu28c.tips.label` | text | 17.5 | 15.5 | 323 | 13.2 | `display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 13 | `bu28c.tips.list` | box | 17.5 | 36.69 | 323 | 89.6 | `margin: 8px 0 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 7px; font-size: 14px; font-weight: 600; line-height: 1.35` |  |
| 14 | `bu28c.tips.tip1` | text | 17.5 | 36.69 | 323 | 18.9 | `display: flex; gap: 8px` | Figtree 14/18.9px peso 600 ls normal #1A1714 |
| 15 | `bu28c.tips.tip1.arrow` ±1 | text | 17.5 | 36.69 | 13.36 | 18.9 | `color: #FF552E; font-weight: 800` | Figtree 14/18.9px peso 800 ls normal #FF552E |
| 16 | `bu28c.tips.tip2` | text | 17.5 | 62.59 | 323 | 18.9 | `display: flex; gap: 8px` | Figtree 14/18.9px peso 600 ls normal #1A1714 |
| 17 | `bu28c.tips.tip2.arrow` ±1 | text | 17.5 | 62.59 | 13.36 | 18.9 | `color: #FF552E; font-weight: 800` | Figtree 14/18.9px peso 800 ls normal #FF552E |
| 18 | `bu28c.tips.tip3` | text | 17.5 | 88.5 | 323 | 37.8 | `display: flex; gap: 8px` | Figtree 14/18.9px peso 600 ls normal #1A1714 |
| 19 | `bu28c.tips.tip3.arrow` ±1 | text | 17.5 | 88.5 | 13.36 | 37.8 | `color: #FF552E; font-weight: 800` | Figtree 14/18.9px peso 800 ls normal #FF552E |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28c.tips.label` | 1 | DICAS | 25.94 | 17.5 | 57.2 | 39.7 |
| `bu28c.tips.tip1` | 1 | Confira a grafia ou use menos palavras | 51.04 | 38.86 | 284.09 | 245.23 |
| `bu28c.tips.tip1.arrow` | 1 | → | 51.04 | 17.5 | 30.86 | 13.36 |
| `bu28c.tips.tip2` | 1 | Tente pelo nome do autor ou pelo ISBN | 76.94 | 38.86 | 287.37 | 248.51 |
| `bu28c.tips.tip2.arrow` | 1 | → | 76.94 | 17.5 | 30.86 | 13.36 |
| `bu28c.tips.tip3` | 1 | O ISBN fica no verso, perto do código de | 102.84 | 38.86 | 297.93 | 259.07 |
| `bu28c.tips.tip3` | 2 | barras | 121.75 | 38.86 | 78.5 | 39.64 |
| `bu28c.tips.tip3.arrow` | 1 | → | 102.84 | 17.5 | 30.86 | 13.36 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Desenho 210 × 170 centrado, 26 abaixo da barra (`buscaNadaEncontrado`, `overflow: visible`), com o "?" em Instrument Serif 44.
2. Título centrado 18 abaixo: "Nada por aqui" Bricolage 30/800 `lh 1` ls −0,8 + "… ainda." Instrument Serif itálico 36; o texto 14,5/600 `lh 1,45`, `max-width 300`, `text-wrap: pretty`, com o termo entre aspas em 800 `#1A1714`.
3. Botões de 56 (gap 12, 22 abaixo): Escanear `#FED170` com sombra 3/3 e o ícone 22; Adicionar à mão preto com o "+" 20 `#F7F0E3`; ambos 16/800.
4. Dicas, 24 abaixo: padding 14/16, raio 18, borda 1,5 `dashed`; "DICAS" 11/800 ls 1,2 `#6F665B` e a lista (gap 7, 14/600 `lh 1,35`) com a seta "→" coral 800 em cada item (gap 8).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O "→" não existe na Figtree 800: o Chromium usa a Inter ExtraBold do sistema (R8, abaixo). No app, a seta vira um ícone ou um glifo de fonte embutida — pergunta da T15 (a largura do item muda).
- A 3ª dica fica num fio de navalha (0,45, abaixo): o `<li>` é flex com a seta como outro item — a largura da frase é a do `<li>` menos a seta e o gap (D-280).
- `text-wrap: pretty` muda as quebras no Chromium: as linhas da tabela são as do navegador — conferir as quebras no app com o termo da fixture.
- Fio de navalha em `bu28c.tips.tip3` linha 1 «O ISBN fica no verso, perto do código de»: sobra 42.57 px · estouro com a próxima palavra 0.45 px.
- `bu28c.tips.tip1` usa glifo de fonte do sistema (Inter ExtraBold (1 glifo(s))) — no navegador o resultado depende da máquina.
- `bu28c.tips.tip1.arrow` usa glifo de fonte do sistema (Inter ExtraBold (1 glifo(s))) — no navegador o resultado depende da máquina.
- `bu28c.tips.tip2` usa glifo de fonte do sistema (Inter ExtraBold (1 glifo(s))) — no navegador o resultado depende da máquina.
- `bu28c.tips.tip2.arrow` usa glifo de fonte do sistema (Inter ExtraBold (1 glifo(s))) — no navegador o resultado depende da máquina.
- `bu28c.tips.tip3` usa glifo de fonte do sistema (Inter ExtraBold (1 glifo(s))) — no navegador o resultado depende da máquina.
- `bu28c.tips.tip3.arrow` usa glifo de fonte do sistema (Inter ExtraBold (1 glifo(s))) — no navegador o resultado depende da máquina.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028c_busca_nada_encontrado_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028c_busca_nada_encontrado_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 28b (seções reutilizadas: searchBar)

Estas seções são as mesmas widgets da 28b (fases L28b_1_abas_e_livros, L28b_2_clubes_e_trechos); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `bu28c.searchBar` | position: {"top": "54px", "right": "16px", "bottom": "936px", "left": "16px"} → {"top": "54px", "right": "16px", "bottom": "740px", "left": "16px"} |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28c.illustration` |  |  | aria-hidden=true |
| `bu28c.actions.scan.icon` |  |  | aria-hidden=true |
| `bu28c.actions.manual.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28c.illustration` | AppSvg(AppIllustrationsScanner.buscaNadaEncontrado, size: 210×170) | tem `<text>` (o "?" em Instrument Serif 44): o flutter_svg desenharia o texto com a fonte do sistema → no app o AppSvg lê o desenho sem os textos e eles voltam em AppText nas mesmas posições (como as capas da Início, T03.7). |
| `bu28c.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `bu28c.body.query` | TextSpan dentro do AppText.rich do pai |  |
| `bu28c.actions.scan` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28c.actions.scan.icon` | AppSvg(AppIconsScanner.scanBarcodeBusca, size: 22) |  |
| `bu28c.actions.manual` | NeoBox |  |
| `bu28c.actions.manual.icon` | AppSvg(AppIconsScanner.plusAddPapel, size: 20) |  |
| `bu28c.tips` | NeoBox |  |

## Interações

- Escanear o código de barras → o Scanner.
- Adicionar à mão → a 28d com o título já preenchido pelo que foi buscado.

## Dados

- O termo buscado (exato, entre aspas); o resto é texto do app.

## Subfases

- **L28c.1** Figurinha e título
- **L28c.2** Texto com o termo
- **L28c.3** Escanear e Adicionar à mão
- **L28c.4** Dicas
- **L28c.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28c.illustration', 'bu28c.title', 'bu28c.body', 'bu28c.actions', 'bu28c.tips'), todos os ids de `kRef28c.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028c_busca_nada_encontrado_390x844@3x.png` no recorte da fase (y 140–764.88) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28cw360` e `kRef28cw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28c.1 Figurinha e título
- [ ] L28c.2 Texto com o termo
- [ ] L28c.3 Escanear e Adicionar à mão
- [ ] L28c.4 Dicas
- [ ] L28c.5 Verificação + relatório
- [ ] Geometria 17/17 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
