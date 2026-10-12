# FASE L14 — Onboarding 3/4 — as 6 sugestões (3 já na estante) e o Continuar

> Tela 14 · prancha `014_onboarding_primeiros_livros` (14 · Onboarding 3/4 — Primeiros livros, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L14_2_sugestoes@3x.png` · `docs/design/medicao/projeto/png/redline/L14_2_sugestoes_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/014_onboarding_primeiros_livros_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_014_onboarding_primeiros_livros.json` · `test/reference/projeto/reference_layout_014_onboarding_primeiros_livros.dart` (`kRef14`).
> Arquivos sugeridos: `lib/features/account/presentation/onboarding/first_books_step.dart`, `lib/features/account/presentation/onboarding/suggestion_cover.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Onboarding 3/4: "Sugestões para você · dos seus gêneros" — 6 capas em grade de 3 (3 já na estante, com o visto lavanda e a sombra; 3 com o "+"), a grade apagando embaixo, e o "Continuar" com a contagem.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{progress}}` = padrão `#FF552E`.

```html
<!-- Suggestions from chosen genres -->
<div style="margin-top: 20px; display: flex; align-items: center; justify-content: space-between; gap: 10px;">
  <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.3px;">Sugestões para você</h2>
  <span style="font-size: 12.5px; font-weight: 700; color: #5B544B; white-space: nowrap;">dos seus gêneros</span>
</div>

<div style="margin-top: 16px; flex: 1 1 0; min-height: 0; overflow: hidden; padding: 8px 8px 0 0; margin-right: -8px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); align-content: start; gap: 20px 12px; -webkit-mask-image: linear-gradient(180deg, #000 calc(100% - 22px), transparent 100%); mask-image: linear-gradient(180deg, #000 calc(100% - 22px), transparent 100%);">
            <button aria-label="Remover Dom Casmurro da estante" aria-pressed="true" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left;">
      <span style="position: relative; display: block; width: 100%;">
        <span aria-hidden="true" style="position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        <span style="position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #552CB7; box-shadow: 3px 3px 0 #1A1714; overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></span>
          <div style="position: absolute; right: -14px; top: -14px; width: 54px; height: 54px; border-radius: 50%; background: #FED170;"></div><div style="position: absolute; right: 22px; top: 34px; width: 12px; height: 12px; border-radius: 50%; border: 1.5px solid #FED170;"></div>
          <span style="position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px;">
            <span style="font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FED170;">Dom<br>Casmurro</span>
            <span style="font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FED170;">MACHADO DE ASSIS</span>
          </span>
        </span>
      </span>
    </button>
    <button aria-label="Remover Orgulho e Preconceito da estante" aria-pressed="true" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left;">
      <span style="position: relative; display: block; width: 100%;">
        <span aria-hidden="true" style="position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        <span style="position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #F2A815; box-shadow: 3px 3px 0 #1A1714; overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></span>
          <div style="position: absolute; left: 7px; right: 0; top: 0; height: 70px; background: radial-gradient(circle, #FFFAF1 2.2px, transparent 2.6px) 0 0/14px 14px;"></div>
          <span style="position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px;">
            <span style="font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #1A1714;">Orgulho e<br>Preconceito</span>
            <span style="font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #1A1714;">JANE AUSTEN</span>
          </span>
        </span>
      </span>
    </button>
    <button aria-label="Remover Memórias Póstumas de Brás Cubas da estante" aria-pressed="true" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left;">
      <span style="position: relative; display: block; width: 100%;">
        <span aria-hidden="true" style="position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        <span style="position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #058CD7; box-shadow: 3px 3px 0 #1A1714; overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></span>
          <div style="position: absolute; left: 15px; right: 14px; top: 16px; display: flex; flex-direction: column; gap: 5px;"><div style="height: 5px; border-radius: 5px; background: #F7F0E3;"></div><div style="height: 5px; width: 70%; border-radius: 5px; background: #F7F0E3;"></div><div style="height: 5px; width: 40%; border-radius: 5px; background: #F7F0E3;"></div></div>
          <span style="position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px;">
            <span style="font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FFFAF1;">Brás<br>Cubas</span>
            <span style="font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">MACHADO DE ASSIS</span>
          </span>
        </span>
      </span>
    </button>
    <button aria-label="Adicionar A Hora da Estrela à estante" aria-pressed="false" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left;">
      <span style="position: relative; display: block; width: 100%;">
        <span aria-hidden="true" style="position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round"><path d="M12 5v14M5 12h14"></path></svg></span>
        <span style="position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FF552E;  overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></span>
          <svg width="44" height="44" viewBox="0 0 24 24" style="position: absolute; right: 12px; top: 12px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1"></path></svg>
          <span style="position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px;">
            <span style="font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FFFAF1;">A Hora da<br>Estrela</span>
            <span style="font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">CLARICE LISPECTOR</span>
          </span>
        </span>
      </span>
    </button>
    <button aria-label="Adicionar Assassinato no Expresso do Oriente à estante" aria-pressed="false" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left;">
      <span style="position: relative; display: block; width: 100%;">
        <span aria-hidden="true" style="position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round"><path d="M12 5v14M5 12h14"></path></svg></span>
        <span style="position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #2B2420;  overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></span>
          <div style="position: absolute; left: 7px; right: 0; top: 0; height: 74px; background: repeating-linear-gradient(135deg, #FED170 0 4px, transparent 4px 14px); opacity: 0.85;"></div>
          <span style="position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px;">
            <span style="font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FFFAF1;">Expresso<br>do Oriente</span>
            <span style="font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">AGATHA CHRISTIE</span>
          </span>
        </span>
      </span>
    </button>
    <button aria-label="Adicionar O Cortiço à estante" aria-pressed="false" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left;">
      <span style="position: relative; display: block; width: 100%;">
        <span aria-hidden="true" style="position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round"><path d="M12 5v14M5 12h14"></path></svg></span>
        <span style="position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #00995E;  overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></span>
          <div style="position: absolute; left: 20px; top: 16px; width: 54px; height: 60px; border-radius: 27px 27px 0 0; background: #FED170;"></div><div style="position: absolute; left: 36px; top: 42px; width: 22px; height: 34px; border-radius: 11px 11px 0 0; background: #00995E;"></div>
          <span style="position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px;">
            <span style="font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FFFAF1;">O Cortiço</span>
            <span style="font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">ALUÍSIO AZEVEDO</span>
          </span>
        </span>
      </span>
    </button>
</div>

<button style="margin-top: 8px; flex-shrink: 0; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
  <span style="color: #F7F0E3;">Continuar</span>
  <span style="min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #F7F0E3; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12.5px; font-weight: 800; color: #1A1714;">3</span>
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
</button>
```

