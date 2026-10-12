# FASE L03 — Scanner (livro encontrado) — a folha: o livro, a coleção, Salvar como e Adicionar à biblioteca

> Tela 03 · prancha `003_scanner_encontrado` (03 · Scanner — livro encontrado, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L03_3_folha@3x.png` · `docs/design/medicao/projeto/png/redline/L03_3_folha_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/003_scanner_encontrado_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_003_scanner_encontrado.json` · `test/reference/projeto/reference_layout_003_scanner_encontrado.dart` (`kRef03`).
> Arquivos sugeridos: `lib/features/scanner/presentation/sheets/scanner_sheet.dart`, `lib/features/scanner/presentation/sheets/found_sheet.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A folha do livro encontrado: o chip verde "Livro encontrado" com o ISBN, o livro (capa, título, autor, formato e a coleção sugerida), "Salvar como" (Quero ler marcado), "Adicionar à biblioteca", escanear outro e "Não é este livro? Buscar pelo título".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<!-- Result sheet: data returned by the book lookup for this ISBN -->
<section role="dialog" aria-label="Livro encontrado" style="position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">
  <span aria-hidden="true" style="align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD;"></span>

  <div style="margin-top: 12px; display: flex; align-items: center; justify-content: space-between; gap: 8px;">
    <span style="display: flex; align-items: center; gap: 5px; height: 26px; padding: 0 10px 0 8px; box-sizing: border-box; border-radius: 999px; background: #E1EDD0; color: #2E5314; font-size: 12px; font-weight: 800;">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
      Livro encontrado
    </span>
    <span style="font-size: 12px; font-weight: 600; color: #5B544B; font-variant-numeric: tabular-nums;">ISBN 978-65-5921-104-3</span>
  </div>

  <a href="#" aria-label="Ver detalhes de Memórias Póstumas de Brás Cubas" style="margin-top: 16px; display: flex; align-items: center; gap: 14px;">
    <div style="position: relative; width: 84px; height: 126px; flex-shrink: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box; box-shadow: 3px 3px 0 #1A1714;">
      <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.15);"></div>
      <div style="position: absolute; left: 14px; right: -26px; bottom: -44px; height: 88px; border-radius: 50%; background: #1A1714;"></div>
      <div style="position: absolute; left: 12px; right: 6px; top: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 14.5px; line-height: 0.95; color: #1A1714;">Memórias Póstumas de Brás Cubas</div>
      <div style="position: absolute; left: 22px; bottom: 9px; font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FF552E;">MACHADO DE ASSIS</div>
    </div>
    <div style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
      <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 19px; line-height: 1.1; letter-spacing: -0.4px;">Memórias Póstumas de Brás Cubas</h2>
      <span style="font-size: 14px; font-weight: 600; color: #5B544B;">Machado de Assis</span>
      <span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Livro físico · 208 páginas</span>
      <span style="margin-top: 8px; align-self: flex-start; height: 30px; padding: 0 6px 0 9px; box-sizing: border-box; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; font-size: 12.5px; font-weight: 700; white-space: nowrap;">
        <span aria-hidden="true" style="width: 15px; display: flex; flex-direction: column;">
          <span style="height: 5px; width: 12px; margin-left: 2px; border-radius: 1.5px; background: #552CB7; border: 1px solid #1A1714;"></span>
          <span style="height: 5px; width: 15px; margin-top: -1px; border-radius: 1.5px; background: #058CD7; border: 1px solid #1A1714;"></span>
          <span style="height: 5px; width: 13px; margin-top: -1px; border-radius: 1.5px; background: #F2A815; border: 1px solid #1A1714;"></span>
        </span>
        Clássicos brasileiros
        <span aria-label="Incluído" style="width: 18px; height: 18px; border-radius: 50%; background: {{brand}}; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
        </span>
      </span>
    </div>
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg>
  </a>

  <span style="margin-top: 18px; font-size: 12px; font-weight: 700; color: #5B544B;">Salvar como</span>
  <div role="radiogroup" aria-label="Salvar como" style="margin-top: 8px; height: 48px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1;">
    <button role="radio" aria-checked="true" style="height: 100%; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800;">Quero ler</button>
    <button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B;">Lendo</button>
    <button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B;">Lido</button>
  </div>

  <div style="margin-top: 16px; display: flex; gap: 10px;">
    <button style="flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; color: #F7F0E3; border: none; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg>
      <span style="color: #F7F0E3;">Adicionar à biblioteca</span>
    </button>
    <button aria-label="Escanear outro livro" style="width: 54px; height: 54px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 12a8 8 0 1 1-2.35-5.65"></path><path d="M20 4v5h-5"></path></svg>
    </button>
  </div>

  <p style="margin: 14px 0 0; text-align: center; font-size: 13.5px; font-weight: 500; color: #5B544B;">Não é este livro? <a href="#" style="font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px;">Buscar pelo título</a></p>
