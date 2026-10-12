# FASE L18 — Cronômetro — as etiquetas da meta e da sequência, Trecho/Pausar/Encerrar, anotar um pensamento e o aviso de bloquear a tela

> Tela 18 · prancha `018_cronometro` (18 · Cronômetro de leitura (livro físico), canvas 390×844) · executada na **T18** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L18_2_controles@3x.png` · `docs/design/medicao/projeto/png/redline/L18_2_controles_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/018_cronometro_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_018_cronometro.json` · `test/reference/projeto/reference_layout_018_cronometro.dart` (`kRef18`).
> Arquivos sugeridos: `lib/features/reading_session/presentation/timer/timer_screen.dart`, `lib/features/reading_session/presentation/timer/timer_controls.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Cronômetro (18), embaixo: as etiquetas "Faltam 4 min para a meta" e "12 dias", os três controles (Trecho, Pausar maior no meio, Encerrar), "Anotar um pensamento" tracejado e o aviso "Pode bloquear a tela: o tempo continua.".

---

## HTML literal da seção

Props do componente: `{{arc}}` = padrão `#FED170`.

```html
<!-- Encouragement, no pressure -->
<div style="margin-top: 18px; display: flex; gap: 8px; flex-wrap: wrap; justify-content: center;">
  <span style="height: 34px; padding: 0 13px 0 10px; border-radius: 999px; background: {{arc}}; border: 1.5px solid #F7F0E3; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 800; color: #1A1714;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"></circle><circle cx="12" cy="12" r="5"></circle><circle cx="12" cy="12" r="1.2" fill="#1A1714"></circle></svg>Faltam 4 min para a meta</span>
  <span style="height: 34px; padding: 0 12px 0 9px; border-radius: 999px; background: #FF552E; border: 1.5px solid #F7F0E3; box-sizing: border-box; display: inline-flex; align-items: center; gap: 5px; font-size: 13px; font-weight: 800; color: #1A1714;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.07-2.14-.22-4.05 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.15.43-2.29 1-3a2.5 2.5 0 0 0 2.5 2.5z"></path></svg>12 dias</span>
</div>

<!-- Controls -->
<div style="margin-top: auto; align-self: stretch; display: flex; align-items: flex-start; justify-content: space-between; padding: 0 6px;">
  <div style="width: 86px; display: flex; flex-direction: column; align-items: center; gap: 8px;">
    <button aria-label="Fotografar um trecho" style="width: 58px; height: 58px; padding: 0; border-radius: 50%; background: #2B2621; border: 1.5px solid rgba(247,240,227,0.85); box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3z"></path><circle cx="12" cy="13" r="3.5"></circle></svg></button>
    <span style="font-size: 12.5px; font-weight: 700; color: #B9AE9C;">Trecho</span>
  </div>
  <div style="width: 86px; display: flex; flex-direction: column; align-items: center; gap: 8px;">
    <button aria-label="Pausar" style="width: 86px; height: 86px; padding: 0; border-radius: 50%; background: #F7F0E3; border: none; box-shadow: 0 0 0 5px #3A332C; display: flex; align-items: center; justify-content: center;">
      <svg width="30" height="30" viewBox="0 0 24 24" aria-hidden="true"><rect x="5.5" y="4" width="4.5" height="16" rx="1.5" fill="#1A1714"></rect><rect x="14" y="4" width="4.5" height="16" rx="1.5" fill="#1A1714"></rect></svg>
    </button>
    <span style="font-size: 12.5px; font-weight: 700; color: #B9AE9C; color: #F7F0E3;">Pausar</span>
  </div>
  <div style="width: 86px; display: flex; flex-direction: column; align-items: center; gap: 8px;">
    <button aria-label="Encerrar sessão" style="width: 58px; height: 58px; padding: 0; border-radius: 50%; background: #2B2621; border: 1.5px solid rgba(247,240,227,0.85); box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="4" width="16" height="16" rx="3" fill="#F7F0E3"></rect></svg></button>
    <span style="font-size: 12.5px; font-weight: 700; color: #B9AE9C;">Encerrar</span>
  </div>
</div>

<div style="margin-top: 14px; display: flex; gap: 8px; justify-content: center;">
  <button style="height: 36px; padding: 0 14px 0 11px; border-radius: 999px; background: transparent; border: 1.5px dashed rgba(247,240,227,0.6); display: flex; align-items: center; gap: 7px; font-size: 13px; font-weight: 700; color: #F7F0E3;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9"></path><path d="M16.4 3.6a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"></path></svg>Anotar um pensamento</button>
</div>

<p style="margin: 14px 0 0; display: flex; align-items: center; gap: 7px; font-size: 12.5px; font-weight: 600; color: #8F8577;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#8F8577" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="4" y="11" width="16" height="10" rx="2"></rect><path d="M8 11V7a4 4 0 0 1 8 0v4"></path></svg>Pode bloquear a tela: o tempo continua.</p>
```

