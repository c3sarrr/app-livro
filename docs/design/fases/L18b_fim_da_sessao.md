# FASE L18b — Fim da sessão — o escurecido, os confetes e a folha (o selo, o título, os três números, a página onde parou, salvar e pular)

> Tela 18b · prancha `018b_fim_da_sessao` (18b · Fim da sessão (página opcional), canvas 390×844) · executada na **T18** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L18b_fim_da_sessao@3x.png` · `docs/design/medicao/projeto/png/redline/L18b_fim_da_sessao_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/018b_fim_da_sessao_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_018b_fim_da_sessao.json` · `test/reference/projeto/reference_layout_018b_fim_da_sessao.dart` (`kRef18b`).
> Arquivos sugeridos: `lib/features/reading_session/presentation/timer/end_session_sheet.dart`, `lib/features/reading_session/presentation/timer/goal_stamp.dart`, `lib/features/reading_session/application/paper_end_form.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Fim da sessão (18b): o cronômetro por baixo do escurecido, os confetes e a folha — o selo verde "meta do dia batida" girado saindo da borda, "SESSÃO ENCERRADA", "12 minutos e meta batida!", os três números (12:31 nesta sessão, 30/30 min hoje, 12 dias seguidos), a página onde parou com menos e mais, "Salvar sessão" e "Pular a página".

---

## HTML literal da seção

Props do componente: `{{arc}}` = padrão `#FED170`, `{{goal}}` = padrão `#ABCF82`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- scrim over the timer -->
<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(12,10,8,0.62); z-index: 2;"></div>

<svg aria-hidden="true" width="22" height="22" viewBox="0 0 24 24" style="position: absolute; left: 40px; top: 120px; z-index: 3;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170" stroke="#1A1714" stroke-width="1.4"></path></svg>

<svg aria-hidden="true" width="16" height="16" viewBox="0 0 24 24" style="position: absolute; left: 318px; top: 96px; z-index: 3;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#ABCF82" stroke="#1A1714" stroke-width="1.4"></path></svg>

<svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" style="position: absolute; left: 190px; top: 150px; z-index: 3;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFC1C6" stroke="#1A1714" stroke-width="1.4"></path></svg>

<span aria-hidden="true" style="position: absolute; left: 110px; top: 200px; width: 26px; height: 8px; border-radius: 4px; background: #B6ACE4; border: 1.5px solid #1A1714; transform: rotate(-20deg); z-index: 3;"></span>

<span aria-hidden="true" style="position: absolute; left: 270px; top: 186px; width: 12px; height: 12px; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; z-index: 3;"></span>

