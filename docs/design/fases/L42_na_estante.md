# FASE L42 — Scanner (já está na estante) — a folha: o progresso, a meta do dia e Iniciar leitura

> Tela 42 · prancha `042_scanner_na_estante` (42 · Scanner — já está na estante, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L42_na_estante@3x.png` · `docs/design/medicao/projeto/png/redline/L42_na_estante_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/042_scanner_na_estante_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_042_scanner_na_estante.json` · `test/reference/projeto/reference_layout_042_scanner_na_estante.dart` (`kRef42`).
> Arquivos sugeridos: `lib/features/scanner/presentation/sheets/on_shelf_sheet.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Já está na estante (42): o mesmo Brás Cubas, semanas depois. Em vez de duplicar, o chip lavanda "Já está na sua estante", o livro com a barra de progresso (pág. 74 de 208 · 36 %), a meta do dia (18 de 30 min) e "Iniciar leitura" — escanear vira o atalho mais rápido para uma sessão.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<section role="dialog" aria-label="Já está na sua estante" style="position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">
  <span aria-hidden="true" style="align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD;"></span>
  <div style="margin-top: 12px; display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 6px 8px;">
    <span style="display: flex; align-items: center; gap: 5px; height: 26px; padding: 0 10px 0 8px; box-sizing: border-box; border-radius: 999px; background: {{brand}}; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800; white-space: nowrap;"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 4v16M8.5 4v16"></path><path d="M13 5.2l3.6-1 4 15.4-3.6 1z"></path><path d="M3 20h18"></path></svg>Já está na sua estante</span>
    <span style="font-size: 12px; font-weight: 600; color: #5B544B; white-space: nowrap; font-variant-numeric: tabular-nums;">ISBN 978-65-5921-104-3</span>
  </div>

  <a href="#" aria-label="Ver detalhes de Memórias Póstumas de Brás Cubas" style="margin-top: 14px; display: flex; align-items: center; gap: 14px;">
    <div style="position: relative; width: 72px; height: 108px; flex-shrink: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box; box-shadow: 3px 3px 0 #1A1714;">
      <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.15);"></div>
      <div style="position: absolute; left: 14px; right: -26px; bottom: -44px; height: 88px; border-radius: 50%; background: #1A1714;"></div>
      <div style="position: absolute; left: 12px; right: 6px; top: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 12.5px; line-height: 0.95; color: #1A1714;">Memórias Póstumas de Brás Cubas</div>
      <div style="position: absolute; left: 22px; bottom: 9px; font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FF552E;">MACHADO DE ASSIS</div>
    </div>
    <div style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
      <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; line-height: 1.1; letter-spacing: -0.4px;">Memórias Póstumas de Brás Cubas</h2>
      <span style="font-size: 13px; font-weight: 600; color: #5B544B;">Machado de Assis · físico</span>
      <span style="margin-top: 6px; display: flex; align-items: center; gap: 8px;">
        <span role="progressbar" aria-label="Progresso" aria-valuenow="36" aria-valuemin="0" aria-valuemax="100" style="flex-grow: 1; height: 9px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E4DACA 0 2px, #FFFAF1 2px 4px); overflow: hidden;"><span style="display: block; width: 36%; height: 100%; background: #FF552E; border-right: 1.3px solid #1A1714; box-sizing: border-box;"></span></span>
        <span style="font-size: 12.5px; font-weight: 800; font-variant-numeric: tabular-nums;">36%</span>
      </span>
      <span style="font-size: 12.5px; font-weight: 600; color: #5B544B;">Lendo · <strong style="color: #1A1714;">pág. 74</strong> de 208</span>
    </div>
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg>
  </a>

  <div style="margin-top: 14px; padding: 10px 12px; border-radius: 16px; background: #F7F0E3; border: 1.3px dashed #CFC3AE; display: flex; align-items: center; gap: 10px;">
    <svg width="34" height="34" viewBox="0 0 46 46" aria-hidden="true" style="flex-shrink: 0;"><circle cx="23" cy="23" r="18" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5"></circle><circle cx="23" cy="23" r="12" fill="none" stroke="#EAD9A6" stroke-width="6"></circle><circle cx="23" cy="23" r="12" fill="none" stroke="#1A1714" stroke-width="6" stroke-dasharray="45.2 75.4" transform="rotate(-90 23 23)"></circle></svg>
    <span style="min-width: 0; font-size: 13px; font-weight: 600; line-height: 1.35; color: #5B544B;"><strong style="color: #1A1714;">18 de 30 min hoje.</strong> Faltam 12 para a meta do dia; a sequência de 12 dias já está garantida.</span>
  </div>

  <div style="margin-top: 14px; display: flex; gap: 10px;">
    <button style="flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; border: none; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700;"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#FED170" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path><path d="M12 2.5V6"></path><path d="m18.5 6.5 1.5-1.5"></path></svg><span style="color: #F7F0E3;">Iniciar leitura</span></button>
    <button aria-label="Escanear outro livro" style="width: 54px; height: 54px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 12a8 8 0 1 1-2.35-5.65"></path><path d="M20 4v5h-5"></path></svg></button>
  </div>
  <p style="margin: 14px 0 0; text-align: center; font-size: 13.5px; font-weight: 500; color: #5B544B;">É outra edição? <a href="#" style="font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px;">Adicionar mesmo assim</a></p>
