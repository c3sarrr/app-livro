# FASE L59 — Excluir conta — o que vai embora, as alternativas, digitar EXCLUIR e o botão preso embaixo

> Tela 59 · prancha `059_excluir_conta` (59 · Excluir conta, canvas 390×960) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L59_excluir_conta@3x.png` · `docs/design/medicao/projeto/png/redline/L59_excluir_conta_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/059_excluir_conta_390x960@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_059_excluir_conta.json` · `test/reference/projeto/reference_layout_059_excluir_conta.dart` (`kRef59`).
> Arquivos sugeridos: `lib/features/settings/presentation/account/delete_account_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Excluir conta (59): "Excluir sua conta?" com tom calmo, os 6 blocos do que vai embora, o que acontece nos clubes, duas saídas mais leves (baixar os dados, fazer uma pausa), digitar EXCLUIR e o botão coral preso embaixo, apagado até terminar de digitar.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{club}}` = padrão `#FFC1C6`.

```html
<h1 style="margin: 0px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px;">Excluir <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.5px;">sua conta?</span></h1>

<p style="margin: 8px 0 0; font-size: 14px; font-weight: 600; line-height: 1.45; color: #5B544B;">Sem pressa. Antes, veja o que vai embora junto com ela.</p>

<div aria-label="O que será apagado" style="margin-top: 16px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px;"><span style="padding: 10px 12px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05;">52</span><span style="font-size: 12px; font-weight: 700;">livros lidos</span></span><span style="padding: 10px 12px; border-radius: 16px; background: #FED170; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05;">214</span><span style="font-size: 12px; font-weight: 700;">grifos</span></span><span style="padding: 10px 12px; border-radius: 16px; background: #FFC1C6; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05;">8</span><span style="font-size: 12px; font-weight: 700;">resenhas</span></span><span style="padding: 10px 12px; border-radius: 16px; background: #ABCF82; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05;">5</span><span style="font-size: 12px; font-weight: 700;">listas</span></span><span style="padding: 10px 12px; border-radius: 16px; background: #FFB8A6; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05;">12</span><span style="font-size: 12px; font-weight: 700;">dias seguidos</span></span><span style="padding: 10px 12px; border-radius: 16px; background: #B6ACE4; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05;">3</span><span style="font-size: 12px; font-weight: 700;">clubes</span></span></div>

<p style="margin: 10px 4px 0; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #3D3830;">Nos clubes, suas mensagens viram “leitora que saiu”. Leitoras de Capitu continua com a Ana.</p>

<!-- softer exits first -->
<div style="margin-top: 18px; display: flex; flex-direction: column; gap: 10px;">
  <a href="#" style="padding: 12px 14px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12M7.5 10.5 12 15l4.5-4.5"></path><path d="M5 19h14"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 800;">Baixar meus dados antes</span><span style="font-size: 12.5px; font-weight: 600; color: #5B544B;">Chega por e-mail em alguns minutos</span></span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></a>
  <a href="#" style="padding: 12px 14px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="8.5"></circle><path d="M10 9v6M14 9v6"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 800;">Prefere uma pausa?</span><span style="font-size: 12.5px; font-weight: 600; color: #5B544B;">Esconda o perfil e pare os avisos por um tempo</span></span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></a>
</div>

<!-- confirm -->
<section aria-label="Confirmar exclusão" style="margin-top: 22px; padding: 14px; border-radius: 22px; background: #FFE9E4; border: 1.5px solid #1A1714;">
  <span style="font-size: 14px; font-weight: 800;">Para confirmar, digite <span style="padding: 1px 6px; border-radius: 6px; background: #FFFAF1; border: 1.2px solid #1A1714; letter-spacing: 1px;">EXCLUIR</span></span>
  <div style="margin-top: 10px; height: 50px; padding: 0 14px; border-radius: 14px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 16px; font-weight: 800; letter-spacing: 1.5px;">EXCL<span aria-hidden="true" style="display: inline-block; width: 2px; height: 20px; margin-left: 1px; background: #FF552E;"></span></div>
  <p style="margin: 10px 0 0; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #3D3830;">A conta some na hora para os outros. Você tem <strong style="color: #1A1714;">30 dias</strong> para voltar atrás entrando de novo; depois, tudo é apagado de vez.</p>
</section>

<div style="position: absolute; left: 0; right: 0; bottom: 0; z-index: 5; padding: 26px 20px 28px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 30%);">
  <button aria-disabled="true" style="width: 100%; height: 56px; border-radius: 999px; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; opacity: 0.45; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 16px; font-weight: 800;"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13"></path><path d="M10 11v6M14 11v6"></path></svg>Excluir minha conta</button><p style="margin: 10px 0 0; text-align: center; font-size: 12.5px; font-weight: 600; color: #6F665B;">O botão libera quando você terminar de digitar.</p>
</div>
```

