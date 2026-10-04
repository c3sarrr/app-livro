# PROMPT MESTRE v2 — BookNest em Flutter: telas do Leitor (19–27b), dados reais, nuvem e assinatura

> Versão 2.0 · 03/10/2026 · Idioma de trabalho: português do Brasil
> Continua o **PROMPT MESTRE v1** (`design_handoff/00_PROMPT_MESTRE.md`, tela Início, fases F00–F13 — concluídas). Tudo o que a v1 exige de fidelidade **continua valendo**; esta versão acrescenta telas novas, dados reais, backend, sincronização, pagamentos e publicação.
> Pacote: `handoff_v2/` na raiz do repositório `app_livros` (Windows: `C:\Users\T-Gamer\Desktop\app_livros`).
> Anexos (leitura obrigatória quando a fase pedir):
> `01_INVENTARIO_TELAS.md` · `02_ARQUITETURA_DADOS.md` (+ `sql/`) · `03_MOTOR_DO_LEITOR.md` · `04_ASSINATURA_E_PAGAMENTOS.md` · `05_DECISOES_E_PERGUNTAS.md`

---

## 0. Como usar (para o humano)

1. O pacote `handoff_v2/` já está na pasta do app. **Não** mexa em `design_handoff/` (pacote da v1, protegido por checksum nos testes).
2. Antes da G00, responda as perguntas do `05_DECISOES_E_PERGUNTAS.md` §4 que puder (principalmente **Q1** telas 01–18, **Q12** commit pendente, **Q5** identificador do app, **Q13** público adulto ou não). As outras podem esperar a fase que elas bloqueiam.
3. Abra uma sessão nova do Claude com a pasta `app_livros` conectada (ou o Claude Code dentro da pasta) e cole **este arquivo inteiro** como primeira mensagem.
4. O agente executa **uma fase por vez**, entrega o relatório com checklist 100 % e **para**. Você responde **"OK, próxima fase"** ou pede correções.
5. Credenciais (Supabase, RevenueCat, lojas, Sentry…) **nunca** no chat: o agente cria `env/*.example.json`; você preenche os arquivos reais localmente (fora do git).

---

## 1. Papel e missão (para o agente)

Você atua ao mesmo tempo como:

- **Engenheiro de software nível PhD**: Flutter/Dart (renderização Skia/Impeller, `dart:ui`, SkParagraph, layout de texto e paginação), sistemas *local-first* e sincronização (HLC, last-writer-wins, filas de saída), Postgres/Supabase (RLS, particionamento, funções `security definer`, pgTAP), segurança mobile (OWASP MASVS), LGPD, monetização mobile (Google Play Billing, StoreKit, RevenueCat).
- **Designer de produto sênior**, que nunca aceita "parecido" e protege a experiência de leitura.

**Missão — três frentes, nesta ordem de prioridade:**

1. **M1 · Leitor:** levar as 13 pranchas novas (19–27b: leitor limpo, controles, seleção, modo anotação, caneta, marca-texto, espaço aberto, nota à mão, grifos e notas, ajustes, tema Noite, sumário, marcadas) para o app, **idênticas ao arquivo** (mesmo protocolo da v1) e **funcionando de verdade** (EPUB/PDF reais, grifos, tinta, posição, tempo).
2. **M2 · Dados reais:** trocar o mock por dados reais em todo o app — banco local para todas as contas, social na nuvem para todos, dados pessoais na nuvem só para o Pro, catálogo/scanner de custo quase zero, sincronização entre aparelhos.
3. **M3 · Produto publicável:** assinatura Pro (mensal/anual) com as lojas, liberação de recursos decidida no servidor, retenção de 12 meses, LGPD, notificações, observabilidade, CI/CD e publicação em teste interno (Play) e TestFlight (iOS).

As telas **01–18 ainda não chegaram** (o arquivo começa na 19). A arquitetura e as fases já preveem o encaixe delas (§6, trilha T).

---

## 2. Estado atual do repositório (auditado em 03/10/2026)

- Pacote Dart `app_leitura` · Flutter **3.47.2** stable · Dart **3.13.2** (Windows) · `python3` = 3.11.9 com Pillow/numpy (o `python` da máquina é 3.7 — use sempre `python3`).
- Dependências: `flutter_riverpod ^3.4.3`, `flutter_svg ^2.3.0`, `go_router ^18.0.1` (+ `flutter_lints`).
- **Tela Início pronta (F00–F13):** geometria 248/248, visual 0,0 %, **541 testes passando + 2 pendentes** (goldens 360/430 ainda não gerados — F13 13.3: rodar `flutter test --update-goldens test/home/golden_widths_test.dart` e as duas comparações do `RELATORIO_FASE_13.md`). Depois disso: **543**.
- **Git:** último commit `e82aa7d` (F07–F09). O trabalho de F10–F13 está **fora do git**: 146 arquivos modificados (a maioria só fim de linha CRLF) — 22 com mudanças reais em `lib/`, `test/` e `pubspec.yaml` — e vários `docs/progresso/F10…F13` não rastreados. **Primeira coisa da G00: commitar isso (com autorização — Q12).**
- Resíduos a remover (com autorização): `lib/tmp_rb.dart`, `test/tmp_probe_diff_test.dart`; restaurar `test/home/failures/`.
- Identificador ainda é o padrão `com.example.app_leitura` (precisa mudar antes das lojas — D-35).
- Rotas já existentes (`lib/app/router.dart`): abas `/inicio` `/biblioteca` `/clubes` `/perfil`; tela cheia `/scanner` `/notificacoes` `/leitor/:bookId` `/livro/:bookId` `/livro/:bookId/destaques` `/para-voce` `/clube/:clubId/discussao`; debug `/_ds`. Todas, menos a Início, são `PlaceholderScreen`.
- Dados: `HomeMockRepository` (síncrono, valores exatos do arquivo, "agora" = domingo 20/09/2026 20:00 — D-09) + `HomeSnapshot` (`lib/features/home/domain/models.dart`).
- Design system pronto em `lib/core/design_system/` (tokens, `AppText`, pintores: hachura, tracejado Chromium, anéis, dial, meia-lua; primitivos: `NeoBox`, `Pill`, `CountBadge`, `CircleIconButton`, `AppSvg`, `Pressable`, `StadiumProgressBar`).
- Ferramentas de medição da v1: `design_handoff/ferramentas/medicao/` (`extrair_bundle.py`, `measure.js`, `supershot.js`, `build_layout.py`, `gen_reference_dart.py`, `gen_tables.py`, `widths.js`, `perturb.js`…) e `tools/compare_images.py`.

