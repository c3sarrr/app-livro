# FASE 5 — Seção 3: Cartão "Continuar lendo" (hero)

> Pré-requisito: FASE 4 aprovada.
> Referências: `secoes/F05_hero@3x.png` · `redline/F05_hero_redline@3x.png` (Nº = tabela abaixo).
> Arquivos: `sections/continue_reading_hero.dart`, `covers/dom_casmurro_cover.dart`.

---

## HTML literal da seção

`{{brand}}` = `homeThemeProvider.brand` (padrão `#B6ACE4`).

```html
    <!-- Continue reading — hero -->
    <section aria-label="Continuar lendo" style="position: relative; margin-top: 24px; background: {{brand}}; border: 1.5px solid #1A1714; border-radius: 28px; box-shadow: 4px 4px 0 #1A1714; padding: 20px; box-sizing: border-box; display: flex; flex-direction: column; gap: 20px; overflow: hidden;">
      <svg width="30" height="30" sc-camel-view-box="0 0 24 24" aria-hidden="true" style="position: absolute; top: 18px; right: 18px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path></svg>
      <svg width="14" height="14" sc-camel-view-box="0 0 24 24" aria-hidden="true" style="position: absolute; top: 54px; right: 50px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>

      <div style="display: flex; gap: 20px; align-items: stretch;">
        <!-- Cover -->
        <div style="position: relative; width: 104px; height: 156px; flex-shrink: 0; margin: 2px 0 0 2px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #552CB7; overflow: hidden; box-sizing: border-box; transform: rotate(-3deg); box-shadow: 3px 3px 0 #1A1714;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.22);"></div>
          <div style="position: absolute; right: -20px; top: -20px; width: 70px; height: 70px; border-radius: 50%; background: #FED170;"></div>
          <div style="position: absolute; right: 18px; top: 38px; width: 18px; height: 18px; border-radius: 50%; border: 1.5px solid #FED170;"></div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
            <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 22px; line-height: 0.92; color: #FED170;">Dom<br>Casmurro</div>
            <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #F7F0E3;">MACHADO DE ASSIS</div>
          </div>
        </div>

        <!-- Meta -->
        <div style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; justify-content: space-between; padding-top: 2px;">
          <div style="display: flex; flex-direction: column; gap: 10px;">
            <span style="align-self: flex-start; font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714;">Cap. 92 de 148</span>
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
        <button aria-label="Destaques e notas deste livro (14)" style="position: relative; width: 54px; height: 54px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0;">
          <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m9 11-6 6v3h9l3-3"></path><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"></path></svg>
          <span style="position: absolute; top: -4px; right: -4px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center;">14</span>
        </button>
      </div>
    </section>
```

## Especificação pixel a pixel

