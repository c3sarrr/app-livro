# FASE L58 — Conta — a capa da conta, Entrar, Sincronização (aparelhos, ler sem internet), Seus dados, sair e excluir

> Tela 58 · prancha `058_conta` (58 · Conta, canvas 390×1200) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L58_conta@3x.png` · `docs/design/medicao/projeto/png/redline/L58_conta_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/058_conta_390x1200@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_058_conta.json` · `test/reference/projeto/reference_layout_058_conta.dart` (`kRef58`).
> Arquivos sugeridos: `lib/features/settings/presentation/account/account_screen.dart`, `lib/features/settings/presentation/account/settings_list_card.dart`, `lib/core/design_system/widgets/app_switch.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Conta (58): o voltar aos ajustes, "Sua conta.", a capa da conta (avatar, nome, @ e nº da leitora, Editar), Entrar (e-mail, senha, contas conectadas), Sincronização (aparelhos, baixar para ler sem internet), Seus dados (exportar, importar CSV), sair e excluir.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{club}}` = padrão `#FFC1C6`, `{{cover}}` = padrão `#B6ACE4`.

```html
<header style="position: absolute; left: 20px; right: 20px; top: 58px; height: 48px; display: flex; align-items: center; justify-content: space-between;">
  <button aria-label="Voltar aos ajustes" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 6l-6 6 6 6"></path></svg></button>
</header>

<h1 style="margin: 0px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px;">Sua <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.5px;">conta.</span></h1>

<section aria-label="Marina Costa" style="position: relative; margin-top: 18px; display: flex; align-items: center; gap: 14px; padding: 16px 16px 16px 30px; border-radius: 8px 24px 24px 8px; background: {{cover}}; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; overflow: hidden;">
  <span aria-hidden="true" style="position: absolute; left: 0; top: 0; bottom: 0; width: 13px; background: rgba(26,23,20,0.12);"></span>
  <span aria-hidden="true" style="position: absolute; left: 16px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.28);"></span>
  <span aria-hidden="true" style="width: 58px; height: 58px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-6deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 36px; line-height: 1; padding-bottom: 4px;">M</span>
  <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;">
    <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Marina Costa</span>
    <span style="font-size: 13px; font-weight: 600; color: #2C2452;">@marinacosta · leitora nº 0052</span>
  </span>
  <button style="height: 36px; padding: 0 12px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; font-size: 12.5px; font-weight: 800;">Editar</button>
</section>

<section aria-label="Entrar" style="margin-top: 26px; display: flex; flex-direction: column; gap: 10px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 8px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px;">Entrar</h2><span style="font-size: 12.5px; font-weight: 700; color: #8A8073;"></span></div>
  <div style="padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column;"><a href="#" style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="3"></rect><path d="m4 7 8 6 8-6"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">E-mail</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">marina@email.com · confirmado</span></span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></a><a href="#" style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="8" cy="15" r="4"></circle><path d="M11 12 20 3M16 7l3 3M14 9l2 2"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Senha</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Trocada há 4 meses</span></span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></a><a href="#" style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Contas conectadas</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Login social ativo · pode desconectar</span></span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></a></div>
</section>

<section aria-label="Sincronização" style="margin-top: 26px; display: flex; flex-direction: column; gap: 10px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 8px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px;">Sincronização</h2><span style="font-size: 12.5px; font-weight: 700; color: #8A8073;">só neste celular</span></div>
  <div style="padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column;"><a href="#" style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="6" y="2.5" width="12" height="19" rx="2.5"></rect><path d="M10.5 18.5h3"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Aparelhos</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Só este celular · mais aparelhos com o Pro</span></span><span style="display: flex; align-items: center; gap: 6px;"><span style="min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: #F1E7D5; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800;">1</span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></span></a><div  style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12M7.5 10.5 12 15l4.5-4.5"></path><path d="M5 19h14"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Baixar livros para ler sem internet</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">2 e-books guardados · 4,1 MB</span></span><button role="switch" aria-checked="true" aria-label="Baixar livros para ler sem internet" style="width: 52px; height: 32px; flex-shrink: 0; padding: 3px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: flex-end;"><span style="width: 23px; height: 23px; border-radius: 50%; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;"></span></button></div></div>
</section>

<section aria-label="Seus dados" style="margin-top: 26px; display: flex; flex-direction: column; gap: 10px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 8px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px;">Seus dados</h2><span style="font-size: 12.5px; font-weight: 700; color: #8A8073;">é tudo seu</span></div>
  <div style="padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column;"><a href="#" style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12M7.5 10.5 12 15l4.5-4.5"></path><path d="M5 19h14"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Exportar meus dados</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Livros e sessões em planilha, grifos e resenhas em texto</span></span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></a><a href="#" style="min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 15V3M7.5 7.5 12 3l4.5 4.5"></path><path d="M5 19h14"></path></svg></span><span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700; line-height: 1.2;">Importar de outro app</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3;">Traga sua estante por arquivo CSV</span></span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink: 0;"><path d="m9 6 6 6-6 6"></path></svg></a></div>
</section>

<button style="margin-top: 26px; height: 52px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15px; font-weight: 800;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4"></path><path d="M9 8l-4 4 4 4M5 12h10"></path></svg>Sair desta conta</button>

<a href="#" style="margin-top: 10px; height: 48px; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800; color: #B83A1C; text-decoration: underline; text-underline-offset: 3px;"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#B83A1C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13"></path><path d="M10 11v6M14 11v6"></path></svg><span style="color: #B83A1C;">Excluir conta</span></a>
```