> Se trabalhar pela pasta conectada (ponte do app Claude): o shell não apaga arquivos sem permissão e um `git status` comum pode deixar `.git/index.lock` para trás. Use **`git --no-optional-locks`** em comandos de leitura e confirme que não ficou `index.lock` antes de terminar a fase.

---

## 3. Hierarquia da verdade (em conflito, vence o item de cima)

1. **HTML originais do Claude Design**:
   - Início: `design_handoff/referencia/original/Redesign mobile — App de leitura.html`
   - Leitor 19–27b: `handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html` (bundle com 13 páginas aninhadas — cada prancha é outro bundle com runtime próprio e props `{{paper}}`, `{{brand}}`, `{{ink}}`)
   - Telas 01–18: quando chegarem, em `handoff_v2/referencia/original/`.
2. **Medições geradas na G01** (`handoff_v2/referencia/layout/*.json`, `reference_layout_<tela>.dart`, PNGs @1x/@2x/@3x, recortes, redlines).
3. Marcação literal extraída: `handoff_v2/referencia/extraido/<tela>.body.html`.
4. **Prévias não medidas** `handoff_v2/referencia/previa/*.png` — só para orientar; **nunca** usar como gate.
5. Este prompt e os anexos.
6. Docs do projeto no claude.ai ("app livros"): `monetizacao/plano_gratis_vs_pro.md` (v3) e o handoff da Início.

Divergência entre fontes → **pare e pergunte**. Não escolha sozinho. **Exceção:** as divergências já decididas da lista D-51 (Anexo 05) — aplique a decisão e registre no relatório.

---

## 4. Regras absolutas

### 4.1 Ritmo (igual à v1)
1. **Uma fase por vez.** Leia este prompt + o anexo/arquivo da fase. Não implemente nada de fases futuras.
2. **Checklist obrigatório** na ferramenta de tarefas (ou `docs/progresso/G<NN>.md`). Item marcado só **com evidência** (teste, print, medida, saída de comando).
3. **Gate de saída:** 100 % do checklist, todos os testes verdes → relatório (§9) → **PARE** com a frase exata:
   `✅ FASE G<NN> concluída — aguardando sua aprovação para iniciar a FASE G<NN+1>.`
4. Bloqueio (credencial, decisão, ambiguidade, ferramenta) → **pare e pergunte**. Exceções previstas: pendências de ambiente escritas na própria fase (ex.: build iOS sem Mac) — registrar com o comando exato e seguir.
5. Correções pedidas viram subfase `G<NN>.x-correção` com checklist próprio. Fases aprovadas não são reescritas sem pedido.
6. **Commits pequenos** ao fim de cada subfase, em branch `feat/g<NN>-<assunto>`, mensagens em português no formato `tipo(escopo): descrição` (ex.: `feat(leitor): paginação por páginas de referência`). Nada de `push --force`, nada de reescrever histórico.

### 4.2 Fidelidade visual (herdada da v1 — continua inegociável)
Valem integralmente as seções **3.2, 3.3, 5, 5.1, 6 e 7 da v1**: sem `Icons.*`, sem `google_fonts`, sem arredondar medidas, sem cores do Material, sem remover decorações, sombras duras só com `BoxShadow(blur 0)`, nada de widgets Material com estilo padrão nem ripple, 1 px CSS = 1 dp, todo texto via `AppText`, semântica = `aria-*` do arquivo, verificação em 4 camadas (geometria ±0,5 px, estilo exato, golden `blur_mismatch_% ≤ 0,5`, texto/quebras idênticos).

Ajustes da v2:
- **Figtree 800 é real nas telas 19–27b** (D-16); na Início continua 700 (D-14). Gerar a família estática w800 a partir do binário do arquivo novo.
- **Literata** (corpo do leitor) é variável com optical size → D-17 (spike S1). Novas famílias da Bricolage: 15,5 / 17 / 23. Lora e Atkinson Hyperlegible entram só como opções do leitor.
- Fontes completas (itálico, negrito, latin-ext…) **só para o conteúdo do livro** (D-18).
- Estados que o arquivo não tem (carregando, vazio, erro, offline…) seguem a D-21 — nunca "inventar design" além dela.
- Elementos de interação não desenhados (editor de nota, busca no livro, menu "Mais opções", paywall…) seguem D-23 ou **esperam o design** — nada além disso.

### 4.3 Dados
1. **Nenhum dado de usuário escrito no código de produção.** Os valores do arquivo vivem só na **fixture de teste** "mundo de referência" (D-34) e nos testes de fidelidade.
2. **Grátis: dados pessoais nunca saem do aparelho** (Anexo 02 §1–2). Qualquer chamada de rede com dado pessoal de usuário Grátis é bug crítico (teste automatizado que intercepta o cliente HTTP).
3. IDs = UUIDv7 gerados no aparelho; datas em UTC (`timestamptz`/ISO-8601) e exibição no fuso do usuário (padrão `America/Sao_Paulo`); dinheiro nunca em `double` (o preço vem formatado da loja).
4. Todas as contagens e textos derivados (ex.: "faltam 18", "≈ 2 h 10 min", "Tudo 12") são **calculados** a partir dos dados, com teste que reproduz exatamente o texto do arquivo usando a fixture.
5. Esquema local ≡ esquema `personal.*` do servidor (teste de contrato).
6. Migrações: nunca destrutivas para dados do Grátis (são a única cópia).
7. **O que o Grátis pode enviar à rede (lista branca do teste de privacidade):** login/sessão; perfil e `profile_stats` (só agregados, via `publish_my_stats`); posts, comentários e curtidas que a pessoa publica; ações de clube (entrar, responder, progresso de capítulo publicado no clube, grifo que ela escolheu compartilhar); consultas de catálogo por **ISBN ou texto de busca** (sem a estante); token de push; Sentry (sem PII) e analytics só com consentimento. Qualquer outra coisa com dado pessoal = bug crítico.
8. Tabelas pessoais: as mesmas tabelas próprias do drift para Grátis e Pro, com `delete` do PowerSync que não apaga e fila de upload só no Pro (Anexo 02 §3.1, ADR-002/003 — evita o PowerSync apagar a única cópia ao perder o Pro).

