# FASE L13 — Onboarding 2/4 — os gêneros (15 e "Mais gêneros") e o Continuar com a contagem

> Tela 13 · prancha `013_onboarding_generos` (13 · Onboarding 2/4 — Gêneros, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L13_generos@3x.png` · `docs/design/medicao/projeto/png/redline/L13_generos_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/013_onboarding_generos_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_013_onboarding_generos.json` · `test/reference/projeto/reference_layout_013_onboarding_generos.dart` (`kRef13`).
> Arquivos sugeridos: `lib/features/account/presentation/onboarding/genres_step.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Onboarding 2/4 — Gêneros (13): "O que você gosta de ler?", 15 gêneros em pílulas (4 escolhidos) e "Mais gêneros", a lista apagando embaixo, e o "Continuar" com a contagem (4).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{progress}}` = padrão `#FF552E`.

```html
<div style="position: relative; margin-top: 36px;">
  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px;">O que você<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.5px;">gosta de ler?</span></h1>
  <svg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24" style="position: absolute; right: 14px; top: 2px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFC1C6" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>
</div>

<p style="margin: 10px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B;">Escolha pelo menos 3. É assim que montamos o seu “Para você”.</p>

<div role="group" aria-label="Gêneros" style="margin-top: 18px; flex: 1 1 0; min-height: 0; overflow: hidden; padding-bottom: 20px; display: flex; flex-wrap: wrap; align-content: flex-start; gap: 9px 8px; -webkit-mask-image: linear-gradient(180deg, #000 calc(100% - 26px), transparent 100%); mask-image: linear-gradient(180deg, #000 calc(100% - 26px), transparent 100%);">
        <button role="checkbox" aria-checked="true" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>Clássicos</button>
  <button role="checkbox" aria-checked="true" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>Romance</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m21.64 3.64-1.28-1.28a1.21 1.21 0 0 0-1.72 0L2.36 18.64a1.21 1.21 0 0 0 0 1.72l1.28 1.28a1.2 1.2 0 0 0 1.72 0L21.64 5.36a1.2 1.2 0 0 0 0-1.72ZM14 7l3 3M5 6v4M19 14v4M10 2v2M7 8H3M21 16h-4M11 3H9"/></svg></span>Fantasia</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09ZM12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2ZM9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"/></svg></span>Ficção científica</button>
  <button role="checkbox" aria-checked="true" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>Mistério</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/></svg></span>Suspense</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 10h.01M15 10h.01M12 2a8 8 0 0 0-8 8v12l3-3 2.5 2.5L12 19l2.5 2.5L17 19l3 3V10a8 8 0 0 0-8-8z"/></svg></span>Terror</button>
  <button role="checkbox" aria-checked="true" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>Literatura brasileira</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12.67 19a2 2 0 0 0 1.416-.588l6.154-6.172a6 6 0 0 0-8.49-8.49L5.586 9.914A2 2 0 0 0 5 11.328V18a1 1 0 0 0 1 1zM16 8 2 22M17.5 15H9"/></svg></span>Poesia</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg></span>Biografias</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 22h14M5 2h14M17 22v-4.172a2 2 0 0 0-.586-1.414L12 12l-4.414 4.414A2 2 0 0 0 7 17.828V22M7 2v4.172a2 2 0 0 0 .586 1.414L12 12l4.414-4.414A2 2 0 0 0 17 6.172V2"/></svg></span>História</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5M9 18h6M10 22h4"/></svg></span>Não ficção</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></span>Quadrinhos</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/></svg></span>Jovem adulto</button>
  <button role="checkbox" aria-checked="false" style="height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap;"><span aria-hidden="true" style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2M9 9h.01M15 9h.01"/></svg></span>Humor</button>
  <button style="height: 44px; padding: 0 16px 0 12px; border-radius: 999px; background: transparent; border: 1.5px dashed #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; white-space: nowrap;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg>Mais gêneros</button>
</div>

<button style="margin-top: 8px; flex-shrink: 0; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
  <span style="color: #F7F0E3;">Continuar</span>
  <span style="min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #F7F0E3; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12.5px; font-weight: 800; color: #1A1714;">4</span>
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
</button>
```

