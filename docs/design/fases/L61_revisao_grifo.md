# FASE L61 — Revisão dos grifos — grifo 2 de 5

> Tela 61 · prancha `061_revisao_grifo_2_de_5` (61 · Revisão — grifo 2 de 5, canvas 390×844) · executada na **T05** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L61_revisao_grifo@3x.png` · `docs/design/medicao/inicio2/png/redline/L61_revisao_grifo_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/061_revisao_grifo_2_de_5_390x844@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_061_revisao_grifo_2_de_5.json` · `test/reference/inicio2/reference_layout_061_revisao_grifo_2_de_5.dart` (`kRef61`).
> Arquivos sugeridos: `lib/features/review/presentation/review_screen.dart`, `lib/features/review/presentation/review_card.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Tela cheia da revisão diária: grifo 2 de 5 do Dom Casmurro, com o baralho, a nota do grifo, a dica de deslizar e os botões "Menos vezes", "Mais vezes", nota, compartilhar e "Próximo".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<header style="position: absolute; left: 20px; right: 20px; top: 58px;">
  <div style="height: 48px; display: flex; align-items: center; justify-content: space-between; gap: 10px;">
    <button aria-label="Fechar revisão" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"></path></svg></button>
    <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px;">Revisão <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 20px;">de hoje</span></span>
    <span style="width: 48px; text-align: right; font-size: 13px; font-weight: 800; font-variant-numeric: tabular-nums;">2 de 5</span>
  </div>
  <div style="margin-top: 12px;"><div role="progressbar" aria-label="Revisão" aria-valuenow="2" aria-valuemin="0" aria-valuemax="5" style="display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 5px;"><span style="height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: #ABCF82;"></span><span style="height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: linear-gradient(90deg, {{brand}} 50%, #FFFAF1 50%);"></span><span style="height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px);"></span><span style="height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px);"></span><span style="height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px);"></span></div></div>
</header>

<!-- the deck: cards still to come peek from behind -->
<div style="position: absolute; left: 24px; right: 24px; top: 156px; height: 452px;">
  <span aria-hidden="true" style="position: absolute; left: 6px; right: -6px; top: 10px; bottom: -10px; border-radius: 26px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; transform: rotate(5deg);"></span><span aria-hidden="true" style="position: absolute; left: 2px; right: -2px; top: 6px; bottom: -6px; border-radius: 26px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; transform: rotate(-4deg);"></span>
  <article aria-label="Grifo 2 de 5: Dom Casmurro, página 6" style="position: absolute; inset: 0; padding: 18px 18px 16px; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column;">
    <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px;"><span style="display: flex; align-items: center; gap: 6px; min-width: 0;"><span aria-hidden="true" style="width: 12px; height: 17px; flex-shrink: 0; border-radius: 1.5px 3px 3px 1.5px; background: #552CB7; border: 1.2px solid #1A1714; box-sizing: border-box;"></span><span style="min-width: 0; font-size: 11.5px; font-weight: 800; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Dom Casmurro · pág. 6</span></span><span style="height: 24px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 5px; font-size: 11px; font-weight: 800; white-space: nowrap;"><span style="width: 11px; height: 11px; border-radius: 50%; background: #FFC1C6; border: 1.1px solid #1A1714; box-sizing: border-box;"></span>personagem</span></div>
    <p style="margin: 18px 0 0; font-family: 'Literata', Georgia, serif; font-size: 22px; line-height: 1.55; color: #2A2520;"><mark style="background: linear-gradient(transparent 14%, rgba(255,193,198,0.95) 14%, rgba(255,193,198,0.95) 92%, transparent 92%); border-radius: 3px; -webkit-box-decoration-break: clone; box-decoration-break: clone; color: inherit;">O meu fim evidente era atar as duas pontas da vida, e restaurar na velhice a adolescência.</mark></p>
    <span style="position: relative; display: block; margin-top: 18px; align-self: flex-start; max-width: 230px; padding: 10px 10px 9px; border-radius: 10px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; transform: rotate(-1.2deg);"><span aria-hidden="true" style="position: absolute; left: 50%; top: -8px; width: 38px; height: 14px; margin-left: -19px; background: rgba(255,250,241,0.85); border: 1.2px solid #1A1714; box-sizing: border-box; transform: rotate(-3deg);"></span><span style="display: block; font-size: 10px; font-weight: 800; letter-spacing: 1px; color: #5B4A1C;">NOTA</span><span style="display: block; margin-top: 2px; font-size: 13px; font-weight: 700; line-height: 1.35;">É o livro todo nessa frase.</span></span>
    <span style="flex-grow: 1;"></span>
    <div style="padding-top: 10px; border-top: 1px dashed #CFC3AE; display: flex; align-items: center; justify-content: space-between; gap: 8px; font-size: 12px; font-weight: 700; color: #8A8073;">
      <span>Você grifou há 17 dias</span><span>revisto 1 vez</span>
    </div>
  </article>
