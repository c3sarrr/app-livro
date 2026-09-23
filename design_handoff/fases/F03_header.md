# FASE 3 — Seção 1: Cabeçalho (avatar, saudação, sino)

> Pré-requisito: FASE 2 aprovada.
> Referências: `referencia/png/secoes/F03_header@3x.png` · `referencia/png/redline/F03_header_redline@3x.png` · ids da seção `header` em `reference_layout.dart`.
> Arquivo: `features/home/presentation/sections/header_section.dart` (substitui o placeholder `header`).

---

## HTML literal da seção (fonte da verdade)

```html
    <!-- Header -->
    <header style="display: flex; align-items: center; justify-content: space-between; height: 48px;">
      <div style="display: flex; align-items: center; gap: 12px;">
        <div style="width: 44px; height: 44px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px;">M</div>
        <div style="display: flex; flex-direction: column; gap: 1px;">
          <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Boa noite,</span>
          <span style="font-size: 16px; font-weight: 700; letter-spacing: -0.1px;">Marina</span>
        </div>
      </div>
      <button aria-label="Notificações, 2 novas" style="position: relative; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0;">
        <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M6 8a6 6 0 1 1 12 0c0 7 3 9 3 9H3s3-2 3-9"></path><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"></path></svg>
        <span style="position: absolute; top: 9px; right: 11px; width: 9px; height: 9px; border-radius: 50%; background: #FF552E; border: 1.5px solid #FFFAF1;"></span>
      </button>
    </header>
```

## Especificação pixel a pixel (medida no arquivo)

Seção `header` — retângulo absoluto no canvas 390×2390: **x=20, y=62, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `header` | box | 0 | 0 | 350 | 48 | `display: flex; align-items: center; justify-content: space-between; height: 48px` |  |
| 2 | `header.identity` | box | 0 | 2 | 114.43 | 44 | `display: flex; align-items: center; gap: 12px` |  |
| 3 | `header.avatar` | box+text | 0 | 2 | 44 | 44 | `width: 44px; height: 44px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 18px` | Bricolage (opsz 18) 18/normal peso 800 ls normal #1A1714 |
| 4 | `header.greetingColumn` | box | 56 | 6.1 | 58.43 | 35.8 | `display: flex; flex-direction: column; gap: 1px` |  |
| 5 | `header.greeting` | text | 56 | 6.1 | 58.43 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 6 | `header.name` | text | 56 | 22.7 | 58.43 | 19.2 | `font-size: 16px; font-weight: 700; letter-spacing: -0.1px` | Figtree 16/normal peso 700 ls -0.1px #1A1714 |
| 7 | `header.bell` | box | 302 | 0 | 48 | 48 | `position: relative; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0px` |  |
| 8 | `header.bell.icon` | icon | 315 | 13 | 22 | 22 | `—` |  |
| 9 | `header.bell.dot` | box | 325.5 | 10.5 | 12 | 12 | `position: absolute; top: 9px; right: 11px; width: 9px; height: 9px; border-radius: 50%; background: #FF552E; border: 1.5px solid #FFFAF1` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `header.avatar` | 1 | M | 29.94 | 13.47 | 30.53 | 17.06 |
| `header.greeting` | 1 | Boa noite, | 18.45 | 56 | 114.43 | 58.43 |
| `header.name` | 1 | Marina | 37.9 | 56 | 105.51 | 49.51 |

## Leitura de designer (detalhes que não podem escapar)

1. **Altura fixa de 48** para a linha inteira; a identidade (avatar 44 + textos) fica centralizada verticalmente → o avatar começa em y+2 (e não em y+0).
2. **Avatar**: círculo 44×44, amarelo `#FED170`, borda **1,5** tinta, letra "M" em **Bricolage 18 (opsz 18) 800** centralizada — não é Figtree.
3. **Coluna de saudação**: gap de **1 px** entre "Boa noite," (Figtree 13/500 `#5B544B`) e "Marina" (Figtree 16/700, letter-spacing **−0,1**). A coluna tem a largura do texto mais largo (58,43) e os dois textos são **esticados** a essa largura (flex coluna, `align-items: stretch`).
4. **Sino**: botão circular 48×48, fundo `#FFFAF1`, borda 1,5; ícone de 22 centralizado (traço 1,8 no viewBox 24 → 1,65 px).
5. **Ponto de notificação**: `width/height 9` + borda 1,5 → **12×12 externos** (content-box!), preenchimento `#FF552E`, **borda `#FFFAF1`** (cor da superfície do botão, não tinta) — cria o "respiro" em volta do ponto. Posição: `top: 9; right: 11` medidos **dentro da borda** do botão → canto superior esquerdo do ponto em (325,5; 10,5) relativo à seção.
6. O ponto é `position: absolute` → pinta **por cima** do ícone do sino (ordem de pintura).

