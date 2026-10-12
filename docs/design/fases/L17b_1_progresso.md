# FASE L17b — Detalhes (e-book) — cartão do progresso (onde parou, barra, Continuar lendo, grifos)

> Tela 17b · prancha `017b_detalhes_ebook` (17b · Detalhes do livro — e-book (Dom Casmurro), canvas 390×1790) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L17b_1_progresso@3x.png` · `docs/design/medicao/projeto/png/redline/L17b_1_progresso_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/017b_detalhes_ebook_390x1790@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_017b_detalhes_ebook.json` · `test/reference/projeto/reference_layout_017b_detalhes_ebook.dart` (`kRef17b`).
> Arquivos sugeridos: `lib/features/library/presentation/details/ebook_progress_card.dart`, `lib/features/library/presentation/details/book_details_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Detalhes do e-book (17b, Dom Casmurro): as seções da 17 (sol lavanda, capa, título, status, clima, sinopse) e, no lugar do cartão da sessão, o cartão lavanda do progresso — onde parou (pág. 159 de 256), 62 % em Instrument Serif, a barra, o tempo para terminar, "Continuar lendo" e os grifos (12).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{halo}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- Digital book: progress saves itself -->
<section aria-label="Progresso" style="margin-top: 18px; padding: 16px; border-radius: 24px; background: {{brand}}; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box;">
  <div style="display: flex; align-items: flex-end; justify-content: space-between; gap: 10px;">
    <div>
      <div style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #2C2452;">ONDE VOCÊ PAROU</div>
      <div style="margin-top: 4px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.5px;">Pág. 159 <span style="font-size: 15px; font-weight: 700; color: #2C2452;">de 256</span></div>
    </div>
    <div style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 44px; line-height: 0.9;">62%</div>
  </div>
  <div style="margin-top: 12px; display: flex;"><span style="position: relative; display: block; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#CFC6EE 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 62%; background: #1A1714;"><svg width="10" height="15" viewBox="0 0 10 15" preserveAspectRatio="none" style="position: absolute; top: 0; right: -5px; height: 100%;"><path d="M0 0H5Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15H0Z" fill="#1A1714"></path><path d="M5 0Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15" fill="none" stroke="#1A1714" stroke-width="1.5" vector-effect="non-scaling-stroke"></path></svg></span></span></div>
  <div style="margin-top: 8px; font-size: 13px; font-weight: 600; color: #2C2452;">≈ 2 h 10 min para terminar · salvo sozinho</div>
  <div style="margin-top: 14px; display: flex; gap: 10px;">
    <button style="flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 4h6a4 4 0 0 1 4 4v13a3 3 0 0 0-3-3H2z"></path><path d="M22 4h-6a4 4 0 0 0-4 4v13a3 3 0 0 1 3-3h7z"></path></svg>
      <span style="color: #F7F0E3;">Continuar lendo</span>
    </button>
    <button aria-label="Grifos deste livro (12)" style="position: relative; width: 54px; height: 54px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 11-6 6v3h9l3-3"></path><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"></path></svg>
      <span style="position: absolute; top: -4px; right: -4px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center;">12</span>
    </button>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `d17b.progress` — retângulo absoluto no canvas 390×1790: **x=20, y=678.16, w=350, h=195.14**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `d17b.progress` | box | 0 | 0 | 350 | 195.14 | `margin-top: 18px; padding: 16px; border-radius: 24px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box` |  |
