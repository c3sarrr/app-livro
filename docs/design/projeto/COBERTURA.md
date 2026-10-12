# Cobertura — as 128 telas do projeto no app

> Criada na R00 (11/10/2026). Uma linha por tela do `CATALOGO.md`, na mesma ordem (as 3 pranchas da 83 em 3 linhas),
> mais as 9 que o Mapa (00) marca como faltando e o que o design deixou para o futuro. **Toda etapa de tela atualiza
> as linhas dela** (ROTEIRO §4, item 6); `test/design/cobertura_test.dart` confere esta tabela com o catálogo e com o
> ROTEIRO §3. Não editar o `CATALOGO.md` nem os arquivos do projeto: esta é a folha de controle.

**Situação:** ✅ feita e igual à prancha (com a exceção aprovada escrita na linha) · 🟠 feita, mas diferente — uma rota
mostra hoje uma versão provisória ou mínima daquela tela ou estado · ⬜ não feita. **Etapa:** a do ROTEIRO §3 que faz
(ou fez) a tela.

## Resumo

| Etapa | ✅ | 🟠 | ⬜ | Total |
|---|---|---|---|---|
| 0 · G00–G22 | 9 | 0 | 0 | 9 |
| 1 · T01 | 4 | 0 | 0 | 4 |
| 3 · T03 | 2 | 0 | 0 | 2 |
| 4 · T04 | 1 | 0 | 0 | 1 |
| 7 · T14 | 0 | 0 | 4 | 4 |
| 8 · T15 | 0 | 8 | 3 | 11 |
| 9 · T16 | 0 | 4 | 10 | 14 |
| 10 · T17 | 0 | 2 | 8 | 10 |
| 11 · T18 | 0 | 2 | 0 | 2 |
| 12 · T05 | 0 | 0 | 3 | 3 |
| 14 · T07 | 0 | 0 | 1 | 1 |
| 15 · T08 | 0 | 0 | 1 | 1 |
| 16 · T09 | 0 | 0 | 1 | 1 |
| 17 · T10 | 0 | 0 | 4 | 4 |
| 18 · T11 | 0 | 0 | 7 | 7 |
| 19 · T12 | 0 | 0 | 2 | 2 |
| 20 · T19 | 0 | 2 | 6 | 8 |
| 21 · T20 | 0 | 0 | 10 | 10 |
| 22 · T21 | 0 | 0 | 7 | 7 |
| 23 · T22 | 0 | 0 | 18 | 18 |
| 24 · T23 | 0 | 0 | 7 | 7 |
| 25 · T24 | 0 | 0 | 2 | 2 |
| **Todas** | **16** | **18** | **94** | **128** |

## As 128 telas

