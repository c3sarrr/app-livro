# FASE L05 — Perfil — Lendo agora (3 capas com o marcador) e 2026 em leitura (a meta, a estante de 24 lombadas e 6 vagas, os números)

> Tela 05 · prancha `005_perfil` (05 · Perfil, canvas 390×2510) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L05_2_lendo_e_ano@3x.png` · `docs/design/medicao/projeto/png/redline/L05_2_lendo_e_ano_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/005_perfil_390x2510@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_005_perfil.json` · `test/reference/projeto/reference_layout_005_perfil.dart` (`kRef05`).
> Arquivos sugeridos: `lib/features/profile/presentation/sections/reading_now_section.dart`, `lib/features/profile/presentation/sections/year_section.dart`, `lib/features/profile/presentation/sections/year_shelf.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Perfil (05), no Resumo: "Lendo agora" com 3 capas e o marcador de fita, e o cartão amarelo "2026 em leitura" — 24 de 30 livros na meta do ano, "2 à frente", a estante do ano (24 lombadas e 6 vagas tracejadas) e os quatro números do ano.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`, `{{card}}` = padrão `#FF552E`.

```html
<!-- Currently reading -->
<section aria-label="Lendo agora" style="margin-top: 28px; display: flex; flex-direction: column; gap: 14px;">
  <div style="display: flex; align-items: center; justify-content: space-between;">
    <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Lendo agora</h2>
    <a href="#" style="height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700;">Ver os 4
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
    </a>
  </div>
  <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px;">
    <a href="#" aria-label="Dom Casmurro, 62% lido" style="display: flex; flex-direction: column; gap: 8px;">
      <span style="position: relative; display: block; height: 132px;">
        <span style="position: absolute; inset: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #552CB7; overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.22);"></span>
          <span style="position: absolute; right: -16px; top: -16px; width: 56px; height: 56px; border-radius: 50%; background: #FED170;"></span>
          <span style="position: absolute; left: 13px; right: 6px; bottom: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 18px; line-height: 0.92; color: #FED170;">Dom<br>Casmurro</span>
        </span>
        <svg width="14" height="26" viewBox="0 0 16 30" aria-hidden="true" style="position: absolute; top: -7px; right: 10px;"><path d="M1.5 0V28L8 22.5 14.5 28V0" fill="#FF552E" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg>
      </span>
      <span style="font-size: 12.5px; font-weight: 800;">62% · pág. 159</span>
    </a>
    <a href="#" aria-label="Mrs. Dalloway, 34% lido" style="display: flex; flex-direction: column; gap: 8px;">
      <span style="position: relative; display: block; height: 132px;">
        <span style="position: absolute; inset: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #ABCF82; overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.14);"></span>
          <span style="position: absolute; left: 22px; right: 16px; top: 20px; height: 32px; border-radius: 32px 32px 0 0; background: #1A1714;"></span>
          <span style="position: absolute; left: 13px; right: 6px; bottom: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 18px; line-height: 0.92; color: #1A1714;">Mrs.<br>Dalloway</span>
        </span>
        <svg width="14" height="26" viewBox="0 0 16 30" aria-hidden="true" style="position: absolute; top: -7px; right: 10px;"><path d="M1.5 0V28L8 22.5 14.5 28V0" fill="#FF552E" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg>
      </span>
      <span style="font-size: 12.5px; font-weight: 800;">34%</span>
    </a>
    <a href="#" aria-label="Orgulho e Preconceito, 81% lido" style="display: flex; flex-direction: column; gap: 8px;">
      <span style="position: relative; display: block; height: 132px;">
        <span style="position: absolute; inset: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box;">
          <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.1);"></span>
          <span style="position: absolute; left: 20px; top: 18px; width: 32px; height: 32px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></span>
          <span style="position: absolute; left: 40px; top: 38px; width: 18px; height: 18px; border-radius: 50%; background: #1A1714;"></span>
          <span style="position: absolute; left: 13px; right: 4px; bottom: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 15.5px; line-height: 0.95; color: #1A1714;">Orgulho e<br>Preconceito</span>
        </span>
        <svg width="14" height="26" viewBox="0 0 16 30" aria-hidden="true" style="position: absolute; top: -7px; right: 10px;"><path d="M1.5 0V28L8 22.5 14.5 28V0" fill="#FF552E" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg>
      </span>
      <span style="font-size: 12.5px; font-weight: 800;">81%</span>
    </a>
  </div>
</section>

<!-- The reading year -->
<section aria-label="2026 em leitura" style="margin-top: 32px; padding: 18px; border-radius: 28px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 16px;">
  <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px;">2026 em <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 27px; letter-spacing: -0.2px;">leitura</span></h2>

  <div style="display: flex; align-items: flex-end; justify-content: space-between; gap: 10px;">
    <div style="display: flex; align-items: baseline; gap: 8px;">
      <span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 58px; font-weight: 800; line-height: 0.85; letter-spacing: -2px;">24</span>
      <span style="font-size: 14px; font-weight: 700; color: #3D3524;">de 30 livros<br>na meta do ano</span>
    </div>
    <span style="flex-shrink: 0; height: 30px; padding: 0 10px 0 8px; display: flex; align-items: center; gap: 4px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 12px; font-weight: 800; white-space: nowrap;">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 17 17 7"></path><path d="M8 7h9v9"></path></svg>
      2 à frente
    </span>
  </div>

  <!-- The year's shelf: one spine per book read, dashed slots still to go -->
  <div aria-label="24 livros lidos de 30 na meta" style="display: flex; flex-direction: column;">
    <div aria-hidden="true" style="display: flex; align-items: flex-end; gap: 2px; padding: 0 4px; height: 48px;">
        <span style="flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; background: #552CB7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 39px; border-radius: 2px 2px 1px 1px; background: #B6ACE4; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 47px; border-radius: 2px 2px 1px 1px; background: #FFC1C6; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 41px; border-radius: 2px 2px 1px 1px; background: #FF552E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 45px; border-radius: 2px 2px 1px 1px; background: #1A1714; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 38px; border-radius: 2px 2px 1px 1px; background: #058CD7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 46px; border-radius: 2px 2px 1px 1px; background: #ABCF82; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 42px; border-radius: 2px 2px 1px 1px; background: #00995E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 40px; border-radius: 2px 2px 1px 1px; background: #FFC1C6; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 47px; border-radius: 2px 2px 1px 1px; background: #058CD7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 43px; border-radius: 2px 2px 1px 1px; background: #00995E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 39px; border-radius: 2px 2px 1px 1px; background: #F2A815; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 45px; border-radius: 2px 2px 1px 1px; background: #552CB7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 41px; border-radius: 2px 2px 1px 1px; background: #B6ACE4; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 46px; border-radius: 2px 2px 1px 1px; background: #FFC1C6; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 38px; border-radius: 2px 2px 1px 1px; background: #FF552E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; background: #1A1714; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 42px; border-radius: 2px 2px 1px 1px; background: #058CD7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 47px; border-radius: 2px 2px 1px 1px; background: #ABCF82; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 40px; border-radius: 2px 2px 1px 1px; background: #00995E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 43px; border-radius: 2px 2px 1px 1px; background: #FFC1C6; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 45px; border-radius: 2px 2px 1px 1px; background: #058CD7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 39px; border-radius: 2px 2px 1px 1px; background: #00995E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55);"></span></span>
        <span style="flex: 1 1 0; height: 46px; border-radius: 2px 2px 1px 1px; background: #F2A815; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px;"><span style="width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35);"></span></span>
        <span style="flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box;"></span>
        <span style="flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box;"></span>
        <span style="flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box;"></span>
        <span style="flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box;"></span>
        <span style="flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box;"></span>
        <span style="flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box;"></span>
    </div>
    <span aria-hidden="true" style="height: 9px; margin-top: -1.2px; border-radius: 5px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 2px 0 #1A1714; box-sizing: border-box;"></span>
  </div>

  <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px;">
    <div style="padding: 12px 12px 11px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 2px;">
      <span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 25px; font-weight: 800; letter-spacing: -0.6px;">7.480</span>
      <span style="font-size: 12.5px; font-weight: 600; color: #5B544B;">páginas lidas</span>
    </div>
    <div style="padding: 12px 12px 11px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 2px;">
      <span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 25px; font-weight: 800; letter-spacing: -0.6px;">112 h</span>
      <span style="font-size: 12.5px; font-weight: 600; color: #5B544B;">de leitura</span>
    </div>
    <div style="padding: 12px 12px 11px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 2px;">
      <span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 25px; font-weight: 800; letter-spacing: -0.6px;">41 dias</span>
      <span style="font-size: 12.5px; font-weight: 600; color: #5B544B;">maior sequência</span>
    </div>
    <div style="padding: 12px 12px 11px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 2px;">
      <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 27px; line-height: 1.05;">Clássicos</span>
      <span style="font-size: 12.5px; font-weight: 600; color: #5B544B;">gênero do ano</span>
    </div>
  </div>

  <a href="#" style="height: 44px; margin: -6px 0 -8px; display: flex; align-items: center; justify-content: space-between; font-size: 14px; font-weight: 800;">
    Ver estatísticas completas
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
  </a>
</section>
```

