# Relatório da FASE G16 — Tela 22: modo anotação e motor de tinta

Data: 08/10/2026 · branch `feat/g16-modo-anotacao` (a partir de `feat/g15-sumario-marcadas`, `8bad461`) · nada
enviado ao GitHub. Evidências de cada subfase: `docs/progresso/G16.md`.

Decisões usadas (respondidas por você em 08/10, antes do código):
- A espessura segue a escala da prancha: 1 mm = 11/6 dp; a Média de 1,2 mm desenha com 2,2 px (D-159, substitui a
  escala física da D-28).
- Os trechos anotados da 22 não quebram na prancha; o mundo da 22 usa espaço não separável dentro deles, e um teste à
  parte garante que, vindo da 19, as quebras ficam e o texto só desce 30 (D-160).
- O grifo feito à mão ganha a mancha do arquivo, a 90 % e multiplicada; no Noite, a técnica da D-133 (D-161).
- Um desenho = traços que se tocam; ele se prende às palavras que cobre e acompanha a fonte (D-162).
- Marca-texto, Espaço, o poço de cor e o 2º toque na ativa avisam "Chega numa próxima fase" (D-163); no PDF, "Anotar"
  avisa (D-164).
- Só a página atual: 2 dedos sobem e descem a página, com mola nas pontas (D-165).
- O rascunho de uma sessão que morreu é gravado sozinho ao reabrir o livro (D-166).
- As regras derivadas do desenho (D-167).

Respondidas na revisão do desenho:
- A Borracha só apaga tinta: traços e grifos feitos à mão (D-168).
- As pranchas 19, 20, 26, 26b, 27 e 27b contam a tinta de hoje sem mostrá-la (D-169).

Respondida depois da revisão independente:
- Numa página sem texto (só uma imagem), "Anotar" avisa e não abre o modo, como no PDF (D-170).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G16.1 Motor | Tipos do traço e unidades da D-159; suavização por ponta (porte do perfect-freehand, igual ao npm nos 30 casos); codec BNK1 com o formato congelado do S4 e o teto de 256 KiB | `ink_stroke_test`, `ink_units_test`, `freehand_test`, `bnk1_codec_test` |
| G16.2 Âncora e desenhos | Linhas e palavras da página; âncora nas palavras e moldura em em (D-162); desenhos de traços que se tocam; cartões | `ink_page_geometry_test`, `drawing_anchor_test`, `drawing_clusters_test`, `card_groups_test` |
| G16.3 Ferramentas e sessão | Reta (15°/4°, 4 px), Borracha, Laço, batente (D-165); árbitro de dedos e caneta (palma); desfazer e refazer (100); a sessão do modo | `ink_tools_test`, `gesture_arbiter_test`, `ink_commands_test`, `annotation_session_test` |
| G16.4 Dados | Repositório da tinta: Concluir numa transação, rascunho por sessão no `kv` (D-166), a fila do Pro só no Concluir, a Borracha só na tinta (D-168), o Grátis sem rede | `ink_repository_test`, `ink_sync_queue_test`, `ink_privacy_free_test`, `local_library_test` |
| G16.5 Pintura | A tinta salva no leitor (cache por página) e a mancha do grifo à mão (D-161), no Creme e no Noite | `reader_ink_test`, `ink_painter_test`, `reader_page_view_test` |
| G16.6 Tela | Bricolage 15,5, ícones, ilustrações com a troca de cor no SVG, anel cônico; pílula e Concluir, prateleira, ilha, canvas, borda de mesa, a camada com os lugares do aparelho (D-167); "Anotar", Concluir e Voltar (D-42), avisos (D-163, D-164), imersivo | `annotation_*_test`, `tool_shelf_test`, `reader_screen_g16_test` |
| G16.7 Prova | Mundo da 22 com a tinta do arquivo e NBSP; L22a–d; golden; comportamento; medidor de latência; revisão independente com correções; mutação; cobertura; gitleaks; capturas | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **2.212 verdes** (+7 pulados, os mesmos da G15; eram 1.930 no fim da G15).
- **Fases L22a–d** (a tela 22 pela rota real, aberta pelo fluxo da prancha: Anotar, as 2 barras do sublinhado
  duplo com a Reta, a onda com a Caneta até 66 % e o dedo parado no centro do anel): **20/20**.
  - os ids de cada seção na posição e no tamanho certos;
  - a tinta conferida ponto a ponto contra os caminhos SVG do arquivo: elipse 0,119 px, risco 0,125 px, onda
    0,000 px (limite 0,5 px);
  - as 22 linhas do parágrafo com as quebras da prancha e, vindo da 19, as quebras do leitor limpo;
  - cores, bordas, sombras duras, Bricolage 15,5/800 e as Figtree; o leitor de tela; os dados do banco.
