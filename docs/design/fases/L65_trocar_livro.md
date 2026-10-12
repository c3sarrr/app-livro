# FASE L65 — Editar perfil, trocar um dos 4 — o escurecido e a folha (o livro de hoje, a busca, as 4 opções com estrelas e o botão)

> Tela 65 · prancha `065_editar_perfil_trocar` (65 · Editar perfil — trocar um dos 4, canvas 390×844) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L65_trocar_livro@3x.png` · `docs/design/medicao/projeto/png/redline/L65_trocar_livro_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/065_editar_perfil_trocar_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_065_editar_perfil_trocar.json` · `test/reference/projeto/reference_layout_065_editar_perfil_trocar.dart` (`kRef65`).
> Arquivos sugeridos: `lib/features/profile/presentation/edit/swap_favorite_sheet.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Editar perfil, trocar um dos 4 (65): a 64 por baixo do escurecido e a folha "Trocar o 3º livro" — o livro de hoje (Iracema, que volta para a estante), a busca nos 52 lidos, as melhores notas (4 opções com estrelas, a já escolhida apagada) e "Pôr Vidas Secas no lugar".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`.

```html
<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(26,23,20,0.5);"></div>

<section role="dialog" aria-label="Trocar o 3º livro" style="position: absolute; left: 10px; right: 10px; bottom: 10px; top: 150px; box-sizing: border-box; padding: 10px 16px 18px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">
  <span aria-hidden="true" style="align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD;"></span>
  <div style="margin-top: 12px; display: flex; align-items: center; gap: 12px;">
    <span style="position: relative;"><span aria-hidden="true" style="position: relative; display: block; width: 40px; height: 60px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><span style="position: absolute; left: 6px; right: -3px; top: 9px; height: 16px; border-radius: 8px 0 0 8px; background: #1A1714;"></span><span style="position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 8.1px; line-height: 0.92; color: #1A1714;">Iracema</span></span><span aria-hidden="true" style="position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">3</span></span>
    <span style="min-width: 0; display: flex; flex-direction: column; gap: 2px;">
      <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1.05; letter-spacing: -0.5px;">Trocar <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 25px;">o 3º livro</span></span>
      <span style="font-size: 12.5px; font-weight: 600; color: #5B544B;">Hoje é Iracema · ela volta para a estante</span>
    </span>
  </div>
  <label style="margin-top: 14px; height: 48px; padding: 0 14px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#5B544B" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="6.5"></circle><path d="m20 20-4.2-4.2"></path></svg><span style="font-size: 14px; font-weight: 600; color: #8A8073;">Buscar nos seus 52 lidos</span></label>
  <span style="margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1px; color: #6F665B;">SUAS MELHORES NOTAS</span>
  <div role="radiogroup" aria-label="Escolher livro" style="margin-top: 8px; display: flex; flex-direction: column; gap: 8px;"><div role="radio" aria-checked="true" style="padding: 8px 12px 8px 8px; border-radius: 18px; background: {{brand}}; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 12px;"><span style=""><span aria-hidden="true" style="position: relative; display: block; width: 34px; height: 51px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #F7D9A0; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><span style="position: absolute; left: 8px; top: 7px; width: 15px; height: 15px; border-radius: 50%; background: #FF552E; box-shadow: 0 0 0 2px rgba(26,23,20,0.12);"></span><span style="position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 6.9px; line-height: 0.92; color: #1A1714;">Vidas<br>Secas</span></span></span><span style="min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 3px;"><span style="font-size: 14.5px; font-weight: 800; line-height: 1.2;">Vidas Secas</span><span style="font-size: 12px; font-weight: 600; color: #5B544B;">Graciliano Ramos</span><span aria-label="5 de 5 estrelas" style="display: flex; gap: 1px;"><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg></span></span><span style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></div><div role="radio" aria-checked="false" style="padding: 8px 12px 8px 8px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 12px;"><span style=""><span aria-hidden="true" style="position: relative; display: block; width: 34px; height: 51px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><svg width="13" height="13" viewBox="0 0 24 24" style="position: absolute; left: 9px; top: 5px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg><span style="position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 6.1px; line-height: 0.92; color: #1A1714;">A Hora<br>da Estrela</span></span></span><span style="min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 3px;"><span style="font-size: 14.5px; font-weight: 800; line-height: 1.2;">A Hora da Estrela</span><span style="font-size: 12px; font-weight: 600; color: #5B544B;">Clarice Lispector</span><span aria-label="5 de 5 estrelas" style="display: flex; gap: 1px;"><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg></span></span><span style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></span></div><div role="radio" aria-checked="false" aria-disabled="true" style="padding: 8px 12px 8px 8px; border-radius: 18px; background: #F7F0E3; border: 1.5px dashed #CFC3AE; box-sizing: border-box; display: flex; align-items: center; gap: 12px;"><span style=" opacity: 0.6;"><span aria-hidden="true" style="position: relative; display: block; width: 34px; height: 51px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><span style="position: absolute; left: 9px; top: 7px; width: 13px; height: 19px; border-radius: 50%; background: #1A1714;"></span><span style="position: absolute; left: 16px; top: 7px; width: 1.5px; height: 19px; background: #B6ACE4;"></span><span style="position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 6.1px; line-height: 0.92; color: #1A1714;">A Meta-<br>morfose</span></span></span><span style="min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 3px; opacity: 0.6;"><span style="font-size: 14.5px; font-weight: 800; line-height: 1.2;">A Metamorfose</span><span style="font-size: 12px; font-weight: 600; color: #5B544B;">Franz Kafka</span><span aria-label="5 de 5 estrelas" style="display: flex; gap: 1px;"><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg></span></span><span style="height: 24px; padding: 0 8px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #CFC3AE; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800; color: #6F665B; white-space: nowrap;">já é o nº 4</span></div><div role="radio" aria-checked="false" style="padding: 8px 12px 8px 8px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 12px;"><span style=""><span aria-hidden="true" style="position: relative; display: block; width: 34px; height: 51px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #FFFAF1; overflow: hidden; box-sizing: border-box;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16);"></span><span style="position: absolute; left: 4px; right: 4px; top: 5px; display: flex; flex-direction: column; gap: 2px;"><span style="height: 2px; border-radius: 4px; background: #058CD7;"></span><span style="height: 2px; width: 70%; border-radius: 4px; background: #058CD7;"></span><span style="height: 2px; width: 40%; border-radius: 4px; background: #058CD7;"></span></span><span style="position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 5.5px; line-height: 0.92; color: #1A1714;">Memórias de<br>um Sargento</span></span></span><span style="min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 3px;"><span style="font-size: 14.5px; font-weight: 800; line-height: 1.2;">Memórias de um Sargento de Milícias</span><span style="font-size: 12px; font-weight: 600; color: #5B544B;">Manuel Antônio de Almeida</span><span aria-label="4,5 de 5 estrelas" style="display: flex; gap: 1px;"><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg><svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><defs><clipPath id="hs1"><rect x="0" y="0" width="12" height="24"></rect></clipPath></defs><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#FFFAF1"></path><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="#F2A815" clip-path="url(#hs1)"></path><path d="m12 2.8 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17.2l-5.6 3 1.1-6.3L2.9 9.5l6.3-.9z" fill="none" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path></svg></span></span><span style="width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></span></div></div>
  <span style="flex-grow: 1;"></span>
  <button style="margin-top: 14px; height: 54px; border-radius: 999px; background: #1A1714; border: none; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15.5px; font-weight: 800;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#FED170" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 7h3.5c4.5 0 4.5 10 9 10H20"></path><path d="M4 17h3.5c1.6 0 2.6-1.3 3.4-3M20 7h-3.5c-1.6 0-2.6 1.3-3.4 3"></path><path d="m17.5 4.5 2.5 2.5-2.5 2.5M17.5 14.5l2.5 2.5-2.5 2.5"></path></svg><span style="color: #F7F0E3;">Pôr Vidas Secas no lugar</span></button>
