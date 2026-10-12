# FASE L05 — Perfil — a atividade recente (desenho, grifo e resenha com estrelas), o degradê e a navegação (aba Perfil)

> Tela 05 · prancha `005_perfil` (05 · Perfil, canvas 390×2510) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L05_4_atividade@3x.png` · `docs/design/medicao/projeto/png/redline/L05_4_atividade_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/005_perfil_390x2510@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_005_perfil.json` · `test/reference/projeto/reference_layout_005_perfil.dart` (`kRef05`).
> Arquivos sugeridos: `lib/features/profile/presentation/sections/recent_activity_section.dart`, `lib/features/shell/presentation/floating_nav_bar.dart`, `lib/features/shell/presentation/bottom_fade.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Perfil (05), no fim do Resumo: a atividade recente (desenhou em Dom Casmurro, grifou com a citação marcada, terminou Quincas Borba com 4 estrelas e a resenha), o degradê do fim e a navegação com o Perfil marcado.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`, `{{card}}` = padrão `#FF552E`.

```html
<!-- Recent activity -->
<section aria-label="Atividade recente" style="margin-top: 38px; display: flex; flex-direction: column; gap: 6px;">
  <h2 style="margin: 0 0 6px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Atividade recente</h2>

  <div style="display: flex; gap: 12px; padding: 12px 0; border-bottom: 1px solid #E4DACA;">
    <span aria-hidden="true" style="width: 36px; height: 36px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16v4z"></path><path d="m13.5 6.5 4 4"></path></svg>
    </span>
    <div style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
      <span style="font-size: 14px; font-weight: 500; line-height: 1.35;">Desenhou à mão em <strong style="font-weight: 800;">Dom Casmurro</strong>, pág. 159</span>
      <span style="font-size: 12px; font-weight: 600; color: #6F665B;">Hoje</span>
    </div>
  </div>

  <div style="display: flex; gap: 12px; padding: 12px 0; border-bottom: 1px solid #E4DACA;">
    <span aria-hidden="true" style="width: 36px; height: 36px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 11-6 6v3h9l3-3"></path><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"></path></svg>
    </span>
    <div style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 6px;">
      <span style="font-size: 14px; font-weight: 500; line-height: 1.35;">Grifou em <strong style="font-weight: 800;">Dom Casmurro</strong></span>
      <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 19px; line-height: 1.15;"><span style="background: linear-gradient(transparent 55%, #FED170 55%);">“…olhos de cigana oblíqua e dissimulada.”</span></span>
      <span style="font-size: 12px; font-weight: 600; color: #6F665B;">Ontem · no clube Leitoras de Capitu</span>
    </div>
  </div>

  <div style="display: flex; gap: 12px; padding: 12px 0;">
    <span aria-hidden="true" style="width: 36px; height: 36px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
    </span>
    <div style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 6px;">
      <span style="font-size: 14px; font-weight: 500; line-height: 1.35;">Terminou <strong style="font-weight: 800;">Quincas Borba</strong></span>
      <span aria-label="4 de 5 estrelas" style="display: flex; gap: 2px;">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z"></path></svg>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z"></path></svg>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z"></path></svg>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z"></path></svg>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z"></path></svg>
      </span>
      <span style="font-size: 14px; font-weight: 500; line-height: 1.4; color: #3D3830;">“Ao vencedor, as batatas!” não sai mais da minha cabeça. Machado sendo irônico no auge.</span>
      <span style="font-size: 12px; font-weight: 600; color: #6F665B;">Há 3 dias · resenha</span>
    </div>
  </div>
</section>

<!-- Bottom fade so content slips under the floating nav -->
<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 150px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 55%); pointer-events: none;"></div>

<!-- Bottom navigation -->
<nav aria-label="Navegação principal" style="position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px;">
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Início</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="4" width="4.5" height="16" rx="1"></rect><rect x="10" y="4" width="4.5" height="16" rx="1"></rect><path d="m16.4 5.6 3.9-1 3.2 14.6-3.9 1z"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Biblioteca</span>
  </a>
  <a href="#" aria-label="Scanner: escanear livro" style="position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px;">
    <span style="position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3.5 8V6a2.5 2.5 0 0 1 2.5-2.5h2"></path><path d="M16 3.5h2A2.5 2.5 0 0 1 20.5 6v2"></path><path d="M20.5 16v2a2.5 2.5 0 0 1-2.5 2.5h-2"></path><path d="M8 20.5H6A2.5 2.5 0 0 1 3.5 18v-2"></path><path d="M8 8.5v7"></path><path d="M11 8.5v7"></path><path d="M13.5 8.5v7"></path><path d="M16 8.5v7"></path></svg>
    </span>
    <span style="font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px;">Scanner</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Clubes</span>
  </a>
  <a href="#" aria-current="page" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"></circle><path d="M4 21a8 8 0 0 1 16 0"></path></svg>
    <span style="font-size: 11px; font-weight: 800;">Perfil</span>
  </a>
</nav>
```

