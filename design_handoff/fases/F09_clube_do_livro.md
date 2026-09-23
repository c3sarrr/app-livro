# FASE 9 — Seção 7: Ticket do clube do livro ("Leitoras de Capitu")

> Pré-requisito: FASE 8 aprovada.
> Referências: `secoes/F09_clube@3x.png` · `redline/F09_clube_redline@3x.png`.
> Arquivo: `sections/book_club_ticket.dart`.

---

## HTML literal da seção

```html
    <!-- Book club — meeting ticket -->
    <section aria-label="Seu clube do livro" style="position: relative; margin-top: 40px; border-radius: 28px; overflow: hidden;">
      <div style="display: flex; background: #FFFAF1; border: 1.5px solid #1A1714; border-radius: 28px; box-sizing: border-box; overflow: hidden;">

        <!-- Ticket body -->
        <div style="flex-grow: 1; min-width: 0; padding: 18px 16px 18px 18px; box-sizing: border-box; display: flex; flex-direction: column; gap: 14px;">
          <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
            <span style="font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; white-space: nowrap;">Clube do livro</span>
            <div aria-label="11 participantes" style="display: flex; align-items: center;">
              <span style="width: 26px; height: 26px; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">A</span>
              <span style="width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">J</span>
              <span style="width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">L</span>
              <span style="width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800;">+8</span>
            </div>
          </div>

          <div style="display: flex; flex-direction: column; gap: 6px;">
            <h3 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1; letter-spacing: -0.5px;">Leitoras de<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 36px; line-height: 0.95; letter-spacing: -0.4px;">Capitu</span></h3>
            <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Dom Casmurro · até o cap. 100</span>
          </div>

          <div style="display: flex; flex-direction: column; gap: 8px;">
            <div style="position: relative; height: 12px;">
              <div role="progressbar" aria-valuenow="54" aria-valuemin="0" aria-valuemax="100" aria-label="Progresso do grupo" style="height: 12px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); overflow: hidden;">
                <div style="width: 54%; height: 100%; background: #FFC1C6; border-right: 1.5px solid #1A1714; box-sizing: border-box;"></div>
              </div>
              <span aria-label="Você" style="position: absolute; left: 62%; top: 50%; width: 24px; height: 24px; margin: -12px 0 0 -12px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-size: 11px; font-weight: 800;">M</span>
            </div>
            <div style="display: flex; justify-content: space-between; font-size: 12px; font-weight: 600; color: #5B544B;">
              <span>Grupo em 54%</span>
              <span style="color: #1A1714; font-weight: 800;">Você em 62%</span>
            </div>
          </div>

          <a href="#" style="height: 46px; border-radius: 999px; background: #1A1714; color: #F7F0E3; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 14px; font-weight: 700;">
            <svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12z"></path></svg>
            <span style="color: #F7F0E3;">Abrir discussão</span>
            <span aria-label="3 mensagens novas" style="min-width: 20px; height: 20px; padding: 0 6px; box-sizing: border-box; border-radius: 999px; background: #FF552E; color: #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center;">3</span>
          </a>
        </div>

        <!-- Ticket stub: next meeting -->
        <div aria-label="Próximo encontro: quinta, 24 de setembro, às 20h" style="width: 92px; flex-shrink: 0; box-sizing: border-box; background: #FFC1C6; border-left: 1.5px dashed #1A1714; padding: 18px 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; text-align: center;">
          <span style="font-size: 10px; font-weight: 800; letter-spacing: 0.1em; color: #4A2F33;">ENCONTRO</span>
          <div style="display: flex; flex-direction: column; align-items: center;">
            <span style="font-size: 12px; font-weight: 800; letter-spacing: 0.08em;">QUI</span>
            <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 42px; line-height: 0.95; letter-spacing: -1.5px;">24</span>
            <span style="font-size: 12px; font-weight: 800; letter-spacing: 0.08em;">SET</span>
          </div>
          <span style="font-size: 13px; font-weight: 800; padding: 4px 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714;">20h</span>
        </div>
      </div>

      <!-- Ticket notches on the perforation -->
      <span aria-hidden="true" style="position: absolute; top: -13px; right: 79.75px; width: 26px; height: 26px; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box;"></span>
      <span aria-hidden="true" style="position: absolute; bottom: -13px; right: 79.75px; width: 26px; height: 26px; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box;"></span>
    </section>
```

