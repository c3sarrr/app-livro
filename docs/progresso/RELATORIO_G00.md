## Relatório — FASE G00: Preparação e checkpoint

> 03/10/2026 · branch `feat/app-completo` · decisões do Cesar no mesmo dia: Q2 (R$ 9,99/R$ 79,99), Q12 (commitar e limpar), Q13 (13+), Q5 adiada.

### Entregue
- Commits (branch `feat/app-completo`, a partir de `main`/`e82aa7d`):
  - `9bf3d49` feat(inicio): fases F10–F13 — recém-chegados, navegação, integração e QA final (79 arquivos)
  - `41d2b4d` docs(handoff): pacote v2 — leitor (telas 19–27b), dados reais, nuvem e assinatura (+ `.gitattributes`: `handoff_v2/** -text`)
  - fix(inicio): `text-wrap: pretty` na frase da meta + goldens 360/430 (fecha a F13 13.3)
  - chore(g00): checksums do handoff_v2, decisões aprovadas e relatório
- Removidos (autorizado): `lib/tmp_rb.dart`, `test/tmp_probe_diff_test.dart`; `test/home/failures/` restaurado.
- `lib/core/design_system/text/app_text.dart`: novo `AppTextWrap { wrap, pretty }` (`text-wrap: pretty` do Chromium).
- `lib/features/home/presentation/sections/reading_day_card.dart`: frase da meta com `textWrap: AppTextWrap.pretty`.
- `test/design_system/app_text_pretty_test.dart` (4 testes) · `test/home/qa_widths_test.dart` (agora confere as LINHAS em 360, não só a contagem).
- `handoff_v2/CHECKSUMS.txt` (36 arquivos: original, extraído, prévias, fontes, SQL) + `test/handoff/handoff_v2_checksums_test.dart`; dev_dependency `crypto ^3.0.7`.
- `docs/progresso/G00_versoes.txt` (flutter doctor -v) · `docs/progresso/G00_flutter_test.txt` (saída completa da suíte).

### Checklist (100%)
- [x] Prompt v2 e anexos lidos — evidência: este relatório segue §6 G00.
- [x] Versões registradas — `G00_versoes.txt` (Flutter 3.47.2 · Dart 3.13.2 · Windows 10 22H2 · Android SDK 37).
- [x] Commit de F10–F13 (Q12) — `9bf3d49`. Não havia commit "só fim de linha" a separar: depois de o Git atualizar o índice, só 19 arquivos tinham mudança real (os outros ~70 eram só data de modificação).
- [x] Resíduos removidos e `test/home/failures` restaurado.
- [x] **F13 13.3 fechada** — goldens 360/430 gerados e comparados (tabelas abaixo): 10/10 seções `PASSOU` nas duas larguras.
- [x] Branch `feat/app-completo` criada.
- [x] `handoff_v2/CHECKSUMS.txt` + teste (36/36).
- [x] Identificador do app — **não trocado** (Q5 = decidir depois; obrigatório até a G27).
- [x] `dart format` 0 alterações · `flutter analyze` **No issues found** · `flutter test` **547 passaram** (543 da Início + 4 do `pretty`) + teste de checksums (1) = 548.

### Bug encontrado e corrigido (a comparação visual de 360 nunca tinha rodado)
- Sintoma: em 360 px a seção `today` **FALHOU** (`blur_mismatch_% = 1,0865`). Na referência medida a frase da meta quebra "Faltam 12 min / para fechar a meta / de hoje."; o app quebrava "Faltam 12 min para / fechar a meta de / hoje.".
- Causa: o parágrafo do arquivo usa `text-wrap: pretty`. Em 390 ele dá o mesmo resultado do quebrador guloso (por isso a F07 passou), mas em 360 o guloso deixa a viúva "hoje." e o Chromium reequilibra. O teste da F13 só conferia a contagem de linhas (3), não o texto.
- Correção: `AppTextWrap.pretty` no `AppText` — só age quando o guloso deixa uma viúva (última linha com uma palavra); reequilibra as últimas 4 linhas minimizando a soma dos quadrados das folgas, mantendo o número de linhas. Medido no Chromium: A = 93,91 / 127,55 / 53,92 (custo 3.809) × B = 127,66 / 93,81 / 53,92 (custo 3.816) → A, igual ao arquivo. Em 390 o resultado é idêntico ao guloso (golden do canvas inalterado). Semântica sem as quebras inseridas (teste).
- Única ocorrência de `text-wrap` no arquivo da Início (busca no HTML).

### Verificação
| Seção | w360 antes | w360 depois | w430 |
|---|---|---|---|
| header | 0,0 | 0,0 | 0,0 |
| headline | 0,1366 | 0,1366 | 0,1128 |
| hero | 0,0 | 0,0 | 0,0 |
| alsoReading | 0,0 | 0,0 | 0,0 |
| **today** | **1,0865 FALHOU** | **0,0 PASSOU** | 0,0 |
| forYou | 0,0 | 0,0 | 0,002 |
| club | 0,0 | 0,0 | 0,0004 |
| recent | 0,0 | 0,0 | 0,0 |
| bottomFade | 0,0 | 0,0 | 0,0 |
| nav | 0,0 | 0,0 | 0,0 |

(`blur_mismatch_%`, gate ≤ 0,5; evidências em `build/visual_diff/G00/w360` e `w430`.)
- Geometria 360/430: 248/248 (`qa_widths_test`), agora com as linhas da frase conferidas.
- Suíte: `02:15 +547: All tests passed!` (`G00_flutter_test.txt`).

### Decisões usadas
- Q2 → D-26 APROVADA · Q12 aprovada · Q13 = 13+ (entra na G05/G25) · Q5 adiada (D-35). Registrado em `handoff_v2/05_DECISOES_E_PERGUNTAS.md`.

### Riscos/pendências (de ambiente — não bloqueiam a G01)
1. **Android toolchain:** `flutter doctor` não executa o Java configurado (`C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\java`). Necessário só para gerar APK (G27). Correção: reinstalar o JDK 17 (Temurin) ou apontar para o JDK do Android Studio: `flutter config --jdk-dir="C:\Program Files\Android\Android Studio\jbr"`.
2. Visual Studio (apps Windows) não é necessário — o alvo é Android/iOS.
3. iOS: sem Mac nesta máquina (pendência prevista para as fases de build/TestFlight).
4. Nada foi enviado ao GitHub (`origin`) — push só quando você pedir.

✅ FASE G00 concluída — aguardando sua aprovação para iniciar a FASE G01.