## Especificação pixel a pixel

Seção `aj59.headline` — retângulo absoluto no canvas 390×960: **x=20, y=122, w=350, h=41.16**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `aj59.headline` | text | 0 | 0 | 350 | 41.16 | `margin: 0px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1.1px #1A1714 |
| 2 | `aj59.headline.serif` ±1 | inline | 111.19 | -6.72 | 156.45 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.5px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.5px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj59.headline` *(composto)* | 1 | Excluir sua conta? | 34.86 | 0 | 267.64 | 267.64 |

Seção `aj59.lead` — retângulo absoluto no canvas 390×960: **x=20, y=171.16, w=350, h=40.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `aj59.lead` | text | 0 | 0 | 350 | 40.6 | `margin: 8px 0 0; font-size: 14px; font-weight: 600; line-height: 1.45; color: #5B544B` | Figtree 14/20.3px peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj59.lead` | 1 | Sem pressa. Antes, veja o que vai embora junto com | 15.05 | 0 | 330.59 | 330.59 |
| `aj59.lead` | 2 | ela. | 35.35 | 0 | 21.6 | 21.6 |

Seção `aj59.losses` — retângulo absoluto no canvas 390×960: **x=20, y=227.76, w=350, h=131**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `aj59.losses` | box | 0 | 0 | 350 | 131 | `margin-top: 16px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px` |  |
| 5 | `aj59.losses.books` | box | 0 | 0 | 111.33 | 61.5 | `padding: 10px 12px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px` |  |
| 6 | `aj59.losses.books.value` | text | 13.5 | 11.5 | 84.33 | 23.1 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05` | Bricolage (opsz 22) 22/23.1px peso 800 ls normal #1A1714 |
| 7 | `aj59.losses.books.label` | text | 13.5 | 35.6 | 84.33 | 14.4 | `font-size: 12px; font-weight: 700` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 8 | `aj59.losses.highlights` | box | 119.33 | 0 | 111.33 | 61.5 | `padding: 10px 12px; border-radius: 16px; background: #FED170; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px` |  |
| 9 | `aj59.losses.highlights.value` | text | 132.83 | 11.5 | 84.33 | 23.1 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05` | Bricolage (opsz 22) 22/23.1px peso 800 ls normal #1A1714 |
| 10 | `aj59.losses.highlights.label` | text | 132.83 | 35.6 | 84.33 | 14.4 | `font-size: 12px; font-weight: 700` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 11 | `aj59.losses.reviews` | box | 238.67 | 0 | 111.33 | 61.5 | `padding: 10px 12px; border-radius: 16px; background: #FFC1C6; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px` |  |
| 12 | `aj59.losses.reviews.value` | text | 252.17 | 11.5 | 84.33 | 23.1 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05` | Bricolage (opsz 22) 22/23.1px peso 800 ls normal #1A1714 |
| 13 | `aj59.losses.reviews.label` | text | 252.17 | 35.6 | 84.33 | 14.4 | `font-size: 12px; font-weight: 700` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 14 | `aj59.losses.lists` | box | 0 | 69.5 | 111.33 | 61.5 | `padding: 10px 12px; border-radius: 16px; background: #ABCF82; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px` |  |
| 15 | `aj59.losses.lists.value` | text | 13.5 | 81 | 84.33 | 23.1 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05` | Bricolage (opsz 22) 22/23.1px peso 800 ls normal #1A1714 |
| 16 | `aj59.losses.lists.label` | text | 13.5 | 105.1 | 84.33 | 14.4 | `font-size: 12px; font-weight: 700` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 17 | `aj59.losses.streak` | box | 119.33 | 69.5 | 111.33 | 61.5 | `padding: 10px 12px; border-radius: 16px; background: #FFB8A6; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px` |  |
| 18 | `aj59.losses.streak.value` | text | 132.83 | 81 | 84.33 | 23.1 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05` | Bricolage (opsz 22) 22/23.1px peso 800 ls normal #1A1714 |
| 19 | `aj59.losses.streak.label` | text | 132.83 | 105.1 | 84.33 | 14.4 | `font-size: 12px; font-weight: 700` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 20 | `aj59.losses.clubs` | box | 238.67 | 69.5 | 111.33 | 61.5 | `padding: 10px 12px; border-radius: 16px; background: #B6ACE4; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 1px` |  |
| 21 | `aj59.losses.clubs.value` | text | 252.17 | 81 | 84.33 | 23.1 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05` | Bricolage (opsz 22) 22/23.1px peso 800 ls normal #1A1714 |
| 22 | `aj59.losses.clubs.label` | text | 252.17 | 105.1 | 84.33 | 14.4 | `font-size: 12px; font-weight: 700` | Figtree 12/normal peso 700 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj59.losses.books.value` | 1 | 52 | 30.31 | 13.5 | 40.27 | 26.77 |
| `aj59.losses.books.label` | 1 | livros lidos | 47 | 13.5 | 72.04 | 58.54 |
| `aj59.losses.highlights.value` | 1 | 214 | 30.31 | 132.83 | 167.97 | 35.14 |
| `aj59.losses.highlights.label` | 1 | grifos | 47 | 132.83 | 164.87 | 32.04 |
| `aj59.losses.reviews.value` | 1 | 8 | 30.31 | 252.17 | 266.6 | 14.43 |
| `aj59.losses.reviews.label` | 1 | resenhas | 47 | 252.17 | 301.25 | 49.08 |
| `aj59.losses.lists.value` | 1 | 5 | 99.81 | 13.5 | 26.92 | 13.42 |
| `aj59.losses.lists.label` | 1 | listas | 116.5 | 13.5 | 41.89 | 28.39 |
| `aj59.losses.streak.value` | 1 | 12 | 99.81 | 132.83 | 154 | 21.17 |
| `aj59.losses.streak.label` | 1 | dias seguidos | 116.5 | 132.83 | 207.08 | 74.25 |
| `aj59.losses.clubs.value` | 1 | 3 | 99.81 | 252.17 | 265.5 | 13.33 |
| `aj59.losses.clubs.label` | 1 | clubes | 116.5 | 252.17 | 287.88 | 35.71 |

