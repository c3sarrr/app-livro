# Relatório da FASE G02 — Spikes técnicos e ADRs

Data: 03/10/2026 · branch `feat/g02-spikes` (a partir de `feat/g01-medicao`) · nada enviado ao GitHub.
Evidências de cada subfase: `docs/progresso/G02.md` · decisões: `docs/adr/` (10 ADRs) · provas: `spikes/`.
Escolhas do Cesar no início da fase: Q14–Q19 aceitas (→ D-54…D-59) · S4 e S5 **simulados** (aparelho e compra real ficam pendentes com os passos exatos).

## Resultado

| Spike | Pergunta | Resultado | ADR |
|---|---|---|---|
| **S1** Fonte variável | Literata variável (`opsz`) = Chromium? | **≤ 0,0008 px** por linha em 1.701 linhas (7 tamanhos), quebras **idênticas**; sem `opsz` explícito até 2,04 px; estáticas ≤ 0,0074 px | ADR-004 (D-17 confirmada) |
| **S3** Paginação | 19 linhas da tela 19? custo? N? | **22/22 linhas iguais**, baseline máx **0,0027 px**, golden da página **0,21 %**; achado: o Flutter arredonda a altura de cada linha (sem correção: 4,68 px e golden 9 %); EPUB real: 0,70 ms/página no host, capítulo de 40 págs ≈ 28 ms; parágrafos longos em pedaços com 835/835 linhas idênticas; N = 1.500 → 251 páginas | ADR-005 |
| **S4** Tinta (simulado) | BNK1, suavização, custo | BNK1: 1.000 traços ida e volta, **412 bytes/100 pontos** a 120 Hz, 256 KiB ≈ 8,8 min de tinta; porte do perfect-freehand = npm (erro 5,7 × 10⁻¹⁴); traço ao vivo p95 **24 µs** de CPU (AOT); app de medição pronto | ADR-006 |
| **S2** Banco + sync | PowerSync + drift + RPC, 4 critérios com modo avião | **8/8 cenários** (2 rodadas finais do zero) + lado Dart **5/5**; achado eliminatório: o padrão de views deixa o PowerSync **apagar 10.000 → 0** linhas do aparelho → **tabelas próprias** (10.000 remoções neutralizadas); 10.050 linhas sobem com corte no meio; purge repovoado; LWW com relógios ±5 min | ADR-002 · ADR-003 |
| **S5** Pagamentos (simulado) | Webhook RevenueCat → Supabase | **14/14** (sandbox/produção, duplicado, fora de ordem, carência, reembolso, troca, transferência, RevenueCat fora do ar…), resposta p50 3,7 ms sem a latência da API | ADR-007 |
| ADR-008 (prova extra `S6`) | Taxa de falha do ISBN | 300 ISBNs brasileiros reais: Open Library falha **33,7 %** (48 % nos 978-65); BrasilAPI (CBL) **2,7 %** | ADR-008 |
| ADR-001/009/010 | Backend · observabilidade · notificações | SQL de referência **23/23** refeito; Sentry e PostHog na UE com opções de privacidade conferidas; push com passos de teste em aparelho | ADR-001 · 009 · 010 |

Commits: `66eeb76` G02.0 · `699bee8` + `9e20a3a` G02.1 (o 2º tira do git o `build/` gerado pelo `flutter test`) · `57e096a` G02.2 · `b3ccf13` G02.3 · `159a4eb` G02.4 · `96ba654` G02.5 · `9b101ba` G02.6 · G02.7 (este relatório).

Qualidade: app principal intocado — `flutter analyze` sem problemas, `dart format` 0 mudanças em 154 arquivos, **`flutter test` = 645 verdes**. Cada spike é um pacote próprio (o `analysis_options.yaml` da raiz exclui `spikes/**`) com análise e formatação limpas: S1 8/8 · S3 6/6 · S4 11/11 · S2 Dart 5/5 · S2 Node 8/8 · S5 14/14 (Deno: `fmt`/`lint` limpos).

