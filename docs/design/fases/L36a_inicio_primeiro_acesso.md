# FASE L36a — Início no primeiro acesso — o cartão do primeiro livro, a meta de hoje e o convite de clube

> Tela 36a · prancha `036a_inicio_primeiro_acesso` (36a · Início — primeiro acesso (estante vazia), canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L36a_inicio_primeiro_acesso@3x.png` · `docs/design/medicao/projeto/png/redline/L36a_inicio_primeiro_acesso_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/036a_inicio_primeiro_acesso_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_036a_inicio_primeiro_acesso.json` · `test/reference/projeto/reference_layout_036a_inicio_primeiro_acesso.dart` (`kRef36a`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/first_book_card.dart`, `lib/features/home/presentation/sections/first_day_goal_card.dart`, `lib/features/home/presentation/sections/club_invite_entry.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A Início no primeiro acesso (36a), quando a estante ainda está vazia: o cabeçalho (lupa e sino), "Sua história começa aqui.", o cartão lavanda "Coloque seu primeiro livro na estante" com Montar minha estante e os atalhos, a meta de hoje (0 de 30 min) e a entrada do convite de clube.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<header style="display: flex; align-items: center; justify-content: space-between; height: 48px;">
  <div style="display: flex; align-items: center; gap: 12px;">
    <div style="width: 44px; height: 44px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px;">M</div>
    <div style="display: flex; flex-direction: column; gap: 1px;"><span style="font-size: 13px; font-weight: 500; color: #5B544B;">Boa noite,</span><span style="font-size: 16px; font-weight: 700;">Marina</span></div>
  </div>
  <div style="display: flex; gap: 8px;">
    <a href="#" aria-label="Buscar livros" style="width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg></a>
    <button aria-label="Notificações" style="width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 8a6 6 0 1 1 12 0c0 7 3 9 3 9H3s3-2 3-9"></path><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"></path></svg></button>
  </div>
</header>

<h1 style="margin: 18px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 38px; line-height: 0.98; letter-spacing: -1.2px;">Sua história<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.5px;">começa aqui.</span></h1>

<!-- first book: the card is the way into the Biblioteca -->
<section aria-label="Adicionar o primeiro livro" style="position: relative; margin-top: 18px; padding: 16px; border-radius: 28px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; overflow: hidden;">
  <div aria-hidden="true" style="position: absolute; right: 8px; top: 10px; width: 130px; height: 110px;"><span style="position: absolute; left: 16px; bottom: 12px; width: 30px; height: 78px; border-radius: 3px 6px 6px 3px; border: 1.6px dashed rgba(26,23,20,0.45); box-sizing: border-box;"></span><span style="position: absolute; left: 50px; bottom: 12px; width: 26px; height: 66px; border-radius: 3px 6px 6px 3px; border: 1.6px dashed rgba(26,23,20,0.45); box-sizing: border-box;"></span><span style="position: absolute; left: 80px; bottom: 12px; width: 32px; height: 86px; border-radius: 3px 6px 6px 3px; border: 1.6px dashed rgba(26,23,20,0.45); box-sizing: border-box;"></span>
    <span style="position: absolute; left: 4px; right: 4px; bottom: 4px; height: 10px; border-radius: 3px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box;"></span>
    <svg width="26" height="26" viewBox="0 0 24 24" style="position: absolute; right: 2px; top: 8px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>
  </div>
  <span style="display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #3B3466;">PRIMEIRO PASSO</span>
  <h2 style="margin: 6px 0 0; max-width: 190px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 25px; line-height: 1.02; letter-spacing: -0.6px;">Coloque seu primeiro livro na estante</h2>
  <p style="margin: 8px 0 0; max-width: 200px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #2F2A4A;">De papel? É só escanear.</p>
  <a href="#" style="margin-top: 16px; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 15.5px; font-weight: 800;"><span style="color: #F7F0E3;">Montar minha estante</span><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg></a>
  <div style="margin-top: 10px; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px;">
    <a href="#" style="height: 44px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 800;"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16"></path><path d="M8 8v8M11 8v8M14 8v8M17 8v8"></path></svg>Escanear</a>
    <a href="#" style="height: 44px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 800;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg>Buscar</a>
    <a href="#" style="height: 44px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 800;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"></path><path d="M14 3v5h5"></path><path d="M12 12v6M9.5 15.5 12 18l2.5-2.5"></path></svg>E-book</a>
  </div>
</section>

<!-- daily goal, still empty -->
<section aria-label="Seu dia de leitura" style="margin-top: 16px; padding: 14px 16px; border-radius: 24px; background: #FED170; border: 1.5px solid #1A1714; display: flex; align-items: center; gap: 14px;">
  <svg width="58" height="58" viewBox="0 0 58 58" aria-hidden="true" style="flex-shrink: 0;"><circle cx="29" cy="29" r="27" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5"></circle><circle cx="29" cy="29" r="20" fill="none" stroke="#1A1714" stroke-width="2" stroke-dasharray="1.5 5" opacity="0.4"></circle><text x="29" y="34" text-anchor="middle" font-family="'Bricolage Grotesque', sans-serif" font-weight="800" font-size="15" fill="#1A1714">0</text></svg>
  <span style="min-width: 0; flex-grow: 1;"><span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px;">Meta de hoje: 30 min</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #4A3C17;">O cronômetro começa assim que o primeiro livro estiver na estante.</span></span>
</section>

<!-- club -->
<a href="#" style="margin-top: 12px; padding: 12px 14px; border-radius: 22px; border: 1.5px dashed #1A1714; display: flex; align-items: center; gap: 12px;">
  <span style="width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg></span>
  <span style="min-width: 0; flex-grow: 1;"><span style="display: block; font-size: 14.5px; font-weight: 800;">Recebeu um convite de clube?</span><span style="display: block; font-size: 12.5px; font-weight: 600; color: #6F665B;">Cole o link ou leia o QR code</span></span>
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
</a>
```

## Especificação pixel a pixel

Seção `e36a.header` — retângulo absoluto no canvas 390×844: **x=20, y=62, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e36a.header` | box | 0 | 0 | 350 | 48 | `display: flex; align-items: center; justify-content: space-between; height: 48px` |  |
| 2 | `e36a.header.identity` ±1 | box | 0 | 2 | 114.43 | 44 | `display: flex; align-items: center; gap: 12px` |  |
| 3 | `e36a.header.avatar` | box+text | 0 | 2 | 44 | 44 | `width: 44px; height: 44px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px` | Bricolage (opsz 18) 18/normal peso 800 ls normal #1A1714 |
| 4 | `e36a.header.greetingColumn` ±1 | box | 56 | 6.1 | 58.43 | 35.8 | `display: flex; flex-direction: column; gap: 1px` |  |
| 5 | `e36a.header.greeting` ±1 | text | 56 | 6.1 | 58.43 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 6 | `e36a.header.name` ±1 | text | 56 | 22.7 | 58.43 | 19.2 | `font-size: 16px; font-weight: 700` | Figtree 16/normal peso 700 ls normal #1A1714 |
| 7 | `e36a.header.actions` | box | 246 | 0 | 104 | 48 | `display: flex; gap: 8px` |  |
| 8 | `e36a.header.search` | box | 246 | 0 | 48 | 48 | `width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 9 | `e36a.header.search.icon` | icon | 259 | 13 | 22 | 22 | `—` |  |
| 10 | `e36a.header.bell` | box | 302 | 0 | 48 | 48 | `width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 11 | `e36a.header.bell.icon` | icon | 315 | 13 | 22 | 22 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e36a.header.avatar` | 1 | M | 29.94 | 13.47 | 30.53 | 17.06 |
| `e36a.header.greeting` | 1 | Boa noite, | 18.45 | 56 | 114.43 | 58.43 |
| `e36a.header.name` | 1 | Marina | 37.9 | 56 | 106.11 | 50.11 |

Seção `e36a.headline` — retângulo absoluto no canvas 390×844: **x=20, y=128, w=350, h=82.32**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 12 | `e36a.headline` | text | 0 | 0 | 350 | 82.32 | `margin: 18px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 38px; line-height: 0.98; letter-spacing: -1.2px` | Bricolage (opsz 38) 38/37.24px peso 800 ls -1.2px #1A1714 |
| 13 | `e36a.headline.serif` ±1 | inline | 0 | 29.88 | 213.28 | 59.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.5px` | Instrument Serif itálico 46/45.08px peso 400 ls -0.5px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e36a.headline` *(composto)* | 1 | Sua história | 31.16 | 0 | 203.95 | 203.95 |
| `e36a.headline` *(composto)* | 2 | começa aqui. | 75.42 | 0 | 213.28 | 213.28 |

Seção `e36a.firstBook` — retângulo absoluto no canvas 390×844: **x=20, y=228.32, w=350, h=281.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 14 | `e36a.firstBook` | box | 0 | 0 | 350 | 281.6 | `position: relative; margin-top: 18px; padding: 16px; border-radius: 28px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; overflow: hidden` |  |
| 15 | `e36a.firstBook.illustration` | box | 210.5 | 11.5 | 130 | 110 | `position: absolute; right: 8px; top: 10px; width: 130px; height: 110px` |  |
| 16 | `e36a.firstBook.illustration.slot1` | box | 226.5 | 31.5 | 30 | 78 | `position: absolute; left: 16px; bottom: 12px; width: 30px; height: 78px; border-radius: 3px 6px 6px 3px; border: 1.6px dashed rgba(26,23,20,0.45); box-sizing: border-box` |  |
| 17 | `e36a.firstBook.illustration.slot2` | box | 260.5 | 43.5 | 26 | 66 | `position: absolute; left: 50px; bottom: 12px; width: 26px; height: 66px; border-radius: 3px 6px 6px 3px; border: 1.6px dashed rgba(26,23,20,0.45); box-sizing: border-box` |  |
| 18 | `e36a.firstBook.illustration.slot3` | box | 290.5 | 23.5 | 32 | 86 | `position: absolute; left: 80px; bottom: 12px; width: 32px; height: 86px; border-radius: 3px 6px 6px 3px; border: 1.6px dashed rgba(26,23,20,0.45); box-sizing: border-box` |  |
| 19 | `e36a.firstBook.illustration.plank` | box | 214.5 | 107.5 | 122 | 10 | `position: absolute; left: 4px; right: 4px; bottom: 4px; height: 10px; border-radius: 3px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 20 | `e36a.firstBook.illustration.sparkle` | icon | 312.5 | 19.5 | 26 | 26 | `position: absolute; right: 2px; top: 8px` |  |
| 21 | `e36a.firstBook.kicker` | text | 17.5 | 17.5 | 315 | 13.2 | `display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #3B3466` | Figtree 11/normal peso 800 ls 1.2px #3B3466 |
| 22 | `e36a.firstBook.title` | text | 17.5 | 36.7 | 190 | 76.5 | `margin: 6px 0 0; max-width: 190px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 25px; line-height: 1.02; letter-spacing: -0.6px` | Bricolage (opsz 25) 25/25.5px peso 800 ls -0.6px #1A1714 |
| 23 | `e36a.firstBook.body` | text | 17.5 | 121.2 | 200 | 18.9 | `margin: 8px 0 0; max-width: 200px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #2F2A4A` | Figtree 13.5/18.9px peso 600 ls normal #2F2A4A |
| 24 | `e36a.firstBook.cta` | box | 17.5 | 156.1 | 315 | 54 | `margin-top: 16px; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 15.5px; font-weight: 800` |  |
| 25 | `e36a.firstBook.cta.label` ±1 | text | 82.05 | 173.8 | 157.9 | 18.61 | `color: #F7F0E3` | Figtree 15.5/normal peso 800 ls normal #F7F0E3 |
| 26 | `e36a.firstBook.cta.icon` ±1 | icon | 248.95 | 173.6 | 19 | 19 | `—` |  |
| 27 | `e36a.firstBook.shortcuts` | box | 17.5 | 220.1 | 315 | 44 | `margin-top: 10px; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px` |  |
| 28 | `e36a.firstBook.shortcuts.scan` | box+text | 17.5 | 220.1 | 99.67 | 44 | `height: 44px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 29 | `e36a.firstBook.shortcuts.scan.icon` ±1 | icon | 28.37 | 233.6 | 17 | 17 | `—` |  |
| 30 | `e36a.firstBook.shortcuts.search` | box+text | 125.17 | 220.1 | 99.67 | 44 | `height: 44px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 31 | `e36a.firstBook.shortcuts.search.icon` ±1 | icon | 143.52 | 234.1 | 16 | 16 | `—` |  |
| 32 | `e36a.firstBook.shortcuts.ebook` | box+text | 232.83 | 220.1 | 99.67 | 44 | `height: 44px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 33 | `e36a.firstBook.shortcuts.ebook.icon` ±1 | icon | 250.11 | 234.1 | 16 | 16 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e36a.firstBook.kicker` | 1 | PRIMEIRO PASSO | 27.95 | 17.5 | 126 | 108.5 |
| `e36a.firstBook.title` | 1 | Coloque seu | 57.7 | 17.5 | 160.57 | 143.07 |
| `e36a.firstBook.title` | 2 | primeiro livro | 83.2 | 17.5 | 174.25 | 156.75 |
| `e36a.firstBook.title` | 3 | na estante | 108.7 | 17.5 | 140.62 | 123.12 |
| `e36a.firstBook.body` | 1 | De papel? É só escanear. | 135.37 | 17.5 | 168.43 | 150.93 |
| `e36a.firstBook.cta.label` | 1 | Montar minha estante | 188.53 | 82.05 | 239.95 | 157.9 |
| `e36a.firstBook.shortcuts.scan` | 1 | Escanear | 246.65 | 51.37 | 106.3 | 54.93 |
| `e36a.firstBook.shortcuts.search` | 1 | Buscar | 246.65 | 165.52 | 206.48 | 40.96 |
| `e36a.firstBook.shortcuts.ebook` | 1 | E-book | 246.65 | 272.11 | 315.23 | 43.12 |

Seção `e36a.today` — retângulo absoluto no canvas 390×844: **x=20, y=525.92, w=350, h=89**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 34 | `e36a.today` | box | 0 | 0 | 350 | 89 | `margin-top: 16px; padding: 14px 16px; border-radius: 24px; background: #FED170; border: 1.5px solid #1A1714; display: flex; align-items: center; gap: 14px` |  |
| 35 | `e36a.today.ring` | icon | 17.5 | 15.5 | 58 | 58 | `flex-shrink: 0` |  |
| 36 | `e36a.today.textBlock` | box | 89.5 | 16.43 | 243 | 56.15 | `min-width: 0; flex-grow: 1` |  |
| 37 | `e36a.today.title` | text | 89.5 | 16.43 | 243 | 20.4 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px` | Bricolage (opsz 17) 17/normal peso 800 ls -0.3px #1A1714 |
| 38 | `e36a.today.body` | text | 89.5 | 38.83 | 243 | 33.75 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #4A3C17` | Figtree 12.5/16.875px peso 600 ls normal #4A3C17 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e36a.today.title` | 1 | Meta de hoje: 30 min | 32.23 | 89.5 | 256.9 | 167.4 |
| `e36a.today.body` | 1 | O cronômetro começa assim que o | 51.63 | 89.5 | 287.4 | 197.9 |
| `e36a.today.body` | 2 | primeiro livro estiver na estante. | 68.51 | 89.5 | 272.07 | 182.57 |

Seção `e36a.club` — retângulo absoluto no canvas 390×844: **x=20, y=626.92, w=350, h=71**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 39 | `e36a.club` | box | 0 | 0 | 350 | 71 | `margin-top: 12px; padding: 12px 14px; border-radius: 22px; border: 1.5px dashed #1A1714; display: flex; align-items: center; gap: 12px` |  |
| 40 | `e36a.club.badge` | box | 15.5 | 13.5 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 41 | `e36a.club.badge.icon` | icon | 26.5 | 24.5 | 22 | 22 | `—` |  |
| 42 | `e36a.club.textBlock` | box | 71.5 | 19.29 | 233 | 32.42 | `min-width: 0; flex-grow: 1` |  |
| 43 | `e36a.club.title` | text | 71.5 | 19.29 | 233 | 17.41 | `display: block; font-size: 14.5px; font-weight: 800` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 44 | `e36a.club.body` | text | 71.5 | 36.7 | 233 | 15.01 | `display: block; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 45 | `e36a.club.chevron` | icon | 316.5 | 26.5 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e36a.club.title` | 1 | Recebeu um convite de clube? | 33.07 | 71.5 | 276.81 | 205.31 |
| `e36a.club.body` | 1 | Cole o link ou leia o QR code | 48.58 | 71.5 | 232.78 | 161.28 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cabeçalho da Início (48): o avatar 44 "M", "Boa noite," 13/500 + "Marina" 16/700, a lupa e o sino 48 (sem o ponto). Título 18 abaixo: Bricolage 38/800 `lh 0,98` ls −1,2 + "começa aqui." Instrument Serif 46.
2. Cartão 18 abaixo: padding 16, raio 28, `#B6ACE4`, sombra 4/4, `overflow: hidden`; o desenho 130 × 110 em `right 8 · top 10` (3 lombadas tracejadas a 45 %, a tábua amarela e a estrela creme); "PRIMEIRO PASSO" 11/800 ls 1,2 `#3B3466`; o título Bricolage 25/800 `max-width 190`; o texto 13,5/600 `#2F2A4A`.
3. "Montar minha estante" 54, preto, 16 abaixo; os 3 atalhos de 44 (grade de 3, gap 8): Escanear `#FED170`, Buscar e E-book `#FFFAF1`, ícones 16–17 + 13/800.
4. Meta de hoje, 16 abaixo: padding 14/16, raio 24, `#FED170`, sem sombra; o anel 58 com as marcas (`dasharray 1,5 5` a 0,4) e o "0"; "Meta de hoje: 30 min" Bricolage 17/800 + o texto 12,5/600 `#4A3C17`.
5. Convite, 12 abaixo: padding 12/14, raio 22, borda 1,5 `dashed`, o quadrado 44 rosa (raio 14) com as pessoas, "Recebeu um convite de clube?" 14,5/800 + "Cole o link ou leia o QR code" 12,5/600 e a seta 18.
6. A navegação com a aba Início ativa (a tabela "Diferenças" da 36: os rótulos de Início e Biblioteca trocam de peso).
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- Na navegação, os rótulos de Início e Biblioteca trocam de largura (a aba marcada vai em 800 com ls −0,2): não fixar a largura dos rótulos.
- O "0" do anel é `<text>` (Bricolage 15/800): `AppText` (o mapa de widgets).
- A 360 o desenho do cartão invade o título (27, abaixo): o título tem `max-width 190` e o desenho é fixo.
- Fio de navalha em `e36a.firstBook.title` linha 2 «primeiro livro»: sobra 33.25 px · estouro com a próxima palavra 0.95 px.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_036a_inicio_primeiro_acesso_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_036a_inicio_primeiro_acesso_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `e36a.firstBook.illustration` | invade o vizinho (x) | 27 | 0 | **sim** | sim | vizinho `e36a.firstBook.title` |

- A 360: fio de navalha em `e36a.firstBook.title` linha 2 «primeiro livro»: sobra 33.25 px · estouro com a próxima palavra 0.95 px.
- A 430: fio de navalha em `e36a.firstBook.title` linha 2 «primeiro livro»: sobra 33.25 px · estouro com a próxima palavra 0.95 px.

## Diferenças em relação à prancha 36 (seções reutilizadas: bottomFade, nav)

Estas seções são as mesmas widgets da 36 (fases L36_biblioteca_vazia); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `e36a.nav.home` | bg: null → "#B6ACE4"; border: null → "1.5px solid #1A1714" |
| `e36a.nav.home.label` | retângulo ['44.21', '784.9', '27.18', '13.2'] → ['43.76', '784.9', '28.07', '13.2']; fonte color: #5B544B → #1A1714; weightCss: 600 → 800; weightRendered: 600 → 800 |
| `e36a.nav.library` | bg: "#B6ACE4" → null; border: "1.5px solid #1A1714" → null |
| `e36a.nav.library.label` | retângulo ['101.8', '784.9', '49.2', '13.2'] → ['101.5', '784.9', '49.79', '13.2']; fonte color: #1A1714 → #5B544B; letterSpacing: -0.2px → normal; weightCss: 800 → 600; weightRendered: 800 → 600 |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e36a.header.search` |  | Buscar livros |  |
| `e36a.header.search.icon` |  |  | aria-hidden=true |
| `e36a.header.bell` |  | Notificações |  |
| `e36a.header.bell.icon` |  |  | aria-hidden=true |
| `e36a.firstBook` |  | Adicionar o primeiro livro |  |
| `e36a.firstBook.illustration` |  |  | aria-hidden=true |
| `e36a.firstBook.cta.icon` |  |  | aria-hidden=true |
| `e36a.firstBook.shortcuts.scan.icon` |  |  | aria-hidden=true |
| `e36a.firstBook.shortcuts.search.icon` |  |  | aria-hidden=true |
| `e36a.firstBook.shortcuts.ebook.icon` |  |  | aria-hidden=true |
| `e36a.today` |  | Seu dia de leitura |  |
| `e36a.today.ring` |  |  | aria-hidden=true |
| `e36a.club.badge.icon` |  |  | aria-hidden=true |
| `e36a.club.chevron` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e36a.header.avatar` | CircleIconButton / NeoBox circular |  |
| `e36a.header.search` | CircleIconButton / NeoBox circular |  |
| `e36a.header.search.icon` | AppSvg(AppIconsInicio.search, size: 22) |  |
| `e36a.header.bell` | CircleIconButton / NeoBox circular |  |
| `e36a.header.bell.icon` | AppSvg(AppIcons.bell, size: 22) |  |
| `e36a.headline.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e36a.firstBook` | NeoBox |  |
| `e36a.firstBook.illustration.slot1` | NeoBox |  |
| `e36a.firstBook.illustration.slot2` | NeoBox |  |
| `e36a.firstBook.illustration.slot3` | NeoBox |  |
| `e36a.firstBook.illustration.plank` | NeoBox |  |
| `e36a.firstBook.illustration.sparkle` | AppSvg(AppIconsBiblioteca.sparkleCreme, size: 26) |  |
| `e36a.firstBook.cta` | NeoBox |  |
| `e36a.firstBook.cta.icon` | AppSvg(AppIconsScanner.arrowNextPapel, size: 19) |  |
| `e36a.firstBook.shortcuts.scan` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e36a.firstBook.shortcuts.scan.icon` | AppSvg(AppIconsScanner.scanBarcodeBusca, size: 17) |  |
| `e36a.firstBook.shortcuts.search` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e36a.firstBook.shortcuts.search.icon` | AppSvg(AppIconsLeitor.search, size: 16) |  |
| `e36a.firstBook.shortcuts.ebook` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e36a.firstBook.shortcuts.ebook.icon` | AppSvg(AppIconsBiblioteca.fileDownload, size: 16) |  |
| `e36a.today` | NeoBox |  |
| `e36a.today.ring` | CustomPainter (anel_hoje_primeiro_acesso) | stroke-dasharray = progresso (as marcas, dasharray 1,5 5): anel desenhado por CustomPainter com o valor real; o SVG é a referência do estado da prancha. O "0" (minutos de hoje) é `<text>` Bricolage 800 15: AppText. |
| `e36a.club` | NeoBox |  |
| `e36a.club.badge` | NeoBox |  |
| `e36a.club.badge.icon` | AppSvg(AppIconsScanner.peopleAvatar, size: 22) |  |
| `e36a.club.chevron` | AppSvg(AppIconsBiblioteca.chevronRightClube, size: 18) |  |

## Interações

- Montar minha estante → a Biblioteca (a 36, vazia); Escanear → o Scanner; Buscar → a Busca (28); E-book → o importar.
- Lupa → a Busca (28, feita na T15); sino → como hoje na Início (a tela 30 chega na T17).
- Convite de clube → colar o link ou ler o QR (o fluxo de convite, T23): a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T16 (ROTEIRO §2b).
- O cartão some sozinho quando o primeiro livro entra (nota do design).

## Dados

- Aparece quando a estante está vazia (a pessoa pulou o passo 3); a meta do dia (30 min) do Onboarding; o nome e a saudação como na Início.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L36a.1** Estado "estante vazia" na Início (troca o herói)
- **L36a.2** Cartão do primeiro livro com os atalhos
- **L36a.3** Meta de hoje vazia
- **L36a.4** Convite de clube
- **L36a.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e36a.header', 'e36a.headline', 'e36a.firstBook', 'e36a.today', 'e36a.club'), todos os ids de `kRef36a.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/036a_inicio_primeiro_acesso_390x844@3x.png` no recorte da fase (y 54–705.92) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef36aw360` e `kRef36aw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L36a.1 Estado "estante vazia" na Início (troca o herói)
- [ ] L36a.2 Cartão do primeiro livro com os atalhos
- [ ] L36a.3 Meta de hoje vazia
- [ ] L36a.4 Convite de clube
- [ ] L36a.5 Verificação + relatório
- [ ] Geometria 44/44 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
