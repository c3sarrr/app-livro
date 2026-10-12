# FASE L56 — Privacidade — o tipo de perfil, quem vê o quê, pessoas (pedidos, achar pelo e-mail, bloqueadas) e o aviso de bloqueio

> Tela 56 · prancha `056_privacidade` (56 · Privacidade, canvas 390×1420) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L56_privacidade@3x.png` · `docs/design/medicao/projeto/png/redline/L56_privacidade_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/056_privacidade_390x1420@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_056_privacidade.json` · `test/reference/projeto/reference_layout_056_privacidade.dart` (`kRef56`).
> Arquivos sugeridos: `lib/features/settings/presentation/privacy/privacy_screen.dart`, `lib/features/settings/presentation/account/settings_list_card.dart`, `lib/core/design_system/widgets/app_switch.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Privacidade (56): "Sua privacidade.", a escolha entre perfil Aberto e Fechado (marcado), quem vê o quê (6 partes, cada uma com a pílula de público), Pessoas (pedidos para seguir, me achar pelo e-mail, bloqueadas) e o aviso tracejado do bloqueio.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{club}}` = padrão `#FFC1C6`.

```html
<h1 style="margin: 0px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px;">Sua <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.5px;">privacidade.</span></h1>

<p style="margin: 8px 0 0; font-size: 14px; font-weight: 600; line-height: 1.4; color: #5B544B;">Você escolhe quem vê cada parte da sua leitura. O que é seu fica seu.</p>

<div role="radiogroup" aria-label="Tipo de perfil" style="margin-top: 18px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;"><button role="radio" aria-checked="false" style="position: relative; min-height: 118px; padding: 14px 12px 12px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; flex-direction: column; align-items: flex-start; gap: 6px; text-align: left;"><span style="position: absolute; top: 10px; right: 10px; width: 24px; height: 24px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></span><span style="width: 38px; height: 38px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="8.5"></circle><path d="M3.5 12h17M12 3.5c2.4 2.6 3.5 5.4 3.5 8.5s-1.1 5.9-3.5 8.5c-2.4-2.6-3.5-5.4-3.5-8.5s1.1-5.9 3.5-8.5z"></path></svg></span><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px;">Aberto</span><span style="font-size: 12px; font-weight: 600; line-height: 1.3; color: #3D3830;">Qualquer pessoa pode seguir e ver o que você liberar.</span></button><button role="radio" aria-checked="true" style="position: relative; min-height: 118px; padding: 14px 12px 12px; border-radius: 22px; background: {{brand}}; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: flex-start; gap: 6px; text-align: left;"><span style="position: absolute; top: 10px; right: 10px; width: 24px; height: 24px; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span><span style="width: 38px; height: 38px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="11" width="14" height="10" rx="2.5"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg></span><span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px;">Fechado</span><span style="font-size: 12px; font-weight: 600; line-height: 1.3; color: #3D3830;">Só quem você aprova vê seu perfil.</span></button></div>

<section aria-label="Quem vê o quê" style="margin-top: 26px; display: flex; flex-direction: column; gap: 10px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 8px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px;">Quem vê o quê</h2><span style="font-size: 12.5px; font-weight: 700; color: #8A8073;">só seguidores aprovados</span></div>
  <div style="padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column;"><div  style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3.5" y="4" width="4.5" height="16" rx="1"></rect><rect x="10" y="4" width="4.5" height="16" rx="1"></rect><path d="m16.4 5.6 3.9-1 3.2 14.6-3.9 1z"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Estante e lendo agora</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Livros, status e capas</span></span><button aria-haspopup="listbox" aria-label="Quem vê: Seguidores" style="height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>Seguidores<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"></path></svg></button></div><div  style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m12 3 2.6 5.5 6 .8-4.4 4.2 1.1 6L12 16.6 6.7 19.5l1.1-6L3.4 9.3l6-.8z"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Resenhas</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Notas, climas e texto</span></span><button aria-haspopup="listbox" aria-label="Quem vê: Seguidores" style="height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>Seguidores<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"></path></svg></button></div><div  style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 11-6 6v3h9l3-3"></path><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Grifos novos</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Padrão: só você. Dá para abrir grifo por grifo</span></span><button aria-haspopup="listbox" aria-label="Quem vê: Só eu" style="height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #F1E7D5; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="11" width="14" height="10" rx="2.5"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg>Só eu<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"></path></svg></button></div><div  style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h9l4 4v14H6z"></path><path d="M14 3v5h5"></path><path d="M9 14h6M9 17h4"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Página onde você está</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Nos clubes, só a porcentagem aparece</span></span><button aria-haspopup="listbox" aria-label="Quem vê: Seguidores" style="height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>Seguidores<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"></path></svg></button></div><div  style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 6h11M9 12h11M9 18h11"></path><circle cx="4.5" cy="6" r="1"></circle><circle cx="4.5" cy="12" r="1"></circle><circle cx="4.5" cy="18" r="1"></circle></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Listas</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Cada lista ainda pode ser só sua</span></span><button aria-haspopup="listbox" aria-label="Quem vê: Seguidores" style="height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>Seguidores<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"></path></svg></button></div><div  style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFB8A6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20V10M10 20V4M16 20v-7M22 20H2"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Metas e estatísticas</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Minutos, sequência e metas</span></span><button aria-haspopup="listbox" aria-label="Quem vê: Só eu" style="height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #F1E7D5; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="11" width="14" height="10" rx="2.5"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg>Só eu<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"></path></svg></button></div></div>
</section>

<section aria-label="Pessoas" style="margin-top: 26px; display: flex; flex-direction: column; gap: 10px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 8px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px;">Pessoas</h2><span style="font-size: 12.5px; font-weight: 700; color: #8A8073;"></span></div>
  <div style="padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column;"><a href="#" style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Pedidos para seguir</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Tomás, Nina e Bia esperam</span></span><span style="display: flex; align-items: center; gap: 6px;"><span style="min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: #FF552E; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800;">3</span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></span></a><div  style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="3"></rect><path d="m4 7 8 6 8-6"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Me achar pelo e-mail</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Quem tem seu e-mail encontra você na busca</span></span><button role="switch" aria-checked="false" aria-label="Me achar pelo e-mail" style="width: 52px; height: 32px; flex-shrink: 0; padding: 3px; border-radius: 999px; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center;"><span style="width: 23px; height: 23px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;"></span></button></div><a href="#" style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="8.5"></circle><path d="M6 6l12 12"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Bloqueadas</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Somem dos dois lados</span></span><span style="display: flex; align-items: center; gap: 6px;"><span style="min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: #F1E7D5; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800;">1</span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></span></a></div>
</section>

<div style="margin-top: 14px; padding: 12px 14px; border-radius: 18px; border: 1.3px dashed #8A7F63; display: flex; gap: 10px; align-items: flex-start;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><circle cx="12" cy="12" r="8.5"></circle><path d="M6 6l12 12"></path></svg><span style="font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #3D3830;"><strong style="color: #1A1714;">Bloquear some dos dois lados:</strong> nenhuma das duas vê o perfil, os grifos ou as resenhas da outra. No clube, as mensagens dela ficam recolhidas para você.</span></div>
```