Seção `hero` — retângulo absoluto no canvas 390×2390: **x=20, y=248.16, w=350, h=275**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `hero` | box | 0 | 0 | 350 | 275 | `position: relative; margin-top: 24px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; border-radius: 28px; box-shadow: #1A1714 4px 4px 0px; padding: 20px; box-sizing: border-box; display: flex; flex-direction: column; gap: 20px; overflow: hidden` |  |
| 2 | `hero.sparkleLarge` | icon | 300.5 | 19.5 | 30 | 30 | `position: absolute; top: 18px; right: 18px` |  |
| 3 | `hero.sparkleSmall` | icon | 284.5 | 55.5 | 14 | 14 | `position: absolute; top: 54px; right: 50px` |  |
| 4 | `hero.topRow` | box | 21.5 | 21.5 | 307 | 158 | `display: flex; gap: 20px; align-items: stretch` |  |
| 5 | `hero.cover` | box | 23.5 | 23.5 | 104 | 156 | `position: relative; width: 104px; height: 156px; flex-shrink: 0; margin: 2px 0px 0px 2px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #552CB7; overflow: hidden; box-sizing: border-box; transform: rotate(-3deg); box-shadow: #1A1714 3px 3px 0px` |  |
| 6 | `hero.cover.spine` | box | 25 | 25 | 7 | 153 | `position: absolute; left: 0px; top: 0px; bottom: 0px; width: 7px; background: rgba(0,0,0,0.22)` |  |
| 7 | `hero.cover.sun` | box | 76 | 5 | 70 | 70 | `position: absolute; right: -20px; top: -20px; width: 70px; height: 70px; border-radius: 50%; background: #FED170` |  |
| 8 | `hero.cover.ring` | box | 87 | 63 | 21 | 21 | `position: absolute; right: 18px; top: 38px; width: 18px; height: 18px; border-radius: 50%; border: 1.5px solid #FED170` |  |
| 9 | `hero.cover.textBlock` | box | 40 | 103.9 | 78 | 62.1 | `position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 10 | `hero.cover.title` | text | 40 | 103.9 | 78 | 40.48 | `font-family: "Instrument Serif", Georgia, serif; font-size: 22px; line-height: 0.92; color: #FED170` | Instrument Serif 22/20.24px peso 400 ls normal #FED170 |
| 11 | `hero.cover.author` | text | 40 | 150.38 | 78 | 15.62 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #F7F0E3` | Figtree 6.5/normal peso 700 ls 0.91px #F7F0E3 |
| 12 | `hero.meta` | box | 147.5 | 21.5 | 181 | 158 | `flex-grow: 1; min-width: 0px; display: flex; flex-direction: column; justify-content: space-between; padding-top: 2px` |  |
| 13 | `hero.meta.top` | box | 147.5 | 23.5 | 181 | 82.4 | `display: flex; flex-direction: column; gap: 10px` |  |
| 14 | `hero.chapterPill` | box+text | 147.5 | 23.5 | 104.55 | 27.4 | `align-self: flex-start; font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 15 | `hero.titleBlock` | box | 147.5 | 60.9 | 181 | 45 | `display: flex; flex-direction: column; gap: 3px` |  |
| 16 | `hero.title` | text | 147.5 | 60.9 | 181 | 25.2 | `margin: 0px; font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 24px; line-height: 1.05; letter-spacing: -0.6px` | Bricolage (opsz 24) 24/25.2px peso 800 ls -0.6px #1A1714 |
| 17 | `hero.author` | text | 147.5 | 89.1 | 181 | 16.8 | `font-size: 14px; font-weight: 500; color: #2F2A40` | Figtree 14/normal peso 500 ls normal #2F2A40 |
| 18 | `hero.meta.bottom` | box | 147.5 | 130.3 | 181 | 49.2 | `display: flex; flex-direction: column; gap: 8px` |  |
| 19 | `hero.progressRow` | box | 147.5 | 130.3 | 181 | 31.2 | `display: flex; align-items: baseline; justify-content: space-between` |  |
| 20 | `hero.percent` | text | 147.5 | 130.3 | 56.46 | 31.2 | `font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 26px; letter-spacing: -0.6px` | Bricolage (opsz 26) 26/normal peso 800 ls -0.6px #1A1714 |
| 21 | `hero.timeLeft` | text | 271.54 | 143.08 | 56.96 | 14.4 | `font-size: 12px; font-weight: 600; color: #2F2A40` | Figtree 12/normal peso 600 ls normal #2F2A40 |
| 22 | `hero.progressBar` | box | 147.5 | 169.5 | 181 | 10 | `height: 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; overflow: hidden` |  |
| 23 | `hero.progressFill` | box | 149 | 171 | 110.36 | 7 | `width: 62%; height: 100%; background: #1A1714; border-radius: 999px` |  |
| 24 | `hero.actions` | box | 21.5 | 199.5 | 307 | 54 | `display: flex; gap: 10px` |  |
| 25 | `hero.cta` | box | 21.5 | 199.5 | 243 | 54 | `flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; color: #F7F0E3; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700` |  |
| 26 | `hero.cta.icon` | icon | 69.06 | 216.5 | 20 | 20 | `—` |  |
| 27 | `hero.cta.label` | text | 99.06 | 216.9 | 117.89 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 700 ls normal #F7F0E3 |
| 28 | `hero.notesButton` | box | 274.5 | 199.5 | 54 | 54 | `position: relative; width: 54px; height: 54px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0px` |  |
| 29 | `hero.notesButton.icon` | icon | 290.5 | 215.5 | 22 | 22 | `—` |  |
| 30 | `hero.notesButton.badge` | box+text | 306.39 | 197 | 24.61 | 22 | `position: absolute; top: -4px; right: -4px; min-width: 22px; height: 22px; padding: 0px 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `hero.cover.title` | 1 | Dom | 121.5 | 40 | 76.12 | 36.12 |
| `hero.cover.title` | 2 | Casmurro | 141.74 | 40 | 114.56 | 74.56 |
| `hero.cover.author` | 1 | MACHADO DE | 156.56 | 40 | 92.96 | 52.96 |
| `hero.cover.author` | 2 | ASSIS | 164.37 | 40 | 62.91 | 22.91 |
| `hero.chapterPill` | 1 | Cap. 92 de 148 | 41.4 | 159 | 240.55 | 81.55 |
| `hero.title` | 1 | Dom Casmurro | 81.42 | 147.5 | 316.53 | 169.03 |
| `hero.author` | 1 | Machado de Assis | 102.4 | 147.5 | 260.91 | 113.41 |
| `hero.percent` | 1 | 62% | 154.48 | 147.5 | 203.96 | 56.46 |
| `hero.timeLeft` | 1 | ~2h 10min | 154.48 | 271.54 | 328.5 | 56.96 |
| `hero.cta.label` | 1 | Continuar lendo | 232.1 | 99.06 | 216.94 | 117.88 |
| `hero.notesButton.badge` | 1 | 14 | 211.85 | 312.89 | 324.5 | 11.61 |

## Leitura de designer (detalhes críticos)

**Cartão**
1. 350 × **275**, fundo `brand`, borda 1,5, raio 28, **sombra dura 4/4 sem blur**, `overflow: hidden` (recorte interno raio 26,5), padding 20, coluna com gap 20.
2. Os dois brilhos são `position: absolute` → medidos a partir da **padding box** (dentro da borda, fora do padding 20): grande 30×30 em `top 18 / right 18`; pequeno 14×14 em `top 54 / right 50`. Pintam **por cima** do conteúdo — o brilho pequeno encosta no "rr" de "Dom Casmurro" (é assim no arquivo; não mova).

**Linha superior (altura 158)**
3. `display:flex; gap 20; align-items: stretch`. A capa (104×156) tem `margin: 2px 0 0 2px` → ocupa 106×158. A coluna de metadados estica para 158 e usa `justify-content: space-between` + `padding-top: 2`.
4. Metadados (largura 181): pílula "Cap. 92 de 148" (alinhada à esquerda, 104,55 × 27,4) → gap 10 → bloco título (gap 3): "Dom Casmurro" Bricolage 24 **line-height 1,05 (25,2)** ls −0,6; "Machado de Assis" Figtree 14/500 **`#2F2A40`** (não é o cinza `#5B544B`).
5. Base: linha "62%" (Bricolage 26 ls −0,6) × "~2h 10min" (Figtree 12/600 `#2F2A40`) alinhados **pela baseline** (`space-between`); gap 8; barra 10 px (fundo `#FFFAF1`, borda 1,5, raio 999, recorte) com preenchimento tinta = 62% da largura interna (178 → **110,36**), raio 999.

