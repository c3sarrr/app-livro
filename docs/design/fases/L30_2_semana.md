# FASE L30 — Notificações — os avisos da semana e a nota do fim

> Tela 30 · prancha `030_notificacoes` (30 · Notificações (sino da Início), canvas 390×1180) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L30_2_semana@3x.png` · `docs/design/medicao/projeto/png/redline/L30_2_semana_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/030_notificacoes_390x1180@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_030_notificacoes.json` · `test/reference/projeto/reference_layout_030_notificacoes.dart` (`kRef30`).
> Arquivos sugeridos: `lib/features/notifications/presentation/notifications_screen.dart`, `lib/features/notifications/presentation/notification_tile.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Notificações (30), embaixo: os avisos de Esta semana (a enquete com "Votar", o pedido aceito do Rafa com "Seguir de volta", Ana entrou no clube), todos lidos, e a nota do fim ("Avisos com mais de 30 dias somem sozinhos.").

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<h2 style="margin: 26px 0 10px; display: flex; align-items: center; gap: 10px; font-size: 11.5px; font-weight: 800; letter-spacing: 1.3px; color: #6F665B;">ESTA SEMANA<span aria-hidden="true" style="flex-grow: 1; border-top: 1.5px dashed #CFC3AE;"></span></h2>

<ul>
  <li><a href="#" style="padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start;">
    <span aria-hidden="true" style="position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 20V10M12 20V4M19 20v-7"></path></svg></span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: flex; align-items: baseline; gap: 8px;"><span style="min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Enquete: próximo livro do clube</span><span style="display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap;">sex</span></span>
      <span style="display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;">8 de 11 já votaram. Falta o seu — fecha terça, 20h.</span><span style="margin-top: 10px; height: 36px; padding: 0 14px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 13px; font-weight: 800; background: #FFFAF1; color: #1A1714;">Votar</span>
    </span>
  </a></li>
  <li><a href="#" style="padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start;">
    <span aria-hidden="true" style="position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="8" r="3.6"></circle><path d="M5 20c.8-3.8 3.6-6 7-6s6.2 2.2 7 6"></path></svg></span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: flex; align-items: baseline; gap: 8px;"><span style="min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Você aceitou o pedido do Rafa</span><span style="display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap;">qui</span></span>
      <span style="display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;">Lê muita ficção científica e poesia.</span><span style="margin-top: 10px; height: 36px; padding: 0 14px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 13px; font-weight: 800; background: #FFFAF1; color: #1A1714;">Seguir de volta</span>
    </span>
  </a></li>
  <li><a href="#" style="padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start;">
    <span aria-hidden="true" style="position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg></span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: flex; align-items: baseline; gap: 8px;"><span style="min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Ana entrou em Leitoras de Capitu</span><span style="display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap;">ter</span></span>
      <span style="display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;">Agora são 11 pessoas no clube.</span>
    </span>
  </a></li>
</ul>