| Nº | Título | Arquivo | Rota no app | Situação | Etapa | Observação |
|---|---|---|---|---|---|---|
| 01 | Início (Home) | `telas/Main.dc.html` | `/inicio` | ✅ | 3 · T03 | a Início nova (D-240); com dados reais o cartão "Seus grifos de hoje" some até a T05 (D-247) e o título curto ("Brás Cubas") só vem com o campo da T14 (D-270) |
| 01b | Início — lendo agora (cronômetro ativo) | `telas/MainLendo.dc.html` | `/inicio` | ✅ | 4 · T04 | a mini-barra do cronômetro nas 4 abas (D-259) e a folha mínima da sessão (D-256); com dados reais o título curto só vem com o campo da T14 (D-270) |
| 60 | Início — grifos de hoje (revisão) | `telas/MainRevisao.dc.html` | `/inicio` | ✅ | 3 · T03 | a 01 rolada até o cartão da revisão (D-241); o cartão só com a fixture até a T05 (D-247) |
| 61 | Revisão — grifo 2 de 5 | `telas/RevisaoGrifo.dc.html` | — | ⬜ | 12 · T05 |  |
| 62 | Revisão — fim | `telas/RevisaoFim.dc.html` | — | ⬜ | 12 · T05 |  |
| 63 | Revisão — imagem para compartilhar | `telas/RevisaoCompartilhar.dc.html` | — | ⬜ | 12 · T05 |  |
| 02 | Biblioteca | `telas/Biblioteca.dc.html` | `/biblioteca` | ⬜ | 7 · T14 | placeholder com o bloco mínimo de importar EPUB/PDF (D-87, D-21); medida na T13 (fases `L02_1_cabecalho` a `L02_5_barra`) |
| 03 | Scanner — livro encontrado | `telas/Scanner.dc.html` | `/scanner` | 🟠 | 8 · T15 | scanner provisório (D-76): o cartão do livro achado; medida na T13 (fases `L03_1_camera` a `L03_3_folha`) |
| 39 | Scanner — mirando | `telas/ScannerMirando.dc.html` | `/scanner` | 🟠 | 8 · T15 | scanner provisório (D-76): a câmera num cartão e "Aponte para o código de barras…"; medida na T13 (fase `L39_mirando`) |
| 40 | Scanner — livro não encontrado | `telas/ScannerNaoEncontrado.dc.html` | `/scanner` | 🟠 | 8 · T15 | scanner provisório (D-76): "Não achamos o ISBN …"; medida na T13 (fase `L40_nao_encontrado`) |
| 41 | Scanner — sem permissão de câmera | `telas/ScannerSemPermissao.dc.html` | `/scanner` | 🟠 | 8 · T15 | scanner provisório (D-76): o texto "Sem acesso à câmera…" e o digitar; medida na T13 (fase `L41_sem_permissao`) |
| 42 | Scanner — já está na estante | `telas/ScannerNaEstante.dc.html` | `/scanner` | 🟠 | 8 · T15 | scanner provisório (D-76): o "já está na estante"; medida na T13 (fase `L42_na_estante`) |
| 69 | Scanner — digitar o ISBN | `telas/ScannerDigitar.dc.html` | `/scanner` | 🟠 | 8 · T15 | scanner provisório (D-76): a pílula "Digitar ISBN" e o campo; medida na T13 (fases `L69_1_titulo_e_etiqueta` a `L69_2_teclado`) |
| 69b | Scanner — ISBN não confere | `telas/ScannerDigitarErro.dc.html` | `/scanner` | 🟠 | 8 · T15 | scanner provisório (D-76): o aviso de ISBN inválido; medida na T13 (fase `L69b_nao_confere`) |
| 04 | Clube — Leitoras de Capitu | `telas/Clube.dc.html` | `/clubes` | ⬜ | 14 · T07 | placeholder (o clube existe só como dado, G21) |
| 31 | Clube — discussão da semana (sem spoiler) | `telas/ClubeDiscussao.dc.html` | `/clube/:clubId/discussao` | ⬜ | 15 · T08 | placeholder |
| 32 | Clube — membros e onde cada uma está | `telas/ClubeMembros.dc.html` | — | ⬜ | 16 · T09 |  |
| 33 | Criar clube | `telas/ClubeCriar.dc.html` | — | ⬜ | 19 · T12 |  |
| 34 | Clube criado — convite (link e QR) | `telas/ClubeConvite.dc.html` | — | ⬜ | 19 · T12 |  |
| 47 | Enquete — criar | `telas/EnqueteCriar.dc.html` | — | ⬜ | 18 · T11 |  |
| 48 | Enquete — indicar um livro | `telas/EnqueteIndicar.dc.html` | — | ⬜ | 18 · T11 |  |
| 49 | Enquete — votar | `telas/EnqueteVotar.dc.html` | — | ⬜ | 18 · T11 |  |
| 50 | Enquete — resultado | `telas/EnqueteResultado.dc.html` | — | ⬜ | 18 · T11 |  |
| 70 | Encontro — detalhe (dom 20 set) | `telas/EncontroDetalhe.dc.html` | — | ⬜ | 17 · T10 |  |
| 71 | Encontro — na hora (sala aberta) | `telas/EncontroNaHora.dc.html` | — | ⬜ | 17 · T10 |  |
| 72 | Encontro — mudar presença com recado | `telas/EncontroPresenca.dc.html` | — | ⬜ | 17 · T10 |  |
| 73 | Encontro — depois (resumo) | `telas/EncontroDepois.dc.html` | — | ⬜ | 17 · T10 |  |
| 102 | Quem votou (enquete aberta, da 04) | `telas/EnqueteQuemVotou.dc.html` | — | ⬜ | 18 · T11 |  |
| 103 | Quem votou (resultado, da 50) | `telas/EnqueteQuemVotouFinal.dc.html` | — | ⬜ | 18 · T11 |  |
| 104 | Voto secreto (variação) | `telas/EnqueteSecreta.dc.html` | — | ⬜ | 18 · T11 |  |
| 05 | Perfil | `telas/Perfil.dc.html` | `/perfil` | ⬜ | 10 · T17 | placeholder com o bloco mínimo da conta (D-69, D-21); medida na T13 (fases `L05_1_capa` a `L05_4_atividade`) |
| 29 | Estatísticas (semana) | `telas/Estatisticas.dc.html` | — | ⬜ | 22 · T21 |  |
| 43 | Perfil — Resenhas | `telas/PerfilResenhas.dc.html` | — | ⬜ | 21 · T20 |  |
| 44 | Perfil — Grifos (mural) | `telas/PerfilGrifos.dc.html` | — | ⬜ | 21 · T20 |  |
| 45 | Perfil — Listas | `telas/PerfilListas.dc.html` | — | ⬜ | 21 · T20 |  |
| 46 | Escrever resenha | `telas/EscreverResenha.dc.html` | — | ⬜ | 21 · T20 |  |
| 51 | Perfil da Júlia — em comum | `telas/PerfilJulia.dc.html` | — | ⬜ | 23 · T22 |  |
| 52 | Perfil da Júlia — grifos públicos | `telas/PerfilJuliaGrifos.dc.html` | — | ⬜ | 23 · T22 |  |
| 53 | Perfil fechado | `telas/PerfilPrivado.dc.html` | — | ⬜ | 23 · T22 |  |
| 54 | Em comum com a Júlia (os 21) | `telas/PerfilEmComum.dc.html` | — | ⬜ | 23 · T22 |  |
| 64 | Editar perfil | `telas/EditarPerfil.dc.html` | — | ⬜ | 10 · T17 | medida na T13 (fases `L64_1_previa_e_cor` a `L64_3_quatro_e_salvar`) |
| 65 | Editar perfil — trocar um dos 4 | `telas/EditarTrocar.dc.html` | — | ⬜ | 10 · T17 | medida na T13 (fase `L65_trocar_livro`) |
| 66 | Lista aberta — Machado do começo ao fim | `telas/ListaAberta.dc.html` | — | ⬜ | 21 · T20 |  |
| 67 | Lista — editar ordem | `telas/ListaEditar.dc.html` | — | ⬜ | 21 · T20 |  |
| 68 | Adicionar à lista | `telas/ListaAdicionar.dc.html` | — | ⬜ | 21 · T20 |  |
| 74 | Resenha aberta — Quincas Borba | `telas/ResenhaAberta.dc.html` | — | ⬜ | 21 · T20 |  |
| 75 | Resenha — responder comentário | `telas/ResenhaResponder.dc.html` | — | ⬜ | 21 · T20 |  |
| 76 | Resenha — quem curtiu | `telas/ResenhaCurtidas.dc.html` | — | ⬜ | 21 · T20 |  |
| 77 | Estatísticas — mês (setembro) | `telas/EstatisticasMes.dc.html` | — | ⬜ | 22 · T21 |  |
| 78 | Estatísticas — ano (2026 até agora) | `telas/EstatisticasAno.dc.html` | — | ⬜ | 22 · T21 |  |
| 79 | Conquistas — álbum de figurinhas | `telas/ConquistasAlbum.dc.html` | — | ⬜ | 22 · T21 |  |
| 80 | Conquistas — quase lá | `telas/ConquistasQuaseLa.dc.html` | — | ⬜ | 22 · T21 |  |
| 81 | Conquista — detalhe (brilhante) | `telas/ConquistaDetalhe.dc.html` | — | ⬜ | 22 · T21 |  |
| 82 | Conquista — figurinha nova | `telas/ConquistaNova.dc.html` | — | ⬜ | 22 · T21 |  |
| 89 | Seguidores (248) | `telas/Seguidores.dc.html` | — | ⬜ | 23 · T22 |  |
| 90 | Seguindo (180), índice no J | `telas/Seguindo.dc.html` | — | ⬜ | 23 · T22 |  |
| 91 | Remover seguidora | `telas/SeguidoresRemover.dc.html` | — | ⬜ | 23 · T22 |  |
| 92 | Seguidores da Júlia (Pro) | `telas/SeguidoresJulia.dc.html` | — | ⬜ | 23 · T22 |  |
| 06 | Ajustes (engrenagem) | `telas/Ajustes.dc.html` | — | ⬜ | 10 · T17 | medida na T13 (fases `L06_1_conta` a `L06_4_mais_e_ajuda`) |
| 56 | Privacidade | `telas/Privacidade.dc.html` | — | ⬜ | 10 · T17 | medida na T13 (fase `L56_privacidade`) |
| 57 | Pedidos para seguir | `telas/PedidosSeguir.dc.html` | — | ⬜ | 23 · T22 |  |
| 58 | Conta | `telas/Conta.dc.html` | `/perfil` | 🟠 | 10 · T17 | o bloco mínimo da conta (G05, D-21): exportar, sair (manter ou apagar deste aparelho), excluir; medida na T13 (fase `L58_conta`) |
| 59 | Excluir conta | `telas/ExcluirConta.dc.html` | `/perfil` | 🟠 | 10 · T17 | a confirmação "Excluir conta" do bloco da conta (G05, D-21); medida na T13 (fase `L59_excluir_conta`) |
| 93 | Quem vê suas resenhas (da 56) | `telas/PublicoResenhas.dc.html` | — | ⬜ | 23 · T22 |  |
| 94 | E as 8 já publicadas? | `telas/PublicoAntigas.dc.html` | — | ⬜ | 23 · T22 |  |
| 95 | Quem vê esta lista (da 67) | `telas/PublicoLista.dc.html` | — | ⬜ | 23 · T22 |  |
| 96 | Lista com perfil aberto (variação) | `telas/PublicoAberto.dc.html` | — | ⬜ | 23 · T22 |  |
| 97 | Quem vê este livro (da 17) | `telas/PublicoLivro.dc.html` | — | ⬜ | 23 · T22 |  |
| 98 | Bloqueadas (da 56) | `telas/Bloqueadas.dc.html` | — | ⬜ | 23 · T22 |  |
| 99 | Desbloquear a Renata | `telas/BloqueadasDesbloquear.dc.html` | — | ⬜ | 23 · T22 |  |
| 100 | Bloquear (do ⋯ do perfil) | `telas/BloqueadasBloquear.dc.html` | — | ⬜ | 23 · T22 |  |
| 101 | Clube: mensagem recolhida (variação) | `telas/ClubeRecolhida.dc.html` | — | ⬜ | 23 · T22 |  |
| 07 | Login | `telas/Login.dc.html` | `/entrar` | 🟠 | 9 · T16 | o Entrar mínimo (D-21): e-mail e código de 6 dígitos; medida na T13 (fases `L07_1_fundo_e_marca` a `L07_2_folha`) |
| 08 | Cadastro por e-mail | `telas/Cadastro.dc.html` | — | ⬜ | 9 · T16 | o app entra por código (D-64…D-69), sem senha: a T16 decide com a prancha; medida na T13 (fase `L08_cadastro`) |
| 09 | Entrar com e-mail | `telas/Entrar.dc.html` | — | ⬜ | 9 · T16 | o app entra por código (D-64…D-69), sem senha: a T16 decide com a prancha; medida na T13 (fase `L09_entrar`) |
| 09b | Entrar — senha incorreta | `telas/EntrarErro.dc.html` | — | ⬜ | 9 · T16 | o app entra por código (D-64…D-69), sem senha: a T16 decide com a prancha; medida na T13 (fase `L09b_senha_incorreta`) |
| 10 | Código de 6 dígitos | `telas/Codigo.dc.html` | `/entrar` | 🟠 | 9 · T16 | o campo "Código de 6 dígitos" do Entrar mínimo (D-21); medida na T13 (fase `L10_codigo`) |
| 11 | Nova senha | `telas/NovaSenha.dc.html` | — | ⬜ | 9 · T16 | o app entra por código (D-64…D-69), sem senha: a T16 decide com a prancha; medida na T13 (fase `L11_nova_senha`) |
| 12 | Onboarding 1/4 — Meta de leitura | `telas/Onboarding1.dc.html` | — | ⬜ | 9 · T16 | medida na T13 (fases `L12_1_topo_e_meta_diaria` a `L12_2_meta_do_ano`) |
| 13 | Onboarding 2/4 — Gêneros | `telas/Onboarding2.dc.html` | — | ⬜ | 9 · T16 | medida na T13 (fase `L13_generos`) |
| 13b | Onboarding — dica do scanner | `telas/OnboardingDica.dc.html` | — | ⬜ | 9 · T16 | medida na T13 (fase `L13b_dica_scanner`) |
| 14 | Onboarding 3/4 — Primeiros livros | `telas/Onboarding3.dc.html` | — | ⬜ | 9 · T16 | medida na T13 (fases `L14_1_busca` a `L14_2_sugestoes`) |
| 15 | Onboarding 4/4 — Foto e @ | `telas/Onboarding4.dc.html` | `/conta/cadastro` | 🟠 | 9 · T16 | a conclusão do cadastro mínima (D-21): o @, sem a foto; a idade (D-69) não tem prancha; medida na T13 (fase `L15_foto_e_arroba`) |
| 16 | Onboarding — Carteirinha pronta | `telas/OnboardingFinal.dc.html` | — | ⬜ | 9 · T16 | medida na T13 (fase `L16_carteirinha`) |
| 17 | Detalhes do livro — físico (Brás Cubas) | `telas/DetalhesFisico.dc.html` | `/livro/:bookId` | ⬜ | 7 · T14 | placeholder; medida na T13 (fases `L17_1_capa` a `L17_6_grifos_e_clube`) |
| 17b | Detalhes do livro — e-book (Dom Casmurro) | `telas/DetalhesDigital.dc.html` | `/livro/:bookId` | ⬜ | 7 · T14 | placeholder; medida na T13 (fases `L17b_1_progresso` a `L17b_2_grifos_e_clube`) |
| 18 | Cronômetro de leitura (livro físico) | `telas/Cronometro.dc.html` | folha da sessão | 🟠 | 11 · T18 | a folha mínima da sessão do papel (D-256) no lugar das duas; medida na T13 (fases `L18_1_topo_e_tempo` a `L18_2_controles`) |
| 18b | Fim da sessão (página opcional) | `telas/FimSessao.dc.html` | folha da sessão | 🟠 | 11 · T18 | a folha mínima da sessão do papel (D-256) no lugar das duas; medida na T13 (fase `L18b_fim_da_sessao`) |
| 19 | Leitor — modo limpo (e-book) | `telas/LeitorLimpo.dc.html` | `/leitor/:bookId` | ✅ | 0 · G00–G22 |  |
| 20 | Leitor — com controles | `telas/LeitorControles.dc.html` | `/leitor/:bookId` | ✅ | 0 · G00–G22 |  |
| 21 | Leitor — seleção de texto | `telas/LeitorSelecao.dc.html` | `/leitor/:bookId` | ✅ | 0 · G00–G22 | a versão corrigida aprovada (D-55) |
| 22 | Leitor — modo anotação | `telas/LeitorAnotacao.dc.html` | `/leitor/:bookId` | ✅ | 0 · G00–G22 |  |
| 23 | Leitor — ajustes da caneta | `telas/LeitorCaneta.dc.html` | `/leitor/:bookId` | ✅ | 1 · T01 |  |
| 24 | Leitor — abrindo espaço (arrastar) | `telas/LeitorEspacoAbrir.dc.html` | `/leitor/:bookId` | ✅ | 1 · T01 |  |
| 24b | Leitor — nota à mão escrita | `telas/LeitorEspaco.dc.html` | `/leitor/:bookId` | ✅ | 1 · T01 |  |
| 25 | Grifos e notas (Dom Casmurro) | `telas/Grifos.dc.html` | `/livro/:bookId/destaques` | ✅ | 0 · G00–G22 | as miniaturas de tinta (D-204) |
| 26 | Leitor — ajustes de leitura (Aa) | `telas/LeitorAjustes.dc.html` | `/leitor/:bookId` | ✅ | 0 · G00–G22 | "baixa visão" no lugar do texto da prancha (D-147) |
| 26b | Leitor — tema Noite (com controles) | `telas/LeitorNoite.dc.html` | `/leitor/:bookId` | ✅ | 0 · G00–G22 |  |
| 27 | Leitor — sumário | `telas/LeitorSumario.dc.html` | `/leitor/:bookId` | ✅ | 0 · G00–G22 |  |
| 27b | Leitor — sumário, aba Marcadas | `telas/LeitorMarcadas.dc.html` | `/leitor/:bookId` | ✅ | 0 · G00–G22 |  |
| 23b | Leitor — ajustes do marca-texto | `telas/LeitorMarcador.dc.html` | `/leitor/:bookId` | ✅ | 1 · T01 | a tinta coral (D-59) |
| 28 | Busca — Explorar (antes de digitar) | `telas/BuscaExplorar.dc.html` | — | ⬜ | 8 · T15 | a lupa da Início ainda sem ação (D-243 b); medida na T13 (fases `L28_1_busca_e_titulo` a `L28_4_em_alta`) |
| 28b | Busca — resultados (“capitu”) | `telas/BuscaResultados.dc.html` | — | ⬜ | 8 · T15 | a lupa da Início ainda sem ação (D-243 b); medida na T13 (fases `L28b_1_abas_e_livros` a `L28b_2_clubes_e_trechos`) |
| 28c | Busca — nada encontrado | `telas/BuscaVazia.dc.html` | — | ⬜ | 8 · T15 | a lupa da Início ainda sem ação (D-243 b); medida na T13 (fase `L28c_nada_encontrado`) |
| 28d | Adicionar livro à mão | `telas/AdicionarMao.dc.html` | `/scanner` | 🟠 | 8 · T15 | o "Digitar os dados" do "não achamos" do scanner provisório (D-76); medida na T13 (fases `L28d_1_topo_e_capa` a `L28d_2_formulario`) |
| 30 | Notificações (sino da Início) | `telas/Notificacoes.dc.html` | `/notificacoes` | ⬜ | 10 · T17 | placeholder; medida na T13 (fases `L30_1_topo_e_hoje` a `L30_2_semana`) |
| 30b | Lembretes e avisos (ajustes) | `telas/NotificacoesAjustes.dc.html` | — | ⬜ | 10 · T17 | medida na T13 (fases `L30b_1_lembrete` a `L30b_2_avisos_e_silencio`) |
| 30c | Notificações — tudo em dia | `telas/NotificacoesVazia.dc.html` | `/notificacoes` | ⬜ | 10 · T17 | placeholder (o vazio da 30); medida na T13 (fase `L30c_tudo_em_dia`) |
| 35 | Abertura (splash) | `telas/Splash.dc.html` | — | ⬜ | 9 · T16 | a abertura nativa do sistema; medida na T13 (fase `L35_abertura`) |
| 36a | Início — primeiro acesso (estante vazia) | `telas/InicioVazia.dc.html` | `/inicio` | 🟠 | 9 · T16 | o vazio da Início sem prancha (D-78…D-85, `home_states.dart`); medida na T13 (fase `L36a_inicio_primeiro_acesso`) |
| 36 | Biblioteca vazia (primeiro livro) | `telas/EstanteVazia.dc.html` | `/biblioteca` | ⬜ | 7 · T14 | placeholder; medida na T13 (fase `L36_biblioteca_vazia`) |
| 37 | Sem internet (clube offline) | `telas/SemInternet.dc.html` | — | ⬜ | 25 · T24 |  |
| 38 | Erro genérico | `telas/Erro.dc.html` | — | ⬜ | 25 · T24 |  |
| 83 | topo — variação A (carteirinha em destaque) | `telas/ProTopoA.dc.html` | — | ⬜ | 20 · T19 |  |
| 83 | topo — variação B (grátis × Pro, na nuvem) | `telas/ProTopoB.dc.html` | — | ⬜ | 20 · T19 |  |
| 83 | Planos Pro (anual marcado) | `telas/ProPlanosAnual.dc.html` | `/_pro` | 🟠 | 20 · T19 | a tela técnica do Pro, só em debug (D-230) |
| 84 | Planos Pro (mensal marcado) | `telas/ProPlanosMensal.dc.html` | `/_pro` | 🟠 | 20 · T19 | a tela técnica do Pro, só em debug (D-230) |
| 85 | Perfil da Júlia (bloqueado) | `telas/ProJuliaBloqueado.dc.html` | — | ⬜ | 20 · T19 |  |
| 86 | Estatísticas (mês e ano bloqueados) | `telas/ProEstatBloqueada.dc.html` | — | ⬜ | 20 · T19 |  |
| 87 | Bem-vinda ao Pro | `telas/ProBemVinda.dc.html` | — | ⬜ | 20 · T19 |  |
| 88 | Gerenciar assinatura | `telas/ProAssinatura.dc.html` | — | ⬜ | 20 · T19 | o "Gerenciar assinatura" do bloco da conta abre a loja (G22) |
| 105 | Convite: fim da sessão (folha) | `telas/ConviteSessao.dc.html` | — | ⬜ | 24 · T23 |  |
| 106 | Convite: 4º clube (Júlia chamou) | `telas/ConviteClube.dc.html` | — | ⬜ | 24 · T23 |  |
| 107 | Convite: cartão no Início | `telas/ConviteInicio.dc.html` | — | ⬜ | 24 · T23 |  |
| 108 | Convite: resumo do mês (1º out) | `telas/ConviteMes.dc.html` | — | ⬜ | 24 · T23 |  |
| 109 | Livro lido + convite pequeno | `telas/ConviteLivroLido.dc.html` | — | ⬜ | 24 · T23 |  |
| 110 | Compartilhar (grátis) + faixa Pro | `telas/ConviteCompartilhar.dc.html` | — | ⬜ | 24 · T23 |  |
| 111 | Celular novo: a estante ficou no outro | `telas/ConviteCelularNovo.dc.html` | — | ⬜ | 24 · T23 |  |