</div>

<p aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 626px; margin: 0; text-align: center; font-size: 12px; font-weight: 700; color: #8A8073;">deslize o cartão para o próximo</p>

<!-- actions (thumb zone); every swipe also has a button -->
<div style="position: absolute; left: 20px; right: 20px; bottom: 30px; display: flex; flex-direction: column; gap: 10px;">
  <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;">
    <button style="height: 50px; padding: 0 14px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800; white-space: nowrap;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path></svg>Menos vezes</button><button style="height: 50px; padding: 0 14px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800; white-space: nowrap; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg>Mais vezes</button>
  </div>
  <div style="display: flex; gap: 10px;">
    <button aria-label="Escrever uma nota" style="width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16v4z"></path><path d="m13.5 6.5 4 4"></path></svg></button><button aria-label="Compartilhar como imagem" style="width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 15V3M7.5 7.5 12 3l4.5 4.5"></path><path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7"></path></svg></button>
    <button style="flex-grow: 1; height: 52px; border-radius: 999px; background: #1A1714; border: none; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15.5px; font-weight: 800;"><span style="color: #F7F0E3;">Próximo</span><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#FED170" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg></button>
  </div>
</div>
```

## Especificação pixel a pixel

Seção `rv61.header` — retângulo absoluto no canvas 390×844: **x=20, y=58, w=350, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `rv61.header` | box | 0 | 0 | 350 | 70 | `position: absolute; left: 20px; right: 20px; top: 58px` |  |
| 2 | `rv61.header.bar` | box | 0 | 0 | 350 | 48 | `height: 48px; display: flex; align-items: center; justify-content: space-between; gap: 10px` |  |
| 3 | `rv61.header.close` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 4 | `rv61.header.close.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |
| 5 | `rv61.header.title` ±1 | text | 117.63 | 11 | 114.74 | 26 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px` | Bricolage (opsz 17) 17/normal peso 800 ls -0.3px #1A1714 |
| 6 | `rv61.header.title.serif` ±1 | inline | 184.91 | 11 | 47.46 | 26 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 20px` | Instrument Serif itálico 20/normal peso 400 ls -0.3px #1A1714 |
| 7 | `rv61.header.counter` | text | 302 | 16.2 | 48 | 15.6 | `width: 48px; text-align: right; font-size: 13px; font-weight: 800; font-variant-numeric: tabular-nums` | Figtree 13/normal peso 800 ls normal #1A1714 tnum |
| 8 | `rv61.header.progressBlock` | box | 0 | 60 | 350 | 10 | `margin-top: 12px` |  |
| 9 | `rv61.header.progress` | box | 0 | 60 | 350 | 10 | `display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 5px` |  |
| 10 | `rv61.header.progress.step0` | box | 0 | 60 | 66 | 10 | `height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: #ABCF82` |  |
| 11 | `rv61.header.progress.step1` | box | 71 | 60 | 66 | 10 | `height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: linear-gradient(90deg, {{brand}} (padrão #B6ACE4) 50%, #FFFAF1 50%)` |  |
| 12 | `rv61.header.progress.step2` | box | 142 | 60 | 66 | 10 | `height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px)` |  |
| 13 | `rv61.header.progress.step3` | box | 213 | 60 | 66 | 10 | `height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px)` |  |
| 14 | `rv61.header.progress.step4` | box | 284 | 60 | 66 | 10 | `height: 10px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px)` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `rv61.header.title` *(composto)* | 1 | Revisão de hoje | 30.8 | 117.63 | 232.37 | 114.74 |
| `rv61.header.counter` | 1 | 2 de 5 | 28.55 | 312.3 | 350 | 37.7 |

