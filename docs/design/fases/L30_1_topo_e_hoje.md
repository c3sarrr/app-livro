# FASE L30 — Notificações — o topo, o título, o resumo e os avisos de hoje (dois em cartão, não lidos)

> Tela 30 · prancha `030_notificacoes` (30 · Notificações (sino da Início), canvas 390×1180) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L30_1_topo_e_hoje@3x.png` · `docs/design/medicao/projeto/png/redline/L30_1_topo_e_hoje_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/030_notificacoes_390x1180@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_030_notificacoes.json` · `test/reference/projeto/reference_layout_030_notificacoes.dart` (`kRef30`).
> Arquivos sugeridos: `lib/features/notifications/presentation/notifications_screen.dart`, `lib/features/notifications/presentation/notifications_top_bar.dart`, `lib/features/notifications/presentation/notification_tile.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Notificações (30), em cima: o topo (voltar, marcar tudo como lido, engrenagem), a estrelinha rosa, "Novidades por aqui.", "2 novas · domingo, 20 de setembro" e os avisos de Hoje — dois não lidos em cartão (o clube, o lembrete com "Ler agora") e dois lidos (o selo novo, as curtidas com avatares). A tela entra no lugar do placeholder de `/notificacoes`.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="position: absolute; left: 16px; right: 16px; top: 54px; display: flex; justify-content: space-between; gap: 8px;">
  <a href="#" aria-label="Voltar" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg></a>
  <span style="display: flex; gap: 8px;">
    <button aria-label="Marcar tudo como lido" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m2 12.5 4.5 4.5L15 8.5"></path><path d="m10.5 16.5.5.5L21.5 6.5"></path></svg></button>
    <a href="#" aria-label="Ajustes de lembretes e avisos" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"></path></svg></a>
  </span>
</div>

<svg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24" style="position: absolute; left: 318px; top: 140px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFC1C6" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg>

<h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 0.98; letter-spacing: -1.1px;">Novidades<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; letter-spacing: -0.4px;">por aqui.</span></h1>

<p style="margin: 8px 0 0; font-size: 14px; font-weight: 600; color: #5B544B;"><strong style="color: #1A1714; font-weight: 800;">2 novas</strong> · domingo, 20 de setembro</p>

<h2 style="margin: 18px 0 10px; display: flex; align-items: center; gap: 10px; font-size: 11.5px; font-weight: 800; letter-spacing: 1.3px; color: #6F665B;">HOJE<span aria-hidden="true" style="flex-grow: 1; border-top: 1.5px dashed #CFC3AE;"></span></h2>

<ul>
  <li><a href="#" style="margin-top: 10px; padding: 12px 12px 12px 12px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; display: flex; gap: 12px; align-items: flex-start;">
    <span aria-hidden="true" style="position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg></span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: flex; align-items: baseline; gap: 8px;"><span style="min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Leitoras de Capitu · 3 mensagens</span><span style="display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap;">20 min<span aria-label="não lida" style="width: 9px; height: 9px; border-radius: 50%; background: #FF552E; border: 1.2px solid #1A1714; flex-shrink: 0;"></span></span></span>
      <span style="display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;"><strong style="color: #1A1714; font-weight: 800;">Júlia:</strong> “Alguém já chegou na parte do Seminário?”</span>
    </span>
  </a></li>
  <li><a href="#" style="margin-top: 10px; padding: 12px 12px 12px 12px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; display: flex; gap: 12px; align-items: flex-start;">
    <span aria-hidden="true" style="position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path></svg></span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: flex; align-items: baseline; gap: 8px;"><span style="min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Faltam 12 min para a meta de hoje</span><span style="display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap;">1 h<span aria-label="não lida" style="width: 9px; height: 9px; border-radius: 50%; background: #FF552E; border: 1.2px solid #1A1714; flex-shrink: 0;"></span></span></span>
      <span style="display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;">Um capítulo de Brás Cubas antes de dormir?</span><span style="margin-top: 10px; height: 36px; padding: 0 14px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 13px; font-weight: 800; background: #1A1714; color: #F7F0E3;">Ler agora</span>
    </span>
  </a></li>
  <li><a href="#" style="padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start;">
    <span aria-hidden="true" style="position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="24" height="24" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg></span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: flex; align-items: baseline; gap: 8px;"><span style="min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Selo novo: 12 dias seguidos</span><span style="display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap;">3 h</span></span>
      <span style="display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;">Já está na sua carteirinha e no perfil.</span>
    </span>
  </a></li>
  <li><a href="#" style="padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start;">
    <span aria-hidden="true" style="position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10z"></path></svg></span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: flex; align-items: baseline; gap: 8px;"><span style="min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3;">Pedro e mais 4 curtiram sua resenha</span><span style="display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap;">5 h</span></span>
      <span style="display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;"><span style="display: inline-flex; vertical-align: middle; margin-right: 6px;"><span style="width: 22px; height: 22px; margin-left: 0; border-radius: 50%; background: #B6ACE4; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800;">P</span><span style="width: 22px; height: 22px; margin-left: -6px; border-radius: 50%; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800;">J</span><span style="width: 22px; height: 22px; margin-left: -6px; border-radius: 50%; background: #ABCF82; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800;">L</span></span>Quincas Borba</span>
    </span>
  </a></li>