## Especificação pixel a pixel

Seção `club` — retângulo absoluto no canvas 390×2390: **x=20, y=1574.56, w=350, h=266.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `club` | box | 0 | 0 | 350 | 266.6 | `position: relative; margin-top: 40px; border-radius: 28px; overflow: hidden` |  |
| 2 | `club.ticket` | box | 0 | 0 | 350 | 266.6 | `display: flex; background: #FFFAF1; border: 1.5px solid #1A1714; border-radius: 28px; box-sizing: border-box; overflow: hidden` |  |
| 3 | `club.body` | box | 1.5 | 1.5 | 255 | 263.6 | `flex-grow: 1; min-width: 0px; padding: 18px 16px 18px 18px; box-sizing: border-box; display: flex; flex-direction: column; gap: 14px` |  |
| 4 | `club.topRow` | box | 19.5 | 19.5 | 221 | 27.4 | `display: flex; align-items: center; justify-content: space-between; gap: 8px` |  |
| 5 | `club.pill` | box+text | 19.5 | 19.5 | 99.38 | 27.4 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 6 | `club.avatars` | box | 160.5 | 20.2 | 80 | 26 | `display: flex; align-items: center` |  |
| 7 | `club.avatar0` | box+text | 160.5 | 20.2 | 26 | 26 | `width: 26px; height: 26px; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |
| 8 | `club.avatar1` | box+text | 178.5 | 20.2 | 26 | 26 | `width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |
| 9 | `club.avatar2` | box+text | 196.5 | 20.2 | 26 | 26 | `width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |
| 10 | `club.avatar3` | box+text | 214.5 | 20.2 | 26 | 26 | `width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800` | Figtree 10/normal peso 800→**700** ls normal #1A1714 |
| 11 | `club.titleBlock` | box | 19.5 | 60.9 | 221 | 77.8 | `display: flex; flex-direction: column; gap: 6px` |  |
| 12 | `club.title` | text | 19.5 | 60.9 | 221 | 56.2 | `margin: 0px; font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 22px; line-height: 1; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/22px peso 800 ls -0.5px #1A1714 |
| — | `club.title.serif` | inline | 19.5 | 76.6 | 86.41 | 46.8 | `font-family: "Instrument Serif", Georgia, serif; font-style: italic; font-weight: 400; font-size: 36px; line-height: 0.95; letter-spacing: -0.4px` | Instrument Serif itálico 36/34.2px peso 400 ls -0.4px #1A1714 |
| 13 | `club.subtitle` | text | 19.5 | 123.1 | 221 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 14 | `club.progressBlock` | box | 19.5 | 152.7 | 221 | 34.4 | `display: flex; flex-direction: column; gap: 8px` |  |
| 15 | `club.progressTrack` | box | 19.5 | 152.7 | 221 | 12 | `position: relative; height: 12px` |  |
| 16 | `club.progressBar` | box | 19.5 | 152.7 | 221 | 12 | `height: 12px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0px, #EFE6D4 3px, #FFFAF1 3px, #FFFAF1 7px); overflow: hidden` |  |
| 17 | `club.progressFill` | box | 21 | 154.2 | 117.72 | 9 | `width: 54%; height: 100%; background: #FFC1C6; border-right: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 18 | `club.youMarker` | box+text | 144.52 | 146.7 | 24 | 24 | `position: absolute; left: 62%; top: 50%; width: 24px; height: 24px; margin: -12px 0px 0px -12px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: "Bricolage Grotesque", sans-serif; font-size: 11px; font-weight: 800` | Bricolage (opsz 12) 11/normal peso 800 ls normal #1A1714 |
| 19 | `club.progressLabels` | box | 19.5 | 172.7 | 221 | 14.4 | `display: flex; justify-content: space-between; font-size: 12px; font-weight: 600; color: #5B544B` |  |
| 20 | `club.groupLabel` | text | 19.5 | 172.7 | 81.12 | 14.4 | `—` | Figtree 12/normal peso 600 ls normal #5B544B |
| 21 | `club.youLabel` | text | 165.62 | 172.7 | 74.88 | 14.4 | `color: #1A1714; font-weight: 800` | Figtree 12/normal peso 800→**700** ls normal #1A1714 |
| 22 | `club.cta` | box | 19.5 | 201.1 | 221 | 46 | `height: 46px; border-radius: 999px; background: #1A1714; color: #F7F0E3; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 14px; font-weight: 700` |  |
| 23 | `club.cta.icon` | icon | 53.69 | 215.1 | 18 | 18 | `—` |  |
| 24 | `club.cta.label` | text | 79.69 | 215.7 | 98.63 | 16.8 | `color: #F7F0E3` | Figtree 14/normal peso 700 ls normal #F7F0E3 |
| 25 | `club.cta.badge` | box+text | 186.31 | 214.1 | 20 | 20 | `min-width: 20px; height: 20px; padding: 0px 6px; box-sizing: border-box; border-radius: 999px; background: #FF552E; color: #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |
| 26 | `club.stub` | box | 256.5 | 1.5 | 92 | 263.6 | `width: 92px; flex-shrink: 0; box-sizing: border-box; background: #FFC1C6; border-left: 1.5px dashed #1A1714; padding: 18px 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; text-align: center` |  |
| 27 | `club.stub.label` | text | 270.94 | 67.65 | 64.63 | 12 | `font-size: 10px; font-weight: 800; letter-spacing: 0.1em; color: #4A2F33` | Figtree 10/normal peso 800→**700** ls 1px #4A2F33 |
| 28 | `club.stub.date` | box | 279.13 | 91.65 | 48.24 | 68.7 | `display: flex; flex-direction: column; align-items: center` |  |
| 29 | `club.stub.weekday` | text | 291.12 | 91.65 | 24.26 | 14.4 | `font-size: 12px; font-weight: 800; letter-spacing: 0.08em` | Figtree 12/normal peso 800→**700** ls 0.96px #1A1714 |
| 30 | `club.stub.day` | text | 279.13 | 106.05 | 48.24 | 39.9 | `font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 42px; line-height: 0.95; letter-spacing: -1.5px` | Bricolage (opsz 42) 42/39.9px peso 800 ls -1.5px #1A1714 |
| 31 | `club.stub.month` | text | 291.13 | 145.95 | 24.24 | 14.4 | `font-size: 12px; font-weight: 800; letter-spacing: 0.08em` | Figtree 12/normal peso 800→**700** ls 0.96px #1A1714 |
| 32 | `club.stub.time` | box+text | 280.07 | 172.35 | 46.36 | 26.6 | `font-size: 13px; font-weight: 800; padding: 4px 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714` | Figtree 13/normal peso 800→**700** ls normal #1A1714 |
| 33 | `club.notchTop` | box | 244.25 | -13 | 26 | 26 | `position: absolute; top: -13px; right: 79.75px; width: 26px; height: 26px; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 34 | `club.notchBottom` | box | 244.25 | 253.6 | 26 | 26 | `position: absolute; bottom: -13px; right: 79.75px; width: 26px; height: 26px; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `club.pill` | 1 | Clube do livro | 37.4 | 31 | 107.38 | 76.38 |
| `club.avatar0` | 1 | A | 37.05 | 169.57 | 177.43 | 7.86 |
| `club.avatar1` | 1 | J | 37.05 | 188.46 | 194.54 | 6.08 |
| `club.avatar2` | 1 | L | 37.05 | 206.55 | 212.45 | 5.9 |
| `club.avatar3` | 1 | +8 | 36.7 | 221.28 | 233.72 | 12.44 |
| `club.title` | 1 | Leitoras de | 79.16 | 19.5 | 132.48 | 112.98 |
| `club.title` | 2 | Capitu | 112.24 | 19.5 | 105.91 | 86.41 |
| `club.title.serif` | 1 | Capitu | 112.24 | 19.5 | 105.91 | 86.41 |
| `club.subtitle` | 1 | Dom Casmurro · até o cap. 100 | 135.45 | 19.5 | 199.51 | 180.01 |
| `club.youMarker` | 1 | M | 162.33 | 151.25 | 161.79 | 10.54 |
| `club.groupLabel` | 1 | Grupo em 54% | 184.1 | 19.5 | 100.62 | 81.12 |
| `club.youLabel` | 1 | Você em 62% | 184.1 | 165.62 | 240.5 | 74.88 |
| `club.cta.label` | 1 | Abrir discussão | 229 | 79.69 | 178.31 | 98.62 |
| `club.cta.badge` | 1 | 3 | 227.95 | 193.26 | 199.37 | 6.11 |
| `club.stub.label` | 1 | ENCONTRO | 77.15 | 270.94 | 335.56 | 64.62 |
| `club.stub.weekday` | 1 | QUI | 103.05 | 291.12 | 315.38 | 24.26 |
| `club.stub.day` | 1 | 24 | 139.86 | 279.13 | 327.37 | 48.24 |
| `club.stub.month` | 1 | SET | 157.35 | 291.13 | 315.37 | 24.24 |
| `club.stub.time` | 1 | 20h | 190.2 | 291.57 | 314.93 | 23.36 |