</section>
```

## Especificação pixel a pixel

Seção `sc42.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=464.09, w=370, h=369.91**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc42.sheet` | box | 0 | 0 | 370 | 369.91 | `position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 2 | `sc42.sheet.handle` | box | 165 | 11.5 | 40 | 5 | `align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD` |  |
| 3 | `sc42.sheet.top` | box | 19.5 | 28.5 | 331 | 26 | `margin-top: 12px; display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 6px 8px` |  |
| 4 | `sc42.sheet.chip` ±1 | box+text | 19.5 | 28.5 | 161.3 | 26 | `display: flex; align-items: center; gap: 5px; height: 26px; padding: 0 10px 0 8px; box-sizing: border-box; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800; white-space: nowrap` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 5 | `sc42.sheet.chip.icon` | icon | 28.7 | 35 | 13 | 13 | `—` |  |
| 6 | `sc42.sheet.isbn` ±1 | text | 202.42 | 34.3 | 148.08 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B; white-space: nowrap; font-variant-numeric: tabular-nums` | Figtree 12/normal peso 600 ls normal #5B544B tnum |
| 7 | `sc42.sheet.book` | box | 19.5 | 68.5 | 331 | 108 | `margin-top: 14px; display: flex; align-items: center; gap: 14px` |  |
| 8 | `sc42.sheet.book.cover` | box | 19.5 | 68.5 | 72 | 108 | `position: relative; width: 72px; height: 108px; flex-shrink: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box; box-shadow: 3px 3px 0 #1A1714` |  |
| 9 | `sc42.sheet.book.cover.spine` | box | 21 | 70 | 6 | 105 | `position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.15)` |  |
| 10 | `sc42.sheet.book.cover.ellipse` | box | 35 | 131 | 81 | 88 | `position: absolute; left: 14px; right: -26px; bottom: -44px; height: 88px; border-radius: 50%; background: #1A1714` |  |
| 11 | `sc42.sheet.book.cover.title` | text | 33 | 81 | 51 | 47.5 | `position: absolute; left: 12px; right: 6px; top: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 12.5px; line-height: 0.95; color: #1A1714` | Instrument Serif 12.5/11.875px peso 400 ls normal #1A1714 |
| 12 | `sc42.sheet.book.cover.author` | text | 43 | 152.78 | 47 | 13.22 | `position: absolute; left: 22px; bottom: 9px; font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FF552E` | Figtree 5.5/normal peso 700 ls 0.77px #FF552E |
| 13 | `sc42.sheet.book.textBlock` | box | 105.5 | 72.39 | 211 | 100.22 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 14 | `sc42.sheet.book.title` | text | 105.5 | 72.39 | 211 | 39.6 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; line-height: 1.1; letter-spacing: -0.4px` | Bricolage (opsz 18) 18/19.8px peso 800 ls -0.4px #1A1714 |
| 15 | `sc42.sheet.book.author` | text | 105.5 | 114.99 | 211 | 15.6 | `font-size: 13px; font-weight: 600; color: #5B544B` | Figtree 13/normal peso 600 ls normal #5B544B |
| 16 | `sc42.sheet.book.progress` | box | 105.5 | 139.59 | 211 | 15.01 | `margin-top: 6px; display: flex; align-items: center; gap: 8px` |  |
| 17 | `sc42.sheet.book.progress.bar` ±1 | box | 105.5 | 142.59 | 176.79 | 9 | `flex-grow: 1; height: 9px; border-radius: 999px; border: 1.3px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E4DACA 0 2px, #FFFAF1 2px 4px); overflow: hidden` |  |
| 18 | `sc42.sheet.book.progress.bar.fill` ±1 | box | 106.8 | 143.9 | 62.71 | 6.4 | `display: block; width: 36%; height: 100%; background: #FF552E; border-right: 1.3px solid #1A1714; box-sizing: border-box` |  |
| 19 | `sc42.sheet.book.progress.percent` ±1 | text | 290.29 | 139.59 | 26.21 | 15.01 | `font-size: 12.5px; font-weight: 800; font-variant-numeric: tabular-nums` | Figtree 12.5/normal peso 800 ls normal #1A1714 tnum |
| 20 | `sc42.sheet.book.reading` | text | 105.5 | 157.6 | 211 | 15.01 | `font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 21 | `sc42.sheet.book.reading.page` ±1 | inline | 149.96 | 157.6 | 43.17 | 15.01 | `color: #1A1714` | Figtree 12.5/normal peso 900→**800** ls normal #1A1714 |
| 22 | `sc42.sheet.book.chevron` | icon | 330.5 | 112.5 | 20 | 20 | `flex-shrink: 0` |  |
| 23 | `sc42.sheet.goal` | box | 19.5 | 190.5 | 331 | 57.7 | `margin-top: 14px; padding: 10px 12px; border-radius: 16px; background: #F7F0E3; border: 1.3px dashed #CFC3AE; display: flex; align-items: center; gap: 10px` |  |
| 24 | `sc42.sheet.goal.ring` | icon | 32.8 | 202.35 | 34 | 34 | `flex-shrink: 0` |  |
| 25 | `sc42.sheet.goal.text` | text | 76.8 | 201.8 | 260.4 | 35.1 | `min-width: 0; font-size: 13px; font-weight: 600; line-height: 1.35; color: #5B544B` | Figtree 13/17.55px peso 600 ls normal #5B544B |
| 26 | `sc42.sheet.goal.text.strong` ±1 | inline | 76.8 | 202.77 | 108.69 | 15.6 | `color: #1A1714` | Figtree 13/17.55px peso 900→**800** ls normal #1A1714 |
| 27 | `sc42.sheet.actions` | box | 19.5 | 262.2 | 331 | 54 | `margin-top: 14px; display: flex; gap: 10px` |  |
| 28 | `sc42.sheet.actions.primary` | box | 19.5 | 262.2 | 267 | 54 | `flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; border: none; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700` |  |
| 29 | `sc42.sheet.actions.primary.icon` ±1 | icon | 89.33 | 278.7 | 21 | 21 | `—` |  |
| 30 | `sc42.sheet.actions.primary.label` ±1 | text | 120.33 | 279.6 | 96.34 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 700 ls normal #F7F0E3 |
| 31 | `sc42.sheet.actions.scanAgain` | box | 296.5 | 262.2 | 54 | 54 | `width: 54px; height: 54px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 32 | `sc42.sheet.actions.scanAgain.icon` | icon | 312.5 | 278.2 | 22 | 22 | `—` |  |
| 33 | `sc42.sheet.footer` | text | 19.5 | 330.2 | 331 | 16.21 | `margin: 14px 0 0; text-align: center; font-size: 13.5px; font-weight: 500; color: #5B544B` | Figtree 13.5/normal peso 500 ls normal #5B544B |
| 34 | `sc42.sheet.footer.link` ±1 | inline | 159.45 | 330.2 | 148.72 | 16.21 | `font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px` | Figtree 13.5/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc42.sheet.chip` | 1 | Já está na sua estante | 45.7 | 46.7 | 169.6 | 122.9 |
| `sc42.sheet.isbn` | 1 | ISBN 978-65-5921-104-3 | 45.7 | 202.42 | 350.5 | 148.08 |
| `sc42.sheet.book.cover.title` | 1 | Memórias | 91.18 | 33 | 75.12 | 42.12 |
| `sc42.sheet.book.cover.title` | 2 | Póstumas | 103.05 | 33 | 74 | 41 |
| `sc42.sheet.book.cover.title` | 3 | de Brás | 114.93 | 33 | 63.84 | 30.84 |
| `sc42.sheet.book.cover.title` | 4 | Cubas | 126.8 | 33 | 58.9 | 25.9 |
| `sc42.sheet.book.cover.author` | 1 | MACHADO DE | 158.01 | 43 | 87.81 | 44.81 |
| `sc42.sheet.book.cover.author` | 2 | ASSIS | 164.62 | 43 | 62.38 | 19.38 |
| `sc42.sheet.book.title` | 1 | Memórias Póstumas de | 88.23 | 105.5 | 306.04 | 200.54 |
| `sc42.sheet.book.title` | 2 | Brás Cubas | 108.03 | 105.5 | 201.91 | 96.41 |
| `sc42.sheet.book.author` | 1 | Machado de Assis · físico | 127.34 | 105.5 | 253.27 | 147.77 |
| `sc42.sheet.book.progress.percent` | 1 | 36% | 151.47 | 290.29 | 316.5 | 26.21 |
| `sc42.sheet.book.reading` *(composto)* | 1 | Lendo · pág. 74 de 208 | 169.48 | 105.5 | 236.3 | 130.8 |
| `sc42.sheet.goal.text` *(composto)* | 1 | 18 de 30 min hoje. Faltam 12 para a meta do | 215.12 | 76.8 | 335.55 | 258.75 |
| `sc42.sheet.goal.text` *(composto)* | 2 | dia; a sequência de 12 dias já está garantida. | 232.67 | 76.8 | 336.22 | 259.42 |
| `sc42.sheet.actions.primary.label` | 1 | Iniciar leitura | 294.8 | 120.33 | 216.67 | 96.34 |
| `sc42.sheet.footer` *(composto)* | 1 | É outra edição? Adicionar mesmo assim | 343.03 | 61.83 | 308.17 | 246.34 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A folha (a mesma nas 03, 39, 40, 41 e 42): `left/right/bottom 10`, padding 10/18/22, raio 30/30/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4; a alça 40 × 5 `#D9CFBD` (raio 3) centrada no topo. É um `Align` no fundo da tela (não um `showModalBottomSheet`), para a câmera continuar visível atrás (nota do design).
2. Topo (flex-wrap): o chip de 26 `{{brand}}` com borda 1,2, as lombadas 13 e "Já está na sua estante" 12/800; o ISBN à direita.
3. Livro, 14 abaixo: capa 72 × 108 (a mesma da 03, menor: título 12,5), título Bricolage 18/800, "Machado de Assis · físico" 13/600; a barra 9 de altura (`flex 1`, borda 1,3, hachura `#E4DACA`/`#FFFAF1`, coral até 36 % com a borda direita 1,3) + "36%" 12,5/800 `tnum`; "Lendo · **pág. 74** de 208" 12,5/600.
4. Meta, 14 abaixo: padding 10/12, raio 16, `#F7F0E3`, borda 1,3 `dashed #CFC3AE`, o anel 34 (r 12, traço 6, 60 %) e "**18 de 30 min hoje.** Faltam 12 para a meta do dia; a sequência de 12 dias já está garantida." 13/600 `lh 1,35`.
5. Ações 16 abaixo (gap 10): o botão preto de 54 (`flex 1`, ícone 20 `#F7F0E3` + 16/700) e o círculo 54 de escanear de novo (a seta circular 22); por último, 14 abaixo, a linha centrada 13,5/500 `#5B544B` com o link 800 sublinhado (offset 3). O botão preto é "Iniciar leitura" com o cronômetro 21 amarelo.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O ícone de "Iniciar leitura" tem 21 (o de "Adicionar" tem 20) e desce 0,5 a mais (T13.5): não reaproveitar o botão da 03 com outro ícone sem conferir.
- O anel é `stroke-dasharray` do progresso: `CustomPainter` com o valor real (o mapa de widgets).
- Fio de navalha em `sc42.sheet.goal.text` linha 2 «dia; a sequência de 12 dias já está garantida.»: sobra 0.98 px · sem palavra seguinte (D-275: a linha única quebra se crescer).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_042_scanner_na_estante_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_042_scanner_na_estante_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 03 (seções reutilizadas: camera, dim, detected, corners, status, controls)

