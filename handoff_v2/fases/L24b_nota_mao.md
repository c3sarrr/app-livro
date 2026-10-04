# FASE L24b — Nota à mão escrita

> Tela 24b · prancha `24b_nota_mao` (24b · Leitor — nota à mão escrita, canvas 390×844) · executada na **G18** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L24b_nota_mao@3x.png` · `referencia/png/redline/L24b_nota_mao_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/24b_nota_mao_390x844@{1,2,3}x.png` · `referencia/layout/layout_24b_nota_mao.json` · `test/reference/leitor/reference_layout_24b_nota_mao.dart` (`kRef24b`).
> Arquivos sugeridos: `lib/features/reader/presentation/handwritten_note.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

O espaço aberto virou uma caixa de nota à mão; o texto de baixo continua depois da caixa.

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- The page: same layout as the clean reader, nudged down; text is locked (no reflow) while drawing -->
<article aria-label="Dom Casmurro, página 159 de 256 — modo anotação" style="position: absolute; left: 28px; right: 28px; top: 116px; bottom: 0; overflow: hidden;">
  <p style="margin: 0; padding-top: 6px; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em;">Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram aqueles <span style="position: relative; white-space: nowrap;"><svg aria-hidden="true" sc-camel-view-box="0 0 100 20" sc-camel-preserve-aspect-ratio="none" style="position: absolute; left: -5px; top: 3px; width: calc(100% + 10px); height: calc(100% - 4px); mix-blend-mode: multiply; pointer-events: none;"><path d="M2 4C20 1.5 45 3.5 70 2.5S94 2 98.5 3.5L99 17C82 18.5 60 16.5 38 18S8 18.5 1.5 17.5Z" fill="#FED170" opacity="0.9"></path></svg>olhos de Capitu</span>. Não me acode imagem capaz de dizer, sem quebra da dignidade do estilo, o que eles foram e me fizeram. <span style="position: relative; white-space: nowrap;"><svg aria-hidden="true" sc-camel-view-box="0 0 100 40" sc-camel-preserve-aspect-ratio="none" style="position: absolute; left: -9px; top: -6px; width: calc(100% + 18px); height: calc(100% + 12px); overflow: visible; pointer-events: none;"><path d="M60 3C86 2 99 10 98.5 21 97.5 33 76 38.5 48 37.5 20 36.5 2 30 2.5 19 3.5 8 25 2.5 53 3.5 70 4.5 83 8.5 88 12.5" fill="none" stroke="#FF552E" stroke-width="2.3" stroke-linecap="round" vector-effect="non-scaling-stroke"></path></svg><svg aria-hidden="true" width="34" height="12" sc-camel-view-box="0 0 34 12" style="position: absolute; left: 50%; top: -14px; margin-left: -17px; overflow: visible; pointer-events: none;"><path d="M1 7.5Q4 3 7 7.5T13 7.5 19 7.5 25 7.5 31 7.5" fill="none" stroke="#FF552E" stroke-width="1.8" stroke-linecap="round"></path></svg>Olhos de ressaca?</span> Vá, de ressaca.</p>

  <!-- Space opened between two lines: the text below slid down to make room -->
  <div role="group" aria-label="Nota à mão, depois de “Vá, de ressaca.”" style="position: relative; margin: 30px 0 26px; height: 150px; border-radius: 18px; border: 1.5px dashed #1A1714; background: #FFFDF8; box-sizing: border-box; font-family: 'Figtree', sans-serif;">
    <span style="position: absolute; left: 14px; top: -13px; height: 24px; padding: 0 10px 0 7px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 800; color: #1A1714; white-space: nowrap;"><svg width="13" height="13" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16z"></path></svg>Nota à mão</span>
    <span aria-hidden="true" style="position: absolute; left: 12px; right: 12px; top: 64px; height: 1.5px; background: #EFE5D3;"></span>
    <span aria-hidden="true" style="position: absolute; left: 12px; right: 12px; top: 106px; height: 1.5px; background: #EFE5D3;"></span>
    <span style="position: absolute; right: 12px; top: -20px; display: flex; gap: 6px;">
      <button aria-label="Recolher a nota" style="width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 15 6-6 6 6"></path></svg></button>
      <button aria-label="Apagar a nota" style="width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 7h16M9 7V4.5h6V7M6.5 7l1 13h9l1-13"></path></svg></button>
    </span>
    <svg aria-label="ressaca = o mar que puxa de volta (escrito à mão)" role="img" width="100%" height="150" sc-camel-view-box="0 0 334 150" style="position: absolute; left: 0; top: 0; overflow: visible;">
      <path d="M21.4 42.4L23.1 39.6L23.8 37.9L23.6 39.8L26.0 39.6L26.9 40.3L27.2 42.5L26.3 45.0L26.6 46.2L27.4 46.8L28.4 46.6L29.9 45.8L30.4 44.8L32.0 42.3M32.8 44.9L34.7 43.8L35.4 42.8L35.9 41.0L36.2 39.3L35.1 38.5L34.4 38.4L33.0 39.5L31.9 41.3L32.2 44.2L33.1 45.7L34.9 46.4L36.3 46.7L37.8 45.6L38.5 44.8L40.4 41.9M40.5 41.8L41.9 39.2L42.6 37.2L42.8 39.3L44.3 41.8L45.0 43.7L45.4 45.6L43.9 46.2M40.3 45.6L41.8 46.4L45.2 46.1L46.7 45.4L47.5 44.2L49.2 41.8M49.1 41.6L50.8 39.0L51.7 37.1L51.5 38.7L53.3 41.6L54.5 43.0L54.1 44.9L52.6 46.0M49.4 45.1L50.8 46.0L54.3 46.0L56.2 45.1L56.7 44.1L58.3 41.0M65.8 40.2L64.9 38.5L63.0 37.4L61.2 37.6L59.6 38.3L58.9 39.3L58.2 41.0L58.1 42.9L59.0 44.8L60.6 45.9L62.6 45.5L64.0 44.6L64.8 42.7L66.5 37.6L65.6 41.9L65.5 44.5L66.5 45.4L67.6 45.3L68.8 44.8L69.8 43.4L71.4 40.6M77.0 39.0L77.2 38.0L76.0 36.9L74.3 37.2L72.9 38.2L72.0 38.8L71.5 41.0L71.6 42.8L72.4 44.5L73.8 45.3L76.3 45.0L78.6 43.2L80.2 40.6M87.9 39.3L87.0 37.8L85.3 36.6L83.3 36.6L81.7 37.6L81.2 38.9L80.5 40.5L80.5 42.5L81.1 44.2L83.2 45.1L84.7 44.9L86.0 44.1L86.9 42.2L88.6 36.5L87.7 41.4L87.9 43.7L88.5 44.6L89.7 44.9L90.9 43.9L92.1 42.9L93.3 40.1M109.4 32.9L124.5 32.7M109.8 38.8L124.4 38.2M145.8 34.4L143.9 34.5L142.3 35.7L141.5 36.5L140.7 38.6L140.8 40.2L141.8 42.2L143.4 43.1L145.1 42.8L146.7 41.6L147.4 40.7L148.0 39.2L148.0 37.2L147.4 35.5L145.5 34.6L144.9 35.7L144.7 37.4L145.7 39.0L147.6 40.0L149.9 40.0L151.7 38.9L152.3 38.0M165.4 37.6L166.9 34.8L168.5 34.0L169.5 34.8L169.6 35.4L168.7 39.5L168.1 41.8M168.5 39.2L169.2 37.3L170.8 34.7L172.8 33.8L174.1 33.7L175.2 34.3L175.3 35.6L174.3 39.3L173.7 41.8M174.7 39.2L175.0 37.2L176.7 34.3L178.2 33.4L180.1 33.1L180.8 34.2L180.6 36.0L180.2 38.8L180.0 40.9L181.2 41.8L181.7 41.4L183.3 40.7L184.2 39.4L185.8 37.0M193.3 35.5L192.1 34.1L190.6 33.1L188.7 32.9L187.4 34.0L186.4 35.2L185.9 37.0L185.7 38.8L186.5 40.6L188.4 41.2L190.1 41.4L191.5 40.1L192.4 38.3L193.7 32.7L193.0 37.3L193.2 40.1L194.3 41.0L195.0 40.9L196.5 39.8L197.2 38.9L199.0 36.4M198.7 36.4L200.6 33.4L201.4 31.7L201.3 33.7L203.7 33.5L204.7 34.6L204.5 36.3L204.0 39.0L203.9 39.7L204.6 40.5L205.4 40.8L207.1 39.5L207.8 38.9L209.7 36.1" fill="none" stroke="#FF552E" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"></path>
      <path d="M40.7 83.3L39.8 81.6L38.1 80.7L36.5 81.0L35.2 81.8L34.1 82.9L33.4 84.5L33.3 86.3L34.4 88.2L35.9 89.0L37.5 88.8L39.1 87.9M41.3 80.4L40.7 83.3L39.4 88.0L37.2 94.5L36.5 97.4L36.4 98.9L37.5 99.7L39.0 99.0L39.4 96.3L39.6 89.9L41.1 89.0L43.2 87.0L45.7 84.3M45.9 84.3L47.3 80.6L45.9 86.0L45.7 87.5L46.5 88.6L48.1 88.8L50.0 87.7L51.6 85.8L53.0 82.7M53.9 80.3L52.3 85.7L52.5 87.3L53.4 88.3L53.8 88.3L55.8 87.3L56.6 86.7L58.0 83.6M58.9 86.5L60.6 85.5L61.4 84.3L61.9 82.5L62.1 80.7L61.2 79.7L60.1 79.9L58.8 81.0L58.0 82.7L58.1 85.5L58.9 87.1L60.8 88.0L62.5 88.3L63.6 87.1L64.8 86.4L66.1 83.3M79.1 83.2L80.6 80.2L81.4 78.3L81.1 81.8L76.7 98.5M81.1 82.1L81.5 80.3L83.2 78.9L84.6 79.1L86.5 79.9L87.2 81.7L87.4 83.8L86.5 85.6L86.1 86.2L84.5 87.4M81.2 86.4L82.6 87.3L85.4 87.3L87.5 86.3L89.0 85.1L91.3 82.7M91.4 82.7L92.9 78.7L91.6 84.2L91.6 86.4L92.7 87.2L94.2 87.2L96.0 86.0L97.4 83.9L99.0 81.3M99.7 78.7L98.0 83.9L98.4 85.7L99.0 86.7L99.8 86.9L101.7 85.7L102.3 84.8L103.8 82.0M103.6 81.9L105.2 79.5L106.9 78.2L108.8 78.5L109.4 79.0L109.5 85.3L110.4 86.2L112.8 86.2L115.4 84.6L117.0 81.6M114.3 79.0L113.4 78.0L111.6 78.1L111.3 78.9L108.0 85.7L107.4 86.4L105.5 86.5L104.7 85.7M124.4 80.6L123.5 78.4L121.4 77.9L120.2 77.9L118.4 78.6L117.6 80.0L117.0 81.8L117.2 83.3L117.6 85.1L119.5 86.2L121.3 86.1L122.8 85.2L123.4 83.3L124.7 77.9L124.1 82.5L124.4 84.9L125.0 85.8L126.1 86.0L127.4 84.7L128.4 84.0L129.9 81.0M150.4 79.3L149.4 77.8L148.0 77.0L146.4 77.0L144.4 77.8L144.0 79.0L142.9 80.5L143.1 82.6L143.9 84.2L145.7 85.4L147.1 84.9L148.8 84.1L149.7 82.2L154.1 65.9M151.1 76.7L150.7 81.3L150.7 84.0L151.2 85.1L152.1 85.2L153.8 83.8L154.4 83.0L156.2 80.5M156.8 82.9L158.5 82.2L159.2 80.8L159.9 79.2L160.3 77.6L159.4 76.8L158.7 76.5L156.7 77.7L156.2 79.1L156.3 82.0L157.0 83.8L158.6 84.5L160.2 84.6L162.2 83.5L163.0 82.6L164.2 80.1M177.5 79.5L178.7 75.8L178.2 80.6L178.2 83.1L179.4 83.8L179.9 84.1L182.5 82.8L183.7 80.9L184.9 78.2L184.7 75.8M184.5 75.5L185.8 79.3L186.3 80.2L187.9 80.0L189.4 79.2M194.6 75.4L193.0 75.1L191.0 76.3L190.6 77.5L189.6 79.0L189.7 80.9L190.8 82.5L192.4 83.7L194.1 83.6L195.5 82.4L196.2 81.5L197.2 79.5L196.8 78.1L196.0 75.9L194.2 75.3L193.6 76.5L193.9 78.3L194.5 79.6L196.0 80.7L198.8 80.6L200.2 79.6L201.1 78.8M201.2 78.9L202.7 75.7L205.1 71.2L205.7 69.4L206.5 66.5L206.2 64.8L205.3 64.2L203.9 64.9L203.1 67.1L202.4 70.3L202.0 76.9L202.3 82.1L202.9 83.3L203.9 83.4L205.1 82.1L205.9 81.1L207.9 78.5M207.8 78.4L209.3 75.7L210.6 72.1M213.1 63.5L208.6 80.3L208.4 82.0L209.2 82.8L210.9 83.0L212.7 81.8L213.2 80.9L215.1 78.1M208.1 71.0L214.1 71.0M222.1 76.9L221.4 75.3L219.8 74.2L218.0 74.6L216.5 75.3L215.7 76.6L214.9 78.3L215.0 80.0L216.1 82.1L217.5 82.5L219.3 82.5L220.6 81.9L221.6 80.0L223.0 74.5L222.4 78.7L222.2 81.6L223.4 82.7L223.9 82.5L225.7 81.5L226.3 80.4L228.1 78.0" fill="none" stroke="#FF552E" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"></path>
      <path d="M258 56C272 40 300 40 314 56 300 70 272 70 258 56Z" fill="none" stroke="#FF552E" stroke-width="2.2" stroke-linejoin="round" stroke-linecap="round"></path><circle cx="286" cy="56" r="7.5" fill="#FF552E"></circle><path d="M258 88q6-7 12 0t12 0 12 0 12 0 12 0" fill="none" stroke="#FF552E" stroke-width="2.2" stroke-linecap="round"></path><path d="M266 102q6-7 12 0t12 0 12 0 12 0" fill="none" stroke="#FF552E" stroke-width="2.2" stroke-linecap="round"></path>
    </svg>
    <span style="position: absolute; left: 14px; bottom: 8px; font-size: 11px; font-weight: 700; color: #A89D8B;">puxe a alça para aumentar</span>
    <button aria-label="Arrastar para mudar a altura do espaço" style="position: absolute; left: 50%; bottom: -12px; width: 52px; height: 22px; margin-left: -26px; padding: 0; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px;"><span style="width: 20px; height: 1.6px; border-radius: 2px; background: #1A1714;"></span><span style="width: 20px; height: 1.6px; border-radius: 2px; background: #1A1714;"></span></button>
  </div>

  <p style="margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left;">É o que me dá ideia daquela feição nova. Traziam não sei que <span style="position: relative; white-space: nowrap;"><svg aria-hidden="true" height="10" style="position: absolute; left: -1px; bottom: -9px; width: calc(100% + 2px); overflow: hidden; pointer-events: none;"><path d="M0 5 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0" fill="none" stroke="#FF552E" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"></path></svg>fluido misterioso</span> e enérgico, uma força que arrastava para dentro, como <span style="position: relative; white-space: nowrap;"><span aria-hidden="true" style="position: absolute; left: -2px; right: -2px; bottom: -3px; height: 2.4px; border-radius: 2px; background: #FF552E;"></span><span aria-hidden="true" style="position: absolute; left: -2px; right: -2px; bottom: -8px; height: 2.4px; border-radius: 2px; background: #FF552E;"></span>a vaga que se retira</span> da praia, nos dias de ressaca. Para não ser arrastado, agarrei-me às outras partes vizinhas, às orelhas, aos braços, aos cabelos espalhados pelos ombros; mas tão depressa buscava as pupilas, a onda que saía delas vinha crescendo, cava e escura, ameaçando envolver-me, puxar-me e tragar-me.</p>
