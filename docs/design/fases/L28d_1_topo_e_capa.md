# FASE L28d — Adicionar à mão — o topo, o título e a capa automática (trocar, fotos e as 5 cores)

> Tela 28d · prancha `028d_adicionar_a_mao` (28d · Adicionar livro à mão, canvas 390×1150) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28d_1_topo_e_capa@3x.png` · `docs/design/medicao/projeto/png/redline/L28d_1_topo_e_capa_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028d_adicionar_a_mao_390x1150@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028d_adicionar_a_mao.json` · `test/reference/projeto/reference_layout_028d_adicionar_a_mao.dart` (`kRef28d`).
> Arquivos sugeridos: `lib/features/library/presentation/manual_book/add_manual_screen.dart`, `lib/features/library/presentation/manual_book/auto_cover.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Adicionar à mão (28d): o fechar, a etiqueta "Livro fora da base", o título "Adicionar à mão." e a capa automática (cor + título e autor) girada −3°, com o selo de trocar a capa, "Fotografar capa", "Da galeria" e as 5 cores.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="position: absolute; left: 16px; right: 16px; top: 54px; height: 48px; display: flex; align-items: center; justify-content: space-between;">
  <a href="#" aria-label="Fechar sem salvar" style="width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"></path></svg></a>
  <span style="height: 30px; padding: 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 12px; font-weight: 800; white-space: nowrap;">Livro fora da base</span>
</div>

<h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1px;">Adicionar<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px;">à mão.</span></h1>

<!-- cover: generated from the title until a photo is added -->
<div style="margin-top: 20px; display: flex; gap: 16px; align-items: flex-start;">
  <div style="position: relative; flex-shrink: 0;">
    <span role="img" aria-label="Capa criada automaticamente: Receitas da vó Cida" style="position: relative; display: block; width: 124px; height: 180px; border-radius: 6px 14px 14px 6px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(-3deg);">
      <span style="position: absolute; left: 8px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35);"></span>
      <svg width="122" height="90" viewBox="0 0 122 90" style="position: absolute; left: 0; top: 8px;">
        <path d="M36 52h50l-5 22H41z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path>
        <path d="M32 52h58" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round"></path>
        <path d="M50 44q-4-8 0-14t0-14M61 44q-4-8 0-14t0-14M72 44q-4-8 0-14t0-14" fill="none" stroke="#1A1714" stroke-width="1.6" stroke-linecap="round"></path>
        <g transform="translate(88 10) scale(.8)"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></g>
      </svg>
      <span style="position: absolute; left: 16px; right: 10px; bottom: 12px;">
        <span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.98; letter-spacing: -0.4px;">Receitas da vó Cida</span>
        <span style="display: block; margin-top: 5px; font-size: 10.5px; font-weight: 700; opacity: 0.8;">Aparecida Ramos</span>
      </span>
    </span>
    <button aria-label="Trocar a capa (foto, galeria ou capa automática)" style="position: absolute; right: -12px; top: -10px; z-index: 1; width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8.5A1.5 1.5 0 0 1 5.5 7H8l1.5-2h5L16 7h2.5A1.5 1.5 0 0 1 20 8.5v9a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 17.5z"></path><path d="M14.6 11.2a3 3 0 0 0-5.3 1"></path><path d="M9.4 14.8a3 3 0 0 0 5.3-1"></path><path d="M14.8 9.6v1.8H13M9.2 16.4v-1.8H11"></path></svg></button>
    <span style="position: absolute; left: 50%; bottom: -14px; transform: translateX(-50%); height: 24px; padding: 0 9px; border-radius: 999px; background: #FED170; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 10.5px; font-weight: 800; white-space: nowrap;">capa automática</span>
  </div>
  <div style="min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 8px;">
    <button style="height: 48px; padding: 0 12px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 800; white-space: nowrap;"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8.5A1.5 1.5 0 0 1 5.5 7H8l1.5-2h5L16 7h2.5A1.5 1.5 0 0 1 20 8.5v9a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 17.5z"></path><circle cx="12" cy="13" r="3.5"></circle></svg>Fotografar capa</button>
    <button style="height: 48px; padding: 0 12px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 800; white-space: nowrap;"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="4" y="5" width="16" height="14" rx="2"></rect><circle cx="9" cy="10" r="1.6"></circle><path d="m20 16-5-5-8 8"></path></svg>Da galeria</button>
    <span style="margin-top: 4px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">OU ESCOLHA A COR</span>
    <div role="radiogroup" aria-label="Cor da capa automática" style="display: flex; gap: 8px; padding-left: 2px;"><button role="radio" aria-checked="true" aria-label="Capa #FFC1C6" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 0 0 2.5px #FFFAF1, 0 0 0 4px #1A1714;"></button><button role="radio" aria-checked="false" aria-label="Capa #FED170" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Capa #B6ACE4" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Capa #ABCF82" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Capa #FF552E" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box;"></button></div>
  </div>
