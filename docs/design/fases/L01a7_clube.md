# FASE L01a7 — Início — ingresso do Clube do livro

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a7_clube@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a7_clube_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/book_club_ticket.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

O ingresso do clube "Leitoras de Capitu" — igual ao da v1 (F09), com o subtítulo "Dom Casmurro · até o cap. 50" (D-241: os números do clube).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

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
        <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Dom Casmurro · até o cap. 50</span>
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

Seção `i01.club` — retângulo absoluto no canvas 390×2650: **x=20, y=1831.52, w=350, h=266.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.club` | box | 0 | 0 | 350 | 266.6 | `position: relative; margin-top: 40px; border-radius: 28px; overflow: hidden` |  |
| 2 | `i01.club.ticket` | box | 0 | 0 | 350 | 266.6 | `display: flex; background: #FFFAF1; border: 1.5px solid #1A1714; border-radius: 28px; box-sizing: border-box; overflow: hidden` |  |
| 3 | `i01.club.body` | box | 1.5 | 1.5 | 255 | 263.6 | `flex-grow: 1; min-width: 0; padding: 18px 16px 18px 18px; box-sizing: border-box; display: flex; flex-direction: column; gap: 14px` |  |
| 4 | `i01.club.topRow` | box | 19.5 | 19.5 | 221 | 27.4 | `display: flex; align-items: center; justify-content: space-between; gap: 8px` |  |
| 5 | `i01.club.pill` ±1 | box+text | 19.5 | 19.5 | 99.38 | 27.4 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 6 | `i01.club.avatars` | box | 160.5 | 20.2 | 80 | 26 | `display: flex; align-items: center` |  |
| 7 | `i01.club.avatar0` | box+text | 160.5 | 20.2 | 26 | 26 | `width: 26px; height: 26px; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 8 | `i01.club.avatar1` | box+text | 178.5 | 20.2 | 26 | 26 | `width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 9 | `i01.club.avatar2` | box+text | 196.5 | 20.2 | 26 | 26 | `width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 10 | `i01.club.avatar3` | box+text | 214.5 | 20.2 | 26 | 26 | `width: 26px; height: 26px; margin-left: -8px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800` | Figtree 10/normal peso 800→**800** ls normal #1A1714 |
| 11 | `i01.club.titleBlock` | box | 19.5 | 60.9 | 221 | 77.8 | `display: flex; flex-direction: column; gap: 6px` |  |
| 12 | `i01.club.title` | text | 19.5 | 60.9 | 221 | 56.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/22px peso 800 ls -0.5px #1A1714 |
| 13 | `i01.club.title.serif` ±1 | inline | 19.5 | 76.6 | 86.41 | 46.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 36px; line-height: 0.95; letter-spacing: -0.4px` | Instrument Serif itálico 36/34.2px peso 400 ls -0.4px #1A1714 |
| 14 | `i01.club.subtitle` | text | 19.5 | 123.1 | 221 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 15 | `i01.club.progressBlock` | box | 19.5 | 152.7 | 221 | 34.4 | `display: flex; flex-direction: column; gap: 8px` |  |
| 16 | `i01.club.progressTrack` | box | 19.5 | 152.7 | 221 | 12 | `position: relative; height: 12px` |  |
| 17 | `i01.club.progressBar` | box | 19.5 | 152.7 | 221 | 12 | `height: 12px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); overflow: hidden` |  |
| 18 | `i01.club.progressFill` | box | 21 | 154.2 | 117.72 | 9 | `width: 54%; height: 100%; background: #FFC1C6; border-right: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 19 | `i01.club.youMarker` | box+text | 144.52 | 146.7 | 24 | 24 | `position: absolute; left: 62%; top: 50%; width: 24px; height: 24px; margin: -12px 0 0 -12px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-size: 11px; font-weight: 800` | Bricolage (opsz 12) 11/normal peso 800 ls normal #1A1714 |
| 20 | `i01.club.progressLabels` | box | 19.5 | 172.7 | 221 | 14.4 | `display: flex; justify-content: space-between; font-size: 12px; font-weight: 600; color: #5B544B` |  |
| 21 | `i01.club.groupLabel` ±1 | text | 19.5 | 172.7 | 81.12 | 14.4 | `—` | Figtree 12/normal peso 600 ls normal #5B544B |
| 22 | `i01.club.youLabel` ±1 | text | 165.62 | 172.7 | 74.88 | 14.4 | `color: #1A1714; font-weight: 800` | Figtree 12/normal peso 800→**800** ls normal #1A1714 |
| 23 | `i01.club.cta` | box | 19.5 | 201.1 | 221 | 46 | `height: 46px; border-radius: 999px; background: #1A1714; color: #F7F0E3; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 14px; font-weight: 700` |  |
| 24 | `i01.club.cta.icon` ±1 | icon | 53.69 | 215.1 | 18 | 18 | `—` |  |
| 25 | `i01.club.cta.label` ±1 | text | 79.69 | 215.7 | 98.63 | 16.8 | `color: #F7F0E3` | Figtree 14/normal peso 700 ls normal #F7F0E3 |
| 26 | `i01.club.cta.badge` ±1 | box+text | 186.31 | 214.1 | 20 | 20 | `min-width: 20px; height: 20px; padding: 0 6px; box-sizing: border-box; border-radius: 999px; background: #FF552E; color: #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 27 | `i01.club.stub` | box | 256.5 | 1.5 | 92 | 263.6 | `width: 92px; flex-shrink: 0; box-sizing: border-box; background: #FFC1C6; border-left: 1.5px dashed #1A1714; padding: 18px 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; text-align: center` |  |
| 28 | `i01.club.stub.label` ±1 | text | 270.94 | 67.65 | 64.63 | 12 | `font-size: 10px; font-weight: 800; letter-spacing: 0.1em; color: #4A2F33` | Figtree 10/normal peso 800→**800** ls 1px #4A2F33 |
| 29 | `i01.club.stub.date` ±1 | box | 279.13 | 91.65 | 48.24 | 68.7 | `display: flex; flex-direction: column; align-items: center` |  |
| 30 | `i01.club.stub.weekday` ±1 | text | 291.12 | 91.65 | 24.26 | 14.4 | `font-size: 12px; font-weight: 800; letter-spacing: 0.08em` | Figtree 12/normal peso 800→**800** ls 0.96px #1A1714 |
| 31 | `i01.club.stub.day` ±1 | text | 279.13 | 106.05 | 48.24 | 39.9 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 42px; line-height: 0.95; letter-spacing: -1.5px` | Bricolage (opsz 42) 42/39.9px peso 800 ls -1.5px #1A1714 |
| 32 | `i01.club.stub.month` ±1 | text | 291.13 | 145.95 | 24.24 | 14.4 | `font-size: 12px; font-weight: 800; letter-spacing: 0.08em` | Figtree 12/normal peso 800→**800** ls 0.96px #1A1714 |
| 33 | `i01.club.stub.time` ±1 | box+text | 280.07 | 172.35 | 46.36 | 26.6 | `font-size: 13px; font-weight: 800; padding: 4px 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714` | Figtree 13/normal peso 800→**800** ls normal #1A1714 |
| 34 | `i01.club.notchTop` | box | 244.25 | -13 | 26 | 26 | `position: absolute; top: -13px; right: 79.75px; width: 26px; height: 26px; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 35 | `i01.club.notchBottom` | box | 244.25 | 253.6 | 26 | 26 | `position: absolute; bottom: -13px; right: 79.75px; width: 26px; height: 26px; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.club.pill` | 1 | Clube do livro | 37.4 | 31 | 107.38 | 76.38 |
| `i01.club.avatar0` | 1 | A | 37.05 | 169.57 | 177.43 | 7.86 |
| `i01.club.avatar1` | 1 | J | 37.05 | 188.46 | 194.54 | 6.08 |
| `i01.club.avatar2` | 1 | L | 37.05 | 206.55 | 212.45 | 5.9 |
| `i01.club.avatar3` | 1 | +8 | 36.7 | 221.28 | 233.72 | 12.44 |
| `i01.club.title` *(composto)* | 1 | Leitoras de | 79.16 | 19.5 | 132.48 | 112.98 |
| `i01.club.title` *(composto)* | 2 | Capitu | 112.24 | 19.5 | 105.91 | 86.41 |
| `i01.club.subtitle` | 1 | Dom Casmurro · até o cap. 50 | 135.45 | 19.5 | 193.23 | 173.73 |
| `i01.club.youMarker` | 1 | M | 162.33 | 151.25 | 161.79 | 10.54 |
| `i01.club.groupLabel` | 1 | Grupo em 54% | 184.1 | 19.5 | 100.62 | 81.12 |
| `i01.club.youLabel` | 1 | Você em 62% | 184.1 | 165.62 | 240.5 | 74.88 |
| `i01.club.cta.label` | 1 | Abrir discussão | 229 | 79.69 | 178.31 | 98.62 |
| `i01.club.cta.badge` | 1 | 3 | 227.95 | 193.25 | 199.37 | 6.12 |
| `i01.club.stub.label` | 1 | ENCONTRO | 77.15 | 270.94 | 335.56 | 64.62 |
| `i01.club.stub.weekday` | 1 | QUI | 103.05 | 291.12 | 315.38 | 24.26 |
| `i01.club.stub.day` | 1 | 24 | 139.86 | 279.13 | 327.37 | 48.24 |
| `i01.club.stub.month` | 1 | SET | 157.35 | 291.13 | 315.37 | 24.24 |
| `i01.club.stub.time` | 1 | 20h | 190.2 | 291.57 | 314.93 | 23.36 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Mesmo desenho, medidas e pintores da v1 (o ticket com recortes, a hachura do progresso `#EFE6D4`/`#FFFAF1`, o marcador "M" em 62 % e o grupo em 54 %, a ponta rosa com "QUI 24 SET 20h").
2. Diferenças em relação à v1: o subtítulo ("até o cap. 50") e a posição na página (a Início ficou mais alta).
3. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.club` |  | Seu clube do livro |  |
| `i01.club.avatars` |  | 11 participantes |  |
| `i01.club.progressBar` | progressbar | Progresso do grupo | aria-valuenow=54, aria-valuemin=0, aria-valuemax=100 |
| `i01.club.youMarker` |  | Você |  |
| `i01.club.cta.icon` |  |  | aria-hidden=true |
| `i01.club.cta.badge` |  | 3 mensagens novas |  |
| `i01.club.stub` |  | Próximo encontro: quinta, 24 de setembro, às 20h |  |
| `i01.club.notchTop` |  |  | aria-hidden=true |
| `i01.club.notchBottom` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.club.ticket` | NeoBox |  |
| `i01.club.pill` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.club.avatar0` | CircleIconButton / NeoBox circular |  |
| `i01.club.avatar1` | CircleIconButton / NeoBox circular |  |
| `i01.club.avatar2` | CircleIconButton / NeoBox circular |  |
| `i01.club.avatar3` | CircleIconButton / NeoBox circular |  |
| `i01.club.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `i01.club.progressBar` | HatchPainter (hachura 135°) dentro do contorno |  |
| `i01.club.progressFill` | NeoBox |  |
| `i01.club.youMarker` | CircleIconButton / NeoBox circular |  |
| `i01.club.cta` | NeoBox |  |
| `i01.club.cta.icon` | AppSvg(AppIcons.ic_message_circle, size: 18) |  |
| `i01.club.cta.badge` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.club.stub` | NeoBox |  |
| `i01.club.stub.time` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.club.notchTop` | CircleIconButton / NeoBox circular |  |
| `i01.club.notchBottom` | CircleIconButton / NeoBox circular |  |

## Interações

- Como hoje (G21): o cartão e "Abrir discussão" abrem o clube.

## Dados

- D-241: capítulo do clube 50 (o mesmo do mundo do leitor e do clube); demais números como hoje.

## Subfases

- **L01a7.1** Ticket com o subtítulo novo
- **L01a7.2** Verificação + relatório (diferenças só de posição)

## Testes da fase

- Geometria: para cada seção ('i01.club'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 1810.52–2119.12) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a7.1 Ticket com o subtítulo novo
- [ ] L01a7.2 Verificação + relatório (diferenças só de posição)
- [ ] Geometria 34/34 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