## Especificação pixel a pixel

Seção `e14.suggestions` — retângulo absoluto no canvas 390×844: **x=20, y=339.43, w=358, h=408.57**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e14.suggestions.header` | box | 0 | 0 | 350 | 21.6 | `margin-top: 20px; display: flex; align-items: center; justify-content: space-between; gap: 10px` |  |
| 2 | `e14.suggestions.title` ±1 | text | 0 | 0 | 177.99 | 21.6 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.3px` | Bricolage (opsz 18) 18/normal peso 800 ls -0.3px #1A1714 |
| 3 | `e14.suggestions.note` ±1 | text | 251.52 | 3.29 | 98.47 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #5B544B; white-space: nowrap` | Figtree 12.5/normal peso 700 ls normal #5B544B |
| 4 | `e14.suggestions.grid` | box | 0 | 37.59 | 358 | 370.98 | `margin-top: 16px; flex: 1 1 0; min-height: 0; overflow: hidden; padding: 8px 8px 0 0; margin-right: -8px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); align-content: start; gap: 20px 12px; -webkit-mask-image: linear-gradient(180deg, #000 calc(100% - 22px), transparent 100%); mask-image: linear-gradient(180deg, #000 calc(100% - 22px), transparent 100%)` |  |
| 5 | `e14.suggestions.book1` | box | 0 | 45.59 | 108.67 | 152 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left` |  |
| 6 | `e14.suggestions.book1.wrap` | box | 0 | 45.59 | 108.67 | 152 | `position: relative; display: block; width: 100%` |  |
| 7 | `e14.suggestions.book1.toggle` | box | 86.67 | 37.59 | 30 | 30 | `position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1` |  |
| 8 | `e14.suggestions.book1.toggle.icon` | icon | 94.67 | 45.59 | 14 | 14 | `—` |  |
| 9 | `e14.suggestions.book1.cover` | box | 0 | 45.59 | 108.67 | 152 | `position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #552CB7; box-shadow: 3px 3px 0 #1A1714; overflow: hidden; box-sizing: border-box` |  |
| 10 | `e14.suggestions.book1.cover.spine` | box | 1.5 | 47.09 | 7 | 149 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 11 | `e14.suggestions.book1.cover.sun` | box | 67.17 | 33.09 | 54 | 54 | `position: absolute; right: -14px; top: -14px; width: 54px; height: 54px; border-radius: 50%; background: #FED170` |  |
| 12 | `e14.suggestions.book1.cover.ring` | box | 70.17 | 81.09 | 15 | 15 | `position: absolute; right: 22px; top: 34px; width: 12px; height: 12px; border-radius: 50%; border: 1.5px solid #FED170` |  |
| 13 | `e14.suggestions.book1.cover.textBlock` | box | 15.5 | 139.52 | 85.67 | 46.57 | `position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px` |  |
| 14 | `e14.suggestions.book1.cover.title` | text | 15.5 | 139.52 | 85.67 | 34.96 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FED170` | Instrument Serif 19/17.48px peso 400 ls normal #FED170 |
| 15 | `e14.suggestions.book1.cover.author` | text | 15.5 | 179.48 | 85.67 | 6.61 | `font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FED170` | Figtree 5.5/normal peso 700 ls 0.77px #FED170 |
| 16 | `e14.suggestions.book2` | box | 120.67 | 45.59 | 108.67 | 152 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left` |  |
| 17 | `e14.suggestions.book2.wrap` | box | 120.67 | 45.59 | 108.67 | 152 | `position: relative; display: block; width: 100%` |  |
| 18 | `e14.suggestions.book2.toggle` | box | 207.33 | 37.59 | 30 | 30 | `position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1` |  |
| 19 | `e14.suggestions.book2.toggle.icon` | icon | 215.33 | 45.59 | 14 | 14 | `—` |  |
| 20 | `e14.suggestions.book2.cover` | box | 120.67 | 45.59 | 108.67 | 152 | `position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #F2A815; box-shadow: 3px 3px 0 #1A1714; overflow: hidden; box-sizing: border-box` |  |
| 21 | `e14.suggestions.book2.cover.spine` | box | 122.17 | 47.09 | 7 | 149 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 22 | `e14.suggestions.book2.cover.glow` | box | 129.17 | 47.09 | 98.67 | 70 | `position: absolute; left: 7px; right: 0; top: 0; height: 70px; background: radial-gradient(circle, #FFFAF1 2.2px, transparent 2.6px) 0 0/14px 14px` |  |
| 23 | `e14.suggestions.book2.cover.textBlock` | box | 136.17 | 139.52 | 85.67 | 46.57 | `position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px` |  |
| 24 | `e14.suggestions.book2.cover.title` | text | 136.17 | 139.52 | 85.67 | 34.96 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #1A1714` | Instrument Serif 19/17.48px peso 400 ls normal #1A1714 |
| 25 | `e14.suggestions.book2.cover.author` | text | 136.17 | 179.48 | 85.67 | 6.61 | `font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #1A1714` | Figtree 5.5/normal peso 700 ls 0.77px #1A1714 |
| 26 | `e14.suggestions.book3` | box | 241.33 | 45.59 | 108.67 | 152 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left` |  |
| 27 | `e14.suggestions.book3.wrap` | box | 241.33 | 45.59 | 108.67 | 152 | `position: relative; display: block; width: 100%` |  |
| 28 | `e14.suggestions.book3.toggle` | box | 328 | 37.59 | 30 | 30 | `position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1` |  |
| 29 | `e14.suggestions.book3.toggle.icon` | icon | 336 | 45.59 | 14 | 14 | `—` |  |
| 30 | `e14.suggestions.book3.cover` | box | 241.33 | 45.59 | 108.67 | 152 | `position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #058CD7; box-shadow: 3px 3px 0 #1A1714; overflow: hidden; box-sizing: border-box` |  |
| 31 | `e14.suggestions.book3.cover.spine` | box | 242.83 | 47.09 | 7 | 149 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 32 | `e14.suggestions.book3.cover.lines` | box | 257.83 | 63.09 | 76.67 | 25 | `position: absolute; left: 15px; right: 14px; top: 16px; display: flex; flex-direction: column; gap: 5px` |  |
| 33 | `e14.suggestions.book3.cover.lines.line1` | box | 257.83 | 63.09 | 76.67 | 5 | `height: 5px; border-radius: 5px; background: #F7F0E3` |  |
| 34 | `e14.suggestions.book3.cover.lines.line2` | box | 257.83 | 73.09 | 53.67 | 5 | `height: 5px; width: 70%; border-radius: 5px; background: #F7F0E3` |  |
| 35 | `e14.suggestions.book3.cover.lines.line3` | box | 257.83 | 83.09 | 30.67 | 5 | `height: 5px; width: 40%; border-radius: 5px; background: #F7F0E3` |  |
| 36 | `e14.suggestions.book3.cover.textBlock` | box | 256.83 | 139.52 | 85.67 | 46.57 | `position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px` |  |
| 37 | `e14.suggestions.book3.cover.title` | text | 256.83 | 139.52 | 85.67 | 34.96 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FFFAF1` | Instrument Serif 19/17.48px peso 400 ls normal #FFFAF1 |
| 38 | `e14.suggestions.book3.cover.author` | text | 256.83 | 179.48 | 85.67 | 6.61 | `font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 5.5/normal peso 700 ls 0.77px #FFFAF1 |
| 39 | `e14.suggestions.book4` | box | 0 | 217.59 | 108.67 | 152 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left` |  |
| 40 | `e14.suggestions.book4.wrap` | box | 0 | 217.59 | 108.67 | 152 | `position: relative; display: block; width: 100%` |  |
| 41 | `e14.suggestions.book4.toggle` | box | 86.67 | 209.59 | 30 | 30 | `position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1` |  |
| 42 | `e14.suggestions.book4.toggle.icon` | icon | 94.67 | 217.59 | 14 | 14 | `—` |  |
| 43 | `e14.suggestions.book4.cover` | box | 0 | 217.59 | 108.67 | 152 | `position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box` |  |
| 44 | `e14.suggestions.book4.cover.spine` | box | 1.5 | 219.09 | 7 | 149 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 45 | `e14.suggestions.book4.cover.star` | icon | 51.17 | 231.09 | 44 | 44 | `position: absolute; right: 12px; top: 12px` |  |
| 46 | `e14.suggestions.book4.cover.textBlock` | box | 15.5 | 311.53 | 85.67 | 46.57 | `position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px` |  |
| 47 | `e14.suggestions.book4.cover.title` | text | 15.5 | 311.53 | 85.67 | 34.96 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FFFAF1` | Instrument Serif 19/17.48px peso 400 ls normal #FFFAF1 |
| 48 | `e14.suggestions.book4.cover.author` | text | 15.5 | 351.48 | 85.67 | 6.61 | `font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 5.5/normal peso 700 ls 0.77px #FFFAF1 |
| 49 | `e14.suggestions.book5` | box | 120.67 | 217.59 | 108.67 | 152 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left` |  |
| 50 | `e14.suggestions.book5.wrap` | box | 120.67 | 217.59 | 108.67 | 152 | `position: relative; display: block; width: 100%` |  |
| 51 | `e14.suggestions.book5.toggle` | box | 207.33 | 209.59 | 30 | 30 | `position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1` |  |
| 52 | `e14.suggestions.book5.toggle.icon` | icon | 215.33 | 217.59 | 14 | 14 | `—` |  |
| 53 | `e14.suggestions.book5.cover` | box | 120.67 | 217.59 | 108.67 | 152 | `position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #2B2420; overflow: hidden; box-sizing: border-box` |  |
| 54 | `e14.suggestions.book5.cover.spine` | box | 122.17 | 219.09 | 7 | 149 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 55 | `e14.suggestions.book5.cover.stripes` | box | 129.17 | 219.09 | 98.67 | 74 | `position: absolute; left: 7px; right: 0; top: 0; height: 74px; background: repeating-linear-gradient(135deg, #FED170 0 4px, transparent 4px 14px); opacity: 0.85` |  |
| 56 | `e14.suggestions.book5.cover.textBlock` | box | 136.17 | 311.53 | 85.67 | 46.57 | `position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px` |  |
| 57 | `e14.suggestions.book5.cover.title` | text | 136.17 | 311.53 | 85.67 | 34.96 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FFFAF1` | Instrument Serif 19/17.48px peso 400 ls normal #FFFAF1 |
| 58 | `e14.suggestions.book5.cover.author` | text | 136.17 | 351.48 | 85.67 | 6.61 | `font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 5.5/normal peso 700 ls 0.77px #FFFAF1 |
| 59 | `e14.suggestions.book6` | box | 241.33 | 217.59 | 108.67 | 152 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; gap: 7px; min-width: 0; text-align: left` |  |
| 60 | `e14.suggestions.book6.wrap` | box | 241.33 | 217.59 | 108.67 | 152 | `position: relative; display: block; width: 100%` |  |
| 61 | `e14.suggestions.book6.toggle` | box | 328 | 209.59 | 30 | 30 | `position: absolute; right: -8px; top: -8px; width: 30px; height: 30px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 1` |  |
| 62 | `e14.suggestions.book6.toggle.icon` | icon | 336 | 217.59 | 14 | 14 | `—` |  |
| 63 | `e14.suggestions.book6.cover` | box | 241.33 | 217.59 | 108.67 | 152 | `position: relative; display: block; width: 100%; height: 152px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box` |  |
| 64 | `e14.suggestions.book6.cover.spine` | box | 242.83 | 219.09 | 7 | 149 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 65 | `e14.suggestions.book6.cover.arch` | box | 262.83 | 235.09 | 54 | 60 | `position: absolute; left: 20px; top: 16px; width: 54px; height: 60px; border-radius: 27px 27px 0 0; background: #FED170` |  |
| 66 | `e14.suggestions.book6.cover.door` | box | 278.83 | 261.09 | 22 | 34 | `position: absolute; left: 36px; top: 42px; width: 22px; height: 34px; border-radius: 11px 11px 0 0; background: #00995E` |  |
| 67 | `e14.suggestions.book6.cover.textBlock` | box | 256.83 | 329 | 85.67 | 29.09 | `position: absolute; left: 14px; right: 6px; bottom: 10px; display: flex; flex-direction: column; gap: 5px` |  |
| 68 | `e14.suggestions.book6.cover.title` | text | 256.83 | 329 | 85.67 | 17.48 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.92; color: #FFFAF1` | Instrument Serif 19/17.48px peso 400 ls normal #FFFAF1 |
| 69 | `e14.suggestions.book6.cover.author` | text | 256.83 | 351.48 | 85.67 | 6.61 | `font-size: 5.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 5.5/normal peso 700 ls 0.77px #FFFAF1 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e14.suggestions.title` | 1 | Sugestões para você | 16.74 | 0 | 177.99 | 177.99 |
| `e14.suggestions.note` | 1 | dos seus gêneros | 15.17 | 251.52 | 350 | 98.48 |
| `e14.suggestions.book1.cover.title` | 1 | Dom | 154.72 | 15.5 | 46.7 | 31.2 |
| `e14.suggestions.book1.cover.title` | 2 | Casmurro | 172.2 | 15.5 | 79.89 | 64.39 |
| `e14.suggestions.book1.cover.author` | 1 | MACHADO DE ASSIS | 184.71 | 15.5 | 81.78 | 66.28 |
| `e14.suggestions.book2.cover.title` | 1 | Orgulho e | 154.72 | 136.17 | 199 | 62.83 |
| `e14.suggestions.book2.cover.title` | 2 | Preconceito | 172.2 | 136.17 | 211.03 | 74.86 |
| `e14.suggestions.book2.cover.author` | 1 | JANE AUSTEN | 184.71 | 136.17 | 182.24 | 46.07 |
| `e14.suggestions.book3.cover.title` | 1 | Brás | 154.72 | 256.83 | 285.05 | 28.22 |
| `e14.suggestions.book3.cover.title` | 2 | Cubas | 172.2 | 256.83 | 296.2 | 39.37 |
| `e14.suggestions.book3.cover.author` | 1 | MACHADO DE ASSIS | 184.71 | 256.83 | 323.11 | 66.28 |
| `e14.suggestions.book4.cover.title` | 1 | A Hora da | 326.72 | 15.5 | 77.97 | 62.47 |
| `e14.suggestions.book4.cover.title` | 2 | Estrela | 344.2 | 15.5 | 59.43 | 43.93 |
| `e14.suggestions.book4.cover.author` | 1 | CLARICE LISPECTOR | 356.71 | 15.5 | 82.64 | 67.14 |
| `e14.suggestions.book5.cover.title` | 1 | Expresso | 326.72 | 136.17 | 192.77 | 56.6 |
| `e14.suggestions.book5.cover.title` | 2 | do Oriente | 344.2 | 136.17 | 203.71 | 67.54 |
| `e14.suggestions.book5.cover.author` | 1 | AGATHA CHRISTIE | 356.71 | 136.17 | 196.25 | 60.08 |
| `e14.suggestions.book6.cover.title` | 1 | O Cortiço | 344.2 | 256.83 | 316.59 | 59.76 |
| `e14.suggestions.book6.cover.author` | 1 | ALUÍSIO AZEVEDO | 356.71 | 256.83 | 317.32 | 60.49 |

