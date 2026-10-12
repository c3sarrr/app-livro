"""T13.11 (R7) — nomes e notas dos <svg> das 41 telas das etapas 7–11, lidos pelo exportar_svgs.py quando
CONJUNTO=projeto (conjuntos.json → svgNomes). Mesmo formato das tabelas da T02 (svgs_nomes_inicio2.py), com a
descrição de cada desenho (3º campo, o comentário da classe da área no app).

Reuso (D-283): o desenho que já existe como asset não é copiado — a comparação é pelo DESENHO: C14N sem o width/height
da raiz, com os ids internos renumerados e sem o stroke-linejoin quando nenhum traço tem junta (o "+" e a lupa com e
sem linejoin, os selos da 09 e da 09b com outro nome de id). As capas Brás Cubas e Dom Casmurro dos Detalhes são as da
Início; a lupa, o check e o "+" do leitor; os ícones da barra de navegação da v1.
Áreas (D-284): cada arquivo novo fica na pasta e na classe da 1ª etapa que o usa (T14 biblioteca, T15 scanner, T16
entrada, T17 perfil, T18 cronometro); as etapas seguintes usam aquela classe.
Nomes: os ícones em inglês (como os existentes), as ilustrações e os gráficos em português; quando o nome do desenho
já existe noutra pasta, um qualificador do uso ou do traço (`ic_plus_cabecalho`, `ic_check_bold`); variantes de cor
com o sufixo de VARIANTE. Nenhum nome novo repete nome de arquivo existente (o exportador confere).
"""

DOC = ('T13.11 — os <svg> das 41 telas das etapas 7–11 (tools/medicao/tmp/projeto/svgs.json), com as cores aplicadas '
       'e sem duplicatas; os que já existem como asset apontam para o arquivo existente (reuso pelo desenho, D-283) e '
       'os novos ficam na pasta da área da 1ª etapa que os usa (D-284).')

