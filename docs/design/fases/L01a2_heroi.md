# FASE L01a2 — Início — herói "Continuar lendo" (Dom Casmurro)

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a2_heroi@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a2_heroi_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/continue_reading_hero.dart`, `lib/features/home/presentation/covers/dom_casmurro_cover.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Herói "Continuar lendo" do Dom Casmurro com a capa nova (o olho e o mar), as pílulas "pág. 159 de 256" e "E-BOOK" no lugar da pílula de capítulo da v1 e o contador de anotações "12".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

```html
<!-- Continue reading — hero -->
<section aria-label="Continuar lendo" style="position: relative; margin-top: 24px; background: {{brand}}; border: 1.5px solid #1A1714; border-radius: 28px; box-shadow: 4px 4px 0 #1A1714; padding: 20px; box-sizing: border-box; display: flex; flex-direction: column; gap: 20px; overflow: hidden;">
  <svg width="30" height="30" sc-camel-view-box="0 0 24 24" aria-hidden="true" style="position: absolute; top: 18px; right: 18px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path></svg>
  <svg width="14" height="14" sc-camel-view-box="0 0 24 24" aria-hidden="true" style="position: absolute; top: 54px; right: 50px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>

  <div style="display: flex; gap: 20px; align-items: stretch;">
    <!-- Cover (illustrated: highlights get drawn covers) -->
    <div style="position: relative; width: 104px; height: 156px; flex-shrink: 0; margin: 2px 0 0 2px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #552CB7; overflow: hidden; box-sizing: border-box; transform: rotate(-3deg); box-shadow: 3px 3px 0 #1A1714;">
      <svg width="100%" height="100%" sc-camel-view-box="0 0 96 144" sc-camel-preserve-aspect-ratio="xMidYMid slice" style="display: block;">
  <defs><clipPath id="home-dc-iris"><circle cx="48" cy="80" r="14.3"></circle></clipPath></defs>
  <rect width="96" height="144" fill="#552CB7"></rect>
  <!-- night sky -->
  <circle cx="80" cy="17" r="7.5" fill="#FED170"></circle>
  <circle cx="83.5" cy="14.5" r="6.4" fill="#552CB7"></circle>
  <path d="M89.5 44c.3 2.2.9 3 3 3.3-2.1.3-2.7 1.1-3 3.3-.3-2.2-.9-3-3-3.3 2.1-.3 2.7-1.1 3-3.3z" fill="#FFFAF1"></path>
  <path d="M68 6c.2 1.4.6 1.9 1.9 2.1-1.3.2-1.7.7-1.9 2.1-.2-1.4-.6-1.9-1.9-2.1 1.3-.2 1.7-.7 1.9-2.1z" fill="#FED170"></path>
  <!-- title -->
  <text x="12" y="24" font-family="'Instrument Serif', Georgia, serif" font-size="19" fill="#FED170">Dom</text>
  <text x="12" y="41" font-family="'Instrument Serif', Georgia, serif" font-size="19" fill="#FED170">Casmurro</text>
  <text x="12.5" y="51" font-family="Figtree, sans-serif" font-size="5.2" font-weight="700" letter-spacing="0.9" fill="#F7F0E3">MACHADO DE ASSIS</text>
  <!-- the eye -->
  <path d="M14 80Q48 52 82 80Q48 108 14 80Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path>
  <circle cx="48" cy="80" r="14.3" fill="#058CD7"></circle>
  <g clip-path="url(#home-dc-iris)" fill="none" stroke="#FFFAF1" stroke-width="1.3" stroke-linecap="round">
    <path d="M31 73q3-2.6 6 0t6 0 6 0 6 0 6 0 6 0"></path>
    <path d="M31 79.5q3-2.6 6 0t6 0 6 0 6 0 6 0 6 0"></path>
    <path d="M31 86q3-2.6 6 0t6 0 6 0 6 0 6 0 6 0"></path>
  </g>
  <circle cx="48" cy="80" r="14.3" fill="none" stroke="#1A1714" stroke-width="1.3"></circle>
  <circle cx="48" cy="80" r="5.2" fill="#1A1714"></circle>
  <circle cx="50.6" cy="77.4" r="1.7" fill="#FFFAF1"></circle>
  <g stroke="#1A1714" stroke-width="1.4" stroke-linecap="round">
    <path d="M27.6 71 24 65"></path>
    <path d="M37.8 67.3 36.2 60.5"></path>
    <path d="M48 66V59"></path>
    <path d="M58.2 67.3 59.8 60.5"></path>
    <path d="M68.4 71 72 65"></path>
  </g>
  <!-- the sea below -->
  <path d="M0 112Q12 105.5 24 112T48 112T72 112T96 112V144H0Z" fill="#B6ACE4"></path>
  <path d="M0 123.5Q12 117 24 123.5T48 123.5T72 123.5T96 123.5V144H0Z" fill="#058CD7"></path>
  <path d="M0 134.5Q12 128 24 134.5T48 134.5T72 134.5T96 134.5V144H0Z" fill="#FFC1C6"></path>
  <g fill="none" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round">
    <path d="M0 112Q12 105.5 24 112T48 112T72 112T96 112"></path>
    <path d="M0 123.5Q12 117 24 123.5T48 123.5T72 123.5T96 123.5"></path>
    <path d="M0 134.5Q12 128 24 134.5T48 134.5T72 134.5T96 134.5"></path>
  </g>
  <g stroke="#FFFAF1" stroke-width="1.2" stroke-linecap="round">
    <path d="M40 101h7"></path>
    <path d="M51 104h4"></path>
    <path d="M34 105h3"></path>
  </g>
</svg>
      <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.22);"></div>
    </div>

    <!-- Meta -->
    <div style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; justify-content: space-between; padding-top: 2px;">
      <div style="display: flex; flex-direction: column; gap: 10px;">
        <span style="display: flex; flex-wrap: wrap; gap: 6px;">
          <span style="font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714;">pág. 159 de 256</span>
          <span style="font-size: 11px; font-weight: 900; letter-spacing: 0.8px; padding: 5px 8px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714;">E-BOOK</span>
        </span>
        <div style="display: flex; flex-direction: column; gap: 3px;">
          <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; line-height: 1.05; letter-spacing: -0.6px;">Dom Casmurro</h2>
          <span style="font-size: 14px; font-weight: 500; color: #2F2A40;">Machado de Assis</span>
        </div>
      </div>
      <div style="display: flex; flex-direction: column; gap: 8px;">
        <div style="display: flex; align-items: baseline; justify-content: space-between;">
          <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 26px; letter-spacing: -0.6px;">62%</span>
          <span style="font-size: 12px; font-weight: 600; color: #2F2A40;">~2h 10min</span>
        </div>
        <div role="progressbar" aria-valuenow="62" aria-valuemin="0" aria-valuemax="100" aria-label="Progresso do livro" style="height: 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; overflow: hidden;">
          <div style="width: 62%; height: 100%; background: #1A1714; border-radius: 999px;"></div>
        </div>
      </div>
    </div>
  </div>

  <div style="display: flex; gap: 10px;">
    <a href="#" style="flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; color: #F7F0E3; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700;">
      <svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 4h6a4 4 0 0 1 4 4v13a3 3 0 0 0-3-3H2z"></path><path d="M22 4h-6a4 4 0 0 0-4 4v13a3 3 0 0 1 3-3h7z"></path></svg>
      <span style="color: #F7F0E3;">Continuar lendo</span>
    </a>
    <button aria-label="Destaques e notas deste livro (12)" style="position: relative; width: 54px; height: 54px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0;">
      <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m9 11-6 6v3h9l3-3"></path><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"></path></svg>
      <span style="position: absolute; top: -4px; right: -4px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center;">12</span>
    </button>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `i01.hero` — retângulo absoluto no canvas 390×2650: **x=20, y=248.16, w=350, h=282.8**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.hero` | box | 0 | 0 | 350 | 282.8 | `position: relative; margin-top: 24px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; border-radius: 28px; box-shadow: 4px 4px 0 #1A1714; padding: 20px; box-sizing: border-box; display: flex; flex-direction: column; gap: 20px; overflow: hidden` |  |