## Construção obrigatória

```dart
SizedBox(
  key: const ValueKey('header'),
  height: 48,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(key: const ValueKey('header.identity'), mainAxisSize: MainAxisSize.min, spacing: 12, children: [
        NeoBox(key: const ValueKey('header.avatar'), width: 44, height: 44, color: AppColors.sun,
            border: const BorderSide(width: 1.5, color: AppColors.ink), radius: BorderRadius.circular(22),
            child: Center(child: AppText('M', style: AppTextStyles.avatarInitial))),
        IntrinsicWidth(
          child: Column(key: const ValueKey('header.greetingColumn'), mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 1, children: [
            AppText(greeting, key: const ValueKey('header.greeting'), style: AppTextStyles.body13Muted),
            AppText(firstName, key: const ValueKey('header.name'), style: AppTextStyles.name16),
          ]),
        ),
      ]),
      CircleIconButton(                                   // assinatura da F01 §1.7
        key: const ValueKey('header.bell'),
        size: 48, color: AppColors.surface, border: const BorderSide(width: 1.5, color: AppColors.ink),
        icon: const AppSvg(AppIcons.bell, size: 22, key: ValueKey('header.bell.icon')),   // centralizado: (13, 13)
        overlays: const [                                 // medidos a partir da borda interna (= position:absolute do CSS)
          Positioned(top: 9, right: 11, child: NeoBox(key: ValueKey('header.bell.dot'),
              width: 12, height: 12,                      // 9 + 2 × 1,5 (content-box)
              color: AppColors.flame, border: BorderSide(width: 1.5, color: AppColors.surface),
              radius: BorderRadius.all(Radius.circular(6)))),
        ],
        onTap: onNotificationsTap,
        semanticsLabel: notificationsAria,                // 'Notificações, 2 novas'
      ),
    ],
  ),
)
```
- Keys de `header.bell` (botão 48), `header.bell.icon` (SizedBox 22 do ícone) e `header.bell.dot` (ponto 12) obrigatórias.
- Semântica: botão com `label: 'Notificações, 2 novas'` (vem de `notificationsAria`); ícone e ponto excluídos da semântica.
- Toque: callback `onNotificationsTap` (ligado à rota na F12). Sem ripple.

## Subfases

- **3.1** Estrutura da linha 48 + identidade (avatar + coluna de saudação) — geometria dos ids 1–6 da tabela.
- **3.2** Sino (botão, ícone, ponto content-box com borda `#FFFAF1`) — geometria dos ids 7–9.
- **3.3** Semântica + callback + estados (nenhum visual novo).
- **3.4** Verificação completa (camadas 1–4) e relatório.

## Testes da fase

- `expectGeometry(tester, idsOfSection('header'))` → 9/9.
- `expectTextLines` para `header.avatar`, `header.greeting`, `header.name` (baselines 29,94 / 18,45 / 37,90 relativas à seção → absolutas +62).
- Estilo: decoração do avatar (cor `#FED170`, borda 1,5 `#1A1714`, raio 22), do botão (`#FFFAF1`, 1,5), do ponto (`#FF552E`, borda 1,5 `#FFFAF1`, 12×12).
- Semântica: `find.bySemanticsLabel('Notificações, 2 novas')` encontra 1 botão.
- Visual: `compare_images.py --rect 0,54,390,64` (canvas @3x) → `blur_mismatch_% ≤ 0,5`.
- Não-regressão: blocos das fases anteriores inalterados (compare com o golden aprovado da F02 no inset superior).

## Checklist de aceite da FASE 3

- [ ] 3.1 Linha de 48 com `spaceBetween` e centralização vertical
- [ ] 3.1 Avatar 44×44 `#FED170`, borda 1,5, "M" Bricolage18 800 centralizado
- [ ] 3.1 Coluna de saudação com gap 1, largura 58,43 e textos esticados (IntrinsicWidth + stretch)
- [ ] 3.1 "Boa noite," Figtree 13/500 `#5B544B`; "Marina" Figtree 16/700 ls −0,1
- [ ] 3.2 Botão 48×48 `#FFFAF1` borda 1,5; ícone `ic_bell.svg` 22 centralizado
- [ ] 3.2 Ponto 12×12 (9 + 2×1,5) `#FF552E` com borda `#FFFAF1`, em top 9 / right 11 dentro da borda, pintado sobre o ícone
- [ ] 3.3 Semântica "Notificações, 2 novas"; callback de toque; sem ripple
- [ ] Geometria 9/9 · Texto 3/3 · Estilo OK · Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com o lado-a-lado `F03` anexado e inspecionado

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 3 concluída — aguardando sua aprovação para iniciar a FASE 4.`
