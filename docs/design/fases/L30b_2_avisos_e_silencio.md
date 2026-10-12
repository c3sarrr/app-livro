# FASE L30b — Lembretes e avisos — avisar sobre (5 chaves) e não incomodar (das → até)

> Tela 30b · prancha `030b_notificacoes_ajustes` (30b · Lembretes e avisos (ajustes), canvas 390×1330) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L30b_2_avisos_e_silencio@3x.png` · `docs/design/medicao/projeto/png/redline/L30b_2_avisos_e_silencio_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/030b_notificacoes_ajustes_390x1330@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_030b_notificacoes_ajustes.json` · `test/reference/projeto/reference_layout_030b_notificacoes_ajustes.dart` (`kRef30b`).
> Arquivos sugeridos: `lib/features/notifications/presentation/reminders_screen.dart`, `lib/core/design_system/widgets/app_switch.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Lembretes e avisos (30b), embaixo: "Avisar sobre" com 5 chaves (mensagens do clube, enquetes e encontros, conquistas ligadas; sequência em risco e seguidores desligadas) e "Não incomodar" das 22:30 às 07:00, com a nota de que o cronômetro continua.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- what to notify -->
<section aria-label="Avisar sobre" style="margin-top: 14px; padding: 16px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714;">
  <div style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">AVISAR SOBRE</div>
  <div style="padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg></span><span style="min-width: 0; flex-grow: 1;"><span id="nt-club" style="display: block; font-size: 15px; font-weight: 800;">Mensagens do clube</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B;">Agrupadas: “3 mensagens em Leitoras de Capitu”</span></span><button type="button" role="switch" aria-checked="true" aria-labelledby="nt-club" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;"><span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></button></div><div style="padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 20V10M12 20V4M19 20v-7"></path></svg></span><span style="min-width: 0; flex-grow: 1;"><span id="nt-poll" style="display: block; font-size: 15px; font-weight: 800;">Enquetes e encontros</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B;">Lembrete um dia antes do encontro</span></span><button type="button" role="switch" aria-checked="true" aria-labelledby="nt-poll" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;"><span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></button></div><div style="padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg></span><span style="min-width: 0; flex-grow: 1;"><span id="nt-badge" style="display: block; font-size: 15px; font-weight: 800;">Conquistas</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B;">Selos novos e recordes</span></span><button type="button" role="switch" aria-checked="true" aria-labelledby="nt-badge" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;"><span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></button></div><div style="padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3c1 3.5 5 5.5 5 10a5 5 0 0 1-10 0c0-2.2 1-3.6 2.2-4.8.2 1.6 1 2.6 2.1 3 0-3 .2-5.6.7-8.2z"></path></svg></span><span style="min-width: 0; flex-grow: 1;"><span id="nt-streak" style="display: block; font-size: 15px; font-weight: 800;">Sequência em risco</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B;">Um aviso só, às 21h, se ainda não leu</span></span><button type="button" role="switch" aria-checked="false" aria-labelledby="nt-streak" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); border: 1.5px solid #1A1714; box-sizing: border-box;"><span style="position: absolute; top: 2.5px; left: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;"></span></button></div><div style="padding: 12px 0;  display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10z"></path></svg></span><span style="min-width: 0; flex-grow: 1;"><span id="nt-social" style="display: block; font-size: 15px; font-weight: 800;">Seguidores e curtidas</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B;">Quem segue você e curte suas resenhas</span></span><button type="button" role="switch" aria-checked="false" aria-labelledby="nt-social" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); border: 1.5px solid #1A1714; box-sizing: border-box;"><span style="position: absolute; top: 2.5px; left: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;"></span></button></div>
</section>

