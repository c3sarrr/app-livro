# Relatório da FASE G15 — Telas 27 e 27b: sumário e páginas marcadas

Data: 07/10/2026 · branch `feat/g15-sumario-marcadas` (a partir de `feat/g14-ajustes-leitura`, `ceded86`) · nada
enviado ao GitHub. Evidências de cada subfase: `docs/progresso/G15.md`.

Decisões usadas (respondidas por você em 06/10, antes do código):
- A faixa do clube fica pronta e some no app até a G21, que liga os clubes (D-149).
- O numeral do capítulo vem do livro: do rótulo do sumário ou do título do capítulo no texto (D-150).
- Tocar num capítulo ou numa marcada vai até lá, fecha a folha e os controles e mostra "← Voltar à pág. N"; o
  capítulo atual só fecha (D-151).
- Tirar a marca na aba Marcadas deixa o cartão com a fita vazia até a folha fechar; tocar de novo devolve a mesma
  marca (D-152).
- As partes do livro viram um título pequeno entre os capítulos (D-153).
- As regras derivadas do desenho (D-154).

Respondidas depois da revisão independente:
- O número do rótulo vale antes do do texto quando pelo menos metade dos capítulos tem número no rótulo; senão, o do
  texto (D-155). O "D. Gloria." do Gutenberg continua o cap. VII.
- O rótulo que é só o número ("XXXII", "Capítulo 1") fica como título, sem numeral (D-156).
- Numeral ou página mais largos que a coluna transbordam inteiros no espaço ao lado, como no HTML da prancha (D-157).
- O leitor de tela lê o cartão das Marcadas inteiro, com a ação "Abrir na página N" (D-158).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G15.1 Numerais | Numeral e título de cada entrada (rótulo, texto, ponto final), guardados no índice; índices de antes da G15 refeitos uma vez | `toc_labels_test`, `book_index_test` (com o Dom Casmurro do Gutenberg), `book_importer_test`, `reader_session_controller_test` |
| G15.2 Dados | O que a folha mostra, a partir dos dados (atual, "lido", anel, marcas, faixa, cartões, datas no fuso); releitura do banco a cada escrita; tirar e devolver a mesma marca com versão; clube vazio até a G21 | `toc_view_test`, `reader_toc_test`, `reader_session_controller_test`, `record_meta_test`, `daos_test` |
| G15.3 Folha e Capítulos | Folha, véu, alça, cabeçalho, abas, faixa do clube, lista com o atual a 378,4, partes, sem sumário, Noite | `toc_sheet_test`, `toc_chapters_test`, `fontes_leitor_g15_test` |
| G15.4 Marcadas e tela | Cartões, fita, dica; "Sumário" abre a folha; ×, Voltar, véu e alça fecham; saltos com a volta; PDF | `toc_bookmarks_test`, `reader_screen_g15_test` |
| G15.5 Verificação | Fases L27 e L27b, goldens, revisão independente com correções, mutação, cobertura, gitleaks e capturas | Abaixo |

Números finais:
- `flutter analyze` sem problemas.
- `flutter test`: **1.930 verdes** (+7 pulados, os mesmos da G14; eram 1.822 no fim da G14).
- **Fase L27** (a tela 27 pela rota real, no mundo da tela 27, com "Sumário" tocado): 5/5.
  - os ids da página, do véu e da folha na posição e no tamanho certos;
  - as quebras e as baselines das linhas à vista;
  - cores, bordas, raios, sombras duras e fontes (Literata 16 e 17/500 novas);
  - leitor de tela: o diálogo, as abas, a lista, os capítulos e o atual;
  - os numerais, as páginas, as marcas, o atual a 41 % e a faixa vêm do banco.
- **Fase L27b** (a aba Marcadas): 5/5, com os 3 marcadores do mundo.
- **Golden @3x** contra as pranchas: **0,0 %** na tela 27 e **0,0 %** na 27b (limite 0,5 %; sem o desfoque do
  comparador, 0,72 % e 0,94 %, o antisserrilhado das letras). O lado a lado foi conferido a olho.
- **Cobertura** dos arquivos mexidos na fase: **98,0 %**. O menor é o importador (92,3 %): faltam caminhos de falha
  antigos, da G09.
