# FASE L17 — Detalhes (livro físico) — barra do topo, sol retrô e a capa na prateleira

> Tela 17 · prancha `017_detalhes_fisico` (17 · Detalhes do livro — físico (Brás Cubas), canvas 390×1940) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L17_1_capa@3x.png` · `docs/design/medicao/projeto/png/redline/L17_1_capa_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_017_detalhes_fisico.json` · `test/reference/projeto/reference_layout_017_detalhes_fisico.dart` (`kRef17`).
> Arquivos sugeridos: `lib/features/library/presentation/details/book_details_screen.dart`, `lib/features/library/presentation/details/details_cover.dart`, `lib/features/library/presentation/details/sunburst_halo.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Detalhes do livro físico (17, Brás Cubas): o sol retrô verde atrás, a barra do topo (voltar, compartilhar, mais) e a capa girada −3° sobre a tábua amarela, com a etiqueta "PAPEL", dois brilhos e o selo de trocar a capa. É a tela que abre ao tocar num livro da Biblioteca.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{halo}}` = padrão `#ABCF82`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- Retro sunburst behind the cover -->
<div aria-hidden="true" style="position: absolute; left: 50%; top: 58px; width: 330px; height: 330px; margin-left: -165px; border-radius: 50%; background: repeating-conic-gradient(from 0deg, {{halo}} 0deg 9deg, #FFFAF1 9deg 18deg); border: 1.5px solid #1A1714; box-sizing: border-box;"></div>

<!-- Top bar -->
<header style="height: 48px; display: flex; align-items: center; justify-content: space-between;">
  <a href="#" aria-label="Voltar" style="width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg></a>
  <span style="display: flex; gap: 8px;">
    <button aria-label="Compartilhar" style="width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 15V3M7.5 7.5 12 3l4.5 4.5"></path><path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7"></path></svg></button>
    <button aria-label="Mais opções" style="width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="5" cy="12" r="1.3" fill="#1A1714"></circle><circle cx="12" cy="12" r="1.3" fill="#1A1714"></circle><circle cx="19" cy="12" r="1.3" fill="#1A1714"></circle></svg></button>
  </span>
</header>

<!-- Cover on its shelf -->
<div style="position: relative; height: 330px; margin-top: 2px;">
  <div style="position: absolute; left: 50%; top: 22px; width: 176px; height: 264px; margin-left: -88px; border-radius: 5px 14px 14px 5px; border: 1.5px solid #1A1714; background: #058CD7; box-shadow: 6px 6px 0 #1A1714; overflow: hidden; box-sizing: border-box; transform: rotate(-3deg);">
    <svg width="100%" height="100%" viewBox="0 0 96 144" preserveAspectRatio="xMidYMid slice" style="display: block;">
  <rect width="96" height="144" fill="#058CD7"></rect>
  <!-- a top hat with little wings: memoirs written from the other side -->
  <path d="M12 9c.2 1.4.6 1.9 1.9 2.1-1.3.2-1.7.7-1.9 2.1-.2-1.4-.6-1.9-1.9-2.1 1.3-.2 1.7-.7 1.9-2.1z" fill="#FED170"></path>
  <path d="M83 90c.3 2.2.9 3 3 3.3-2.1.3-2.7 1.1-3 3.3-.3-2.2-.9-3-3-3.3 2.1-.3 2.7-1.1 3-3.3z" fill="#FFFAF1"></path>
  <path d="M20 58c.2 1.4.6 1.9 1.9 2.1-1.3.2-1.7.7-1.9 2.1-.2-1.4-.6-1.9-1.9-2.1 1.3-.2 1.7-.7 1.9-2.1z" fill="#FFFAF1"></path>
  <text x="12" y="20" font-family="Figtree, sans-serif" font-size="4.6" font-weight="800" letter-spacing="0.8" fill="#F7F0E3">MEMÓRIAS PÓSTUMAS DE</text>
  <text x="11" y="38" font-family="'Instrument Serif', Georgia, serif" font-size="17.5" fill="#FED170">Brás Cubas</text>
  <!-- wings -->
  <path d="M33 66c-8-1-15-6-18-13 5 2 9 2 12 1-3-1-6-4-7-7 5 3 10 4 14 4z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.2" stroke-linejoin="round"></path>
  <path d="M63 66c8-1 15-6 18-13-5 2-9 2-12 1 3-1 6-4 7-7-5 3-10 4-14 4z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.2" stroke-linejoin="round"></path>
  <!-- hat -->
  <path d="M36 46h24l-2 30H38z" fill="#1A1714"></path>
  <rect x="37.2" y="68" width="21.6" height="5" fill="#FF552E"></rect>
  <ellipse cx="48" cy="77" rx="18" ry="4.2" fill="#1A1714"></ellipse>
  <path d="M40 50.5c3-1 13-1 16 0" stroke="#FFFAF1" stroke-width="1" stroke-linecap="round" opacity="0.5"></path>
  <!-- clouds -->
  <path d="M-4 120c4-8 14-8 18-3 3-6 13-7 17 0 4-5 13-4 15 3 4-6 14-5 17 1 3-5 12-5 15 1 4-3 10-2 12 2V146H-4z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path>
  <path d="M-4 134c5-5 12-5 16-1 4-4 11-4 15 0 4-4 12-4 16 0 4-4 11-4 15 0 4-4 11-4 15 0 4-3 9-3 13 0V146H-4z" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path>
  <text x="12.5" y="104" font-family="Figtree, sans-serif" font-size="5.2" font-weight="700" letter-spacing="0.9" fill="#F7F0E3">MACHADO DE ASSIS</text>