## Especificação pixel a pixel

Seção `cr18.chips` — retângulo absoluto no canvas 390×844: **x=47.92, y=529, w=294.17, h=34**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `cr18.chips` ±1 | box | 0 | 0 | 294.17 | 34 | `margin-top: 18px; display: flex; gap: 8px; flex-wrap: wrap; justify-content: center` |  |
| 2 | `cr18.chips.goal` ±1 | box+text | 0 | 0 | 200.31 | 34 | `height: 34px; padding: 0 13px 0 10px; border-radius: 999px; background: {{arc}} (padrão #FED170); border: 1.5px solid #F7F0E3; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 800; color: #1A1714` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 3 | `cr18.chips.goal.icon` ±1 | icon | 11.5 | 9 | 16 | 16 | `—` |  |
| 4 | `cr18.chips.streak` ±1 | box+text | 208.3 | 0 | 85.86 | 34 | `height: 34px; padding: 0 12px 0 9px; border-radius: 999px; background: #FF552E; border: 1.5px solid #F7F0E3; box-sizing: border-box; display: inline-flex; align-items: center; gap: 5px; font-size: 13px; font-weight: 800; color: #1A1714` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 5 | `cr18.chips.streak.icon` ±1 | icon | 218.8 | 9 | 16 | 16 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `cr18.chips.goal` | 1 | Faltam 4 min para a meta | 21.55 | 33.5 | 185.8 | 152.3 |
| `cr18.chips.streak` | 1 | 12 dias | 21.55 | 239.8 | 280.66 | 40.86 |

Seção `cr18.controls` — retângulo absoluto no canvas 390×844: **x=20, y=621.98, w=350, h=109.01**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `cr18.controls` | box | 0 | 0 | 350 | 109.01 | `margin-top: auto; align-self: stretch; display: flex; align-items: flex-start; justify-content: space-between; padding: 0 6px` |  |
| 7 | `cr18.controls.photo` | box | 6 | 0 | 86 | 81.01 | `width: 86px; display: flex; flex-direction: column; align-items: center; gap: 8px` |  |
| 8 | `cr18.controls.photo.button` | box | 20 | 0 | 58 | 58 | `width: 58px; height: 58px; padding: 0; border-radius: 50%; background: #2B2621; border: 1.5px solid rgba(247,240,227,0.85); box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 9 | `cr18.controls.photo.icon` | icon | 38 | 18 | 22 | 22 | `—` |  |
| 10 | `cr18.controls.photo.label` ±1 | text | 29.15 | 66 | 39.7 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #B9AE9C` | Figtree 12.5/normal peso 700 ls normal #B9AE9C |
| 11 | `cr18.controls.pause` | box | 132 | 0 | 86 | 109.01 | `width: 86px; display: flex; flex-direction: column; align-items: center; gap: 8px` |  |
| 12 | `cr18.controls.pause.button` | box | 132 | 0 | 86 | 86 | `width: 86px; height: 86px; padding: 0; border-radius: 50%; background: #F7F0E3; border: none; box-shadow: 0 0 0 5px #3A332C; display: flex; align-items: center; justify-content: center` |  |
| 13 | `cr18.controls.pause.icon` | icon | 160 | 28 | 30 | 30 | `—` |  |
| 14 | `cr18.controls.pause.label` ±1 | text | 155.8 | 94 | 38.4 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #B9AE9C; color: #F7F0E3` | Figtree 12.5/normal peso 700 ls normal #F7F0E3 |
| 15 | `cr18.controls.end` | box | 258 | 0 | 86 | 81.01 | `width: 86px; display: flex; flex-direction: column; align-items: center; gap: 8px` |  |
| 16 | `cr18.controls.end.button` | box | 272 | 0 | 58 | 58 | `width: 58px; height: 58px; padding: 0; border-radius: 50%; background: #2B2621; border: 1.5px solid rgba(247,240,227,0.85); box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 17 | `cr18.controls.end.icon` | icon | 292 | 20 | 18 | 18 | `—` |  |
| 18 | `cr18.controls.end.label` ±1 | text | 276.46 | 66 | 49.09 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #B9AE9C` | Figtree 12.5/normal peso 700 ls normal #B9AE9C |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `cr18.controls.photo.label` | 1 | Trecho | 77.88 | 29.15 | 68.85 | 39.7 |
| `cr18.controls.pause.label` | 1 | Pausar | 105.88 | 155.8 | 194.2 | 38.4 |
| `cr18.controls.end.label` | 1 | Encerrar | 77.88 | 276.46 | 325.54 | 49.08 |