## Especificação pixel a pixel

Seção `p05.reading` — retângulo absoluto no canvas 390×2510: **x=20, y=751.57, w=350, h=213.01**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `p05.reading` | box | 0 | 0 | 350 | 213.01 | `margin-top: 28px; display: flex; flex-direction: column; gap: 14px` |  |
| 2 | `p05.reading.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 3 | `p05.reading.header.title` ±1 | text | 0 | 10 | 115.88 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 4 | `p05.reading.header.all` ±1 | text | 275.21 | 0 | 74.79 | 44 | `height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 5 | `p05.reading.header.all.icon` | icon | 332 | 13 | 18 | 18 | `—` |  |
| 6 | `p05.reading.grid` | box | 0 | 58 | 350 | 155.01 | `display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px` |  |
| 7 | `p05.reading.grid.book1` | box | 0 | 58 | 107.33 | 155.01 | `display: flex; flex-direction: column; gap: 8px` |  |
| 8 | `p05.reading.grid.book1.cover` | box | 0 | 58 | 107.33 | 132 | `position: relative; display: block; height: 132px` |  |
| 9 | `p05.reading.grid.book1.cover.art` | box | 0 | 58 | 107.33 | 132 | `position: absolute; inset: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #552CB7; overflow: hidden; box-sizing: border-box` |  |
| 10 | `p05.reading.grid.book1.cover.spine` | box | 1.5 | 59.5 | 6 | 129 | `position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.22)` |  |
| 11 | `p05.reading.grid.book1.cover.circle` | box | 65.83 | 43.5 | 56 | 56 | `position: absolute; right: -16px; top: -16px; width: 56px; height: 56px; border-radius: 50%; background: #FED170` |  |
| 12 | `p05.reading.grid.book1.cover.title` | text | 14.5 | 144.38 | 85.33 | 33.12 | `position: absolute; left: 13px; right: 6px; bottom: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 18px; line-height: 0.92; color: #FED170` | Instrument Serif 18/16.56px peso 400 ls normal #FED170 |
| 13 | `p05.reading.grid.book1.cover.bookmark` | icon | 83.33 | 51 | 14 | 26 | `position: absolute; top: -7px; right: 10px` |  |
| 14 | `p05.reading.grid.book1.caption` | text | 0 | 198 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 800` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 15 | `p05.reading.grid.book2` | box | 121.33 | 58 | 107.33 | 155.01 | `display: flex; flex-direction: column; gap: 8px` |  |
| 16 | `p05.reading.grid.book2.cover` | box | 121.33 | 58 | 107.33 | 132 | `position: relative; display: block; height: 132px` |  |
| 17 | `p05.reading.grid.book2.cover.art` | box | 121.33 | 58 | 107.33 | 132 | `position: absolute; inset: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #ABCF82; overflow: hidden; box-sizing: border-box` |  |
| 18 | `p05.reading.grid.book2.cover.spine` | box | 122.83 | 59.5 | 6 | 129 | `position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.14)` |  |
| 19 | `p05.reading.grid.book2.cover.arch` | box | 144.83 | 79.5 | 66.33 | 32 | `position: absolute; left: 22px; right: 16px; top: 20px; height: 32px; border-radius: 32px 32px 0 0; background: #1A1714` |  |
| 20 | `p05.reading.grid.book2.cover.title` | text | 135.83 | 144.38 | 85.33 | 33.12 | `position: absolute; left: 13px; right: 6px; bottom: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 18px; line-height: 0.92; color: #1A1714` | Instrument Serif 18/16.56px peso 400 ls normal #1A1714 |
| 21 | `p05.reading.grid.book2.cover.bookmark` | icon | 204.67 | 51 | 14 | 26 | `position: absolute; top: -7px; right: 10px` |  |
| 22 | `p05.reading.grid.book2.caption` | text | 121.33 | 198 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 800` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 23 | `p05.reading.grid.book3` | box | 242.67 | 58 | 107.33 | 155.01 | `display: flex; flex-direction: column; gap: 8px` |  |
| 24 | `p05.reading.grid.book3.cover` | box | 242.67 | 58 | 107.33 | 132 | `position: relative; display: block; height: 132px` |  |
| 25 | `p05.reading.grid.book3.cover.art` | box | 242.67 | 58 | 107.33 | 132 | `position: absolute; inset: 0; border-radius: 3px 8px 8px 3px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box` |  |
| 26 | `p05.reading.grid.book3.cover.spine` | box | 244.17 | 59.5 | 6 | 129 | `position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: rgba(0,0,0,0.1)` |  |
| 27 | `p05.reading.grid.book3.cover.ring` | box | 264.17 | 77.5 | 32 | 32 | `position: absolute; left: 20px; top: 18px; width: 32px; height: 32px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 28 | `p05.reading.grid.book3.cover.dot` | box | 284.17 | 97.5 | 18 | 18 | `position: absolute; left: 40px; top: 38px; width: 18px; height: 18px; border-radius: 50%; background: #1A1714` |  |
| 29 | `p05.reading.grid.book3.cover.title` | text | 257.17 | 148.05 | 87.33 | 29.45 | `position: absolute; left: 13px; right: 4px; bottom: 11px; font-family: 'Instrument Serif', Georgia, serif; font-size: 15.5px; line-height: 0.95; color: #1A1714` | Instrument Serif 15.5/14.725px peso 400 ls normal #1A1714 |
| 30 | `p05.reading.grid.book3.cover.bookmark` | icon | 326 | 51 | 14 | 26 | `position: absolute; top: -7px; right: 10px` |  |
| 31 | `p05.reading.grid.book3.caption` | text | 242.67 | 198 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 800` | Figtree 12.5/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.reading.header.title` | 1 | Lendo agora | 28.6 | 0 | 115.88 | 115.88 |
| `p05.reading.header.all` | 1 | Ver os 4 | 26.9 | 275.21 | 328 | 52.79 |
| `p05.reading.grid.book1.cover.title` | 1 | Dom | 158.78 | 14.5 | 44.06 | 29.56 |
| `p05.reading.grid.book1.cover.title` | 2 | Casmurro | 175.34 | 14.5 | 75.5 | 61 |
| `p05.reading.grid.book1.caption` | 1 | 62% · pág. 159 | 209.88 | 0 | 82.21 | 82.21 |
| `p05.reading.grid.book2.cover.title` | 1 | Mrs. | 158.78 | 135.83 | 162.91 | 27.08 |
| `p05.reading.grid.book2.cover.title` | 2 | Dalloway | 175.34 | 135.83 | 192.32 | 56.49 |
| `p05.reading.grid.book2.caption` | 1 | 34% | 209.88 | 121.33 | 146.65 | 25.32 |
| `p05.reading.grid.book3.cover.title` | 1 | Orgulho e | 160.68 | 257.17 | 308.43 | 51.26 |
| `p05.reading.grid.book3.cover.title` | 2 | Preconceito | 175.41 | 257.17 | 318.24 | 61.07 |
| `p05.reading.grid.book3.caption` | 1 | 81% | 209.88 | 242.67 | 265.94 | 23.27 |