</section>
```

## Especificação pixel a pixel

Seção `p65.scrim` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `p65.scrim` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; background: rgba(26,23,20,0.5)` |  |

Seção `p65.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=150, w=370, h=684**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `p65.sheet` | box | 0 | 0 | 370 | 684 | `position: absolute; left: 10px; right: 10px; bottom: 10px; top: 150px; box-sizing: border-box; padding: 10px 16px 18px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 3 | `p65.sheet.handle` | box | 165 | 11.5 | 40 | 5 | `align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD` |  |
| 4 | `p65.sheet.head` | box | 17.5 | 28.5 | 335 | 60 | `margin-top: 12px; display: flex; align-items: center; gap: 12px` |  |
| 5 | `p65.sheet.head.current` | box | 17.5 | 28.5 | 40 | 60 | `position: relative` |  |
| 6 | `p65.sheet.head.current.cover` | box | 17.5 | 28.5 | 40 | 60 | `position: relative; display: block; width: 40px; height: 60px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box` |  |
| 7 | `p65.sheet.head.current.cover.spine` | box | 19 | 30 | 4 | 57 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 8 | `p65.sheet.head.current.cover.band` | box | 25 | 39 | 34 | 16 | `position: absolute; left: 6px; right: -3px; top: 9px; height: 16px; border-radius: 8px 0 0 8px; background: #1A1714` |  |
| 9 | `p65.sheet.head.current.cover.title` | text | 26 | 73.55 | 27 | 7.45 | `position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 8.1px; line-height: 0.92; color: #1A1714` | Instrument Serif 8.1/7.452px peso 400 ls normal #1A1714 |
| 10 | `p65.sheet.head.current.rank` | box+text | 10.5 | 21.5 | 22 | 22 | `position: absolute; left: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714; color: #FFFAF1; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800 ls normal #FFFAF1 |
| 11 | `p65.sheet.head.textBlock` ±1 | box | 69.5 | 36.87 | 226.03 | 43.26 | `min-width: 0; display: flex; flex-direction: column; gap: 2px` |  |
| 12 | `p65.sheet.head.title` ±1 | text | 69.5 | 36.87 | 226.03 | 26.25 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1.05; letter-spacing: -0.5px` | Bricolage (opsz 21) 21/22.05px peso 800 ls -0.5px #1A1714 |
| 13 | `p65.sheet.head.title.serif` ±1 | inline | 138.02 | 33.74 | 74.95 | 32.5 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 25px` | Instrument Serif itálico 25/26.25px peso 400 ls -0.5px #1A1714 |
| 14 | `p65.sheet.head.body` ±1 | text | 69.5 | 65.12 | 226.03 | 15.01 | `font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 15 | `p65.sheet.search` | box | 17.5 | 102.5 | 335 | 48 | `margin-top: 14px; height: 48px; padding: 0 14px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px` |  |
| 16 | `p65.sheet.search.icon` | icon | 33 | 117.5 | 18 | 18 | `—` |  |
| 17 | `p65.sheet.search.placeholder` ±1 | text | 59 | 118.1 | 153.55 | 16.8 | `font-size: 14px; font-weight: 600; color: #8A8073` | Figtree 14/normal peso 600 ls normal #8A8073 |
| 18 | `p65.sheet.optionsLabel` | text | 17.5 | 164.5 | 335 | 13.2 | `margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1px; color: #6F665B` | Figtree 11/normal peso 800 ls 1px #6F665B |
| 19 | `p65.sheet.options` | box | 17.5 | 185.7 | 335 | 320.2 | `margin-top: 8px; display: flex; flex-direction: column; gap: 8px` |  |
| 20 | `p65.sheet.options.option1` | box | 17.5 | 185.7 | 335 | 70 | `padding: 8px 12px 8px 8px; border-radius: 18px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 12px` |  |
| 21 | `p65.sheet.options.option1.thumb` | box | 27 | 195.2 | 34 | 51 | `—` |  |
| 22 | `p65.sheet.options.option1.thumb.cover` | box | 27 | 195.2 | 34 | 51 | `position: relative; display: block; width: 34px; height: 51px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #F7D9A0; overflow: hidden; box-sizing: border-box` |  |
| 23 | `p65.sheet.options.option1.thumb.cover.spine` | box | 28.5 | 196.7 | 4 | 48 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 24 | `p65.sheet.options.option1.thumb.cover.square` | box | 36.5 | 203.7 | 15 | 15 | `position: absolute; left: 8px; top: 7px; width: 15px; height: 15px; border-radius: 50%; background: #FF552E; box-shadow: 0 0 0 2px rgba(26,23,20,0.12)` |  |
| 25 | `p65.sheet.options.option1.thumb.cover.title` | text | 35.5 | 226 | 21 | 12.7 | `position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 6.9px; line-height: 0.92; color: #1A1714` | Instrument Serif 6.9/6.348px peso 400 ls normal #1A1714 |
| 26 | `p65.sheet.options.option1.textBlock` | box | 73 | 195.8 | 226 | 49.8 | `min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 3px` |  |
| 27 | `p65.sheet.options.option1.title` | text | 73 | 195.8 | 226 | 17.4 | `font-size: 14.5px; font-weight: 800; line-height: 1.2` | Figtree 14.5/17.4px peso 800 ls normal #1A1714 |
| 28 | `p65.sheet.options.option1.author` | text | 73 | 216.2 | 226 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B` | Figtree 12/normal peso 600 ls normal #5B544B |
| 29 | `p65.sheet.options.option1.rating` | box | 73 | 233.6 | 226 | 12 | `display: flex; gap: 1px` |  |
| 30 | `p65.sheet.options.option1.rating.star1` | icon | 73 | 233.6 | 12 | 12 | `—` |  |
| 31 | `p65.sheet.options.option1.rating.star2` | icon | 86 | 233.6 | 12 | 12 | `—` |  |
| 32 | `p65.sheet.options.option1.rating.star3` | icon | 99 | 233.6 | 12 | 12 | `—` |  |
| 33 | `p65.sheet.options.option1.rating.star4` | icon | 112 | 233.6 | 12 | 12 | `—` |  |
| 34 | `p65.sheet.options.option1.rating.star5` | icon | 125 | 233.6 | 12 | 12 | `—` |  |
| 35 | `p65.sheet.options.option1.radio` | box | 311 | 206.7 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 36 | `p65.sheet.options.option1.radio.icon` | icon | 317.5 | 213.2 | 15 | 15 | `—` |  |
| 37 | `p65.sheet.options.option2` | box | 17.5 | 263.7 | 335 | 70 | `padding: 8px 12px 8px 8px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 12px` |  |
| 38 | `p65.sheet.options.option2.thumb` | box | 27 | 273.2 | 34 | 51 | `—` |  |
| 39 | `p65.sheet.options.option2.thumb.cover` | box | 27 | 273.2 | 34 | 51 | `position: relative; display: block; width: 34px; height: 51px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box` |  |
| 40 | `p65.sheet.options.option2.thumb.cover.spine` | box | 28.5 | 274.7 | 4 | 48 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 41 | `p65.sheet.options.option2.thumb.cover.star` | icon | 37.5 | 279.7 | 13 | 13 | `position: absolute; left: 9px; top: 5px` |  |
| 42 | `p65.sheet.options.option2.thumb.cover.title` | text | 35.5 | 305.48 | 21 | 11.22 | `position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 6.1px; line-height: 0.92; color: #1A1714` | Instrument Serif 6.1/5.612px peso 400 ls normal #1A1714 |
| 43 | `p65.sheet.options.option2.textBlock` | box | 73 | 273.8 | 226 | 49.8 | `min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 3px` |  |
| 44 | `p65.sheet.options.option2.title` | text | 73 | 273.8 | 226 | 17.4 | `font-size: 14.5px; font-weight: 800; line-height: 1.2` | Figtree 14.5/17.4px peso 800 ls normal #1A1714 |
| 45 | `p65.sheet.options.option2.author` | text | 73 | 294.2 | 226 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B` | Figtree 12/normal peso 600 ls normal #5B544B |
| 46 | `p65.sheet.options.option2.rating` | box | 73 | 311.6 | 226 | 12 | `display: flex; gap: 1px` |  |
| 47 | `p65.sheet.options.option2.rating.star1` | icon | 73 | 311.6 | 12 | 12 | `—` |  |
| 48 | `p65.sheet.options.option2.rating.star2` | icon | 86 | 311.6 | 12 | 12 | `—` |  |
| 49 | `p65.sheet.options.option2.rating.star3` | icon | 99 | 311.6 | 12 | 12 | `—` |  |
| 50 | `p65.sheet.options.option2.rating.star4` | icon | 112 | 311.6 | 12 | 12 | `—` |  |
| 51 | `p65.sheet.options.option2.rating.star5` | icon | 125 | 311.6 | 12 | 12 | `—` |  |
| 52 | `p65.sheet.options.option2.radio` | box | 311 | 284.7 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 53 | `p65.sheet.options.option3` | box | 17.5 | 341.7 | 335 | 70 | `padding: 8px 12px 8px 8px; border-radius: 18px; background: #F7F0E3; border: 1.5px dashed #CFC3AE; box-sizing: border-box; display: flex; align-items: center; gap: 12px` |  |
| 54 | `p65.sheet.options.option3.thumb` | box | 27 | 351.2 | 34 | 51 | `opacity: 0.6` |  |
| 55 | `p65.sheet.options.option3.thumb.cover` | box | 27 | 351.2 | 34 | 51 | `position: relative; display: block; width: 34px; height: 51px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box` |  |
| 56 | `p65.sheet.options.option3.thumb.cover.spine` | box | 28.5 | 352.7 | 4 | 48 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 57 | `p65.sheet.options.option3.thumb.cover.oval` | box | 37.5 | 359.7 | 13 | 19 | `position: absolute; left: 9px; top: 7px; width: 13px; height: 19px; border-radius: 50%; background: #1A1714` |  |
| 58 | `p65.sheet.options.option3.thumb.cover.seam` | box | 44.5 | 359.7 | 1.5 | 19 | `position: absolute; left: 16px; top: 7px; width: 1.5px; height: 19px; background: #B6ACE4` |  |
| 59 | `p65.sheet.options.option3.thumb.cover.title` | text | 35.5 | 383.48 | 21 | 11.22 | `position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 6.1px; line-height: 0.92; color: #1A1714` | Instrument Serif 6.1/5.612px peso 400 ls normal #1A1714 |
| 60 | `p65.sheet.options.option3.textBlock` ±1 | box | 73 | 351.8 | 186.22 | 49.8 | `min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 3px; opacity: 0.6` |  |
| 61 | `p65.sheet.options.option3.title` ±1 | text | 73 | 351.8 | 186.22 | 17.4 | `font-size: 14.5px; font-weight: 800; line-height: 1.2` | Figtree 14.5/17.4px peso 800 ls normal #1A1714 |
| 62 | `p65.sheet.options.option3.author` ±1 | text | 73 | 372.2 | 186.22 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B` | Figtree 12/normal peso 600 ls normal #5B544B |
| 63 | `p65.sheet.options.option3.rating` ±1 | box | 73 | 389.6 | 186.22 | 12 | `display: flex; gap: 1px` |  |
| 64 | `p65.sheet.options.option3.rating.star1` | icon | 73 | 389.6 | 12 | 12 | `—` |  |
| 65 | `p65.sheet.options.option3.rating.star2` | icon | 86 | 389.6 | 12 | 12 | `—` |  |
| 66 | `p65.sheet.options.option3.rating.star3` | icon | 99 | 389.6 | 12 | 12 | `—` |  |
| 67 | `p65.sheet.options.option3.rating.star4` | icon | 112 | 389.6 | 12 | 12 | `—` |  |
| 68 | `p65.sheet.options.option3.rating.star5` | icon | 125 | 389.6 | 12 | 12 | `—` |  |
| 69 | `p65.sheet.options.option3.tag` ±1 | box+text | 271.22 | 364.7 | 67.78 | 24 | `height: 24px; padding: 0 8px; flex-shrink: 0; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #CFC3AE; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800; color: #6F665B; white-space: nowrap` | Figtree 11/normal peso 800 ls normal #6F665B |
| 70 | `p65.sheet.options.option4` | box | 17.5 | 419.7 | 335 | 86.2 | `padding: 8px 12px 8px 8px; border-radius: 18px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 12px` |  |
| 71 | `p65.sheet.options.option4.thumb` | box | 27 | 437.3 | 34 | 51 | `—` |  |
| 72 | `p65.sheet.options.option4.thumb.cover` | box | 27 | 437.3 | 34 | 51 | `position: relative; display: block; width: 34px; height: 51px; flex-shrink: 0; border-radius: 3px 5px 5px 3px; border: 1.5px solid #1A1714; background: #FFFAF1; overflow: hidden; box-sizing: border-box` |  |
| 73 | `p65.sheet.options.option4.thumb.cover.spine` | box | 28.5 | 438.8 | 4 | 48 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.16)` |  |
| 74 | `p65.sheet.options.option4.thumb.cover.lines` | box | 32.5 | 443.8 | 23 | 10 | `position: absolute; left: 4px; right: 4px; top: 5px; display: flex; flex-direction: column; gap: 2px` |  |
| 75 | `p65.sheet.options.option4.thumb.cover.lines.line1` | box | 32.5 | 443.8 | 23 | 2 | `height: 2px; border-radius: 4px; background: #058CD7` |  |
| 76 | `p65.sheet.options.option4.thumb.cover.lines.line2` | box | 32.5 | 447.8 | 16.1 | 2 | `height: 2px; width: 70%; border-radius: 4px; background: #058CD7` |  |
| 77 | `p65.sheet.options.option4.thumb.cover.lines.line3` | box | 32.5 | 451.8 | 9.2 | 2 | `height: 2px; width: 40%; border-radius: 4px; background: #058CD7` |  |
| 78 | `p65.sheet.options.option4.thumb.cover.title` | text | 35.5 | 460.56 | 21 | 20.24 | `position: absolute; left: 7px; right: 3px; bottom: 6px; font-family: 'Instrument Serif', Georgia, serif; font-weight: 400; font-size: 5.5px; line-height: 0.92; color: #1A1714` | Instrument Serif 5.5/5.06px peso 400 ls normal #1A1714 |
| 79 | `p65.sheet.options.option4.textBlock` | box | 73 | 429.2 | 226 | 67.2 | `min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 3px` |  |
| 80 | `p65.sheet.options.option4.title` | text | 73 | 429.2 | 226 | 34.8 | `font-size: 14.5px; font-weight: 800; line-height: 1.2` | Figtree 14.5/17.4px peso 800 ls normal #1A1714 |
| 81 | `p65.sheet.options.option4.author` | text | 73 | 467 | 226 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B` | Figtree 12/normal peso 600 ls normal #5B544B |
| 82 | `p65.sheet.options.option4.rating` | box | 73 | 484.4 | 226 | 12 | `display: flex; gap: 1px` |  |
| 83 | `p65.sheet.options.option4.rating.star1` | icon | 73 | 484.4 | 12 | 12 | `—` |  |
| 84 | `p65.sheet.options.option4.rating.star2` | icon | 86 | 484.4 | 12 | 12 | `—` |  |
| 85 | `p65.sheet.options.option4.rating.star3` | icon | 99 | 484.4 | 12 | 12 | `—` |  |
| 86 | `p65.sheet.options.option4.rating.star4` | icon | 112 | 484.4 | 12 | 12 | `—` |  |
| 87 | `p65.sheet.options.option4.rating.star5` | icon | 125 | 484.4 | 12 | 12 | `—` |  |
| 88 | `p65.sheet.options.option4.radio` | box | 311 | 448.8 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 89 | `p65.sheet.spacer` | box | 17.5 | 505.9 | 335 | 90.6 | `flex-grow: 1` |  |
| 90 | `p65.sheet.confirm` | box | 17.5 | 610.5 | 335 | 54 | `margin-top: 14px; height: 54px; border-radius: 999px; background: #1A1714; border: none; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15.5px; font-weight: 800` |  |
| 91 | `p65.sheet.confirm.icon` ±1 | icon | 83.55 | 628.5 | 18 | 18 | `—` |  |
| 92 | `p65.sheet.confirm.label` ±1 | text | 109.55 | 628.2 | 176.9 | 18.61 | `color: #F7F0E3` | Figtree 15.5/normal peso 800 ls normal #F7F0E3 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p65.sheet.head.current.cover.title` | 1 | Iracema | 80.03 | 26 | 48.23 | 22.23 |
| `p65.sheet.head.current.rank` | 1 | 3 | 36.35 | 18.41 | 24.59 | 6.18 |
| `p65.sheet.head.title` *(composto)* | 1 | Trocar o 3º livro | 58.49 | 69.5 | 212.97 | 143.47 |
| `p65.sheet.head.body` | 1 | Hoje é Iracema · ela volta para a estante | 77 | 69.5 | 295.53 | 226.03 |
| `p65.sheet.search.placeholder` | 1 | Buscar nos seus 52 lidos | 131.4 | 59 | 212.55 | 153.55 |
| `p65.sheet.optionsLabel` | 1 | SUAS MELHORES NOTAS | 174.95 | 17.5 | 167.4 | 149.9 |
| `p65.sheet.options.option1.thumb.cover.title` | 1 | Vidas | 231.51 | 35.5 | 48.06 | 12.56 |
| `p65.sheet.options.option1.thumb.cover.title` | 2 | Secas | 237.86 | 35.5 | 47.98 | 12.48 |
| `p65.sheet.options.option1.title` | 1 | Vidas Secas | 209.57 | 73 | 154.13 | 81.13 |
| `p65.sheet.options.option1.author` | 1 | Graciliano Ramos | 227.6 | 73 | 167.79 | 94.79 |
| `p65.sheet.options.option2.thumb.cover.title` | 1 | A Hora | 310.36 | 35.5 | 49.3 | 13.8 |
| `p65.sheet.options.option2.thumb.cover.title` | 2 | da Estrela | 315.97 | 35.5 | 55.86 | 20.36 |
| `p65.sheet.options.option2.title` | 1 | A Hora da Estrela | 287.57 | 73 | 190.15 | 117.15 |
| `p65.sheet.options.option2.author` | 1 | Clarice Lispector | 305.6 | 73 | 165.41 | 92.41 |
| `p65.sheet.options.option3.thumb.cover.title` | 1 | A Meta- | 388.36 | 35.5 | 52.05 | 16.55 |
| `p65.sheet.options.option3.thumb.cover.title` | 2 | morfose | 393.97 | 35.5 | 52.33 | 16.83 |
| `p65.sheet.options.option3.title` | 1 | A Metamorfose | 365.57 | 73 | 177.41 | 104.41 |
| `p65.sheet.options.option3.author` | 1 | Franz Kafka | 383.6 | 73 | 136.2 | 63.2 |
| `p65.sheet.options.option3.tag` | 1 | já é o nº 4 | 380.55 | 280.42 | 329.8 | 49.38 |
| `p65.sheet.options.option4.thumb.cover.title` | 1 | Memórias | 464.96 | 35.5 | 54.03 | 18.53 |
| `p65.sheet.options.option4.thumb.cover.title` | 2 | de | 470.02 | 35.5 | 39.97 | 4.47 |
| `p65.sheet.options.option4.thumb.cover.title` | 3 | um | 475.08 | 35.5 | 41.87 | 6.37 |
| `p65.sheet.options.option4.thumb.cover.title` | 4 | Sargento | 480.14 | 35.5 | 52 | 16.5 |
| `p65.sheet.options.option4.title` | 1 | Memórias de um Sargento de | 442.97 | 73 | 269.55 | 196.55 |
| `p65.sheet.options.option4.title` | 2 | Milícias | 460.37 | 73 | 123.98 | 50.98 |
| `p65.sheet.options.option4.author` | 1 | Manuel Antônio de Almeida | 478.4 | 73 | 222.97 | 149.97 |
| `p65.sheet.confirm.label` | 1 | Pôr Vidas Secas no lugar | 642.92 | 109.55 | 286.45 | 176.9 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Por baixo, o topo e a prévia da 64 (a tabela "Diferenças"); o escurecido preto a 0,5 por cima de tudo.
2. Folha em `left/right/bottom 10 · top 150`: padding 10/16/18, raio 32/32/44/44, `#FFFAF1`, borda 1,5, sombra 0/4, coluna; a alça 40 × 5 `#D9CFBD`; a cabeça (gap 12, 12 abaixo): a capa 40 × 60 com o número e "Trocar" Bricolage 21/800 + "o 3º livro" Instrument Serif 25, e "Hoje é Iracema · ela volta para a estante" 12,5/600.
3. Busca 14 abaixo: pílula de 48, `#F7F0E3`, borda 1,5, a lupa 18 e "Buscar nos seus 52 lidos".
4. "SUAS MELHORES NOTAS" 11/800 ls 1, 14 abaixo; as opções (`radiogroup`, gap 8): cada uma com padding 8/12/8/8, raio 18, a capinha, o título e o autor, as 5 estrelas e o rádio; a escolhida `{{brand}}` com sombra 2/2; a que já está nos 4 apagada com "já é o nº 4".
5. O botão no fundo (`flex-grow` antes dele): 54, preto, 15,5/800, o ícone de troca `#FED170`.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A folha tem `top 150` fixo e o fundo a 10: a altura depende da tela (684 a 844). Em telas baixas, a lista das opções rola dentro da folha e o botão fica no fundo.
- A capinha da 2ª opção tem o título em duas linhas com `<br>` e a 2ª ("da Estrela") fica num fio de navalha (0,64): a 2ª linha é uma palavra só, que quebra se crescer.
- O escurecido cobre a 64 inteira, inclusive o topo dela: o fechar da 64 não responde com a folha aberta.
- Fio de navalha em `p65.sheet.options.option2.thumb.cover.title` linha 2 «da Estrela»: sobra 0.64 px · sem palavra seguinte (D-275: a linha única quebra se crescer).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_065_editar_perfil_trocar_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_065_editar_perfil_trocar_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `p65.sheet.options.option2.thumb.cover.title` linha 2 «da Estrela»: sobra 0.64 px · sem palavra seguinte (D-275: a linha única quebra se crescer).
- A 360: fio de navalha em `p65.sheet.options.option4.title` linha 1 «Memórias de um Sargento»: sobra 19.67 px · estouro com a próxima palavra 0.55 px.
- A 430: fio de navalha em `p65.sheet.options.option2.thumb.cover.title` linha 2 «da Estrela»: sobra 0.64 px · sem palavra seguinte (D-275: a linha única quebra se crescer).