Seção `e14.continue` — retângulo absoluto no canvas 390×844: **x=20, y=756, w=350, h=54**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 70 | `e14.continue` | box | 0 | 0 | 350 | 54 | `margin-top: 8px; flex-shrink: 0; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 71 | `e14.continue.label` ±1 | text | 105.75 | 17.4 | 74.5 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 72 | `e14.continue.count` ±1 | box+text | 190.24 | 15 | 24.01 | 24 | `min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #F7F0E3; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12.5px; font-weight: 800; color: #1A1714` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 73 | `e14.continue.icon` ±1 | icon | 224.25 | 17 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e14.continue.label` | 1 | Continuar | 32.6 | 105.75 | 180.24 | 74.49 |
| `e14.continue.count` | 1 | 3 | 31.38 | 198.74 | 205.75 | 7.01 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Sugestões para você" Bricolage 18/800 ls −0,3 e "dos seus gêneros" 12,5/700, 20 abaixo da busca.
2. Grade de 3 (gap 20/12, 16 abaixo; padding 8/8/0/0 e `margin-right −8`, para o selo caber; máscara nos últimos 22): capas de 152 de altura (largura da coluna), raio 4/9/9/4, borda 1,5, a lombada de 7, título Instrument Serif 19 `lh 0,92` + autor 5,5/700.
3. Na estante: sombra 3/3 e o selo 30 `{{brand}}` com o visto 14 em `right/top −8`; fora: sem sombra e o selo `#FFFAF1` com o "+" 14.
4. "Continuar" com a contagem (3).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As capas da fixture são CSS (círculos, bolinhas, listras): com dados reais, a capa do catálogo (D-79).
- O selo passa 8 da capa: a grade tem o recuo de 8 à direita e no topo para o selo não ser cortado — no app, `Clip.none` ou o mesmo recuo.
- `e14.suggestions.grid` tem máscara `linear-gradient(#000000 calc(100% - 22px), #000000@0 100%)` → `ShaderMask`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_014_onboarding_primeiros_livros_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_014_onboarding_primeiros_livros_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e14.suggestions.book1` |  | Remover Dom Casmurro da estante | aria-pressed=true |
| `e14.suggestions.book1.toggle` |  |  | aria-hidden=true |
| `e14.suggestions.book2` |  | Remover Orgulho e Preconceito da estante | aria-pressed=true |
| `e14.suggestions.book2.toggle` |  |  | aria-hidden=true |
| `e14.suggestions.book3` |  | Remover Memórias Póstumas de Brás Cubas da estante | aria-pressed=true |
| `e14.suggestions.book3.toggle` |  |  | aria-hidden=true |
| `e14.suggestions.book4` |  | Adicionar A Hora da Estrela à estante | aria-pressed=false |
| `e14.suggestions.book4.toggle` |  |  | aria-hidden=true |
| `e14.suggestions.book5` |  | Adicionar Assassinato no Expresso do Oriente à estante | aria-pressed=false |
| `e14.suggestions.book5.toggle` |  |  | aria-hidden=true |
| `e14.suggestions.book6` |  | Adicionar O Cortiço à estante | aria-pressed=false |
| `e14.suggestions.book6.toggle` |  |  | aria-hidden=true |
| `e14.continue.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e14.suggestions.book1.toggle` | CircleIconButton / NeoBox circular |  |
| `e14.suggestions.book1.toggle.icon` | AppSvg(AppIconsInicio.checkTiny, size: 14) |  |
| `e14.suggestions.book1.cover` | NeoBox |  |
| `e14.suggestions.book1.cover.spine` | NeoBox |  |
| `e14.suggestions.book1.cover.sun` | CircleIconButton / NeoBox circular |  |
| `e14.suggestions.book1.cover.ring` | CircleIconButton / NeoBox circular |  |
| `e14.suggestions.book2.toggle` | CircleIconButton / NeoBox circular |  |
| `e14.suggestions.book2.toggle.icon` | AppSvg(AppIconsInicio.checkTiny, size: 14) |  |
| `e14.suggestions.book2.cover` | NeoBox |  |
| `e14.suggestions.book2.cover.spine` | NeoBox |  |
| `e14.suggestions.book3.toggle` | CircleIconButton / NeoBox circular |  |
| `e14.suggestions.book3.toggle.icon` | AppSvg(AppIconsInicio.checkTiny, size: 14) |  |
| `e14.suggestions.book3.cover` | NeoBox |  |
| `e14.suggestions.book3.cover.spine` | NeoBox |  |
| `e14.suggestions.book3.cover.lines.line1` | NeoBox |  |
| `e14.suggestions.book3.cover.lines.line2` | NeoBox |  |
| `e14.suggestions.book3.cover.lines.line3` | NeoBox |  |
| `e14.suggestions.book4.toggle` | CircleIconButton / NeoBox circular |  |
| `e14.suggestions.book4.toggle.icon` | AppSvg(AppIconsLeitor.plus, size: 14) |  |
| `e14.suggestions.book4.cover` | NeoBox |  |
| `e14.suggestions.book4.cover.spine` | NeoBox |  |
| `e14.suggestions.book4.cover.star` | AppSvg(AppIconsInicio.sparkleSolidCream, size: 44) |  |
| `e14.suggestions.book5.toggle` | CircleIconButton / NeoBox circular |  |
| `e14.suggestions.book5.toggle.icon` | AppSvg(AppIconsLeitor.plus, size: 14) |  |
| `e14.suggestions.book5.cover` | NeoBox |  |
| `e14.suggestions.book5.cover.spine` | NeoBox |  |
| `e14.suggestions.book5.cover.stripes` | HatchPainter (hachura 135°) dentro do contorno |  |
| `e14.suggestions.book6.toggle` | CircleIconButton / NeoBox circular |  |
| `e14.suggestions.book6.toggle.icon` | AppSvg(AppIconsLeitor.plus, size: 14) |  |
| `e14.suggestions.book6.cover` | NeoBox |  |
| `e14.suggestions.book6.cover.spine` | NeoBox |  |
| `e14.suggestions.book6.cover.arch` | NeoBox |  |
| `e14.suggestions.book6.cover.door` | NeoBox |  |
| `e14.continue` | NeoBox |  |
| `e14.continue.count` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e14.continue.icon` | AppSvg(AppIconsEntrada.arrowForward, size: 20) |  |

## Interações

- Capa → adiciona ou tira da estante (o círculo vira visto lavanda e a capa ganha sombra); `aria-pressed` e o rótulo "Adicionar…"/"Remover… da estante".
- Continuar → o passo 4 (15). Não é obrigatório adicionar livros.
- Ao chegar no passo 3 pela primeira vez, a dica do scanner (13b).

## Dados

- Sugestões vindas dos gêneros escolhidos (o catálogo); o status com que os adicionados entram na estante é pergunta da T16.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L14.1** Grade de sugestões com a máscara
- **L14.2** Selo de adicionar e tirar
- **L14.3** Continuar com a contagem
- **L14.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e14.suggestions', 'e14.continue'), todos os ids de `kRef14.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/014_onboarding_primeiros_livros_390x844@3x.png` no recorte da fase (y 331.43–818) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef14w360` e `kRef14w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L14.1 Grade de sugestões com a máscara
- [ ] L14.2 Selo de adicionar e tirar
- [ ] L14.3 Continuar com a contagem
- [ ] L14.4 Verificação + relatório
- [ ] Geometria 73/73 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