## Leitura de designer (detalhes críticos)

**Estrutura de ingresso (ticket)**
1. A `<section>` só recorta (raio 28, `overflow: hidden`, **sem** borda/fundo). Dentro: o ticket (fundo `#FFFAF1`, borda 1,5, raio 28, recorte) em linha: **corpo** (flexível, 255) + **canhoto** (92).
2. Canhoto: fundo `#FFC1C6`, **borda esquerda 1,5 tracejada** (a perfuração: traço 3, 59 traços em 263,6 px, vão 1,4931), padding **18 8**, coluna centralizada, gap 12.
3. **Entalhes**: dois círculos 26×26 (border-box) `#F7F0E3` com borda 1,5 tinta, filhos da `<section>` (por cima do ticket), em `right 79,75` e `top −13` / `bottom −13` → centro exatamente sobre a perfuração (x = 350 − 92,75) e sobre a borda superior/inferior. O recorte da `<section>` mostra só **meio círculo** — a "mordida" interrompe a borda do ticket.
4. Altura 266,6 vem do corpo: 1,5 + 18 + 27,4 + 14 + 77,8 + 14 + 34,4 + 14 + 46 + 18 + 1,5. O canhoto estica.

**Corpo (padding 18 16 18 18, gap 14)**
5. Linha superior (`space-between`, centralizada, gap 8): pílula "Clube do livro" (fundo `#FFC1C6`, borda 1,5, padding 5 10, 12/700, **nowrap**) → 99,38 × 27,4; avatares 26×26 (border-box, borda 1,5) sobrepostos com `margin-left −8`: **A** `#B6ACE4`, **J** `#ABCF82`, **L** `#FFC1C6` (11/800→700) e **+8** `#FFFAF1` (**10**/800→700). Os posteriores pintam por cima. Grupo 80 × 26, centrado (y+0,7).
6. Título (gap 6): "Leitoras de" Bricolage 22 **line-height 1** ls −0,5 ⏎ "Capitu" Instrument Serif **itálico 36** line-height **0,95** ls −0,4 — no HTML é **um parágrafo** (`<h3>` com `<br>`) de 56,2 de altura; a linha 2 mede exatamente a caixa do itálico (34,2), que cobre o *strut* da Bricolage acima e abaixo da baseline → em Flutter são **dois `AppText` numa coluna** (22 + 34,2 = 56,2; baselines 18,26 e 51,34 a partir do topo), pelo mesmo motivo da F04 (letter-spacing diferente em cada linha). Subtítulo "Dom Casmurro · até o cap. 100" 13/500 `#5B544B`.
7. Progresso (gap 8): trilho 12 px, raio 999, borda 1,5, **hachura** `#EFE6D4`/`#FFFAF1`, recorte; preenchimento do grupo **54%** da largura interna (218 → **117,72**), fundo `#FFC1C6`, **borda direita 1,5 tinta**, sem raio (é recortado pela curva do trilho). Marcador "Você": 24×24 `#FED170` borda 1,5, "M" Bricolage **11** (opsz 12), centrado em **62% da largura total** do trilho (221 → x = 137,02) e no meio da altura → sai 6 px acima e abaixo do trilho.
8. Legendas (`space-between`): "Grupo em 54%" 12/600 `#5B544B` · "Você em 62%" 12/800→700 tinta.
9. CTA 221 × **46**, raio 999, tinta, conteúdo centralizado gap 8: balão 18 (traço `#F7F0E3`) + "Abrir discussão" 14/700 `#F7F0E3` + badge "3" (mín. 20 × 20, padding 0 6, `#FF552E`, texto **tinta** 11/800→700).

