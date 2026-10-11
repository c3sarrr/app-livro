# Relatório da FASE G06 — Sincronização Pro e e-books na nuvem

Data: 04/10/2026 · branch `feat/g06-sync` (a partir de `feat/g05-conta`) · nada enviado ao GitHub nem à
nuvem (D-63/D-71). Evidências de cada subfase: `docs/progresso/G06.md`.
Decisões usadas (respondidas por você em 04/10, antes da fase): D-70 confirmada · PowerSync local agora e
Cloud região Brasil na produção (D-71) · o social exige a faixa etária (D-72) · Q9 fica para depois.

## Antes da fase

| Pendência | O que fiz |
|---|---|
| D-72 — escrita social sem faixa registrada | gatilho `private.require_age_band` em 10 tabelas + perfil público (`15_social_exige_faixa`, 16 testes) |
| A CI não rodava os testes da página de exclusão | job `site` no workflow do banco (`deno fmt --check`, `lint`, `test`) |
| Git do WSL via todos os arquivos como mudados (CRLF) | `core.autocrlf input` no WSL |
| D-70, D-71, D-72 e Q9 | registradas no `handoff_v2/05` e no Anexo 02 §5.3 |

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G06.0 Ambiente | serviço PowerSync 1.26.1 (fixado pelo digest) no Docker do WSL, ligado ao Supabase local; Sync Streams com as 10 tabelas pessoais e o porteiro `billing.sync_access`; papel `powersync_role` só de leitura; a fila do Pro só aceita linhas do **dono ativo** | `16_powersync_papel` (12) + testes da fila |
| G06.1 Conector | credencial só com sessão e Pro confirmado pelo servidor; lotes de até 500 operações **e 2 MiB** para `sync_apply_changes`; recusa por linha guardada com a operação inteira; `pro_required` desliga; rede/5xx com recuo até 60 s; hora do servidor medida a cada credencial | `booknest_connector_test`, `sync_backend_test`, `sync_store_test`, `server_clock_test`, `17_relogio_do_servidor` |
| G06.2 Pro ⇄ Grátis | virar Pro reenfileira tudo e mostra o progresso; perder o Pro desliga **sem apagar nada**; voltar reenfileira; trocar de dono para a fila antes de mexer nos dados | `sync_engine_test`, `account_controller_test`, `local_library_test` |
| G06.3 Dois aparelhos | motor real + PowerSync local + Supabase local: virar Pro e o 2º baixa igual; offline com edições cruzadas e apagar × editar → **estados iguais**; relógio 10 min adiantado; perder o Pro não apaga nada | `sync_dois_aparelhos_test` (`--tags integracao`) |
| G06.4 E-books na nuvem | envio **retomável** (TUS com o token da URL assinada — provado com corte no meio e mesmo sha256), download de 5 min sob demanda que só guarda o arquivo certo, exclusão pelo servidor; o bucket não tem mais as políticas SELECT/DELETE | `18_ebooks_g06` (16), Deno `ebook-download-url` + `purge-storage`, `ebook_cloud_test`, prova `tools/supabase/provar_envio_retomavel.sh`, integração com 2 aparelhos |
| G06.5 Indicador (D-21) | uma linha discreta no bloco da conta (nada no Grátis); aviso de alterações não enviadas antes de sair/excluir | `sync_indicator_test`, `account_screens_test`; textos em `docs/design/estados_sem_design.md` |

Números finais: `flutter analyze` sem problemas · `flutter test` **973 verdes** (6 ignorados: os de integração, que rodam à parte) · integração com
Supabase + PowerSync locais **6/6** · `supabase test db` **20 arquivos, 475 testes** · `db lint` limpo · Edge
Functions **60 unitários + 9 de integração**.

## Revisão independente

Um agente separado leu tudo sem editar. Foram 12 achados — 3 altos. Corrigi todos, cada um com teste novo e
controle de mutação. A tabela completa está em `docs/progresso/G06.md`; os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 (alta) | Um aparelho que não sabia do e-book, com uma edição mais nova, apagava o arquivo da nuvem | o caminho do arquivo só muda para um arquivo que existe na pasta da conta e do livro |
| 2 (alta) | Relógio acertado depois da medida (ou uma versão no futuro lida de uma linha) mandava todas as escritas para o futuro e a RPC recusava | hora corrigida por âncora monotônica; versão longe no futuro não puxa o relógio; a linha recusada é reemitida com a hora certa |
| 3 (alta) | Numa troca de conta no meio do caminho, a biblioteca de uma conta podia subir para outra | a RPC recusa linha de outro dono (`owner_mismatch`); o conector confere a sessão e o dono; a conta só segue com a sessão confirmada |
| 4–11 | travamento ao sair, recusas 23503 presas, junção ignorada pelo servidor, lote grande, dados que ficavam ao "apagar deste aparelho", arquivos órfãos, ordem de parada, estados do envio retomável | corrigidos — ver `G06.md` |

Controles de mutação: **app 35/35** e **SQL 11/11** — toda variante com o defeito reprova nos testes (lista em `G06.md`).

## Decisão de desenho (registrada no ADR-003)

A versão de uma linha recusada por estar no futuro (`invalid_hlc`) pode **descer uma vez** — ela nunca chegou
ao servidor nem a outro aparelho. Fora disso, nenhuma escrita local grava versão menor que a gravada.

## O que fica pendente (registrado)

- **Botões do e-book na nuvem** ("Guardar na nuvem" / "Baixar"): o serviço está pronto; a tela do livro ainda
  não tem design (G09 em diante).
- **Produção (D-63/D-71):** PowerSync Cloud região Brasil, chaves e o PowerSync na lista de suboperadores.
- **Compra do Pro:** o SDK do RevenueCat entra na G22; hoje o Pro é conferido no servidor (`my_entitlement`).
- **Q9 — hospedagem/domínio** da página de exclusão (G25/G27).
- **iOS (precisa de Mac):** os itens da G05 continuam.

## Commits

Ver `git log feat/g05-conta..feat/g06-sync` (um por subfase e um da revisão, mensagens em português).
