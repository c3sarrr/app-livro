# FASE L06 — Ajustes — o voltar, o título, a busca, a conta (capa de livro) e a assinatura

> Tela 06 · prancha `006_ajustes` (06 · Ajustes (engrenagem), canvas 390×2400) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L06_1_conta@3x.png` · `docs/design/medicao/projeto/png/redline/L06_1_conta_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/006_ajustes_390x2400@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_006_ajustes.json` · `test/reference/projeto/reference_layout_006_ajustes.dart` (`kRef06`).
> Arquivos sugeridos: `lib/features/settings/presentation/settings_screen.dart`, `lib/features/settings/presentation/sections/settings_account_card.dart`, `lib/features/settings/presentation/sections/plan_card.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Ajustes (06), em cima: o voltar para o Perfil, "Seus ajustes.", a busca nos ajustes, o cartão da conta com a linguagem de capa de livro (avatar, nome, e-mail, "Dados só neste celular") e o cartão amarelo da assinatura (plano Grátis, conhecer o Pro).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`.

```html
<!-- Back (pushed from Perfil) -->
<div style="height: 48px; display: flex; align-items: center;">
  <a href="#" aria-label="Voltar para o perfil" style="width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg>
  </a>
</div>

<h1 style="margin: 16px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 1; letter-spacing: -1.2px;">Seus <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.6px;">ajustes.</span></h1>

<!-- Search -->
<label style="margin-top: 18px; height: 52px; display: flex; align-items: center; gap: 10px; padding: 0 18px 0 16px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg>
  <input type="search" aria-label="Buscar nos ajustes" placeholder="Buscar ajuste" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 15px; font-weight: 500; color: #1A1714;">
</label>

<!-- Account (same book-cover language as the profile) -->
<a href="#" aria-label="Conta de Marina Costa" style="position: relative; margin-top: 18px; display: flex; align-items: center; gap: 14px; padding: 16px 16px 16px 30px; border-radius: 8px 24px 24px 8px; background: {{cover}}; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; overflow: hidden;">
  <span aria-hidden="true" style="position: absolute; left: 0; top: 0; bottom: 0; width: 13px; background: rgba(26,23,20,0.12);"></span>
  <span aria-hidden="true" style="position: absolute; left: 16px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.28);"></span>
  <span aria-hidden="true" style="width: 58px; height: 58px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-6deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 36px; line-height: 1; padding-bottom: 4px;">M</span>
  <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;">
    <span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 20px; font-weight: 800; letter-spacing: -0.4px;">Marina Costa</span>
    <span style="font-size: 13px; font-weight: 600; color: #2C2452; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">marina@email.com</span>
    <span style="margin-top: 5px; align-self: flex-start; height: 24px; padding: 0 9px 0 6px; display: flex; align-items: center; gap: 4px; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; box-sizing: border-box; font-size: 11.5px; font-weight: 800; white-space: nowrap;">
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="7" y="2.5" width="10" height="19" rx="2.5"></rect><path d="M11 18.5h2"></path></svg>
      Dados só neste celular
    </span>
  </span>
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg>
</a>

<!-- Subscription (Ajustes › Assinatura): free state, opens the Pro plans (83) -->
<a href="#" aria-label="Assinatura: plano Grátis. Conhecer o BookNest Pro" style="position: relative; margin-top: 14px; display: flex; align-items: center; gap: 12px; padding: 14px 16px; border-radius: 22px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box;">
  <span aria-hidden="true" style="width: 42px; height: 42px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24"><path d="M12 2.6l2.9 5.9 6.5.9-4.7 4.6 1.1 6.5L12 17.4l-5.8 3.1 1.1-6.5L2.6 9.4l6.5-.9z" fill="#FF552E" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg></span>
  <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;">
    <span style="display: flex; align-items: center; gap: 8px;"><span style="font-size: 15.5px; font-weight: 800;">Assinatura</span><span style="height: 22px; padding: 0 8px; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800;">Grátis</span></span>
    <span style="font-size: 12.5px; font-weight: 600; color: #4A3B12; line-height: 1.3;">Conheça o Pro: estante na nuvem, em qualquer celular</span>
  </span>
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg>
</a>
```

## Especificação pixel a pixel

Seção `aj06.top` — retângulo absoluto no canvas 390×2400: **x=20, y=58, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `aj06.top` | box | 0 | 0 | 350 | 48 | `height: 48px; display: flex; align-items: center` |  |
| 2 | `aj06.top.back` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `aj06.top.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |

Seção `aj06.headline` — retângulo absoluto no canvas 390×2400: **x=20, y=122, w=350, h=46**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `aj06.headline` | text | 0 | 0 | 350 | 46 | `margin: 16px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 1; letter-spacing: -1.2px` | Bricolage (opsz 36) 36/36px peso 800 ls -1.2px #1A1714 |
| 5 | `aj06.headline.serif` ±1 | inline | 87.15 | -6.9 | 118.71 | 59.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.6px` | Instrument Serif itálico 46/46px peso 400 ls -0.6px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj06.headline` *(composto)* | 1 | Seus ajustes. | 38.64 | 0 | 205.86 | 205.86 |

Seção `aj06.search` — retângulo absoluto no canvas 390×2400: **x=20, y=186, w=350, h=52**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `aj06.search` | box | 0 | 0 | 350 | 52 | `margin-top: 18px; height: 52px; display: flex; align-items: center; gap: 10px; padding: 0 18px 0 16px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 7 | `aj06.search.icon` | icon | 17.5 | 16 | 20 | 20 | `—` |  |
| 8 | `aj06.search.input` | box | 47.5 | 1.5 | 283 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 15px; font-weight: 500; color: #1A1714` |  |

Seção `aj06.account` — retângulo absoluto no canvas 390×2400: **x=20, y=256, w=350, h=107.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 9 | `aj06.account` | box | 0 | 0 | 350 | 107.6 | `position: relative; margin-top: 18px; display: flex; align-items: center; gap: 14px; padding: 16px 16px 16px 30px; border-radius: 8px 24px 24px 8px; background: {{cover}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; overflow: hidden` |  |
| 10 | `aj06.account.spine` | box | 1.5 | 1.5 | 13 | 104.6 | `position: absolute; left: 0; top: 0; bottom: 0; width: 13px; background: rgba(26,23,20,0.12)` |  |
| 11 | `aj06.account.spineLine` | box | 17.5 | 1.5 | 1.5 | 104.6 | `position: absolute; left: 16px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.28)` |  |
| 12 | `aj06.account.avatar` | box+text | 31.5 | 24.8 | 58 | 58 | `width: 58px; height: 58px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-6deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 36px; line-height: 1; padding-bottom: 4px` | Instrument Serif itálico 36/36px peso 400 ls normal #1A1714 |
| 13 | `aj06.account.textBlock` | box | 103.5 | 17.5 | 195 | 72.6 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 14 | `aj06.account.name` | text | 103.5 | 17.5 | 195 | 24 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 20px; font-weight: 800; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 15 | `aj06.account.email` | text | 103.5 | 43.5 | 195 | 15.6 | `font-size: 13px; font-weight: 600; color: #2C2452; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 13/normal peso 600 ls normal #2C2452 |
| 16 | `aj06.account.badge` ±1 | box+text | 103.5 | 66.1 | 152.75 | 24 | `margin-top: 5px; align-self: flex-start; height: 24px; padding: 0 9px 0 6px; display: flex; align-items: center; gap: 4px; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; box-sizing: border-box; font-size: 11.5px; font-weight: 800; white-space: nowrap` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 17 | `aj06.account.badge.icon` | icon | 110.7 | 72.1 | 12 | 12 | `—` |  |
| 18 | `aj06.account.chevron` | icon | 312.5 | 43.8 | 20 | 20 | `flex-shrink: 0` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `aj06.account.avatar`: caixa visual com `transform: rotate(-6deg)` = x 28.63, y 21.93, w 63.74, h 63.74 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj06.account.avatar` | 1 | M | 64.04 | 48.53 | 72.47 | 23.94 |
| `aj06.account.name` | 1 | Marina Costa | 36.1 | 103.5 | 229.57 | 126.07 |
| `aj06.account.email` | 1 | marina@email.com | 55.85 | 103.5 | 216.94 | 113.44 |
| `aj06.account.badge` | 1 | Dados só neste celular | 82.12 | 126.7 | 246.05 | 119.35 |

