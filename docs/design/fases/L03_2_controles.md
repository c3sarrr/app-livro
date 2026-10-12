# FASE L03 — Scanner — barra do topo (fechar, Código | Digitar e a lanterna)

> Tela 03 · prancha `003_scanner_encontrado` (03 · Scanner — livro encontrado, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L03_2_controles@3x.png` · `docs/design/medicao/projeto/png/redline/L03_2_controles_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/003_scanner_encontrado_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_003_scanner_encontrado.json` · `test/reference/projeto/reference_layout_003_scanner_encontrado.dart` (`kRef03`).
> Arquivos sugeridos: `lib/features/scanner/presentation/scanner_top_bar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A barra do topo do Scanner (igual em todos os estados): fechar, o seletor "Código | Digitar" (como adicionar) e a lanterna. Na 69 o "Digitar" fica marcado e a lanterna dá lugar ao "?".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<!-- Top controls (below the real status bar) -->
<div style="position: absolute; left: 20px; right: 20px; top: 58px; height: 48px; display: flex; align-items: center; justify-content: space-between;">
  <button aria-label="Fechar scanner" style="width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"></path></svg>
  </button>
  <div role="radiogroup" aria-label="Como adicionar" style="height: 48px; padding: 3px; box-sizing: border-box; display: flex; gap: 2px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714;">
    <button role="radio" aria-checked="true" style="height: 100%; padding: 0 14px 0 12px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" aria-hidden="true"><path d="M4 6v12M20 6v12" stroke-width="2"></path><path d="M7.5 6v12M13.5 6v12" stroke-width="1.2"></path><path d="M10.5 6v12M16.8 6v12" stroke-width="2.4"></path></svg>
      Código
    </button>
    <button role="radio" aria-checked="false" style="height: 100%; padding: 0 14px 0 12px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2.5" y="6" width="19" height="12" rx="2.5"></rect><path d="M6.5 10h.01M10 10h.01M14 10h.01M17.5 10h.01M7.5 14h9"></path></svg>
      Digitar
    </button>
  </div>
  <button aria-label="Ligar lanterna" style="width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2 4.5 13.5H11L10 22l8.5-11.5H12L13 2z"></path></svg>
  </button>
</div>
```

## Especificação pixel a pixel

Seção `sc03.controls` — retângulo absoluto no canvas 390×844: **x=20, y=58, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc03.controls` | box | 0 | 0 | 350 | 48 | `position: absolute; left: 20px; right: 20px; top: 58px; height: 48px; display: flex; align-items: center; justify-content: space-between` |  |
| 2 | `sc03.controls.close` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `sc03.controls.close.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |
| 4 | `sc03.controls.mode` ±1 | box | 71.92 | 0 | 206.15 | 48 | `height: 48px; padding: 3px; box-sizing: border-box; display: flex; gap: 2px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714` |  |
| 5 | `sc03.controls.mode.code` ±1 | box+text | 76.42 | 4.5 | 101.25 | 39 | `height: 100%; padding: 0 14px 0 12px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 6 | `sc03.controls.mode.code.icon` ±1 | icon | 89.92 | 15 | 18 | 18 | `—` |  |
| 7 | `sc03.controls.mode.type` ±1 | text | 179.67 | 4.5 | 93.9 | 39 | `height: 100%; padding: 0 14px 0 12px; display: flex; align-items: center; gap: 7px; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600` | Figtree 14/normal peso 600 ls normal #1A1714 |
| 8 | `sc03.controls.mode.type.icon` ±1 | icon | 191.67 | 15 | 18 | 18 | `—` |  |
| 9 | `sc03.controls.torch` | box | 302 | 0 | 48 | 48 | `width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 10 | `sc03.controls.torch.icon` | icon | 316 | 14 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc03.controls.mode.code` | 1 | Código | 28.9 | 114.92 | 162.17 | 47.25 |
| `sc03.controls.mode.type` | 1 | Digitar | 28.9 | 216.67 | 259.58 | 42.91 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Barra em `left/right 20 · top 58`, 48 de altura, `space-between`. Fechar e lanterna: círculos 48 `#FFFAF1`, borda 1,5, sem sombra; X 20 (traço 2,2) e o raio 20 (traço 1,9).
2. Seletor: pílula de 48 (padding 3, gap 2, borda 1,5, `#FFFAF1`); cada opção com padding 0/14/0/12, gap 7, ícone 18 + rótulo 14. A marcada em `{{brand}}` com borda 1,5 e 800; a outra sem fundo, 600.
3. O ícone de "Código" são 6 barras com traços de 2, 1,2 e 2,4 (o desenho de um código de barras); o de "Digitar", um teclado.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A largura de cada opção depende do peso do rótulo (800 marcado × 600): trocar a aba muda as duas larguras (a 69 mostra a troca na tabela "Diferenças") — não fixar a largura.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_003_scanner_encontrado_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_003_scanner_encontrado_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc03.controls.close` |  | Fechar scanner |  |
| `sc03.controls.mode` | radiogroup | Como adicionar |  |
| `sc03.controls.mode.code` | radio |  | aria-checked=true |
| `sc03.controls.mode.code.icon` |  |  | aria-hidden=true |
| `sc03.controls.mode.type` | radio |  | aria-checked=false |
| `sc03.controls.mode.type.icon` |  |  | aria-hidden=true |
| `sc03.controls.torch` |  | Ligar lanterna |  |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc03.controls.close` | CircleIconButton / NeoBox circular |  |
| `sc03.controls.close.icon` | AppSvg(AppIconsInicio.closeBold, size: 20) |  |
| `sc03.controls.mode` | NeoBox |  |
| `sc03.controls.mode.code` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc03.controls.mode.code.icon` | AppSvg(AppIconsScanner.barcode, size: 18) |  |
| `sc03.controls.mode.type.icon` | AppSvg(AppIconsScanner.keyboard, size: 18) |  |
| `sc03.controls.torch` | CircleIconButton / NeoBox circular |  |
| `sc03.controls.torch.icon` | AppSvg(AppIconsScanner.flash, size: 20) |  |

## Interações

- Fechar → sai do Scanner (volta para onde abriu).
- Código | Digitar → troca de aba: Digitar pausa a câmera e abre o campo do ISBN (69); voltar para Código tira o foco do campo e religa a câmera; o que foi digitado fica guardado até fechar o Scanner (nota do design).
- Lanterna → liga e desliga (`Semantics(toggled)`, 48 × 48); sem permissão de câmera fica apagada (41).

## Dados

- Nada vem do banco: o estado do seletor e da lanterna é da tela.

## Subfases

- **L03.1** Fechar e lanterna
- **L03.2** Seletor Código | Digitar
- **L03.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc03.controls'), todos os ids de `kRef03.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/003_scanner_encontrado_390x844@3x.png` no recorte da fase (y 50–114) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef03w360` e `kRef03w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L03.1 Fechar e lanterna
- [ ] L03.2 Seletor Código | Digitar
- [ ] L03.3 Verificação + relatório
- [ ] Geometria 10/10 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
