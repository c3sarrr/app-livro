# FASE L06 — Ajustes — Leitura: o tema das páginas, a fonte, o tamanho do texto, virar páginas e a tela acesa

> Tela 06 · prancha `006_ajustes` (06 · Ajustes (engrenagem), canvas 390×2400) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L06_2_leitura@3x.png` · `docs/design/medicao/projeto/png/redline/L06_2_leitura_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/006_ajustes_390x2400@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_006_ajustes.json` · `test/reference/projeto/reference_layout_006_ajustes.dart` (`kRef06`).
> Arquivos sugeridos: `lib/features/settings/presentation/sections/reading_settings_section.dart`, `lib/core/design_system/widgets/app_switch.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Ajustes (06), Leitura: "Restaurar padrão", o tema das páginas (Claro, Sépia marcado, Escuro em miniatura), a fonte do livro (Literata), o tamanho do texto (18 pt, a régua com A e A), virar páginas (Paginado ou Contínuo) e manter a tela acesa.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`.

```html
<!-- Reading -->
<section aria-label="Leitura" style="margin-top: 34px; display: flex; flex-direction: column; gap: 12px;">
  <div style="display: flex; align-items: center; justify-content: space-between;">
    <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px;">Leitura</h2>
    <a href="#" style="height: 44px; display: flex; align-items: center; font-size: 13.5px; font-weight: 700; color: #5B544B;">Restaurar padrão</a>
  </div>

  <div style="padding: 16px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column;">
    <span style="font-size: 13px; font-weight: 800;">Tema das páginas</span>
    <div role="radiogroup" aria-label="Tema das páginas" style="margin-top: 10px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px;">
      <button role="radio" aria-checked="false" style="padding: 0; background: transparent; border: none; display: flex; flex-direction: column; gap: 7px; align-items: stretch; text-align: left;">
        <span style="position: relative; height: 86px; padding: 10px 11px; border-radius: 14px; background: #FFFDF8; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px;">
          <span style="font-family: 'Literata', Georgia, serif; font-size: 24px; line-height: 1; color: #1A1714;">Aa</span>
          <span style="height: 3px; width: 100%; border-radius: 2px; background: #D9D0C0;"></span>
          <span style="height: 3px; width: 86%; border-radius: 2px; background: #D9D0C0;"></span>
          <span style="height: 3px; width: 64%; border-radius: 2px; background: #D9D0C0;"></span>
        </span>
        <span style="font-size: 13px; font-weight: 600; color: #5B544B; text-align: center;">Claro</span>
      </button>
      <button role="radio" aria-checked="true" style="padding: 0; background: transparent; border: none; display: flex; flex-direction: column; gap: 7px; align-items: stretch; text-align: left;">
        <span style="position: relative; height: 86px; padding: 10px 11px; border-radius: 14px; background: #F1E2C4; border: 2.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px;">
          <span style="font-family: 'Literata', Georgia, serif; font-size: 24px; line-height: 1; color: #4A3620;">Aa</span>
          <span style="height: 3px; width: 100%; border-radius: 2px; background: #CDB78E;"></span>
          <span style="height: 3px; width: 86%; border-radius: 2px; background: #CDB78E;"></span>
          <span style="height: 3px; width: 64%; border-radius: 2px; background: #CDB78E;"></span>
          <span style="position: absolute; top: -9px; right: -9px; width: 24px; height: 24px; border-radius: 50%; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
          </span>
        </span>
        <span style="font-size: 13px; font-weight: 800; text-align: center;">Sépia</span>
      </button>
      <button role="radio" aria-checked="false" style="padding: 0; background: transparent; border: none; display: flex; flex-direction: column; gap: 7px; align-items: stretch; text-align: left;">
        <span style="position: relative; height: 86px; padding: 10px 11px; border-radius: 14px; background: #1E1B18; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px;">
          <span style="font-family: 'Literata', Georgia, serif; font-size: 24px; line-height: 1; color: #EDE4D3;">Aa</span>
          <span style="height: 3px; width: 100%; border-radius: 2px; background: #4A443D;"></span>
          <span style="height: 3px; width: 86%; border-radius: 2px; background: #4A443D;"></span>
          <span style="height: 3px; width: 64%; border-radius: 2px; background: #4A443D;"></span>
        </span>
        <span style="font-size: 13px; font-weight: 600; color: #5B544B; text-align: center;">Escuro</span>
      </button>
    </div>

    <a href="#" style="margin-top: 14px; min-height: 56px; display: flex; align-items: center; gap: 12px; border-top: 1px solid #EAE1D0;">
      <span style="flex-grow: 1; display: flex; flex-direction: column; gap: 2px;">
        <span style="font-size: 15px; font-weight: 700;">Fonte do livro</span>
        <span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Feita para textos longos</span>
      </span>
      <span style="font-family: 'Literata', Georgia, serif; font-size: 16px; font-weight: 600;">Literata</span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>

    <div style="padding: 12px 0 14px; display: flex; flex-direction: column; gap: 10px; border-top: 1px solid #EAE1D0;">
      <div style="display: flex; align-items: baseline; justify-content: space-between;">
        <span style="font-size: 15px; font-weight: 700;">Tamanho do texto</span>
        <span style="font-size: 13px; font-weight: 800;">18 pt</span>
      </div>
      <div style="display: flex; align-items: center; gap: 12px;">
        <span aria-hidden="true" style="font-family: 'Literata', Georgia, serif; font-size: 14px; font-weight: 600;">A</span>
        <div role="slider" aria-label="Tamanho do texto" aria-valuemin="12" aria-valuemax="28" aria-valuenow="18" style="position: relative; flex-grow: 1; height: 30px; display: flex; align-items: center;">
          <span style="width: 100%; height: 10px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px); overflow: hidden;"><span style="display: block; width: 38%; height: 100%; background: {{brand}}; border-right: 1.2px solid #1A1714; box-sizing: border-box;"></span></span>
          <span aria-hidden="true" style="position: absolute; left: 38%; top: 2px; margin-left: -13px; width: 26px; height: 26px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box;"></span>
        </div>
        <span aria-hidden="true" style="font-family: 'Literata', Georgia, serif; font-size: 24px; font-weight: 600;">A</span>
      </div>
    </div>

    <div style="padding: 12px 0; display: flex; align-items: center; justify-content: space-between; gap: 10px; border-top: 1px solid #EAE1D0;">
      <span style="font-size: 15px; font-weight: 700; white-space: nowrap;">Virar páginas</span>
      <div role="radiogroup" aria-label="Modo de leitura" style="height: 40px; padding: 3px; box-sizing: border-box; display: flex; gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1;">
        <button role="radio" aria-checked="true" style="height: 100%; padding: 0 12px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 13px; font-weight: 800;">Paginado</button>
        <button role="radio" aria-checked="false" style="height: 100%; padding: 0 12px; border-radius: 999px; background: transparent; border: none; font-size: 13px; font-weight: 600; color: #5B544B;">Contínuo</button>
      </div>
    </div>

    <div style="padding: 12px 0 2px; display: flex; align-items: center; justify-content: space-between; gap: 12px; border-top: 1px solid #EAE1D0;">
      <span style="display: flex; flex-direction: column; gap: 2px;">
        <span style="font-size: 15px; font-weight: 700;">Manter a tela acesa</span>
        <span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Enquanto um livro estiver aberto</span>
      </span>
      <button role="switch" aria-checked="true" aria-label="Manter a tela acesa" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
        <span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
      </button>
    </div>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `aj06.reading` — retângulo absoluto no canvas 390×2400: **x=20, y=499.1, w=350, h=501.85**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `aj06.reading` | box | 0 | 0 | 350 | 501.85 | `margin-top: 34px; display: flex; flex-direction: column; gap: 12px` |  |