</svg>
    <span aria-hidden="true" style="position: absolute; left: 0; top: 0; bottom: 0; width: 10px; background: rgba(0,0,0,0.2);"></span>
  </div>
  <span style="position: absolute; left: 50%; top: 10px; margin-left: 52px; height: 30px; padding: 0 11px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 900; letter-spacing: 1.1px; transform: rotate(9deg);"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"></path></svg>PAPEL</span>
  <svg aria-hidden="true" width="26" height="26" viewBox="0 0 24 24" style="position: absolute; left: 22px; top: 200px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>
  <svg aria-hidden="true" width="16" height="16" viewBox="0 0 24 24" style="position: absolute; right: 24px; top: 86px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>
  <button aria-label="Trocar a capa (fotografar a sua edição, galeria ou voltar para a capa original)" style="position: absolute; left: 50%; top: 250px; margin-left: 64px; z-index: 1; width: 42px; height: 42px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8.5A1.5 1.5 0 0 1 5.5 7H8l1.5-2h5L16 7h2.5A1.5 1.5 0 0 1 20 8.5v9a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 17.5z"></path><path d="M14.6 11.2a3 3 0 0 0-5.3 1"></path><path d="M9.4 14.8a3 3 0 0 0 5.3-1"></path><path d="M14.8 9.6v1.8H13M9.2 16.4v-1.8H11"></path></svg></button>
  <!-- shelf plank -->
  <span aria-hidden="true" style="position: absolute; left: -6px; right: -6px; top: 292px; height: 16px; border-radius: 4px; background: {{shelf}}; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box;"></span>