# primeiro id de cada desenho → (destino, nome-base, descrição). O sufixo de variante vem de VARIANTE (cor distintiva);
# um id de variante listado aqui dá o nome dela (precisa na variante sem cor distintiva: a tinta de um desenho
# colorido); as outras variantes listadas repetem o nome que o sufixo daria.
NOMES = {
    # ── T14 · Biblioteca (02, 36, 17, 17b) ──────────────────────────────────────────────────────────────────────
    'b02.header.add.icon': ('ic', 'ic_plus_cabecalho', '"+" do cabeçalho (adicionar livro)'),
    'b02.search.field.icon': ('ic', 'ic_search', 'lupa do campo de busca'),
    'b02.search.filters.icon': ('ic', 'ic_filters', 'filtros (dois controles deslizantes)'),
    'b02.collections.seeAll.icon': ('ic', 'ic_arrow_right', 'seta "ver todas"'),
    'b02.sortView.sort.icon': ('ic', 'ic_sort', 'ordenar (setas para cima e para baixo)'),
    'b02.sortView.sort.chevron': ('ic', 'ic_chevron_down', 'chevron para baixo'),
    'b02.sortView.toggle.grid.icon': ('ic', 'ic_view_grid', 'ver em grade'),
    'b02.sortView.toggle.list.icon': ('ic', 'ic_view_list', 'ver em lista'),
    'b02.shelf.book1.ribbon': ('il', 'il_fita_marcador', 'fita de marcador coral pendurada na capa da estante'),
    'b02.shelf.book5.info.tag.icon': ('ic', 'ic_check_bold', 'check de traço 3 (lido)'),
    'b02.shelf.book7.info.notes.icon': ('ic', 'ic_highlighter_bold', 'marca-texto de traço 2 (grifos do livro)'),
    'b02.nav.home.icon': ('ic', 'ic_nav_home', 'aba Início'),
    'b02.nav.library.icon': ('ic', 'ic_nav_library_active', 'aba Estante ativa'),
    'b02.nav.scanner.icon': ('ic', 'ic_nav_scanner', 'aba Scanner'),
    'b02.nav.clubs.icon': ('ic', 'ic_nav_clubs', 'aba Clubes'),
    'b02.nav.profile.icon': ('ic', 'ic_nav_profile', 'aba Perfil'),
    'b36.illustration.book.icon': ('ic', 'ic_sparkle', 'brilho com contorno'),
    'e35.sparkleSmall': ('ic', 'ic_sparkle_tinta', 'brilho com contorno cheio de tinta'),
    'b36.actions.scan.icon': ('ic', 'ic_scan_barcode', 'escanear código de barras (moldura com barras)'),
    'b36.actions.ebook.icon': ('ic', 'ic_file_download', 'arquivo com seta para baixo (importar e-book)'),
    'd17.header.back.icon': ('ic', 'ic_arrow_left', 'voltar'),
    'd17.header.share.icon': ('ic', 'ic_share', 'compartilhar'),
    'd17.header.more.icon': ('ic', 'ic_more_dots', 'mais'),
    'd17.cover.book.art': ('il', 'il_capa_bras_cubas_asas', 'capa Brás Cubas com asas'),
    'd17.cover.formatTag.icon': ('ic', 'ic_book_paper', 'livro de papel'),
    'd17.cover.sparkleSmall': ('ic', 'ic_sparkle_solid', 'brilho cheio'),
    'd17.cover.change.icon': ('ic', 'ic_camera_swap', 'câmera com setas (trocar a capa)'),
    'd17.meta.format.icon': ('ic', 'ic_book_closed', 'livro fechado do formato (meta dos Detalhes)'),
    'd17.session.ring': ('graf', 'anel_sessao_livro', 'anel de progresso da sessão do livro'),
    'd17.session.start.icon': ('ic', 'ic_stopwatch_amarelo', 'cronômetro amarelo (começar a ler)'),
    'd17.session.page.update.icon': ('ic', 'ic_pencil_line', 'lápis sobre a linha (atualizar a página)'),
    'd17.mood.split.fill.edge': ('graf', 'borda_onda_preenchimento', 'borda ondulada da ponta da barra preenchida'),
    'd17b.progress.bar.fill.edge': ('graf', 'borda_onda_preenchimento_tinta', 'a mesma borda, em tinta'),
    'd17.highlights.quote.caption.icon': ('ic', 'ic_camera', 'câmera (foto do trecho)'),
    'd17.highlights.club.chevron': ('ic', 'ic_chevron_right_clube', 'chevron para a direita do clube (traço 2,4)'),
    'd17b.cover.book.art': ('il', 'il_capa_dom_casmurro', 'capa Dom Casmurro'),
    'd17b.cover.formatTag.icon': ('ic', 'ic_tablet', 'leitor digital (formato e-book, traço 2,2)'),
    'd17b.meta.format.icon': ('ic', 'ic_tablet_meta', 'leitor digital do formato (meta dos Detalhes, traço 2)'),
    'd17b.progress.continue.icon': ('ic', 'ic_book_open', 'livro aberto'),
    'd17b.progress.highlights.icon': ('ic', 'ic_highlighter', 'marca-texto'),
    # ── T15 · Scanner e busca (03, 39, 40, 41, 42, 69, 69b, 28, 28b, 28c, 28d) ─────────────────────────────────────
    'sc03.camera.label.barcode': ('graf', 'codigo_barras_camera', 'código de barras do livro sob a câmera (03)'),
    'sc03.detected.badge.icon': ('ic', 'ic_check_small', 'check'),
    'sc03.corners': ('il', 'mira_scanner', 'cantos da mira do scanner'),
    'sc03.status.chip.badge.icon': ('ic', 'ic_check_read_amarelo', 'check amarelo do chip de status'),
    'sc03.controls.close.icon': ('ic', 'ic_close_bold', 'fechar'),
    'sc03.controls.mode.code.icon': ('ic', 'ic_barcode', 'código de barras (modo código)'),
    'sc03.controls.mode.type.icon': ('ic', 'ic_keyboard', 'teclado (modo digitar)'),
    'sc03.controls.torch.icon': ('ic', 'ic_flash', 'lanterna (raio)'),
    'sc03.sheet.book.collection.check.icon': ('ic', 'ic_check_tiny', 'check pequeno'),
    'sc03.sheet.book.chevron': ('ic', 'ic_chevron_right_fino', 'chevron para a direita (traço 2)'),
    'sc03.sheet.actions.primary.icon': ('ic', 'ic_plus_papel', '"+" papel do botão principal'),
    'sc03.sheet.actions.scanAgain.icon': ('ic', 'ic_refresh', 'escanear de novo (seta circular)'),
    'sc39.status.chip.badge.icon': ('ic', 'ic_scan_barcode_amarelo', 'escanear, amarelo, do chip de status'),
    'sc39.sheet.lead.art': ('il', 'il_livro_codigo_barras', 'livro lavanda com o código de barras (como mirar)'),
    'sc40.camera.label.barcode': ('graf', 'codigo_barras_camera_nao_encontrado', 'código sob a câmera (40)'),
    'sc40.sheet.chip.icon': ('ic', 'ic_alert_small', 'alerta (!) pequeno do chip'),
    'sc40.sheet.lead.art': ('il', 'il_livro_interrogacao', 'livro verde com "?" (não encontrado)'),
    'sc41.corners': ('il', 'mira_scanner_tracejada', 'cantos tracejados da mira (sem permissão)'),
    'sc41.sheet.art.image': ('il', 'il_camera_cadeado', 'câmera com cadeado (sem permissão)'),
    'sc41.sheet.path.icon': ('ic', 'ic_settings_small', 'engrenagem do caminho dos Ajustes'),
    'sc42.sheet.chip.icon': ('ic', 'ic_shelf', 'livros na estante'),
    'sc42.sheet.goal.ring': ('graf', 'anel_meta_livro', 'anel de progresso do livro na estante'),
    'sc69.controls.help.icon': ('ic', 'ic_help', 'ajuda (? no círculo)'),
    'sc69.sticker.card.kind.icon': ('ic', 'ic_book_simple', 'livro (tipo do adesivo)'),
    'sc69.sticker.card.barcode.bars': ('graf', 'codigo_barras_isbn_digitado', 'código de barras do ISBN digitado'),
    'sc69.toolbar.paste.icon': ('ic', 'ic_clipboard', 'colar (prancheta)'),
    'sc69.toolbar.hide.icon': ('ic', 'ic_keyboard_hide', 'esconder o teclado'),
    'sc69.keypad.delete.icon': ('ic', 'ic_backspace', 'apagar (teclado do sistema, R8)'),
    'sc69b.sticker.shakeLeft': ('il', 'tremor_esquerda', 'marcas de tremor à esquerda do adesivo'),
    'sc69b.sticker.shakeRight': ('il', 'tremor_direita', 'marcas de tremor à direita do adesivo'),
    'sc69b.sticker.card.alert.icon': ('ic', 'ic_alert', 'alerta (!) no círculo'),
    'sc69b.sticker.card.barcode.bars': ('graf', 'codigo_barras_isbn_nao_confere', 'o ISBN que não confere'),
    'sc69b.toolbar.clearAll.icon': ('ic', 'ic_eraser', 'borracha (apagar tudo)'),
    'bu28.searchBar.field.icon': ('ic', 'ic_search_cinza', 'lupa cinza'),
    'bu28.searchBar.scan.icon': ('ic', 'ic_scan_barcode_busca', 'escanear da barra de busca (traço 1,9)'),
    'bu28.recent.item1.icon': ('ic', 'ic_clock', 'relógio (buscas recentes)'),
    'bu28.trending.book1.clubs.icon': ('ic', 'ic_people', 'pessoas'),
    'bu28.trending.book2.cover.art': ('il', 'il_capa_iracema', 'capa Iracema (sol sobre as ondas)'),
    'bu28.trending.book3.cover.art': ('il', 'il_capa_policarpo_quaresma', 'capa Policarpo Quaresma (violão)'),
    'bu28.trending.book4.cover.art': ('il', 'il_capa_a_hora_da_estrela', 'capa A Hora da Estrela (brilhos)'),
    'bu28b.searchBar.field.clear.icon': ('ic', 'ic_close_small', 'limpar a busca (× de traço 2,8)'),
    'bu28b.books.result1.cover.art': ('il', 'il_capa_dom_casmurro_olho', 'capa Dom Casmurro do resultado (olho)'),
    'bu28b.books.result1.open.icon': ('ic', 'ic_arrow_next_papel', 'seta papel (abrir o livro)'),
    'bu28b.books.result2.cover.art': ('il', 'il_capa_capitu_memorias', 'capa Capitu: memórias póstumas (ondas)'),
    'bu28b.books.result2.add.icon': ('ic', 'ic_plus_add', '"+" de traço 2,6 (adicionar)'),
    'bu28b.clubs.club1.member.icon': ('ic', 'ic_check_bold_tinta', 'check de traço 3 em tinta'),
    'bu28b.clubs.club1.avatar.icon': ('ic', 'ic_people_avatar', 'pessoas no avatar do clube'),
    'bu28c.illustration': ('il', 'il_busca_nada_encontrado', 'livro com lupa e "?" (nada encontrado)'),
    'bu28d.header.close.icon': ('ic', 'ic_close_round', 'fechar'),
    'bu28d.cover.preview.book.art': ('il', 'il_capa_receitas_da_vo_cida', 'capa Receitas da vó Cida (tigela)'),
    'bu28d.cover.options.camera.icon': ('ic', 'ic_camera_capa', 'câmera (tirar foto da capa)'),
    'bu28d.cover.options.gallery.icon': ('ic', 'ic_image', 'imagem (escolher da galeria)'),
    # ── T16 · Entrada e onboarding (35, 07, 08, 09, 09b, 10, 11, 12, 13, 13b, 14, 15, 16, 36a) ────────────────────
    'e35.waves': ('il', 'ondas_abertura', 'ondas verticais da abertura'),
    'e35.stamp.rays': ('il', 'raios_selo_abertura', 'raios em volta do selo da abertura'),
    'e35.stamp.badge.art': ('il', 'selo_leia_grife_converse', 'selo "LEIA · GRIFE · CONVERSE" (abertura)'),
    'e07.waves': ('il', 'ondas_entrada', 'ondas do topo das telas de entrada'),
    'e07.badge': ('il', 'selo_leia_grife_converse_login', 'o mesmo selo, com a sombra a 3 (login)'),
    'e07.sparkleLarge': ('ic', 'ic_sparkle_outline', 'brilho com contorno'),
    'e07.sheet.buttons.email.icon': ('ic', 'ic_mail', 'envelope papel (e-mail)'),
    'e08.sheet.form.password.field.reveal.icon': ('ic', 'ic_eye', 'olho (mostrar a senha)'),
    'e08.sheet.form.rules.rule1.check.icon': ('ic', 'ic_check_mini', 'check mínimo das regras da senha'),
    'e08.sheet.form.submit.icon': ('ic', 'ic_arrow_forward', 'seta papel (continuar)'),
    'e09.badge': ('il', 'selo_de_volta_a_leitura', 'selo "DE VOLTA À LEITURA · BOOKNEST"'),
    'e10.envelope': ('il', 'envelope_codigo', 'envelope com o código'),
    'e10.sheet.resend.timer': ('graf', 'anel_reenviar_codigo', 'anel da contagem para reenviar o código'),
    'e10.sheet.help.spam.icon': ('ic', 'ic_alert_cinza', 'alerta (!) cinza (olhe o spam)'),
    'e11.padlock': ('il', 'cadeado_aberto', 'cadeado aberto (nova senha)'),
    'e11.sheet.notice.icon': ('ic', 'ic_shield', 'escudo cinza (aviso de segurança)'),
    'e12.waves': ('il', 'ondas_onboarding_meta', 'ondas do topo do onboarding (meta)'),
    'e12.daily.option1.art': ('il', 'despertador_5_min', 'despertador com 5 min'),
    'e12.daily.option2.art': ('il', 'despertador_15_min', 'despertador com 15 min'),
    'e12.daily.option3.art': ('il', 'despertador_30_min', 'despertador com 30 min (tocando)'),
    'e12.daily.option4.art': ('il', 'despertador_60_min', 'despertador com 60 min'),
    'e12.daily.option3.radio.icon': ('ic', 'ic_check_tiny_creme', 'check pequeno creme do rádio'),
    'e12.yearly.stepper.minus.icon': ('ic', 'ic_minus_bold', '"−" de traço 2,6 do contador'),
    'e12.yearly.stepper.plus.icon': ('ic', 'ic_plus_meta', '"+" amarelo do contador da meta'),
    'e13.waves': ('il', 'ondas_onboarding_generos', 'ondas do topo do onboarding (gêneros)'),
    'e13.top.back.icon': ('ic', 'ic_arrow_left_bold', 'voltar de traço 2,4'),
    'e13.genres.chip3.badge.icon': ('ic', 'ic_genero_fantasia', 'varinha (Fantasia)'),
    'e13.genres.chip4.badge.icon': ('ic', 'ic_genero_ficcao_cientifica', 'foguete (Ficção científica)'),
    'e13.genres.chip7.badge.icon': ('ic', 'ic_genero_terror', 'fantasma (Terror)'),
    'e13.genres.chip9.badge.icon': ('ic', 'ic_genero_poesia', 'pena (Poesia)'),
    'e13.genres.chip10.badge.icon': ('ic', 'ic_genero_biografias', 'pessoa (Biografias)'),
    'e13.genres.chip11.badge.icon': ('ic', 'ic_genero_historia', 'ampulheta (História)'),
    'e13.genres.chip12.badge.icon': ('ic', 'ic_genero_nao_ficcao', 'lâmpada (Não ficção)'),
    'e13.genres.chip13.badge.icon': ('ic', 'ic_genero_quadrinhos', 'balão de fala (Quadrinhos)'),
    'e13.genres.chip14.badge.icon': ('ic', 'ic_genero_jovem_adulto', 'raio (Jovem adulto)'),
    'e13.genres.chip15.badge.icon': ('ic', 'ic_genero_humor', 'carinha sorrindo (Humor)'),
    'e13.genres.more.icon': ('ic', 'ic_plus_generos', '"+" de traço 2,4 (mais gêneros)'),
    'e13b.waves': ('il', 'ondas_onboarding_dica', 'ondas do topo do onboarding (dica do scanner)'),
    'e13b.search.scan.icon': ('ic', 'ic_scan_barcode_grande', 'escanear (24, traço 2)'),
    'e13b.coach.arrow': ('il', 'seta_curva_dica', 'seta curva da dica'),
    'e13b.coach.card.art': ('il', 'il_livro_codigo_barras_dica', 'livro lavanda com o código (cartão da dica)'),
    'e13b.coach.card.actions.try.icon': ('ic', 'ic_scan_barcode_dica', 'escanear amarelo (traço 2,2) do "tentar"'),
    'e13b.suggestions.book4.cover.star': ('ic', 'ic_sparkle_solid_creme', 'brilho cheio creme'),
    'e13b.suggestions.book4.toggle.icon': ('ic', 'ic_plus', '"+"'),
    'e14.waves': ('il', 'ondas_onboarding_livros', 'ondas do topo do onboarding (primeiros livros)'),
    'e15.waves': ('il', 'ondas_onboarding_foto', 'ondas do topo do onboarding (foto)'),
    'e15.photo.add.icon': ('ic', 'ic_camera_creme', 'câmera creme (adicionar foto)'),
    'e15.photo.info.gallery.icon': ('ic', 'ic_image_small', 'imagem (17, galeria)'),
    'e15.username.field.valid.icon': ('ic', 'ic_check_valid', 'check do @ válido (traço 3,8)'),
    'e15.bio.field.icon': ('ic', 'ic_pencil_note', 'lápis sobre a linha (bio)'),
    'e15.continue.icon': ('ic', 'ic_sparkle_solid_amarelo', 'brilho cheio amarelo'),
    'e16.card.footer.code.bars': ('il', 'codigo_barras_carteirinha', 'código de barras da carteirinha'),
    'e16.stamp': ('il', 'carimbo_carteirinha', 'carimbo "LEITORA Nº … · BOOKNEST" da carteirinha'),
    'e16.sheet.share.icon': ('ic', 'ic_share_up', 'compartilhar (19, traço 2)'),
    'e36a.header.search.icon': ('ic', 'ic_search_home', 'lupa do cabeçalho'),
    'e36a.header.bell.icon': ('ic', 'ic_bell', 'sino'),
    'e36a.today.ring': ('graf', 'anel_hoje_primeiro_acesso', 'anel "hoje" do primeiro acesso'),
    'e36a.nav.home.icon': ('ic', 'ic_nav_home_active', 'aba Início ativa'),
    'e36a.nav.library.icon': ('ic', 'ic_nav_library', 'aba Estante'),
    'e08.card.stamp.icon': ('ic', 'ic_sparkle_solid_violeta', 'brilho cheio violeta'),
    # ── T17 · Perfil, ajustes, conta, privacidade e notificações (05, 64, 65, 06, 58, 59, 56, 30, 30b, 30c) ─────────
    'p05.top.settings.icon': ('ic', 'ic_settings', 'engrenagem (ajustes)'),
    'p05.hero.avatar.streak.icon': ('ic', 'ic_flame_filled', 'chama cheia amarela (sequência)'),
    'p05.card.code.bars': ('il', 'codigo_barras_carteirinha_perfil', 'código de barras da carteirinha do perfil'),
    'p05.card.stamp': ('il', 'carimbo_carteirinha_perfil', 'carimbo violeta com brilho da carteirinha'),
    'p05.actions.edit.icon': ('ic', 'ic_pencil_edit', 'lápis'),
    'p05.reading.grid.book1.cover.bookmark': ('il', 'fita_marcador_capa', 'fita coral na capa da grade (14×26)'),
    'p05.year.more.icon': ('ic', 'ic_arrow_forward_tinta', 'seta em tinta (mais do ano)'),
    'p05.year.goal.ahead.icon': ('ic', 'ic_arrow_up_right', 'seta para cima e à direita (à frente da meta)'),
    'p05.achievements.grid.badge1.medal.art': ('il', 'medalha_ondulada_amarela', 'medalha ondulada amarela'),
    'p05.achievements.grid.badge2.medal.art': ('il', 'medalha_hexagono_verde', 'medalha hexágono verde'),
    'p05.achievements.grid.badge2.medal.center.icon': ('ic', 'ic_book_open_medalha', 'livro aberto (26, medalha)'),
    'p05.achievements.grid.badge3.medal.art': ('il', 'medalha_circulo_rosa', 'medalha círculo rosa'),
    'p05.achievements.grid.badge3.medal.center.icon': ('ic', 'ic_chat_bubble', 'balão de conversa (medalha)'),
    'p05.achievements.grid.badge4.medal.art': ('il', 'medalha_losango_lavanda', 'medalha losango lavanda'),
    'p05.achievements.next.bar.fill.edge': ('graf', 'borda_onda_conquista', 'borda ondulada da barra da conquista'),
    'p05.activity.item3.icon.art': ('ic', 'ic_check', 'check'),
    'p05.activity.item3.rating.star1': ('ic', 'ic_star', 'estrela dourada da nota'),
    'p05.nav.profile.icon': ('ic', 'ic_nav_profile_active', 'aba Perfil ativa'),
    'p64.top.close.icon': ('ic', 'ic_close_bold', 'fechar'),
    'p64.preview.avatar.change.icon': ('ic', 'ic_camera_small', 'câmera (15, trocar o avatar)'),
    'p64.colors.custom.dot.icon': ('ic', 'ic_plus_mini', '"+" mínimo da cor personalizada'),
    'p64.favorites.grid.slot1.book.swap.icon': ('ic', 'ic_pencil_small', 'lápis (14, trocar o favorito)'),
    'p64.favorites.grid.slot1.handle.icon': ('ic', 'ic_drag_handle', 'alça de arrastar (6 pontos)'),
    'p64.bottom.save.icon': ('ic', 'ic_check_verde', 'check verde (salvar)'),
    'p65.sheet.search.icon': ('ic', 'ic_search_grafite', 'lupa grafite da folha'),
    'p65.sheet.options.option1.radio.icon': ('ic', 'ic_check_bold_creme', 'check de traço 3 creme do rádio'),
    'p65.sheet.options.option1.rating.star1': ('ic', 'ic_star_small', 'estrela dourada pequena (12)'),
    'p65.sheet.options.option4.rating.star5': ('ic', 'ic_star_half_small', 'meia estrela pequena'),
    'p65.sheet.confirm.icon': ('ic', 'ic_shuffle_amarelo', 'trocar (setas cruzadas, amarelo)'),
    'aj06.footer.version.icon': ('ic', 'ic_sparkle_solid_cinza', 'brilho cheio cinza (versão)'),
    'aj06.reading.theme.sepia.preview.check.icon': ('ic', 'ic_check_read', 'check'),
    'aj06.goals.streak.title.icon': ('ic', 'ic_flame_filled_coral', 'chama cheia coral'),
    'aj06.account.badge.icon': ('ic', 'ic_phone_small', 'celular (12, conta)'),
    'aj06.account.chevron': ('ic', 'ic_chevron_right_lista', 'chevron para a direita das listas (traço 2,2)'),
    'aj06.plan.icon.art': ('ic', 'ic_star_coral', 'estrela coral (plano)'),
    'aj06.goals.yearly.stepper.minus.icon': ('ic', 'ic_minus_stepper', '"−" do contador (16)'),
    'aj06.goals.yearly.stepper.plus.icon': ('ic', 'ic_plus_stepper_creme', '"+" creme do contador (16)'),
    'aj06.more.list.notifications.icon.art': ('ic', 'ic_bell_lista', 'sino das listas (traço 2)'),
    'aj06.more.list.privacy.icon.art': ('ic', 'ic_lock', 'cadeado'),
    'aj06.more.list.library.icon.art': ('ic', 'ic_folder_download', 'pasta com seta (biblioteca)'),
    'aj06.more.list.scanner.icon.art': ('ic', 'ic_scan_barcode_lista', 'escanear das listas (18)'),
    'aj06.more.list.appearance.icon.art': ('ic', 'ic_contrast', 'contraste (aparência)'),
    'aj06.more.list.language.icon.art': ('ic', 'ic_globe', 'globo (idioma)'),
    'aj06.help.list.center.icon': ('ic', 'ic_help_lista', 'ajuda (? no círculo, 20)'),
    'aj06.help.list.terms.icon': ('ic', 'ic_document', 'documento (termos)'),
    'aj06.footer.signOut.icon': ('ic', 'ic_sign_out', 'sair (traço 2,2)'),
    'aj58.top.back.icon': ('ic', 'ic_chevron_left', 'chevron para a esquerda (voltar)'),
    'aj58.signIn.list.password.icon.art': ('ic', 'ic_key', 'chave (senha)'),
    'aj58.signIn.list.connected.icon.art': ('ic', 'ic_people_lista', 'pessoas das listas (contas ligadas)'),
    'aj58.sync.list.devices.icon.art': ('ic', 'ic_phone', 'celular (aparelhos)'),
    'aj58.sync.list.offline.icon.art': ('ic', 'ic_download', 'baixar'),
    'aj58.data.list.import.icon.art': ('ic', 'ic_upload', 'enviar (importar)'),
    'aj58.signOut.icon': ('ic', 'ic_sign_out_fino', 'sair (traço 2)'),
    'aj58.delete.icon': ('ic', 'ic_trash_delete', 'lixeira vermelha (excluir a conta)'),
    'aj59.alternatives.pause.icon.art': ('ic', 'ic_pause_circle', 'pausa no círculo'),
    'aj56.profileType.open.icon.art': ('ic', 'ic_globe_perfil', 'globo (perfil aberto, 19)'),
    'aj56.profileType.closed.radio.icon': ('ic', 'ic_check_small_creme', 'check creme do rádio'),
    'aj56.visibility.list.shelf.icon.art': ('ic', 'ic_library_lista', 'estante das listas'),
    'aj56.visibility.list.shelf.audience.icon': ('ic', 'ic_people_small', 'pessoas (14, público)'),
    'aj56.visibility.list.shelf.audience.chevron': ('ic', 'ic_chevron_down_small', 'chevron para baixo (14)'),
    'aj56.visibility.list.reviews.icon.art': ('ic', 'ic_star_outline', 'estrela de contorno (resenhas)'),
    'aj56.visibility.list.highlights.audience.icon': ('ic', 'ic_lock_small', 'cadeado (14, só eu)'),
    'aj56.visibility.list.page.icon.art': ('ic', 'ic_document_page', 'página (o que estou lendo)'),
    'aj56.visibility.list.lists.icon.art': ('ic', 'ic_list', 'lista com marcadores'),
    'aj56.visibility.list.stats.icon.art': ('ic', 'ic_bar_chart', 'gráfico de barras (estatísticas)'),
    'aj56.people.list.blocked.icon.art': ('ic', 'ic_block', 'bloqueado (círculo cortado)'),
    'n30.top.markRead.icon': ('ic', 'ic_check_double', 'check duplo (marcar como lidas)'),
    'n30.sparkle': ('ic', 'ic_sparkle_notificacao', 'brilho rosa com contorno (notificações)'),
    'n30.today.list.item2.icon.art': ('ic', 'ic_stopwatch_fino', 'cronômetro (traço 1,9)'),
    'n30.today.list.item4.icon.art': ('ic', 'ic_heart', 'coração'),
    'n30.week.list.item1.icon.art': ('ic', 'ic_stats_bars', 'barras (resumo)'),
    'n30.week.list.item2.icon.art': ('ic', 'ic_person', 'pessoa'),
    'n30b.topics.streak.icon.art': ('ic', 'ic_flame_outline', 'chama de contorno (sequência)'),
    'n30b.quiet.head.icon.art': ('ic', 'ic_moon_creme', 'lua creme (não incomodar)'),
    'n30c.illustration': ('il', 'il_notificacoes_vazia', 'sino dormindo (zzz) sobre o livro'),
    # ── T18 · Cronômetro (18, 18b) ──────────────────────────────────────────────────────────────────────────────
    'cr18.top.minimize.icon': ('ic', 'ic_chevron_down_papel', 'chevron para baixo papel (minimizar)'),
    'cr18.top.sound.icon': ('ic', 'ic_rain_papel', 'nuvem com chuva (som ambiente)'),
    'cr18.timer.ring': ('graf', 'anel_cronometro', 'anel do cronômetro'),
    'cr18.chips.goal.icon': ('ic', 'ic_target', 'alvo (meta)'),
    'cr18.chips.streak.icon': ('ic', 'ic_flame_chip', 'chama de contorno (chip, traço 2)'),
    'cr18.controls.photo.icon': ('ic', 'ic_camera_papel', 'câmera papel'),
    'cr18.controls.pause.icon': ('ic', 'ic_pause_tinta', 'pausar'),
    'cr18.controls.end.icon': ('ic', 'ic_stop_papel', 'parar (quadrado papel)'),
    'cr18.lockHint.icon': ('ic', 'ic_lock_cinza', 'cadeado cinza (dica da tela bloqueada)'),
    'cr18.note.button.icon': ('ic', 'ic_pencil_note_papel', 'lápis sobre a linha, papel (nota)'),
    'cr18b.timer.ring': ('graf', 'anel_cronometro_fim', 'anel do cronômetro completo (fim da sessão)'),
    'cr18b.confetti.sparkle1': ('ic', 'ic_sparkle_previa', 'brilho amarelo'),
    'cr18b.sheet.stamp': ('il', 'carimbo_meta_batida', 'carimbo "META DO DIA · BATIDA"'),
    'cr18b.sheet.stats.session.icon.art': ('ic', 'ic_stopwatch_small', 'cronômetro (16)'),
    'cr18b.sheet.page.next.icon': ('ic', 'ic_plus_meta_creme', '"+" creme da página seguinte'),
}