- **Golden @3x** contra a prancha: **0,20 %** (página), **0,00 %** (topo), **0,16 %** (prateleira) e **0,00 %**
  (ilha) — limite 0,5 %. O lado a lado foi conferido a olho.
- **Cobertura** dos arquivos mexidos na fase: **97,5 %** (o menor é o `main.dart`, a abertura do app de produção, que os testes não rodam).
- **Mutação:** **51/51** trocas derrubadas pelos testes, todas por comportamento. Na 1ª rodada passaram 3; os testes
  ganharam o que faltava e as 3 caíram.
- **gitleaks:** os commits da fase e as pastas tocadas, sem vazamento.
- **Latência no celular:** pendente — o celular não estava ligado ao PC. O medidor do S4 já está no modo anotação
  (`--dart-define=BOOKNEST_MEDIR_TINTA=true`); o roteiro está em `G16.md` ("Resultados").

## Capturas

Mandadas na conversa e guardadas em `tools/medicao/tmp/capturas_g16/` (fora do git), 390×844 @3x, pelo teste
`test/golden/capturas_g16_test.dart`:
- a tela 22 em Creme e no Noite;
- a tinta no leitor limpo, depois de A+ e depois da Lora;
- o Laço com a seleção, parado e sendo arrastado;
- a Borracha sobre o grifo à mão;
- o lado a lado da tela 22 com a prancha.

Conferindo as capturas, a pílula do rótulo ativo cortava "Borracha" e "Marcador"; agora transborda centrada, como o
HTML, com teste.

## Revisão independente

Um agente separado leu tudo sem editar e fez **17 achados de código** e **9 sobre testes**. Um virou pergunta para
você (D-170). Corrigi com teste no commit `7851dde`; o 17 ficou como pendência. Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 | Uma sessão nova podia apagar o rascunho de uma sessão que morreu e não gravou ao abrir | Uma chave de rascunho por sessão; ao abrir, cada uma é gravada por si |
| 2 | O que se desenhava durante o Concluir se perdia | Gravando, o modo não aceita tinta; o traço em curso entra na gravação |
| 3 | Com o dedo, o indicador de toque repintava a tela inteira a cada evento | Página, traço ao vivo e indicador em camadas próprias; o modo inteiro numa camada sobre o leitor |
| 4 | Página sem texto: o desenho sumia ao Concluir | D-170 |
| 5, 11, 12 | Laço com a ferramenta trocada no meio, seleção grande demais, tempo do traço voltando, erro ao montar o Concluir | Sem quebra; a seleção grande não se move; a falha liga a pílula |
| 6, 7, 8 | Palavra quebrada entre linhas, trecho que passa de página, trecho em outro tamanho | O desenho fica nas palavras certas e não estica |
| 9, 10 | Toque durante a volta do batente; limite pela linha de base | A página vai ao lugar final; o limite pela base da linha |
| 13 | O rascunho do convidado ficava sem dono ao entrar na conta | Passa para a conta |
| 14, 15, 16 | Medidor contando eventos sem pintura; erro do banco no relatório; página do modo sem texto para o leitor de tela | Corrigidos |

Os outros (os testes e as pendências) estão em `G16.md`, seção "Revisão independente".

## O que mudou do desenho

Nenhuma decisão mudou sem você. Mudou a forma, registrada em `G16.md` (seção "Desvios"):
- **Rascunho:** uma chave por sessão no `kv` (a seção 4 falava em uma por livro).
- **As barras da 22** saem com a Média (2,2 px) contra 2,4 px no arquivo; **a onda ao vivo** tem a pressão
  simulada do dedo. O golden passa.
- **As linhas 20 e 21** não são pintadas no modo: ficam debaixo da parte opaca da borda de mesa.

## Pendências

- **Grifos sobrepostos no Noite** (achado 17): a G17 trata o marca-texto e os grifos da tinta juntos.
- **O Laço da prateleira no Noite** fica escuro (o preenchimento do arquivo é translúcido); para o design decidir.
- **Latência no celular:** com o celular no cabo USB, eu rodo a medição (uns 20 traços seus no modo anotação) e
  registro p50, p95 e máximo; se não bater, a subfase dos pontos previstos.
- **G26 (no celular):** TalkBack e VoiceOver no modo, a caneta de verdade (pressão e palma), o foco ao entrar e sair.

✅ FASE G16 concluída — aguardando sua aprovação para iniciar a FASE G17.
