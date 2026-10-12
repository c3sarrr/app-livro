# FASE L02 — Biblioteca — abas de status, ordenar e grade/lista

> Tela 02 · prancha `002_biblioteca` (02 · Biblioteca, canvas 390×1640) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L02_3_status_e_ordem@3x.png` · `docs/design/medicao/projeto/png/redline/L02_3_status_e_ordem_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/002_biblioteca_390x1640@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_002_biblioteca.json` · `test/reference/projeto/reference_layout_002_biblioteca.dart` (`kRef02`).
> Arquivos sugeridos: `lib/features/library/presentation/sections/status_tabs.dart`, `lib/features/library/presentation/sections/sort_view_bar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

As abas de status (Todos 86 · Lendo 4 · Quero ler 26 · Lidos 52 · Favoritos 12 · Abandonados 4), presas no topo enquanto a estante rola, e a linha de ordenar ("Ordenar: Recentes") com o seletor grade/lista.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- Reading status (pinned while the shelf scrolls) -->
<div role="tablist" aria-label="Status de leitura" style="margin: 18px -20px 0; padding: 2px 20px 4px; display: flex; gap: 8px; overflow: hidden;">
  <button role="tab" aria-selected="true" style="flex-shrink: 0; height: 42px; padding: 0 8px 0 16px; display: flex; align-items: center; gap: 8px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800;">
    Todos
    <span style="min-width: 28px; height: 26px; padding: 0 7px; box-sizing: border-box; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800; display: flex; align-items: center; justify-content: center;">86</span>
  </button>
  <button role="tab" aria-selected="false" style="flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600;">Lendo <span style="font-size: 12px; font-weight: 700; color: #6F665B;">4</span></button>
  <button role="tab" aria-selected="false" style="flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600;">Quero ler <span style="font-size: 12px; font-weight: 700; color: #6F665B;">26</span></button>
  <button role="tab" aria-selected="false" style="flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600;">Lidos <span style="font-size: 12px; font-weight: 700; color: #6F665B;">52</span></button>
  <button role="tab" aria-selected="false" style="flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600;">Favoritos <span style="font-size: 12px; font-weight: 700; color: #6F665B;">12</span></button>
  <button role="tab" aria-selected="false" style="flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600;">Abandonados <span style="font-size: 12px; font-weight: 700; color: #6F665B;">4</span></button>
</div>

<!-- Sort + view (the active chip already carries the count) -->
<div style="margin-top: 10px; display: flex; align-items: center; justify-content: space-between; gap: 8px;">
  <button aria-label="Ordenar por: Recentes" style="height: 44px; margin-left: -10px; padding: 0 10px; display: flex; align-items: center; gap: 6px; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 700;">
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 4v16M3.5 7.5 7 4l3.5 3.5M17 20V4M13.5 16.5 17 20l3.5-3.5"></path></svg>
    <span style="font-weight: 500; color: #5B544B;">Ordenar:</span> Recentes
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"></path></svg>
  </button>
  <div role="radiogroup" aria-label="Visualização" style="height: 44px; padding: 3px; box-sizing: border-box; display: flex; gap: 2px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714;">
    <button role="radio" aria-checked="true" aria-label="Grade" style="width: 44px; height: 100%; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.8"><rect x="4" y="4" width="6.5" height="6.5" rx="1.6"></rect><rect x="13.5" y="4" width="6.5" height="6.5" rx="1.6"></rect><rect x="4" y="13.5" width="6.5" height="6.5" rx="1.6"></rect><rect x="13.5" y="13.5" width="6.5" height="6.5" rx="1.6"></rect></svg>
    </button>
    <button role="radio" aria-checked="false" aria-label="Lista" style="width: 44px; height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; display: flex; align-items: center; justify-content: center;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round"><path d="M9 6h11M9 12h11M9 18h11"></path><circle cx="4.5" cy="6" r="1.1" fill="#1A1714"></circle><circle cx="4.5" cy="12" r="1.1" fill="#1A1714"></circle><circle cx="4.5" cy="18" r="1.1" fill="#1A1714"></circle></svg>
    </button>
  </div>