</section>
```

## Especificação pixel a pixel

Seção `sc03.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=425.39, w=370, h=408.61**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc03.sheet` | box | 0 | 0 | 370 | 408.61 | `position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 2 | `sc03.sheet.handle` | box | 165 | 11.5 | 40 | 5 | `align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD` |  |
| 3 | `sc03.sheet.top` | box | 19.5 | 28.5 | 331 | 26 | `margin-top: 12px; display: flex; align-items: center; justify-content: space-between; gap: 8px` |  |
| 4 | `sc03.sheet.chip` ±1 | box+text | 19.5 | 28.5 | 131.74 | 26 | `display: flex; align-items: center; gap: 5px; height: 26px; padding: 0 10px 0 8px; box-sizing: border-box; border-radius: 999px; background: #E1EDD0; color: #2E5314; font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #2E5314 |
| 5 | `sc03.sheet.chip.icon` | icon | 27.5 | 35 | 13 | 13 | `—` |  |
| 6 | `sc03.sheet.isbn` ±1 | text | 202.42 | 34.3 | 148.08 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B; font-variant-numeric: tabular-nums` | Figtree 12/normal peso 600 ls normal #5B544B tnum |
| 7 | `sc03.sheet.book` | box | 19.5 | 70.5 | 331 | 126 | `margin-top: 16px; display: flex; align-items: center; gap: 14px` |  |
| 8 | `sc03.sheet.book.cover` | box | 19.5 | 70.5 | 84 | 126 | `position: relative; width: 84px; height: 126px; flex-shrink: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box; box-shadow: 3px 3px 0 #1A1714` |  |
| 9 | `sc03.sheet.book.cover.spine` | box | 21 | 72 | 6 | 123 | `position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.15)` |  |
| 10 | `sc03.sheet.book.cover.ellipse` | box | 35 | 151 | 93 | 88 | `position: absolute; left: 14px; right: -26px; bottom: -44px; height: 88px; border-radius: 50%; background: #1A1714` |  |
| 11 | `sc03.sheet.book.cover.title` | text | 33 | 83 | 63 | 41.33 | `position: absolute; left: 12px; right: 6px; top: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 14.5px; line-height: 0.95; color: #1A1714` | Instrument Serif 14.5/13.775px peso 400 ls normal #1A1714 |
| 12 | `sc03.sheet.book.cover.author` | text | 43 | 172.78 | 59 | 13.22 | `position: absolute; left: 22px; bottom: 9px; font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FF552E` | Figtree 5.5/normal peso 700 ls 0.77px #FF552E |
| 13 | `sc03.sheet.book.textBlock` | box | 117.5 | 73.19 | 199 | 120.61 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 14 | `sc03.sheet.book.title` | text | 117.5 | 73.19 | 199 | 41.8 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 19px; line-height: 1.1; letter-spacing: -0.4px` | Bricolage (opsz 19) 19/20.9px peso 800 ls -0.4px #1A1714 |
| 15 | `sc03.sheet.book.author` | text | 117.5 | 118 | 199 | 16.8 | `font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 16 | `sc03.sheet.book.meta` | text | 117.5 | 137.79 | 199 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 17 | `sc03.sheet.book.collection` ±1 | box+text | 117.5 | 163.81 | 180.59 | 30 | `margin-top: 8px; align-self: flex-start; height: 30px; padding: 0 6px 0 9px; box-sizing: border-box; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; font-size: 12.5px; font-weight: 700; white-space: nowrap` | Figtree 12.5/normal peso 700 ls normal #1A1714 |
| 18 | `sc03.sheet.book.collection.pile` | box | 128 | 169.31 | 15 | 19 | `width: 15px; display: flex; flex-direction: column` |  |
| 19 | `sc03.sheet.book.collection.pile.spine1` | box | 130 | 169.31 | 14 | 7 | `height: 5px; width: 12px; margin-left: 2px; border-radius: 1.5px; background: #552CB7; border: 1px solid #1A1714` |  |
| 20 | `sc03.sheet.book.collection.pile.spine2` | box | 128 | 175.31 | 17 | 7 | `height: 5px; width: 15px; margin-top: -1px; border-radius: 1.5px; background: #058CD7; border: 1px solid #1A1714` |  |
| 21 | `sc03.sheet.book.collection.pile.spine3` | box | 128 | 181.31 | 15 | 7 | `height: 5px; width: 13px; margin-top: -1px; border-radius: 1.5px; background: #F2A815; border: 1px solid #1A1714` |  |
| 22 | `sc03.sheet.book.collection.check` ±1 | box | 272.58 | 169.81 | 18 | 18 | `width: 18px; height: 18px; border-radius: 50%; background: {{brand}} (padrão #B6ACE4); border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 23 | `sc03.sheet.book.collection.check.icon` ±1 | icon | 276.58 | 173.81 | 10 | 10 | `—` |  |
| 24 | `sc03.sheet.book.chevron` | icon | 330.5 | 123.5 | 20 | 20 | `flex-shrink: 0` |  |
| 25 | `sc03.sheet.saveAs.label` | text | 19.5 | 214.5 | 331 | 14.4 | `margin-top: 18px; font-size: 12px; font-weight: 700; color: #5B544B` | Figtree 12/normal peso 700 ls normal #5B544B |
| 26 | `sc03.sheet.saveAs.options` | box | 19.5 | 236.9 | 331 | 48 | `margin-top: 8px; height: 48px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1` |  |
| 27 | `sc03.sheet.saveAs.options.wantToRead` | box+text | 24 | 241.4 | 106 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 28 | `sc03.sheet.saveAs.options.reading` | text | 132 | 241.4 | 106 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 29 | `sc03.sheet.saveAs.options.read` | text | 240 | 241.4 | 106 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 30 | `sc03.sheet.actions` | box | 19.5 | 300.9 | 331 | 54 | `margin-top: 16px; display: flex; gap: 10px` |  |
| 31 | `sc03.sheet.actions.primary` | box | 19.5 | 300.9 | 267 | 54 | `flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; color: #F7F0E3; border: none; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700` |  |
| 32 | `sc03.sheet.actions.primary.icon` ±1 | icon | 57.98 | 317.9 | 20 | 20 | `—` |  |
| 33 | `sc03.sheet.actions.primary.label` ±1 | text | 87.98 | 318.3 | 160.03 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 700 ls normal #F7F0E3 |
| 34 | `sc03.sheet.actions.scanAgain` | box | 296.5 | 300.9 | 54 | 54 | `width: 54px; height: 54px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 35 | `sc03.sheet.actions.scanAgain.icon` | icon | 312.5 | 316.9 | 22 | 22 | `—` |  |
| 36 | `sc03.sheet.footer` | text | 19.5 | 368.9 | 331 | 16.21 | `margin: 14px 0 0; text-align: center; font-size: 13.5px; font-weight: 500; color: #5B544B` | Figtree 13.5/normal peso 500 ls normal #5B544B |
| 37 | `sc03.sheet.footer.link` ±1 | inline | 182.48 | 368.9 | 109.9 | 16.21 | `font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px` | Figtree 13.5/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc03.sheet.chip` | 1 | Livro encontrado | 45.7 | 45.5 | 141.24 | 95.74 |
| `sc03.sheet.isbn` | 1 | ISBN 978-65-5921-104-3 | 45.7 | 202.42 | 350.5 | 148.08 |
| `sc03.sheet.book.cover.title` | 1 | Memórias | 94.81 | 33 | 81.86 | 48.86 |
| `sc03.sheet.book.cover.title` | 2 | Póstumas de | 108.59 | 33 | 94.8 | 61.8 |
| `sc03.sheet.book.cover.title` | 3 | Brás Cubas | 122.36 | 33 | 87.04 | 54.04 |
| `sc03.sheet.book.cover.author` | 1 | MACHADO DE | 178.01 | 43 | 87.81 | 44.81 |
| `sc03.sheet.book.cover.author` | 2 | ASSIS | 184.62 | 43 | 62.38 | 19.38 |
| `sc03.sheet.book.title` | 1 | Memórias Póstumas | 89.91 | 117.5 | 302.97 | 185.47 |
| `sc03.sheet.book.title` | 2 | de Brás Cubas | 110.82 | 117.5 | 245.69 | 128.19 |
| `sc03.sheet.book.author` | 1 | Machado de Assis | 131.29 | 117.5 | 231.63 | 114.13 |
| `sc03.sheet.book.meta` | 1 | Livro físico · 208 páginas | 149.68 | 117.5 | 257.52 | 140.02 |
| `sc03.sheet.book.collection` | 1 | Clássicos brasileiros | 183.18 | 150 | 265.58 | 115.58 |
| `sc03.sheet.saveAs.label` | 1 | Salvar como | 225.9 | 19.5 | 87.37 | 67.87 |
| `sc03.sheet.saveAs.options.wantToRead` | 1 | Quero ler | 265.8 | 46.51 | 107.49 | 60.98 |
| `sc03.sheet.saveAs.options.reading` | 1 | Lendo | 265.8 | 165.28 | 204.72 | 39.44 |
| `sc03.sheet.saveAs.options.read` | 1 | Lido | 265.8 | 279.34 | 306.66 | 27.32 |
| `sc03.sheet.actions.primary.label` | 1 | Adicionar à biblioteca | 333.5 | 87.98 | 248.02 | 160.04 |
| `sc03.sheet.footer` *(composto)* | 1 | Não é este livro? Buscar pelo título | 381.73 | 77.62 | 292.38 | 214.76 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A folha (a mesma nas 03, 39, 40, 41 e 42): `left/right/bottom 10`, padding 10/18/22, raio 30/30/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4; a alça 40 × 5 `#D9CFBD` (raio 3) centrada no topo. É um `Align` no fundo da tela (não um `showModalBottomSheet`), para a câmera continuar visível atrás (nota do design).
2. Topo, 12 abaixo da alça (`space-between`): o chip de 26 `#E1EDD0`/`#2E5314`, padding 0/10/0/8, visto 13 + 12/800; à direita "ISBN 978-65-5921-104-3" 12/600 `#5B544B` `tnum`.
3. Livro, 16 abaixo (gap 14): capa 84 × 126 (raio 3/8/8/3, borda 1,5, sombra 3/3, coral com a lombada 6 e a meia-lua preta, título Instrument Serif 14,5 `lh 0,95` e autor 5,5/700 ls 0,14em); ao lado, o título Bricolage 19/800 `lh 1,1` ls −0,4, o autor 14/600 e "Livro físico · 208 páginas" 12,5/500, gap 3; a seta 20 à direita.
4. A coleção, 8 abaixo: pílula de 30 (padding 0/6/0/9, gap 7, borda 1,5), a mini pilha de 3 lombadas (5 de altura, borda 1, raio 1,5, sobrepostas 1), "Clássicos brasileiros" 12,5/700 `nowrap` e o visto em círculo 18 `{{brand}}` (rótulo "Incluído").
5. "Salvar como" 12/700 `#5B544B` e, 8 abaixo, a régua de 48 (padding 3, borda 1,5, 3 colunas, gap 2): o marcado em `{{brand}}` com borda 1,5 e 14/800; os outros sem fundo, 14/600 `#5B544B`. A 18 abaixo do livro.
6. Ações 16 abaixo (gap 10): o botão preto de 54 (`flex 1`, ícone 20 `#F7F0E3` + 16/700) e o círculo 54 de escanear de novo (a seta circular 22); por último, 14 abaixo, a linha centrada 13,5/500 `#5B544B` com o link 800 sublinhado (offset 3).
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A capa da folha é a capa da fixture em CSS (84 × 126; na 42, 72 × 108 com o título em 12,5): com dados reais, a capa do catálogo (D-79).
- A 360 a pílula da coleção passa 11,59 do bloco de texto (abaixo): `nowrap` com o nome inteiro — decidir na T15 se encolhe com reticências.
- Fio de navalha em `sc03.sheet.book.cover.title` linha 2 «Póstumas de»: sobra 1.2 px · estouro com a próxima palavra 22.8 px.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_003_scanner_encontrado_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_003_scanner_encontrado_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `sc03.sheet.book.collection` | passa do pai (x) | 11.59 | 0 | **sim** | sim | pai `sc03.sheet.book.textBlock` (vaza) |

