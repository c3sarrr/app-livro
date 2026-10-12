# FASE L07 — Login — a folha: "Sua história começa aqui.", Google, Apple, e-mail e os termos

> Tela 07 · prancha `007_login` (07 · Login, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L07_2_folha@3x.png` · `docs/design/medicao/projeto/png/redline/L07_2_folha_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/007_login_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_007_login.json` · `test/reference/projeto/reference_layout_007_login.dart` (`kRef07`).
> Arquivos sugeridos: `lib/features/account/presentation/entry/login_screen.dart`, `lib/features/account/presentation/entry/social_sign_in_buttons.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Login, a folha: "Sua história começa aqui.", o texto, os botões oficiais do Google e da Apple (claros), "Cadastrar com e-mail" (preto), "Já tem conta? Entrar" e os termos.

---

## HTML literal da seção

Props do componente: nenhuma (as cores desta tela são fixas).

```html
<!-- Sign-in sheet -->
<section aria-label="Entrar ou criar conta" style="position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 24px 20px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">
  <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px;">Sua história<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 40px; letter-spacing: -0.4px;">começa aqui.</span></h2>
  <p style="margin: 10px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.4; color: #5B544B; text-wrap: pretty;">Leia, grife e converse sobre livros com quem lê junto com você.</p>

  <div style="margin-top: 18px; display: flex; flex-direction: column; gap: 10px;">
    <!-- Official light-theme sign-in button: white fill, #747775 stroke, #1F1F1F text -->
    <button style="position: relative; width: 100%; height: 50px; padding: 0 16px; border-radius: 999px; background: #FFFFFF; border: 1px solid #747775; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Google Sans', 'Roboto', system-ui, sans-serif; font-size: 15px; font-weight: 500; line-height: 20px; letter-spacing: 0.1px; color: #1F1F1F;">
      <span aria-hidden="true" style="position: absolute; left: 16px; top: 50%; margin-top: -10px; width: 20px; height: 20px; border-radius: 4px; border: 1.2px dashed #747775; box-sizing: border-box;"></span>
      Continuar com o Google
    </button>
    <!-- Sign in with Apple (iOS only), official "white outline" style: white fill, black 1px stroke, black text -->
    <button style="position: relative; width: 100%; height: 50px; padding: 0 16px; border-radius: 999px; background: #FFFFFF; border: 1px solid #000000; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: -apple-system, 'SF Pro Text', system-ui, sans-serif; font-size: 15.5px; font-weight: 500; line-height: 20px; letter-spacing: -0.2px; color: #000000;">
      <span aria-hidden="true" style="position: absolute; left: 16px; top: 50%; margin-top: -10px; width: 20px; height: 20px; border-radius: 4px; border: 1.2px dashed #000000; box-sizing: border-box;"></span>
      Continuar com a Apple
    </button>
    <button style="width: 100%; height: 50px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 15.5px; font-weight: 800; color: #F7F0E3;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="3"></rect><path d="m4 7 8 6 8-6"></path></svg>
      <span style="color: #F7F0E3;">Cadastrar com e-mail</span>
    </button>
  </div>

  <p style="margin: 6px 0 0; height: 44px; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 14px; font-weight: 600; color: #5B544B;">Já tem conta? <a href="#" style="font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px;">Entrar</a></p>

  <p style="margin: 4px 0 0; font-size: 12px; font-weight: 500; line-height: 1.45; color: #6F665B; text-align: center; text-wrap: pretty;">Ao continuar, você concorda com os <a href="#" style="font-weight: 700; color: #1A1714; text-decoration: underline; text-underline-offset: 2px;">Termos de Uso</a> e a <a href="#" style="font-weight: 700; color: #1A1714; text-decoration: underline; text-underline-offset: 2px;">Política de Privacidade</a>.</p>
</section>
```

## Especificação pixel a pixel

Seção `e07.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=389.04, w=370, h=444.96**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e07.sheet` | box | 0 | 0 | 370 | 444.96 | `position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 24px 20px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 2 | `e07.sheet.title` | text | 21.5 | 25.5 | 327 | 70.56 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 32) 32/31.36px peso 800 ls -1px #1A1714 |
| 3 | `e07.sheet.title.serif` ±1 | inline | 21.5 | 50.46 | 185.88 | 52 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 40px; letter-spacing: -0.4px` | Instrument Serif itálico 40/39.2px peso 400 ls -0.4px #1A1714 |
| 4 | `e07.sheet.lead` | text | 21.5 | 106.06 | 327 | 40.6 | `margin: 10px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.4; color: #5B544B; text-wrap: pretty` | Figtree 14.5/20.3px peso 500 ls normal #5B544B |
| 5 | `e07.sheet.buttons` | box | 21.5 | 164.66 | 327 | 170 | `margin-top: 18px; display: flex; flex-direction: column; gap: 10px` |  |
| 6 | `e07.sheet.buttons.google` | box+text | 21.5 | 164.66 | 327 | 50 | `position: relative; width: 100%; height: 50px; padding: 0 16px; border-radius: 999px; background: #FFFFFF; border: 1px solid #747775; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Google Sans', 'Roboto', system-ui, sans-serif; font-size: 15px; font-weight: 500; line-height: 20px; letter-spacing: 0.1px; color: #1F1F1F` | Google Sans 15/20px peso 500→**800** ls 0.1px #1F1F1F |
| 7 | `e07.sheet.buttons.google.logo` | box | 38.5 | 179.66 | 20 | 20 | `position: absolute; left: 16px; top: 50%; margin-top: -10px; width: 20px; height: 20px; border-radius: 4px; border: 1.2px dashed #747775; box-sizing: border-box` |  |
| 8 | `e07.sheet.buttons.apple` | box+text | 21.5 | 224.66 | 327 | 50 | `position: relative; width: 100%; height: 50px; padding: 0 16px; border-radius: 999px; background: #FFFFFF; border: 1px solid #000000; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: -apple-system, 'SF Pro Text', system-ui, sans-serif; font-size: 15.5px; font-weight: 500; line-height: 20px; letter-spacing: -0.2px; color: #000000` | -apple-system 15.5/20px peso 500→**800** ls -0.2px #000000 |
| 9 | `e07.sheet.buttons.apple.logo` | box | 38.5 | 239.66 | 20 | 20 | `position: absolute; left: 16px; top: 50%; margin-top: -10px; width: 20px; height: 20px; border-radius: 4px; border: 1.2px dashed #000000; box-sizing: border-box` |  |
| 10 | `e07.sheet.buttons.email` | box | 21.5 | 284.66 | 327 | 50 | `width: 100%; height: 50px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 15.5px; font-weight: 800; color: #F7F0E3` |  |
| 11 | `e07.sheet.buttons.email.icon` ±1 | icon | 92.24 | 299.66 | 20 | 20 | `—` |  |
| 12 | `e07.sheet.buttons.email.label` ±1 | text | 122.24 | 300.35 | 155.53 | 18.61 | `color: #F7F0E3` | Figtree 15.5/normal peso 800 ls normal #F7F0E3 |
| 13 | `e07.sheet.signIn` | text | 21.5 | 340.66 | 327 | 44 | `margin: 6px 0 0; height: 44px; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 14 | `e07.sheet.signIn.link` ±1 | text | 212.27 | 354.26 | 40.74 | 16.8 | `font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 15 | `e07.sheet.legal` | text | 21.5 | 388.66 | 327 | 34.8 | `margin: 4px 0 0; font-size: 12px; font-weight: 500; line-height: 1.45; color: #6F665B; text-align: center; text-wrap: pretty` | Figtree 12/17.4px peso 500 ls normal #6F665B |
| 16 | `e07.sheet.legal.terms` ±1 | inline | 235.56 | 390.16 | 80.95 | 14.4 | `font-weight: 700; color: #1A1714; text-decoration: underline; text-underline-offset: 2px` | Figtree 12/17.4px peso 700 ls normal #1A1714 |
| 17 | `e07.sheet.legal.privacy` ±1 | inline | 120.99 | 407.56 | 125.4 | 14.4 | `font-weight: 700; color: #1A1714; text-decoration: underline; text-underline-offset: 2px` | Figtree 12/17.4px peso 700 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e07.sheet.title` *(composto)* | 1 | Sua história | 51.74 | 21.5 | 194.72 | 173.22 |
| `e07.sheet.title` *(composto)* | 2 | começa aqui. | 90.06 | 21.5 | 207.38 | 185.88 |
| `e07.sheet.lead` | 1 | Leia, grife e converse sobre livros com quem lê | 121.28 | 21.5 | 325.86 | 304.36 |
| `e07.sheet.lead` | 2 | junto com você. | 141.58 | 21.5 | 126.36 | 104.86 |
| `e07.sheet.buttons.google` | 1 | Continuar com o Google | 194.24 | 102.77 | 267.23 | 164.46 |
| `e07.sheet.buttons.apple` | 1 | Continuar com a Apple | 254.09 | 102.54 | 267.46 | 164.92 |
| `e07.sheet.buttons.email.label` | 1 | Cadastrar com e-mail | 315.08 | 122.24 | 277.76 | 155.52 |
| `e07.sheet.signIn` | 1 | Já tem conta? | 367.56 | 116.99 | 207.27 | 90.28 |
| `e07.sheet.signIn.link` | 1 | Entrar | 367.56 | 212.27 | 253.01 | 40.74 |
| `e07.sheet.legal` *(composto)* | 1 | Ao continuar, você concorda com os Termos de Uso e a | 401.56 | 34.87 | 335.13 | 300.26 |
| `e07.sheet.legal` *(composto)* | 2 | Política de Privacidade. | 418.96 | 120.99 | 249.01 | 128.02 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A folha da entrada: `left/right/bottom 10` (e um `top` por tela), padding 24–26/20/20, raio 32/32/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4, coluna. O título é sempre Bricolage 32/800 `lh 0,98` ls −1 + quebra + Instrument Serif itálico 40–42 ls −0,4, e o texto de baixo 14,5/500 `lh 1,4–1,45` `#5B544B`, 8 abaixo. Aqui: `left/right/bottom 10`, padding 24/20/20, título 32 + 40.
2. Botões (coluna, gap 10, 18 abaixo do texto), 50 de altura: Google `#FFFFFF`, borda 1 `#747775`, texto 15/500 ls 0,1 `#1F1F1F` (a fonte do Google); Apple `#FFFFFF`, borda 1 preta, 15,5/500 ls −0,2 (a do sistema); os lugares dos logos são quadrados tracejados 20 × 20 em `left 16`, centrados na altura.
3. "Cadastrar com e-mail": 50, preto, borda 1,5, o envelope 20 `#F7F0E3` + 15,5/800.
4. "Já tem conta? Entrar": linha de 44, 6 abaixo, 14/600 com o link 800 sublinhado; os termos 12/500 `lh 1,45` `#6F665B`, centrados, `text-wrap: pretty`, com os dois links 700 sublinhados (offset 2).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- Os botões sociais seguem o kit de marca oficial (nota login-google-slot): os quadrados tracejados são o lugar dos logos oficiais — usar os arquivos dos kits, sem redesenhar. No Flutter, `SignInWithAppleButton(style: whiteOutlined, iconAlignment: left)` já desenha o logo.
- O Google pede a Google Sans, que não está no Google Fonts: a prancha cai na Roboto 500; o app usa a Roboto 500 embutida (T13.10) ou o botão oficial do pacote — pergunta da T16. O texto da Apple usa a fonte do sistema (R8, abaixo): o botão oficial resolve.
- `text-wrap: pretty` nos termos: as quebras da tabela são as do Chromium — conferir no app.
- `e07.sheet.buttons.apple` usa glifo de fonte do sistema (Inter Medium (21 glifo(s))) — no navegador o resultado depende da máquina.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_007_login_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_007_login_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e07.sheet` |  | Entrar ou criar conta |  |
| `e07.sheet.buttons.google.logo` |  |  | aria-hidden=true |
| `e07.sheet.buttons.apple.logo` |  |  | aria-hidden=true |
| `e07.sheet.buttons.email.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e07.sheet` | NeoBox |  |
| `e07.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e07.sheet.buttons.google` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e07.sheet.buttons.google.logo` | NeoBox |  |
| `e07.sheet.buttons.apple` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e07.sheet.buttons.apple.logo` | NeoBox |  |
| `e07.sheet.buttons.email` | NeoBox |  |
| `e07.sheet.buttons.email.icon` | AppSvg(AppIconsEntrada.mail, size: 20) |  |
| `e07.sheet.legal.terms` | TextSpan dentro do AppText.rich do pai |  |
| `e07.sheet.legal.privacy` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Continuar com o Google → o login nativo do Google (`native_sign_in.dart`, G05).
- Continuar com a Apple → só no iOS (no Android o botão não aparece: a folha encolhe — confirmar o desenho sem ele na T16).
- Cadastrar com e-mail → o Cadastro (08); Entrar → Entrar com e-mail (09).
- Termos de Uso e Política de Privacidade → as páginas dos documentos (os endereços são da G25/G27).

## Dados

- Nenhum dado; a folha leva à autenticação que já existe (Supabase, G05).

## Subfases

- **L07.1** Folha com o título e o texto
- **L07.2** Botões oficiais do Google e da Apple (kits de marca)
- **L07.3** Cadastrar, Entrar e os termos
- **L07.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e07.sheet'), todos os ids de `kRef07.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/007_login_390x844@3x.png` no recorte da fase (y 381.04–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef07w360` e `kRef07w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L07.1 Folha com o título e o texto
- [ ] L07.2 Botões oficiais do Google e da Apple (kits de marca)
- [ ] L07.3 Cadastrar, Entrar e os termos
- [ ] L07.4 Verificação + relatório
- [ ] Geometria 14/14 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
