# FASE L06 — Ajustes — Mais ajustes, Ajuda e o rodapé (sair, excluir, versão)

> Tela 06 · prancha `006_ajustes` (06 · Ajustes (engrenagem), canvas 390×2400) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L06_4_mais_e_ajuda@3x.png` · `docs/design/medicao/projeto/png/redline/L06_4_mais_e_ajuda_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/006_ajustes_390x2400@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_006_ajustes.json` · `test/reference/projeto/reference_layout_006_ajustes.dart` (`kRef06`).
> Arquivos sugeridos: `lib/features/settings/presentation/sections/more_settings_section.dart`, `lib/features/settings/presentation/sections/help_section.dart`, `lib/features/settings/presentation/sections/account_actions.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Ajustes (06), embaixo: Mais ajustes (Notificações, Privacidade, Biblioteca e dados, Scanner, Aparência do app, Idioma e acessibilidade), Ajuda (central, fale com a gente, termos) e o rodapé — sair, excluir e a versão; a navegação e o degradê do Perfil, presos ao fundo.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`.

```html
<!-- More settings -->
<section aria-label="Mais ajustes" style="margin-top: 34px; display: flex; flex-direction: column; gap: 12px;">
  <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px;">Mais ajustes</h2>
  <div style="padding: 4px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column;">

    <a href="#" style="min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;">
      <span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 8a6 6 0 1 1 12 0c0 7 3 9 3 9H3s3-2 3-9"></path><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"></path></svg></span>
      <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700;">Notificações</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Clubes, respostas e lembretes</span></span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>

    <a href="#" style="min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;">
      <span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="11" width="14" height="10" rx="2.5"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path></svg></span>
      <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700;">Privacidade</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Perfil fechado · 3 pedidos</span></span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>

    <a href="#" style="min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;">
      <span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7a2 2 0 0 1 2-2h4l2 2h6a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"></path><path d="M12 10.5v5.5M9.5 13.5 12 16l2.5-2.5"></path></svg></span>
      <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700;">Biblioteca e dados</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Importar, exportar e ler sem internet</span></span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>

    <a href="#" style="min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;">
      <span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3.5 8V6a2.5 2.5 0 0 1 2.5-2.5h2"></path><path d="M16 3.5h2A2.5 2.5 0 0 1 20.5 6v2"></path><path d="M20.5 16v2a2.5 2.5 0 0 1-2.5 2.5h-2"></path><path d="M8 20.5H6A2.5 2.5 0 0 1 3.5 18v-2"></path><path d="M8.5 8.5v7M12 8.5v7M15.5 8.5v7"></path></svg></span>
      <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700;">Scanner</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Som e vibração ao ler o código</span></span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>

    <a href="#" style="min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;">
      <span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="8"></circle><path d="M12 4a8 8 0 0 0 0 16z" fill="#1A1714"></path></svg></span>
      <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700;">Aparência do app</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Automático · cor de destaque lavanda</span></span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>

    <a href="#" style="min-height: 66px; display: flex; align-items: center; gap: 12px;">
      <span aria-hidden="true" style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"></circle><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"></path></svg></span>
      <span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 15px; font-weight: 700;">Idioma e acessibilidade</span><span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">Português (Brasil) · texto maior</span></span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>
  </div>
</section>

<!-- Help -->
<section aria-label="Ajuda" style="margin-top: 34px; display: flex; flex-direction: column; gap: 12px;">
  <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px;">Ajuda</h2>
  <div style="padding: 4px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column;">
    <a href="#" style="min-height: 56px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"></circle><path d="M9.5 9.2a2.6 2.6 0 1 1 3.6 2.4c-.7.3-1.1.9-1.1 1.6v.6"></path><path d="M12 17h.01"></path></svg>
      <span style="flex-grow: 1; font-size: 15px; font-weight: 700;">Central de ajuda</span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>
    <a href="#" style="min-height: 56px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12z"></path></svg>
      <span style="flex-grow: 1; font-size: 15px; font-weight: 700;">Fale com a gente</span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>
    <a href="#" style="min-height: 56px; display: flex; align-items: center; gap: 12px;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 3h7l4 4v14H7z"></path><path d="M14 3v4h4"></path><path d="M10 12h5M10 16h5"></path></svg>
      <span style="flex-grow: 1; font-size: 15px; font-weight: 700;">Termos e privacidade</span>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
    </a>
  </div>