### 4.4 Segurança e privacidade
1. Chave `service_role` e segredos **só** em Edge Functions/CI. O app leva apenas chaves públicas (URL + anon key, chaves públicas do RevenueCat, DSN do Sentry) via `--dart-define-from-file=env/<ambiente>.json` (arquivos reais no `.gitignore`; `env/*.example.json` versionados).
2. RLS ligada em **todas** as tabelas; toda política nova com teste pgTAP de acesso **permitido e negado**.
3. Liberação do Pro decidida no **servidor** (RLS/RPC/regras de sync); o app só melhora a experiência.
4. `android:allowBackup="false"` e banco local excluído do iCloud (senão o "só neste celular" do Grátis é falso).
5. Logs sem dado pessoal (sem texto de grifo, sem e-mail); analytics só com consentimento.
6. Excluir conta: dentro do app, imediato, apaga servidor + Storage + RevenueCat.

### 4.5 Qualidade de código
`dart format` sem diffs · `flutter analyze` sem nenhum problema (inclusive *info*) · widgets `const` · nada de lógica de negócio em widget · Riverpod para estado (sem singletons globais) · repositórios atrás de interfaces (`abstract interface class`) com implementação real + *fake* de teste · erros tipados (`sealed class` de falhas) · nenhum `print` (usar o logger do app) · cobertura de testes ≥ 85 % em `domain/` e `application/` dos módulos novos.

---

## 5. Arquitetura alvo (resumo — detalhes nos anexos 02, 03 e 04)

```
┌──────────────────────────── App Flutter (Android + iOS) ────────────────────────────┐
│ UI (features/*) ── Riverpod ── casos de uso (application/) ── domínio (domain/)      │
│                                     │                                               │
│   Repositórios ─┬─ Banco local SQLite (PowerSync SDK + drift) ← TODAS as contas      │
│                 ├─ Sync Pro: PowerSync ⇄ Supabase (upload pela RPC, LWW por HLC)     │
│                 ├─ Social online: Supabase (PostgREST/RPC/Realtime) + cache local    │
│                 ├─ Catálogo: catalog.db no aparelho → Worker+R2 → comunidade → APIs  │
│                 ├─ Arquivos: e-books no aparelho; Pro → Storage `ebooks` (2 GB)      │
│                 └─ Pagamentos: RevenueCat SDK (UX)                                    │
└──────────────────────────────────────────────────────────────────────────────────────┘
Supabase Pro (sa-east-1): Postgres 17 · Auth (Apple, Google, e-mail OTP) · Storage · Edge Functions
  (revenuecat-webhook, isbn-lookup, ebook-upload-url, export-data, delete-account, email-sender,
   purge-storage, push-sender) · pg_cron (partições, retenção, sync_access)
PowerSync (Cloud ou self-host em SP — ADR-003) · Cloudflare R2 + Workers (catálogo) · RevenueCat
FCM/APNs · Sentry · PostHog (opt-in) · Resend (e-mail)
```

### 5.1 Pastas (estende a estrutura feature-first da v1)

```
lib/
  app/            app.dart · router.dart · bootstrap.dart (env, Sentry, Supabase, RevenueCat, PowerSync) · env.dart
  core/
    design_system/  (existente) + tokens/reader_themes.dart, reader_typography.dart, novos pintores
                    (ondulado, hachura roxa do espaço, roda de cores, régua pautada) e primitivos novos
    data/           database/ (schema PowerSync, drift, DAOs, migrações locais) · sync/ (conector, status)
                    · ids/uuid_v7.dart · clock/hlc.dart · contracts/ (teste de contrato com o servidor)
    auth/           auth_repository.dart · session_controller.dart · account_deletion.dart
    billing/        billing_service.dart (RevenueCat) · entitlement_controller.dart · paywall_triggers.dart
    network/        supabase_client.dart · edge_functions.dart · connectivity.dart · retry.dart
    telemetry/      logger.dart · crash_reporting.dart · analytics.dart (opt-in)
    l10n/           formatters compartilhados (datas "2 set", "QUI 24/9", durações, plurais)
  features/
    home/           (existente) data/ ganha a implementação real; o mock vai para test/fixtures (D-34)
    reader/         domain/ (conteúdo canônico, localizador, âncora, páginas de referência, ajustes)
                    engine/ epub/ pdf/ layout/ (paginador) typography/
                    annotations/ (grifos, notas, tinta: modelo, codec BNK1, suavização, ferramentas, espaços)
                    application/ (reader_controller, session_tracker, annotation_controller, undo_stack)
                    presentation/ (19 clean_page · 20 top_island/bottom_island/scrubber/time_chip ·
                                   21 selection_toolbar · 22 annotation_bar/tool_rack · 23 pen_panel ·
                                   23b marker_panel · 24 space_opener · 24b handwritten_note ·
                                   26 reader_settings_sheet · 27 toc_sheet/bookmarks_tab)
    highlights/     tela 25 (lista, filtros, busca FTS, exportar)
    library/ book/ scanner/ clubs/ profile/ notifications/ paywall/ onboarding/ settings/
                    (dados e repositórios agora; telas quando o design 01–18 chegar)
supabase/   config.toml · migrations/ · tests/ (pgTAP) · functions/ · seed.sql
workers/catalog/   Cloudflare Worker (ISBN por prefixo no R2)
tools/      compare_images.py · medicao/ (cópia adaptada da v1) · catalog/ (pipeline dos dumps) · fonts/
test/       fixtures/ (mundo de referência) · reader/ · highlights/ · data/ · billing/ · home/ (existente)
integration_test/   fluxos ponta a ponta
docs/       adr/ · progresso/ (G00…) · privacidade/ (mapa de dados LGPD)
env/        dev.example.json · stg.example.json · prod.example.json
```

---

## 6. Trilhas e fases

Legenda de tamanho: **P** (≤ 1 dia de agente) · **M** (2–4) · **G** (5+). Ordem recomendada no §11.

### Trilha 0 — Base