<p style="margin: 22px 8px 0; text-align: center; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #8A8073;">Avisos com mais de 30 dias somem sozinhos.</p>
```

## Especificação pixel a pixel

Seção `n30.week` — retângulo absoluto no canvas 390×1180: **x=16, y=660.66, w=358, h=335.81**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `n30.week.label` | text | 0 | 0 | 358 | 13.81 | `margin: 26px 0 10px; display: flex; align-items: center; gap: 10px; font-size: 11.5px; font-weight: 800; letter-spacing: 1.3px; color: #6F665B` | Figtree 11.5/normal peso 800 ls 1.3px #6F665B |
| 2 | `n30.week.label.rule` ±1 | box | 104.6 | 6.16 | 253.4 | 1.5 | `flex-grow: 1; border-top: 1.5px dashed #CFC3AE` |  |
| 3 | `n30.week.list` | box | 0 | 23.81 | 358 | 312 | `—` |  |
| 4 | `n30.week.list.item1` | box | 0 | 23.81 | 358 | 130.85 | `—` |  |
| 5 | `n30.week.list.item1.card` | box | 0 | 23.81 | 358 | 130.85 | `padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start` |  |
| 6 | `n30.week.list.item1.icon` | box | 12 | 35.81 | 44 | 44 | `position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 7 | `n30.week.list.item1.icon.art` | icon | 23.5 | 47.31 | 21 | 21 | `—` |  |
| 8 | `n30.week.list.item1.textBlock` | box | 68 | 35.81 | 278 | 105.65 | `min-width: 0; flex-grow: 1` |  |
| 9 | `n30.week.list.item1.head` | box | 68 | 35.81 | 278 | 18.85 | `display: flex; align-items: baseline; gap: 8px` |  |
| 10 | `n30.week.list.item1.title` ±1 | text | 68 | 35.81 | 251.54 | 18.85 | `min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 11 | `n30.week.list.item1.time` ±1 | text | 327.54 | 38.91 | 18.46 | 14.4 | `display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #8A8073 |
| 12 | `n30.week.list.item1.body` | text | 68 | 57.66 | 278 | 37.8 | `display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 13 | `n30.week.list.item1.action` ±1 | box+text | 68 | 105.46 | 65.03 | 36 | `margin-top: 10px; height: 36px; padding: 0 14px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 13px; font-weight: 800; background: #FFFAF1; color: #1A1714` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 14 | `n30.week.list.item2` | box | 0 | 154.66 | 358 | 111.95 | `—` |  |
| 15 | `n30.week.list.item2.card` | box | 0 | 154.66 | 358 | 111.95 | `padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start` |  |
| 16 | `n30.week.list.item2.icon` | box | 12 | 166.66 | 44 | 44 | `position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 17 | `n30.week.list.item2.icon.art` | icon | 23.5 | 178.16 | 21 | 21 | `—` |  |
| 18 | `n30.week.list.item2.textBlock` | box | 68 | 166.66 | 278 | 86.75 | `min-width: 0; flex-grow: 1` |  |
| 19 | `n30.week.list.item2.head` | box | 68 | 166.66 | 278 | 18.85 | `display: flex; align-items: baseline; gap: 8px` |  |
| 20 | `n30.week.list.item2.title` ±1 | text | 68 | 166.66 | 252.94 | 18.85 | `min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 21 | `n30.week.list.item2.time` ±1 | text | 328.94 | 169.76 | 17.06 | 14.4 | `display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #8A8073 |
| 22 | `n30.week.list.item2.body` | text | 68 | 188.51 | 278 | 18.9 | `display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 23 | `n30.week.list.item2.action` ±1 | box+text | 68 | 217.41 | 121.78 | 36 | `margin-top: 10px; height: 36px; padding: 0 14px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 13px; font-weight: 800; background: #FFFAF1; color: #1A1714` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 24 | `n30.week.list.item3` | box | 0 | 266.61 | 358 | 69.2 | `—` |  |
| 25 | `n30.week.list.item3.card` | box | 0 | 266.61 | 358 | 69.2 | `padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start` |  |
| 26 | `n30.week.list.item3.icon` | box | 12 | 278.61 | 44 | 44 | `position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 27 | `n30.week.list.item3.icon.art` | icon | 23 | 289.61 | 22 | 22 | `—` |  |
| 28 | `n30.week.list.item3.textBlock` | box | 68 | 278.61 | 278 | 40.75 | `min-width: 0; flex-grow: 1` |  |
| 29 | `n30.week.list.item3.head` | box | 68 | 278.61 | 278 | 18.85 | `display: flex; align-items: baseline; gap: 8px` |  |
| 30 | `n30.week.list.item3.title` ±1 | text | 68 | 278.61 | 254.09 | 18.85 | `min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 31 | `n30.week.list.item3.time` ±1 | text | 330.09 | 281.71 | 15.91 | 14.4 | `display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #8A8073 |
| 32 | `n30.week.list.item3.body` | text | 68 | 300.46 | 278 | 18.9 | `display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30.week.label` | 1 | ESTA SEMANA | 10.93 | 0 | 94.6 | 94.6 |
| `n30.week.list.item1.title` | 1 | Enquete: próximo livro do clube | 50.31 | 68 | 282.38 | 214.38 |
| `n30.week.list.item1.time` | 1 | sex | 50.31 | 327.54 | 346 | 18.46 |
| `n30.week.list.item1.body` | 1 | 8 de 11 já votaram. Falta o seu — fecha terça, | 71.83 | 68 | 344.15 | 276.15 |
| `n30.week.list.item1.body` | 2 | 20h. | 90.73 | 68 | 95.17 | 27.17 |
| `n30.week.list.item1.action` | 1 | Votar | 128.01 | 83.5 | 117.53 | 34.03 |
| `n30.week.list.item2.title` | 1 | Você aceitou o pedido do Rafa | 181.16 | 68 | 273.13 | 205.13 |
| `n30.week.list.item2.time` | 1 | qui | 181.16 | 328.94 | 346 | 17.06 |
| `n30.week.list.item2.body` | 1 | Lê muita ficção científica e poesia. | 202.68 | 68 | 280.02 | 212.02 |
| `n30.week.list.item2.action` | 1 | Seguir de volta | 239.96 | 83.5 | 174.28 | 90.78 |
| `n30.week.list.item3.title` | 1 | Ana entrou em Leitoras de Capitu | 293.11 | 68 | 294.68 | 226.68 |
| `n30.week.list.item3.time` | 1 | ter | 293.11 | 330.09 | 346 | 15.91 |
| `n30.week.list.item3.body` | 1 | Agora são 11 pessoas no clube. | 314.63 | 68 | 255.35 | 187.35 |

Seção `n30.footnote` — retângulo absoluto no canvas 390×1180: **x=24, y=1018.47, w=342, h=17.5**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 33 | `n30.footnote` | text | 0 | 0 | 342 | 17.5 | `margin: 22px 8px 0; text-align: center; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #8A8073` | Figtree 12.5/17.5px peso 600 ls normal #8A8073 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30.footnote` | 1 | Avisos com mais de 30 dias somem sozinhos. | 13.12 | 43.27 | 298.73 | 255.46 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "ESTA SEMANA" como o "HOJE", 26 acima e 10 abaixo.
2. O aviso: o quadrado 44 de raio 14 na cor do tipo (Clube `#FFC1C6`, Lembrete `#FED170`, Conquistas `#ABCF82`, Social `#B6ACE4`) com o ícone; o título 14,5/800 `lh 1,3` (`flex 1`) e, na mesma linha pela base, o tempo 12/700 `#8A8073` `nowrap`; o texto 13,5/600 `lh 1,4` `#5B544B`, 3 abaixo; a ação, quando tem, numa pílula de 36, 10 abaixo (preta em "Ler agora", creme nas outras). Não lido = cartão (padding 12, raio 20, `#FFFAF1`, borda 1,5, sombra 2/2, 10 acima) com a bolinha coral 9 (borda 1,2) depois do tempo; lido = liso, padding 12/12, o fio tracejado 1,2 `#D9CCB4` embaixo.
3. A nota do fim 22 abaixo, margem 8 dos lados: 12,5/600 `lh 1,4` `#8A8073`, centrada.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A seção Esta semana também não tem contêiner (como Hoje): a caixa é a união dos ids de topo.
- O dia da semana ("sex", "qui", "ter") vem da data do aviso; mais de 7 dias, a data curta — sem prancha: pergunta da T17.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_030_notificacoes_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_030_notificacoes_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `n30.week.label.rule` |  |  | aria-hidden=true |
| `n30.week.list.item1.icon` |  |  | aria-hidden=true |
| `n30.week.list.item1.icon.art` |  |  | aria-hidden=true |
| `n30.week.list.item2.icon` |  |  | aria-hidden=true |
| `n30.week.list.item2.icon.art` |  |  | aria-hidden=true |
| `n30.week.list.item3.icon` |  |  | aria-hidden=true |
| `n30.week.list.item3.icon.art` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `n30.week.label.rule` | NeoBox |  |
| `n30.week.list.item1.card` | NeoBox |  |
| `n30.week.list.item1.icon` | NeoBox |  |
| `n30.week.list.item1.icon.art` | AppSvg(AppIconsPerfil.statsBars, size: 21) |  |
| `n30.week.list.item1.action` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `n30.week.list.item2.card` | NeoBox |  |
| `n30.week.list.item2.icon` | NeoBox |  |
| `n30.week.list.item2.icon.art` | AppSvg(AppIconsPerfil.person, size: 21) |  |
| `n30.week.list.item2.action` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `n30.week.list.item3.card` | NeoBox |  |
| `n30.week.list.item3.icon` | NeoBox |  |
| `n30.week.list.item3.icon.art` | AppSvg(AppIconsScanner.peopleAvatar, size: 22) |  |

## Interações

- Enquete ("Votar") → a Enquete (47), da T11; Ana entrou → o clube (31), da T08: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).
- Pedido aceito → o perfil do Rafa (51), da T22; "Seguir de volta" segue (o social já existe) e o botão muda para o estado seguido, sem prancha: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).

## Dados

- Os avisos com mais de 30 dias saem da lista (a regra do texto do fim).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L30.1** Esta semana
- **L30.2** Nota do fim
- **L30.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('n30.week', 'n30.footnote'), todos os ids de `kRef30.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/030_notificacoes_390x1180@3x.png` no recorte da fase (y 652.66–1043.97) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef30w360` e `kRef30w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L30.1 Esta semana
- [ ] L30.2 Nota do fim
- [ ] L30.3 Verificação + relatório
- [ ] Geometria 33/33 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