</div>
```

## Especificação pixel a pixel

Seção `b02.statusTabs` — retângulo absoluto no canvas 390×1640: **x=0, y=366, w=390, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `b02.statusTabs` | box | 0 | 0 | 390 | 48 | `margin: 18px -20px 0; padding: 2px 20px 4px; display: flex; gap: 8px; overflow: hidden` |  |
| 2 | `b02.statusTabs.all` ±1 | box+text | 20 | 2 | 104.6 | 42 | `flex-shrink: 0; height: 42px; padding: 0 8px 0 16px; display: flex; align-items: center; gap: 8px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 3 | `b02.statusTabs.all.count` ±1 | box+text | 84.34 | 10 | 30.76 | 26 | `min-width: 28px; height: 26px; padding: 0 7px; box-sizing: border-box; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 4 | `b02.statusTabs.reading` ±1 | box+text | 132.6 | 2 | 87.03 | 42 | `flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 5 | `b02.statusTabs.reading.count` ±1 | text | 196.54 | 15.8 | 7.6 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |
| 6 | `b02.statusTabs.wantToRead` ±1 | box+text | 227.63 | 2 | 113.2 | 42 | `flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 7 | `b02.statusTabs.wantToRead.count` ±1 | text | 311.42 | 15.8 | 13.91 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |
| 8 | `b02.statusTabs.read` ±1 | box+text | 348.83 | 2 | 87.77 | 42 | `flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 9 | `b02.statusTabs.read.count` ±1 | text | 407.18 | 15.8 | 13.92 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |
| 10 | `b02.statusTabs.favorites` ±1 | box+text | 444.6 | 2 | 110.96 | 42 | `flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 11 | `b02.statusTabs.favorites.count` ±1 | text | 528.05 | 15.8 | 12.01 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |
| 12 | `b02.statusTabs.abandoned` ±1 | box+text | 563.57 | 2 | 135.47 | 42 | `flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 13 | `b02.statusTabs.abandoned.count` ±1 | text | 675.94 | 15.8 | 7.6 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b02.statusTabs.all` | 1 | Todos | 27.9 | 37.5 | 76.34 | 38.84 |
| `b02.statusTabs.all.count` | 1 | 86 | 27.2 | 92.54 | 106.9 | 14.36 |
| `b02.statusTabs.reading` | 1 | Lendo | 27.9 | 150.1 | 189.54 | 39.44 |
| `b02.statusTabs.reading.count` | 1 | 4 | 27.2 | 196.54 | 204.13 | 7.59 |
| `b02.statusTabs.wantToRead` | 1 | Quero ler | 27.9 | 245.13 | 304.42 | 59.29 |
| `b02.statusTabs.wantToRead.count` | 1 | 26 | 27.2 | 311.42 | 325.33 | 13.91 |
| `b02.statusTabs.read` | 1 | Lidos | 27.9 | 366.33 | 400.18 | 33.85 |
| `b02.statusTabs.read.count` | 1 | 52 *(oculta: recortada)* | 27.2 | 407.18 | 421.1 | 13.92 |
| `b02.statusTabs.favorites` | 1 | Favoritos *(oculta: recortada)* | 27.9 | 462.1 | 521.05 | 58.95 |
| `b02.statusTabs.favorites.count` | 1 | 12 *(oculta: recortada)* | 27.2 | 528.05 | 540.07 | 12.02 |
| `b02.statusTabs.abandoned` | 1 | Abandonados *(oculta: recortada)* | 27.9 | 581.07 | 668.94 | 87.87 |
| `b02.statusTabs.abandoned.count` | 1 | 4 *(oculta: recortada)* | 27.2 | 675.94 | 683.54 | 7.6 |

Seção `b02.sortView` — retângulo absoluto no canvas 390×1640: **x=20, y=424, w=350, h=44**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 14 | `b02.sortView` | box | 0 | 0 | 350 | 44 | `margin-top: 10px; display: flex; align-items: center; justify-content: space-between; gap: 8px` |  |
| 15 | `b02.sortView.sort` ±1 | text | -10 | 0 | 187.3 | 44 | `height: 44px; margin-left: -10px; padding: 0 10px; display: flex; align-items: center; gap: 6px; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 16 | `b02.sortView.sort.icon` | icon | 0 | 13 | 18 | 18 | `—` |  |
| 17 | `b02.sortView.sort.prefix` ±1 | text | 24 | 13.6 | 55.38 | 16.8 | `font-weight: 500; color: #5B544B` | Figtree 14/normal peso 500 ls normal #5B544B |
| 18 | `b02.sortView.sort.chevron` ±1 | icon | 151.3 | 14 | 16 | 16 | `—` |  |
| 19 | `b02.sortView.toggle` | box | 251 | 0 | 99 | 44 | `height: 44px; padding: 3px; box-sizing: border-box; display: flex; gap: 2px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714` |  |
| 20 | `b02.sortView.toggle.grid` | box | 255.5 | 4.5 | 44 | 35 | `width: 44px; height: 100%; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 21 | `b02.sortView.toggle.grid.icon` | icon | 268.5 | 13 | 18 | 18 | `—` |  |
| 22 | `b02.sortView.toggle.list` | box | 301.5 | 4.5 | 44 | 35 | `width: 44px; height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; display: flex; align-items: center; justify-content: center` |  |
| 23 | `b02.sortView.toggle.list.icon` | icon | 314.5 | 13 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b02.sortView.sort` | 1 | Recentes | 26.9 | 85.38 | 145.3 | 59.92 |
| `b02.sortView.sort.prefix` | 1 | Ordenar: | 26.9 | 24 | 79.38 | 55.38 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Abas: fila de 42 de altura, gap 8, com `margin 18 −20 0` e `padding 2 20 4`, `overflow: hidden`. A marcada: fundo `{{brand}}`, borda 1,5 preta, sombra dura 2/2, padding 0/8/0/16, gap 8, "Todos" Figtree 14/800 e o contador em pílula (mín. 28 × 26, `#FFFAF1`, borda 1,2, 12/800).
2. As outras: `#FFFAF1` com borda 1,5 **`#E2D7C4`** (bege, não preta), sem sombra, padding 0/14/0/16, gap 7, rótulo 14/600 e o número solto 12/700 `#6F665B`. A partir de "Lidos" as abas saem do quadro (a fila corta).
3. Ordenar, 10 abaixo: botão de 44 de altura com `margin-left −10` (o ícone fica a 10 da margem), ícone 18 + "Ordenar:" 14/500 `#5B544B` + "Recentes" 14/700 + a seta 16 (traço 2,2), gap 6.
4. Grade/lista: pílula de 44, padding 3, gap 2, borda 1,5; a opção marcada é um círculo 44 de largura (altura da pílula menos o padding) em `{{brand}}`, borda 1,5, com a grade de quadrados preenchidos `#FFFAF1`; a lista fica sem fundo nem borda.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- Marcar uma aba muda borda (preta × bege), sombra, padding (16/8 × 16/14), gap (8 × 7), peso (800 × 600) e o contador (pílula × número solto) — não é só a cor: um widget com os dois estados, e o golden das duas pontas (a marcada e uma desmarcada).
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `b02.statusTabs.read.count`, `b02.statusTabs.favorites`, `b02.statusTabs.favorites.count`, `b02.statusTabs.abandoned`, `b02.statusTabs.abandoned.count`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_002_biblioteca_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_002_biblioteca_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `b02.statusTabs.read` | sai do quadro (x) | 76.6 | 46.6 | não | sim |  |
| 360 | `b02.statusTabs.read` | passa do pai (x) | 76.6 | 46.6 | não | sim | pai `b02.statusTabs` (cortado) |
| 360 | `b02.statusTabs.favorites` | sai do quadro (x) | 195.56 | 165.56 | não | sim |  |
| 360 | `b02.statusTabs.favorites` | passa do pai (x) | 195.56 | 165.56 | não | sim | pai `b02.statusTabs` (cortado) |
| 360 | `b02.statusTabs.abandoned` | sai do quadro (x) | 339.04 | 309.04 | não | sim |  |
| 360 | `b02.statusTabs.abandoned` | passa do pai (x) | 339.04 | 309.04 | não | sim | pai `b02.statusTabs` (cortado) |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `b02.statusTabs` | tablist | Status de leitura |  |
| `b02.statusTabs.all` | tab |  | aria-selected=true |
| `b02.statusTabs.reading` | tab |  | aria-selected=false |
| `b02.statusTabs.wantToRead` | tab |  | aria-selected=false |
| `b02.statusTabs.read` | tab |  | aria-selected=false |
| `b02.statusTabs.favorites` | tab |  | aria-selected=false |
| `b02.statusTabs.abandoned` | tab |  | aria-selected=false |
| `b02.sortView.sort` |  | Ordenar por: Recentes |  |
| `b02.sortView.sort.icon` |  |  | aria-hidden=true |
| `b02.sortView.sort.chevron` |  |  | aria-hidden=true |
| `b02.sortView.toggle` | radiogroup | Visualização |  |
| `b02.sortView.toggle.grid` | radio | Grade | aria-checked=true |
| `b02.sortView.toggle.list` | radio | Lista | aria-checked=false |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `b02.statusTabs.all` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.statusTabs.all.count` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.statusTabs.reading` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.statusTabs.wantToRead` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.statusTabs.read` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.statusTabs.favorites` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.statusTabs.abandoned` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.sortView.sort.icon` | AppSvg(AppIconsBiblioteca.sort, size: 18) |  |
| `b02.sortView.sort.chevron` | AppSvg(AppIconsBiblioteca.chevronDown, size: 16) |  |
| `b02.sortView.toggle` | NeoBox |  |
| `b02.sortView.toggle.grid` | NeoBox |  |
| `b02.sortView.toggle.grid.icon` | AppSvg(AppIconsBiblioteca.viewGrid, size: 18) |  |
| `b02.sortView.toggle.list.icon` | AppSvg(AppIconsBiblioteca.viewList, size: 18) |  |

## Interações

- Aba → filtra a estante pelo status; a contagem de cada uma vem do banco.
- As abas ficam presas no topo quando a estante rola (o comentário da prancha: "pinned while the shelf scrolls"): `SliverPersistentHeader` fixo, e a fila rola de lado (a 360 já corta na 4ª aba).
- Ordenar → o menu das ordens não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T14 (ROTEIRO §2b).
- Grade/lista → a vista em lista não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T14 (ROTEIRO §2b).

## Dados

- Contagens do banco local: Todos = Lendo + Quero ler + Lidos + Abandonados (4 + 26 + 52 + 4 = 86, a revisão de consistência do design); Favoritos conta à parte (o livro favorito também tem um status).
- O `ShelfStatus` já tem os quatro status (`abandoned` incluído); "favorito" ainda não existe no `user_books` — o campo novo é pergunta da T14 (sem ele, a aba segue a D-247).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L02.1** Abas de status com as contagens
- **L02.2** Abas presas ao rolar
- **L02.3** Ordenar e grade/lista
- **L02.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('b02.statusTabs', 'b02.sortView'), todos os ids de `kRef02.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/002_biblioteca_390x1640@3x.png` no recorte da fase (y 358–476) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef02w360` e `kRef02w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L02.1 Abas de status com as contagens
- [ ] L02.2 Abas presas ao rolar
- [ ] L02.3 Ordenar e grade/lista
- [ ] L02.4 Verificação + relatório
- [ ] Geometria 23/23 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