VARIANTE = {'#1A1714': 'tinta', '#FFFAF1': 'creme', '#F7F0E3': 'papel', '#FED170': 'amarelo', '#B6ACE4': 'lavanda',
            '#FFC1C6': 'rosa', '#ABCF82': 'verde', '#552CB7': 'violeta', '#6F665B': 'cinza', '#5B544B': 'grafite',
            '#FF552E': 'coral', '#B83A1C': 'vermelho', '#2E5314': 'verde_escuro', '#8A8073': 'cinza_claro',
            '#F2A815': 'dourado'}

# props do componente com cor no SVG (conferido nos 41 templates: os atributos com {{prop}} dentro de <svg>)
DINAMICAS = {
    'sc03.corners': {'#FED170': 'reticle'}, 'sc40.corners': {'#FED170': 'reticle'},
    'sc42.corners': {'#FED170': 'reticle'},
    'e09.badge': {'#FED170': 'badge'}, 'e09b.badge': {'#FED170': 'badge'},
    'e10.envelope': {'#B6ACE4': 'env'}, 'e10.sheet.resend.timer': {'#B6ACE4': 'brand'},
    'e11.padlock': {'#FED170': 'lock'},
    'e12.top.progress.fill.edge': {'#FF552E': 'progress'}, 'e13.top.progress.fill.edge': {'#FF552E': 'progress'},
    'e13b.top.progress.fill.edge': {'#FF552E': 'progress'}, 'e14.top.progress.fill.edge': {'#FF552E': 'progress'},
    'cr18.timer.ring': {'#FED170': 'arc'}, 'cr18b.timer.ring': {'#FED170': 'arc'},
    'cr18b.sheet.stamp': {'#ABCF82': 'goal'},
}