<!-- quiet hours -->
<section aria-label="Silêncio" style="margin-top: 14px; padding: 16px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714;">
  <div style="display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #552CB7; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"></path></svg></span><span style="min-width: 0; flex-grow: 1;"><span id="nt-quiet" style="display: block; font-size: 16px; font-weight: 800;">Não incomodar</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">Nada chega nesse horário</span></span><button type="button" role="switch" aria-checked="true" aria-labelledby="nt-quiet" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;"><span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></button></div>
  <div style="margin-top: 14px; display: grid; grid-template-columns: 1fr auto 1fr; gap: 10px; align-items: center;">
    <span><span style="display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">DAS</span><span style="margin-top: 6px; height: 56px; padding: 0 14px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; letter-spacing: -0.5px; font-variant-numeric: tabular-nums; font-size: 24px; height: 50px;">22:30</span></span>
    <span aria-hidden="true" style="margin-top: 18px; font-size: 18px; font-weight: 800;">→</span>
    <span><span style="display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">ATÉ</span><span style="margin-top: 6px; height: 56px; padding: 0 14px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; letter-spacing: -0.5px; font-variant-numeric: tabular-nums; font-size: 24px; height: 50px;">07:00</span></span>
  </div>
  <p style="margin: 12px 0 0; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #6F665B;">O cronômetro de leitura continua funcionando normalmente.</p>
