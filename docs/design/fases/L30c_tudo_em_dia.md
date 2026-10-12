# FASE L30c — Notificações, tudo em dia — o topo (marcar como lido apagado), o desenho, o texto, Ajustar lembretes e o lembrete marcado

> Tela 30c · prancha `030c_notificacoes_vazia` (30c · Notificações — tudo em dia, canvas 390×844) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L30c_tudo_em_dia@3x.png` · `docs/design/medicao/projeto/png/redline/L30c_tudo_em_dia_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/030c_notificacoes_vazia_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_030c_notificacoes_vazia.json` · `test/reference/projeto/reference_layout_030c_notificacoes_vazia.dart` (`kRef30c`).
> Arquivos sugeridos: `lib/features/notifications/presentation/notifications_empty.dart`, `lib/features/notifications/presentation/notifications_top_bar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Notificações, tudo em dia (30c): o topo com o "marcar tudo como lido" apagado, o desenho do sininho dormindo em cima do livro, "Tudo em dia.", o que vai aparecer ali, "Ajustar lembretes" e o lembrete marcado para 21:30.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="position: absolute; left: 16px; right: 16px; top: 54px; display: flex; justify-content: space-between; gap: 8px;">
  <a href="#" aria-label="Voltar" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg></a>
  <span style="display: flex; gap: 8px;">
    <button aria-label="Marcar tudo como lido" disabled style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; opacity: 0.35;"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m2 12.5 4.5 4.5L15 8.5"></path><path d="m10.5 16.5.5.5L21.5 6.5"></path></svg></button>
    <a href="#" aria-label="Ajustes de lembretes e avisos" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"></path></svg></a>
  </span>
</div>

<!-- sticker: a quiet bell resting on a book -->
<svg aria-hidden="true" width="230" height="200" viewBox="0 0 230 200" style="display: block; margin: 34px auto 0; overflow: visible;">
  <rect x="34" y="138" width="160" height="34" rx="6" fill="#1A1714" transform="translate(5 5)"></rect>
  <rect x="34" y="138" width="160" height="34" rx="6" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.6"></rect>
  <path d="M46 146h136M46 155h136M46 164h136" stroke="#FFFAF1" stroke-width="2" stroke-linecap="round" opacity="0.8"></path>
  <path d="M34 150h-6M34 160h-6" stroke="#1A1714" stroke-width="1.6"></path>
  <g transform="rotate(-10 114 96)">
    <path d="M78 132c6-6 8-16 8-36a28 28 0 0 1 56 0c0 20 2 30 8 36z" fill="#1A1714" transform="translate(4 4)"></path>
    <path d="M78 132c6-6 8-16 8-36a28 28 0 0 1 56 0c0 20 2 30 8 36z" fill="#FED170" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path>
    <path d="M104 132a10 10 0 0 0 20 0" fill="#FED170" stroke="#1A1714" stroke-width="1.6"></path>
    <circle cx="114" cy="64" r="5" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.6"></circle>
    <path d="M100 100q4 4 8 0M120 100q4 4 8 0" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path>
  </g>
  <text x="168" y="62" font-family="'Bricolage Grotesque', sans-serif" font-weight="800" font-size="22" fill="#1A1714">z</text>
  <text x="184" y="44" font-family="'Bricolage Grotesque', sans-serif" font-weight="800" font-size="16" fill="#1A1714">z</text>
  <text x="196" y="30" font-family="'Bricolage Grotesque', sans-serif" font-weight="800" font-size="12" fill="#1A1714">z</text>
  <g transform="translate(22 40) scale(1.05)"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFC1C6" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></g>
</svg>

<h2 style="margin: 22px 0 0; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1; letter-spacing: -0.7px;">Tudo em dia<span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 34px;">.</span></h2>

<p style="margin: 10px auto 0; max-width: 290px; text-align: center; font-size: 14.5px; font-weight: 600; line-height: 1.45; color: #5B544B; text-wrap: pretty;">Quando o clube conversar, uma enquete abrir ou você ganhar um selo, aparece aqui.</p>

<a href="#" style="margin: 24px auto 0; width: fit-content; height: 50px; padding: 0 20px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 15px; font-weight: 800;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"></path></svg>Ajustar lembretes</a>

<div style="margin-top: 30px; padding: 14px 16px; border-radius: 20px; border: 1.5px dashed #1A1714; display: flex; align-items: center; gap: 12px;">
  <span aria-hidden="true" style="position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path></svg></span>
  <span style="min-width: 0; flex-grow: 1; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;">Seu lembrete de leitura está marcado para <strong style="color: #1A1714; font-weight: 800;">21:30</strong>.</span>
