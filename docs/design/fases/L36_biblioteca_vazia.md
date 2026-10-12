# FASE L36 — Biblioteca vazia — a prateleira esperando o primeiro livro

> Tela 36 · prancha `036_biblioteca_vazia` (36 · Biblioteca vazia (primeiro livro), canvas 390×844) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L36_biblioteca_vazia@3x.png` · `docs/design/medicao/projeto/png/redline/L36_biblioteca_vazia_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/036_biblioteca_vazia_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_036_biblioteca_vazia.json` · `test/reference/projeto/reference_layout_036_biblioteca_vazia.dart` (`kRef36`).
> Arquivos sugeridos: `lib/features/library/presentation/empty_library.dart`, `lib/features/library/presentation/library_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Biblioteca vazia (36): sem nenhum livro, o título grande, a prateleira tracejada com o livro rosa "o seu aqui?", a frase "A estante está esperando o primeiro livro." e as ações — Escanear (amarelo, a principal), Buscar e E-book ou PDF. A navegação continua igual.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 42px; line-height: 0.98; letter-spacing: -1.4px;">Sua<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 50px; letter-spacing: -0.6px;">biblioteca.</span></h1>

<div role="img" aria-label="Uma prateleira vazia esperando livros" style="position: relative; margin: 26px auto 0; width: 300px; height: 190px;">
  <span style="position: absolute; left: 38px; bottom: 18px; width: 44px; height: 120px; border-radius: 4px 8px 8px 4px; border: 1.8px dashed #A69C8F; box-sizing: border-box; transform: rotate(0deg);"></span><span style="position: absolute; left: 88px; bottom: 18px; width: 40px; height: 104px; border-radius: 4px 8px 8px 4px; border: 1.8px dashed #A69C8F; box-sizing: border-box; transform: rotate(0deg);"></span><span style="position: absolute; left: 134px; bottom: 18px; width: 46px; height: 128px; border-radius: 4px 8px 8px 4px; border: 1.8px dashed #A69C8F; box-sizing: border-box; transform: rotate(0deg);"></span><span style="position: absolute; left: 186px; bottom: 18px; width: 40px; height: 98px; border-radius: 4px 8px 8px 4px; border: 1.8px dashed #A69C8F; box-sizing: border-box; transform: rotate(-10deg);"></span>
  <span style="position: absolute; left: 236px; bottom: 18px; width: 52px; height: 74px; border-radius: 4px 9px 9px 4px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; transform: rotate(-8deg); transform-origin: bottom left; display: flex; align-items: center; justify-content: center;">
    <svg width="36" height="36" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg></span>
  <span style="position: absolute; left: 200px; top: 10px; height: 26px; padding: 0 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 11.5px; font-weight: 800; transform: rotate(6deg); white-space: nowrap;">o seu aqui?</span>
  <span style="position: absolute; left: -6px; right: -6px; bottom: 2px; height: 16px; border-radius: 4px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box;"></span>
</div>

<h2 style="margin: 22px 0 0; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 26px; line-height: 1.02; letter-spacing: -0.6px;">A estante está esperando<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 30px;">o primeiro livro.</span></h2>

<p style="margin: 8px auto 0; max-width: 300px; text-align: center; font-size: 14.5px; font-weight: 600; line-height: 1.45; color: #5B544B;">Pegue um livro de papel aí perto e aponte a câmera para o código de barras no verso.</p>

<div style="margin-top: 18px; display: flex; flex-direction: column; gap: 10px;">
  <a href="#" style="height: 54px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; color: #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 15.5px; font-weight: 800;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16"></path><path d="M8 8v8M11 8v8M14 8v8M17 8v8"></path></svg><span style="color: #1A1714;">Escanear meu primeiro livro</span></a>
  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
    <a href="#" style="height: 50px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg>Buscar</a>
    <a href="#" style="height: 50px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"></path><path d="M14 3v5h5"></path><path d="M12 12v6M9.5 15.5 12 18l2.5-2.5"></path></svg>E-book ou PDF</a>
  </div>
</div>

