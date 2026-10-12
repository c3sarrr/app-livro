# FASE L17 — Detalhes (livro físico) — Seus grifos, fotografar um trecho e a enquete do clube

> Tela 17 · prancha `017_detalhes_fisico` (17 · Detalhes do livro — físico (Brás Cubas), canvas 390×1940) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L17_6_grifos_e_clube@3x.png` · `docs/design/medicao/projeto/png/redline/L17_6_grifos_e_clube_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_017_detalhes_fisico.json` · `test/reference/projeto/reference_layout_017_detalhes_fisico.dart` (`kRef17`).
> Arquivos sugeridos: `lib/features/library/presentation/details/details_highlights_section.dart`, `lib/features/library/presentation/details/club_poll_card.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Livro físico: "Seus grifos" (3 trechos) com o último grifo — fotografado, em Instrument Serif com o marca-texto amarelo e "Fotografado da pág. 9" —, o botão tracejado "Fotografar um trecho" e o cartão rosa do clube: o livro lidera a votação do próximo livro.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{halo}}` = padrão `#ABCF82`, `{{shelf}}` = padrão `#FED170`.

```html
<section aria-label="Grifos e clube" style="margin-top: 30px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Seus grifos</h2><span style="font-size: 12.5px; font-weight: 700; color: #6F665B;">3 trechos</span></div>
  <figure style="margin: 12px 0 0; padding: 16px 16px 14px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <blockquote style="margin: 0; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 21px; line-height: 1.35;"><span style="background: linear-gradient(transparent 52%, #FED170 52%, #FED170 92%, transparent 92%); -webkit-box-decoration-break: clone; box-decoration-break: clone;">“Ao verme que primeiro roeu as frias carnes do meu cadáver dedico como saudosa lembrança estas memórias póstumas.”</span></blockquote>
    <figcaption style="margin-top: 10px; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 700; color: #6F665B;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6F665B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3z"></path><circle cx="12" cy="13" r="3.5"></circle></svg> Fotografado da pág. 9</figcaption>
  </figure>
  <button style="margin-top: 10px; width: 100%; height: 48px; border-radius: 999px; background: transparent; border: 1.5px dashed #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 14.5px; font-weight: 800;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3z"></path><circle cx="12" cy="13" r="3.5"></circle></svg>Fotografar um trecho</button>

  <a href="#" style="margin-top: 16px; display: flex; align-items: center; gap: 12px; padding: 14px; border-radius: 20px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box;">
    <span aria-hidden="true" style="width: 44px; height: 44px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px;">1º</span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.1px; color: #5B2A33;">LEITORAS DE CAPITU</span>
      <span style="display: block; margin-top: 2px; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Lidera a votação do próximo livro do clube</span>
      <span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #3E3832;">5 votos · fecha terça</span>
    </span>
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
  </a>
</section>
```

## Especificação pixel a pixel