_TEXTO = ('tem <text> ({det}): o flutter_svg desenharia o texto com a fonte do sistema → no app o AppSvg lê o desenho '
          'sem os textos e eles voltam em AppText nas mesmas posições (como as capas da Início, T03.7){extra}.')
_CAPA = ('capa da Início com <text> ({det}) e preserveAspectRatio="xMidYMid slice", width/height 100% da caixa '
         '{caixa} (escala {escala}): AppSvg sem os textos em BoxFit.cover e os textos em AppText por cima, nas posições '
         '× escala (como o herói da Início).')
_ARCO = ('o texto "{texto}" ({fonte}) corre num <textPath> em volta do círculo (textLength {tl}, lengthAdjust spacing): '
         'o flutter_svg não faz textPath → no app, o desenho sem o texto e as letras distribuídas no arco por um pintor '
         'com o AppFonts{extra}.')
_ANEL = ('stroke-dasharray = progresso ({det}): anel desenhado por CustomPainter com o valor real; o SVG é a '
         'referência do estado da prancha.')
_BORDA = ('preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): a '
          'borda ondulada da ponta da barra preenchida, esticada na altura da barra com traço fixo de 1,5 — '
          'CustomPainter, como a onda da barra do leitor.')
_CAMERA = ('é a cena do protótipo sob a câmera (o código de barras do livro, com os dígitos em <text> Figtree 600 11): '
           'no app é a imagem da câmera ao vivo — fica só como referência (como a tinta da fixture, D-34).')
