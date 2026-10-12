# FASE L28d — Adicionar à mão — o formulário (título, autor, formato, páginas, ISBN, Salvar como) e o botão

> Tela 28d · prancha `028d_adicionar_a_mao` (28d · Adicionar livro à mão, canvas 390×1150) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28d_2_formulario@3x.png` · `docs/design/medicao/projeto/png/redline/L28d_2_formulario_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028d_adicionar_a_mao_390x1150@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028d_adicionar_a_mao.json` · `test/reference/projeto/reference_layout_028d_adicionar_a_mao.dart` (`kRef28d`).
> Arquivos sugeridos: `lib/features/library/presentation/manual_book/manual_book_form.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Adicionar à mão: o formulário — Título (preenchido com o que foi buscado), Autor, Formato (Papel | E-book), Número de páginas, ISBN (com o botão amarelo de ler pela câmera), Salvar como (Lendo) — o botão "Adicionar à estante" e a nota "ficam só com você".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- form -->
<div style="margin-top: 34px;">
  <label for="am-title" style="display: block; font-size: 13.5px; font-weight: 800; line-height: 18px;">Título</label>
  <div style="margin-top: 6px; height: 52px; padding: 0 14px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px;"><input id="am-title" type="text" value="Receitas da vó Cida" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714;"></div>

  <label for="am-author" style="margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px;">Autor<span style="font-weight: 600; color: #8A8073;"> · opcional</span></label>
  <div style="margin-top: 6px; height: 52px; padding: 0 14px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px;"><input id="am-author" type="text" value="Aparecida Ramos" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714;"></div>

  <span style="margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px;">Formato</span>
  <div role="radiogroup" aria-label="Formato" style="margin-top: 6px; height: 50px; padding: 3px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 3px;"><button role="radio" aria-checked="true" style="padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800; white-space: nowrap;">Papel</button><button role="radio" aria-checked="false" style="padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; font-size: 14px; font-weight: 700; white-space: nowrap;">E-book</button></div>

  <label for="am-pages" style="margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px;">Número de páginas<span style="font-weight: 600; color: #8A8073;"> · opcional</span></label>
  <div style="margin-top: 6px; height: 52px; padding: 0 14px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px; width: 150px;"><input id="am-pages" type="text" inputmode="numeric" placeholder="ex.: 120" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714;"></div>
  <p style="margin: 6px 0 0 2px; font-size: 12.5px; font-weight: 500; line-height: 16px; color: #6F665B;">Sem ele, o app conta só os minutos de leitura.</p>

  <label for="am-isbn" style="margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px;">ISBN<span style="font-weight: 600; color: #8A8073;"> · opcional</span></label>
  <div style="margin-top: 6px; height: 52px; padding: 0 14px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px; padding-right: 6px;"><input id="am-isbn" type="text" inputmode="numeric" placeholder="978-…" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714;"><a href="#" aria-label="Ler o ISBN com a câmera" style="width: 40px; height: 40px; flex-shrink: 0; border-radius: 12px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16"></path><path d="M8 8v8M11 8v8M14 8v8M17 8v8"></path></svg></a></div>

  <span style="margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px;">Salvar como</span>
  <div role="radiogroup" aria-label="Salvar como" style="margin-top: 6px; height: 50px; padding: 3px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 3px;"><button role="radio" aria-checked="false" style="padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; font-size: 14px; font-weight: 700; white-space: nowrap;">Quero ler</button><button role="radio" aria-checked="true" style="padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800; white-space: nowrap;">Lendo</button><button role="radio" aria-checked="false" style="padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; font-size: 14px; font-weight: 700; white-space: nowrap;">Lido</button></div>
</div>

<button style="margin-top: 26px; width: 100%; height: 56px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 16px; font-weight: 800; color: #F7F0E3;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg><span style="color: #F7F0E3;">Adicionar à estante</span></button>