Seção `rv61.deck` — retângulo absoluto no canvas 390×844: **x=24, y=156, w=342, h=452**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 15 | `rv61.deck` | box | 0 | 0 | 342 | 452 | `position: absolute; left: 24px; right: 24px; top: 156px; height: 452px` |  |
| 16 | `rv61.deck.behind2` | box | 6 | 10 | 342 | 452 | `position: absolute; left: 6px; right: -6px; top: 10px; bottom: -10px; border-radius: 26px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; transform: rotate(5deg)` |  |
| 17 | `rv61.deck.behind1` | box | 2 | 6 | 342 | 452 | `position: absolute; left: 2px; right: -2px; top: 6px; bottom: -6px; border-radius: 26px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; transform: rotate(-4deg)` |  |
| 18 | `rv61.deck.card` | box | 0 | 0 | 342 | 452 | `position: absolute; inset: 0; padding: 18px 18px 16px; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 19 | `rv61.deck.card.top` | box | 19.5 | 19.5 | 303 | 24 | `display: flex; align-items: center; justify-content: space-between; gap: 8px` |  |
| 20 | `rv61.deck.card.top.book` ±1 | box | 19.5 | 23 | 139.3 | 17 | `display: flex; align-items: center; gap: 6px; min-width: 0` |  |
| 21 | `rv61.deck.card.top.book.spine` | box | 19.5 | 23 | 12 | 17 | `width: 12px; height: 17px; flex-shrink: 0; border-radius: 1.5px 3px 3px 1.5px; background: #552CB7; border: 1.2px solid #1A1714; box-sizing: border-box` |  |
| 22 | `rv61.deck.card.top.book.label` ±1 | text | 37.5 | 24.59 | 121.3 | 13.81 | `min-width: 0; font-size: 11.5px; font-weight: 800; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 23 | `rv61.deck.card.top.tag` ±1 | box+text | 225.45 | 19.5 | 97.05 | 24 | `height: 24px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 5px; font-size: 11px; font-weight: 800; white-space: nowrap` | Figtree 11/normal peso 800 ls normal #1A1714 |
| 24 | `rv61.deck.card.top.tag.dot` ±1 | box | 232.65 | 26 | 11 | 11 | `width: 11px; height: 11px; border-radius: 50%; background: #FFC1C6; border: 1.1px solid #1A1714; box-sizing: border-box` |  |
| 25 | `rv61.deck.card.quote` | box | 19.5 | 61.5 | 303 | 136.4 | `margin: 18px 0 0; font-family: 'Literata', Georgia, serif; font-size: 22px; line-height: 1.55; color: #2A2520` | Literata (opsz 22) 22/34.1px peso 400 ls normal #2A2520 |
| 26 | `rv61.deck.card.quote.mark` ±1 | inline | 19.5 | 62.21 | 284.88 | 134.97 | `background: linear-gradient(transparent 14%, rgba(255,193,198,0.95) 14%, rgba(255,193,198,0.95) 92%, transparent 92%); border-radius: 3px; -webkit-box-decoration-break: clone; box-decoration-break: clone; color: inherit` | Literata (opsz 22) 22/34.1px peso 400 ls normal #2A2520 |
| 27 | `rv61.deck.card.note` ±1 | box | 19.5 | 215.9 | 175.01 | 53.55 | `position: relative; display: block; margin-top: 18px; align-self: flex-start; max-width: 230px; padding: 10px 10px 9px; border-radius: 10px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; transform: rotate(-1.2deg)` |  |
| 28 | `rv61.deck.card.note.tape` ±1 | box | 88 | 209.4 | 38 | 14 | `position: absolute; left: 50%; top: -8px; width: 38px; height: 14px; margin-left: -19px; background: rgba(255,250,241,0.85); border: 1.2px solid #1A1714; box-sizing: border-box; transform: rotate(-3deg)` |  |
| 29 | `rv61.deck.card.note.label` ±1 | text | 31 | 227.4 | 152.01 | 12 | `display: block; font-size: 10px; font-weight: 800; letter-spacing: 1px; color: #5B4A1C` | Figtree 10/normal peso 800 ls 1px #5B4A1C |
| 30 | `rv61.deck.card.note.text` ±1 | text | 31 | 241.4 | 152.01 | 17.55 | `display: block; margin-top: 2px; font-size: 13px; font-weight: 700; line-height: 1.35` | Figtree 13/17.55px peso 700 ls normal #1A1714 |
| 31 | `rv61.deck.card.spacer` | box | 19.5 | 269.45 | 303 | 139.65 | `flex-grow: 1` |  |
| 32 | `rv61.deck.card.footer` | box | 19.5 | 409.1 | 303 | 25.4 | `padding-top: 10px; border-top: 1px dashed #CFC3AE; display: flex; align-items: center; justify-content: space-between; gap: 8px; font-size: 12px; font-weight: 700; color: #8A8073` |  |
| 33 | `rv61.deck.card.footer.when` ±1 | text | 19.5 | 420.1 | 120.26 | 14.4 | `—` | Figtree 12/normal peso 700 ls normal #8A8073 |
| 34 | `rv61.deck.card.footer.reviewed` ±1 | text | 254.84 | 420.1 | 67.66 | 14.4 | `—` | Figtree 12/normal peso 700 ls normal #8A8073 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `rv61.deck.behind2`: caixa visual com `transform: rotate(5deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `rv61.deck.behind1`: caixa visual com `transform: rotate(-4deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `rv61.deck.card.note`: caixa visual com `transform: rotate(-1.2deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `rv61.deck.card.note.tape`: caixa visual com `transform: rotate(-3deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `rv61.deck.card.note.label`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `rv61.deck.card.note.text`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `rv61.deck.card.top.book.label` | 1 | Dom Casmurro · pág. 6 | 35.53 | 37.5 | 158.8 | 121.3 |
| `rv61.deck.card.top.tag` | 1 | personagem | 35.35 | 248.65 | 312.3 | 63.65 |
| `rv61.deck.card.quote` *(composto)* | 1 | O meu fim evidente era atar | 88.1 | 19.5 | 304.38 | 284.88 |
| `rv61.deck.card.quote` *(composto)* | 2 | as duas pontas da vida, e | 122.2 | 19.5 | 271.28 | 251.78 |
| `rv61.deck.card.quote` *(composto)* | 3 | restaurar na velhice a | 156.3 | 19.5 | 242.73 | 223.23 |
| `rv61.deck.card.quote` *(composto)* | 4 | adolescência. | 190.4 | 19.5 | 158.94 | 139.44 |
| `rv61.deck.card.note.label` | 1 | NOTA | 236.9 | 31 | 63.09 | 32.09 |
| `rv61.deck.card.note.text` | 1 | É o livro todo nessa frase. | 254.72 | 31 | 183.01 | 152.01 |
| `rv61.deck.card.footer.when` | 1 | Você grifou há 17 dias | 431.5 | 19.5 | 139.76 | 120.26 |
| `rv61.deck.card.footer.reviewed` | 1 | revisto 1 vez | 431.5 | 254.84 | 322.5 | 67.66 |