_ISBN = ('o código de barras do ISBN digitado ({det}): no app, desenhado a partir dos dígitos que a pessoa digita '
         '(barras EAN-13 por CustomPainter, dígitos em AppText); o SVG é a referência do estado da prancha.')
_LARGURA = ('width="100%" (a largura da caixa da capa){par}: o arquivo sai com a largura medida; no app, a ilustração '
            'ocupa a caixa da capa ({fit}).')
_FORA = ('desenha fora da própria caixa ({det}; o <svg> tem overflow: visible): no app, sem recorte (o SvgPicture '
         'com clipBehavior: Clip.none, ou o pintor sem clip) — com o recorte padrão, o que passa some.')
_ENCOLHIDO = ('o <svg> de {attr} (atributos) não tem flex-shrink: 0 e encolhe na linha que não cabe{motivo}: fica {lay} no '
              'layout, e o desenho (viewBox 24×24, preserveAspectRatio meet) sai {des}, centrado na altura. A prancha mostra '
              'o ícone menor — decidir na {etapa} se o app repete o encolhimento (o tamanho do catálogo) ou usa o dos '
              'atributos.')
_TRACEJADO = ('tem stroke-dasharray ({det}): o flutter_svg traceja com outra fase → no app, o registro de tracejados '
              '(svgDashes, T01 e D-285) lê o arquivo sem esse traço{id} e o pinta por cima como o Chromium: o padrão '
              'começa {inicio}, e o comprimento das curvas é medido na escala da pintura (D-286).')