<p style="margin: 10px 8px 0; text-align: center; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #6F665B;">Livros adicionados à mão ficam só com você. Dá para editar tudo depois.</p>
```

## Especificação pixel a pixel

Seção `bu28d.form` — retângulo absoluto no canvas 390×1150: **x=16, y=430.48, w=358, h=544**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28d.form` | box | 0 | 0 | 358 | 544 | `margin-top: 34px` |  |
| 2 | `bu28d.form.title.label` | text | 0 | 0 | 358 | 18 | `display: block; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 3 | `bu28d.form.title.field` | box | 0 | 24 | 358 | 52 | `margin-top: 6px; height: 52px; padding: 0 14px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px` |  |
| 4 | `bu28d.form.title.field.input` | box | 17.5 | 25.5 | 325 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714` |  |
| 5 | `bu28d.form.author.label` | text | 0 | 90 | 358 | 18 | `margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 6 | `bu28d.form.author.label.optional` ±1 | inline | 36.27 | 90.89 | 62.33 | 16.21 | `font-weight: 600; color: #8A8073` | Figtree 13.5/18px peso 600 ls normal #8A8073 |
| 7 | `bu28d.form.author.field` | box | 0 | 114 | 358 | 52 | `margin-top: 6px; height: 52px; padding: 0 14px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px` |  |
| 8 | `bu28d.form.author.field.input` | box | 17.5 | 115.5 | 325 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714` |  |
| 9 | `bu28d.form.format.label` | text | 0 | 180 | 358 | 18 | `margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 10 | `bu28d.form.format.options` | box | 0 | 204 | 358 | 50 | `margin-top: 6px; height: 50px; padding: 3px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 3px` |  |
| 11 | `bu28d.form.format.options.paper` | box+text | 4.5 | 208.5 | 173 | 41 | `padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800; white-space: nowrap` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 12 | `bu28d.form.format.options.ebook` | box+text | 180.5 | 208.5 | 173 | 41 | `padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 13 | `bu28d.form.pages.label` | text | 0 | 268 | 358 | 18 | `margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 14 | `bu28d.form.pages.label.optional` ±1 | inline | 121.68 | 268.89 | 62.33 | 16.21 | `font-weight: 600; color: #8A8073` | Figtree 13.5/18px peso 600 ls normal #8A8073 |
| 15 | `bu28d.form.pages.field` | box | 0 | 292 | 150 | 52 | `margin-top: 6px; height: 52px; padding: 0 14px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px; width: 150px` |  |
| 16 | `bu28d.form.pages.field.input` | box | 17.5 | 293.5 | 117 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714` |  |
| 17 | `bu28d.form.pages.hint` | text | 2 | 350 | 356 | 16 | `margin: 6px 0 0 2px; font-size: 12.5px; font-weight: 500; line-height: 16px; color: #6F665B` | Figtree 12.5/16px peso 500 ls normal #6F665B |
| 18 | `bu28d.form.isbn.label` | text | 0 | 380 | 358 | 18 | `margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 19 | `bu28d.form.isbn.label.optional` ±1 | inline | 30.86 | 380.89 | 62.33 | 16.21 | `font-weight: 600; color: #8A8073` | Figtree 13.5/18px peso 600 ls normal #8A8073 |
| 20 | `bu28d.form.isbn.field` | box | 0 | 404 | 358 | 52 | `margin-top: 6px; height: 52px; padding: 0 14px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px; padding-right: 6px` |  |
| 21 | `bu28d.form.isbn.field.input` | box | 17.5 | 405.5 | 283 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714` |  |
| 22 | `bu28d.form.isbn.field.scan` | box | 310.5 | 410 | 40 | 40 | `width: 40px; height: 40px; flex-shrink: 0; border-radius: 12px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 23 | `bu28d.form.isbn.field.scan.icon` | icon | 321 | 420.5 | 19 | 19 | `—` |  |
| 24 | `bu28d.form.saveAs.label` | text | 0 | 470 | 358 | 18 | `margin-top: 14px; display: block; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 25 | `bu28d.form.saveAs.options` | box | 0 | 494 | 358 | 50 | `margin-top: 6px; height: 50px; padding: 3px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 3px` |  |
| 26 | `bu28d.form.saveAs.options.wantToRead` | box+text | 4.5 | 498.5 | 114.33 | 41 | `padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 27 | `bu28d.form.saveAs.options.reading` | box+text | 121.83 | 498.5 | 114.33 | 41 | `padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800; white-space: nowrap` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 28 | `bu28d.form.saveAs.options.read` | box+text | 239.17 | 498.5 | 114.33 | 41 | `padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; font-size: 14px; font-weight: 700; white-space: nowrap` | Figtree 14/normal peso 700 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28d.form.title.label` | 1 | Título | 13.72 | 0 | 36.48 | 36.48 |
| `bu28d.form.author.label` *(composto)* | 1 | Autor · opcional | 103.72 | 0 | 98.6 | 98.6 |
| `bu28d.form.format.label` | 1 | Formato | 193.72 | 0 | 53.12 | 53.12 |
| `bu28d.form.format.options.paper` | 1 | Papel | 233.9 | 73.03 | 108.97 | 35.94 |
| `bu28d.form.format.options.ebook` | 1 | E-book | 233.9 | 243.95 | 290.05 | 46.1 |
| `bu28d.form.pages.label` *(composto)* | 1 | Número de páginas · opcional | 281.72 | 0 | 184 | 184 |
| `bu28d.form.pages.hint` | 1 | Sem ele, o app conta só os minutos de leitura. | 362.37 | 2 | 258.88 | 256.88 |
| `bu28d.form.isbn.label` *(composto)* | 1 | ISBN · opcional | 393.72 | 0 | 93.19 | 93.19 |
| `bu28d.form.saveAs.label` | 1 | Salvar como | 483.72 | 0 | 77.23 | 77.23 |
| `bu28d.form.saveAs.options.wantToRead` | 1 | Quero ler | 523.9 | 31.65 | 91.68 | 60.03 |
| `bu28d.form.saveAs.options.reading` | 1 | Lendo | 523.9 | 158.98 | 199.02 | 40.04 |
| `bu28d.form.saveAs.options.read` | 1 | Lido | 523.9 | 282.51 | 310.16 | 27.65 |

Seção `bu28d.submit` — retângulo absoluto no canvas 390×1150: **x=16, y=1000.48, w=358, h=56**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 29 | `bu28d.submit` | box | 0 | 0 | 358 | 56 | `margin-top: 26px; width: 100%; height: 56px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 30 | `bu28d.submit.icon` ±1 | icon | 92.24 | 18 | 20 | 20 | `—` |  |
| 31 | `bu28d.submit.label` ±1 | text | 121.24 | 18.4 | 144.53 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28d.submit.label` | 1 | Adicionar à estante | 33.6 | 121.24 | 265.76 | 144.52 |

Seção `bu28d.footnote` — retângulo absoluto no canvas 390×1150: **x=24, y=1066.48, w=342, h=35**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 32 | `bu28d.footnote` | text | 0 | 0 | 342 | 35 | `margin: 10px 8px 0; text-align: center; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #6F665B` | Figtree 12.5/17.5px peso 600 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28d.footnote` | 1 | Livros adicionados à mão ficam só com você. Dá para editar | 13.12 | 2.12 | 339.88 | 337.76 |
| `bu28d.footnote` | 2 | tudo depois. | 30.62 | 135.76 | 206.24 | 70.48 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Rótulos 13,5/800 `lh 18` (" · opcional" 600 `#8A8073`); campos de 52, 6 abaixo do rótulo, 14 entre os grupos: padding 0/14/0/16, raio 16, `#F7F0E3`, borda 1,5, texto 16/600.
2. Formato e Salvar como: réguas de 50 (padding 3, gap 3, `#F7F0E3`), a marcada em `{{brand}}` com borda 1,5 e 14/800, as outras com borda transparente de 1,5 e 14/700.
3. Páginas: o campo tem 150 de largura e, 6 abaixo, "Sem ele, o app conta só os minutos de leitura." 12,5/500 `lh 16` `#6F665B`. ISBN: o campo com `padding-right 6` e o botão 40 × 40 (raio 12, `#FED170`, borda 1,5, ícone 19).
4. Botão "Adicionar à estante", 26 abaixo: largura toda, 56, preto, "+" 20 + 16/800; a nota centrada 12,5/600 `lh 1,4`, 10 abaixo.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- "ex.: 120" e "978-…" são `placeholder` (cor padrão do Chromium): `hintText` com a cor da referência @3x.
- Sem páginas, o livro de papel conta só minutos (a barra de progresso da Biblioteca não tem dado — a mesma pergunta da L02_4).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028d_adicionar_a_mao_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028d_adicionar_a_mao_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28d.form.format.options` | radiogroup | Formato |  |
| `bu28d.form.format.options.paper` | radio |  | aria-checked=true |
| `bu28d.form.format.options.ebook` | radio |  | aria-checked=false |
| `bu28d.form.isbn.field.scan` |  | Ler o ISBN com a câmera |  |
| `bu28d.form.isbn.field.scan.icon` |  |  | aria-hidden=true |
| `bu28d.form.saveAs.options` | radiogroup | Salvar como |  |
| `bu28d.form.saveAs.options.wantToRead` | radio |  | aria-checked=false |
| `bu28d.form.saveAs.options.reading` | radio |  | aria-checked=true |
| `bu28d.form.saveAs.options.read` | radio |  | aria-checked=false |
| `bu28d.submit.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28d.form.title.field` | NeoBox |  |
| `bu28d.form.author.label.optional` | TextSpan dentro do AppText.rich do pai |  |
| `bu28d.form.author.field` | NeoBox |  |
| `bu28d.form.format.options` | NeoBox |  |
| `bu28d.form.format.options.paper` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28d.form.format.options.ebook` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28d.form.pages.label.optional` | TextSpan dentro do AppText.rich do pai |  |
| `bu28d.form.pages.field` | NeoBox |  |
| `bu28d.form.isbn.label.optional` | TextSpan dentro do AppText.rich do pai |  |
| `bu28d.form.isbn.field` | NeoBox |  |
| `bu28d.form.isbn.field.scan` | NeoBox |  |
| `bu28d.form.isbn.field.scan.icon` | AppSvg(AppIconsScanner.scanBarcodeBusca, size: 19) |  |
| `bu28d.form.saveAs.options` | NeoBox |  |
| `bu28d.form.saveAs.options.wantToRead` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28d.form.saveAs.options.reading` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28d.form.saveAs.options.read` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28d.submit` | NeoBox |  |
| `bu28d.submit.icon` | AppSvg(AppIconsScanner.plusAddPapel, size: 20) |  |

