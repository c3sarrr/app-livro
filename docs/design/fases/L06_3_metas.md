# FASE L06 — Ajustes — Metas e lembretes: as duas metas com menos e mais, o lembrete com o horário e a proteção da sequência

> Tela 06 · prancha `006_ajustes` (06 · Ajustes (engrenagem), canvas 390×2400) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L06_3_metas@3x.png` · `docs/design/medicao/projeto/png/redline/L06_3_metas_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/006_ajustes_390x2400@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_006_ajustes.json` · `test/reference/projeto/reference_layout_006_ajustes.dart` (`kRef06`).
> Arquivos sugeridos: `lib/features/settings/presentation/sections/goals_section.dart`, `lib/core/design_system/widgets/app_switch.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Ajustes (06), Metas e lembretes: o cartão amarelo com a meta do ano (30 livros) e a diária (30 min), cada uma com menos e mais, o lembrete para ler (todos os dias, 21:00, ligado) e a proteção da sequência (1 dia de folga por semana).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`.

```html
<!-- Goals & reminders -->
<section aria-label="Metas e lembretes" style="margin-top: 34px; display: flex; flex-direction: column; gap: 12px;">
  <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px;">Metas e <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 27px; letter-spacing: -0.2px;">lembretes</span></h2>

  <div style="padding: 16px; border-radius: 26px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px;">
    <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;">
      <div style="padding: 12px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 4px;">
        <span style="font-size: 12.5px; font-weight: 700; color: #5B544B;">Meta do ano</span>
        <span style="display: flex; align-items: baseline; gap: 5px;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 32px; font-weight: 800; letter-spacing: -1px; line-height: 1;">30</span><span style="font-size: 13px; font-weight: 700;">livros</span></span>
        <span style="margin-top: 6px; display: flex; gap: 8px;">
          <button aria-label="Diminuir meta do ano" style="width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"><path d="M5 12h14"></path></svg></button>
          <button aria-label="Aumentar meta do ano" style="width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="2.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"></path></svg></button>
        </span>
      </div>
      <div style="padding: 12px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 4px;">
        <span style="font-size: 12.5px; font-weight: 700; color: #5B544B;">Meta diária</span>
        <span style="display: flex; align-items: baseline; gap: 5px;"><span style="font-family: 'Bricolage Grotesque', sans-serif; font-size: 32px; font-weight: 800; letter-spacing: -1px; line-height: 1;">30</span><span style="font-size: 13px; font-weight: 700;">min</span></span>
        <span style="margin-top: 6px; display: flex; gap: 8px;">
          <button aria-label="Diminuir meta diária" style="width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"><path d="M5 12h14"></path></svg></button>
          <button aria-label="Aumentar meta diária" style="width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="2.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"></path></svg></button>
        </span>
      </div>
    </div>

    <div style="padding: 12px 2px; display: flex; align-items: center; justify-content: space-between; gap: 12px; border-bottom: 1px solid rgba(26,23,20,0.16);">
      <span style="display: flex; flex-direction: column; gap: 2px;">
        <span style="font-size: 15px; font-weight: 700;">Lembrete para ler</span>
        <span style="font-size: 12.5px; font-weight: 600; color: #4A4030;">Todos os dias</span>
      </span>
      <span style="display: flex; align-items: center; gap: 8px;">
        <button aria-label="Horário do lembrete: 21h" style="height: 36px; padding: 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800; font-variant-numeric: tabular-nums;">21:00</button>
        <button role="switch" aria-checked="true" aria-label="Lembrete para ler" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
          <span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        </button>
      </span>
    </div>

    <div style="padding: 12px 2px 4px; display: flex; align-items: center; justify-content: space-between; gap: 12px;">
      <span style="display: flex; flex-direction: column; gap: 2px;">
        <span style="display: flex; align-items: center; gap: 6px; font-size: 15px; font-weight: 700;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="#FF552E" stroke="#1A1714" stroke-width="1.8" stroke-linejoin="round" aria-hidden="true"><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.07-2.14-.22-4.05 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.15.43-2.29 1-3a2.5 2.5 0 0 0 2.5 2.5z"></path></svg>
          Proteger minha sequência
        </span>
        <span style="font-size: 12.5px; font-weight: 600; color: #4A4030; line-height: 1.35;">1 dia de folga por semana sem zerar</span>
      </span>
      <button role="switch" aria-checked="true" aria-label="Proteger minha sequência" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
        <span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
      </button>
    </div>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `aj06.goals` — retângulo absoluto no canvas 390×2400: **x=20, y=1034.95, w=350, h=335.99**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `aj06.goals` | box | 0 | 0 | 350 | 335.99 | `margin-top: 34px; display: flex; flex-direction: column; gap: 12px` |  |