## Especificação pixel a pixel

Seção `p05.activity` — retângulo absoluto no canvas 390×2510: **x=20, y=1986.69, w=350, h=330.95**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `p05.activity` | box | 0 | 0 | 350 | 330.95 | `margin-top: 38px; display: flex; flex-direction: column; gap: 6px` |  |
| 2 | `p05.activity.title` | text | 0 | 0 | 350 | 24 | `margin: 0 0 6px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 3 | `p05.activity.item1` | box | 0 | 36 | 350 | 61.3 | `display: flex; gap: 12px; padding: 12px 0; border-bottom: 1px solid #E4DACA` |  |
| 4 | `p05.activity.item1.icon` | box | 0 | 48 | 36 | 36 | `width: 36px; height: 36px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 5 | `p05.activity.item1.icon.art` | icon | 9 | 57 | 18 | 18 | `—` |  |
| 6 | `p05.activity.item1.textBlock` | box | 48 | 48 | 302 | 36.3 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 7 | `p05.activity.item1.text` | text | 48 | 48 | 302 | 18.9 | `font-size: 14px; font-weight: 500; line-height: 1.35` | Figtree 14/18.9px peso 500 ls normal #1A1714 |
| 8 | `p05.activity.item1.text.book` ±1 | inline | 179.07 | 49.05 | 97.72 | 16.8 | `font-weight: 800` | Figtree 14/18.9px peso 800 ls normal #1A1714 |
| 9 | `p05.activity.item1.time` | text | 48 | 69.9 | 302 | 14.4 | `font-size: 12px; font-weight: 600; color: #6F665B` | Figtree 12/normal peso 600 ls normal #6F665B |
| 10 | `p05.activity.item2` | box | 0 | 103.3 | 350 | 92.15 | `display: flex; gap: 12px; padding: 12px 0; border-bottom: 1px solid #E4DACA` |  |
| 11 | `p05.activity.item2.icon` | box | 0 | 115.3 | 36 | 36 | `width: 36px; height: 36px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 12 | `p05.activity.item2.icon.art` | icon | 9 | 124.3 | 18 | 18 | `—` |  |
| 13 | `p05.activity.item2.textBlock` | box | 48 | 115.3 | 302 | 67.15 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 6px` |  |
| 14 | `p05.activity.item2.text` | text | 48 | 115.3 | 302 | 18.9 | `font-size: 14px; font-weight: 500; line-height: 1.35` | Figtree 14/18.9px peso 500 ls normal #1A1714 |
| 15 | `p05.activity.item2.text.book` ±1 | inline | 114.49 | 116.35 | 97.72 | 16.8 | `font-weight: 800` | Figtree 14/18.9px peso 800 ls normal #1A1714 |
| 16 | `p05.activity.item2.quote` | box | 48 | 140.2 | 302 | 21.85 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 19px; line-height: 1.15` | Instrument Serif itálico 19/21.85px peso 400 ls normal #1A1714 |
| 17 | `p05.activity.item2.quote.highlight` ±1 | inline | 48 | 138.77 | 284.77 | 24.7 | `background: linear-gradient(transparent 55%, #FED170 55%)` | Instrument Serif itálico 19/21.85px peso 400 ls normal #1A1714 |
| 18 | `p05.activity.item2.time` | text | 48 | 168.05 | 302 | 14.4 | `font-size: 12px; font-weight: 600; color: #6F665B` | Figtree 12/normal peso 600 ls normal #6F665B |
| 19 | `p05.activity.item3` | box | 0 | 201.45 | 350 | 129.5 | `display: flex; gap: 12px; padding: 12px 0` |  |
| 20 | `p05.activity.item3.icon` | box | 0 | 213.45 | 36 | 36 | `width: 36px; height: 36px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 21 | `p05.activity.item3.icon.art` | icon | 9 | 222.45 | 18 | 18 | `—` |  |
| 22 | `p05.activity.item3.textBlock` | box | 48 | 213.45 | 302 | 105.5 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 6px` |  |
| 23 | `p05.activity.item3.text` | text | 48 | 213.45 | 302 | 18.9 | `font-size: 14px; font-weight: 500; line-height: 1.35` | Figtree 14/18.9px peso 500 ls normal #1A1714 |
| 24 | `p05.activity.item3.text.book` ±1 | inline | 110.13 | 214.5 | 94.49 | 16.8 | `font-weight: 800` | Figtree 14/18.9px peso 800 ls normal #1A1714 |
| 25 | `p05.activity.item3.rating` | box | 48 | 238.35 | 302 | 15 | `display: flex; gap: 2px` |  |
| 26 | `p05.activity.item3.rating.star1` | icon | 48 | 238.35 | 15 | 15 | `—` |  |
| 27 | `p05.activity.item3.rating.star2` | icon | 65 | 238.35 | 15 | 15 | `—` |  |
| 28 | `p05.activity.item3.rating.star3` | icon | 82 | 238.35 | 15 | 15 | `—` |  |
| 29 | `p05.activity.item3.rating.star4` | icon | 99 | 238.35 | 15 | 15 | `—` |  |
| 30 | `p05.activity.item3.rating.star5` | icon | 116 | 238.35 | 15 | 15 | `—` |  |
| 31 | `p05.activity.item3.review` | text | 48 | 259.35 | 302 | 39.2 | `font-size: 14px; font-weight: 500; line-height: 1.4; color: #3D3830` | Figtree 14/19.6px peso 500 ls normal #3D3830 |
| 32 | `p05.activity.item3.time` | text | 48 | 304.55 | 302 | 14.4 | `font-size: 12px; font-weight: 600; color: #6F665B` | Figtree 12/normal peso 600 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.activity.title` | 1 | Atividade recente | 18.6 | 0 | 167.38 | 167.38 |
| `p05.activity.item1.text` *(composto)* | 1 | Desenhou à mão em Dom Casmurro, pág. 159 | 62.35 | 48 | 335.62 | 287.62 |
| `p05.activity.item1.time` | 1 | Hoje | 81.3 | 48 | 73.97 | 25.97 |
| `p05.activity.item2.text` *(composto)* | 1 | Grifou em Dom Casmurro | 129.65 | 48 | 212.21 | 164.21 |
| `p05.activity.item2.quote` *(composto)* | 1 | “…olhos de cigana oblíqua e dissimulada.” | 157.58 | 48 | 332.77 | 284.77 |
| `p05.activity.item2.time` | 1 | Ontem · no clube Leitoras de Capitu | 179.45 | 48 | 243.95 | 195.95 |
| `p05.activity.item3.text` *(composto)* | 1 | Terminou Quincas Borba | 227.8 | 48 | 204.62 | 156.62 |
| `p05.activity.item3.review` | 1 | “Ao vencedor, as batatas!” não sai mais da | 274.05 | 48 | 311.87 | 263.87 |
| `p05.activity.item3.review` | 2 | minha cabeça. Machado sendo irônico no auge. | 293.65 | 48 | 345.28 | 297.28 |
| `p05.activity.item3.time` | 1 | Há 3 dias · resenha | 315.95 | 48 | 149.5 | 101.5 |

Seção `p05.bottomFade` — retângulo absoluto no canvas 390×2510: **x=0, y=2360, w=390, h=150**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 33 | `p05.bottomFade` | box | 0 | 0 | 390 | 150 | `position: absolute; left: 0; right: 0; bottom: 0; height: 150px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 55%); pointer-events: none` |  |

Seção `p05.nav` — retângulo absoluto no canvas 390×2510: **x=16, y=2410, w=358, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 34 | `p05.nav` | box | 0 | 0 | 358 | 70 | `position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px` |  |
| 35 | `p05.nav.home` | box | 9.5 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 36 | `p05.nav.home.icon` | icon | 30.8 | 15.9 | 22 | 22 | `—` |  |
| 37 | `p05.nav.home.label` ±1 | text | 28.21 | 40.9 | 27.18 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 38 | `p05.nav.library` | box | 78.1 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 39 | `p05.nav.library.icon` | icon | 99.4 | 15.9 | 22 | 22 | `—` |  |
| 40 | `p05.nav.library.label` ±1 | text | 85.5 | 40.9 | 49.79 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 41 | `p05.nav.scanner` | box | 146.7 | 9.5 | 64.6 | 51 | `position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px` |  |
| 42 | `p05.nav.scanner.fab` | box | 149 | -20.5 | 60 | 60 | `position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 43 | `p05.nav.scanner.icon` | icon | 165 | -4.5 | 28 | 28 | `—` |  |
| 44 | `p05.nav.scanner.label` ±1 | text | 158.35 | 45.3 | 41.3 | 15.2 | `font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px` | Figtree 11/normal peso 700 ls normal #1A1714 |
| 45 | `p05.nav.clubs` | box | 215.3 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 46 | `p05.nav.clubs.icon` | icon | 236.6 | 15.9 | 22 | 22 | `—` |  |
| 47 | `p05.nav.clubs.label` ±1 | text | 230.37 | 40.9 | 34.45 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 48 | `p05.nav.profile` | box | 283.9 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 49 | `p05.nav.profile.icon` | icon | 305.2 | 15.9 | 22 | 22 | `—` |  |
| 50 | `p05.nav.profile.label` ±1 | text | 302.45 | 40.9 | 27.5 | 13.2 | `font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p05.nav.home.label` | 1 | Início | 51.35 | 28.21 | 55.39 | 27.18 |
| `p05.nav.library.label` | 1 | Biblioteca | 51.35 | 85.5 | 135.3 | 49.8 |
| `p05.nav.scanner.label` | 1 | Scanner | 55.75 | 158.35 | 199.65 | 41.3 |
| `p05.nav.clubs.label` | 1 | Clubes | 51.35 | 230.37 | 264.83 | 34.46 |
| `p05.nav.profile.label` | 1 | Perfil | 51.35 | 302.45 | 329.95 | 27.5 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Atividade recente" Bricolage 20/800, 6 acima da lista; cada item com padding 12/0, gap 12 e o fio de 1 `#E4DACA` (o último sem fio): o círculo 36 colorido (borda 1,5) com o ícone 18 e o texto em coluna.
2. O texto: a frase 14/500 `lh 1,35` com o livro em 800; a citação Instrument Serif itálico 19 `lh 1,15` com o marca-texto `#FED170` dos 45% de baixo (`linear-gradient`); as estrelas 15 (gap 2: 4 douradas `#F2A815` e 1 vazia); a resenha 14/500 `lh 1,4` `#3D3830`; e o quando 12/600 `#6F665B`.
3. O degradê de 150 no fundo (transparente → `#F7F0E3` em 55%) e a navegação flutuante: a mesma da Início (o shell), com o Perfil marcado (`{{brand}}`, borda 1,5, o ícone cheio `#FFFAF1`, 11/800).
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O marca-texto da citação é um degradê duro de 55% atrás do texto inline (quebra junto com a linha): no app, o mesmo componente da citação marcada da Início e dos grifos (`marked_quote.dart`), não um fundo de caixa.
- O "4 de 5 estrelas" é o rótulo do grupo; as estrelas são decorativas.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_005_perfil_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_005_perfil_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `p05.nav.scanner.fab` | passa do pai (x) | 0.7 | 0 | **sim** | sim | pai `p05.nav.scanner` (vaza) |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `p05.activity` |  | Atividade recente |  |
| `p05.activity.item1.icon` |  |  | aria-hidden=true |
| `p05.activity.item2.icon` |  |  | aria-hidden=true |
| `p05.activity.item3.icon` |  |  | aria-hidden=true |
| `p05.activity.item3.rating` |  | 4 de 5 estrelas |  |
| `p05.bottomFade` |  |  | aria-hidden=true |
| `p05.nav` |  | Navegação principal |  |
| `p05.nav.scanner` |  | Scanner: escanear livro |  |
| `p05.nav.scanner.icon` |  |  | aria-hidden=true |
| `p05.nav.profile` |  |  | aria-current=page |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `p05.activity.item1` | NeoBox |  |
| `p05.activity.item1.icon` | CircleIconButton / NeoBox circular |  |
| `p05.activity.item1.icon.art` | AppSvg(AppIconsInicio.pencilEdit, size: 18) |  |
| `p05.activity.item1.text.book` | TextSpan dentro do AppText.rich do pai |  |
| `p05.activity.item2` | NeoBox |  |
| `p05.activity.item2.icon` | CircleIconButton / NeoBox circular |  |
| `p05.activity.item2.icon.art` | AppSvg(AppIconsBiblioteca.highlighterBold, size: 18) |  |
| `p05.activity.item2.text.book` | TextSpan dentro do AppText.rich do pai |  |
| `p05.activity.item2.quote.highlight` | TextSpan dentro do AppText.rich do pai |  |
| `p05.activity.item3.icon` | CircleIconButton / NeoBox circular |  |
| `p05.activity.item3.icon.art` | AppSvg(AppIconsLeitor.check, size: 18) |  |
| `p05.activity.item3.text.book` | TextSpan dentro do AppText.rich do pai |  |
| `p05.activity.item3.rating.star1` | AppSvg(AppIconsPerfil.star, size: 15) |  |
| `p05.activity.item3.rating.star2` | AppSvg(AppIconsPerfil.star, size: 15) |  |
| `p05.activity.item3.rating.star3` | AppSvg(AppIconsPerfil.star, size: 15) |  |
| `p05.activity.item3.rating.star4` | AppSvg(AppIconsPerfil.star, size: 15) |  |
| `p05.activity.item3.rating.star5` | AppSvg(AppIconsPerfil.starCreme, size: 15) |  |
| `p05.bottomFade` | DecoratedBox(LinearGradient) |  |
| `p05.nav` | NeoBox |  |
| `p05.nav.home.icon` | AppSvg(AppIcons.navHome, size: 22) |  |
| `p05.nav.library.icon` | AppSvg(AppIcons.navLibrary, size: 22) |  |
| `p05.nav.scanner.fab` | CircleIconButton / NeoBox circular |  |
| `p05.nav.scanner.icon` | AppSvg(AppIcons.navScanner, size: 28) |  |
| `p05.nav.clubs.icon` | AppSvg(AppIcons.navClubs, size: 22) |  |
| `p05.nav.profile` | NeoBox |  |
| `p05.nav.profile.icon` | AppSvg(AppIcons.navProfileActive, size: 22) |  |

