# FASE L05 — Perfil — o @ e os ajustes, a capa do perfil (avatar com a sequência, nome, bio e números), a carteirinha, Editar/Compartilhar e as abas

> Tela 05 · prancha `005_perfil` (05 · Perfil, canvas 390×2510) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L05_1_capa@3x.png` · `docs/design/medicao/projeto/png/redline/L05_1_capa_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/005_perfil_390x2510@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_005_perfil.json` · `test/reference/projeto/reference_layout_005_perfil.dart` (`kRef05`).
> Arquivos sugeridos: `lib/features/profile/presentation/profile_screen.dart`, `lib/features/profile/presentation/sections/profile_cover.dart`, `lib/features/profile/presentation/sections/library_card.dart`, `lib/features/profile/presentation/sections/profile_tabs.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Perfil (05), em cima: o @ com a engrenagem dos Ajustes, a capa do perfil em forma de livro (lombada, "EDIÇÃO 2026 / LEITORA Nº 0052", o avatar M girado com a sequência, o nome, a bio e os números), a carteirinha de leitora girada, "Editar perfil" e "Compartilhar", e as abas Resumo, Resenhas, Grifos e Listas. A tela entra no lugar do placeholder da aba (`/perfil`, hoje com o bloco da conta, D-69).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`, `{{card}}` = padrão `#FF552E`.