</div>
```

## Especificação pixel a pixel

Seção `bu28d.header` — retângulo absoluto no canvas 390×1150: **x=16, y=54, w=358, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28d.header` | box | 0 | 0 | 358 | 48 | `position: absolute; left: 16px; right: 16px; top: 54px; height: 48px; display: flex; align-items: center; justify-content: space-between` |  |
| 2 | `bu28d.header.close` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `bu28d.header.close.icon` | icon | 15 | 15 | 18 | 18 | `—` |  |
| 4 | `bu28d.header.badge` ±1 | box+text | 231.36 | 9 | 126.64 | 30 | `height: 30px; padding: 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 12px; font-weight: 800; white-space: nowrap` | Figtree 12/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28d.header.badge` | 1 | Livro fora da base | 28.2 | 244.86 | 344.5 | 99.64 |

Seção `bu28d.title` — retângulo absoluto no canvas 390×1150: **x=16, y=122, w=358, h=74.48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `bu28d.title` | text | 0 | 0 | 358 | 74.48 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1px #1A1714 |
| 6 | `bu28d.title.serif` ±1 | inline | 0 | 26.6 | 101.17 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.4px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28d.title` *(composto)* | 1 | Adicionar | 27.88 | 0 | 149.55 | 149.55 |
| `bu28d.title` *(composto)* | 2 | à mão. | 68.18 | 0 | 101.17 | 101.17 |