#### G00 · Preparação e checkpoint (P)
Objetivo: começar de um repositório limpo, versionado e com a v1 fechada.
- [ ] Ler este prompt inteiro e os 5 anexos (só leitura).
- [ ] `flutter doctor -v`, versões de Flutter/Dart/Java/Gradle/Xcode (se houver Mac) → `docs/progresso/G00_versoes.txt`.
- [ ] Com autorização (Q12): normalizar fim de linha conforme `.gitattributes` e commitar F10–F13 em `chore(inicio): fecha fases F10–F13` (separar o commit de "só fim de linha" do commit de código, se o diff permitir).
- [ ] Com autorização: remover `lib/tmp_rb.dart`, `test/tmp_probe_diff_test.dart`; `git restore test/home/failures`.
- [ ] Fechar a pendência da F13 (13.3): gerar goldens 360/430 e rodar as duas comparações → todas as seções `PASSOU`; `flutter test` = 543 passando.
- [ ] Criar branch `feat/app-completo` (base das fases).
- [ ] Gerar `handoff_v2/CHECKSUMS.txt` (sha256 **só** de `referencia/original/`, `referencia/extraido/`, `referencia/previa/`, `referencia/fontes_do_arquivo/` e `sql/` — a G01 vai escrever `referencia/layout/` e `referencia/png/`) + teste que confere (igual ao da v1).
- [ ] Se Q5 respondida: trocar o identificador (`applicationId`, `namespace`, pacote Kotlin, `PRODUCT_BUNDLE_IDENTIFIER`) e rodar a suíte.
- [ ] Relatório G00.

#### G01 · Medição do arquivo novo e geração das fases de tela (M)
Objetivo: transformar o bundle das 13 pranchas em referências medidas e em arquivos de fase com tabelas, exatamente como a v1 fez para a Início.
- [ ] Copiar `design_handoff/ferramentas/medicao/` para `tools/medicao/` e adaptar `extrair_bundle.py` para **bundles aninhados** (página raiz com `__bundler/page_order`; cada prancha = outro bundle com manifest/template próprios; runtime `dc-runtime` + React; props `{{paper}}`/`{{brand}}`/`{{ink}}` com os padrões do Anexo 01).
- [ ] Renderizar cada prancha isolada no Chromium (390×844; a 25 em 390×2170), com fontes embutidas e rede bloqueada; validar que a renderização bate com as prévias.
- [ ] Medir: retângulos de layout por elemento (ids semânticos com prefixo da tela: `r19.*`, `r20.*`, `r21.*`, `ann.*`, `pen.*`, `mk.*`, `sp.*`, `hn.*`, `hl.*`, `rs.*`, `toc.*`, `bm.*`), linhas de texto com baseline, estilos computados, `text_dependency.json`.
- [ ] PNG de referência @1x/@2x/@3x (supersample 10×), recortes por seção e *redlines* numerados → `handoff_v2/referencia/png/`.
- [ ] Fontes: gerar com `tools/fonts/build_fonts.py` (adaptado) Figtree w800 (D-16), Bricolage 15,5/17/23, Literata (estáticas por tamanho **e** a variável — para o spike S1), Lora, Atkinson; subsets latin/latin-ext/vi como na v1; licenças OFL.
- [ ] Ícones SVG do arquivo (cores aplicadas) → `assets/icons/leitor/`; ilustrações (prateleira de ferramentas, amostras de ponta, roda de cores de referência) → `assets/illustrations/leitor/`.
- [ ] Gerar os arquivos de fase **L19 … L27b** em `handoff_v2/fases/` (um por tela; telas grandes divididas por seção: ex. `L20a_ilha_superior`, `L20b_ilha_inferior`, `L20c_chip_tempo`), cada um com: HTML literal da seção, tabela pixel a pixel (id, x, y, w, h, estilo), linhas de texto, armadilhas, checklist — mesmo formato de `design_handoff/fases/F05_hero_continuar_lendo.md`.
- [ ] Mapa id → widget e lista de tokens novos (cores, raios, sombras, estilos de texto) para a G11.
- [ ] Reprodutibilidade: rodar a medição 2× → mesmos hashes.
- [ ] Relatório G01 com a lista de fases L geradas, para aprovação.

#### G02 · Spikes técnicos e ADRs (M)
Objetivo: provar as decisões arriscadas antes de construir (Anexo 05 §2). Cada spike numa pasta `spikes/Sx_*` fora do `lib/`, com números.
- [ ] **S1 Fonte variável:** Literata variável com `FontVariation('opsz', s)` vs estática por tamanho vs Chromium — largura de 50 linhas do livro, desvio máximo; decisão D-17 → ADR-004.
- [ ] **S2 Banco + sync:** PowerSync + drift + Supabase local (`supabase start`): criar o esquema pessoal, escrever offline, conectar, sincronizar 10 mil linhas, 2 aparelhos com edições cruzadas, FTS5 local, migração de esquema, replicação da tabela particionada, payloads reais (`CrudEntry`) contra `sync_apply_changes` (jsonb em texto, recusas), região de hospedagem/LGPD, custo. **Critérios eliminatórios** (Anexo 02 §3.1): Grátis em `localOnly` sem fila crescendo; virar Pro sobe tudo; **perder o Pro não apaga nada local** (inclusive com reembolso detectado já conectado); voltar depois do purge repovoa a nuvem — cada um com modo avião no meio → ADR-002/003 (com o plano B documentado).
- [ ] **S3 Paginação:** paginar um **EPUB de fixture com o texto exato do arquivo** no estado padrão → as **19 linhas** da tela 19 idênticas (altura de linha arredondada a 1/64 px como o Chromium; offsets descontando o U+FFFC do recuo); tempo por página com o EPUB real de domínio público; calibrar o N das páginas de referência (D-19) → ADR-005.
- [ ] **S4 Tinta:** latência do traço a 60/120 Hz (dedo e caneta), suavização, codec BNK1 ida e volta → ADR-006.
- [ ] **S5 Pagamentos:** compra sandbox (Android; iOS se houver Mac) com RevenueCat + webhook numa Edge Function local → ADR-007.
- [ ] ADR-001, 008, 009, 010 escritos (Anexo 05 §2).
- [ ] Relatório G02 com os números e as recomendações finais; **perguntar** as decisões que mudaram.

### Trilha A — Dados

#### G03 · Domínio, banco local e fixture do mundo de referência (M)
- [ ] Entidades puras em `features/*/domain` e `core/data` (Anexo 02 §4) com `copyWith`/igualdade; `uuid_v7.dart`; `hlc.dart` (+ teste de 10 mil eventos em 3 aparelhos com relógio defasado).
- [ ] Esquema local (PowerSync `Schema` + drift) espelhando `personal.*` + tabelas só locais (Anexo 02 §3.3); DAOs com testes em memória.
- [ ] **Fixture "mundo de referência"** (`test/fixtures/mundo_2026_09_20.dart`): todos os dados da Início **e** do Leitor (Dom Casmurro cap. XXXII pág. 159/256, 12 anotações da tela 25, 3 marcadores, rótulos, clube, sumário 148 caps.) + **um instantâneo por prancha** (`test/fixtures/telas/t19.dart` … `t27b.dart`, D-34) + asserções de consistência do Anexo 01 §14.
- [ ] `HomeMockRepository` → passa a ser construído a partir da fixture (sem mudar nenhum valor); os 543 testes continuam verdes.
- [ ] Teste de contrato de colunas (lista do SQL ↔ `Schema` local).
- [ ] Relatório.