Seção `aj59.clubsNote` — retângulo absoluto no canvas 390×960: **x=24, y=368.76, w=342, h=35**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 23 | `aj59.clubsNote` | text | 0 | 0 | 342 | 35 | `margin: 10px 4px 0; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #3D3830` | Figtree 12.5/17.5px peso 600 ls normal #3D3830 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj59.clubsNote` | 1 | Nos clubes, suas mensagens viram “leitora que saiu”. | 13.12 | 0 | 297.57 | 297.57 |
| `aj59.clubsNote` | 2 | Leitoras de Capitu continua com a Ana. | 30.62 | 0 | 222.58 | 222.58 |

Seção `aj59.alternatives` — retângulo absoluto no canvas 390×960: **x=20, y=421.76, w=350, h=152.02**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 24 | `aj59.alternatives` | box | 0 | 0 | 350 | 152.02 | `margin-top: 18px; display: flex; flex-direction: column; gap: 10px` |  |
| 25 | `aj59.alternatives.download` | box | 0 | 0 | 350 | 65 | `padding: 12px 14px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; display: flex; align-items: center; gap: 12px` |  |
| 26 | `aj59.alternatives.download.icon` | box | 15.5 | 13.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 27 | `aj59.alternatives.download.icon.art` | icon | 25.5 | 23.5 | 18 | 18 | `—` |  |
| 28 | `aj59.alternatives.download.textBlock` | box | 65.5 | 15 | 239 | 35.01 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 29 | `aj59.alternatives.download.title` | text | 65.5 | 15 | 239 | 18 | `font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 30 | `aj59.alternatives.download.body` | text | 65.5 | 35 | 239 | 15.01 | `font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 31 | `aj59.alternatives.download.chevron` | icon | 316.5 | 23.5 | 18 | 18 | `flex-shrink: 0` |  |
| 32 | `aj59.alternatives.pause` | box | 0 | 75 | 350 | 77.02 | `padding: 12px 14px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; align-items: center; gap: 12px` |  |
| 33 | `aj59.alternatives.pause.icon` | box | 15.5 | 94.51 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 34 | `aj59.alternatives.pause.icon.art` | icon | 25.5 | 104.51 | 18 | 18 | `—` |  |
| 35 | `aj59.alternatives.pause.textBlock` | box | 65.5 | 88.5 | 239 | 50.02 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 36 | `aj59.alternatives.pause.title` | text | 65.5 | 88.5 | 239 | 18 | `font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 37 | `aj59.alternatives.pause.body` | text | 65.5 | 108.5 | 239 | 30.02 | `font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 38 | `aj59.alternatives.pause.chevron` | icon | 316.5 | 104.51 | 18 | 18 | `flex-shrink: 0` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj59.alternatives.download.title` | 1 | Baixar meus dados antes | 29.24 | 65.5 | 237.36 | 171.86 |
| `aj59.alternatives.download.body` | 1 | Chega por e-mail em alguns minutos | 46.87 | 65.5 | 272.77 | 207.27 |
| `aj59.alternatives.pause.title` | 1 | Prefere uma pausa? | 102.75 | 65.5 | 203.41 | 137.91 |
| `aj59.alternatives.pause.body` | 1 | Esconda o perfil e pare os avisos por um | 120.38 | 65.5 | 292.62 | 227.12 |
| `aj59.alternatives.pause.body` | 2 | tempo | 135.39 | 65.5 | 102.74 | 37.24 |

Seção `aj59.confirm` — retângulo absoluto no canvas 390×960: **x=20, y=595.78, w=350, h=172.7**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 39 | `aj59.confirm` | box | 0 | 0 | 350 | 172.7 | `margin-top: 22px; padding: 14px; border-radius: 22px; background: #FFE9E4; border: 1.5px solid #1A1714` | Figtree 16/normal peso 400 ls normal #1A1714 |
| 40 | `aj59.confirm.label` ±1 | inline | 15.5 | 15.2 | 225.79 | 21.2 | `font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 41 | `aj59.confirm.label.word` ±1 | inline | 160.79 | 15.2 | 80.49 | 21.2 | `padding: 1px 6px; border-radius: 6px; background: #FFFAF1; border: 1.2px solid #1A1714; letter-spacing: 1px` | Figtree 14/normal peso 800 ls 1px #1A1714 |
| 42 | `aj59.confirm.field` | box+text | 15.5 | 44.7 | 319 | 50 | `margin-top: 10px; height: 50px; padding: 0 14px; border-radius: 14px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 16px; font-weight: 800; letter-spacing: 1.5px` | Figtree 16/normal peso 800 ls 1.5px #1A1714 |
| 43 | `aj59.confirm.field.caret` ±1 | box | 79.09 | 59.7 | 2 | 20 | `display: inline-block; width: 2px; height: 20px; margin-left: 1px; background: #FF552E` |  |
| 44 | `aj59.confirm.note` | text | 15.5 | 104.7 | 319 | 52.5 | `margin: 10px 0 0; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #3D3830` | Figtree 12.5/17.5px peso 600 ls normal #3D3830 |
| 45 | `aj59.confirm.note.deadline` ±1 | inline | 286.46 | 105.94 | 41.77 | 15.01 | `color: #1A1714` | Figtree 12.5/17.5px peso 900→**800** ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj59.confirm` *(composto)* | 1 | Para confirmar, digite EXCLUIR | 30.7 | 15.5 | 234.09 | 218.59 |
| `aj59.confirm` *(composto)* | 2 | EXCL | 75.3 | 31 | 78.09 | 47.09 |
| `aj59.confirm` *(composto)* | 3 | A conta some na hora para os outros. Você tem 30 dias | 117.82 | 15.5 | 328.24 | 312.74 |
| `aj59.confirm` *(composto)* | 4 | para voltar atrás entrando de novo; depois, tudo é | 135.32 | 15.5 | 297.73 | 282.23 |
| `aj59.confirm` *(composto)* | 5 | apagado de vez. | 152.82 | 15.5 | 107.43 | 91.93 |
| `aj59.confirm.field` | 1 | EXCL | 75.3 | 31 | 78.09 | 47.09 |
| `aj59.confirm.note` *(composto)* | 1 | A conta some na hora para os outros. Você tem 30 dias | 117.82 | 15.5 | 328.24 | 312.74 |
| `aj59.confirm.note` *(composto)* | 2 | para voltar atrás entrando de novo; depois, tudo é | 135.32 | 15.5 | 297.73 | 282.23 |
| `aj59.confirm.note` *(composto)* | 3 | apagado de vez. | 152.82 | 15.5 | 107.43 | 91.93 |

Seção `aj59.bottom` — retângulo absoluto no canvas 390×960: **x=0, y=824.99, w=390, h=135.01**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 46 | `aj59.bottom` | box | 0 | 0 | 390 | 135.01 | `position: absolute; left: 0; right: 0; bottom: 0; z-index: 5; padding: 26px 20px 28px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 30%)` |  |
| 47 | `aj59.bottom.delete` | box+text | 20 | 26 | 350 | 56 | `width: 100%; height: 56px; border-radius: 999px; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; opacity: 0.45; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 16px; font-weight: 800` | Figtree 16/normal peso 800 ls normal #1A1714 |
| 48 | `aj59.bottom.delete.icon` ±1 | icon | 107.9 | 44.5 | 19 | 19 | `—` |  |
| 49 | `aj59.bottom.hint` | text | 20 | 92 | 350 | 15.01 | `margin: 10px 0 0; text-align: center; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj59.bottom.delete` | 1 | Excluir minha conta | 59.6 | 135.9 | 282.1 | 146.2 |
| `aj59.bottom.hint` | 1 | O botão libera quando você terminar de digitar. | 103.88 | 60.86 | 329.14 | 268.28 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O topo da Conta (a tabela "Diferenças"); "Excluir" Bricolage 34/800 + "sua conta?" Instrument Serif 42 e o texto 14/600 `lh 1,45` `#5B544B`, 8 abaixo.
2. Perdas 16 abaixo (grade de 3, gap 8): padding 10/12, raio 16, borda 1,5, cada bloco na sua cor; o número Bricolage 22/800 `lh 1,05` e o rótulo 12/700. O texto dos clubes 12,5/600 `#3D3830`, 10 abaixo.
3. Saídas 18 abaixo (gap 10): padding 12/14, raio 20, `#FFFAF1`, borda 1,5, o círculo 38 com o ícone, o título e a descrição; a 1ª com sombra 3/3, a 2ª sem.
4. Confirmar 22 abaixo: padding 14, raio 22, `#FFE9E4`, borda 1,5; "Para confirmar, digite" 14/800 com o "EXCLUIR" numa etiqueta (`#FFFAF1`, borda 1,2, ls 1); o campo de 50 (raio 14, 16/800 ls 1,5) com "EXCL" e o cursor coral 2 × 20; o aviso dos 30 dias 12,5/600.
5. Fundo preso como na 64: "Excluir minha conta" 56, coral, borda 1,5, opacidade 0,45 (`aria-disabled`), a lixeira 19, e "O botão libera quando você terminar de digitar." embaixo.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O botão apagado é opacidade 0,45 sobre o coral (a cor e a borda juntas), não outra cor; a referência guarda a caixa, não a opacidade.
- O campo mostra o texto digitado em maiúsculas com ls 1,5 e o cursor desenhado: no app, `TextField` com o estilo, não um texto fixo.
- A 360 o rótulo "dias seguidos" fica num fio de navalha (0,09, abaixo).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_059_excluir_conta_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_059_excluir_conta_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `aj59.losses.streak.label` linha 1 «dias seguidos»: sobra 0.09 px · sem palavra seguinte (D-275: a linha única quebra se crescer).