## Especificação pixel a pixel

Seção `aj56.headline` — retângulo absoluto no canvas 390×1420: **x=20, y=122, w=350, h=41.16**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `aj56.headline` | text | 0 | 0 | 350 | 41.16 | `margin: 0px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1.1px #1A1714 |
| 2 | `aj56.headline.serif` ±1 | inline | 65.47 | -6.72 | 188.04 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.5px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.5px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj56.headline` *(composto)* | 1 | Sua privacidade. | 34.86 | 0 | 253.51 | 253.51 |

Seção `aj56.lead` — retângulo absoluto no canvas 390×1420: **x=20, y=171.16, w=350, h=39.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `aj56.lead` | text | 0 | 0 | 350 | 39.2 | `margin: 8px 0 0; font-size: 14px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 14/19.6px peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj56.lead` | 1 | Você escolhe quem vê cada parte da sua leitura. O que | 14.7 | 0 | 346.77 | 346.77 |
| `aj56.lead` | 2 | é seu fica seu. | 34.3 | 0 | 89.21 | 89.21 |

Seção `aj56.profileType` — retângulo absoluto no canvas 390×1420: **x=20, y=228.36, w=350, h=146.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `aj56.profileType` | box | 0 | 0 | 350 | 146.2 | `margin-top: 18px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px` |  |
| 5 | `aj56.profileType.open` | box | 0 | 0 | 170 | 146.2 | `position: relative; min-height: 118px; padding: 14px 12px 12px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; flex-direction: column; align-items: flex-start; gap: 6px; text-align: left` |  |
| 6 | `aj56.profileType.open.radio` | box | 134.5 | 11.5 | 24 | 24 | `position: absolute; top: 10px; right: 10px; width: 24px; height: 24px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 7 | `aj56.profileType.open.icon` | box | 13.5 | 15.5 | 38 | 38 | `width: 38px; height: 38px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 8 | `aj56.profileType.open.icon.art` | icon | 23 | 25 | 19 | 19 | `—` |  |
| 9 | `aj56.profileType.open.title` ±1 | text | 13.5 | 59.5 | 56.18 | 20.4 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px` | Bricolage (opsz 17) 17/normal peso 800 ls -0.3px #1A1714 |
| 10 | `aj56.profileType.open.body` | text | 13.5 | 85.9 | 143 | 46.8 | `font-size: 12px; font-weight: 600; line-height: 1.3; color: #3D3830` | Figtree 12/15.6px peso 600 ls normal #3D3830 |
| 11 | `aj56.profileType.closed` | box | 180 | 0 | 170 | 146.2 | `position: relative; min-height: 118px; padding: 14px 12px 12px; border-radius: 22px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: flex-start; gap: 6px; text-align: left` |  |
| 12 | `aj56.profileType.closed.radio` | box | 314.5 | 11.5 | 24 | 24 | `position: absolute; top: 10px; right: 10px; width: 24px; height: 24px; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 13 | `aj56.profileType.closed.radio.icon` | icon | 320 | 17 | 13 | 13 | `—` |  |
| 14 | `aj56.profileType.closed.icon` | box | 193.5 | 15.5 | 38 | 38 | `width: 38px; height: 38px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 15 | `aj56.profileType.closed.icon.art` | icon | 203 | 25 | 19 | 19 | `—` |  |
| 16 | `aj56.profileType.closed.title` ±1 | text | 193.5 | 59.5 | 69.93 | 20.4 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px` | Bricolage (opsz 17) 17/normal peso 800 ls -0.3px #1A1714 |
| 17 | `aj56.profileType.closed.body` | text | 193.5 | 85.9 | 143 | 31.2 | `font-size: 12px; font-weight: 600; line-height: 1.3; color: #3D3830` | Figtree 12/15.6px peso 600 ls normal #3D3830 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj56.profileType.open.title` | 1 | Aberto | 75.31 | 13.5 | 69.68 | 56.18 |
| `aj56.profileType.open.body` | 1 | Qualquer pessoa pode | 97.9 | 13.5 | 135.41 | 121.91 |
| `aj56.profileType.open.body` | 2 | seguir e ver o que você | 113.5 | 13.5 | 139.21 | 125.71 |
| `aj56.profileType.open.body` | 3 | liberar. | 129.1 | 13.5 | 50.83 | 37.33 |
| `aj56.profileType.closed.title` | 1 | Fechado | 75.31 | 193.5 | 263.43 | 69.93 |
| `aj56.profileType.closed.body` | 1 | Só quem você aprova vê | 97.9 | 193.5 | 326.75 | 133.25 |
| `aj56.profileType.closed.body` | 2 | seu perfil. | 113.5 | 193.5 | 246.72 | 53.22 |

