# Conferência — as pranchas medidas × o projeto completo

> Gerado por `tools/medicao/conferir_projeto.py` (R00, R8). Não editar à mão: rodar o script de novo.
> Projeto: `docs/design/projeto`.

**35/35 iguais** (DOM normalizado e CSS do `<helmet>` sem as `@font-face`). Runtime: o `dc-runtime.js` contém os 3 scripts das pranchas antigas, na ordem — é o `support.js` que os `.dc.html` chamam.

| Grupo | Nº | Extração antiga | `.dc.html` do projeto | Tokens | DOM | CSS | Resultado |
|---|---|---|---|---|---|---|---|
| Início e revisão | 01 | `001_inicio` | `telas/Main.dc.html` | 903 | igual | igual | igual |
| Início e revisão | 01b | `001b_inicio_lendo_agora` | `telas/MainLendo.dc.html` | 904 | igual | igual | igual |
| Início e revisão | 60 | `060_inicio_grifos_de_hoje` | `telas/MainRevisao.dc.html` | 903 | igual | igual | igual |
| Início e revisão | 61 | `061_revisao_grifo_2_de_5` | `telas/RevisaoGrifo.dc.html` | 149 | igual | igual | igual |
| Início e revisão | 62 | `062_revisao_fim` | `telas/RevisaoFim.dc.html` | 228 | igual | igual | igual |
| Início e revisão | 63 | `063_revisao_imagem_compartilhar` | `telas/RevisaoCompartilhar.dc.html` | 161 | igual | igual | igual |
| Leitor | 19 | `19_leitor_limpo` | `telas/LeitorLimpo.dc.html` | 32 | igual | igual | igual |
| Leitor | 20 | `20_leitor_controles` | `telas/LeitorControles.dc.html` | 170 | igual | igual | igual |
| Leitor | 21 | `21_selecao_texto` | `telas/LeitorSelecao.dc.html` | 130 | igual | igual | igual |
| Leitor | 22 | `22_modo_anotacao` | `telas/LeitorAnotacao.dc.html` | 247 | igual | igual | igual |
| Leitor | 23 | `23_ajustes_caneta` | `telas/LeitorCaneta.dc.html` | 364 | igual | igual | igual |
| Leitor | 23b | `23b_ajustes_marcatexto` | `telas/LeitorMarcador.dc.html` | 393 | igual | igual | igual |
| Leitor | 24 | `24_abrindo_espaco` | `telas/LeitorEspacoAbrir.dc.html` | 273 | igual | igual | igual |
| Leitor | 24b | `24b_nota_mao` | `telas/LeitorEspaco.dc.html` | 296 | igual | igual | igual |
| Leitor | 25 | `25_grifos_notas` | `telas/Grifos.dc.html` | 555 | igual | igual | igual |
| Leitor | 26 | `26_ajustes_leitura` | `telas/LeitorAjustes.dc.html` | 269 | igual | igual | igual |
| Leitor | 26b | `26b_tema_noite` | `telas/LeitorNoite.dc.html` | 168 | igual | igual | igual |
| Leitor | 27 | `27_sumario` | `telas/LeitorSumario.dc.html` | 367 | igual | igual | igual |
| Leitor | 27b | `27b_sumario_marcadas` | `telas/LeitorMarcadas.dc.html` | 160 | igual | igual | igual |
| Clube | 04 | `004_clube_leitoras_de_capitu` | `telas/Clube.dc.html` | 781 | igual | igual | igual |
| Clube | 31 | `031_clube_discusso_da_semana_sem_spoiler` | `telas/ClubeDiscussao.dc.html` | 309 | igual | igual | igual |
| Clube | 32 | `032_clube_membros_e_onde_cada_uma_est` | `telas/ClubeMembros.dc.html` | 390 | igual | igual | igual |
| Clube | 33 | `033_criar_clube` | `telas/ClubeCriar.dc.html` | 399 | igual | igual | igual |
| Clube | 34 | `034_clube_criado_convite_link_e_qr` | `telas/ClubeConvite.dc.html` | 592 | igual | igual | igual |
| Clube | 47 | `047_enquete_criar` | `telas/EnqueteCriar.dc.html` | 295 | igual | igual | igual |
| Clube | 48 | `048_enquete_indicar_um_livro` | `telas/EnqueteIndicar.dc.html` | 210 | igual | igual | igual |
| Clube | 49 | `049_enquete_votar` | `telas/EnqueteVotar.dc.html` | 266 | igual | igual | igual |
| Clube | 50 | `050_enquete_resultado` | `telas/EnqueteResultado.dc.html` | 345 | igual | igual | igual |
| Clube | 70 | `070_encontro_detalhe_dom_20_set` | `telas/EncontroDetalhe.dc.html` | 609 | igual | igual | igual |
| Clube | 71 | `071_encontro_na_hora_sala_aberta` | `telas/EncontroNaHora.dc.html` | 207 | igual | igual | igual |
| Clube | 72 | `072_encontro_mudar_presena_com_recado` | `telas/EncontroPresenca.dc.html` | 720 | igual | igual | igual |
| Clube | 73 | `073_encontro_depois_resumo` | `telas/EncontroDepois.dc.html` | 481 | igual | igual | igual |
| Clube | 102 | `102_quem_votou_enquete_aberta_da_04` | `telas/EnqueteQuemVotou.dc.html` | 975 | igual | igual | igual |
| Clube | 103 | `103_quem_votou_resultado_da_50` | `telas/EnqueteQuemVotouFinal.dc.html` | 505 | igual | igual | igual |
| Clube | 104 | `104_voto_secreto_variao` | `telas/EnqueteSecreta.dc.html` | 1092 | igual | igual | igual |

| Script antigo | Bytes | No `dc-runtime.js` (na ordem) |
|---|---|---|
| React | 10750 | sim |
| ReactDOM | 131834 | sim |
| runtime | 45304 | sim |

## Renderização

Prova de que o mesmo DOM renderiza igual (R00): `tools/medicao/renderizar_dc.js` monta a tela com o `dc-runtime.js` como `support.js` e as fontes embutidas e, com `--antiga`, renderiza a exportação antiga nas mesmas condições; `tools/compare_images.py` compara os dois PNG. Resultado de 11/10/2026 para a 01b @3x: **0 pixels diferentes**. A referência medida da T02 sai do zoom 10: o `.dc.html` no zoom 10 dá o mesmo layout do JSON medido (o "pág. 159 de 256" com 108,97 px e o "E-BOOK" na 2ª linha); no zoom 1 o avanço das letras arredonda (107,97 px) e o "E-BOOK" cabe na 1ª linha — por isso a T13 mede com o método da T02.