- **Mutação:** **60/60** trocas derrubadas pelos testes, todas por comportamento (nenhuma só por compilação), em
  `tools/medicao/tmp/mut/g15/` (gerador `gerar_g15.py`): os numerais (D-150, D-155, D-156), os índices antigos
  refeitos, tirar e devolver a marca, o modelo da folha (atual, fim do capítulo, "lido", PDF, meta, datas, cartões,
  fita pedida, contador, índice que falha), o `ReaderToc`, a coluna que transborda (D-157), a rolagem ao trocar de aba,
  o arrasto, a semântica (D-158) e a tela. Na 1ª rodada passaram duas — o "lido" no capítulo atual no fim do livro e a
  releitura que começa quando a gravação da fita termina —; os testes ganharam as asserções que faltavam (`66c4f5c`) e
  as duas caíram na 2ª rodada.
- **gitleaks:** os 16 commits da fase (`ceded86..HEAD`) e as pastas `lib/features/reader`, `lib/features/library`,
  `lib/core`, `test` e `docs/progresso`, sem vazamento.

## Capturas

Mandadas na conversa e guardadas em `tools/medicao/tmp/capturas_g15/` (fora do git), 390×844 @3x, pelo teste
`test/golden/capturas_g15_test.dart`:
- as telas 27 e 27b em Creme e no Noite, pela rota real no mundo de referência;
- a lista no cap. CXXXVIII, com os numerais largos inteiros no espaço ao lado (D-157);
- a aba Marcadas com a fita de um cartão tirada (D-152);
- um livro com partes (D-153) e um livro sem sumário (D-21), com a folha sozinha;
- o lado a lado das telas 27 e 27b com as pranchas.

Conferindo as capturas, a fita da dica no Noite saía clara com traço escuro; virou a fita vazia do Noite (só o
contorno claro, D-154), com teste (`66c4f5c`).

## Revisão independente

Um agente separado leu tudo sem editar e fez **10 achados de código** e **5 sobre testes**. Quatro viraram perguntas
para você (D-155 a D-158). Corrigi tudo com teste no commit `3f7b77c`. Os principais:

| # | Achado | O que fiz |
|---|---|---|
| 1 | No próprio Dom Casmurro, o cap. 138 aparecia como "CXXXVI" (o numeral não cabia na coluna de 52) | D-157: transborda inteiro no espaço ao lado |
| 2 | No PDF, todo cartão das Marcadas dizia o 1º capítulo | O capítulo vem da página da marca |
| 3 | O numeral do texto passava por cima do rótulo ("Capítulo 1 — X" virava "I │ Capítulo 1 — X"; "XXXII │ XXXII") | D-155 e D-156 |
| 4 | Dois toques rápidos na fita perdiam o 2º | A fita muda na hora e o banco confirma depois; a falha volta ao que o banco diz |
| 5, 6 | Marca na capa aparecia como "cap. I"; uma entrada no fim do sumário apontando para o começo virava o atual para sempre | Sem capítulo antes do 1º; o atual é o que começa mais perto antes da posição |
| 7 | O índice que falha ao ler dizia que o livro não tem sumário | Fica só a moldura |
| 8 | Trocar de aba e voltar perdia a rolagem da lista | A lista fica onde estava; reabrir volta ao atual |
| 9 | O leitor de tela só dizia "Abrir na página N" no cartão; parte e faixa em maiúsculas podiam ser soletradas | D-158; parte e faixa lidas como no livro |
| 10 | Arrastar e abrir a folha refaziam a lista inteira a cada quadro | Só a folha anda |

Os outros (incluindo os testes e as pendências) estão em `G15.md`, seção "Revisão independente". Conferindo as
capturas, achei mais um: a fita da dica no Noite saía clara com traço escuro; virou a fita vazia do Noite (`66c4f5c`).

## O que mudou do desenho

Nenhuma decisão mudou sem você. Mudou a forma, registrada em `G15.md` (seção "Desvios"):
- **Numerais:** as D-155 e D-156 refinam a D-150.
- **Esmaecido da lista:** pintado na cor da folha, sem camada a mais (o resultado é o mesmo da prancha).
- **L27:** a altura da página de cima vem da prancha (200) e a caixa da lista é medida do cap. XXV ao XXXVII, porque
  a lista inteira está montada e rolada.
- **Fita do cartão:** muda no toque; o banco confirma depois (D-152 igual).

## Pendências

- **Sumários enormes:** a lista é montada inteira; com milhares de entradas, uma lista preguiçosa (fase de
  desempenho).
- **G21:** a meta do clube casada com o capítulo do livro e a faixa num livro sem sumário.
- **G26 (no celular):** o foco do leitor de tela ao abrir e fechar a folha, TalkBack e VoiceOver, o arrasto.
- **Anotações antes do 1º capítulo** ainda contam no cap. I (regra da G10).
- **Tablet:** uma largura máxima para a folha.

✅ FASE G15 concluída — aguardando sua aprovação para iniciar a FASE G16.