| 2 | `aj06.reading.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 3 | `aj06.reading.header.title` ±1 | text | 0 | 8.8 | 71.68 | 26.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/normal peso 800 ls -0.5px #1A1714 |
| 4 | `aj06.reading.header.reset` ±1 | text | 243.28 | 0 | 106.72 | 44 | `height: 44px; display: flex; align-items: center; font-size: 13.5px; font-weight: 700; color: #5B544B` | Figtree 13.5/normal peso 700 ls normal #5B544B |
| 5 | `aj06.reading.card` | box | 0 | 56 | 350 | 445.85 | `padding: 16px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 6 | `aj06.reading.themeLabel` | text | 17.5 | 73.5 | 315 | 15.6 | `font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 7 | `aj06.reading.theme` | box | 17.5 | 99.1 | 315 | 108.6 | `margin-top: 10px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px` |  |
| 8 | `aj06.reading.theme.light` | box | 17.5 | 99.1 | 98.33 | 108.6 | `padding: 0; background: transparent; border: none; display: flex; flex-direction: column; gap: 7px; align-items: stretch; text-align: left` |  |
| 9 | `aj06.reading.theme.light.preview` | box | 17.5 | 99.1 | 98.33 | 86 | `position: relative; height: 86px; padding: 10px 11px; border-radius: 14px; background: #FFFDF8; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px` |  |
| 10 | `aj06.reading.theme.light.preview.sample` | text | 30 | 110.6 | 73.33 | 24 | `font-family: 'Literata', Georgia, serif; font-size: 24px; line-height: 1; color: #1A1714` | Literata (opsz 24) 24/24px peso 400 ls normal #1A1714 |
| 11 | `aj06.reading.theme.light.preview.line1` | box | 30 | 140.6 | 73.33 | 3 | `height: 3px; width: 100%; border-radius: 2px; background: #D9D0C0` |  |
| 12 | `aj06.reading.theme.light.preview.line2` | box | 30 | 149.6 | 63.07 | 3 | `height: 3px; width: 86%; border-radius: 2px; background: #D9D0C0` |  |
| 13 | `aj06.reading.theme.light.preview.line3` | box | 30 | 158.6 | 46.93 | 3 | `height: 3px; width: 64%; border-radius: 2px; background: #D9D0C0` |  |
| 14 | `aj06.reading.theme.light.label` | text | 17.5 | 192.1 | 98.33 | 15.6 | `font-size: 13px; font-weight: 600; color: #5B544B; text-align: center` | Figtree 13/normal peso 600 ls normal #5B544B |
| 15 | `aj06.reading.theme.sepia` | box | 125.83 | 99.1 | 98.33 | 108.6 | `padding: 0; background: transparent; border: none; display: flex; flex-direction: column; gap: 7px; align-items: stretch; text-align: left` |  |
| 16 | `aj06.reading.theme.sepia.preview` | box | 125.83 | 99.1 | 98.33 | 86 | `position: relative; height: 86px; padding: 10px 11px; border-radius: 14px; background: #F1E2C4; border: 2.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px` |  |
| 17 | `aj06.reading.theme.sepia.preview.sample` | text | 139.33 | 111.6 | 71.33 | 24 | `font-family: 'Literata', Georgia, serif; font-size: 24px; line-height: 1; color: #4A3620` | Literata (opsz 24) 24/24px peso 400 ls normal #4A3620 |
| 18 | `aj06.reading.theme.sepia.preview.line1` | box | 139.33 | 141.6 | 71.33 | 3 | `height: 3px; width: 100%; border-radius: 2px; background: #CDB78E` |  |
| 19 | `aj06.reading.theme.sepia.preview.line2` | box | 139.33 | 150.6 | 61.35 | 3 | `height: 3px; width: 86%; border-radius: 2px; background: #CDB78E` |  |
| 20 | `aj06.reading.theme.sepia.preview.line3` | box | 139.33 | 159.6 | 45.65 | 3 | `height: 3px; width: 64%; border-radius: 2px; background: #CDB78E` |  |
| 21 | `aj06.reading.theme.sepia.preview.check` | box | 206.67 | 92.6 | 24 | 24 | `position: absolute; top: -9px; right: -9px; width: 24px; height: 24px; border-radius: 50%; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 22 | `aj06.reading.theme.sepia.preview.check.icon` | icon | 212.67 | 98.6 | 12 | 12 | `—` |  |
| 23 | `aj06.reading.theme.sepia.label` | text | 125.83 | 192.1 | 98.33 | 15.6 | `font-size: 13px; font-weight: 800; text-align: center` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 24 | `aj06.reading.theme.dark` | box | 234.17 | 99.1 | 98.33 | 108.6 | `padding: 0; background: transparent; border: none; display: flex; flex-direction: column; gap: 7px; align-items: stretch; text-align: left` |  |
| 25 | `aj06.reading.theme.dark.preview` | box | 234.17 | 99.1 | 98.33 | 86 | `position: relative; height: 86px; padding: 10px 11px; border-radius: 14px; background: #1E1B18; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px` |  |
| 26 | `aj06.reading.theme.dark.preview.sample` | text | 246.67 | 110.6 | 73.33 | 24 | `font-family: 'Literata', Georgia, serif; font-size: 24px; line-height: 1; color: #EDE4D3` | Literata (opsz 24) 24/24px peso 400 ls normal #EDE4D3 |
| 27 | `aj06.reading.theme.dark.preview.line1` | box | 246.67 | 140.6 | 73.33 | 3 | `height: 3px; width: 100%; border-radius: 2px; background: #4A443D` |  |
| 28 | `aj06.reading.theme.dark.preview.line2` | box | 246.67 | 149.6 | 63.07 | 3 | `height: 3px; width: 86%; border-radius: 2px; background: #4A443D` |  |
| 29 | `aj06.reading.theme.dark.preview.line3` | box | 246.67 | 158.6 | 46.93 | 3 | `height: 3px; width: 64%; border-radius: 2px; background: #4A443D` |  |
| 30 | `aj06.reading.theme.dark.label` | text | 234.17 | 192.1 | 98.33 | 15.6 | `font-size: 13px; font-weight: 600; color: #5B544B; text-align: center` | Figtree 13/normal peso 600 ls normal #5B544B |
| 31 | `aj06.reading.font` | box | 17.5 | 221.7 | 315 | 57 | `margin-top: 14px; min-height: 56px; display: flex; align-items: center; gap: 12px; border-top: 1px solid #EAE1D0` |  |
| 32 | `aj06.reading.font.textBlock` ±1 | box | 17.5 | 233.19 | 209.95 | 35.01 | `flex-grow: 1; display: flex; flex-direction: column; gap: 2px` |  |
| 33 | `aj06.reading.font.title` ±1 | text | 17.5 | 233.19 | 209.95 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 34 | `aj06.reading.font.body` ±1 | text | 17.5 | 253.19 | 209.95 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 35 | `aj06.reading.font.value` ±1 | text | 239.45 | 238.82 | 63.05 | 23.76 | `font-family: 'Literata', Georgia, serif; font-size: 16px; font-weight: 600` | Literata (opsz 16) 16/normal peso 600 ls normal #1A1714 |
| 36 | `aj06.reading.font.chevron` | icon | 314.5 | 241.7 | 18 | 18 | `—` |  |
| 37 | `aj06.reading.size` | box | 17.5 | 278.7 | 315 | 90.64 | `padding: 12px 0 14px; display: flex; flex-direction: column; gap: 10px; border-top: 1px solid #EAE1D0` |  |
| 38 | `aj06.reading.size.head` | box | 17.5 | 291.7 | 315 | 18 | `display: flex; align-items: baseline; justify-content: space-between` |  |
| 39 | `aj06.reading.size.title` ±1 | text | 17.5 | 291.7 | 123.99 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 40 | `aj06.reading.size.value` ±1 | text | 302.73 | 293.6 | 29.77 | 15.6 | `font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 41 | `aj06.reading.size.row` | box | 17.5 | 319.7 | 315 | 35.64 | `display: flex; align-items: center; gap: 12px` |  |
| 42 | `aj06.reading.size.small` ±1 | text | 17.5 | 327.12 | 10.44 | 20.79 | `font-family: 'Literata', Georgia, serif; font-size: 14px; font-weight: 600` | Literata (opsz 14) 14/normal peso 600 ls normal #1A1714 |
| 43 | `aj06.reading.size.slider` ±1 | box | 39.94 | 322.52 | 262.82 | 30 | `position: relative; flex-grow: 1; height: 30px; display: flex; align-items: center` |  |
| 44 | `aj06.reading.size.slider.track` ±1 | box | 39.94 | 332.52 | 262.82 | 10 | `width: 100%; height: 10px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px); overflow: hidden` |  |
| 45 | `aj06.reading.size.slider.fill` ±1 | box | 41.44 | 334.02 | 98.73 | 7 | `display: block; width: 38%; height: 100%; background: {{brand}} (padrão #B6ACE4); border-right: 1.2px solid #1A1714; box-sizing: border-box` |  |
| 46 | `aj06.reading.size.slider.thumb` ±1 | box | 126.81 | 324.52 | 26 | 26 | `position: absolute; left: 38%; top: 2px; margin-left: -13px; width: 26px; height: 26px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box` |  |
| 47 | `aj06.reading.size.large` ±1 | text | 314.76 | 319.7 | 17.74 | 35.64 | `font-family: 'Literata', Georgia, serif; font-size: 24px; font-weight: 600` | Literata (opsz 24) 24/normal peso 600 ls normal #1A1714 |
| 48 | `aj06.reading.paging` | box | 17.5 | 369.34 | 315 | 65 | `padding: 12px 0; display: flex; align-items: center; justify-content: space-between; gap: 10px; border-top: 1px solid #EAE1D0` |  |
| 49 | `aj06.reading.paging.title` ±1 | text | 17.5 | 393.34 | 91.08 | 18 | `font-size: 15px; font-weight: 700; white-space: nowrap` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 50 | `aj06.reading.paging.toggle` ±1 | box | 159.44 | 382.34 | 173.06 | 40 | `height: 40px; padding: 3px; box-sizing: border-box; display: flex; gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1` |  |
| 51 | `aj06.reading.paging.toggle.paged` ±1 | box+text | 163.94 | 386.84 | 83.2 | 31 | `height: 100%; padding: 0 12px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 52 | `aj06.reading.paging.toggle.scroll` ±1 | text | 249.14 | 386.84 | 78.86 | 31 | `height: 100%; padding: 0 12px; border-radius: 999px; background: transparent; border: none; font-size: 13px; font-weight: 600; color: #5B544B` | Figtree 13/normal peso 600 ls normal #5B544B |
| 53 | `aj06.reading.screenOn` | box | 17.5 | 434.34 | 315 | 50.01 | `padding: 12px 0 2px; display: flex; align-items: center; justify-content: space-between; gap: 12px; border-top: 1px solid #EAE1D0` |  |
| 54 | `aj06.reading.screenOn.textBlock` ±1 | box | 17.5 | 447.34 | 183.31 | 35.01 | `display: flex; flex-direction: column; gap: 2px` |  |
| 55 | `aj06.reading.screenOn.title` ±1 | text | 17.5 | 447.34 | 183.31 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 56 | `aj06.reading.screenOn.body` ±1 | text | 17.5 | 467.34 | 183.31 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 57 | `aj06.reading.screenOn.switch` | box | 278.5 | 448.85 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 58 | `aj06.reading.screenOn.switch.thumb` | box | 304.5 | 452.85 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 59 | `aj06.reading.screenOn.switch.thumb.icon` | icon | 311 | 459.35 | 11 | 11 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj06.reading.header.title` | 1 | Leitura | 29.26 | 0 | 71.68 | 71.68 |
| `aj06.reading.header.reset` | 1 | Restaurar padrão | 26.73 | 243.28 | 350 | 106.72 |
| `aj06.reading.themeLabel` | 1 | Tema das páginas | 85.85 | 17.5 | 124.32 | 106.82 |
| `aj06.reading.theme.light.preview.sample` | 1 | Aa | 133.03 | 30 | 60.24 | 30.24 |
| `aj06.reading.theme.light.label` | 1 | Claro | 204.45 | 50.89 | 82.44 | 31.55 |
| `aj06.reading.theme.sepia.preview.sample` | 1 | Aa | 134.03 | 139.33 | 169.57 | 30.24 |
| `aj06.reading.theme.sepia.label` | 1 | Sépia | 204.45 | 158.2 | 191.8 | 33.6 |
| `aj06.reading.theme.dark.preview.sample` | 1 | Aa | 133.03 | 246.67 | 276.91 | 30.24 |
| `aj06.reading.theme.dark.label` | 1 | Escuro | 204.45 | 263.13 | 303.54 | 40.41 |
| `aj06.reading.font.title` | 1 | Fonte do livro | 247.44 | 17.5 | 112.27 | 94.77 |
| `aj06.reading.font.body` | 1 | Feita para textos longos | 265.07 | 17.5 | 152.15 | 134.65 |
| `aj06.reading.font.value` | 1 | Literata | 257.65 | 239.45 | 302.5 | 63.05 |
| `aj06.reading.size.title` | 1 | Tamanho do texto | 305.95 | 17.5 | 141.49 | 123.99 |
| `aj06.reading.size.value` | 1 | 18 pt | 305.95 | 302.73 | 332.5 | 29.77 |
| `aj06.reading.size.small` | 1 | A | 343.61 | 17.5 | 27.94 | 10.44 |
| `aj06.reading.size.large` | 1 | A | 347.95 | 314.76 | 332.5 | 17.74 |
| `aj06.reading.paging.title` | 1 | Virar páginas | 407.59 | 17.5 | 108.58 | 91.08 |
| `aj06.reading.paging.toggle.paged` | 1 | Paginado | 406.89 | 177.44 | 233.64 | 56.2 |
| `aj06.reading.paging.toggle.scroll` | 1 | Contínuo | 406.89 | 261.14 | 316 | 54.86 |
| `aj06.reading.screenOn.title` | 1 | Manter a tela acesa | 461.59 | 17.5 | 150.84 | 133.34 |
| `aj06.reading.screenOn.body` | 1 | Enquanto um livro estiver aberto | 479.22 | 17.5 | 200.81 | 183.31 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Leitura" Bricolage 22/800 ls −0,5 com "Restaurar padrão" (44, 13,5/700 `#5B544B`); o cartão: padding 16, raio 24, `#FFFAF1`, borda 1,5, sem sombra.
2. Tema (`radiogroup`, grade de 3, gap 10, 10 abaixo do rótulo 13/800): a miniatura de 86 (padding 10/11, raio 14, borda 1,5, gap 6) com o "Aa" Literata 24 e as 3 linhas de 3 (100%, 86%, 64%) e o nome 13/600 embaixo; a marcada com borda 2,5, sombra 3/3, o visto num círculo 24 `{{brand}}` em `top/right −9` e o nome 13/800.
3. Fonte do livro: linha de 56 (o fio de 1 `#EAE1D0` em cima): "Fonte do livro" 15/700 + "Feita para textos longos" 12,5/500 e, à direita, "Literata" Literata 16/600 e a seta 18.
4. Tamanho: "Tamanho do texto" 15/700 e "18 pt" 13/800; a régua (`slider`, 30 de altura) com o "A" Literata 14 e o 24 nas pontas: o trilho de 10 hachurado, o preenchimento `{{brand}}` de 38% e o puxador 26 (sombra 2/2).
5. Virar páginas: o seletor de 40 ("Paginado" `{{brand}}` 13/800, "Contínuo" 13/600); Manter a tela acesa: título + "Enquanto um livro estiver aberto" e a chave.
6. A chave dos Ajustes e dos Lembretes (`role="switch"`): 54 × 32, raio cheio, borda 1,5; ligada, o trilho `{{brand}}` e a bolinha `#FFFAF1` de 24 (borda 1,5) a 2,5 da direita, com o visto de 11 (traço 3,6). É um dos dois desenhos de chave da T17 — o outro está na Conta e na Privacidade (52 × 32, sem visto).
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As chaves têm dois desenhos na T17 (54 × 32 com o visto nos Ajustes e nos Lembretes; 52 × 32 sem visto, trilho preto, na Conta e na Privacidade): no app, um widget com as duas variantes (`core/design_system/widgets/app_switch.dart`), cada tela com a sua, como a prancha. Unificar seria melhoria além do design (ROTEIRO §2b): só como proposta, com "Manter igual ao design".
- O visto da miniatura marcada sai da caixa (−9): `Clip.none` e o padding da grade para ele não cortar.
- A régua é `role="slider"` com o puxador decorativo: a semântica fica no slider (mín. 12, máx. 28, valor 18).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_006_ajustes_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_006_ajustes_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `aj06.reading` |  | Leitura |  |
| `aj06.reading.theme` | radiogroup | Tema das páginas |  |
| `aj06.reading.theme.light` | radio |  | aria-checked=false |
| `aj06.reading.theme.sepia` | radio |  | aria-checked=true |
| `aj06.reading.theme.sepia.preview.check.icon` |  |  | aria-hidden=true |
| `aj06.reading.theme.dark` | radio |  | aria-checked=false |
| `aj06.reading.font.chevron` |  |  | aria-hidden=true |
| `aj06.reading.size.small` |  |  | aria-hidden=true |
| `aj06.reading.size.slider` | slider | Tamanho do texto | aria-valuemin=12, aria-valuemax=28, aria-valuenow=18 |
| `aj06.reading.size.slider.thumb` |  |  | aria-hidden=true |
| `aj06.reading.size.large` |  |  | aria-hidden=true |
| `aj06.reading.paging.toggle` | radiogroup | Modo de leitura |  |
| `aj06.reading.paging.toggle.paged` | radio |  | aria-checked=true |
| `aj06.reading.paging.toggle.scroll` | radio |  | aria-checked=false |
| `aj06.reading.screenOn.switch` | switch | Manter a tela acesa | aria-checked=true |
| `aj06.reading.screenOn.switch.thumb.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `aj06.reading.card` | NeoBox |  |
| `aj06.reading.theme.light.preview` | NeoBox |  |
| `aj06.reading.theme.light.preview.line1` | NeoBox |  |
| `aj06.reading.theme.light.preview.line2` | NeoBox |  |
| `aj06.reading.theme.light.preview.line3` | NeoBox |  |
| `aj06.reading.theme.sepia.preview` | NeoBox |  |
| `aj06.reading.theme.sepia.preview.line1` | NeoBox |  |
| `aj06.reading.theme.sepia.preview.line2` | NeoBox |  |
| `aj06.reading.theme.sepia.preview.line3` | NeoBox |  |
| `aj06.reading.theme.sepia.preview.check` | CircleIconButton / NeoBox circular |  |
| `aj06.reading.theme.sepia.preview.check.icon` | AppSvg(AppIconsLeitor.checkRead, size: 12) |  |
| `aj06.reading.theme.dark.preview` | NeoBox |  |
| `aj06.reading.theme.dark.preview.line1` | NeoBox |  |
| `aj06.reading.theme.dark.preview.line2` | NeoBox |  |
| `aj06.reading.theme.dark.preview.line3` | NeoBox |  |
| `aj06.reading.font` | NeoBox |  |
| `aj06.reading.font.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.reading.size` | NeoBox |  |
| `aj06.reading.size.slider.track` | HatchPainter (hachura 135°) dentro do contorno |  |
| `aj06.reading.size.slider.fill` | NeoBox |  |
| `aj06.reading.size.slider.thumb` | CircleIconButton / NeoBox circular |  |
| `aj06.reading.paging` | NeoBox |  |
| `aj06.reading.paging.toggle` | NeoBox |  |
| `aj06.reading.paging.toggle.paged` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj06.reading.screenOn` | NeoBox |  |
| `aj06.reading.screenOn.switch` | NeoBox |  |
| `aj06.reading.screenOn.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `aj06.reading.screenOn.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |

## Interações

- Tema, fonte, tamanho e virar páginas mudam os mesmos ajustes do leitor (a tela 26, `ReaderSettings`).
- Fonte do livro → a escolha da fonte: a da tela 26 (o leitor) ou uma lista própria — sem prancha aqui: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b).
- Restaurar padrão → volta aos padrões da tela 26 (`ReaderLook`); se pede confirmação, é pergunta da T17.
- Manter a tela acesa → liga ou desliga o `wakelock` do leitor (hoje sempre ligado com um livro aberto).

## Dados

- Os ajustes de leitura já existem (`reader_settings.dart`): o papel tem 4 opções no leitor (creme, branco, sépia, noite) e aqui 3 (Claro, Sépia, Escuro); o tamanho é um passo (D-20) e aqui pontos (12–28, 18 pt); não há modo contínuo nem a chave da tela acesa. Como juntar os dois é pergunta da T17.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L06.1** Título e Restaurar padrão
- **L06.2** Tema das páginas
- **L06.3** Fonte e tamanho do texto
- **L06.4** Virar páginas e a tela acesa (a chave)
- **L06.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('aj06.reading'), todos os ids de `kRef06.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/006_ajustes_390x2400@3x.png` no recorte da fase (y 491.1–1008.95) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef06w360` e `kRef06w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L06.1 Título e Restaurar padrão
- [ ] L06.2 Tema das páginas
- [ ] L06.3 Fonte e tamanho do texto
- [ ] L06.4 Virar páginas e a tela acesa (a chave)
- [ ] L06.5 Verificação + relatório
- [ ] Geometria 59/59 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
