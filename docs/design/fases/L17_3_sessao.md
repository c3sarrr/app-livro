# FASE L17 — Detalhes (livro físico) — cartão da sessão de leitura (cronômetro e página opcional)

> Tela 17 · prancha `017_detalhes_fisico` (17 · Detalhes do livro — físico (Brás Cubas), canvas 390×1940) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L17_3_sessao@3x.png` · `docs/design/medicao/projeto/png/redline/L17_3_sessao_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_017_detalhes_fisico.json` · `test/reference/projeto/reference_layout_017_detalhes_fisico.dart` (`kRef17`).
> Arquivos sugeridos: `lib/features/library/presentation/details/reading_session_card.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Livro físico: o cartão amarelo da sessão de leitura — o anel com os minutos de hoje (18 de 30), o total no livro (3 h 40 min em 6 sessões), o botão preto "Iniciar leitura" e a linha tracejada "Parou na pág. 74 · opcional" com "Atualizar". No papel o app conta minutos, não páginas (nota do design).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{halo}}` = padrão `#ABCF82`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- Physical book: a reading timer instead of page tracking -->
<section aria-label="Sessão de leitura" style="margin-top: 18px; padding: 16px; border-radius: 24px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box;">
  <div style="display: flex; align-items: center; gap: 14px;">
    <svg width="58" height="58" viewBox="0 0 46 46" aria-hidden="true" style="flex-shrink: 0;"><circle cx="23" cy="23" r="18" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5"></circle><circle cx="23" cy="23" r="13" fill="none" stroke="#EAD9A6" stroke-width="5"></circle><circle cx="23" cy="23" r="13" fill="none" stroke="#1A1714" stroke-width="5" stroke-linecap="round" stroke-dasharray="49 81.7" transform="rotate(-90 23 23)"></circle></svg>
    <div style="min-width: 0; flex-grow: 1;">
      <div style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.5px;">18 <span style="font-size: 15px; font-weight: 700; color: #3E3832;">de 30 min hoje</span></div>
      <div style="margin-top: 4px; font-size: 13px; font-weight: 600; color: #3E3832;">Neste livro: 3 h 40 min em 6 sessões</div>
    </div>
  </div>
  <button style="margin-top: 14px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
    <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#FED170" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path><path d="M12 2.5V6"></path><path d="m18.5 6.5 1.5-1.5"></path></svg>
    <span style="color: #F7F0E3;">Iniciar leitura</span>
  </button>
  <div style="margin-top: 10px; display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 10px 12px; border-radius: 16px; background: rgba(255,250,241,0.7); border: 1.5px dashed rgba(26,23,20,0.45);">
    <span style="min-width: 0; font-size: 13px; font-weight: 600; color: #3E3832; line-height: 1.35;">Parou na <strong style="font-weight: 800; color: #1A1714;">pág. 74</strong> <span style="color: #6F665B;">· opcional</span></span>
    <a href="#" style="flex-shrink: 0; height: 32px; padding: 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9"></path><path d="M16.4 3.6a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"></path></svg>Atualizar</a>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `d17.session` — retângulo absoluto no canvas 390×1940: **x=20, y=664.44, w=350, h=226**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `d17.session` | box | 0 | 0 | 350 | 226 | `margin-top: 18px; padding: 16px; border-radius: 24px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box` |  |
