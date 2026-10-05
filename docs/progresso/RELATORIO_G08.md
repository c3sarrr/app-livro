# Relatório da FASE G08 — Início com dados reais

Data: 05/10/2026 · branch `feat/g08-inicio` (a partir de `feat/g07-catalogo`, `4e7700b`) · nada enviado ao GitHub.
Evidências de cada subfase: `docs/progresso/G08.md`.

Decisões usadas (respondidas por você em 05/10, antes do código):
- Início sem dados = seções que se adaptam (D-78).
- Capa = foto real com cache offline, e capa gerada enquanto não há foto (D-79).
- Clube some até a G21 (D-80).
- Para você some quando não há sugestão (D-81).
- Semana = últimos 7 dias (D-82).
- Frases de concluído (D-83).
- Convidado sem nome (D-84).
- Regras derivadas, aprovadas com o desenho (D-85, que substitui a D-61).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G08.1 Modelo | A Início aceita a falta de leitura, de Para você e de Clube, e sabe se a estante está vazia. Capa = arte desenhada (só a fixture) ou foto real. Exemplar "Físico". Textos de convidado e de concluído | `g08_modelo_test` (10) |
| G08.2 Fonte real | Tudo lido do banco do aparelho, numa transação, só do dono ativo e sem linhas apagadas: livro em leitura (capítulo, progresso, anotações, tempo restante pela velocidade das sessões de 30 dias), também lendo, dia de leitura no fuso de cada sessão (minutos, páginas, grifos, sequência de dias com ≥ 1 min, últimos 7 dias, barras da D-10), recém-chegados. Para você vem do `catalog.db` pelo autor da estante. O Clube vem do cache do social (vazio até a G21). Atualiza quando o banco muda (rajadas viram um recálculo), em 0h/5h/12h/18h e quando o app volta do segundo plano | `local_home_repository_test` (23), `catalog_for_you_source_test` (8), `cached_club_ticket_source_test` (4), `home_providers_test` (14) |
| G08.3 Capas | A foto vem do Open Library (id ou ISBN) ou da URL da API externa e é guardada no aparelho, então aparece offline. Limites: 4 downloads de cada vez, 2 MB, só imagem, só https. "Sem capa" espera 7 dias; falha passageira, 10 min. As capas da estante nunca saem do cache; as outras saem acima de 40 MB. Sem foto, a capa gerada no estilo das 9 capas do arquivo | `cover_store_test` (12), `book_cover_test` (9) |
| G08.4 Estados | Seções sem dados somem com o gap de antes delas. Convites "Escanear livro" e "Ver biblioteca". Carregando (aviso depois de 400 ms) e erro com "Tentar de novo". O `main()` de produção abre a Início com os dados reais | `inicio_estados_test` (9); `docs/design/estados_sem_design.md` |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **1.114 verdes** (+6 pulados, como antes; eram 1.036 no fim da G07).
- **Todos os testes de fidelidade da Início continuam verdes com a fixture**, sem mudar nenhuma asserção.
- Mutação: **14/14** trocas derrubadas pelos testes (sequência, teto das barras, dono ativo, recém-chegados, anotações apagadas, ordem dos autores, nome exato, título já na estante, só imagem, capa da estante, espera de 7 dias, meta no minuto exato, gap da seção, clube por dono).
- gitleaks: os 6 commits da fase e as pastas novas sem vazamento.

A integração com Supabase e PowerSync não foi rodada: a G08 não mexe na sincronização nem no servidor.

## Como fica na tela

As capturas estão em `tools/medicao/tmp/g08/capturas/` (fora do git) e foram enviadas na conversa:
1. Estante vazia.
2. Só livros escaneados: Recém-chegados com "Físico", Para você e capas geradas.
3. Lendo com a meta cumprida.

## O mundo de referência gravado no banco

A fonte real lendo o mundo de referência reproduz o **lado do Leitor**: cap. XXXII, 12 anotações, 1 grifo hoje, 18 min, 24 páginas, sequência de 12 dias e a semana inteira. Ela diverge da prancha da Início só nestes pontos (o teste exige exatamente esta lista):

