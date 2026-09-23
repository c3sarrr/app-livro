# Pacote de handoff — Tela "Início" (App de leitura) → Flutter idêntico

Este pacote transforma o arquivo **`Redesign mobile — App de leitura.html`** (1 tela: Início, 390 × 2390) num
roteiro de implementação em Flutter **fase por fase**, com referências medidas pixel a pixel e testes que
provam a fidelidade.

## Como usar

1. Copie esta pasta para a raiz do repositório Flutter com o nome **`design_handoff/`**.
2. Abra `00_PROMPT_MESTRE.md` e cole o conteúdo inteiro no agente de código (Claude Code, Cursor, etc.).
3. O agente executa a **FASE 0** e para. Revise o relatório e responda **"OK, próxima fase"**.
4. Repita até a **FASE 13**. Nunca libere mais de uma fase por vez.

## Conteúdo

| Pasta/arquivo | O que é |
|---|---|
| `00_PROMPT_MESTRE.md` | Papel, regras absolutas, proibições anti-simplificação, arquitetura (Riverpod + go_router), tradução CSS→Flutter, tipografia, protocolo de verificação, decisões fora do arquivo, mapa das fases |
| `fases/F00…F13` | Uma fase por arquivo (preparação, design system, esqueleto, 8 seções da tela, navegação, integração, QA final), cada uma com HTML literal, tabela pixel a pixel, subfases e checklist de aceite |
| `referencia/original/` | O HTML original (fonte da verdade) |
| `referencia/png/` | Canvas 390×2390 @1x/@2x/@3x (supersample 10×), primeira dobra 390×844 (derivada), recortes por seção, redlines numerados, larguras 360 e 430 |
| `referencia/layout/` | Geometria medida (JSON + Dart para os testes): 248 elementos, linhas de texto, baselines; `layout_w360/w430.json` + Dart para a validação fluida; `text_dependency.json` (ids com tolerância horizontal ±1,0) |
| `referencia/svg_graficos/` | SVGs originais do dial e dos anéis (referência para os pintores) |
| `assets/fonts/` | 36 TTFs estáticos gerados dos mesmos binários do arquivo + licença OFL |
| `assets/icons/` | 14 ícones SVG do arquivo (cores já aplicadas) + 4 estados extrapolados (D-07) |
| `ferramentas/` | `compare_images.py` (gate visual), `build_fonts.py` (regerar fontes), `pubspec_fonts.yaml`, fontes originais convertidas e, em `medicao/`, os scripts de medição e de geração das referências (`gen_reference_dart.py`, `envolver_layout_fluido.py`, `widths.js`, `perturb.js`…) para repetir o processo nas próximas telas |

## Achados importantes do arquivo (já tratados no prompt)

- O arquivo tem **só a tela Início**; Biblioteca, Scanner, Clubes e Perfil aparecem apenas no menu (viram placeholders).
- **Bricolage Grotesque é variável com optical size**: o navegador usa `opsz = tamanho da fonte`. Por isso há uma família por tamanho.
- **Figtree 800 renderiza como 700** no arquivo (o `@font-face` só declara até 700).
- Bordas de **1,5 px e 1,2 px** exatas; sombras duras sem blur; 3 capas rotacionadas.
- Na linha "O Alienista" o CSS encolhe texto e selo (flex-shrink): o selo vira "Quero / ler". O prompt reproduz isso fielmente (D-12).
- A capa do Dom Casmurro quebra o autor em "MACHADO DE / ASSIS" por 0,33 px — quebra forçada documentada.
- O motor de texto do Flutter desloca linhas alinhadas à esquerda em **metade do letter-spacing** (o navegador não). O `AppText` do prompt corrige isso; por isso os títulos de duas linhas com letter-spacing diferente ("Continue / sua história.", "Leitoras de / Capitu") viram duas linhas de texto empilhadas.

## Revisão

Versão 1.1: auditada por uma revisão independente contra o código-fonte atual do Flutter/Skia (compilação dos trechos, semântica, restrições de layout, números). Todas as correções estão aplicadas; os valores das tabelas batem 100% com `layout_inicio.json`.