Seção `aj06.plan` — retângulo absoluto no canvas 390×2400: **x=20, y=377.6, w=350, h=87.5**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 19 | `aj06.plan` | box | 0 | 0 | 350 | 87.5 | `position: relative; margin-top: 14px; display: flex; align-items: center; gap: 12px; padding: 14px 16px; border-radius: 22px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box` |  |
| 20 | `aj06.plan.icon` | box | 17.5 | 22.75 | 42 | 42 | `width: 42px; height: 42px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 21 | `aj06.plan.icon.art` | icon | 27.5 | 32.75 | 22 | 22 | `—` |  |
| 22 | `aj06.plan.textBlock` | box | 71.5 | 15.5 | 229 | 56.5 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 23 | `aj06.plan.head` | box | 71.5 | 15.5 | 229 | 22 | `display: flex; align-items: center; gap: 8px` |  |
| 24 | `aj06.plan.title` ±1 | text | 71.5 | 17.19 | 77.54 | 18.61 | `font-size: 15.5px; font-weight: 800` | Figtree 15.5/normal peso 800 ls normal #1A1714 |
| 25 | `aj06.plan.tag` ±1 | box+text | 157.04 | 15.5 | 49.63 | 22 | `height: 22px; padding: 0 8px; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800 ls normal #1A1714 |
| 26 | `aj06.plan.body` | text | 71.5 | 39.5 | 229 | 32.5 | `font-size: 12.5px; font-weight: 600; color: #4A3B12; line-height: 1.3` | Figtree 12.5/16.25px peso 600 ls normal #4A3B12 |
| 27 | `aj06.plan.chevron` | icon | 312.5 | 33.75 | 20 | 20 | `flex-shrink: 0` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj06.plan.title` | 1 | Assinatura | 31.92 | 71.5 | 149.04 | 77.54 |
| `aj06.plan.tag` | 1 | Grátis | 30.35 | 166.24 | 197.47 | 31.23 |
| `aj06.plan.body` | 1 | Conheça o Pro: estante na nuvem, em | 52 | 71.5 | 285.8 | 214.3 |
| `aj06.plan.body` | 2 | qualquer celular | 68.25 | 71.5 | 161.91 | 90.41 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Voltar de 48 (sem sombra, seta 20); "Seus" Bricolage 36/800 `lh 1` ls −1,2 + "ajustes." Instrument Serif 46 ls −0,6, 16 abaixo.
2. Busca 18 abaixo: pílula de 52, padding 0/18/0/16, gap 10, a lupa 20 e o campo 15/500 ("Buscar ajuste").
3. Conta 18 abaixo: padding 16/16/16/30, raio 8/24/24/8, `{{cover}}`, borda 1,5, sombra 4/4, a lombada de 13 e o vinco em `left 16`; o avatar 58 girado −6° (sombra 2/2, "M" Instrument Serif 36); o nome Bricolage 20/800, o e-mail 13/600 `#2C2452` com reticências e a pílula "Dados só neste celular" (24, 11,5/800, o celular 12), 5 abaixo; a seta 20 à direita.
4. Assinatura 14 abaixo: padding 14/16, raio 22, `#FED170`, borda 1,5, sombra 3/3, gap 12; a estrela coral num círculo 42; "Assinatura" 15,5/800 com a pílula "Grátis" (22, 11/800) e "Conheça o Pro: estante na nuvem, em qualquer celular" 12,5/600 `#4A3B12`; a seta 20.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O cartão da conta tem 107,6 de altura aqui e 93 na Conta (58): não é o mesmo componente (aqui o e-mail e a pílula, lá o @ e o botão Editar), só a mesma linguagem de capa.
- O e-mail corta com reticências (`nowrap` + `ellipsis`) e o nome não: um nome longo quebra a linha.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_006_ajustes_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_006_ajustes_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `aj06.top.back` |  | Voltar para o perfil |  |
| `aj06.search.icon` |  |  | aria-hidden=true |
| `aj06.search.input` |  | Buscar nos ajustes |  |
| `aj06.account` |  | Conta de Marina Costa |  |
| `aj06.account.spine` |  |  | aria-hidden=true |
| `aj06.account.spineLine` |  |  | aria-hidden=true |
| `aj06.account.avatar` |  |  | aria-hidden=true |
| `aj06.account.badge.icon` |  |  | aria-hidden=true |
| `aj06.account.chevron` |  |  | aria-hidden=true |
| `aj06.plan` |  | Assinatura: plano Grátis. Conhecer o BookNest Pro |  |
| `aj06.plan.icon` |  |  | aria-hidden=true |
| `aj06.plan.chevron` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `aj06.top.back` | CircleIconButton / NeoBox circular |  |
| `aj06.top.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `aj06.headline.serif` | TextSpan dentro do AppText.rich do pai |  |
| `aj06.search` | NeoBox |  |
| `aj06.search.icon` | AppSvg(AppIconsLeitor.search, size: 20) |  |
| `aj06.account` | NeoBox |  |
| `aj06.account.spine` | NeoBox |  |
| `aj06.account.spineLine` | NeoBox |  |
| `aj06.account.avatar` | CircleIconButton / NeoBox circular | Transform: rotate(-6deg) |
| `aj06.account.badge` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj06.account.badge.icon` | AppSvg(AppIconsPerfil.phoneSmall, size: 12) |  |
| `aj06.account.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 20) |  |
| `aj06.plan` | NeoBox |  |
| `aj06.plan.icon` | CircleIconButton / NeoBox circular |  |
| `aj06.plan.icon.art` | AppSvg(AppIconsPerfil.starCoral, size: 22) |  |
| `aj06.plan.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj06.plan.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 20) |  |