Seção `d17.highlights` — retângulo absoluto no canvas 390×1940: **x=20, y=1536.01, w=350, h=382.32**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `d17.highlights` | box | 0 | 0 | 350 | 382.32 | `margin-top: 30px` |  |
| 2 | `d17.highlights.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 3 | `d17.highlights.title` ±1 | text | 0 | 0 | 106.27 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 4 | `d17.highlights.count` ±1 | text | 296.35 | 6.72 | 53.65 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #6F665B` | Figtree 12.5/normal peso 700 ls normal #6F665B |
| 5 | `d17.highlights.quote` | box | 0 | 36 | 350 | 171.41 | `margin: 12px 0 0; padding: 16px 16px 14px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 6 | `d17.highlights.quote.text` | box | 17.5 | 53.5 | 315 | 113.4 | `margin: 0; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 21px; line-height: 1.35` | Instrument Serif itálico 21/28.35px peso 400 ls normal #1A1714 |
| 7 | `d17.highlights.quote.text.mark` ±1 | inline | 17.5 | 54.02 | 271.76 | 112.35 | `background: linear-gradient(transparent 52%, #FED170 52%, #FED170 92%, transparent 92%); -webkit-box-decoration-break: clone; box-decoration-break: clone` | Instrument Serif itálico 21/28.35px peso 400 ls normal #1A1714 |
| 8 | `d17.highlights.quote.caption` | text | 17.5 | 176.9 | 315 | 15.01 | `margin-top: 10px; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 700; color: #6F665B` | Figtree 12.5/normal peso 700 ls normal #6F665B |
| 9 | `d17.highlights.quote.caption.icon` | icon | 17.5 | 177.4 | 14 | 14 | `—` |  |
| 10 | `d17.highlights.photograph` | box+text | 0 | 217.41 | 350 | 48 | `margin-top: 10px; width: 100%; height: 48px; border-radius: 999px; background: transparent; border: 1.5px dashed #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 14.5px; font-weight: 800` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 11 | `d17.highlights.photograph.icon` ±1 | icon | 89.59 | 232.41 | 18 | 18 | `—` |  |
| 12 | `d17.highlights.club` | box | 0 | 281.41 | 350 | 100.91 | `margin-top: 16px; display: flex; align-items: center; gap: 12px; padding: 14px; border-radius: 20px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box` |  |
| 13 | `d17.highlights.club.rank` | box+text | 15.5 | 309.87 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px` | Bricolage (opsz 18) 18/normal peso 800 ls normal #1A1714 |
| 14 | `d17.highlights.club.textBlock` ±1 | box | 71.5 | 296.91 | 234.57 | 69.91 | `min-width: 0; flex-grow: 1` |  |
| 15 | `d17.highlights.club.kicker` ±1 | text | 71.5 | 296.91 | 234.57 | 13.2 | `display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.1px; color: #5B2A33` | Figtree 11/normal peso 800 ls 1.1px #5B2A33 |
| 16 | `d17.highlights.club.title` ±1 | text | 71.5 | 312.11 | 234.57 | 37.7 | `display: block; margin-top: 2px; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 17 | `d17.highlights.club.meta` ±1 | text | 71.5 | 351.81 | 234.57 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #3E3832` | Figtree 12.5/normal peso 600 ls normal #3E3832 |
| 18 | `d17.highlights.club.chevron` ±1 | icon | 318.07 | 321.87 | 16.43 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17.highlights.title` | 1 | Seus grifos | 18.6 | 0 | 106.27 | 106.27 |
| `d17.highlights.count` | 1 | 3 trechos | 18.6 | 296.35 | 350 | 53.65 |
| `d17.highlights.quote.text` *(composto)* | 1 | “Ao verme que primeiro roeu as frias | 74.81 | 17.5 | 289.26 | 271.76 |
| `d17.highlights.quote.text` *(composto)* | 2 | carnes do meu cadáver dedico como | 103.16 | 17.5 | 287.92 | 270.42 |
| `d17.highlights.quote.text` *(composto)* | 3 | saudosa lembrança estas memórias | 131.51 | 17.5 | 285.75 | 268.25 |
| `d17.highlights.quote.text` *(composto)* | 4 | póstumas.” | 159.86 | 17.5 | 100.07 | 82.57 |
| `d17.highlights.quote.caption` | 1 | Fotografado da pág. 9 | 188.78 | 37.5 | 163.8 | 126.3 |
| `d17.highlights.photograph` | 1 | Fotografar um trecho | 246.48 | 115.59 | 260.41 | 144.82 |
| `d17.highlights.club.rank` | 1 | 1º | 337.81 | 30.44 | 44.56 | 14.12 |
| `d17.highlights.club.kicker` | 1 | LEITORAS DE CAPITU | 307.36 | 71.5 | 204.03 | 132.53 |
| `d17.highlights.club.title` | 1 | Lidera a votação do próximo livro | 326.61 | 71.5 | 296.37 | 224.87 |
| `d17.highlights.club.title` | 2 | do clube | 345.46 | 71.5 | 128.85 | 57.35 |
| `d17.highlights.club.meta` | 1 | 5 votos · fecha terça | 363.69 | 71.5 | 187.38 | 115.88 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Seus grifos" Bricolage 20/800 e "3 trechos" 12,5/700 `#6F665B` (baseline), 30 abaixo da sinopse.
2. Grifo: padding 16/16/14, raio 20, `#FFFAF1`, borda 1,5, sem sombra; citação Instrument Serif itálico 21 `lh 1,35` com o marca-texto em cada linha (`linear-gradient`: transparente até 52 %, `#FED170` de 52 % a 92 %, `box-decoration-break: clone`); a legenda 10 abaixo, câmera 14 + "Fotografado da pág. 9" 12,5/700 `#6F665B`.
3. "Fotografar um trecho", 10 abaixo: 48 de altura, sem fundo, borda 1,5 `dashed #1A1714`, câmera 18 + 14,5/800.
4. Clube, 16 abaixo: padding 14, raio 20, `#FFC1C6`, sombra dura 3/3, gap 12 — o círculo 44 com "1º" Bricolage 18/800; "LEITORAS DE CAPITU" 11/800 ls 1,1 `#5B2A33`, "Lidera a votação do próximo livro do clube" 14,5/800 `lh 1,3` e "5 votos · fecha terça" 12,5/600 `#3E3832`; a seta à direita (traço 2,4).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O marca-texto cobre de 52 % a 92 % da altura de cada linha (não da caixa): no app, o marca-texto por linha dos grifos (`marked_quote.dart`), conferindo as alturas na referência @3x.
- A seta do clube encolhe no flex (20 → 16,43, ver o mapa de widgets): decidir na T14 se o app repete.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_017_detalhes_fisico_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_017_detalhes_fisico_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `d17.highlights` |  | Grifos e clube |  |
| `d17.highlights.quote.caption.icon` |  |  | aria-hidden=true |
| `d17.highlights.photograph.icon` |  |  | aria-hidden=true |
| `d17.highlights.club.rank` |  |  | aria-hidden=true |
| `d17.highlights.club.chevron` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `d17.highlights.quote` | NeoBox |  |
| `d17.highlights.quote.text.mark` | TextSpan dentro do AppText.rich do pai |  |
| `d17.highlights.quote.caption.icon` | AppSvg(AppIconsBiblioteca.camera, size: 14) |  |
| `d17.highlights.photograph` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.highlights.photograph.icon` | AppSvg(AppIconsBiblioteca.cameraTinta, size: 18) |  |
| `d17.highlights.club` | NeoBox |  |
| `d17.highlights.club.rank` | CircleIconButton / NeoBox circular |  |
| `d17.highlights.club.chevron` | AppSvg(AppIconsBiblioteca.chevronRightClube, size: 16.43) | o `<svg>` de 20×20 (atributos) não tem flex-shrink: 0 e encolhe na linha que não cabe: fica 16,43×20 no layout, e o desenho (viewBox 24×24, preserveAspectRatio meet) sai 16,43×16,43, centrado na altura. A prancha mostra o ícone menor — decidir na T14 se o app repete o encolhimento (o tamanho do catálogo) ou usa o dos atributos. |

## Interações

- Grifo → os grifos do livro (a tela 25, `AppRoutes.destaques`).
- Fotografar um trecho → câmera e leitura de texto no aparelho (OCR offline, nota do design); a tela da captura não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T14 (ROTEIRO §2b).
- Cartão do clube → a Enquete (47–49), da T11: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T14 (ROTEIRO §2b).

## Dados

- "3 trechos" = os grifos deste livro; o mostrado é o mais recente, com a origem (fotografado) e a página.
- O cartão aparece quando um clube da pessoa tem este livro numa enquete aberta. O app ainda não tem enquete (é da T11): D-247 — com dados reais o cartão some até lá, e a fixture continua nos testes.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L17.1** Seus grifos com o último trecho
- **L17.2** Fotografar um trecho
- **L17.3** Cartão da enquete do clube
- **L17.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('d17.highlights'), todos os ids de `kRef17.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@3x.png` no recorte da fase (y 1528.01–1926.33) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef17w360` e `kRef17w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L17.1 Seus grifos com o último trecho
- [ ] L17.2 Fotografar um trecho
- [ ] L17.3 Cartão da enquete do clube
- [ ] L17.4 Verificação + relatório
- [ ] Geometria 17/17 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