| Ponto | Fonte real | Prancha da Início | Por quê |
|---|---|---|---|
| Capítulo | 32 | 92 | Q25/D-60: cada prancha tem os próprios valores |
| Destaques do livro | 12 | 14 | Q25/D-60 |
| Grifos hoje | 1 | 2 | Q25/D-60 |
| Progresso | 0,62113 | 0,62 | a prancha arredonda a 2 casas (o rótulo continua "62%") |
| Tempo restante | ~1h 12min | ~2h 10min | o arquivo escreve o tempo; a regra pessoal de verdade é da G10 (a fonte usa os 45 s/página da única sessão com páginas) |
| Alturas das barras | `min × 4/3` (D-10) | px do arquivo | D-10 |
| Senhora | "Quero ler" | "Novo" | pela regra da D-85, livro "quero ler" é "Quero ler"; a prancha desenhou "Novo" |

## Revisão independente

Um agente separado leu tudo sem editar. Ele confirmou que o caminho da fixture não mudou e encontrou **13 achados**: 2 altos, 5 médios e 6 baixos, todos no caminho real. **11 foram corrigidos** com teste novo, que falhou antes da correção. Detalhes em `G08.md`. Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 (alta) | A foto não voltava na sessão depois de uma falha passageira | A capa tenta de novo enquanto está na tela |
| 2 (alta) | Falha no catálogo ou no Clube derrubava a Início inteira | Essas seções somem e o erro vai para o relatório de falhas; com dados na tela, um erro novo não troca a tela |
| 3 (média) | "Hoje" e a saudação ficavam parados depois de o celular dormir | Recálculo em 0h/5h/12h/18h e na volta do app |
| 4 (média) | Autor com muitas edições perdia as da língua do aparelho | A ordem sai do SQL antes do limite |
| 5 (média) | Wi-Fi com página de login marcava "sem capa" por 7 dias | Vira falha passageira (10 min) |
| 6 (média) | O convidado piscava para quem tem conta | O usuário da conta entra por cima dos dados |
| 7 (média) | O dia local usava um fuso só (horário de verão), e datas em outro formato derrubavam a tela | Cada sessão usa o fuso dela; data ilegível é ignorada |

Os dois achados baixos que tinham ficado foram corrigidos na **G08.6-correção** (pedido seu em 05/10/2026), com teste que falhou antes:
- **Livro "lendo" nunca aberto aparecia no herói e também em Recém-chegados.** Agora cada livro aparece uma vez: Recém-chegados = só "quero ler" nunca abertos. A pílula "Novo" fica para a G09 (status do livro importado).
- **Capa vinda de qualquer host https.** Agora só os hosts das fontes de capa (Open Library e archive.org, Google Books, Hardcover, ISBNdb), medidos no Windows e conferidos também nos redirecionamentos. Fora da lista: recuo pelo ISBN ou capa gerada.

## Pendências

- **Clube no Supabase** (D-80): a G21 grava o resumo do clube no cache do social (o formato está documentado em `cached_club_ticket_source.dart`) e o ticket aparece sozinho.
- **Notificações** (o ponto do sininho) também ficam para a G21.
- **Privacidade:**
  - a política deve dizer que a foto da capa é pedida direto à fonte, sem conta nem identificador, e que a fonte vê o IP;
  - a futura tela Sobre deve ter o link de cortesia ao Open Library (D-79).
- **Celular** (quando você ligar):
  - abrir com a estante vazia;
  - escanear um livro e ver Recém-chegados com a foto;
  - pôr em modo avião e reabrir: a foto continua;
  - voltar ao app no dia seguinte: "Bom dia" e a semana andaram.
- **"Novo" em Recém-chegados:** a regra entra na G09 (status do livro importado); até lá, só "Quero ler".

✅ FASE G08 concluída — aguardando sua aprovação para iniciar a FASE G09.