## Especificação pixel a pixel

Seção `e13.heading` — retângulo absoluto no canvas 390×844: **x=20, y=142, w=350, h=78.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e13.heading` | box | 0 | 0 | 350 | 78.4 | `position: relative; margin-top: 36px` |  |
| 2 | `e13.heading.title` | text | 0 | 0 | 350 | 78.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1.1px #1A1714 |
| 3 | `e13.heading.title.serif` ±1 | inline | 0 | 25.96 | 192.54 | 59.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.5px` | Instrument Serif itálico 46/45.08px peso 400 ls -0.5px #1A1714 |
| 4 | `e13.heading.sparkle` | icon | 312 | 2 | 24 | 24 | `position: absolute; right: 14px; top: 2px` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e13.heading.title` *(composto)* | 1 | O que você | 27.88 | 0 | 167.93 | 167.93 |
| `e13.heading.title` *(composto)* | 2 | gosta de ler? | 71.5 | 0 | 192.54 | 192.54 |

Seção `e13.lead` — retângulo absoluto no canvas 390×844: **x=20, y=230.4, w=350, h=42.05**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `e13.lead` | text | 0 | 0 | 350 | 42.05 | `margin: 10px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B` | Figtree 14.5/21.025px peso 500 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e13.lead` | 1 | Escolha pelo menos 3. É assim que montamos o seu | 15.58 | 0 | 336.15 | 336.15 |
| `e13.lead` | 2 | “Para você”. | 36.6 | 0 | 77.07 | 77.07 |

