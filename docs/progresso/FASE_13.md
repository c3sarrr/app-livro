# FASE 13 — QA final pixel a pixel e auditoria anti-simplificação

Checklist da fase (`design_handoff/fases/F13_qa_final.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F13_verificacao.txt` · revisão de designer: `F13_comparacao.md` · relatório: `RELATORIO_FASE_13.md`.

- [x] 13.1 Geometria 248/248 no canvas 390×2390 (+ tabela dos 10 maiores desvios)
  - `qa_canvas_test.dart`: 248/248, maior desvio 0,043 px (`hero.cta.label.w`); tabela por seção no relatório.
- [x] 13.1 Texto: todas as linhas/quebras/reticências conferidas (`expectTextLines` em todos os ids com linhas)
  - 88 ids / 100 linhas; 4 em capa rotacionada (só quebras); 2 reticências.
- [x] 13.1 Visual: todas as seções (`--layout`) e o canvas inteiro (sem `--rect`) com `blur_mismatch_% ≤ 0,5`
  - 10/10 seções 0,0; canvas inteiro 0,0 (raw 1,07 %).
- [x] 13.1 Estilo: todos os testes de estilo das fases 3–11 continuam verdes
  - suíte completa: 541 passaram; os 9 `style_*_test.dart` incluídos.
- [x] 13.2 Viewport 390×844 `blur_mismatch_% ≤ 0,5`
  - 0,0 (raw 0,55 %).
- [x] 13.2 Rolagem ao fim registrada (máx. 1511,16; lista termina em y = 704; 19,5 px do FAB; 40 px da barra) + print
  - `qa_viewport_test.dart`; print `build/visual_diff/F13/viewport_fim_da_rolagem@3x.png`.
- [x] 13.3 360: geometria 248/248 ±1,0
- [x] 13.3 430: geometria 248/248 ±1,0
  - `qa_widths_test.dart`: maior desvio 0,043 px nas duas.
- [ ] 13.3 360 e 430: visual ≤ 0,5 % por seção — **PENDENTE**: `flutter test --update-goldens` negado pelo ambiente; goldens `inicio_w360@2x.png` / `inicio_w430@2x.png` ainda não existem. Comandos exatos no relatório.
- [x] 13.3 Casos só-360 sem código especial (título em 2 linhas, meta em 3 linhas, chips em 2 linhas, flex-shrink 168 px)
  - afirmados em `qa_widths_test.dart`; a mesma árvore monta 360/390/430.
- [x] 13.4 Auditoria automática: as 8 buscas com o resultado esperado; checksums OK
  - 0 ocorrências nas 7 buscas (1 comentário do pubspec reescrito); checksums 131/131.
- [x] 13.4 Checklist manual anti-simplificação 100% com evidência
  - `qa_antisimplificacao_test.dart` (7 testes): sombras 7/7, rotações, bordas, 18 SVGs, fontes, pintores, quebras/reticências. Nota: HTML tem 8 hachuras (checklist diz 7).
- [x] 13.5 Revisão de designer registrada (`canvas_lado_a_lado.png`; nenhuma diferença que não seja de rasterização)
  - `F13_comparacao.md` + 9 recortes a 300 %.
- [x] 13.6 Relatório final completo (6 itens)
  - `RELATORIO_FASE_13.md`.
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  - format exit 0 · analyze No issues · `flutter test`: 541 passaram, **2 falharam** (os 2 goldens de 360/430 inexistentes). Fecha junto com a pendência acima.
