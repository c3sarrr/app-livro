# G15 — Sumário e Marcadas (telas 27 e 27b): plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha no
> Windows (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.

**Objetivo:** a folha do sumário com as abas Capítulos (27) e Marcadas (27b), funcionando com o livro de verdade e
idêntica às pranchas.

**Arquitetura:**
- Os numerais são lidos na importação (`toc_labels.dart`, puro, no isolate) e guardados no índice.
- Uma função pura (`buildTocView`) monta tudo o que a folha mostra a partir do índice, da posição, das anotações,
  dos marcadores e do clube.
- Um `ReaderToc` (ChangeNotifier, como o `ReaderChrome`) lê o banco e relê a cada escrita.
- A `TocSheet` só desenha.
- A tela liga a ferramenta Sumário, os saltos (`jumpTo`) e a fita (`setBookmark`).

**Pilha:** Flutter/Dart, drift (SQLite), flutter_test, goldens @3x, `tools/compare_images.py`.

**Espelho e execução:**
- Código no espelho `/home/claude/g03/repo`. Cada ciclo vai ao PC por `./ciclo.sh <arquivos>` → `SendUserFile` →
  `device_commit_files` → `expandir.ps1`.
- Testes no Windows:
  - um arquivo: `rodar.ps1 -Nome X -Cmd "flutter test <arquivo>"`;
  - a suíte: `suite.ps1`.
- Commits por `commits_g15x.ps1` com `msg_g15_NN.txt`.
- Spec: `docs/progresso/G15.md` (D-149…D-154).

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `lib/features/reader/content/toc_labels.dart` (novo) | numeral e título de uma entrada (rótulo; bloco do texto) | 1 |
| `lib/features/reader/content/book_index.dart` | `TocPoint.textNumeral`, JSON, `tocUpToDate`, `buildEpubIndex` | 2 |
| `lib/features/reader/application/reader_session_controller.dart` | refaz índice velho; `setBookmark`; deps do clube e do fuso | 3, 5, 6 |
| `lib/features/library/application/book_importer.dart` | `indexBook`/`indexPending` refazem índice velho | 3 |
| `test/support/mundo_epub.dart` | `nav` do mundo com numerais e sem a folha de rosto | 4 |
| `test/fixtures/telas/indice_t27.dart` (novo) | índice injetado da tela 27 (páginas do sumário, 41 %) | 4 |
| `lib/core/data/model/record_meta.dart` | `restored` | 5 |
| `lib/core/data/database/daos/reader_daos.dart` | `BookmarksDao.byId` | 5 |
| `lib/features/reader/application/reader_club_source.dart` (novo) | fonte do clube (vazia até a G21) | 6 |
| `lib/features/reader/application/toc_view.dart` (novo) | `buildTocView` (puro) | 7 |
| `lib/features/reader/application/reader_toc.dart` (novo) | lê o banco, relê, guarda os tirados | 8 |
| `pubspec.yaml`, `app_typography.dart`, `app_icons_leitor.dart`, `app_colors.dart` | Literata 16 e 15,5, ícones, cores e estilos | 9 |
| `lib/features/reader/presentation/toc_sheet.dart` (novo) | moldura, véu, alça, cabeçalho, abas | 10 |
| `lib/features/reader/presentation/toc_chapters.dart` (novo) | faixa, lista, linhas, atual com anel, partes, vazio | 11 |
| `lib/features/reader/presentation/toc_bookmarks.dart` (novo) | cartões, fita, dica | 12 |
| `lib/features/reader/presentation/reader_screen.dart` | abrir, fechar, Voltar, saltos, aviso, PDF | 13 |
| `test/support/fase_l27.dart`, `l27_test.dart`, `l27b_test.dart`, `leitor_27*_test.dart` (novos) | fases e goldens | 14, 15 |

---

### Tarefa 1: numeral e título de uma entrada (`toc_labels.dart`)

**Arquivos:** criar `lib/features/reader/content/toc_labels.dart`; teste
`test/features/reader/content/toc_labels_test.dart`.

- [ ] **Passo 1 (RED):**

```dart
// G15.1 (D-150) — o numeral do capítulo como no livro.
import 'package:app_leitura/features/reader/content/toc_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rótulo do sumário', () {
    test('numeral + separador + título', () {
      expect(tocLabel('XXXII. Olhos de ressaca'), (numeral: 'XXXII', title: 'Olhos de ressaca'));
      expect(tocLabel('XXXII — Olhos de ressaca'), (numeral: 'XXXII', title: 'Olhos de ressaca'));
      expect(tocLabel('32) Olhos'), (numeral: '32', title: 'Olhos'));
      expect(tocLabel('IV: A ópera'), (numeral: 'IV', title: 'A ópera'));
      expect(tocLabel('1 - Um'), (numeral: '1', title: 'Um'));
      expect(tocLabel('Capítulo 32 — Olhos de ressaca'), (numeral: '32', title: 'Olhos de ressaca'));
      expect(tocLabel('CAPÍTULO XXXII. Olhos'), (numeral: 'XXXII', title: 'Olhos'));
      expect(tocLabel('Chapter 4: Title'), (numeral: '4', title: 'Title'));
    });
    test('sem título depois do número: o rótulo fica como título, sem numeral', () {
      expect(tocLabel('XXXII'), (numeral: null, title: 'XXXII'));
      expect(tocLabel('Capítulo 1'), (numeral: null, title: 'Capítulo 1'));
    });
    test('romano só válido e em maiúsculas; palavra não é número', () {
      expect(tocLabel('CIVIL. Guerra').numeral, isNull);
      expect(tocLabel('IIII. Quatro').numeral, isNull);
      expect(tocLabel('xxxii. Olhos').numeral, isNull);
      expect(tocLabel('I, Robô').numeral, isNull);
      expect(tocLabel('Do titulo.'), (numeral: null, title: 'Do titulo'));
    });
    test('um ponto final sai; reticências, ! e ? ficam', () {
      expect(tocLabel('Olhos de ressaca.').title, 'Olhos de ressaca');
      expect(tocLabel('E bem, e o resto?').title, 'E bem, e o resto?');
      expect(tocLabel('Um dever amarissimo!').title, 'Um dever amarissimo!');
      expect(tocLabel('Enfim...').title, 'Enfim...');
      expect(tocLabel('  Muitos   espaços. ').title, 'Muitos espaços');
    });
    test('numeral do texto: vale quando o rótulo não tem; não repete no título', () {
      expect(tocLabel('Olhos de ressaca.', textNumeral: 'XXXII'), (numeral: 'XXXII', title: 'Olhos de ressaca'));
      expect(tocLabel('XXXII Olhos de ressaca', textNumeral: 'XXXII'), (numeral: 'XXXII', title: 'Olhos de ressaca'));
      expect(tocLabel('V. O agregado', textNumeral: 'X'), (numeral: 'V', title: 'O agregado'));
    });
  });

  group('numeral no texto', () {
    test('o bloco logo antes da entrada (Gutenberg)', () {
      const t = 'fim do anterior.\n￼\nXXXII\nOlhos de ressaca.\nTudo era materia';
      expect(headingNumeral(t, t.indexOf('Olhos')), 'XXXII');
    });
    test('o bloco na entrada, pulando a imagem', () {
      const t = 'antes.\n￼\nCapítulo 7.\nTítulo\nTexto';
      expect(headingNumeral(t, t.indexOf('￼')), '7');
      const u = 'XXXII Olhos de ressaca\nTexto';
      expect(headingNumeral(u, 0), 'XXXII');
    });
    test('sem número perto: nada', () {
      const t = 'MACHADO DE ASSIS\nDA ACADEMIA BRAZILEIRA\nB. L. GARNIER';
      expect(headingNumeral(t, t.indexOf('DA ACADEMIA')), isNull);
      expect(headingNumeral('Texto corrido sem número.', 0), isNull);
      expect(headingNumeral('', 0), isNull);
      expect(headingNumeral('abc', 99), isNull);
    });
  });
}
```

Run: `flutter test test/features/reader/content/toc_labels_test.dart`. Esperado: FAIL (o arquivo não existe).

- [ ] **Passo 2 (GREEN):**

```dart
// G15.1 (D-150) — o numeral do capítulo como no livro: do rótulo do sumário ("XXXII. Olhos de ressaca", "Capítulo 32
// — Olhos de ressaca") ou, quando o rótulo não tem, do título do capítulo no texto quando ele é só um número (o
// Gutenberg põe "XXXII" num bloco logo antes de "Olhos de ressaca."). Romano só em maiúsculas e válido ("CIVIL" não é
// número). O título perde um ponto final. Puro: roda no isolate da importação.

/// O numeral (ou nada) e o título de uma entrada do sumário para a tela 27.
typedef TocLabel = ({String? numeral, String title});

const String _roman =
    '(?=[MDCLXVI])M{0,3}(?:CM|CD|D?C{0,3})(?:XC|XL|L?X{0,3})(?:IX|IV|V?I{0,3})';
const String _number = '(?:$_roman|[0-9]{1,4})';
const String _prefix =
    r'(?:[Cc]ap[íi]tulo|CAP[ÍI]TULO|[Cc]ap\.|CAP\.|[Cc]hapter|CHAPTER)';

final RegExp _prefixed = RegExp('^$_prefix\\s+($_number)\\s*[.:—–-]\\s*(.+)\$');
final RegExp _numbered = RegExp('^($_number)(?:[.):]|\\s+[—–-])\\s+(.+)\$');
final RegExp _alone = RegExp('^(?:$_prefix\\s+)?($_number)\\.?\$');
final RegExp _spaces = RegExp(r'\s+');

TocLabel tocLabel(String label, {String? textNumeral}) {
  final t = label.replaceAll(_spaces, ' ').trim();
  final m = _prefixed.firstMatch(t) ?? _numbered.firstMatch(t);
  if (m != null) return (numeral: m.group(1), title: tocTitle(m.group(2)!));
  if (textNumeral != null) {
    final rest = t.startsWith('$textNumeral ')
        ? t.substring(textNumeral.length + 1)
        : t;
    return (numeral: textNumeral, title: tocTitle(rest));
  }
  return (numeral: null, title: tocTitle(t));
}

/// O título como a folha mostra: espaços juntados e um ponto final a menos ("…", "!" e "?" ficam).
String tocTitle(String label) {
  final s = label.replaceAll(_spaces, ' ').trim();
  if (s.endsWith('.') && !s.endsWith('..')) {
    final c = s.substring(0, s.length - 1).trimRight();
    if (c.isNotEmpty) return c;
  }
  return s;
}

/// O numeral do capítulo no texto canônico [text] de um item, perto da entrada em [offset]: o bloco onde ela começa
/// ou o bloco logo antes (blocos separados por `\n`; U+FFFC e vazios pulados), quando ele é só um número.
String? headingNumeral(String text, int offset) {
  if (offset < 0 || offset > text.length || text.isEmpty) return null;
  final start = offset == 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;
  // o bloco da entrada, pulando os vazios para a frente
  var at = start;
  while (at <= text.length) {
    final end = _endOf(text, at);
    final b = text.substring(at, end);
    if (!_blank(b)) {
      final n = _numeralOf(b);
      if (n != null) return n;
      break;
    }
    if (end >= text.length) break;
    at = end + 1;
  }
  // o bloco antes, pulando os vazios para trás
  var end = start - 1;
  while (end > 0) {
    final s = text.lastIndexOf('\n', end - 1) + 1;
    final b = text.substring(s, end);
    if (!_blank(b)) return _numeralOf(b);
    end = s - 1;
  }
  return null;
}

int _endOf(String text, int from) {
  final e = text.indexOf('\n', from);
  return e < 0 ? text.length : e;
}

bool _blank(String b) => b.replaceAll('￼', '').trim().isEmpty;

String? _numeralOf(String block) {
  final line = block.split(' ').first.replaceAll(_spaces, ' ').trim();
  if (line.length > 24) return null;
  return _alone.firstMatch(line)?.group(1);
}
```

- [ ] **Passo 3:** o teste passa. Commit `feat(leitor): numeral e título de uma entrada do sumário (D-150)`.

### Tarefa 2: o índice guarda o numeral do texto

**Arquivos:**
- `lib/features/reader/content/book_index.dart`;
- teste: `test/features/reader/content/book_index_test.dart` (novos testes no grupo "índice de um EPUB" e um teste do
  Gutenberg).

- [ ] **Passo 1 (RED):**
  - **EPUB montado:**
    - o `nav` aponta "Olhos de ressaca." para o `h4` de um capítulo cujo corpo é
      `<h5>XXXII</h5><h4 id="t">Olhos de ressaca.</h4><p>Tudo.</p>`;
    - um segundo capítulo tem o rótulo "V. O agregado";
    - um terceiro é "Prefácio", sem número.
  - **Esperado:** `textNumeral` = `'XXXII'`, `null` (o rótulo já tem) e `null`.
  - **`tocJson`:** tem a chave `text_numeral` em cada entrada; `fromColumns` volta com o valor e
    `tocUpToDate == true`.
  - **JSON sem a chave** (índice de antes): `tocUpToDate == false` no EPUB e `true` no PDF (`layout: 'pdf'`) ou sem
    sumário (`[]`).
  - **Gutenberg** (`indexEpubFile`):
    - as entradas 2…149 (as folhas 2 a 149) têm `tocLabel(title, textNumeral:).numeral` igual a I, II, …, CXLVIII
      (conversão romana no teste);
    - as entradas 0, 1, 150, 151 e 152 (rosto, academia, FIM, INDICE, licença) ficam sem numeral.
- [ ] **Passo 2 (GREEN):**
  - `TocPoint` ganha `final String? textNumeral` (opcional no construtor, comparado em lugar nenhum — é dado);
  - `tocJson` grava `'text_numeral': t.textNumeral`;
  - `fromColumns` lê `t['text_numeral'] as String?` e calcula
    `tocUpToDate = layout == 'pdf' || toc.every((t) => (t as Map).containsKey('text_numeral'))`;
  - `BookIndex` ganha `final bool tocUpToDate` (padrão `true`, `const`);
  - `buildEpubIndex`: para cada entrada com lugar, se `tocLabel(e.title).numeral == null`, então
    `textNumeral: headingNumeral(items[at.$1].text, at.$2)`.
- [ ] **Passo 3:** verdes, inclusive os testes antigos do índice. Commit
  `feat(leitor): índice guarda o numeral do capítulo lido no texto (D-150)`.

### Tarefa 3: índices de antes da G15 são refeitos uma vez

**Arquivos:**
- `reader_session_controller.dart` (`_openEpub`);
- `book_importer.dart` (`indexBook`, `indexPending`);
- testes:
  - `test/features/reader/application/reader_session_controller_test.dart` (ao lado do teste do `ref_page_version`);
  - `test/features/library/book_importer_test.dart`.

- [ ] **Passo 1 (RED):**
  - **Sessão:** com um índice gravado cujo `toc_json` não tem `text_numeral` (`UPDATE book_content_index SET toc_json =
    '[{"title":"I","spine":1,"offset":0,"depth":0,"leaf":true}]'`):
    - abrir chama `deps.indexBook` uma vez, mostrando "preparando";
    - abrir de novo com o índice novo não chama.
  - **Importação:**
    - `indexBook` com o índice velho refaz e devolve `true`;
    - `indexPending` conta esse livro;
    - um índice novo não é refeito.
- [ ] **Passo 2 (GREEN):**
  - `_openEpub`: `|| !index.tocUpToDate` na condição;
  - `indexBook`: o retorno antecipado exige `current.tocUpToDate`;
  - SQL do `indexPending`: `OR (i.toc_json LIKE '[{%' AND instr(i.toc_json, '"text_numeral"') = 0)`.
- [ ] **Passo 3:** verdes. Commit `feat(leitor): índices de antes da G15 são refeitos uma vez (D-154)`.

### Tarefa 4: o mundo de referência com o sumário do livro

**Arquivos:**
- `test/support/mundo_epub.dart`;
- criar `test/fixtures/telas/indice_t27.dart`;
- testes:
  - `test/features/reader/content/mundo_epub_test.dart`;
  - criar `test/fixtures/telas/indice_t27_test.dart`.

- [ ] **Passo 1 (RED):**
  - **`mundo_epub_test`:** o índice do mundo completo tem 148 entradas, com o rótulo
    `'${s.numeral}. ${s.titulo}'` de `sumarioDomCasmurro`; a entrada c aponta para o item c + 1, posição 0.
  - **`indice_t27_test`** (`indiceDaTela27(indiceReal)`):
    - `tocStartPages` = as páginas do `sumarioDomCasmurro`;
    - 256 páginas;
    - a posição (item 32, 0) dá pág. 159 e capítulo 31;
    - o progresso no cap. XXXII = 18/44 ± 0,001.
- [ ] **Passo 2 (GREEN):**
  - **`mundoEpub`:** passa `navBody` com só os capítulos (sem a folha de rosto). No Dom Casmurro o rótulo é
    `'${s.numeral}. ${s.titulo}'`; nos outros livros, `'Capítulo ${c + 1}'`, escapados.
  - **`indiceDaTela27(BookIndex real)`:**
    - parte de `indiceDaTela19(real)` (a mesma régua e as mesmas páginas);
    - troca o sumário: o capítulo c começa em `G_c = (p_c − 1) × 1500 + 300 × k`, com k = capítulos anteriores na
      mesma página;
    - no cap. XXXII, `G_31 = 156 × 1500 + 357`, que dá (237.893 − G_31) ÷ (G_32 − G_31) ≈ 18/44;
    - converte com `spineAt(G_c)` e mantém título e folha.
- [ ] **Passo 3:** rodar os testes que usam o mundo (`l19`/`l20`/`l21`/`l26`/`l26b`, goldens 19–26b, `mundo_*`): a
  página e as âncoras não mudam (o texto é o mesmo). Commit
  `test(leitor): mundo de referência com o sumário do livro e o índice da tela 27`.

### Tarefa 5: tirar e devolver a mesma marca

**Arquivos:**
- `record_meta.dart` (`restored`);
- `reader_daos.dart` (`BookmarksDao.byId`, com os apagados);
- `reader_session_controller.dart` (`setBookmark`);
- testes:
  - `test/core/data/model/value_semantics_test.dart`;
  - `test/core/data/database/daos_test.dart`;
  - `reader_session_controller_test.dart` (grupo G15).

- [ ] **Passo 1 (RED):**
  - **`meta.restored(at, v)`:** `deletedAt == null`, `updatedAt == at`, `version == v` e `createdAt` igual;
  - **`byId`:** devolve também a linha apagada;
  - **`setBookmark(b, on: false)`:** grava o tombstone com versão maior, e `forBook` não tem mais a marca;
  - **`on: true`:** a mesma linha volta (id, `createdAt`, excerpto, página iguais) com versão maior;
  - chamar `on: false` numa já tirada não grava nada;
  - falha do banco vai para `onError` e nada muda.
- [ ] **Passo 2 (GREEN):**

```dart
  /// A fita da aba Marcadas (D-152): tira ([on] falso) ou devolve a marca [b] — a mesma linha, com o mesmo excerto e
  /// a mesma data; lida de novo no banco na hora de gravar (pode ter vindo de outro aparelho).
  Future<void> setBookmark(Bookmark b, {required bool on}) {
    if (_closed) return Future.value();
    interaction();
    return _serial(() async {
      try {
        final dao = BookmarksDao(deps.db);
        await deps.versioning.write('bookmarks', b.id, (v) async {
          final cur = await dao.byId(b.id) ?? b;
          if (cur.meta.isDeleted != on) return;
          final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
          await dao.upsert(
            cur.copyWith(
              meta: on ? cur.meta.restored(at, v) : cur.meta.deleted(at, v),
            ),
          );
        });
      } on Object catch (e, st) {
        deps.onError(e, st);
      }
    });
  }
```

  `RecordMeta.restored(at, v) => copyWith(updatedAt: at, deletedAt: const Nullable(null), version: v);`.
  `BookmarksDao.byId` lê sem o filtro de `deletedAt`.
- [ ] **Passo 3:** verdes. Commit `feat(leitor): tirar e devolver a mesma marca (D-152)`.

### Tarefa 6: fonte do clube e fuso nas dependências do leitor

**Arquivos:**
- criar `lib/features/reader/application/reader_club_source.dart`;
- `ReaderDeps` (`club`, `utcOffsetAt`);
- `test/support/reader_harness.dart` (parâmetros `club`, `utcOffsetAt`);
- teste: `test/features/reader/application/reader_club_source_test.dart`.

- [ ] **Passo 1 (RED):** `const NoReaderClub().goalFor('u', 'b')` dá `null`; `ReaderDeps(...)` tem `club` = `NoReaderClub`
  e `utcOffsetAt(t) == t.toLocal().timeZoneOffset` por padrão.
- [ ] **Passo 2 (GREEN):**

```dart
// G15.2 (D-149) — o clube que lê este livro, para a faixa do sumário (tela 27): nome, próximo encontro e a meta em
// capítulo (contado de 1). A G21 liga aos clubes; até lá, nenhum (a faixa some — como o ticket da Início, D-80).
typedef ReaderClubGoal = ({String name, DateTime? nextMeeting, int goalChapter});

abstract interface class ReaderClubSource {
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId);
}

final class NoReaderClub implements ReaderClubSource {
  const NoReaderClub();

  @override
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId) async => null;
}

/// O deslocamento do fuso do aparelho no instante [utc].
Duration readerUtcOffset(DateTime utc) => utc.toLocal().timeZoneOffset;
```

  `ReaderDeps`: `this.club = const NoReaderClub()`, `this.utcOffsetAt = readerUtcOffset`.
- [ ] **Passo 3:** verdes. Commit `feat(leitor): fonte do clube do livro, vazia até a G21 (D-149)`.

### Tarefa 7: `buildTocView` — tudo o que a folha mostra

**Arquivos:** criar `lib/features/reader/application/toc_view.dart`; teste
`test/features/reader/application/toc_view_test.dart`.

Tipos:

```dart
enum TocRowKind { part, chapter }

final class TocRow {
  // kind, entry (índice no sumário), chapter (folha; null na parte), numeral, title (parte em maiúsculas), page,
  // marks (ChapterMarks), marksLabel ("1 marca" / "N marcas"), read, current, progress (0…1), target (ReaderMark?)
}

final class TocClubStrip { final String kicker; final String goal; }

final class TocBookmarkCard {
  // bookmark, marked, page, chapter ("cap. I · Do título" | título | null), here, excerpt, date, target
}

final class TocView {
  // subtitle, chapters (int? — nulo sem sumário), bookmarks (vivos), rows, currentRow (int?), refPage, club, cards
}

TocView buildTocView({
  required String bookTitle,
  required BookIndex? index,
  required ReaderMark at,
  required int refPage,
  required List<Annotation> annotations,
  required List<Bookmark> bookmarks,
  List<Bookmark> removed = const [],
  ReaderClubGoal? club,
  required DateTime now,
  required Duration Function(DateTime utc) utcOffsetAt,
});
```

- [ ] **Passo 1 (RED):** um índice montado à mão.
  - **Montagem:** `BookIndex`; `spine` de 3 itens de 3.000 caracteres; `refPages` sintéticas a cada 1.500;
    sumário:
    - "Parte I", não folha, (0, 0);
    - "I. Um", (0, 0);
    - "II. Dois", (1, 0);
    - "Sem lugar", sem item;
    - "III. Três", (2, 0).
  - **Linhas e posição:**
    - posição (1, 750): a parte em maiúsculas, sem página;
    - "I" lido;
    - "II" atual com progresso 0,25;
    - "Sem lugar" sem página, sem alvo, sem "lido";
    - "III" não lido;
    - páginas 1, 3, nulo e 5;
    - `currentRow` = 2.
  - **Bordas da posição:**
    - posição antes do 1º capítulo: nenhum atual, nada lido;
    - posição no fim do livro: o último é atual com progresso 1.
  - **Marcas:** "1 marca" e "3 marcas", com os símbolos de `chapterMarks`; uma anotação apagada não conta.
  - **Cabeçalho e abas:** "Livro · 3 capítulos" e "1 capítulo"; sem sumário: `chapters` nulo e o título sozinho.
  - **Faixa do clube:**
    - "LEITORAS DE CAPITU · QUI 24/9" com o encontro de 24/09/2026 23:00 UTC e o fuso −3 h;
    - meta 3 com o atual II → "Até o cap. III · falta 1";
    - meta 2 → "Até o cap. II";
    - meta 9 → "Até o cap. 9 · faltam 7";
    - sem encontro: só o nome;
    - sem clube: nula.
  - **Marcadas:**
    - na ordem do livro, com a página e "cap. I · Um";
    - sem numeral: só o título;
    - `here` na página atual;
    - "marcada hoje" no mesmo dia local, mesmo depois da meia-noite UTC;
    - "marcada em 2 set";
    - "marcada em 2 set 2025";
    - o tirado nesta abertura aparece com `marked: false`;
    - o vivo vence o tirado;
    - alvo do `EpubLocator` (item, posição), do `PdfLocator` (0, página) e do `RawLocator` nulo.
  - **PDF** (`layout: 'pdf'`, `refPages: RefPageMap.pdf(10)`, sumário com página 0 e 4, posição (0, 6)):
    - páginas 1 e 5;
    - o primeiro lido;
    - o segundo atual com progresso 2/6.
- [ ] **Passo 2 (GREEN):** a implementação da seção 2 da spec:
  - começos: `globalOffset` no EPUB e a página no PDF;
  - fim de cada folha: o começo da próxima folha com lugar, numa passada de trás para a frente; no último, o fim do
    livro;
  - marcas: `chapterMarks` sobre as anotações agrupadas por capítulo;
  - faixa: a meta pelo numeral da linha da meta;
  - datas: no fuso de `utcOffsetAt`, com os meses `jan fev mar abr mai jun jul ago set out nov dez` e os dias
    `SEG TER QUA QUI SEX SÁB DOM`.
- [ ] **Passo 3:** verdes. Commit `feat(leitor): o que a folha do sumário mostra, a partir dos dados (D-150…D-154)`.

### Tarefa 8: `ReaderToc` — lê o banco e relê

**Arquivos:** criar `lib/features/reader/application/reader_toc.dart`; teste
`test/features/reader/application/reader_toc_test.dart` (banco em memória, como o do `ReaderChrome`).

- [ ] **Passo 1 (RED):**
  - **Leitura:** depois da 1ª leitura, `view` tem as linhas do índice gravado e os cartões dos marcadores.
  - **Releitura:**
    - gravar um marcador → `view` muda e avisa;
    - tirar um marcador depois de `keep(b)` → o cartão fica com `marked: false`;
    - devolver → `marked: true`.
  - **Clube:** com a fonte de teste → `view.club` existe; a fonte que lança → `onError` e a faixa some.
  - **Ciclo de vida:** `dispose` para de ouvir.
- [ ] **Passo 2 (GREEN):**
  - como o `ReaderChrome`: `tableUpdates` em `bookmarks` e `annotations`, e geração contra respostas velhas;
  - o índice e o clube são lidos uma vez;
  - `place()` dá a marca e a página atuais;
  - `keep(b)` guarda o marcador tirado.
- [ ] **Passo 3:** verdes. Commit `feat(leitor): dados da folha do sumário lidos do banco e relidos a cada escrita`.

### Tarefa 9: fontes, ícones, cores e estilos da folha

**Arquivos:**
- `pubspec.yaml` (famílias `Literata16` e `Literata15_5`, com `Ext` e `Vi`, peso 400);
- `app_typography.dart`:
  - `literataStatic` ganha 16: {400} e 15.5: {400};
  - estilos `readerToc*` (título Bricolage 26/800 ls −0,6; subtítulo 13/600; abas 14/800 e 14/700; faixa 11/800 ls
    0,8 e 15/800; numeral 12/800 ls 0,5; título Literata 16 lh 1,25; atual Literata 17/500; página 13/700 tnum;
    marcas 11,5/800; pílula 11,5/800; parte 11/800 ls 0,8; vazio 14/600; Marcadas: pág. 12,5/800 tnum, cap. 12/700,
    aqui 11/800, excerto Literata 15,5 lh 1,5, data 11,5/700, dica 13/600 lh 1,45);
- `app_icons_leitor.dart`: `flag`, `chevronRight`, `ribbonCoral`, `ribbonTiny`, `ribbonHint` (o `ic_ribbon`),
  `checkRead` e `pencilCoral`;
- `app_colors.dart`: `clubKicker` `#5B3A3E` e `tocRule` `#E3D8C4`;
- teste `test/design_system/fontes_leitor_g15_test.dart`:
  - as famílias no `FontManifest.json`;
  - a largura de "Olhos de ressaca" em Literata 17/500 e de "As curiosidades de" em Literata 16 contra a L27, dentro
    de 0,05;
  - os ícones carregam.

- [ ] RED → GREEN (`tocar.ps1` depois do `pubspec`) → commit
  `feat(design): Literata 16 e 15,5, ícones e estilos do sumário (G15)`.

### Tarefa 10: a moldura da folha (`toc_sheet.dart`)

**Arquivos:** criar `lib/features/reader/presentation/toc_sheet.dart`; teste
`test/features/reader/presentation/toc_sheet_test.dart`.

```dart
class TocSheet extends StatefulWidget {
  const TocSheet({
    super.key,
    required this.open,
    required this.view,           // nulo antes da 1ª leitura: só moldura e abas
    required this.palette,        // ReaderChromePalette (Noite — D-154)
    required this.brand,
    required this.onClose,
    required this.onChapter,      // ValueChanged<TocRow>
    required this.onBookmark,     // ValueChanged<TocBookmarkCard> — abrir
    required this.onRibbon,       // ValueChanged<TocBookmarkCard> — tirar/devolver
    this.onClub,
  });
}
```

- **Estado:** a aba (volta para Capítulos a cada abertura), o arrasto e a última `TocView` (para descer com o
  conteúdo depois de fechar).
- **Animação:** `TweenAnimationBuilder` de 150 ms (`readerFade`). O véu `Color(0x471A1714)` vai a 28 % × a.
- **Folha:** `left/right 10`, `top 112`, `bottom readerSheetBottom(pad)`; desce `(1 − a) × (altura + 4)` mais o
  arrasto.
- **Fechar:** a regra de soltura da G14 (`readerSheetDismissDrag`, `readerSheetDismissVelocity`); o toque no véu
  fecha.
- **Semântica:**
  - `Semantics(container, scopesRoute, namesRoute, label: 'Sumário')`;
  - `BlockSemantics` aberta e `ExcludeSemantics` fechada.
- **Cabeçalho:**
  - alça 40×5 (`palette.dash`), 8;
  - "Sumário" (cabeçalho) e o subtítulo;
  - × 44 (`p.well`).
- **Abas** (`toc.sheet.tabs.*` / `bm.sheet.tabs.*`, conforme a aba): 46, padding 3, duas colunas com gap 3,
  `Semantics(selected:, button)` e um `Semantics(role: tablist)` em volta.

Testes:
- abre e fecha em 150 ms;
- × e o véu chamam `onClose`;
- arrastar 64 fecha e o empurrão para cima não fecha;
- a aba troca e volta a Capítulos ao reabrir;
- no Noite: as cores das ilhas;
- semântica do diálogo e das abas;
- sem `view`, só a moldura.

- [ ] RED → GREEN → commit `feat(leitor): folha do sumário com abas (telas 27/27b)`.

### Tarefa 11: a aba Capítulos (`toc_chapters.dart`)

**Arquivos:** criar `lib/features/reader/presentation/toc_chapters.dart`; teste
`test/features/reader/presentation/toc_chapters_test.dart`.

- **Faixa** (`toc.sheet.club.*`), com as medidas da seção 3 da spec. A seta chama `onClub`.
- **Lista** (`toc.sheet.chapters`):
  - `ShaderMask` com o gradiente transparente→preto de 0 a 22 e preto→transparente nos 40 de baixo;
  - dentro, `Positioned(top: −6)` com `SingleChildScrollView(controller)` e `Column` das linhas.
- **Linha** (`toc.sheet.chapters.ch{n}`, n = folha + 1): `.link`, `.numeral`, `.title`, `.marks` (`.highlight`,
  `.note`, `.ink`, `.handwritten`), `.page`, `.read` e `.status`.
- **Atual** (`.progressRing` com `CustomPainter`, `.youAreHere` com `.icon`). O anel desenha o trilho e um arco
  `progress × 2π` a partir de −π/2, com ponta redonda; com 0, só o trilho.
- **Parte** (`toc.sheet.chapters.part{e}`).
- **Vazio** (`toc.sheet.empty`).
- **Altura inicial:** na 1ª montagem (pós-frame), `jumpTo(clamp(max(top − 378.4, top + h + 40 − viewport), 0,
  max))`, com `top`/`h` do cartão atual medidos pelo `RenderBox`.
- **Semântica:**
  - o botão da linha: "XXV, No Passeio Público, página 121";
  - "lido";
  - "1 marca";
  - o atual com "lendo" e "você está na pág. 159";
  - a parte é cabeçalho.

Testes (com uma `TocView` montada à mão):
- as linhas e os textos;
- "lido";
- o cartão atual com o anel em 0, 0,41 e 1 (golden do pintor, ou o ângulo pelo `debugPaint`);
- a parte;
- o vazio;
- a altura inicial: atual no 8º → offset = soma das 7 de cima; atual no 2º → 0; lista baixa → o cartão inteiro à
  vista;
- o toque na linha chama `onChapter(row)`;
- a linha sem alvo não é botão;
- Noite.

- [ ] RED → GREEN → commit `feat(leitor): aba Capítulos do sumário (tela 27, D-153)`.

### Tarefa 12: a aba Marcadas (`toc_bookmarks.dart`)

**Arquivos:** criar `lib/features/reader/presentation/toc_bookmarks.dart`; teste
`test/features/reader/presentation/toc_bookmarks_test.dart`.

- **Lista** `bm.sheet.bookmarks` ("Páginas marcadas"), com rolagem.
- **Cartões** `bm.sheet.bookmarks.item{n}`, cada um com:
  - `.row`;
  - `.head.page`, `.head.chapter` e `.head.here`;
  - `.excerpt`, com no máximo 3 linhas;
  - `.date`;
  - `.ribbon` e `.icon`: `ribbonCoral` quando marcada; `ribbonEmpty` (o contorno da G12) com 20×22 quando tirada.
- **Dica:** `bm.sheet.hint`, com `.iconWrap` (`DashedCirclePainter`) e `.icon`.
- **Semântica:**
  - o cartão é um botão "Abrir na página N";
  - a fita é um botão alternável:
    - marcada: "Tirar a marca da página N", `toggled: true`;
    - tirada: "Marcar a página N", `toggled: false`.

Testes:
- os 3 cartões com os textos;
- "você está aqui" só no da página atual;
- a sombra só nele;
- sem excerto, não há a linha;
- a fita chama `onRibbon` e o desenho troca com `marked`;
- o toque no cartão chama `onBookmark`;
- sem marcadores, só a dica;
- Noite.

- [ ] RED → GREEN → commit `feat(leitor): aba Marcadas do sumário (tela 27b, D-152)`.

### Tarefa 13: a tela liga tudo

**Arquivos:**
- `reader_screen.dart`;
- teste `test/features/reader/presentation/reader_screen_g15_test.dart` (com `LivroNaEstante.domCasmurro()`, o
  Gutenberg indexado, e com o mundo).

Mudanças na tela:
- **Estado:**
  - `_toc` e `ReaderToc? _tocData`;
  - `_tool(ReaderTool.toc)` → `_openToc()` (sai o aviso da D-118);
  - a `TocSheet` entra por cima dos controles, depois da folha de ajustes.
- **Fechar:**
  - `PopScope`: `else if (_toc) _closeToc();` depois do `_settings`;
  - `_closeToc` some com a folha, descarta o `_tocData` e volta aos controles.
- **Controles e prazos:**
  - `_holdBack` com `_toc`;
  - `ReaderControls.open: _controls && !_settings && !_toc`;
  - a barra de status com `!_toc`;
  - fechar tudo quando o estado deixa de ser `ReaderReady`.
- **Saltos (D-151):**
  - `onChapter(row)`: atual → fecha a folha e os controles; senão, fecha tudo e `jumpTo(row.target!, timed:)`;
  - `onBookmark(card)`: com alvo, fecha tudo e `jumpTo(card.target!, timed:)`.
- **Fita (D-152):** `onRibbon(card)`: marcada → `_tocData.keep(card.bookmark)` e
  `setBookmark(card.bookmark, on: false)`; tirada → `on: true`.
- **Aviso da faixa:** `onClub` → `_showToast(readerSoonText)`; com a folha aberta, a pílula fica por cima dela, a 12
  da base.

Testes:
- "Sumário" abre a folha na aba Capítulos com o sumário do Gutenberg;
- o aviso da D-118 não aparece mais;
- ×, Voltar, véu e arrasto fecham e os controles voltam;
- tocar em "XXXIII" salta, fecha tudo e mostra "← Voltar à pág. N";
- o atual só fecha, sem pílula;
- abrir de novo volta à aba Capítulos;
- **Marcadas:**
  - o cartão salta;
  - a fita tira, o cartão fica e o contador cai;
  - tocar de novo devolve a mesma linha;
  - ao fechar e reabrir, o tirado some;
  - a fita da ilha de cima acompanha;
- PDF com e sem estrutura ("Este livro não tem sumário.");
- Noite;
- a faixa no app não aparece (`NoReaderClub`).

- [ ] RED → GREEN → commit `feat(leitor): Sumário nos controles abre a folha; saltos e fita (D-151, D-152)`.

### Tarefa 14: fase L27 e golden 27

**Arquivos:**
- criar `test/support/fase_l27.dart` (molde da `fase_l26.dart`);
- `test/features/reader/presentation/l27_test.dart`;
- `test/golden/leitor_27_test.dart`;
- `test/golden/goldens/leitor_27@3x.png`.

**Mundo e abertura:**
- `livroDaTela27()`: `livroDaTela20()` com `usarIndice(indiceDaTela27(livro.index))`.
- Clube de teste: o do mundo (`'Leitoras de Capitu'`, `proximoEncontro`, `metaCapitulo` 50).
- `utcOffsetAt: (_) => mundo.fuso`.
- `abrirTela27`: a tela 20, tocar `r20.bottomIsland.tools.toc` e esperar 150 ms.

**O que a fase confere:**
- **Geometria:**
  - os 131 ids de `kRef27.idsOfSection` nas seções `toc.page`, `toc.fade` e `toc.sheet`;
  - a página por baixo é a do leitor, como na L26 (`toc.page.text` recortado).
- **Texto:**
  - as linhas e as baselines;
  - o fio de navalha de "As curiosidades de";
  - as recortadas não aparecem.
- **Estilo e semântica:** as tabelas da L27, com "1 marca" (D-51c).
- **Dados:** os textos saem de `t27` (`capitulo`, `faltamParaOClube`, `marcasDoCapitulo`), nunca escritos no teste
  como literal da prancha.

**Golden:** recorte y 84–844, `blur_mismatch_% ≤ 0,5`, com lado a lado e heatmap.

- [ ] RED → GREEN (ajustes de medida) → commit `test(leitor): fase L27 e golden da tela 27`.

### Tarefa 15: fase L27b e golden 27b

**Arquivos:** `fase_l27.dart` (parte b); `l27b_test.dart`; `leitor_27b_test.dart`; `goldens/leitor_27b@3x.png`.

**Abertura:** `abrirTela27b` = a tela 27 + tocar `toc.sheet.tabs.bookmarks`.

**O que a fase confere:**
- os 53 ids;
- os textos dos 3 cartões, com as datas do mundo no fuso do mundo;
- a semântica:
  - "Abrir na página 3/6/159";
  - "Tirar a marca da página N", pressionado;
- o golden no recorte y 84–842.

- [ ] RED → GREEN → commit `test(leitor): fase L27b e golden da tela 27b`.

### Tarefa 16: verificação, revisão e relatório

1. **Suíte:** `suite.ps1` (format, analyze, `flutter test --coverage`).
2. **Revisão independente:** um agente que não escreveu o código lê o diff `ceded86..HEAD`.
   - Corrigir os achados técnicos com teste.
   - As perguntas de produto vão para você (próximas D-155…).
3. **Mutação:** `/home/claude/g03/mut/gerar_g15.py`, no molde da `gerar_g14.py`. Trocas em:
   - os separadores e o romano;
   - o bloco antes;
   - o ponto final;
   - `tocUpToDate`;
   - "lido", atual e anel;
   - "1 marca", "falta 1" e a meta passada;
   - "hoje" e o ano;
   - o vivo vence o tirado;
   - `restored` e `setBookmark`;
   - a altura inicial;
   - o atual só fecha;
   - os saltos e a fita da tela.

   Todas as trocas precisam cair pelo comportamento, não por compilação.
4. **Cobertura** dos arquivos de `lib` mexidos: ≥ 90 %.
5. **gitleaks** nos commits da fase e nas pastas tocadas.
6. **Capturas** (`capturas_g15_test.dart`, fora do git):
   - as duas abas em Creme e no Noite;
   - um livro com partes;
   - sem sumário;
   - o cartão com a fita tirada;
   - os lados a lados.
7. **Relatório e decisões:**
   - `G15.md` (resultados, revisão, desvios, pendências, checklist);
   - `RELATORIO_G15.md`, que termina em "✅ FASE G15 concluída — aguardando sua aprovação para iniciar a FASE G16.";
   - o relatório sobe para o projeto (`handoff_app_completo/relatorios/RELATORIO_G15.md`);
   - as D-149…D-154 (e as da revisão) vão para `handoff_app_completo/05_DECISOES_E_PERGUNTAS.md`.

## Autorrevisão

- **Cobertura da spec:**
  - seção 1 → Tarefas 1–4;
  - seção 2 → Tarefas 5–8;
  - seção 3 → Tarefas 9–11;
  - seção 4 → Tarefas 12–13;
  - seção 5 → Tarefas 14–16.
- **Nomes:** os mesmos em todas as tarefas: `tocLabel`, `tocTitle`, `headingNumeral`, `TocPoint.textNumeral`,
  `BookIndex.tocUpToDate`, `buildTocView`, `TocView`, `TocRow`, `TocBookmarkCard`, `TocClubStrip`, `ReaderToc.keep`,
  `ReaderClubSource.goalFor`, `ReaderClubGoal`, `setBookmark(b, on:)`, `RecordMeta.restored` e `BookmarksDao.byId`.
- **Sem lacunas:** as medidas que faltam aqui vêm das tabelas da L27/L27b, conferidas pelas fases.
