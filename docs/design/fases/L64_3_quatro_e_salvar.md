# FASE L64 — Editar perfil — os 4 que me definem (o número, trocar e a alça de arrastar) e o Salvar preso embaixo

> Tela 64 · prancha `064_editar_perfil` (64 · Editar perfil, canvas 390×1400) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L64_3_quatro_e_salvar@3x.png` · `docs/design/medicao/projeto/png/redline/L64_3_quatro_e_salvar_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/064_editar_perfil_390x1400@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_064_editar_perfil.json` · `test/reference/projeto/reference_layout_064_editar_perfil.dart` (`kRef64`).
> Arquivos sugeridos: `lib/features/profile/presentation/edit/favorites_editor.dart`, `lib/features/profile/presentation/edit/edit_profile_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Editar perfil (64), embaixo: os 4 que me definem com o número, o lápis de trocar e a alça de arrastar ("segure para reordenar"), e o "Salvar alterações" preso no fundo com o aviso de que quem segue vê a capa nova na hora.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`.

```html
<!-- Four that define me -->
<div style="margin-top: 22px; display: flex; justify-content: space-between; align-items: baseline;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.4px;">Quatro que me <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 22px;">definem</span></span><span style="font-size: 11.5px; font-weight: 700; color: #8A8073;">segure para reordenar</span></div>