**Capa "Dom Casmurro" (arte, 104×156)**
6. Fundo `#552CB7`, borda 1,5, raio **4 10 10 4**, sombra dura **3/3**, `overflow: hidden`, **rotação −3°** em torno do centro (sombra e borda giram junto; o layout não muda).
7. Filhos (todos absolutos, medidos dentro da borda, na ordem de pintura): lombada 7 px `rgba(0,0,0,.22)` (altura total); sol 70×70 `#FED170` em `right −20 / top −20` (recortado pelo canto); anel **21×21** (18 + borda 1,5 `#FED170`, content-box) em `right 18 / top 38`, sem preenchimento; bloco de texto em `left 15 / right 8 / bottom 12`, coluna gap 6: "Dom⏎Casmurro" Instrument Serif 22 **line-height 0,92** `#FED170`; "MACHADO DE⏎ASSIS" Figtree 6,5/700 ls 0,91 `#F7F0E3`.
8. ⚠ **Quebra do autor na capa**: a largura disponível é 78,00 e "MACHADO DE ASSIS" mede 78,33 (com o espaçamento final) → no arquivo quebra em "MACHADO DE / ASSIS" por **0,33 px**. Como é uma arte estática e o caso é de fio de navalha, **force** a quebra com `\n` (única exceção permitida por este motivo). O `<br>` de "Dom⏎Casmurro" já existe no HTML.

**Ações (altura 54)**
9. `gap 10`: CTA ocupa 243 (flex-grow), altura 54, raio 999, fundo tinta, conteúdo centralizado com gap 10: ícone livro 20 (traço `#F7F0E3`) + "Continuar lendo" Figtree 16/700 `#F7F0E3`.
10. Botão de destaques 54×54 `#FFFAF1` borda 1,5, ícone marca-texto 22; **badge "14"**: `position:absolute; top −4; right −4` (a partir de dentro da borda do botão), min-width 22, altura 22, padding 0 5, borda 1,5, fundo `#FED170`, texto 11/800→**700** → **24,61 × 22** (o "14" é mais largo que o mínimo). O badge sai do contorno do botão (sem recorte).

## Construção obrigatória