**Canhoto (texto centralizado)**
10. "ENCONTRO" 10/800→700 ls **1,0** (0,1em) `#4A2F33` → gap 12 → data em coluna: "QUI" 12/800→700 ls **0,96**, "24" Bricolage 42 line-height **0,95** ls −1,5, "SET" → gap 12 → pílula "20h" (padding 4 10, borda 1,5, `#FFFAF1`, 13/800→700) → 46,36 × 26,6. Bloco de 131,3 centrado verticalmente.

## Construção obrigatória

```dart
ClipRRect(key: const ValueKey('club'), borderRadius: BorderRadius.circular(28), child: Stack(children: [
  NeoBox(key: const ValueKey('club.ticket'), color: AppColors.surface, border: const BorderSide(width: 1.5, color: AppColors.ink),
    radius: BorderRadius.circular(28), clip: true,
    child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(child: Padding(key: const ValueKey('club.body'), padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [/* topRow, titleBlock, progressBlock, cta */]))),
      SizedBox(key: const ValueKey('club.stub'), width: 92, child: _Stub(/* fundo blush + perfuração + conteúdo */)),
    ])),
  ),
  const Positioned(top: -13, right: 79.75, child: _Notch(key: ValueKey('club.notchTop'))),
  const Positioned(bottom: -13, right: 79.75, child: _Notch(key: ValueKey('club.notchBottom'))),
]))
```
- `_Stub`: `ColoredBox(blush)` + `Stack([Positioned(left: 0, top: 0, bottom: 0, width: 1.5, child: CustomPaint(painter: ChromiumDashPainter(axis: Axis.vertical))), Padding(padding: EdgeInsets.fromLTRB(1.5 + 8, 18, 8, 18), child: Center(child: Column(mainAxisSize: min, spacing: 12, …)))])`.
- Avatares: `SizedBox(width: 80, height: 26, child: Stack([for i in 0..3: Positioned(left: i * 18, child: avatar)]))` + `Semantics(container: true, label: '11 participantes', excludeSemantics: true)`.
- Título:
  ```dart
  Semantics(container: true, header: true, label: 'Leitoras de Capitu', excludeSemantics: true, // <h3>
    child: Column(key: const ValueKey('club.title'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppText('Leitoras de', style: AppTextStyles.clubTitle),   // 22 de altura
      AppText('Capitu', style: AppTextStyles.clubSerif),        // 34,2 de altura
    ]))
  ```