</div>
```

## Especificação pixel a pixel

Seção `n30c.top` — retângulo absoluto no canvas 390×844: **x=16, y=54, w=358, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `n30c.top` | box | 0 | 0 | 358 | 48 | `position: absolute; left: 16px; right: 16px; top: 54px; display: flex; justify-content: space-between; gap: 8px` |  |
| 2 | `n30c.top.back` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `n30c.top.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |
| 4 | `n30c.top.actions` | box | 254 | 0 | 104 | 48 | `display: flex; gap: 8px` |  |
| 5 | `n30c.top.markRead` | box | 254 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; opacity: 0.35` |  |
| 6 | `n30c.top.markRead.icon` | icon | 267.5 | 13.5 | 21 | 21 | `—` |  |
| 7 | `n30c.top.settings` | box | 310 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 8 | `n30c.top.settings.icon` | icon | 324 | 14 | 20 | 20 | `—` |  |

Seção `n30c.illustration` — retângulo absoluto no canvas 390×844: **x=80, y=234.4, w=230, h=200**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 9 | `n30c.illustration` | icon | 0 | 0 | 230 | 200 | `display: block; margin: 34px auto 0; overflow: visible` |  |

Seção `n30c.empty` — retângulo absoluto no canvas 390×844: **x=16, y=456.4, w=358, h=160.05**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 10 | `n30c.empty.title` | text | 0 | 0 | 358 | 34 | `margin: 22px 0 0; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1; letter-spacing: -0.7px` | Bricolage (opsz 28) 28/28px peso 800 ls -0.7px #1A1714 |
| 11 | `n30c.empty.title.dot` ±1 | inline | 254.11 | -5.1 | 6.75 | 44.2 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 34px` | Instrument Serif itálico 34/34px peso 400 ls -0.7px #1A1714 |
| 12 | `n30c.empty.body` | text | 34 | 44 | 290 | 42.05 | `margin: 10px auto 0; max-width: 290px; text-align: center; font-size: 14.5px; font-weight: 600; line-height: 1.45; color: #5B544B; text-wrap: pretty` | Figtree 14.5/21.025px peso 600 ls normal #5B544B |
| 13 | `n30c.empty.cta` ±1 | box+text | 81.82 | 110.05 | 194.35 | 50 | `margin: 24px auto 0; width: fit-content; height: 50px; padding: 0 20px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 14 | `n30c.empty.cta.icon` ±1 | icon | 103.32 | 126.05 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30c.empty.title` *(composto)* | 1 | Tudo em dia. | 28.56 | 97.14 | 260.86 | 163.72 |
| `n30c.empty.body` | 1 | Quando o clube conversar, uma enquete | 59.58 | 46.29 | 311.71 | 265.42 |
| `n30c.empty.body` | 2 | abrir ou você ganhar um selo, aparece aqui. | 80.6 | 37.03 | 320.97 | 283.94 |
| `n30c.empty.cta` | 1 | Ajustar lembretes | 140.3 | 129.32 | 254.68 | 125.36 |

Seção `n30c.reminder` — retângulo absoluto no canvas 390×844: **x=16, y=646.45, w=358, h=75**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 15 | `n30c.reminder` | box | 0 | 0 | 358 | 75 | `margin-top: 30px; padding: 14px 16px; border-radius: 20px; border: 1.5px dashed #1A1714; display: flex; align-items: center; gap: 12px` |  |
| 16 | `n30c.reminder.icon` | box | 17.5 | 15.5 | 44 | 44 | `position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 17 | `n30c.reminder.icon.art` | icon | 28.5 | 26.5 | 22 | 22 | `—` |  |
| 18 | `n30c.reminder.text` | text | 73.5 | 18.6 | 267 | 37.8 | `min-width: 0; flex-grow: 1; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 19 | `n30c.reminder.text.time` ±1 | inline | 73.5 | 38.84 | 34.44 | 16.21 | `color: #1A1714; font-weight: 800` | Figtree 13.5/18.9px peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30c.reminder.text` *(composto)* | 1 | Seu lembrete de leitura está marcado para | 32.77 | 73.5 | 332.85 | 259.35 |
| `n30c.reminder.text` *(composto)* | 2 | 21:30. | 51.67 | 73.5 | 111.07 | 37.57 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O topo e o título da 30 (a tabela "Diferenças"); o marcar como lido com opacidade 0,35 (`disabled`).
2. O desenho 230 × 200 centrado, 34 abaixo do topo (`overflow: visible`, o livro com a sombra dura).
3. "Tudo em dia" Bricolage 28/800 ls −0,7 + o "." Instrument Serif 34, centrado, 22 abaixo; o texto 14,5/600 `lh 1,45` `#5B544B`, `max-width 290`, `text-wrap: pretty`, 10 abaixo.
4. "Ajustar lembretes" 24 abaixo: pílula de 50 com a largura do conteúdo (`fit-content`), padding 0/20, `#FFFAF1`, borda 1,5, sombra 2/2, a engrenagem 18 e 15/800.
5. O lembrete 30 abaixo: padding 14/16, raio 20, tracejado 1,5 preto, o quadrado 44 `#FED170` e "Seu lembrete de leitura está marcado para 21:30." 13,5/600 com o horário em 800.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O apagado é opacidade 0,35 que a referência não guarda (só a caixa): no app, `Opacity` no botão inteiro, com a semântica de desabilitado.
- A seção do vazio não tem contêiner (o desenho, o título, o texto, o botão e o lembrete soltos): a caixa é a união dos ids de topo.
- O desenho sai da própria caixa (`overflow: visible`): `Clip.none`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_030c_notificacoes_vazia_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_030c_notificacoes_vazia_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 30 (seções reutilizadas: headline)