## Especificação pixel a pixel

Seção `aj58.top` — retângulo absoluto no canvas 390×1200: **x=20, y=58, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `aj58.top` | box | 0 | 0 | 350 | 48 | `position: absolute; left: 20px; right: 20px; top: 58px; height: 48px; display: flex; align-items: center; justify-content: space-between` |  |
| 2 | `aj58.top.back` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `aj58.top.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |

Seção `aj58.headline` — retângulo absoluto no canvas 390×1200: **x=20, y=122, w=350, h=41.16**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `aj58.headline` | text | 0 | 0 | 350 | 41.16 | `margin: 0px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1.1px #1A1714 |
| 5 | `aj58.headline.serif` ±1 | inline | 65.47 | -6.72 | 91.54 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.5px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.5px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj58.headline` *(composto)* | 1 | Sua conta. | 34.86 | 0 | 157.01 | 157.01 |

Seção `aj58.account` — retângulo absoluto no canvas 390×1200: **x=20, y=181.16, w=350, h=93**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `aj58.account` | box | 0 | 0 | 350 | 93 | `position: relative; margin-top: 18px; display: flex; align-items: center; gap: 14px; padding: 16px 16px 16px 30px; border-radius: 8px 24px 24px 8px; background: {{cover}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; overflow: hidden` |  |
| 7 | `aj58.account.spine` | box | 1.5 | 1.5 | 13 | 90 | `position: absolute; left: 0; top: 0; bottom: 0; width: 13px; background: rgba(26,23,20,0.12)` |  |
| 8 | `aj58.account.spineLine` | box | 17.5 | 1.5 | 1.5 | 90 | `position: absolute; left: 16px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.28)` |  |
| 9 | `aj58.account.avatar` | box+text | 31.5 | 17.5 | 58 | 58 | `width: 58px; height: 58px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-6deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 36px; line-height: 1; padding-bottom: 4px` | Instrument Serif itálico 36/36px peso 400 ls normal #1A1714 |
| 10 | `aj58.account.textBlock` ±1 | box | 103.5 | 17.9 | 153.36 | 57.2 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 11 | `aj58.account.name` ±1 | text | 103.5 | 17.9 | 153.36 | 24 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 12 | `aj58.account.handle` ±1 | text | 103.5 | 43.9 | 153.36 | 31.2 | `font-size: 13px; font-weight: 600; color: #2C2452` | Figtree 13/normal peso 600 ls normal #2C2452 |
| 13 | `aj58.account.edit` ±1 | box+text | 270.86 | 28.5 | 61.64 | 36 | `height: 36px; padding: 0 12px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.3px solid #1A1714; box-sizing: border-box; font-size: 12.5px; font-weight: 800` | Figtree 12.5/normal peso 800 ls normal #1A1714 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `aj58.account.avatar`: caixa visual com `transform: rotate(-6deg)` = x 28.63, y 14.63, w 63.74, h 63.74 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj58.account.avatar` | 1 | M | 56.74 | 48.53 | 72.47 | 23.94 |
| `aj58.account.name` | 1 | Marina Costa | 36.5 | 103.5 | 229.57 | 126.07 |
| `aj58.account.handle` | 1 | @marinacosta · leitora nº | 56.25 | 103.5 | 251.45 | 147.95 |
| `aj58.account.handle` | 2 | 0052 | 71.85 | 103.5 | 135.21 | 31.71 |
| `aj58.account.edit` | 1 | Editar | 50.87 | 284.16 | 319.2 | 35.04 |