_ONDAS = ('faixa de ondas de largura fixa (390){mask}: a 360 sai 30 px do quadro e é cortada na borda (fluidez, T13.9) '
          '— decidir na T16 se acompanha a largura da tela.')
ARMADILHAS = {
    'd17.cover.book.art': _CAPA.format(det='"MEMÓRIAS PÓSTUMAS DE" Figtree 800 4,6 ls 0,8; "Brás Cubas" Instrument '
                                           'Serif 17,5; "MACHADO DE ASSIS" Figtree 700 5,2 ls 0,9',
                                       caixa='173×261', escala='max(173/96, 261/144) = 1,8125'),
    'd17b.cover.book.art': _CAPA.format(det='"Dom" e "Casmurro" Instrument Serif 19; "MACHADO DE ASSIS" Figtree 700 '
                                            '5,2 ls 0,9; e uma máscara', caixa='173×261',
                                        escala='max(173/96, 261/144) = 1,8125'),
    # a mesma capa noutra caixa (o arquivo é o da Início, reusado pelo desenho): a escala é a de cada uso
    'e07.cover.art': _CAPA.format(det='"Dom" e "Casmurro" Instrument Serif 19; "MACHADO DE ASSIS" Figtree 700 5,2 ls 0,9; '
                                      'e uma máscara', caixa='101×153', escala='max(101/96, 153/144) = 1,0625'),
    'cr18.book.cover.art': _CAPA.format(det='"MEMÓRIAS PÓSTUMAS DE" Figtree 800 4,6 ls 0,8; "Brás Cubas" Instrument '
                                            'Serif 17,5; "MACHADO DE ASSIS" Figtree 700 5,2 ls 0,9',
                                        caixa='43×66', escala='max(43/96, 66/144) = 0,4583'),
    'cr18b.book.cover.art': _CAPA.format(det='"MEMÓRIAS PÓSTUMAS DE" Figtree 800 4,6 ls 0,8; "Brás Cubas" Instrument '
                                             'Serif 17,5; "MACHADO DE ASSIS" Figtree 700 5,2 ls 0,9',
                                         caixa='43×66', escala='max(43/96, 66/144) = 0,4583'),
    'd17.session.ring': _ANEL.format(det='dasharray 49 de 81,7 = 2π·13 → 60 %, rotate(-90)'),
    'sc42.sheet.goal.ring': _ANEL.format(det='dasharray 45,2 de 75,4 = 2π·12 → 60 %, rotate(-90)'),
    'e10.sheet.resend.timer': _ANEL.format(det='dasharray 53,4 com dashoffset 16 → 70 % restante da contagem'),
    'e36a.today.ring': _ANEL.format(det='as marcas, dasharray 1,5 5') + ' O "0" (minutos de hoje) é <text> '
                                                                        'Bricolage 800 15: AppText.',
    'cr18.timer.ring': _ANEL.format(det='dasharray 626,3 de 703,7 = 2π·112 → 89 %, rotate(-90)') + ' A cor do arco é a '
                                                                                                  'prop "arc".',
    'cr18b.timer.ring': _ANEL.format(det='dasharray 703,6 de 703,7: o arco completo (meta batida)') + ' A cor do arco é '
                                                                                                       'a prop "arc".',
    'd17.mood.split.fill.edge': _BORDA,
    'p05.achievements.next.bar.fill.edge': _BORDA,
    'sc03.camera.label.barcode': _CAMERA,
    'sc40.camera.label.barcode': _CAMERA,
    'sc69.sticker.card.barcode.bars': _ISBN.format(det='os 13 dígitos em <text> Figtree 700 12, o "?" dos que faltam '
                                                       'e as barras tracejadas da parte por digitar')
    + ' ' + _FORA.format(det='0,55 px acima da caixa'),
    'sc69b.sticker.card.barcode.bars': _ISBN.format(det='o mesmo adesivo em rosa, com o dígito que não confere')
    + ' ' + _FORA.format(det='0,6 px acima da caixa'),
    'sc39.sheet.lead.art': _TRACEJADO.format(det='o <rect> de cantos 6, 5/4, 2,4, coral', inicio='em (x + rx, y), no '
                                             'sentido horário', id=' (só o do id="tracejado": os outros <rect> têm traço)'),
    'sc40.sheet.lead.art': _TEXTO.format(det='o "?" em Instrument Serif 26', extra='')
    + ' ' + _TRACEJADO.format(det='o <rect> de cantos 4, 4/3, 1,3, tinta, sobre o fundo creme dele',
                              inicio='em (x + rx, y), no sentido horário',
                              id=' (só o do id="tracejado": os outros <rect> têm traço)'),
    'sc41.corners': _TRACEJADO.format(det='os 4 cantos da mira num <path>, 2/9, 5,5, creme, pontas redondas', id='',
                                      inicio='de novo em cada subcaminho (cada M)'),
    'bu28c.illustration': _TEXTO.format(det='o "?" em Instrument Serif 44', extra=''),
    'n30c.illustration': _TEXTO.format(det='os três "z" em Bricolage 800 22, 16 e 12', extra=''),
    'e10.envelope': _TEXTO.format(det='"SEU CÓDIGO" Figtree 800 9 ls 1,2 e "482 7••" Bricolage 800 27 ls 2',
                                  extra=' — o código é o enviado de verdade, com os dígitos que faltam em •')
    + ' ' + _FORA.format(det='o papel em y −12 do viewBox 190×160: sai 16 px acima da caixa 238×200'),
    'e12.daily.option3.art': _FORA.format(det='os risquinhos de toque em x −1,5 e 57,5 do viewBox 56: saem 2,3 px de '
                                              'cada lado da caixa 54, que ainda gira −5°'),
    'e35.stamp.badge.art': _ARCO.format(texto='LEIA · GRIFE · CONVERSE ·', fonte='Figtree 800 11,5', tl=252, extra=''),
    'e07.badge': _ARCO.format(texto='LEIA · GRIFE · CONVERSE ·', fonte='Figtree 800 11,5', tl=252, extra=''),
    'e09.badge': _ARCO.format(texto='DE VOLTA À LEITURA · BOOKNEST ·', fonte='Figtree 800 11,5', tl=252,
                              extra='; a cor do selo é a prop "badge"'),
    'e16.stamp': _ARCO.format(texto='LEITORA Nº 0052 · BOOKNEST ·', fonte='Figtree 900 10,5 ls 1, violeta', tl=226,
                              extra='; o número é o da leitora e o "2026" (Bricolage 800 11, no centro) é o ano: '
                                    'AppText')
    + ' ' + _FORA.format(det='as três linhas de movimento em x −20 do viewBox 112: saem 18,5 px à esquerda da caixa 98'),
    'cr18b.sheet.stamp': _ARCO.format(texto='META DO DIA · BATIDA · META DO DIA ·', fonte='Figtree 900 10,5 ls 1',
                                      tl=232, extra='; a cor do selo é a prop "goal"'),
    'bu28.trending.book2.cover.art': _LARGURA.format(par=' e preserveAspectRatio="none"', fit='BoxFit.fill: esticada'),
    'bu28.trending.book3.cover.art': _LARGURA.format(par='', fit='BoxFit.contain, centrada'),
    'bu28.trending.book4.cover.art': _LARGURA.format(par='', fit='BoxFit.contain, centrada'),
    'bu28b.books.result1.cover.art': _LARGURA.format(par='', fit='BoxFit.contain, centrada'),
    'bu28b.books.result2.cover.art': _LARGURA.format(par='', fit='BoxFit.contain, centrada'),
    'e35.waves': ('as ondas verticais da abertura: viewBox 390×640 esticado em 390×844 (preserveAspectRatio="none") — '
                  'no app, BoxFit.fill na altura da tela.'),
    'e07.waves': _ONDAS.format(mask=''),
    'e12.waves': _ONDAS.format(mask=', com <mask>'),
    'e13.waves': _ONDAS.format(mask=', com <mask>'),
    'e13b.waves': _ONDAS.format(mask=', com <mask>'),
    'e14.waves': _ONDAS.format(mask=', com <mask>'),
    'e15.waves': _ONDAS.format(mask=', com <mask>'),
    'p65.sheet.options.option4.rating.star5': ('a meia estrela é uma estrela com <mask> (metade dourada): conferir no '
                                               'app que o flutter_svg recorta igual (a prova é no Chromium).'),
    'sc69.keypad.delete.icon': ('a tecla de apagar do teclado do sistema (R8, informativo): o app não desenha o '
                                'teclado; fica como referência.'),
}