- Trilho + marcador (o ticket está sob `IntrinsicHeight`; um `LayoutBuilder` que tenha a altura intrínseca consultada lança "LayoutBuilder does not support returning intrinsic dimensions" → o `SizedBox` de altura fixa responde a consulta sem descer até ele):
  ```dart
  SizedBox(key: const ValueKey('club.progressTrack'), height: 12, child: LayoutBuilder(builder: (context, c) {
    final w = c.maxWidth; // 221
    return Stack(clipBehavior: Clip.none, children: [
      Positioned.fill(child: Semantics(container: true, label: 'Progresso do grupo', value: '54%', excludeSemantics: true,
        child: NeoBox(key: const ValueKey('club.progressBar'), border: const BorderSide(width: 1.5, color: AppColors.ink),
          radius: BorderRadius.circular(999), clip: true,
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: HatchPainter(stripe: AppColors.hatch))),
            Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(   // Align → o FSB mede só a fração
              alignment: Alignment.centerLeft, widthFactor: groupProgress, heightFactor: 1,
              child: const DecoratedBox(key: ValueKey('club.progressFill'),   // 0,54 × 218 = 117,72 × 9
                decoration: BoxDecoration(color: AppColors.blush,
                    border: Border(right: BorderSide(width: 1.5, color: AppColors.ink)))))),
          ])))),
      Positioned(left: w * userProgress - 12, top: -6,                     // 62% de 221 = 137,02 → 125,02
        child: Semantics(container: true, label: 'Você', excludeSemantics: true, child: /* marcador 24×24, Key club.youMarker */)),
    ]);
  }))
  ```
  O `Align` aqui é redundante (o `Stack` já afrouxa as restrições do filho não posicionado) e fica só para deixar explícito o alinhamento à esquerda; a Key está no `DecoratedBox`, que mede 117,72 × 9 em qualquer caso. Onde o `Align` é **obrigatório** é no `StadiumProgressBar` (F01), cuja Key fica no próprio `FractionallySizedBox` e cujo pai (`Container`) passa restrição *tight*.