Estas seções são as mesmas widgets da 03 (fases L03_1_camera, L03_2_controles, L03_3_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Só na base: `camera.book.ring`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc42.sheet` | dialog | Já está na sua estante |  |
| `sc42.sheet.handle` |  |  | aria-hidden=true |
| `sc42.sheet.chip.icon` |  |  | aria-hidden=true |
| `sc42.sheet.book` |  | Ver detalhes de Memórias Póstumas de Brás Cubas |  |
| `sc42.sheet.book.progress.bar` | progressbar | Progresso | aria-valuenow=36, aria-valuemin=0, aria-valuemax=100 |
| `sc42.sheet.book.chevron` |  |  | aria-hidden=true |
| `sc42.sheet.goal.ring` |  |  | aria-hidden=true |
| `sc42.sheet.actions.primary.icon` |  |  | aria-hidden=true |
| `sc42.sheet.actions.scanAgain` |  | Escanear outro livro |  |
| `sc42.sheet.actions.scanAgain.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc42.sheet` | NeoBox |  |
| `sc42.sheet.handle` | NeoBox |  |
| `sc42.sheet.chip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc42.sheet.chip.icon` | AppSvg(AppIconsScanner.shelf, size: 13) |  |
| `sc42.sheet.book.cover` | NeoBox |  |
| `sc42.sheet.book.cover.spine` | NeoBox |  |
| `sc42.sheet.book.cover.ellipse` | CircleIconButton / NeoBox circular |  |
| `sc42.sheet.book.progress.bar` | HatchPainter (hachura 135°) dentro do contorno |  |
| `sc42.sheet.book.progress.bar.fill` | NeoBox |  |
| `sc42.sheet.book.reading.page` | TextSpan dentro do AppText.rich do pai |  |
| `sc42.sheet.book.chevron` | AppSvg(AppIconsScanner.chevronRightFino, size: 20) |  |
| `sc42.sheet.goal` | NeoBox |  |
| `sc42.sheet.goal.ring` | CustomPainter (anel_meta_livro) | stroke-dasharray = progresso (dasharray 45,2 de 75,4 = 2π·12 → 60 %, rotate(-90)): anel desenhado por CustomPainter com o valor real; o SVG é a referência do estado da prancha. |
| `sc42.sheet.goal.text.strong` | TextSpan dentro do AppText.rich do pai |  |
| `sc42.sheet.actions.primary` | NeoBox |  |
| `sc42.sheet.actions.primary.icon` | AppSvg(AppIconsBiblioteca.stopwatchAmarelo, size: 21) |  |
| `sc42.sheet.actions.scanAgain` | CircleIconButton / NeoBox circular |  |
| `sc42.sheet.actions.scanAgain.icon` | AppSvg(AppIconsScanner.refresh, size: 22) |  |
| `sc42.sheet.footer.link` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Livro → os Detalhes (17).
- Iniciar leitura → o cronômetro neste livro (o de hoje, da T04; a tela 18 chega na T18).
- Escanear outro → a mira (39).
- Adicionar mesmo assim → uma segunda edição do livro; a confirmação não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T15 (ROTEIRO §2b).
- Variações da nota do design (sem prancha, mesmo layout): livro Lido → o botão "Ler de novo"; em Quero ler → "Começar a ler", que muda o status para Lendo.

## Dados

- O livro da estante (D-77: o ISBN já está numa linha ativa — `ScanOnShelf`, nada vai para a rede), a página e o total (36 %), os minutos de hoje, a meta e a sequência.
- "a sequência de 12 dias já está garantida": o dia conta com 5 min (a regra das estatísticas); o texto muda quando ainda não está garantida — o outro texto é pergunta da T15.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L42.1** Folha "já está na estante"
- **L42.2** Livro com o progresso
- **L42.3** Meta do dia
- **L42.4** Iniciar leitura e as variações (Lido, Quero ler)
- **L42.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc42.sheet'), todos os ids de `kRef42.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/042_scanner_na_estante_390x844@3x.png` no recorte da fase (y 456.09–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef42w360` e `kRef42w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L42.1 Folha "já está na estante"
- [ ] L42.2 Livro com o progresso
- [ ] L42.3 Meta do dia
- [ ] L42.4 Iniciar leitura e as variações (Lido, Quero ler)
- [ ] L42.5 Verificação + relatório
- [ ] Geometria 31/31 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