Seção `p05.year` — retângulo absoluto no canvas 390×2510: **x=20, y=996.58, w=350, h=442.01**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 32 | `p05.year` | box | 0 | 0 | 350 | 442.01 | `margin-top: 32px; padding: 18px; border-radius: 28px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 16px` |  |
| 33 | `p05.year.title` | text | 19.5 | 19.5 | 311 | 35.1 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/normal peso 800 ls -0.5px #1A1714 |
| 34 | `p05.year.title.serif` ±1 | inline | 114.62 | 19.5 | 65.56 | 35.1 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 27px; letter-spacing: -0.2px` | Instrument Serif itálico 27/normal peso 400 ls -0.2px #1A1714 |
| 35 | `p05.year.goal` | box | 19.5 | 70.6 | 311 | 64.09 | `display: flex; align-items: flex-end; justify-content: space-between; gap: 10px` |  |
| 36 | `p05.year.goal.count` ±1 | box | 19.5 | 70.6 | 172.01 | 64.09 | `display: flex; align-items: baseline; gap: 8px` |  |
| 37 | `p05.year.goal.count.number` ±1 | text | 19.5 | 70.6 | 65.66 | 49.3 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 58px; font-weight: 800; line-height: 0.85; letter-spacing: -2px` | Bricolage (opsz 58) 58/49.3px peso 800 ls -2px #1A1714 |
| 38 | `p05.year.goal.count.label` ±1 | text | 93.16 | 101.09 | 98.35 | 33.6 | `font-size: 14px; font-weight: 700; color: #3D3524` | Figtree 14/normal peso 700 ls normal #3D3524 |
| 39 | `p05.year.goal.ahead` ±1 | box+text | 238.62 | 104.69 | 91.88 | 30 | `flex-shrink: 0; height: 30px; padding: 0 10px 0 8px; display: flex; align-items: center; gap: 4px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 12px; font-weight: 800; white-space: nowrap` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 40 | `p05.year.goal.ahead.icon` ±1 | icon | 248.12 | 113.19 | 13 | 13 | `—` |  |
| 41 | `p05.year.shelf` | box | 19.5 | 150.69 | 311 | 55.8 | `display: flex; flex-direction: column` |  |
| 42 | `p05.year.shelf.books` | box | 19.5 | 150.69 | 311 | 48 | `display: flex; align-items: flex-end; gap: 2px; padding: 0 4px; height: 48px` |  |
| 43 | `p05.year.shelf.books.book1` | box | 23.5 | 154.69 | 8.17 | 44 | `flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; background: #552CB7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 44 | `p05.year.shelf.books.book1.line` | box | 25.85 | 160.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 45 | `p05.year.shelf.books.book2` | box | 33.67 | 159.69 | 8.17 | 39 | `flex: 1 1 0; height: 39px; border-radius: 2px 2px 1px 1px; background: #B6ACE4; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 46 | `p05.year.shelf.books.book2.line` | box | 36.02 | 165.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 47 | `p05.year.shelf.books.book3` | box | 43.83 | 151.69 | 8.17 | 47 | `flex: 1 1 0; height: 47px; border-radius: 2px 2px 1px 1px; background: #FFC1C6; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 48 | `p05.year.shelf.books.book3.line` | box | 46.19 | 157.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 49 | `p05.year.shelf.books.book4` | box | 54 | 157.69 | 8.17 | 41 | `flex: 1 1 0; height: 41px; border-radius: 2px 2px 1px 1px; background: #FF552E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 50 | `p05.year.shelf.books.book4.line` | box | 56.35 | 163.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 51 | `p05.year.shelf.books.book5` | box | 64.17 | 153.69 | 8.17 | 45 | `flex: 1 1 0; height: 45px; border-radius: 2px 2px 1px 1px; background: #1A1714; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 52 | `p05.year.shelf.books.book5.line` | box | 66.52 | 159.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 53 | `p05.year.shelf.books.book6` | box | 74.33 | 160.69 | 8.17 | 38 | `flex: 1 1 0; height: 38px; border-radius: 2px 2px 1px 1px; background: #058CD7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 54 | `p05.year.shelf.books.book6.line` | box | 76.69 | 166.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 55 | `p05.year.shelf.books.book7` | box | 84.5 | 152.69 | 8.17 | 46 | `flex: 1 1 0; height: 46px; border-radius: 2px 2px 1px 1px; background: #ABCF82; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 56 | `p05.year.shelf.books.book7.line` | box | 86.85 | 158.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 57 | `p05.year.shelf.books.book8` | box | 94.67 | 156.69 | 8.17 | 42 | `flex: 1 1 0; height: 42px; border-radius: 2px 2px 1px 1px; background: #00995E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 58 | `p05.year.shelf.books.book8.line` | box | 97.02 | 162.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 59 | `p05.year.shelf.books.book9` | box | 104.83 | 158.69 | 8.17 | 40 | `flex: 1 1 0; height: 40px; border-radius: 2px 2px 1px 1px; background: #FFC1C6; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 60 | `p05.year.shelf.books.book9.line` | box | 107.19 | 164.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 61 | `p05.year.shelf.books.book10` | box | 115 | 151.69 | 8.17 | 47 | `flex: 1 1 0; height: 47px; border-radius: 2px 2px 1px 1px; background: #058CD7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 62 | `p05.year.shelf.books.book10.line` | box | 117.35 | 157.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 63 | `p05.year.shelf.books.book11` | box | 125.17 | 155.69 | 8.17 | 43 | `flex: 1 1 0; height: 43px; border-radius: 2px 2px 1px 1px; background: #00995E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 64 | `p05.year.shelf.books.book11.line` | box | 127.52 | 161.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 65 | `p05.year.shelf.books.book12` | box | 135.33 | 159.69 | 8.17 | 39 | `flex: 1 1 0; height: 39px; border-radius: 2px 2px 1px 1px; background: #F2A815; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 66 | `p05.year.shelf.books.book12.line` | box | 137.69 | 165.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 67 | `p05.year.shelf.books.book13` | box | 145.5 | 153.69 | 8.17 | 45 | `flex: 1 1 0; height: 45px; border-radius: 2px 2px 1px 1px; background: #552CB7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 68 | `p05.year.shelf.books.book13.line` | box | 147.85 | 159.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 69 | `p05.year.shelf.books.book14` | box | 155.67 | 157.69 | 8.17 | 41 | `flex: 1 1 0; height: 41px; border-radius: 2px 2px 1px 1px; background: #B6ACE4; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 70 | `p05.year.shelf.books.book14.line` | box | 158.02 | 163.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 71 | `p05.year.shelf.books.book15` | box | 165.83 | 152.69 | 8.17 | 46 | `flex: 1 1 0; height: 46px; border-radius: 2px 2px 1px 1px; background: #FFC1C6; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 72 | `p05.year.shelf.books.book15.line` | box | 168.19 | 158.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 73 | `p05.year.shelf.books.book16` | box | 176 | 160.69 | 8.17 | 38 | `flex: 1 1 0; height: 38px; border-radius: 2px 2px 1px 1px; background: #FF552E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 74 | `p05.year.shelf.books.book16.line` | box | 178.35 | 166.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 75 | `p05.year.shelf.books.book17` | box | 186.17 | 154.69 | 8.17 | 44 | `flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; background: #1A1714; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 76 | `p05.year.shelf.books.book17.line` | box | 188.52 | 160.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 77 | `p05.year.shelf.books.book18` | box | 196.33 | 156.69 | 8.17 | 42 | `flex: 1 1 0; height: 42px; border-radius: 2px 2px 1px 1px; background: #058CD7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 78 | `p05.year.shelf.books.book18.line` | box | 198.69 | 162.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 79 | `p05.year.shelf.books.book19` | box | 206.5 | 151.69 | 8.17 | 47 | `flex: 1 1 0; height: 47px; border-radius: 2px 2px 1px 1px; background: #ABCF82; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 80 | `p05.year.shelf.books.book19.line` | box | 208.85 | 157.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 81 | `p05.year.shelf.books.book20` | box | 216.67 | 158.69 | 8.17 | 40 | `flex: 1 1 0; height: 40px; border-radius: 2px 2px 1px 1px; background: #00995E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 82 | `p05.year.shelf.books.book20.line` | box | 219.02 | 164.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 83 | `p05.year.shelf.books.book21` | box | 226.83 | 155.69 | 8.17 | 43 | `flex: 1 1 0; height: 43px; border-radius: 2px 2px 1px 1px; background: #FFC1C6; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 84 | `p05.year.shelf.books.book21.line` | box | 229.19 | 161.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 85 | `p05.year.shelf.books.book22` | box | 237 | 153.69 | 8.17 | 45 | `flex: 1 1 0; height: 45px; border-radius: 2px 2px 1px 1px; background: #058CD7; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 86 | `p05.year.shelf.books.book22.line` | box | 239.35 | 159.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 87 | `p05.year.shelf.books.book23` | box | 247.17 | 159.69 | 8.17 | 39 | `flex: 1 1 0; height: 39px; border-radius: 2px 2px 1px 1px; background: #00995E; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 88 | `p05.year.shelf.books.book23.line` | box | 249.52 | 165.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(255,250,241,0.55)` |  |
| 89 | `p05.year.shelf.books.book24` | box | 257.33 | 152.69 | 8.17 | 46 | `flex: 1 1 0; height: 46px; border-radius: 2px 2px 1px 1px; background: #F2A815; border: 1.2px solid #1A1714; box-sizing: border-box; display: flex; justify-content: center; padding-top: 5px` |  |
| 90 | `p05.year.shelf.books.book24.line` | box | 259.69 | 158.89 | 3.46 | 2 | `width: 60%; height: 2px; border-radius: 1px; background: rgba(26,23,20,0.35)` |  |
| 91 | `p05.year.shelf.books.slot1` | box | 267.5 | 154.69 | 8.17 | 44 | `flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box` |  |
| 92 | `p05.year.shelf.books.slot2` | box | 277.67 | 154.69 | 8.17 | 44 | `flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box` |  |
| 93 | `p05.year.shelf.books.slot3` | box | 287.83 | 154.69 | 8.17 | 44 | `flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box` |  |
| 94 | `p05.year.shelf.books.slot4` | box | 298 | 154.69 | 8.17 | 44 | `flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box` |  |
| 95 | `p05.year.shelf.books.slot5` | box | 308.17 | 154.69 | 8.17 | 44 | `flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box` |  |
| 96 | `p05.year.shelf.books.slot6` | box | 318.33 | 154.69 | 8.17 | 44 | `flex: 1 1 0; height: 44px; border-radius: 2px 2px 1px 1px; border: 1.2px dashed #8A7F63; box-sizing: border-box` |  |
| 97 | `p05.year.shelf.plank` | box | 19.5 | 197.49 | 311 | 9 | `height: 9px; margin-top: -1.2px; border-radius: 5px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 2px 0 #1A1714; box-sizing: border-box` |  |
| 98 | `p05.year.stats` | box | 19.5 | 222.49 | 311 | 154.02 | `display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px` |  |
| 99 | `p05.year.stats.pages` | box | 19.5 | 222.49 | 151.5 | 73.01 | `padding: 12px 12px 11px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 2px` |  |
| 100 | `p05.year.stats.pages.value` | text | 33 | 235.99 | 124.5 | 30 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 25px; font-weight: 800; letter-spacing: -0.6px` | Bricolage (opsz 25) 25/normal peso 800 ls -0.6px #1A1714 |
| 101 | `p05.year.stats.pages.label` | text | 33 | 267.99 | 124.5 | 15.01 | `font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 102 | `p05.year.stats.hours` | box | 179 | 222.49 | 151.5 | 73.01 | `padding: 12px 12px 11px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 2px` |  |
| 103 | `p05.year.stats.hours.value` | text | 192.5 | 235.99 | 124.5 | 30 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 25px; font-weight: 800; letter-spacing: -0.6px` | Bricolage (opsz 25) 25/normal peso 800 ls -0.6px #1A1714 |
| 104 | `p05.year.stats.hours.label` | text | 192.5 | 267.99 | 124.5 | 15.01 | `font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 105 | `p05.year.stats.streak` | box | 19.5 | 303.5 | 151.5 | 73.01 | `padding: 12px 12px 11px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 2px` |  |
| 106 | `p05.year.stats.streak.value` | text | 33 | 317 | 124.5 | 30 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 25px; font-weight: 800; letter-spacing: -0.6px` | Bricolage (opsz 25) 25/normal peso 800 ls -0.6px #1A1714 |
| 107 | `p05.year.stats.streak.label` | text | 33 | 349 | 124.5 | 15.01 | `font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 108 | `p05.year.stats.genre` | box | 179 | 303.5 | 151.5 | 73.01 | `padding: 12px 12px 11px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 2px` |  |
| 109 | `p05.year.stats.genre.value` | text | 192.5 | 317 | 124.5 | 28.35 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 27px; line-height: 1.05` | Instrument Serif itálico 27/28.35px peso 400 ls normal #1A1714 |
| 110 | `p05.year.stats.genre.label` | text | 192.5 | 347.35 | 124.5 | 15.01 | `font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 111 | `p05.year.more` | text | 19.5 | 386.51 | 311 | 44 | `height: 44px; margin: -6px 0 -8px; display: flex; align-items: center; justify-content: space-between; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 112 | `p05.year.more.icon` | icon | 312.5 | 399.51 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.year.title` *(composto)* | 1 | 2026 em leitura | 46.23 | 19.5 | 180.18 | 160.68 |
| `p05.year.goal.count.number` | 1 | 24 | 114.39 | 19.5 | 85.16 | 65.66 |
| `p05.year.goal.count.label` | 1 | de 30 livros | 114.39 | 93.16 | 167.62 | 74.46 |
| `p05.year.goal.count.label` | 2 | na meta do ano | 131.19 | 93.16 | 191.51 | 98.35 |
| `p05.year.goal.ahead` | 1 | 2 à frente | 123.89 | 265.12 | 319 | 53.88 |
| `p05.year.stats.pages.value` | 1 | 7.480 | 259.24 | 33 | 96.48 | 63.48 |
| `p05.year.stats.pages.label` | 1 | páginas lidas | 279.87 | 33 | 105.81 | 72.81 |
| `p05.year.stats.hours.value` | 1 | 112 h | 259.24 | 192.5 | 243.57 | 51.07 |
| `p05.year.stats.hours.label` | 1 | de leitura | 279.87 | 192.5 | 245.8 | 53.3 |
| `p05.year.stats.streak.value` | 1 | 41 dias | 340.25 | 33 | 109.62 | 76.62 |
| `p05.year.stats.streak.label` | 1 | maior sequência | 360.88 | 33 | 125.81 | 92.81 |
| `p05.year.stats.genre.value` | 1 | Clássicos | 340.35 | 192.5 | 277.5 | 85 |
| `p05.year.stats.genre.label` | 1 | gênero do ano | 359.23 | 192.5 | 274.14 | 81.64 |
| `p05.year.more` | 1 | Ver estatísticas completas | 413.41 | 19.5 | 192.88 | 173.38 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Lendo agora" 28 abaixo das abas: o título Bricolage 20/800 ls −0,4 e "Ver os 4" (44 de altura, 14/700, seta 18); a grade de 3 (gap 14), cada livro com a capa de 132 (raio 3/8/8/3, borda 1,5, a lombada de 6) e o marcador de fita 14 × 26 por cima, e o rótulo 12,5/800, 8 abaixo.
2. Cartão do ano 32 abaixo: padding 18, raio 28, `#FED170`, borda 1,5, sombra 4/4, gap 16; "2026 em" Bricolage 22/800 + "leitura" Instrument Serif 27; o "24" Bricolage 58/800 `lh 0,85` ls −2 com "de 30 livros / na meta do ano" 14/700 `#3D3524`; a pílula "2 à frente" (30, `#FFFAF1`, 12/800) presa embaixo à direita.
3. Estante: a fileira de 48 (flex pela base, gap 2, padding 0/4) com as 24 lombadas (`flex 1 1 0`, alturas da prancha de 38 a 47, raio 2/2/1/1, borda 1,2, a faixa de 2 a 60% no topo) e as 6 vagas de 44 tracejadas (1,2 `#8A7F63`), todas de 8,1667 de largura; a tábua de 9 (`#FFFAF1`, borda 1,5, sombra 0/2), subindo 1,2.
4. Números em grade de 2 (gap 8): padding 12/12/11, raio 18, `#FFFAF1`, borda 1,5, sem sombra; o valor Bricolage 25/800 ls −0,6 (o gênero, Instrument Serif itálico 27) e o rótulo 12,5/600 `#5B544B`.
5. "Ver estatísticas completas" (44, margem −6/0/−8, 14/800, seta 18) fecha o cartão.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A estante tem 24 lombadas e 6 vagas de 8,1667 (`flex 1 1 0`, gap 2): no app, `Expanded` na mesma ordem — a largura é a mesma para lombada e vaga, e a borda de 1,2 fica dentro (`box-sizing: border-box`).
- A tábua sobe 1,2 sobre a fileira (`margin-top −1,2`): as lombadas encostam na tábua por cima.
- As capas desta seção são CSS (formas absolutas em px e o título com `<br>`), como as da Biblioteca: as formas presas por `left`/`right` esticam com a coluna; o título com quebra imposta ("Mrs.`<br>`Dalloway") não é fio de navalha (D-280).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_005_perfil_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_005_perfil_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `p05.reading` |  | Lendo agora |  |
| `p05.reading.header.all.icon` |  |  | aria-hidden=true |
| `p05.reading.grid.book1` |  | Dom Casmurro, 62% lido |  |
| `p05.reading.grid.book1.cover.bookmark` |  |  | aria-hidden=true |
| `p05.reading.grid.book2` |  | Mrs. Dalloway, 34% lido |  |
| `p05.reading.grid.book2.cover.bookmark` |  |  | aria-hidden=true |
| `p05.reading.grid.book3` |  | Orgulho e Preconceito, 81% lido |  |
| `p05.reading.grid.book3.cover.bookmark` |  |  | aria-hidden=true |
| `p05.year` |  | 2026 em leitura |  |
| `p05.year.goal.ahead.icon` |  |  | aria-hidden=true |
| `p05.year.shelf` |  | 24 livros lidos de 30 na meta |  |
| `p05.year.shelf.books` |  |  | aria-hidden=true |
| `p05.year.shelf.plank` |  |  | aria-hidden=true |
| `p05.year.more.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `p05.reading.header.all.icon` | AppSvg(AppIcons.arrowRight, size: 18) |  |
| `p05.reading.grid.book1.cover.art` | NeoBox |  |
| `p05.reading.grid.book1.cover.spine` | NeoBox |  |
| `p05.reading.grid.book1.cover.circle` | CircleIconButton / NeoBox circular |  |
| `p05.reading.grid.book1.cover.bookmark` | AppSvg(AppIllustrationsPerfil.fitaMarcadorCapa, size: 14×26) |  |
| `p05.reading.grid.book2.cover.art` | NeoBox |  |
| `p05.reading.grid.book2.cover.spine` | NeoBox |  |
| `p05.reading.grid.book2.cover.arch` | NeoBox |  |
| `p05.reading.grid.book2.cover.bookmark` | AppSvg(AppIllustrationsPerfil.fitaMarcadorCapa, size: 14×26) |  |
| `p05.reading.grid.book3.cover.art` | NeoBox |  |
| `p05.reading.grid.book3.cover.spine` | NeoBox |  |
| `p05.reading.grid.book3.cover.ring` | CircleIconButton / NeoBox circular |  |
| `p05.reading.grid.book3.cover.dot` | CircleIconButton / NeoBox circular |  |
| `p05.reading.grid.book3.cover.bookmark` | AppSvg(AppIllustrationsPerfil.fitaMarcadorCapa, size: 14×26) |  |
| `p05.year` | NeoBox |  |
| `p05.year.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `p05.year.goal.ahead` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p05.year.goal.ahead.icon` | AppSvg(AppIconsPerfil.arrowUpRight, size: 13) |  |
| `p05.year.shelf.books.book1` | NeoBox |  |
| `p05.year.shelf.books.book1.line` | NeoBox |  |
| `p05.year.shelf.books.book2` | NeoBox |  |
| `p05.year.shelf.books.book2.line` | NeoBox |  |
| `p05.year.shelf.books.book3` | NeoBox |  |
| `p05.year.shelf.books.book3.line` | NeoBox |  |
| `p05.year.shelf.books.book4` | NeoBox |  |
| `p05.year.shelf.books.book4.line` | NeoBox |  |
| `p05.year.shelf.books.book5` | NeoBox |  |
| `p05.year.shelf.books.book5.line` | NeoBox |  |
| `p05.year.shelf.books.book6` | NeoBox |  |
| `p05.year.shelf.books.book6.line` | NeoBox |  |
| `p05.year.shelf.books.book7` | NeoBox |  |
| `p05.year.shelf.books.book7.line` | NeoBox |  |
| `p05.year.shelf.books.book8` | NeoBox |  |
| `p05.year.shelf.books.book8.line` | NeoBox |  |
| `p05.year.shelf.books.book9` | NeoBox |  |
| `p05.year.shelf.books.book9.line` | NeoBox |  |
| `p05.year.shelf.books.book10` | NeoBox |  |
| `p05.year.shelf.books.book10.line` | NeoBox |  |
| `p05.year.shelf.books.book11` | NeoBox |  |
| `p05.year.shelf.books.book11.line` | NeoBox |  |
| `p05.year.shelf.books.book12` | NeoBox |  |
| `p05.year.shelf.books.book12.line` | NeoBox |  |
| `p05.year.shelf.books.book13` | NeoBox |  |
| `p05.year.shelf.books.book13.line` | NeoBox |  |
| `p05.year.shelf.books.book14` | NeoBox |  |
| `p05.year.shelf.books.book14.line` | NeoBox |  |
| `p05.year.shelf.books.book15` | NeoBox |  |
| `p05.year.shelf.books.book15.line` | NeoBox |  |
| `p05.year.shelf.books.book16` | NeoBox |  |
| `p05.year.shelf.books.book16.line` | NeoBox |  |
| `p05.year.shelf.books.book17` | NeoBox |  |
| `p05.year.shelf.books.book17.line` | NeoBox |  |
| `p05.year.shelf.books.book18` | NeoBox |  |
| `p05.year.shelf.books.book18.line` | NeoBox |  |
| `p05.year.shelf.books.book19` | NeoBox |  |
| `p05.year.shelf.books.book19.line` | NeoBox |  |
| `p05.year.shelf.books.book20` | NeoBox |  |
| `p05.year.shelf.books.book20.line` | NeoBox |  |
| `p05.year.shelf.books.book21` | NeoBox |  |
| `p05.year.shelf.books.book21.line` | NeoBox |  |
| `p05.year.shelf.books.book22` | NeoBox |  |
| `p05.year.shelf.books.book22.line` | NeoBox |  |
| `p05.year.shelf.books.book23` | NeoBox |  |
| `p05.year.shelf.books.book23.line` | NeoBox |  |
| `p05.year.shelf.books.book24` | NeoBox |  |
| `p05.year.shelf.books.book24.line` | NeoBox |  |
| `p05.year.shelf.books.slot1` | NeoBox |  |
| `p05.year.shelf.books.slot2` | NeoBox |  |
| `p05.year.shelf.books.slot3` | NeoBox |  |
| `p05.year.shelf.books.slot4` | NeoBox |  |
| `p05.year.shelf.books.slot5` | NeoBox |  |
| `p05.year.shelf.books.slot6` | NeoBox |  |
| `p05.year.shelf.plank` | NeoBox |  |
| `p05.year.stats.pages` | NeoBox |  |
| `p05.year.stats.hours` | NeoBox |  |
| `p05.year.stats.streak` | NeoBox |  |
| `p05.year.stats.genre` | NeoBox |  |
| `p05.year.more.icon` | AppSvg(AppIconsPerfil.arrowForwardTinta, size: 18) |  |

## Interações

- Capa → os Detalhes do livro (17/17b, da T14); se o e-book abre direto o leitor, é pergunta da T17.
- "Ver os 4" → a Biblioteca (02) com o filtro Lendo, se a T17 decidir; senão, sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b).
- "Ver estatísticas completas" → as Estatísticas (29), da T21: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).

## Dados

- Lendo agora = os livros com o status Lendo (`ShelfStatus.reading`), os 3 mais recentes, e o total no "Ver os N"; o rótulo é a porcentagem e, no 1º, a página ("62% · pág. 159"); nos outros, só a porcentagem — a regra (o 1º, o mais recente, ou quando cabe) é pergunta da T17.
- O ano: os livros terminados no ano (`ProfileNumbers.booksReadYear`) contra a meta do ano (o mesmo campo da 12, da T16, em `ReadingGoals`); "N à frente" = lidos − meta × a fração do ano que passou, arredondado. O texto quando está atrás do ritmo não tem prancha — pergunta da T17.
- Uma lombada por livro lido no ano (a cor da capa do livro) e uma vaga por livro que falta; as alturas da prancha são as da fixture — no app, a altura de cada lombada sai do livro (o número de páginas, numa faixa de 38 a 47) ou de uma sequência fixa: pergunta da T17. Com mais lidos que a meta, as vagas somem e as lombadas estreitam (a fileira é `flex 1 1 0`).
- Páginas lidas, horas e maior sequência vêm das sessões (papel e e-book) e da sequência; o gênero do ano, do gênero dos livros terminados — enquanto o livro não tiver gênero no banco, o item segue a D-247.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L05.1** Lendo agora: as 3 capas, o marcador e o rótulo
- **L05.2** Cartão do ano: o número e a pílula
- **L05.3** Estante do ano (lombadas e vagas)
- **L05.4** Os quatro números e o link
- **L05.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('p05.reading', 'p05.year'), todos os ids de `kRef05.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/005_perfil_390x2510@3x.png` no recorte da fase (y 743.57–1446.59) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef05w360` e `kRef05w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L05.1 Lendo agora: as 3 capas, o marcador e o rótulo
- [ ] L05.2 Cartão do ano: o número e a pílula
- [ ] L05.3 Estante do ano (lombadas e vagas)
- [ ] L05.4 Os quatro números e o link
- [ ] L05.5 Verificação + relatório
- [ ] Geometria 111/111 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