</section>
```

## Especificação pixel a pixel

Seção `n30b.topics` — retângulo absoluto no canvas 390×1330: **x=16, y=637.99, w=358, h=394.5**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `n30b.topics` | box | 0 | 0 | 358 | 394.5 | `margin-top: 14px; padding: 16px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714` |  |
| 2 | `n30b.topics.label` | text | 17.5 | 17.5 | 323 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 3 | `n30b.topics.club` | box | 17.5 | 30.69 | 323 | 78.95 | `padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px` |  |
| 4 | `n30b.topics.club.icon` | box | 17.5 | 50.57 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 5 | `n30b.topics.club.icon.art` | icon | 27 | 60.07 | 19 | 19 | `—` |  |
| 6 | `n30b.topics.club.textBlock` | box | 67.5 | 42.69 | 207 | 53.75 | `min-width: 0; flex-grow: 1` |  |
| 7 | `n30b.topics.club.title` | text | 67.5 | 42.69 | 207 | 18 | `display: block; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 8 | `n30b.topics.club.body` | text | 67.5 | 62.69 | 207 | 33.75 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B` | Figtree 12.5/16.875px peso 600 ls normal #6F665B |
| 9 | `n30b.topics.club.switch` | box | 286.5 | 53.57 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 10 | `n30b.topics.club.switch.thumb` | box | 312.5 | 57.57 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 11 | `n30b.topics.club.switch.thumb.icon` | icon | 319 | 64.07 | 11 | 11 | `—` |  |
| 12 | `n30b.topics.polls` | box | 17.5 | 109.64 | 323 | 63.2 | `padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px` |  |
| 13 | `n30b.topics.polls.icon` | box | 17.5 | 121.64 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 14 | `n30b.topics.polls.icon.art` | icon | 27.5 | 131.64 | 18 | 18 | `—` |  |
| 15 | `n30b.topics.polls.textBlock` | box | 67.5 | 122.21 | 207 | 36.88 | `min-width: 0; flex-grow: 1` |  |
| 16 | `n30b.topics.polls.title` | text | 67.5 | 122.21 | 207 | 18 | `display: block; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 17 | `n30b.topics.polls.body` | text | 67.5 | 142.21 | 207 | 16.88 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B` | Figtree 12.5/16.875px peso 600 ls normal #6F665B |
| 18 | `n30b.topics.polls.switch` | box | 286.5 | 124.64 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 19 | `n30b.topics.polls.switch.thumb` | box | 312.5 | 128.64 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 20 | `n30b.topics.polls.switch.thumb.icon` | icon | 319 | 135.14 | 11 | 11 | `—` |  |
| 21 | `n30b.topics.achievements` | box | 17.5 | 172.85 | 323 | 63.2 | `padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px` |  |
| 22 | `n30b.topics.achievements.icon` | box | 17.5 | 184.85 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 23 | `n30b.topics.achievements.icon.art` | icon | 26.5 | 193.85 | 20 | 20 | `—` |  |
| 24 | `n30b.topics.achievements.textBlock` | box | 67.5 | 185.41 | 207 | 36.88 | `min-width: 0; flex-grow: 1` |  |
| 25 | `n30b.topics.achievements.title` | text | 67.5 | 185.41 | 207 | 18 | `display: block; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 26 | `n30b.topics.achievements.body` | text | 67.5 | 205.41 | 207 | 16.88 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B` | Figtree 12.5/16.875px peso 600 ls normal #6F665B |
| 27 | `n30b.topics.achievements.switch` | box | 286.5 | 187.85 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 28 | `n30b.topics.achievements.switch.thumb` | box | 312.5 | 191.85 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 29 | `n30b.topics.achievements.switch.thumb.icon` | icon | 319 | 198.35 | 11 | 11 | `—` |  |
| 30 | `n30b.topics.streak` | box | 17.5 | 236.04 | 323 | 63.2 | `padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px` |  |
| 31 | `n30b.topics.streak.icon` | box | 17.5 | 248.04 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 32 | `n30b.topics.streak.icon.art` | icon | 27.5 | 258.04 | 18 | 18 | `—` |  |
| 33 | `n30b.topics.streak.textBlock` | box | 67.5 | 248.61 | 207 | 36.88 | `min-width: 0; flex-grow: 1` |  |
| 34 | `n30b.topics.streak.title` | text | 67.5 | 248.61 | 207 | 18 | `display: block; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 35 | `n30b.topics.streak.body` | text | 67.5 | 268.61 | 207 | 16.88 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B` | Figtree 12.5/16.875px peso 600 ls normal #6F665B |
| 36 | `n30b.topics.streak.switch` | box | 286.5 | 251.04 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 37 | `n30b.topics.streak.switch.thumb` | box | 290.5 | 255.04 | 24 | 24 | `position: absolute; top: 2.5px; left: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 38 | `n30b.topics.social` | box | 17.5 | 299.25 | 323 | 77.75 | `padding: 12px 0; display: flex; align-items: center; gap: 12px` |  |
| 39 | `n30b.topics.social.icon` | box | 17.5 | 319.12 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 40 | `n30b.topics.social.icon.art` | icon | 27.5 | 329.12 | 18 | 18 | `—` |  |
| 41 | `n30b.topics.social.textBlock` | box | 67.5 | 311.25 | 207 | 53.75 | `min-width: 0; flex-grow: 1` |  |
| 42 | `n30b.topics.social.title` | text | 67.5 | 311.25 | 207 | 18 | `display: block; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 43 | `n30b.topics.social.body` | text | 67.5 | 331.25 | 207 | 33.75 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #6F665B` | Figtree 12.5/16.875px peso 600 ls normal #6F665B |
| 44 | `n30b.topics.social.switch` | box | 286.5 | 322.12 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 45 | `n30b.topics.social.switch.thumb` | box | 290.5 | 326.12 | 24 | 24 | `position: absolute; top: 2.5px; left: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30b.topics.label` | 1 | AVISAR SOBRE | 27.94 | 17.5 | 110.47 | 92.97 |
| `n30b.topics.club.title` | 1 | Mensagens do clube | 56.94 | 67.5 | 208.86 | 141.36 |
| `n30b.topics.club.body` | 1 | Agrupadas: “3 mensagens em | 75.51 | 67.5 | 235.16 | 167.66 |
| `n30b.topics.club.body` | 2 | Leitoras de Capitu” | 92.38 | 67.5 | 176.34 | 108.84 |
| `n30b.topics.polls.title` | 1 | Enquetes e encontros | 136.46 | 67.5 | 218.53 | 151.03 |
| `n30b.topics.polls.body` | 1 | Lembrete um dia antes do encontro | 155.02 | 67.5 | 269.89 | 202.39 |
| `n30b.topics.achievements.title` | 1 | Conquistas | 199.66 | 67.5 | 145.94 | 78.44 |
| `n30b.topics.achievements.body` | 1 | Selos novos e recordes | 218.22 | 67.5 | 197.86 | 130.36 |
| `n30b.topics.streak.title` | 1 | Sequência em risco | 262.86 | 67.5 | 202.86 | 135.36 |
| `n30b.topics.streak.body` | 1 | Um aviso só, às 21h, se ainda não leu | 281.42 | 67.5 | 272.66 | 205.16 |
| `n30b.topics.social.title` | 1 | Seguidores e curtidas | 325.5 | 67.5 | 218.93 | 151.43 |
| `n30b.topics.social.body` | 1 | Quem segue você e curte suas | 344.05 | 67.5 | 241.03 | 173.53 |
| `n30b.topics.social.body` | 2 | resenhas | 360.93 | 67.5 | 118.12 | 50.62 |

