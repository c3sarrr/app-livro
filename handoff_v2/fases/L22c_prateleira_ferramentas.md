# FASE L22c — Modo anotação — prateleira de ferramentas

> Tela 22 · prancha `22_modo_anotacao` (22 · Leitor — modo anotação, canvas 390×844) · executada na **G16** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L22c_prateleira_ferramentas@3x.png` · `referencia/png/redline/L22c_prateleira_ferramentas_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/22_modo_anotacao_390x844@{1,2,3}x.png` · `referencia/layout/layout_22_modo_anotacao.json` · `test/reference/leitor/reference_layout_22_modo_anotacao.dart` (`kRef22`).
> Arquivos sugeridos: `lib/features/reader/presentation/tool_rack.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Ferramentas como objetos físicos "atrás" da ilha; a ativa sobe 12 px.

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{ink}}` = padrão `#FF552E`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- Tools: physical objects tucked behind the island; the active one pops up -->
<div role="radiogroup" aria-label="Ferramentas de anotação" style="position: absolute; left: 39px; bottom: 98px; width: 312px; height: 70px; display: flex;">
    <button role="radio" aria-checked="true" aria-label="Caneta" style="width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center; transform: translateY(-12px);"><svg width="50" height="70" sc-camel-view-box="0 0 50 70" aria-hidden="true" style="display: block;"><path d="M17.5 74V26.5L24.5 11.5H30.5L37.5 26.5V74Z" fill="#1A1714"></path><rect x="15" y="24" width="20" height="52" fill="{{brand}}" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><rect x="15" y="31" width="20" height="7" fill="{{ink}}" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><path d="M15 24 22 9H28L35 24Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path><path d="M22 9 23.5 2.5H26.5L28 9Z" fill="{{ink}}" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg></button>
    <button role="radio" aria-checked="false" aria-label="Marca-texto" style="width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center;"><svg width="50" height="70" sc-camel-view-box="0 0 50 70" aria-hidden="true" style="display: block;"><rect x="13" y="28" width="24" height="48" rx="2" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><rect x="13" y="36" width="24" height="9" fill="#FED170" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><path d="M15 28 17 20H33L35 28Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path><path d="M19 20V13L31 8V20Z" fill="#FED170" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg></button>
    <button role="radio" aria-checked="false" aria-label="Borracha" style="width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center;"><svg width="50" height="70" sc-camel-view-box="0 0 50 70" aria-hidden="true" style="display: block;"><rect x="13" y="15" width="24" height="30" rx="7" fill="#FFC1C6" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><rect x="12" y="33" width="26" height="43" rx="2" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><path d="M12 39.5H38M12 45H38" stroke="#1A1714" stroke-width="1.2"></path></svg></button>
    <button role="radio" aria-checked="false" aria-label="Laço — selecionar e mover traços" style="width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center;"><svg width="50" height="70" sc-camel-view-box="0 0 50 70" aria-hidden="true" style="display: block;"><rect x="21" y="31" width="8" height="45" rx="2" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><path d="M25 31C23 28 26 27 24.5 25" fill="none" stroke="#1A1714" stroke-width="1.5" stroke-linecap="round"></path><ellipse cx="25" cy="15" rx="15" ry="10.5" fill="rgba(182,172,228,0.35)" stroke="#1A1714" stroke-width="1.7" stroke-dasharray="4 3"></ellipse></svg></button>
    <button role="radio" aria-checked="false" aria-label="Linha reta" style="width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center;"><svg width="50" height="70" sc-camel-view-box="0 0 50 70" aria-hidden="true" style="display: block;"><rect x="15" y="8" width="20" height="68" rx="2.5" fill="#ABCF82" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><path d="M15 14H22" stroke="#1A1714" stroke-width="1.3"></path><path d="M15 19H19" stroke="#1A1714" stroke-width="1.3"></path><path d="M15 24H22" stroke="#1A1714" stroke-width="1.3"></path><path d="M15 29H19" stroke="#1A1714" stroke-width="1.3"></path><path d="M15 34H22" stroke="#1A1714" stroke-width="1.3"></path><path d="M15 39H19" stroke="#1A1714" stroke-width="1.3"></path><path d="M15 44H22" stroke="#1A1714" stroke-width="1.3"></path><path d="M15 49H19" stroke="#1A1714" stroke-width="1.3"></path></svg></button>
    <button role="radio" aria-checked="false" aria-label="Espaço — arrastar entre as linhas para abrir lugar de escrever" style="width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center;"><svg width="50" height="70" sc-camel-view-box="0 0 50 70" aria-hidden="true" style="display: block;"><rect x="13" y="9" width="24" height="67" rx="3" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></rect><path d="M17 16H33" stroke="#CFC3AE" stroke-width="1.3"></path><path d="M17 21H33" stroke="#CFC3AE" stroke-width="1.3"></path><path d="M17 50H33" stroke="#CFC3AE" stroke-width="1.3"></path><path d="M17 55H33" stroke="#CFC3AE" stroke-width="1.3"></path><path d="M17 60H33" stroke="#CFC3AE" stroke-width="1.3"></path><path d="M17 65H33" stroke="#CFC3AE" stroke-width="1.3"></path><path d="M17 70H33" stroke="#CFC3AE" stroke-width="1.3"></path><rect x="13" y="27" width="24" height="17" fill="#FED170" stroke="#1A1714" stroke-width="1.5"></rect><path d="M25 29.5V41.5M21.8 32.5 25 29.5 28.2 32.5M21.8 38.5 25 41.5 28.2 38.5" fill="none" stroke="#1A1714" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"></path></svg></button>