## Interações

- Só o título é obrigatório; o botão sem título não tem prancha (a prancha mostra o formulário preenchido) — pergunta da T15.
- Ler o ISBN com a câmera → o Scanner na aba Código, que devolve o ISBN para o campo.
- Adicionar à estante → grava o livro privado na estante (formato, páginas, ISBN, status) e vai para os Detalhes do livro.
- Teclado: o formulário rola e o botão continua alcançável.

## Dados

- Título vindo da busca (28c) ou o ISBN vindo do Scanner (40); formato começa em Papel, status em Lendo (nota do design). Livro à mão é privado; se o mesmo ISBN aparecer na base depois, o app oferece juntar sem perder minutos, grifos e notas (o fluxo de juntar não tem prancha).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L28d.1** Campos de texto (título, autor, páginas, ISBN)
- **L28d.2** Réguas de formato e status
- **L28d.3** Adicionar à estante (livro privado)
- **L28d.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28d.form', 'bu28d.submit', 'bu28d.footnote'), todos os ids de `kRef28d.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028d_adicionar_a_mao_390x1150@3x.png` no recorte da fase (y 422.48–1109.48) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28dw360` e `kRef28dw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28d.1 Campos de texto (título, autor, páginas, ISBN)
- [ ] L28d.2 Réguas de formato e status
- [ ] L28d.3 Adicionar à estante (livro privado)
- [ ] L28d.4 Verificação + relatório
- [ ] Geometria 29/29 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
