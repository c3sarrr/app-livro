# Anexo 05 — Decisões fora do arquivo, ADRs e perguntas abertas

> Parte do pacote `handoff_v2/` · versão 2.0 · 03/10/2026
> Regra: **D-01 a D-15** (prompt v1, tela Início) continuam valendo. As decisões abaixo são **PROPOSTAS** até o Cesar aprovar (status muda para APROVADA com a data). O agente não cria decisão nova sem perguntar; se precisar, para e pergunta.

## 1. Decisões propostas (D-16 em diante)

| ID | Decisão proposta | Motivo | Status |
|---|---|---|---|
| D-16 | Nas telas 19–27b, Figtree 800 é **800 de verdade** (família estática `Figtree` w800 gerada do binário do arquivo). Na Início continua D-14 (800 → 700). | O `@font-face` deste arquivo declara 800 sobre a fonte variável; medido no Chromium (423,48 px vs 418,41 px) | PROPOSTA |
| D-17 | Literata como fonte **variável** com `opsz = tamanho` e `wght 400/500` via `fontVariations`; se o spike S1 mostrar desvio > 0,05 px/linha, instâncias estáticas por tamanho | O leitor precisa de 7 tamanhos e 4 fontes; o navegador aplica optical size automático | PROPOSTA |
| D-18 | Para o **conteúdo do livro** (itálico, negrito, latin-ext, grego, cirílico) usar os arquivos completos OFL das 4 fontes (google/fonts). A interface continua só com os binários do arquivo. | O bundle só embute o subconjunto latin regular; livros reais têm itálico/negrito e caracteres fora do latin | PROPOSTA |
| D-19 | **Páginas de referência**: `page-list` da edição impressa se existir; senão 1 página = N caracteres (N inicial 1.500, calibrado com Dom Casmurro ≈ 256). "pág. X" = página do 1º caractere visível. | Número estável entre aparelhos, fontes e membros do clube; bate com "pág. 159 de 256" | PROPOSTA |
| D-20 | Valores não visíveis: tamanhos 16 · 17,5 · 19 · **20,5** · 22 · 24 · 26; entrelinha Justo 1,5 · **Médio 1,72** · Solto 1,95; margens Estreita 20 · **Média 28** · Larga 40 | O arquivo só mostra o estado selecionado | PROPOSTA |
| D-21 | Estados não desenhados (carregando, vazio, erro, offline, sem permissão de câmera, livro sem sumário, arquivo com DRM): versão mínima com primitivos existentes (texto Figtree + botão do design system), listados num doc para o design desenhar depois | Dados reais exigem esses estados; o arquivo não tem | PROPOSTA |
| D-22 | Toque no centro abre/fecha controles; terços laterais e arrasto horizontal viram a página; deslizar 220 ms `easeOutCubic`; barra de posição navega ao soltar | O arquivo não define gestos | PROPOSTA |
| D-23 | Não desenhados → versão mínima provisória: editor de nota (folha com campo de texto), busca no livro, menu "Mais opções" (folha com Editar cor · Compartilhar no clube · Apagar) | Botões existem no arquivo; as telas não | PROPOSTA |
| D-24 | Exportar: **Grátis** exporta os próprios grifos e notas de texto (Markdown e CSV) — portabilidade; **Pro** exporta tudo (inclui desenhos/notas à mão em PDF, histórico, todos os livros) | O doc v3 diz "Grátis: lista CSV". A LGPD prevê portabilidade dos dados do titular — restringir isso ao pago pode ser problemático (confirmar com advogado) | PROPOSTA — **pergunta Q4** |
| D-25 | Modo convidado: dá para usar o app sem conta (tudo local); conta é exigida para social e para assinar | Alinha com "Grátis = só no celular"; reduz atrito | PROPOSTA — **pergunta Q3** |
| D-26 | Preço: R$ 9,99/mês e R$ 79,99/ano, teste grátis 7 dias | Pedido do Cesar (memória do projeto); o doc v3 diz R$ 9,90/R$ 79,90 | **APROVADA 03/10/2026** (preço; o teste grátis segue proposto) |
| D-27 | Tempo automático: conta com leitor visível + app em primeiro plano; pausa após 120 s sem interação; descarta sessões < 10 s; página lida = ≥ 3 s na tela | "contando sozinho" sem inflar números | PROPOSTA |
| D-28 | 1 mm de traço = 160/25,4 ≈ 6,299 dp lógicos; Fina/Média/Grossa = 0,6×/1×/1,8× | O Flutter não expõe o DPI físico de forma confiável | PROPOSTA |
| D-29 | Tinta sobre o texto ancorada na palavra mais próxima, em unidades de em; tinta em espaço aberto em coordenadas normalizadas da caixa | "acompanha se a fonte mudar" (tela 23b) | PROPOSTA |
| D-30 | Agrupamento em cartões (`group_id`) pela regra do Anexo 02 §4.3, gravada na criação | Reproduz os 3 cartões da pág. 159 da tela 25 | PROPOSTA |
| D-31 | Nota à mão sem OCR na v1; rótulo semântico genérico "Nota à mão, <data>"; não entra na busca | O texto do `aria-label` do arquivo só existe porque é um exemplo | PROPOSTA |
| D-32 | Grifos sobrepostos: mesma cor → une; cor diferente → o novo substitui o trecho sobreposto (divide o antigo) | Evita pilhas ilegíveis | PROPOSTA |
| D-33 | A cor `brand` é uma preferência global do app (Início + Leitor + tela 25), mesma lista de 4 opções | É a mesma prop nos dois arquivos | PROPOSTA |
| D-34 | O mock da Início vira **fixture de teste**: um "mundo de referência" base (20/09/2026 20:00) + **um instantâneo por prancha** (as pranchas não saem todas de um único estado — Anexo 01 §14); produção usa só dados reais | Mantém os testes de fidelidade e ganha dados reais | PROPOSTA |
| D-35 | Trocar `com.example.app_leitura` pelo identificador definitivo **antes** do 1º envio às lojas (não muda depois) | O Google Play recusa `com.example`; o id é permanente | PROPOSTA — Q5 adiada pelo Cesar ("decidir depois"); obrigatória até a G27 |
| D-36 | Clubes com **proteção de spoiler**: post marcado com capítulo; membro só vê posts até o próprio capítulo (com opção "mostrar mesmo assim") | Meta "Até o cap. L" sugere leitura em ritmos diferentes | PROPOSTA (fora do arquivo — só com design) |
| D-37 | Botão "Tema" alterna entre o último papel claro e Noite; ícone sol/lua como no arquivo | Atalho do tema na tela 20/26b | PROPOSTA |
| D-38 | "Escolher outra cor" (tela 21) abre o mesmo seletor da tela 23 (roda + brilho + hex) | Reuso; sem tela nova | PROPOSTA |
| D-39 | Copiar/Compartilhar levam o trecho + "— Autor, *Título* (pág. N)" | Útil e comum | PROPOSTA |
| D-40 | Contagem por rótulo do marca-texto = grifos com a cor em **todos** os livros | Única leitura coerente entre 23b e 25 | PROPOSTA |
| D-41 | Espaço aberto: mínimo 1, máximo 12 linhas | Limite razoável | PROPOSTA |
| D-42 | Botão Voltar do sistema: fecha a camada mais alta; no modo anotação = Concluir (salva) | Não perder tinta | PROPOSTA |
| D-43 | PDF: "Fonte" e "Papel" desabilitados (cinza); tinta e grifo por página | PDF tem layout fixo | PROPOSTA |
| D-44 | Grifos que não reancoram vão para "grifos sem lugar" (nunca são apagados) | Segurança dos dados do leitor | PROPOSTA |
| D-45 | Seleção por palavra ao arrastar; por caractere quando a lupa aparece (pressão parada > 300 ms) | Padrão de leitores | PROPOSTA |
| D-46 | Laço: arrastar move; tocar fora solta; apagar com a Borracha (sem menu na v1) | Menu não desenhado | PROPOSTA |
| D-47 | Seleção limitada à página visível na v1 | Simplicidade e fidelidade | PROPOSTA |
| D-48 | Compras **sandbox** liberam o Pro também no backend de produção (a revisão da Apple e o TestFlight usam sandbox), marcadas `environment='sandbox'` e fora dos relatórios | Sem isso o app é rejeitado na revisão | PROPOSTA |
| D-49 | Textos derivados que o arquivo escreveu à mão: contexto do cartão da tela 25 = até 55 caracteres antes do grifo (começo da frase, corte em palavra, "…"); excerto do marcador (27b) = até 90 caracteres + "…", gravado na criação, máx. 3 linhas. As fixtures guardam os textos literais do arquivo | O arquivo tem 0–55 e 54–83 caracteres sem regra única | PROPOSTA |
| D-50 | Slider de espessura da caneta 0,3–4,0 mm (como o `aria-valuemin/max` do arquivo) com escala `v = 0,3 + 3,7 · t^1,24`, que põe 1,2 mm em 32 % como no arquivo (linear daria 24 %) | Reproduz a posição do botão | PROPOSTA |
| D-51 | **Divergências conhecidas do arquivo** (o agente NÃO para por causa delas): (a) a prancha 21 não tem a prop `brand` → usa a `brand` global; (b) a prop `paper` oferece `#F3E7CF`, mas o cartão Sépia usa `#EEDDBF` → o tema Sépia é `#EEDDBF` (o `#F3E7CF` era variação de Creme do Claude Design); (c) `aria-label="1 marcas"` → o app diz "1 marca" (plural correto); (d) o rótulo `role=img` da nota à mão na 25 contém o texto escrito → D-31; (e) contagens por rótulo da 23b → D-40; (f) números do sumário ilustrativos → D-19/D-34 | Evitar paradas por divergências já decididas | PROPOSTA |
| D-52 | Moderação do conteúdo social (exigência da App Store 1.2 para conteúdo gerado por usuários): denunciar, bloquear, filtro de palavras na publicação, fila de moderação interna com meta de resposta em até 24 h, termos aceitos antes de publicar, contato publicado | Sem isso o app com clubes/perfis pode ser rejeitado | PROPOSTA |
| D-53 | Privacidade operacional: encarregado (DPO) nomeado e publicado; plano de resposta a incidentes com prazos da ANPD; política para menores conforme a lei vigente (Q13) | LGPD e lojas | PROPOSTA |