```dart
Semantics(                                                      // <section aria-label> (convenção §5.1 do mestre)
  container: true,
  explicitChildNodes: true,
  label: 'Continuar lendo',
  child: NeoBox(
    key: const ValueKey('hero'),
    color: theme.brand, border: const BorderSide(width: 1.5, color: AppColors.ink),
    radius: BorderRadius.circular(28), shadow: AppShadows.hard4, clip: true,
    child: Stack(children: [                                    // Stack = padding box (dentro da borda)
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 20, children: [
          IntrinsicHeight(child: Row(key: const ValueKey('hero.topRow'), crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 20, children: [
            Align(alignment: Alignment.topLeft,   // o stretch da Row NÃO pode esticar a capa (altura definida no CSS)
              child: Padding(padding: const EdgeInsets.only(left: 2, top: 2),
                child: SizedBox(key: const ValueKey('hero.cover'), width: 104, height: 156,
                    child: Transform.rotate(angle: -3 * math.pi / 180,
                        child: KeyedSubtree(key: const ValueKey('hero.cover#rot'), child: const DomCasmurroCover()))))),
            Expanded(child: /* hero.meta: Padding(top: 2) + Column(spaceBetween) [hero.meta.top, hero.meta.bottom] */),
          ])),
          SizedBox(key: const ValueKey('hero.actions'), height: 54, child: Row(spacing: 10, children: [/* CTA Expanded + botão 54 */])),
        ]),
      ),
      const Positioned(top: 18, right: 18, child: AppSvg(AppIcons.sparkleOutline, size: 30, key: ValueKey('hero.sparkleLarge'))),
      const Positioned(top: 54, right: 50, child: AppSvg(AppIcons.sparkleSolid, size: 14, key: ValueKey('hero.sparkleSmall'))),
    ]),
  ),
)
```
Pontos obrigatórios:
- Capa no `Align(topLeft)`: com `IntrinsicHeight` + `Row(stretch)`, a linha mede max(158, altura da coluna de metadados). Em 390 são 158, mas em 360 o título quebra e a linha mede **158,8** — sem o `Align`, o `SizedBox(104×156)` receberia altura *tight* 156,8 e a capa (e o texto ancorado embaixo dela) desceria 0,8 px. No CSS um item com altura definida nunca é esticado (w360: `hero.cover` continua com 156).
- Barra de progresso (assinatura da F01 §1.7):
  ```dart
  Semantics(container: true, label: 'Progresso do livro', value: '62%', excludeSemantics: true,
    child: StadiumProgressBar(key: const ValueKey('hero.progressBar'), fillKey: const ValueKey('hero.progressFill'),
        progress: 0.62, height: 10, background: AppColors.surface, fillColor: AppColors.ink)) // borda padrão 1,5 tinta
  ```
  → externa 181×10; preenchimento 0,62 × 178 = **110,36 × 7** alinhado à esquerda, raio 999, recortado pelo raio interno.
- Linha "62%": `Row(mainAxisAlignment: spaceBetween, crossAxisAlignment: baseline, textBaseline: alphabetic)`.
- Pílula: `Align(alignment: Alignment.centerLeft, child: Pill(key: 'hero.chapterPill' …))` dentro da coluna esticada.
- Título "Dom Casmurro" é `<h2>`: `Semantics(container: true, header: true, child: AppText('Dom Casmurro', key: const ValueKey('hero.title'), style: AppTextStyles.heroTitle))`.
- CTA: `Expanded(child: Pressable(isLink: true, semanticsLabel: 'Continuar lendo', onTap: …, child: NeoBox(key: const ValueKey('hero.cta'), height: 54, color: AppColors.ink, radius: BorderRadius.circular(999), child: Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 10, children: [const AppSvg(AppIcons.bookOpen, size: 20, key: ValueKey('hero.cta.icon')), AppText('Continuar lendo', key: const ValueKey('hero.cta.label'), style: AppTextStyles.cta16OnInk)]))))` → ícone em x 89,06 e rótulo em 119,06 (conteúdo 147,89 centralizado em 243); destino na F12 (`/leitor/:bookId`).
- Botão destaques (assinatura da F01 §1.7 — o `overlays` é medido a partir da borda interna, como o `position:absolute` do CSS):
  ```dart
  CircleIconButton(
    key: const ValueKey('hero.notesButton'),
    size: 54, color: AppColors.surface, border: const BorderSide(width: 1.5, color: AppColors.ink),
    icon: const AppSvg(AppIcons.highlighter, size: 22, key: ValueKey('hero.notesButton.icon')),
    overlays: [ // não-const: AppTextStyles.* são `static final`
      Positioned(top: -4, right: -4, child: CountBadge(key: const ValueKey('hero.notesButton.badge'), label: '14',
          style: AppTextStyles.micro11Bold, minWidth: 22, height: 22, horizontalPadding: 5,
          background: AppColors.sun, border: const BorderSide(width: 1.5, color: AppColors.ink))),
    ],
    onTap: …, // F12
    semanticsLabel: 'Destaques e notas deste livro (14)',
  )
  ```
  → badge 24,61 × 22 com o canto superior esquerdo em (x + 54 − 1,5 + 4 − 24,61; y + 1,5 − 4) = (x + 31,89; y − 2,5) em relação ao botão (absoluto 326,39; 445,16); sai do contorno sem recorte e não bloqueia o toque do botão.