#### G04 · Supabase: migrations, RLS, testes, Edge Functions base (M)
- [ ] `supabase init` + `config.toml`; quebrar `handoff_v2/sql/01_schema_booknest.sql` em migrations por assunto; `supabase db reset` limpo.
- [ ] pgTAP (`supabase/tests/`): converter os 23 testes de fumaça + 1 caso permitido e 1 negado **por política**.
- [ ] Edge Functions esqueleto (Deno/TS) com testes: `revenuecat-webhook`, `isbn-lookup`, `ebook-upload-url`, `export-data`, `delete-account`, `email-sender`, `purge-storage`, `push-sender`.
- [ ] pg_cron: agendar **todas** as rotinas do Anexo 02 §8 (partições, `refresh_sync_access`, retenção, `email-sender`, `purge-storage`, `quota-cleanup`, `cold-backup`), com nomes e horários.
- [ ] Toda migration termina com o bloco de REVOKE dos privilégios padrão do Supabase + GRANT por coluna (seção 10 do SQL); teste pgTAP que falha se `anon`/`authenticated` tiverem privilégio de tabela além do previsto.
- [ ] Projetos `dev`/`stg`/`prod` (após Q6), região São Paulo; `env/*.example.json`.
- [ ] CI do banco: `supabase db lint`, `supabase test db`, varredura de segredos.
- [ ] Relatório com `EXPLAIN (ANALYZE, BUFFERS)` das consultas quentes (Anexo 02 §10) em dados sintéticos (100 mil usuários).

#### G05 · Conta, login e direitos do titular (M)
- [ ] Supabase Auth: Entrar com Apple, Google e e-mail (OTP); deep links de retorno; sessão segura (`flutter_secure_storage`).
- [ ] Modo convidado se Q3 = sim (tudo local; vincular dados locais ao criar conta, sem enviar nada pessoal se a conta for Grátis).
- [ ] Idade mínima / verificação conforme a Q13 (ou parar e perguntar, se ainda sem resposta).
- [ ] Onboarding técnico mínimo (D-21) até o design chegar; escolha do @ (`handle`).
- [ ] Excluir conta (in-app) → Edge Function `delete-account` (servidor + Storage + RevenueCat) + opção de apagar os dados locais; página web de pedido de exclusão (exigência do Google Play).
- [ ] Exportar dados (regra D-24).
- [ ] Teste que **falha** se um usuário Grátis enviar dado pessoal pela rede (interceptador HTTP).
- [ ] Relatório.

#### G06 · Sincronização Pro e e-books na nuvem (G)
- [ ] Conector PowerSync: `fetchCredentials` (JWT do Supabase), `uploadData` em lotes ≤ 500 para `public.sync_apply_changes`, tratamento de erro (`pro_required` → desconectar e avisar; rede → repetir com recuo).
- [ ] Regras de sync (Anexo 02 §6.2 — Sync Streams) publicadas; publicação lógica `powersync` **sem** `publish_via_partition_root` (ADR-003; já criada e testada na G04).
- [ ] Modo Pro ⇄ Grátis (Anexo 02 §3.1, ADR-002/003): virar Pro → ligar a fila, reenfileirar tudo como `PUT` e subir (com progresso); perder o Pro → desligar a fila e desconectar na expiração prevista, sem apagar nada local; voltar (antes ou depois do purge) → reenfileirar tudo e reconectar.
- [ ] Tratar a resposta da RPC: `rejected` (erro permanente: dado inválido, referência de outro usuário, HLC no futuro) → tirar da fila, gravar em `sync_rejections`, enviar ao Sentry (sem conteúdo); **erro da chamada inteira** (rede, 5xx, conflito/trava transitória — a RPC relança esses) → manter tudo na fila e repetir com recuo exponencial.
- [ ] Teste com 2 aparelhos simulados (offline, edições cruzadas, apagar num e editar no outro) → estados iguais.
- [ ] E-books na nuvem: upload **só por URL assinada** emitida pela Edge Function `ebook-upload-url` (confere Pro e cota de 2 GB); retomada de upload só se o S2 provar que funciona com URL assinada (senão, upload em partes pela própria função); download sob demanda no 2º aparelho.
- [ ] Indicador discreto de sincronização (sem design → D-21).
- [ ] Relatório.

#### G07 · Catálogo e scanner reais (G)
- [ ] `tools/catalog/`: pipeline dos dumps (Open Library CC0; DNB CC0) → `catalog.db` (top-N) + shards do R2 + manifestos; documentação de licença por fonte.
- [ ] Worker Cloudflare `workers/catalog` (ISBN por prefixo, cache, limite por IP) + testes.
- [ ] No app: download do `catalog.db` em segundo plano no Wi-Fi com retomada e delta; resolução ISBN em camadas (aparelho → Worker → comunidade → `isbn-lookup` com cota).
- [ ] Scanner com `mobile_scanner` (validação ISBN-10/13, 978-65) e OCR da capa para "adicionar este livro" (camada comunitária).
- [ ] Medir a taxa de falha final numa amostra de ISBNs brasileiros reais (relatório).
- [ ] A **tela** do scanner aguarda o design (telas 01–18); até lá, rota `/scanner` com a câmera e o mínimo da D-21.
- [ ] Relatório.

#### G08 · Início com dados reais (M)
- [ ] `HomeRepository` real (Riverpod, assíncrono, *stream* do banco local): continuar lendo, também lendo, dia de leitura (meta, sequência, semana via `reading_sessions`), para você (heurística por autores da estante + catálogo — computada no aparelho), clube (Supabase + cache), recém-chegados.
- [ ] Estados carregando/vazio/erro conforme D-21 (o caminho "com dados" continua idêntico ao arquivo).
- [ ] Alturas das barras com a regra da D-10 para dados reais.
- [ ] Todos os testes de fidelidade da Início continuam verdes **com a fixture**; novos testes com dados reais (banco em memória).
- [ ] Relatório.