</section>

<!-- Account actions (kept apart, at the end) -->
<div style="margin-top: 30px; display: flex; flex-direction: column; align-items: center; gap: 6px;">
  <button style="width: 100%; height: 52px; display: flex; align-items: center; justify-content: center; gap: 8px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 15px; font-weight: 800;">
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3"></path><path d="m10 17-5-5 5-5"></path><path d="M5 12h11"></path></svg>
    Sair da conta
  </button>
  <button style="height: 44px; padding: 0 12px; background: transparent; border: none; font-size: 14px; font-weight: 800; color: #A3301A;">Excluir conta</button>
  <span style="display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 600; color: #6F665B;">
    <svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#6F665B"></path></svg>
    Versão 3.0 · feito para quem lê
  </span>
</div>
```

## Especificação pixel a pixel

Seção `aj06.more` — retângulo absoluto no canvas 390×2400: **x=20, y=1404.93, w=350, h=450.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `aj06.more` | box | 0 | 0 | 350 | 450.4 | `margin-top: 34px; display: flex; flex-direction: column; gap: 12px` |  |
| 2 | `aj06.more.title` | text | 0 | 0 | 350 | 26.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/normal peso 800 ls -0.5px #1A1714 |
| 3 | `aj06.more.list` | box | 0 | 38.4 | 350 | 412 | `padding: 4px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 4 | `aj06.more.list.notifications` | box | 15.5 | 43.9 | 319 | 67 | `min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 5 | `aj06.more.list.notifications.icon` | box | 15.5 | 57.9 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 6 | `aj06.more.list.notifications.icon.art` | icon | 25.5 | 67.9 | 18 | 18 | `—` |  |
| 7 | `aj06.more.list.notifications.textBlock` | box | 65.5 | 59.4 | 239 | 35.01 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 8 | `aj06.more.list.notifications.title` | text | 65.5 | 59.4 | 239 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 9 | `aj06.more.list.notifications.body` | text | 65.5 | 79.4 | 239 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 10 | `aj06.more.list.notifications.chevron` | icon | 316.5 | 67.9 | 18 | 18 | `—` |  |
| 11 | `aj06.more.list.privacy` | box | 15.5 | 110.9 | 319 | 67 | `min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 12 | `aj06.more.list.privacy.icon` | box | 15.5 | 124.9 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 13 | `aj06.more.list.privacy.icon.art` | icon | 25.5 | 134.9 | 18 | 18 | `—` |  |
| 14 | `aj06.more.list.privacy.textBlock` | box | 65.5 | 126.4 | 239 | 35.01 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 15 | `aj06.more.list.privacy.title` | text | 65.5 | 126.4 | 239 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 16 | `aj06.more.list.privacy.body` | text | 65.5 | 146.4 | 239 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 17 | `aj06.more.list.privacy.chevron` | icon | 316.5 | 134.9 | 18 | 18 | `—` |  |
| 18 | `aj06.more.list.library` | box | 15.5 | 177.9 | 319 | 67 | `min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 19 | `aj06.more.list.library.icon` | box | 15.5 | 191.9 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 20 | `aj06.more.list.library.icon.art` | icon | 25.5 | 201.9 | 18 | 18 | `—` |  |
| 21 | `aj06.more.list.library.textBlock` | box | 65.5 | 193.4 | 239 | 35.01 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 22 | `aj06.more.list.library.title` | text | 65.5 | 193.4 | 239 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 23 | `aj06.more.list.library.body` | text | 65.5 | 213.4 | 239 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 24 | `aj06.more.list.library.chevron` | icon | 316.5 | 201.9 | 18 | 18 | `—` |  |
| 25 | `aj06.more.list.scanner` | box | 15.5 | 244.9 | 319 | 67 | `min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 26 | `aj06.more.list.scanner.icon` | box | 15.5 | 258.9 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 27 | `aj06.more.list.scanner.icon.art` | icon | 25.5 | 268.9 | 18 | 18 | `—` |  |
| 28 | `aj06.more.list.scanner.textBlock` | box | 65.5 | 260.4 | 239 | 35.01 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 29 | `aj06.more.list.scanner.title` | text | 65.5 | 260.4 | 239 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 30 | `aj06.more.list.scanner.body` | text | 65.5 | 280.4 | 239 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 31 | `aj06.more.list.scanner.chevron` | icon | 316.5 | 268.9 | 18 | 18 | `—` |  |
| 32 | `aj06.more.list.appearance` | box | 15.5 | 311.9 | 319 | 67 | `min-height: 66px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 33 | `aj06.more.list.appearance.icon` | box | 15.5 | 325.9 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 34 | `aj06.more.list.appearance.icon.art` | icon | 25.5 | 335.9 | 18 | 18 | `—` |  |
| 35 | `aj06.more.list.appearance.textBlock` | box | 65.5 | 327.4 | 239 | 35.01 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 36 | `aj06.more.list.appearance.title` | text | 65.5 | 327.4 | 239 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 37 | `aj06.more.list.appearance.body` | text | 65.5 | 347.4 | 239 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 38 | `aj06.more.list.appearance.chevron` | icon | 316.5 | 335.9 | 18 | 18 | `—` |  |
| 39 | `aj06.more.list.language` | box | 15.5 | 378.9 | 319 | 66 | `min-height: 66px; display: flex; align-items: center; gap: 12px` |  |
| 40 | `aj06.more.list.language.icon` | box | 15.5 | 392.9 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 41 | `aj06.more.list.language.icon.art` | icon | 25.5 | 402.9 | 18 | 18 | `—` |  |
| 42 | `aj06.more.list.language.textBlock` | box | 65.5 | 394.4 | 239 | 35.01 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 43 | `aj06.more.list.language.title` | text | 65.5 | 394.4 | 239 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 44 | `aj06.more.list.language.body` | text | 65.5 | 414.4 | 239 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 45 | `aj06.more.list.language.chevron` | icon | 316.5 | 402.9 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj06.more.title` | 1 | Mais ajustes | 20.46 | 0 | 129.41 | 129.41 |
| `aj06.more.list.notifications.title` | 1 | Notificações | 73.65 | 65.5 | 153.99 | 88.49 |
| `aj06.more.list.notifications.body` | 1 | Clubes, respostas e lembretes | 91.28 | 65.5 | 234.31 | 168.81 |
| `aj06.more.list.privacy.title` | 1 | Privacidade | 140.65 | 65.5 | 146.5 | 81 |
| `aj06.more.list.privacy.body` | 1 | Perfil fechado · 3 pedidos | 158.28 | 65.5 | 208.05 | 142.55 |
| `aj06.more.list.library.title` | 1 | Biblioteca e dados | 207.65 | 65.5 | 191.28 | 125.78 |
| `aj06.more.list.library.body` | 1 | Importar, exportar e ler sem internet | 225.28 | 65.5 | 268.86 | 203.36 |
| `aj06.more.list.scanner.title` | 1 | Scanner | 274.65 | 65.5 | 121.82 | 56.32 |
| `aj06.more.list.scanner.body` | 1 | Som e vibração ao ler o código | 292.28 | 65.5 | 238.52 | 173.02 |
| `aj06.more.list.appearance.title` | 1 | Aparência do app | 341.65 | 65.5 | 186.7 | 121.2 |
| `aj06.more.list.appearance.body` | 1 | Automático · cor de destaque lavanda | 359.28 | 65.5 | 278.34 | 212.84 |
| `aj06.more.list.language.title` | 1 | Idioma e acessibilidade | 408.65 | 65.5 | 224.96 | 159.46 |
| `aj06.more.list.language.body` | 1 | Português (Brasil) · texto maior | 426.28 | 65.5 | 239.15 | 173.65 |