```html
<!-- Top bar -->
<header style="display: flex; align-items: center; justify-content: space-between; height: 48px;">
  <span style="font-size: 15px; font-weight: 800;">@marinacosta</span>
  <button aria-label="Configurações" style="width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"></path></svg>
  </button>
</header>

<!-- The profile as a book cover -->
<section aria-label="Marina Costa" style="position: relative; margin-top: 16px; min-height: 322px; padding: 18px 20px 18px 34px; box-sizing: border-box; border-radius: 8px 26px 26px 8px; background: {{cover}}; border: 1.5px solid #1A1714; box-shadow: 5px 5px 0 #1A1714; display: flex; flex-direction: column; overflow: hidden;">
  <!-- spine and hinge -->
  <span aria-hidden="true" style="position: absolute; left: 0; top: 0; bottom: 0; width: 16px; background: rgba(26,23,20,0.12);"></span>
  <span aria-hidden="true" style="position: absolute; left: 19px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.28);"></span>

  <span style="max-width: 170px; font-size: 10px; font-weight: 800; letter-spacing: 0.14em; line-height: 1.6; color: #2C2452;">EDIÇÃO 2026<br>LEITORA Nº 0052</span>

  <!-- avatar sticker -->
  <div style="position: absolute; top: 26px; right: 22px; width: 100px; height: 100px;">
    <div style="width: 96px; height: 96px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-6deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 60px; line-height: 1; padding-bottom: 6px;">M</div>
    <span aria-label="Sequência de 12 dias" style="position: absolute; left: -12px; bottom: -2px; height: 30px; padding: 0 10px 0 7px; display: flex; align-items: center; gap: 4px; border-radius: 999px; background: #FF552E; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(7deg); font-size: 13px; font-weight: 800;">
      <svg width="15" height="15" viewBox="0 0 24 24" fill="#FED170" stroke="#1A1714" stroke-width="1.8" stroke-linejoin="round" aria-hidden="true"><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.07-2.14-.22-4.05 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.15.43-2.29 1-3a2.5 2.5 0 0 0 2.5 2.5z"></path></svg>
      12
    </span>
  </div>

  <h1 style="margin: 72px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 46px; line-height: 0.92; letter-spacing: -1.6px;">Marina<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 58px; line-height: 0.95; letter-spacing: -0.8px;">Costa</span></h1>
  <p style="margin: 12px 0 0; max-width: 270px; font-size: 14.5px; font-weight: 600; line-height: 1.35; color: #2C2452; text-wrap: pretty;">Clássicos brasileiros, café forte e grifo tudo a lápis.</p>

  <div style="margin-top: 18px; display: flex; align-items: flex-end; justify-content: space-between; gap: 10px;">
    <span style="font-size: 12.5px; font-weight: 600; color: #2C2452; line-height: 1.5;"><strong style="color: #1A1714; font-weight: 800;">248</strong> seguidores · <strong style="color: #1A1714; font-weight: 800;">180</strong> seguindo<br><strong style="color: #1A1714; font-weight: 800;">3</strong> clubes · <strong style="color: #1A1714; font-weight: 800;">52</strong> livros lidos</span>
    <!-- colophon mark -->
    <span aria-hidden="true" style="width: 34px; height: 34px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;">
      <svg width="18" height="18" viewBox="0 0 24 24"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1"></path></svg>
    </span>
  </div>
</section>

<!-- Library card from onboarding: tap opens the full card (share as image) -->
<a href="#" aria-label="Abrir carteirinha de leitora número 0052" style="position: relative; margin-top: 20px; display: block; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; overflow: hidden; transform: rotate(-1.2deg);">
  <span style="height: 28px; padding: 0 12px; background: {{card}}; border-bottom: 1.5px solid #1A1714; display: flex; align-items: center; justify-content: space-between;">
    <span style="font-size: 10px; font-weight: 800; letter-spacing: 1.3px; white-space: nowrap;">CARTEIRINHA DE LEITORA</span>
    <span style="font-size: 10px; font-weight: 800; letter-spacing: 1px; white-space: nowrap; font-variant-numeric: tabular-nums;">Nº 0052</span>
  </span>
  <span style="position: relative; padding: 11px 12px 11px 14px; display: flex; align-items: center; gap: 12px; background: repeating-linear-gradient(180deg, transparent 0 19px, #EFE6D5 19px 20px);">
    <span style="display: flex; flex-direction: column; gap: 3px; flex-shrink: 0;">
      <svg aria-hidden="true" width="92" height="24" viewBox="0 0 92 24"><rect x="0.0" y="0" width="1.6" height="24" fill="#1A1714"></rect><rect x="2.8" y="0" width="1.3" height="24" fill="#1A1714"></rect><rect x="6.3" y="0" width="1.6" height="24" fill="#1A1714"></rect><rect x="10.1" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="12.7" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="15.9" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="18.1" y="0" width="2.2" height="24" fill="#1A1714"></rect><rect x="21.5" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="24.7" y="0" width="2.2" height="24" fill="#1A1714"></rect><rect x="28.1" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="30.3" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="32.9" y="0" width="2.2" height="24" fill="#1A1714"></rect><rect x="36.7" y="0" width="1.6" height="24" fill="#1A1714"></rect><rect x="40.5" y="0" width="2.2" height="24" fill="#1A1714"></rect><rect x="44.9" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="47.1" y="0" width="1.3" height="24" fill="#1A1714"></rect><rect x="50.6" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="53.8" y="0" width="1.6" height="24" fill="#1A1714"></rect><rect x="57.0" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="60.2" y="0" width="1.3" height="24" fill="#1A1714"></rect><rect x="63.1" y="0" width="1.6" height="24" fill="#1A1714"></rect><rect x="65.9" y="0" width="1.6" height="24" fill="#1A1714"></rect><rect x="69.1" y="0" width="2.2" height="24" fill="#1A1714"></rect><rect x="73.5" y="0" width="1.3" height="24" fill="#1A1714"></rect><rect x="76.0" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="78.2" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="81.4" y="0" width="2.2" height="24" fill="#1A1714"></rect><rect x="85.2" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="87.4" y="0" width="1" height="24" fill="#1A1714"></rect><rect x="89.6" y="0" width="1" height="24" fill="#1A1714"></rect></svg>
      <span style="font-size: 8.5px; font-weight: 800; letter-spacing: 1.3px; font-variant-numeric: tabular-nums;">0052 · 2026 · BN</span>
    </span>
    <span aria-hidden="true" style="align-self: stretch; width: 0; border-left: 1.5px dashed #CFC3AE;"></span>
    <span style="min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 2px;">
      <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.1; letter-spacing: -0.3px; white-space: nowrap;">30 min/dia</span>
      <span style="font-size: 12px; font-weight: 600; color: #5B544B; white-space: nowrap;">24 livros em 2026</span>
    </span>
    <svg aria-hidden="true" width="46" height="46" viewBox="0 0 112 112" style="flex-shrink: 0; transform: rotate(-12deg);">
      <circle cx="56" cy="56" r="50" fill="rgba(85,44,183,0.08)" stroke="#552CB7" stroke-width="5"></circle>
      <circle cx="56" cy="56" r="36" fill="none" stroke="#552CB7" stroke-width="3"></circle>
      <path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" transform="translate(32 32) scale(2)" fill="#552CB7"></path>
    </svg>
  </span>
</a>

<!-- Actions -->
<div style="margin-top: 20px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;">
  <button style="height: 48px; display: flex; align-items: center; justify-content: center; gap: 8px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14.5px; font-weight: 800;">
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16v4z"></path><path d="m13.5 6.5 4 4"></path></svg>
    Editar perfil
  </button>
  <button style="height: 48px; display: flex; align-items: center; justify-content: center; gap: 8px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14.5px; font-weight: 800;">
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 15V3M7.5 7.5 12 3l4.5 4.5"></path><path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7"></path></svg>
    Compartilhar
  </button>
</div>

<!-- Profile sections -->
<div role="tablist" aria-label="Seções do perfil" style="margin: 18px -20px 0; padding: 2px 20px 4px; display: flex; gap: 8px; overflow: hidden;">
  <button role="tab" aria-selected="true" style="flex-shrink: 0; height: 42px; padding: 0 16px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800;">Resumo</button>
  <button role="tab" aria-selected="false" style="flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600;">Resenhas <span style="font-size: 12px; font-weight: 700; color: #6F665B;">8</span></button>
  <button role="tab" aria-selected="false" style="flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600;">Grifos <span style="font-size: 12px; font-weight: 700; color: #6F665B;">214</span></button>
  <button role="tab" aria-selected="false" style="flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600;">Listas <span style="font-size: 12px; font-weight: 700; color: #6F665B;">5</span></button>
</div>
```