</article>
```

## Especificação pixel a pixel

Seção `hn.page` — retângulo absoluto no canvas 390×844: **x=28, y=116, w=334, h=728**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `hn.page` | box | 0 | 0 | 334 | 728 | `position: absolute; left: 28px; right: 28px; top: 116px; bottom: 0; overflow: hidden` |  |
| 2 | `hn.page.text` | text | 0 | 0 | 334 | 288.08 | `margin: 0; padding-top: 6px; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 3 | `hn.page.text.handHighlight` ±1 | inline | 0 | 114.19 | 148.92 | 30.44 | `position: relative; white-space: nowrap` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 4 | `hn.page.text.handHighlight.stroke` ±1 | icon | -5 | 117.19 | 158.92 | 26.44 | `position: absolute; left: -5px; top: 3px; width: calc(100% + 10px); height: calc(100% - 4px); mix-blend-mode: multiply; pointer-events: none` |  |
| 5 | `hn.page.text.circled` ±1 | inline | 0 | 255.23 | 168.54 | 30.44 | `position: relative; white-space: nowrap` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 6 | `hn.page.text.circled.ellipse` ±1 | icon | -9 | 249.23 | 186.54 | 42.44 | `position: absolute; left: -9px; top: -6px; width: calc(100% + 18px); height: calc(100% + 12px); overflow: visible; pointer-events: none` |  |
| 7 | `hn.page.text.circled.flourish` ±1 | icon | 67.27 | 241.23 | 34 | 12 | `position: absolute; left: 50%; top: -14px; margin-left: -17px; overflow: visible; pointer-events: none` |  |
| 8 | `hn.page.handNote` | box | 0 | 318.08 | 334 | 150 | `position: relative; margin: 30px 0 26px; height: 150px; border-radius: 18px; border: 1.5px dashed #1A1714; background: #FFFDF8; box-sizing: border-box; font-family: 'Figtree', sans-serif` |  |
| 9 | `hn.page.handNote.tag` ±1 | box+text | 15.5 | 306.58 | 98.97 | 24 | `position: absolute; left: 14px; top: -13px; height: 24px; padding: 0 10px 0 7px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 800; color: #1A1714; white-space: nowrap` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 10 | `hn.page.handNote.tag.icon` | icon | 24 | 312.08 | 13 | 13 | `—` |  |
| 11 | `hn.page.handNote.rule1` | box | 13.5 | 383.58 | 307 | 1.5 | `position: absolute; left: 12px; right: 12px; top: 64px; height: 1.5px; background: #EFE5D3` |  |
| 12 | `hn.page.handNote.rule2` | box | 13.5 | 425.58 | 307 | 1.5 | `position: absolute; left: 12px; right: 12px; top: 106px; height: 1.5px; background: #EFE5D3` |  |
| 13 | `hn.page.handNote.actions` | box | 234.5 | 299.58 | 86 | 40 | `position: absolute; right: 12px; top: -20px; display: flex; gap: 6px` |  |
| 14 | `hn.page.handNote.actions.collapse` | box | 234.5 | 299.58 | 40 | 40 | `width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 15 | `hn.page.handNote.actions.collapse.icon` | icon | 245.5 | 310.58 | 18 | 18 | `—` |  |
| 16 | `hn.page.handNote.actions.delete` | box | 280.5 | 299.58 | 40 | 40 | `width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 17 | `hn.page.handNote.actions.delete.icon` | icon | 291.5 | 310.58 | 18 | 18 | `—` |  |
| 18 | `hn.page.handNote.ink` | icon | 1.5 | 319.58 | 331 | 150 | `position: absolute; left: 0; top: 0; overflow: visible` |  |
| 19 | `hn.page.handNote.hint` ±1 | text | 15.5 | 445.38 | 132.33 | 13.2 | `position: absolute; left: 14px; bottom: 8px; font-size: 11px; font-weight: 700; color: #A89D8B` | Figtree 11/normal peso 700 ls normal #A89D8B |
| 20 | `hn.page.handNote.handle` | box | 141 | 456.58 | 52 | 22 | `position: absolute; left: 50%; bottom: -12px; width: 52px; height: 22px; margin-left: -26px; padding: 0; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px` |  |
| 21 | `hn.page.handNote.handle.bar1` | box | 157 | 464.48 | 20 | 1.6 | `width: 20px; height: 1.6px; border-radius: 2px; background: #1A1714` |  |
| 22 | `hn.page.handNote.handle.bar2` | box | 157 | 469.08 | 20 | 1.6 | `width: 20px; height: 1.6px; border-radius: 2px; background: #1A1714` |  |
| 23 | `hn.page.textBelow` | text | 0 | 494.08 | 334 | 493.64 | `margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 24 | `hn.page.textBelow.wavy` ±1 | inline | 0 | 567.01 | 165.14 | 30.44 | `position: relative; white-space: nowrap` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 25 | `hn.page.textBelow.wavy.wave` ±1 | icon | -1 | 596.45 | 167.14 | 10 | `position: absolute; left: -1px; bottom: -9px; width: calc(100% + 2px); overflow: hidden; pointer-events: none` |  |
| 26 | `hn.page.textBelow.doubleUnderline` ±1 | inline | 57.67 | 637.53 | 183.47 | 30.44 | `position: relative; white-space: nowrap` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 27 | `hn.page.textBelow.doubleUnderline.line1` ±1 | box | 55.67 | 668.57 | 187.47 | 2.4 | `position: absolute; left: -2px; right: -2px; bottom: -3px; height: 2.4px; border-radius: 2px; background: #FF552E` |  |
| 28 | `hn.page.textBelow.doubleUnderline.line2` ±1 | box | 55.67 | 673.57 | 187.47 | 2.4 | `position: absolute; left: -2px; right: -2px; bottom: -8px; height: 2.4px; border-radius: 2px; background: #FF552E` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `hn.page.text` *(composto)* | 1 | Retórica dos namorados, dá-me | 32.54 | 26.65 | 332 | 305.35 |
| `hn.page.text` *(composto)* | 2 | uma comparação exata e poética | 67.8 | 0 | 312.39 | 312.39 |
| `hn.page.text` *(composto)* | 3 | para dizer o que foram aqueles | 103.06 | 0 | 294.1 | 294.1 |
| `hn.page.text` *(composto)* | 4 | olhos de Capitu. Não me acode | 138.32 | 0 | 293.2 | 293.2 |
| `hn.page.text` *(composto)* | 5 | imagem capaz de dizer, sem | 173.58 | 0 | 267.46 | 267.46 |
| `hn.page.text` *(composto)* | 6 | quebra da dignidade do estilo, o | 208.84 | 0 | 305.61 | 305.61 |
| `hn.page.text` *(composto)* | 7 | que eles foram e me fizeram. | 244.1 | 0 | 274.05 | 274.05 |
| `hn.page.text` *(composto)* | 8 | Olhos de ressaca? Vá, de ressaca. | 279.36 | 0 | 312.43 | 312.43 |
| `hn.page.handNote.tag` | 1 | Nota à mão | 322.61 | 42 | 102.97 | 60.97 |
| `hn.page.handNote.hint` | 1 | puxe a alça para aumentar | 455.83 | 15.5 | 147.83 | 132.33 |
| `hn.page.textBelow` *(composto)* | 1 | É o que me dá ideia daquela feição | 520.62 | 0 | 325.69 | 325.69 |
| `hn.page.textBelow` *(composto)* | 2 | nova. Traziam não sei que | 555.88 | 0 | 252.27 | 252.27 |
| `hn.page.textBelow` *(composto)* | 3 | fluido misterioso e enérgico, uma | 591.14 | 0 | 322.57 | 322.57 |
| `hn.page.textBelow` *(composto)* | 4 | força que arrastava para dentro, | 626.4 | 0 | 309.03 | 309.03 |
| `hn.page.textBelow` *(composto)* | 5 | como a vaga que se retira da praia, | 661.66 | 0 | 330.66 | 330.66 |
| `hn.page.textBelow` *(composto)* | 6 | nos dias de ressaca. Para não ser | 696.92 | 0 | 308.34 | 308.34 |
| `hn.page.textBelow` *(composto)* | 7 | arrastado, agarrei-me às outras | 732.18 | 0 | 301.46 | 301.46 |
| `hn.page.textBelow` *(composto)* | 8 | partes vizinhas, às orelhas, aos *(oculta: recortada)* | 767.44 | 0 | 297.41 | 297.41 |
| `hn.page.textBelow` *(composto)* | 9 | braços, aos cabelos espalhados *(oculta: recortada)* | 802.7 | 0 | 293.73 | 293.73 |
| `hn.page.textBelow` *(composto)* | 10 | pelos ombros; mas tão depressa *(oculta: recortada)* | 837.96 | 0 | 302.87 | 302.87 |
| `hn.page.textBelow` *(composto)* | 11 | buscava as pupilas, a onda que *(oculta: recortada)* | 873.22 | 0 | 292.33 | 292.33 |
| `hn.page.textBelow` *(composto)* | 12 | saía delas vinha crescendo, cava e *(oculta: recortada)* | 908.48 | 0 | 322.79 | 322.79 |
| `hn.page.textBelow` *(composto)* | 13 | escura, ameaçando envolver-me, *(oculta: recortada)* | 943.74 | 0 | 317.21 | 317.21 |
| `hn.page.textBelow` *(composto)* | 14 | puxar-me e tragar-me. *(oculta: recortada)* | 979 | 0 | 218.3 | 218.3 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Caixa: `margin 30/0/26`, altura 150, raio 18, tracejado 1,5, fundo `#FFFDF8`; etiqueta amarela "✎ Nota à mão" em `left 14 · top −13`; 2 réguas `#EFE5D3` em 64 e 106.
2. Botões 40 "Recolher a nota" (˄) e "Apagar a nota" (lixeira) em `right 12 · top −20`; tinta coral "ressaca = o mar / que puxa de volta" + olho + ondas (SVG 334×150).
3. Dica "puxe a alça para aumentar" (Figtree 11/700 `#A89D8B`) e alça 52×22 com duas barras, sombra 2/2, em `bottom −12` centrada.

