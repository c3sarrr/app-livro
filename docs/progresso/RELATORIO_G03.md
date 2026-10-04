# Relatório da FASE G03 — Domínio, banco local e fixture do mundo de referência

Data: 04/10/2026 · branch `feat/g03-dominio` (a partir de `feat/g02-spikes`) · nada enviado ao GitHub.
Evidências de cada subfase: `docs/progresso/G03.md`.
Decisão usada sem resposta sua: **Q20 adotada provisoriamente** (a recomendação do relatório G02, provada no S2) — confirme abaixo.

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G03.1 IDs e relógio | `core/data/ids/uuid_v7.dart` (RFC 9562, ordem estrita mesmo com o relógio voltando) · `core/data/clock/hlc.dart` (texto no formato da RPC; `send`/`receive`; regra do ADR-003 `sendAfterReading`) | 27 testes; **10.000 eventos em 3 aparelhos com ±5 min**: todos únicos, ordem do texto = ordem do valor, monotonia por aparelho, causalidade respeitada, nenhum acima de agora + 5 min; LWW com a regra: **0** edições perdidas de 3.000 (sem a regra: > 500) |
| G03.2 Domínio | 10 entidades (`UserBook`, `ReadingPosition`, `ReadingSession`, `Bookmark`, `Annotation`, `InkLayer`, `HighlightLabel`, `ReaderSettings`, `PenPresets`, `ReadingGoals`) com `copyWith`/igualdade e **os CHECKs do SQL**; `Locator`/`TextAnchor` do Anexo 03 §5 (formato desconhecido preservado sem perda); contagens derivadas do Anexo 02 §4.2 | 41 testes + 8 de semântica de valor |
| G03.3 Banco local | `AppDatabase` (drift): 10 tabelas pessoais = `personal.*` (STRICT, CHECKs em SQLite, `_extras`) + 9 só locais + FTS5; esquema do PowerSync só com **tabelas próprias** (`put` LWW, `delete` que não apaga); fila só no Pro; `LocalVersioning.write` (porta única das versões); 10 DAOs + `KvDao`; instantâneo do esquema v1 + teste de migração | 34 testes, inclusive sobre a **conexão real do PowerSync** (fila 0 no Grátis; PUT com a linha inteira no Pro; `put` antigo não sobrescreve; coluna nova vai para `_extras`; `delete` só registra) |
| G03.4 Contrato | `tools/contracts/gerar_contrato_personal.py` (information_schema do Postgres com o SQL aplicado) | SQL = information_schema = banco local: **126 colunas** (10 tabelas), nomes, ordem e tipos; mutação (tirar 1 coluna da fila) é pega |
| G03.5 Fixture | `test/fixtures/mundo_2026_09_20.dart` + `telas/t19…t27b` + `telas/inicio.dart`; sumário de 148 capítulos (`tools/fixtures/gerar_sumario_dom_casmurro.py`) | 22 testes: o mundo passa por **todos os CHECKs do banco** e volta igual; **Anexo 01 §14 inteiro** (12 = 6+2+1+3; págs. 3/6/41/121/152/159 ↔ sumário; marcas XXV=1, XXXI=2, XXXII=5; "faltam 18"; 3 marcadas e a fita pressionada; rótulos 5/3/2/2; 18 min hoje) |
| G03.6 Início | `HomeMockRepository` saiu de `lib/` e é montado do mundo, **sem mudar nenhum valor**; `lib/` sem dado de usuário | os 645 testes que já existiam continuam verdes, agora com a fixture |

Commits: `02c99aa` G03.0 · `42166e9` G03.1 · `369e7f9` G03.2 · `a2312c0` G03.3 · `b3244f0` G03.4 · G03.3-correção (revisão) · G03.5 · G03.6 · G03.7 (este relatório).

Qualidade: `flutter analyze` **sem problemas** · `dart format` **0** mudanças (224 arquivos) · **`flutter test` = 782 verdes** (eram 645) · cobertura de linhas ≥ 85 % em tudo o que é novo (domínio 99–100 %, DAOs 99,6 %, `home/application` 100 % — `tools/coverage/resumo.py`).

Revisão independente: um agente separado leu tudo contra o SQL, os anexos e os ADRs. Os achados e o que fiz:

- **Corrigido:** a regra "receive antes do send" agora é atômica (ler, versionar e gravar numa transação) e um gatilho recusa qualquer versão local menor que a gravada.
- **Corrigido:** um HLC salvo mais de 5 min no futuro é ignorado ao abrir o app.
- **Corrigido:** os DAOs recusam um 2º livro com o mesmo arquivo e um 2º rótulo com a mesma cor (índices únicos do servidor).
- **Corrigido:** `started_at` ficou imutável e ≥ 2024 (regras da RPC).
- **Corrigido:** as cores favoritas seguem só o CHECK do SQL.
- **Corrigido:** os localizadores da fixture ficaram coerentes.
- **Virou pergunta:** o último achado é a Q26.

## Preciso da sua decisão

| # | O quê | Recomendação |
|---|---|---|
| **Q20** | Confirmar o banco local com **tabelas próprias** (o padrão antigo apagou 10.000 → 0 linhas no S2) + regra do HLC + `_extras` — já implementado assim na G03 | **sim** |
| **Q25** (nova) | A Início e o Leitor **não mostram o mesmo estado** de Dom Casmurro, ao contrário do que o Anexo 01 §14 supõe. Divergem em 4 números: <br>• capítulo: "Cap. 92 de 148" × XXXII <br>• meta do clube: "até o cap. 100" × cap. L (50) <br>• destaques do livro: 14 × 12 <br>• grifos hoje: 2 × 1 <br>Progresso 62 %, "2h 10min", 18 min hoje e o encontro de quinta 24/09 batem. **(A)** manter cada prancha com os seus valores (como está) · (B) alinhar a Início ao Leitor quando ela ganhar dados reais (G08) | **A** |
| **Q26** (nova) | Sem o mock em `lib/` (regra §4.3.1), o `main()` de produção abre a Início **sem fonte de dados até a G08**: aparece a tela de erro. O app com os dados do arquivo roda com `flutter run -t test/fixtures/main_mundo_referencia.dart`. **(A)** manter assim até a G08 · (B) antecipar um estado mínimo "sem dados" (D-21) | **A** |
| Q21–Q24, Q7, Q8 | Continuam abertas do relatório G02 (bloqueiam G06, G07, G09–G11, G24) | ver relatório G02 |

## O que a G03 não resolve (anotado nos ADRs)

- **G06:** relógio do aparelho mais de 5 min adiantado faz a RPC recusar (`invalid_hlc`) as escritas do período. Falta medir a defasagem pela hora do servidor e reenfileirar com versão nova as linhas recusadas (ADR-003).
- **G06:** conferir no upload os índices únicos que vêm de outro aparelho.
- **G09/G16/G17:** a fixture ainda não tem traços de tinta (`strokes_b64` vazio). Os do arquivo (`referencia/svg_tinta`) entram com o codec BNK1 no app.
- **G09/G16/G17:** os deslocamentos das âncoras usam o "texto canônico de fixture" (só trechos literais do arquivo). O EPUB de fixture da G09 tem de ser montado com esses textos.
- **Sumário:** só XXV–XXXVII e a pág. 3 do cap. I são do arquivo. As outras páginas são interpoladas pelo texto real e alguns capítulos curtos do fim começam na mesma página (números ilustrativos, D-19).
- **Ambiente** (sem mudança): sem emulador/aparelho e JDK do Android quebrado; sem Mac.

## Ferramentas e skills

Conferido no início da fase: usei a skill de TDD (teste antes do código). A ordem foi seguida à risca na G03.1, com 27 testes falhando antes do código. Nas outras subfases a falha inicial foi de compilação (classe ou código gerado ainda inexistente), complementada por controles de mutação. Nenhuma skill ou plugin instalado cobre drift, PowerSync ou Flutter de forma útil aqui. Também usei: Flutter 3.47.2/Dart 3.13.2 (Windows), drift 2.35.1 + drift_dev, powersync 2.4.0, Postgres 16.15 (contrato) e o texto de Dom Casmurro do Projeto Gutenberg (#55752, domínio público), baixado pelo spike S3.

## Próxima fase

A frase de parada segue a regra (G03 → **G04 — Supabase: migrations, RLS, testes, Edge Functions**). A ordem sugerida no §11 do prompt mestre põe o leitor antes do backend (G03 → **G09 — Importação e conteúdo canônico**). Diga qual prefere.