Seção `e13.genres` — retângulo absoluto no canvas 390×844: **x=20, y=290.45, w=350, h=457.55**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `e13.genres` | box | 0 | 0 | 350 | 457.55 | `margin-top: 18px; flex: 1 1 0; min-height: 0; overflow: hidden; padding-bottom: 20px; display: flex; flex-wrap: wrap; align-content: flex-start; gap: 9px 8px; -webkit-mask-image: linear-gradient(180deg, #000 calc(100% - 26px), transparent 100%); mask-image: linear-gradient(180deg, #000 calc(100% - 26px), transparent 100%)` |  |
| 7 | `e13.genres.chip1` ±1 | box+text | 0 | 0 | 119.99 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 8 | `e13.genres.chip1.badge` | box | 8.5 | 8 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 9 | `e13.genres.chip1.badge.icon` | icon | 15.5 | 15 | 14 | 14 | `—` |  |
| 10 | `e13.genres.chip2` ±1 | box+text | 127.99 | 0 | 120.19 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 11 | `e13.genres.chip2.badge` ±1 | box | 136.49 | 8 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 12 | `e13.genres.chip2.badge.icon` ±1 | icon | 143.49 | 15 | 14 | 14 | `—` |  |
| 13 | `e13.genres.chip3` ±1 | box+text | 0 | 53 | 113.68 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 14 | `e13.genres.chip3.badge` | box | 8.5 | 61 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 15 | `e13.genres.chip3.badge.icon` | icon | 15 | 67.5 | 15 | 15 | `—` |  |
| 16 | `e13.genres.chip4` ±1 | box+text | 121.68 | 53 | 166.16 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 17 | `e13.genres.chip4.badge` ±1 | box | 130.18 | 61 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 18 | `e13.genres.chip4.badge.icon` ±1 | icon | 136.68 | 67.5 | 15 | 15 | `—` |  |
| 19 | `e13.genres.chip5` ±1 | box+text | 0 | 106 | 112.6 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 20 | `e13.genres.chip5.badge` | box | 8.5 | 114 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 21 | `e13.genres.chip5.badge.icon` | icon | 15.5 | 121 | 14 | 14 | `—` |  |
| 22 | `e13.genres.chip6` ±1 | box+text | 120.6 | 106 | 121.38 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 23 | `e13.genres.chip6.badge` ±1 | box | 129.1 | 114 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 24 | `e13.genres.chip6.badge.icon` ±1 | icon | 135.6 | 120.5 | 15 | 15 | `—` |  |
| 25 | `e13.genres.chip7` ±1 | box+text | 249.97 | 106 | 99.06 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 26 | `e13.genres.chip7.badge` ±1 | box | 258.47 | 114 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 27 | `e13.genres.chip7.badge.icon` ±1 | icon | 264.97 | 120.5 | 15 | 15 | `—` |  |
| 28 | `e13.genres.chip8` ±1 | box+text | 0 | 159 | 185.83 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 29 | `e13.genres.chip8.badge` ±1 | box | 8.5 | 167 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 30 | `e13.genres.chip8.badge.icon` ±1 | icon | 15.5 | 174 | 14 | 14 | `—` |  |
| 31 | `e13.genres.chip9` ±1 | box+text | 193.83 | 159 | 101.85 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 32 | `e13.genres.chip9.badge` ±1 | box | 202.33 | 167 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 33 | `e13.genres.chip9.badge.icon` ±1 | icon | 208.83 | 173.5 | 15 | 15 | `—` |  |
| 34 | `e13.genres.chip10` ±1 | box+text | 0 | 212 | 124.71 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 35 | `e13.genres.chip10.badge` ±1 | box | 8.5 | 220 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 36 | `e13.genres.chip10.badge.icon` ±1 | icon | 15 | 226.5 | 15 | 15 | `—` |  |
| 37 | `e13.genres.chip11` ±1 | box+text | 132.71 | 212 | 110.76 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 38 | `e13.genres.chip11.badge` ±1 | box | 141.21 | 220 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 39 | `e13.genres.chip11.badge.icon` ±1 | icon | 147.71 | 226.5 | 15 | 15 | `—` |  |
| 40 | `e13.genres.chip12` ±1 | box+text | 0 | 265 | 129.66 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 41 | `e13.genres.chip12.badge` ±1 | box | 8.5 | 273 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 42 | `e13.genres.chip12.badge.icon` ±1 | icon | 15 | 279.5 | 15 | 15 | `—` |  |
| 43 | `e13.genres.chip13` ±1 | box+text | 137.66 | 265 | 134.35 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 44 | `e13.genres.chip13.badge` ±1 | box | 146.16 | 273 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 45 | `e13.genres.chip13.badge.icon` ±1 | icon | 152.66 | 279.5 | 15 | 15 | `—` |  |
| 46 | `e13.genres.chip14` ±1 | box+text | 0 | 318 | 147.23 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 47 | `e13.genres.chip14.badge` ±1 | box | 8.5 | 326 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 48 | `e13.genres.chip14.badge.icon` ±1 | icon | 15 | 332.5 | 15 | 15 | `—` |  |
| 49 | `e13.genres.chip15` ±1 | box+text | 155.23 | 318 | 104.1 | 44 | `height: 44px; padding: 0 14px 0 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 50 | `e13.genres.chip15.badge` ±1 | box | 163.73 | 326 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 51 | `e13.genres.chip15.badge.icon` ±1 | icon | 170.23 | 332.5 | 15 | 15 | `—` |  |
| 52 | `e13.genres.more` ±1 | box+text | 0 | 371 | 139.87 | 44 | `height: 44px; padding: 0 16px 0 12px; border-radius: 999px; background: transparent; border: 1.5px dashed #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 53 | `e13.genres.more.icon` ±1 | icon | 13.5 | 384 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e13.genres.chip1` | 1 | Clássicos | 26.9 | 44.5 | 104.49 | 59.99 |
| `e13.genres.chip2` | 1 | Romance | 26.9 | 172.49 | 232.67 | 60.18 |
| `e13.genres.chip3` | 1 | Fantasia | 79.9 | 44.5 | 98.18 | 53.68 |
| `e13.genres.chip4` | 1 | Ficção científica | 79.9 | 166.18 | 272.34 | 106.16 |
| `e13.genres.chip5` | 1 | Mistério | 132.9 | 44.5 | 97.1 | 52.6 |
| `e13.genres.chip6` | 1 | Suspense | 132.9 | 165.1 | 226.47 | 61.37 |
| `e13.genres.chip7` | 1 | Terror | 132.9 | 294.47 | 333.53 | 39.06 |
| `e13.genres.chip8` | 1 | Literatura brasileira | 185.9 | 44.5 | 170.33 | 125.83 |
| `e13.genres.chip9` | 1 | Poesia | 185.9 | 238.33 | 280.18 | 41.85 |
| `e13.genres.chip10` | 1 | Biografias | 238.9 | 44.5 | 109.21 | 64.71 |
| `e13.genres.chip11` | 1 | História | 238.9 | 177.21 | 227.97 | 50.76 |
| `e13.genres.chip12` | 1 | Não ficção | 291.9 | 44.5 | 114.16 | 69.66 |
| `e13.genres.chip13` | 1 | Quadrinhos | 291.9 | 182.16 | 256.52 | 74.36 |
| `e13.genres.chip14` | 1 | Jovem adulto | 344.9 | 44.5 | 131.73 | 87.23 |
| `e13.genres.chip15` | 1 | Humor | 344.9 | 199.73 | 243.83 | 44.1 |
| `e13.genres.more` | 1 | Mais gêneros | 397.9 | 37.5 | 122.37 | 84.87 |