</ul>
```

## Especificação pixel a pixel

Seção `n30.top` — retângulo absoluto no canvas 390×1180: **x=16, y=54, w=358, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `n30.top` | box | 0 | 0 | 358 | 48 | `position: absolute; left: 16px; right: 16px; top: 54px; display: flex; justify-content: space-between; gap: 8px` |  |
| 2 | `n30.top.back` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `n30.top.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |
| 4 | `n30.top.actions` | box | 254 | 0 | 104 | 48 | `display: flex; gap: 8px` |  |
| 5 | `n30.top.markRead` | box | 254 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 6 | `n30.top.markRead.icon` | icon | 267.5 | 13.5 | 21 | 21 | `—` |  |
| 7 | `n30.top.settings` | box | 310 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 8 | `n30.top.settings.icon` | icon | 324 | 14 | 20 | 20 | `—` |  |

Seção `n30.sparkle` — retângulo absoluto no canvas 390×1180: **x=318, y=140, w=24, h=24**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 9 | `n30.sparkle` | icon | 0 | 0 | 24 | 24 | `position: absolute; left: 318px; top: 140px` |  |

Seção `n30.headline` — retângulo absoluto no canvas 390×1180: **x=16, y=122, w=358, h=78.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 10 | `n30.headline` | text | 0 | 0 | 358 | 78.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 36) 36/35.28px peso 800 ls -1.1px #1A1714 |
| 11 | `n30.headline.serif` ±1 | inline | 0 | 28.24 | 142.3 | 57.2 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; letter-spacing: -0.4px` | Instrument Serif itálico 44/43.12px peso 400 ls -0.4px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30.headline` *(composto)* | 1 | Novidades | 29.52 | 0 | 175.56 | 175.56 |
| `n30.headline` *(composto)* | 2 | por aqui. | 71.8 | 0 | 142.3 | 142.3 |

Seção `n30.summary` — retângulo absoluto no canvas 390×1180: **x=16, y=208.4, w=358, h=16.8**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 12 | `n30.summary` | text | 0 | 0 | 358 | 16.8 | `margin: 8px 0 0; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 13 | `n30.summary.count` ±1 | inline | 0 | 0 | 49.35 | 16.8 | `color: #1A1714; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30.summary` *(composto)* | 1 | 2 novas · domingo, 20 de setembro | 13.3 | 0 | 223.62 | 223.62 |