<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 130px; background: linear-gradient(to top, #F7F0E3 55%, rgba(247,240,227,0));"></div>

<nav aria-label="Navegação principal" style="position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px;">
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Início</span>
  </a>
  <a href="#" aria-current="page" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="4" width="4.5" height="16" rx="1"></rect><rect x="10" y="4" width="4.5" height="16" rx="1"></rect><path d="m16.4 5.6 3.9-1 3.2 14.6-3.9 1z"></path></svg>
    <span style="font-size: 11px; font-weight: 800; letter-spacing: -0.2px;">Biblioteca</span>
  </a>
  <a href="#" aria-label="Scanner: escanear livro ou página" style="position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px;">
    <span style="position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3.5 8V6a2.5 2.5 0 0 1 2.5-2.5h2"></path><path d="M16 3.5h2A2.5 2.5 0 0 1 20.5 6v2"></path><path d="M20.5 16v2a2.5 2.5 0 0 1-2.5 2.5h-2"></path><path d="M8 20.5H6A2.5 2.5 0 0 1 3.5 18v-2"></path><path d="M8 8.5v7"></path><path d="M11 8.5v7"></path><path d="M13.5 8.5v7"></path><path d="M16 8.5v7"></path></svg>
    </span>
    <span style="font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px;">Scanner</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Clubes</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"></circle><path d="M4 21a8 8 0 0 1 16 0"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Perfil</span>
  </a>
</nav>
```

## Especificação pixel a pixel

Seção `b36.title` — retângulo absoluto no canvas 390×844: **x=20, y=62, w=350, h=90.16**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `b36.title` | text | 0 | 0 | 350 | 90.16 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 42px; line-height: 0.98; letter-spacing: -1.4px` | Bricolage (opsz 42) 42/41.16px peso 800 ls -1.4px #1A1714 |
| 2 | `b36.title.serif` ±1 | inline | 0 | 33.16 | 180.9 | 65 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 50px; letter-spacing: -0.6px` | Instrument Serif itálico 50/49px peso 400 ls -0.6px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b36.title` *(composto)* | 1 | Sua | 34.44 | 0 | 72.16 | 72.16 |
| `b36.title` *(composto)* | 2 | biblioteca. | 82.66 | 0 | 180.9 | 180.9 |

Seção `b36.illustration` — retângulo absoluto no canvas 390×844: **x=45, y=178.16, w=300, h=190**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `b36.illustration` | box | 0 | 0 | 300 | 190 | `position: relative; margin: 26px auto 0; width: 300px; height: 190px` |  |
| 4 | `b36.illustration.slot1` | box | 38 | 52 | 44 | 120 | `position: absolute; left: 38px; bottom: 18px; width: 44px; height: 120px; border-radius: 4px 8px 8px 4px; border: 1.8px dashed #A69C8F; box-sizing: border-box; transform: rotate(0deg)` |  |
| 5 | `b36.illustration.slot2` | box | 88 | 68 | 40 | 104 | `position: absolute; left: 88px; bottom: 18px; width: 40px; height: 104px; border-radius: 4px 8px 8px 4px; border: 1.8px dashed #A69C8F; box-sizing: border-box; transform: rotate(0deg)` |  |
| 6 | `b36.illustration.slot3` | box | 134 | 44 | 46 | 128 | `position: absolute; left: 134px; bottom: 18px; width: 46px; height: 128px; border-radius: 4px 8px 8px 4px; border: 1.8px dashed #A69C8F; box-sizing: border-box; transform: rotate(0deg)` |  |
| 7 | `b36.illustration.slot4` | box | 186 | 74 | 40 | 98 | `position: absolute; left: 186px; bottom: 18px; width: 40px; height: 98px; border-radius: 4px 8px 8px 4px; border: 1.8px dashed #A69C8F; box-sizing: border-box; transform: rotate(-10deg)` |  |
| 8 | `b36.illustration.book` | box | 236 | 98 | 52 | 74 | `position: absolute; left: 236px; bottom: 18px; width: 52px; height: 74px; border-radius: 4px 9px 9px 4px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; transform: rotate(-8deg); transform-origin: bottom left; display: flex; align-items: center; justify-content: center` |  |
| 9 | `b36.illustration.book.icon` | icon | 244 | 117 | 36 | 36 | `—` |  |
| 10 | `b36.illustration.tag` ±1 | box+text | 200 | 10 | 82.42 | 26 | `position: absolute; left: 200px; top: 10px; height: 26px; padding: 0 10px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 11.5px; font-weight: 800; transform: rotate(6deg); white-space: nowrap` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 11 | `b36.illustration.plank` | box | -6 | 172 | 312 | 16 | `position: absolute; left: -6px; right: -6px; bottom: 2px; height: 16px; border-radius: 4px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `b36.illustration.slot4`: caixa visual com `transform: rotate(-10deg)` = x 177.79, y 71.27, w 56.41, h 103.46 (relativa à seção).
- `b36.illustration.book`: caixa visual com `transform: rotate(-8deg)` = x 225.7, y 91.48, w 61.79, h 80.52 (relativa à seção).
- `b36.illustration.book.icon`: caixa visual deslocada pelo transform de um ancestral = x 236.27, y 111.41, w 40.66, h 40.66 (relativa à seção).
- `b36.illustration.tag`: caixa visual com `transform: rotate(6deg)` = x 198.87, y 5.76, w 84.69, h 34.47 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b36.illustration.tag` | 1 | o seu aqui? | 27.03 | 211.5 | 270.92 | 59.42 |

Seção `b36.heading` — retângulo absoluto no canvas 390×844: **x=20, y=390.16, w=350, h=57.12**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 12 | `b36.heading` | text | 0 | 0 | 350 | 57.12 | `margin: 22px 0 0; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 26px; line-height: 1.02; letter-spacing: -0.6px` | Bricolage (opsz 26) 26/26.52px peso 800 ls -0.6px #1A1714 |
| 13 | `b36.heading.serif` ±1 | inline | 91.63 | 22.32 | 166.74 | 39 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 30px` | Instrument Serif itálico 30/30.6px peso 400 ls -0.6px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b36.heading` *(composto)* | 1 | A estante está esperando | 21.84 | 20.57 | 329.43 | 308.86 |
| `b36.heading` *(composto)* | 2 | o primeiro livro. | 52.02 | 91.63 | 258.37 | 166.74 |

Seção `b36.body` — retângulo absoluto no canvas 390×844: **x=45, y=455.28, w=300, h=42.05**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 14 | `b36.body` | text | 0 | 0 | 300 | 42.05 | `margin: 8px auto 0; max-width: 300px; text-align: center; font-size: 14.5px; font-weight: 600; line-height: 1.45; color: #5B544B` | Figtree 14.5/21.025px peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b36.body` | 1 | Pegue um livro de papel aí perto e aponte a | 15.58 | 7.95 | 292.05 | 284.1 |
| `b36.body` | 2 | câmera para o código de barras no verso. | 36.6 | 14.97 | 285.03 | 270.06 |

Seção `b36.actions` — retângulo absoluto no canvas 390×844: **x=20, y=515.33, w=350, h=114**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 15 | `b36.actions` | box | 0 | 0 | 350 | 114 | `margin-top: 18px; display: flex; flex-direction: column; gap: 10px` |  |
| 16 | `b36.actions.scan` | box | 0 | 0 | 350 | 54 | `height: 54px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; color: #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 15.5px; font-weight: 800` |  |
| 17 | `b36.actions.scan.icon` ±1 | icon | 59.72 | 17 | 20 | 20 | `—` |  |
| 18 | `b36.actions.scan.label` ±1 | text | 88.72 | 17.69 | 201.56 | 18.61 | `color: #1A1714` | Figtree 15.5/normal peso 800 ls normal #1A1714 |
| 19 | `b36.actions.row` | box | 0 | 64 | 350 | 50 | `display: grid; grid-template-columns: 1fr 1fr; gap: 10px` |  |
| 20 | `b36.actions.search` | box+text | 0 | 64 | 170 | 50 | `height: 50px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 21 | `b36.actions.search.icon` ±1 | icon | 50.44 | 80 | 18 | 18 | `—` |  |
| 22 | `b36.actions.ebook` | box+text | 180 | 64 | 170 | 50 | `height: 50px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 23 | `b36.actions.ebook.icon` ±1 | icon | 204.77 | 80 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b36.actions.scan.label` | 1 | Escanear meu primeiro livro | 32.42 | 88.72 | 290.28 | 201.56 |
| `b36.actions.search` | 1 | Buscar | 93.9 | 75.44 | 119.56 | 44.12 |
| `b36.actions.ebook` | 1 | E-book ou PDF | 93.9 | 229.77 | 325.23 | 95.46 |

Seção `b36.bottomFade` — retângulo absoluto no canvas 390×844: **x=0, y=714, w=390, h=130**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 24 | `b36.bottomFade` | box | 0 | 0 | 390 | 130 | `position: absolute; left: 0; right: 0; bottom: 0; height: 130px; background: linear-gradient(to top, #F7F0E3 55%, rgba(247,240,227,0))` |  |

Seção `b36.nav` — retângulo absoluto no canvas 390×844: **x=16, y=744, w=358, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 25 | `b36.nav` | box | 0 | 0 | 358 | 70 | `position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px` |  |
| 26 | `b36.nav.home` | box | 9.5 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 27 | `b36.nav.home.icon` | icon | 30.8 | 15.9 | 22 | 22 | `—` |  |
| 28 | `b36.nav.home.label` ±1 | text | 28.21 | 40.9 | 27.18 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 29 | `b36.nav.library` | box | 78.1 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 30 | `b36.nav.library.icon` | icon | 99.4 | 15.9 | 22 | 22 | `—` |  |
| 31 | `b36.nav.library.label` ±1 | text | 85.8 | 40.9 | 49.2 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: -0.2px` | Figtree 11/normal peso 800 ls -0.2px #1A1714 |
| 32 | `b36.nav.scanner` | box | 146.7 | 9.5 | 64.6 | 51 | `position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px` |  |
| 33 | `b36.nav.scanner.fab` | box | 149 | -20.5 | 60 | 60 | `position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 34 | `b36.nav.scanner.icon` | icon | 165 | -4.5 | 28 | 28 | `—` |  |
| 35 | `b36.nav.scanner.label` ±1 | text | 158.35 | 45.3 | 41.3 | 15.2 | `font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px` | Figtree 11/normal peso 700 ls normal #1A1714 |
| 36 | `b36.nav.clubs` | box | 215.3 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 37 | `b36.nav.clubs.icon` | icon | 236.6 | 15.9 | 22 | 22 | `—` |  |
| 38 | `b36.nav.clubs.label` ±1 | text | 230.37 | 40.9 | 34.45 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 39 | `b36.nav.profile` | box | 283.9 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 40 | `b36.nav.profile.icon` | icon | 305.2 | 15.9 | 22 | 22 | `—` |  |
| 41 | `b36.nav.profile.label` ±1 | text | 303.18 | 40.9 | 26.05 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b36.nav.home.label` | 1 | Início | 51.35 | 28.21 | 55.39 | 27.18 |
| `b36.nav.library.label` | 1 | Biblioteca | 51.35 | 85.8 | 135 | 49.2 |
| `b36.nav.scanner.label` | 1 | Scanner | 55.75 | 158.35 | 199.65 | 41.3 |
| `b36.nav.clubs.label` | 1 | Clubes | 51.35 | 230.37 | 264.83 | 34.46 |
| `b36.nav.profile.label` | 1 | Perfil | 51.35 | 303.18 | 329.22 | 26.04 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Título em 2 linhas (não é o da 02): "Sua" Bricolage 42/800 `lh 0,98` ls −1,4, quebra, e "biblioteca." Instrument Serif itálico 50 ls −0,6 — a composição do título da Início.
2. Desenho 300 × 190, centrado, 26 abaixo (`role=img`, "Uma prateleira vazia esperando livros"): 4 lugares tracejados (borda 1,8 `dashed #A69C8F`, raio 4/8/8/4, alturas 120, 104, 128 e 98, o 4º girado −10°), o livro rosa 52 × 74 (`#FFC1C6`, sombra 3/3, girado −8° pela base esquerda) com a estrela 36 `#FED170`, a pílula "o seu aqui?" 11,5/800 girada 6° e a tábua de 16 (`left/right −6`, sombra 0/4).
3. Frase: Bricolage 26/800 `lh 1,02` ls −0,6, centrada, e "o primeiro livro." Instrument Serif itálico 30; o texto 14,5/600 `lh 1,45` `#5B544B`, `max-width 300`, 8 abaixo.
4. Ações (coluna, gap 10, 18 abaixo): "Escanear meu primeiro livro" com 54 de altura, `#FED170`, sombra 3/3, ícone 20 + 15,5/800; embaixo, duas pílulas de 50 lado a lado (`1fr 1fr`, gap 10), `#FFFAF1`, sem sombra, ícone 18 + 14/800: Buscar e E-book ou PDF.
5. Degradê de 130, de baixo para cima (`#F7F0E3` até 55 %), e a navegação igual à da 02 (Biblioteca ativa).
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O tracejado dos lugares é `border: dashed` do CSS (o navegador escolhe o traço pela borda de 1,8): no app, um pintor de borda tracejada com o padrão medido na referência @3x — não é um SVG (os tracejados do catálogo, D-285, são outros).
- O livro rosa gira pela base esquerda (`transform-origin: bottom left`) e a pílula pelo centro: a tabela traz as caixas sem o giro.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_036_biblioteca_vazia_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_036_biblioteca_vazia_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `b36.nav.scanner.fab` | passa do pai (x) | 0.7 | 0 | **sim** | sim | pai `b36.nav.scanner` (vaza) |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `b36.illustration` | img | Uma prateleira vazia esperando livros |  |
| `b36.illustration.book.icon` |  |  | aria-hidden=true |
| `b36.actions.scan.icon` |  |  | aria-hidden=true |
| `b36.actions.search.icon` |  |  | aria-hidden=true |
| `b36.actions.ebook.icon` |  |  | aria-hidden=true |
| `b36.bottomFade` |  |  | aria-hidden=true |
| `b36.nav` |  | Navegação principal |  |
| `b36.nav.library` |  |  | aria-current=page |
| `b36.nav.scanner` |  | Scanner: escanear livro ou página |  |
| `b36.nav.scanner.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `b36.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `b36.illustration.slot1` | NeoBox | Transform: rotate(0deg) |
| `b36.illustration.slot2` | NeoBox | Transform: rotate(0deg) |
| `b36.illustration.slot3` | NeoBox | Transform: rotate(0deg) |
| `b36.illustration.slot4` | NeoBox | Transform: rotate(-10deg) |
| `b36.illustration.book` | NeoBox | Transform: rotate(-8deg) |
| `b36.illustration.book.icon` | AppSvg(AppIconsInicio.sparkleYellow, size: 36) |  |
| `b36.illustration.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) | Transform: rotate(6deg) |
| `b36.illustration.plank` | NeoBox |  |
| `b36.heading.serif` | TextSpan dentro do AppText.rich do pai |  |
| `b36.actions.scan` | NeoBox |  |
| `b36.actions.scan.icon` | AppSvg(AppIconsBiblioteca.scanBarcode, size: 20) |  |
| `b36.actions.search` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b36.actions.search.icon` | AppSvg(AppIconsLeitor.search, size: 18) |  |
| `b36.actions.ebook` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b36.actions.ebook.icon` | AppSvg(AppIconsBiblioteca.fileDownload, size: 18) |  |
| `b36.bottomFade` | DecoratedBox(LinearGradient) |  |
| `b36.nav` | NeoBox |  |
| `b36.nav.home.icon` | AppSvg(AppIcons.navHome, size: 22) |  |
| `b36.nav.library` | NeoBox |  |
| `b36.nav.library.icon` | AppSvg(AppIcons.navLibraryActive, size: 22) |  |
| `b36.nav.scanner.fab` | CircleIconButton / NeoBox circular |  |
| `b36.nav.scanner.icon` | AppSvg(AppIcons.navScanner, size: 28) |  |
| `b36.nav.clubs.icon` | AppSvg(AppIcons.navClubs, size: 22) |  |
| `b36.nav.profile.icon` | AppSvg(AppIcons.navProfile, size: 22) |  |

## Interações

- Escanear meu primeiro livro → o Scanner (`/scanner`); a tela nova do Scanner é da T15.
- Buscar → a Busca (28), da T15: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T14 (ROTEIRO §2b).
- E-book ou PDF → o importar que já existe (o seletor de arquivos da G09, D-21 e D-87).
- Navegação: como na 02.

## Dados

- A tela aparece quando a estante não tem nenhum livro (nenhum `user_book`) e some sozinha quando o primeiro entra.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L36.1** Estado vazio no lugar da estante
- **L36.2** Prateleira tracejada e o livro "o seu aqui?"
- **L36.3** Frase e ações
- **L36.4** Degradê e navegação
- **L36.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('b36.title', 'b36.illustration', 'b36.heading', 'b36.body', 'b36.actions', 'b36.bottomFade', 'b36.nav'), todos os ids de `kRef36.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/036_biblioteca_vazia_390x844@3x.png` no recorte da fase (y 54–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef36w360` e `kRef36w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L36.1 Estado vazio no lugar da estante
- [ ] L36.2 Prateleira tracejada e o livro "o seu aqui?"
- [ ] L36.3 Frase e ações
- [ ] L36.4 Degradê e navegação
- [ ] L36.5 Verificação + relatório
- [ ] Geometria 39/39 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