Seção `e13.continue` — retângulo absoluto no canvas 390×844: **x=20, y=756, w=350, h=54**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 54 | `e13.continue` | box | 0 | 0 | 350 | 54 | `margin-top: 8px; flex-shrink: 0; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 55 | `e13.continue.label` ±1 | text | 105.26 | 17.4 | 74.5 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 56 | `e13.continue.count` ±1 | box+text | 189.75 | 15 | 24.99 | 24 | `min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #F7F0E3; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12.5px; font-weight: 800; color: #1A1714` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 57 | `e13.continue.icon` ±1 | icon | 224.74 | 17 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e13.continue.label` | 1 | Continuar | 32.6 | 105.26 | 179.75 | 74.49 |
| `e13.continue.count` | 1 | 4 | 31.38 | 198.25 | 206.24 | 7.99 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O topo da 12 com o voltar e "2 de 4" (a tabela "Diferenças"); título Bricolage 34/800 + "gosta de ler?" Instrument Serif 46, o brilho rosa 24.
2. Gêneros (flex-wrap, gap 9/8, 18 abaixo; `flex 1`, `overflow: hidden`, `padding-bottom 20`, a máscara que apaga os últimos 26): pílulas de 44, padding 0/14/0/7, gap 8, borda 1,5, 14/700 — o círculo 28 com o ícone 15 do gênero (verde, rosa ou amarelo) ou, escolhido, o círculo preto com o visto 14 e o fundo `{{brand}}` com sombra 2/2.
3. "Mais gêneros": pílula tracejada (borda 1,5 `dashed`) com o "+" 18.
4. "Continuar" 54, 8 abaixo, com a contagem numa pílula de 24 `{{brand}}` (borda 1,5 `#F7F0E3`, 12,5/800).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A 3ª fileira (Mistério, Suspense, Terror) termina 0,97 antes da borda: com o texto um pouco mais largo o "Terror" desce e 15 ids descem junto (D-278, abaixo).
- A máscara apaga a lista por cima do que passa: `ShaderMask` no `Wrap` dentro de uma área rolável.
- Fio de navalha na fileira 3 de `e13.genres` (flex-wrap) «Mistério | Suspense | Terror»: sobra 0.97 px · estouro com o 1º item da fileira seguinte 192.87 px — no Flutter (`Wrap`), as fileiras mudam com uma diferença mínima de largura.
- `e13.genres` tem máscara `linear-gradient(#000000 calc(100% - 26px), #000000@0 100%)` → `ShaderMask`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_013_onboarding_generos_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_013_onboarding_generos_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 12 (seções reutilizadas: waves, top)

