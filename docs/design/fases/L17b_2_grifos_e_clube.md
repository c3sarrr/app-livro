# FASE L17b — Detalhes (e-book) — Seus grifos (Ver os 12) e o próximo encontro do clube

> Tela 17b · prancha `017b_detalhes_ebook` (17b · Detalhes do livro — e-book (Dom Casmurro), canvas 390×1790) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L17b_2_grifos_e_clube@3x.png` · `docs/design/medicao/projeto/png/redline/L17b_2_grifos_e_clube_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/017b_detalhes_ebook_390x1790@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_017b_detalhes_ebook.json` · `test/reference/projeto/reference_layout_017b_detalhes_ebook.dart` (`kRef17b`).
> Arquivos sugeridos: `lib/features/library/presentation/details/details_highlights_section.dart`, `lib/features/library/presentation/details/club_meeting_card.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

E-book: "Seus grifos" com "Ver os 12", um grifo do leitor ("…olhos de cigana oblíqua e dissimulada.", pág. 121, em amarelo) — sem o botão de fotografar — e o cartão-ingresso do próximo encontro do clube (QUI 24 SET · 20h).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{halo}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`.

```html
<section aria-label="Grifos e clube" style="margin-top: 30px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Seus grifos</h2><a href="#" style="font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px; white-space: nowrap;">Ver os 12</a></div>
  <figure style="margin: 12px 0 0; padding: 16px 16px 14px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <blockquote style="margin: 0; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 21px; line-height: 1.35;"><span style="background: linear-gradient(transparent 52%, #FED170 52%, #FED170 92%, transparent 92%); -webkit-box-decoration-break: clone; box-decoration-break: clone;">“…olhos de cigana oblíqua e dissimulada.”</span></blockquote>
    <figcaption style="margin-top: 10px; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 700; color: #6F665B;">pág. 121 · grifado em amarelo</figcaption>
  </figure>


  <a href="#" aria-label="Próximo encontro do clube Leitoras de Capitu" style="margin-top: 16px; display: flex; align-items: stretch; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden;">
    <span style="width: 84px; flex-shrink: 0; padding: 12px 0; background: #FFC1C6; border-right: 1.5px dashed #1A1714; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 1px;">
      <span style="font-size: 11px; font-weight: 800; letter-spacing: 1px;">QUI</span>
      <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1;">24</span>
      <span style="font-size: 11px; font-weight: 800; letter-spacing: 1px;">SET · 20h</span>
    </span>
    <span style="min-width: 0; flex-grow: 1; padding: 12px 14px;">
      <span style="display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B;">LEITORAS DE CAPITU</span>
      <span style="display: block; margin-top: 2px; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Encontro até o cap. 50</span>
      <span style="display: block; margin-top: 4px; font-size: 12.5px; font-weight: 600; color: #3E3832;">Grupo 54% · você 62%</span>
    </span>
  </a>
</section>
```

## Especificação pixel a pixel

Seção `d17b.highlights` — retângulo absoluto no canvas 390×1790: **x=20, y=1494.07, w=350, h=221.76**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `d17b.highlights` | box | 0 | 0 | 350 | 221.76 | `margin-top: 30px` |  |
| 2 | `d17b.highlights.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 3 | `d17b.highlights.title` ±1 | text | 0 | 0 | 106.27 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 4 | `d17b.highlights.seeAll` ±1 | text | 295.44 | 6.25 | 54.56 | 15.6 | `font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px; white-space: nowrap` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 5 | `d17b.highlights.quote` | box | 0 | 36 | 350 | 86.36 | `margin: 12px 0 0; padding: 16px 16px 14px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 6 | `d17b.highlights.quote.text` | box | 17.5 | 53.5 | 315 | 28.35 | `margin: 0; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 21px; line-height: 1.35` | Instrument Serif itálico 21/28.35px peso 400 ls normal #1A1714 |
| 7 | `d17b.highlights.quote.text.mark` ±1 | inline | 17.5 | 54.02 | 314.75 | 27.3 | `background: linear-gradient(transparent 52%, #FED170 52%, #FED170 92%, transparent 92%); -webkit-box-decoration-break: clone; box-decoration-break: clone` | Instrument Serif itálico 21/28.35px peso 400 ls normal #1A1714 |
| 8 | `d17b.highlights.quote.caption` | text | 17.5 | 91.85 | 315 | 15.01 | `margin-top: 10px; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 700; color: #6F665B` | Figtree 12.5/normal peso 700 ls normal #6F665B |
| 9 | `d17b.highlights.club` | box | 0 | 138.36 | 350 | 83.4 | `margin-top: 16px; display: flex; align-items: stretch; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden` |  |
| 10 | `d17b.highlights.club.date` | box | 1.5 | 139.86 | 85.5 | 80.4 | `width: 84px; flex-shrink: 0; padding: 12px 0; background: #FFC1C6; border-right: 1.5px dashed #1A1714; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 1px` |  |
| 11 | `d17b.highlights.club.date.weekday` ±1 | text | 32.14 | 151.86 | 22.71 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1px` | Figtree 11/normal peso 800 ls 1px #1A1714 |
| 12 | `d17b.highlights.club.date.day` ±1 | text | 26.2 | 166.06 | 34.61 | 28 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1` | Bricolage (opsz 28) 28/28px peso 800 ls normal #1A1714 |
| 13 | `d17b.highlights.club.date.monthTime` ±1 | text | 15.16 | 195.06 | 56.69 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1px` | Figtree 11/normal peso 800 ls 1px #1A1714 |
| 14 | `d17b.highlights.club.textBlock` | box | 87 | 139.86 | 261.5 | 80.4 | `min-width: 0; flex-grow: 1; padding: 12px 14px` |  |
| 15 | `d17b.highlights.club.kicker` | text | 101 | 151.86 | 233.5 | 13.2 | `display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.1px #6F665B |
| 16 | `d17b.highlights.club.title` | text | 101 | 167.06 | 233.5 | 18.85 | `display: block; margin-top: 2px; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 17 | `d17b.highlights.club.meta` | text | 101 | 189.91 | 233.5 | 15.01 | `display: block; margin-top: 4px; font-size: 12.5px; font-weight: 600; color: #3E3832` | Figtree 12.5/normal peso 600 ls normal #3E3832 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17b.highlights.title` | 1 | Seus grifos | 18.6 | 0 | 106.27 | 106.27 |
| `d17b.highlights.seeAll` | 1 | Ver os 12 | 18.6 | 295.44 | 350 | 54.56 |
| `d17b.highlights.quote.text` *(composto)* | 1 | “…olhos de cigana oblíqua e dissimulada.” | 74.81 | 17.5 | 332.25 | 314.75 |
| `d17b.highlights.quote.caption` | 1 | pág. 121 · grifado em amarelo | 103.73 | 17.5 | 183.84 | 166.34 |
| `d17b.highlights.club.date.weekday` | 1 | QUI | 162.31 | 32.14 | 54.86 | 22.72 |
| `d17b.highlights.club.date.day` | 1 | 24 | 189.3 | 26.2 | 60.8 | 34.6 |
| `d17b.highlights.club.date.monthTime` | 1 | SET · 20h | 205.51 | 15.16 | 71.84 | 56.68 |
| `d17b.highlights.club.kicker` | 1 | LEITORAS DE CAPITU | 162.31 | 101 | 233.53 | 132.53 |
| `d17b.highlights.club.title` | 1 | Encontro até o cap. 50 | 181.56 | 101 | 252.87 | 151.87 |
| `d17b.highlights.club.meta` | 1 | Grupo 54% · você 62% | 201.79 | 101 | 228.97 | 127.97 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Seus grifos" Bricolage 20/800 e "Ver os 12" 13/800 sublinhado (offset 3), `nowrap`, na mesma baseline.
2. Grifo igual ao da 17 (padding 16/16/14, raio 20), a citação em 1 linha; a legenda sem ícone: "pág. 121 · grifado em amarelo" 12,5/700 `#6F665B`.
3. Encontro, 16 abaixo: `align-items: stretch`, raio 20, `#FFFAF1`, sombra 3/3, `overflow: hidden`. A data à esquerda: 84 de largura, `#FFC1C6`, borda direita 1,5 `dashed`, "QUI" 11/800 ls 1, "24" Bricolage 28/800 `lh 1` e "SET · 20h" 11/800. À direita (padding 12/14): "LEITORAS DE CAPITU" 11/800 ls 1,1 `#6F665B`, "Encontro até o cap. 50" 14,5/800 e, 4 abaixo, "Grupo 54% · você 62%" 12,5/600 `#3E3832`.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A cor do marca-texto é a do grifo ("grifado em amarelo"): no app, a cor real da anotação (as 4 do leitor), e a legenda diz a cor.
- A borda tracejada entre a data e o texto é vertical: pintor de tracejado.
- Fio de navalha em `d17b.highlights.quote.text` linha 1 «“…olhos de cigana oblíqua e dissimulada.”»: sobra 0.25 px · sem palavra seguinte (D-275: a linha única quebra se crescer).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_017b_detalhes_ebook_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_017b_detalhes_ebook_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `d17b.highlights` |  | Grifos e clube |  |
| `d17b.highlights.club` |  | Próximo encontro do clube Leitoras de Capitu |  |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `d17b.highlights.quote` | NeoBox |  |
| `d17b.highlights.quote.text.mark` | TextSpan dentro do AppText.rich do pai |  |
| `d17b.highlights.club` | NeoBox |  |
| `d17b.highlights.club.date` | NeoBox |  |

## Interações

- Ver os 12 → os grifos do livro (a tela 25).
- Grifo → o trecho no leitor (`AppRoutes.leitor` com `goTo`, G19).
- Cartão do encontro → o Encontro do clube (70), da T10: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T14 (ROTEIRO §2b).

## Dados

- O grifo mostrado é o mais recente do livro, com a página e a cor; "12" = as anotações do livro.
- O encontro aparece quando um clube da pessoa lê este livro e tem encontro marcado: o dado já existe (`ClubCard.nextMeeting`, os clubes da G); "Grupo 54% · você 62%" = o progresso médio do clube e o seu.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L17b.1** Seus grifos com Ver os 12
- **L17b.2** Grifo do leitor
- **L17b.3** Cartão do encontro do clube
- **L17b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('d17b.highlights'), todos os ids de `kRef17b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/017b_detalhes_ebook_390x1790@3x.png` no recorte da fase (y 1486.07–1723.83) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef17bw360` e `kRef17bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L17b.1 Seus grifos com Ver os 12
- [ ] L17b.2 Grifo do leitor
- [ ] L17b.3 Cartão do encontro do clube
- [ ] L17b.4 Verificação + relatório
- [ ] Geometria 16/16 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
