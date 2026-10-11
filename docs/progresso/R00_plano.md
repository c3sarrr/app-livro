# R00 — Arrumação: plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez; onde há código, TDD (o
> teste falha, o código mínimo passa) e commit pequeno. Passos com `- [ ]`.
> Spec: `docs/progresso/R00.md` (D-267, D-268, R1…R8), citada por R00.n. Branch `feat/r00-arrumacao`, a partir da
> `main` em `d8c32d2` (o merge do PR #1, a T04 inteira). As 4 respostas de 11/10/2026 foram as recomendadas: o plano
> vale inteiro (os passos "se D-267 …" não se aplicam).

**Objetivo:** a `main` em dia e o roteiro no git; a prova de que as pranchas medidas não mudaram; a cobertura das 128
telas (+ as 9 que faltam); as ligações do Mapa (00) e a `docs/NAVEGACAO.md` com um teste que percorre o app; o modo
demonstração fora da loja; e as 16 telas prontas vistas no Galaxy S22+, lado a lado com as pranchas.

**Arquitetura:** três ferramentas de leitura do projeto em `tools/medicao/` (Python puro, sem Chromium, exceto a
renderização de prova) → documentos em `docs/design/projeto/` e `docs/` → testes Dart que leem esses documentos e
travam a coerência (cobertura × catálogo × ROTEIRO; navegação documentada × provada). O modo demonstração vive em
`test/fixtures/demonstracao/` (nada em `lib/`, D-34) e reaproveita `Mundo.gravarEm`, `mundoEpub` e o índice injetado
das telas do leitor; entra no app por `runBookNest(overrides: …)`, trocando o banco, as pastas e o relógio.

**Pilha:** Flutter 3.47.2 / Dart 3.13.2, flutter_riverpod 3, drift + PowerSync, go_router 18; Python 3.11 (WSL, para o
Chromium) e `python3` do Windows para os scripts sem Chromium (`PYTHONIOENCODING=utf-8`); `adb` do SDK Android;
Playwright 1.56 no WSL (`tools/medicao/wsl.sh`).

**Execução e ambiente:** testes no Windows, um `flutter test` por vez (sqlite3.dll); o celular é o
`RXCT200CA6F` (SM-S906E); o app normal dele tem dados do Cesar — o demo só abre `booknest_demo.db`; gitleaks no WSL com
`MSYS_NO_PATHCONV=1`. Antes de cada tarefa: `git status` limpo e nenhuma outra sessão mexendo no checkout.

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `.gitattributes` | `docs/design/projeto/** -text` | 1 |
| `CLAUDE.md`, `docs/ROTEIRO.md`, `docs/STATUS.md`, `docs/design/LEIA-ME.md`, `docs/design/projeto/**` | o roteiro e o projeto no git | 1 |
| `docs/progresso/R00.md`, `R00_plano.md` | spec e plano com as respostas | 2 |
| `docs/progresso/PLANO_FIDELIDADE_TELAS.md` | D-267, D-268 na §3 | 2 |
| `tools/medicao/conferir_projeto.py` (novo) | as 35 pranchas antigas × o projeto; o `dc-runtime.js` (R8) | 3 |
| `tools/medicao/renderizar_dc.js` (novo) | a 01b do projeto renderizada com o `dc-runtime.js` como `support.js` | 3 |
| `docs/design/medicao/projeto/conferencia_projeto.md` (novo) | o resultado da conferência | 3 |
| `docs/design/projeto/COBERTURA.md` (novo) | as 128 + as 9 + o futuro (R1, R2) | 4 |
| `test/design/cobertura_test.dart` (novo) | catálogo × cobertura × ROTEIRO | 4 |
| `tools/medicao/mapa_navegacao.py` (novo), `docs/design/medicao/projeto/mapa_navegacao.json` (novo) | as ligações do Mapa (R3) | 5 |
| `docs/NAVEGACAO.md` (novo) | rotas, toques, ligações do mapa, como chegar (R4) | 6 |
| `test/support/navegacao.dart` (novo) | a lista das ligações e o percurso (R5) | 7 |
| `test/app/navegacao_test.dart` (novo), `integration_test/navegacao_test.dart` (novo) | o percurso na suíte e no S22+ | 7 |
| `test/design/navegacao_doc_test.dart` (novo) | documentação × prova | 7 |
| `test/fixtures/demonstracao/semear_mundo.dart` (novo) | o mundo gravado num banco (R6) | 8 |
| `test/fixtures/demonstracao/relogio_demonstracao.dart` (novo) | o relógio que começa no "agora" de referência e anda | 8 |
| `test/fixtures/demonstracao/overrides_demonstracao.dart` (novo) | banco, pastas, capas, relógio, tique | 8 |
| `test/fixtures/main_demonstracao.dart` (novo) | o alvo (1) da D-267 | 8 |
| `test/fixtures/main_mundo_referencia.dart`, `test/fixtures/overrides_do_mundo.dart` | o alvo (2): o leitor e os grifos abrem do banco semeado | 8 |
| `test/fixtures/demonstracao/*_test.dart`, `test/design/sem_test_em_lib_test.dart` (novos) | a semeadura, a privacidade, o isolamento | 8 |
| `integration_test/capturas_r00_test.dart`, `test_driver/integration_test.dart` (novos) | leva o app a cada uma das 16 telas e marca | 9 |
| `tools/celular/capturar_r00.py` (novo) | o `adb exec-out screencap -p` em cada marca e o lado a lado | 9 |
| `docs/progresso/R00_celular.md`, `docs/progresso/R00_celular/*.png` (novos) | a prova no celular | 9 |
| `docs/ROTEIRO.md`, `docs/STATUS.md`, `docs/design/LEIA-ME.md`, `docs/progresso/R00.md` | fechamento | 10 |

---

## Tarefa 1 — Git e o roteiro no repositório (R00.1)

- [x] **Conferir o checkout:** `git status` (só os 5 caminhos do roteiro + a spec e o plano); `git log -1` = `7754c53`.
- [x] **main em dia.** O `git fetch` mostrou o `origin/main` em `d8c32d2` (o merge do PR #1, feito no GitHub em 10/10
      23:09, árvore igual à do `7754c53`): a `main` local avança até ele, sem push.
  ```bash
  git fetch origin
  git fetch . origin/main:main        # só avança (recusa o que não for fast-forward)
  git checkout -b feat/r00-arrumacao  # a partir da main
  ```
  (O `git checkout main` direto é recusado com o `CLAUDE.md` modificado; o `--ff-only` rodado nessa hora avançou a
  branch da T04 por engano e ela voltou ao `7754c53` com `git branch -f` — ver os Desvios da spec.)
- [x] **`.gitattributes`:** acrescentar, depois da linha da G21:
  ```
  # R00: o projeto completo do Claude Design (128 telas + o mapa) byte a byte, como veio (os sha256 do CATALOGO.md)
  docs/design/projeto/** -text
  ```
- [x] **Commit do roteiro** (`94b06b5`): `git add .gitattributes CLAUDE.md docs/ROTEIRO.md docs/STATUS.md docs/design/LEIA-ME.md docs/design/projeto`
      → `docs(roteiro): o roteiro único, o STATUS e o projeto completo do design (R00.1)`.
- [x] **Os sha256 batem no checkout** (os 12 primeiros dígitos do `CATALOGO.md` contra os arquivos):
  ```bash
  rm -rf docs/design/projeto && git checkout -- docs/design/projeto
  PYTHONIOENCODING=utf-8 python3 - <<'EOF'
  import hashlib, re
  linhas = open('docs/design/projeto/CATALOGO.md', encoding='utf-8').read().splitlines()
  ok = ruins = 0
  for l in linhas:
      m = re.search(r'`(telas/[^`]+)`.*`([0-9a-f]{12})`', l)
      if not m: continue
      h = hashlib.sha256(open('docs/design/projeto/' + m.group(1), 'rb').read()).hexdigest()[:12]
      if h == m.group(2): ok += 1
      else: ruins += 1; print('DIFERE', m.group(1), h, m.group(2))
  print('ok', ok, 'diferentes', ruins)
  EOF
  ```
  Resultado: `ok 129 diferentes 0` antes e depois do checkout. Push: `git push -u origin feat/r00-arrumacao`.

## Tarefa 2 — Spec e plano com as respostas (R00.1)

- [ ] Preencher em `R00.md` a tabela "Decisões" com as respostas (data, opção escolhida) e mudar o título para
      "Decisões em uso"; cortar deste plano o que as respostas tirarem.
- [ ] `PLANO_FIDELIDADE_TELAS.md` §3: as linhas D-267 e D-268 (proposta escolhida e alternativas), e a nota do topo
      ("as D-267 e D-268 vieram da R00").
- [ ] ROTEIRO §1 item 3: "A próxima decisão livre é a **D-269**".
- [ ] Commit `docs(progresso): R00 — spec, plano e as decisões D-267 e D-268`.

## Tarefa 3 — As pranchas do projeto contra as medidas (R00.2, R8)

**Arquivos:** `tools/medicao/conferir_projeto.py`, `tools/medicao/renderizar_dc.js`,
`docs/design/medicao/projeto/conferencia_projeto.md`.

- [ ] **Escrever `conferir_projeto.py`** (Python puro). Pares: as 6 de `tools/medicao/pranchas_inicio2/<slug>/template.html`,
      as 13 de `tools/medicao/pranchas/<slug>/template.html` e as 16 do clube extraídas para
      `tools/medicao/tmp/r00/pranchas_clube/` (`extrair_bundle.py … --aninhado tools/medicao/pranchas_clube.json`,
      fora do git), cada uma com o `.dc.html` do `CATALOGO.md`. O núcleo:
  ```python
  class Tokens(HTMLParser):
      """DOM em tokens comparáveis: fora do <helmet>; atributos em ordem; sc-camel-* → camelCase; espaços colapsados;
      data-props como JSON ordenado; style sem o ';' final."""
      def __init__(self):
          super().__init__(convert_charrefs=True); self.out = []; self.dentro_helmet = 0
      def handle_starttag(self, tag, attrs):
          if tag == 'helmet': self.dentro_helmet += 1
          if self.dentro_helmet: return
          norm = []
          for k, v in attrs:
              k = k.lower(); v = v or ''
              if k.startswith('sc-camel-'): k = k[len('sc-camel-'):].replace('-', '')
              if k == 'data-props': v = json.dumps(json.loads(v), sort_keys=True)
              if k == 'style': v = re.sub(r'\s+', ' ', v).strip().rstrip(';')
              if tag == 'script' and k == 'src': v = 'SUPORTE'   # o id do bundle × ./support.js
              norm.append((k, v))
          self.out.append((tag, tuple(sorted(norm))))
      def handle_endtag(self, tag):
          if tag == 'helmet': self.dentro_helmet -= 1
          elif not self.dentro_helmet: self.out.append(('/', tag))
      def handle_data(self, d):
          d = re.sub(r'\s+', ' ', d).strip()
          if d and not self.dentro_helmet: self.out.append(('#', d))

  def css_do_helmet(html):
      """O CSS do <helmet> sem comentários nem @font-face (as fontes são da T13)."""
      h = html[html.find('<helmet>'):html.find('</helmet>')]
      css = ' '.join(re.findall(r'<style>(.*?)</style>', h, re.S))
      css = re.sub(r'/\*.*?\*/', '', css, flags=re.S)
      css = re.sub(r'@font-face\s*{[^}]*}', '', css)
      return re.sub(r'\s+', ' ', css).strip()
  ```
      E o runtime: os 3 `.js` de `pranchas_inicio2/001b_inicio_lendo_agora/assets/` (React, ReactDOM, o runtime)
      contidos, nessa ordem, no `docs/design/projeto/dc-runtime.js`. Saída: a tabela Markdown (tela · arquivo
      antigo · `.dc.html` · tokens · DOM · CSS · resultado) + o resumo, escrita em `conferencia_projeto.md`; código de
      saída 1 se alguma diferir.
- [ ] **Rodar:** `PYTHONIOENCODING=utf-8 python3 tools/medicao/conferir_projeto.py` → `35/35 iguais`, runtime `contém os 3`.
      Mutação manual (fora do git): trocar um texto num `.dc.html` copiado para `tools/medicao/tmp/` e apontar o
      script para ele (`--projeto tools/medicao/tmp/r00/projeto_mutado`) → `34/35`, saída 1.
- [ ] **Escrever `renderizar_dc.js`** (Node, Playwright do WSL): monta em `tools/medicao/tmp/r00/dc/` uma cópia do
      `MainLendo.dc.html` com o `<helmet>` do `template.html` antigo (as `@font-face` com os `assets/`), o
      `dc-runtime.js` copiado como `support.js` e os `assets/` antigos ao lado; abre essa cópia e o `original.html`
      antigo com `lancar()`/a rotina do `abrir()` do `comum.js` (rede bloqueada, `document.fonts.ready`), tira o PNG
      do quadro (390 × 844, dsf 1) das duas e compara o `innerText` do quadro.
- [ ] **Rodar:** `MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'node tools/medicao/renderizar_dc.js'` e
      `python3 tools/compare_images.py <novo.png> <antigo.png>` → texto igual, `raw_mismatch_% = 0`. Anotar na
      conferência.
- [ ] **ROTEIRO §6b:** trocar a última frase por: "O `support.js` que os `.dc.html` chamam é o próprio `dc-runtime.js`
      (a R00 conferiu: ele é a concatenação exata do React, do ReactDOM e do runtime das pranchas antigas, e a 01b
      renderiza igual com ele no lugar)."
- [ ] Commit `feat(medicao): a conferência das pranchas do projeto contra as medidas — 35/35 iguais (R00.2)`.

## Tarefa 4 — A cobertura das 128 telas (R00.3, R1, R2)

**Arquivos:** `docs/design/projeto/COBERTURA.md`, `test/design/cobertura_test.dart`.

- [ ] **Teste primeiro** (`cobertura_test.dart`, `dart:io` + `flutter_test`), lendo os 3 arquivos da raiz do repo:
  - `catalogo()` → as linhas da tabela do `CATALOGO.md` (nº, título, arquivo), sem a 00;
  - `cobertura()` → as linhas da tabela principal da `COBERTURA.md` (nº, título, arquivo, rota, situação, etapa, obs.);
  - `roteiro()` → por etapa (o ID da coluna 2 da tabela da §3), os números de tela citados na coluna 3
    (`RegExp(r'\b(\d{2,3}b?|\d{2}[a-d])\b')` nos parênteses).
  Casos: (1) cada tela do catálogo aparece **uma vez** na cobertura com o mesmo título e arquivo (as 3 da 83 casam pelo
  arquivo); (2) nenhuma linha a mais; (3) situação ∈ {✅, 🟠, ⬜}; (4) a etapa da linha cita aquele número no ROTEIRO
  (as 16 ✅ apontam a etapa que as fez: T03, T04 ou 0 · G00–G22/T01); (5) as 16 do app (01, 01b, 60, 19–27b) estão ✅;
  (6) a seção das 9 que faltam tem 9 linhas com "abre de" e uma etapa que existe no ROTEIRO.
- [ ] Rodar `flutter test test/design/cobertura_test.dart` → falha (o arquivo não existe).
- [ ] **Escrever a `COBERTURA.md`**: topo (o que é, como manter, a legenda e o resumo ✅/🟠/⬜ por etapa); a tabela das
      128 na ordem do catálogo — rota (do `router.dart`; "—" sem rota), situação pela R1 (🟠 só onde uma rota mostra
      hoje uma versão provisória daquele estado: conferir no código o que o `scanner_screen.dart` desenha — achou, já na
      estante, não achou, sem permissão, digitar —, o que o `sign_in_screen.dart` e o `onboarding_screen.dart`
      cobrem, e escrever na observação "provisório (D-76)", "mínimo (D-21)"); a etapa pela §3; as exceções aprovadas
      nas ✅ (D-55, D-147, D-204, D-59). Depois: "As 9 que faltam no projeto" (abre de, prioridade do design, etapa da
      D-268, o que o app tem hoje) e "Futuro (fora da v1.0)": Livros do ano.
- [ ] Rodar o teste → passa. Mutação: trocar a etapa de uma linha e apagar outra → cada uma derruba um caso.
- [ ] Commit `docs(design): a cobertura das 128 telas e o teste que a confere com o catálogo e o roteiro (R00.3)`.

## Tarefa 5 — As ligações do Mapa (R00.4, R3)

**Arquivos:** `tools/medicao/mapa_navegacao.py`, `docs/design/medicao/projeto/mapa_navegacao.json`.

O mapa é estático (cartões em `position: absolute` com `left/top/width/height` em px do quadro de 1700 × 1300; as setas
num único `<svg viewBox="0 0 1700 1300">` com `marker-end`): a leitura não precisa de Chromium.

- [ ] **Escrever o script:**
  ```python
  CARTAO = re.compile(r'<div style="position: absolute; left: ([\d.]+)px; top: ([\d.]+)px; width: ([\d.]+)px; '
                      r'height: ([\d.]+)px;[^"]*"><span[^>]*>([^<]+)</span><span[^>]*>([^<]+)</span></div>')
  CAMINHO = re.compile(r'<path d="M([\d.]+) ([\d.]+) C[\d. ]+ ([\d.]+) ([\d.]+)"([^>]*)>')

  def cartao_em(x, y, cartoes, folga=8.0):
      dentro = [c for c in cartoes
                if c['x'] - folga <= x <= c['x'] + c['w'] + folga and c['y'] - folga <= y <= c['y'] + c['h'] + folga]
      return min(dentro, key=lambda c: abs(c['y'] + c['h'] / 2 - y)) if dentro else None
  ```
      Cartão = `{numero, titulo, x, y, w, h, faltando}` (o "+" tracejado = `faltando`; o número repetido da 83 fica
      com o título para desempatar). Ligação = `{de, para, seta}`: a ponta `M` é a origem, a última coordenada é o
      destino quando o caminho tem `marker-end` (as duas pontas com `marker-start` + `marker-end` = ida e volta).
      Caminho com uma ponta fora de qualquer cartão → `sem_par` (com as coordenadas). Grava o JSON (cartões, ligações,
      `sem_par`, as seções e a frase da barra de baixo) e imprime o resumo.
- [ ] **Rodar** `PYTHONIOENCODING=utf-8 python3 tools/medicao/mapa_navegacao.py` → 135 cartões (126 + 9), 83 setas (os 3 caminhos restantes são a legenda e o
      desenho da ponta, ignorados de propósito),
      `sem_par` vazio (ou cada um explicado no JSON e no relatório). Conferir 5 ligações a olho no PNG do mapa
      (renderizado pelo `renderizar_dc.js` da Tarefa 3 com `MapaNavegacao.dc.html`, 1700 × 1300).
- [ ] Commit `feat(medicao): as ligações do mapa de navegação lidas da geometria da tela 00 (R00.4)`.

## Tarefa 6 — `docs/NAVEGACAO.md` (R00.5, R4)

- [ ] **(a) Rotas:** uma linha por rota do `router.dart` (as 4 abas, `/scanner`, `/notificacoes`, `/leitor/:bookId`,
      `/livro/:bookId`, `/livro/:bookId/destaques`, `/para-voce`, `/clube/:clubId/discussao`, `/entrar`,
      `/conta/cadastro`, `/_ds`, `/_pro`): o que mostra hoje, telas do projeto que vão para lá, a etapa que troca.
- [ ] **(b) Toques das telas prontas:** para cada uma (Início 01/01b/60 com a mini-barra e a folha da sessão; leitor
      19–27b; grifos 25), cada elemento tocável da prancha: chave do widget → destino → classe (✅/⏸/🟡) e a decisão
      (D-243 b, D-256…D-263). Fonte: os testes de toque que existem (`touch_home_test`, `touch_nav_test`,
      `toques_test` da T04, os testes de toque do leitor e da 25) e o código dos `onTap`.
- [ ] **(c) O mapa ao lado:** as ligações do `mapa_navegacao.json` que saem das telas prontas, cada uma com "no app:
      ✅ / ⏸ / 🟡 / ainda não (etapa)".
- [ ] **(d) Como chegar no celular:** passos para cada uma das 16 telas, no alvo (1) da D-267 (ex.: "21 · abrir o Dom
      Casmurro pelo 'Continuar lendo', segurar 'ressaca' até selecionar").
- [ ] Commit `docs: a NAVEGACAO.md — rotas, toques das telas prontas, o mapa e como chegar (R00.5)`.

## Tarefa 7 — O teste de navegação (R00.6, R5)

**Arquivos:** `test/support/navegacao.dart`, `test/app/navegacao_test.dart`, `integration_test/navegacao_test.dart`,
`test/design/navegacao_doc_test.dart`.

- [ ] **A lista** (`navegacao.dart`), uma entrada por toque documentado:
  ```dart
  enum Classe { leva, semAcao, placeholder }

  final class Ligacao {
    const Ligacao(this.origem, this.chave, this.classe, {this.destino, this.titulo, this.etapa, this.decisao});
    final String origem;     // 'inicio', 'leitor', 'grifos', 'shell'
    final String chave;      // a ValueKey do widget tocado
    final Classe classe;
    final Finder Function()? destino; // como achar a tela de destino (✅)
    final String? titulo;    // o título do placeholder (🟡)
    final String? etapa;     // a etapa que troca o placeholder (🟡)
    final String? decisao;   // a decisão do "sem ação" (⏸)
  }
  ```
      e o percurso `Future<List<String>> percorrer(WidgetTester tester, List<Ligacao> lista)`: para cada entrada, volta
      à origem, rola até a chave, toca; ✅ → `expect(destino(), findsOneWidget)` e volta; ⏸ → a rota e a árvore não
      mudam; 🟡 → acha o `PlaceholderScreen` com o título, guarda `"🟡 <origem> · <chave> → <título> (<etapa>)"` e volta.
      Devolve as linhas 🟡.
- [ ] **Na suíte** (`navegacao_test.dart`): o app inteiro (`abrirAppComLivro` com o mundo semeado em memória pela
      `semearMundo` da Tarefa 8 — se a Tarefa 8 ainda não existe, com o `domCasmurroEmLeitura`), as 4 abas pela barra,
      o FAB do scanner, depois `percorrer`; imprime os 🟡. Rodar → verde.
- [ ] **No celular** (`integration_test/navegacao_test.dart`): `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
      e o mesmo percurso sobre o banco semeado num diretório temporário do aparelho.
      `flutter test integration_test/navegacao_test.dart -d RXCT200CA6F` → verde; a lista dos 🟡 no relatório.
- [ ] **Documentação × prova** (`navegacao_doc_test.dart`): lê a tabela (b) da `NAVEGACAO.md` (chave, classe) e compara
      com a lista: toda linha documentada tem a entrada e vice-versa, com a mesma classe.
- [ ] Mutação: trocar a classe de uma entrada (✅ → ⏸) e o destino de outra → cada teste cai.
- [ ] Commit `test(navegacao): o percurso das telas prontas na suíte e no celular, e a NAVEGACAO.md conferida (R00.6)`.

## Tarefa 8 — Modo demonstração (R00.7, D-267, R6)

> Se D-267 = só (1): pular os passos do alvo (2). Só (2): pular os do alvo (1) e o relógio. "Não fazer agora": pular a
> tarefa; a Tarefa 9 usa o `main_mundo_referencia.dart` de hoje e as telas do leitor ficam com a observação.

**Arquivos:** `test/fixtures/demonstracao/{semear_mundo,relogio_demonstracao,overrides_demonstracao}.dart`,
`test/fixtures/main_demonstracao.dart`, `test/fixtures/{main_mundo_referencia,overrides_do_mundo}.dart`, os testes.

- [ ] **Teste da semeadura primeiro** (`test/fixtures/demonstracao/semear_mundo_test.dart`): num `AppDatabase` em
      memória e num diretório temporário, `semearMundo(db, livros: dir)`; depois: os livros, posições, sessões,
      marcadores, anotações, camadas de tinta, rótulos, ajustes, caneta e metas do `mundoReferencia` relidos pelos DAOs
      (contagens e ids); o arquivo do Dom Casmurro existe em `livros/` e o `LocalFilesDao.byBook` aponta para ele com
      o sha certo; o índice gravado tem `refPagesTotal = 256`; o dono ativo do `LocalLibrary` é o `usuarioId` do mundo;
      rodar duas vezes não duplica nada (a R6: só grava com o banco vazio, ou com `recomecar: true`, que apaga antes).
- [ ] **Escrever `semearMundo`:** `mundoReferencia.gravarEm(db)`; o EPUB `mundoEpub(Slugs.domCasmurro, completo: true)`
      gravado como `<id do livro>.epub` em `livros`; `LocalFilesDao(db).upsert(userBookId, path, bytes, sha256, now)`;
      o índice injetado das telas do leitor (`test/fixtures/telas/indice_t19.dart`) por `BookContentIndexDao(db).upsert`;
      o catálogo do aparelho com as páginas do Brás Cubas (`CatalogCacheDao.putBook`, como o `cronometro_papel_test`);
      `LocalLibrary(db).setActiveOwner(mundoReferencia.usuarioId)`. Sem `flutter_test` no arquivo (ele entra num app).
- [ ] **O relógio** (`relogio_demonstracao.dart`): `DateTime Function() relogioDemonstracao(DateTime inicio,
      {Stopwatch? cronometro})` = `inicio + cronometro.elapsed` (o `Stopwatch` começa na abertura). Teste: logo após
      criar devolve `inicio`; depois de `elapsed` X devolve `inicio + X` (com um `Stopwatch` falso).
- [ ] **Os overrides** (`overrides_demonstracao.dart`): `powerSyncDatabaseProvider` com o caminho
      `<suporte>/booknest_demo.db` (o mesmo corpo do provedor de produção, outro arquivo); `booksDirProvider` →
      `<suporte>/livros_demo`; `fileCoversDirProvider` → `<suporte>/capas_arquivo_demo`; `coverImagesProvider` com a
      pasta `<suporte>/capas_demo`; `clockProvider` → `relogioDemonstracao(HomeMockRepository.referenceNow)`;
      `secondTickerProvider` → `PeriodicSecondTicker()`; `brandStoreProvider` → `MemoryBrandStore()`.
- [ ] **O alvo (1)** (`main_demonstracao.dart`):
  ```dart
  // R00 (D-267) — o app de verdade sobre um banco só da demonstração, com o mundo de referência gravado; nunca na loja:
  //   flutter run --profile -t test/fixtures/main_demonstracao.dart [--dart-define=BOOKNEST_DEMO_RECOMECAR=true]
  Future<void> main() async {
    if (kReleaseMode) {
      throw StateError('O modo demonstração não roda em release (D-267).');
    }
    WidgetsFlutterBinding.ensureInitialized();
    await prepararBancoDemonstracao(
      recomecar: const bool.fromEnvironment('BOOKNEST_DEMO_RECOMECAR'),
    );
    await app.runBookNest(overrides: overridesDemonstracao);
  }
  ```
      `prepararBancoDemonstracao` abre o `booknest_demo.db`, chama `semearMundo` se ele estiver vazio (ou com
      `recomecar`) e fecha; nunca abre o `booknest.db`. Sem `--dart-define` de servidor: convidado (D-64).
- [ ] **O alvo (2)** (`main_mundo_referencia.dart`): o leitor e os grifos saem dos overrides que os deixam no "abrindo"
      (`leitorDoMundo`, `destaquesDoMundo`) e passam a abrir do banco da demonstração semeado; os ids que a Início da
      fixture usa (os slugs) chegam ao leitor pela tabela `mundoReferencia.slugs` (um `homeRepositoryProvider` que
      embrulha o `HomeMockRepository` e troca o id dos livros pelo da estante). Teste: na Início do alvo (2), o
      "Continuar lendo" abre o leitor no Dom Casmurro, pág. 159 de 256.
- [ ] **Testes de isolamento e privacidade:**
  - `sem_test_em_lib_test.dart`: nenhum arquivo de `lib/` importa `test/`, `integration_test/` ou `fixtures`
    (varre os `import`);
  - o demo com o interceptador do Supabase da T04 (`paper_timer_privacy_free_test` como modelo): abrir, ler,
    cronometrar → nenhum pedido ao Supabase;
  - o `prepararBancoDemonstracao` num diretório de suporte falso: cria só `booknest_demo.db` e as pastas `_demo`, e um
    `booknest.db` que já estava lá fica com os mesmos bytes;
  - a Início do alvo (1) sobre o banco semeado: os números do mundo (Dom Casmurro pág. 159 de 256 no herói, "18 de 30
    min", a sequência de 12 dias) e as diferenças conhecidas para a prancha listadas (D-247: sem o cartão da revisão;
    D-79: capa gerada; D-60/`t01_divergencias`).
- [ ] Rodar os testes da tarefa → verdes; `flutter analyze` 0.
- [ ] Commit `feat(demonstracao): o mundo de referência num banco só do demo, fora da loja (R00.7 · D-267)`.

## Tarefa 9 — Prova no celular (R00.8, R7)

**Arquivos:** `integration_test/capturas_r00_test.dart`, `test_driver/integration_test.dart`,
`tools/celular/capturar_r00.py`, `docs/progresso/R00_celular.md`, `docs/progresso/R00_celular/*.png`.

- [ ] **O roteiro no aparelho** (`capturas_r00_test.dart`): sobe o alvo (1) já semeado (`prepararBancoDemonstracao`
      com `recomecar: true` + `runBookNest(overrides: overridesDemonstracao)`), e para cada tela leva o app ao estado da
      prancha com gestos de verdade e imprime `R00CAP <nn>` e espera 6 s parado (o gesto da 24 fica segurado no meio
      do arrasto durante a espera):
      01 Início no topo · 60 Início rolada até o "Seu dia" · 01b o play do Brás Cubas, 8 min 42 s andados no relógio
      do demo · 19 o "Continuar lendo" · 20 toque no meio · 21 segurar uma palavra do "Olhos de ressaca" · 22 "Anotar"
      · 23 a caneta · 23b o marca-texto · 24 arrastar entre parágrafos, segurado · 24b a nota à mão do mundo · 25 o
      botão Grifos · 26 "Fonte" · 26b o Tema Noite com os controles · 27 "Sumário" · 27b a aba Marcadas.
      `test_driver/integration_test.dart` = o `integrationDriver()` padrão.
- [ ] **O script do computador** (`capturar_r00.py`): roda
      `flutter drive --profile --driver=test_driver/integration_test.dart --target=integration_test/capturas_r00_test.dart -d RXCT200CA6F`,
      lê a saída linha a linha e, em cada `R00CAP nn`, roda `adb exec-out screencap -p` para
      `docs/progresso/R00_celular/<nn>_celular.png`; no fim monta `<nn>_lado_a_lado.png` (a captura e o PNG da prancha
      — `docs/design/medicao/inicio2/png/` para 01/01b/60 e o da G01 para o leitor — na mesma altura, com o título
      embaixo) com o Pillow. Falha se faltar alguma das 16.
- [ ] **Rodar** `PYTHONIOENCODING=utf-8 python3 tools/celular/capturar_r00.py` → 16 capturas + 16 lado a lado. Com o
      alvo (2), as 3 da Início também (`<nn>_prancha_celular.png`), para mostrar a Início igual à prancha.
- [ ] **`R00_celular.md`:** o aparelho (modelo, Android, 384 × 832 lógicos), o build (comando, perfil), a tabela das 16
      (captura, lado a lado, o que difere e a decisão que explica — a largura de 384, D-247, D-79, D-60), o "como
      chegar" e os comandos.
- [ ] **Devolver o celular:** `flutter install` do app normal (`lib/main.dart`, perfil release ou o que estava) e
      conferir que os dados do Cesar continuam (o `booknest.db` não foi aberto pelo demo).
- [ ] Commit `docs(progresso): R00 — as 16 telas prontas no Galaxy S22+, lado a lado com as pranchas (R00.8)`.

## Tarefa 10 — Documentos, verificação e relatório (R00.9)

- [ ] `docs/design/LEIA-ME.md`: o `support.js` = `dc-runtime.js`; a conferência (35/35) e o comando; a `COBERTURA.md` e
      o `mapa_navegacao.json`.
- [ ] ROTEIRO: §3 (as 9 telas da D-268 nas linhas das etapas, entre parênteses, "+ as faltando: …"); §7 com os itens
      marcados; §6b (Tarefa 3).
- [ ] `COBERTURA.md`: conferir as 16 ✅ e o resumo.
- [ ] Memória: a pendência de ambiente da F12 (sem JDK, sem aparelho) encerrada — o JDK 17 e o S22+ por USB.
- [ ] **§7:** `dart format .` (sem mudanças) · `flutter analyze` (0) · `flutter test` inteira · os scripts da R00 de
      novo (35/35, o mapa, a cobertura) · gitleaks nos commits da etapa (`main..HEAD`) · `git status` limpo.
- [ ] **Revisão independente** (só leitura, do diff da etapa) e mutação nas regras com código (R2, R3, R5, R6).
- [ ] `STATUS.md`: última etapa 5 · R00 (commit), próxima ▶ 6 · T13, o que mudou no celular (o modo demonstração), a
      branch, o histórico.
- [ ] `R00.md`: Resultados, Desvios, Pendências, Commits, checklist marcado. Relatório (modelo do prompt mestre §9)
      terminando com `✅ ETAPA 5 · R00 concluída — aguardando sua aprovação para a ETAPA 6 · T13.` **PARAR.**
- [ ] Depois da aprovação: `git checkout main && git merge --ff-only feat/r00-arrumacao && git push origin main`.