<!-- End-of-session sheet -->
<section role="dialog" aria-modal="true" aria-labelledby="fim-title" style="position: absolute; left: 0; right: 0; bottom: 0; z-index: 4; padding: 12px 20px 34px; border-radius: 32px 32px 0 0; background: #FFFAF1; border-top: 1.5px solid #1A1714; box-sizing: border-box; color: #1A1714;">
  <span aria-hidden="true" style="display: block; width: 44px; height: 5px; margin: 0 auto; border-radius: 3px; background: #CFC3AE;"></span>

  <!-- goal stamp -->
  <svg aria-hidden="true" width="104" height="104" viewBox="0 0 112 112" style="position: absolute; right: 18px; top: -46px; transform: rotate(10deg);">
    <defs><path id="fim-ring" d="M56 56m-38 0a38 38 0 1 1 76 0a38 38 0 1 1-76 0"></path></defs>
    <circle cx="59" cy="59" r="50" fill="#1A1714"></circle>
    <circle cx="56" cy="56" r="50" fill="{{goal}}" stroke="#1A1714" stroke-width="2"></circle>
    <circle cx="56" cy="56" r="26" fill="#FFFAF1" stroke="#1A1714" stroke-width="2"></circle>
    <text font-family="Figtree, sans-serif" font-size="10.5" font-weight="900" fill="#1A1714" letter-spacing="1"><textPath href="#fim-ring" textLength="232" lengthAdjust="spacing">META DO DIA · BATIDA · META DO DIA ·</textPath></text>
    <path d="m44 57 8 8 17-18" fill="none" stroke="#1A1714" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"></path>
  </svg>

  <div style="margin-top: 16px; font-size: 11.5px; font-weight: 800; letter-spacing: 1.6px; color: #6F665B;">SESSÃO ENCERRADA</div>
  <h1 id="fim-title" style="margin: 6px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px;">12 minutos<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px;">e meta batida!</span></h1>

  <div style="margin-top: 18px; display: flex; gap: 8px;">
    <div style="flex: 1 1 0; min-width: 0; padding: 12px 10px 11px; border-radius: 18px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px;">
        <span style="width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path><path d="M12 2.5V6"></path></svg></span>
        <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1; letter-spacing: -0.5px; white-space: nowrap; font-variant-numeric: tabular-nums;">12:31</span>
        <span style="font-size: 12px; font-weight: 700; line-height: 1.25; color: #3E3832;">nesta sessão</span>
      </div>
    <div style="flex: 1 1 0; min-width: 0; padding: 12px 10px 11px; border-radius: 18px; background: {{goal}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px;">
        <span style="width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1; letter-spacing: -0.5px; white-space: nowrap; font-variant-numeric: tabular-nums;">30/30</span>
        <span style="font-size: 12px; font-weight: 700; line-height: 1.25; color: #3E3832;">min hoje</span>
      </div>
    <div style="flex: 1 1 0; min-width: 0; padding: 12px 10px 11px; border-radius: 18px; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px;">
        <span style="width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.07-2.14-.22-4.05 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.15.43-2.29 1-3a2.5 2.5 0 0 0 2.5 2.5z"></path></svg></span>
        <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1; letter-spacing: -0.5px; white-space: nowrap; font-variant-numeric: tabular-nums;">12 dias</span>
        <span style="font-size: 12px; font-weight: 700; line-height: 1.25; color: #3E3832;">seguidos</span>
      </div>
  </div>

  <!-- optional page -->
  <div style="margin-top: 20px; display: flex; align-items: center; justify-content: space-between; gap: 10px;">
    <label for="fim-page" style="font-size: 15px; font-weight: 800;">Em que página você parou?</label>
    <span style="height: 22px; padding: 0 8px; border-radius: 999px; border: 1.5px solid #CFC3AE; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800; color: #5B544B; flex-shrink: 0;">Opcional</span>
  </div>
  <div style="margin-top: 10px; display: flex; align-items: center; gap: 10px;">
    <button aria-label="Página anterior" style="width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.6" stroke-linecap="round"><path d="M6 12h12"></path></svg></button>
    <div style="flex-grow: 1; height: 64px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}}; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px;">
      <span style="font-size: 14px; font-weight: 700; color: #6F665B;">pág.</span>
      <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 38px; line-height: 1; letter-spacing: -1px; font-variant-numeric: tabular-nums;">88</span>
      <input id="fim-page" type="number" inputmode="numeric" value="88" style="position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none;">
    </div>
    <button aria-label="Próxima página" style="width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="2.6" stroke-linecap="round"><path d="M6 12h12M12 6v12"></path></svg></button>
  </div>
  <p style="margin: 10px 0 0; text-align: center; font-size: 13px; font-weight: 600; color: #5B544B;">Antes: pág. 74 · <strong style="color: #1A1714; font-weight: 800;">+14 páginas</strong> hoje</p>

  <button style="margin-top: 18px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
    <span style="color: #F7F0E3;">Salvar sessão</span>
  </button>
  <button style="margin-top: 6px; width: 100%; height: 44px; border: none; background: transparent; font-size: 14.5px; font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px;">Pular a página</button>
</section>
```

## Especificação pixel a pixel

Seção `cr18b.scrim` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `cr18b.scrim` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; background: rgba(12,10,8,0.62); z-index: 2` |  |

Seção `cr18b.confetti` — retângulo absoluto no canvas 390×844: **x=40, y=96, w=294, h=115**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `cr18b.confetti.sparkle1` | icon | 0 | 24 | 22 | 22 | `position: absolute; left: 40px; top: 120px; z-index: 3` |  |
| 3 | `cr18b.confetti.sparkle2` | icon | 278 | 0 | 16 | 16 | `position: absolute; left: 318px; top: 96px; z-index: 3` |  |
| 4 | `cr18b.confetti.sparkle3` | icon | 150 | 54 | 18 | 18 | `position: absolute; left: 190px; top: 150px; z-index: 3` |  |
| 5 | `cr18b.confetti.dashLavender` | box | 70 | 104 | 29 | 11 | `position: absolute; left: 110px; top: 200px; width: 26px; height: 8px; border-radius: 4px; background: #B6ACE4; border: 1.5px solid #1A1714; transform: rotate(-20deg); z-index: 3` |  |
| 6 | `cr18b.confetti.dotCoral` | box | 230 | 90 | 15 | 15 | `position: absolute; left: 270px; top: 186px; width: 12px; height: 12px; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; z-index: 3` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `cr18b.confetti.dashLavender`: caixa visual com `transform: rotate(-20deg)` = x 68.99, y 99.37, w 31.01, h 20.25 (relativa à seção).