Estas seções são as mesmas widgets da 30 (fases L30_1_topo_e_hoje, L30_2_semana); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 30.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `n30c.top.back` |  | Voltar |  |
| `n30c.top.back.icon` |  |  | aria-hidden=true |
| `n30c.top.markRead` |  | Marcar tudo como lido |  |
| `n30c.top.markRead.icon` |  |  | aria-hidden=true |
| `n30c.top.settings` |  | Ajustes de lembretes e avisos |  |
| `n30c.top.settings.icon` |  |  | aria-hidden=true |
| `n30c.illustration` |  |  | aria-hidden=true |
| `n30c.empty.cta.icon` |  |  | aria-hidden=true |
| `n30c.reminder.icon` |  |  | aria-hidden=true |
| `n30c.reminder.icon.art` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `n30c.top.back` | CircleIconButton / NeoBox circular |  |
| `n30c.top.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `n30c.top.markRead` | CircleIconButton / NeoBox circular |  |
| `n30c.top.markRead.icon` | AppSvg(AppIconsPerfil.checkDouble, size: 21) |  |
| `n30c.top.settings` | CircleIconButton / NeoBox circular |  |
| `n30c.top.settings.icon` | AppSvg(AppIconsPerfil.settings, size: 20) |  |
| `n30c.illustration` | AppSvg(AppIllustrationsPerfil.notificacoesVazia, size: 230×200) | tem `<text>` (os três "z" em Bricolage 800 22, 16 e 12): o flutter_svg desenharia o texto com a fonte do sistema → no app o AppSvg lê o desenho sem os textos e eles voltam em AppText nas mesmas posições (como as capas da Início, T03.7). |
| `n30c.empty.title.dot` | TextSpan dentro do AppText.rich do pai |  |
| `n30c.empty.cta` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `n30c.empty.cta.icon` | AppSvg(AppIconsPerfil.settings, size: 18) |  |
| `n30c.reminder` | NeoBox |  |
| `n30c.reminder.icon` | NeoBox |  |
| `n30c.reminder.icon.art` | AppSvg(AppIconsPerfil.stopwatchFino, size: 22) |  |
| `n30c.reminder.text.time` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Voltar → a tela anterior. Engrenagem e "Ajustar lembretes" → a 30b.
- Marcar tudo como lido → apagado (não responde; `onPressed: null`).

## Dados

- A 30c é o estado da 30 sem avisos (nenhum nos 30 dias): mesma rota, outro conteúdo. O lembrete mostra o horário de verdade; com o lembrete desligado, o texto não tem prancha — pergunta da T17.
- Com tudo lido, o sino da Início fica sem a bolinha coral (a nota do design).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L30c.1** Topo com o marcar como lido apagado
- **L30c.2** Desenho, título e texto
- **L30c.3** Ajustar lembretes e o lembrete
- **L30c.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('n30c.top', 'n30c.illustration', 'n30c.empty', 'n30c.reminder'), todos os ids de `kRef30c.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/030c_notificacoes_vazia_390x844@3x.png` no recorte da fase (y 46–729.45) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef30cw360` e `kRef30cw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L30c.1 Topo com o marcar como lido apagado
- [ ] L30c.2 Desenho, título e texto
- [ ] L30c.3 Ajustar lembretes e o lembrete
- [ ] L30c.4 Verificação + relatório
- [ ] Geometria 17/17 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