Seção `aj58.signIn` — retângulo absoluto no canvas 390×1200: **x=20, y=300.16, w=350, h=283**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 14 | `aj58.signIn` | box | 0 | 0 | 350 | 283 | `margin-top: 26px; display: flex; flex-direction: column; gap: 10px` |  |
| 15 | `aj58.signIn.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 8px` |  |
| 16 | `aj58.signIn.header.title` ±1 | text | 0 | 0 | 59.39 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.5px #1A1714 |
| 17 | `aj58.signIn.header.note` | box | 350 | 18.6 | 0 | 0 | `font-size: 12.5px; font-weight: 700; color: #8A8073` |  |
| 18 | `aj58.signIn.list` | box | 0 | 34 | 350 | 249 | `padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 19 | `aj58.signIn.list.email` | box | 15.5 | 37.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 20 | `aj58.signIn.list.email.icon` | box | 15.5 | 58.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 21 | `aj58.signIn.list.email.icon.art` | icon | 25.5 | 68.5 | 18 | 18 | `—` |  |
| 22 | `aj58.signIn.list.email.textBlock` | box | 65.5 | 59.38 | 239 | 36.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 23 | `aj58.signIn.list.email.title` | text | 65.5 | 59.38 | 239 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 24 | `aj58.signIn.list.email.body` | text | 65.5 | 79.38 | 239 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 25 | `aj58.signIn.list.email.chevron` | icon | 316.5 | 68.5 | 18 | 18 | `flex-shrink: 0` |  |
| 26 | `aj58.signIn.list.password` | box | 15.5 | 118.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 27 | `aj58.signIn.list.password.icon` | box | 15.5 | 139.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 28 | `aj58.signIn.list.password.icon.art` | icon | 25.5 | 149.5 | 18 | 18 | `—` |  |
| 29 | `aj58.signIn.list.password.textBlock` | box | 65.5 | 140.38 | 239 | 36.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 30 | `aj58.signIn.list.password.title` | text | 65.5 | 140.38 | 239 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 31 | `aj58.signIn.list.password.body` | text | 65.5 | 160.38 | 239 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 32 | `aj58.signIn.list.password.chevron` | icon | 316.5 | 149.5 | 18 | 18 | `flex-shrink: 0` |  |
| 33 | `aj58.signIn.list.connected` | box | 15.5 | 199.5 | 319 | 80 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px` |  |
| 34 | `aj58.signIn.list.connected.icon` | box | 15.5 | 220.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 35 | `aj58.signIn.list.connected.icon.art` | icon | 25.5 | 230.5 | 18 | 18 | `—` |  |
| 36 | `aj58.signIn.list.connected.textBlock` | box | 65.5 | 221.37 | 239 | 36.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 37 | `aj58.signIn.list.connected.title` | text | 65.5 | 221.37 | 239 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 38 | `aj58.signIn.list.connected.body` | text | 65.5 | 241.37 | 239 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 39 | `aj58.signIn.list.connected.chevron` | icon | 316.5 | 230.5 | 18 | 18 | `flex-shrink: 0` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj58.signIn.header.title` | 1 | Entrar | 18.6 | 0 | 59.39 | 59.39 |
| `aj58.signIn.list.email.title` | 1 | E-mail | 73.63 | 65.5 | 109.15 | 43.65 |
| `aj58.signIn.list.email.body` | 1 | marina@email.com · confirmado | 91.88 | 65.5 | 247.35 | 181.85 |
| `aj58.signIn.list.password.title` | 1 | Senha | 154.63 | 65.5 | 107.98 | 42.48 |
| `aj58.signIn.list.password.body` | 1 | Trocada há 4 meses | 172.88 | 65.5 | 177.05 | 111.55 |
| `aj58.signIn.list.connected.title` | 1 | Contas conectadas | 235.62 | 65.5 | 197.78 | 132.28 |
| `aj58.signIn.list.connected.body` | 1 | Login social ativo · pode desconectar | 253.87 | 65.5 | 274.37 | 208.87 |

Seção `aj58.sync` — retângulo absoluto no canvas 390×1200: **x=20, y=609.16, w=350, h=202**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 40 | `aj58.sync` | box | 0 | 0 | 350 | 202 | `margin-top: 26px; display: flex; flex-direction: column; gap: 10px` |  |
| 41 | `aj58.sync.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 8px` |  |
| 42 | `aj58.sync.header.title` ±1 | text | 0 | 0 | 133.57 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.5px #1A1714 |
| 43 | `aj58.sync.header.note` ±1 | text | 260.88 | 6.72 | 89.12 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #8A8073` | Figtree 12.5/normal peso 700 ls normal #8A8073 |
| 44 | `aj58.sync.list` | box | 0 | 34 | 350 | 168 | `padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 45 | `aj58.sync.list.devices` | box | 15.5 | 37.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 46 | `aj58.sync.list.devices.icon` | box | 15.5 | 58.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 47 | `aj58.sync.list.devices.icon.art` | icon | 25.5 | 68.5 | 18 | 18 | `—` |  |
| 48 | `aj58.sync.list.devices.textBlock` | box | 65.5 | 51.25 | 209 | 52.5 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 49 | `aj58.sync.list.devices.title` | text | 65.5 | 51.25 | 209 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 50 | `aj58.sync.list.devices.body` | text | 65.5 | 71.25 | 209 | 32.5 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 51 | `aj58.sync.list.devices.trail` | box | 286.5 | 65.5 | 48 | 24 | `display: flex; align-items: center; gap: 6px` |  |
| 52 | `aj58.sync.list.devices.trail.count` | box+text | 286.5 | 65.5 | 24 | 24 | `min-width: 24px; height: 24px; padding: 0 7px; border-radius: 999px; background: #F1E7D5; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 53 | `aj58.sync.list.devices.trail.chevron` | icon | 316.5 | 68.5 | 18 | 18 | `flex-shrink: 0` |  |
| 54 | `aj58.sync.list.offline` | box | 15.5 | 118.5 | 319 | 80 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px` |  |
| 55 | `aj58.sync.list.offline.icon` | box | 15.5 | 139.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 56 | `aj58.sync.list.offline.icon.art` | icon | 25.5 | 149.5 | 18 | 18 | `—` |  |
| 57 | `aj58.sync.list.offline.textBlock` | box | 65.5 | 131.38 | 205 | 54.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 58 | `aj58.sync.list.offline.title` | text | 65.5 | 131.38 | 205 | 36 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 59 | `aj58.sync.list.offline.body` | text | 65.5 | 169.38 | 205 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 60 | `aj58.sync.list.offline.switch` | box | 282.5 | 142.5 | 52 | 32 | `width: 52px; height: 32px; flex-shrink: 0; padding: 3px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: flex-end` |  |
| 61 | `aj58.sync.list.offline.switch.thumb` | box | 307 | 147 | 23 | 23 | `width: 23px; height: 23px; border-radius: 50%; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj58.sync.header.title` | 1 | Sincronização | 18.6 | 0 | 133.57 | 133.57 |
| `aj58.sync.header.note` | 1 | só neste celular | 18.6 | 260.88 | 350 | 89.12 |
| `aj58.sync.list.devices.title` | 1 | Aparelhos | 65.5 | 65.5 | 135.16 | 69.66 |
| `aj58.sync.list.devices.body` | 1 | Só este celular · mais aparelhos com | 83.75 | 65.5 | 268.48 | 202.98 |
| `aj58.sync.list.devices.body` | 2 | o Pro | 100 | 65.5 | 94.69 | 29.19 |
| `aj58.sync.list.devices.trail.count` | 1 | 1 | 81.7 | 295.94 | 301.06 | 5.12 |
| `aj58.sync.list.offline.title` | 1 | Baixar livros para ler sem | 145.62 | 65.5 | 236.44 | 170.94 |
| `aj58.sync.list.offline.title` | 2 | internet | 163.62 | 65.5 | 120.7 | 55.2 |
| `aj58.sync.list.offline.body` | 1 | 2 e-books guardados · 4,1 MB | 181.87 | 65.5 | 230.59 | 165.09 |

Seção `aj58.data` — retângulo absoluto no canvas 390×1200: **x=20, y=837.16, w=350, h=202**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 62 | `aj58.data` | box | 0 | 0 | 350 | 202 | `margin-top: 26px; display: flex; flex-direction: column; gap: 10px` |  |
| 63 | `aj58.data.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 8px` |  |
| 64 | `aj58.data.header.title` ±1 | text | 0 | 0 | 108.58 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.5px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.5px #1A1714 |
| 65 | `aj58.data.header.note` ±1 | text | 290.41 | 6.72 | 59.59 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #8A8073` | Figtree 12.5/normal peso 700 ls normal #8A8073 |
| 66 | `aj58.data.list` | box | 0 | 34 | 350 | 168 | `padding: 2px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 67 | `aj58.data.list.export` | box | 15.5 | 37.5 | 319 | 81 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 68 | `aj58.data.list.export.icon` | box | 15.5 | 58.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 69 | `aj58.data.list.export.icon.art` | icon | 25.5 | 68.5 | 18 | 18 | `—` |  |
| 70 | `aj58.data.list.export.textBlock` | box | 65.5 | 51.25 | 239 | 52.5 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 71 | `aj58.data.list.export.title` | text | 65.5 | 51.25 | 239 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 72 | `aj58.data.list.export.body` | text | 65.5 | 71.25 | 239 | 32.5 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 73 | `aj58.data.list.export.chevron` | icon | 316.5 | 68.5 | 18 | 18 | `flex-shrink: 0` |  |
| 74 | `aj58.data.list.import` | box | 15.5 | 118.5 | 319 | 80 | `min-height: 64px; padding: 8px 0; display: flex; align-items: center; gap: 12px` |  |
| 75 | `aj58.data.list.import.icon` | box | 15.5 | 139.5 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 76 | `aj58.data.list.import.icon.art` | icon | 25.5 | 149.5 | 18 | 18 | `—` |  |
| 77 | `aj58.data.list.import.textBlock` | box | 65.5 | 140.38 | 239 | 36.25 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 78 | `aj58.data.list.import.title` | text | 65.5 | 140.38 | 239 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 79 | `aj58.data.list.import.body` | text | 65.5 | 160.38 | 239 | 16.25 | `font-size: 12.5px; font-weight: 500; color: #5B544B; line-height: 1.3` | Figtree 12.5/16.25px peso 500 ls normal #5B544B |
| 80 | `aj58.data.list.import.chevron` | icon | 316.5 | 149.5 | 18 | 18 | `flex-shrink: 0` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj58.data.header.title` | 1 | Seus dados | 18.6 | 0 | 108.59 | 108.59 |
| `aj58.data.header.note` | 1 | é tudo seu | 18.6 | 290.41 | 350 | 59.59 |
| `aj58.data.list.export.title` | 1 | Exportar meus dados | 65.5 | 65.5 | 210.96 | 145.46 |
| `aj58.data.list.export.body` | 1 | Livros e sessões em planilha, grifos e | 83.75 | 65.5 | 271.33 | 205.83 |
| `aj58.data.list.export.body` | 2 | resenhas em texto | 100 | 65.5 | 168.99 | 103.49 |
| `aj58.data.list.import.title` | 1 | Importar de outro app | 154.62 | 65.5 | 217.54 | 152.04 |
| `aj58.data.list.import.body` | 1 | Traga sua estante por arquivo CSV | 172.87 | 65.5 | 259.9 | 194.4 |

Seção `aj58.signOut` — retângulo absoluto no canvas 390×1200: **x=20, y=1065.16, w=350, h=52**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 81 | `aj58.signOut` | box+text | 0 | 0 | 350 | 52 | `margin-top: 26px; height: 52px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 82 | `aj58.signOut.icon` ±1 | icon | 105.67 | 17 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj58.signOut` | 1 | Sair desta conta | 31.25 | 131.67 | 244.33 | 112.66 |

Seção `aj58.delete` — retângulo absoluto no canvas 390×1200: **x=20, y=1127.16, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 83 | `aj58.delete` | box | 0 | 0 | 350 | 48 | `margin-top: 10px; height: 48px; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 14px; font-weight: 800; color: #B83A1C; text-decoration: underline; text-underline-offset: 3px` |  |
| 84 | `aj58.delete.icon` ±1 | icon | 120.59 | 15.5 | 17 | 17 | `—` |  |
| 85 | `aj58.delete.label` ±1 | text | 144.59 | 15.6 | 84.83 | 16.8 | `color: #B83A1C` | Figtree 14/normal peso 800 ls normal #B83A1C |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj58.delete.label` | 1 | Excluir conta | 28.9 | 144.59 | 229.41 | 84.82 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O topo da Conta, da Excluir conta e da Privacidade: o voltar de 48 (`#FFFAF1`, borda 1,5, sem sombra, seta 20 traço 2,2) em `left/right 20 · top 58`; o título 58 abaixo do topo da tela: Bricolage 34/800 `lh 0,98` ls −1,1 + Instrument Serif itálico 42 ls −0,5.
2. Capa 18 abaixo: padding 16/16/16/30, raio 8/24/24/8, `{{cover}}`, borda 1,5, sombra 4/4, a lombada e o vinco; o avatar 58 girado −6°; o nome Bricolage 20/800 e "@marinacosta · leitora nº 0052" 13/600 `#2C2452`; o "Editar" numa pílula de 36 (borda 1,3, 12,5/800).
3. As listas da Conta e da Privacidade: o título da seção Bricolage 20/800 ls −0,5 com o rótulo à direita 12,5/700 `#8A8073` (pode ser vazio, como em Entrar e Pessoas), 10 acima do cartão; o cartão com padding 2/14, raio 24, `#FFFAF1`, borda 1,5, sem sombra; cada linha `min-height 64`, padding 8/0, gap 12 — o círculo 38 colorido com o ícone 18, o título 15/700 `lh 1,2`, a descrição 12,5/500 `#5B544B` e, à direita, a seta, a contagem ou a chave; o fio de 1 `#EAE1D0` entre as linhas.
4. Entrar: e-mail (confirmado), senha (trocada há 4 meses) e contas conectadas (login social ativo); Sincronização (rótulo "só neste celular"): aparelhos (com a contagem 1) e "Baixar livros para ler sem internet" com a chave; Seus dados (rótulo "é tudo seu"): exportar e importar de outro app.
5. "Sair desta conta" 26 abaixo (52, `#FFFAF1`, borda 1,5, 15/800, a porta 18) e "Excluir conta" (48, 14/800 `#B83A1C` sublinhado com 3 de recuo, a lixeira 17), 10 abaixo.
6. A chave da Conta e da Privacidade: 52 × 32, a bolinha de 23 sem visto; ligada, o trilho preto e a bolinha na cor da marca. É o 2º desenho de chave da T17 (o 1º, 54 × 32 com o visto, fica nos Ajustes e nos Lembretes).
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As chaves têm dois desenhos na T17 (54 × 32 com o visto nos Ajustes e nos Lembretes; 52 × 32 sem visto, trilho preto, na Conta e na Privacidade): no app, um widget com as duas variantes (`core/design_system/widgets/app_switch.dart`), cada tela com a sua, como a prancha. Unificar seria melhoria além do design (ROTEIRO §2b): só como proposta, com "Manter igual ao design".
- O cartão da conta tem 93 de altura aqui e 107,6 nos Ajustes (06): são componentes diferentes.
- A 360 a descrição das contas conectadas fica num fio de navalha (0,13) e, a 430, a da exportação (abaixo).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_058_conta_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_058_conta_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `aj58.signIn.list.connected.body` linha 1 «Login social ativo · pode desconectar»: sobra 0.13 px · sem palavra seguinte (D-275: a linha única quebra se crescer).
- A 430: fio de navalha em `aj58.data.list.export.body` linha 1 «Livros e sessões em planilha, grifos e resenhas»: sobra 19.93 px · estouro com a próxima palavra 0.68 px.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `aj58.top.back` |  | Voltar aos ajustes |  |
| `aj58.top.back.icon` |  |  | aria-hidden=true |
| `aj58.account` |  | Marina Costa |  |
| `aj58.account.spine` |  |  | aria-hidden=true |
| `aj58.account.spineLine` |  |  | aria-hidden=true |
| `aj58.account.avatar` |  |  | aria-hidden=true |
| `aj58.signIn` |  | Entrar |  |
| `aj58.signIn.list.email.icon` |  |  | aria-hidden=true |
| `aj58.signIn.list.email.icon.art` |  |  | aria-hidden=true |
| `aj58.signIn.list.email.chevron` |  |  | aria-hidden=true |
| `aj58.signIn.list.password.icon` |  |  | aria-hidden=true |
| `aj58.signIn.list.password.icon.art` |  |  | aria-hidden=true |
| `aj58.signIn.list.password.chevron` |  |  | aria-hidden=true |
| `aj58.signIn.list.connected.icon` |  |  | aria-hidden=true |
| `aj58.signIn.list.connected.icon.art` |  |  | aria-hidden=true |
| `aj58.signIn.list.connected.chevron` |  |  | aria-hidden=true |
| `aj58.sync` |  | Sincronização |  |
| `aj58.sync.list.devices.icon` |  |  | aria-hidden=true |
| `aj58.sync.list.devices.icon.art` |  |  | aria-hidden=true |
| `aj58.sync.list.devices.trail.chevron` |  |  | aria-hidden=true |
| `aj58.sync.list.offline.icon` |  |  | aria-hidden=true |
| `aj58.sync.list.offline.icon.art` |  |  | aria-hidden=true |
| `aj58.sync.list.offline.switch` | switch | Baixar livros para ler sem internet | aria-checked=true |
| `aj58.data` |  | Seus dados |  |
| `aj58.data.list.export.icon` |  |  | aria-hidden=true |
| `aj58.data.list.export.icon.art` |  |  | aria-hidden=true |
| `aj58.data.list.export.chevron` |  |  | aria-hidden=true |
| `aj58.data.list.import.icon` |  |  | aria-hidden=true |
| `aj58.data.list.import.icon.art` |  |  | aria-hidden=true |
| `aj58.data.list.import.chevron` |  |  | aria-hidden=true |
| `aj58.signOut.icon` |  |  | aria-hidden=true |
| `aj58.delete.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `aj58.top.back` | CircleIconButton / NeoBox circular |  |
| `aj58.top.back.icon` | AppSvg(AppIconsPerfil.chevronLeft, size: 20) |  |
| `aj58.headline.serif` | TextSpan dentro do AppText.rich do pai |  |
| `aj58.account` | NeoBox |  |
| `aj58.account.spine` | NeoBox |  |
| `aj58.account.spineLine` | NeoBox |  |
| `aj58.account.avatar` | CircleIconButton / NeoBox circular | Transform: rotate(-6deg) |
| `aj58.account.edit` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj58.signIn.list` | NeoBox |  |
| `aj58.signIn.list.email` | NeoBox |  |
| `aj58.signIn.list.email.icon` | CircleIconButton / NeoBox circular |  |
| `aj58.signIn.list.email.icon.art` | AppSvg(AppIconsEntrada.mailTinta, size: 18) |  |
| `aj58.signIn.list.email.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj58.signIn.list.password` | NeoBox |  |
| `aj58.signIn.list.password.icon` | CircleIconButton / NeoBox circular |  |
| `aj58.signIn.list.password.icon.art` | AppSvg(AppIconsPerfil.key, size: 18) |  |
| `aj58.signIn.list.password.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj58.signIn.list.connected.icon` | CircleIconButton / NeoBox circular |  |
| `aj58.signIn.list.connected.icon.art` | AppSvg(AppIconsPerfil.peopleLista, size: 18) |  |
| `aj58.signIn.list.connected.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj58.sync.list` | NeoBox |  |
| `aj58.sync.list.devices` | NeoBox |  |
| `aj58.sync.list.devices.icon` | CircleIconButton / NeoBox circular |  |
| `aj58.sync.list.devices.icon.art` | AppSvg(AppIconsPerfil.phone, size: 18) |  |
| `aj58.sync.list.devices.trail.count` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj58.sync.list.devices.trail.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj58.sync.list.offline.icon` | CircleIconButton / NeoBox circular |  |
| `aj58.sync.list.offline.icon.art` | AppSvg(AppIconsInicio.download, size: 18) |  |
| `aj58.sync.list.offline.switch` | NeoBox |  |
| `aj58.sync.list.offline.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `aj58.data.list` | NeoBox |  |
| `aj58.data.list.export` | NeoBox |  |
| `aj58.data.list.export.icon` | CircleIconButton / NeoBox circular |  |
| `aj58.data.list.export.icon.art` | AppSvg(AppIconsInicio.download, size: 18) |  |
| `aj58.data.list.export.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj58.data.list.import.icon` | CircleIconButton / NeoBox circular |  |
| `aj58.data.list.import.icon.art` | AppSvg(AppIconsPerfil.upload, size: 18) |  |
| `aj58.data.list.import.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj58.signOut` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj58.signOut.icon` | AppSvg(AppIconsPerfil.signOutFino, size: 18) |  |
| `aj58.delete.icon` | AppSvg(AppIconsPerfil.trashDelete, size: 17) |  |

## Interações

- Voltar → os Ajustes. Editar → a 64.
- E-mail, senha e contas conectadas → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b) (as telas de trocar não têm prancha; a troca de senha usa as telas 10 e 11 da T16, se a T17 decidir).
- Aparelhos → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b) (mais aparelhos = o Pro, da T19).
- Chave de ler sem internet → guarda os e-books no aparelho (o que já acontece com os baixados).
- Exportar meus dados → Exportar meus dados: tela que falta (D-268), da própria T17 — perguntar, buscar 3–5 referências, desenhar a prancha em `docs/design/novas/` e esperar o "sim" antes do Flutter (ROTEIRO §5). Importar de outro app → Importar CSV: tela que falta (D-268), da própria T17 — perguntar, buscar 3–5 referências, desenhar a prancha em `docs/design/novas/` e esperar o "sim" antes do Flutter (ROTEIRO §5).
- Sair desta conta → a `signOut` (D-65). Excluir conta → a 59.

## Dados

- Conta (`AccountSummary`): o @, o nome e o nº da leitora; o e-mail e o "confirmado", da autenticação; o resto ("trocada há 4 meses", "login social ativo", os aparelhos — `otherSessions` — e os e-books guardados com o tamanho, "2 e-books guardados · 4,1 MB") vem do que o app já sabe; o que faltar é pergunta da T17.
- Exportar hoje é o JSON local pela folha do sistema (D-65), e a nota do design diz que o arquivo chega por e-mail: entra na tela que falta (Exportar meus dados).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L58.1** Topo, título e capa da conta
- **L58.2** Entrar
- **L58.3** Sincronização com a chave
- **L58.4** Seus dados
- **L58.5** Sair e excluir
- **L58.6** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('aj58.top', 'aj58.headline', 'aj58.account', 'aj58.signIn', 'aj58.sync', 'aj58.data', 'aj58.signOut', 'aj58.delete'), todos os ids de `kRef58.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/058_conta_390x1200@3x.png` no recorte da fase (y 50–1183.16) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef58w360` e `kRef58w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L58.1 Topo, título e capa da conta
- [ ] L58.2 Entrar
- [ ] L58.3 Sincronização com a chave
- [ ] L58.4 Seus dados
- [ ] L58.5 Sair e excluir
- [ ] L58.6 Verificação + relatório
- [ ] Geometria 84/84 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