Seção `rv61.swipeHint` — retângulo absoluto no canvas 390×844: **x=0, y=626, w=390, h=14.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 35 | `rv61.swipeHint` | text | 0 | 0 | 390 | 14.4 | `position: absolute; left: 0; right: 0; top: 626px; margin: 0; text-align: center; font-size: 12px; font-weight: 700; color: #8A8073` | Figtree 12/normal peso 700 ls normal #8A8073 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `rv61.swipeHint` | 1 | deslize o cartão para o próximo | 11.4 | 109.16 | 280.84 | 171.68 |

Seção `rv61.actions` — retângulo absoluto no canvas 390×844: **x=20, y=702, w=350, h=112**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 36 | `rv61.actions` | box | 0 | 0 | 350 | 112 | `position: absolute; left: 20px; right: 20px; bottom: 30px; display: flex; flex-direction: column; gap: 10px` |  |
| 37 | `rv61.actions.frequency` | box | 0 | 0 | 350 | 50 | `display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px` |  |
| 38 | `rv61.actions.less` | box+text | 0 | 0 | 170 | 50 | `height: 50px; padding: 0 14px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800; white-space: nowrap` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 39 | `rv61.actions.less.icon` ±1 | icon | 31.09 | 16 | 18 | 18 | `—` |  |
| 40 | `rv61.actions.more` | box+text | 180 | 0 | 170 | 50 | `height: 50px; padding: 0 14px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800; white-space: nowrap; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 41 | `rv61.actions.more.icon` ±1 | icon | 217.38 | 16 | 18 | 18 | `—` |  |
| 42 | `rv61.actions.row` | box | 0 | 60 | 350 | 52 | `display: flex; gap: 10px` |  |
| 43 | `rv61.actions.note` | box | 0 | 60 | 52 | 52 | `width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 44 | `rv61.actions.note.icon` | icon | 16 | 76 | 20 | 20 | `—` |  |
| 45 | `rv61.actions.share` | box | 62 | 60 | 52 | 52 | `width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 46 | `rv61.actions.share.icon` | icon | 78 | 76 | 20 | 20 | `—` |  |
| 47 | `rv61.actions.next` | box | 124 | 60 | 226 | 52 | `flex-grow: 1; height: 52px; border-radius: 999px; background: #1A1714; border: none; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15.5px; font-weight: 800` |  |
| 48 | `rv61.actions.next.label` ±1 | text | 193.99 | 76.7 | 60.02 | 18.61 | `color: #F7F0E3` | Figtree 15.5/normal peso 800 ls normal #F7F0E3 |
| 49 | `rv61.actions.next.icon` ±1 | icon | 262.01 | 77 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `rv61.actions.less` | 1 | Menos vezes | 29.9 | 56.09 | 138.91 | 82.82 |
| `rv61.actions.more` | 1 | Mais vezes | 29.9 | 242.38 | 312.62 | 70.24 |
| `rv61.actions.next.label` | 1 | Próximo | 91.42 | 193.99 | 254.01 | 60.02 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cabeçalho (`left/right 20 · top 58`): fechar 48 (círculo `#FFFAF1`, `ic_close_bold` 20); "Revisão de" Bricolage 17/800 ls −0,3 + "hoje" Instrument Serif itálico 20 (centrado); "2 de 5" Figtree 13/800 tabular, alinhado à direita numa caixa de 48. Progresso 12 abaixo: 5 segmentos 66 × 10 (gap 5, raio 999, borda 1,3) — feito verde `#ABCF82`, atual metade `{{brand}}`/metade `#FFFAF1` (degradê com parada dura em 50 %), os demais com hachura 135° `#E9DFCC`/`#FFFAF1` (3/7).
2. Baralho (`left/right 24 · top 156`, 342 × 452): atrás, um cartão lavanda girado −4° (deslocado 2/6) e um verde girado +5° (6/10), raio 26, borda 1,5, sombra 3/3; o cartão da frente `#FFFAF1`, sombra 4/4, padding 18/18/16.
3. Topo do cartão: lombada 12 × 17 `#552CB7` + "Dom Casmurro · pág. 6" Figtree 11,5/800 (reticências); etiqueta "personagem" (24 de altura, borda 1,2, bolinha rosa 11).
4. Grifo em **Literata 22/400** `lh 1,55` `#2A2520` (família nova `Literata22`), 4 linhas; fundo rosa `rgba(255,193,198,.95)` de 14 % a 92 % da linha, raio 3, **por linha** (`box-decoration-break: clone`).
5. Nota: caixa amarela `#FED170` raio 10, borda 1,5, sombra 2/2, **girada −1,2°**, até 230 de largura; fita creme 38 × 14 `rgba(255,250,241,.85)` com borda 1,2 a −8 do topo; "NOTA" Figtree 10/800 ls 1 `#5B4A1C`; texto 13/700 `lh 1,35`.
6. Rodapé do cartão (tracejado 1 `#CFC3AE`): "Você grifou há 17 dias" × "revisto 1 vez", Figtree 12/700 `#8A8073`. Dica "deslize o cartão para o próximo" (12/700 `#8A8073`, centrada em y 626).
7. Ações (`bottom 30`): "− Menos vezes" (`#FFFAF1`) e "+ Mais vezes" (`{{brand}}` com sombra 2/2 — destacado), 50 de altura, Figtree 14/800; depois nota (lápis 20) e compartilhar (`ic_share`) em círculos 52 e "Próximo" preto Figtree 15,5/800 com a seta amarela 18.
8. Fontes desta prancha: a Figtree vai até 800 (D-246: 800 **real**, `Figtree-ExtraBold.ttf`; 900 renderiza 800); Bricolage 800 com a família do tamanho; Literata estática por tamanho (D-104).