Estas seções são as mesmas widgets da 12 (fases L12_1_topo_e_meta_diaria, L12_2_meta_do_ano); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `e13.top.step` | retângulo ['20', '64', '66.7', '36'] → ['70', '64', '64.7', '36']; padding: "0px 13px 0px 13px" → "0px 12px 0px 12px"; texto «1 de 4» → «2 de 4» |
| `e13.top.progress` | retângulo ['98.7', '74', '196.14', '16'] → ['144.7', '74', '154.14', '16'] |
| `e13.top.progress.fill` | retângulo ['100.2', '75.5', '48.29', '13'] → ['146.2', '75.5', '75.57', '13']; position: {"top": "0px", "right": "144.857px", "bottom": "0px", "left": "0px"} → {"top": "0px", "right": "75.5716px", "bottom": "0px", "left": "0px"} |
| `e13.top.progress.fill.edge` | retângulo ['143.49', '75.5', '10', '13'] → ['216.77', '75.5', '10', '13']; position: {"top": "0px", "right": "-5px", "bottom": "0px", "left": "43.2856px"} → {"top": "0px", "right": "-5px", "bottom": "0px", "left": "70.5714px"} |
| `e13.top.skip` | retângulo ['306.84', '64', '63.16', '36'] → ['308.84', '64', '61.16', '36']; padding: "0px 14px 0px 14px" → "0px 13px 0px 13px" |

