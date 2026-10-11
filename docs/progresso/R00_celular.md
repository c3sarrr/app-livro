# R00 · As 16 telas prontas no celular (R00.8, R7)

> Etapa 5 · R00, Arrumação — a regra R7 da [spec](R00.md) e a Tarefa 9 do [plano](R00_plano.md). 11/10/2026.
> As capturas e os lado a lado estão em [`R00_celular/`](R00_celular/).

## O aparelho

| | |
|---|---|
| Modelo | Samsung Galaxy S22+ (SM-S906E), por USB (`RXCT200CA6F`) |
| Sistema | Android 16 (API 36) |
| Tela | 1080 × 2340 px a 450 dpi = 2,8125 px por ponto lógico → **384 × 832 lógicos** (as pranchas: 390 × 844) |
| Navegação | 3 botões (a barra do sistema fica no pé, sobre o app de ponta a ponta) |

## O build e o roteiro

- **Alvo (1)** — `test/fixtures/main_demonstracao.dart` (D-267): o app de verdade sobre o banco só do demo
  (`booknest_demo.db`), com o mundo de referência semeado; sem servidor. As 16 telas.
- **Alvo (2)** — `test/fixtures/main_mundo_referencia.dart`: a Início igual à prancha (a fixture da 01) e o leitor
  sobre o banco semeado. As 3 telas da Início, em `<nn>_prancha_*.png`.
- O roteiro do aparelho é [`integration_test/capturas_r00_test.dart`](../../integration_test/capturas_r00_test.dart):
  monta o alvo sobre uma pasta temporária (o banco recém-semeado, num diretório do sistema que é apagado depois), leva
  o app ao estado de cada prancha com gestos de verdade — os mesmos caminhos da tabela (b) da
  [NAVEGACAO.md](../NAVEGACAO.md) — e em cada uma imprime `R00CAP <nn>` e fica parado 6 s. O relógio começa no "agora"
  de referência (dom 20/09/2026 20:00) e só anda quando o roteiro manda (a 01b: 8 min 42 s).
- O script [`tools/celular/capturar_r00.py`](../../tools/celular/capturar_r00.py) roda o roteiro em perfil, tira a
  captura pelo `adb exec-out screencap -p` a cada marca e monta o lado a lado (a captura e o PNG da prancha @3x na mesma
  altura, o título embaixo). Falha se faltar alguma captura.
- **A barra do Android** aparece nas telas que a mostram (o leitor limpo e o modo anotação a escondem). A faixa dos
  ícones de notificação dela (os apps do celular do Cesar; o repositório é público) é coberta em cada captura — do fim
  do relógio ao último ícone antes do meio, coluna a coluna, com a cor de cima e a de baixo; o relógio, a rede e a
  bateria ficam. Na 60 a barra está sobre o conteúdo rolado e os ícones não se separam do fundo: a faixa vai do fim do
  relógio medido na 01 (a captura anterior, do mesmo minuto) até x 400 e aparece como um degradê no alto do mostrador.
- O celular está no fuso de São Paulo (`persist.sys.timezone` = `America/Sao_Paulo`), o mesmo do mundo de referência
  (D-09): as horas das sessões gravadas e o "agora" do relógio do demo batem.

```bash
python3 tools/celular/capturar_r00.py --alvo 1
```

```bash
python3 tools/celular/capturar_r00.py --alvo 2
```

Por dentro, cada rodada é
`flutter drive --profile --keep-app-running --driver=test_driver/integration_test.dart --target=integration_test/capturas_r00_test.dart --dart-define=R00_ALVO=<n> -d RXCT200CA6F`.

### Os dados do app normal

O app instalado (`com.example.app_leitura`) guarda os dados de verdade do Cesar (`booknest.db`, `livros/`,
`capas_arquivo/`, `catalogo/`). O roteiro nunca abre esse banco (o demo usa outro nome de arquivo e outras pastas — D-267,
com teste), e o build não pode desinstalar o app:

- **nunca** `flutter install` (desinstala antes de instalar) nem `flutter drive` sem `--keep-app-running` ou
  `flutter test integration_test` sem `--no-uninstall` (os dois desinstalam no fim) — conferido no código do
  `flutter_tools` 3.47.2;
