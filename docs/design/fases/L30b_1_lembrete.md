# FASE L30b — Lembretes e avisos — o lembrete de leitura (horário, dias, só se não leu, a prévia do aviso)

> Tela 30b · prancha `030b_notificacoes_ajustes` (30b · Lembretes e avisos (ajustes), canvas 390×1330) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L30b_1_lembrete@3x.png` · `docs/design/medicao/projeto/png/redline/L30b_1_lembrete_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/030b_notificacoes_ajustes_390x1330@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_030b_notificacoes_ajustes.json` · `test/reference/projeto/reference_layout_030b_notificacoes_ajustes.dart` (`kRef30b`).
> Arquivos sugeridos: `lib/features/notifications/presentation/reminders_screen.dart`, `lib/core/design_system/widgets/app_switch.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Lembretes e avisos (30b), em cima: o voltar, "Lembretes sem pressão." e o cartão do lembrete de leitura — a chave, o horário 21:30, os dias da semana (sábado desligado), "Só se eu ainda não li hoje" e a prévia de como o aviso chega.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="position: absolute; left: 16px; right: 16px; top: 54px; display: flex; justify-content: space-between;">
  <a href="#" aria-label="Voltar" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg></a>
</div>

<h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 0.98; letter-spacing: -1.1px;">Lembretes<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; letter-spacing: -0.4px;">sem pressão.</span></h1>

<!-- reading reminder -->
<section aria-label="Lembrete de leitura" style="margin-top: 14px; padding: 16px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; margin-top: 18px;">
  <div style="display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path></svg></span><span style="min-width: 0; flex-grow: 1;"><span id="nt-read" style="display: block; font-size: 16px; font-weight: 800;">Lembrete de leitura</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">No máximo um por dia</span></span><button type="button" role="switch" aria-checked="true" aria-labelledby="nt-read" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;"><span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></button></div>

  <div style="margin-top: 14px; display: flex; gap: 10px; align-items: center;">
    <span style="height: 56px; padding: 0 14px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; letter-spacing: -0.5px; font-variant-numeric: tabular-nums;">21:30</span>
    <span style="font-size: 13px; font-weight: 600; line-height: 1.35; color: #5B544B;">Tocar no horário abre o relógio para trocar.</span>
  </div>
  <div style="margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">EM QUAIS DIAS</div>
  <div role="group" aria-label="Dias do lembrete" style="margin-top: 8px; display: flex; justify-content: space-between;"><button role="checkbox" aria-checked="true" aria-label="segunda" style="width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}}; font-size: 13px; font-weight: 800;">S</button><button role="checkbox" aria-checked="true" aria-label="terça" style="width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}}; font-size: 13px; font-weight: 800;">T</button><button role="checkbox" aria-checked="true" aria-label="quarta" style="width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}}; font-size: 13px; font-weight: 800;">Q</button><button role="checkbox" aria-checked="true" aria-label="quinta" style="width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}}; font-size: 13px; font-weight: 800;">Q</button><button role="checkbox" aria-checked="true" aria-label="sexta" style="width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}}; font-size: 13px; font-weight: 800;">S</button><button role="checkbox" aria-checked="false" aria-label="sábado" style="width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FFFAF1; color: #8A8073; font-size: 13px; font-weight: 800;">S</button><button role="checkbox" aria-checked="true" aria-label="domingo" style="width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}}; font-size: 13px; font-weight: 800;">D</button></div>

  <div style="margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: flex; align-items: center; gap: 12px;">
    <span style="min-width: 0; flex-grow: 1;"><span id="nt-smart" style="display: block; font-size: 14.5px; font-weight: 800;">Só se eu ainda não li hoje</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B;">Bateu a meta? O lembrete nem aparece.</span></span><button type="button" role="switch" aria-checked="true" aria-labelledby="nt-smart" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;"><span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></button>
  </div>

  <!-- preview of the push -->
  <div style="margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">VAI APARECER ASSIM</div>
  <div aria-label="Prévia do aviso" style="margin-top: 8px; padding: 11px 12px; border-radius: 18px; background: #F1E7D5; border: 1.5px solid #1A1714; display: flex; gap: 10px; align-items: flex-start;">
    <span aria-hidden="true" style="width: 34px; height: 34px; flex-shrink: 0; border-radius: 10px; background: #1A1714; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 15px; color: #FED170;">B</span>
    <span style="min-width: 0; flex-grow: 1;"><span style="display: flex; justify-content: space-between; font-size: 12px; font-weight: 700; color: #6F665B;"><span>BookNest</span><span>21:30</span></span>
    <span style="display: block; margin-top: 2px; font-size: 14px; font-weight: 800;">Faltam 12 min para a meta</span>
    <span style="display: block; margin-top: 1px; font-size: 13px; font-weight: 600; color: #5B544B;">Um capítulo de Brás Cubas antes de dormir?</span></span>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `n30b.top` — retângulo absoluto no canvas 390×1330: **x=16, y=54, w=358, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `n30b.top` | box | 0 | 0 | 358 | 48 | `position: absolute; left: 16px; right: 16px; top: 54px; display: flex; justify-content: space-between` |  |