Seção `aj56.visibility` — retângulo absoluto no canvas 390×1420: **x=20, y=400.56, w=350, h=532.5**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 18 | `aj56.visibility` | box | 0 | 0 | 350 | 532.5 | `margin-top: 26px; display: flex; flex-direction: column; gap: 10px` |  |
| 19 | `aj56.visibility.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 8px` |  |
| 20 | `aj56.visibility.header.title` ±1 | text | 0 | 0 | 136.85 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.5px #1A1714 |
| 21 | `aj56.visibility.header.note` ±1 | text | 208.3 | 6.72 | 141.7 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #8A8073` | Figtree 12.5/normal peso 700 ls normal #8A8073 |
| 22 | `aj56.visibility.list` | box | 0 | 34 | 350 | 498.5 | `padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 23 | `aj56.visibility.list.shelf` | box | 15.5 | 37.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 24 | `aj56.visibility.list.shelf.icon` | box | 15.5 | 58.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 25 | `aj56.visibility.list.shelf.icon.art` | icon | 25.5 | 68.5 | 18 | 18 | `—` |  |
| 26 | `aj56.visibility.list.shelf.textBlock` ±1 | box | 65.5 | 50.38 | 132.91 | 54.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 27 | `aj56.visibility.list.shelf.title` ±1 | text | 65.5 | 50.38 | 132.91 | 36 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 28 | `aj56.visibility.list.shelf.body` ±1 | text | 65.5 | 88.38 | 132.91 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 29 | `aj56.visibility.list.shelf.audience` ±1 | box+text | 210.41 | 59.5 | 124.09 | 36 | `height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 30 | `aj56.visibility.list.shelf.audience.icon` ±1 | icon | 221.71 | 70.5 | 14 | 14 | `—` |  |
| 31 | `aj56.visibility.list.shelf.audience.chevron` | icon | 311.2 | 70.5 | 14 | 14 | `—` |  |
| 32 | `aj56.visibility.list.reviews` | box | 15.5 | 118.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 33 | `aj56.visibility.list.reviews.icon` | box | 15.5 | 139.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 34 | `aj56.visibility.list.reviews.icon.art` | icon | 25.5 | 149.5 | 18 | 18 | `—` |  |
| 35 | `aj56.visibility.list.reviews.textBlock` ±1 | box | 65.5 | 140.37 | 132.91 | 36.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 36 | `aj56.visibility.list.reviews.title` ±1 | text | 65.5 | 140.37 | 132.91 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 37 | `aj56.visibility.list.reviews.body` ±1 | text | 65.5 | 160.37 | 132.91 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 38 | `aj56.visibility.list.reviews.audience` ±1 | box+text | 210.41 | 140.5 | 124.09 | 36 | `height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 39 | `aj56.visibility.list.reviews.audience.icon` ±1 | icon | 221.71 | 151.5 | 14 | 14 | `—` |  |
| 40 | `aj56.visibility.list.reviews.audience.chevron` | icon | 311.2 | 151.5 | 14 | 14 | `—` |  |
| 41 | `aj56.visibility.list.highlights` | box | 15.5 | 199.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 42 | `aj56.visibility.list.highlights.icon` | box | 15.5 | 220.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 43 | `aj56.visibility.list.highlights.icon.art` | icon | 25.5 | 230.5 | 18 | 18 | `—` |  |
| 44 | `aj56.visibility.list.highlights.textBlock` ±1 | box | 65.5 | 213.25 | 166.5 | 52.5 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 45 | `aj56.visibility.list.highlights.title` ±1 | text | 65.5 | 213.25 | 166.5 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 46 | `aj56.visibility.list.highlights.body` ±1 | text | 65.5 | 233.25 | 166.5 | 32.5 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 47 | `aj56.visibility.list.highlights.audience` ±1 | box+text | 244 | 221.5 | 90.5 | 36 | `height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #F1E7D5; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 48 | `aj56.visibility.list.highlights.audience.icon` ±1 | icon | 255.3 | 232.5 | 14 | 14 | `—` |  |
| 49 | `aj56.visibility.list.highlights.audience.chevron` | icon | 311.2 | 232.5 | 14 | 14 | `—` |  |
| 50 | `aj56.visibility.list.page` | box | 15.5 | 280.5 | 319 | 87.5 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 51 | `aj56.visibility.list.page.icon` | box | 15.5 | 304.75 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 52 | `aj56.visibility.list.page.icon.art` | icon | 25.5 | 314.75 | 18 | 18 | `—` |  |
| 53 | `aj56.visibility.list.page.textBlock` ±1 | box | 65.5 | 288.5 | 132.91 | 70.5 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 54 | `aj56.visibility.list.page.title` ±1 | text | 65.5 | 288.5 | 132.91 | 36 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 55 | `aj56.visibility.list.page.body` ±1 | text | 65.5 | 326.5 | 132.91 | 32.5 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 56 | `aj56.visibility.list.page.audience` ±1 | box+text | 210.41 | 305.75 | 124.09 | 36 | `height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 57 | `aj56.visibility.list.page.audience.icon` ±1 | icon | 221.71 | 316.75 | 14 | 14 | `—` |  |
| 58 | `aj56.visibility.list.page.audience.chevron` | icon | 311.2 | 316.75 | 14 | 14 | `—` |  |
| 59 | `aj56.visibility.list.lists` | box | 15.5 | 368 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 60 | `aj56.visibility.list.lists.icon` | box | 15.5 | 389 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 61 | `aj56.visibility.list.lists.icon.art` | icon | 25.5 | 399 | 18 | 18 | `—` |  |
| 62 | `aj56.visibility.list.lists.textBlock` ±1 | box | 65.5 | 381.75 | 132.91 | 52.5 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 63 | `aj56.visibility.list.lists.title` ±1 | text | 65.5 | 381.75 | 132.91 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 64 | `aj56.visibility.list.lists.body` ±1 | text | 65.5 | 401.75 | 132.91 | 32.5 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 65 | `aj56.visibility.list.lists.audience` ±1 | box+text | 210.41 | 390 | 124.09 | 36 | `height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 66 | `aj56.visibility.list.lists.audience.icon` ±1 | icon | 221.71 | 401 | 14 | 14 | `—` |  |
| 67 | `aj56.visibility.list.lists.audience.chevron` | icon | 311.2 | 401 | 14 | 14 | `—` |  |
| 68 | `aj56.visibility.list.stats` | box | 15.5 | 449 | 319 | 80 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px` |  |
| 69 | `aj56.visibility.list.stats.icon` | box | 15.5 | 470 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFB8A6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 70 | `aj56.visibility.list.stats.icon.art` | icon | 25.5 | 480 | 18 | 18 | `—` |  |
| 71 | `aj56.visibility.list.stats.textBlock` ±1 | box | 65.5 | 470.87 | 166.5 | 36.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 72 | `aj56.visibility.list.stats.title` ±1 | text | 65.5 | 470.87 | 166.5 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 73 | `aj56.visibility.list.stats.body` ±1 | text | 65.5 | 490.87 | 166.5 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 74 | `aj56.visibility.list.stats.audience` ±1 | box+text | 244 | 471 | 90.5 | 36 | `height: 36px; padding: 0 8px 0 10px; flex-shrink: 0; border-radius: 999px; background: #F1E7D5; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 12.5px; font-weight: 800; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 75 | `aj56.visibility.list.stats.audience.icon` ±1 | icon | 255.3 | 482 | 14 | 14 | `—` |  |
| 76 | `aj56.visibility.list.stats.audience.chevron` | icon | 311.2 | 482 | 14 | 14 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj56.visibility.header.title` | 1 | Quem vê o quê | 18.6 | 0 | 136.85 | 136.85 |
| `aj56.visibility.header.note` | 1 | só seguidores aprovados | 18.6 | 208.3 | 350 | 141.7 |
| `aj56.visibility.list.shelf.title` | 1 | Estante e lendo | 64.63 | 65.5 | 171.55 | 106.05 |
| `aj56.visibility.list.shelf.title` | 2 | agora | 82.63 | 65.5 | 104.91 | 39.41 |
| `aj56.visibility.list.shelf.body` | 1 | Livros, status e capas | 100.88 | 65.5 | 185.63 | 120.13 |
| `aj56.visibility.list.shelf.audience` | 1 | Seguidores | 81.88 | 240.71 | 306.2 | 65.49 |
| `aj56.visibility.list.reviews.title` | 1 | Resenhas | 154.62 | 65.5 | 130.84 | 65.34 |
| `aj56.visibility.list.reviews.body` | 1 | Notas, climas e texto | 172.87 | 65.5 | 183.62 | 118.12 |
| `aj56.visibility.list.reviews.audience` | 1 | Seguidores | 162.87 | 240.71 | 306.2 | 65.49 |
| `aj56.visibility.list.highlights.title` | 1 | Grifos novos | 227.5 | 65.5 | 151.96 | 86.46 |
| `aj56.visibility.list.highlights.body` | 1 | Padrão: só você. Dá para abrir | 245.75 | 65.5 | 231.58 | 166.08 |
| `aj56.visibility.list.highlights.body` | 2 | grifo por grifo | 262 | 65.5 | 143.89 | 78.39 |
| `aj56.visibility.list.highlights.audience` | 1 | Só eu | 243.87 | 274.3 | 306.2 | 31.9 |
| `aj56.visibility.list.page.title` | 1 | Página onde você | 302.75 | 65.5 | 186.75 | 121.25 |
| `aj56.visibility.list.page.title` | 2 | está | 320.75 | 65.5 | 94.61 | 29.11 |
| `aj56.visibility.list.page.body` | 1 | Nos clubes, só a | 339 | 65.5 | 156.53 | 91.03 |
| `aj56.visibility.list.page.body` | 2 | porcentagem aparece | 355.25 | 65.5 | 189.53 | 124.03 |
| `aj56.visibility.list.page.audience` | 1 | Seguidores | 328.12 | 240.71 | 306.2 | 65.49 |
| `aj56.visibility.list.lists.title` | 1 | Listas | 396 | 65.5 | 105.36 | 39.86 |
| `aj56.visibility.list.lists.body` | 1 | Cada lista ainda pode | 414.25 | 65.5 | 185.92 | 120.42 |
| `aj56.visibility.list.lists.body` | 2 | ser só sua | 430.5 | 65.5 | 121 | 55.5 |
| `aj56.visibility.list.lists.audience` | 1 | Seguidores | 412.37 | 240.71 | 306.2 | 65.49 |
| `aj56.visibility.list.stats.title` | 1 | Metas e estatísticas | 485.12 | 65.5 | 202.27 | 136.77 |
| `aj56.visibility.list.stats.body` | 1 | Minutos, sequência e metas | 503.37 | 65.5 | 221.54 | 156.04 |
| `aj56.visibility.list.stats.audience` | 1 | Só eu | 493.37 | 274.3 | 306.2 | 31.9 |

Seção `aj56.people` — retângulo absoluto no canvas 390×1420: **x=20, y=959.06, w=350, h=283**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 77 | `aj56.people` | box | 0 | 0 | 350 | 283 | `margin-top: 26px; display: flex; flex-direction: column; gap: 10px` |  |
| 78 | `aj56.people.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 8px` |  |
| 79 | `aj56.people.header.title` ±1 | text | 0 | 0 | 78.3 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.5px #1A1714 |
| 80 | `aj56.people.header.note` | box | 350 | 18.6 | 0 | 0 | `font-size: 12.5px; font-weight: 700; color: #8A8073` |  |
| 81 | `aj56.people.list` | box | 0 | 34 | 350 | 249 | `padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 82 | `aj56.people.list.requests` | box | 15.5 | 37.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 83 | `aj56.people.list.requests.icon` | box | 15.5 | 58.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 84 | `aj56.people.list.requests.icon.art` | icon | 25.5 | 68.5 | 18 | 18 | `—` |  |
| 85 | `aj56.people.list.requests.textBlock` | box | 65.5 | 59.38 | 209 | 36.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 86 | `aj56.people.list.requests.title` | text | 65.5 | 59.38 | 209 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 87 | `aj56.people.list.requests.body` | text | 65.5 | 79.38 | 209 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 88 | `aj56.people.list.requests.trail` | box | 286.5 | 65.5 | 48 | 24 | `display: flex; align-items: center; gap: 6px` |  |
| 89 | `aj56.people.list.requests.trail.count` | box+text | 286.5 | 65.5 | 24 | 24 | `min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: #FF552E; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 90 | `aj56.people.list.requests.trail.chevron` | icon | 316.5 | 68.5 | 18 | 18 | `flex-shrink: 0` |  |
| 91 | `aj56.people.list.findByEmail` | box | 15.5 | 118.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 92 | `aj56.people.list.findByEmail.icon` | box | 15.5 | 139.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 93 | `aj56.people.list.findByEmail.icon.art` | icon | 25.5 | 149.5 | 18 | 18 | `—` |  |
| 94 | `aj56.people.list.findByEmail.textBlock` | box | 65.5 | 132.25 | 205 | 52.5 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 95 | `aj56.people.list.findByEmail.title` | text | 65.5 | 132.25 | 205 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 96 | `aj56.people.list.findByEmail.body` | text | 65.5 | 152.25 | 205 | 32.5 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 97 | `aj56.people.list.findByEmail.switch` | box | 282.5 | 142.5 | 52 | 32 | `width: 52px; height: 32px; flex-shrink: 0; padding: 3px; border-radius: 999px; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center` |  |
| 98 | `aj56.people.list.findByEmail.switch.thumb` | box | 287 | 147 | 23 | 23 | `width: 23px; height: 23px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 99 | `aj56.people.list.blocked` | box | 15.5 | 199.5 | 319 | 80 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px` |  |
| 100 | `aj56.people.list.blocked.icon` | box | 15.5 | 220.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 101 | `aj56.people.list.blocked.icon.art` | icon | 25.5 | 230.5 | 18 | 18 | `—` |  |
| 102 | `aj56.people.list.blocked.textBlock` | box | 65.5 | 221.38 | 209 | 36.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 103 | `aj56.people.list.blocked.title` | text | 65.5 | 221.38 | 209 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 104 | `aj56.people.list.blocked.body` | text | 65.5 | 241.38 | 209 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 105 | `aj56.people.list.blocked.trail` | box | 286.5 | 227.5 | 48 | 24 | `display: flex; align-items: center; gap: 6px` |  |
| 106 | `aj56.people.list.blocked.trail.count` | box+text | 286.5 | 227.5 | 24 | 24 | `min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: #F1E7D5; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 107 | `aj56.people.list.blocked.trail.chevron` | icon | 316.5 | 230.5 | 18 | 18 | `flex-shrink: 0` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj56.people.header.title` | 1 | Pessoas | 18.6 | 0 | 78.3 | 78.3 |
| `aj56.people.list.requests.title` | 1 | Pedidos para seguir | 73.62 | 65.5 | 200.47 | 134.97 |
| `aj56.people.list.requests.body` | 1 | Tomás, Nina e Bia esperam | 91.87 | 65.5 | 215.63 | 150.13 |
| `aj56.people.list.requests.trail.count` | 1 | 3 | 81.7 | 295.13 | 301.87 | 6.74 |
| `aj56.people.list.findByEmail.title` | 1 | Me achar pelo e-mail | 146.5 | 65.5 | 208.65 | 143.15 |
| `aj56.people.list.findByEmail.body` | 1 | Quem tem seu e-mail encontra você | 164.75 | 65.5 | 270 | 204.5 |
| `aj56.people.list.findByEmail.body` | 2 | na busca | 181 | 65.5 | 115.44 | 49.94 |
| `aj56.people.list.blocked.title` | 1 | Bloqueadas | 235.62 | 65.5 | 144.7 | 79.2 |
| `aj56.people.list.blocked.body` | 1 | Somem dos dois lados | 253.87 | 65.5 | 191.39 | 125.89 |
| `aj56.people.list.blocked.trail.count` | 1 | 1 | 243.7 | 295.94 | 301.06 | 5.12 |