Seção `n30.today` — retângulo absoluto no canvas 390×1180: **x=16, y=243.2, w=358, h=391.46**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 14 | `n30.today.label` | text | 0 | 0 | 358 | 13.81 | `margin: 18px 0 10px; display: flex; align-items: center; gap: 10px; font-size: 11.5px; font-weight: 800; letter-spacing: 1.3px; color: #6F665B` | Figtree 11.5/normal peso 800 ls 1.3px #6F665B |
| 15 | `n30.today.label.rule` ±1 | box | 46.23 | 6.16 | 311.77 | 1.5 | `flex-grow: 1; border-top: 1.5px dashed #CFC3AE` |  |
| 16 | `n30.today.list` | box | 0 | 23.81 | 358 | 367.65 | `—` |  |
| 17 | `n30.today.list.item1` | box | 0 | 23.81 | 358 | 105.5 | `—` |  |
| 18 | `n30.today.list.item1.card` | box | 0 | 23.81 | 358 | 105.5 | `margin-top: 10px; padding: 12px 12px 12px 12px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; display: flex; gap: 12px; align-items: flex-start` |  |
| 19 | `n30.today.list.item1.icon` | box | 13.5 | 37.31 | 44 | 44 | `position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 20 | `n30.today.list.item1.icon.art` | icon | 24.5 | 48.31 | 22 | 22 | `—` |  |
| 21 | `n30.today.list.item1.textBlock` | box | 69.5 | 37.31 | 275 | 78.5 | `min-width: 0; flex-grow: 1` |  |
| 22 | `n30.today.list.item1.head` | box | 69.5 | 37.31 | 275 | 37.7 | `display: flex; align-items: baseline; gap: 8px` |  |
| 23 | `n30.today.list.item1.title` ±1 | text | 69.5 | 37.31 | 211.6 | 37.7 | `min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 24 | `n30.today.list.item1.time` ±1 | text | 289.1 | 40.41 | 55.4 | 14.4 | `display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #8A8073 |
| 25 | `n30.today.list.item1.time.unread` | box | 333.1 | 41.91 | 11.4 | 11.4 | `width: 9px; height: 9px; border-radius: 50%; background: #FF552E; border: 1.2px solid #1A1714; flex-shrink: 0` |  |
| 26 | `n30.today.list.item1.body` | text | 69.5 | 78.01 | 275 | 37.8 | `display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 27 | `n30.today.list.item1.body.author` ±1 | inline | 69.5 | 79.35 | 34.3 | 16.21 | `color: #1A1714; font-weight: 800` | Figtree 13.5/18.9px peso 800 ls normal #1A1714 |
| 28 | `n30.today.list.item2` | box | 0 | 139.31 | 358 | 113.75 | `—` |  |
| 29 | `n30.today.list.item2.card` | box | 0 | 139.31 | 358 | 113.75 | `margin-top: 10px; padding: 12px 12px 12px 12px; border-radius: 20px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; display: flex; gap: 12px; align-items: flex-start` |  |
| 30 | `n30.today.list.item2.icon` | box | 13.5 | 152.81 | 44 | 44 | `position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 31 | `n30.today.list.item2.icon.art` | icon | 24.5 | 163.81 | 22 | 22 | `—` |  |
| 32 | `n30.today.list.item2.textBlock` | box | 69.5 | 152.81 | 275 | 86.75 | `min-width: 0; flex-grow: 1` |  |
| 33 | `n30.today.list.item2.head` | box | 69.5 | 152.81 | 275 | 18.85 | `display: flex; align-items: baseline; gap: 8px` |  |
| 34 | `n30.today.list.item2.title` ±1 | text | 69.5 | 152.81 | 234.84 | 18.85 | `min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 35 | `n30.today.list.item2.time` ±1 | text | 312.34 | 155.91 | 32.16 | 14.4 | `display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #8A8073 |
| 36 | `n30.today.list.item2.time.unread` | box | 333.1 | 157.41 | 11.4 | 11.4 | `width: 9px; height: 9px; border-radius: 50%; background: #FF552E; border: 1.2px solid #1A1714; flex-shrink: 0` |  |
| 37 | `n30.today.list.item2.body` | text | 69.5 | 174.66 | 275 | 18.9 | `display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 38 | `n30.today.list.item2.action` ±1 | box+text | 69.5 | 203.56 | 88.27 | 36 | `margin-top: 10px; height: 36px; padding: 0 14px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 13px; font-weight: 800; background: #1A1714; color: #F7F0E3` | Figtree 13/normal peso 800 ls normal #F7F0E3 |
| 39 | `n30.today.list.item3` | box | 0 | 253.06 | 358 | 69.2 | `—` |  |
| 40 | `n30.today.list.item3.card` | box | 0 | 253.06 | 358 | 69.2 | `padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start` |  |
| 41 | `n30.today.list.item3.icon` | box | 12 | 265.06 | 44 | 44 | `position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 42 | `n30.today.list.item3.icon.art` | icon | 22 | 275.06 | 24 | 24 | `—` |  |
| 43 | `n30.today.list.item3.textBlock` | box | 68 | 265.06 | 278 | 40.75 | `min-width: 0; flex-grow: 1` |  |
| 44 | `n30.today.list.item3.head` | box | 68 | 265.06 | 278 | 18.85 | `display: flex; align-items: baseline; gap: 8px` |  |
| 45 | `n30.today.list.item3.title` ±1 | text | 68 | 265.06 | 253.63 | 18.85 | `min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 46 | `n30.today.list.item3.time` ±1 | text | 329.63 | 268.16 | 16.37 | 14.4 | `display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #8A8073 |
| 47 | `n30.today.list.item3.body` | text | 68 | 286.91 | 278 | 18.9 | `display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 48 | `n30.today.list.item4` | box | 0 | 322.26 | 358 | 69.2 | `—` |  |
| 49 | `n30.today.list.item4.card` | box | 0 | 322.26 | 358 | 69.2 | `padding: 12px 12px; border-bottom: 1.2px dashed #D9CCB4; display: flex; gap: 12px; align-items: flex-start` |  |
| 50 | `n30.today.list.item4.icon` | box | 12 | 334.26 | 44 | 44 | `position: relative; width: 44px; height: 44px; flex-shrink: 0; border-radius: 14px; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 51 | `n30.today.list.item4.icon.art` | icon | 23.5 | 345.76 | 21 | 21 | `—` |  |
| 52 | `n30.today.list.item4.textBlock` | box | 68 | 334.26 | 278 | 43.85 | `min-width: 0; flex-grow: 1` |  |
| 53 | `n30.today.list.item4.head` | box | 68 | 334.26 | 278 | 18.85 | `display: flex; align-items: baseline; gap: 8px` |  |
| 54 | `n30.today.list.item4.title` ±1 | text | 68 | 334.26 | 253.33 | 18.85 | `min-width: 0; flex-grow: 1; font-size: 14.5px; font-weight: 800; line-height: 1.3` | Figtree 14.5/18.85px peso 800 ls normal #1A1714 |
| 55 | `n30.today.list.item4.time` ±1 | text | 329.33 | 337.36 | 16.67 | 14.4 | `display: flex; align-items: center; gap: 6px; flex-shrink: 0; font-size: 12px; font-weight: 700; color: #8A8073; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #8A8073 |
| 56 | `n30.today.list.item4.body` | text | 68 | 356.11 | 278 | 22 | `display: block; margin-top: 3px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 57 | `n30.today.list.item4.body.avatars` | box | 68 | 356.11 | 54 | 22 | `display: inline-flex; vertical-align: middle; margin-right: 6px` |  |
| 58 | `n30.today.list.item4.body.avatars.avatar1` | box+text | 68 | 356.11 | 22 | 22 | `width: 22px; height: 22px; margin-left: 0; border-radius: 50%; background: #B6ACE4; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800` | Figtree 10/14px peso 800 ls normal #5B544B |
| 59 | `n30.today.list.item4.body.avatars.avatar2` | box+text | 84 | 356.11 | 22 | 22 | `width: 22px; height: 22px; margin-left: -6px; border-radius: 50%; background: #FFC1C6; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800` | Figtree 10/14px peso 800 ls normal #5B544B |
| 60 | `n30.today.list.item4.body.avatars.avatar3` | box+text | 100 | 356.11 | 22 | 22 | `width: 22px; height: 22px; margin-left: -6px; border-radius: 50%; background: #ABCF82; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800` | Figtree 10/14px peso 800 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30.today.label` | 1 | HOJE | 10.93 | 0 | 36.23 | 36.23 |
| `n30.today.list.item1.title` | 1 | Leitoras de Capitu · 3 | 51.81 | 69.5 | 212.14 | 142.64 |
| `n30.today.list.item1.title` | 2 | mensagens | 70.66 | 69.5 | 145.67 | 76.17 |
| `n30.today.list.item1.time` | 1 | 20 min | 51.81 | 289.1 | 327.1 | 38 |
| `n30.today.list.item1.body` *(composto)* | 1 | Júlia: “Alguém já chegou na parte do | 92.18 | 69.5 | 295.82 | 226.32 |
| `n30.today.list.item1.body` *(composto)* | 2 | Seminário?” | 111.08 | 69.5 | 142.98 | 73.48 |
| `n30.today.list.item2.title` | 1 | Faltam 12 min para a meta de hoje | 167.31 | 69.5 | 297.69 | 228.19 |
| `n30.today.list.item2.time` | 1 | 1 h | 167.31 | 312.34 | 327.1 | 14.76 |
| `n30.today.list.item2.body` | 1 | Um capítulo de Brás Cubas antes de dormir? | 188.83 | 69.5 | 340.46 | 270.96 |
| `n30.today.list.item2.action` | 1 | Ler agora | 226.11 | 85 | 142.26 | 57.26 |
| `n30.today.list.item3.title` | 1 | Selo novo: 12 dias seguidos | 279.56 | 68 | 250.63 | 182.63 |
| `n30.today.list.item3.time` | 1 | 3 h | 279.56 | 329.63 | 346 | 16.37 |
| `n30.today.list.item3.body` | 1 | Já está na sua carteirinha e no perfil. | 301.08 | 68 | 290.79 | 222.79 |
| `n30.today.list.item4.title` | 1 | Pedro e mais 4 curtiram sua resenha | 348.76 | 68 | 312.01 | 244.01 |
| `n30.today.list.item4.time` | 1 | 5 h | 348.76 | 329.33 | 346 | 16.67 |
| `n30.today.list.item4.body` | 1 | Quincas Borba | 370.48 | 128 | 217.24 | 89.24 |
| `n30.today.list.item4.body.avatars.avatar1` | 1 | P | 370.61 | 75.93 | 82.07 | 6.14 |
| `n30.today.list.item4.body.avatars.avatar2` | 1 | J | 370.61 | 92.15 | 97.85 | 5.7 |
| `n30.today.list.item4.body.avatars.avatar3` | 1 | L | 370.61 | 108.28 | 113.72 | 5.44 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O topo das Notificações: `left/right 16 · top 54` (4 mais para fora e para cima que o das outras telas da T17), os botões de 48 com sombra dura 2/2: voltar à esquerda e, à direita (gap 8), "Marcar tudo como lido" (o duplo visto 21) e a engrenagem 20 "Ajustes de lembretes e avisos".
2. A estrelinha rosa 24 em `left 318 · top 140`; "Novidades" Bricolage 36/800 `lh 0,98` ls −1,1 + quebra + "por aqui." Instrument Serif itálico 44; o resumo 14/600 `#5B544B` com "2 novas" em 800, 8 abaixo.
3. "HOJE" 11,5/800 ls 1,3 `#6F665B` com o traço tracejado (1,5 `#CFC3AE`) até a borda, 18 acima e 10 abaixo.
4. O aviso: o quadrado 44 de raio 14 na cor do tipo (Clube `#FFC1C6`, Lembrete `#FED170`, Conquistas `#ABCF82`, Social `#B6ACE4`) com o ícone; o título 14,5/800 `lh 1,3` (`flex 1`) e, na mesma linha pela base, o tempo 12/700 `#8A8073` `nowrap`; o texto 13,5/600 `lh 1,4` `#5B544B`, 3 abaixo; a ação, quando tem, numa pílula de 36, 10 abaixo (preta em "Ler agora", creme nas outras). Não lido = cartão (padding 12, raio 20, `#FFFAF1`, borda 1,5, sombra 2/2, 10 acima) com a bolinha coral 9 (borda 1,2) depois do tempo; lido = liso, padding 12/12, o fio tracejado 1,2 `#D9CCB4` embaixo.
5. As curtidas: os avatares de 22 (borda 1,3, 10/800) sobrepostos em −6, antes do livro.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A margem de 10 do cartão atravessa o `<li>` (colapsa): os 10 ficam entre os itens e, no 1º, se juntam aos 10 de baixo do rótulo "Hoje" — 10, não 20, entre o rótulo e o 1º cartão.
- A seção Hoje não tem contêiner (o título e a lista soltos no `<main>`): a caixa dela é a união dos ids de topo (`meta.secoesSemElemento`).
- "Ler agora" está dentro do link do aviso (um `<span>`): no app, o aviso inteiro é o alvo e a pílula é um segundo alvo — confirmar na pergunta da T17.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_030_notificacoes_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_030_notificacoes_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `n30.top.back` |  | Voltar |  |
| `n30.top.back.icon` |  |  | aria-hidden=true |
| `n30.top.markRead` |  | Marcar tudo como lido |  |
| `n30.top.markRead.icon` |  |  | aria-hidden=true |
| `n30.top.settings` |  | Ajustes de lembretes e avisos |  |
| `n30.top.settings.icon` |  |  | aria-hidden=true |
| `n30.sparkle` |  |  | aria-hidden=true |
| `n30.today.label.rule` |  |  | aria-hidden=true |
| `n30.today.list.item1.icon` |  |  | aria-hidden=true |
| `n30.today.list.item1.icon.art` |  |  | aria-hidden=true |
| `n30.today.list.item1.time.unread` |  | não lida |  |
| `n30.today.list.item2.icon` |  |  | aria-hidden=true |
| `n30.today.list.item2.icon.art` |  |  | aria-hidden=true |
| `n30.today.list.item2.time.unread` |  | não lida |  |
| `n30.today.list.item3.icon` |  |  | aria-hidden=true |
| `n30.today.list.item3.icon.art` |  |  | aria-hidden=true |
| `n30.today.list.item4.icon` |  |  | aria-hidden=true |
| `n30.today.list.item4.icon.art` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `n30.top.back` | CircleIconButton / NeoBox circular |  |
| `n30.top.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `n30.top.markRead` | CircleIconButton / NeoBox circular |  |
| `n30.top.markRead.icon` | AppSvg(AppIconsPerfil.checkDouble, size: 21) |  |
| `n30.top.settings` | CircleIconButton / NeoBox circular |  |
| `n30.top.settings.icon` | AppSvg(AppIconsPerfil.settings, size: 20) |  |
| `n30.sparkle` | AppSvg(AppIconsPerfil.sparkleNotificacao, size: 24) |  |
| `n30.headline.serif` | TextSpan dentro do AppText.rich do pai |  |
| `n30.summary.count` | TextSpan dentro do AppText.rich do pai |  |
| `n30.today.label.rule` | NeoBox |  |
| `n30.today.list.item1.card` | NeoBox |  |
| `n30.today.list.item1.icon` | NeoBox |  |
| `n30.today.list.item1.icon.art` | AppSvg(AppIconsScanner.peopleAvatar, size: 22) |  |
| `n30.today.list.item1.time.unread` | CircleIconButton / NeoBox circular |  |
| `n30.today.list.item1.body.author` | TextSpan dentro do AppText.rich do pai |  |
| `n30.today.list.item2.card` | NeoBox |  |
| `n30.today.list.item2.icon` | NeoBox |  |
| `n30.today.list.item2.icon.art` | AppSvg(AppIconsPerfil.stopwatchFino, size: 22) |  |
| `n30.today.list.item2.time.unread` | CircleIconButton / NeoBox circular |  |
| `n30.today.list.item2.action` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `n30.today.list.item3.card` | NeoBox |  |
| `n30.today.list.item3.icon` | NeoBox |  |
| `n30.today.list.item3.icon.art` | AppSvg(AppIconsPerfil.sparkleNotificacaoCreme, size: 24) |  |
| `n30.today.list.item4.card` | NeoBox |  |
| `n30.today.list.item4.icon` | NeoBox |  |
| `n30.today.list.item4.icon.art` | AppSvg(AppIconsPerfil.heart, size: 21) |  |
| `n30.today.list.item4.body.avatars.avatar1` | CircleIconButton / NeoBox circular |  |
| `n30.today.list.item4.body.avatars.avatar2` | CircleIconButton / NeoBox circular |  |
| `n30.today.list.item4.body.avatars.avatar3` | CircleIconButton / NeoBox circular |  |

## Interações

- Voltar → a tela anterior (a Início, pelo sino). Engrenagem → a 30b.
- Marcar tudo como lido → tira os cartões e as bolinhas (os avisos ficam lisos); sem não lidos, o botão fica apagado (a 30c).
- Aviso do clube → a Discussão da semana (31), da T08: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).
- Aviso do lembrete → "Ler agora" começa a sessão do último livro de papel (o cronômetro da T04, a mini-barra; a tela 18 chega na T18).
- Selo novo → as Conquistas (79), da T21; curtidas → a resenha (74), da T20: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).

## Dados

- Os avisos: o app ainda não guarda notificações. Os lembretes são locais (a nota do design pede `flutter_local_notifications`, que o app ainda não tem — pacote novo é pergunta da T17); clube e social vêm do servidor (push, serviço a definir). Sem o dado, cada tipo segue a D-247.
- Agrupados por dia (Hoje, Esta semana); o tempo relativo ("20 min", "1 h", "sex"); a data do resumo pelo relógio do app; o número de novas = os não lidos.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L30.1** Topo com os três botões
- **L30.2** Título e resumo
- **L30.3** Hoje: avisos em cartão e lisos
- **L30.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('n30.top', 'n30.sparkle', 'n30.headline', 'n30.summary', 'n30.today'), todos os ids de `kRef30.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/030_notificacoes_390x1180@3x.png` no recorte da fase (y 46–642.66) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef30w360` e `kRef30w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L30.1 Topo com os três botões
- [ ] L30.2 Título e resumo
- [ ] L30.3 Hoje: avisos em cartão e lisos
- [ ] L30.4 Verificação + relatório
- [ ] Geometria 57/57 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