- antes de cada instalação, os scripts ([`aparelho.py`](../../tools/celular/aparelho.py)) conferem que o celular está
  conectado, que o APK instalado tem a assinatura do build novo (o do `flutter drive`: a chave de debug deste
  computador, SHA-256 `14faa78b…`, pelo `keytool` e pelo `apksigner`) e que há espaço — com outro assinante o
  `adb install -r` falha e o `flutter` desinstala para tentar de novo — e guardam o APK do app normal em
  `%LOCALAPPDATA%\booknest\celular\`; depois de instalar, conferem que a data da primeira instalação não mudou;
- antes da primeira instalação, o APK que estava no aparelho (o app de 09/10, compilado em AOT, sem depuração) foi
  guardado fora do repositório; uma cópia dos dados, logo depois da primeira instalação por cima (sem depuração, a pasta
  do app de antes não se deixa ler); depois de cada rodada, o `booknest.db` (339 968 bytes,
  09/10 23:16), o `-wal` (10/10 23:28), o livro em `livros/` e a capa em `capas_arquivo/` foram conferidos — iguais;
- o roteiro apaga no fim a pasta temporária do demo (conferido no aparelho: nada sobra no `code_cache`);
- **devolução:** o mesmo APK de antes, reinstalado por cima com `adb install -r` (mesma assinatura, mesma versão — os
  dados ficam): o app voltou a ser o de 09/10 (sem depuração), com a data da primeira instalação (09/10 21:31)
  preservada, o que prova que ele não foi desinstalado em nenhum momento. Na segunda rodada (11/10, a partir das 11:43) a
  volta foi pelo `python3 tools/celular/demo.py --voltar`, com o APK guardado pelo próprio script (igual byte a byte
  ao de antes da R00).

### A entrada de verdade do alvo (1)

O roteiro das capturas monta o alvo sobre uma pasta temporária; a entrada que o Cesar usa é o
`main_demonstracao.dart` → `runBookNest`. Ela rodou no S22+ pelo `demo.py` (11/10, 11:43): o app abriu na Início do
demo ([demo_entrada_celular](R00_celular/demo_entrada_celular.png): "Boa noite, Marina", o Dom Casmurro na pág. 159 de
256, 62 %), e a pasta do app ganhou só o `booknest_demo.db` e as pastas `*_demo` (todos das 11:43). O `booknest.db`
continua **igual byte a byte** à cópia de segurança (SHA-256 `aab7258a…`, 339 968 bytes, 09/10 23:16), assim como o
livro em `livros/` e a capa em `capas_arquivo/`; o `-wal` e o `-shm` têm a data de 04:31 — a primeira abertura do app
normal depois da devolução da primeira rodada (o `profileinstaller` é da mesma hora) —, antes da instalação do demo, e
continuaram iguais depois das capturas.

## As 16 telas no alvo (1)

O que difere e não é defeito tem a decisão ao lado. "Largura de 384" = o texto do livro quebra em outros pontos que na
prancha de 390, e a página leva menos texto.

| Tela | Captura | Lado a lado | O que difere da prancha | Por quê |
|---|---|---|---|---|
| 01 Início | [01_celular](R00_celular/01_celular.png) | [01](R00_celular/01_lado_a_lado.png) | As capas são as geradas (não a arte desenhada); "~1h 20min" em vez de "~2h 10min"; o Brás Cubas com o título inteiro ("Memórias Póstum…"); a barra de status do Android em cima | Capas: D-79. Tempo: a velocidade pessoal (D-97) pesa as 2 sessões curtas de hoje do mundo (10 + 8 min). Título: D-270 (achado 1). Barra: o app é de ponta a ponta e a prancha não desenha o sistema |
| 60 Início, revisão | [60_celular](R00_celular/60_celular.png) | [60](R00_celular/60_lado_a_lado.png) | Rolada até o mesmo ponto (o pé do "Seu dia" em 289,7): sem o cartão "Seus grifos de hoje", então o "Para você" sobe; nele, Memorial de Aires, Quincas Borba e Esaú e Jacó com as capas geradas (a prancha: Esaú e Jacó, Memorial de Aires, Casa de Pensão); "1 destaque" em vez de "2 destaques" | Revisão: D-247 (chega com a T05). Para você: o catálogo só do demo (D-269) pela regra da G08 — um autor só, a edição mais nova primeiro (D-81); capas: D-79. Destaques: D-60 (`t01_divergencias_test`) |
| 01b Lendo agora | [01b_celular](R00_celular/01b_celular.png) | [01b](R00_celular/01b_lado_a_lado.png) | Igual, com o "08:42"; a mini-barra com o título inteiro e a capa gerada | D-79 e D-270 |
| 19 Leitor limpo | [19_celular](R00_celular/19_celular.png) | [19](R00_celular/19_lado_a_lado.png) | A pág. 159 com a tinta de hoje (o grifo, a elipse, as ondas, a nota à mão); a onda de "fluido" e o sublinhado de "a vaga" passam da margem direita | Tinta: D-169 (as pranchas mostram a página limpa e contam a tinta). Margem: largura de 384 — o trecho passou a quebrar entre linhas e o desenho fica no começo do 1º pedaço (G16, a limitação do Anexo 03 §9.5) |
| 20 Controles | [20_celular](R00_celular/20_celular.png) | [20](R00_celular/20_lado_a_lado.png) | "18 min hoje" igual; "≈ 1 h 20 min" em vez de "≈ 2 h 10 min"; a tinta de hoje; a barra de status | D-97, D-169; a barra volta com os controles (D-105) |
| 21 Seleção | [21_celular](R00_celular/21_celular.png) | [21](R00_celular/21_lado_a_lado.png) | Seleciona "capaz" (a prancha estende a seleção até "como a vaga… ressaca.", que no celular cai na página seguinte) e o menu abre acima, no terço de cima | Largura de 384 + a nota à mão do mundo ocupando a página (D-169) |
| 22 Modo anotação | [22_celular](R00_celular/22_celular.png) | [22](R00_celular/22_lado_a_lado.png) | A nota à mão já está na página; a prancha mostra o traço ao vivo e o Desfazer ativo | O mundo é o fim da história da 24b: a tinta é de uma sessão já gravada, então a sessão nova começa sem passos |
| 23 Caneta | [23_celular](R00_celular/23_celular.png) | [23](R00_celular/23_lado_a_lado.png) | Igual; o Desfazer apagado | Idem 22 |
| 23b Marca-texto | [23b_celular](R00_celular/23b_celular.png) | [23b](R00_celular/23b_lado_a_lado.png) | Igual; o Desfazer apagado | Idem 22 (a D-59 da 23b vale igual) |
| 24 Abrindo espaço | [24_celular](R00_celular/24_celular.png) | [24](R00_celular/24_lado_a_lado.png) | Igual: "3 linhas" na fresta de "Vá, de ressaca.", o texto de baixo descido | Para chegar: a fresta já tem a nota da 24b (uma nota por âncora, G18 R5) — o roteiro apaga a nota na sessão, abre o espaço e desfaz os dois passos antes de concluir |
| 24b Nota à mão | [24b_celular](R00_celular/24b_celular.png) | [24b](R00_celular/24b_lado_a_lado.png) | Igual; quebras da largura de 384; o Desfazer apagado | Idem 22 |
| 25 Grifos e notas | [25_celular](R00_celular/25_celular.png) | [25](R00_celular/25_lado_a_lado.png) | Igual (o topo da prancha de 2170) | — |
| 26 Ajustes (Aa) | [26_celular](R00_celular/26_celular.png) | [26](R00_celular/26_lado_a_lado.png) | Igual; a tinta de hoje atrás do painel | D-169 (a D-147 da 26 vale igual) |
| 26b Noite | [26b_celular](R00_celular/26b_celular.png) | [26b](R00_celular/26b_lado_a_lado.png) | Igual, "18 min hoje" | D-169 |
| 27 Sumário | [27_celular](R00_celular/27_celular.png) | [27](R00_celular/27_lado_a_lado.png) | Igual, com as páginas da prancha (121, 126… 157 do XXXII, 163); o XXXIII fica sob a barra de navegação do Android | Páginas: o índice do demo põe cada capítulo na página do sumário do mundo (achado 4). O pé: a tela tem 832 de altura e a barra de 3 botões fica sobre o app |
| 27b Marcadas | [27b_celular](R00_celular/27b_celular.png) | [27b](R00_celular/27b_lado_a_lado.png) | Igual | — |

## A Início no alvo (2)

| Tela | Captura | Lado a lado | O que difere |
|---|---|---|---|
| 01 | [01_prancha_celular](R00_celular/01_prancha_celular.png) | [01](R00_celular/01_prancha_lado_a_lado.png) | Igual à prancha (capa desenhada, "~2h 10min", "Brás Cubas"); só a barra de status e a de navegação do Android |
| 60 | [60_prancha_celular](R00_celular/60_prancha_celular.png) | [60](R00_celular/60_prancha_lado_a_lado.png) | Igual, com o cartão da revisão e o "Para você" |
| 01b | [01b_prancha_celular](R00_celular/01b_prancha_celular.png) | [01b](R00_celular/01b_prancha_lado_a_lado.png) | Igual, "Brás Cubas · 08:42" |

## O percurso no aparelho (R5)

`flutter test integration_test/navegacao_test.dart -d RXCT200CA6F --no-uninstall` (depois da conferência do
`aparelho.py`: a assinatura do app instalado é a chave de debug deste computador) — as 74 ligações da tabela (b) da
NAVEGACAO.md, no Galaxy S22+, em 6 min 14 s: todas passam; os 18 🟡 (placeholders de etapas futuras) saem na lista do
console e batem com a tabela. Depois disso a prova ficou mais forte (a página de chegada e o acerto dos ⏸, R00.md
Desvio 12); a versão nova roda na suíte (`test/app/navegacao_test.dart`), e a do aparelho é o mesmo código.

## Como chegar

Os passos de cada tela estão na [NAVEGACAO.md, seção (d)](../NAVEGACAO.md#d-como-chegar-no-celular), com o comando do
alvo (1). São os mesmos que o roteiro das capturas faz.

## Achados

1. **O título curto do Brás Cubas.** A prancha mostra "Brás Cubas" em "Também lendo" e na mini-barra; o app mostra
   `shortTitle ?? title`, e o livro do banco não tem título curto (só a fixture da Início tem). Com dados reais aparece
   "Memórias Póstumas de Brás Cubas", cortado com reticências. Resposta de 11/10 (**D-270**): a T14 (Livro · editar) ganha o
   campo opcional "título curto", preenchido pelo catálogo quando houver; até lá, o título inteiro com reticências.
2. **O "Para você" sumia no alvo (1).** Ele vem do catálogo baixado (G08, D-81), e o demo não usa o servidor (D-267).
   Resposta de 11/10 (**D-269**): um catálogo só do demo (`test/fixtures/demonstracao/catalogo_demonstracao.dart`, formato 1 do
   pipeline, as edições de Machado de Assis da Penguin-Companhia com os ISBNs reais) e um atualizador sem rede. A regra
   da G08 escolhe de um autor só, então a Casa de Pensão (Aluísio Azevedo) da prancha dá lugar ao Quincas Borba, e a
   edição mais nova vem primeiro (Memorial de Aires, 2022).
3. **A tinta de hoje na largura de 384.** A onda de "fluido misterioso" e o sublinhado de "a vaga que se retira" passam
   da margem: a regra da G16 para trecho que passou a quebrar entre linhas. Já registrada (G16); aparece no celular por
   causa da largura.
4. **As páginas do sumário e dos marcadores.** Na primeira rodada o sumário mostrava outras páginas que a prancha, e
   foi atribuído à largura de 384; a prova de navegação mais forte mostrou a causa de verdade: o EPUB curto do mundo
   espalhava os capítulos por igual nas 256 páginas, e o marcador da pág. 3 levava à pág. 5. O índice do demo
   (`test/fixtures/demonstracao/indice_demonstracao.dart`) põe cada capítulo na página do sumário do mundo; a 27 foi
   capturada de novo (11/10, 11:51) e as outras 15 telas saíram iguais às da primeira rodada (fora da barra do
   Android).
