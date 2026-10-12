# FASE L05 — Perfil — os 4 livros que me definem na prateleira e as conquistas (4 medalhas e a próxima, com a barra)

> Tela 05 · prancha `005_perfil` (05 · Perfil, canvas 390×2510) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L05_3_favoritos_e_conquistas@3x.png` · `docs/design/medicao/projeto/png/redline/L05_3_favoritos_e_conquistas_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/005_perfil_390x2510@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_005_perfil.json` · `test/reference/projeto/reference_layout_005_perfil.dart` (`kRef05`).
> Arquivos sugeridos: `lib/features/profile/presentation/sections/favorites_section.dart`, `lib/features/profile/presentation/sections/achievements_section.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Perfil (05), no Resumo: "Quatro que me definem" (4 capas na prateleira) e as Conquistas — "12 de 30", quatro medalhas (o selo de sequência, o hexágono, o círculo e o losango) e a próxima ("14 dias seguidos", faltam 2) com a barra listrada.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`, `{{card}}` = padrão `#FF552E`.

```html
<!-- Four favourites -->
<section aria-label="Quatro livros que me definem" style="margin-top: 36px; display: flex; flex-direction: column; gap: 16px;">
  <div style="display: flex; align-items: center; justify-content: space-between;">
    <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Quatro que me <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 25px; letter-spacing: -0.2px;">definem</span></h2>
    <a href="#" style="height: 44px; display: flex; align-items: center; font-size: 14px; font-weight: 700;">Editar</a>
  </div>
  <div style="position: relative;">
    <div style="display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; padding: 0 2px;">
      <a href="#" aria-label="Quincas Borba" style="position: relative; display: block; height: 118px; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box;">
        <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.18);"></span>
        <span style="position: absolute; left: 12px; right: 12px; top: 13px; display: flex; flex-direction: column; gap: 4px;"><span style="height: 4px; border-radius: 4px; background: #F7F0E3;"></span><span style="height: 4px; width: 70%; border-radius: 4px; background: #F7F0E3;"></span><span style="height: 4px; width: 40%; border-radius: 4px; background: #F7F0E3;"></span></span>
        <span style="position: absolute; left: 11px; right: 4px; bottom: 9px; font-family: 'Instrument Serif', Georgia, serif; font-size: 17px; line-height: 0.9; color: #FFFAF1;">Quincas<br>Borba</span>
      </a>
      <a href="#" aria-label="O Cortiço" style="position: relative; display: block; height: 118px; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box;">
        <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.18);"></span>
        <span style="position: absolute; left: 16px; top: 14px; width: 46px; height: 54px; border-radius: 23px 23px 0 0; background: #FED170;"></span>
        <span style="position: absolute; left: 29px; top: 36px; width: 20px; height: 32px; border-radius: 10px 10px 0 0; background: #00995E;"></span>
        <span style="position: absolute; left: 11px; right: 4px; bottom: 9px; font-family: 'Instrument Serif', Georgia, serif; font-size: 17px; line-height: 0.9; color: #FFFAF1;">O Cortiço</span>
      </a>
      <a href="#" aria-label="Iracema" style="position: relative; display: block; height: 118px; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box;">
        <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.14);"></span>
        <span style="position: absolute; left: 14px; right: -8px; top: 18px; height: 32px; border-radius: 32px 0 0 32px; background: #1A1714;"></span>
        <span style="position: absolute; left: 11px; right: 4px; bottom: 9px; font-family: 'Instrument Serif', Georgia, serif; font-size: 18px; line-height: 0.9; color: #1A1714;">Iracema</span>
      </a>
      <a href="#" aria-label="A Metamorfose" style="position: relative; display: block; height: 118px; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box;">
        <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.12);"></span>
        <span style="position: absolute; left: 22px; top: 16px; width: 32px; height: 44px; border-radius: 50%; background: #1A1714;"></span>
        <span style="position: absolute; left: 37.5px; top: 16px; width: 1.5px; height: 44px; background: #B6ACE4;"></span>
        <span style="position: absolute; left: 11px; right: 3px; bottom: 9px; font-family: 'Instrument Serif', Georgia, serif; font-size: 15px; line-height: 0.92; color: #1A1714;">A Meta-<br>morfose</span>
      </a>
    </div>
    <span aria-hidden="true" style="display: block; height: 11px; margin: -1.5px -5px 0; border-radius: 6px; background: {{shelf}}; border: 1.5px solid #1A1714; box-shadow: 0 3px 0 #1A1714; box-sizing: border-box;"></span>
  </div>
</section>

<!-- Achievements -->
<section aria-label="Conquistas" style="margin-top: 38px; display: flex; flex-direction: column; gap: 14px;">
  <div style="display: flex; align-items: center; justify-content: space-between;">
    <div style="display: flex; align-items: baseline; gap: 8px;">
      <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Conquistas</h2>
      <span style="font-size: 13px; font-weight: 700; color: #5B544B;">12 de 30</span>
    </div>
    <a href="#" style="height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700;">Ver todas
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
    </a>
  </div>

  <div style="display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 6px;">
    <div style="display: flex; flex-direction: column; align-items: center; gap: 8px; text-align: center;">
      <span style="position: relative; width: 72px; height: 72px;">
        <svg width="72" height="72" viewBox="0 0 72 72" aria-hidden="true"><path d="M65.60 34.00 L65.22 35.36 L64.18 36.64 L62.75 37.79 L61.28 38.81 L60.11 39.79 L59.50 40.83 L59.51 42.04 L60.03 43.47 L60.79 45.10 L61.46 46.81 L61.72 48.43 L61.37 49.80 L60.36 50.79 L58.82 51.38 L57.01 51.65 L55.22 51.81 L53.72 52.07 L52.67 52.67 L52.07 53.72 L51.81 55.22 L51.65 57.01 L51.38 58.82 L50.79 60.36 L49.80 61.37 L48.43 61.72 L46.81 61.46 L45.10 60.79 L43.47 60.03 L42.04 59.51 L40.83 59.50 L39.79 60.11 L38.81 61.28 L37.79 62.75 L36.64 64.18 L35.36 65.22 L34.00 65.60 L32.64 65.22 L31.36 64.18 L30.21 62.75 L29.19 61.28 L28.21 60.11 L27.17 59.50 L25.96 59.51 L24.53 60.03 L22.90 60.79 L21.19 61.46 L19.57 61.72 L18.20 61.37 L17.21 60.36 L16.62 58.82 L16.35 57.01 L16.19 55.22 L15.93 53.72 L15.33 52.67 L14.28 52.07 L12.78 51.81 L10.99 51.65 L9.18 51.38 L7.64 50.79 L6.63 49.80 L6.28 48.43 L6.54 46.81 L7.21 45.10 L7.97 43.47 L8.49 42.04 L8.50 40.83 L7.89 39.79 L6.72 38.81 L5.25 37.79 L3.82 36.64 L2.78 35.36 L2.40 34.00 L2.78 32.64 L3.82 31.36 L5.25 30.21 L6.72 29.19 L7.89 28.21 L8.50 27.17 L8.49 25.96 L7.97 24.53 L7.21 22.90 L6.54 21.19 L6.28 19.57 L6.63 18.20 L7.64 17.21 L9.18 16.62 L10.99 16.35 L12.78 16.19 L14.28 15.93 L15.33 15.33 L15.93 14.28 L16.19 12.78 L16.35 10.99 L16.62 9.18 L17.21 7.64 L18.20 6.63 L19.57 6.28 L21.19 6.54 L22.90 7.21 L24.53 7.97 L25.96 8.49 L27.17 8.50 L28.21 7.89 L29.19 6.72 L30.21 5.25 L31.36 3.82 L32.64 2.78 L34.00 2.40 L35.36 2.78 L36.64 3.82 L37.79 5.25 L38.81 6.72 L39.79 7.89 L40.83 8.50 L42.04 8.49 L43.47 7.97 L45.10 7.21 L46.81 6.54 L48.43 6.28 L49.80 6.63 L50.79 7.64 L51.38 9.18 L51.65 10.99 L51.81 12.78 L52.07 14.28 L52.67 15.33 L53.72 15.93 L55.22 16.19 L57.01 16.35 L58.82 16.62 L60.36 17.21 L61.37 18.20 L61.72 19.57 L61.46 21.19 L60.79 22.90 L60.03 24.53 L59.51 25.96 L59.50 27.17 L60.11 28.21 L61.28 29.19 L62.75 30.21 L64.18 31.36 L65.22 32.64 Z" fill="#1A1714" transform="translate(3 3)"></path><path d="M65.60 34.00 L65.22 35.36 L64.18 36.64 L62.75 37.79 L61.28 38.81 L60.11 39.79 L59.50 40.83 L59.51 42.04 L60.03 43.47 L60.79 45.10 L61.46 46.81 L61.72 48.43 L61.37 49.80 L60.36 50.79 L58.82 51.38 L57.01 51.65 L55.22 51.81 L53.72 52.07 L52.67 52.67 L52.07 53.72 L51.81 55.22 L51.65 57.01 L51.38 58.82 L50.79 60.36 L49.80 61.37 L48.43 61.72 L46.81 61.46 L45.10 60.79 L43.47 60.03 L42.04 59.51 L40.83 59.50 L39.79 60.11 L38.81 61.28 L37.79 62.75 L36.64 64.18 L35.36 65.22 L34.00 65.60 L32.64 65.22 L31.36 64.18 L30.21 62.75 L29.19 61.28 L28.21 60.11 L27.17 59.50 L25.96 59.51 L24.53 60.03 L22.90 60.79 L21.19 61.46 L19.57 61.72 L18.20 61.37 L17.21 60.36 L16.62 58.82 L16.35 57.01 L16.19 55.22 L15.93 53.72 L15.33 52.67 L14.28 52.07 L12.78 51.81 L10.99 51.65 L9.18 51.38 L7.64 50.79 L6.63 49.80 L6.28 48.43 L6.54 46.81 L7.21 45.10 L7.97 43.47 L8.49 42.04 L8.50 40.83 L7.89 39.79 L6.72 38.81 L5.25 37.79 L3.82 36.64 L2.78 35.36 L2.40 34.00 L2.78 32.64 L3.82 31.36 L5.25 30.21 L6.72 29.19 L7.89 28.21 L8.50 27.17 L8.49 25.96 L7.97 24.53 L7.21 22.90 L6.54 21.19 L6.28 19.57 L6.63 18.20 L7.64 17.21 L9.18 16.62 L10.99 16.35 L12.78 16.19 L14.28 15.93 L15.33 15.33 L15.93 14.28 L16.19 12.78 L16.35 10.99 L16.62 9.18 L17.21 7.64 L18.20 6.63 L19.57 6.28 L21.19 6.54 L22.90 7.21 L24.53 7.97 L25.96 8.49 L27.17 8.50 L28.21 7.89 L29.19 6.72 L30.21 5.25 L31.36 3.82 L32.64 2.78 L34.00 2.40 L35.36 2.78 L36.64 3.82 L37.79 5.25 L38.81 6.72 L39.79 7.89 L40.83 8.50 L42.04 8.49 L43.47 7.97 L45.10 7.21 L46.81 6.54 L48.43 6.28 L49.80 6.63 L50.79 7.64 L51.38 9.18 L51.65 10.99 L51.81 12.78 L52.07 14.28 L52.67 15.33 L53.72 15.93 L55.22 16.19 L57.01 16.35 L58.82 16.62 L60.36 17.21 L61.37 18.20 L61.72 19.57 L61.46 21.19 L60.79 22.90 L60.03 24.53 L59.51 25.96 L59.50 27.17 L60.11 28.21 L61.28 29.19 L62.75 30.21 L64.18 31.36 L65.22 32.64 Z" fill="#FED170" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg>
        <span style="position: absolute; left: 0; top: 0; width: 68px; height: 68px; display: flex; flex-direction: column; align-items: center; justify-content: center; line-height: 1;">
          <span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 22px; font-weight: 800;">12</span>
          <span style="font-size: 8px; font-weight: 800; letter-spacing: 0.1em;">DIAS</span>
        </span>
      </span>
      <span style="font-size: 12px; font-weight: 700; line-height: 1.25;">Sequência<br>de 12 dias</span>
    </div>
    <div style="display: flex; flex-direction: column; align-items: center; gap: 8px; text-align: center;">
      <span style="position: relative; width: 72px; height: 72px;">
        <svg width="72" height="72" viewBox="0 0 72 72" aria-hidden="true"><path d="M34.00 4.00 L59.98 19.00 L59.98 49.00 L34.00 64.00 L8.02 49.00 L8.02 19.00 Z" fill="#1A1714" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round" transform="translate(3 3)"></path><path d="M34.00 4.00 L59.98 19.00 L59.98 49.00 L34.00 64.00 L8.02 49.00 L8.02 19.00 Z" fill="#ABCF82" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg>
        <span style="position: absolute; left: 0; top: 0; width: 68px; height: 68px; display: flex; align-items: center; justify-content: center;">
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 4h6a4 4 0 0 1 4 4v13a3 3 0 0 0-3-3H2z"></path><path d="M22 4h-6a4 4 0 0 0-4 4v13a3 3 0 0 1 3-3h7z"></path></svg>
        </span>
      </span>
      <span style="font-size: 12px; font-weight: 700; line-height: 1.25;">10 clássicos<br>brasileiros</span>
    </div>
    <div style="display: flex; flex-direction: column; align-items: center; gap: 8px; text-align: center;">
      <span style="position: relative; width: 72px; height: 72px;">
        <svg width="72" height="72" viewBox="0 0 72 72" aria-hidden="true"><circle cx="34" cy="34" r="30" fill="#1A1714" transform="translate(3 3)"></circle><circle cx="34" cy="34" r="30" fill="#FFC1C6" stroke="#1A1714" stroke-width="1.5"></circle></svg>
        <span style="position: absolute; left: 0; top: 0; width: 68px; height: 68px; display: flex; align-items: center; justify-content: center;">
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12z"></path></svg>
        </span>
      </span>
      <span style="font-size: 12px; font-weight: 700; line-height: 1.25;">Voz do<br>clube</span>
    </div>
    <div style="display: flex; flex-direction: column; align-items: center; gap: 8px; text-align: center;">
      <span style="position: relative; width: 72px; height: 72px;">
        <svg width="72" height="72" viewBox="0 0 72 72" aria-hidden="true"><rect x="12" y="12" width="44" height="44" rx="9" fill="#1A1714" transform="translate(3 3) rotate(45 34 34)"></rect><rect x="12" y="12" width="44" height="44" rx="9" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.5" transform="rotate(45 34 34)"></rect></svg>
        <span style="position: absolute; left: 0; top: 0; width: 68px; height: 68px; display: flex; flex-direction: column; align-items: center; justify-content: center; line-height: 1;">
          <span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 18px; font-weight: 800;">200</span>
          <span style="font-size: 8px; font-weight: 800; letter-spacing: 0.1em;">GRIFOS</span>
        </span>
      </span>
      <span style="font-size: 12px; font-weight: 700; line-height: 1.25;">Mão<br>de lápis</span>
    </div>
  </div>

  <!-- Next achievement -->
  <div style="padding: 12px 14px; border-radius: 18px; border: 1.5px dashed #8A7F63; display: flex; flex-direction: column; gap: 8px;">
    <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 8px;">
      <span style="font-size: 13px; font-weight: 700;">Próxima: <strong style="font-weight: 800;">14 dias seguidos</strong></span>
      <span style="font-size: 12px; font-weight: 700; color: #5B544B; white-space: nowrap;">faltam 2</span>
    </div>
    <span aria-hidden="true" style="position: relative; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px); overflow: hidden;">
      <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 86%; background: #FF552E;">
        <svg width="10" height="13" viewBox="0 0 10 13" preserveAspectRatio="none" style="position: absolute; top: 0; right: -5px; height: 100%;"><path d="M0 0H5Q9.5 2.17 5 4.33Q0.5 6.5 5 8.67Q9.5 10.83 5 13H0Z" fill="#FF552E"></path><path d="M5 0Q9.5 2.17 5 4.33Q0.5 6.5 5 8.67Q9.5 10.83 5 13" fill="none" stroke="#1A1714" stroke-width="1.5" vector-effect="non-scaling-stroke"></path></svg>
      </span>
    </span>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `p05.favorites` — retângulo absoluto no canvas 390×2510: **x=20, y=1474.59, w=350, h=187.5**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `p05.favorites` | box | 0 | 0 | 350 | 187.5 | `margin-top: 36px; display: flex; flex-direction: column; gap: 16px` |  |
| 2 | `p05.favorites.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 3 | `p05.favorites.header.title` ±1 | text | 0 | 5.75 | 216.52 | 32.5 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 4 | `p05.favorites.header.title.serif` ±1 | inline | 143.44 | 5.75 | 73.08 | 32.5 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 25px; letter-spacing: -0.2px` | Instrument Serif itálico 25/normal peso 400 ls -0.2px #1A1714 |
| 5 | `p05.favorites.header.edit` ±1 | text | 311.49 | 0 | 38.51 | 44 | `height: 44px; display: flex; align-items: center; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 6 | `p05.favorites.shelf` | box | 0 | 60 | 350 | 127.5 | `position: relative` |  |
| 7 | `p05.favorites.shelf.books` | box | 0 | 60 | 350 | 118 | `display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; padding: 0 2px` |  |
| 8 | `p05.favorites.shelf.books.book1` | box | 2 | 60 | 79 | 118 | `position: relative; display: block; height: 118px; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box` |  |
| 9 | `p05.favorites.shelf.books.book1.spine` | box | 3.5 | 61.5 | 5 | 115 | `position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.18)` |  |
| 10 | `p05.favorites.shelf.books.book1.lines` | box | 15.5 | 74.5 | 52 | 20 | `position: absolute; left: 12px; right: 12px; top: 13px; display: flex; flex-direction: column; gap: 4px` |  |
| 11 | `p05.favorites.shelf.books.book1.lines.line1` | box | 15.5 | 74.5 | 52 | 4 | `height: 4px; border-radius: 4px; background: #F7F0E3` |  |
| 12 | `p05.favorites.shelf.books.book1.lines.line2` | box | 15.5 | 82.5 | 36.4 | 4 | `height: 4px; width: 70%; border-radius: 4px; background: #F7F0E3` |  |
| 13 | `p05.favorites.shelf.books.book1.lines.line3` | box | 15.5 | 90.5 | 20.8 | 4 | `height: 4px; width: 40%; border-radius: 4px; background: #F7F0E3` |  |
| 14 | `p05.favorites.shelf.books.book1.title` | text | 14.5 | 136.9 | 61 | 30.6 | `position: absolute; left: 11px; right: 4px; bottom: 9px; font-family: 'Instrument Serif', Georgia, serif; font-size: 17px; line-height: 0.9; color: #FFFAF1` | Instrument Serif 17/15.3px peso 400 ls normal #FFFAF1 |
| 15 | `p05.favorites.shelf.books.book2` | box | 91 | 60 | 79 | 118 | `position: relative; display: block; height: 118px; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box` |  |
| 16 | `p05.favorites.shelf.books.book2.spine` | box | 92.5 | 61.5 | 5 | 115 | `position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.18)` |  |
| 17 | `p05.favorites.shelf.books.book2.arch` | box | 108.5 | 75.5 | 46 | 54 | `position: absolute; left: 16px; top: 14px; width: 46px; height: 54px; border-radius: 23px 23px 0 0; background: #FED170` |  |
| 18 | `p05.favorites.shelf.books.book2.door` | box | 121.5 | 97.5 | 20 | 32 | `position: absolute; left: 29px; top: 36px; width: 20px; height: 32px; border-radius: 10px 10px 0 0; background: #00995E` |  |
| 19 | `p05.favorites.shelf.books.book2.title` | text | 103.5 | 152.2 | 61 | 15.3 | `position: absolute; left: 11px; right: 4px; bottom: 9px; font-family: 'Instrument Serif', Georgia, serif; font-size: 17px; line-height: 0.9; color: #FFFAF1` | Instrument Serif 17/15.3px peso 400 ls normal #FFFAF1 |
| 20 | `p05.favorites.shelf.books.book3` | box | 180 | 60 | 79 | 118 | `position: relative; display: block; height: 118px; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box` |  |
| 21 | `p05.favorites.shelf.books.book3.spine` | box | 181.5 | 61.5 | 5 | 115 | `position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.14)` |  |
| 22 | `p05.favorites.shelf.books.book3.band` | box | 195.5 | 79.5 | 70 | 32 | `position: absolute; left: 14px; right: -8px; top: 18px; height: 32px; border-radius: 32px 0 0 32px; background: #1A1714` |  |
| 23 | `p05.favorites.shelf.books.book3.title` | text | 192.5 | 151.3 | 61 | 16.2 | `position: absolute; left: 11px; right: 4px; bottom: 9px; font-family: 'Instrument Serif', Georgia, serif; font-size: 18px; line-height: 0.9; color: #1A1714` | Instrument Serif 18/16.2px peso 400 ls normal #1A1714 |
| 24 | `p05.favorites.shelf.books.book4` | box | 269 | 60 | 79 | 118 | `position: relative; display: block; height: 118px; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box` |  |
| 25 | `p05.favorites.shelf.books.book4.spine` | box | 270.5 | 61.5 | 5 | 115 | `position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.12)` |  |
| 26 | `p05.favorites.shelf.books.book4.oval` | box | 292.5 | 77.5 | 32 | 44 | `position: absolute; left: 22px; top: 16px; width: 32px; height: 44px; border-radius: 50%; background: #1A1714` |  |
| 27 | `p05.favorites.shelf.books.book4.seam` | box | 308 | 77.5 | 1.5 | 44 | `position: absolute; left: 37.5px; top: 16px; width: 1.5px; height: 44px; background: #B6ACE4` |  |
| 28 | `p05.favorites.shelf.books.book4.title` | text | 281.5 | 139.9 | 62 | 27.6 | `position: absolute; left: 11px; right: 3px; bottom: 9px; font-family: 'Instrument Serif', Georgia, serif; font-size: 15px; line-height: 0.92; color: #1A1714` | Instrument Serif 15/13.8px peso 400 ls normal #1A1714 |
| 29 | `p05.favorites.shelf.plank` | box | -5 | 176.5 | 360 | 11 | `display: block; height: 11px; margin: -1.5px -5px 0; border-radius: 6px; background: {{shelf}} (padrão #FED170); border: 1.5px solid #1A1714; box-shadow: 0 3px 0 #1A1714; box-sizing: border-box` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.favorites.header.title` *(composto)* | 1 | Quatro que me definem | 30.5 | 0 | 216.52 | 216.52 |
| `p05.favorites.header.edit` | 1 | Editar | 26.9 | 311.49 | 350 | 38.51 |
| `p05.favorites.shelf.books.book1.title` | 1 | Quincas | 150.33 | 14.5 | 60.83 | 46.33 |
| `p05.favorites.shelf.books.book1.title` | 2 | Borba | 165.63 | 14.5 | 49.42 | 34.92 |
| `p05.favorites.shelf.books.book2.title` | 1 | O Cortiço | 165.63 | 103.5 | 156.97 | 53.47 |
| `p05.favorites.shelf.books.book3.title` | 1 | Iracema | 165.52 | 192.5 | 241.91 | 49.41 |
| `p05.favorites.shelf.books.book4.title` | 1 | A Meta- | 151.9 | 281.5 | 322.19 | 40.69 |
| `p05.favorites.shelf.books.book4.title` | 2 | morfose | 165.7 | 281.5 | 322.88 | 41.38 |

Seção `p05.achievements` — retângulo absoluto no canvas 390×2510: **x=20, y=1700.09, w=350, h=248.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 30 | `p05.achievements` | box | 0 | 0 | 350 | 248.6 | `margin-top: 38px; display: flex; flex-direction: column; gap: 14px` |  |
| 31 | `p05.achievements.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 32 | `p05.achievements.header.titleGroup` ±1 | box | 0 | 10 | 165.17 | 24 | `display: flex; align-items: baseline; gap: 8px` |  |
| 33 | `p05.achievements.header.title` ±1 | text | 0 | 10 | 107.38 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 34 | `p05.achievements.header.count` ±1 | text | 115.38 | 16.25 | 49.79 | 15.6 | `font-size: 13px; font-weight: 700; color: #5B544B` | Figtree 13/normal peso 700 ls normal #5B544B |
| 35 | `p05.achievements.header.all` ±1 | text | 266.11 | 0 | 83.89 | 44 | `height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 36 | `p05.achievements.header.all.icon` | icon | 332 | 13 | 18 | 18 | `—` |  |
| 37 | `p05.achievements.grid` | box | 0 | 58 | 350 | 110 | `display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 6px` |  |
| 38 | `p05.achievements.grid.badge1` | box | 0 | 58 | 83 | 110 | `display: flex; flex-direction: column; align-items: center; gap: 8px; text-align: center` |  |
| 39 | `p05.achievements.grid.badge1.medal` | box | 5.5 | 58 | 72 | 72 | `position: relative; width: 72px; height: 72px` |  |
| 40 | `p05.achievements.grid.badge1.medal.art` | icon | 5.5 | 58 | 72 | 72 | `—` |  |
| 41 | `p05.achievements.grid.badge1.medal.center` | box | 5.5 | 58 | 68 | 68 | `position: absolute; left: 0; top: 0; width: 68px; height: 68px; display: flex; flex-direction: column; align-items: center; justify-content: center; line-height: 1` |  |
| 42 | `p05.achievements.grid.badge1.medal.center.number` ±1 | text | 28.92 | 77 | 21.16 | 22 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 22px; font-weight: 800` | Bricolage (opsz 22) 22/22px peso 800 ls normal #1A1714 |
| 43 | `p05.achievements.grid.badge1.medal.center.unit` ±1 | text | 28.55 | 99 | 21.9 | 8 | `font-size: 8px; font-weight: 800; letter-spacing: 0.1em` | Figtree 8/8px peso 800 ls 0.8px #1A1714 |
| 44 | `p05.achievements.grid.badge1.label` ±1 | text | 12.78 | 138 | 57.44 | 30 | `font-size: 12px; font-weight: 700; line-height: 1.25` | Figtree 12/15px peso 700 ls normal #1A1714 |
| 45 | `p05.achievements.grid.badge2` | box | 89 | 58 | 83 | 110 | `display: flex; flex-direction: column; align-items: center; gap: 8px; text-align: center` |  |
| 46 | `p05.achievements.grid.badge2.medal` | box | 94.5 | 58 | 72 | 72 | `position: relative; width: 72px; height: 72px` |  |
| 47 | `p05.achievements.grid.badge2.medal.art` | icon | 94.5 | 58 | 72 | 72 | `—` |  |
| 48 | `p05.achievements.grid.badge2.medal.center` | box | 94.5 | 58 | 68 | 68 | `position: absolute; left: 0; top: 0; width: 68px; height: 68px; display: flex; align-items: center; justify-content: center` |  |
| 49 | `p05.achievements.grid.badge2.medal.center.icon` | icon | 115.5 | 79 | 26 | 26 | `—` |  |
| 50 | `p05.achievements.grid.badge2.label` ±1 | text | 98.02 | 138 | 64.97 | 30 | `font-size: 12px; font-weight: 700; line-height: 1.25` | Figtree 12/15px peso 700 ls normal #1A1714 |
| 51 | `p05.achievements.grid.badge3` | box | 178 | 58 | 83 | 110 | `display: flex; flex-direction: column; align-items: center; gap: 8px; text-align: center` |  |
| 52 | `p05.achievements.grid.badge3.medal` | box | 183.5 | 58 | 72 | 72 | `position: relative; width: 72px; height: 72px` |  |
| 53 | `p05.achievements.grid.badge3.medal.art` | icon | 183.5 | 58 | 72 | 72 | `—` |  |
| 54 | `p05.achievements.grid.badge3.medal.center` | box | 183.5 | 58 | 68 | 68 | `position: absolute; left: 0; top: 0; width: 68px; height: 68px; display: flex; align-items: center; justify-content: center` |  |
| 55 | `p05.achievements.grid.badge3.medal.center.icon` | icon | 204.5 | 79 | 26 | 26 | `—` |  |
| 56 | `p05.achievements.grid.badge3.label` ±1 | text | 200.58 | 138 | 37.85 | 30 | `font-size: 12px; font-weight: 700; line-height: 1.25` | Figtree 12/15px peso 700 ls normal #1A1714 |
| 57 | `p05.achievements.grid.badge4` | box | 267 | 58 | 83 | 110 | `display: flex; flex-direction: column; align-items: center; gap: 8px; text-align: center` |  |
| 58 | `p05.achievements.grid.badge4.medal` | box | 272.5 | 58 | 72 | 72 | `position: relative; width: 72px; height: 72px` |  |
| 59 | `p05.achievements.grid.badge4.medal.art` | icon | 272.5 | 58 | 72 | 72 | `—` |  |
| 60 | `p05.achievements.grid.badge4.medal.center` | box | 272.5 | 58 | 68 | 68 | `position: absolute; left: 0; top: 0; width: 68px; height: 68px; display: flex; flex-direction: column; align-items: center; justify-content: center; line-height: 1` |  |
| 61 | `p05.achievements.grid.badge4.medal.center.number` ±1 | text | 289.02 | 79 | 34.95 | 18 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 18px; font-weight: 800` | Bricolage (opsz 18) 18/18px peso 800 ls normal #1A1714 |
| 62 | `p05.achievements.grid.badge4.medal.center.unit` ±1 | text | 289.54 | 97 | 33.92 | 8 | `font-size: 8px; font-weight: 800; letter-spacing: 0.1em` | Figtree 8/8px peso 800 ls 0.8px #1A1714 |
| 63 | `p05.achievements.grid.badge4.label` ±1 | text | 287.56 | 138 | 41.88 | 30 | `font-size: 12px; font-weight: 700; line-height: 1.25` | Figtree 12/15px peso 700 ls normal #1A1714 |
| 64 | `p05.achievements.next` | box | 0 | 182 | 350 | 66.6 | `padding: 12px 14px; border-radius: 18px; border: 1.5px dashed #8A7F63; display: flex; flex-direction: column; gap: 8px` |  |
| 65 | `p05.achievements.next.head` | box | 15.5 | 195.5 | 319 | 15.6 | `display: flex; align-items: baseline; justify-content: space-between; gap: 8px` |  |
| 66 | `p05.achievements.next.title` ±1 | text | 15.5 | 195.5 | 154.31 | 15.6 | `font-size: 13px; font-weight: 700` | Figtree 13/normal peso 700 ls normal #1A1714 |
| 67 | `p05.achievements.next.title.goal` ±1 | inline | 71.2 | 195.5 | 98.61 | 15.6 | `font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 68 | `p05.achievements.next.remaining` ±1 | text | 289.2 | 196.45 | 45.3 | 14.4 | `font-size: 12px; font-weight: 700; color: #5B544B; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #5B544B |
| 69 | `p05.achievements.next.bar` | box | 15.5 | 219.1 | 319 | 16 | `position: relative; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E9DFCC 0 3px, #FFFAF1 3px 7px); overflow: hidden` |  |
| 70 | `p05.achievements.next.bar.fill` | box | 17 | 220.6 | 271.76 | 13 | `position: absolute; left: 0; top: 0; bottom: 0; width: 86%; background: #FF552E` |  |
| 71 | `p05.achievements.next.bar.fill.edge` | icon | 283.76 | 220.6 | 10 | 13 | `position: absolute; top: 0; right: -5px; height: 100%` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.achievements.header.title` | 1 | Conquistas | 28.6 | 0 | 107.38 | 107.38 |
| `p05.achievements.header.count` | 1 | 12 de 30 | 28.6 | 115.38 | 165.17 | 49.79 |
| `p05.achievements.header.all` | 1 | Ver todas | 26.9 | 266.11 | 328 | 61.89 |
| `p05.achievements.grid.badge1.medal.center.number` | 1 | 12 | 95.26 | 28.92 | 50.08 | 21.16 |
| `p05.achievements.grid.badge1.medal.center.unit` | 1 | DIAS | 105.8 | 28.55 | 50.45 | 21.9 |
| `p05.achievements.grid.badge1.label` | 1 | Sequência | 149.7 | 12.78 | 70.22 | 57.44 |
| `p05.achievements.grid.badge1.label` | 2 | de 12 dias | 164.7 | 14.61 | 68.39 | 53.78 |
| `p05.achievements.grid.badge2.label` | 1 | 10 clássicos | 149.7 | 98.02 | 162.98 | 64.96 |
| `p05.achievements.grid.badge2.label` | 2 | brasileiros | 164.7 | 102.16 | 158.84 | 56.68 |
| `p05.achievements.grid.badge3.label` | 1 | Voz do | 149.7 | 200.58 | 238.42 | 37.84 |
| `p05.achievements.grid.badge3.label` | 2 | clube | 164.7 | 204.44 | 234.56 | 30.12 |
| `p05.achievements.grid.badge4.medal.center.number` | 1 | 200 | 93.94 | 289.02 | 323.98 | 34.96 |
| `p05.achievements.grid.badge4.medal.center.unit` | 1 | GRIFOS | 103.8 | 289.54 | 323.46 | 33.92 |
| `p05.achievements.grid.badge4.label` | 1 | Mão | 149.7 | 296.7 | 320.3 | 23.6 |
| `p05.achievements.grid.badge4.label` | 2 | de lápis | 164.7 | 287.56 | 329.44 | 41.88 |
| `p05.achievements.next.title` *(composto)* | 1 | Próxima: 14 dias seguidos | 207.85 | 15.5 | 169.81 | 154.31 |
| `p05.achievements.next.remaining` | 1 | faltam 2 | 207.85 | 289.2 | 334.5 | 45.3 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Favoritos 36 abaixo do cartão do ano: "Quatro que me" Bricolage 20/800 + "definem" Instrument Serif 25 e "Editar" (44, 14/700); a grade de 4 (gap 10, padding 0/2) com as capas de 118 (raio 3/7/7/3, borda 1,5, a lombada de 5, o título Instrument Serif 15–18 `lh 0,9`) e a prateleira de 11 em `{{shelf}}` (borda 1,5, sombra 0/3), 5 para fora de cada lado e subindo 1,5.
2. Conquistas 38 abaixo: "Conquistas" Bricolage 20/800 com "12 de 30" 13/700 `#5B544B` pela base (gap 8), e "Ver todas" com a seta 18; a grade de 4 (gap 6), cada medalha numa área 72 × 72 com o desenho de 68 e a sombra dura de 3 (o SVG da prancha), o miolo (o "12 DIAS" Bricolage 22 + 8/800 ls 0,1em, o ícone 26 ou o "200 GRIFOS") e o rótulo 12/700 `lh 1,25` em duas linhas, 8 abaixo.
3. Próxima: padding 12/14, raio 18, tracejado 1,5 `#8A7F63`, gap 8; "Próxima: 14 dias seguidos" 13/700 com o nome em 800, e "faltam 2" 12/700 `#5B544B` `nowrap`; a barra de 16 (borda 1,5, hachura `#E9DFCC`/`#FFFAF1` 3/7) com o preenchimento coral de 86% e a ponta ondulada (o SVG 10 × 13 esticado na altura).
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A barra da próxima conquista é a mesma régua da Início (a hachura e a ponta ondulada, D-285 para os traços): o preenchimento de 86% é proporção da largura, com a ponta de 10 saindo 5 para a direita.
- As medalhas são SVG com a sombra desenhada como uma 2ª forma deslocada 3/3: entram pelo `AppSvg`, sem `BoxShadow`.
- A 360 o título "O Cortiço" da 2ª capa fica num fio de navalha (0,04, abaixo): uma linha só, que quebra se crescer.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_005_perfil_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_005_perfil_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `p05.favorites.shelf.books.book2.title` linha 1 «O Cortiço»: sobra 0.04 px · sem palavra seguinte (D-275: a linha única quebra se crescer).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `p05.favorites` |  | Quatro livros que me definem |  |
| `p05.favorites.shelf.books.book1` |  | Quincas Borba |  |
| `p05.favorites.shelf.books.book2` |  | O Cortiço |  |
| `p05.favorites.shelf.books.book3` |  | Iracema |  |
| `p05.favorites.shelf.books.book4` |  | A Metamorfose |  |
| `p05.favorites.shelf.plank` |  |  | aria-hidden=true |
| `p05.achievements` |  | Conquistas |  |
| `p05.achievements.header.all.icon` |  |  | aria-hidden=true |
| `p05.achievements.grid.badge1.medal.art` |  |  | aria-hidden=true |
| `p05.achievements.grid.badge2.medal.art` |  |  | aria-hidden=true |
| `p05.achievements.grid.badge2.medal.center.icon` |  |  | aria-hidden=true |
| `p05.achievements.grid.badge3.medal.art` |  |  | aria-hidden=true |
| `p05.achievements.grid.badge3.medal.center.icon` |  |  | aria-hidden=true |
| `p05.achievements.grid.badge4.medal.art` |  |  | aria-hidden=true |
| `p05.achievements.next.bar` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `p05.favorites.header.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `p05.favorites.shelf.books.book1` | NeoBox |  |
| `p05.favorites.shelf.books.book1.spine` | NeoBox |  |
| `p05.favorites.shelf.books.book1.lines.line1` | NeoBox |  |
| `p05.favorites.shelf.books.book1.lines.line2` | NeoBox |  |
| `p05.favorites.shelf.books.book1.lines.line3` | NeoBox |  |
| `p05.favorites.shelf.books.book2` | NeoBox |  |
| `p05.favorites.shelf.books.book2.spine` | NeoBox |  |
| `p05.favorites.shelf.books.book2.arch` | NeoBox |  |
| `p05.favorites.shelf.books.book2.door` | NeoBox |  |
| `p05.favorites.shelf.books.book3` | NeoBox |  |
| `p05.favorites.shelf.books.book3.spine` | NeoBox |  |
| `p05.favorites.shelf.books.book3.band` | NeoBox |  |
| `p05.favorites.shelf.books.book4` | NeoBox |  |
| `p05.favorites.shelf.books.book4.spine` | NeoBox |  |
| `p05.favorites.shelf.books.book4.oval` | CircleIconButton / NeoBox circular |  |
| `p05.favorites.shelf.books.book4.seam` | NeoBox |  |
| `p05.favorites.shelf.plank` | NeoBox |  |
| `p05.achievements.header.all.icon` | AppSvg(AppIcons.arrowRight, size: 18) |  |
| `p05.achievements.grid.badge1.medal.art` | AppSvg(AppIllustrationsPerfil.medalhaOnduladaAmarela, size: 72×72) |  |
| `p05.achievements.grid.badge2.medal.art` | AppSvg(AppIllustrationsPerfil.medalhaHexagonoVerde, size: 72×72) |  |
| `p05.achievements.grid.badge2.medal.center.icon` | AppSvg(AppIconsPerfil.bookOpenMedalha, size: 26) |  |
| `p05.achievements.grid.badge3.medal.art` | AppSvg(AppIllustrationsPerfil.medalhaCirculoRosa, size: 72×72) |  |
| `p05.achievements.grid.badge3.medal.center.icon` | AppSvg(AppIconsPerfil.chatBubble, size: 26) |  |
| `p05.achievements.grid.badge4.medal.art` | AppSvg(AppIllustrationsPerfil.medalhaLosangoLavanda, size: 72×72) |  |
| `p05.achievements.next` | NeoBox |  |
| `p05.achievements.next.title.goal` | TextSpan dentro do AppText.rich do pai |  |
| `p05.achievements.next.bar` | HatchPainter (hachura 135°) dentro do contorno |  |
| `p05.achievements.next.bar.fill` | NeoBox |  |
| `p05.achievements.next.bar.fill.edge` | CustomPainter (borda_onda_conquista) | preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): a borda ondulada da ponta da barra preenchida, esticada na altura da barra com traço fixo de 1,5 — CustomPainter, como a onda da barra do leitor. |

## Interações

- Capa → os Detalhes do livro (17/17b, da T14).
- "Editar" → a 64, já no bloco dos 4 (rolada até ele), se a T17 decidir; senão, a 64 do começo.
- "Ver todas" e as medalhas → as Conquistas (79), da T21: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).

## Dados

- Os 4 que me definem são escolhidos na 64 (ordem 1–4). O app ainda não guarda favoritos: o campo novo (no perfil, no servidor) é pergunta da T17; sem o dado, a seção segue a D-247.
- As conquistas (quantas de quantas, as 4 mais recentes e a próxima com o que falta) são da T21: até lá, a seção segue a D-247 (fixture nos testes, some com dados reais); a sequência que já existe (12 dias) pode alimentar o 1º selo e a próxima — pergunta da T17.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L05.1** Quatro que me definem: capas e prateleira
- **L05.2** Conquistas: título, grade de medalhas
- **L05.3** Próxima conquista com a barra
- **L05.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('p05.favorites', 'p05.achievements'), todos os ids de `kRef05.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/005_perfil_390x2510@3x.png` no recorte da fase (y 1466.59–1956.69) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef05w360` e `kRef05w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L05.1 Quatro que me definem: capas e prateleira
- [ ] L05.2 Conquistas: título, grade de medalhas
- [ ] L05.3 Próxima conquista com a barra
- [ ] L05.4 Verificação + relatório
- [ ] Geometria 69/69 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