## Mudanças no plano — preciso da sua decisão (Q20–Q24 no Anexo 05)

| # | O que muda | Por quê (número) | Recomendação |
|---|---|---|---|
| **Q20** | Sync: **tabelas próprias** do drift (o `delete` do PowerSync não apaga; fila só no Pro) no lugar das views "localOnly ↔ sincronizadas"; + Sync Streams, curinga das partições, upload só `PUT`, regra do HLC, `_extras`, data/hora com 6 casas | Ao voltar a rede, o SDK reconecta com o token em cache; com o bucket revogado, apagou **10.000 → 0** linhas. Com tabelas próprias: 0 apagadas | **sim** |
| **Q21** | Leitor: altura de linha **exata** (35,26) e **pintura linha a linha** (vale também para o `AppText` de várias linhas na G11) | O Flutter arredonda a altura de cada linha: 4,68 px na 19ª linha, golden 9 % → 0,21 % com a correção; 18 textos das telas 19–27b passariam de 0,5 px | **sim** |
| **Q22** | D-17 confirmada; usar a Literata variável também na interface e aposentar as 33 estáticas | 259 linhas das pranchas com a variável: ≤ 0,010 px; 1,39 MB → 0,58 MB | **sim** |
| **Q23** | D-19: manter N = 1.500 | 251 páginas (só texto) / 264 (com a licença do Gutenberg); 1.467 daria 256 nesta edição | **1.500** |
| **Q24** | Catálogo: BrasilAPI como 1ª API; ver na G07 se os dados da CBL podem ir para o catálogo compartilhado | Dumps abertos: 33,7 % de falha em livros brasileiros; BrasilAPI: 2,7 % | **sim** |
| Q7 (já aberta) | PowerSync Cloud na **região BR** (existe) × self-host | Self-host provado no S2 (serviço + Postgres, sem MongoDB) | **Cloud BR** |
| Q8 (já aberta) | Sentry (UE, sem PII) + PostHog só com consentimento (UE) | Regiões e opções conferidas na documentação | **sim** |

Informativos (sem decisão sua): a RPC `sync_apply_changes` levou p95 424–559 ms por lote de 500 no Postgres local (meta 400 ms → otimização na G04); `refresh_sync_access()` por usuário na G04; o PowerSync self-host tem licença FSL-1.1-ALv2 (uso próprio permitido; não é parecer jurídico).

## Pendências (com os comandos/passos nos ADRs)

- **S4:** latência do traço em aparelho — `flutter run --profile -t lib/latencia_app.dart` (ADR-006). Bloqueio de ambiente da G00: sem aparelho/emulador e JDK do Android quebrado.
- **S5:** compra sandbox real — contas Apple/Google/RevenueCat e o identificador do app (Q5) antes (ADR-007).
- **ADR-010:** teste de push em aparelho (Firebase + APNs).
- **G04:** `supabase start` (Docker) com Postgres 17 e os 8 cenários do S2 contra ele; aqui o Docker não tem daemon e o C: tem ~6 GB livres.
- **iOS:** sem Mac (gate da tela 19 e latência no iPhone ficam para quando houver).

## Ferramentas e skills

Conferido no início da fase: nenhuma skill/plugin instalada cobre Flutter, PowerSync, Supabase ou RevenueCat; as de documentos não se aplicam a ADRs em Markdown no repositório. Usados: Flutter 3.47.2/Dart 3.13.2 (Windows), Playwright/Chromium 141, Postgres 16, serviço PowerSync 1.27 (npm), Node 24 (npm), Deno 2.9.6 (npm).

## Próxima fase

**G03 — Domínio, banco local e fixture do mundo de referência**: entidades, `uuid_v7.dart`, `hlc.dart` (com a regra `receive` antes do `send`), esquema local no drift (tabelas próprias, se a Q20 for aprovada), DAOs, fixture `mundo_2026_09_20` e teste de contrato com o SQL.
