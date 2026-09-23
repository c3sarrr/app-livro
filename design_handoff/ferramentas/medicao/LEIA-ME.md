# Como as referências foram medidas (para repetir nas próximas telas)

1. `extrair_bundle.py` — abre o bundle do Claude Design e extrai o HTML real + fontes.
2. Renderização no Chromium (Playwright ≥ 1.56) com `--font-render-hinting=none` (avanços fracionários, como no Flutter).
3. `measure.js 100` — aplica `zoom: 100` ao `<body>` (bordas de 1,5 e 1,2 px ficam exatas — o Chromium arredonda larguras
   de borda para pixel inteiro — e as métricas de fonte deixam de ser arredondadas), neutraliza `transform` e mede o
   retângulo de layout de cada elemento mapeado em `idmap.json` (índice `data-dc-tpl` → id semântico), as linhas de texto
   (retângulo por caractere) e as larguras intrínsecas.
4. `supershot.js` — screenshot com `zoom: 10` em blocos, costurado e reduzido (BOX) para @1x/@2x/@3x.
5. `build_layout.py` — gera `layout_inicio.json`; `gen_tables.py` — as tabelas das fases.
6. `perturb.js` — acrescenta largura a todos os textos e vê quais ids mudam x/w → `text_dependency.json`
   (esses ids ganham tolerância horizontal ±1,0 em `kTextDependentX`).
7. `gen_reference_dart.py layout_inicio.json text_dependency.json > reference_layout.dart` — referência Dart dos testes.
8. Larguras fluidas (validação secundária da F13): `widths.js` (mede 360 e 430 + blocos de imagem com zoom 10) →
   `envolver_layout_fluido.py layout_w360_cru.json layout_inicio.json 360 > layout_w360.json` →
   `gen_reference_dart.py --flat layout_w360.json > reference_layout_w360.dart` (idem 430).
9. `knife.js` — detecta quebras de linha em "fio de navalha" (folga < 1,5 px) para decidir onde forçar `\n`.
Requer Node + `playwright`, Python 3 + `pillow`, `numpy`, `fonttools`, `brotli`.