## Interações

- Voltar → o Perfil (os Ajustes ficam empilhados na aba Perfil).
- Buscar → filtra as linhas dos Ajustes pelo título e pela descrição; o resultado não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b).
- Conta → a Conta (58).
- Assinatura → os Planos do Pro (83), da T19 (hoje só o paywall de trabalho, D-230): a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).

## Dados

- Nome, e-mail e plano são os da conta (`AccountSummary`, `pro`); "Dados só neste celular" quando a conta não sincroniza (sem o Pro) — com o Pro, o texto e o ícone da sincronização (`sync_indicator.dart`) não têm prancha aqui: pergunta da T17. Sem conta, o cartão chama para entrar (sem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b)).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L06.1** Voltar, título e busca
- **L06.2** Cartão da conta
- **L06.3** Cartão da assinatura
- **L06.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('aj06.top', 'aj06.headline', 'aj06.search', 'aj06.account', 'aj06.plan'), todos os ids de `kRef06.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/006_ajustes_390x2400@3x.png` no recorte da fase (y 50–473.1) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef06w360` e `kRef06w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L06.1 Voltar, título e busca
- [ ] L06.2 Cartão da conta
- [ ] L06.3 Cartão da assinatura
- [ ] L06.4 Verificação + relatório
- [ ] Geometria 26/26 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