## As 9 que faltam no projeto (D-268)

Os cartões tracejados com "+" do Mapa (00), com a prioridade das notas do design (`NOTAS.md`, "telas-faltando"). Cada
uma entra na etapa da tela que a abre, pela §5 do ROTEIRO (perguntar, 3–5 referências, prancha em HTML em
`docs/design/novas/`, o "sim", e só então o Flutter).

| Tela que falta | Abre de | Prioridade do design | Etapa | O app hoje |
|---|---|---|---|---|
| Revisão · escrever nota | 61 | média | 12 · T05 | — |
| Coleções · ver todas | 02 | baixa | 7 · T14 | — |
| Trocar a capa (fotografar a sua edição) | 17, 17b | média | 7 · T14 | — |
| Busca dentro do livro | 20 | média | 8 · T15 | a busca mínima do leitor (D-23, D-120) |
| Exportar meus dados (LGPD) | 58, 59 | média | 10 · T17 | o "Exportar meus dados" do bloco da conta (G05, D-21) |
| Importar CSV de outro app | 58 | média | 10 · T17 | — |
| Aparência e acessibilidade | 06 | média | 10 · T17 | — |
| Carteirinha aberta (compartilhar como imagem) | 05, 16 | baixa | 10 · T17 | — |
| Enquete · deu empate (desempate de 24 h) | 47 | média | 18 · T11 | — |

## Fora da v1.0

| Tela | Por quê |
|---|---|
| Livros do ano (só em dezembro) | o design marca como "futuro (combinado)" (`NOTAS.md`, "telas-faltando"); D-268 → ROTEIRO §9 |