| 2 | `d17b.progress.top` | box | 17.5 | 17.5 | 315 | 40.3 | `display: flex; align-items: flex-end; justify-content: space-between; gap: 10px` |  |
| 3 | `d17b.progress.textBlock` ±1 | box | 17.5 | 17.5 | 133.61 | 40.3 | `—` |  |
| 4 | `d17b.progress.kicker` ±1 | text | 17.5 | 17.5 | 133.61 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #2C2452` | Figtree 11/normal peso 800 ls 1.2px #2C2452 |
| 5 | `d17b.progress.page` ±1 | text | 17.5 | 34.7 | 133.61 | 23.1 | `margin-top: 4px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/23.1px peso 800 ls -0.5px #1A1714 |
| 6 | `d17b.progress.page.total` ±1 | inline | 104.39 | 39.56 | 46.72 | 18 | `font-size: 15px; font-weight: 700; color: #2C2452` | Bricolage (opsz 15) 15/15.75px peso 700 ls -0.5px #2C2452 |
| 7 | `d17b.progress.percent` ±1 | text | 270.64 | 18.2 | 61.86 | 39.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 44px; line-height: 0.9` | Instrument Serif itálico 44/39.6px peso 400 ls normal #1A1714 |
| 8 | `d17b.progress.bar` | box | 17.5 | 69.8 | 315 | 16 | `margin-top: 12px; display: flex` |  |
| 9 | `d17b.progress.bar.track` | box | 17.5 | 69.8 | 315 | 16 | `position: relative; display: block; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#CFC6EE 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden` |  |
| 10 | `d17b.progress.bar.fill` | box | 19 | 71.3 | 193.44 | 13 | `position: absolute; left: 0; top: 0; bottom: 0; width: 62%; background: #1A1714` |  |
| 11 | `d17b.progress.bar.fill.edge` | icon | 207.44 | 71.3 | 10 | 13 | `position: absolute; top: 0; right: -5px; height: 100%` |  |
| 12 | `d17b.progress.timeLeft` | text | 17.5 | 93.8 | 315 | 15.84 | `margin-top: 8px; font-size: 13px; font-weight: 600; color: #2C2452` | Figtree 13/normal peso 600 ls normal #2C2452 |
| 13 | `d17b.progress.actions` | box | 17.5 | 123.64 | 315 | 54 | `margin-top: 14px; display: flex; gap: 10px` |  |
| 14 | `d17b.progress.continue` | box | 17.5 | 123.64 | 251 | 54 | `flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 15 | `d17b.progress.continue.icon` ±1 | icon | 68.3 | 140.64 | 20 | 20 | `—` |  |
| 16 | `d17b.progress.continue.label` ±1 | text | 98.3 | 141.04 | 119.41 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 17 | `d17b.progress.highlights` | box | 278.5 | 123.64 | 54 | 54 | `position: relative; width: 54px; height: 54px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 18 | `d17b.progress.highlights.icon` | icon | 294.5 | 139.64 | 22 | 22 | `—` |  |
| 19 | `d17b.progress.highlights.badge` ±1 | box+text | 310.85 | 121.14 | 24.15 | 22 | `position: absolute; top: -4px; right: -4px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 11/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17b.progress.kicker` | 1 | ONDE VOCÊ PAROU | 27.95 | 17.5 | 141.59 | 124.09 |
| `d17b.progress.page` *(composto)* | 1 | Pág. 159 de 256 | 53.51 | 17.5 | 151.11 | 133.61 |
| `d17b.progress.percent` | 1 | 62% | 52.96 | 270.64 | 332.5 | 61.86 |
| `d17b.progress.timeLeft` | 1 | ≈ 2 h 10 min para terminar · salvo sozinho | 106.39 | 17.5 | 260.29 | 242.79 |
| `d17b.progress.continue.label` | 1 | Continuar lendo | 156.24 | 98.3 | 217.7 | 119.4 |
| `d17b.progress.highlights.badge` | 1 | 12 | 135.99 | 317.35 | 328.5 | 11.15 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cartão 18 abaixo do status: padding 16, raio 24, `{{brand}}`, borda 1,5, sombra 4/4. Em cima (`align-items: flex-end`, `space-between`): "ONDE VOCÊ PAROU" 11/800 ls 1,2 `#2C2452` e, 4 abaixo, "Pág. 159" Bricolage 22/800 + "de 256" 15/700 `#2C2452`; à direita, "62%" Instrument Serif itálico 44 `lh 0,9`.
2. Barra, 12 abaixo: 16 de altura, borda 1,5, hachura 135° `#CFC6EE`/`#FFFAF1`, o preto até 62 % com a ponta ondulada (o desenho do clima, em preto).
3. "≈ 2 h 10 min para terminar · salvo sozinho" 13/600 `#2C2452`, 8 abaixo; os botões 14 abaixo (gap 10): "Continuar lendo" (`flex 1`, 54, preto, livro aberto 20 `#F7F0E3` + 16/800) e o círculo 54 dos grifos com o marca-texto 22 e o contador "12" (pílula 22, `#FED170`, 11/800, `top/right −4`).
4. O que muda da 17 (a tabela "Diferenças"): o sol lavanda, a capa roxa, o título maior (40 e 52, "Dom / Casmurro": tudo desce 13,72), "E-BOOK" na etiqueta, o ano e o formato, os climas (misterioso, reflexivo, romântico, tenso) e a sinopse com uma linha a menos (a ficha sobe 41,94).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O "≈" não existe na Figtree: o Chromium o desenha com a Inter SemiBold do sistema (R8, declarado no índice). No app o Flutter cai na fonte de reserva do aparelho — trocar por "~" (como a Início: "~2h 10min") ou embutir o glifo é pergunta da T14 (a largura da linha muda).
- Fio de navalha na fileira 1 de `d17b.meta` (seção reaproveitada da 17; o risco é desta prancha) (flex-wrap) «Machado de Assis | d17b.meta.dot | 1899»: sobra 170.11 px · estouro com o 1º item da fileira seguinte 0.47 px — no Flutter (`Wrap`), as fileiras mudam com uma diferença mínima de largura.
- `d17b.progress` usa glifo de fonte do sistema (Inter SemiBold (1 glifo(s))) — no navegador o resultado depende da máquina.
- `d17b.progress.timeLeft` usa glifo de fonte do sistema (Inter SemiBold (1 glifo(s))) — no navegador o resultado depende da máquina.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_017b_detalhes_ebook_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_017b_detalhes_ebook_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 17 (seções reutilizadas: halo, header, cover, title, meta, status, mood, synopsis)