## Armadilhas

- Fio de navalha em `hn.page.text` linha 7 «que eles foram e me fizeram.»: sobra 59.95 px · estouro com a próxima palavra 0.71 px.
- Fio de navalha em `hn.page.textBelow` linha 11 «buscava as pupilas, a onda que»: sobra 41.67 px · estouro com a próxima palavra 0.54 px.
- `hn.page.text.handHighlight.stroke` usa `mix-blend-mode: multiply`.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `hn.page.textBelow`.

## Diferenças em relação à prancha 22 (seções reutilizadas: deskEdge, modePill, done, toolShelf, island)

Estas seções são as mesmas widgets da 22 (fases L22a_pagina_anotada, L22b_topo_modo_anotacao, L22c_prateleira_ferramentas, L22d_ilha_anotacao); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `hn.page` |  | Dom Casmurro, página 159 de 256 — modo anotação |  |
| `hn.page.text.handHighlight.stroke` |  |  | aria-hidden=true |
| `hn.page.text.circled.ellipse` |  |  | aria-hidden=true |
| `hn.page.text.circled.flourish` |  |  | aria-hidden=true |
| `hn.page.handNote` | group | Nota à mão, depois de “Vá, de ressaca.” |  |
| `hn.page.handNote.tag.icon` |  |  | aria-hidden=true |
| `hn.page.handNote.rule1` |  |  | aria-hidden=true |
| `hn.page.handNote.rule2` |  |  | aria-hidden=true |
| `hn.page.handNote.actions.collapse` |  | Recolher a nota |  |
| `hn.page.handNote.actions.collapse.icon` |  |  | aria-hidden=true |
| `hn.page.handNote.actions.delete` |  | Apagar a nota |  |
| `hn.page.handNote.actions.delete.icon` |  |  | aria-hidden=true |
| `hn.page.handNote.ink` | img | ressaca = o mar que puxa de volta (escrito à mão) |  |
| `hn.page.handNote.handle` |  | Arrastar para mudar a altura do espaço |  |
| `hn.page.textBelow.wavy.wave` |  |  | aria-hidden=true |
| `hn.page.textBelow.doubleUnderline.line1` |  |  | aria-hidden=true |
| `hn.page.textBelow.doubleUnderline.line2` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `hn.page.text.handHighlight` | TextSpan dentro do AppText.rich do pai |  |
| `hn.page.text.handHighlight.stroke` | InkStrokesPainter (traços da fixture: grifo_mao_livre_capitu) |  |
| `hn.page.text.circled` | TextSpan dentro do AppText.rich do pai |  |
| `hn.page.text.circled.ellipse` | InkStrokesPainter (traços da fixture: elipse_olhos_de_ressaca) | vector-effect="non-scaling-stroke" e preserveAspectRatio="none" (esticado sobre o trecho): na app é tinta (traços salvos), não asset. |
| `hn.page.text.circled.flourish` | InkStrokesPainter (traços da fixture: risco_sobre_olhos_de_ressaca) |  |
| `hn.page.handNote` | NeoBox |  |
| `hn.page.handNote.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `hn.page.handNote.tag.icon` | AppSvg(AppIconsLeitor.ic_pencil_bold, size: 13) |  |
| `hn.page.handNote.rule1` | NeoBox |  |
| `hn.page.handNote.rule2` | NeoBox |  |
| `hn.page.handNote.actions.collapse` | CircleIconButton / NeoBox circular |  |
| `hn.page.handNote.actions.collapse.icon` | AppSvg(AppIconsLeitor.ic_chevron_up, size: 18) |  |
| `hn.page.handNote.actions.delete` | CircleIconButton / NeoBox circular |  |
| `hn.page.handNote.actions.delete.icon` | AppSvg(AppIconsLeitor.ic_trash, size: 18) |  |
| `hn.page.handNote.ink` | InkStrokesPainter (traços da fixture: nota_mao_ressaca) | width="100%" (largura da caixa) e rótulo role=img com o texto escrito (D-31: no app o rótulo é genérico). |
| `hn.page.handNote.handle` | NeoBox |  |
| `hn.page.handNote.handle.bar1` | NeoBox |  |
| `hn.page.handNote.handle.bar2` | NeoBox |  |
| `hn.page.textBelow.wavy` | TextSpan dentro do AppText.rich do pai |  |
| `hn.page.textBelow.wavy.wave` | InkStrokesPainter (traços da fixture: ondulado_fluido_misterioso) |  |
| `hn.page.textBelow.doubleUnderline` | TextSpan dentro do AppText.rich do pai |  |
| `hn.page.textBelow.doubleUnderline.line1` | NeoBox |  |
| `hn.page.textBelow.doubleUnderline.line2` | NeoBox |  |

## Interações

- Recolher/expandir; apagar (confirmação não desenhada → D-23); arrastar a alça muda a altura em linhas.

## Dados

- `ink_layers` (space, `collapsed`, `strokes_b64`) + `annotations(kind=handwriting)`; rótulo semântico genérico "Nota à mão, <data>" (D-31).

## Subfases

- **L24b.1** Caixa + etiqueta + réguas
- **L24b.2** Botões
- **L24b.3** Tinta da nota
- **L24b.4** Alça e dica
- **L24b.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('hn.page'), todos os ids de `kRef24b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/24b_nota_mao_390x844@3x.png` no recorte da fase (y 108–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L24b.1 Caixa + etiqueta + réguas
- [ ] L24b.2 Botões
- [ ] L24b.3 Tinta da nota
- [ ] L24b.4 Alça e dica
- [ ] L24b.5 Verificação + relatório
- [ ] Geometria 24/24 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
