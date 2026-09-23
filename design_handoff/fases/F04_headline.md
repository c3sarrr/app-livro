# FASE 4 — Seção 2: Título editorial "Continue / sua história."

> Pré-requisito: FASE 3 aprovada.
> Referências: `referencia/png/secoes/F04_headline@3x.png` · `redline/F04_headline_redline@3x.png`.
> Arquivo: `features/home/presentation/sections/headline_section.dart`.

---

## HTML literal da seção

```html
    <!-- Editorial headline -->
    <h1 style="margin: 24px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 42px; line-height: 0.98; letter-spacing: -1.4px;">Continue<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 50px; letter-spacing: -0.6px;">sua história.</span></h1>
```

## Especificação pixel a pixel

Seção `headline` — retângulo absoluto no canvas 390×2390: **x=20, y=134, w=350, h=90.16**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `headline` | text | 0 | 0 | 350 | 90.16 | `margin: 24px 0px 0px; font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 42px; line-height: 0.98; letter-spacing: -1.4px` | Bricolage (opsz 42) 42/41.16px peso 800 ls -1.4px #1A1714 |
| — | `headline.serif` | inline | 0 | 33.16 | 219.65 | 65 | `font-family: "Instrument Serif", Georgia, serif; font-style: italic; font-weight: 400; font-size: 50px; letter-spacing: -0.6px` | Instrument Serif itálico 50/49px peso 400 ls -0.6px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `headline` | 1 | Continue | 34.44 | 0 | 170.69 | 170.69 |
| `headline` | 2 | sua história. | 82.66 | 0 | 219.65 | 219.65 |
| `headline.serif` | 1 | sua história. | 82.66 | 0 | 219.65 | 219.65 |

## Leitura de designer (e de tipógrafo)

1. É **um único parágrafo** (`<h1>`) com duas linhas e duas fontes: linha 1 "Continue" em **Bricolage 42 (opsz 42) 800**, ls **−1,4**; linha 2 "sua história." em **Instrument Serif itálico 50**, ls **−0,6**.
2. `line-height: 0.98` está no `<h1>` e é **herdado como fator** pelo `<span>` → a linha 2 tem 0,98 × 50 = **49 px**; a linha 1 tem 0,98 × 42 = **41,16 px**. Altura total **90,16**.
3. Baselines (relativas ao topo do h1): **34,44** e **82,66**. Derivação (confira no teste): meia-entrelinha "even" = (altura da linha − (ascender + descender)) / 2; Bricolage 42: (41,16 − 50,4)/2 = −4,62 → baseline = 39,06 − 4,62 = 34,44; Instrument 50: (49 − 65)/2 = −8 → baseline da linha 2 = 41,16 + 49,5 − 8 = 82,66.
4. As duas linhas começam em x = 20 (sem recuo). Largura da linha 1 = 170,69; linha 2 = 219,65 (inclui o espaçamento após o último caractere, como o navegador).
5. O ponto final faz parte do itálico ("história."). Acento agudo em "ó" — a fonte tem o glifo; não troque por composição.
6. `margin-top: 24` já está no esqueleto (F02). A seção é só o texto.

## Construção obrigatória

```dart
Semantics(
  container: true,
  header: true,                       // <h1> (se o seu SDK tiver `headingLevel`, use 1)
  label: 'Continue sua história.',
  excludeSemantics: true,             // os dois AppText não geram nós próprios
  child: Column(
    key: const ValueKey('headline'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText('Continue', style: AppTextStyles.displayXL),          // linha 1: 41,16 de altura
      AppText('sua história.', style: AppTextStyles.displaySerifXL), // linha 2: 49 de altura
    ],
  ),
)
```
- **Por que duas linhas em dois `AppText`** (e não um `AppText.rich` com `\n`): o motor de texto do Flutter desloca cada linha alinhada à esquerda em metade do letter-spacing do primeiro caractere, e as duas linhas têm letter-spacing diferente (−1,4 e −0,6). O `RenderAppText` desfaz esse deslocamento **por parágrafo** (F01 §1.4), então cada linha precisa ser um parágrafo. No CSS, a linha 2 mede exatamente a caixa do itálico (49), que cobre o *strut* da Bricolage acima e abaixo da baseline — por isso a coluna de dois parágrafos reproduz as mesmas alturas (41,16 + 49 = 90,16) e baselines (34,44 e 82,66). Isso já foi provado no teste (e) da F01.
- Largura: a coluna estica nos 350 da coluna de conteúdo, então `headline` tem retângulo 20, 134, **350** × 90,16; os dois `AppText` recebem largura *tight* 350 e começam em x = 20.
- O `expectTextLines(tester, 'headline')` junta as linhas de todos os `AppText` sob a Key (ordem vertical) e confere como um parágrafo só.

## Subfases

- **4.1** Coluna com as duas linhas (Bricolage 42 / Instrument Serif itálico 50), alturas de linha 41,16 e 49, semântica de cabeçalho num nó só.
- **4.2** Verificação: altura 90,16, baselines, extensões de linha, semântica de cabeçalho.

## Testes da fase

- `expectGeometry(tester, ['headline'])` e `expectTextLines(tester, 'headline')` (linhas "Continue" / "sua história.", baselines 168,44 e 216,66 absolutas).
- Correção de meio letter-spacing em contexto: `debugLines()` dos dois `AppText` → `left` = **20,00 ±0,05** (sem a correção: 19,30 e 19,70).
- Semântica (`tester.ensureSemantics()`): existe **um** nó com `isHeader` e label exatamente "Continue sua história." (e nenhum nó separado para "Continue" ou "sua história.").
- Visual: `--rect 0,126,390,106` → `blur_mismatch_% ≤ 0,5`.
- Não-regressão da F03.

## Checklist de aceite da FASE 4

- [ ] 4.1 `Column` (Key `headline`) com `AppText('Continue', displayXL)` + `AppText('sua história.', displaySerifXL)`, envolvida em `Semantics(container, header, label, excludeSemantics)`
- [ ] 4.1 Alturas de linha 41,16 e 49 (fator 0,98), distribuição even; início das duas linhas em x = 20,00 (±0,05, correção de meio letter-spacing ativa)
- [ ] 4.2 Retângulo 20/134/350/90,16 (±0,5)
- [ ] 4.2 Baselines 168,44 e 216,66 (±0,5); larguras 170,69 e 219,65 (±1,0)
- [ ] 4.2 Semântica: um único nó de cabeçalho "Continue sua história."
- [ ] Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com lado-a-lado anexado e inspecionado

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 4 concluída — aguardando sua aprovação para iniciar a FASE 5.`