Seção `cr18b.sheet` — retângulo absoluto no canvas 390×844: **x=0, y=297.57, w=390, h=546.43**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 7 | `cr18b.sheet` | box | 0 | 0 | 390 | 546.43 | `position: absolute; left: 0; right: 0; bottom: 0; z-index: 4; padding: 12px 20px 34px; border-radius: 32px 32px 0 0; background: #FFFAF1; border-top: 1.5px solid #1A1714; box-sizing: border-box; color: #1A1714` |  |
| 8 | `cr18b.sheet.handle` | box | 173 | 13.5 | 44 | 5 | `display: block; width: 44px; height: 5px; margin: 0 auto; border-radius: 3px; background: #CFC3AE` |  |
| 9 | `cr18b.sheet.stamp` | icon | 268 | -44.5 | 104 | 104 | `position: absolute; right: 18px; top: -46px; transform: rotate(10deg)` |  |
| 10 | `cr18b.sheet.label` | text | 20 | 34.5 | 350 | 13.81 | `margin-top: 16px; font-size: 11.5px; font-weight: 800; letter-spacing: 1.6px; color: #6F665B` | Figtree 11.5/normal peso 800 ls 1.6px #6F665B |
| 11 | `cr18b.sheet.title` | text | 20 | 54.31 | 350 | 72.52 | `margin: 6px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 32) 32/31.36px peso 800 ls -1px #1A1714 |
| 12 | `cr18b.sheet.title.serif` ±1 | inline | 20 | 78.95 | 212.93 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.4px #1A1714 |
| 13 | `cr18b.sheet.stats` | box | 20 | 144.83 | 350 | 104 | `margin-top: 18px; display: flex; gap: 8px` |  |
| 14 | `cr18b.sheet.stats.session` | box | 20 | 144.83 | 111.33 | 104 | `flex: 1 1 0; min-width: 0; padding: 12px 10px 11px; border-radius: 18px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px` |  |
| 15 | `cr18b.sheet.stats.session.icon` | box | 31.5 | 158.33 | 30 | 30 | `width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 16 | `cr18b.sheet.stats.session.icon.art` | icon | 38.5 | 165.33 | 16 | 16 | `—` |  |
| 17 | `cr18b.sheet.stats.session.value` | text | 31.5 | 194.33 | 88.33 | 21 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1; letter-spacing: -0.5px; white-space: nowrap; font-variant-numeric: tabular-nums` | Bricolage (opsz 21) 21/21px peso 800 ls -0.5px #1A1714 tnum |
| 18 | `cr18b.sheet.stats.session.label` | text | 31.5 | 221.33 | 88.33 | 15 | `font-size: 12px; font-weight: 700; line-height: 1.25; color: #3E3832` | Figtree 12/15px peso 700 ls normal #3E3832 |
| 19 | `cr18b.sheet.stats.today` | box | 139.33 | 144.83 | 111.33 | 104 | `flex: 1 1 0; min-width: 0; padding: 12px 10px 11px; border-radius: 18px; background: {{goal}} (padrão #ABCF82); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px` |  |
| 20 | `cr18b.sheet.stats.today.icon` | box | 150.83 | 158.33 | 30 | 30 | `width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 21 | `cr18b.sheet.stats.today.icon.art` | icon | 157.83 | 165.33 | 16 | 16 | `—` |  |
| 22 | `cr18b.sheet.stats.today.value` | text | 150.83 | 194.33 | 88.33 | 21 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1; letter-spacing: -0.5px; white-space: nowrap; font-variant-numeric: tabular-nums` | Bricolage (opsz 21) 21/21px peso 800 ls -0.5px #1A1714 tnum |
| 23 | `cr18b.sheet.stats.today.label` | text | 150.83 | 221.33 | 88.33 | 15 | `font-size: 12px; font-weight: 700; line-height: 1.25; color: #3E3832` | Figtree 12/15px peso 700 ls normal #3E3832 |
| 24 | `cr18b.sheet.stats.streak` | box | 258.67 | 144.83 | 111.33 | 104 | `flex: 1 1 0; min-width: 0; padding: 12px 10px 11px; border-radius: 18px; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px` |  |
| 25 | `cr18b.sheet.stats.streak.icon` | box | 270.17 | 158.33 | 30 | 30 | `width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 26 | `cr18b.sheet.stats.streak.icon.art` | icon | 277.17 | 165.33 | 16 | 16 | `—` |  |
| 27 | `cr18b.sheet.stats.streak.value` | text | 270.17 | 194.33 | 88.33 | 21 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1; letter-spacing: -0.5px; white-space: nowrap; font-variant-numeric: tabular-nums` | Bricolage (opsz 21) 21/21px peso 800 ls -0.5px #1A1714 tnum |
| 28 | `cr18b.sheet.stats.streak.label` | text | 270.17 | 221.33 | 88.33 | 15 | `font-size: 12px; font-weight: 700; line-height: 1.25; color: #3E3832` | Figtree 12/15px peso 700 ls normal #3E3832 |
| 29 | `cr18b.sheet.pageHeader` | box | 20 | 268.83 | 350 | 22 | `margin-top: 20px; display: flex; align-items: center; justify-content: space-between; gap: 10px` |  |
| 30 | `cr18b.sheet.pageHeader.label` ±1 | text | 20 | 270.83 | 191.04 | 18 | `font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 31 | `cr18b.sheet.pageHeader.optional` ±1 | box+text | 305.09 | 268.83 | 64.91 | 22 | `height: 22px; padding: 0 8px; border-radius: 999px; border: 1.5px solid #CFC3AE; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800; color: #5B544B; flex-shrink: 0` | Figtree 11/normal peso 800 ls normal #5B544B |
| 32 | `cr18b.sheet.page` | box | 20 | 300.83 | 350 | 64 | `margin-top: 10px; display: flex; align-items: center; gap: 10px` |  |
| 33 | `cr18b.sheet.page.prev` | box | 20 | 306.83 | 52 | 52 | `width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 34 | `cr18b.sheet.page.prev.icon` | icon | 37 | 323.83 | 18 | 18 | `—` |  |
| 35 | `cr18b.sheet.page.field` | box | 82 | 300.83 | 226 | 64 | `flex-grow: 1; height: 64px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}} (padrão #B6ACE4); box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px` |  |
| 36 | `cr18b.sheet.page.field.prefix` ±1 | text | 154.78 | 324.43 | 27.69 | 16.8 | `font-size: 14px; font-weight: 700; color: #6F665B` | Figtree 14/normal peso 700 ls normal #6F665B |
| 37 | `cr18b.sheet.page.field.value` ±1 | text | 190.48 | 313.83 | 44.74 | 38 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 38px; line-height: 1; letter-spacing: -1px; font-variant-numeric: tabular-nums` | Bricolage (opsz 38) 38/38px peso 800 ls -1px #1A1714 tnum |
| 38 | `cr18b.sheet.page.field.input` | box | 190.5 | 329.33 | 9 | 7 | `position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none` |  |
| 39 | `cr18b.sheet.page.next` | box | 318 | 306.83 | 52 | 52 | `width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 40 | `cr18b.sheet.page.next.icon` | icon | 335 | 323.83 | 18 | 18 | `—` |  |
| 41 | `cr18b.sheet.progress` | text | 20 | 374.83 | 350 | 15.6 | `margin: 10px 0 0; text-align: center; font-size: 13px; font-weight: 600; color: #5B544B` | Figtree 13/normal peso 600 ls normal #5B544B |
| 42 | `cr18b.sheet.progress.added` ±1 | inline | 191.87 | 374.83 | 72.19 | 15.6 | `color: #1A1714; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 43 | `cr18b.sheet.save` | box | 20 | 408.43 | 350 | 54 | `margin-top: 18px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 44 | `cr18b.sheet.save.label` ±1 | text | 145.06 | 425.83 | 99.88 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 45 | `cr18b.sheet.skip` | text | 20 | 468.43 | 350 | 44 | `margin-top: 6px; width: 100%; height: 44px; border: none; background: transparent; font-size: 14.5px; font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px` | Figtree 14.5/normal peso 800 ls normal #1A1714 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `cr18b.sheet.stamp`: caixa visual com `transform: rotate(10deg)` = x 259.76, y -52.74, w 120.48, h 120.48 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `cr18b.sheet.label` | 1 | SESSÃO ENCERRADA | 45.43 | 20 | 164.2 | 144.2 |
| `cr18b.sheet.title` *(composto)* | 1 | 12 minutos | 80.55 | 20 | 175.24 | 155.24 |
| `cr18b.sheet.title` *(composto)* | 2 | e meta batida! | 120.53 | 20 | 232.93 | 212.93 |
| `cr18b.sheet.stats.session.value` | 1 | 12:31 | 211.76 | 31.5 | 86.98 | 55.48 |
| `cr18b.sheet.stats.session.label` | 1 | nesta sessão | 233.03 | 31.5 | 101.24 | 69.74 |
| `cr18b.sheet.stats.today.value` | 1 | 30/30 | 211.76 | 150.83 | 208.46 | 57.63 |
| `cr18b.sheet.stats.today.label` | 1 | min hoje | 233.03 | 150.83 | 198.06 | 47.23 |
| `cr18b.sheet.stats.streak.value` | 1 | 12 dias | 211.76 | 270.17 | 340.82 | 70.65 |
| `cr18b.sheet.stats.streak.label` | 1 | seguidos | 233.03 | 270.17 | 319.28 | 49.11 |
| `cr18b.sheet.pageHeader.label` | 1 | Em que página você parou? | 285.08 | 20 | 211.04 | 191.04 |
| `cr18b.sheet.pageHeader.optional` | 1 | Opcional | 283.68 | 314.59 | 360.5 | 45.91 |
| `cr18b.sheet.page.field.prefix` | 1 | pág. | 337.73 | 154.78 | 182.48 | 27.7 |
| `cr18b.sheet.page.field.value` | 1 | 88 | 345.37 | 190.48 | 235.22 | 44.74 |
| `cr18b.sheet.progress` *(composto)* | 1 | Antes: pág. 74 · +14 páginas hoje | 387.18 | 97.08 | 292.92 | 195.84 |
| `cr18b.sheet.save.label` | 1 | Salvar sessão | 441.03 | 145.06 | 244.94 | 99.88 |
| `cr18b.sheet.skip` | 1 | Pular a página | 495.51 | 147.66 | 242.34 | 94.68 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Por baixo, a 18 inteira com o tempo 12:31 e "Hoje: 30 de 30 min" (a tabela "Diferenças"); o escurecido (`#0C0A08` a 0,62) e os confetes (as três estrelinhas e os dois pedaços, soltos no quadro).
2. Folha (`left/right/bottom 0`, `z-index 4`): padding 12/20/34, raio 32/32/0/0, `#FFFAF1`, só a borda de cima 1,5; a alça 44 × 5 `#CFC3AE`; o selo 104 (viewBox 112) em `right 18 · top −46`, girado 10°.
3. "SESSÃO ENCERRADA" 11,5/800 ls 1,6 `#6F665B`, 16 abaixo; "12 minutos" Bricolage 32/800 `lh 0,98` ls −1 + quebra + "e meta batida!" Instrument Serif itálico 42, 6 abaixo.
4. Números 18 abaixo (gap 8, `flex 1 1 0`): padding 12/10/11, raio 18, borda 1,5 (`#F7F0E3`, `{{goal}}`, coral), o ícone num círculo 30, o valor Bricolage 21/800 `nowrap` `tnum` e o rótulo 12/700 `#3E3832`.
5. Página 20 abaixo: "Em que página você parou?" 15/800 e "Opcional" (22, borda 1,5 `#CFC3AE`, 11/800); a fileira (gap 10, 10 abaixo): menos (52, `#FFFAF1`), o campo de 64 (raio 18, borda 1,5, o anel `{{brand}}` de 4) com "pág." 14/700 e o "88" Bricolage 38/800 `tnum`, e mais (52, preto).
6. "Antes: pág. 74 · +14 páginas hoje" 13/600 centrado, 10 abaixo; "Salvar sessão" (54, preto, 16/800), 18 abaixo; "Pular a página" (44, sem fundo, 14,5/800 sublinhado), 6 abaixo.
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A 18b não é outra tela: a folha abre por cima do cronômetro, que fica igual por baixo do escurecido. Por baixo da folha a etiqueta ainda diz "Faltam 4 min para a meta" — fica escondida, e no app vale o estado real.
- O tempo usa algarismos tabulares (`font-variant-numeric: tabular-nums`; no app, `withTabularFigures()`, D-282): 08:42 e 12:31 têm a mesma largura (184,25). O número do "Hoje" não: o "30" é 0,54 mais largo que o "26" e a linha continua centrada. Os três números da folha e o da página também são `tnum`.
- O input da página é de 1 px e invisível, mas o navegador dá a ele a borda e o recuo padrão (9 × 7) e, absoluto num flex sem posição, o põe no centro do campo: o número mostrado é um `<span>`, não o input. No app, um `TextField` estilizado com o número, sem a caixa de 1 px.
- O selo, a capa e o pedaço lilás dos confetes são girados (a referência guarda a caixa sem o giro e a visível, `vis`); o texto em curva do selo ("META DO DIA · BATIDA") fica no desenho (`<textPath>`, o mapa de widgets).
- A borda de cima da folha com o raio só em cima faz o Skia do Chromium desenhar um bloco no canto em alguns zooms (R3): a referência foi conferida por faixa (`convergenciaFaixa`, y 290–335) — no app não há o defeito.
- As três cores com nome da prancha (`meta.props`): `arc` #FED170 (o arco do anel e a etiqueta da meta), `goal` #ABCF82 (o selo e o cartão de hoje) e `brand` #B6ACE4 (o anel de 4 em volta do campo da página) — no app vêm dos tokens.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_018b_fim_da_sessao_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_018b_fim_da_sessao_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 18 (seções reutilizadas: top, book, timer, chips, controls, note, lockHint)

Estas seções são as mesmas widgets da 18 (fases L18_1_topo_e_tempo, L18_2_controles); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `cr18b.timer.time` | texto «08:42» → «12:31» |
| `cr18b.timer.today` | retângulo ['134.8', '403.5', '120.4', '16.8'] → ['134.53', '403.5', '120.95', '16.8']; texto «Hoje: 26 de 30 min» → «Hoje: 30 de 30 min» |
| `cr18b.timer.today.minutes` | retângulo ['172.42', '403.5', '16.44', '16.8'] → ['172.15', '403.5', '16.98', '16.8']; texto «26» → «30» |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `cr18b.scrim` |  |  | aria-hidden=true |
| `cr18b.confetti.sparkle1` |  |  | aria-hidden=true |
| `cr18b.confetti.sparkle2` |  |  | aria-hidden=true |
| `cr18b.confetti.sparkle3` |  |  | aria-hidden=true |
| `cr18b.confetti.dashLavender` |  |  | aria-hidden=true |
| `cr18b.confetti.dotCoral` |  |  | aria-hidden=true |
| `cr18b.sheet` | dialog |  | aria-modal=true, aria-labelledby=fim-title |
| `cr18b.sheet.handle` |  |  | aria-hidden=true |
| `cr18b.sheet.stamp` |  |  | aria-hidden=true |
| `cr18b.sheet.stats.session.icon.art` |  |  | aria-hidden=true |
| `cr18b.sheet.stats.today.icon.art` |  |  | aria-hidden=true |
| `cr18b.sheet.stats.streak.icon.art` |  |  | aria-hidden=true |
| `cr18b.sheet.page.prev` |  | Página anterior |  |
| `cr18b.sheet.page.next` |  | Próxima página |  |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `cr18b.scrim` | NeoBox |  |
| `cr18b.confetti.sparkle1` | AppSvg(AppIconsInicio.sparklePreview, size: 22) |  |
| `cr18b.confetti.sparkle2` | AppSvg(AppIconsCronometro.sparklePreviaVerde, size: 16) |  |
| `cr18b.confetti.sparkle3` | AppSvg(AppIconsCronometro.sparklePreviaRosa, size: 18) |  |
| `cr18b.confetti.dashLavender` | NeoBox | Transform: rotate(-20deg) |
| `cr18b.confetti.dotCoral` | CircleIconButton / NeoBox circular |  |
| `cr18b.sheet` | NeoBox |  |
| `cr18b.sheet.handle` | NeoBox |  |
| `cr18b.sheet.stamp` | AppSvg(AppIllustrationsCronometro.carimboMetaBatida, size: 104×104) | cores dinâmicas: #ABCF82 = goal · o texto "META DO DIA · BATIDA · META DO DIA ·" (Figtree 900 10,5 ls 1) corre num `<textPath>` em volta do círculo (textLength 232, lengthAdjust spacing): o flutter_svg não faz textPath → no app, o desenho sem o texto e as letras distribuídas no arco por um pintor com o AppFonts; a cor do selo é a prop "goal". |
| `cr18b.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `cr18b.sheet.stats.session` | NeoBox |  |
| `cr18b.sheet.stats.session.icon` | CircleIconButton / NeoBox circular |  |
| `cr18b.sheet.stats.session.icon.art` | AppSvg(AppIconsCronometro.stopwatchSmall, size: 16) |  |
| `cr18b.sheet.stats.today` | NeoBox |  |
| `cr18b.sheet.stats.today.icon` | CircleIconButton / NeoBox circular |  |
| `cr18b.sheet.stats.today.icon.art` | AppSvg(AppIconsScanner.checkBoldTinta, size: 16) |  |
| `cr18b.sheet.stats.streak` | NeoBox |  |
| `cr18b.sheet.stats.streak.icon` | CircleIconButton / NeoBox circular |  |
| `cr18b.sheet.stats.streak.icon.art` | AppSvg(AppIconsCronometro.flameChip, size: 16) |  |
| `cr18b.sheet.pageHeader.optional` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `cr18b.sheet.page.prev` | CircleIconButton / NeoBox circular |  |
| `cr18b.sheet.page.prev.icon` | AppSvg(AppIconsEntrada.minusBold, size: 18) |  |
| `cr18b.sheet.page.field` | NeoBox |  |
| `cr18b.sheet.page.field.input` | NeoBox |  |
| `cr18b.sheet.page.next` | CircleIconButton / NeoBox circular |  |
| `cr18b.sheet.page.next.icon` | AppSvg(AppIconsCronometro.plusMetaCreme, size: 18) |  |
| `cr18b.sheet.progress.added` | TextSpan dentro do AppText.rich do pai |  |
| `cr18b.sheet.save` | NeoBox |  |

## Interações

- Menos e mais → a página (1 a N, a regra da T04, `paper_end_form.dart`); tocar no número abre o teclado numérico (a nota do design).
- Salvar sessão → encerra e grava a sessão com a página (o `end(page:)` da T04); a tela fecha e volta para onde estava.
- Pular a página → grava só os minutos (o `end()` sem página).
- Arrastar a alça para baixo ou tocar no escurecido → volta ao cronômetro sem encerrar (se o tempo fica parado ou volta a andar é pergunta da T18).
- Com a meta batida: o selo, os confetes e a vibração leve (a nota do design); sem a meta, a folha sem o selo e o título sem "e meta batida!" — sem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T18 (ROTEIRO §2b).

## Dados

- Os três números: o tempo desta sessão, os minutos de hoje contra a meta e a sequência. A página vem sugerida pela última anotada (a nota do design) e o "Antes" é a página da sessão anterior; "+14 páginas" = a página − a anterior.
- O livro sem o total de páginas: a folha da T04 pede o total; aqui não há esse campo na prancha — pergunta da T18.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L18b.1** Escurecido, confetes e a moldura da folha
- **L18b.2** Selo, título e os três números
- **L18b.3** Página onde parou (menos, campo, mais)
- **L18b.4** Salvar e pular
- **L18b.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('cr18b.scrim', 'cr18b.confetti', 'cr18b.sheet'), todos os ids de `kRef18b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/018b_fim_da_sessao_390x844@3x.png` no recorte da fase (y 88–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef18bw360` e `kRef18bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L18b.1 Escurecido, confetes e a moldura da folha
- [ ] L18b.2 Selo, título e os três números
- [ ] L18b.3 Página onde parou (menos, campo, mais)
- [ ] L18b.4 Salvar e pular
- [ ] L18b.5 Verificação + relatório
- [ ] Geometria 43/43 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