Seção `aj06.help` — retângulo absoluto no canvas 390×2400: **x=20, y=1889.34, w=350, h=219.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 46 | `aj06.help` | box | 0 | 0 | 350 | 219.4 | `margin-top: 34px; display: flex; flex-direction: column; gap: 12px` |  |
| 47 | `aj06.help.title` | text | 0 | 0 | 350 | 26.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/normal peso 800 ls -0.5px #1A1714 |
| 48 | `aj06.help.list` | box | 0 | 38.39 | 350 | 181 | `padding: 4px 14px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column` |  |
| 49 | `aj06.help.list.center` | box | 15.5 | 43.89 | 319 | 57 | `min-height: 56px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 50 | `aj06.help.list.center.icon` | icon | 15.5 | 61.89 | 20 | 20 | `—` |  |
| 51 | `aj06.help.list.center.label` | text | 47.5 | 62.89 | 257 | 18 | `flex-grow: 1; font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 52 | `aj06.help.list.center.chevron` | icon | 316.5 | 62.89 | 18 | 18 | `—` |  |
| 53 | `aj06.help.list.contact` | box | 15.5 | 100.89 | 319 | 57 | `min-height: 56px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #EAE1D0` |  |
| 54 | `aj06.help.list.contact.icon` | icon | 15.5 | 118.89 | 20 | 20 | `—` |  |
| 55 | `aj06.help.list.contact.label` | text | 47.5 | 119.89 | 257 | 18 | `flex-grow: 1; font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 56 | `aj06.help.list.contact.chevron` | icon | 316.5 | 119.89 | 18 | 18 | `—` |  |
| 57 | `aj06.help.list.terms` | box | 15.5 | 157.89 | 319 | 56 | `min-height: 56px; display: flex; align-items: center; gap: 12px` |  |
| 58 | `aj06.help.list.terms.icon` | icon | 15.5 | 175.9 | 20 | 20 | `—` |  |
| 59 | `aj06.help.list.terms.label` | text | 47.5 | 176.9 | 257 | 18 | `flex-grow: 1; font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 60 | `aj06.help.list.terms.chevron` | icon | 316.5 | 176.9 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj06.help.title` | 1 | Ajuda | 20.46 | 0 | 60.2 | 60.2 |
| `aj06.help.list.center.label` | 1 | Central de ajuda | 77.14 | 47.5 | 160.78 | 113.28 |
| `aj06.help.list.contact.label` | 1 | Fale com a gente | 134.14 | 47.5 | 164.43 | 116.93 |
| `aj06.help.list.terms.label` | 1 | Termos e privacidade | 191.15 | 47.5 | 194.5 | 147 |

Seção `aj06.footer` — retângulo absoluto no canvas 390×2400: **x=20, y=2138.74, w=350, h=122.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 61 | `aj06.footer` | box | 0 | 0 | 350 | 122.4 | `margin-top: 30px; display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 62 | `aj06.footer.signOut` | box+text | 0 | 0 | 350 | 52 | `width: 100%; height: 52px; display: flex; align-items: center; justify-content: center; gap: 8px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 63 | `aj06.footer.signOut.icon` ±1 | icon | 116.47 | 17 | 18 | 18 | `—` |  |
| 64 | `aj06.footer.delete` ±1 | text | 120.59 | 58 | 108.83 | 44 | `height: 44px; padding: 0 12px; background: transparent; border: none; font-size: 14px; font-weight: 800; color: #A3301A` | Figtree 14/normal peso 800 ls normal #A3301A |
| 65 | `aj06.footer.version` ±1 | text | 83.26 | 108 | 183.48 | 14.4 | `display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 600; color: #6F665B` | Figtree 12/normal peso 600 ls normal #6F665B |
| 66 | `aj06.footer.version.icon` ±1 | icon | 83.26 | 109.2 | 12 | 12 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `aj06.footer.signOut` | 1 | Sair da conta | 31.25 | 142.47 | 233.53 | 91.06 |
| `aj06.footer.delete` | 1 | Excluir conta | 84.9 | 132.59 | 217.41 | 84.82 |
| `aj06.footer.version` | 1 | Versão 3.0 · feito para quem lê | 119.4 | 101.26 | 266.74 | 165.48 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Mais ajustes" e "Ajuda" Bricolage 22/800, 34 entre as seções; os cartões: padding 4/14, raio 24, `#FFFAF1`, borda 1,5, sem sombra.
2. As linhas dos Ajustes: `min-height 66` (56 na Ajuda), gap 12, o fio de 1 `#EAE1D0` entre elas; o círculo 38 colorido com o ícone 18 (na Ajuda, o ícone 20 solto), o título 15/700 e a descrição 12,5/500 `#5B544B` (`min-width: 0`), e a seta 18 (traço 2,2).
3. Rodapé 30 abaixo (coluna centrada, gap 6): "Sair da conta" (52, largura toda, `#FFFAF1`, borda 1,5, 15/800, a porta 18); "Excluir conta" (44, sem fundo, 14/800 `#A3301A`); a versão 12/600 `#6F665B` com a estrelinha 12.
4. Por baixo, o degradê e a navegação da 05 (a tabela "Diferenças": os dois 110 acima, porque a página tem 2400 e não 2510).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A navegação aparece nos Ajustes com o Perfil marcado: a 06 é rota filha da aba Perfil (no ramo do shell), não uma tela por cima de tudo como a Conta, a Privacidade e as Notificações.
- O fim da página precisa do espaço da navegação e do degradê (o recuo do shell, `shell_insets.dart`).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_006_ajustes_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_006_ajustes_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 05 (seções reutilizadas: bottomFade, nav)