## Diferenças em relação à prancha 64 (seções reutilizadas: top, preview)

Estas seções são as mesmas widgets da 64 (fases L64_1_previa_e_cor, L64_2_campos, L64_3_quatro_e_salvar); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `p65.top` | position: {"top": "58px", "right": "20px", "bottom": "1294px", "left": "20px"} → {"top": "58px", "right": "20px", "bottom": "738px", "left": "20px"} |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `p65.scrim` |  |  | aria-hidden=true |
| `p65.sheet` | dialog | Trocar o 3º livro |  |
| `p65.sheet.handle` |  |  | aria-hidden=true |
| `p65.sheet.head.current.cover` |  |  | aria-hidden=true |
| `p65.sheet.head.current.rank` |  |  | aria-hidden=true |
| `p65.sheet.search.icon` |  |  | aria-hidden=true |
| `p65.sheet.options` | radiogroup | Escolher livro |  |
| `p65.sheet.options.option1` | radio |  | aria-checked=true |
| `p65.sheet.options.option1.thumb.cover` |  |  | aria-hidden=true |
| `p65.sheet.options.option1.rating` |  | 5 de 5 estrelas |  |
| `p65.sheet.options.option1.rating.star1` |  |  | aria-hidden=true |
| `p65.sheet.options.option1.rating.star2` |  |  | aria-hidden=true |
| `p65.sheet.options.option1.rating.star3` |  |  | aria-hidden=true |
| `p65.sheet.options.option1.rating.star4` |  |  | aria-hidden=true |
| `p65.sheet.options.option1.rating.star5` |  |  | aria-hidden=true |
| `p65.sheet.options.option1.radio.icon` |  |  | aria-hidden=true |
| `p65.sheet.options.option2` | radio |  | aria-checked=false |
| `p65.sheet.options.option2.thumb.cover` |  |  | aria-hidden=true |
| `p65.sheet.options.option2.rating` |  | 5 de 5 estrelas |  |
| `p65.sheet.options.option2.rating.star1` |  |  | aria-hidden=true |
| `p65.sheet.options.option2.rating.star2` |  |  | aria-hidden=true |
| `p65.sheet.options.option2.rating.star3` |  |  | aria-hidden=true |
| `p65.sheet.options.option2.rating.star4` |  |  | aria-hidden=true |
| `p65.sheet.options.option2.rating.star5` |  |  | aria-hidden=true |
| `p65.sheet.options.option3` | radio |  | aria-checked=false, aria-disabled=true |
| `p65.sheet.options.option3.thumb.cover` |  |  | aria-hidden=true |
| `p65.sheet.options.option3.rating` |  | 5 de 5 estrelas |  |
| `p65.sheet.options.option3.rating.star1` |  |  | aria-hidden=true |
| `p65.sheet.options.option3.rating.star2` |  |  | aria-hidden=true |
| `p65.sheet.options.option3.rating.star3` |  |  | aria-hidden=true |
| `p65.sheet.options.option3.rating.star4` |  |  | aria-hidden=true |
| `p65.sheet.options.option3.rating.star5` |  |  | aria-hidden=true |
| `p65.sheet.options.option4` | radio |  | aria-checked=false |
| `p65.sheet.options.option4.thumb.cover` |  |  | aria-hidden=true |
| `p65.sheet.options.option4.rating` |  | 4,5 de 5 estrelas |  |
| `p65.sheet.options.option4.rating.star1` |  |  | aria-hidden=true |
| `p65.sheet.options.option4.rating.star2` |  |  | aria-hidden=true |
| `p65.sheet.options.option4.rating.star3` |  |  | aria-hidden=true |
| `p65.sheet.options.option4.rating.star4` |  |  | aria-hidden=true |
| `p65.sheet.options.option4.rating.star5` |  |  | aria-hidden=true |
| `p65.sheet.confirm.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `p65.scrim` | NeoBox |  |
| `p65.sheet` | NeoBox |  |
| `p65.sheet.handle` | NeoBox |  |
| `p65.sheet.head.current.cover` | NeoBox |  |
| `p65.sheet.head.current.cover.spine` | NeoBox |  |
| `p65.sheet.head.current.cover.band` | NeoBox |  |
| `p65.sheet.head.current.rank` | CircleIconButton / NeoBox circular |  |
| `p65.sheet.head.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `p65.sheet.search` | NeoBox |  |
| `p65.sheet.search.icon` | AppSvg(AppIconsPerfil.searchGrafite, size: 18) |  |
| `p65.sheet.options.option1` | NeoBox |  |
| `p65.sheet.options.option1.thumb.cover` | NeoBox |  |
| `p65.sheet.options.option1.thumb.cover.spine` | NeoBox |  |
| `p65.sheet.options.option1.thumb.cover.square` | CircleIconButton / NeoBox circular |  |
| `p65.sheet.options.option1.rating.star1` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option1.rating.star2` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option1.rating.star3` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option1.rating.star4` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option1.rating.star5` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option1.radio` | CircleIconButton / NeoBox circular |  |
| `p65.sheet.options.option1.radio.icon` | AppSvg(AppIconsPerfil.checkBoldCreme, size: 15) |  |
| `p65.sheet.options.option2` | NeoBox |  |
| `p65.sheet.options.option2.thumb.cover` | NeoBox |  |
| `p65.sheet.options.option2.thumb.cover.spine` | NeoBox |  |
| `p65.sheet.options.option2.thumb.cover.star` | AppSvg(AppIcons.sparkleSolid, size: 13) |  |
| `p65.sheet.options.option2.rating.star1` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option2.rating.star2` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option2.rating.star3` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option2.rating.star4` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option2.rating.star5` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option2.radio` | CircleIconButton / NeoBox circular |  |
| `p65.sheet.options.option3` | NeoBox |  |
| `p65.sheet.options.option3.thumb.cover` | NeoBox |  |
| `p65.sheet.options.option3.thumb.cover.spine` | NeoBox |  |
| `p65.sheet.options.option3.thumb.cover.oval` | CircleIconButton / NeoBox circular |  |
| `p65.sheet.options.option3.thumb.cover.seam` | NeoBox |  |
| `p65.sheet.options.option3.rating.star1` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option3.rating.star2` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option3.rating.star3` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option3.rating.star4` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option3.rating.star5` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option3.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p65.sheet.options.option4` | NeoBox |  |
| `p65.sheet.options.option4.thumb.cover` | NeoBox |  |
| `p65.sheet.options.option4.thumb.cover.spine` | NeoBox |  |
| `p65.sheet.options.option4.thumb.cover.lines.line1` | NeoBox |  |
| `p65.sheet.options.option4.thumb.cover.lines.line2` | NeoBox |  |
| `p65.sheet.options.option4.thumb.cover.lines.line3` | NeoBox |  |
| `p65.sheet.options.option4.rating.star1` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option4.rating.star2` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option4.rating.star3` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option4.rating.star4` | AppSvg(AppIconsPerfil.starSmall, size: 12) |  |
| `p65.sheet.options.option4.rating.star5` | AppSvg(AppIconsPerfil.starHalfSmall, size: 12) | a meia estrela é uma estrela com `<mask>` (metade dourada): conferir no app que o flutter_svg recorta igual (a prova é no Chromium). |
| `p65.sheet.options.option4.radio` | CircleIconButton / NeoBox circular |  |
| `p65.sheet.confirm` | NeoBox |  |
| `p65.sheet.confirm.icon` | AppSvg(AppIconsPerfil.shuffleAmarelo, size: 18) |  |

## Interações

- Opção → escolhe o livro (a já escolhida não marca); o botão diz o nome ("Pôr Vidas Secas no lugar").
- Buscar → filtra os lidos pelo título e pelo autor.
- Botão → troca no rascunho da 64 e fecha a folha; arrastar a alça para baixo ou tocar no escurecido fecha sem trocar.

## Dados

- Os livros que a pessoa terminou (52), as melhores notas primeiro (a nota de cada livro é da T20: até lá, a ordem e as estrelas seguem a D-247, com os lidos mais recentes no lugar — pergunta da T17).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L65.1** Escurecido e moldura da folha
- **L65.2** Cabeça: o livro de hoje
- **L65.3** Busca e opções com estrelas
- **L65.4** Botão de trocar
- **L65.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('p65.scrim', 'p65.sheet'), todos os ids de `kRef65.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/065_editar_perfil_trocar_390x844@3x.png` no recorte da fase (y 142–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef65w360` e `kRef65w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L65.1 Escurecido e moldura da folha
- [ ] L65.2 Cabeça: o livro de hoje
- [ ] L65.3 Busca e opções com estrelas
- [ ] L65.4 Botão de trocar
- [ ] L65.5 Verificação + relatório
- [ ] Geometria 91/91 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