# notas de um uso só (a armadilha do desenho vale para todos os usos; estas, só para o uso indicado)
NOTAS_USO = {
    'd17.highlights.club.chevron': _ENCOLHIDO.format(attr='20×20', motivo='', lay='16,43×20', des='16,43×16,43',
                                                     etapa='T14'),
    'bu28b.searchBar.field.icon': _ENCOLHIDO.format(attr='20×20', motivo=' (o campo tem a busca digitada por inteiro)',
                                                    lay='16,78×20', des='16,78×16,78', etapa='T15'),
    'bu28c.searchBar.field.icon': _ENCOLHIDO.format(attr='20×20', motivo=' (o campo tem a busca digitada por inteiro)',
                                                    lay='16,78×20', des='16,78×16,78', etapa='T15'),
    'e08.card.header.icon': _ENCOLHIDO.format(attr='12×12', motivo=': fica com o que sobra do cabeçalho depois do rótulo '
                                                                   '"CARTEIRINHA DE LEITORA" (sem quebra), 149 − 139,03',
                                              lay='9,97×12', des='9,97×9,97', etapa='T16'),
}

OPCOES = {
    'reusar': True,             # desenho igual a um asset existente → o catálogo aponta para ele, sem cópia
    'desenho': True,            # D-283: a comparação e os grupos pelo desenho (sem o tamanho, ids, linejoin sem junta)
    'normalizarIds': True,      # ids internos do arquivo → d1, d2… (o mesmo desenho com outro nome de id)
    'alturaPercentual': True,   # height="100%" → altura do layout (o flutter_svg não resolve porcentagem)
    'tamanhoLayout': True,      # tamanho = o do layout (sem os giros), não o retângulo visível do svgs.js
    'nomesUnicos': True,        # nenhum arquivo novo com o nome de um arquivo existente noutra pasta
    'limparAntigos': True,      # apaga o que a rodada anterior gravou e esta não grava mais
    'armadilhaPorUso': True,    # um uso com entrada própria em ARMADILHAS usa a dele (a capa reusada noutra caixa)
    'atributos': True,          # o uso guarda o width/height do <svg> quando o layout é outro (o flex encolheu, esticou)
    'idTracejado': True,        # D-285: o elemento tracejado do arquivo novo com id="tracejado" (o registro do app)
}