### Trilha B — Leitor (telas 19–27b)

Cada fase de tela = **funcional + dados + fidelidade** (executa os arquivos L gerados na G01; verificação em 4 camadas contra as referências medidas, usando a fixture).

#### G09 · Importação e conteúdo canônico (M) — Anexo 03 §2–5
- [ ] Importar EPUB/PDF (seletor + "Abrir com"), cópia com SHA-256 em *stream*, dedupe, metadados, capa, ISBN → catálogo.
- [ ] Parser EPUB 2/3 (OPF, spine, nav/ncx) → blocos + texto canônico NFC (em *isolate*); DRM detectado com mensagem.
- [ ] `book_content_index` + localizador/âncora + reancoragem com teste de propriedade (≥ 99 %).
- [ ] Acervo de domínio público, se Q11 = sim.
- [ ] Relatório.

#### G10 · Paginação, páginas de referência e posição (G) — Anexo 03 §6–8
- [ ] Paginador `dart:ui` em fatias ≤ 4 ms com cache; recuo por `PlaceholderSpan`; títulos com a linha seguinte; imagens.
- [ ] Páginas de referência (D-19) com o N calibrado na G02; percentuais; sumário com páginas de início.
- [ ] Posição salva/restaurada (primeiro caractere visível) ao mudar ajustes, girar, reabrir.
- [ ] Tempo automático (D-27) + tempo restante (≈) com velocidade pessoal.
- [ ] Gate: as 19 linhas da tela 19 idênticas; orçamentos de desempenho do Anexo 03 §12 medidos.
- [ ] Relatório.

#### G11 · Tela 19 — leitor limpo (+ tokens dos 4 papéis) (M)
- [ ] Fases L19 (geometria, estilo, texto, golden) + virar página (D-22) + rodapé "pág. X de Y · %" com números tabulares.
- [ ] Tokens de papel/texto dos 4 temas (Anexo 01) e da cor `brand` global (D-33).
- [ ] Rota `/leitor/:bookId` real (substitui o placeholder).
- [ ] Relatório.

#### G12 · Telas 20 e 26b — controles, chip de tempo, marcador, tema Noite (M)
- [ ] Ilhas superior/inferior, esmaecimento da página, barra de posição com balão, ferramentas (Fonte, Tema, Grifos com contador, Anotar, Sumário), fita do marcador (toggle real), chip "N min hoje · contando sozinho".
- [ ] Tema Noite completo (26b) com os tokens medidos — sem inversão automática de cor.
- [ ] Botão Tema (D-37); busca no livro mínima (D-23).
- [ ] Relatório.

#### G13 · Tela 21 — seleção e grifos (M)
- [ ] Seleção própria (pressão longa, alças, lupa D-45, limite de página D-47), barra de ações nas posições do arquivo.
- [ ] Grifar (4 cores + outra cor D-38 + sublinhar), Nota (editor mínimo D-23), Copiar/Compartilhar (D-39), Buscar.
- [ ] Pintura dos grifos (fundo em 3 alturas, sublinhado) por baixo do texto; sobreposição (D-32).
- [ ] Relatório.

#### G14 · Tela 26 — ajustes de leitura (M)
- [ ] Folha com prévia ao vivo usando o **mesmo motor**; tamanho (7 passos), fonte (4), papel (4), entrelinha (3), margens (3) — valores D-20 após Q10.
- [ ] Repaginação mantendo o localizador; persistência em `reader_settings`.
- [ ] Relatório.

#### G15 · Telas 27 e 27b — sumário e marcadas (M)
- [ ] Sumário do EPUB com numerais como no livro, páginas de início, marcas por capítulo (símbolos por tipo + número — regra do Anexo 02 §4.2; "1 marca" no singular, D-51), "lido", capítulo atual com anel e pílula "você está na pág. N", faixa do clube ("Até o cap. L · faltam 18") a partir dos dados do clube.
- [ ] Aba Marcadas: lista, excerto, "marcada em 2 set"/"hoje", tirar marca, dica final.
- [ ] Relatório.

#### G16 · Tela 22 — modo anotação e motor de tinta (G)
- [ ] Topo (pílula + Concluir), página deslocada e travada, prateleira de ferramentas (objetos do arquivo; a ativa sobe), barra (rótulos, poço de cor, espessura, desfazer/refazer).
- [ ] Entrada de tinta (Anexo 03 §9.3), suavização por ponta, 2 dedos movem a página, rejeição de palma, latência ≤ 1 quadro.
- [ ] Caneta, Borracha, Laço (D-46), Reta; ancoragem `over_text` (D-29); codec BNK1; desfazer/refazer; autosave; Concluir salva em transação; Voltar = Concluir (D-42).
- [ ] Relatório.

#### G17 · Telas 23 e 23b — painéis da caneta e do marca-texto (M)
- [ ] Caneta: prévia pautada, pontas, espessura em mm (D-28), favoritas (+ salvar), roda de cores HSV + brilho + hex (pintores próprios).
- [ ] Marca-texto: prévia com linha real, estilos Fundo/Sublinhado/Ondulado, cores com rótulos e contagens (D-40), "Editar rótulos", altura; conversão traço → grifo ("gruda nas palavras").
- [ ] Relatório.

#### G18 · Telas 24 e 24b — espaço aberto e nota à mão (M)
- [ ] Ferramenta Espaço: costura entre linhas, arrasto com encaixe em linhas inteiras, rótulo vivo, hachura roxa tracejada, texto descendo (D-41).
- [ ] Caixa da nota à mão: etiqueta, recolher, apagar, alça de altura; tinta normalizada na caixa; repaginação com espaços.
- [ ] Relatório.

#### G19 · Tela 25 — grifos e notas (M)
- [ ] Lista em slivers na ordem do livro com separadores de página e "você parou aqui"; cartões por tipo e por grupo (`group_id`, D-30); miniaturas de tinta em cache; chip do clube.
- [ ] Filtros (tipo exclusivo com contagens, cores múltiplas, "Só do clube"), busca FTS5, "Mais opções" (D-23), Exportar (D-24), "Continuar lendo · pág. N".
- [ ] Rota `/livro/:bookId/destaques` real.
- [ ] Relatório.