Seção `n30b.quiet` — retângulo absoluto no canvas 390×1330: **x=16, y=1046.48, w=358, h=203.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 46 | `n30b.quiet` | box | 0 | 0 | 358 | 203.2 | `margin-top: 14px; padding: 16px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714` |  |
| 47 | `n30b.quiet.head` | box | 17.5 | 17.5 | 323 | 38 | `display: flex; align-items: center; gap: 12px` |  |
| 48 | `n30b.quiet.head.icon` | box | 17.5 | 17.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 12px; background: #552CB7; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 49 | `n30b.quiet.head.icon.art` | icon | 27.5 | 27.5 | 18 | 18 | `—` |  |
| 50 | `n30b.quiet.head.textBlock` | box | 67.5 | 18.4 | 207 | 36.21 | `min-width: 0; flex-grow: 1` |  |
| 51 | `n30b.quiet.head.title` | text | 67.5 | 18.4 | 207 | 19.2 | `display: block; font-size: 16px; font-weight: 800` | Figtree 16/normal peso 800 ls normal #1A1714 |
| 52 | `n30b.quiet.head.body` | text | 67.5 | 39.6 | 207 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 53 | `n30b.quiet.head.switch` | box | 286.5 | 20.5 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 54 | `n30b.quiet.head.switch.thumb` | box | 312.5 | 24.5 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 55 | `n30b.quiet.head.switch.thumb.icon` | icon | 319 | 31 | 11 | 11 | `—` |  |
| 56 | `n30b.quiet.range` | box | 17.5 | 69.5 | 323 | 69.2 | `margin-top: 14px; display: grid; grid-template-columns: 1fr auto 1fr; gap: 10px; align-items: center` |  |
| 57 | `n30b.quiet.range.from` ±1 | box | 17.5 | 69.5 | 142.91 | 69.2 | `—` |  |
| 58 | `n30b.quiet.range.from.label` ±1 | text | 17.5 | 69.5 | 142.91 | 13.2 | `display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 59 | `n30b.quiet.range.from.value` ±1 | box+text | 17.5 | 88.7 | 142.91 | 50 | `margin-top: 6px; height: 56px; padding: 0 14px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; letter-spacing: -0.5px; font-variant-numeric: tabular-nums; font-size: 24px; height: 50px` | Bricolage (opsz 24) 24/normal peso 800 ls -0.5px #1A1714 tnum |
| 60 | `n30b.quiet.range.arrow` ±1 | text | 170.41 | 102.13 | 17.17 | 21.94 | `margin-top: 18px; font-size: 18px; font-weight: 800` | Figtree 18/normal peso 800 ls normal #1A1714 |
| 61 | `n30b.quiet.range.to` ±1 | box | 197.59 | 69.5 | 142.91 | 69.2 | `—` |  |
| 62 | `n30b.quiet.range.to.label` ±1 | text | 197.59 | 69.5 | 142.91 | 13.2 | `display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 63 | `n30b.quiet.range.to.value` ±1 | box+text | 197.59 | 88.7 | 142.91 | 50 | `margin-top: 6px; height: 56px; padding: 0 14px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; letter-spacing: -0.5px; font-variant-numeric: tabular-nums; font-size: 24px; height: 50px` | Bricolage (opsz 24) 24/normal peso 800 ls -0.5px #1A1714 tnum |
| 64 | `n30b.quiet.note` | text | 17.5 | 150.7 | 323 | 35 | `margin: 12px 0 0; font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #6F665B` | Figtree 12.5/17.5px peso 600 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `n30b.quiet.head.title` | 1 | Não incomodar | 33.6 | 67.5 | 181.2 | 113.7 |
| `n30b.quiet.head.body` | 1 | Nada chega nesse horário | 51.48 | 67.5 | 214.2 | 146.7 |
| `n30b.quiet.range.from.label` | 1 | DAS | 79.95 | 17.5 | 43.54 | 26.04 |
| `n30b.quiet.range.from.value` | 1 | 22:30 | 121.63 | 33 | 96.55 | 63.55 |
| `n30b.quiet.range.arrow` | 1 | → | 119.58 | 170.41 | 187.59 | 17.18 |
| `n30b.quiet.range.to.label` | 1 | ATÉ | 79.95 | 197.59 | 221.58 | 23.99 |
| `n30b.quiet.range.to.value` | 1 | 07:00 | 121.63 | 213.09 | 276.63 | 63.54 |
| `n30b.quiet.note` | 1 | O cronômetro de leitura continua funcionando | 163.83 | 17.5 | 281.14 | 263.64 |
| `n30b.quiet.note` | 2 | normalmente. | 181.33 | 17.5 | 96.01 | 78.51 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Os dois cartões como o do lembrete (padding 16, raio 24, borda 1,5, sombra 3/3), 14 entre eles.
2. "AVISAR SOBRE" 11/800 ls 1,2; as linhas (padding 12/0, o tracejado 1,2 `#D9CCB4` entre elas, gap 12): o quadrado 38 de raio 12 na cor do tipo, o título 15/800, a descrição 12,5/600 `lh 1,35` e a chave.
3. Não incomodar: a cabeça com o quadrado roxo `#552CB7` e a chave; a grade `1fr auto 1fr` (gap 10, 14 abaixo) com "DAS" e "ATÉ" (11/800, a caixa 6 abaixo) — as caixas de 50 com Bricolage 24 `tnum` — e a seta 18/800 18 abaixo do topo; a nota 12,5/600 `#6F665B`, 12 abaixo.
4. A chave dos Ajustes e dos Lembretes (`role="switch"`): 54 × 32, raio cheio, borda 1,5; ligada, o trilho `{{brand}}` e a bolinha `#FFFAF1` de 24 (borda 1,5) a 2,5 da direita, com o visto de 11 (traço 3,6). É um dos dois desenhos de chave da T17 — o outro está na Conta e na Privacidade (52 × 32, sem visto).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As chaves têm dois desenhos na T17 (54 × 32 com o visto nos Ajustes e nos Lembretes; 52 × 32 sem visto, trilho preto, na Conta e na Privacidade): no app, um widget com as duas variantes (`core/design_system/widgets/app_switch.dart`), cada tela com a sua, como a prancha. Unificar seria melhoria além do design (ROTEIRO §2b): só como proposta, com "Manter igual ao design".
- A seta "→" não existe na Figtree 800: o Chromium usa a Inter ExtraBold do sistema (R8, abaixo). No app, a seta vem da família de reserva (como o "→" das dicas da 28c): ícone ou glifo embutido é pergunta da T17.
- As caixas do horário declaram o tamanho duas vezes (28 e 56, depois 24 e 50): valem os últimos, 24 e 50.
- `n30b.quiet.range` usa glifo de fonte do sistema (Inter ExtraBold (1 glifo(s))) — no navegador o resultado depende da máquina.
- `n30b.quiet.range.arrow` usa glifo de fonte do sistema (Inter ExtraBold (1 glifo(s))) — no navegador o resultado depende da máquina.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_030b_notificacoes_ajustes_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_030b_notificacoes_ajustes_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `n30b.topics` |  | Avisar sobre |  |
| `n30b.topics.club.icon` |  |  | aria-hidden=true |
| `n30b.topics.club.icon.art` |  |  | aria-hidden=true |
| `n30b.topics.club.switch` | switch |  | aria-checked=true, aria-labelledby=nt-club |
| `n30b.topics.club.switch.thumb.icon` |  |  | aria-hidden=true |
| `n30b.topics.polls.icon` |  |  | aria-hidden=true |
| `n30b.topics.polls.icon.art` |  |  | aria-hidden=true |
| `n30b.topics.polls.switch` | switch |  | aria-checked=true, aria-labelledby=nt-poll |
| `n30b.topics.polls.switch.thumb.icon` |  |  | aria-hidden=true |
| `n30b.topics.achievements.icon` |  |  | aria-hidden=true |
| `n30b.topics.achievements.icon.art` |  |  | aria-hidden=true |
| `n30b.topics.achievements.switch` | switch |  | aria-checked=true, aria-labelledby=nt-badge |
| `n30b.topics.achievements.switch.thumb.icon` |  |  | aria-hidden=true |
| `n30b.topics.streak.icon` |  |  | aria-hidden=true |
| `n30b.topics.streak.icon.art` |  |  | aria-hidden=true |
| `n30b.topics.streak.switch` | switch |  | aria-checked=false, aria-labelledby=nt-streak |
| `n30b.topics.social.icon` |  |  | aria-hidden=true |
| `n30b.topics.social.icon.art` |  |  | aria-hidden=true |
| `n30b.topics.social.switch` | switch |  | aria-checked=false, aria-labelledby=nt-social |
| `n30b.quiet` |  | Silêncio |  |
| `n30b.quiet.head.icon` |  |  | aria-hidden=true |
| `n30b.quiet.head.icon.art` |  |  | aria-hidden=true |
| `n30b.quiet.head.switch` | switch |  | aria-checked=true, aria-labelledby=nt-quiet |
| `n30b.quiet.head.switch.thumb.icon` |  |  | aria-hidden=true |
| `n30b.quiet.range.arrow` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `n30b.topics` | NeoBox |  |
| `n30b.topics.club` | NeoBox |  |
| `n30b.topics.club.icon` | NeoBox |  |
| `n30b.topics.club.icon.art` | AppSvg(AppIconsScanner.peopleAvatar, size: 19) |  |
| `n30b.topics.club.switch` | NeoBox |  |
| `n30b.topics.club.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `n30b.topics.club.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |
| `n30b.topics.polls` | NeoBox |  |
| `n30b.topics.polls.icon` | NeoBox |  |
| `n30b.topics.polls.icon.art` | AppSvg(AppIconsPerfil.statsBars, size: 18) |  |
| `n30b.topics.polls.switch` | NeoBox |  |
| `n30b.topics.polls.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `n30b.topics.polls.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |
| `n30b.topics.achievements` | NeoBox |  |
| `n30b.topics.achievements.icon` | NeoBox |  |
| `n30b.topics.achievements.icon.art` | AppSvg(AppIconsPerfil.sparkleNotificacaoCreme, size: 20) |  |
| `n30b.topics.achievements.switch` | NeoBox |  |
| `n30b.topics.achievements.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `n30b.topics.achievements.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |
| `n30b.topics.streak` | NeoBox |  |
| `n30b.topics.streak.icon` | NeoBox |  |
| `n30b.topics.streak.icon.art` | AppSvg(AppIconsPerfil.flameOutline, size: 18) |  |
| `n30b.topics.streak.switch` | HatchPainter (hachura 135°) dentro do contorno |  |
| `n30b.topics.streak.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `n30b.topics.social.icon` | NeoBox |  |
| `n30b.topics.social.icon.art` | AppSvg(AppIconsPerfil.heart, size: 18) |  |
| `n30b.topics.social.switch` | HatchPainter (hachura 135°) dentro do contorno |  |
| `n30b.topics.social.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `n30b.quiet` | NeoBox |  |
| `n30b.quiet.head.icon` | NeoBox |  |
| `n30b.quiet.head.icon.art` | AppSvg(AppIconsPerfil.moonCreme, size: 18) |  |
| `n30b.quiet.head.switch` | NeoBox |  |
| `n30b.quiet.head.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `n30b.quiet.head.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |
| `n30b.quiet.range.from.value` | NeoBox + AppText |  |
| `n30b.quiet.range.to.value` | NeoBox + AppText |  |

## Interações

- Cada chave → liga ou desliga aquele tipo de aviso (grava na hora).
- Chave do não incomodar → liga ou desliga o silêncio; DAS e ATÉ → o relógio do sistema para trocar.

## Dados

- Os padrões da nota do design: clube, enquetes e encontros e conquistas ligados; sequência em risco e seguidores e curtidas desligados; silêncio das 22:30 às 7:00. Os avisos do clube e do social dependem do push (serviço a definir); sem ele, as chaves gravam a preferência e o texto não muda.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L30b.1** Avisar sobre (as 5 chaves)
- **L30b.2** Não incomodar: chave, das, até e a nota
- **L30b.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('n30b.topics', 'n30b.quiet'), todos os ids de `kRef30b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/030b_notificacoes_ajustes_390x1330@3x.png` no recorte da fase (y 629.99–1257.68) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef30bw360` e `kRef30bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L30b.1 Avisar sobre (as 5 chaves)
- [ ] L30b.2 Não incomodar: chave, das, até e a nota
- [ ] L30b.3 Verificação + relatório
- [ ] Geometria 64/64 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