Seção `cr18.note` — retângulo absoluto no canvas 390×844: **x=99.97, y=744.99, w=190.06, h=36**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 19 | `cr18.note` ±1 | box | 0 | 0 | 190.06 | 36 | `margin-top: 14px; display: flex; gap: 8px; justify-content: center` |  |
| 20 | `cr18.note.button` ±1 | box+text | 0 | 0 | 190.06 | 36 | `height: 36px; padding: 0 14px 0 11px; border-radius: 999px; background: transparent; border: 1.5px dashed rgba(247,240,227,0.6); display: flex; align-items: center; gap: 7px; font-size: 13px; font-weight: 700; color: #F7F0E3` | Figtree 13/normal peso 700 ls normal #F7F0E3 |
| 21 | `cr18.note.button.icon` ±1 | icon | 12.5 | 10.5 | 15 | 15 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `cr18.note.button` | 1 | Anotar um pensamento | 22.55 | 34.5 | 174.56 | 140.06 |

Seção `cr18.lockHint` — retângulo absoluto no canvas 390×844: **x=71.81, y=794.99, w=246.38, h=15.01**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 22 | `cr18.lockHint` ±1 | text | 0 | 0 | 246.38 | 15.01 | `margin: 14px 0 0; display: flex; align-items: center; gap: 7px; font-size: 12.5px; font-weight: 600; color: #8F8577` | Figtree 12.5/normal peso 600 ls normal #8F8577 |
| 23 | `cr18.lockHint.icon` ±1 | icon | 0 | 0.5 | 14 | 14 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `cr18.lockHint` | 1 | Pode bloquear a tela: o tempo continua. | 11.88 | 21 | 246.38 | 225.38 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Etiquetas 18 abaixo do relógio (flex-wrap, gap 8, centradas): pílulas de 34, borda 1,5 creme, 13/800 preto — a da meta em `{{arc}}` com o alvo 16, a da sequência coral com o fogo 16.
2. Controles no fundo (`margin-top: auto`, padding 0/6, `space-between`, alinhados pelo topo): colunas de 86 com o botão e o rótulo 12,5/700 `#B9AE9C`, 8 abaixo; Trecho e Encerrar com o círculo 58 escuro (a câmera 22; o quadrado creme 18); Pausar com o círculo 86 creme, sem borda, o anel de 5 `#3A332C` (sombra) e as duas barras pretas 30, com o rótulo creme.
3. "Anotar um pensamento" 14 abaixo: pílula de 36, padding 0/14/0/11, sem fundo, tracejado 1,5 creme a 0,6, o lápis 15 e 13/700 creme.
4. O aviso 14 abaixo: 12,5/600 `#8F8577` com o cadeado 14 (gap 7); o aviso termina 34 acima do fundo.
5. A tela é escura (o fundo da prancha, para não brilhar ao lado do livro de papel — a nota do design): os botões `#2B2621` com a borda 1,5 creme a 0,85, os textos `#F7F0E3` e os secundários `#B9AE9C`.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- Os três controles se alinham pelo topo, com 40 entre eles e o do meio maior (86 contra 58): os rótulos ficam em alturas diferentes, como na prancha.
- O anel do Pausar é `box-shadow` (0 0 0 5): fica fora do círculo de 86 e não ocupa espaço.
- As etiquetas quebram com `flex-wrap`, mas sobram 55,8 na fileira: nenhum fio de navalha (D-278).
- As três cores com nome da prancha (`meta.props`): `arc` #FED170 (o arco do anel e a etiqueta da meta), `goal` #ABCF82 (o selo e o cartão de hoje) e `brand` #B6ACE4 (o anel de 4 em volta do campo da página) — no app vêm dos tokens.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_018_cronometro_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_018_cronometro_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `cr18.chips.goal.icon` |  |  | aria-hidden=true |
| `cr18.chips.streak.icon` |  |  | aria-hidden=true |
| `cr18.controls.photo.button` |  | Fotografar um trecho |  |
| `cr18.controls.photo.icon` |  |  | aria-hidden=true |
| `cr18.controls.pause.button` |  | Pausar |  |
| `cr18.controls.pause.icon` |  |  | aria-hidden=true |
| `cr18.controls.end.button` |  | Encerrar sessão |  |
| `cr18.controls.end.icon` |  |  | aria-hidden=true |
| `cr18.note.button.icon` |  |  | aria-hidden=true |
| `cr18.lockHint.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `cr18.chips.goal` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `cr18.chips.goal.icon` | AppSvg(AppIconsCronometro.target, size: 16) |  |
| `cr18.chips.streak` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `cr18.chips.streak.icon` | AppSvg(AppIconsCronometro.flameChip, size: 16) |  |
| `cr18.controls.photo.button` | CircleIconButton / NeoBox circular |  |
| `cr18.controls.photo.icon` | AppSvg(AppIconsCronometro.cameraPapel, size: 22) |  |
| `cr18.controls.pause.button` | CircleIconButton / NeoBox circular |  |
| `cr18.controls.pause.icon` | AppSvg(AppIconsInicio.pauseInk, size: 30) |  |
| `cr18.controls.end.button` | CircleIconButton / NeoBox circular |  |
| `cr18.controls.end.icon` | AppSvg(AppIconsCronometro.stopPapel, size: 18) |  |
| `cr18.note.button` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `cr18.note.button.icon` | AppSvg(AppIconsCronometro.pencilNotePapel, size: 15) |  |
| `cr18.lockHint.icon` | AppSvg(AppIconsCronometro.lockCinza, size: 14) |  |

## Interações

- Pausar → pausa (o rótulo vira "Continuar" e o ícone o play — sem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T18 (ROTEIRO §2b)); o mesmo `toggle` do controlador da T04.
- Encerrar → abre o Fim da sessão (18b) por cima, com o tempo parado.
- Trecho → a câmera (`image_picker`) para fotografar o trecho do livro de papel; onde a foto fica (um grifo de foto, sem prancha) é pergunta da T18.
- Anotar um pensamento → a nota da sessão: a folha não tem prancha aqui — sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T18 (ROTEIRO §2b) (ou a folha de nota do leitor, `note_sheet.dart`, se a T18 decidir).

## Dados

- "Faltam N min para a meta" = a meta diária − os minutos de hoje (some ou muda quando bate: o texto da meta batida durante a sessão não tem prancha — pergunta da T18); "12 dias" = a sequência.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L18.1** Etiquetas da meta e da sequência
- **L18.2** Os três controles
- **L18.3** Anotar e o aviso de bloquear
- **L18.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('cr18.chips', 'cr18.controls', 'cr18.note', 'cr18.lockHint'), todos os ids de `kRef18.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/018_cronometro_390x844@3x.png` no recorte da fase (y 521–818) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef18w360` e `kRef18w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L18.1 Etiquetas da meta e da sequência
- [ ] L18.2 Os três controles
- [ ] L18.3 Anotar e o aviso de bloquear
- [ ] L18.4 Verificação + relatório
- [ ] Geometria 23/23 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