| 2 | `i01.hero.sparkleLarge` | icon | 300.5 | 19.5 | 30 | 30 | `position: absolute; top: 18px; right: 18px` |  |
| 3 | `i01.hero.sparkleSmall` | icon | 284.5 | 55.5 | 14 | 14 | `position: absolute; top: 54px; right: 50px` |  |
| 4 | `i01.hero.topRow` | box | 21.5 | 21.5 | 307 | 165.8 | `display: flex; gap: 20px; align-items: stretch` |  |
| 5 | `i01.hero.cover` | box | 23.5 | 23.5 | 104 | 156 | `position: relative; width: 104px; height: 156px; flex-shrink: 0; margin: 2px 0 0 2px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #552CB7; overflow: hidden; box-sizing: border-box; transform: rotate(-3deg); box-shadow: 3px 3px 0 #1A1714` |  |
| 6 | `i01.hero.cover.art` | icon | 25 | 25 | 101 | 153 | `display: block` |  |
| 7 | `i01.hero.cover.spine` | box | 25 | 25 | 7 | 153 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.22)` |  |
| 8 | `i01.hero.meta` | box | 147.5 | 21.5 | 181 | 165.8 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; justify-content: space-between; padding-top: 2px` |  |
| 9 | `i01.hero.meta.top` | box | 147.5 | 23.5 | 181 | 114.6 | `display: flex; flex-direction: column; gap: 10px` |  |
| 10 | `i01.hero.pills` | box | 147.5 | 23.5 | 181 | 59.6 | `display: flex; flex-wrap: wrap; gap: 6px` |  |
| 11 | `i01.hero.pagePill` ±1 | box+text | 147.5 | 23.5 | 108.97 | 27.4 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 12 | `i01.hero.formatPill` ±1 | box+text | 147.5 | 56.9 | 66.14 | 26.2 | `font-size: 11px; font-weight: 900; letter-spacing: 0.8px; padding: 5px 8px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714` | Figtree 11/normal peso 900→**800** ls 0.8px #1A1714 |
| 13 | `i01.hero.titleBlock` | box | 147.5 | 93.1 | 181 | 45 | `display: flex; flex-direction: column; gap: 3px` |  |
| 14 | `i01.hero.title` | text | 147.5 | 93.1 | 181 | 25.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; line-height: 1.05; letter-spacing: -0.6px` | Bricolage (opsz 24) 24/25.2px peso 800 ls -0.6px #1A1714 |
| 15 | `i01.hero.author` | text | 147.5 | 121.3 | 181 | 16.8 | `font-size: 14px; font-weight: 500; color: #2F2A40` | Figtree 14/normal peso 500 ls normal #2F2A40 |
| 16 | `i01.hero.meta.bottom` | box | 147.5 | 138.1 | 181 | 49.2 | `display: flex; flex-direction: column; gap: 8px` |  |
| 17 | `i01.hero.progressRow` | box | 147.5 | 138.1 | 181 | 31.2 | `display: flex; align-items: baseline; justify-content: space-between` |  |
| 18 | `i01.hero.percent` ±1 | text | 147.5 | 138.1 | 56.46 | 31.2 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 26px; letter-spacing: -0.6px` | Bricolage (opsz 26) 26/normal peso 800 ls -0.6px #1A1714 |
| 19 | `i01.hero.timeLeft` ±1 | text | 271.54 | 150.88 | 56.96 | 14.4 | `font-size: 12px; font-weight: 600; color: #2F2A40` | Figtree 12/normal peso 600 ls normal #2F2A40 |
| 20 | `i01.hero.progressBar` | box | 147.5 | 177.3 | 181 | 10 | `height: 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; overflow: hidden` |  |
| 21 | `i01.hero.progressFill` | box | 149 | 178.8 | 110.36 | 7 | `width: 62%; height: 100%; background: #1A1714; border-radius: 999px` |  |
| 22 | `i01.hero.actions` | box | 21.5 | 207.3 | 307 | 54 | `display: flex; gap: 10px` |  |
| 23 | `i01.hero.cta` | box | 21.5 | 207.3 | 243 | 54 | `flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; color: #F7F0E3; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700` |  |
| 24 | `i01.hero.cta.icon` ±1 | icon | 69.06 | 224.3 | 20 | 20 | `—` |  |
| 25 | `i01.hero.cta.label` ±1 | text | 99.06 | 224.7 | 117.89 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 700 ls normal #F7F0E3 |
| 26 | `i01.hero.notesButton` | box | 274.5 | 207.3 | 54 | 54 | `position: relative; width: 54px; height: 54px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 27 | `i01.hero.notesButton.icon` | icon | 290.5 | 223.3 | 22 | 22 | `—` |  |
| 28 | `i01.hero.notesButton.badge` ±1 | box+text | 306.99 | 204.8 | 24.01 | 22 | `position: absolute; top: -4px; right: -4px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `i01.hero.cover`: caixa visual com `transform: rotate(-3deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.hero.cover.art`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.hero.cover.spine`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.hero.pagePill` | 1 | pág. 159 de 256 | 41.4 | 159 | 244.97 | 85.97 |
| `i01.hero.formatPill` | 1 | E-BOOK | 73.85 | 157 | 204.14 | 47.14 |
| `i01.hero.title` | 1 | Dom Casmurro | 113.62 | 147.5 | 316.53 | 169.03 |
| `i01.hero.author` | 1 | Machado de Assis | 134.6 | 147.5 | 260.91 | 113.41 |
| `i01.hero.percent` | 1 | 62% | 162.28 | 147.5 | 203.96 | 56.46 |
| `i01.hero.timeLeft` | 1 | ~2h 10min | 162.28 | 271.54 | 328.5 | 56.96 |
| `i01.hero.cta.label` | 1 | Continuar lendo | 239.9 | 99.06 | 216.94 | 117.88 |
| `i01.hero.notesButton.badge` | 1 | 12 | 219.65 | 313.49 | 324.5 | 11.01 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cartão: fundo `{{brand}}` (padrão `#B6ACE4`), borda 1,5, raio 28, sombra dura 4/4, padding 20 → 350 × 282,8 (a v1 tinha 275: +7,8 pelas duas pílulas, que quebram em 2 linhas).
2. Capa 104 × 156 **girada −3°** (`Transform.rotate` no centro; a tabela traz o retângulo de layout, a caixa visual vem abaixo dela), raio 4/10/10/4, borda 1,5, sombra 3/3, `overflow: hidden`: desenho `il_capa_dom_casmurro.svg` (101 × 153, `slice`) e, por cima, a lombada de 7 px `rgba(0,0,0,.22)`.
3. Pílulas (`wrap`, gap 6): "pág. 159 de 256" Figtree 12/700, padding 5/10, `#FFFAF1`, borda 1,5, raio 999; "E-BOOK" Figtree 11/900 (→ 700), ls 0,8, padding 5/8, `#FED170`. A 2ª desce para a linha de baixo (181 de largura útil).
4. Título Bricolage 24/800 `lh 1,05` ls −0,6 + autor Figtree 14/500 `#2F2A40`; "62%" Bricolage 26/800 e "~2h 10min" Figtree 12/600 alinhados pela baseline (`space-between`); barra de 10 com o preenchimento `#1A1714` em 62 %.
5. Ações (gap 10): CTA preto de 54 (livro aberto 20 `#F7F0E3` + "Continuar lendo" Figtree 16/700) e o botão 54 dos destaques (marca-texto 22) com o contador amarelo "12" (Figtree 11/800 → 700, `top/right −4`, mín. 22).
6. Brilhos da v1: `ic_sparkle_outline` 30 (`top 18 · right 18`) e `ic_sparkle_solid` 14 (`top 54 · right 50`).
7. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- A capa tem `<text>` (Instrument Serif e Figtree) e `preserveAspectRatio="xMidYMid slice"`: o flutter_svg usa a fonte do sistema e não faz "slice" → desenho sem os textos (BoxFit.cover) + textos em `AppText` nas posições do viewBox × 1,0625 (catálogo de SVGs).
- As larguras de texto dependem das estáticas refeitas com os avanços do HVAR (D-249): com elas "Continuar lendo" bate com o Chromium a 0,008 px; com as da v1 antigas sairia 0,053 px mais largo. Um golden ou medida com outra fonte não vale.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.hero` |  | Continuar lendo |  |
| `i01.hero.sparkleLarge` |  |  | aria-hidden=true |
| `i01.hero.sparkleSmall` |  |  | aria-hidden=true |
| `i01.hero.progressBar` | progressbar | Progresso do livro | aria-valuenow=62, aria-valuemin=0, aria-valuemax=100 |
| `i01.hero.notesButton` |  | Destaques e notas deste livro (12) |  |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.hero` | NeoBox |  |
| `i01.hero.sparkleLarge` | AppSvg(AppIcons.ic_sparkle_outline, size: 30) |  |
| `i01.hero.sparkleSmall` | AppSvg(AppIcons.ic_sparkle_solid, size: 14) |  |
| `i01.hero.cover` | NeoBox | Transform: rotate(-3deg) |
| `i01.hero.cover.art` | AppSvg(AppIllustrationsInicio.il_capa_dom_casmurro, size: 101×153) | tem <text> (Instrument Serif 19 no título; Figtree 700 5,2 no autor, em unidades do viewBox 96×144) e preserveAspectRatio="xMidYMid slice" (escala max(101/96, 153/144) = 1,0625): o flutter_svg desenha <text> com a fonte do sistema e não faz "slice" → no app, o desenho sem os textos (BoxFit.cover) e os textos com AppText por cima, nas mesmas posições × escala; a capa fica dentro de uma caixa girada (rotate(-3deg)) — o tamanho do catálogo é o do layout, sem o giro. |
| `i01.hero.cover.spine` | NeoBox |  |
| `i01.hero.pagePill` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.hero.formatPill` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.hero.progressBar` | NeoBox |  |
| `i01.hero.progressFill` | NeoBox |  |
| `i01.hero.cta` | NeoBox |  |
| `i01.hero.cta.icon` | AppSvg(AppIcons.ic_book_open, size: 20) |  |
| `i01.hero.notesButton` | CircleIconButton / NeoBox circular |  |
| `i01.hero.notesButton.icon` | AppSvg(AppIcons.ic_highlighter, size: 22) |  |
| `i01.hero.notesButton.badge` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |

## Interações

- CTA → abre o leitor na posição salva (como hoje).
- Botão dos destaques → os grifos do livro (tela 25), como hoje.

## Dados

- "pág. 159 de 256" = página de referência atual e total (G10); "E-BOOK" = formato do livro (a regra para PDF e papel fica no plano da T03); "12" = anotações do livro (D-241: o mundo do leitor); "62%" e "~2h 10min" como hoje.
- A capa desenhada só na fixture; capas reais seguem a D-79.

## Subfases

- **L01a2.1** Cartão e grade do herói
- **L01a2.2** Capa nova (SVG sem textos + AppText, giro −3°)
- **L01a2.3** Pílulas página e formato
- **L01a2.4** Título, progresso e tempo
- **L01a2.5** Ações e contador
- **L01a2.6** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01.hero'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 240.16–538.96) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a2.1 Cartão e grade do herói
- [ ] L01a2.2 Capa nova (SVG sem textos + AppText, giro −3°)
- [ ] L01a2.3 Pílulas página e formato
- [ ] L01a2.4 Título, progresso e tempo
- [ ] L01a2.5 Ações e contador
- [ ] L01a2.6 Verificação + relatório
- [ ] Geometria 28/28 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
