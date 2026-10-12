#!/usr/bin/env python3
"""G01.8 — recortes @3x (do supersample 10×) dos elementos desenhados por CSS que viram CustomPainter no app
(gradientes cônicos/radiais, hachuras) → handoff_v2/referencia/png/elementos/<nome>@3x.png, para o teste visual
de cada pintor na G11. Recorte = caixa visual do elemento + 2 px.
Uso: [CONJUNTO=inicio2] python3 tools/medicao/recortes_elementos.py
T02: pastas e lista de elementos pelo conjunto (ITENS_INICIO2; nos outros, ITENS_LEITOR, a lista da G01).
T13.11 (R7): ITENS_PROJETO, as 41 telas das etapas 7–11 (capas e cartões em CSS, avatares, selos e medalhas, as cenas
da câmera, degradês, hachuras, pautas, máscaras e as ilustrações de div com <svg> dentro). O id pode ser uma tupla
(recorte da união das caixas: o adesivo do ISBN com as fitas que passam dele) e o item pode trazer a região (x, y,
largura, altura) em CSS px no lugar da caixa (os fundos de tela inteira, recortados onde não há nada por cima).
Elemento fora do quadro (carrossel) não entra; caixa vazia é erro.
"""
import json
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import NOME, caminho, indice  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
S = 3
ITENS_LEITOR = [  # (prancha, id, nome)
    ('23_ajustes_caneta', 'pen.penPanel.picker.wheel', 'roda_de_cores'),
    ('23_ajustes_caneta', 'pen.penPanel.picker.brightness', 'brilho_degrade'),
    ('22_modo_anotacao', 'ann.island.colorWell', 'poco_de_cor_anel'),
    ('21_selecao_texto', 'r21.toolbar.colors.other', 'outra_cor_anel'),
    ('20_leitor_controles', 'r20.bottomIsland.scrubber', 'barra_posicao_hachura'),
    ('23_ajustes_caneta', 'pen.penPanel.size', 'espessura_hachura'),
    ('24_abrindo_espaco', 'sp.page.spaceOpener', 'espaco_hachura_roxa'),
    ('23_ajustes_caneta', 'pen.penPanel.preview', 'faixa_pautada_previa'),
    ('22_modo_anotacao', 'ann.deskEdge', 'borda_de_mesa_degrade'),
    ('20_leitor_controles', 'r20.fade', 'veu_pagina_esmaecida'),
    ('26b_tema_noite', 'r20.fade', 'veu_pagina_esmaecida_noite'),
]
# T02 — Início e revisão: hachuras e degradês do CSS, e os dois gráficos em SVG que viram CustomPainter (svg_graficos)
ITENS_INICIO2 = [
    ('001_inicio', 'i01.today.week.bar0', 'barra_semana_hachura'),
    ('001_inicio', 'i01.today.week.bar6', 'barra_semana_hoje_hachura'),
    ('001_inicio', 'i01.club.progressBar', 'barra_clube_hachura'),
    ('001_inicio', 'i01.today.dial', 'mostrador_meta_diaria'),
    ('001_inicio', 'i01.alsoReading.card2.ring', 'anel_progresso_livro'),
    ('001_inicio', 'i01.bottomFade', 'degrade_inferior'),
    ('001b_inicio_lendo_agora', 'i01b.bottomFade', 'degrade_inferior_lendo_agora'),
    ('061_revisao_grifo_2_de_5', 'rv61.header.progress.step1', 'progresso_revisao_metade'),
    ('061_revisao_grifo_2_de_5', 'rv61.header.progress.step2', 'progresso_revisao_hachura'),
    ('061_revisao_grifo_2_de_5', 'rv61.deck.card.quote.mark', 'grifo_rosa_cartao'),
    ('062_revisao_fim', 'rv62.footer', 'degrade_rodape_revisao'),
    ('063_revisao_imagem_compartilhar', 'rv63.sheet.preview.quote.highlight', 'grifo_creme_previa'),
    # capas e cartões desenhados em CSS (div, borda, raio, círculo — não são <svg>): viram widgets compostos;
    # as do herói (Dom Casmurro) e da mini-barra (Brás Cubas com asas) são SVG (assets/illustrations/inicio2)
    ('001_inicio', 'i01.alsoReading.card1.cover', 'capa_bras_cubas_cartola'),
    ('001_inicio', 'i01.alsoReading.card2.cover', 'capa_orgulho_e_preconceito'),
    ('001_inicio', 'i01.forYou.item1.cover', 'capa_esau_e_jaco'),
    ('001_inicio', 'i01.forYou.item2.cover', 'capa_memorial_de_aires'),
    ('001_inicio', 'i01.forYou.item3.cover', 'capa_casa_de_pensao'),   # passa da borda (carrossel): recorte até x 390
    # (Quincas Borba e O Cortiço, do "Para você" da 01b, estão no DOM abaixo dos 844 px da prancha: sem imagem)
    ('001_inicio', 'i01.recent.row0.cover', 'capa_frankenstein'),
    ('001_inicio', 'i01.recent.row1.cover', 'capa_o_alienista'),
    ('001_inicio', 'i01.recent.row2.cover', 'capa_senhora'),
    ('001_inicio', 'i01.review.art', 'cartoes_revisao_inicio'),
    ('062_revisao_fim', 'rv62.summary.art', 'cartoes_revisao_fim'),
]
# T13.11 — as 41 telas das etapas 7–11, por etapa. Quase nada se repete entre telas (a 14 tem as capas escolhidas, a
# 18b o confete sobre a capa, os grifos e as fitas mudam de tamanho): cada tela tem os seus recortes.
ITENS_PROJETO = [
    # T14 · Biblioteca
    ('002_biblioteca', 'b02.collections.card1.pile', 'pilha_colecao_classicos_brasileiros'),
    ('002_biblioteca', 'b02.collections.card2.pile', 'pilha_colecao_clube_capitu'),
    # (a pilha da Faculdade, card3, está fora do quadro — carrossel, x 457: sem imagem)
    ('002_biblioteca', 'b02.shelf.book1.cover', 'capa_estante_dom_casmurro'),
    ('002_biblioteca', 'b02.shelf.book2.cover', 'capa_estante_mrs_dalloway'),
    ('002_biblioteca', 'b02.shelf.book3.cover', 'capa_estante_orgulho_e_preconceito'),
    ('002_biblioteca', 'b02.shelf.book4.cover', 'capa_estante_senhora'),
    ('002_biblioteca', 'b02.shelf.book5.cover', 'capa_estante_o_alienista_pdf'),
    ('002_biblioteca', 'b02.shelf.book6.cover', 'capa_estante_frankenstein'),
    ('002_biblioteca', 'b02.shelf.book7.cover', 'capa_estante_teoria_literaria_pdf'),
    ('002_biblioteca', 'b02.shelf.book8.cover', 'capa_estante_quincas_borba'),
    ('002_biblioteca', 'b02.shelf.book9.cover', 'capa_estante_o_cortico'),
    ('002_biblioteca', 'b02.shelf.book10.cover', 'capa_estante_iracema'),
    ('002_biblioteca', 'b02.shelf.book11.cover', 'capa_estante_crime_e_castigo'),
    ('002_biblioteca', 'b02.shelf.book12.cover', 'capa_estante_a_metamorfose'),
    ('002_biblioteca', 'b02.shelf.book1.info.progress.bar', 'barra_progresso_estante_1_hachura'),
    ('002_biblioteca', 'b02.shelf.book2.info.progress.bar', 'barra_progresso_estante_2_hachura'),
    ('002_biblioteca', 'b02.shelf.book3.info.progress.bar', 'barra_progresso_estante_3_hachura'),
    ('002_biblioteca', 'b02.bottomFade', 'degrade_inferior_biblioteca'),
    ('017_detalhes_fisico', 'd17.cover', 'capa_detalhes_fisico'),
    ('017_detalhes_fisico', 'd17.halo', 'halo_raios_verde'),
    ('017_detalhes_fisico', 'd17.mood.split.track', 'trilho_humor_hachura'),
    ('017_detalhes_fisico', 'd17.highlights.quote.text.mark', 'grifo_trecho_detalhes'),
    ('017b_detalhes_ebook', 'd17b.cover', 'capa_detalhes_ebook'),
    ('017b_detalhes_ebook', 'd17b.halo', 'halo_raios_lavanda'),
    ('017b_detalhes_ebook', 'd17b.progress.bar.track', 'trilho_progresso_ebook_hachura_lavanda'),
    ('017b_detalhes_ebook', 'd17b.mood.split.track', 'trilho_humor_ebook_hachura'),
    ('017b_detalhes_ebook', 'd17b.highlights.quote.text.mark', 'grifo_trecho_detalhes_ebook'),
    ('036_biblioteca_vazia', 'b36.illustration', 'ilustracao_biblioteca_vazia'),
    ('036_biblioteca_vazia', 'b36.bottomFade', 'degrade_inferior_biblioteca_vazia'),
    # T15 · Scanner e busca (as cenas da câmera são do protótipo: no app é a câmera ao vivo — referência só)
    ('003_scanner_encontrado', 'sc03.camera.book', 'cena_camera_encontrado'),
    ('039_scanner_mirando', 'sc39.camera.book', 'cena_camera_mirando'),
    ('040_scanner_nao_encontrado', 'sc40.camera.book', 'cena_camera_nao_encontrado'),
    ('042_scanner_na_estante', 'sc42.camera.book', 'cena_camera_na_estante'),
    ('003_scanner_encontrado', 'sc03.sheet.book.cover', 'capa_scanner_bras_cubas'),
    ('003_scanner_encontrado', 'sc03.sheet.book.collection.pile', 'pilha_colecao_mini'),
    ('041_scanner_sem_permissao', 'sc41.backdrop', 'fundo_listrado_sem_permissao', (0, 110, 390, 64)),
    ('041_scanner_sem_permissao', 'sc41.sheet.art', 'ilustracao_camera_sem_permissao'),
    ('042_scanner_na_estante', 'sc42.sheet.book.cover', 'capa_scanner_bras_cubas_na_estante'),
    ('042_scanner_na_estante', 'sc42.sheet.book.progress.bar', 'barra_progresso_scanner_hachura'),
    ('069_scanner_digitar_isbn', 'sc69.backdrop', 'fundo_pontilhado_isbn', (0, 0, 390, 56)),
    ('069_scanner_digitar_isbn', ('sc69.sticker', 'sc69.sticker.tapeLeft', 'sc69.sticker.tapeRight'),
     'adesivo_isbn_digitado'),
    ('069_scanner_digitar_isbn', 'sc69.sticker.tapeLeft', 'fita_adesiva_amarela'),
    ('069_scanner_digitar_isbn', 'sc69.sticker.tapeRight', 'fita_adesiva_rosa'),
    ('069b_scanner_isbn_nao_confere', ('sc69b.sticker', 'sc69b.sticker.tapeLeft', 'sc69b.sticker.tapeRight'),
     'adesivo_isbn_nao_confere'),
    ('069b_scanner_isbn_nao_confere', 'sc69b.sticker.tapeLeft', 'fita_adesiva_amarela_nao_confere'),
    ('069b_scanner_isbn_nao_confere', 'sc69b.sticker.tapeRight', 'fita_adesiva_rosa_nao_confere'),
    ('028_busca_explorar', 'bu28.trending.book1.cover', 'capa_em_alta_o_cortico'),
    ('028_busca_explorar', 'bu28.trending.book2.cover', 'capa_em_alta_iracema'),
    ('028_busca_explorar', 'bu28.trending.book3.cover', 'capa_em_alta_policarpo_quaresma'),  # passa da borda: até x 390
    # (A Hora da Estrela, book4, está fora do quadro — carrossel, x 442: sem imagem)
    ('028b_busca_resultados', 'bu28b.tabs', 'abas_busca_esmaecidas'),
    ('028b_busca_resultados', 'bu28b.books.result1.cover', 'capa_resultado_dom_casmurro'),
    ('028b_busca_resultados', 'bu28b.books.result2.cover', 'capa_resultado_capitu'),
    ('028b_busca_resultados', 'bu28b.books.result1.match.mark', 'grifo_busca_trecho_do_livro'),
    ('028b_busca_resultados', 'bu28b.books.result2.title.mark', 'grifo_busca_titulo'),
    ('028b_busca_resultados', 'bu28b.clubs.club1.avatar', 'avatar_clube_leitoras_de_capitu'),
    ('028b_busca_resultados', 'bu28b.clubs.club2.avatar', 'avatar_clube_capitu_sem_spoiler'),
    ('028b_busca_resultados', 'bu28b.clubs.club1.name.mark', 'grifo_busca_clube_1'),
    ('028b_busca_resultados', 'bu28b.clubs.club2.name.mark', 'grifo_busca_clube_2'),
    ('028b_busca_resultados', 'bu28b.highlights.quote1.text.mark1', 'grifo_busca_destaque_1a'),
    ('028b_busca_resultados', 'bu28b.highlights.quote1.text.mark2', 'grifo_busca_destaque_1b'),
    ('028b_busca_resultados', 'bu28b.highlights.quote2.text.mark', 'grifo_busca_destaque_2'),
    ('028d_adicionar_a_mao', 'bu28d.cover', 'capa_automatica_adicionar'),
    # T16 · Entrada e onboarding
    ('007_login', 'e07.cover', 'capa_login_dom_casmurro'),
    ('008_cadastro', 'e08.card', 'carteirinha_cadastro'),
    ('008_cadastro', 'e08.card.stamp', 'selo_carteirinha_cadastro'),
    ('008_cadastro', 'e08.sheet.form.strength.bar', 'barra_forca_senha_cadastro_hachura'),
    ('011_nova_senha', 'e11.sheet.form.strength.bar', 'barra_forca_senha_nova_hachura'),
    ('012_onboarding_meta', 'e12.top.progress', 'progresso_onboarding_meta_hachura'),
    ('013_onboarding_generos', 'e13.top.progress', 'progresso_onboarding_generos_hachura'),
    ('013_onboarding_generos', 'e13.genres', 'generos_esmaecidos'),
    # (a 13b é a 14 sob o véu da dica do scanner: a barra, a grade e as capas são as da 14, logo abaixo)
    ('014_onboarding_primeiros_livros', 'e14.top.progress', 'progresso_onboarding_primeiros_livros_hachura'),
    ('014_onboarding_primeiros_livros', 'e14.suggestions.grid', 'grade_sugestoes_primeiros_livros_esmaecida'),
    ('014_onboarding_primeiros_livros', 'e14.suggestions.book1.cover', 'capa_sugestao_dom_casmurro'),
    ('014_onboarding_primeiros_livros', 'e14.suggestions.book2.cover', 'capa_sugestao_orgulho_e_preconceito'),
    ('014_onboarding_primeiros_livros', 'e14.suggestions.book3.cover', 'capa_sugestao_bras_cubas'),
    ('014_onboarding_primeiros_livros', 'e14.suggestions.book4.cover', 'capa_sugestao_a_hora_da_estrela'),
    ('014_onboarding_primeiros_livros', 'e14.suggestions.book5.cover', 'capa_sugestao_expresso_do_oriente'),
    ('014_onboarding_primeiros_livros', 'e14.suggestions.book6.cover', 'capa_sugestao_o_cortico'),
    ('015_onboarding_foto', 'e15.photo', 'cartao_foto_perfil'),
    ('016_onboarding_carteirinha', 'e16.card', 'carteirinha_onboarding'),
    ('035_abertura', 'e35.stamp', 'selo_abertura'),
    ('035_abertura', 'e35.loading', 'carregando_abertura_hachura'),
    ('036a_inicio_primeiro_acesso', 'e36a.header.avatar', 'avatar_cabecalho_primeiro_acesso'),
    ('036a_inicio_primeiro_acesso', 'e36a.firstBook.illustration', 'ilustracao_primeiro_livro'),
    ('036a_inicio_primeiro_acesso', 'e36a.bottomFade', 'degrade_inferior_primeiro_acesso'),
    # T17 · Perfil, ajustes, conta, privacidade e notificações
    ('005_perfil', 'p05.hero.avatar', 'avatar_perfil'),
    ('005_perfil', 'p05.card', 'carteirinha_perfil'),
    ('005_perfil', 'p05.card.stamp', 'selo_carteirinha_perfil'),
    ('005_perfil', 'p05.reading.grid.book1.cover', 'capa_lendo_dom_casmurro'),
    ('005_perfil', 'p05.reading.grid.book2.cover', 'capa_lendo_mrs_dalloway'),
    ('005_perfil', 'p05.reading.grid.book3.cover', 'capa_lendo_orgulho_e_preconceito'),
    ('005_perfil', 'p05.achievements.grid.badge1.medal', 'medalha_sequencia_12_dias'),
    ('005_perfil', 'p05.achievements.grid.badge2.medal', 'medalha_10_classicos_brasileiros'),
    ('005_perfil', 'p05.achievements.grid.badge3.medal', 'medalha_voz_do_clube'),
    ('005_perfil', 'p05.achievements.grid.badge4.medal', 'medalha_mao_de_lapis'),
    ('005_perfil', 'p05.achievements.next.bar', 'barra_proxima_conquista_hachura'),
    ('005_perfil', 'p05.activity.item2.quote.highlight', 'grifo_atividade'),
    ('005_perfil', 'p05.bottomFade', 'degrade_inferior_perfil'),
    ('006_ajustes', 'aj06.account.avatar', 'avatar_conta_ajustes'),
    ('006_ajustes', 'aj06.reading.size.slider.track', 'trilho_tamanho_letra_hachura'),
    ('006_ajustes', 'aj06.bottomFade', 'degrade_inferior_ajustes'),
    ('058_conta', 'aj58.account.avatar', 'avatar_conta'),
    ('059_excluir_conta', 'aj59.bottom', 'degrade_inferior_excluir_conta'),
    ('064_editar_perfil', 'p64.preview.avatar', 'avatar_previa_editar_perfil'),
    ('064_editar_perfil', 'p64.colors', 'cores_esmaecidas'),
    ('064_editar_perfil', 'p64.colors.custom', 'cor_personalizada_conica'),
    ('064_editar_perfil', 'p64.favorites.grid.slot1.book.cover', 'capa_favorito_quincas_borba'),
    ('064_editar_perfil', 'p64.favorites.grid.slot2.book.cover', 'capa_favorito_o_cortico'),
    ('064_editar_perfil', 'p64.favorites.grid.slot3.book.cover', 'capa_favorito_iracema'),
    ('064_editar_perfil', 'p64.favorites.grid.slot4.book.cover', 'capa_favorito_a_metamorfose'),
    ('064_editar_perfil', 'p64.bottom', 'degrade_inferior_editar_perfil'),
    # (a prévia do avatar da 65 fica sob o véu da folha: a de referência é a da 64)
    ('065_editar_perfil_trocar', 'p65.sheet.head.current.cover', 'capa_favorito_atual_iracema'),
    ('065_editar_perfil_trocar', 'p65.sheet.options.option1.thumb.cover', 'capa_opcao_vidas_secas'),
    ('065_editar_perfil_trocar', 'p65.sheet.options.option2.thumb.cover', 'capa_opcao_a_hora_da_estrela'),
    ('065_editar_perfil_trocar', 'p65.sheet.options.option3.thumb.cover', 'capa_opcao_a_metamorfose'),
    ('065_editar_perfil_trocar', 'p65.sheet.options.option4.thumb.cover', 'capa_opcao_memorias_de_um_sargento'),
    ('030b_notificacoes_ajustes', 'n30b.topics.streak.switch', 'interruptor_desligado_sequencia_hachura'),
    ('030b_notificacoes_ajustes', 'n30b.topics.social.switch', 'interruptor_desligado_social_hachura'),
    # T18 · Cronômetro
    ('018_cronometro', 'cr18.book.cover', 'capa_cronometro_bras_cubas'),
    ('018_cronometro', 'cr18.controls.photo', 'botao_foto_cronometro'),
    # (na 18b a capa fica sob o véu da folha de fim de sessão: a de referência é a da 18)
]
ITENS = {'inicio2': ITENS_INICIO2, 'projeto': ITENS_PROJETO}.get(NOME, ITENS_LEITOR)