## 2. ADRs técnicos a escrever (com prova) — `docs/adr/`

| ADR | Pergunta | Recomendação inicial | Prova exigida |
|---|---|---|---|
| ADR-001 | Backend | Supabase Pro em `sa-east-1` (Postgres 17, Auth, Storage, Edge Functions, pg_cron) | SQL de referência passando (já: 23/23, com ataques) |
| ADR-002 | Banco local | SQLite (PowerSync SDK) + drift | spike S2 |
| ADR-003 | Sincronização Pro | PowerSync (Cloud ou self-host em `sa-east-1`) com upload pela RPC `sync_apply_changes` | spike S2: offline/online, 2 aparelhos, 10 mil linhas, FTS5, migração, região/LGPD, custo, replicação da tabela particionada, payloads reais (`CrudEntry`) contra a RPC, e os 4 fluxos do Anexo 02 §3.1 (Grátis em `localOnly` sem fila crescendo; virar Pro; perder o Pro **sem apagar nada local**; voltar depois do purge) — com modo avião no meio |
| ADR-004 | Fonte do leitor | Literata variável (`opsz`) | spike S1: largura/quebras vs Chromium |
| ADR-005 | Paginação | Motor próprio com `dart:ui Paragraph` | spike S3: 19 linhas idênticas à tela 19; tempo por página |
| ADR-006 | Tinta | `Listener` + suavização própria + codec BNK1 | spike S4: latência ≤ 1 quadro, 120 Hz |
| ADR-007 | Pagamentos | RevenueCat + webhook → Supabase | spike S5: compra sandbox nas 2 lojas |
| ADR-008 | Catálogo/ISBN | aparelho → R2/Workers → comunidade → APIs | estimativa de taxa de falha com amostra real |
| ADR-009 | Observabilidade | Sentry (falhas) + PostHog opt-in (produto) | política de privacidade compatível |
| ADR-010 | Notificações | FCM/APNs via `firebase_messaging` + notificações locais para meta diária | teste em aparelho |