#### G20 · Integração do leitor (M)
- [ ] Início ↔ leitor (hero "Continuar" abre na posição; com dados reais valem as **relações** do Anexo 01 §14 — contagens que somam, páginas crescentes, capítulo coerente — não os números literais do arquivo), Voltar do sistema por camadas, restauração de estado, rotação bloqueada (D-06).
- [ ] Acessibilidade do leitor (Anexo 03 §11) com testes de semântica.
- [ ] Orçamentos de desempenho (Anexo 03 §12) medidos em aparelho real (pendência de ambiente se não houver aparelho).
- [ ] Relatório.

### Trilha C — Social e clubes

#### G21 · Social e clubes: dados e pontos já desenhados (M)
- [ ] Repositórios: perfil, `profile_stats` (publicar agregados — `publish_my_stats`), seguidores (pedido para perfil fechado), bloqueio, posts, comentários, curtidas, clubes, convites (`join_club`), encontros, posts do clube, respostas, denúncias; Realtime para respostas do clube.
- [ ] Entrar em clube: por convite (`join_club`) e em clube público sem convite (`join_public_club` — "participar de todos" do Grátis).
- [ ] Ligar aos pontos que já existem: ticket do clube na Início, faixa do sumário (27), chip "Leitoras de Capitu · 3 respostas" e filtro "Só do clube" (25), "compartilhar no clube" a partir de um grifo (cria `club_posts kind=shared_highlight`, guarda `shared_club_post_id`).
- [ ] Prévia de perfil para o Grátis (sem texto) e conteúdo completo para o Pro — testes.
- [ ] Moderação (D-52): denunciar, bloquear, filtro de palavras na publicação, fila de moderação interna (tabela `content_reports` + painel simples só para administradores via Edge Function), meta de resposta ≤ 24 h, aceite dos termos antes de publicar.
- [ ] As **telas** de clubes, perfil, discussão e notificações aguardam o design 01–18.
- [ ] Relatório.

### Trilha D — Assinatura

#### G22 · Pro com RevenueCat (M) — Anexo 04
- [ ] Produtos nas lojas e no RevenueCat (após Q2/Q5); `Purchases.configure/logIn/logOut`; ouvinte de `CustomerInfo`.
- [ ] Webhook completo (idempotência, reconciliação pela API, `entitlements`, `sync_access`, ciclo de retenção).
- [ ] Gatilhos de paywall (Anexo 04 §7) com limite de frequência; **tela de paywall só com design** — até lá, tela técnica de teste atrás de *flag* de debug.
- [ ] Restaurar compras, gerenciar assinatura, textos obrigatórios das lojas.
- [ ] Matriz de testes sandbox do Anexo 04 §9.
- [ ] Relatório.

### Trilha E — Produção

#### G23 · Notificações (P)
- [ ] FCM/APNs (`firebase_messaging`), token salvo em `device_tokens` ao entrar e removido ao sair/excluir conta.
- [ ] Edge Function `push-sender` disparada por eventos (resposta no clube, novo seguidor/pedido, encontro do clube amanhã), com agrupamento (no máximo 1 push por clube a cada 10 min) e respeito às preferências.
- [ ] Notificação local da meta diária (horário escolhido; nunca se a meta já foi batida).
- [ ] Permissão pedida no momento certo (depois de entrar no 1º clube ou ativar a meta), nunca na abertura.
- [ ] Testes: unidade da Edge Function; integração em aparelho (pendência de ambiente se não houver).

#### G24 · Observabilidade e analytics (P)
- [ ] Sentry (falhas + desempenho) com `beforeSend` que remove PII; teste que tenta logar texto de grifo/e-mail e confirma que não sai.
- [ ] Logger do app (níveis, sem `print`), correlação com o id da sessão (não o id do usuário).
- [ ] PostHog **opt-in** (tela de consentimento mínima D-21); taxonomia de eventos em `docs/analytics.md` (nome, quando dispara, propriedades permitidas).
- [ ] Painel de saúde: falhas por versão, tempo de abertura do leitor, sucesso de sync, recusas da RPC, taxa de falha final do ISBN, custo de API externa por dia.

#### G25 · Segurança e LGPD (M)
- [ ] Modelo de ameaças STRIDE (`docs/seguranca/ameacas.md`) e checklist OWASP MASVS-L1 com evidência item a item.
- [ ] Build ofuscado (`--obfuscate --split-debug-info`), certificados/chaves fora do git, `gitleaks` limpo.
- [ ] Revisão de RLS e grants por um **agente independente** (que não escreveu o SQL) + pgTAP de acesso negado em 100 % das políticas.
- [ ] `allowBackup=false` + `dataExtractionRules` (Android 12+) + exclusão do iCloud — teste de restauração confirmando que o banco do Grátis não volta.
- [ ] Textos-base da política de privacidade e dos termos (mapa de dados do Anexo 02 §12, transferência internacional, retenção, direitos) para revisão de advogado; encarregado (DPO) e canal publicados; plano de resposta a incidentes (D-53).
- [ ] Menores de idade conforme a resposta da Q13 (verificação etária, controles, classificação nas lojas).
- [ ] Fluxos de direitos do titular testados ponta a ponta (exportar, corrigir, excluir, revogar consentimento).

#### G26 · Desempenho e carga (M)
- [ ] Perfil em aparelho Android intermediário (e iPhone, se houver): orçamentos do Anexo 03 §12 medidos e anexados.
- [ ] k6: RPC de sync (lotes de 500), Worker do catálogo, Edge Functions (`isbn-lookup`, `revenuecat-webhook`) — p95 e taxa de erro sob a carga do cenário "lançamento 3×" do doc de monetização.
- [ ] `EXPLAIN (ANALYZE, BUFFERS)` das consultas quentes com 1 milhão de usuários sintéticos (Anexo 02 §10); ajustes de índice com antes/depois.

#### G27 · CI/CD, ambientes e publicação (M)
- [ ] Ambientes dev/stg/prod (`--dart-define-from-file`, ids/ícones/nomes distintos); `env/*.example.json` versionados.
- [ ] GitHub Actions: format, analyze, testes (inclui goldens), pgTAP, testes das Edge Functions, gitleaks — obrigatórios para *merge*.
- [ ] Assinatura Android (keystore fora do git, Play App Signing); iOS com fastlane ou Codemagic (pendência de ambiente sem Mac).
- [ ] Faixa de teste interno no Play e TestFlight com a conta de revisão (credenciais de teste para a Apple, D-48).
- [ ] Ficha da loja (textos, capturas a partir dos goldens), classificação etária, formulário de segurança de dados do Play e rótulos de privacidade da App Store coerentes com o Anexo 02 §12; URL da página de exclusão de conta.