def caixa(item, pr):
    """O recorte (x0, y0, x1, y1), em px @3x, de um item: a região dada (T13.11) ou a caixa visual — a união das caixas,
    se o id é uma tupla (T13.11) — + 2 px, dentro do quadro. Caixa vazia (fora do quadro) é erro."""
    slug, id_, nome, *regiao = item
    w, h = pr[slug]['canvas']
    if regiao:                          # T13.11: a região dada (o fundo de tela inteira, sem nada por cima)
        x, y, ww, hh = regiao[0]
        box = (round(x * S), round(y * S), round((x + ww) * S), round((y + hh) * S))
    else:
        L = json.load(open(caminho('layout', f'layout_{slug}.json'), encoding='utf-8'))
        caixas = [L['elements'][i].get('vis') or L['elements'][i]['abs'] for i in ((id_,) if isinstance(id_, str) else id_)]
        x, y = min(c[0] for c in caixas), min(c[1] for c in caixas)
        ww, hh = max(c[0] + c[2] for c in caixas) - x, max(c[1] + c[3] for c in caixas) - y
        box = (max(0, round((x - 2) * S)), max(0, round((y - 2) * S)), min(w * S, round((x + ww + 2) * S)), min(h * S, round((y + hh + 2) * S)))
    if box[2] <= box[0] or box[3] <= box[1]:
        raise SystemExit(f'{nome}: caixa vazia {box} (fora do quadro?)')
    return box


def main():
    os.makedirs(caminho('png', 'elementos'), exist_ok=True)
    pr = {p['slug']: p for p in indice()['pranchas']}
    nomes = [item[2] for item in ITENS]
    if len(set(nomes)) != len(nomes):
        raise SystemExit(f'nome repetido: {sorted(n for n in set(nomes) if nomes.count(n) > 1)}')
    for item in ITENS:
        slug, id_, nome = item[:3]
        w, h = pr[slug]['canvas']
        box = caixa(item, pr)
        im = Image.open(caminho('png', f'{slug}_{w}x{h}@{S}x.png'))
        im.crop(box).save(caminho('png', 'elementos', f'{nome}@{S}x.png'), optimize=True)
        print(f"{nome:30s} {id_ if isinstance(id_, str) else '+'.join(id_):40s} {box}")


if __name__ == '__main__':
    main()
