# FASE L28 — Busca (Explorar) — buscas recentes e os climas

> Tela 28 · prancha `028_busca_explorar` (28 · Busca — Explorar (antes de digitar), canvas 390×1520) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28_2_recentes_e_clima@3x.png` · `docs/design/medicao/projeto/png/redline/L28_2_recentes_e_clima_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028_busca_explorar_390x1520@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028_busca_explorar.json` · `test/reference/projeto/reference_layout_028_busca_explorar.dart` (`kRef28`).
> Arquivos sugeridos: `lib/features/search/presentation/sections/recent_searches.dart`, `lib/features/search/presentation/sections/mood_chips.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Busca (Explorar): as buscas recentes (capitu, Clarice Lispector, romance de época) com "Limpar" e "Pelo clima", oito pílulas coloridas votadas pelos leitores (Leve, Tenso, Para chorar, De uma sentada…).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="margin-top: 24px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px;">Buscas recentes</h2><a href="#" style="font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px;">Limpar</a></div>

<div style="margin-top: 12px; display: flex; flex-wrap: wrap; gap: 8px;"><a href="#" style="height: 38px; padding: 0 13px 0 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; white-space: nowrap;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6F665B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="8"></circle><path d="M12 8v4l2.5 1.5"></path></svg>capitu</a><a href="#" style="height: 38px; padding: 0 13px 0 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; white-space: nowrap;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6F665B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="8"></circle><path d="M12 8v4l2.5 1.5"></path></svg>Clarice Lispector</a><a href="#" style="height: 38px; padding: 0 13px 0 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; white-space: nowrap;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6F665B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="8"></circle><path d="M12 8v4l2.5 1.5"></path></svg>romance de época</a></div>

<div style="margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px;">Pelo clima</h2><span style="font-size: 12.5px; font-weight: 700; color: #6F665B;">votos dos leitores</span></div>