Seção `bu28d.cover` — retângulo absoluto no canvas 390×1150: **x=16, y=216.48, w=358, h=180**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 7 | `bu28d.cover` | box | 0 | 0 | 358 | 180 | `margin-top: 20px; display: flex; gap: 16px; align-items: flex-start` |  |
| 8 | `bu28d.cover.preview` | box | 0 | 0 | 124 | 180 | `position: relative; flex-shrink: 0` |  |
| 9 | `bu28d.cover.preview.book` | box | 0 | 0 | 124 | 180 | `position: relative; display: block; width: 124px; height: 180px; border-radius: 6px 14px 14px 6px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(-3deg)` |  |
| 10 | `bu28d.cover.preview.book.spine` | box | 9.5 | 1.5 | 1.5 | 177 | `position: absolute; left: 8px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35)` |  |
| 11 | `bu28d.cover.preview.book.art` | icon | 1.5 | 9.5 | 122 | 90 | `position: absolute; left: 0; top: 8px` |  |
| 12 | `bu28d.cover.preview.book.textBlock` | box | 17.5 | 115.57 | 95 | 50.93 | `position: absolute; left: 16px; right: 10px; bottom: 12px` |  |
| 13 | `bu28d.cover.preview.book.title` | text | 17.5 | 115.57 | 95 | 33.32 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 0.98; letter-spacing: -0.4px` | Bricolage (opsz 17) 17/16.66px peso 800 ls -0.4px #1A1714 |
| 14 | `bu28d.cover.preview.book.author` | text | 17.5 | 153.89 | 95 | 12.61 | `display: block; margin-top: 5px; font-size: 10.5px; font-weight: 700; opacity: 0.8` | Figtree 10.5/normal peso 700 ls normal #1A1714 |
| 15 | `bu28d.cover.preview.change` | box | 96 | -10 | 40 | 40 | `position: absolute; right: -12px; top: -10px; z-index: 1; width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 16 | `bu28d.cover.preview.change.icon` | icon | 106 | 0 | 20 | 20 | `—` |  |
| 17 | `bu28d.cover.preview.tag` ±1 | box+text | 62 | 170 | 102.08 | 24 | `position: absolute; left: 50%; bottom: -14px; transform: translateX(-50%); height: 24px; padding: 0 9px; border-radius: 999px; background: #FED170; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 10.5px; font-weight: 800; white-space: nowrap` | Figtree 10.5/normal peso 800 ls normal #1A1714 |
| 18 | `bu28d.cover.options` | box | 140 | 0 | 218 | 165.2 | `min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 8px` |  |
| 19 | `bu28d.cover.options.camera` | box+text | 140 | 0 | 218 | 48 | `height: 48px; padding: 0 12px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 800; white-space: nowrap` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 20 | `bu28d.cover.options.camera.icon` | icon | 153.5 | 14.5 | 19 | 19 | `—` |  |
| 21 | `bu28d.cover.options.gallery` | box+text | 140 | 56 | 218 | 48 | `height: 48px; padding: 0 12px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 800; white-space: nowrap` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 22 | `bu28d.cover.options.gallery.icon` | icon | 153.5 | 70.5 | 19 | 19 | `—` |  |
| 23 | `bu28d.cover.options.colorLabel` | text | 140 | 116 | 218 | 13.2 | `margin-top: 4px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 24 | `bu28d.cover.options.colors` | box | 140 | 137.2 | 218 | 28 | `display: flex; gap: 8px; padding-left: 2px` |  |
| 25 | `bu28d.cover.options.colors.swatch1` | box | 142 | 137.2 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 0 0 2.5px #FFFAF1, 0 0 0 4px #1A1714` |  |
| 26 | `bu28d.cover.options.colors.swatch2` | box | 178 | 137.2 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 27 | `bu28d.cover.options.colors.swatch3` | box | 214 | 137.2 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 28 | `bu28d.cover.options.colors.swatch4` | box | 250 | 137.2 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 29 | `bu28d.cover.options.colors.swatch5` | box | 286 | 137.2 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `bu28d.cover.preview.book`: caixa visual com `transform: rotate(-3deg)` = x -4.62, y -3.12, w 133.25, h 186.24 (relativa à seção).
- `bu28d.cover.preview.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 4.94, y 4.29, w 10.76, h 176.84 (relativa à seção).
- `bu28d.cover.preview.book.art`: caixa visual deslocada pelo transform de um ancestral = x -2.63, y 6.39, w 126.54, h 96.26 (relativa à seção).
- `bu28d.cover.preview.book.textBlock`: caixa visual deslocada pelo transform de um ancestral = x 18.9, y 112.89, w 97.53, h 55.83 (relativa à seção).
- `bu28d.cover.preview.book.title`: caixa visual deslocada pelo transform de um ancestral = x 18.9, y 112.89, w 96.61, h 38.25 (relativa à seção).
- `bu28d.cover.preview.book.author`: caixa visual deslocada pelo transform de um ancestral = x 20.91, y 151.16, w 95.53, h 17.57 (relativa à seção).
- `bu28d.cover.preview.tag`: caixa visual com `transform: translateX(-50%)` = x 10.96, y 170, w 102.08, h 24 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28d.cover.preview.book.title` | 1 | Receitas da | 129.51 | 17.5 | 110.38 | 92.88 |
| `bu28d.cover.preview.book.title` | 2 | vó Cida | 146.17 | 17.5 | 76.1 | 58.6 |
| `bu28d.cover.preview.book.author` | 1 | Aparecida Ramos | 163.87 | 17.5 | 102.05 | 84.55 |
| `bu28d.cover.preview.tag` | 1 | capa automática | 185.67 | 72.3 | 153.78 | 81.48 |
| `bu28d.cover.options.camera` | 1 | Fotografar capa | 28.9 | 180.5 | 284.87 | 104.37 |
| `bu28d.cover.options.gallery` | 1 | Da galeria | 84.9 | 180.5 | 245.73 | 65.23 |
| `bu28d.cover.options.colorLabel` | 1 | OU ESCOLHA A COR | 126.45 | 140 | 267.4 | 127.4 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Topo em `left/right 16 · top 54`, 48 de altura: fechar 48 (sombra 2/2, X 18 traço 2,4) e a etiqueta de 30 (padding 0/12, borda 1,5, 12/800).
2. Título: "Adicionar" Bricolage 34/800 `lh 0,98` ls −1, quebra, "à mão." Instrument Serif itálico 42 ls −0,4.
3. Capa 124 × 180, 20 abaixo, raio 6/14/14/6, borda 1,5, sombra 4/4, girada −3°: a cor escolhida, a lombada de 1,5 a 8, o desenho do bolo (122 × 90) e, embaixo, o título Bricolage 17/800 `lh 0,98` + o autor 10,5/700 a 0,8. A etiqueta "capa automática" (24, `#FED170`, 10,5/800) centrada 14 abaixo; o selo de trocar 40 em `right −12 · top −10`.
4. À direita (gap 8): "Fotografar capa" (48, raio 16, sombra 2/2) e "Da galeria" (48, sem sombra), ícone 19 + 14/800; "OU ESCOLHA A COR" 11/800 ls 1,2; 5 círculos de 28 (gap 8) com a marcada no anel duplo (`0 0 0 2.5 #FFFAF1, 0 0 0 4 #1A1714`).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A etiqueta "capa automática" usa `translateX(-50%)` (centrada pela própria largura): no app, `Align` centrado, não um deslocamento fixo.
- Só a capa gira (−3°): o selo de trocar e a etiqueta são irmãos dela e ficam retos.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028d_adicionar_a_mao_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028d_adicionar_a_mao_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28d.header.close` |  | Fechar sem salvar |  |
| `bu28d.header.close.icon` |  |  | aria-hidden=true |
| `bu28d.cover.preview.book` | img | Capa criada automaticamente: Receitas da vó Cida |  |
| `bu28d.cover.preview.change` |  | Trocar a capa (foto, galeria ou capa automática) |  |
| `bu28d.cover.preview.change.icon` |  |  | aria-hidden=true |
| `bu28d.cover.options.camera.icon` |  |  | aria-hidden=true |
| `bu28d.cover.options.gallery.icon` |  |  | aria-hidden=true |
| `bu28d.cover.options.colors` | radiogroup | Cor da capa automática |  |
| `bu28d.cover.options.colors.swatch1` | radio | Capa #FFC1C6 | aria-checked=true |
| `bu28d.cover.options.colors.swatch2` | radio | Capa #FED170 | aria-checked=false |
| `bu28d.cover.options.colors.swatch3` | radio | Capa #B6ACE4 | aria-checked=false |
| `bu28d.cover.options.colors.swatch4` | radio | Capa #ABCF82 | aria-checked=false |
| `bu28d.cover.options.colors.swatch5` | radio | Capa #FF552E | aria-checked=false |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28d.header.close` | CircleIconButton / NeoBox circular |  |
| `bu28d.header.close.icon` | AppSvg(AppIconsLeitor.close, size: 18) |  |
| `bu28d.header.badge` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28d.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `bu28d.cover.preview.book` | NeoBox | Transform: rotate(-3deg) |
| `bu28d.cover.preview.book.spine` | NeoBox |  |
| `bu28d.cover.preview.book.art` | AppSvg(AppIllustrationsScanner.capaReceitasDaVoCida, size: 122×90) |  |
| `bu28d.cover.preview.change` | CircleIconButton / NeoBox circular |  |
| `bu28d.cover.preview.change.icon` | AppSvg(AppIconsBiblioteca.cameraSwap, size: 20) |  |
| `bu28d.cover.preview.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) | Transform: translateX(-50%) |
| `bu28d.cover.options.camera` | NeoBox + AppText |  |
| `bu28d.cover.options.camera.icon` | AppSvg(AppIconsScanner.cameraCapa, size: 19) |  |
| `bu28d.cover.options.gallery` | NeoBox + AppText |  |
| `bu28d.cover.options.gallery.icon` | AppSvg(AppIconsScanner.image, size: 19) |  |
| `bu28d.cover.options.colors.swatch1` | CircleIconButton / NeoBox circular |  |
| `bu28d.cover.options.colors.swatch2` | CircleIconButton / NeoBox circular |  |
| `bu28d.cover.options.colors.swatch3` | CircleIconButton / NeoBox circular |  |
| `bu28d.cover.options.colors.swatch4` | CircleIconButton / NeoBox circular |  |
| `bu28d.cover.options.colors.swatch5` | CircleIconButton / NeoBox circular |  |

## Interações

- Fechar → sai sem salvar; com mudanças, confirmar o descarte (sem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T15 (ROTEIRO §2b)).
- Trocar a capa → a mesma escolha da tela "Trocar a capa" da T14 (Fotografar, Galeria ou voltar para a capa automática).
- Fotografar capa → câmera com recorte automático; Da galeria → as fotos do aparelho.
- Cor → a capa automática muda na hora (título e autor por cima).

## Dados

- A capa automática é gerada do título, do autor e da cor (sem foto); a foto fica só com a pessoa. O desenho do meio (o bolo da fixture): como escolher (por gênero, sorteado ou sem desenho) é pergunta da T15.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L28d.1** Topo e título
- **L28d.2** Capa automática girada com a etiqueta e o selo
- **L28d.3** Fotografar, galeria e as cores
- **L28d.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28d.header', 'bu28d.title', 'bu28d.cover'), todos os ids de `kRef28d.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028d_adicionar_a_mao_390x1150@3x.png` no recorte da fase (y 46–418.48) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28dw360` e `kRef28dw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28d.1 Topo e título
- [ ] L28d.2 Capa automática girada com a etiqueta e o selo
- [ ] L28d.3 Fotografar, galeria e as cores
- [ ] L28d.4 Verificação + relatório
- [ ] Geometria 28/28 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