- `DomCasmurroCover`: `NeoBox(width 104, height 156, color violet, borda 1,5, raio AppRadii.coverL, sombra hard3, clip: true)` + `Stack` com os 4 filhos na ordem da tabela (Keys `hero.cover.spine`, `.sun`, `.ring`, `.textBlock`, `.title`, `.author`).

## Subfases

- **5.1** Cartão (fundo brand, borda, raio, sombra dura, recorte interno) + brilhos absolutos por cima.
- **5.2** Capa Dom Casmurro completa (arte, rotação −3°, sombra 3/3, quebra forçada do autor).
- **5.3** Coluna de metadados — topo (pílula, título 1,05, autor `#2F2A40`).
- **5.4** Coluna de metadados — base (62% × tempo pela baseline, barra 62%).
- **5.5** Ações (CTA 243×54 com ícone+rótulo centralizados; botão 54 com badge 24,61 sobreposto).
- **5.6** Verificação completa + relatório.

## Testes da fase

- `expectGeometry(tester, idsOfSection('hero'))` → 30/30 (inclui os filhos da capa rotacionada via `layoutRect`).
- `expectTextLines` para todos os textos da seção (a capa só compara quebras: "Dom"/"Casmurro" e "MACHADO DE"/"ASSIS").
- Estilo: hero (`brand`, 1,5, raio 28, sombra (4,4) blur 0); capa (`#552CB7`, raio 4/10/10/4, sombra (3,3), ângulo −3°); anel da capa 21×21 borda `#FED170`; badge (`#FED170`, 1,5, 24,61×22).
- Tema: trocar `brand` para cada opção de `AppColors.brandOptions` muda só o fundo do cartão (e, na F11, o item ativo).
- Visual: `--rect 16,244,358,284` → `blur_mismatch_% ≤ 0,5`. Inspecione no lado-a-lado: rotação da capa, sombra da capa, recorte do sol no canto, brilho pequeno sobre o "rr".
- Não-regressão F03–F04.

## Checklist de aceite da FASE 5

- [ ] 5.1 Cartão 350×275, fundo brand, borda 1,5, raio 28, sombra (4,4,0), recorte interno 26,5, padding 20, gap 20
- [ ] 5.1 Brilho 30 em top18/right18 e brilho 14 em top54/right50 (a partir da borda interna), pintados por cima
- [ ] 5.2 Capa 104×156 no slot com margem 2/0/0/2, dentro de `Align(topLeft)` (nunca esticada pela linha); rotação −3° com Key no slot e `#rot` no conteúdo
- [ ] 5.2 Lombada 7 px .22 · sol 70 em −20/−20 recortado · anel 21×21 content-box · ordem de pintura correta
- [ ] 5.2 "Dom⏎Casmurro" 22/0,92 `#FED170`; "MACHADO DE⏎ASSIS" 6,5/700 ls 0,91 `#F7F0E3` (quebra forçada documentada)
- [ ] 5.3 Pílula 104,55×27,4 à esquerda; gap 10; título 24/1,05 ls −0,6; autor 14/500 `#2F2A40`; gap 3
- [ ] 5.4 "62%" × "~2h 10min" por baseline; gap 8; barra 181×10 com preenchimento 110,36×7
- [ ] 5.5 CTA 243×54 (ícone 20 + rótulo, gap 10, centralizados); botão 54 com badge 24,61×22 em top −4/right −4
- [ ] 5.5 Semânticas: seção (container + explicitChildNodes), cabeçalho h2 "Dom Casmurro", CTA (link), destaques (14), barra (62%)
- [ ] Geometria 30/30 · Texto OK · Estilo OK · Tema OK · Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com lado-a-lado e heatmap inspecionados

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 5 concluída — aguardando sua aprovação para iniciar a FASE 6.`