Seção `aj56.blockNote` — retângulo absoluto no canvas 390×1420: **x=20, y=1256.06, w=350, h=96.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 108 | `aj56.blockNote` | box | 0 | 0 | 350 | 96.6 | `margin-top: 14px; padding: 12px 14px; border-radius: 18px; border: 1.3px dashed #8A7F63; display: flex; gap: 10px; align-items: flex-start` |  |
| 109 | `aj56.blockNote.icon` | icon | 15.3 | 13.3 | 18 | 18 | `flex-shrink: 0` |  |
| 110 | `aj56.blockNote.text` | text | 43.3 | 13.3 | 291.4 | 70 | `font-size: 12.5px; font-weight: 600; line-height: 1.4; color: #3D3830` | Figtree 12.5/17.5px peso 600 ls normal #3D3830 |
| 111 | `aj56.blockNote.text.lead` ±1 | inline | 43.3 | 14.54 | 174.26 | 15.01 | `color: #1A1714` | Figtree 12.5/17.5px peso 900→**800** ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj56.blockNote.text` *(composto)* | 1 | Bloquear some dos dois lados: nenhuma das duas | 26.42 | 43.3 | 325.62 | 282.32 |
| `aj56.blockNote.text` *(composto)* | 2 | vê o perfil, os grifos ou as resenhas da outra. No | 43.92 | 43.3 | 314.4 | 271.1 |
| `aj56.blockNote.text` *(composto)* | 3 | clube, as mensagens dela ficam recolhidas para | 61.42 | 43.3 | 311.56 | 268.26 |
| `aj56.blockNote.text` *(composto)* | 4 | você. | 78.92 | 43.3 | 73.77 | 30.47 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O topo da Conta, da Excluir conta e da Privacidade: o voltar de 48 (`#FFFAF1`, borda 1,5, sem sombra, seta 20 traço 2,2) em `left/right 20 · top 58`; o título 58 abaixo do topo da tela: Bricolage 34/800 `lh 0,98` ls −1,1 + Instrument Serif itálico 42 ls −0,5.
2. O texto 14/600 `lh 1,4`, 8 abaixo; o tipo de perfil 18 abaixo (`radiogroup`, grade de 2, gap 10): cartões de `min-height 118`, padding 14/12/12, raio 22, o rádio 24 em `top/right 10`, o título e a descrição; o escolhido com a borda preta e a cor (o outro com a borda `#E2D7C4`).
3. As listas da Conta e da Privacidade: o título da seção Bricolage 20/800 ls −0,5 com o rótulo à direita 12,5/700 `#8A8073` (pode ser vazio, como em Entrar e Pessoas), 10 acima do cartão; o cartão com padding 2/14, raio 24, `#FFFAF1`, borda 1,5, sem sombra; cada linha `min-height 64`, padding 8/0, gap 12 — o círculo 38 colorido com o ícone 18, o título 15/700 `lh 1,2`, a descrição 12,5/500 `#5B544B` e, à direita, a seta, a contagem ou a chave; o fio de 1 `#EAE1D0` entre as linhas.
4. Quem vê o quê (rótulo "só seguidores aprovados"): cada parte com a pílula de público à direita (`aria-haspopup listbox`: Seguidores ou Só eu). Pessoas: pedidos (3), me achar pelo e-mail (a chave) e bloqueadas (1).
5. O aviso 14 abaixo: padding 12/14, raio 18, tracejado 1,3 `#8A7F63`, o ícone 18 e o texto 12,5/600 com o começo em preto.
6. A chave da Conta e da Privacidade: 52 × 32, a bolinha de 23 sem visto; ligada, o trilho preto e a bolinha na cor da marca. É o 2º desenho de chave da T17 (o 1º, 54 × 32 com o visto, fica nos Ajustes e nos Lembretes).
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As chaves têm dois desenhos na T17 (54 × 32 com o visto nos Ajustes e nos Lembretes; 52 × 32 sem visto, trilho preto, na Conta e na Privacidade): no app, um widget com as duas variantes (`core/design_system/widgets/app_switch.dart`), cada tela com a sua, como a prancha. Unificar seria melhoria além do design (ROTEIRO §2b): só como proposta, com "Manter igual ao design".
- Dois fios de navalha a 390 (as descrições de Grifos novos e de Me achar pelo e-mail, 0,42 e 0,50) e mais a 360 (abaixo): as quebras dependem da largura exata da coluna da descrição.
- As linhas de "Quem vê o quê" não são links (a linha é `<div>`): só a pílula responde ao toque.
- Fio de navalha em `aj56.visibility.list.highlights.body` linha 1 «Padrão: só você. Dá para abrir»: sobra 0.42 px · estouro com a próxima palavra 29.25 px.
- Fio de navalha em `aj56.people.list.findByEmail.body` linha 1 «Quem tem seu e-mail encontra você»: sobra 0.5 px · estouro com a próxima palavra 16.01 px.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_056_privacidade_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_056_privacidade_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `aj56.lead` linha 1 «Você escolhe quem vê cada parte da sua leitura. O»: sobra 0.42 px · estouro com a próxima palavra 26.77 px.
- A 360: fio de navalha em `aj56.visibility.list.highlights.body` linha 1 «Padrão: só você. Dá»: sobra 26.75 px · estouro com a próxima palavra 0.99 px.
- A 360: fio de navalha em `aj56.visibility.list.stats.title` linha 1 «Metas e»: sobra 82.58 px · estouro com a próxima palavra 0.27 px.
- A 360: fio de navalha em `aj56.people.list.findByEmail.body` linha 1 «Quem tem seu e-mail encontra»: sobra 0.92 px · estouro com a próxima palavra 29.5 px.