## Diferenças em relação à prancha 58 (seções reutilizadas: top)

Estas seções são as mesmas widgets da 58 (fases L58_conta); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `aj59.top` | position: {"top": "58px", "right": "20px", "bottom": "1094px", "left": "20px"} → {"top": "58px", "right": "20px", "bottom": "854px", "left": "20px"} |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `aj59.losses` |  | O que será apagado |  |
| `aj59.alternatives.download.icon` |  |  | aria-hidden=true |
| `aj59.alternatives.download.icon.art` |  |  | aria-hidden=true |
| `aj59.alternatives.download.chevron` |  |  | aria-hidden=true |
| `aj59.alternatives.pause.icon` |  |  | aria-hidden=true |
| `aj59.alternatives.pause.icon.art` |  |  | aria-hidden=true |
| `aj59.alternatives.pause.chevron` |  |  | aria-hidden=true |
| `aj59.confirm` |  | Confirmar exclusão |  |
| `aj59.confirm.field.caret` |  |  | aria-hidden=true |
| `aj59.bottom.delete` |  |  | aria-disabled=true |
| `aj59.bottom.delete.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `aj59.headline.serif` | TextSpan dentro do AppText.rich do pai |  |
| `aj59.losses.books` | NeoBox |  |
| `aj59.losses.highlights` | NeoBox |  |
| `aj59.losses.reviews` | NeoBox |  |
| `aj59.losses.lists` | NeoBox |  |
| `aj59.losses.streak` | NeoBox |  |
| `aj59.losses.clubs` | NeoBox |  |
| `aj59.alternatives.download` | NeoBox |  |
| `aj59.alternatives.download.icon` | CircleIconButton / NeoBox circular |  |
| `aj59.alternatives.download.icon.art` | AppSvg(AppIconsInicio.download, size: 18) |  |
| `aj59.alternatives.download.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj59.alternatives.pause` | NeoBox |  |
| `aj59.alternatives.pause.icon` | CircleIconButton / NeoBox circular |  |
| `aj59.alternatives.pause.icon.art` | AppSvg(AppIconsPerfil.pauseCircle, size: 18) |  |
| `aj59.alternatives.pause.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj59.confirm` | NeoBox |  |
| `aj59.confirm.label` | TextSpan dentro do AppText.rich do pai |  |
| `aj59.confirm.label.word` | TextSpan dentro do AppText.rich do pai |  |
| `aj59.confirm.field` | NeoBox + AppText |  |
| `aj59.confirm.field.caret` | NeoBox |  |
| `aj59.confirm.note.deadline` | TextSpan dentro do AppText.rich do pai |  |
| `aj59.bottom` | DecoratedBox(LinearGradient) |  |
| `aj59.bottom.delete` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj59.bottom.delete.icon` | AppSvg(AppIconsPerfil.trashDeleteTinta, size: 19) |  |

