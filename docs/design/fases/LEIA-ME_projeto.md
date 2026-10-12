# Fases de tela L — Biblioteca, scanner e busca, entrada, perfil e ajustes, cronômetro (as 41 telas das etapas 7–11)

Geradas na T13 (`CONJUNTO=projeto python3 tools/medicao/gen_fases.py`) a partir das medições do projeto completo do design (`docs/design/projeto/telas/*.dc.html`). Cada fase L é executada dentro da etapa indicada (`docs/ROTEIRO.md`: T14 Biblioteca, T15 Scanner e busca, T16 Entrada e onboarding, T17 Perfil, ajustes, conta, privacidade e notificações, T18 Cronômetro) e segue o formato da v1 (`design_handoff/fases/F05_hero_continuar_lendo.md`). As notas de cada tela no `docs/design/projeto/NOTAS.md` valem junto com a fase.

Tokens novos e mapa id → widget: `L00_projeto_tokens_e_widgets.md`.

| Fase | O que é | Fase T | Tela | ids |
|---|---|---|---|---|
| [L02_1_cabecalho](L02_1_cabecalho.md) | Biblioteca — título, adicionar, busca e filtros | T14 | 02 | 11 |
| [L02_2_colecoes](L02_2_colecoes.md) | Biblioteca — Coleções (cartões com a pilha de lombadas) | T14 | 02 | 40 |
| [L02_3_status_e_ordem](L02_3_status_e_ordem.md) | Biblioteca — abas de status, ordenar e grade/lista | T14 | 02 | 23 |
| [L02_4_estante](L02_4_estante.md) | Biblioteca — a estante (4 prateleiras de 3 livros) | T14 | 02 | 161 |
| [L02_5_barra](L02_5_barra.md) | Biblioteca — degradê inferior e barra de navegação | T14 | 02 | 18 |
| [L36_biblioteca_vazia](L36_biblioteca_vazia.md) | Biblioteca vazia — a prateleira esperando o primeiro livro | T14 | 36 | 41 |
| [L17_1_capa](L17_1_capa.md) | Detalhes (livro físico) — barra do topo, sol retrô e a capa na prateleira | T14 | 17 | 21 |
| [L17_2_titulo_e_status](L17_2_titulo_e_status.md) | Detalhes (livro físico) — título, autor, ano, formato e status | T14 | 17 | 12 |
| [L17_3_sessao](L17_3_sessao.md) | Detalhes (livro físico) — cartão da sessão de leitura (cronômetro e página opcional) | T14 | 17 | 16 |
| [L17_4_clima](L17_4_clima.md) | Detalhes — Clima do livro (humor, ritmo, personagens × trama) | T14 | 17 | 27 |
| [L17_5_sinopse](L17_5_sinopse.md) | Detalhes — Sinopse e ficha (páginas, ano, formato, ISBN) | T14 | 17 | 18 |
| [L17_6_grifos_e_clube](L17_6_grifos_e_clube.md) | Detalhes (livro físico) — Seus grifos, fotografar um trecho e a enquete do clube | T14 | 17 | 18 |
| [L17b_1_progresso](L17b_1_progresso.md) | Detalhes (e-book) — cartão do progresso (onde parou, barra, Continuar lendo, grifos) | T14 | 17b | 19 |
| [L17b_2_grifos_e_clube](L17b_2_grifos_e_clube.md) | Detalhes (e-book) — Seus grifos (Ver os 12) e o próximo encontro do clube | T14 | 17b | 17 |
| [L03_1_camera](L03_1_camera.md) | Scanner — a câmera congelada no verso do livro, a moldura, o código lido e o chip "Código lido" | T15 | 03 | 18 |
| [L03_2_controles](L03_2_controles.md) | Scanner — barra do topo (fechar, Código | Digitar e a lanterna) | T15 | 03 | 10 |
| [L03_3_folha](L03_3_folha.md) | Scanner (livro encontrado) — a folha: o livro, a coleção, Salvar como e Adicionar à biblioteca | T15 | 03 | 37 |
| [L39_mirando](L39_mirando.md) | Scanner (mirando) — a linha que varre a moldura e a folha de dicas | T15 | 39 | 14 |
| [L40_nao_encontrado](L40_nao_encontrado.md) | Scanner (livro não encontrado) — a folha: fora da nossa base, Salvar como e Adicionar à mão | T15 | 40 | 25 |
| [L41_sem_permissao](L41_sem_permissao.md) | Scanner (sem permissão de câmera) — o fundo listrado e a folha que pede a câmera | T15 | 41 | 15 |
| [L42_na_estante](L42_na_estante.md) | Scanner (já está na estante) — a folha: o progresso, a meta do dia e Iniciar leitura | T15 | 42 | 34 |
| [L69_1_titulo_e_etiqueta](L69_1_titulo_e_etiqueta.md) | Digitar o ISBN — o título e a etiqueta que imprime as barras enquanto a pessoa digita | T15 | 69 | 31 |
| [L69_2_teclado](L69_2_teclado.md) | Digitar o ISBN — a barra de teclas do app (X, colar, esconder) sobre o teclado numérico do sistema | T15 | 69 | 41 |
| [L69b_nao_confere](L69b_nao_confere.md) | Digitar o ISBN (não confere) — a etiqueta tremida, o X digitado e o aviso | T15 | 69b | 27 |
| [L28_1_busca_e_titulo](L28_1_busca_e_titulo.md) | Busca (Explorar) — barra de busca, brilho e o título "O que vamos ler agora?" | T15 | 28 | 11 |
| [L28_2_recentes_e_clima](L28_2_recentes_e_clima.md) | Busca (Explorar) — buscas recentes e os climas | T15 | 28 | 22 |
| [L28_3_generos](L28_3_generos.md) | Busca (Explorar) — os 8 gêneros (cada um com o livrinho inclinado) | T15 | 28 | 52 |
| [L28_4_em_alta](L28_4_em_alta.md) | Busca (Explorar) — Em alta nos clubes (carrossel de 4 livros) | T15 | 28 | 59 |
| [L28b_1_abas_e_livros](L28b_1_abas_e_livros.md) | Busca (resultados) — as abas por tipo e os livros (o seu e o novo) | T15 | 28b | 38 |
| [L28b_2_clubes_e_trechos](L28b_2_clubes_e_trechos.md) | Busca (resultados) — os clubes, os seus trechos e o cartão do scanner | T15 | 28b | 43 |
| [L28c_nada_encontrado](L28c_nada_encontrado.md) | Busca (nada encontrado) — o desenho, o texto, Escanear e Adicionar à mão, e as dicas | T15 | 28c | 19 |
| [L28d_1_topo_e_capa](L28d_1_topo_e_capa.md) | Adicionar à mão — o topo, o título e a capa automática (trocar, fotos e as 5 cores) | T15 | 28d | 29 |
| [L28d_2_formulario](L28d_2_formulario.md) | Adicionar à mão — o formulário (título, autor, formato, páginas, ISBN, Salvar como) e o botão | T15 | 28d | 32 |
| [L35_abertura](L35_abertura.md) | Abertura — as ondas, o carimbo que pousa, a marca BookNest e a barra de carregar | T16 | 35 | 14 |
| [L07_1_fundo_e_marca](L07_1_fundo_e_marca.md) | Login — as ondas, a capa ilustrada, o selo, os brilhos e a marca | T16 | 07 | 11 |
| [L07_2_folha](L07_2_folha.md) | Login — a folha: "Sua história começa aqui.", Google, Apple, e-mail e os termos | T16 | 07 | 17 |
| [L08_cadastro](L08_cadastro.md) | Cadastro — a carteirinha que se preenche e o formulário (nome, e-mail, senha com a força) | T16 | 08 | 55 |
| [L09_entrar](L09_entrar.md) | Entrar — o selo e a folha (e-mail, senha, "ou" e o código por e-mail) | T16 | 09 | 34 |
| [L09b_senha_incorreta](L09b_senha_incorreta.md) | Entrar (senha incorreta) — o campo rosado, o aviso e o código em amarelo | T16 | 09b | 30 |
| [L10_codigo](L10_codigo.md) | Código de 6 dígitos — o envelope e a folha (as 6 peças, reenviar e abrir o e-mail) | T16 | 10 | 34 |
| [L11_nova_senha](L11_nova_senha.md) | Nova senha — o cadeado aberto e a folha (a senha, a força, as regras e os outros aparelhos) | T16 | 11 | 47 |
| [L12_1_topo_e_meta_diaria](L12_1_topo_e_meta_diaria.md) | Onboarding 1/4 — o topo com a barra, o título e os minutos por dia | T16 | 12 | 38 |
| [L12_2_meta_do_ano](L12_2_meta_do_ano.md) | Onboarding 1/4 — a meta do ano e o Continuar | T16 | 12 | 13 |
| [L13_generos](L13_generos.md) | Onboarding 2/4 — os gêneros (15 e "Mais gêneros") e o Continuar com a contagem | T16 | 13 | 57 |
| [L14_1_busca](L14_1_busca.md) | Onboarding 3/4 — o título, a busca e o scanner | T16 | 14 | 11 |
| [L14_2_sugestoes](L14_2_sugestoes.md) | Onboarding 3/4 — as 6 sugestões (3 já na estante) e o Continuar | T16 | 14 | 73 |
| [L13b_dica_scanner](L13b_dica_scanner.md) | Onboarding 3/4 (dica) — o foco no scanner, a seta, "é aqui!" e o cartão | T16 | 13b | 17 |
| [L15_foto_e_arroba](L15_foto_e_arroba.md) | Onboarding 4/4 — a foto, o @ e a frase sobre você | T16 | 15 | 41 |
| [L16_carteirinha](L16_carteirinha.md) | Carteirinha pronta — os confetes, a carteirinha, o carimbo e a folha | T16 | 16 | 47 |
| [L36a_inicio_primeiro_acesso](L36a_inicio_primeiro_acesso.md) | Início no primeiro acesso — o cartão do primeiro livro, a meta de hoje e o convite de clube | T16 | 36a | 45 |
| [L05_1_capa](L05_1_capa.md) | Perfil — o @ e os ajustes, a capa do perfil (avatar com a sequência, nome, bio e números), a carteirinha, Editar/Compartilhar e as abas | T17 | 05 | 49 |
| [L05_2_lendo_e_ano](L05_2_lendo_e_ano.md) | Perfil — Lendo agora (3 capas com o marcador) e 2026 em leitura (a meta, a estante de 24 lombadas e 6 vagas, os números) | T17 | 05 | 112 |
| [L05_3_favoritos_e_conquistas](L05_3_favoritos_e_conquistas.md) | Perfil — os 4 livros que me definem na prateleira e as conquistas (4 medalhas e a próxima, com a barra) | T17 | 05 | 71 |
| [L05_4_atividade](L05_4_atividade.md) | Perfil — a atividade recente (desenho, grifo e resenha com estrelas), o degradê e a navegação (aba Perfil) | T17 | 05 | 50 |
| [L64_1_previa_e_cor](L64_1_previa_e_cor.md) | Editar perfil — o topo, a prévia ao vivo da capa, as cores da capa e o tipo de avatar | T17 | 64 | 41 |
| [L64_2_campos](L64_2_campos.md) | Editar perfil — nome, @ e bio, pronomes e gêneros favoritos | T17 | 64 | 51 |
| [L64_3_quatro_e_salvar](L64_3_quatro_e_salvar.md) | Editar perfil — os 4 que me definem (o número, trocar e a alça de arrastar) e o Salvar preso embaixo | T17 | 64 | 60 |
| [L65_trocar_livro](L65_trocar_livro.md) | Editar perfil, trocar um dos 4 — o escurecido e a folha (o livro de hoje, a busca, as 4 opções com estrelas e o botão) | T17 | 65 | 92 |
| [L06_1_conta](L06_1_conta.md) | Ajustes — o voltar, o título, a busca, a conta (capa de livro) e a assinatura | T17 | 06 | 27 |
| [L06_2_leitura](L06_2_leitura.md) | Ajustes — Leitura: o tema das páginas, a fonte, o tamanho do texto, virar páginas e a tela acesa | T17 | 06 | 59 |
| [L06_3_metas](L06_3_metas.md) | Ajustes — Metas e lembretes: as duas metas com menos e mais, o lembrete com o horário e a proteção da sequência | T17 | 06 | 42 |
| [L06_4_mais_e_ajuda](L06_4_mais_e_ajuda.md) | Ajustes — Mais ajustes, Ajuda e o rodapé (sair, excluir, versão) | T17 | 06 | 66 |
| [L58_conta](L58_conta.md) | Conta — a capa da conta, Entrar, Sincronização (aparelhos, ler sem internet), Seus dados, sair e excluir | T17 | 58 | 85 |
| [L59_excluir_conta](L59_excluir_conta.md) | Excluir conta — o que vai embora, as alternativas, digitar EXCLUIR e o botão preso embaixo | T17 | 59 | 49 |
| [L56_privacidade](L56_privacidade.md) | Privacidade — o tipo de perfil, quem vê o quê, pessoas (pedidos, achar pelo e-mail, bloqueadas) e o aviso de bloqueio | T17 | 56 | 111 |
| [L30_1_topo_e_hoje](L30_1_topo_e_hoje.md) | Notificações — o topo, o título, o resumo e os avisos de hoje (dois em cartão, não lidos) | T17 | 30 | 60 |
| [L30_2_semana](L30_2_semana.md) | Notificações — os avisos da semana e a nota do fim | T17 | 30 | 33 |
| [L30b_1_lembrete](L30b_1_lembrete.md) | Lembretes e avisos — o lembrete de leitura (horário, dias, só se não leu, a prévia do aviso) | T17 | 30b | 43 |
| [L30b_2_avisos_e_silencio](L30b_2_avisos_e_silencio.md) | Lembretes e avisos — avisar sobre (5 chaves) e não incomodar (das → até) | T17 | 30b | 64 |
| [L30c_tudo_em_dia](L30c_tudo_em_dia.md) | Notificações, tudo em dia — o topo (marcar como lido apagado), o desenho, o texto, Ajustar lembretes e o lembrete marcado | T17 | 30c | 19 |
| [L18_1_topo_e_tempo](L18_1_topo_e_tempo.md) | Cronômetro — a barra de cima (minimizar, a sessão e o som ambiente), o livro e o relógio (o anel, o estado, o tempo e o de hoje) | T18 | 18 | 20 |
| [L18_2_controles](L18_2_controles.md) | Cronômetro — as etiquetas da meta e da sequência, Trecho/Pausar/Encerrar, anotar um pensamento e o aviso de bloquear a tela | T18 | 18 | 23 |
| [L18b_fim_da_sessao](L18b_fim_da_sessao.md) | Fim da sessão — o escurecido, os confetes e a folha (o selo, o título, os três números, a página onde parou, salvar e pular) | T18 | 18b | 45 |