</div>
```

## Especificação pixel a pixel

Seção `d17.halo` — retângulo absoluto no canvas 390×1940: **x=30, y=58, w=330, h=330**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `d17.halo` | box | 0 | 0 | 330 | 330 | `position: absolute; left: 50%; top: 58px; width: 330px; height: 330px; margin-left: -165px; border-radius: 50%; background: repeating-conic-gradient(from 0deg, {{halo}} (padrão #ABCF82) 0deg 9deg, #FFFAF1 9deg 18deg); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 2 | `d17.halo.center` | box | 110 | 110 | 110 | 110 | `position: absolute; left: 50%; top: 168px; width: 110px; height: 110px; margin-left: -55px; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box` |  |

Seção `d17.header` — retângulo absoluto no canvas 390×1940: **x=20, y=58, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `d17.header` | box | 0 | 0 | 350 | 48 | `height: 48px; display: flex; align-items: center; justify-content: space-between` |  |
| 4 | `d17.header.back` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 5 | `d17.header.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |
| 6 | `d17.header.actions` | box | 246 | 0 | 104 | 48 | `display: flex; gap: 8px` |  |
| 7 | `d17.header.share` | box | 246 | 0 | 48 | 48 | `width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 8 | `d17.header.share.icon` | icon | 260 | 14 | 20 | 20 | `—` |  |
| 9 | `d17.header.more` | box | 302 | 0 | 48 | 48 | `width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 10 | `d17.header.more.icon` | icon | 316 | 14 | 20 | 20 | `—` |  |

Seção `d17.cover` — retângulo absoluto no canvas 390×1940: **x=20, y=108, w=350, h=330**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 11 | `d17.cover` | box | 0 | 0 | 350 | 330 | `position: relative; height: 330px; margin-top: 2px` |  |
| 12 | `d17.cover.book` | box | 87 | 22 | 176 | 264 | `position: absolute; left: 50%; top: 22px; width: 176px; height: 264px; margin-left: -88px; border-radius: 5px 14px 14px 5px; border: 1.5px solid #1A1714; background: #058CD7; box-shadow: 6px 6px 0 #1A1714; overflow: hidden; box-sizing: border-box; transform: rotate(-3deg)` |  |
| 13 | `d17.cover.book.art` | icon | 88.5 | 23.5 | 173 | 261 | `display: block` |  |
| 14 | `d17.cover.book.spine` | box | 88.5 | 23.5 | 10 | 261 | `position: absolute; left: 0; top: 0; bottom: 0; width: 10px; background: rgba(0,0,0,0.2)` |  |
| 15 | `d17.cover.formatTag` ±1 | box+text | 227 | 10 | 85.06 | 30 | `position: absolute; left: 50%; top: 10px; margin-left: 52px; height: 30px; padding: 0 11px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 900; letter-spacing: 1.1px; transform: rotate(9deg)` | Figtree 11.5/normal peso 900→**800** ls 1.1px #1A1714 |
| 16 | `d17.cover.formatTag.icon` | icon | 239.5 | 18 | 14 | 14 | `—` |  |
| 17 | `d17.cover.sparkleLarge` | icon | 22 | 200 | 26 | 26 | `position: absolute; left: 22px; top: 200px` |  |
| 18 | `d17.cover.sparkleSmall` | icon | 310 | 86 | 16 | 16 | `position: absolute; right: 24px; top: 86px` |  |
| 19 | `d17.cover.change` | box | 239 | 250 | 42 | 42 | `position: absolute; left: 50%; top: 250px; margin-left: 64px; z-index: 1; width: 42px; height: 42px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 20 | `d17.cover.change.icon` | icon | 250 | 261 | 20 | 20 | `—` |  |
| 21 | `d17.cover.plank` | box | -6 | 292 | 362 | 16 | `position: absolute; left: -6px; right: -6px; top: 292px; height: 16px; border-radius: 4px; background: {{shelf}} (padrão #FED170); border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `d17.cover.book`: caixa visual com `transform: rotate(-3deg)` = x 80.21, y 17.58, w 189.58, h 272.85 (relativa à seção).
- `d17.cover.book.art`: caixa visual deslocada pelo transform de um ancestral = x 81.79, y 19.15, w 186.42, h 269.7 (relativa à seção).
- `d17.cover.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 81.79, y 27.68, w 23.65, h 261.17 (relativa à seção).
- `d17.cover.formatTag`: caixa visual com `transform: rotate(9deg)` = x 225.18, y 3.53, w 88.7, h 42.94 (relativa à seção).
- `d17.cover.formatTag.icon`: caixa visual deslocada pelo transform de um ancestral = x 238.77, y 13.39, w 16.02, h 16.02 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17.cover.formatTag` | 1 | PAPEL | 29.03 | 258.5 | 299.56 | 41.06 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Sol: círculo 330 centrado em x 195, top 58, `repeating-conic-gradient` de 9° em 9° entre `{{halo}}` (verde `#ABCF82` na 17, lavanda `#B6ACE4` na 17b) e `#FFFAF1`, borda 1,5 — 20 raios de cada cor a partir do topo, no sentido horário: `ConicRingPainter`.
2. Barra do topo de 48: voltar à esquerda; compartilhar e "mais" à direita (gap 8). Círculos 48 `#FFFAF1`, borda 1,5, sem sombra; ícones 20 (traço 2,2 no voltar, 2 nos outros).
3. Capa 176 × 264 (top 22 na área de 330, `margin-left −88`), raio 5/14/14/5, borda 1,5, sombra dura 6/6, girada −3° no centro: o desenho do Brás Cubas com asas (o mesmo da Início, `coverBrasCubasWings`) e a lombada de 10 `rgba(0,0,0,.2)`.
4. Etiqueta "PAPEL": pílula de 30, `#FED170`, borda 1,5, sombra 2/2, ícone 14 + 11,5/900 (→ 800) ls 1,1, girada 9°, em `left 50% + 52 · top 10`. Brilhos: creme 26 (`left 22 · top 200`) e preto 16 (`right 24 · top 86`). Trocar a capa: círculo 42, sombra 2/2, ícone 20, em `left 50% + 64 · top 250`, por cima da capa (`z-index 1`).
5. Tábua: `left/right −6`, top 292, 16 de altura, raio 4, `{{shelf}}`, borda 1,5, sombra 0/4.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O desenho da capa tem `<text>` e `slice` (ver o mapa de widgets): `AppSvg` sem os textos em `BoxFit.cover` e os textos em `AppText` por cima, nas posições do viewBox × a escala — como o herói da Início.
- O sol vem antes no HTML e fica por baixo da barra e da capa; rola com a tela (é conteúdo, não fundo fixo).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_017_detalhes_fisico_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_017_detalhes_fisico_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `d17.halo` |  |  | aria-hidden=true |
| `d17.halo.center` |  |  | aria-hidden=true |
| `d17.header.back` |  | Voltar |  |
| `d17.header.back.icon` |  |  | aria-hidden=true |
| `d17.header.share` |  | Compartilhar |  |
| `d17.header.share.icon` |  |  | aria-hidden=true |
| `d17.header.more` |  | Mais opções |  |
| `d17.header.more.icon` |  |  | aria-hidden=true |
| `d17.cover.book.spine` |  |  | aria-hidden=true |
| `d17.cover.formatTag.icon` |  |  | aria-hidden=true |
| `d17.cover.sparkleLarge` |  |  | aria-hidden=true |
| `d17.cover.sparkleSmall` |  |  | aria-hidden=true |
| `d17.cover.change` |  | Trocar a capa (fotografar a sua edição, galeria ou voltar para a capa original) |  |
| `d17.cover.change.icon` |  |  | aria-hidden=true |
| `d17.cover.plank` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `d17.halo` | ConicRingPainter (anel arco-íris) |  |
| `d17.halo.center` | CircleIconButton / NeoBox circular |  |
| `d17.header.back` | CircleIconButton / NeoBox circular |  |
| `d17.header.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `d17.header.share` | CircleIconButton / NeoBox circular |  |
| `d17.header.share.icon` | AppSvg(AppIconsLeitor.share, size: 20) |  |
| `d17.header.more` | CircleIconButton / NeoBox circular |  |
| `d17.header.more.icon` | AppSvg(AppIconsInicio.moreCircles, size: 20) |  |
| `d17.cover.book` | NeoBox | Transform: rotate(-3deg) |
| `d17.cover.book.art` | AppSvg(AppIllustrationsInicio.coverBrasCubasWings, size: 173×261) | capa da Início com `<text>` ("MEMÓRIAS PÓSTUMAS DE" Figtree 800 4,6 ls 0,8; "Brás Cubas" Instrument Serif 17,5; "MACHADO DE ASSIS" Figtree 700 5,2 ls 0,9) e preserveAspectRatio="xMidYMid slice", width/height 100% da caixa 173×261 (escala max(173/96, 261/144) = 1,8125): AppSvg sem os textos em BoxFit.cover e os textos em AppText por cima, nas posições × escala (como o herói da Início). |
| `d17.cover.book.spine` | NeoBox |  |
| `d17.cover.formatTag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) | Transform: rotate(9deg) |
| `d17.cover.formatTag.icon` | AppSvg(AppIconsInicio.bookPaper, size: 14) |  |
| `d17.cover.sparkleLarge` | AppSvg(AppIconsBiblioteca.sparkleCreme, size: 26) |  |
| `d17.cover.sparkleSmall` | AppSvg(AppIcons.sparkleSolid, size: 16) |  |
| `d17.cover.change` | CircleIconButton / NeoBox circular |  |
| `d17.cover.change.icon` | AppSvg(AppIconsBiblioteca.cameraSwap, size: 20) |  |
| `d17.cover.plank` | NeoBox |  |

## Interações

- Voltar → a tela anterior (a Biblioteca, a Início ou a Busca).
- Compartilhar → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T14 (ROTEIRO §2b) (ou a folha do sistema, se a T14 decidir).
- "Mais opções" (⋯) → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T14 (ROTEIRO §2b).
- Trocar a capa → tela que falta (D-268), da própria T14 (ROTEIRO §5). Pela nota do design: fotografar a capa da edição que a pessoa tem, escolher da galeria ou voltar para a capa original; a foto fica só para ela.

## Dados

- Capa: a do catálogo ou a foto da pessoa (D-79); a etiqueta diz o formato do livro (PAPEL, E-BOOK…).
- O sol e o cartão do meio seguem o formato: verde no papel (17), lavanda no e-book (17b) — no app, pelos tokens, não fixos no widget.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L17.1** A tela dos Detalhes na rota do livro (`AppRoutes.livro`)
- **L17.2** Sol retrô (ConicRingPainter)
- **L17.3** Barra do topo
- **L17.4** Capa girada na tábua, etiqueta, brilhos e trocar a capa
- **L17.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('d17.halo', 'd17.header', 'd17.cover'), todos os ids de `kRef17.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@3x.png` no recorte da fase (y 50–446) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef17w360` e `kRef17w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L17.1 A tela dos Detalhes na rota do livro (`AppRoutes.livro`)
- [ ] L17.2 Sol retrô (ConicRingPainter)
- [ ] L17.3 Barra do topo
- [ ] L17.4 Capa girada na tábua, etiqueta, brilhos e trocar a capa
- [ ] L17.5 Verificação + relatório
- [ ] Geometria 21/21 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