- CTA = `Pressable(isLink: true)` → `/clube/:clubId/discussao` (F12); badge `Semantics(container: true, label: '3 mensagens novas', excludeSemantics: true)` (nó próprio dentro do link). Canhoto `Semantics(container: true, label: meetingAria, excludeSemantics: true)`. Seção `Semantics(container: true, explicitChildNodes: true, label: 'Seu clube do livro')`. Entalhes e perfuração: `ExcludeSemantics` (`aria-hidden`).

## Subfases

- **9.1** Estrutura do ticket: recorte da seção, ticket com borda, corpo 255 + canhoto 92 esticado.
- **9.2** Perfuração tracejada (59 traços) + entalhes (meio círculo por cima da borda).
- **9.3** Linha superior: pílula nowrap + 4 avatares sobrepostos (ordem de pintura).
- **9.4** Título misto (22/1 + itálico 36/0,95) e subtítulo com "·".
- **9.5** Progresso: trilho hachurado, preenchimento 54% com borda direita, marcador em 62% transbordando.
- **9.6** CTA com badge "3".
- **9.7** Canhoto: ENCONTRO / QUI 24 SET / 20h, espaçamentos e centralização.
- **9.8** Verificação completa + relatório.

## Testes da fase

- `expectGeometry(tester, idsOfSection('club'))` → 34/34.
- `expectTextLines` (título com 2 linhas "Leitoras de" / "Capitu", baselines 1653,72 e 1686,80 absolutas; canhoto; legendas).
- `chromiumDashStarts(length: 263.6, thickness: 1.5)` usado pela perfuração → 59 traços.
- Estilo: entalhes 26×26 `#F7F0E3` borda 1,5 em right 79,75; canhoto `#FFC1C6`; preenchimento com borda direita; marcador 24×24 em x_centro = 39,5 + 137,02 (absoluto 176,52).
- Visual: `--rect 16,1566,358,284` → `blur_mismatch_% ≤ 0,5`. Inspecione: meia-lua dos entalhes interrompendo a borda, perfuração alinhada ao centro dos entalhes, hachura do trilho, marcador sobre a divisa.
- Não-regressão F03–F08.

## Checklist de aceite da FASE 9

- [ ] 9.1 Seção recorta com raio 28 (sem borda); ticket `#FFFAF1` borda 1,5 raio 28; corpo 255 + canhoto 92; altura 266,6
- [ ] 9.2 Perfuração: borda esquerda tracejada 1,5 do canhoto (59 traços, vão 1,4931)
- [ ] 9.2 Entalhes 26×26 `#F7F0E3` borda 1,5 em right 79,75, top/bottom −13, recortados em meio círculo, por cima do ticket
- [ ] 9.3 Pílula "Clube do livro" nowrap 99,38×27,4; avatares A/J/L/+8 26×26 sobrepostos (−8) com cores e fontes corretas
- [ ] 9.4 "Leitoras de" 22/1 ls −0,5 + "Capitu" itálico 36/0,95 ls −0,4 em coluna de 2 `AppText` (56,2) com um único nó de cabeçalho "Leitoras de Capitu"; subtítulo com "·"
- [ ] 9.5 Trilho 12 hachurado; preenchimento 117,72 com borda direita 1,5; marcador 24 em 62% transbordando 6 px
- [ ] 9.5 Legendas "Grupo em 54%" (600 `#5B544B`) × "Você em 62%" (700 tinta)
- [ ] 9.6 CTA 221×46 com balão 18 + rótulo 14/700 + badge "3" (20×20 `#FF552E`, texto tinta)
- [ ] 9.7 Canhoto: ENCONTRO 10 ls 1 `#4A2F33`; QUI/SET 12 ls 0,96; "24" Bricolage42/0,95 ls −1,5; pílula 20h 46,36×26,6; gaps 12
- [ ] Geometria 34/34 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com lado-a-lado e heatmap inspecionados

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 9 concluída — aguardando sua aprovação para iniciar a FASE 10.`