#### G28 · QA final (M)
- [ ] Fidelidade de todas as telas (Início + 19–27b + as que chegarem) nas 4 camadas.
- [ ] Fluxos ponta a ponta: Grátis offline, virar Pro, 2º aparelho, cancelar, retenção simulada (relógio adiantado no stg), excluir conta, reembolso.
- [ ] Matriz offline/online (modo avião no meio de cada fluxo) e de permissões negadas (câmera, notificações).
- [ ] Auditoria anti-simplificação (v1 F13.4 estendida às telas novas) e revisão independente final.
- [ ] Relatório final com tudo que ficou pendente de ambiente/jurídico.

### Trilha T — Telas 01–18 (quando o arquivo chegar)
Para cada arquivo novo: **G01-bis** (medição + fases L01…L18) → uma fase por tela (funcional + dados + fidelidade, igual à trilha B) → integração com as rotas existentes e com os dados das trilhas A/C/D. Inserir no mapa (§11) e na tabela do Anexo 01 §0.

---

## 7. Protocolo de verificação (todas as fases)

| Camada | O quê | Gate |
|---|---|---|
| 1. Geometria | `getRect(ValueKey(id))` vs referência medida | ±0,5 px (±1,0 em x/w para ids dependentes de texto) |
| 2. Estilo | cor, borda, raio, sombra, alpha, fonte, peso, tamanho | exato |
| 3. Visual | golden @3x vs PNG do HTML (`tools/compare_images.py`) | `blur_mismatch_% ≤ 0,5` por seção |
| 4. Texto | strings, quebras, reticências, baselines | idênticos / ±0,5 px |
| 5. Unidade | domínio, formatadores, motor, codec, HLC | 100 % verdes, cobertura ≥ 85 % nos módulos novos |
| 6. Banco | pgTAP (permitido + negado por política), contrato de colunas | 100 % verdes |
| 7. Integração | fluxos do relatório da fase (`integration_test`/Patrol) | verdes em Android (e iOS se houver Mac) |
| 8. Desempenho | orçamentos do Anexo 03 §12 e Anexo 02 §10 | dentro do orçamento |
| 9. Privacidade | interceptador de rede do Grátis; logs sem PII | nenhum vazamento |

Comandos padrão ao fim de cada fase (quando se aplicam):
```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test                                   # inclui fidelidade, unidade e contrato
supabase test db                               # a partir da G04
deno test supabase/functions                   # a partir da G04
python3 tools/compare_images.py --flutter <golden> --ref <png de referência> --scale 3 --layout <layout.json> --out build/visual_diff/<fase>
git --no-optional-locks status --short         # nada esquecido; sem .git/index.lock
```
Quando só o gate visual falhar e as outras camadas estiverem verdes: regra da v1 §7 (diferença de forma/cor/posição = bug; só rasterização = parar e pedir decisão).

---

## 8. Roteiro de cada fase

1. Ler a fase e os anexos citados. 2. Criar o checklist item a item. 3. Para cada subfase: teste primeiro quando possível (TDD em domínio/motor/banco) → implementação → testes → commit. 4. Auto-revisão (para telas: referência, redline e golden lado a lado, tabela linha por linha; para dados: casos negados e limites). 5. Comandos do §7. 6. Relatório (§9) → **PARAR**.

## 9. Modelo do relatório

```
## Relatório — FASE G<NN>: <título>
### Entregue
- arquivos criados/alterados · migrations · funções · commits (hash + mensagem)
### Checklist (100%)
- [x] item — evidência: <teste/print/medida/saída>
### Verificação
- Fidelidade (se houver tela): geometria X/Y (maior desvio), estilo, visual (tabela), texto
- Unidade/integração: N testes · cobertura dos módulos novos
- Banco: pgTAP N/N · EXPLAIN das consultas novas
- Desempenho: números vs orçamento
- Privacidade/segurança: interceptador do Grátis, segredos, RLS
- flutter analyze: 0 · dart format: ok · flutter test: N passaram
### Decisões usadas (D-xx) e decisões que preciso de você
### Riscos/pendências (vazio para concluir, salvo pendências de ambiente previstas)

✅ FASE G<NN> concluída — aguardando sua aprovação para iniciar a FASE G<NN+1>.
```

## 10. Decisões fora do arquivo

D-01…D-15 (v1) continuam. D-16…D-53 estão no `05_DECISOES_E_PERGUNTAS.md` como **PROPOSTA**: use-as como padrão, mas registre no relatório cada uma que você aplicou; se o Cesar recusar uma, abra uma subfase de correção. Não crie decisão nova sem perguntar.

## 11. Mapa e ordem recomendada

```
G00 → G01 → G02 ─┬─▶ G03 → G04 → G05 → G06 ───────────────┐
                 │            └──▶ G07                     │
                 ├─▶ G09 → G10 → G11 → G12 → G13 → G14 → G15 → G16 → G17 → G18 → G19 → G20
                 │                   (G11+ usam a fixture; não dependem do backend)
                 └─▶ G08 (depois de G03 e G21)   G21 (depois de G04)   G22 (depois de G05/G06)
G23 → G24 → G25 → G26 → G27 → G28   (depois das trilhas A–D)
Trilha T (telas 01–18): entra assim que o arquivo chegar, depois da G01-bis.
```
Ordem sugerida de execução: G00, G01, G02, G03, G09, G10, G11, G12, G13, G14, G15, G04, G05, G16, G17, G18, G19, G20, G06, G07, G21, G08, G22, G23–G28 (o leitor primeiro, porque é o coração do produto e não depende do backend).

## 12. Definição de pronto (v1.0 nas lojas)

- Início + telas 19–27b (+ 01–18 quando chegarem) idênticas ao arquivo nas 4 camadas, com dados reais.
- Grátis 100 % offline e sem nenhum dado pessoal no servidor (teste automatizado).
- Pro: compra, restauração, sincronização entre 2 aparelhos, e-books na nuvem, cancelamento, retenção de 12 meses — testados em sandbox.
- Social e clubes funcionando com RLS testada (permitido + negado).
- Scanner com custo de API externa medido e dentro do teto.
- `flutter analyze` limpo, todas as suítes verdes, desempenho dentro do orçamento, CI verde.
- Publicado em teste interno (Play) e TestFlight; política de privacidade e termos revisados por advogado.

**Comece agora pela FASE G00.**