<div style="margin-top: 12px; display: flex; flex-wrap: wrap; gap: 9px 8px;"><a href="#" style="height: 42px; padding: 0 15px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap;">Leve</a><a href="#" style="height: 42px; padding: 0 15px; border-radius: 999px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap;">Tenso</a><a href="#" style="height: 42px; padding: 0 15px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap;">Para chorar</a><a href="#" style="height: 42px; padding: 0 15px; border-radius: 999px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap;">De uma sentada</a><a href="#" style="height: 42px; padding: 0 15px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap;">Engraçado</a><a href="#" style="height: 42px; padding: 0 15px; border-radius: 999px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap;">Reflexivo</a><a href="#" style="height: 42px; padding: 0 15px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap;">Misterioso</a><a href="#" style="height: 42px; padding: 0 15px; border-radius: 999px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap;">Esperançoso</a></div>
```

## Especificação pixel a pixel

Seção `bu28.recent` — retângulo absoluto no canvas 390×1520: **x=16, y=230.4, w=358, h=121.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28.recent.header` | box | 0 | 0 | 358 | 25.2 | `margin-top: 24px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 2 | `bu28.recent.title` ±1 | text | 0 | 0 | 164.91 | 25.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px` | Bricolage (opsz 21) 21/normal peso 800 ls -0.4px #1A1714 |
| 3 | `bu28.recent.clear` ±1 | text | 315.81 | 7.18 | 42.19 | 15.6 | `font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 4 | `bu28.recent.list` | box | 0 | 37.2 | 358 | 84 | `margin-top: 12px; display: flex; flex-wrap: wrap; gap: 8px` |  |
| 5 | `bu28.recent.item1` ±1 | box+text | 0 | 37.2 | 88.77 | 38 | `height: 38px; padding: 0 13px 0 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 6 | `bu28.recent.item1.icon` | icon | 11.5 | 48.2 | 16 | 16 | `—` |  |
| 7 | `bu28.recent.item2` ±1 | box+text | 96.77 | 37.2 | 157.23 | 38 | `height: 38px; padding: 0 13px 0 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 8 | `bu28.recent.item2.icon` ±1 | icon | 108.27 | 48.2 | 16 | 16 | `—` |  |
| 9 | `bu28.recent.item3` ±1 | box+text | 0 | 83.2 | 166.66 | 38 | `height: 38px; padding: 0 13px 0 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 10 | `bu28.recent.item3.icon` | icon | 11.5 | 94.2 | 16 | 16 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28.recent.title` | 1 | Buscas recentes | 19.53 | 0 | 164.91 | 164.91 |
| `bu28.recent.clear` | 1 | Limpar | 19.53 | 315.81 | 358 | 42.19 |
| `bu28.recent.item1` | 1 | capitu | 61.1 | 33.5 | 74.27 | 40.77 |
| `bu28.recent.item2` | 1 | Clarice Lispector | 61.1 | 130.27 | 239.5 | 109.23 |
| `bu28.recent.item3` | 1 | romance de época | 107.1 | 33.5 | 152.16 | 118.66 |

Seção `bu28.mood` — retângulo absoluto no canvas 390×1520: **x=16, y=381.6, w=358, h=181.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 11 | `bu28.mood.header` | box | 0 | 0 | 358 | 25.2 | `margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 12 | `bu28.mood.title` ±1 | text | 0 | 0 | 101.17 | 25.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px` | Bricolage (opsz 21) 21/normal peso 800 ls -0.4px #1A1714 |
| 13 | `bu28.mood.voters` ±1 | text | 256.57 | 7.65 | 101.42 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #6F665B` | Figtree 12.5/normal peso 700 ls normal #6F665B |
| 14 | `bu28.mood.chips` | box | 0 | 37.2 | 358 | 144 | `margin-top: 12px; display: flex; flex-wrap: wrap; gap: 9px 8px` |  |
| 15 | `bu28.mood.chips.chip1` ±1 | box+text | 0 | 37.2 | 64.81 | 42 | `height: 42px; padding: 0 15px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 16 | `bu28.mood.chips.chip2` ±1 | box+text | 72.81 | 37.2 | 72.51 | 42 | `height: 42px; padding: 0 15px; border-radius: 999px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 17 | `bu28.mood.chips.chip3` ±1 | box+text | 153.32 | 37.2 | 110.68 | 42 | `height: 42px; padding: 0 15px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 18 | `bu28.mood.chips.chip4` ±1 | box+text | 0 | 88.2 | 140.6 | 42 | `height: 42px; padding: 0 15px; border-radius: 999px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 19 | `bu28.mood.chips.chip5` ±1 | box+text | 148.6 | 88.2 | 105.15 | 42 | `height: 42px; padding: 0 15px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 20 | `bu28.mood.chips.chip6` ±1 | box+text | 0 | 139.2 | 96.64 | 42 | `height: 42px; padding: 0 15px; border-radius: 999px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 21 | `bu28.mood.chips.chip7` ±1 | box+text | 104.64 | 139.2 | 104.01 | 42 | `height: 42px; padding: 0 15px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 22 | `bu28.mood.chips.chip8` ±1 | box+text | 216.65 | 139.2 | 119.03 | 42 | `height: 42px; padding: 0 15px; border-radius: 999px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 14.5px; font-weight: 800; white-space: nowrap` | Figtree 14.5/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28.mood.title` | 1 | Pelo clima | 19.53 | 0 | 101.17 | 101.17 |
| `bu28.mood.voters` | 1 | votos dos leitores | 19.53 | 256.57 | 358 | 101.43 |
| `bu28.mood.chips.chip1` | 1 | Leve | 63.28 | 16.5 | 48.31 | 31.81 |
| `bu28.mood.chips.chip2` | 1 | Tenso | 63.28 | 89.31 | 128.82 | 39.51 |
| `bu28.mood.chips.chip3` | 1 | Para chorar | 63.28 | 169.82 | 247.5 | 77.68 |
| `bu28.mood.chips.chip4` | 1 | De uma sentada | 114.28 | 16.5 | 124.1 | 107.6 |
| `bu28.mood.chips.chip5` | 1 | Engraçado | 114.28 | 165.1 | 237.26 | 72.16 |
| `bu28.mood.chips.chip6` | 1 | Reflexivo | 165.28 | 16.5 | 80.14 | 63.64 |
| `bu28.mood.chips.chip7` | 1 | Misterioso | 165.28 | 121.14 | 192.15 | 71.01 |
| `bu28.mood.chips.chip8` | 1 | Esperançoso | 165.28 | 233.15 | 319.18 | 86.03 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Buscas recentes" Bricolage 21/800 ls −0,4 e "Limpar" 13/800 sublinhado (offset 3), 24 abaixo do título.
2. Recentes (flex-wrap, gap 8, 12 abaixo): pílulas de 38, padding 0/13/0/10, `#FFFAF1`, borda 1,5, sem sombra, o relógio 16 `#6F665B` + 14/700 `nowrap`.
3. "Pelo clima" + "votos dos leitores" 12,5/700 `#6F665B`, 30 abaixo; as pílulas (flex-wrap, gap 9/8) de 42, padding 0/15, borda 1,5, **sombra 2/2**, 14,5/800: amarelo, lavanda, rosa e verde se repetem na ordem.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As cores dos climas aqui (Leve amarelo, Tenso lavanda…) e as dos humores da 17 (irônico rosa, reflexivo amarelo…) precisam sair de uma tabela só de clima → cor; conferir que "Reflexivo" é lavanda aqui e amarelo na 17 — a divergência é do design e é pergunta da T15.
- Fio de navalha na fileira 2 de `bu28.mood.chips` (flex-wrap) «De uma sentada | Engraçado»: sobra 104.24 px · estouro com o 1º item da fileira seguinte 0.4 px — no Flutter (`Wrap`), as fileiras mudam com uma diferença mínima de largura.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028_busca_explorar_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028_busca_explorar_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28.recent.item1.icon` |  |  | aria-hidden=true |
| `bu28.recent.item2.icon` |  |  | aria-hidden=true |
| `bu28.recent.item3.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28.recent.item1` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.recent.item1.icon` | AppSvg(AppIconsScanner.clock, size: 16) |  |
| `bu28.recent.item2` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.recent.item2.icon` | AppSvg(AppIconsScanner.clock, size: 16) |  |
| `bu28.recent.item3` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.recent.item3.icon` | AppSvg(AppIconsScanner.clock, size: 16) |  |
| `bu28.mood.chips.chip1` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.mood.chips.chip2` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.mood.chips.chip3` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.mood.chips.chip4` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.mood.chips.chip5` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.mood.chips.chip6` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.mood.chips.chip7` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.mood.chips.chip8` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |

## Interações

- Recente → busca o termo de novo; Limpar → apaga as recentes (sem confirmação na prancha).
- Clima → os livros com esse clima: a lista não tem prancha — sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T15 (ROTEIRO §2b).

## Dados

- Buscas recentes salvas no aparelho (nota do design); a prancha mostra 3 — quantas guardar e mostrar é pergunta da T15.
- Climas: os mesmos dos Detalhes (17), com as mesmas cores em todo o app; os votos ainda não têm fonte (ver a L17_4).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L28.1** Buscas recentes com Limpar
- **L28.2** Pílulas de clima (flex-wrap)
- **L28.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28.recent', 'bu28.mood'), todos os ids de `kRef28.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028_busca_explorar_390x1520@3x.png` no recorte da fase (y 222.4–570.8) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28w360` e `kRef28w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28.1 Buscas recentes com Limpar
- [ ] L28.2 Pílulas de clima (flex-wrap)
- [ ] L28.3 Verificação + relatório
- [ ] Geometria 22/22 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
