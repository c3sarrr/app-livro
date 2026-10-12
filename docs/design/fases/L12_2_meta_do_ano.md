# FASE L12 — Onboarding 1/4 — a meta do ano e o Continuar

> Tela 12 · prancha `012_onboarding_meta` (12 · Onboarding 1/4 — Meta de leitura, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L12_2_meta_do_ano@3x.png` · `docs/design/medicao/projeto/png/redline/L12_2_meta_do_ano_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/012_onboarding_meta_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_012_onboarding_meta.json` · `test/reference/projeto/reference_layout_012_onboarding_meta.dart` (`kRef12`).
> Arquivos sugeridos: `lib/features/account/presentation/onboarding/goal_step.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Onboarding 1/4 — Meta, embaixo: o cartão amarelo "Livros em 2026 · Cerca de 2 por mês" com o menos, o 24 e o mais, e o "Continuar" no fundo.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{progress}}` = padrão `#FF552E`.

```html
<!-- Yearly books (goal = yellow) -->
<section aria-label="Meta do ano" style="margin-top: 16px; padding: 14px 12px 14px 16px; border-radius: 22px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 12px;">
  <span style="flex-grow: 1; min-width: 0;">
    <span style="display: block; font-size: 14.5px; font-weight: 800; line-height: 1.25;">Livros em 2026</span>
    <span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.3; color: #3E3832;">Cerca de 2 por mês</span>
  </span>
  <div style="display: flex; align-items: center; gap: 6px;">
    <button aria-label="Diminuir meta" style="width: 44px; height: 44px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.6" stroke-linecap="round"><path d="M6 12h12"></path></svg></button>
    <output aria-live="polite" style="min-width: 48px; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 30px; line-height: 1; letter-spacing: -0.8px; font-variant-numeric: tabular-nums;">24</output>
    <button aria-label="Aumentar meta" style="width: 44px; height: 44px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#FED170" stroke-width="2.6" stroke-linecap="round"><path d="M6 12h12M12 6v12"></path></svg></button>
  </div>
</section>

<button style="margin-top: auto; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
  <span style="color: #F7F0E3;">Continuar</span>
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
</button>
```

## Especificação pixel a pixel

Seção `e12.yearly` — retângulo absoluto no canvas 390×844: **x=20, y=623.42, w=350, h=75**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e12.yearly` | box | 0 | 0 | 350 | 75 | `margin-top: 16px; padding: 14px 12px 14px 16px; border-radius: 22px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 12px` |  |
| 2 | `e12.yearly.textBlock` | box | 17.5 | 19.32 | 159 | 36.38 | `flex-grow: 1; min-width: 0` |  |
| 3 | `e12.yearly.title` | text | 17.5 | 19.32 | 159 | 18.12 | `display: block; font-size: 14.5px; font-weight: 800; line-height: 1.25` | Figtree 14.5/18.125px peso 800 ls normal #1A1714 |
| 4 | `e12.yearly.hint` | text | 17.5 | 39.44 | 159 | 16.25 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.3; color: #3E3832` | Figtree 12.5/16.25px peso 600 ls normal #3E3832 |
| 5 | `e12.yearly.stepper` | box | 188.5 | 15.5 | 148 | 44 | `display: flex; align-items: center; gap: 6px` |  |
| 6 | `e12.yearly.stepper.minus` | box | 188.5 | 15.5 | 44 | 44 | `width: 44px; height: 44px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 7 | `e12.yearly.stepper.minus.icon` | icon | 201.5 | 28.5 | 18 | 18 | `—` |  |
| 8 | `e12.yearly.stepper.value` | text | 238.5 | 22.5 | 48 | 30 | `min-width: 48px; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 30px; line-height: 1; letter-spacing: -0.8px; font-variant-numeric: tabular-nums` | Bricolage (opsz 30) 30/30px peso 800 ls -0.8px #1A1714 tnum |
| 9 | `e12.yearly.stepper.plus` | box | 292.5 | 15.5 | 44 | 44 | `width: 44px; height: 44px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 10 | `e12.yearly.stepper.plus.icon` | icon | 305.5 | 28.5 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e12.yearly.title` | 1 | Livros em 2026 | 33.45 | 17.5 | 121.55 | 104.05 |
| `e12.yearly.hint` | 1 | Cerca de 2 por mês | 51.94 | 17.5 | 127.57 | 110.07 |
| `e12.yearly.stepper.value` | 1 | 24 | 47.41 | 244.73 | 280.27 | 35.54 |

Seção `e12.continue` — retângulo absoluto no canvas 390×844: **x=20, y=756, w=350, h=54**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 11 | `e12.continue` | box | 0 | 0 | 350 | 54 | `margin-top: auto; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 12 | `e12.continue.label` ±1 | text | 122.75 | 17.4 | 74.5 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 13 | `e12.continue.icon` ±1 | icon | 207.25 | 17 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e12.continue.label` | 1 | Continuar | 32.6 | 122.75 | 197.25 | 74.5 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cartão 16 abaixo das opções: padding 14/12/14/16, raio 22, `#FED170`, borda 1,5, sem sombra; "Livros em 2026" 14,5/800 e "Cerca de 2 por mês" 12,5/600 `#3E3832`.
2. Contador (gap 6): menos (44, `#FFFAF1`, borda 1,5, traço 2,6) — "24" Bricolage 30/800 ls −0,8 `tnum`, mín. 48, `aria-live` — mais (44, preto, o "+" `#FED170`).
3. "Continuar" 54, preto, seta 20, no fundo (`margin-top: auto`).
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- "Cerca de N por mês" com metas pequenas (menos de 12 no ano) não tem texto na prancha — pergunta da T16.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_012_onboarding_meta_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_012_onboarding_meta_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e12.yearly` |  | Meta do ano |  |
| `e12.yearly.stepper.minus` |  | Diminuir meta |  |
| `e12.yearly.stepper.value` |  |  | aria-live=polite |
| `e12.yearly.stepper.plus` |  | Aumentar meta |  |
| `e12.continue.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e12.yearly` | NeoBox |  |
| `e12.yearly.stepper.minus` | CircleIconButton / NeoBox circular |  |
| `e12.yearly.stepper.minus.icon` | AppSvg(AppIconsEntrada.minusBold, size: 18) |  |
| `e12.yearly.stepper.plus` | CircleIconButton / NeoBox circular |  |
| `e12.yearly.stepper.plus.icon` | AppSvg(AppIconsEntrada.plusMeta, size: 18) |  |
| `e12.continue` | NeoBox |  |
| `e12.continue.icon` | AppSvg(AppIconsEntrada.arrowForward, size: 20) |  |

## Interações

- Menos e mais → muda a meta do ano (limites e passo: pergunta da T16); "Cerca de 2 por mês" acompanha (meta ÷ 12, arredondado).
- Continuar → o passo 2 (13).

## Dados

- A meta de livros do ano (`ReadingGoals`); o ano corrente no rótulo.

## Subfases

- **L12.1** Cartão da meta do ano
- **L12.2** Continuar no fundo
- **L12.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e12.yearly', 'e12.continue'), todos os ids de `kRef12.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/012_onboarding_meta_390x844@3x.png` no recorte da fase (y 615.42–818) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef12w360` e `kRef12w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L12.1 Cartão da meta do ano
- [ ] L12.2 Continuar no fundo
- [ ] L12.3 Verificação + relatório
- [ ] Geometria 13/13 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