## Interações

- Voltar → a Conta.
- Baixar meus dados antes → Exportar meus dados (a tela que falta, D-268, a mesma da 58).
- Prefere uma pausa? → esconder o perfil e parar os avisos por um tempo: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b) (a pausa é regra nova).
- Campo → compara com "EXCLUIR" sem diferenciar maiúsculas (a nota do design); o botão só libera quando bate.
- Excluir minha conta → a `deleteAccount` que já existe (D-65); depois a tela de despedida, sem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b).

## Dados

- Os 6 números (livros lidos, grifos, resenhas, listas, dias seguidos, clubes) são os da pessoa; os que ainda não existem (resenhas, listas) seguem a D-247. O texto dos clubes cita o clube e quem fica no lugar (o mundo do clube, T06–T12).
- Os 30 dias para voltar atrás: a exclusão de hoje (D-65) apaga na hora — o prazo é regra nova, pergunta da T17.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L59.1** Título, texto e os 6 blocos
- **L59.2** Clubes e as duas saídas
- **L59.3** Confirmar: digitar EXCLUIR
- **L59.4** Botão preso embaixo (apagado e liberado)
- **L59.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('aj59.headline', 'aj59.lead', 'aj59.losses', 'aj59.clubsNote', 'aj59.alternatives', 'aj59.confirm', 'aj59.bottom'), todos os ids de `kRef59.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/059_excluir_conta_390x960@3x.png` no recorte da fase (y 107.28–960) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef59w360` e `kRef59w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L59.1 Título, texto e os 6 blocos
- [ ] L59.2 Clubes e as duas saídas
- [ ] L59.3 Confirmar: digitar EXCLUIR
- [ ] L59.4 Botão preso embaixo (apagado e liberado)
- [ ] L59.5 Verificação + relatório
- [ ] Geometria 45/45 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