- A 360: fio de navalha em `sc03.sheet.book.cover.title` linha 2 «Póstumas de»: sobra 1.2 px · estouro com a próxima palavra 22.8 px.
- A 430: fio de navalha em `sc03.sheet.book.cover.title` linha 2 «Póstumas de»: sobra 1.2 px · estouro com a próxima palavra 22.8 px.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc03.sheet` | dialog | Livro encontrado |  |
| `sc03.sheet.handle` |  |  | aria-hidden=true |
| `sc03.sheet.chip.icon` |  |  | aria-hidden=true |
| `sc03.sheet.book` |  | Ver detalhes de Memórias Póstumas de Brás Cubas |  |
| `sc03.sheet.book.collection.pile` |  |  | aria-hidden=true |
| `sc03.sheet.book.collection.check` |  | Incluído |  |
| `sc03.sheet.book.chevron` |  |  | aria-hidden=true |
| `sc03.sheet.saveAs.options` | radiogroup | Salvar como |  |
| `sc03.sheet.saveAs.options.wantToRead` | radio |  | aria-checked=true |
| `sc03.sheet.saveAs.options.reading` | radio |  | aria-checked=false |
| `sc03.sheet.saveAs.options.read` | radio |  | aria-checked=false |
| `sc03.sheet.actions.primary.icon` |  |  | aria-hidden=true |
| `sc03.sheet.actions.scanAgain` |  | Escanear outro livro |  |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc03.sheet` | NeoBox |  |
| `sc03.sheet.handle` | NeoBox |  |
| `sc03.sheet.chip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc03.sheet.chip.icon` | AppSvg(AppIconsBiblioteca.checkBold, size: 13) |  |
| `sc03.sheet.book.cover` | NeoBox |  |
| `sc03.sheet.book.cover.spine` | NeoBox |  |
| `sc03.sheet.book.cover.ellipse` | CircleIconButton / NeoBox circular |  |
| `sc03.sheet.book.collection` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc03.sheet.book.collection.pile.spine1` | NeoBox |  |
| `sc03.sheet.book.collection.pile.spine2` | NeoBox |  |
| `sc03.sheet.book.collection.pile.spine3` | NeoBox |  |
| `sc03.sheet.book.collection.check` | CircleIconButton / NeoBox circular |  |
| `sc03.sheet.book.collection.check.icon` | AppSvg(AppIconsInicio.checkTiny, size: 10) |  |
| `sc03.sheet.book.chevron` | AppSvg(AppIconsScanner.chevronRightFino, size: 20) |  |
| `sc03.sheet.saveAs.options` | NeoBox |  |
| `sc03.sheet.saveAs.options.wantToRead` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc03.sheet.actions.primary` | NeoBox |  |
| `sc03.sheet.actions.primary.icon` | AppSvg(AppIconsScanner.plusPapel, size: 20) |  |
| `sc03.sheet.actions.scanAgain` | CircleIconButton / NeoBox circular |  |
| `sc03.sheet.actions.scanAgain.icon` | AppSvg(AppIconsScanner.refresh, size: 22) |  |
| `sc03.sheet.footer.link` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Livro → os Detalhes (17), feitos na T14.
- Coleção → o livro entra na coleção sugerida (o visto); trocar ou tirar a coleção não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T15 (ROTEIRO §2b).
- Salvar como → o status com que o livro entra (Quero ler por padrão aqui; "Lendo" na 40).
- Adicionar à biblioteca → grava o livro com o status e a coleção; depois, o que a tela mostra (a 03 não desenha o "adicionado") segue o estado `ScanAdded` de hoje — confirmar na T15.
- Escanear outro livro → volta para a mira (39).
- Buscar pelo título → a Busca (28), com o campo vazio.

## Dados

- Título, autor, formato, páginas, ISBN e capa do catálogo; a coleção sugerida pelo gênero ou pelas coleções da pessoa (a regra é pergunta da T15; as coleções nascem na T14).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L03.1** A folha comum do Scanner (posição, alça, raio)
- **L03.2** Topo: chip e ISBN
- **L03.3** Livro e coleção
- **L03.4** Salvar como e as ações
- **L03.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc03.sheet'), todos os ids de `kRef03.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/003_scanner_encontrado_390x844@3x.png` no recorte da fase (y 417.39–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef03w360` e `kRef03w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L03.1 A folha comum do Scanner (posição, alça, raio)
- [ ] L03.2 Topo: chip e ISBN
- [ ] L03.3 Livro e coleção
- [ ] L03.4 Salvar como e as ações
- [ ] L03.5 Verificação + relatório
- [ ] Geometria 36/36 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