## Interações

- Item do desenho e do grifo → os grifos do livro (25, `/livro/:bookId/destaques`) no trecho, se a T17 decidir; o clube citado ("no clube Leitoras de Capitu") não é um link na prancha.
- Item da resenha → a Resenha aberta (74), da T20: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).
- Navegação: as abas do shell (Perfil marcado); o Scanner abre o scanner (`/scanner`).

## Dados

- A atividade = os últimos eventos da pessoa (grifo, desenho, livro terminado com a nota e a resenha), do mais novo ao mais velho, com o tempo relativo ("Hoje", "Ontem", "Há 3 dias"). Desenho e grifo vêm do banco local (os grifos do leitor); a resenha e a nota são da T20 — até lá, esse tipo de item segue a D-247. Quantos itens mostrar é pergunta da T17.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L05.1** Atividade recente: os três tipos de item
- **L05.2** Degradê e navegação com o Perfil marcado
- **L05.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('p05.activity', 'p05.bottomFade', 'p05.nav'), todos os ids de `kRef05.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/005_perfil_390x2510@3x.png` no recorte da fase (y 1978.69–2510) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef05w360` e `kRef05w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L05.1 Atividade recente: os três tipos de item
- [ ] L05.2 Degradê e navegação com o Perfil marcado
- [ ] L05.3 Verificação + relatório
- [ ] Geometria 46/46 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