Só nesta prancha: `top.back`, `top.back.icon`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e13.heading.sparkle` |  |  | aria-hidden=true |
| `e13.genres` | group | Gêneros |  |
| `e13.genres.chip1` | checkbox |  | aria-checked=true |
| `e13.genres.chip1.badge` |  |  | aria-hidden=true |
| `e13.genres.chip2` | checkbox |  | aria-checked=true |
| `e13.genres.chip2.badge` |  |  | aria-hidden=true |
| `e13.genres.chip3` | checkbox |  | aria-checked=false |
| `e13.genres.chip3.badge` |  |  | aria-hidden=true |
| `e13.genres.chip4` | checkbox |  | aria-checked=false |
| `e13.genres.chip4.badge` |  |  | aria-hidden=true |
| `e13.genres.chip5` | checkbox |  | aria-checked=true |
| `e13.genres.chip5.badge` |  |  | aria-hidden=true |
| `e13.genres.chip6` | checkbox |  | aria-checked=false |
| `e13.genres.chip6.badge` |  |  | aria-hidden=true |
| `e13.genres.chip7` | checkbox |  | aria-checked=false |
| `e13.genres.chip7.badge` |  |  | aria-hidden=true |
| `e13.genres.chip8` | checkbox |  | aria-checked=true |
| `e13.genres.chip8.badge` |  |  | aria-hidden=true |
| `e13.genres.chip9` | checkbox |  | aria-checked=false |
| `e13.genres.chip9.badge` |  |  | aria-hidden=true |
| `e13.genres.chip10` | checkbox |  | aria-checked=false |
| `e13.genres.chip10.badge` |  |  | aria-hidden=true |
| `e13.genres.chip11` | checkbox |  | aria-checked=false |
| `e13.genres.chip11.badge` |  |  | aria-hidden=true |
| `e13.genres.chip12` | checkbox |  | aria-checked=false |
| `e13.genres.chip12.badge` |  |  | aria-hidden=true |
| `e13.genres.chip13` | checkbox |  | aria-checked=false |
| `e13.genres.chip13.badge` |  |  | aria-hidden=true |
| `e13.genres.chip14` | checkbox |  | aria-checked=false |
| `e13.genres.chip14.badge` |  |  | aria-hidden=true |
| `e13.genres.chip15` | checkbox |  | aria-checked=false |
| `e13.genres.chip15.badge` |  |  | aria-hidden=true |
| `e13.genres.more.icon` |  |  | aria-hidden=true |
| `e13.continue.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e13.heading.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e13.heading.sparkle` | AppSvg(AppIconsEntrada.sparkleRosa, size: 24) |  |
| `e13.genres.chip1` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip1.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip1.badge.icon` | AppSvg(AppIconsEntrada.checkTinyCreme, size: 14) |  |
| `e13.genres.chip2` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip2.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip2.badge.icon` | AppSvg(AppIconsEntrada.checkTinyCreme, size: 14) |  |
| `e13.genres.chip3` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip3.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip3.badge.icon` | AppSvg(AppIconsEntrada.generoFantasia, size: 15) |  |
| `e13.genres.chip4` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip4.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip4.badge.icon` | AppSvg(AppIconsEntrada.generoFiccaoCientifica, size: 15) |  |
| `e13.genres.chip5` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip5.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip5.badge.icon` | AppSvg(AppIconsEntrada.checkTinyCreme, size: 14) |  |
| `e13.genres.chip6` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip6.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip6.badge.icon` | AppSvg(AppIconsEntrada.eye, size: 15) |  |
| `e13.genres.chip7` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip7.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip7.badge.icon` | AppSvg(AppIconsEntrada.generoTerror, size: 15) |  |
| `e13.genres.chip8` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip8.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip8.badge.icon` | AppSvg(AppIconsEntrada.checkTinyCreme, size: 14) |  |
| `e13.genres.chip9` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip9.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip9.badge.icon` | AppSvg(AppIconsEntrada.generoPoesia, size: 15) |  |
| `e13.genres.chip10` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip10.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip10.badge.icon` | AppSvg(AppIconsEntrada.generoBiografias, size: 15) |  |
| `e13.genres.chip11` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip11.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip11.badge.icon` | AppSvg(AppIconsEntrada.generoHistoria, size: 15) |  |
| `e13.genres.chip12` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip12.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip12.badge.icon` | AppSvg(AppIconsEntrada.generoNaoFiccao, size: 15) |  |
| `e13.genres.chip13` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip13.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip13.badge.icon` | AppSvg(AppIconsEntrada.generoQuadrinhos, size: 15) |  |
| `e13.genres.chip14` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip14.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip14.badge.icon` | AppSvg(AppIconsEntrada.generoJovemAdulto, size: 15) |  |
| `e13.genres.chip15` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.chip15.badge` | CircleIconButton / NeoBox circular |  |
| `e13.genres.chip15.badge.icon` | AppSvg(AppIconsEntrada.generoHumor, size: 15) |  |
| `e13.genres.more` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.genres.more.icon` | AppSvg(AppIconsInicio.plusBold, size: 18) |  |
| `e13.continue` | NeoBox |  |
| `e13.continue.count` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13.continue.icon` | AppSvg(AppIconsEntrada.arrowForward, size: 20) |  |

## Interações

- Gênero → marca e desmarca (checkbox); no mínimo 3: abaixo de 3, o botão fica apagado com "Escolha mais N" (nota do design; o estado apagado não tem prancha — o texto segue a nota).
- Mais gêneros → a lista completa: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T16 (ROTEIRO §2b).
- A lista rola com o botão fixo embaixo.

## Dados

- Os gêneros escolhidos alimentam o "Para você" e as sugestões do passo 3; a lista de gêneros é a da Busca (28).

## Subfases

- **L13.1** Topo com voltar
- **L13.2** Pílulas de gênero (Wrap) com a máscara
- **L13.3** Continuar com a contagem e o mínimo de 3
- **L13.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e13.heading', 'e13.lead', 'e13.genres', 'e13.continue'), todos os ids de `kRef13.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/013_onboarding_generos_390x844@3x.png` no recorte da fase (y 134–818) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef13w360` e `kRef13w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L13.1 Topo com voltar
- [ ] L13.2 Pílulas de gênero (Wrap) com a máscara
- [ ] L13.3 Continuar com a contagem e o mínimo de 3
- [ ] L13.4 Verificação + relatório
- [ ] Geometria 56/56 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