</div>
```

## Especificação pixel a pixel

Seção `ann.toolShelf` — retângulo absoluto no canvas 390×844: **x=39, y=676, w=312, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `ann.toolShelf` | box | 0 | 0 | 312 | 70 | `position: absolute; left: 39px; bottom: 98px; width: 312px; height: 70px; display: flex` |  |
| 2 | `ann.toolShelf.pen` | box | 0 | 0 | 52 | 70 | `width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center; transform: translateY(-12px)` |  |
| 3 | `ann.toolShelf.pen.art` | icon | 1 | 0 | 50 | 70 | `display: block` |  |
| 4 | `ann.toolShelf.marker` | box | 52 | 0 | 52 | 70 | `width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center` |  |
| 5 | `ann.toolShelf.marker.art` | icon | 53 | 0 | 50 | 70 | `display: block` |  |
| 6 | `ann.toolShelf.eraser` | box | 104 | 0 | 52 | 70 | `width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center` |  |
| 7 | `ann.toolShelf.eraser.art` | icon | 105 | 0 | 50 | 70 | `display: block` |  |
| 8 | `ann.toolShelf.lasso` | box | 156 | 0 | 52 | 70 | `width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center` |  |
| 9 | `ann.toolShelf.lasso.art` | icon | 157 | 0 | 50 | 70 | `display: block` |  |
| 10 | `ann.toolShelf.line` | box | 208 | 0 | 52 | 70 | `width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center` |  |
| 11 | `ann.toolShelf.line.art` | icon | 209 | 0 | 50 | 70 | `display: block` |  |
| 12 | `ann.toolShelf.space` | box | 260 | 0 | 52 | 70 | `width: 52px; height: 70px; padding: 0; border: none; background: transparent; flex-shrink: 0; display: flex; justify-content: center` |  |
| 13 | `ann.toolShelf.space.art` | icon | 261 | 0 | 50 | 70 | `display: block` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `ann.toolShelf.pen`: caixa visual com `transform: translateY(-12px)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `ann.toolShelf.pen.art`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. `radiogroup` "Ferramentas de anotação" com 6 botões 50×70 (ilustrações em `assets/illustrations/leitor/`) atrás da ilha; a ativa tem `translateY(-12px)`.
2. Caneta ativa: corpo na cor `brand` + sombra; inativa: corpo `#FFFAF1` (24). Espaço ativo: `brand` (24).
3. ⚠ **Achado da G01 (23b):** com o marca-texto ativo, a caneta continua pintada como ativa e o marca-texto como inativo — decisão no relatório.

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `ann.toolShelf` | radiogroup | Ferramentas de anotação |  |
| `ann.toolShelf.pen` | radio | Caneta | aria-checked=true |
| `ann.toolShelf.pen.art` |  |  | aria-hidden=true |
| `ann.toolShelf.marker` | radio | Marca-texto | aria-checked=false |
| `ann.toolShelf.marker.art` |  |  | aria-hidden=true |
| `ann.toolShelf.eraser` | radio | Borracha | aria-checked=false |
| `ann.toolShelf.eraser.art` |  |  | aria-hidden=true |
| `ann.toolShelf.lasso` | radio | Laço — selecionar e mover traços | aria-checked=false |
| `ann.toolShelf.lasso.art` |  |  | aria-hidden=true |
| `ann.toolShelf.line` | radio | Linha reta | aria-checked=false |
| `ann.toolShelf.line.art` |  |  | aria-hidden=true |
| `ann.toolShelf.space` | radio | Espaço — arrastar entre as linhas para abrir lugar de escrever | aria-checked=false |
| `ann.toolShelf.space.art` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `ann.toolShelf.pen.art` | AppSvg(AppIllustrationsLeitor.il_ferramenta_caneta_ativa, size: 50×70) | cores dinâmicas: #B6ACE4 = brand, #FF552E = ink |
| `ann.toolShelf.marker.art` | AppSvg(AppIllustrationsLeitor.il_ferramenta_marcatexto, size: 50×70) |  |
| `ann.toolShelf.eraser.art` | AppSvg(AppIllustrationsLeitor.il_ferramenta_borracha, size: 50×70) |  |
| `ann.toolShelf.lasso.art` | AppSvg(AppIllustrationsLeitor.il_ferramenta_laco, size: 50×70) |  |
| `ann.toolShelf.line.art` | AppSvg(AppIllustrationsLeitor.il_ferramenta_reta, size: 50×70) |  |
| `ann.toolShelf.space.art` | AppSvg(AppIllustrationsLeitor.il_ferramenta_espaco, size: 50×70) |  |

## Interações

- Tocar escolhe a ferramenta; tocar de novo na ativa abre o painel dela (telas 23/23b).

## Dados

- Ferramenta atual (`pen_presets`).

## Subfases

- **L22c.1** Prateleira e ordem de pintura
- **L22c.2** Estado ativo (sobe 12 + cor)
- **L22c.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('ann.toolShelf'), todos os ids de `kRef22.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/22_modo_anotacao_390x844@3x.png` no recorte da fase (y 656–754) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L22c.1 Prateleira e ordem de pintura
- [ ] L22c.2 Estado ativo (sobe 12 + cor)
- [ ] L22c.3 Verificação + relatório
- [ ] Geometria 13/13 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
