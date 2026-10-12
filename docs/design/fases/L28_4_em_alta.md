# FASE L28 — Busca (Explorar) — Em alta nos clubes (carrossel de 4 livros)

> Tela 28 · prancha `028_busca_explorar` (28 · Busca — Explorar (antes de digitar), canvas 390×1520) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28_4_em_alta@3x.png` · `docs/design/medicao/projeto/png/redline/L28_4_em_alta_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028_busca_explorar_390x1520@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028_busca_explorar.json` · `test/reference/projeto/reference_layout_028_busca_explorar.dart` (`kRef28`).
> Arquivos sugeridos: `lib/features/search/presentation/sections/trending_carousel.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Busca (Explorar): "Em alta nos clubes" — livros que mais clubes começaram esta semana — num carrossel de capas de 124 × 176 com o título, o autor e a pílula rosa "38 clubes".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px;">Em alta nos clubes</h2></div>

<p style="margin: 4px 0 0; font-size: 13.5px; font-weight: 600; color: #5B544B;">Livros que mais clubes começaram esta semana</p>

<div style="margin: 14px -16px 0; padding: 0 16px 6px; display: flex; gap: 14px; overflow: hidden;"><a href="#" style="width: 128px; flex-shrink: 0; display: block;"><span aria-hidden="true" style="position: relative; display: block; width: 124px; height: 176px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg);"><span style="position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35);"></span><span style="position: absolute; left: 16px; top: 14px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 37px; top: 14px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FED170; box-sizing: border-box;"></span><span style="position: absolute; left: 58px; top: 14px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 79px; top: 14px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 16px; top: 34px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 37px; top: 34px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 58px; top: 34px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FED170; box-sizing: border-box;"></span><span style="position: absolute; left: 79px; top: 34px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 16px; top: 54px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FED170; box-sizing: border-box;"></span><span style="position: absolute; left: 37px; top: 54px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 58px; top: 54px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 79px; top: 54px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box;"></span><span style="position: absolute; left: 14px; right: 8px; bottom: 10px; color: #1A1714;"><span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.95; letter-spacing: -0.4px;">O Cortiço</span><span style="display: block; margin-top: 4px; font-size: 10px; font-weight: 700; opacity: 0.8;">Aluísio Azevedo</span></span></span><span style="display: block; margin-top: 10px; font-size: 14px; font-weight: 800; line-height: 1.2;">O Cortiço</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">Aluísio Azevedo</span><span style="margin-top: 7px; height: 26px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 800; white-space: nowrap;"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg>38 clubes</span></a><a href="#" style="width: 128px; flex-shrink: 0; display: block;"><span aria-hidden="true" style="position: relative; display: block; width: 124px; height: 176px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg);"><span style="position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35);"></span><svg width="100%" height="70" viewBox="0 0 110 70" preserveAspectRatio="none" style="position: absolute; left: 0; top: 10px; overflow: hidden;"><circle cx="78" cy="22" r="13" fill="#FED170" stroke="#1A1714" stroke-width="1.4"></circle><path d="M-4 46q9-8 18 0t18 0 18 0 18 0 18 0 18 0 18 0V80H-4Z" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.4"></path><path d="M-4 58q9-8 18 0t18 0 18 0 18 0 18 0 18 0 18 0V80H-4Z" fill="#552CB7" stroke="#1A1714" stroke-width="1.4"></path></svg><span style="position: absolute; left: 14px; right: 8px; bottom: 10px; color: #1A1714;"><span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.95; letter-spacing: -0.4px;">Iracema</span><span style="display: block; margin-top: 4px; font-size: 10px; font-weight: 700; opacity: 0.8;">José de Alencar</span></span></span><span style="display: block; margin-top: 10px; font-size: 14px; font-weight: 800; line-height: 1.2;">Iracema</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">José de Alencar</span><span style="margin-top: 7px; height: 26px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 800; white-space: nowrap;"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg>31 clubes</span></a><a href="#" style="width: 128px; flex-shrink: 0; display: block;"><span aria-hidden="true" style="position: relative; display: block; width: 124px; height: 176px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg);"><span style="position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35);"></span><svg width="100%" height="96" viewBox="0 0 110 96" style="position: absolute; left: 0; top: 4px;"><g transform="rotate(-28 55 52)"><rect x="51.5" y="2" width="7" height="40" rx="2" fill="#1A1714"></rect><rect x="48" y="-6" width="14" height="11" rx="3" fill="#1A1714"></rect><circle cx="55" cy="46" r="13" fill="#FF552E" stroke="#1A1714" stroke-width="1.5"></circle><circle cx="55" cy="66" r="18" fill="#FF552E" stroke="#1A1714" stroke-width="1.5"></circle><circle cx="55" cy="55" r="5.5" fill="#1A1714"></circle><rect x="47" y="72" width="16" height="4" rx="1.5" fill="#1A1714"></rect><path d="M53.5 4V74M56.5 4V74" stroke="#FFFAF1" stroke-width="0.7"></path></g></svg><span style="position: absolute; left: 14px; right: 8px; bottom: 10px; color: #1A1714;"><span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.95; letter-spacing: -0.4px;">Policarpo Quaresma</span><span style="display: block; margin-top: 4px; font-size: 10px; font-weight: 700; opacity: 0.8;">Lima Barreto</span></span></span><span style="display: block; margin-top: 10px; font-size: 14px; font-weight: 800; line-height: 1.2;">Policarpo Quaresma</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">Lima Barreto</span><span style="margin-top: 7px; height: 26px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 800; white-space: nowrap;"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg>24 clubes</span></a><a href="#" style="width: 128px; flex-shrink: 0; display: block;"><span aria-hidden="true" style="position: relative; display: block; width: 124px; height: 176px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #552CB7; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg);"><span style="position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35);"></span><svg width="100%" height="90" viewBox="0 0 110 90" style="position: absolute; left: 0; top: 4px;"><path transform="translate(30 14) scale(2)" d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path><path transform="translate(14 8) scale(.8)" d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg><span style="position: absolute; left: 14px; right: 8px; bottom: 10px; color: #F7F0E3;"><span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.95; letter-spacing: -0.4px;">A Hora da Estrela</span><span style="display: block; margin-top: 4px; font-size: 10px; font-weight: 700; opacity: 0.8;">Clarice Lispector</span></span></span><span style="display: block; margin-top: 10px; font-size: 14px; font-weight: 800; line-height: 1.2;">A Hora da Estrela</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">Clarice Lispector</span><span style="margin-top: 7px; height: 26px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 800; white-space: nowrap;"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg>22 clubes</span></a></div>
```

## Especificação pixel a pixel

Seção `bu28.trending` — retângulo absoluto no canvas 390×1520: **x=0, y=1074, w=390, h=335.02**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28.trending.header` | box | 16 | 0 | 358 | 25.2 | `margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 2 | `bu28.trending.title` ±1 | text | 16 | 0 | 184.72 | 25.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px` | Bricolage (opsz 21) 21/normal peso 800 ls -0.4px #1A1714 |
| 3 | `bu28.trending.subtitle` | text | 16 | 29.2 | 358 | 16.21 | `margin: 4px 0 0; font-size: 13.5px; font-weight: 600; color: #5B544B` | Figtree 13.5/normal peso 600 ls normal #5B544B |
| 4 | `bu28.trending.carousel` | box | 0 | 59.41 | 390 | 275.61 | `margin: 14px -16px 0; padding: 0 16px 6px; display: flex; gap: 14px; overflow: hidden` |  |
| 5 | `bu28.trending.book1` | box | 16 | 59.41 | 128 | 269.61 | `width: 128px; flex-shrink: 0; display: block` |  |
| 6 | `bu28.trending.book1.cover` | box | 16 | 59.41 | 124 | 176 | `position: relative; display: block; width: 124px; height: 176px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg)` |  |
| 7 | `bu28.trending.book1.cover.spine` | box | 24.5 | 60.91 | 1.5 | 173 | `position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35)` |  |
| 8 | `bu28.trending.book1.cover.window1` | box | 33.5 | 74.91 | 12 | 14 | `position: absolute; left: 16px; top: 14px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 9 | `bu28.trending.book1.cover.window2` | box | 54.5 | 74.91 | 12 | 14 | `position: absolute; left: 37px; top: 14px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FED170; box-sizing: border-box` |  |
| 10 | `bu28.trending.book1.cover.window3` | box | 75.5 | 74.91 | 12 | 14 | `position: absolute; left: 58px; top: 14px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 11 | `bu28.trending.book1.cover.window4` | box | 96.5 | 74.91 | 12 | 14 | `position: absolute; left: 79px; top: 14px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 12 | `bu28.trending.book1.cover.window5` | box | 33.5 | 94.91 | 12 | 14 | `position: absolute; left: 16px; top: 34px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 13 | `bu28.trending.book1.cover.window6` | box | 54.5 | 94.91 | 12 | 14 | `position: absolute; left: 37px; top: 34px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 14 | `bu28.trending.book1.cover.window7` | box | 75.5 | 94.91 | 12 | 14 | `position: absolute; left: 58px; top: 34px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FED170; box-sizing: border-box` |  |
| 15 | `bu28.trending.book1.cover.window8` | box | 96.5 | 94.91 | 12 | 14 | `position: absolute; left: 79px; top: 34px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 16 | `bu28.trending.book1.cover.window9` | box | 33.5 | 114.91 | 12 | 14 | `position: absolute; left: 16px; top: 54px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FED170; box-sizing: border-box` |  |
| 17 | `bu28.trending.book1.cover.window10` | box | 54.5 | 114.91 | 12 | 14 | `position: absolute; left: 37px; top: 54px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 18 | `bu28.trending.book1.cover.window11` | box | 75.5 | 114.91 | 12 | 14 | `position: absolute; left: 58px; top: 54px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 19 | `bu28.trending.book1.cover.window12` | box | 96.5 | 114.91 | 12 | 14 | `position: absolute; left: 79px; top: 54px; width: 12px; height: 14px; border: 1.3px solid #1A1714; background: #FFFAF1; box-sizing: border-box` |  |
| 20 | `bu28.trending.book1.cover.textBlock` | box | 31.5 | 191.76 | 99 | 32.15 | `position: absolute; left: 14px; right: 8px; bottom: 10px; color: #1A1714` |  |
| 21 | `bu28.trending.book1.cover.title` | text | 31.5 | 191.76 | 99 | 16.15 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.95; letter-spacing: -0.4px` | Bricolage (opsz 17) 17/16.15px peso 800 ls -0.4px #1A1714 |
| 22 | `bu28.trending.book1.cover.author` | text | 31.5 | 211.91 | 99 | 12 | `display: block; margin-top: 4px; font-size: 10px; font-weight: 700; opacity: 0.8` | Figtree 10/normal peso 700 ls normal #1A1714 |
| 23 | `bu28.trending.book1.title` | text | 16 | 245.41 | 128 | 16.8 | `display: block; margin-top: 10px; font-size: 14px; font-weight: 800; line-height: 1.2` | Figtree 14/16.8px peso 800 ls normal #1A1714 |
| 24 | `bu28.trending.book1.author` | text | 16 | 264.21 | 128 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 25 | `bu28.trending.book1.clubs` ±1 | box+text | 16 | 286.22 | 85.48 | 26 | `margin-top: 7px; height: 26px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 800; white-space: nowrap` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 26 | `bu28.trending.book1.clubs.icon` | icon | 23.3 | 292.72 | 13 | 13 | `—` |  |
| 27 | `bu28.trending.book2` | box | 158 | 59.41 | 128 | 269.61 | `width: 128px; flex-shrink: 0; display: block` |  |
| 28 | `bu28.trending.book2.cover` | box | 158 | 59.41 | 124 | 176 | `position: relative; display: block; width: 124px; height: 176px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg)` |  |
| 29 | `bu28.trending.book2.cover.spine` | box | 166.5 | 60.91 | 1.5 | 173 | `position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35)` |  |
| 30 | `bu28.trending.book2.cover.art` | icon | 159.5 | 70.91 | 121 | 70 | `position: absolute; left: 0; top: 10px; overflow: hidden` |  |
| 31 | `bu28.trending.book2.cover.textBlock` | box | 173.5 | 191.76 | 99 | 32.15 | `position: absolute; left: 14px; right: 8px; bottom: 10px; color: #1A1714` |  |
| 32 | `bu28.trending.book2.cover.title` | text | 173.5 | 191.76 | 99 | 16.15 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.95; letter-spacing: -0.4px` | Bricolage (opsz 17) 17/16.15px peso 800 ls -0.4px #1A1714 |
| 33 | `bu28.trending.book2.cover.author` | text | 173.5 | 211.91 | 99 | 12 | `display: block; margin-top: 4px; font-size: 10px; font-weight: 700; opacity: 0.8` | Figtree 10/normal peso 700 ls normal #1A1714 |
| 34 | `bu28.trending.book2.title` | text | 158 | 245.41 | 128 | 16.8 | `display: block; margin-top: 10px; font-size: 14px; font-weight: 800; line-height: 1.2` | Figtree 14/16.8px peso 800 ls normal #1A1714 |
| 35 | `bu28.trending.book2.author` | text | 158 | 264.21 | 128 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 36 | `bu28.trending.book2.clubs` ±1 | box+text | 158 | 286.22 | 83.35 | 26 | `margin-top: 7px; height: 26px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 800; white-space: nowrap` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 37 | `bu28.trending.book2.clubs.icon` | icon | 165.3 | 292.72 | 13 | 13 | `—` |  |
| 38 | `bu28.trending.book3` | box | 300 | 59.41 | 128 | 269.61 | `width: 128px; flex-shrink: 0; display: block` |  |
| 39 | `bu28.trending.book3.cover` | box | 300 | 59.41 | 124 | 176 | `position: relative; display: block; width: 124px; height: 176px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg)` |  |
| 40 | `bu28.trending.book3.cover.spine` | box | 308.5 | 60.91 | 1.5 | 173 | `position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35)` |  |
| 41 | `bu28.trending.book3.cover.art` | icon | 301.5 | 64.91 | 121 | 96 | `position: absolute; left: 0; top: 4px` |  |
| 42 | `bu28.trending.book3.cover.textBlock` | box | 315.5 | 175.61 | 99 | 48.3 | `position: absolute; left: 14px; right: 8px; bottom: 10px; color: #1A1714` |  |
| 43 | `bu28.trending.book3.cover.title` | text | 315.5 | 175.61 | 99 | 32.3 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.95; letter-spacing: -0.4px` | Bricolage (opsz 17) 17/16.15px peso 800 ls -0.4px #1A1714 |
| 44 | `bu28.trending.book3.cover.author` | text | 315.5 | 211.91 | 99 | 12 | `display: block; margin-top: 4px; font-size: 10px; font-weight: 700; opacity: 0.8` | Figtree 10/normal peso 700 ls normal #1A1714 |
| 45 | `bu28.trending.book3.title` | text | 300 | 245.41 | 128 | 33.6 | `display: block; margin-top: 10px; font-size: 14px; font-weight: 800; line-height: 1.2` | Figtree 14/16.8px peso 800 ls normal #1A1714 |
| 46 | `bu28.trending.book3.author` | text | 300 | 281.01 | 128 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 47 | `bu28.trending.book3.clubs` ±1 | box+text | 300 | 303.02 | 86.11 | 26 | `margin-top: 7px; height: 26px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 800; white-space: nowrap` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 48 | `bu28.trending.book3.clubs.icon` | icon | 307.3 | 309.52 | 13 | 13 | `—` |  |
| 49 | `bu28.trending.book4` | box | 442 | 59.41 | 128 | 269.61 | `width: 128px; flex-shrink: 0; display: block` |  |
| 50 | `bu28.trending.book4.cover` | box | 442 | 59.41 | 124 | 176 | `position: relative; display: block; width: 124px; height: 176px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #552CB7; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg)` |  |
| 51 | `bu28.trending.book4.cover.spine` | box | 450.5 | 60.91 | 1.5 | 173 | `position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35)` |  |
| 52 | `bu28.trending.book4.cover.art` | icon | 443.5 | 64.91 | 121 | 90 | `position: absolute; left: 0; top: 4px` |  |
| 53 | `bu28.trending.book4.cover.textBlock` | box | 457.5 | 175.61 | 99 | 48.3 | `position: absolute; left: 14px; right: 8px; bottom: 10px; color: #F7F0E3` |  |
| 54 | `bu28.trending.book4.cover.title` | text | 457.5 | 175.61 | 99 | 32.3 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.95; letter-spacing: -0.4px` | Bricolage (opsz 17) 17/16.15px peso 800 ls -0.4px #F7F0E3 |
| 55 | `bu28.trending.book4.cover.author` | text | 457.5 | 211.91 | 99 | 12 | `display: block; margin-top: 4px; font-size: 10px; font-weight: 700; opacity: 0.8` | Figtree 10/normal peso 700 ls normal #F7F0E3 |
| 56 | `bu28.trending.book4.title` | text | 442 | 245.41 | 128 | 16.8 | `display: block; margin-top: 10px; font-size: 14px; font-weight: 800; line-height: 1.2` | Figtree 14/16.8px peso 800 ls normal #1A1714 |
| 57 | `bu28.trending.book4.author` | text | 442 | 264.21 | 128 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 58 | `bu28.trending.book4.clubs` ±1 | box+text | 442 | 286.22 | 85.52 | 26 | `margin-top: 7px; height: 26px; padding: 0 9px 0 6px; border-radius: 999px; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 800; white-space: nowrap` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 59 | `bu28.trending.book4.clubs.icon` | icon | 449.3 | 292.72 | 13 | 13 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28.trending.title` | 1 | Em alta nos clubes | 19.53 | 16 | 200.72 | 184.72 |
| `bu28.trending.subtitle` | 1 | Livros que mais clubes começaram esta semana | 42.03 | 16 | 309.16 | 293.16 |
| `bu28.trending.book1.cover.title` | 1 | O Cortiço | 205.44 | 31.5 | 105.53 | 74.03 |
| `bu28.trending.book1.cover.author` | 1 | Aluísio Azevedo | 221.41 | 31.5 | 104.8 | 73.3 |
| `bu28.trending.book1.title` | 1 | O Cortiço | 258.71 | 16 | 79.74 | 63.74 |
| `bu28.trending.book1.author` | 1 | Aluísio Azevedo | 276.09 | 16 | 106.65 | 90.65 |
| `bu28.trending.book1.clubs` | 1 | 38 clubes | 303.24 | 40.3 | 91.18 | 50.88 |
| `bu28.trending.book2.cover.title` | 1 | Iracema | 205.44 | 173.5 | 239.31 | 65.81 |
| `bu28.trending.book2.cover.author` | 1 | José de Alencar | 221.41 | 173.5 | 246.71 | 73.21 |
| `bu28.trending.book2.title` | 1 | Iracema | 258.71 | 158 | 210.7 | 52.7 |
| `bu28.trending.book2.author` | 1 | José de Alencar | 276.09 | 158 | 248.53 | 90.53 |
| `bu28.trending.book2.clubs` | 1 | 31 clubes | 303.24 | 182.3 | 231.05 | 48.75 |
| `bu28.trending.book3.cover.title` | 1 | Policarpo | 189.29 | 315.5 | 391.67 | 76.17 |
| `bu28.trending.book3.cover.title` | 2 | Quaresma | 205.44 | 315.5 | 398.75 | 83.25 |
| `bu28.trending.book3.cover.author` | 1 | Lima Barreto | 221.41 | 315.5 | 374.23 | 58.73 |
| `bu28.trending.book3.title` | 1 | Policarpo | 258.71 | 300 | 361.5 | 61.5 |
| `bu28.trending.book3.title` | 2 | Quaresma | 275.51 | 300 | 366.7 | 66.7 |
| `bu28.trending.book3.author` | 1 | Lima Barreto | 292.89 | 300 | 372.37 | 72.37 |
| `bu28.trending.book3.clubs` | 1 | 24 clubes | 320.05 | 324.3 | 375.81 | 51.51 |
| `bu28.trending.book4.cover.title` | 1 | A Hora da | 189.29 | 457.5 | 534.79 | 77.29 |
| `bu28.trending.book4.cover.title` | 2 | Estrela | 205.44 | 457.5 | 513.91 | 56.41 |
| `bu28.trending.book4.cover.author` | 1 | Clarice Lispector | 221.41 | 457.5 | 535.52 | 78.02 |
| `bu28.trending.book4.title` | 1 | A Hora da Estrela *(oculta: recortada)* | 258.71 | 442 | 555.11 | 113.11 |
| `bu28.trending.book4.author` | 1 | Clarice Lispector *(oculta: recortada)* | 276.09 | 442 | 538.26 | 96.26 |
| `bu28.trending.book4.clubs` | 1 | 22 clubes *(oculta: recortada)* | 303.24 | 466.3 | 517.22 | 50.92 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Em alta nos clubes" Bricolage 21/800, 30 abaixo dos gêneros; o texto 13,5/600 `#5B544B`, 4 abaixo.
2. Carrossel com `margin 14 −16 0` e `padding 0 16 6`, gap 14, `overflow: hidden`: itens de 128 com a capa de 124 × 176 (raio 6/12/12/6, borda 1,5, sombra 3/3), a lombada de 1,5 a 7 da borda e o título Bricolage 17/800 + autor 10/700 a 0,8 dentro, embaixo.
3. Embaixo da capa: título 14/800, autor 12,5/600 `#6F665B` e a pílula de 26 `#FFC1C6` (borda 1,3, padding 0/9/0/6, as pessoas 13 + "38 clubes" 11,5/800).
4. Capas da fixture: O Cortiço (as janelas em CSS), Iracema, Policarpo Quaresma e A Hora da Estrela (desenhos SVG que ocupam a largura da capa).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As ilustrações de Iracema, Policarpo e A Hora da Estrela têm `width="100%"`: no app ocupam a caixa da capa (Iracema esticada, `BoxFit.fill`; as outras com `contain`), como diz o mapa de widgets.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `bu28.trending.book4.title`, `bu28.trending.book4.author`, `bu28.trending.book4.clubs`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028_busca_explorar_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028_busca_explorar_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `bu28.trending.book3` | sai do quadro (x) | 68 | 38 | não | sim |  |
| 360 | `bu28.trending.book3` | passa do pai (x) | 68 | 38 | não | sim | pai `bu28.trending.carousel` (cortado) |
| 360 | `bu28.trending.book4` | sai do quadro (x) | 210 | 180 | não | sim |  |
| 360 | `bu28.trending.book4` | passa do pai (x) | 210 | 180 | não | sim | pai `bu28.trending.carousel` (cortado) |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28.trending.book1.cover` |  |  | aria-hidden=true |
| `bu28.trending.book1.clubs.icon` |  |  | aria-hidden=true |
| `bu28.trending.book2.cover` |  |  | aria-hidden=true |
| `bu28.trending.book2.clubs.icon` |  |  | aria-hidden=true |
| `bu28.trending.book3.cover` |  |  | aria-hidden=true |
| `bu28.trending.book3.clubs.icon` |  |  | aria-hidden=true |
| `bu28.trending.book4.cover` |  |  | aria-hidden=true |
| `bu28.trending.book4.clubs.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28.trending.book1.cover` | NeoBox | Transform: rotate(0deg) |
| `bu28.trending.book1.cover.spine` | NeoBox |  |
| `bu28.trending.book1.cover.window1` | NeoBox |  |
| `bu28.trending.book1.cover.window2` | NeoBox |  |
| `bu28.trending.book1.cover.window3` | NeoBox |  |
| `bu28.trending.book1.cover.window4` | NeoBox |  |
| `bu28.trending.book1.cover.window5` | NeoBox |  |
| `bu28.trending.book1.cover.window6` | NeoBox |  |
| `bu28.trending.book1.cover.window7` | NeoBox |  |
| `bu28.trending.book1.cover.window8` | NeoBox |  |
| `bu28.trending.book1.cover.window9` | NeoBox |  |
| `bu28.trending.book1.cover.window10` | NeoBox |  |
| `bu28.trending.book1.cover.window11` | NeoBox |  |
| `bu28.trending.book1.cover.window12` | NeoBox |  |
| `bu28.trending.book1.clubs` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.trending.book1.clubs.icon` | AppSvg(AppIconsLeitor.people, size: 13) |  |
| `bu28.trending.book2.cover` | NeoBox | Transform: rotate(0deg) |
| `bu28.trending.book2.cover.spine` | NeoBox |  |
| `bu28.trending.book2.cover.art` | AppSvg(AppIllustrationsScanner.capaIracema, size: 121×70) | width="100%" (a largura da caixa da capa) e preserveAspectRatio="none": o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa (BoxFit.fill: esticada). |
| `bu28.trending.book2.clubs` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.trending.book2.clubs.icon` | AppSvg(AppIconsLeitor.people, size: 13) |  |
| `bu28.trending.book3.cover` | NeoBox | Transform: rotate(0deg) |
| `bu28.trending.book3.cover.spine` | NeoBox |  |
| `bu28.trending.book3.cover.art` | AppSvg(AppIllustrationsScanner.capaPolicarpoQuaresma, size: 121×96) | width="100%" (a largura da caixa da capa): o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa (BoxFit.contain, centrada). |
| `bu28.trending.book3.clubs` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.trending.book3.clubs.icon` | AppSvg(AppIconsLeitor.people, size: 13) |  |
| `bu28.trending.book4.cover` | NeoBox | Transform: rotate(0deg) |
| `bu28.trending.book4.cover.spine` | NeoBox |  |
| `bu28.trending.book4.cover.art` | AppSvg(AppIllustrationsScanner.capaAHoraDaEstrela, size: 121×90) | width="100%" (a largura da caixa da capa): o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa (BoxFit.contain, centrada). |
| `bu28.trending.book4.clubs` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28.trending.book4.clubs.icon` | AppSvg(AppIconsLeitor.people, size: 13) |  |

## Interações

- Livro → os detalhes do livro do catálogo; um livro que não está na estante não tem prancha de Detalhes (a 17 é a do livro da pessoa) — pergunta da T15.

## Dados

- "Livros que mais clubes começaram esta semana" vem do servidor (a contagem de clubes por livro na semana); a consulta ainda não existe: D-247 — com dados reais a seção some até haver a fonte (pergunta da T15), e a fixture continua nos testes.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L28.1** Título e texto
- **L28.2** Carrossel de capas com a contagem de clubes
- **L28.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28.trending'), todos os ids de `kRef28.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028_busca_explorar_390x1520@3x.png` no recorte da fase (y 1066–1417.02) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28w360` e `kRef28w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28.1 Título e texto
- [ ] L28.2 Carrossel de capas com a contagem de clubes
- [ ] L28.3 Verificação + relatório
- [ ] Geometria 59/59 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
