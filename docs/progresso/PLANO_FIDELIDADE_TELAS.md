# Plano — todas as telas com prancha idênticas ao HTML (Trilha T)

> 10/10/2026 · **aprovado em 10/10/2026** ("ok, execute o plano"): as decisões D-239…D-248 valem como estão na
> coluna "Proposta" da §3. Base: `docs/design/auditoria_telas.md` (mesma data). As D-249…D-251 nasceram das 3 perguntas
> do relatório T02 e foram tomadas por delegação (10/10/2026: "nas decisões escolha o que você achar melhor, pois quero
> tudo na maior qualidade e nada simplificado"); o porquê de cada uma está em `docs/progresso/T02.md`. As D-252…D-255
> são as 4 regras da Início que a prancha 01 mostra e não define, respondidas em 10/10/2026 no começo da T03 (as 4
> propostas recomendadas); detalhe em `docs/progresso/T03.md`. As D-256…D-263 são as 8 regras do cronômetro do livro
> de papel que a prancha 01b mostra e não define, respondidas em 10/10/2026 no começo da T04 (as 8 propostas
> recomendadas); detalhe em `docs/progresso/T04.md`. As D-264…D-266 vieram da revisão independente do fim da T04
> (a sessão ao sair da conta, a que perde na adoção e o aviso de falha na folha), respondidas em 10/10/2026 (as 3
> recomendadas). As D-267 e D-268 vieram da R00 (o modo demonstração e as 9 telas que o Mapa marca como faltando),
> respondidas em 11/10/2026 (as recomendadas); as D-269 e D-270, dos achados da prova no celular (o "Para você" do
> modo demonstração e o título curto), também (as recomendadas); detalhe em `docs/progresso/R00.md` e
> `R00_celular.md`. As D-271…D-273 vieram do começo da T13 (o escopo da medição do projeto, as larguras e as fontes
> de fora do arquivo), respondidas em 11/10/2026 (as recomendadas), e as D-274…D-278 dos achados da T13 (os redlines da Início sem números, o fio de navalha de uma linha, a linha que dá a largura da caixa, o input invisível da 15 e as fileiras de flex-wrap), também (as recomendadas); detalhe em `docs/progresso/T13.md`. Desde
> 10/10/2026 a ordem das
> etapas é a do `docs/ROTEIRO.md`; esta tabela continua sendo o registro das decisões.
> Formato do roteiro: `handoff_v2/00_PROMPT_MESTRE_V2.md` §6 (trilha T: G01-bis → uma fase por tela → integração),
> §7 (verificação), §8 (roteiro de cada fase), §9 (relatório). O prompt mestre e o mapa (§11) **não foram editados**:
> a inserção é a decisão D-239, para você aprovar.

## 1. De onde partimos

- **(A) 9 telas fiéis** no leitor: 19, 20, 21, 22, 25, 26, 26b, 27, 27b. Três têm exceção já aprovada e ficam como
  estão: 21 (D-55, a versão corrigida), 25 (D-204, as miniaturas de tinta), 26 (D-147, "baixa visão").
- **(B) leve — 4 telas** do leitor (23, 23b, 24, 24b) passam nos gates, mas mostram diferenças que ficaram como
  "Desvios" nos relatórios, **sem decisão**: o Desfazer e o "+" apagados (na prancha estão acesos), a íris da 24b em
  fileiras, o traço do dedo e o rastro da 24, e recortes do golden que deixam pílula/prateleira/ilha sem comparação.
  Pela régua do seu pedido, elas ganham a fase T01. A tinta coral da 23b é decisão aprovada (D-59) e fica.
- **(B) 22 pranchas** dos dois arquivos de `docs/design/referencia/` que o app não tem (19) ou tem diferente (3: a
  Início, a aba Clubes e a discussão). **Nenhuma está medida.**
- **(C) 9 telas com rota e ~25 folhas/estados** sem prancha em nenhum HTML (§6 da auditoria): bloqueiam fases
  futuras e alguns toques dentro das telas B.
- **A G22 já está implementada e fechada** (commits `c8cfca0`…`cd55500`, 09/10). O plano começa depois dela.

## 2. Regras para não estragar o que já foi feito

1. **Nenhuma fase aprovada é reescrita.** O que mudar numa tela já entregue vira fase T com checklist próprio (§4.1 do
   prompt mestre, item 5). Teste antigo só muda com o motivo escrito no relatório da fase, como na G11/G12.
2. **A suíte inteira fica verde no fim de cada fase** (`dart format`, `flutter analyze`, `flutter test`, pgTAP e Deno
   quando houver servidor). Os goldens só mudam nas telas da fase, e cada golden novo é comparado com o PNG do HTML
   **antes e depois** (`tools/compare_images.py`, tabela no relatório).
3. **`design_handoff/`, `handoff_v2/` e `docs/design/referencia/` continuam só leitura** (os testes de checksum
   continuam). As saídas novas vão para os lugares da D-242.
4. **Uma fase por vez**, com a frase de parada do §4.1 (`✅ FASE T<NN> concluída — aguardando sua aprovação para
   iniciar a FASE <próxima>.`). Decisão nova só com pergunta.
5. **Nunca inventar tela:** o que não tem prancha segue a D-243 (abaixo) ou espera o HTML.
6. Branch `feat/t<NN>-<assunto>` a partir do último branch; commits pequenos por subfase; `docs/progresso/T<NN>.md`
   (spec, checklist, resultado) e `T<NN>_plano.md`, como nas G19–G22.

## 3. Decisões novas (D-239 em diante) — aprovadas em 10/10/2026

A última decisão usada antes desta tabela era a D-238 (G22); a tabela vai até a D-278 (T13) e a próxima livre é a
D-279.

| ID | Proposta | Alternativa |
|---|---|---|
| **D-239** | **Inserção da Trilha T:** as fases T01–T12 entram **depois da G22 (já concluída) e antes da G23**, na ordem da §4. G23–G28 mantêm o número. A G28 (QA final) passa a cobrir também as telas T. Motivo do lugar: a G23 vai mandar os lembretes que as pranchas prometem (enquete, encontro, revisão); a G25 precisa dos dados novos no mapa da LGPD; a G26 precisa das RPCs novas na carga; a G27 tira as capturas da loja dos goldens. Obs.: o roteiro termina na G28 — não existe G29. | Intercalar: T01–T05 antes da G23 e T06–T12 depois da G25 |
| **D-240** | **A 01 nova substitui a Início da v1 como referência de fidelidade.** A v1 fica em `design_handoff/` (intocada). Na T03 a suíte da Início (`qa_*`, `geometry_*`, `style_*`, `text_*`, `semantics_*`, `golden_*` de `test/home/`) passa a medir a 01 nova — não roda em paralelo com a da v1, porque o app só tem uma Início. | Manter a v1 e não fazer a T03 (a 01 nova fica fora do app) |
| **D-241** | **Mundo de referência:** um instantâneo por prancha nova (D-34): `t01`, `t01b`, `t60`…`t63`, `t04`…`t104`. A 01 nova usa os números do leitor e do clube (pág. 159 de 256, 12 anotações, até o cap. 50), então as 4 divergências da D-60 somem; as que sobrarem entre pranchas (ex.: o Para você da 01 × 01b) ficam listadas no teste, uma a uma, como a D-60 faz hoje. | — |
| **D-242** | **Onde ficam as medições novas** (porque `handoff_v2/` e `docs/design/referencia/` são só leitura): `docs/design/medicao/<inicio2|clube>/` (layout JSON, `text_dependency.json`, PNG @1x/@2x/@3x, recortes, redlines, `idmap`) · `docs/design/fases/` (as fases L) · `test/reference/inicio2/` e `test/reference/clube/` (`reference_layout_*.dart`) · extração fora do git em `tools/medicao/pranchas_inicio2/` (nova linha no `.gitignore`) e `pranchas_clube/` (já ignorada). Índice novo `tools/medicao/pranchas_inicio2.json`. | `handoff_v2/referencia/…` (como a G01), liberando a regra do CLAUDE.md só para essas pastas |
| **D-243** | **Toques das pranchas que levam a destinos sem prancha:** o elemento fica **idêntico à prancha**; o toque é (a) **mínimo da D-23** onde o produto precisa para funcionar — fim da sessão do papel com a página, sair do clube com confirmação, denunciar e bloquear, entrar no clube pelo link — ou (b) **sem ação**, com teste que documenta, nos demais — lupa da Início, toque na mini-barra do cronômetro, "Mudar horário e quantidade", "Sugerir uma pergunta", "Ajustar" lembretes, carteirinha, ícone de calendário e menus ⋯. Cada item fica listado no plano da fase e entra em `estados_sem_design.md`. | Tudo (b), ou tudo esperando o design |
| **D-244** | **Os dados que as pranchas pedem nascem nas fases T** (servidor + banco local + sync do Pro), cada um com migration, pgTAP permitido e negado, teste de contrato e o teste de privacidade do Grátis: sessão de cronômetro do livro de papel e a página do papel (T04); agenda da revisão diária, contagens, sequência e nota nova (T05); enquete, indicações, votos, voto secreto, desempate (T11); sala da chamada, quem está nela, duração e quem foi, canhoto (T10); link do convite `booknest.app/c/…`, validade, limite de pessoas e o link profundo (T12). Cumpre a D-211. | Fazer só as telas com os dados que já existem e deixar enquete, sala e convite para depois |
| **D-245** | **Push e lembretes que as pranchas prometem** ("As 11 membras recebem um aviso", "Lembrar quem não votou", "Lembretes: qua às 20h e qui às 19h45", "Amanhã, 8h: mais 5", "O 1º encontro já entra com lembrete na véspera"): nas fases T, o dado e a agenda; o envio entra na G23, que ganha esses eventos. | — |
| **D-246** | **Fontes:** Figtree 800 **real** nas pranchas 61–63 e nas 16 do clube (os arquivos declaram 800 — como a D-16); 800 → 700 nas 01, 01b e 60 (o arquivo só declara até 700 — a D-14 continua). A Instrument Serif itálica em 600 e 800 das 04, 102 e 104 é **negrito sintético do Chromium** (o arquivo só tem 400): a T06 mede e, se o Flutter não reproduzir dentro do gate, para e pergunta. | — |
| **D-247** | **Seção cujo dado ainda não existe:** aparece com a fixture (os testes de fidelidade) e **some com dados reais até a fase dela**, como a D-80 fez com o ticket do clube: o cartão "Seus grifos de hoje" até a T05; o cartão "Próximo livro" da 04 até a T11. O "play" do livro de papel e o "Ler agora" aparecem na T03 sem ação (D-243 b) e ganham ação na T04. | Esconder também nos testes de fidelidade (perde a prova da seção) |
| **D-248** | **O "+" das favoritas na 23:** a prancha mostra o "+" aceso com o coral já favorito; a D-175 apaga. Proposta: o "+" fica aceso como na prancha e o toque com a cor já favorita mostra a pílula "Essa cor já está nas favoritas." | Manter a D-175 e aceitar a diferença como exceção (como a D-59) |
| **D-249** | **As estáticas da Início v1 refeitas com os avanços do HVAR** (Figtree 400–700 e Bricolage 12…42, os mesmos 32 arquivos e famílias), do mesmo binário do arquivo, como a G01 fez com as novas (`tools/fonts/build_fonts.py v1`). A v1 instanciou sem isso e a `Figtree-Bold.ttf` saía até 0,0528 px por linha mais larga que o Chromium (limite 0,05); refeitas, as 866 linhas medidas (leitor + Início) ficam ≤ 0,01 px, com contornos e kerning idênticos e os acentos mais perto da variável. Exceção explícita à regra da v1 de usar "exatamente `design_handoff/assets/fonts`" (que continua intocado como o pacote original); os 30 goldens com texto foram refeitos (só pixels de texto mudam; contra as pranchas, 9 melhores e 8 iguais). | Limite próprio de 0,055 px só para a `Figtree-Bold.ttf` da v1 |
| **D-250** | **O progresso da revisão diz o que o texto mostra:** a 62 declara `aria-valuenow="6"` com máximo 5, mas o texto é "5 de 5" e os 5 segmentos estão completos (a contagem do protótipo passa do fim). No app o valor semântico é o do texto — "5 de 5" na 62, "2 de 5" na 61 — e nunca passa do máximo (teste de semântica na T05). | Copiar o 6 literal |
| **D-251** | **"Mais vezes" (61) é a ação sugerida, não um estado:** destacado em `{{brand}}` com sombra, sem `aria-pressed`; o próprio arquivo marca seleção com `aria-checked` (na 63) e aqui não marca nada. No app: botão comum, sem `selected`/`toggled` na semântica, destaque só visual e fixo; "Menos vezes" e "Mais vezes" registram a escolha (a regra de agendamento é do plano da T05, D-244). | Tratar como alternância com estado |
| **D-252** | **"Papel · tempo" é o tempo já lido** no livro de papel: a soma do `active_seconds` das sessões do livro (`reading_sessions`, todas as origens, sem as apagadas), no padrão `Xh MMmin`. Sem nenhuma sessão — ou com menos de 1 min lido no total (decidido no fim da T03: nunca "Papel · 0h 00min") —, a pílula diz só "Papel". Na 01b o cronômetro roda (08:42) e a pílula fica em 3h 40min: a sessão em andamento só conta quando termina (regra da T04). | O tempo restante estimado (D-97) · mostrar "0h 00min" sem sessões |
| **D-253** | **No cartão do Também lendo, a página decide "play" × anel:** livro de papel com página registrada → anel com o progresso e "Papel · pág. N"; sem página → "play" (sem ação até a T04) e "Papel · tempo" (D-252); e-book e PDF → anel, sem pílula (a prancha não desenha pílula para eles). A página do papel vem da posição do livro (`reading_positions.ref_page`), que a T04 grava no fim da sessão. | "play" só no 1º livro de papel · "play" em todo livro de papel |
| **D-254** | **Selo do formato no herói:** EPUB → "E-BOOK", PDF → "PDF", físico → "PAPEL", todos no estilo amarelo da prancha. A pílula "pág. X de Y" é a página de referência atual (`reading_positions.ref_page`) e o total (`user_books.ref_pages_total`, G10); sem um dos dois, a pílula some e o selo fica sozinho. | "E-BOOK" também no PDF · selo só no EPUB |
| **D-255** | **Recém-chegados com "Lido":** os 3 adicionados mais recentes, nunca abertos no app, com situação "quero ler" ou "lido" (`finished`). Lido → "Lido" (vale mais que o "Novo"); quero ler → "Novo"/"Quero ler" pela D-88. O formato físico se chama "Papel" (como a prancha). | Qualquer situação menos "lendo" · "Lido" só na fixture |
| **D-256** | **Fim da sessão do papel:** o toque na mini-barra abre a folha da sessão (mínimo da D-23, vocabulário da D-21): o livro, o tempo, Pausar/Retomar, "Em que página você parou?" (opcional), "Encerrar sessão" e "Descartar sessão" (com confirmação). O item "toque na mini-barra" da D-243 passa de (b) para (a); a tela do cronômetro (C15) substitui a folha quando tiver prancha. | Segurar o pausar abre a folha; o toque na mini-barra continua sem ação |
| **D-257** | **Sessão pausada:** mini-barra igual à da 01b com o play em tinta no lugar do pausar ("Retomar"), o tempo parado e "EM PAUSA · PAPEL" com o ponto `#B9AE9C`; no cartão, o play amarelo da 01 com o aro coral, rótulo "Retomar leitura de …". | Só o ícone e o tempo mudam |
| **D-258** | **"Ler agora":** com sessão aberta, age nela (pausada → retoma; rodando → nada); sem sessão, o cronômetro do livro de papel em leitura mais recente (o herói, se for de papel; senão o 1º de papel do Também lendo); sem livro de papel em leitura, abre o herói no leitor. | Sempre o herói · só papel, senão nada |
| **D-259** | **Mini-barra nas 4 abas do shell**, com o degradê de 240 / 48 % da 01b; some nas telas empilhadas; a folga do fim de cada aba cresce 96 (66 + 30) enquanto ela aparece. | Só na Início |
| **D-260** | **Total de páginas do papel:** sem `ref_pages_total`, a folha pede também "De quantas páginas é o livro?", já com as páginas do catálogo do aparelho pelo ISBN quando houver, e grava no livro; a página vai de 1 ao total. | Total do catálogo, senão só a página (anel em 0 %) |
| **D-261** | **Encerrar conta como abrir:** o fim da sessão grava `last_opened_at` e o livro vira o herói na próxima leitura da Início; durante a sessão nada muda de lugar. | Só com página · nunca |
| **D-262** | **Uma sessão por vez:** o play de outro livro com sessão aberta abre a folha da atual; ao encerrar ou descartar, a do outro livro começa. | Troca direto (sem página) · play sem ação |
| **D-263** | **O leitor pausa o papel:** abrir qualquer livro no leitor pausa a sessão do papel que estiver rodando. | O cronômetro continua (tempo em dobro) |
| **D-264** | **Sair da conta pausa a sessão do papel:** a do dono que sai pausa no instante da troca; quando ele volta, ela está em pausa com o tempo até ali. | Grava ao sair · continua contando |
| **D-265** | **Na adoção, a sessão que perde é gravada:** fica aberta a que começou por último e a outra é gravada sem página até a troca (menos de 10 s não grava). | A que perde some · fica a mais longa |
| **D-266** | **Falha na folha da sessão avisa:** "Não deu para encerrar a sessão. Tente de novo." (descartar, pausar, retomar) no aviso de erro da folha, e os botões voltam; fora da folha, só o relatório. | Folha e aviso passageiro · só o relatório |
| **D-267** | **Modo demonstração, em dois alvos fora de `lib/`:** (1) `test/fixtures/main_demonstracao.dart` — o app de verdade sobre um banco só do demo (`booknest_demo.db`, pastas `_demo`), com o mundo de referência gravado (Início, leitor com o EPUB, grifos, tinta, marcadores, metas, cronômetro), sem servidor, e o relógio que parte de dom 20/09/2026 20:00 (D-09) e anda; (2) o `main_mundo_referencia.dart`, com a Início igual à prancha e o leitor e os grifos abrindo do banco semeado. Nunca no build de loja: alvo separado, recusa em release e teste de que `lib/` não importa `test/`. | Só (1) · só (2) · não fazer agora; relógio real com o mundo deslocado · relógio parado |
| **D-268** | **As 9 telas que o Mapa (00) marca como faltando entram na etapa da tela que as abre**, pela §5 do ROTEIRO (perguntar, referências, prancha em HTML no estilo do projeto, "sim", Flutter): Revisão · escrever nota → T05; Coleções · ver todas e Trocar a capa → T14; Busca dentro do livro → T15; Exportar meus dados, Importar CSV, Aparência e acessibilidade e Carteirinha aberta → T17; Enquete · deu empate → T11. "Livros do ano" (o design marca como futuro) fica fora da v1.0 (§9 do ROTEIRO). | Uma etapa nova só para as 9, antes da R01 · fora da v1.0 |
| **D-269** | **O "Para você" no modo demonstração vem de um catálogo só do demo:** um `catalog.db` no formato 1 do pipeline, na pasta do demo (`test/fixtures/demonstracao/catalogo_demonstracao.dart`), com edições de Machado de Assis da Penguin-Companhia (ISBNs reais), e um atualizador cuja rede é sempre "nenhuma"; o app calcula a seção pela regra da G08 (D-81: um autor só, a edição mais nova primeiro), então a Casa de Pensão da prancha dá lugar ao Quincas Borba. O alvo (2) segue igual à prancha. | O alvo (1) sem a seção, registrado |
| **D-270** | **Título curto do livro, na T14:** o livro ganha o campo opcional "título curto", editável no Livro e preenchido pelo catálogo quando houver; "Também lendo", a mini-barra, a folha da sessão e o "Para você" usam o curto quando existe. Até a T14, com dados reais, o título inteiro com reticências (a prancha mostra "Brás Cubas", que só a fixture tem). | Regra automática (o que vem depois do último " de ") · o título inteiro sempre |
| **D-271** | **A T13 mede as 41 telas das etapas 7–11 por completo**, como a T02 fez com a Início: ids semânticos de todos os elementos, layout, texto, estilos, PNG @1x/@2x/@3x, recortes, redlines, referências Dart, fontes, SVGs, tokens, mapa id → widget e fases L; as etapas T14–T18 começam com tudo medido. | Ferramenta + medição bruta (ids automáticos), o resto em cada etapa · ferramenta + só as 4 da T14 |
| **D-272** | **As 41 telas também a 360 e 430 px** (o quadro com a largura trocada, CSS fluido, como a T03 fez com a 01), com a lista das telas que não se adaptam a 360. | Cada etapa mede as larguras das suas telas |
| **D-273** | **Fontes de fora do arquivo:** as respostas do `css2` das consultas novas e os `.woff2` da Roboto 500 (o botão do Google na 07) baixados do Google Fonts, com URL e sha256 no manifesto, conferindo que as outras fontes são as mesmas versões que já temos; o texto em fonte do sistema (o botão da Apple na 07, o teclado do sistema na 69/69b) medido e marcado informativo. | Não baixar: a 07 medida com a reserva do Linux e o botão do Google informativo, a fonte decidida na T16 |
| **D-274** | **Os redlines da Início (T02) refeitos com números:** o `recortar.py` desenha os rótulos com a 1ª face da Figtree que tem os dígitos (e falha se nenhuma tiver); os 14 redlines da `inicio2` saem de novo e o manifesto da T02 muda só nesses 14 arquivos. | Deixar os 14 redlines com quadradinhos (a `legenda.json` tem os números); corrigir numa etapa própria |
| **D-275** | **Fio de navalha de uma linha, no projeto (T13 em diante):** a linha única que pode quebrar, numa caixa de largura imposta, com sobra entre 0 e 1,5 px entra nos fios de navalha (medida pela largura real da linha); o leitor e a Início ficam como estão. | Incluir também no leitor e na Início (G01/T02 mudam); manter a regra da G01 e só anotar nas fases L |
| **D-276** | **A linha que dá a largura da caixa não é fio de navalha (T13 em diante, todos os conjuntos):** sobra 0 = a caixa é do tamanho do texto e cresce junto; vale também no texto de 2+ linhas, como na linha única (D-275). No leitor e na Início nenhum risco tinha sobra 0 (nada muda); sai o "dígito / final" do X da 69/69b. | Só no projeto; manter como fio, com nota |
| **D-277** | **O input invisível conta como informativo (R8):** o input de verdade do @ da 15 (opacity 0, 1×1, atrás do texto desenhado) cai na fonte padrão do campo porque a folha da tela não diz `input{font-family:inherit}`; entra na reserva do índice como `informativo`, com o motivo (o app não desenha esse texto). | Ignorar elementos invisíveis na medição (todos os conjuntos); declarar como reserva do app |
| **D-278** | **A fileira de um flex-wrap também é fio de navalha (projeto):** nos conjuntos com `facaLinhaUnica`, o `perturbar.js` mede cada fileira de flex-wrap pelo tamanho hipotético dos itens (sem crescer nem encolher) e marca a fileira cheia por < 1,5 px ou o 1º item da fileira seguinte que caberia faltando < 1,5 px — no Flutter (`Wrap`) uma diferença mínima de largura de texto muda as fileiras e desloca os itens seguintes. Entra no `knife_edges.json` (no contêiner, `fileiras: true`) e na referência Dart (o mesmo `LeitorKnifeEdge`). Na T14–T16: a fileira do autor da 17b (0,47), os humores da 28 (0,40) e os gêneros da 13 (0,97); o leitor e a Início não têm caso. | Só anotar como armadilha; detectar em todos os conjuntos |

## 4. As fases

Tamanho como no §6: **P** ≤ 1 dia de agente · **M** 2–4 · **G** 5+.

| Ordem | Fase | Pranchas | Tam. | Depende de | Bloqueios parciais (C) |
|---|---|---|---|---|---|
| 1 | **T01** · Leitor — acertos de fidelidade | 23, 23b, 24, 24b | M | — (as referências da G01 existem) · D-248 | — |
| 2 | **T02** · G01-bis — arquivo da Início e da revisão | 01, 01b, 60, 61, 62, 63 | M | D-242 | — |
| 3 | **T03** · Início nova | 01, 60 | G | T02 · D-240, D-241, D-243, D-247 | lupa (C14) |
| 4 | **T04** · Lendo agora — cronômetro do livro de papel | 01b (+ o "play" e o "Ler agora" da 01) | M | T03 · D-244 | tela do cronômetro e fim da sessão (C15) |
| 5 | **T05** · Revisão dos grifos | 61, 62, 63 (+ o cartão da 01/60) | G | T02, T03 · D-244, D-245 | "Mudar horário e quantidade" (C17) |
| 6 | **T06** · G01-bis — arquivo do clube | as 16 | G | D-242, D-246 | — |
| 7 | **T07** · Aba Clubes | 04 (+ a barra com Clubes ativo) | G | T06 · G21 · D-247 | Clubes sem clube (C13), menu ⋯ (C20) |
| 8 | **T08** · Discussão da semana | 31 | M | T06 | menu ⋯ / denunciar (C20) |
| 9 | **T09** · Membros | 32 | M | T07 | "Sair do clube" (C20) |
| 10 | **T10** · Encontro | 70, 71, 72, 73 | G | T07 · D-244, D-245 | "Sugerir uma pergunta", "Ajustar" (C18), carteirinha (C19) |
| 11 | **T11** · Enquete do próximo livro | 47, 48, 49, 50, 102, 103, 104 | G | T07 · D-244, D-245 | a enquete em fase de indicação, atrás da 48 (C22) |
| 12 | **T12** · Criar clube e convite | 33, 34 | G | T07 · D-244 | "Trocar" livro (C21), quem abre o link (C16) |

Por que esta ordem:
- **T01 primeiro:** é a única que não precisa de medição nova nem de decisão grande, e fecha o leitor.
- **A família da Início antes do clube:** a Início é a tela principal; a T03 depende da decisão D-240 — se você
  recusar, T03–T05 saem do plano e o resto não muda.
- **No clube, primeiro o que já tem dado** (G21: 04, 31, 32, 70, 72, 73) e depois o que precisa de servidor novo
  (sala, enquete, convite). A 04 vem antes porque é a porta de entrada das outras.
- **T11 antes da T12:** a enquete completa o cartão "Próximo livro" da 04; criar clube e convite precisam do link
  profundo, que encosta na G27 (domínio e verificação de app links).

## 5. Cada fase, no formato do roteiro

Toda fase de tela segue o §8 do prompt mestre e entrega as **4 camadas do §7** contra as referências da sua G01-bis:
geometria ±0,5 px (±1,0 em x/w dos ids que dependem de texto) · estilo exato · golden @3x com `blur_mismatch_% ≤ 0,5`
**por seção e na tela inteira** · texto e quebras idênticos — mais semântica pelos `aria-*` do arquivo, unidade
(≥ 85 % nos módulos novos), banco (pgTAP permitido + negado) quando houver, integração e privacidade do Grátis.

### T01 · Leitor — acertos de fidelidade (M)
Objetivo: tirar as diferenças pequenas que ficaram nas telas do leitor, sem mexer no que está fiel.
- [ ] Ler os G16–G18 (Desvios) e as pranchas 23, 23b, 24, 24b (e a D-59, que fica).
- [ ] Fixture: os instantâneos das 23, 23b, 24 e 24b com passos no modo, para o **Desfazer aceso** como na prancha.
- [ ] O **"+" das favoritas** aceso (D-248, ou exceção registrada).
- [ ] 24b: a **íris em espiral**, amostrada do caminho SVG (no lugar das fileiras).
- [ ] 24: o **traço do dedo** do abridor e o **rastro** com o comprimento da prancha.
- [ ] `docs/design/estados_sem_design.md` ganha as seções G11–G20 (o que o leitor e a 25 mostram sem prancha — lista
      da auditoria §5.2), para o design desenhar (hoje nada do leitor chega lá).
- [ ] Golden contra o PNG do HTML também **fora dos recortes** que ficaram sem comparação (pílula, prateleira e ilha
      da 23/23b; pílula da 24/24b) — tela inteira.
- [ ] Um script que refaz o gate visual de **todas** as telas A (Início + 19–27b) de uma vez
      (`tools/medicao/conferir_goldens.sh`, saída numa tabela), para a G28 e para depois de cada fase T.
- [ ] Relatório T01 com a tabela antes/depois de cada tela.

### T02 · G01-bis — arquivo da Início e da revisão (M)
Objetivo: transformar as 6 pranchas em referências medidas e fases L, exatamente como a G01 fez.
- [ ] `tools/medicao/pranchas_inicio2.json` (uuid, slug, título, canvas, prefixo: `i01`, `i01b`, `i60`, `rv61`,
      `rv62`, `rv63`); extração conferida (page_order, títulos, canvas) e reprodutível.
- [ ] `comum.js` e os scripts de medição aceitam o índice e a saída por parâmetro (hoje o `pranchas.json` é fixo).
- [ ] Renderizar cada prancha isolada no Chromium (390 × canvas, rede bloqueada, fontes embutidas) e conferir contra
      o render da página raiz (o arquivo não traz prévias).
- [ ] Medir: retângulos por id, linhas de texto com baseline, estilos computados, `text_dependency.json`.
- [ ] PNG @1x/@2x/@3x (supersample 10×), recortes por seção e redlines → D-242.
- [ ] Fontes: tamanhos novos da Bricolage (as famílias por tamanho da v1), Instrument Serif nos tamanhos novos,
      Literata 22 (61) e 15 (62); Figtree 700 nas 01/01b/60 e 800 nas 61–63 (D-246).
- [ ] Ilustrações e ícones novos: capas desenhadas (Dom Casmurro com o olho e o mar; Brás Cubas com cartola, e com
      asas na mini-barra; Esaú e Jacó, Memorial de Aires, Casa de Pensão), os cartões da revisão, ícones de busca,
      cronômetro, play/pausa, livro de papel.
- [ ] Fases L geradas: `L01a…` (uma por seção da 01: cabeçalho, herói, também lendo, dia, revisão, para você, clube,
      recém-chegados, barra), `L01b`, `L60`, `L61`, `L62`, `L63` — com HTML literal, tabela pixel a pixel, linhas de
      texto, armadilhas e checklist (formato da `design_handoff/fases/F05_hero_continuar_lendo.md`).
- [ ] Mapa id → widget e lista de tokens novos.
- [ ] Rodar a medição 2× → mesmos hashes.
- [ ] Relatório T02 com a lista das fases L para aprovação.

### T03 · Início nova (01 e 60) (G)
Objetivo: a Início do app idêntica à 01 nova, com dados reais, sem perder nada da G08/G21.
- [ ] Fixture `t01` (D-241) e a lista de divergências refeita.
- [ ] Cabeçalho com o **botão de busca** (toque D-243 b).
- [ ] Herói: **"pág. X de Y"** (páginas de referência da G10), selo **"E-BOOK"** pelo formato, contador = anotações
      do livro (12), a capa nova do Dom Casmurro (só na fixture; capas reais seguem a D-79).
- [ ] Também lendo: contador total, **cartão do livro de papel** com o botão "play" (D-247) e a pílula
      **"Papel · tempo"** / **"Papel · pág. N"** (regra derivada a confirmar no plano da fase: o tempo é o lido? o
      restante?).
- [ ] Dia de leitura: **"Ler agora"** e **"N sessões"** (de `reading_sessions`).
- [ ] Seção **"Seus grifos de hoje"** (fixture; some com dados reais até a T05 — D-247).
- [ ] Recém-chegados: pílula **"Lido"** (estilo verde novo) e o formato "Papel".
- [ ] Viewport 60 (a Início rolada até o cartão) como caso de teste.
- [ ] Trocar a suíte de fidelidade da Início (D-240): geometria, estilo, texto, semântica, goldens canvas/viewport/
      360/430, `qa_*` e a auditoria anti-simplificação; os estados da G08 (vazio, convidado, carregando, erro…) e os
      testes de dados reais continuam.
- [ ] Relatório T03.

### T04 · Lendo agora — cronômetro do livro de papel (01b) (M)
- [ ] Domínio: sessão de cronômetro (começar, pausar, retomar, encerrar), sobrevive ao app fechado, grava em
      `reading_sessions` com o formato papel; meta e sequência do dia contam a sessão.
- [ ] **Mini-barra** acima da barra de navegação (L01b): capa, "● LENDO · PAPEL", título, tempo, pausa; o cartão do
      Também lendo em pausa com o anel coral.
- [ ] "play" do cartão e "Ler agora" começam a sessão (no livro de papel em leitura; regra a confirmar no plano).
- [ ] Toque na mini-barra: D-243 b até a tela do cronômetro (C15); fim da sessão com a página do papel: D-243 a.
- [ ] Banco local + sync Pro (D-244), contrato, privacidade do Grátis.
- [ ] Relatório T04.

### T05 · Revisão dos grifos (61, 62, 63 + cartão) (G)
- [ ] Domínio: o baralho do dia (5 por dia), "Mais vezes"/"Menos vezes" mudando a frequência, "revisto N vez(es)",
      "Você grifou há N dias", sequência de dias revisando, nota nova durante a revisão, a próxima revisão
      ("Amanhã, 8h: mais 5…"). Regra de agendamento a aprovar no plano da fase (D-244).
- [ ] Banco local (tabelas próprias) + `personal.*` no servidor + sync Pro + contrato + privacidade do Grátis.
- [ ] Rota nova `/revisao` (tela cheia); **61**: baralho com deslizar e os botões; lápis → editor da nota do leitor
      (D-23); **62**: fim com os números e "Voltar a ler · pág. N" (abre o leitor na posição); "Mudar horário e
      quantidade" D-243 b.
- [ ] **63**: a folha "Compartilhar grifo" com a imagem gerada no aparelho (cor, nota e @ opcionais), Salvar,
      Stories, Copiar texto, Mais (dependência nova para salvar/compartilhar a imagem: a confirmar).
- [ ] O cartão "Seus grifos de hoje" da Início ligado ao baralho de verdade (sai da D-247).
- [ ] Lembrete das 8h: o dado e a hora; o envio na G23 (D-245).
- [ ] Relatório T05.

### T06 · G01-bis — arquivo do clube (G)
Como a T02, para as 16 pranchas (prefixos `c04`…`c104` do `pranchas_clube.json`), com:
- [ ] as folhas sobre outra tela (102 e 104 sobre a 04; 103 sobre a 50; 72 sobre a 70; 48 sobre a enquete em
      indicação) medidas com o fundo esmaecido;
- [ ] o negrito sintético da Instrument Serif (D-246) medido e testado no Flutter;
- [ ] Literata do clube (14,5 na 31; 16,5/500 na 33) e Bricolage até 96 px (70) e 72 px (73);
- [ ] ilustrações: selos e carimbos (CLUBE DE LEITURA "Pd", VOU, FUI, SECRETO, ESCOLHIDO), capas pequenas, o
      cartão-convite com recortes, confetes; o QR é gerado (não é imagem do arquivo);
- [ ] fases L04 (por seção), L31…L104; relatório T06.

### T07 · Aba Clubes (04) (G)
- [ ] Trocar o `PlaceholderScreen('Clubes')` pela 04: título e "+", seletor de clubes, herói, "Onde cada uma está"
      com as contas e "Atualizar" (D-216), ticket com Vou/Talvez/Não vou (`set_rsvp`), "Discussões" por semana
      (trancadas até a pessoa chegar), grifo compartilhado (D-219), barra com Clubes ativo.
- [ ] Cartão "Próximo livro" com a fixture; some com dados reais até a T11 (D-247).
- [ ] Dados: `club_overview` (G21); cache e tempo real conforme a D-225.
- [ ] Clubes sem clube (C13): D-243 a, mínimo, até o design. Menu ⋯ (C20): D-243.
- [ ] Ligações: ticket → 70 (T10), semana → 31 (T08), avatares/"11 leitoras" → 32 (T09), "+" → 33 (T12).
- [ ] Relatório T07.

### T08 · Discussão da semana (31) (M)
- [ ] `/clube/:clubId/discussao` real: pergunta da semana, "Mais curtidas/Mais recentes" (`week_thread`, keyset),
      respostas com citação e página, curtir, responder (termos D-222), **o borrado do spoiler** com "Mostrar mesmo
      assim" (D-218), compositor; tempo real (D-225).
- [ ] A seta da faixa do clube no sumário (27) e "Abrir discussão" do ticket da Início abrem a 31 (hoje "Chega numa
      próxima fase").
- [ ] Menu ⋯: denunciar e bloquear (D-52) pela D-243 a.
- [ ] Relatório T08.

### T09 · Membros (32) (M)
- [ ] Rota `/clube/:clubId/membros`: cartão do encontro, ordenar por "Mais à frente/Nome/Presença", as 11 linhas
      (`club_members_overview`), o aviso de privacidade, "Convidar" (→ 34 da T12; até lá D-243 b), "Sair do clube"
      com confirmação D-243 a.
- [ ] Relatório T09.

### T10 · Encontro (70, 71, 72, 73) (G)
- [ ] Servidor: a sala abre 15 min antes, quem está nela, duração, quem foi, o canhoto (D-244).
- [ ] **70** detalhe (ticket grande com o número da leitora, presença, recado, a leitura até o encontro com
      "Continuar na pág. N", chamada e lembretes, perguntas na ordem da anfitriã, quem vai); **72** folha da presença
      com recado (`set_rsvp`, `meeting_notes`, "Só a Ana/O clube todo"); **71** sala aberta (contador, quem está,
      "Entrar na chamada", perguntas à mão, "Vou atrasar"/"Não vou conseguir"); **73** encerrado (FUI, quem foi, o que
      conversamos, a próxima semana).
- [ ] "Sugerir uma pergunta", "Ajustar", carteirinha: D-243 b. Lembretes: dado e agenda; envio na G23 (D-245).
- [ ] Relatório T10.

### T11 · Enquete do próximo livro (47–50, 102–104) (G)
- [ ] Servidor: enquete, indicações (1 por pessoa, trocar até o prazo), votos (1 por pessoa, mudar até fechar), parcial
      só depois de votar, voto secreto, desempate de 24 h, resultado e o próximo livro no clube; RLS com pgTAP
      permitido/negado; o aviso às membras e "lembrar quem não votou" pela D-245.
- [ ] **47** criar, **48** indicar (busca no catálogo e na estante — G07 — com o botão do scanner), **49** votar,
      **50** resultado ("Como você vai ler?" muda a estante; "Pôr na minha agenda" pelo calendário do sistema —
      dependência a confirmar), **102/103** quem votou, **104** voto secreto.
- [ ] O cartão "Próximo livro" da 04 ligado (sai da D-247).
- [ ] A enquete em fase de indicação (atrás da 48) não tem prancha própria (C22): D-243.
- [ ] Relatório T11.

### T12 · Criar clube e convite (33, 34) (G)
- [ ] **33** criar (nome, cores por elemento com prévia ao vivo, primeiro livro, semanas, dias e hora, online/
      presencial, só com convite/aberto, proteção contra spoiler) com `create_club` (G21).
- [ ] **34** convite: o cartão com o **QR** (dependência nova para gerar QR: a confirmar), o link
      `booknest.app/c/…` com validade e limite (`create_invite`), Copiar, Compartilhar, Mostrar QR, "Quem você segue".
- [ ] Link profundo para abrir o convite no app (Android App Links / iOS Universal Links — a verificação do domínio é
      pendência de ambiente até a G27); quem abre o link: D-243 a até o design (C16). "Trocar" livro (C21): D-243.
- [ ] Relatório T12.

## 6. Onde entra no roteiro (proposta da D-239 — o §11 não foi editado)

```
… G21 → G22 (concluída) → T01 → T02 → T03 → T04 → T05 → T06 → T07 → T08 → T09 → T10 → T11 → T12
      → G23 (+ lembretes da D-245) → G24 → G25 (+ dados novos no mapa LGPD) → G26 (+ RPCs novas) → G27 → G28
Fases T futuras (as telas C): entram quando o HTML chegar, cada arquivo com a sua G01-bis.
```

Conta aproximada: 5 fases M (T01, T02, T04, T08, T09) + 7 fases G (T03, T05, T06, T07, T10, T11, T12).

## 7. O que fica bloqueado até você exportar os HTMLs (C)

**Fases inteiras que não podem começar** (cada uma vira T13 em diante, com a sua G01-bis, quando o arquivo chegar):

| Tela (nome sugerido na auditoria §6) | Rota | Hoje | Afeta também |
|---|---|---|---|
| C1 Biblioteca | `/biblioteca` | placeholder + importar | links "Biblioteca →" da Início |
| C2 Livro — detalhe | `/livro/:bookId` | placeholder | "Guardar na nuvem"/"Baixar" do Pro (G06) |
| C3 Para você — ver tudo | `/para-voce` | placeholder | "Ver tudo" da Início |
| C4–C6 Perfil, perfil de outra pessoa, conta e ajustes | `/perfil` | placeholder + bloco da conta | gatilho do paywall "Perfil de outra pessoa" (G22) |
| C7 Notificações | `/notificacoes` | placeholder | G23 (a lista no app) |
| C8 Scanner | `/scanner` | provisório (D-76) | a busca da 48 usa o scanner |
| C9–C11 Entrar, concluir cadastro, boas-vindas | `/entrar`, `/conta/cadastro` | D-21 | G25 (fluxos do titular) |
| C12 Assinatura — Pro (paywall) | `/_pro` (só depuração) | tela técnica | **o build de produção não vende até ela existir (D-230)** — encosta na G27 |
| C13 Clubes — sem clube | aba Clubes | — | T07 (fica no mínimo D-21) |
| C14 Busca | — | — | T03 (lupa sem ação) |
| C15 Cronômetro de leitura | — | — | T04 (mini-barra sem ação no toque) |
| C16 Convite — entrar no clube | link profundo | — | T12 (mínimo D-21) |

**Elementos que ficam sem ação ou mínimos dentro das fases T** (D-243): C17 (T05), C18 e C19 (T10), C20 (T07, T08,
T09), C21 (T12), C22 (T11); e as folhas do leitor e da 25 já feitas pela D-23 (C23, C24) continuam como estão até o
design. C25 (estados carregando/vazio/erro/sem conexão) vale para todas as fases.

## 8. Riscos

- **Tamanho:** 7 fases G. A trilha T é maior que a trilha B do leitor; o clube sozinho (T06–T12) é ~5 fases G.
- **Troca da suíte da Início (T03):** a maior mudança de teste até aqui. Mitigação: a suíte nova é escrita e fica
  verde antes de a antiga sair, no mesmo commit; a D-240 pode ser recusada sem afetar o resto.
- **Negrito sintético e famílias por tamanho** podem exigir fontes novas (T02/T06) — se não baterem, parar e perguntar
  (§7 da v1).
- **O gate visual não é automático hoje:** um desvio novo numa tela A só aparece se alguém rodar o
  `compare_images.py`. A T01 entrega o script; a G28 o roda em tudo.
- **Dependências novas** (imagem para compartilhar, QR, calendário) precisam de aprovação no plano de cada fase.
- **O link profundo** precisa do domínio e da verificação das lojas (G27): a T12 fecha com essa pendência de ambiente.
- **Fora do escopo, mas achado na auditoria:** a pendência "repaginar quando a tela muda de tamanho" (G11.md:340,
  G12.md:296, atribuída à G14) não foi feita nem listada; `reader_screen.dart:249-263` lê o viewport uma vez. Não é
  fidelidade — fica para você decidir onde entra (G26 ou uma correção do leitor).