<div style="position: relative; margin-top: 14px;">
  <div style="display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); justify-items: center; gap: 8px;"><div style="display: flex; flex-direction: column; align-items: center; gap: 6px;"><span style="position: relative; display: block;"><span aria-hidden="true" style="position: relative; display: block; width: 66px; height: 99px; flex-shrink: 0; border-radius: 3px 6px 6px 3px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><span style="position: absolute; left: 9px; right: 9px; top: 11px; display: flex; flex-direction: column; gap: 3px;"><span style="height: 3px; border-radius: 4px; background: #F7F0E3;"></span><span style="height: 3px; width: 70%; border-radius: 4px; background: #F7F0E3;"></span><span style="height: 3px; width: 40%; border-radius: 4px; background: #F7F0E3;"></span></span><span style="position: absolute; left: 9px; right: 3px; bottom: 7px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 13.4px; line-height: 0.92; color: #FFFAF1;">Quincas<br>Borba</span></span><span aria-hidden="true" style="position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">1</span><button aria-label="Trocar Quincas Borba" style="position: absolute; right: -8px; bottom: -8px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16v4z"></path><path d="m13.5 6.5 4 4"></path></svg></button></span><span aria-hidden="true" style="height: 18px; display: flex; align-items: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8A8073" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="6" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="6" r="1.4" fill="#1A1714"></circle><circle cx="9" cy="12" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="12" r="1.4" fill="#1A1714"></circle><circle cx="9" cy="18" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="18" r="1.4" fill="#1A1714"></circle></svg></span></div><div style="display: flex; flex-direction: column; align-items: center; gap: 6px;"><span style="position: relative; display: block;"><span aria-hidden="true" style="position: relative; display: block; width: 66px; height: 99px; flex-shrink: 0; border-radius: 3px 6px 6px 3px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><span style="position: absolute; left: 12px; top: 11px; width: 36px; height: 42px; border-radius: 18px 18px 0 0; background: #FED170;"></span><span style="position: absolute; left: 22px; top: 28px; width: 15px; height: 25px; border-radius: 7px 7px 0 0; background: #00995E;"></span><span style="position: absolute; left: 9px; right: 3px; bottom: 7px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 13.4px; line-height: 0.92; color: #FFFAF1;">O Cortiço</span></span><span aria-hidden="true" style="position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">2</span><button aria-label="Trocar O Cortiço" style="position: absolute; right: -8px; bottom: -8px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16v4z"></path><path d="m13.5 6.5 4 4"></path></svg></button></span><span aria-hidden="true" style="height: 18px; display: flex; align-items: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8A8073" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="6" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="6" r="1.4" fill="#1A1714"></circle><circle cx="9" cy="12" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="12" r="1.4" fill="#1A1714"></circle><circle cx="9" cy="18" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="18" r="1.4" fill="#1A1714"></circle></svg></span></div><div style="display: flex; flex-direction: column; align-items: center; gap: 6px;"><span style="position: relative; display: block;"><span aria-hidden="true" style="position: relative; display: block; width: 66px; height: 99px; flex-shrink: 0; border-radius: 3px 6px 6px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><span style="position: absolute; left: 11px; right: -6px; top: 15px; height: 26px; border-radius: 13px 0 0 13px; background: #1A1714;"></span><span style="position: absolute; left: 9px; right: 3px; bottom: 7px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 13.4px; line-height: 0.92; color: #1A1714;">Iracema</span></span><span aria-hidden="true" style="position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">3</span><button aria-label="Trocar Iracema" style="position: absolute; right: -8px; bottom: -8px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16v4z"></path><path d="m13.5 6.5 4 4"></path></svg></button></span><span aria-hidden="true" style="height: 18px; display: flex; align-items: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8A8073" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="6" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="6" r="1.4" fill="#1A1714"></circle><circle cx="9" cy="12" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="12" r="1.4" fill="#1A1714"></circle><circle cx="9" cy="18" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="18" r="1.4" fill="#1A1714"></circle></svg></span></div><div style="display: flex; flex-direction: column; align-items: center; gap: 6px;"><span style="position: relative; display: block;"><span aria-hidden="true" style="position: relative; display: block; width: 66px; height: 99px; flex-shrink: 0; border-radius: 3px 6px 6px 3px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><span style="position: absolute; left: 18px; top: 14px; width: 26px; height: 37px; border-radius: 50%; background: #1A1714;"></span><span style="position: absolute; left: 31px; top: 14px; width: 1.5px; height: 37px; background: #B6ACE4;"></span><span style="position: absolute; left: 9px; right: 3px; bottom: 7px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 11.8px; line-height: 0.92; color: #1A1714;">A Meta-<br>morfose</span></span><span aria-hidden="true" style="position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">4</span><button aria-label="Trocar A Metamorfose" style="position: absolute; right: -8px; bottom: -8px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16v4z"></path><path d="m13.5 6.5 4 4"></path></svg></button></span><span aria-hidden="true" style="height: 18px; display: flex; align-items: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8A8073" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="6" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="6" r="1.4" fill="#1A1714"></circle><circle cx="9" cy="12" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="12" r="1.4" fill="#1A1714"></circle><circle cx="9" cy="18" r="1.4" fill="#1A1714"></circle><circle cx="15" cy="18" r="1.4" fill="#1A1714"></circle></svg></span></div></div>
</div>

<div style="position: absolute; left: 0; right: 0; bottom: 0; z-index: 5; padding: 26px 20px 28px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 30%);">
  <button style="width: 100%; height: 56px; border-radius: 999px; background: #1A1714; border: none; box-shadow: 0 4px 0 rgba(26,23,20,0.25); display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800;"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#ABCF82" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg><span style="color: #F7F0E3;">Salvar alterações</span></button><p style="margin: 10px 0 0; text-align: center; font-size: 12.5px; font-weight: 600; color: #6F665B;">Quem segue você vê a capa nova na hora.</p>