## Armadilhas

- "Mais vezes" destacado (`{{brand}}` + sombra 2/2) é a ação sugerida, não um estado (D-251): o arquivo marca seleção com `aria-checked` (na 63) e aqui não marca nada — botão comum, sem `selected`/`toggled` na semântica; o destaque é só visual e não muda com o toque. Os dois botões registram a escolha.
- O grifo é um fundo por linha (não um retângulo único): reutilizar o pintor de grifo do leitor (G13).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `rv61.header.close` |  | Fechar revisão |  |
| `rv61.header.close.icon` |  |  | aria-hidden=true |
| `rv61.header.progress` | progressbar | Revisão | aria-valuenow=2, aria-valuemin=0, aria-valuemax=5 |
| `rv61.deck.behind2` |  |  | aria-hidden=true |
| `rv61.deck.behind1` |  |  | aria-hidden=true |
| `rv61.deck.card` |  | Grifo 2 de 5: Dom Casmurro, página 6 |  |
| `rv61.deck.card.top.book.spine` |  |  | aria-hidden=true |
| `rv61.deck.card.note.tape` |  |  | aria-hidden=true |
| `rv61.swipeHint` |  |  | aria-hidden=true |
| `rv61.actions.less.icon` |  |  | aria-hidden=true |
| `rv61.actions.more.icon` |  |  | aria-hidden=true |
| `rv61.actions.note` |  | Escrever uma nota |  |
| `rv61.actions.note.icon` |  |  | aria-hidden=true |
| `rv61.actions.share` |  | Compartilhar como imagem |  |
| `rv61.actions.share.icon` |  |  | aria-hidden=true |
| `rv61.actions.next.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `rv61.header.close` | CircleIconButton / NeoBox circular |  |
| `rv61.header.close.icon` | AppSvg(AppIconsInicio.ic_close_bold, size: 20) |  |
| `rv61.header.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `rv61.header.progress.step0` | NeoBox |  |
| `rv61.header.progress.step1` | DecoratedBox(LinearGradient) |  |
| `rv61.header.progress.step2` | HatchPainter (hachura 135°) dentro do contorno |  |
| `rv61.header.progress.step3` | HatchPainter (hachura 135°) dentro do contorno |  |
| `rv61.header.progress.step4` | HatchPainter (hachura 135°) dentro do contorno |  |
| `rv61.deck.behind2` | NeoBox | Transform: rotate(5deg) |
| `rv61.deck.behind1` | NeoBox | Transform: rotate(-4deg) |
| `rv61.deck.card` | NeoBox |  |
| `rv61.deck.card.top.book.spine` | NeoBox |  |
| `rv61.deck.card.top.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rv61.deck.card.top.tag.dot` | CircleIconButton / NeoBox circular |  |
| `rv61.deck.card.quote.mark` | TextSpan dentro do AppText.rich do pai |  |
| `rv61.deck.card.note` | NeoBox | Transform: rotate(-1.2deg) |
| `rv61.deck.card.note.tape` | NeoBox | Transform: rotate(-3deg) |
| `rv61.deck.card.footer` | NeoBox |  |
| `rv61.actions.less` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rv61.actions.less.icon` | AppSvg(AppIconsInicio.ic_minus, size: 18) |  |
| `rv61.actions.more` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rv61.actions.more.icon` | AppSvg(AppIconsInicio.ic_plus_bold, size: 18) |  |
| `rv61.actions.note` | CircleIconButton / NeoBox circular |  |
| `rv61.actions.note.icon` | AppSvg(AppIconsInicio.ic_pencil_edit, size: 20) |  |
| `rv61.actions.share` | CircleIconButton / NeoBox circular |  |
| `rv61.actions.share.icon` | AppSvg(AppIconsLeitor.ic_share, size: 20) |  |
| `rv61.actions.next` | NeoBox |  |
| `rv61.actions.next.icon` | AppSvg(AppIconsInicio.ic_arrow_next, size: 18) |  |