| 2 | `n30b.top.back` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `n30b.top.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |

Seção `n30b.headline` — retângulo absoluto no canvas 390×1330: **x=16, y=122, w=358, h=78.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `n30b.headline` | text | 0 | 0 | 358 | 78.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 36) 36/35.28px peso 800 ls -1.1px #1A1714 |
| 5 | `n30b.headline.serif` ±1 | inline | 0 | 28.24 | 188.54 | 57.2 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; letter-spacing: -0.4px` | Instrument Serif itálico 44/43.12px peso 400 ls -0.4px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30b.headline` *(composto)* | 1 | Lembretes | 29.52 | 0 | 175.23 | 175.23 |
| `n30b.headline` *(composto)* | 2 | sem pressão. | 71.8 | 0 | 188.54 | 188.54 |

Seção `n30b.reading` — retângulo absoluto no canvas 390×1330: **x=16, y=218.4, w=358, h=405.58**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `n30b.reading` | box | 0 | 0 | 358 | 405.58 | `margin-top: 14px; padding: 16px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; margin-top: 18px` |  |
| 7 | `n30b.reading.head` | box | 17.5 | 17.5 | 323 | 38 | `display: flex; align-items: center; gap: 12px` |  |
| 8 | `n30b.reading.head.icon` | box | 17.5 | 17.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 9 | `n30b.reading.head.icon.art` | icon | 26.5 | 26.5 | 20 | 20 | `—` |  |
| 10 | `n30b.reading.head.textBlock` | box | 67.5 | 18.39 | 207 | 36.21 | `min-width: 0; flex-grow: 1` |  |
| 11 | `n30b.reading.head.title` | text | 67.5 | 18.39 | 207 | 19.2 | `display: block; font-size: 16px; font-weight: 800` | Figtree 16/normal peso 800 ls normal #1A1714 |
| 12 | `n30b.reading.head.body` | text | 67.5 | 39.59 | 207 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 13 | `n30b.reading.head.switch` | box | 286.5 | 20.5 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 14 | `n30b.reading.head.switch.thumb` | box | 312.5 | 24.5 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 15 | `n30b.reading.head.switch.thumb.icon` | icon | 319 | 31 | 11 | 11 | `—` |  |
| 16 | `n30b.reading.time` | box | 17.5 | 69.5 | 323 | 56 | `margin-top: 14px; display: flex; gap: 10px; align-items: center` |  |
| 17 | `n30b.reading.time.value` ±1 | box+text | 17.5 | 69.5 | 105.22 | 56 | `height: 56px; padding: 0 14px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; letter-spacing: -0.5px; font-variant-numeric: tabular-nums` | Bricolage (opsz 28) 28/normal peso 800 ls -0.5px #1A1714 tnum |
| 18 | `n30b.reading.time.hint` ±1 | text | 132.72 | 79.95 | 207.78 | 35.1 | `font-size: 13px; font-weight: 600; line-height: 1.35; color: #5B544B` | Figtree 13/17.55px peso 600 ls normal #5B544B |
| 19 | `n30b.reading.daysLabel` | text | 17.5 | 139.5 | 323 | 13.2 | `margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 20 | `n30b.reading.days` | box | 17.5 | 160.7 | 323 | 38 | `margin-top: 8px; display: flex; justify-content: space-between` |  |
| 21 | `n30b.reading.days.mon` | box+text | 17.5 | 160.7 | 38 | 38 | `width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}} (padrão #B6ACE4); font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 22 | `n30b.reading.days.tue` | box+text | 65 | 160.7 | 38 | 38 | `width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}} (padrão #B6ACE4); font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 23 | `n30b.reading.days.wed` | box+text | 112.5 | 160.7 | 38 | 38 | `width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}} (padrão #B6ACE4); font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 24 | `n30b.reading.days.thu` | box+text | 160 | 160.7 | 38 | 38 | `width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}} (padrão #B6ACE4); font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 25 | `n30b.reading.days.fri` | box+text | 207.5 | 160.7 | 38 | 38 | `width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}} (padrão #B6ACE4); font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 26 | `n30b.reading.days.sat` | box+text | 255 | 160.7 | 38 | 38 | `width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FFFAF1; color: #8A8073; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #8A8073 |
| 27 | `n30b.reading.days.sun` | box+text | 302.5 | 160.7 | 38 | 38 | `width: 38px; height: 38px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: {{brand}} (padrão #B6ACE4); font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 28 | `n30b.reading.smart` | box | 17.5 | 212.7 | 323 | 49.78 | `margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: flex; align-items: center; gap: 12px` |  |
| 29 | `n30b.reading.smart.textBlock` | box | 17.5 | 226.2 | 257 | 36.28 | `min-width: 0; flex-grow: 1` |  |
| 30 | `n30b.reading.smart.title` | text | 17.5 | 226.2 | 257 | 17.41 | `display: block; font-size: 14.5px; font-weight: 800` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 31 | `n30b.reading.smart.body` | text | 17.5 | 245.61 | 257 | 16.88 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B` | Figtree 12.5/16.875px peso 600 ls normal #6F665B |
| 32 | `n30b.reading.smart.switch` | box | 286.5 | 228.34 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 33 | `n30b.reading.smart.switch.thumb` | box | 312.5 | 232.34 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 34 | `n30b.reading.smart.switch.thumb.icon` | icon | 319 | 238.84 | 11 | 11 | `—` |  |
| 35 | `n30b.reading.previewLabel` | text | 17.5 | 276.49 | 323 | 13.2 | `margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 36 | `n30b.reading.preview` | box | 17.5 | 297.69 | 323 | 90.4 | `margin-top: 8px; padding: 11px 12px; border-radius: 18px; background: #F1E7D5; border: 1.5px solid #1A1714; display: flex; gap: 10px; align-items: flex-start` |  |
| 37 | `n30b.reading.preview.appIcon` | box+text | 31 | 310.19 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; border-radius: 10px; background: #1A1714; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 15px; color: #FED170` | Bricolage (opsz 15) 15/normal peso 800 ls normal #FED170 |
| 38 | `n30b.reading.preview.textBlock` | box | 75 | 310.19 | 252 | 65.4 | `min-width: 0; flex-grow: 1` |  |
| 39 | `n30b.reading.preview.meta` | box | 75 | 310.19 | 252 | 14.4 | `display: flex; justify-content: space-between; font-size: 12px; font-weight: 700; color: #6F665B` |  |
| 40 | `n30b.reading.preview.meta.app` ±1 | text | 75 | 310.19 | 54.08 | 14.4 | `—` | Figtree 12/normal peso 700 ls normal #6F665B |
| 41 | `n30b.reading.preview.meta.time` ±1 | text | 296.93 | 310.19 | 30.07 | 14.4 | `—` | Figtree 12/normal peso 700 ls normal #6F665B |
| 42 | `n30b.reading.preview.title` | text | 75 | 326.59 | 252 | 16.8 | `display: block; margin-top: 2px; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 43 | `n30b.reading.preview.body` | text | 75 | 344.38 | 252 | 31.2 | `display: block; margin-top: 1px; font-size: 13px; font-weight: 600; color: #5B544B` | Figtree 13/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30b.reading.head.title` | 1 | Lembrete de leitura | 33.6 | 67.5 | 213.95 | 146.45 |
| `n30b.reading.head.body` | 1 | No máximo um por dia | 51.48 | 67.5 | 195.55 | 128.05 |
| `n30b.reading.time.value` | 1 | 21:30 | 106.74 | 33 | 107.22 | 74.22 |
| `n30b.reading.time.hint` | 1 | Tocar no horário abre o relógio | 93.27 | 132.72 | 312.92 | 180.2 |
| `n30b.reading.time.hint` | 2 | para trocar. | 110.82 | 132.72 | 200.96 | 68.24 |
| `n30b.reading.daysLabel` | 1 | EM QUAIS DIAS | 149.95 | 17.5 | 114.3 | 96.8 |
| `n30b.reading.days.mon` | 1 | S | 184.25 | 32.58 | 40.42 | 7.84 |
| `n30b.reading.days.tue` | 1 | T | 184.25 | 80.11 | 87.89 | 7.78 |
| `n30b.reading.days.wed` | 1 | Q | 184.25 | 126.34 | 136.66 | 10.32 |
| `n30b.reading.days.thu` | 1 | Q | 184.25 | 173.84 | 184.16 | 10.32 |
| `n30b.reading.days.fri` | 1 | S | 184.25 | 222.58 | 230.42 | 7.84 |
| `n30b.reading.days.sat` | 1 | S | 184.25 | 270.08 | 277.92 | 7.84 |
| `n30b.reading.days.sun` | 1 | D | 184.25 | 316.92 | 326.08 | 9.16 |
| `n30b.reading.smart.title` | 1 | Só se eu ainda não li hoje | 239.98 | 17.5 | 184.74 | 167.24 |
| `n30b.reading.smart.body` | 1 | Bateu a meta? O lembrete nem aparece. | 258.42 | 17.5 | 244.81 | 227.31 |
| `n30b.reading.previewLabel` | 1 | VAI APARECER ASSIM | 286.93 | 17.5 | 154.86 | 137.36 |
| `n30b.reading.preview.appIcon` | 1 | B | 332.13 | 42.82 | 53.18 | 10.36 |
| `n30b.reading.preview.meta.app` | 1 | BookNest | 321.59 | 75 | 129.08 | 54.08 |
| `n30b.reading.preview.meta.time` | 1 | 21:30 | 321.59 | 296.93 | 327 | 30.07 |
| `n30b.reading.preview.title` | 1 | Faltam 12 min para a meta | 339.88 | 75 | 244.27 | 169.27 |
| `n30b.reading.preview.body` | 1 | Um capítulo de Brás Cubas antes de | 356.73 | 75 | 287.02 | 212.02 |
| `n30b.reading.preview.body` | 2 | dormir? | 372.34 | 75 | 120.77 | 45.77 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O voltar como o das Notificações (`left 16 · top 54`, sombra 2/2), sem os outros dois botões; "Lembretes" Bricolage 36/800 + quebra + "sem pressão." Instrument Serif 44.
2. Cartão 18 abaixo: padding 16, raio 24, `#FFFAF1`, borda 1,5, sombra 3/3; a cabeça com o quadrado 38 de raio 12 `#FED170`, "Lembrete de leitura" 16/800 + "No máximo um por dia" 12,5/600 `#6F665B` e a chave.
3. Horário 14 abaixo: a caixa de 56 (padding 0/14, raio 16, `#F7F0E3`, borda 1,5, Bricolage 28/800 ls −0,5 `tnum`) e, ao lado, "Tocar no horário abre o relógio para trocar." 13/600.
4. "EM QUAIS DIAS" 11/800 ls 1,2, 14 abaixo; os 7 dias (`group`, `space-between`, 8 abaixo): círculos 38 (borda 1,5, 13/800), marcados em `{{brand}}`.
5. O "Só se eu ainda não li hoje" (o tracejado 1,5 `#CFC3AE` em cima, padding 12/0/0) com a chave; "VAI APARECER ASSIM" e a prévia (padding 11/12, raio 18, `#F1E7D5`, borda 1,5): o "B" num quadrado preto 34 de raio 10, "BookNest" e "21:30" 12/700, o título 14/800 e o texto 13/600.
6. A chave dos Ajustes e dos Lembretes (`role="switch"`): 54 × 32, raio cheio, borda 1,5; ligada, o trilho `{{brand}}` e a bolinha `#FFFAF1` de 24 (borda 1,5) a 2,5 da direita, com o visto de 11 (traço 3,6). É um dos dois desenhos de chave da T17 — o outro está na Conta e na Privacidade (52 × 32, sem visto).
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As chaves têm dois desenhos na T17 (54 × 32 com o visto nos Ajustes e nos Lembretes; 52 × 32 sem visto, trilho preto, na Conta e na Privacidade): no app, um widget com as duas variantes (`core/design_system/widgets/app_switch.dart`), cada tela com a sua, como a prancha. Unificar seria melhoria além do design (ROTEIRO §2b): só como proposta, com "Manter igual ao design".
- A seção declara `margin-top` duas vezes (14 e 18): vale a última, 18.
- O horário e os dias são `<span>`/`button` no HTML, mas o horário não é botão: no app ele é o alvo que abre o relógio, com a semântica de botão.
- Os dias usam `aria-labelledby` e rótulos por extenso ("segunda"…): no app, `Semantics(label:)` com o nome do dia, não a letra.
- A 360 a descrição do "Só se eu ainda não li hoje" fica num fio de navalha (0,31 com a próxima palavra, abaixo).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_030b_notificacoes_ajustes_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_030b_notificacoes_ajustes_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `n30b.reading.smart.body` linha 1 «Bateu a meta? O lembrete nem»: sobra 51.28 px · estouro com a próxima palavra 0.31 px.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `n30b.top.back` |  | Voltar |  |
| `n30b.top.back.icon` |  |  | aria-hidden=true |
| `n30b.reading` |  | Lembrete de leitura |  |
| `n30b.reading.head.icon` |  |  | aria-hidden=true |
| `n30b.reading.head.icon.art` |  |  | aria-hidden=true |
| `n30b.reading.head.switch` | switch |  | aria-checked=true, aria-labelledby=nt-read |
| `n30b.reading.head.switch.thumb.icon` |  |  | aria-hidden=true |
| `n30b.reading.days` | group | Dias do lembrete |  |
| `n30b.reading.days.mon` | checkbox | segunda | aria-checked=true |
| `n30b.reading.days.tue` | checkbox | terça | aria-checked=true |
| `n30b.reading.days.wed` | checkbox | quarta | aria-checked=true |
| `n30b.reading.days.thu` | checkbox | quinta | aria-checked=true |
| `n30b.reading.days.fri` | checkbox | sexta | aria-checked=true |
| `n30b.reading.days.sat` | checkbox | sábado | aria-checked=false |
| `n30b.reading.days.sun` | checkbox | domingo | aria-checked=true |
| `n30b.reading.smart.switch` | switch |  | aria-checked=true, aria-labelledby=nt-smart |
| `n30b.reading.smart.switch.thumb.icon` |  |  | aria-hidden=true |
| `n30b.reading.preview` |  | Prévia do aviso |  |
| `n30b.reading.preview.appIcon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `n30b.top.back` | CircleIconButton / NeoBox circular |  |
| `n30b.top.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `n30b.headline.serif` | TextSpan dentro do AppText.rich do pai |  |
| `n30b.reading` | NeoBox |  |
| `n30b.reading.head.icon` | NeoBox |  |
| `n30b.reading.head.icon.art` | AppSvg(AppIconsPerfil.stopwatchFino, size: 20) |  |
| `n30b.reading.head.switch` | NeoBox |  |
| `n30b.reading.head.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.head.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |
| `n30b.reading.time.value` | NeoBox + AppText |  |
| `n30b.reading.days.mon` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.days.tue` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.days.wed` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.days.thu` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.days.fri` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.days.sat` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.days.sun` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.smart` | NeoBox |  |
| `n30b.reading.smart.switch` | NeoBox |  |
| `n30b.reading.smart.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `n30b.reading.smart.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |
| `n30b.reading.preview` | NeoBox |  |
| `n30b.reading.preview.appIcon` | NeoBox + AppText |  |

## Interações

- Voltar → as Notificações (30) ou os Ajustes (06), de onde veio.
- Chave do lembrete → liga ou desliga (o mesmo lembrete da 06).
- Horário → o relógio do sistema (`showTimePicker`) para trocar.
- Dias → marca e desmarca cada dia (o mínimo de dias marcados é pergunta da T17).
- Só se eu ainda não li hoje → com a meta batida no dia, o aviso não sai.

## Dados

- O lembrete (ligado, horário, dias, só se não leu) é novo: agendado como aviso local (pacote novo, pergunta da T17), no máximo um por dia.
- A prévia usa o texto de verdade do aviso: o que falta para a meta de hoje e o último livro de papel.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L30b.1** Voltar e título
- **L30b.2** Cartão: cabeça com a chave e o horário
- **L30b.3** Dias da semana
- **L30b.4** Só se não leu e a prévia do aviso
- **L30b.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('n30b.top', 'n30b.headline', 'n30b.reading'), todos os ids de `kRef30b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/030b_notificacoes_ajustes_390x1330@3x.png` no recorte da fase (y 46–631.98) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef30bw360` e `kRef30bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L30b.1 Voltar e título
- [ ] L30b.2 Cartão: cabeça com a chave e o horário
- [ ] L30b.3 Dias da semana
- [ ] L30b.4 Só se não leu e a prévia do aviso
- [ ] L30b.5 Verificação + relatório
- [ ] Geometria 42/42 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