## 3. Novas dependências (cada uma precisa de linha no ADR correspondente)

Produção: `supabase_flutter`, `powersync`, `drift` + `drift_sqlite_async`, `purchases_flutter`, `mobile_scanner`, `google_mlkit_text_recognition`, `archive`, `xml` (ou `html`), `pdfrx`, `uuid`, `path_provider`, `file_picker`, `share_plus`, `flutter_secure_storage`, `connectivity_plus`, `sentry_flutter`, `firebase_messaging` + `flutter_local_notifications`, `crypto`, `intl` (se o `formatters.dart` não bastar). Dev: `drift_dev`, `build_runner`, `mocktail`, `patrol` (ou `integration_test`).
Continuam **proibidos**: `google_fonts`, `flutter_screenutil`, kits de UI prontos, pacotes de ícones, color pickers prontos, pacotes de paywall com layout próprio (a UI segue o arquivo).
Versões: sempre a estável mais recente compatível com Flutter 3.47.2 / Dart 3.13.2 (as do `F00_versoes.txt`), conferidas no pub.dev no dia da fase.

## 4. Perguntas para o Cesar (responder antes da fase indicada)

Respostas em 03/10/2026: **Q2** = R$ 9,99/mês e R$ 79,99/ano · **Q5** = decidir depois (manter `com.example` até a G27) · **Q12** = sim, commitar e limpar (feito na G00) · **Q13** = **13 anos ou mais** (exige cuidados com adolescentes: verificação etária, padrões protetivos e textos legais — G05/G25).


