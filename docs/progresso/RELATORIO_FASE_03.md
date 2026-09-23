## Relatório — FASE 3: Seção 1 — Cabeçalho (avatar, saudação, sino)

### Entregue
- Seção: `lib/features/home/presentation/sections/header_section.dart` (`HeaderSection`, construção obrigatória da fase; lê do snapshot só `user` e `now`).
- `lib/features/home/presentation/home_screen.dart`: o placeholder `header` virou `HeaderSection()` (1 import + 1 linha).
- Testes (14 novos): `test/home/geometry_header_test.dart` (3), `text_header_test.dart` (2), `style_header_test.dart` (7), `semantics_header_test.dart` (2).
- Helper de teste: `test/support/geometry_report.dart` (`reportGeometry`, `reportTextLines` — registram obtido × referência para os relatórios).
- Golden: `test/golden/goldens/inicio_canvas@3x.png` regenerado (agora com o cabeçalho).
- Documentação: `docs/progresso/FASE_03.md`, `F03_verificacao.txt`, `F03_comparacao.md`, este relatório.
- Removido o `.gitkeep` de `presentation/sections/` (a pasta deixou de estar vazia).

### Checklist (100%)
- [x] 3.1 Linha de 48 com `spaceBetween` e centralização vertical — evidência: estrutura conferida; identidade em y + 2; `header` (20, 62, 350, 48)
- [x] 3.1 Avatar 44×44 `#FED170`, borda 1,5, "M" Bricolage18 800 centralizado — evidência: decoração exata; "M" em `avatarInitial`, centro = centro do avatar
- [x] 3.1 Coluna de saudação com gap 1, largura 58,43 e textos esticados — evidência: `IntrinsicWidth` + `stretch` + `spacing: 1`; coluna 58,445 e os 2 textos com essa largura
- [x] 3.1 "Boa noite," Figtree 13/500 `#5B544B`; "Marina" Figtree 16/700 ls −0,1 — evidência: `body13Muted` / `name16` conferidos propriedade a propriedade
- [x] 3.2 Botão 48×48 `#FFFAF1` borda 1,5; ícone `ic_bell.svg` 22 centralizado — evidência: decoração exata; ícone em (13, 13) do botão
- [x] 3.2 Ponto 12×12 `#FF552E` borda `#FFFAF1`, top 9 / right 11, sobre o ícone — evidência: decoração e posição exatas (345,5; 72,5); ordem provada na `Stack` e nos pixels
- [x] 3.3 Semântica "Notificações, 2 novas"; callback; sem ripple — evidência: 1 botão com o rótulo, sem nós filhos; callback por toque e pela ação semântica; sem Ink/Material; só a escala da D-04
- [x] Geometria 9/9 · Texto 3/3 · Estilo OK · Visual ≤ 0,5% · Não-regressão OK — evidência: ver Verificação
- [x] `dart format` / `flutter analyze` (0) / `flutter test` — evidência: 0 mudanças · No issues found! · +214: All tests passed!
- [x] Relatório com o lado-a-lado F03 anexado e inspecionado — evidência: lado a lado, heatmap e ampliação 4× abertos e anexados

### Verificação
- Geometria: 9/9 elementos dentro da tolerância (maior desvio: `header.identity.w` = 0,015 px — largura de texto; os não textuais com Δ 0,000).
- Estilo: 7/7 testes (avatar, "M", saudação e nome, botão e ícone, ponto e posição, ordem de pintura nos pixels, sem ripple + D-04), valores exatos.
- Visual:

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | header (0, 54, 390, 64) | 0,0 | 0,3579 | 0,461 | 142 | PASSOU |
  | header, modo `--layout` | 0,0 | 0,4113 | 0,53 | 142 | PASSOU |
  | não-regressão: inset × golden aprovado da F02 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

  Evidências em `build/visual_diff/F03/` (lado a lado, heatmap, onion e `F03_header_zoom_4x.png`). As diferenças de pixel são só de rasterização: nas formas (ícone, ponto, anéis) Δ massa ≤ 1 % e Δ centroide ≤ 0,035 px; nos textos o antisserrilhado dos glifos sai ~3 % mais claro que o do navegador, igual nos pesos 500/700/800, e há um deslocamento vertical ≤ 0,13 px, que é o arredondamento da baseline ao pixel de dispositivo a DPR 3 (a baseline de layout é exata). Todos os 34.832 pixels alterados em relação ao golden da F02 estão dentro do retângulo do header. Tabela completa em `F03_comparacao.md`.
- Texto: 3/3 (1 linha cada; baselines 91,940 / 80,450 / 99,900 × arquivo 91,94 / 80,45 / 99,9; início/fim a ≤ 0,015 px); strings "M", "Boa noite,", "Marina" derivadas dos dados.
- flutter analyze: 0 problemas · dart format: ok (67 arquivos, 0 mudanças) · flutter test: 214 passaram · `design_handoff/` intacto (131/131).

### Decisões fora do arquivo usadas nesta fase
- D-04 (toque sem ripple, escala 0,97 via `Pressable`), D-09 ("agora" de referência → "Boa noite,"), D-15 (rótulo semântico = `aria-label`).
- Nenhuma decisão nova. Notas:
  1. O ponto de notificação é sempre desenhado, exatamente como no arquivo (não criei um estado "sem notificações", que o arquivo não tem).
  2. `onNotificationsTap` fica sem ligação na tela até a F12 (a fase diz "ligado à rota na F12"). Até lá, na tela real, o botão tem o rótulo e o feedback de toque, mas ainda sem ação.

### Riscos/pendências
- Nenhuma.
- Informativo — git: continua só o commit da F00; F01, F02 e F03 estão sem commit (os arquivos de cada fase estão em caminhos separados; `home_screen.dart` é da F02 com a troca de 1 linha na F03).

✅ FASE 3 concluída — aguardando sua aprovação para iniciar a FASE 4.