</div>
```

## Especificação pixel a pixel

Seção `p64.favoritesHeader` — retângulo absoluto no canvas 390×1400: **x=20, y=1102.87, w=350, h=28.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `p64.favoritesHeader` | box | 0 | 0 | 350 | 28.6 | `margin-top: 22px; display: flex; justify-content: space-between; align-items: baseline` |  |
| 2 | `p64.favoritesHeader.title` ±1 | text | 0 | 0 | 191.64 | 28.6 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.4px` | Bricolage (opsz 18) 18/normal peso 800 ls -0.4px #1A1714 |
| 3 | `p64.favoritesHeader.title.serif` ±1 | inline | 128.9 | 0 | 62.74 | 28.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 22px` | Instrument Serif itálico 22/normal peso 400 ls -0.4px #1A1714 |
| 4 | `p64.favoritesHeader.hint` ±1 | text | 233.09 | 10.85 | 116.91 | 13.81 | `font-size: 11.5px; font-weight: 700; color: #8A8073` | Figtree 11.5/normal peso 700 ls normal #8A8073 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.favoritesHeader.title` *(composto)* | 1 | Quatro que me definem | 21.78 | 0 | 191.64 | 191.64 |
| `p64.favoritesHeader.hint` | 1 | segure para reordenar | 21.78 | 233.09 | 350 | 116.91 |