| # | Pergunta | Bloqueia |
|---|---|---|
| Q1 | Onde estão as telas **01–18**? (este arquivo começa na 19) Envie o(s) HTML do Claude Design. | fases das telas 01–18 |
| Q2 | Preço final: **R$ 9,99/R$ 79,99** ou R$ 9,90/R$ 79,90? Teste grátis de 7 dias? | G22 |
| Q3 | Pode usar o app **sem conta** (modo convidado, tudo local)? | G05 |
| Q4 | Exportação no Grátis: ok liberar os próprios grifos/notas em Markdown/CSV (portabilidade)? | G19 |
| Q5 | Nome final na loja ("BookNest"?) e identificador do app (ex.: `br.com.<empresa>.booknest`). Conta de desenvolvedor em nome da empresa (CNPJ; a Apple pede D-U-N-S)? | G27 (e trocar o id já na G00) |
| Q6 | Supabase: já existe um projeto (há uma pasta "chave senha superbase postgrer" no Desktop)? Posso criar `booknest-dev/stg/prod`? As chaves **não** devem ser coladas no chat — vão para `.env` local. | G04 |
| Q7 | PowerSync Cloud (mais simples) ou self-host em São Paulo (dados no Brasil)? | G06 |
| Q8 | Sentry + PostHog (opt-in) ok para falhas e métricas? | G24 |
| Q9 | Domínio e e-mail remetente (política de privacidade, página de exclusão de conta, e-mails de retenção). | G22/G25 |
| Q10 | Aprovar os valores da D-20 (tamanhos, entrelinha, margens)? | G14 |
| Q11 | Ter um acervo de **domínio público** dentro do app (ex.: Machado de Assis) para quem não tem EPUB? | G09 |
| Q12 | Posso **commitar** o trabalho das fases F10–F13 que está fora do git (146 arquivos alterados — a maioria só fim de linha CRLF — e 22 com mudanças reais de código/teste) antes de começar? | G00 |
| Q13 | Público do app: só adultos (18+) ou também adolescentes? Isso muda verificação de idade, controles e textos legais (Lei 15.211/2025 — "ECA Digital" — e regras das lojas). | G05/G25 |