## Diferenças em relação à prancha 58 (seções reutilizadas: top)

Estas seções são as mesmas widgets da 58 (fases L58_conta); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `aj56.top` | position: {"top": "58px", "right": "20px", "bottom": "1094px", "left": "20px"} → {"top": "58px", "right": "20px", "bottom": "1314px", "left": "20px"} |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `aj56.profileType` | radiogroup | Tipo de perfil |  |
| `aj56.profileType.open` | radio |  | aria-checked=false |
| `aj56.profileType.open.icon.art` |  |  | aria-hidden=true |
| `aj56.profileType.closed` | radio |  | aria-checked=true |
| `aj56.profileType.closed.radio.icon` |  |  | aria-hidden=true |
| `aj56.profileType.closed.icon.art` |  |  | aria-hidden=true |
| `aj56.visibility` |  | Quem vê o quê |  |
| `aj56.visibility.list.shelf.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.shelf.icon.art` |  |  | aria-hidden=true |
| `aj56.visibility.list.shelf.audience` |  | Quem vê: Seguidores | aria-haspopup=listbox |
| `aj56.visibility.list.shelf.audience.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.shelf.audience.chevron` |  |  | aria-hidden=true |
| `aj56.visibility.list.reviews.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.reviews.icon.art` |  |  | aria-hidden=true |
| `aj56.visibility.list.reviews.audience` |  | Quem vê: Seguidores | aria-haspopup=listbox |
| `aj56.visibility.list.reviews.audience.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.reviews.audience.chevron` |  |  | aria-hidden=true |
| `aj56.visibility.list.highlights.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.highlights.icon.art` |  |  | aria-hidden=true |
| `aj56.visibility.list.highlights.audience` |  | Quem vê: Só eu | aria-haspopup=listbox |
| `aj56.visibility.list.highlights.audience.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.highlights.audience.chevron` |  |  | aria-hidden=true |
| `aj56.visibility.list.page.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.page.icon.art` |  |  | aria-hidden=true |
| `aj56.visibility.list.page.audience` |  | Quem vê: Seguidores | aria-haspopup=listbox |
| `aj56.visibility.list.page.audience.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.page.audience.chevron` |  |  | aria-hidden=true |
| `aj56.visibility.list.lists.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.lists.icon.art` |  |  | aria-hidden=true |
| `aj56.visibility.list.lists.audience` |  | Quem vê: Seguidores | aria-haspopup=listbox |
| `aj56.visibility.list.lists.audience.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.lists.audience.chevron` |  |  | aria-hidden=true |
| `aj56.visibility.list.stats.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.stats.icon.art` |  |  | aria-hidden=true |
| `aj56.visibility.list.stats.audience` |  | Quem vê: Só eu | aria-haspopup=listbox |
| `aj56.visibility.list.stats.audience.icon` |  |  | aria-hidden=true |
| `aj56.visibility.list.stats.audience.chevron` |  |  | aria-hidden=true |
| `aj56.people` |  | Pessoas |  |
| `aj56.people.list.requests.icon` |  |  | aria-hidden=true |
| `aj56.people.list.requests.icon.art` |  |  | aria-hidden=true |
| `aj56.people.list.requests.trail.chevron` |  |  | aria-hidden=true |
| `aj56.people.list.findByEmail.icon` |  |  | aria-hidden=true |
| `aj56.people.list.findByEmail.icon.art` |  |  | aria-hidden=true |
| `aj56.people.list.findByEmail.switch` | switch | Me achar pelo e-mail | aria-checked=false |
| `aj56.people.list.blocked.icon` |  |  | aria-hidden=true |
| `aj56.people.list.blocked.icon.art` |  |  | aria-hidden=true |
| `aj56.people.list.blocked.trail.chevron` |  |  | aria-hidden=true |
| `aj56.blockNote.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `aj56.headline.serif` | TextSpan dentro do AppText.rich do pai |  |
| `aj56.profileType.open` | NeoBox |  |
| `aj56.profileType.open.radio` | CircleIconButton / NeoBox circular |  |
| `aj56.profileType.open.icon` | NeoBox |  |
| `aj56.profileType.open.icon.art` | AppSvg(AppIconsPerfil.globePerfil, size: 19) |  |
| `aj56.profileType.closed` | NeoBox |  |
| `aj56.profileType.closed.radio` | CircleIconButton / NeoBox circular |  |
| `aj56.profileType.closed.radio.icon` | AppSvg(AppIconsPerfil.checkSmallCreme, size: 13) |  |
| `aj56.profileType.closed.icon` | NeoBox |  |
| `aj56.profileType.closed.icon.art` | AppSvg(AppIconsPerfil.lock, size: 19) |  |
| `aj56.visibility.list` | NeoBox |  |
| `aj56.visibility.list.shelf` | NeoBox |  |
| `aj56.visibility.list.shelf.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.visibility.list.shelf.icon.art` | AppSvg(AppIconsPerfil.libraryLista, size: 18) |  |
| `aj56.visibility.list.shelf.audience` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj56.visibility.list.shelf.audience.icon` | AppSvg(AppIconsPerfil.peopleSmall, size: 14) |  |
| `aj56.visibility.list.shelf.audience.chevron` | AppSvg(AppIconsPerfil.chevronDownSmall, size: 14) |  |
| `aj56.visibility.list.reviews` | NeoBox |  |
| `aj56.visibility.list.reviews.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.visibility.list.reviews.icon.art` | AppSvg(AppIconsPerfil.starOutline, size: 18) |  |
| `aj56.visibility.list.reviews.audience` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj56.visibility.list.reviews.audience.icon` | AppSvg(AppIconsPerfil.peopleSmall, size: 14) |  |
| `aj56.visibility.list.reviews.audience.chevron` | AppSvg(AppIconsPerfil.chevronDownSmall, size: 14) |  |
| `aj56.visibility.list.highlights` | NeoBox |  |
| `aj56.visibility.list.highlights.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.visibility.list.highlights.icon.art` | AppSvg(AppIconsBiblioteca.highlighterBold, size: 18) |  |
| `aj56.visibility.list.highlights.audience` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj56.visibility.list.highlights.audience.icon` | AppSvg(AppIconsPerfil.lockSmall, size: 14) |  |
| `aj56.visibility.list.highlights.audience.chevron` | AppSvg(AppIconsPerfil.chevronDownSmall, size: 14) |  |
| `aj56.visibility.list.page` | NeoBox |  |
| `aj56.visibility.list.page.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.visibility.list.page.icon.art` | AppSvg(AppIconsPerfil.documentPage, size: 18) |  |
| `aj56.visibility.list.page.audience` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj56.visibility.list.page.audience.icon` | AppSvg(AppIconsPerfil.peopleSmall, size: 14) |  |
| `aj56.visibility.list.page.audience.chevron` | AppSvg(AppIconsPerfil.chevronDownSmall, size: 14) |  |
| `aj56.visibility.list.lists` | NeoBox |  |
| `aj56.visibility.list.lists.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.visibility.list.lists.icon.art` | AppSvg(AppIconsPerfil.list, size: 18) |  |
| `aj56.visibility.list.lists.audience` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj56.visibility.list.lists.audience.icon` | AppSvg(AppIconsPerfil.peopleSmall, size: 14) |  |
| `aj56.visibility.list.lists.audience.chevron` | AppSvg(AppIconsPerfil.chevronDownSmall, size: 14) |  |
| `aj56.visibility.list.stats.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.visibility.list.stats.icon.art` | AppSvg(AppIconsPerfil.barChart, size: 18) |  |
| `aj56.visibility.list.stats.audience` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj56.visibility.list.stats.audience.icon` | AppSvg(AppIconsPerfil.lockSmall, size: 14) |  |
| `aj56.visibility.list.stats.audience.chevron` | AppSvg(AppIconsPerfil.chevronDownSmall, size: 14) |  |
| `aj56.people.list` | NeoBox |  |
| `aj56.people.list.requests` | NeoBox |  |
| `aj56.people.list.requests.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.people.list.requests.icon.art` | AppSvg(AppIconsPerfil.peopleLista, size: 18) |  |
| `aj56.people.list.requests.trail.count` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj56.people.list.requests.trail.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj56.people.list.findByEmail` | NeoBox |  |
| `aj56.people.list.findByEmail.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.people.list.findByEmail.icon.art` | AppSvg(AppIconsEntrada.mailTinta, size: 18) |  |
| `aj56.people.list.findByEmail.switch` | NeoBox |  |
| `aj56.people.list.findByEmail.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `aj56.people.list.blocked.icon` | CircleIconButton / NeoBox circular |  |
| `aj56.people.list.blocked.icon.art` | AppSvg(AppIconsPerfil.block, size: 18) |  |
| `aj56.people.list.blocked.trail.count` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj56.people.list.blocked.trail.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj56.blockNote` | NeoBox |  |
| `aj56.blockNote.icon` | AppSvg(AppIconsPerfil.block, size: 18) |  |
| `aj56.blockNote.text.lead` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Aberto e Fechado → muda o tipo do perfil; com o perfil fechado, "Todos" fica indisponível nas pílulas (a nota do design).
- Pílula de público → a folha Quem vê (93–97), da T22: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).
- Pedidos para seguir → a 57, e Bloqueadas → a 98, da T22: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T17 (ROTEIRO §2b).
- Me achar pelo e-mail → a chave grava na hora.

## Dados

- O tipo do perfil já existe (`AccountSummary.isPrivate`); o público por parte, o grifo padrão e o "me achar pelo e-mail" são um documento de configurações por pessoa (a nota do design), novo: pergunta da T17. O servidor filtra; o app só mostra.
- Pedidos e bloqueadas: as contagens do social (`follow_repository.dart`).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L56.1** Título, texto e o tipo de perfil
- **L56.2** Quem vê o quê com as pílulas
- **L56.3** Pessoas com a chave
- **L56.4** Aviso do bloqueio
- **L56.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('aj56.headline', 'aj56.lead', 'aj56.profileType', 'aj56.visibility', 'aj56.people', 'aj56.blockNote'), todos os ids de `kRef56.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/056_privacidade_390x1420@3x.png` no recorte da fase (y 107.28–1360.66) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef56w360` e `kRef56w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L56.1 Título, texto e o tipo de perfil
- [ ] L56.2 Quem vê o quê com as pílulas
- [ ] L56.3 Pessoas com a chave
- [ ] L56.4 Aviso do bloqueio
- [ ] L56.5 Verificação + relatório
- [ ] Geometria 109/109 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