| 2 | `aj06.goals.title` | text | 0 | 0 | 350 | 35.1 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/normal peso 800 ls -0.5px #1A1714 |
| 3 | `aj06.goals.title.serif` ±1 | inline | 85.88 | 0 | 89.41 | 35.1 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 27px; letter-spacing: -0.2px` | Instrument Serif itálico 27/normal peso 400 ls -0.2px #1A1714 |
| 4 | `aj06.goals.card` | box | 0 | 47.1 | 350 | 288.88 | `padding: 16px; border-radius: 26px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; gap: 6px` |  |
| 5 | `aj06.goals.grid` | box | 17.5 | 64.6 | 315 | 128.01 | `display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px` |  |
| 6 | `aj06.goals.yearly` | box | 17.5 | 64.6 | 152.5 | 128.01 | `padding: 12px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 4px` |  |
| 7 | `aj06.goals.yearly.label` | text | 31 | 78.1 | 125.5 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #5B544B` | Figtree 12.5/normal peso 700 ls normal #5B544B |
| 8 | `aj06.goals.yearly.value` | box | 31 | 97.11 | 125.5 | 32 | `display: flex; align-items: baseline; gap: 5px` |  |
| 9 | `aj06.goals.yearly.value.number` ±1 | text | 31 | 97.11 | 38.16 | 32 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 32px; font-weight: 800; letter-spacing: -1px; line-height: 1` | Bricolage (opsz 32) 32/32px peso 800 ls -1px #1A1714 |
| 10 | `aj06.goals.yearly.value.unit` ±1 | text | 74.16 | 111.32 | 32.37 | 15.6 | `font-size: 13px; font-weight: 700` | Figtree 13/normal peso 700 ls normal #1A1714 |
| 11 | `aj06.goals.yearly.stepper` | box | 31 | 139.11 | 125.5 | 40 | `margin-top: 6px; display: flex; gap: 8px` |  |
| 12 | `aj06.goals.yearly.stepper.minus` | box | 31 | 139.11 | 40 | 40 | `width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 13 | `aj06.goals.yearly.stepper.minus.icon` | icon | 43 | 151.11 | 16 | 16 | `—` |  |
| 14 | `aj06.goals.yearly.stepper.plus` | box | 79 | 139.11 | 40 | 40 | `width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 15 | `aj06.goals.yearly.stepper.plus.icon` | icon | 91 | 151.11 | 16 | 16 | `—` |  |
| 16 | `aj06.goals.daily` | box | 180 | 64.6 | 152.5 | 128.01 | `padding: 12px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #1A1714; display: flex; flex-direction: column; gap: 4px` |  |
| 17 | `aj06.goals.daily.label` | text | 193.5 | 78.1 | 125.5 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #5B544B` | Figtree 12.5/normal peso 700 ls normal #5B544B |
| 18 | `aj06.goals.daily.value` | box | 193.5 | 97.11 | 125.5 | 32 | `display: flex; align-items: baseline; gap: 5px` |  |
| 19 | `aj06.goals.daily.value.number` ±1 | text | 193.5 | 97.11 | 38.16 | 32 | `font-family: 'Bricolage Grotesque', sans-serif; font-size: 32px; font-weight: 800; letter-spacing: -1px; line-height: 1` | Bricolage (opsz 32) 32/32px peso 800 ls -1px #1A1714 |
| 20 | `aj06.goals.daily.value.unit` ±1 | text | 236.66 | 111.32 | 22.13 | 15.6 | `font-size: 13px; font-weight: 700` | Figtree 13/normal peso 700 ls normal #1A1714 |
| 21 | `aj06.goals.daily.stepper` | box | 193.5 | 139.11 | 125.5 | 40 | `margin-top: 6px; display: flex; gap: 8px` |  |
| 22 | `aj06.goals.daily.stepper.minus` | box | 193.5 | 139.11 | 40 | 40 | `width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 23 | `aj06.goals.daily.stepper.minus.icon` | icon | 205.5 | 151.11 | 16 | 16 | `—` |  |
| 24 | `aj06.goals.daily.stepper.plus` | box | 241.5 | 139.11 | 40 | 40 | `width: 40px; height: 40px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 25 | `aj06.goals.daily.stepper.plus.icon` | icon | 253.5 | 151.11 | 16 | 16 | `—` |  |
| 26 | `aj06.goals.reminder` | box | 17.5 | 198.61 | 315 | 61 | `padding: 12px 2px; display: flex; align-items: center; justify-content: space-between; gap: 12px; border-bottom: 1px solid rgba(26,23,20,0.16)` |  |
| 27 | `aj06.goals.reminder.textBlock` ±1 | box | 19.5 | 211.11 | 122.1 | 35.01 | `display: flex; flex-direction: column; gap: 2px` |  |
| 28 | `aj06.goals.reminder.title` ±1 | text | 19.5 | 211.11 | 122.1 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 29 | `aj06.goals.reminder.body` ±1 | text | 19.5 | 231.11 | 122.1 | 15.01 | `font-size: 12.5px; font-weight: 600; color: #4A4030` | Figtree 12.5/normal peso 600 ls normal #4A4030 |
| 30 | `aj06.goals.reminder.controls` ±1 | box | 201.35 | 210.61 | 129.15 | 36 | `display: flex; align-items: center; gap: 8px` |  |
| 31 | `aj06.goals.reminder.time` ±1 | box+text | 201.35 | 210.61 | 67.15 | 36 | `height: 36px; padding: 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800; font-variant-numeric: tabular-nums` | Figtree 14/normal peso 800 ls normal #1A1714 tnum |
| 32 | `aj06.goals.reminder.switch` | box | 276.5 | 212.61 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 33 | `aj06.goals.reminder.switch.thumb` | box | 302.5 | 216.61 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 34 | `aj06.goals.reminder.switch.thumb.icon` | icon | 309 | 223.11 | 11 | 11 | `—` |  |
| 35 | `aj06.goals.streak` | box | 17.5 | 265.61 | 315 | 52.88 | `padding: 12px 2px 4px; display: flex; align-items: center; justify-content: space-between; gap: 12px` |  |
| 36 | `aj06.goals.streak.textBlock` ±1 | box | 19.5 | 277.61 | 201.56 | 36.88 | `display: flex; flex-direction: column; gap: 2px` |  |
| 37 | `aj06.goals.streak.title` ±1 | text | 19.5 | 277.61 | 201.56 | 18 | `display: flex; align-items: center; gap: 6px; font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 38 | `aj06.goals.streak.title.icon` | icon | 19.5 | 278.61 | 16 | 16 | `—` |  |
| 39 | `aj06.goals.streak.body` ±1 | text | 19.5 | 297.61 | 201.56 | 16.88 | `font-size: 12.5px; font-weight: 600; color: #4A4030; line-height: 1.35` | Figtree 12.5/16.875px peso 600 ls normal #4A4030 |
| 40 | `aj06.goals.streak.switch` | box | 276.5 | 280.05 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 41 | `aj06.goals.streak.switch.thumb` | box | 302.5 | 284.05 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 42 | `aj06.goals.streak.switch.thumb.icon` | icon | 309 | 290.55 | 11 | 11 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj06.goals.title` *(composto)* | 1 | Metas e lembretes | 26.73 | 0 | 175.29 | 175.29 |
| `aj06.goals.yearly.label` | 1 | Meta do ano | 89.98 | 31 | 101.89 | 70.89 |
| `aj06.goals.yearly.value.number` | 1 | 30 | 123.67 | 31 | 69.16 | 38.16 |
| `aj06.goals.yearly.value.unit` | 1 | livros | 123.67 | 74.16 | 106.53 | 32.37 |
| `aj06.goals.daily.label` | 1 | Meta diária | 89.98 | 193.5 | 257.68 | 64.18 |
| `aj06.goals.daily.value.number` | 1 | 30 | 123.67 | 193.5 | 231.66 | 38.16 |
| `aj06.goals.daily.value.unit` | 1 | min | 123.67 | 236.66 | 258.79 | 22.13 |
| `aj06.goals.reminder.title` | 1 | Lembrete para ler | 225.36 | 19.5 | 141.6 | 122.1 |
| `aj06.goals.reminder.body` | 1 | Todos os dias | 242.98 | 19.5 | 95.58 | 76.08 |
| `aj06.goals.reminder.time` | 1 | 21:00 | 233.51 | 214.85 | 255 | 40.15 |
| `aj06.goals.streak.title` | 1 | Proteger minha sequência | 291.86 | 41.5 | 221.03 | 179.53 |
| `aj06.goals.streak.body` | 1 | 1 dia de folga por semana sem zerar | 310.42 | 19.5 | 221.06 | 201.56 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Metas e" Bricolage 22/800 + "lembretes" Instrument Serif 27; o cartão: padding 16, raio 26, `#FED170`, borda 1,5, sombra 4/4, gap 6.
2. Metas em grade de 2 (gap 10): padding 12, raio 18, `#FFFAF1`, borda 1,5; o rótulo 12,5/700 `#5B544B`, o número Bricolage 32/800 ls −1 `lh 1` com a unidade 13/700 pela base e, 6 abaixo, o menos (40, `#FFFAF1`) e o mais (40, preto, o "+" `#FFFAF1`).
3. Lembrete: padding 12/2, o fio de 1 preto a 0,16 embaixo; "Lembrete para ler" 15/700 + "Todos os dias" 12,5/600 `#4A4030`; à direita (gap 8) o horário numa pílula de 36 (14/800 `tnum`) e a chave.
4. Sequência: padding 12/2/4; o fogo coral 16 + "Proteger minha sequência" 15/700 e "1 dia de folga por semana sem zerar" 12,5/600 `lh 1,35`; a chave.
5. A chave dos Ajustes e dos Lembretes (`role="switch"`): 54 × 32, raio cheio, borda 1,5; ligada, o trilho `{{brand}}` e a bolinha `#FFFAF1` de 24 (borda 1,5) a 2,5 da direita, com o visto de 11 (traço 3,6). É um dos dois desenhos de chave da T17 — o outro está na Conta e na Privacidade (52 × 32, sem visto).
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As chaves têm dois desenhos na T17 (54 × 32 com o visto nos Ajustes e nos Lembretes; 52 × 32 sem visto, trilho preto, na Conta e na Privacidade): no app, um widget com as duas variantes (`core/design_system/widgets/app_switch.dart`), cada tela com a sua, como a prancha. Unificar seria melhoria além do design (ROTEIRO §2b): só como proposta, com "Manter igual ao design".
- O horário usa algarismos tabulares (`tnum`): `withTabularFigures()` (D-282).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_006_ajustes_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_006_ajustes_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `aj06.goals` |  | Metas e lembretes |  |
| `aj06.goals.yearly.stepper.minus` |  | Diminuir meta do ano |  |
| `aj06.goals.yearly.stepper.plus` |  | Aumentar meta do ano |  |
| `aj06.goals.daily.stepper.minus` |  | Diminuir meta diária |  |
| `aj06.goals.daily.stepper.plus` |  | Aumentar meta diária |  |
| `aj06.goals.reminder.time` |  | Horário do lembrete: 21h |  |
| `aj06.goals.reminder.switch` | switch | Lembrete para ler | aria-checked=true |
| `aj06.goals.reminder.switch.thumb.icon` |  |  | aria-hidden=true |
| `aj06.goals.streak.title.icon` |  |  | aria-hidden=true |
| `aj06.goals.streak.switch` | switch | Proteger minha sequência | aria-checked=true |
| `aj06.goals.streak.switch.thumb.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `aj06.goals.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `aj06.goals.card` | NeoBox |  |
| `aj06.goals.yearly` | NeoBox |  |
| `aj06.goals.yearly.stepper.minus` | CircleIconButton / NeoBox circular |  |
| `aj06.goals.yearly.stepper.minus.icon` | AppSvg(AppIconsPerfil.minusStepper, size: 16) |  |
| `aj06.goals.yearly.stepper.plus` | CircleIconButton / NeoBox circular |  |
| `aj06.goals.yearly.stepper.plus.icon` | AppSvg(AppIconsPerfil.plusStepperCreme, size: 16) |  |
| `aj06.goals.daily` | NeoBox |  |
| `aj06.goals.daily.stepper.minus` | CircleIconButton / NeoBox circular |  |
| `aj06.goals.daily.stepper.minus.icon` | AppSvg(AppIconsPerfil.minusStepper, size: 16) |  |
| `aj06.goals.daily.stepper.plus` | CircleIconButton / NeoBox circular |  |
| `aj06.goals.daily.stepper.plus.icon` | AppSvg(AppIconsPerfil.plusStepperCreme, size: 16) |  |
| `aj06.goals.reminder` | NeoBox |  |
| `aj06.goals.reminder.time` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj06.goals.reminder.switch` | NeoBox |  |
| `aj06.goals.reminder.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `aj06.goals.reminder.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |
| `aj06.goals.streak.title.icon` | AppSvg(AppIconsPerfil.flameFilledCoral, size: 16) |  |
| `aj06.goals.streak.switch` | NeoBox |  |
| `aj06.goals.streak.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `aj06.goals.streak.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |

## Interações

- Menos e mais → mudam a meta (do ano: o passo e os limites da 12, da T16; diária: 5 a 600, o passo é pergunta da T17); o valor grava na hora.
- Horário → o relógio do sistema para trocar (como na 30b).
- Chave do lembrete → liga ou desliga o lembrete (o mesmo da 30b). Chave da sequência → a regra da folga.

## Dados

- As metas são as de `ReadingGoals` (a diária já existe; a do ano é o campo da 12, da T16).
- O lembrete é o mesmo da 30b: aqui a prancha diz "Todos os dias" e 21:00, e a 30b diz 21:30 sem o sábado. No app é um lembrete só — as duas telas mostram o mesmo dado; a fixture de cada prancha segue a prancha (D-34) e a coerência (D-88) é pergunta da T17. O texto dos dias ("Todos os dias", "Dias úteis", a lista) é pergunta da T17.
- A proteção da sequência é regra nova (a sequência não zera com 1 dia sem ler por semana): pergunta da T17.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L06.1** Cartão: as duas metas com menos e mais
- **L06.2** Lembrete com o horário e a chave
- **L06.3** Proteger a sequência
- **L06.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('aj06.goals'), todos os ids de `kRef06.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/006_ajustes_390x2400@3x.png` no recorte da fase (y 1026.95–1378.94) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef06w360` e `kRef06w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L06.1 Cartão: as duas metas com menos e mais
- [ ] L06.2 Lembrete com o horário e a chave
- [ ] L06.3 Proteger a sequência
- [ ] L06.4 Verificação + relatório
- [ ] Geometria 41/41 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