## Interações

- Deslizar o cartão / "Próximo" → próximo grifo (o baralho anda; a barra de progresso também).
- "Menos vezes" / "Mais vezes" → muda a frequência do grifo (regra de agendamento no plano da T05).
- Lápis → editor da nota do leitor (D-23); compartilhar → folha "Compartilhar grifo" (63).
- Fechar → sai da revisão (volta à Início).

## Dados

- "2 de 5" = posição no baralho do dia (5 por dia); "há 17 dias" = hoje − data do grifo; "revisto 1 vez" = contagem de revisões; etiqueta e cor do grifo; nota do grifo (tudo da T05, D-244).

## Subfases

- **L61.1** Cabeçalho e progresso de 5
- **L61.2** Baralho (cartões girados atrás)
- **L61.3** Cartão: topo, grifo Literata 22, nota girada
- **L61.4** Rodapé do cartão e dica
- **L61.5** Ações
- **L61.6** Deslizar e animação
- **L61.7** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('rv61.header', 'rv61.deck', 'rv61.swipeHint', 'rv61.actions'), todos os ids de `kRef61.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/061_revisao_grifo_2_de_5_390x844@3x.png` no recorte da fase (y 50–822) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L61.1 Cabeçalho e progresso de 5
- [ ] L61.2 Baralho (cartões girados atrás)
- [ ] L61.3 Cartão: topo, grifo Literata 22, nota girada
- [ ] L61.4 Rodapé do cartão e dica
- [ ] L61.5 Ações
- [ ] L61.6 Deslizar e animação
- [ ] L61.7 Verificação + relatório
- [ ] Geometria 47/47 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