| 2 | `d17.session.top` | box | 17.5 | 17.5 | 315 | 58 | `display: flex; align-items: center; gap: 14px` |  |
| 3 | `d17.session.ring` | icon | 17.5 | 17.5 | 58 | 58 | `flex-shrink: 0` |  |
| 4 | `d17.session.textBlock` | box | 89.5 | 25.15 | 243 | 42.7 | `min-width: 0; flex-grow: 1` |  |
| 5 | `d17.session.today` | text | 89.5 | 25.15 | 243 | 23.1 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/23.1px peso 800 ls -0.5px #1A1714 |
| 6 | `d17.session.today.goal` ±1 | inline | 115.1 | 30.01 | 99.9 | 18 | `font-size: 15px; font-weight: 700; color: #3E3832` | Bricolage (opsz 15) 15/15.75px peso 700 ls -0.5px #3E3832 |
| 7 | `d17.session.total` | text | 89.5 | 52.25 | 243 | 15.6 | `margin-top: 4px; font-size: 13px; font-weight: 600; color: #3E3832` | Figtree 13/normal peso 600 ls normal #3E3832 |
| 8 | `d17.session.start` | box | 17.5 | 89.5 | 315 | 54 | `margin-top: 14px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 9 | `d17.session.start.icon` ±1 | icon | 110.21 | 106 | 21 | 21 | `—` |  |
| 10 | `d17.session.start.label` ±1 | text | 141.21 | 106.9 | 98.58 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 11 | `d17.session.page` | box | 17.5 | 153.5 | 315 | 55 | `margin-top: 10px; display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 10px 12px; border-radius: 16px; background: rgba(255,250,241,0.7); border: 1.5px dashed rgba(26,23,20,0.45)` |  |
| 12 | `d17.session.page.text` ±1 | text | 31 | 172.22 | 159.34 | 17.55 | `min-width: 0; font-size: 13px; font-weight: 600; color: #3E3832; line-height: 1.35` | Figtree 13/17.55px peso 600 ls normal #3E3832 |
| 13 | `d17.session.page.text.strong` ±1 | inline | 85.42 | 173.19 | 44.9 | 15.6 | `font-weight: 800; color: #1A1714` | Figtree 13/17.55px peso 800 ls normal #1A1714 |
| 14 | `d17.session.page.text.optional` ±1 | inline | 133.45 | 173.19 | 56.89 | 15.6 | `color: #6F665B` | Figtree 13/17.55px peso 600 ls normal #6F665B |
| 15 | `d17.session.page.update` ±1 | box+text | 219.47 | 165 | 99.53 | 32 | `flex-shrink: 0; height: 32px; padding: 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 16 | `d17.session.page.update.icon` ±1 | icon | 232.97 | 174 | 14 | 14 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17.session.today` *(composto)* | 1 | 18 de 30 min hoje | 43.96 | 89.5 | 215 | 125.5 |
| `d17.session.total` | 1 | Neste livro: 3 h 40 min em 6 sessões | 64.6 | 89.5 | 304.17 | 214.67 |
| `d17.session.start.label` | 1 | Iniciar leitura | 122.1 | 141.21 | 239.79 | 98.58 |
| `d17.session.page.text` *(composto)* | 1 | Parou na pág. 74 · opcional | 185.55 | 31 | 190.34 | 159.34 |
| `d17.session.page.update` | 1 | Atualizar | 185.38 | 252.98 | 305.5 | 52.52 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cartão 18 abaixo do status: padding 16, raio 24, `#FED170`, borda 1,5, sombra dura 4/4.
2. Linha de cima (gap 14): o anel SVG 58 (viewBox 46: disco `#FFFAF1` r 18 com borda 1,5; trilho r 13 `#EAD9A6` de traço 5; o arco preto `dasharray 49 81,7`, girado −90°: 60 % de 30 min); ao lado, "18" Bricolage 22/800 `lh 1,05` ls −0,5 + "de 30 min hoje" Figtree 15/700 `#3E3832` e, 4 abaixo, "Neste livro: 3 h 40 min em 6 sessões" 13/600 `#3E3832`.
3. "Iniciar leitura", 14 abaixo: 54 de altura, largura toda, `#1A1714`, o cronômetro 21 em `#FED170` + 16/800 `#F7F0E3`, gap 10.
4. Página, 10 abaixo: padding 10/12, raio 16, `rgba(255,250,241,.7)`, borda 1,5 `dashed rgba(26,23,20,.45)`; "Parou na" 13/600 `#3E3832` + "pág. 74" 800 `#1A1714` + "· opcional" `#6F665B`; "Atualizar" em pílula de 32, `#FFFAF1`, borda 1,5, lápis 14 + 12,5/800.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O arco é o `dasharray` (49 de 81,7 = 2π · 13) a partir do topo: no app, um pintor de arco com o ângulo minutos ÷ meta e a ponta redonda — não o `stroke-dasharray` do flutter_svg (D-285).
- A borda da página é `dashed` com cor translúcida: pintor de tracejado com o padrão da referência @3x.
- O "pág. 74" em 800 dentro do texto em 600: a caixa é do tamanho do texto (sobra 0, T13.4) — o `AppText.rich` com os três pesos, sem largura fixa.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_017_detalhes_fisico_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_017_detalhes_fisico_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `d17.session` |  | Sessão de leitura |  |
| `d17.session.ring` |  |  | aria-hidden=true |
| `d17.session.start.icon` |  |  | aria-hidden=true |
| `d17.session.page.update.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `d17.session` | NeoBox |  |
| `d17.session.ring` | CustomPainter (anel_sessao_livro) | stroke-dasharray = progresso (dasharray 49 de 81,7 = 2π·13 → 60 %, rotate(-90)): anel desenhado por CustomPainter com o valor real; o SVG é a referência do estado da prancha. |
| `d17.session.today.goal` | TextSpan dentro do AppText.rich do pai |  |
| `d17.session.start` | NeoBox |  |
| `d17.session.start.icon` | AppSvg(AppIconsBiblioteca.stopwatchAmarelo, size: 21) |  |
| `d17.session.page` | NeoBox |  |
| `d17.session.page.text.strong` | TextSpan dentro do AppText.rich do pai |  |
| `d17.session.page.text.optional` | TextSpan dentro do AppText.rich do pai |  |
| `d17.session.page.update` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.session.page.update.icon` | AppSvg(AppIconsBiblioteca.pencilLine, size: 14) |  |

## Interações

- Iniciar leitura → o cronômetro do livro de papel que já existe (T04: a mini-barra e a folha mínima); a tela do cronômetro (18) chega na T18.
- Atualizar → a página onde parou: a prancha não desenha o campo. A página é dado do produto (D-243 a: o mínimo da D-23, como a página da folha mínima da T04) — confirmar na pergunta da T14.

## Dados

- "18 de 30 min hoje" = os minutos de hoje (papel e e-book) e a meta do dia; "Neste livro" = a soma das sessões deste livro e quantas são (3 h 40 min em 6, a revisão de consistência); "pág. 74" = a última página anotada (opcional).
- Livro sem página anotada: a linha não tem prancha para esse caso — o texto é pergunta da T14.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L17.1** Cartão com o anel da meta de hoje
- **L17.2** Iniciar leitura ligado ao cronômetro da T04
- **L17.3** Página opcional e Atualizar
- **L17.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('d17.session'), todos os ids de `kRef17.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@3x.png` no recorte da fase (y 656.44–898.44) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef17w360` e `kRef17w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L17.1 Cartão com o anel da meta de hoje
- [ ] L17.2 Iniciar leitura ligado ao cronômetro da T04
- [ ] L17.3 Página opcional e Atualizar
- [ ] L17.4 Verificação + relatório
- [ ] Geometria 13/13 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