## Especificação pixel a pixel

Seção `p05.top` — retângulo absoluto no canvas 390×2510: **x=20, y=58, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `p05.top` | box | 0 | 0 | 350 | 48 | `display: flex; align-items: center; justify-content: space-between; height: 48px` |  |
| 2 | `p05.top.handle` ±1 | text | 0 | 15 | 101.28 | 18 | `font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 3 | `p05.top.settings` | box | 302 | 0 | 48 | 48 | `width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 4 | `p05.top.settings.icon` | icon | 315 | 13 | 22 | 22 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.top.handle` | 1 | @marinacosta | 29.25 | 0 | 101.28 | 101.28 |

Seção `p05.hero` — retângulo absoluto no canvas 390×2510: **x=20, y=122, w=350, h=347.07**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `p05.hero` | box | 0 | 0 | 350 | 347.07 | `position: relative; margin-top: 16px; min-height: 322px; padding: 18px 20px 18px 34px; box-sizing: border-box; border-radius: 8px 26px 26px 8px; background: {{cover}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 5px 5px 0 #1A1714; display: flex; flex-direction: column; overflow: hidden` |  |
| 6 | `p05.hero.spine` | box | 1.5 | 1.5 | 16 | 344.07 | `position: absolute; left: 0; top: 0; bottom: 0; width: 16px; background: rgba(26,23,20,0.12)` |  |
| 7 | `p05.hero.spineLine` | box | 20.5 | 1.5 | 1.5 | 344.07 | `position: absolute; left: 19px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.28)` |  |
| 8 | `p05.hero.edition` | text | 35.5 | 19.5 | 170 | 32 | `max-width: 170px; font-size: 10px; font-weight: 800; letter-spacing: 0.14em; line-height: 1.6; color: #2C2452` | Figtree 10/16px peso 800 ls 1.4px #2C2452 |
| 9 | `p05.hero.avatar` | box | 226.5 | 27.5 | 100 | 100 | `position: absolute; top: 26px; right: 22px; width: 100px; height: 100px` |  |
| 10 | `p05.hero.avatar.circle` | box+text | 226.5 | 27.5 | 96 | 96 | `width: 96px; height: 96px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-6deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 60px; line-height: 1; padding-bottom: 6px` | Instrument Serif itálico 60/60px peso 400 ls normal #1A1714 |
| 11 | `p05.hero.avatar.streak` ±1 | box+text | 214.5 | 99.5 | 52.18 | 30 | `position: absolute; left: -12px; bottom: -2px; height: 30px; padding: 0 10px 0 7px; display: flex; align-items: center; gap: 4px; border-radius: 999px; background: #FF552E; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(7deg); font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 12 | `p05.hero.avatar.streak.icon` | icon | 223 | 107 | 15 | 15 | `—` |  |
| 13 | `p05.hero.name` | text | 35.5 | 123.5 | 293 | 97.42 | `margin: 72px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 46px; line-height: 0.92; letter-spacing: -1.6px` | Bricolage (opsz 46) 46/42.32px peso 800 ls -1.6px #1A1714 |
| 14 | `p05.hero.name.serif` ±1 | inline | 35.5 | 155.67 | 108.35 | 75.4 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 58px; line-height: 0.95; letter-spacing: -0.8px` | Instrument Serif itálico 58/55.1px peso 400 ls -0.8px #1A1714 |
| 15 | `p05.hero.bio` | text | 35.5 | 232.92 | 270 | 39.15 | `margin: 12px 0 0; max-width: 270px; font-size: 14.5px; font-weight: 600; line-height: 1.35; color: #2C2452; text-wrap: pretty` | Figtree 14.5/19.575px peso 600 ls normal #2C2452 |
| 16 | `p05.hero.stats` | box | 35.5 | 290.07 | 293 | 37.5 | `margin-top: 18px; display: flex; align-items: flex-end; justify-content: space-between; gap: 10px` |  |
| 17 | `p05.hero.stats.text` ±1 | text | 35.5 | 290.07 | 173.64 | 37.5 | `font-size: 12.5px; font-weight: 600; color: #2C2452; line-height: 1.5` | Figtree 12.5/18.75px peso 600 ls normal #2C2452 |
| 18 | `p05.hero.stats.followers` ±1 | inline | 35.5 | 291.94 | 22.98 | 15.01 | `color: #1A1714; font-weight: 800` | Figtree 12.5/18.75px peso 800 ls normal #1A1714 |
| 19 | `p05.hero.stats.following` ±1 | inline | 132.97 | 291.94 | 21.11 | 15.01 | `color: #1A1714; font-weight: 800` | Figtree 12.5/18.75px peso 800 ls normal #1A1714 |
| 20 | `p05.hero.stats.clubs` ±1 | inline | 35.5 | 310.69 | 7.01 | 15.01 | `color: #1A1714; font-weight: 800` | Figtree 12.5/18.75px peso 800 ls normal #1A1714 |
| 21 | `p05.hero.stats.books` ±1 | inline | 91.69 | 310.69 | 14.65 | 15.01 | `color: #1A1714; font-weight: 800` | Figtree 12.5/18.75px peso 800 ls normal #1A1714 |
| 22 | `p05.hero.stats.arrow` | box | 294.5 | 293.57 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 23 | `p05.hero.stats.arrow.icon` | icon | 302.5 | 301.57 | 18 | 18 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `p05.hero.avatar.circle`: caixa visual com `transform: rotate(-6deg)` = x 221.75, y 22.75, w 105.51, h 105.51 (relativa à seção).
- `p05.hero.avatar.streak`: caixa visual com `transform: rotate(7deg)` = x 212.87, y 96.43, w 55.45, h 36.14 (relativa à seção).
- `p05.hero.avatar.streak.icon`: caixa visual deslocada pelo transform de um ancestral = x 222.22, y 104.91, w 16.72, h 16.72 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.hero.edition` | 1 | EDIÇÃO 2026 | 31 | 35.5 | 115.78 | 80.28 |
| `p05.hero.edition` | 2 | LEITORA Nº 0052 | 47 | 35.5 | 139.41 | 103.91 |
| `p05.hero.avatar.circle` | 1 | M | 92.9 | 254.55 | 294.45 | 39.9 |
| `p05.hero.avatar.streak` | 1 | 12 | 119.05 | 242 | 255.18 | 13.18 |
| `p05.hero.name` *(composto)* | 1 | Marina | 159.84 | 35.5 | 180.3 | 144.8 |
| `p05.hero.name` *(composto)* | 2 | Costa | 213.09 | 35.5 | 143.85 | 108.35 |
| `p05.hero.bio` | 1 | Clássicos brasileiros, café forte e grifo | 247.78 | 35.5 | 286.54 | 251.04 |
| `p05.hero.bio` | 2 | tudo a lápis. | 267.36 | 35.5 | 114.32 | 78.82 |
| `p05.hero.stats.text` *(composto)* | 1 | 248 seguidores · 180 seguindo | 303.82 | 35.5 | 209.14 | 173.64 |
| `p05.hero.stats.text` *(composto)* | 2 | 3 clubes · 52 livros lidos | 322.57 | 35.5 | 169.39 | 133.89 |

Seção `p05.card` — retângulo absoluto no canvas 390×2510: **x=20, y=489.07, w=350, h=100.5**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 24 | `p05.card` | box | 0 | 0 | 350 | 100.5 | `position: relative; margin-top: 20px; display: block; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; overflow: hidden; transform: rotate(-1.2deg)` |  |
| 25 | `p05.card.header` | box | 1.5 | 1.5 | 347 | 29.5 | `height: 28px; padding: 0 12px; background: {{card}} (padrão #FF552E); border-bottom: 1.5px solid #1A1714; display: flex; align-items: center; justify-content: space-between` |  |
| 26 | `p05.card.header.title` ±1 | text | 13.5 | 9.5 | 156.19 | 12 | `font-size: 10px; font-weight: 800; letter-spacing: 1.3px; white-space: nowrap` | Figtree 10/normal peso 800 ls 1.3px #1A1714 |
| 27 | `p05.card.header.number` ±1 | text | 290.39 | 9.5 | 46.11 | 12 | `font-size: 10px; font-weight: 800; letter-spacing: 1px; white-space: nowrap; font-variant-numeric: tabular-nums` | Figtree 10/normal peso 800 ls 1px #1A1714 tnum |
| 28 | `p05.card.body` | box | 1.5 | 31 | 347 | 68 | `position: relative; padding: 11px 12px 11px 14px; display: flex; align-items: center; gap: 12px; background: repeating-linear-gradient(180deg, transparent 0 19px, #EFE6D5 19px 20px)` |  |
| 29 | `p05.card.code` | box | 15.5 | 46.4 | 92 | 37.21 | `display: flex; flex-direction: column; gap: 3px; flex-shrink: 0` |  |
| 30 | `p05.card.code.bars` | icon | 15.5 | 46.4 | 92 | 24 | `—` |  |
| 31 | `p05.card.code.text` | text | 15.5 | 73.4 | 92 | 10.21 | `font-size: 8.5px; font-weight: 800; letter-spacing: 1.3px; font-variant-numeric: tabular-nums` | Figtree 8.5/normal peso 800 ls 1.3px #1A1714 tnum |
| 32 | `p05.card.divider` | box | 119.5 | 42 | 1.5 | 46 | `align-self: stretch; width: 0; border-left: 1.5px dashed #CFC3AE` |  |
| 33 | `p05.card.goals` | box | 133 | 47.45 | 145.5 | 35.1 | `min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 2px` |  |
| 34 | `p05.card.goals.daily` | text | 133 | 47.45 | 145.5 | 18.7 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.1; letter-spacing: -0.3px; white-space: nowrap` | Bricolage (opsz 17) 17/18.7px peso 800 ls -0.3px #1A1714 |
| 35 | `p05.card.goals.yearly` | text | 133 | 68.15 | 145.5 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B; white-space: nowrap` | Figtree 12/normal peso 600 ls normal #5B544B |
| 36 | `p05.card.stamp` | icon | 290.5 | 42 | 46 | 46 | `flex-shrink: 0; transform: rotate(-12deg)` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `p05.card`: caixa visual com `transform: rotate(-1.2deg)` = x -1.01, y -3.65, w 352.03, h 107.81 (relativa à seção).
- `p05.card.header`: caixa visual deslocada pelo transform de um ancestral = x 0.52, y -2.12, w 347.54, h 36.76 (relativa à seção).
- `p05.card.header.title`: caixa visual deslocada pelo transform de um ancestral = x 12.68, y 9.62, w 156.41, h 15.27 (relativa à seção).
- `p05.card.header.number`: caixa visual deslocada pelo transform de um ancestral = x 289.51, y 6.13, w 46.35, h 12.96 (relativa à seção).
- `p05.card.body`: caixa visual deslocada pelo transform de um ancestral = x 1.14, y 27.37, w 348.35, h 75.25 (relativa à seção).
- `p05.card.code`: caixa visual deslocada pelo transform de um ancestral = x 15.45, y 47.81, w 92.76, h 39.13 (relativa à seção).
- `p05.card.code.bars`: caixa visual deslocada pelo transform de um ancestral = x 15.45, y 47.81, w 92.48, h 25.92 (relativa à seção).
- `p05.card.code.text`: caixa visual deslocada pelo transform de um ancestral = x 16.02, y 74.8, w 92.19, h 12.13 (relativa à seção).
- `p05.card.divider`: caixa visual deslocada pelo transform de um ancestral = x 119.34, y 43.13, w 2.46, h 46.02 (relativa à seção).
- `p05.card.goals`: caixa visual deslocada pelo transform de um ancestral = x 132.95, y 45.28, w 146.2, h 38.14 (relativa à seção).
- `p05.card.goals.daily`: caixa visual deslocada pelo transform de um ancestral = x 132.95, y 45.28, w 145.86, h 21.74 (relativa à seção).
- `p05.card.goals.yearly`: caixa visual deslocada pelo transform de um ancestral = x 133.38, y 65.98, w 145.77, h 17.44 (relativa à seção).
- `p05.card.stamp`: caixa visual com `transform: rotate(-12deg)` = x 286.13, y 34.45, w 55.29, h 55.29 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.card.header.title` | 1 | CARTEIRINHA DE LEITORA | 19 | 13.5 | 169.69 | 156.19 |
| `p05.card.header.number` | 1 | Nº 0052 | 19 | 290.39 | 336.5 | 46.11 |
| `p05.card.code.text` | 1 | 0052 · 2026 · BN | 81.47 | 15.5 | 103.76 | 88.26 |
| `p05.card.goals.daily` | 1 | 30 min/dia | 62.41 | 133 | 219.09 | 86.09 |
| `p05.card.goals.yearly` | 1 | 24 livros em 2026 | 79.55 | 133 | 230.63 | 97.63 |

Seção `p05.actions` — retângulo absoluto no canvas 390×2510: **x=20, y=609.57, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 37 | `p05.actions` | box | 0 | 0 | 350 | 48 | `margin-top: 20px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px` |  |
| 38 | `p05.actions.edit` | box+text | 0 | 0 | 170 | 48 | `height: 48px; display: flex; align-items: center; justify-content: center; gap: 8px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14.5px; font-weight: 800` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 39 | `p05.actions.edit.icon` ±1 | icon | 31.85 | 15 | 18 | 18 | `—` |  |
| 40 | `p05.actions.share` | box+text | 180 | 0 | 170 | 48 | `height: 48px; display: flex; align-items: center; justify-content: center; gap: 8px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14.5px; font-weight: 800` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 41 | `p05.actions.share.icon` ±1 | icon | 207.09 | 15 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.actions.edit` | 1 | Editar perfil | 29.07 | 57.85 | 138.15 | 80.3 |
| `p05.actions.share` | 1 | Compartilhar | 29.07 | 233.09 | 322.91 | 89.82 |

Seção `p05.tabs` — retângulo absoluto no canvas 390×2510: **x=0, y=675.57, w=390, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 42 | `p05.tabs` | box | 0 | 0 | 390 | 48 | `margin: 18px -20px 0; padding: 2px 20px 4px; display: flex; gap: 8px; overflow: hidden` |  |
| 43 | `p05.tabs.summary` ±1 | box+text | 20 | 2 | 87.21 | 42 | `flex-shrink: 0; height: 42px; padding: 0 16px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 44 | `p05.tabs.reviews` ±1 | box+text | 115.21 | 2 | 107.88 | 42 | `flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 45 | `p05.tabs.reviews.count` ±1 | text | 200.24 | 15.8 | 7.34 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |
| 46 | `p05.tabs.highlights` ±1 | box+text | 231.09 | 2 | 98.6 | 42 | `flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 47 | `p05.tabs.highlights.count` ±1 | text | 294.58 | 15.8 | 19.61 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |
| 48 | `p05.tabs.lists` ±1 | box+text | 337.69 | 2 | 83.69 | 42 | `flex-shrink: 0; height: 42px; padding: 0 14px 0 16px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 49 | `p05.tabs.lists.count` ±1 | text | 398.9 | 15.8 | 6.97 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.tabs.summary` | 1 | Resumo | 27.9 | 37.5 | 89.71 | 52.21 |
| `p05.tabs.reviews` | 1 | Resenhas | 27.9 | 132.71 | 193.24 | 60.53 |
| `p05.tabs.reviews.count` | 1 | 8 | 27.2 | 200.24 | 207.59 | 7.35 |
| `p05.tabs.highlights` | 1 | Grifos | 27.9 | 248.59 | 287.58 | 38.99 |
| `p05.tabs.highlights.count` | 1 | 214 | 27.2 | 294.58 | 314.19 | 19.61 |
| `p05.tabs.lists` | 1 | Listas | 27.9 | 355.19 | 391.9 | 36.71 |
| `p05.tabs.lists.count` | 1 | 5 *(oculta: recortada)* | 27.2 | 398.9 | 405.88 | 6.98 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Topo de 48: "@marinacosta" 15/800 e o botão "Configurações" (48, `#FFFAF1`, borda 1,5, sem sombra, engrenagem 22 traço 1,8).
2. Capa 16 abaixo: `min-height 322`, padding 18/20/18/34, raio 8/26/26/8, `{{cover}}`, borda 1,5, sombra 5/5, `overflow: hidden`; a lombada (16 de largura, preto a 0,12) e o vinco (1,5 em `left 19`, preto a 0,28).
3. "EDIÇÃO 2026 / LEITORA Nº 0052" 10/800 ls 0,14em `lh 1,6` `#2C2452`, `max-width 170`; o avatar em `top 26 · right 22`: o círculo 96 `#FED170` (borda 1,5, sombra 3/3) girado −6° com o "M" Instrument Serif itálico 60 e a pílula coral da sequência (30 de altura, sombra 2/2, girada 7°, o fogo e "12" 13/800) em `left −12 · bottom −2`.
4. Nome 72 abaixo: "Marina" Bricolage 46/800 `lh 0,92` ls −1,6 + quebra + "Costa" Instrument Serif itálico 58 `lh 0,95` ls −0,8; a bio 14,5/600 `lh 1,35` `#2C2452`, `max-width 270`, `text-wrap: pretty`, 12 abaixo.
5. Números 18 abaixo, pela base com o colofão (o círculo preto 34): 12,5/600 `lh 1,5` `#2C2452` com os números em 800 preto, em duas linhas ("248 seguidores · 180 seguindo" / "3 clubes · 52 livros lidos").
6. Carteirinha 20 abaixo, girada −1,2°: raio 16, `#FFFAF1`, borda 1,5, sombra 4/4; a faixa de 28 em `{{card}}` ("CARTEIRINHA DE LEITORA" e "Nº 0052" 10/800, `tnum`); o corpo pautado (`repeating-linear-gradient`, uma linha `#EFE6D5` a cada 20) com o código de barras 92 × 24, "0052 · 2026 · BN" 8,5/800, o tracejado vertical, "30 min/dia" Bricolage 17/800, "24 livros em 2026" 12/600 e o carimbo 46 girado −12°.
7. Botões 20 abaixo, em grade de 2 (gap 10): pílulas de 48, `#FFFAF1`, borda 1,5, 14,5/800 com o ícone.
8. Abas 18 abaixo (`tablist`, margem −20 até as bordas, padding 2/20/4, gap 8, `overflow: hidden`): pílulas de 42, 14/600 com a contagem 12/700 `#6F665B`; a escolhida `{{brand}}` 14/800, borda 1,5 preta e sombra 2/2; as outras com a borda `#E2D7C4`.
9. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A aba Listas já passa da tela a 390 (31,38, e 61,38 a 360) e a contagem dela some sob o `overflow` (abaixo): no app, abas que rolam (`TabBar(isScrollable: true)`, a nota do design), paradas no começo como a prancha.
- A capa tem altura mínima (322) e cresce com a bio: o avatar é absoluto e não empurra o nome (o nome desce 72 fixos). A 360 o "EDIÇÃO 2026" invade o avatar em 9 (abaixo): o app reproduz o CSS.
- A linha de números dá a largura da própria caixa (o `<span>` cresce com ela, D-280): não é fio de navalha.
- A carteirinha girada −1,2° desenha fora da própria caixa (a referência guarda a caixa sem o giro e a visível); o toque segue a caixa girada.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `p05.tabs.lists.count`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_005_perfil_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_005_perfil_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `p05.tabs.lists` | sai do quadro (x) | 61.38 | 31.38 | não | sim |  |
| 360 | `p05.tabs.lists` | passa do pai (x) | 61.38 | 31.38 | não | sim | pai `p05.tabs` (cortado) |
| 360 | `p05.hero.edition` | invade o vizinho (x) | 9 | 0 | **sim** | sim | vizinho `p05.hero.avatar` |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `p05.top.settings` |  | Configurações |  |
| `p05.hero` |  | Marina Costa |  |
| `p05.hero.spine` |  |  | aria-hidden=true |
| `p05.hero.spineLine` |  |  | aria-hidden=true |
| `p05.hero.avatar.streak` |  | Sequência de 12 dias |  |
| `p05.hero.avatar.streak.icon` |  |  | aria-hidden=true |
| `p05.hero.stats.arrow` |  |  | aria-hidden=true |
| `p05.card` |  | Abrir carteirinha de leitora número 0052 |  |
| `p05.card.code.bars` |  |  | aria-hidden=true |
| `p05.card.divider` |  |  | aria-hidden=true |
| `p05.card.stamp` |  |  | aria-hidden=true |
| `p05.actions.edit.icon` |  |  | aria-hidden=true |
| `p05.actions.share.icon` |  |  | aria-hidden=true |
| `p05.tabs` | tablist | Seções do perfil |  |
| `p05.tabs.summary` | tab |  | aria-selected=true |
| `p05.tabs.reviews` | tab |  | aria-selected=false |
| `p05.tabs.highlights` | tab |  | aria-selected=false |
| `p05.tabs.lists` | tab |  | aria-selected=false |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `p05.top.settings` | CircleIconButton / NeoBox circular |  |
| `p05.top.settings.icon` | AppSvg(AppIconsPerfil.settings, size: 22) |  |
| `p05.hero` | NeoBox |  |
| `p05.hero.spine` | NeoBox |  |
| `p05.hero.spineLine` | NeoBox |  |
| `p05.hero.avatar.circle` | CircleIconButton / NeoBox circular | Transform: rotate(-6deg) |
| `p05.hero.avatar.streak` | Pill / CountBadge (NeoBox com raio de pílula + AppText) | Transform: rotate(7deg) |
| `p05.hero.avatar.streak.icon` | AppSvg(AppIconsPerfil.flameFilled, size: 15) |  |
| `p05.hero.name.serif` | TextSpan dentro do AppText.rich do pai |  |
| `p05.hero.stats.followers` | TextSpan dentro do AppText.rich do pai |  |
| `p05.hero.stats.following` | TextSpan dentro do AppText.rich do pai |  |
| `p05.hero.stats.clubs` | TextSpan dentro do AppText.rich do pai |  |
| `p05.hero.stats.books` | TextSpan dentro do AppText.rich do pai |  |
| `p05.hero.stats.arrow` | CircleIconButton / NeoBox circular |  |
| `p05.hero.stats.arrow.icon` | AppSvg(AppIconsInicio.sparkleSolidCream, size: 18) |  |
| `p05.card` | NeoBox | Transform: rotate(-1.2deg) |
| `p05.card.header` | NeoBox |  |
| `p05.card.body` | HatchPainter (hachura 135°) dentro do contorno |  |
| `p05.card.code.bars` | AppSvg(AppIllustrationsPerfil.codigoBarrasCarteirinhaPerfil, size: 92×24) |  |
| `p05.card.divider` | NeoBox |  |
| `p05.card.stamp` | AppSvg(AppIllustrationsPerfil.carimboCarteirinhaPerfil, size: 46×46) |  |
| `p05.actions.edit` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p05.actions.edit.icon` | AppSvg(AppIconsInicio.pencilEdit, size: 18) |  |
| `p05.actions.share` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p05.actions.share.icon` | AppSvg(AppIconsLeitor.share, size: 18) |  |
| `p05.tabs.summary` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p05.tabs.reviews` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p05.tabs.highlights` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p05.tabs.lists` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |

## Interações

- Engrenagem → os Ajustes (06), empilhados dentro da aba Perfil (a navegação continua: a 06 mostra a nav).
- Editar perfil → a 64. Compartilhar → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b) (ou a folha do sistema com o link do perfil, se a T17 decidir).
- Carteirinha → Carteirinha aberta (compartilhar como imagem): tela que falta (D-268), da própria T17 — perguntar, buscar 3–5 referências, desenhar a prancha em `docs/design/novas/` e esperar o "sim" antes do Flutter (ROTEIRO §5).
- "248 seguidores" e "180 seguindo" → Seguidores e Seguindo (89, 90), da T22: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).
- "3 clubes" → a aba Clubes; "52 livros lidos" → a Biblioteca (02) com o filtro Lido (os dois existem na T17) — confirmar na pergunta da T17.
- Abas Resenhas, Grifos e Listas → as abas 43, 44 e 45, da T20; a nota do design pede `NestedScrollView` com a capa colapsando e as abas presas, que a T20 completa: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).

## Dados

- O @ e o nome são os da conta (`AccountSummary`); a bio, os números e a sequência, do perfil (`ProfileFull`, `social_models.dart`); seguidores e seguindo, do social (`follow_repository.dart`). O nº da leitora e o ano da carteirinha são os do cadastro (a 16 da T16); a meta diária e os livros do ano vêm das metas (`ReadingGoals`).
- A cor da capa (`{{cover}}`) e o avatar (inicial ou foto) são escolhas da 64; a cor da carteirinha (`{{card}}`) é a do cadastro (a 16).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L05.1** Topo e capa do perfil (lombada, avatar com a sequência, nome, bio e números)
- **L05.2** Carteirinha de leitora
- **L05.3** Editar perfil e Compartilhar
- **L05.4** Abas
- **L05.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('p05.top', 'p05.hero', 'p05.card', 'p05.actions', 'p05.tabs'), todos os ids de `kRef05.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/005_perfil_390x2510@3x.png` no recorte da fase (y 50–731.57) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef05w360` e `kRef05w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L05.1 Topo e capa do perfil (lombada, avatar com a sequência, nome, bio e números)
- [ ] L05.2 Carteirinha de leitora
- [ ] L05.3 Editar perfil e Compartilhar
- [ ] L05.4 Abas
- [ ] L05.5 Verificação + relatório
- [ ] Geometria 44/44 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