Estas seções são as mesmas widgets da 05 (fases L05_1_capa, L05_2_lendo_e_ano, L05_3_favoritos_e_conquistas, L05_4_atividade); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `aj06.bottomFade` (seção inteira) | muda de lugar: x 0, y -110 (abaixo, os ids dela já descontado esse deslocamento) |
| `aj06.bottomFade` | position: {"top": "2360px", "right": "0px", "bottom": "0px", "left": "0px"} → {"top": "2250px", "right": "0px", "bottom": "0px", "left": "0px"} |
| `aj06.nav` (seção inteira) | muda de lugar: x 0, y -110 (abaixo, os ids dela já descontado esse deslocamento) |
| `aj06.nav` | position: {"top": "2410px", "right": "16px", "bottom": "30px", "left": "16px"} → {"top": "2300px", "right": "16px", "bottom": "30px", "left": "16px"} |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `aj06.more` |  | Mais ajustes |  |
| `aj06.more.list.notifications.icon` |  |  | aria-hidden=true |
| `aj06.more.list.notifications.chevron` |  |  | aria-hidden=true |
| `aj06.more.list.privacy.icon` |  |  | aria-hidden=true |
| `aj06.more.list.privacy.chevron` |  |  | aria-hidden=true |
| `aj06.more.list.library.icon` |  |  | aria-hidden=true |
| `aj06.more.list.library.chevron` |  |  | aria-hidden=true |
| `aj06.more.list.scanner.icon` |  |  | aria-hidden=true |
| `aj06.more.list.scanner.chevron` |  |  | aria-hidden=true |
| `aj06.more.list.appearance.icon` |  |  | aria-hidden=true |
| `aj06.more.list.appearance.chevron` |  |  | aria-hidden=true |
| `aj06.more.list.language.icon` |  |  | aria-hidden=true |
| `aj06.more.list.language.chevron` |  |  | aria-hidden=true |
| `aj06.help` |  | Ajuda |  |
| `aj06.help.list.center.icon` |  |  | aria-hidden=true |
| `aj06.help.list.center.chevron` |  |  | aria-hidden=true |
| `aj06.help.list.contact.icon` |  |  | aria-hidden=true |
| `aj06.help.list.contact.chevron` |  |  | aria-hidden=true |
| `aj06.help.list.terms.icon` |  |  | aria-hidden=true |
| `aj06.help.list.terms.chevron` |  |  | aria-hidden=true |
| `aj06.footer.signOut.icon` |  |  | aria-hidden=true |
| `aj06.footer.version.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `aj06.more.list` | NeoBox |  |
| `aj06.more.list.notifications` | NeoBox |  |
| `aj06.more.list.notifications.icon` | CircleIconButton / NeoBox circular |  |
| `aj06.more.list.notifications.icon.art` | AppSvg(AppIconsPerfil.bellLista, size: 18) |  |
| `aj06.more.list.notifications.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.more.list.privacy` | NeoBox |  |
| `aj06.more.list.privacy.icon` | CircleIconButton / NeoBox circular |  |
| `aj06.more.list.privacy.icon.art` | AppSvg(AppIconsPerfil.lock, size: 18) |  |
| `aj06.more.list.privacy.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.more.list.library` | NeoBox |  |
| `aj06.more.list.library.icon` | CircleIconButton / NeoBox circular |  |
| `aj06.more.list.library.icon.art` | AppSvg(AppIconsPerfil.folderDownload, size: 18) |  |
| `aj06.more.list.library.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.more.list.scanner` | NeoBox |  |
| `aj06.more.list.scanner.icon` | CircleIconButton / NeoBox circular |  |
| `aj06.more.list.scanner.icon.art` | AppSvg(AppIconsPerfil.scanBarcodeLista, size: 18) |  |
| `aj06.more.list.scanner.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.more.list.appearance` | NeoBox |  |
| `aj06.more.list.appearance.icon` | CircleIconButton / NeoBox circular |  |
| `aj06.more.list.appearance.icon.art` | AppSvg(AppIconsPerfil.contrast, size: 18) |  |
| `aj06.more.list.appearance.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.more.list.language.icon` | CircleIconButton / NeoBox circular |  |
| `aj06.more.list.language.icon.art` | AppSvg(AppIconsPerfil.globe, size: 18) |  |
| `aj06.more.list.language.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.help.list` | NeoBox |  |
| `aj06.help.list.center` | NeoBox |  |
| `aj06.help.list.center.icon` | AppSvg(AppIconsPerfil.helpLista, size: 20) |  |
| `aj06.help.list.center.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.help.list.contact` | NeoBox |  |
| `aj06.help.list.contact.icon` | AppSvg(AppIconsPerfil.chatBubble, size: 20) |  |
| `aj06.help.list.contact.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.help.list.terms.icon` | AppSvg(AppIconsPerfil.document, size: 20) |  |
| `aj06.help.list.terms.chevron` | AppSvg(AppIconsPerfil.chevronRightLista, size: 18) |  |
| `aj06.footer.signOut` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `aj06.footer.signOut.icon` | AppSvg(AppIconsPerfil.signOut, size: 18) |  |
| `aj06.footer.version.icon` | AppSvg(AppIconsPerfil.sparkleSolidCinza, size: 12) |  |

## Interações

- Notificações → Lembretes e avisos (30b). Privacidade → a 56.
- Biblioteca e dados → as seções de Sincronização e Seus dados da Conta (58), se a T17 decidir; senão, sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b).
- Scanner → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b).
- Aparência do app e Idioma e acessibilidade → Aparência e acessibilidade: tela que falta (D-268), da própria T17 — perguntar, buscar 3–5 referências, desenhar a prancha em `docs/design/novas/` e esperar o "sim" antes do Flutter (ROTEIRO §5). Se é uma tela para as duas linhas ou duas, entra na mesma pergunta.
- Central de ajuda, Fale com a gente e Termos e privacidade → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b) (ou o link externo, se a T17 decidir).
- Sair da conta → sai (a `signOut` que já existe, com a escolha de apagar o que está no aparelho, D-65); a confirmação não tem prancha nesta tela.
- Excluir conta → a Excluir conta (59).

## Dados

- As descrições das linhas acompanham o estado ("Perfil fechado · 3 pedidos", "Automático · cor de destaque lavanda", "Português (Brasil) · texto maior"): cada uma vem do ajuste de verdade; os pedidos, do social.
- A versão é a do app (a do build; ler a versão em tempo de execução pede pacote novo, pergunta da T17), com o texto "feito para quem lê".
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L06.1** Mais ajustes (as 6 linhas)
- **L06.2** Ajuda
- **L06.3** Rodapé: sair, excluir e a versão
- **L06.4** Navegação e degradê presos ao fundo
- **L06.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('aj06.more', 'aj06.help', 'aj06.footer'), todos os ids de `kRef06.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/006_ajustes_390x2400@3x.png` no recorte da fase (y 1396.93–2269.14) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef06w360` e `kRef06w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L06.1 Mais ajustes (as 6 linhas)
- [ ] L06.2 Ajuda
- [ ] L06.3 Rodapé: sair, excluir e a versão
- [ ] L06.4 Navegação e degradê presos ao fundo
- [ ] L06.5 Verificação + relatório
- [ ] Geometria 66/66 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