Estas seções são as mesmas widgets da 17 (fases L17_1_capa, L17_2_titulo_e_status, L17_3_sessao, L17_4_clima, L17_5_sinopse, L17_6_grifos_e_clube); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `d17b.halo` | bgImage: "repeating-conic-gradient(#ABCF82 0deg, #ABCF82 9deg, #FFFAF1 9deg, #FFFAF1 18deg)" → "repeating-conic-gradient(#B6ACE4 0deg, #B6ACE4 9deg, #FFFAF1 9deg, #FFFAF1 18deg)"; position: {"top": "58px", "right": "30px", "bottom": "1552px", "left": "195px"} → {"top": "58px", "right": "30px", "bottom": "1402px", "left": "195px"} |
| `d17b.halo.center` | position: {"top": "168px", "right": "140px", "bottom": "1662px", "left": "195px"} → {"top": "168px", "right": "140px", "bottom": "1512px", "left": "195px"} |
| `d17b.cover.book` | bg: "#058CD7" → "#552CB7" |
| `d17b.cover.formatTag` | retângulo ['247', '118', '85.06', '30'] → ['247', '118', '95.22', '30']; position: {"top": "10px", "right": "37.942px", "bottom": "290px", "left": "175px"} → {"top": "10px", "right": "27.78px", "bottom": "290px", "left": "175px"}; texto «PAPEL» → «E-BOOK» |
| `d17b.title` | retângulo ['20', '440', '350', '76.44'] → ['20', '440', '350', '90.16']; fonte lineHeight: 33.32px → 39.2px; opsz: 34.0 → 40.0; size: 34.0 → 40.0; texto «Memórias Póstumas / de Brás Cubas» → «Dom / Casmurro» |
| `d17b.title.serif` | retângulo ['20', '466.28', '210.55', '57.2'] → ['20', '470.88', '185.07', '67.6']; fonte lineHeight: 43.12px → 50.96px; size: 44.0 → 52.0; texto «de Brás Cubas» → «Casmurro» |
| `d17b.meta` (seção inteira) | muda de lugar: x 0, y 13.72 (abaixo, os ids dela já descontado esse deslocamento) |
| `d17b.meta.year` | retângulo ['167.19', '526.44', '30.96', '18'] → ['167.19', '540.16', '32.7', '18']; texto «1881» → «1899» |
| `d17b.meta.format` | retângulo ['20', '552.44', '183.94', '28'] → ['20', '566.16', '160.57', '28']; texto «Livro físico · 208 páginas» → «E-book · 256 páginas» |
| `d17b.status` (seção inteira) | muda de lugar: x 0, y 13.72 (abaixo, os ids dela já descontado esse deslocamento) |
| `d17b.mood` (seção inteira) | muda de lugar: x 0, y -17.14 (abaixo, os ids dela já descontado esse deslocamento) |
| `d17b.mood.voters` | retângulo ['288.14', '927.16', '81.86', '15.01'] → ['285.5', '910.02', '84.5', '15.01']; texto «1,2 mil leitores» → «2,4 mil leitores» |
| `d17b.mood.tag1` | retângulo ['37.5', '973.94', '100.05', '32'] → ['37.5', '956.8', '123.03', '32']; texto «irônico» → «misterioso» |
| `d17b.mood.tag1.percent` | retângulo ['100.67', '982.74', '23.38', '14.4'] → ['123.35', '965.6', '23.68', '14.4']; texto «72%» → «69%» |
| `d17b.mood.tag2` | retângulo ['145.55', '973.94', '112.87', '32'] → ['168.53', '956.8', '110.58', '32'] |
| `d17b.mood.tag2.percent` | retângulo ['220.84', '982.74', '24.07', '14.4'] → ['243.82', '965.6', '21.78', '14.4']; texto «58%» → «61%» |
| `d17b.mood.tag3` | retângulo ['37.5', '1013.94', '122.23', '32'] → ['37.5', '996.8', '122.63', '32']; texto «engraçado» → «romântico» |
| `d17b.mood.tag3.percent` | retângulo ['123.81', '1022.74', '22.42', '14.4'] → ['121.68', '1005.6', '24.95', '14.4']; texto «41%» → «44%» |
| `d17b.mood.tag4` | retângulo ['167.73', '1013.94', '106.44', '32'] → ['168.13', '996.8', '91.42', '32']; texto «sombrio» → «tenso» |
| `d17b.mood.tag4.percent` | retângulo ['238.5', '1022.74', '22.16', '14.4'] → ['222.67', '1005.6', '23.38', '14.4']; texto «18%» → «23%» |
| `d17b.mood.pace.medium.percent` | retângulo ['204.58', '1095.73', '23.3', '13.81'] → ['205.02', '1078.6', '22.43', '13.81']; texto «64%» → «57%» |
| `d17b.mood.splitLabels.characters` | retângulo ['37.5', '1140.14', '122.56', '13.2'] → ['37.5', '1123', '124.31', '13.2']; texto «PERSONAGENS 81%» → «PERSONAGENS 86%» |
| `d17b.mood.splitLabels.plot` | retângulo ['279.45', '1140.14', '73.05', '13.2'] → ['278.87', '1123', '73.63', '13.2']; texto «TRAMA 19%» → «TRAMA 14%» |
| `d17b.mood.split.fill` | retângulo ['39', '1160.84', '252.72', '13'] → ['39', '1143.7', '268.32', '13']; position: {"top": "0px", "right": "59.28px", "bottom": "0px", "left": "0px"} → {"top": "0px", "right": "43.68px", "bottom": "0px", "left": "0px"} |
| `d17b.mood.split.fill.edge` | retângulo ['286.72', '1160.84', '10', '13'] → ['302.32', '1143.7', '10', '13']; position: {"top": "0px", "right": "-5px", "bottom": "0px", "left": "247.72px"} → {"top": "0px", "right": "-5px", "bottom": "0px", "left": "263.32px"} |
| `d17b.synopsis` (seção inteira) | muda de lugar: x 0, y -17.14 (abaixo, os ids dela já descontado esse deslocamento) |
| `d17b.synopsis` | retângulo ['20', '1222.84', '350', '283.17'] → ['20', '1205.7', '350', '258.37'] |
| `d17b.synopsis.text` | retângulo ['20', '1256.84', '350', '124.63'] → ['20', '1239.7', '350', '99.83']; texto «Depois de morto, Brás Cubas resolve contar a / própria vida,» → «Já velho, Bento Santiago tenta “atar as duas / pontas da vid» |
| `d17b.synopsis.text.more` | retângulo ['106.27', '1361.87', '54.78', '16.8'] → ['271.54', '1319.93', '54.78', '16.8'] |
| `d17b.synopsis.facts` | retângulo ['20', '1395.47', '350', '110.54'] → ['20', '1353.53', '350', '110.54'] |
| `d17b.synopsis.fact1` | retângulo ['20', '1396.97', '175', '53.02'] → ['20', '1355.03', '175', '53.02'] |
| `d17b.synopsis.fact1.label` | retângulo ['20', '1406.97', '175', '12.61'] → ['20', '1365.03', '175', '12.61'] |
| `d17b.synopsis.fact1.value` | retângulo ['20', '1422.58', '175', '17.41'] → ['20', '1380.64', '175', '17.41']; texto «208» → «256» |
| `d17b.synopsis.fact2` | retângulo ['195', '1396.97', '175', '53.02'] → ['195', '1355.03', '175', '53.02'] |
| `d17b.synopsis.fact2.label` | retângulo ['210.5', '1406.97', '159.5', '12.61'] → ['210.5', '1365.03', '159.5', '12.61'] |
| `d17b.synopsis.fact2.value` | retângulo ['210.5', '1422.58', '159.5', '17.41'] → ['210.5', '1380.64', '159.5', '17.41']; texto «1881» → «1899» |
| `d17b.synopsis.fact3` | retângulo ['20', '1449.99', '175', '54.52'] → ['20', '1408.05', '175', '54.52'] |
| `d17b.synopsis.fact3.label` | retângulo ['20', '1461.49', '175', '12.61'] → ['20', '1419.55', '175', '12.61'] |
| `d17b.synopsis.fact3.value` | retângulo ['20', '1477.1', '175', '17.41'] → ['20', '1435.16', '175', '17.41']; texto «Brochura» → «E-book» |
| `d17b.synopsis.fact4` | retângulo ['195', '1449.99', '175', '54.52'] → ['195', '1408.05', '175', '54.52'] |
| `d17b.synopsis.fact4.label` | retângulo ['210.5', '1461.49', '159.5', '12.61'] → ['210.5', '1419.55', '159.5', '12.61']; texto «ISBN» → «DIREITOS» |
| `d17b.synopsis.fact4.value` | retângulo ['210.5', '1477.1', '159.5', '17.41'] → ['210.5', '1435.16', '159.5', '17.41']; texto «978-65-5921-104-3» → «Domínio público» |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `d17b.progress` |  | Progresso |  |
| `d17b.progress.continue.icon` |  |  | aria-hidden=true |
| `d17b.progress.highlights` |  | Grifos deste livro (12) |  |
| `d17b.progress.highlights.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `d17b.progress` | NeoBox |  |
| `d17b.progress.page.total` | TextSpan dentro do AppText.rich do pai |  |
| `d17b.progress.bar.track` | HatchPainter (hachura 135°) dentro do contorno |  |
| `d17b.progress.bar.fill` | NeoBox |  |
| `d17b.progress.bar.fill.edge` | CustomPainter (borda_onda_preenchimento_tinta) | preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): a borda ondulada da ponta da barra preenchida, esticada na altura da barra com traço fixo de 1,5 — CustomPainter, como a onda da barra do leitor. |
| `d17b.progress.continue` | NeoBox |  |
| `d17b.progress.continue.icon` | AppSvg(AppIcons.bookOpen, size: 20) |  |
| `d17b.progress.highlights` | CircleIconButton / NeoBox circular |  |
| `d17b.progress.highlights.icon` | AppSvg(AppIcons.highlighter, size: 22) |  |
| `d17b.progress.highlights.badge` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |

## Interações

- Continuar lendo → o leitor na posição salva (`AppRoutes.leitor`).
- Grifos (12) → os grifos do livro (a tela 25, `AppRoutes.destaques`).
- As outras seções como na 17.

## Dados

- "Pág. 159 de 256" e "62%" = a posição salva do leitor (a página de referência e o total, G10); "≈ 2 h 10 min" = o tempo que falta (o cálculo da Início); "12" = as anotações do livro (D-241). O progresso salva sozinho: nada para atualizar à mão.
- A 17b serve ao e-book e ao PDF; o sol e o cartão em lavanda vêm de `{{halo}}` e `{{brand}}`.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L17b.1** Detalhes do e-book: as seções da 17 com as diferenças
- **L17b.2** Cartão do progresso
- **L17b.3** Continuar lendo e grifos ligados
- **L17b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('d17b.progress'), todos os ids de `kRef17b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/017b_detalhes_ebook_390x1790@3x.png` no recorte da fase (y 670.16–881.3) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef17bw360` e `kRef17bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L17b.1 Detalhes do e-book: as seções da 17 com as diferenças
- [ ] L17b.2 Cartão do progresso
- [ ] L17b.3 Continuar lendo e grifos ligados
- [ ] L17b.4 Verificação + relatório
- [ ] Geometria 18/18 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