Seção `p64.favorites` — retângulo absoluto no canvas 390×1400: **x=20, y=1145.47, w=350, h=123**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `p64.favorites` | box | 0 | 0 | 350 | 123 | `position: relative; margin-top: 14px` |  |
| 6 | `p64.favorites.grid` | box | 0 | 0 | 350 | 123 | `display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); justify-items: center; gap: 8px` |  |
| 7 | `p64.favorites.grid.slot1` | box | 7.75 | 0 | 66 | 123 | `display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 8 | `p64.favorites.grid.slot1.book` | box | 7.75 | 0 | 66 | 99 | `position: relative; display: block` |  |
| 9 | `p64.favorites.grid.slot1.book.cover` | box | 7.75 | 0 | 66 | 99 | `position: relative; display: block; width: 66px; height: 99px; flex-shrink: 0; border-radius: 3px 6px 6px 3px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box` |  |
| 10 | `p64.favorites.grid.slot1.book.cover.spine` | box | 9.25 | 1.5 | 4 | 96 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 11 | `p64.favorites.grid.slot1.book.cover.lines` | box | 18.25 | 12.5 | 45 | 15 | `position: absolute; left: 9px; right: 9px; top: 11px; display: flex; flex-direction: column; gap: 3px` |  |
| 12 | `p64.favorites.grid.slot1.book.cover.lines.line1` | box | 18.25 | 12.5 | 45 | 3 | `height: 3px; border-radius: 4px; background: #F7F0E3` |  |
| 13 | `p64.favorites.grid.slot1.book.cover.lines.line2` | box | 18.25 | 18.5 | 31.5 | 3 | `height: 3px; width: 70%; border-radius: 4px; background: #F7F0E3` |  |
| 14 | `p64.favorites.grid.slot1.book.cover.lines.line3` | box | 18.25 | 24.5 | 18 | 3 | `height: 3px; width: 40%; border-radius: 4px; background: #F7F0E3` |  |
| 15 | `p64.favorites.grid.slot1.book.cover.title` | text | 18.25 | 65.84 | 51 | 24.66 | `position: absolute; left: 9px; right: 3px; bottom: 7px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 13.4px; line-height: 0.92; color: #FFFAF1` | Instrument Serif 13.4/12.328px peso 400 ls normal #FFFAF1 |
| 16 | `p64.favorites.grid.slot1.book.rank` | box+text | 0.75 | -7 | 22 | 22 | `position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800 ls normal #FFFAF1 |
| 17 | `p64.favorites.grid.slot1.book.swap` | box | 51.75 | 77 | 30 | 30 | `position: absolute; right: -8px; bottom: -8px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 18 | `p64.favorites.grid.slot1.book.swap.icon` | icon | 59.75 | 85 | 14 | 14 | `—` |  |
| 19 | `p64.favorites.grid.slot1.handle` | box | 32.75 | 105 | 16 | 18 | `height: 18px; display: flex; align-items: center` |  |
| 20 | `p64.favorites.grid.slot1.handle.icon` | icon | 32.75 | 106 | 16 | 16 | `—` |  |
| 21 | `p64.favorites.grid.slot2` | box | 97.25 | 0 | 66 | 123 | `display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 22 | `p64.favorites.grid.slot2.book` | box | 97.25 | 0 | 66 | 99 | `position: relative; display: block` |  |
| 23 | `p64.favorites.grid.slot2.book.cover` | box | 97.25 | 0 | 66 | 99 | `position: relative; display: block; width: 66px; height: 99px; flex-shrink: 0; border-radius: 3px 6px 6px 3px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box` |  |
| 24 | `p64.favorites.grid.slot2.book.cover.spine` | box | 98.75 | 1.5 | 4 | 96 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 25 | `p64.favorites.grid.slot2.book.cover.arch` | box | 110.75 | 12.5 | 36 | 42 | `position: absolute; left: 12px; top: 11px; width: 36px; height: 42px; border-radius: 18px 18px 0 0; background: #FED170` |  |
| 26 | `p64.favorites.grid.slot2.book.cover.door` | box | 120.75 | 29.5 | 15 | 25 | `position: absolute; left: 22px; top: 28px; width: 15px; height: 25px; border-radius: 7px 7px 0 0; background: #00995E` |  |
| 27 | `p64.favorites.grid.slot2.book.cover.title` | text | 107.75 | 78.17 | 51 | 12.33 | `position: absolute; left: 9px; right: 3px; bottom: 7px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 13.4px; line-height: 0.92; color: #FFFAF1` | Instrument Serif 13.4/12.328px peso 400 ls normal #FFFAF1 |
| 28 | `p64.favorites.grid.slot2.book.rank` | box+text | 90.25 | -7 | 22 | 22 | `position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800 ls normal #FFFAF1 |
| 29 | `p64.favorites.grid.slot2.book.swap` | box | 141.25 | 77 | 30 | 30 | `position: absolute; right: -8px; bottom: -8px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 30 | `p64.favorites.grid.slot2.book.swap.icon` | icon | 149.25 | 85 | 14 | 14 | `—` |  |
| 31 | `p64.favorites.grid.slot2.handle` | box | 122.25 | 105 | 16 | 18 | `height: 18px; display: flex; align-items: center` |  |
| 32 | `p64.favorites.grid.slot2.handle.icon` | icon | 122.25 | 106 | 16 | 16 | `—` |  |
| 33 | `p64.favorites.grid.slot3` | box | 186.75 | 0 | 66 | 123 | `display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 34 | `p64.favorites.grid.slot3.book` | box | 186.75 | 0 | 66 | 99 | `position: relative; display: block` |  |
| 35 | `p64.favorites.grid.slot3.book.cover` | box | 186.75 | 0 | 66 | 99 | `position: relative; display: block; width: 66px; height: 99px; flex-shrink: 0; border-radius: 3px 6px 6px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box` |  |
| 36 | `p64.favorites.grid.slot3.book.cover.spine` | box | 188.25 | 1.5 | 4 | 96 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 37 | `p64.favorites.grid.slot3.book.cover.band` | box | 199.25 | 16.5 | 58 | 26 | `position: absolute; left: 11px; right: -6px; top: 15px; height: 26px; border-radius: 13px 0 0 13px; background: #1A1714` |  |
| 38 | `p64.favorites.grid.slot3.book.cover.title` | text | 197.25 | 78.17 | 51 | 12.33 | `position: absolute; left: 9px; right: 3px; bottom: 7px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 13.4px; line-height: 0.92; color: #1A1714` | Instrument Serif 13.4/12.328px peso 400 ls normal #1A1714 |
| 39 | `p64.favorites.grid.slot3.book.rank` | box+text | 179.75 | -7 | 22 | 22 | `position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800 ls normal #FFFAF1 |
| 40 | `p64.favorites.grid.slot3.book.swap` | box | 230.75 | 77 | 30 | 30 | `position: absolute; right: -8px; bottom: -8px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 41 | `p64.favorites.grid.slot3.book.swap.icon` | icon | 238.75 | 85 | 14 | 14 | `—` |  |
| 42 | `p64.favorites.grid.slot3.handle` | box | 211.75 | 105 | 16 | 18 | `height: 18px; display: flex; align-items: center` |  |
| 43 | `p64.favorites.grid.slot3.handle.icon` | icon | 211.75 | 106 | 16 | 16 | `—` |  |
| 44 | `p64.favorites.grid.slot4` | box | 276.25 | 0 | 66 | 123 | `display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 45 | `p64.favorites.grid.slot4.book` | box | 276.25 | 0 | 66 | 99 | `position: relative; display: block` |  |
| 46 | `p64.favorites.grid.slot4.book.cover` | box | 276.25 | 0 | 66 | 99 | `position: relative; display: block; width: 66px; height: 99px; flex-shrink: 0; border-radius: 3px 6px 6px 3px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box` |  |
| 47 | `p64.favorites.grid.slot4.book.cover.spine` | box | 277.75 | 1.5 | 4 | 96 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 48 | `p64.favorites.grid.slot4.book.cover.oval` | box | 295.75 | 15.5 | 26 | 37 | `position: absolute; left: 18px; top: 14px; width: 26px; height: 37px; border-radius: 50%; background: #1A1714` |  |
| 49 | `p64.favorites.grid.slot4.book.cover.seam` | box | 308.75 | 15.5 | 1.5 | 37 | `position: absolute; left: 31px; top: 14px; width: 1.5px; height: 37px; background: #B6ACE4` |  |
| 50 | `p64.favorites.grid.slot4.book.cover.title` | text | 286.75 | 68.79 | 51 | 21.71 | `position: absolute; left: 9px; right: 3px; bottom: 7px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 11.8px; line-height: 0.92; color: #1A1714` | Instrument Serif 11.8/10.856px peso 400 ls normal #1A1714 |
| 51 | `p64.favorites.grid.slot4.book.rank` | box+text | 269.25 | -7 | 22 | 22 | `position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800 ls normal #FFFAF1 |
| 52 | `p64.favorites.grid.slot4.book.swap` | box | 320.25 | 77 | 30 | 30 | `position: absolute; right: -8px; bottom: -8px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 53 | `p64.favorites.grid.slot4.book.swap.icon` | icon | 328.25 | 85 | 14 | 14 | `—` |  |
| 54 | `p64.favorites.grid.slot4.handle` | box | 301.25 | 105 | 16 | 18 | `height: 18px; display: flex; align-items: center` |  |
| 55 | `p64.favorites.grid.slot4.handle.icon` | icon | 301.25 | 106 | 16 | 16 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.favorites.grid.slot1.book.cover.title` | 1 | Quincas | 76.56 | 18.25 | 54.77 | 36.52 |
| `p64.favorites.grid.slot1.book.cover.title` | 2 | Borba | 88.89 | 18.25 | 45.77 | 27.52 |
| `p64.favorites.grid.slot1.book.rank` | 1 | 1 | 7.85 | 9.41 | 14.09 | 4.68 |
| `p64.favorites.grid.slot2.book.cover.title` | 1 | O Cortiço | 88.89 | 107.75 | 149.89 | 42.14 |
| `p64.favorites.grid.slot2.book.rank` | 1 | 2 | 7.85 | 98.02 | 104.48 | 6.46 |
| `p64.favorites.grid.slot3.book.cover.title` | 1 | Iracema | 88.89 | 197.25 | 234.03 | 36.78 |
| `p64.favorites.grid.slot3.book.rank` | 1 | 3 | 7.85 | 187.66 | 193.84 | 6.18 |
| `p64.favorites.grid.slot4.book.cover.title` | 1 | A Meta- | 78.22 | 286.75 | 318.76 | 32.01 |
| `p64.favorites.grid.slot4.book.cover.title` | 2 | morfose | 89.07 | 286.75 | 319.31 | 32.56 |
| `p64.favorites.grid.slot4.book.rank` | 1 | 4 | 7.85 | 276.74 | 283.76 | 7.02 |

Seção `p64.bottom` — retângulo absoluto no canvas 390×1400: **x=0, y=1264.99, w=390, h=135.01**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 56 | `p64.bottom` | box | 0 | 0 | 390 | 135.01 | `position: absolute; left: 0; right: 0; bottom: 0; z-index: 5; padding: 26px 20px 28px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 30%)` |  |
| 57 | `p64.bottom.save` | box | 20 | 26 | 350 | 56 | `width: 100%; height: 56px; border-radius: 999px; background: #1A1714; border: none; box-shadow: 0 4px 0 rgba(26,23,20,0.25); display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800` |  |
| 58 | `p64.bottom.save.icon` ±1 | icon | 116.54 | 44.5 | 19 | 19 | `—` |  |
| 59 | `p64.bottom.save.label` ±1 | text | 145.54 | 44.4 | 127.92 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 60 | `p64.bottom.note` | text | 20 | 92 | 350 | 15.01 | `margin: 10px 0 0; text-align: center; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.bottom.save.label` | 1 | Salvar alterações | 59.6 | 145.54 | 273.46 | 127.92 |
| `p64.bottom.note` | 1 | Quem segue você vê a capa nova na hora. | 103.88 | 76.56 | 313.44 | 236.88 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Quatro que me" Bricolage 18/800 + "definem" Instrument Serif 22, com "segure para reordenar" 11,5/700 `#8A8073`, 22 abaixo; a grade de 4 (`justify-items: center`, gap 8), 14 abaixo.
2. Cada livro: a capa 66 × 99 (raio 3/6/6/3, borda 1,5, a lombada de 4, o título Instrument Serif 11,8–13,4 `lh 0,92`), o número num círculo preto de 22 em `left/top −7` (11/800 `#FFFAF1`), o lápis num círculo 30 `#FFFAF1` (borda 1,5) em `right/bottom −8` e, 6 abaixo, a alça de 18 (os 6 pontos 1,4).
3. Fundo preso (`left/right/bottom 0`, `z-index 5`, padding 26/20/28, o degradê do creme a 30%): "Salvar alterações" 56, preto, sem borda, sombra 0/4 preta a 0,25, o visto `#ABCF82` 19 e o texto 16/800 `#F7F0E3`; o aviso 12,5/600 `#6F665B` centrado, 10 abaixo.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O número e o lápis saem da capa (−7 e −8): `Clip.none` no livro, e o toque do lápis vale também fora da capa.
- O "Salvar" fica por cima do conteúdo: o fim da rolagem precisa do espaço dele (o degradê de 26 + 56 + o aviso + 28), senão os 4 ficam por baixo.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_064_editar_perfil_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_064_editar_perfil_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `p64.favorites.grid.slot1.book.cover` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot1.book.rank` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot1.book.swap` |  | Trocar Quincas Borba |  |
| `p64.favorites.grid.slot1.book.swap.icon` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot1.handle` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot1.handle.icon` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot2.book.cover` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot2.book.rank` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot2.book.swap` |  | Trocar O Cortiço |  |
| `p64.favorites.grid.slot2.book.swap.icon` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot2.handle` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot2.handle.icon` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot3.book.cover` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot3.book.rank` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot3.book.swap` |  | Trocar Iracema |  |
| `p64.favorites.grid.slot3.book.swap.icon` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot3.handle` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot3.handle.icon` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot4.book.cover` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot4.book.rank` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot4.book.swap` |  | Trocar A Metamorfose |  |
| `p64.favorites.grid.slot4.book.swap.icon` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot4.handle` |  |  | aria-hidden=true |
| `p64.favorites.grid.slot4.handle.icon` |  |  | aria-hidden=true |
| `p64.bottom.save.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `p64.favoritesHeader.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `p64.favorites.grid.slot1.book.cover` | NeoBox |  |
| `p64.favorites.grid.slot1.book.cover.spine` | NeoBox |  |
| `p64.favorites.grid.slot1.book.cover.lines.line1` | NeoBox |  |
| `p64.favorites.grid.slot1.book.cover.lines.line2` | NeoBox |  |
| `p64.favorites.grid.slot1.book.cover.lines.line3` | NeoBox |  |
| `p64.favorites.grid.slot1.book.rank` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot1.book.swap` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot1.book.swap.icon` | AppSvg(AppIconsPerfil.pencilSmall, size: 14) |  |
| `p64.favorites.grid.slot1.handle.icon` | AppSvg(AppIconsPerfil.dragHandle, size: 16) |  |
| `p64.favorites.grid.slot2.book.cover` | NeoBox |  |
| `p64.favorites.grid.slot2.book.cover.spine` | NeoBox |  |
| `p64.favorites.grid.slot2.book.cover.arch` | NeoBox |  |
| `p64.favorites.grid.slot2.book.cover.door` | NeoBox |  |
| `p64.favorites.grid.slot2.book.rank` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot2.book.swap` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot2.book.swap.icon` | AppSvg(AppIconsPerfil.pencilSmall, size: 14) |  |
| `p64.favorites.grid.slot2.handle.icon` | AppSvg(AppIconsPerfil.dragHandle, size: 16) |  |
| `p64.favorites.grid.slot3.book.cover` | NeoBox |  |
| `p64.favorites.grid.slot3.book.cover.spine` | NeoBox |  |
| `p64.favorites.grid.slot3.book.cover.band` | NeoBox |  |
| `p64.favorites.grid.slot3.book.rank` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot3.book.swap` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot3.book.swap.icon` | AppSvg(AppIconsPerfil.pencilSmall, size: 14) |  |
| `p64.favorites.grid.slot3.handle.icon` | AppSvg(AppIconsPerfil.dragHandle, size: 16) |  |
| `p64.favorites.grid.slot4.book.cover` | NeoBox |  |
| `p64.favorites.grid.slot4.book.cover.spine` | NeoBox |  |
| `p64.favorites.grid.slot4.book.cover.oval` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot4.book.cover.seam` | NeoBox |  |
| `p64.favorites.grid.slot4.book.rank` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot4.book.swap` | CircleIconButton / NeoBox circular |  |
| `p64.favorites.grid.slot4.book.swap.icon` | AppSvg(AppIconsPerfil.pencilSmall, size: 14) |  |
| `p64.favorites.grid.slot4.handle.icon` | AppSvg(AppIconsPerfil.dragHandle, size: 16) |  |
| `p64.bottom` | DecoratedBox(LinearGradient) |  |
| `p64.bottom.save` | NeoBox |  |
| `p64.bottom.save.icon` | AppSvg(AppIconsPerfil.checkVerde, size: 19) |  |

## Interações

- Lápis → a folha "Trocar um dos 4" (65) daquele número.
- Segurar e arrastar → reordena (o número acompanha a posição); no leitor de tela, as ações "mover para a esquerda/direita" (a nota do design).
- Salvar alterações → grava o rascunho e volta ao Perfil; sem mudanças, o botão fica como está (o estado apagado não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b)).

## Dados

- Os 4 livros do perfil, na ordem (o mesmo campo da 05); só livros que a pessoa terminou.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L64.1** Os 4 com número, lápis e alça
- **L64.2** Reordenar (arrastar e as ações de acessibilidade)
- **L64.3** Salvar preso no fundo
- **L64.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('p64.favoritesHeader', 'p64.favorites', 'p64.bottom'), todos os ids de `kRef64.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/064_editar_perfil_390x1400@3x.png` no recorte da fase (y 1094.87–1400) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef64w360` e `kRef64w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L64.1 Os 4 com número, lápis e alça
- [ ] L64.2 Reordenar (arrastar e as ações de acessibilidade)
- [ ] L64.3 Salvar preso no fundo
- [ ] L64.4 Verificação + relatório
- [ ] Geometria 59/59 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
