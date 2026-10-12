# FASE L02 — Biblioteca — a estante (4 prateleiras de 3 livros)

> Tela 02 · prancha `002_biblioteca` (02 · Biblioteca, canvas 390×1640) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L02_4_estante@3x.png` · `docs/design/medicao/projeto/png/redline/L02_4_estante_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/002_biblioteca_390x1640@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_002_biblioteca.json` · `test/reference/projeto/reference_layout_002_biblioteca.dart` (`kRef02`).
> Arquivos sugeridos: `lib/features/library/presentation/sections/shelf_section.dart`, `lib/features/library/presentation/widgets/shelf_book.dart`, `lib/features/library/presentation/covers/library_covers.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A estante: 4 prateleiras de 3 livros (grade de 3 colunas, gap 14, 30 entre as prateleiras), cada uma sobre uma tábua `{{shelf}}`. Embaixo da capa: título, autor e, conforme o livro, a barra de progresso, a etiqueta de status (Novo, Lido, Quero ler) ou as notas. A 4ª prateleira continua por baixo da navegação.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- The shelf: 3 books per row, standing on a plank -->
<div aria-label="Livros" style="margin-top: 22px; display: flex; flex-direction: column; gap: 30px;">

  <!-- Shelf row 1 -->
  <div style="position: relative;">
    <div aria-hidden="true" style="position: absolute; left: -5px; right: -5px; top: 158.5px; height: 11px; border-radius: 6px; background: {{shelf}}; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 3px 0 #1A1714;"></div>
    <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px;">

      <a href="#" aria-label="Dom Casmurro, Machado de Assis, 62% lido" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; height: 160px;">
          <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #552CB7; overflow: hidden; box-sizing: border-box;">
            <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.22);"></div>
            <div style="position: absolute; right: -20px; top: -20px; width: 68px; height: 68px; border-radius: 50%; background: #FED170;"></div>
            <div style="position: absolute; right: 16px; top: 40px; width: 16px; height: 16px; border-radius: 50%; border: 1.5px solid #FED170;"></div>
            <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
              <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 22px; line-height: 0.92; color: #FED170;">Dom<br>Casmurro</div>
              <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #F7F0E3;">MACHADO DE ASSIS</div>
            </div>
          </div>
          <svg width="16" height="30" viewBox="0 0 16 30" aria-hidden="true" style="position: absolute; top: -8px; right: 12px;"><path d="M1.5 0V28L8 22.5 14.5 28V0" fill="#FF552E" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Dom Casmurro</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Machado de Assis</span>
          <div style="margin-top: 5px; display: flex; align-items: center; gap: 6px;">
            <div style="width: 40px; height: 7px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E4DACA 0 2px, #FFFAF1 2px 4px); overflow: hidden;"><div style="width: 62%; height: 100%; background: #FF552E;"></div></div>
            <span style="font-size: 12px; font-weight: 800;">62%</span>
          </div>
        </div>
      </a>

      <a href="#" aria-label="Mrs. Dalloway, Virginia Woolf, 34% lido" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; height: 160px;">
          <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #ABCF82; overflow: hidden; box-sizing: border-box;">
            <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.14);"></div>
            <div style="position: absolute; left: 26px; right: 20px; top: 26px; height: 40px; border-radius: 40px 40px 0 0; background: #1A1714;"></div>
            <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
              <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 22px; line-height: 0.92; color: #1A1714;">Mrs.<br>Dalloway</div>
              <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #1A1714;">VIRGINIA WOOLF</div>
            </div>
          </div>
          <svg width="16" height="30" viewBox="0 0 16 30" aria-hidden="true" style="position: absolute; top: -8px; right: 12px;"><path d="M1.5 0V28L8 22.5 14.5 28V0" fill="#FF552E" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Mrs. Dalloway</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Virginia Woolf</span>
          <div style="margin-top: 5px; display: flex; align-items: center; gap: 6px;">
            <div style="width: 40px; height: 7px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E4DACA 0 2px, #FFFAF1 2px 4px); overflow: hidden;"><div style="width: 34%; height: 100%; background: #FF552E;"></div></div>
            <span style="font-size: 12px; font-weight: 800;">34%</span>
          </div>
        </div>
      </a>

      <a href="#" aria-label="Orgulho e Preconceito, Jane Austen, 81% lido" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; height: 160px;">
          <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box;">
            <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.1);"></div>
            <div style="position: absolute; left: 24px; top: 24px; width: 40px; height: 40px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></div>
            <div style="position: absolute; left: 50px; top: 50px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714;"></div>
            <div style="position: absolute; left: 15px; right: 6px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
              <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.95; color: #1A1714;">Orgulho e<br>Preconceito</div>
              <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #1A1714;">JANE AUSTEN</div>
            </div>
          </div>
          <svg width="16" height="30" viewBox="0 0 16 30" aria-hidden="true" style="position: absolute; top: -8px; right: 12px;"><path d="M1.5 0V28L8 22.5 14.5 28V0" fill="#FF552E" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></path></svg>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Orgulho e Preconceito</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Jane Austen</span>
          <div style="margin-top: 5px; display: flex; align-items: center; gap: 6px;">
            <div style="width: 40px; height: 7px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E4DACA 0 2px, #FFFAF1 2px 4px); overflow: hidden;"><div style="width: 81%; height: 100%; background: #FF552E;"></div></div>
            <span style="font-size: 12px; font-weight: 800;">81%</span>
          </div>
        </div>
      </a>
    </div>
  </div>

  <!-- Shelf row 2 -->
  <div style="position: relative;">
    <div aria-hidden="true" style="position: absolute; left: -5px; right: -5px; top: 158.5px; height: 11px; border-radius: 6px; background: {{shelf}}; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 3px 0 #1A1714;"></div>
    <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px;">

      <a href="#" aria-label="Senhora, José de Alencar, novo" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #F2A815; overflow: hidden; box-sizing: border-box;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.12);"></div>
          <div style="position: absolute; left: 22px; right: 18px; top: 22px; height: 58px; border-radius: 34px 34px 0 0; border: 1.5px solid #1A1714; border-bottom: none; box-sizing: border-box;"></div>
          <div style="position: absolute; left: 38px; right: 34px; top: 42px; height: 38px; border-radius: 20px 20px 0 0; background: #1A1714;"></div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
            <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 24px; line-height: 0.92; color: #1A1714;">Senhora</div>
            <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #1A1714;">JOSÉ DE ALENCAR</div>
          </div>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Senhora</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">José de Alencar</span>
          <span style="margin-top: 5px; align-self: flex-start; font-size: 11.5px; font-weight: 700; padding: 4px 9px; border-radius: 999px; background: #EFE7D7; color: #4A4238;">Novo</span>
        </div>
      </a>

      <a href="#" aria-label="O Alienista, Machado de Assis, PDF, lido" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.12);"></div>
          <div style="position: absolute; left: 30px; top: 22px; width: 46px; height: 46px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></div>
          <div style="position: absolute; left: 40px; top: 32px; width: 26px; height: 26px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></div>
          <div style="position: absolute; left: 48px; top: 40px; width: 10px; height: 10px; border-radius: 50%; background: #1A1714;"></div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 30px; font-family: 'Instrument Serif', Georgia, serif; font-size: 21px; line-height: 0.92; color: #1A1714;">O<br>Alienista</div>
          <span style="position: absolute; left: 12px; bottom: 9px; font-size: 9px; font-weight: 800; letter-spacing: 0.04em; padding: 2px 6px; border-radius: 6px; background: #FFFAF1; border: 1.2px solid #1A1714;">PDF</span>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">O Alienista</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Machado de Assis</span>
          <span style="margin-top: 5px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 4px 9px 4px 7px; border-radius: 999px; background: #E1EDD0; color: #2E5314;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>Lido</span>
        </div>
      </a>

      <a href="#" aria-label="Frankenstein, Mary Shelley, quero ler" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #1A1714; overflow: hidden; box-sizing: border-box;">
          <div style="position: absolute; left: 22px; top: 22px; width: 44px; height: 44px; border-radius: 50%; background: #B6ACE4;"></div>
          <div style="position: absolute; left: 58px; top: 50px; width: 28px; height: 28px; border-radius: 50%; border: 1.5px solid #B6ACE4; box-sizing: border-box;"></div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
            <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 21px; line-height: 0.92; color: #B6ACE4;">Franken-<br>stein</div>
            <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #F7F0E3;">MARY SHELLEY</div>
          </div>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Frankenstein</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Mary Shelley</span>
          <span style="margin-top: 5px; align-self: flex-start; font-size: 11.5px; font-weight: 700; padding: 4px 9px; border-radius: 999px; background: #ECE7FA; color: #3B2D86;">Quero ler</span>
        </div>
      </a>
    </div>
  </div>

  <!-- Shelf row 3 -->
  <div style="position: relative;">
    <div aria-hidden="true" style="position: absolute; left: -5px; right: -5px; top: 158.5px; height: 11px; border-radius: 6px; background: {{shelf}}; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 3px 0 #1A1714;"></div>
    <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px;">

      <a href="#" aria-label="Teoria Literária, apostila em PDF, 18 notas" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FFFDF8; overflow: hidden; box-sizing: border-box; padding: 14px 12px 0 14px; display: flex; flex-direction: column; gap: 5px;">
          <span style="font-size: 6.5px; font-weight: 800; letter-spacing: 0.14em; color: #6F665B;">UNIDADE 2</span>
          <span style="font-size: 13px; font-weight: 800; line-height: 1.05; letter-spacing: -0.2px;">Teoria<br>Literária</span>
          <div style="margin-top: 6px; display: flex; flex-direction: column; gap: 5px;">
            <span style="height: 3px; width: 100%; border-radius: 2px; background: #DCD2C1;"></span>
            <span style="height: 3px; width: 88%; border-radius: 2px; background: #DCD2C1;"></span>
            <span style="height: 7px; width: 94%; margin: -2px 0; border-radius: 2px; background: #FED170;"></span>
            <span style="height: 3px; width: 76%; border-radius: 2px; background: #DCD2C1;"></span>
            <span style="height: 3px; width: 92%; border-radius: 2px; background: #DCD2C1;"></span>
            <span style="height: 3px; width: 60%; border-radius: 2px; background: #DCD2C1;"></span>
          </div>
          <span style="position: absolute; left: 12px; bottom: 9px; font-size: 9px; font-weight: 800; letter-spacing: 0.04em; padding: 2px 6px; border-radius: 6px; background: #FFFAF1; border: 1.2px solid #1A1714;">PDF</span>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Teoria Literária</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Apostila importada</span>
          <span style="margin-top: 5px; display: flex; align-items: center; gap: 5px; font-size: 12px; font-weight: 800;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 11-6 6v3h9l3-3"></path><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"></path></svg>
            18 notas
          </span>
        </div>
      </a>

      <a href="#" aria-label="Quincas Borba, Machado de Assis, lido" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></div>
          <div style="position: absolute; left: 16px; right: 16px; top: 18px; display: flex; flex-direction: column; gap: 6px;">
            <div style="height: 6px; border-radius: 6px; background: #F7F0E3;"></div>
            <div style="height: 6px; width: 70%; border-radius: 6px; background: #F7F0E3;"></div>
            <div style="height: 6px; width: 40%; border-radius: 6px; background: #F7F0E3;"></div>
          </div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
            <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 23px; line-height: 0.9; color: #FFFAF1;">Quincas<br>Borba</div>
            <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">MACHADO DE ASSIS</div>
          </div>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Quincas Borba</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Machado de Assis</span>
          <span style="margin-top: 5px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 4px 9px 4px 7px; border-radius: 999px; background: #E1EDD0; color: #2E5314;">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
            Lido
          </span>
        </div>
      </a>

      <a href="#" aria-label="O Cortiço, Aluísio Azevedo, lido" style="display: flex; flex-direction: column; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></div>
          <div style="position: absolute; left: 22px; top: 20px; width: 62px; height: 72px; border-radius: 31px 31px 0 0; background: #FED170;"></div>
          <div style="position: absolute; left: 40px; top: 50px; width: 26px; height: 42px; border-radius: 13px 13px 0 0; background: #00995E;"></div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
            <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 23px; line-height: 0.9; color: #FFFAF1;">O Cortiço</div>
            <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">ALUÍSIO AZEVEDO</div>
          </div>
        </div>
        <div style="margin-top: 26px; display: flex; flex-direction: column; gap: 3px;">
          <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">O Cortiço</span>
          <span style="font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Aluísio Azevedo</span>
          <span style="margin-top: 5px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 4px 9px 4px 7px; border-radius: 999px; background: #E1EDD0; color: #2E5314;">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
            Lido
          </span>
        </div>
      </a>
    </div>
  </div>

  <!-- Shelf row 4 (continues under the navigation) -->
  <div style="position: relative;">
    <div aria-hidden="true" style="position: absolute; left: -5px; right: -5px; top: 158.5px; height: 11px; border-radius: 6px; background: {{shelf}}; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 3px 0 #1A1714;"></div>
    <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px;">
      <a href="#" aria-label="Iracema, José de Alencar" style="display: block; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.14);"></div>
          <div style="position: absolute; left: 18px; right: -10px; top: 26px; height: 44px; border-radius: 44px 0 0 44px; background: #1A1714;"></div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; font-family: 'Instrument Serif', Georgia, serif; font-size: 24px; line-height: 0.9; color: #1A1714;">Iracema</div>
        </div>
      </a>
      <a href="#" aria-label="Crime e Castigo, Fiódor Dostoiévski" style="display: block; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FED170; overflow: hidden; box-sizing: border-box;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.12);"></div>
          <div style="position: absolute; left: 20px; top: 20px; width: 12px; height: 70px; background: #1A1714; transform: rotate(24deg); transform-origin: top left;"></div>
          <div style="position: absolute; left: 50px; top: 22px; width: 34px; height: 34px; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box;"></div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; font-family: 'Instrument Serif', Georgia, serif; font-size: 20px; line-height: 0.92; color: #1A1714;">Crime e<br>Castigo</div>
        </div>
      </a>
      <a href="#" aria-label="A Metamorfose, Franz Kafka" style="display: block; min-width: 0;">
        <div style="position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.12);"></div>
          <div style="position: absolute; left: 30px; top: 24px; width: 44px; height: 58px; border-radius: 50%; background: #1A1714;"></div>
          <div style="position: absolute; left: 51px; top: 24px; width: 1.5px; height: 58px; background: #B6ACE4;"></div>
          <div style="position: absolute; left: 15px; right: 8px; bottom: 12px; font-family: 'Instrument Serif', Georgia, serif; font-size: 20px; line-height: 0.92; color: #1A1714;">A Meta-<br>morfose</div>
        </div>
      </a>
    </div>
  </div>
</div>
```

## Especificação pixel a pixel

Seção `b02.shelf` — retângulo absoluto no canvas 390×1640: **x=20, y=490, w=350, h=1011.25**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `b02.shelf` | box | 0 | 0 | 350 | 1011.25 | `margin-top: 22px; display: flex; flex-direction: column; gap: 30px` |  |
| 2 | `b02.shelf.row1` | box | 0 | 0 | 350 | 260.01 | `position: relative` |  |
| 3 | `b02.shelf.row1.plank` | box | -5 | 158.5 | 360 | 11 | `position: absolute; left: -5px; right: -5px; top: 158.5px; height: 11px; border-radius: 6px; background: {{shelf}} (padrão #FED170); border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 3px 0 #1A1714` |  |
| 4 | `b02.shelf.row1.grid` | box | 0 | 0 | 350 | 260.01 | `display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px` |  |
| 5 | `b02.shelf.book1` | box | 0 | 0 | 107.33 | 260.01 | `display: flex; flex-direction: column; min-width: 0` |  |
| 6 | `b02.shelf.book1.coverWrap` | box | 0 | 0 | 107.33 | 160 | `position: relative; height: 160px` |  |
| 7 | `b02.shelf.book1.cover` | box | 0 | 0 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #552CB7; overflow: hidden; box-sizing: border-box` |  |
| 8 | `b02.shelf.book1.cover.spine` | box | 1.5 | 1.5 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.22)` |  |
| 9 | `b02.shelf.book1.cover.circle` | box | 57.83 | -18.5 | 68 | 68 | `position: absolute; right: -20px; top: -20px; width: 68px; height: 68px; border-radius: 50%; background: #FED170` |  |
| 10 | `b02.shelf.book1.cover.ring` | box | 70.83 | 41.5 | 19 | 19 | `position: absolute; right: 16px; top: 40px; width: 16px; height: 16px; border-radius: 50%; border: 1.5px solid #FED170` |  |
| 11 | `b02.shelf.book1.cover.textBlock` | box | 16.5 | 92.21 | 81.33 | 54.29 | `position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 12 | `b02.shelf.book1.cover.title` | text | 16.5 | 92.21 | 81.33 | 40.48 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 22px; line-height: 0.92; color: #FED170` | Instrument Serif 22/20.24px peso 400 ls normal #FED170 |
| 13 | `b02.shelf.book1.cover.author` | text | 16.5 | 138.69 | 81.33 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #F7F0E3` | Figtree 6.5/normal peso 700 ls 0.91px #F7F0E3 |
| 14 | `b02.shelf.book1.ribbon` | icon | 79.33 | -8 | 16 | 30 | `position: absolute; top: -8px; right: 12px` |  |
| 15 | `b02.shelf.book1.info` | box | 0 | 186 | 107.33 | 57.21 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 16 | `b02.shelf.book1.info.title` | text | 0 | 186 | 107.33 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 17 | `b02.shelf.book1.info.author` | text | 0 | 205.8 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 18 | `b02.shelf.book1.info.progress` | box | 0 | 228.81 | 107.33 | 14.4 | `margin-top: 5px; display: flex; align-items: center; gap: 6px` |  |
| 19 | `b02.shelf.book1.info.progress.bar` | box | 0 | 232.51 | 40 | 7 | `width: 40px; height: 7px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E4DACA 0 2px, #FFFAF1 2px 4px); overflow: hidden` |  |
| 20 | `b02.shelf.book1.info.progress.fill` | box | 1.2 | 233.71 | 23.31 | 4.6 | `width: 62%; height: 100%; background: #FF552E` |  |
| 21 | `b02.shelf.book1.info.progress.percent` ±1 | text | 46 | 228.81 | 23.99 | 14.4 | `font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 22 | `b02.shelf.book2` | box | 121.33 | 0 | 107.33 | 260.01 | `display: flex; flex-direction: column; min-width: 0` |  |
| 23 | `b02.shelf.book2.coverWrap` | box | 121.33 | 0 | 107.33 | 160 | `position: relative; height: 160px` |  |
| 24 | `b02.shelf.book2.cover` | box | 121.33 | 0 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #ABCF82; overflow: hidden; box-sizing: border-box` |  |
| 25 | `b02.shelf.book2.cover.spine` | box | 122.83 | 1.5 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.14)` |  |
| 26 | `b02.shelf.book2.cover.arch` | box | 148.83 | 27.5 | 58.33 | 40 | `position: absolute; left: 26px; right: 20px; top: 26px; height: 40px; border-radius: 40px 40px 0 0; background: #1A1714` |  |
| 27 | `b02.shelf.book2.cover.textBlock` | box | 137.83 | 92.21 | 81.33 | 54.29 | `position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 28 | `b02.shelf.book2.cover.title` | text | 137.83 | 92.21 | 81.33 | 40.48 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 22px; line-height: 0.92; color: #1A1714` | Instrument Serif 22/20.24px peso 400 ls normal #1A1714 |
| 29 | `b02.shelf.book2.cover.author` | text | 137.83 | 138.69 | 81.33 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #1A1714` | Figtree 6.5/normal peso 700 ls 0.91px #1A1714 |
| 30 | `b02.shelf.book2.ribbon` | icon | 200.67 | -8 | 16 | 30 | `position: absolute; top: -8px; right: 12px` |  |
| 31 | `b02.shelf.book2.info` | box | 121.33 | 186 | 107.33 | 57.21 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 32 | `b02.shelf.book2.info.title` | text | 121.33 | 186 | 107.33 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 33 | `b02.shelf.book2.info.author` | text | 121.33 | 205.8 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 34 | `b02.shelf.book2.info.progress` | box | 121.33 | 228.81 | 107.33 | 14.4 | `margin-top: 5px; display: flex; align-items: center; gap: 6px` |  |
| 35 | `b02.shelf.book2.info.progress.bar` | box | 121.33 | 232.51 | 40 | 7 | `width: 40px; height: 7px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E4DACA 0 2px, #FFFAF1 2px 4px); overflow: hidden` |  |
| 36 | `b02.shelf.book2.info.progress.fill` | box | 122.53 | 233.71 | 12.78 | 4.6 | `width: 34%; height: 100%; background: #FF552E` |  |
| 37 | `b02.shelf.book2.info.progress.percent` ±1 | text | 167.33 | 228.81 | 24.3 | 14.4 | `font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 38 | `b02.shelf.book3` | box | 242.67 | 0 | 107.33 | 260.01 | `display: flex; flex-direction: column; min-width: 0` |  |
| 39 | `b02.shelf.book3.coverWrap` | box | 242.67 | 0 | 107.33 | 160 | `position: relative; height: 160px` |  |
| 40 | `b02.shelf.book3.cover` | box | 242.67 | 0 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box` |  |
| 41 | `b02.shelf.book3.cover.spine` | box | 244.17 | 1.5 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.1)` |  |
| 42 | `b02.shelf.book3.cover.ring` | box | 268.17 | 25.5 | 40 | 40 | `position: absolute; left: 24px; top: 24px; width: 40px; height: 40px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 43 | `b02.shelf.book3.cover.dot` | box | 294.17 | 51.5 | 22 | 22 | `position: absolute; left: 50px; top: 50px; width: 22px; height: 22px; border-radius: 50%; background: #1A1714` |  |
| 44 | `b02.shelf.book3.cover.textBlock` | box | 259.17 | 96.59 | 83.33 | 49.91 | `position: absolute; left: 15px; right: 6px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 45 | `b02.shelf.book3.cover.title` | text | 259.17 | 96.59 | 83.33 | 36.1 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.95; color: #1A1714` | Instrument Serif 19/18.05px peso 400 ls normal #1A1714 |
| 46 | `b02.shelf.book3.cover.author` | text | 259.17 | 138.69 | 83.33 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #1A1714` | Figtree 6.5/normal peso 700 ls 0.91px #1A1714 |
| 47 | `b02.shelf.book3.ribbon` | icon | 322 | -8 | 16 | 30 | `position: absolute; top: -8px; right: 12px` |  |
| 48 | `b02.shelf.book3.info` | box | 242.67 | 186 | 107.33 | 74.01 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 49 | `b02.shelf.book3.info.title` | text | 242.67 | 186 | 107.33 | 33.6 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 50 | `b02.shelf.book3.info.author` | text | 242.67 | 222.6 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 51 | `b02.shelf.book3.info.progress` | box | 242.67 | 245.61 | 107.33 | 14.4 | `margin-top: 5px; display: flex; align-items: center; gap: 6px` |  |
| 52 | `b02.shelf.book3.info.progress.bar` | box | 242.67 | 249.31 | 40 | 7 | `width: 40px; height: 7px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #E4DACA 0 2px, #FFFAF1 2px 4px); overflow: hidden` |  |
| 53 | `b02.shelf.book3.info.progress.fill` | box | 243.87 | 250.51 | 30.46 | 4.6 | `width: 81%; height: 100%; background: #FF552E` |  |
| 54 | `b02.shelf.book3.info.progress.percent` ±1 | text | 288.67 | 245.61 | 22.34 | 14.4 | `font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 55 | `b02.shelf.row2` | box | 0 | 290.01 | 350 | 250.62 | `position: relative` |  |
| 56 | `b02.shelf.row2.plank` | box | -5 | 448.51 | 360 | 11 | `position: absolute; left: -5px; right: -5px; top: 158.5px; height: 11px; border-radius: 6px; background: {{shelf}} (padrão #FED170); border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 3px 0 #1A1714` |  |
| 57 | `b02.shelf.row2.grid` | box | 0 | 290.01 | 350 | 250.62 | `display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px` |  |
| 58 | `b02.shelf.book4` | box | 0 | 290.01 | 107.33 | 250.62 | `display: flex; flex-direction: column; min-width: 0` |  |
| 59 | `b02.shelf.book4.cover` | box | 0 | 290.01 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #F2A815; overflow: hidden; box-sizing: border-box` |  |
| 60 | `b02.shelf.book4.cover.spine` | box | 1.5 | 291.51 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.12)` |  |
| 61 | `b02.shelf.book4.cover.archOutline` | box | 23.5 | 313.51 | 64.33 | 58 | `position: absolute; left: 22px; right: 18px; top: 22px; height: 58px; border-radius: 34px 34px 0 0; border: 1.5px solid #1A1714; border-bottom: none; box-sizing: border-box` |  |
| 62 | `b02.shelf.book4.cover.arch` | box | 39.5 | 333.51 | 32.33 | 38 | `position: absolute; left: 38px; right: 34px; top: 42px; height: 38px; border-radius: 20px 20px 0 0; background: #1A1714` |  |
| 63 | `b02.shelf.book4.cover.textBlock` | box | 16.5 | 400.62 | 81.33 | 35.89 | `position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 64 | `b02.shelf.book4.cover.title` | text | 16.5 | 400.62 | 81.33 | 22.08 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 24px; line-height: 0.92; color: #1A1714` | Instrument Serif 24/22.08px peso 400 ls normal #1A1714 |
| 65 | `b02.shelf.book4.cover.author` | text | 16.5 | 428.7 | 81.33 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #1A1714` | Figtree 6.5/normal peso 700 ls 0.91px #1A1714 |
| 66 | `b02.shelf.book4.info` | box | 0 | 476.01 | 107.33 | 64.62 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 67 | `b02.shelf.book4.info.title` | text | 0 | 476.01 | 107.33 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 68 | `b02.shelf.book4.info.author` | text | 0 | 495.81 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 69 | `b02.shelf.book4.info.tag` ±1 | box+text | 0 | 518.82 | 46.21 | 21.81 | `margin-top: 5px; align-self: flex-start; font-size: 11.5px; font-weight: 700; padding: 4px 9px; border-radius: 999px; background: #EFE7D7; color: #4A4238` | Figtree 11.5/normal peso 700 ls normal #4A4238 |
| 70 | `b02.shelf.book5` | box | 121.33 | 290.01 | 107.33 | 250.62 | `display: flex; flex-direction: column; min-width: 0` |  |
| 71 | `b02.shelf.book5.cover` | box | 121.33 | 290.01 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box` |  |
| 72 | `b02.shelf.book5.cover.spine` | box | 122.83 | 291.51 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.12)` |  |
| 73 | `b02.shelf.book5.cover.ringOuter` | box | 152.83 | 313.51 | 46 | 46 | `position: absolute; left: 30px; top: 22px; width: 46px; height: 46px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 74 | `b02.shelf.book5.cover.ringInner` | box | 162.83 | 323.51 | 26 | 26 | `position: absolute; left: 40px; top: 32px; width: 26px; height: 26px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 75 | `b02.shelf.book5.cover.dot` | box | 170.83 | 331.51 | 10 | 10 | `position: absolute; left: 48px; top: 40px; width: 10px; height: 10px; border-radius: 50%; background: #1A1714` |  |
| 76 | `b02.shelf.book5.cover.title` | text | 137.83 | 379.87 | 81.33 | 38.64 | `position: absolute; left: 15px; right: 8px; bottom: 30px; font-family: 'Instrument Serif', Georgia, serif; font-size: 21px; line-height: 0.92; color: #1A1714` | Instrument Serif 21/19.32px peso 400 ls normal #1A1714 |
| 77 | `b02.shelf.book5.cover.formatBadge` ±1 | box+text | 134.83 | 422.31 | 32.38 | 17.2 | `position: absolute; left: 12px; bottom: 9px; font-size: 9px; font-weight: 800; letter-spacing: 0.04em; padding: 2px 6px; border-radius: 6px; background: #FFFAF1; border: 1.2px solid #1A1714` | Figtree 9/normal peso 800 ls 0.36px #1A1714 |
| 78 | `b02.shelf.book5.info` | box | 121.33 | 476.01 | 107.33 | 64.62 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 79 | `b02.shelf.book5.info.title` | text | 121.33 | 476.01 | 107.33 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 80 | `b02.shelf.book5.info.author` | text | 121.33 | 495.81 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 81 | `b02.shelf.book5.info.tag` ±1 | box+text | 121.33 | 518.82 | 54.71 | 21.81 | `margin-top: 5px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 4px 9px 4px 7px; border-radius: 999px; background: #E1EDD0; color: #2E5314` | Figtree 11.5/normal peso 700 ls normal #2E5314 |
| 82 | `b02.shelf.book5.info.tag.icon` | icon | 128.33 | 523.73 | 12 | 12 | `—` |  |
| 83 | `b02.shelf.book6` | box | 242.67 | 290.01 | 107.33 | 250.62 | `display: flex; flex-direction: column; min-width: 0` |  |
| 84 | `b02.shelf.book6.cover` | box | 242.67 | 290.01 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #1A1714; overflow: hidden; box-sizing: border-box` |  |
| 85 | `b02.shelf.book6.cover.circle` | box | 266.17 | 313.51 | 44 | 44 | `position: absolute; left: 22px; top: 22px; width: 44px; height: 44px; border-radius: 50%; background: #B6ACE4` |  |
| 86 | `b02.shelf.book6.cover.ring` | box | 302.17 | 341.51 | 28 | 28 | `position: absolute; left: 58px; top: 50px; width: 28px; height: 28px; border-radius: 50%; border: 1.5px solid #B6ACE4; box-sizing: border-box` |  |
| 87 | `b02.shelf.book6.cover.textBlock` | box | 259.17 | 384.06 | 81.33 | 52.45 | `position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 88 | `b02.shelf.book6.cover.title` | text | 259.17 | 384.06 | 81.33 | 38.64 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 21px; line-height: 0.92; color: #B6ACE4` | Instrument Serif 21/19.32px peso 400 ls normal #B6ACE4 |
| 89 | `b02.shelf.book6.cover.author` | text | 259.17 | 428.7 | 81.33 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #F7F0E3` | Figtree 6.5/normal peso 700 ls 0.91px #F7F0E3 |
| 90 | `b02.shelf.book6.info` | box | 242.67 | 476.01 | 107.33 | 64.62 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 91 | `b02.shelf.book6.info.title` | text | 242.67 | 476.01 | 107.33 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 92 | `b02.shelf.book6.info.author` | text | 242.67 | 495.81 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 93 | `b02.shelf.book6.info.tag` ±1 | box+text | 242.67 | 518.82 | 67.31 | 21.81 | `margin-top: 5px; align-self: flex-start; font-size: 11.5px; font-weight: 700; padding: 4px 9px; border-radius: 999px; background: #ECE7FA; color: #3B2D86` | Figtree 11.5/normal peso 700 ls normal #3B2D86 |
| 94 | `b02.shelf.row3` | box | 0 | 570.63 | 350 | 250.62 | `position: relative` |  |
| 95 | `b02.shelf.row3.plank` | box | -5 | 729.13 | 360 | 11 | `position: absolute; left: -5px; right: -5px; top: 158.5px; height: 11px; border-radius: 6px; background: {{shelf}} (padrão #FED170); border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 3px 0 #1A1714` |  |
| 96 | `b02.shelf.row3.grid` | box | 0 | 570.63 | 350 | 250.62 | `display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px` |  |
| 97 | `b02.shelf.book7` | box | 0 | 570.63 | 107.33 | 250.62 | `display: flex; flex-direction: column; min-width: 0` |  |
| 98 | `b02.shelf.book7.cover` | box | 0 | 570.63 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FFFDF8; overflow: hidden; box-sizing: border-box; padding: 14px 12px 0 14px; display: flex; flex-direction: column; gap: 5px` |  |
| 99 | `b02.shelf.book7.cover.kicker` | text | 15.5 | 586.13 | 78.33 | 7.81 | `font-size: 6.5px; font-weight: 800; letter-spacing: 0.14em; color: #6F665B` | Figtree 6.5/normal peso 800 ls 0.91px #6F665B |
| 100 | `b02.shelf.book7.cover.title` | text | 15.5 | 598.94 | 78.33 | 27.3 | `font-size: 13px; font-weight: 800; line-height: 1.05; letter-spacing: -0.2px` | Figtree 13/13.65px peso 800 ls -0.2px #1A1714 |
| 101 | `b02.shelf.book7.cover.lines` | box | 15.5 | 637.24 | 78.33 | 43 | `margin-top: 6px; display: flex; flex-direction: column; gap: 5px` |  |
| 102 | `b02.shelf.book7.cover.lines.line1` | box | 15.5 | 637.24 | 78.33 | 3 | `height: 3px; width: 100%; border-radius: 2px; background: #DCD2C1` |  |
| 103 | `b02.shelf.book7.cover.lines.line2` | box | 15.5 | 645.24 | 68.93 | 3 | `height: 3px; width: 88%; border-radius: 2px; background: #DCD2C1` |  |
| 104 | `b02.shelf.book7.cover.lines.highlight` | box | 15.5 | 651.24 | 73.63 | 7 | `height: 7px; width: 94%; margin: -2px 0; border-radius: 2px; background: #FED170` |  |
| 105 | `b02.shelf.book7.cover.lines.line3` | box | 15.5 | 661.24 | 59.53 | 3 | `height: 3px; width: 76%; border-radius: 2px; background: #DCD2C1` |  |
| 106 | `b02.shelf.book7.cover.lines.line4` | box | 15.5 | 669.24 | 72.07 | 3 | `height: 3px; width: 92%; border-radius: 2px; background: #DCD2C1` |  |
| 107 | `b02.shelf.book7.cover.lines.line5` | box | 15.5 | 677.24 | 47 | 3 | `height: 3px; width: 60%; border-radius: 2px; background: #DCD2C1` |  |
| 108 | `b02.shelf.book7.cover.formatBadge` ±1 | box+text | 13.5 | 702.93 | 32.38 | 17.2 | `position: absolute; left: 12px; bottom: 9px; font-size: 9px; font-weight: 800; letter-spacing: 0.04em; padding: 2px 6px; border-radius: 6px; background: #FFFAF1; border: 1.2px solid #1A1714` | Figtree 9/normal peso 800 ls 0.36px #1A1714 |
| 109 | `b02.shelf.book7.info` | box | 0 | 756.63 | 107.33 | 57.21 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 110 | `b02.shelf.book7.info.title` | text | 0 | 756.63 | 107.33 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 111 | `b02.shelf.book7.info.source` | text | 0 | 776.43 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 112 | `b02.shelf.book7.info.notes` | text | 0 | 799.44 | 107.33 | 14.4 | `margin-top: 5px; display: flex; align-items: center; gap: 5px; font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 113 | `b02.shelf.book7.info.notes.icon` | icon | 0 | 799.64 | 14 | 14 | `—` |  |
| 114 | `b02.shelf.book8` | box | 121.33 | 570.63 | 107.33 | 250.62 | `display: flex; flex-direction: column; min-width: 0` |  |
| 115 | `b02.shelf.book8.cover` | box | 121.33 | 570.63 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box` |  |
| 116 | `b02.shelf.book8.cover.spine` | box | 122.83 | 572.13 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 117 | `b02.shelf.book8.cover.bars` | box | 138.83 | 590.13 | 72.33 | 30 | `position: absolute; left: 16px; right: 16px; top: 18px; display: flex; flex-direction: column; gap: 6px` |  |
| 118 | `b02.shelf.book8.cover.bars.bar1` | box | 138.83 | 590.13 | 72.33 | 6 | `height: 6px; border-radius: 6px; background: #F7F0E3` |  |
| 119 | `b02.shelf.book8.cover.bars.bar2` | box | 138.83 | 602.13 | 50.63 | 6 | `height: 6px; width: 70%; border-radius: 6px; background: #F7F0E3` |  |
| 120 | `b02.shelf.book8.cover.bars.bar3` | box | 138.83 | 614.13 | 28.93 | 6 | `height: 6px; width: 40%; border-radius: 6px; background: #F7F0E3` |  |
| 121 | `b02.shelf.book8.cover.textBlock` | box | 137.83 | 661.92 | 81.33 | 55.21 | `position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 122 | `b02.shelf.book8.cover.title` | text | 137.83 | 661.92 | 81.33 | 41.4 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 23px; line-height: 0.9; color: #FFFAF1` | Instrument Serif 23/20.7px peso 400 ls normal #FFFAF1 |
| 123 | `b02.shelf.book8.cover.author` | text | 137.83 | 709.32 | 81.33 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 6.5/normal peso 700 ls 0.91px #FFFAF1 |
| 124 | `b02.shelf.book8.info` | box | 121.33 | 756.63 | 107.33 | 64.62 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 125 | `b02.shelf.book8.info.title` | text | 121.33 | 756.63 | 107.33 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 126 | `b02.shelf.book8.info.author` | text | 121.33 | 776.43 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 127 | `b02.shelf.book8.info.tag` ±1 | box+text | 121.33 | 799.44 | 54.71 | 21.81 | `margin-top: 5px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 4px 9px 4px 7px; border-radius: 999px; background: #E1EDD0; color: #2E5314` | Figtree 11.5/normal peso 700 ls normal #2E5314 |
| 128 | `b02.shelf.book8.info.tag.icon` | icon | 128.33 | 804.35 | 12 | 12 | `—` |  |
| 129 | `b02.shelf.book9` | box | 242.67 | 570.63 | 107.33 | 250.62 | `display: flex; flex-direction: column; min-width: 0` |  |
| 130 | `b02.shelf.book9.cover` | box | 242.67 | 570.63 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box` |  |
| 131 | `b02.shelf.book9.cover.spine` | box | 244.17 | 572.13 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 132 | `b02.shelf.book9.cover.arch` | box | 266.17 | 592.13 | 62 | 72 | `position: absolute; left: 22px; top: 20px; width: 62px; height: 72px; border-radius: 31px 31px 0 0; background: #FED170` |  |
| 133 | `b02.shelf.book9.cover.door` | box | 284.17 | 622.13 | 26 | 42 | `position: absolute; left: 40px; top: 50px; width: 26px; height: 42px; border-radius: 13px 13px 0 0; background: #00995E` |  |
| 134 | `b02.shelf.book9.cover.textBlock` | box | 259.17 | 682.62 | 81.33 | 34.51 | `position: absolute; left: 15px; right: 8px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 135 | `b02.shelf.book9.cover.title` | text | 259.17 | 682.62 | 81.33 | 20.7 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 23px; line-height: 0.9; color: #FFFAF1` | Instrument Serif 23/20.7px peso 400 ls normal #FFFAF1 |
| 136 | `b02.shelf.book9.cover.author` | text | 259.17 | 709.32 | 81.33 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 6.5/normal peso 700 ls 0.91px #FFFAF1 |
| 137 | `b02.shelf.book9.info` | box | 242.67 | 756.63 | 107.33 | 64.62 | `margin-top: 26px; display: flex; flex-direction: column; gap: 3px` |  |
| 138 | `b02.shelf.book9.info.title` | text | 242.67 | 756.63 | 107.33 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 139 | `b02.shelf.book9.info.author` | text | 242.67 | 776.43 | 107.33 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 140 | `b02.shelf.book9.info.tag` ±1 | box+text | 242.67 | 799.44 | 54.71 | 21.81 | `margin-top: 5px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 4px 9px 4px 7px; border-radius: 999px; background: #E1EDD0; color: #2E5314` | Figtree 11.5/normal peso 700 ls normal #2E5314 |
| 141 | `b02.shelf.book9.info.tag.icon` | icon | 249.67 | 804.35 | 12 | 12 | `—` |  |
| 142 | `b02.shelf.row4` | box | 0 | 851.25 | 350 | 160 | `position: relative` |  |
| 143 | `b02.shelf.row4.plank` | box | -5 | 1009.75 | 360 | 11 | `position: absolute; left: -5px; right: -5px; top: 158.5px; height: 11px; border-radius: 6px; background: {{shelf}} (padrão #FED170); border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 3px 0 #1A1714` |  |
| 144 | `b02.shelf.row4.grid` | box | 0 | 851.25 | 350 | 160 | `display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px` |  |
| 145 | `b02.shelf.book10` | box | 0 | 851.25 | 107.33 | 160 | `display: block; min-width: 0` |  |
| 146 | `b02.shelf.book10.cover` | box | 0 | 851.25 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box` |  |
| 147 | `b02.shelf.book10.cover.spine` | box | 1.5 | 852.75 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.14)` |  |
| 148 | `b02.shelf.book10.cover.capsule` | box | 19.5 | 878.75 | 96.33 | 44 | `position: absolute; left: 18px; right: -10px; top: 26px; height: 44px; border-radius: 44px 0 0 44px; background: #1A1714` |  |
| 149 | `b02.shelf.book10.cover.title` | text | 16.5 | 976.15 | 81.33 | 21.6 | `position: absolute; left: 15px; right: 8px; bottom: 12px; font-family: 'Instrument Serif', Georgia, serif; font-size: 24px; line-height: 0.9; color: #1A1714` | Instrument Serif 24/21.6px peso 400 ls normal #1A1714 |
| 150 | `b02.shelf.book11` | box | 121.33 | 851.25 | 107.33 | 160 | `display: block; min-width: 0` |  |
| 151 | `b02.shelf.book11.cover` | box | 121.33 | 851.25 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #FED170; overflow: hidden; box-sizing: border-box` |  |
| 152 | `b02.shelf.book11.cover.spine` | box | 122.83 | 852.75 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.12)` |  |
| 153 | `b02.shelf.book11.cover.slash` | box | 142.83 | 872.75 | 12 | 70 | `position: absolute; left: 20px; top: 20px; width: 12px; height: 70px; background: #1A1714; transform: rotate(24deg); transform-origin: top left` |  |
| 154 | `b02.shelf.book11.cover.circle` | box | 172.83 | 874.75 | 34 | 34 | `position: absolute; left: 50px; top: 22px; width: 34px; height: 34px; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 155 | `b02.shelf.book11.cover.title` | text | 137.83 | 960.95 | 81.33 | 36.8 | `position: absolute; left: 15px; right: 8px; bottom: 12px; font-family: 'Instrument Serif', Georgia, serif; font-size: 20px; line-height: 0.92; color: #1A1714` | Instrument Serif 20/18.4px peso 400 ls normal #1A1714 |
| 156 | `b02.shelf.book12` | box | 242.67 | 851.25 | 107.33 | 160 | `display: block; min-width: 0` |  |
| 157 | `b02.shelf.book12.cover` | box | 242.67 | 851.25 | 107.33 | 160 | `position: relative; width: 100%; height: 160px; border-radius: 4px 9px 9px 4px; border: 1.5px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box` |  |
| 158 | `b02.shelf.book12.cover.spine` | box | 244.17 | 852.75 | 7 | 157 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.12)` |  |
| 159 | `b02.shelf.book12.cover.oval` | box | 274.17 | 876.75 | 44 | 58 | `position: absolute; left: 30px; top: 24px; width: 44px; height: 58px; border-radius: 50%; background: #1A1714` |  |
| 160 | `b02.shelf.book12.cover.seam` | box | 295.17 | 876.75 | 1.5 | 58 | `position: absolute; left: 51px; top: 24px; width: 1.5px; height: 58px; background: #B6ACE4` |  |
| 161 | `b02.shelf.book12.cover.title` | text | 259.17 | 960.95 | 81.33 | 36.8 | `position: absolute; left: 15px; right: 8px; bottom: 12px; font-family: 'Instrument Serif', Georgia, serif; font-size: 20px; line-height: 0.92; color: #1A1714` | Instrument Serif 20/18.4px peso 400 ls normal #1A1714 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `b02.shelf.book11.cover.slash`: caixa visual com `transform: rotate(24deg)` = x 114.36, y 872.75, w 39.43, h 68.83 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b02.shelf.book1.cover.title` | 1 | Dom | 109.81 | 16.5 | 52.62 | 36.12 |
| `b02.shelf.book1.cover.title` | 2 | Casmurro | 130.05 | 16.5 | 91.06 | 74.56 |
| `b02.shelf.book1.cover.author` | 1 | MACHADO DE ASSIS | 144.87 | 16.5 | 94.83 | 78.33 |
| `b02.shelf.book1.info.title` | 1 | Dom Casmurro | 199.3 | 0 | 96.52 | 96.52 |
| `b02.shelf.book1.info.author` | 1 | Machado de Assis | 217.68 | 0 | 101.25 | 101.25 |
| `b02.shelf.book1.info.progress.percent` | 1 | 62% | 240.21 | 46 | 69.99 | 23.99 |
| `b02.shelf.book2.cover.title` | 1 | Mrs. | 109.81 | 137.83 | 170.92 | 33.09 |
| `b02.shelf.book2.cover.title` | 2 | Dalloway | 130.05 | 137.83 | 206.87 | 69.04 |
| `b02.shelf.book2.cover.author` | 1 | VIRGINIA WOOLF | 144.87 | 137.83 | 204.81 | 66.98 |
| `b02.shelf.book2.info.title` | 1 | Mrs. Dalloway | 199.3 | 121.33 | 210.74 | 89.41 |
| `b02.shelf.book2.info.author` | 1 | Virginia Woolf | 217.68 | 121.33 | 200.97 | 79.64 |
| `b02.shelf.book2.info.progress.percent` | 1 | 34% | 240.21 | 167.33 | 191.63 | 24.3 |
| `b02.shelf.book3.cover.title` | 1 | Orgulho e | 112.07 | 259.17 | 322 | 62.83 |
| `b02.shelf.book3.cover.title` | 2 | Preconceito | 130.12 | 259.17 | 334.03 | 74.86 |
| `b02.shelf.book3.cover.author` | 1 | JANE AUSTEN | 144.87 | 259.17 | 313.62 | 54.45 |
| `b02.shelf.book3.info.title` | 1 | Orgulho e | 199.3 | 242.67 | 306 | 63.33 |
| `b02.shelf.book3.info.title` | 2 | Preconceito | 216.1 | 242.67 | 320.58 | 77.91 |
| `b02.shelf.book3.info.author` | 1 | Jane Austen | 234.48 | 242.67 | 312.62 | 69.95 |
| `b02.shelf.book3.info.progress.percent` | 1 | 81% | 257.01 | 288.67 | 311.01 | 22.34 |
| `b02.shelf.book4.cover.title` | 1 | Senhora | 419.82 | 16.5 | 83.77 | 67.27 |
| `b02.shelf.book4.cover.author` | 1 | JOSÉ DE ALENCAR | 434.88 | 16.5 | 88.63 | 72.13 |
| `b02.shelf.book4.info.title` | 1 | Senhora | 489.31 | 0 | 53.09 | 53.09 |
| `b02.shelf.book4.info.author` | 1 | José de Alencar | 507.69 | 0 | 89.69 | 89.69 |
| `b02.shelf.book4.info.tag` | 1 | Novo | 533.75 | 9 | 37.21 | 28.21 |
| `b02.shelf.book5.cover.title` | 1 | O | 396.67 | 137.83 | 149.17 | 11.34 |
| `b02.shelf.book5.cover.title` | 2 | Alienista | 415.99 | 137.83 | 199.03 | 61.2 |
| `b02.shelf.book5.cover.formatBadge` | 1 | PDF | 434.06 | 142.03 | 160.01 | 17.98 |
| `b02.shelf.book5.info.title` | 1 | O Alienista | 489.31 | 121.33 | 191.66 | 70.33 |
| `b02.shelf.book5.info.author` | 1 | Machado de Assis | 507.69 | 121.33 | 222.59 | 101.26 |
| `b02.shelf.book5.info.tag` | 1 | Lido | 533.75 | 144.33 | 167.05 | 22.72 |
| `b02.shelf.book6.cover.title` | 1 | Franken- | 400.86 | 259.17 | 326.64 | 67.47 |
| `b02.shelf.book6.cover.title` | 2 | stein | 420.18 | 259.17 | 293.08 | 33.91 |
| `b02.shelf.book6.cover.author` | 1 | MARY SHELLEY | 434.88 | 259.17 | 317.91 | 58.74 |
| `b02.shelf.book6.info.title` | 1 | Frankenstein | 489.31 | 242.67 | 325.28 | 82.61 |
| `b02.shelf.book6.info.author` | 1 | Mary Shelley | 507.69 | 242.67 | 314.48 | 71.81 |
| `b02.shelf.book6.info.tag` | 1 | Quero ler | 533.75 | 251.67 | 300.98 | 49.31 |
| `b02.shelf.book7.cover.kicker` | 1 | UNIDADE 2 | 592.31 | 15.5 | 58.29 | 42.79 |
| `b02.shelf.book7.cover.title` | 1 | Teoria | 610.31 | 15.5 | 51.83 | 36.33 |
| `b02.shelf.book7.cover.title` | 2 | Literária | 623.96 | 15.5 | 64.82 | 49.32 |
| `b02.shelf.book7.cover.formatBadge` | 1 | PDF | 714.68 | 20.7 | 38.68 | 17.98 |
| `b02.shelf.book7.info.title` | 1 | Teoria Literária | 769.93 | 0 | 96.49 | 96.49 |
| `b02.shelf.book7.info.source` | 1 | Apostila importada | 788.31 | 0 | 106.97 | 106.97 |
| `b02.shelf.book7.info.notes` | 1 | 18 notas | 810.84 | 19 | 65.16 | 46.16 |
| `b02.shelf.book8.cover.title` | 1 | Quincas | 680.09 | 137.83 | 200.51 | 62.68 |
| `b02.shelf.book8.cover.title` | 2 | Borba | 700.79 | 137.83 | 185.07 | 47.24 |
| `b02.shelf.book8.cover.author` | 1 | MACHADO DE ASSIS | 715.5 | 137.83 | 216.16 | 78.33 |
| `b02.shelf.book8.info.title` | 1 | Quincas Borba | 769.93 | 121.33 | 214.73 | 93.4 |
| `b02.shelf.book8.info.author` | 1 | Machado de Assis | 788.31 | 121.33 | 222.59 | 101.26 |
| `b02.shelf.book8.info.tag` | 1 | Lido | 814.37 | 144.33 | 167.05 | 22.72 |
| `b02.shelf.book9.cover.title` | 1 | O Cortiço | 700.79 | 259.17 | 331.5 | 72.33 |
| `b02.shelf.book9.cover.author` | 1 | ALUÍSIO AZEVEDO | 715.5 | 259.17 | 330.65 | 71.48 |
| `b02.shelf.book9.info.title` | 1 | O Cortiço | 769.93 | 242.67 | 305.68 | 63.01 |
| `b02.shelf.book9.info.author` | 1 | Aluísio Azevedo | 788.31 | 242.67 | 332.48 | 89.81 |
| `b02.shelf.book9.info.tag` | 1 | Lido | 814.37 | 265.67 | 288.38 | 22.71 |
| `b02.shelf.book10.cover.title` | 1 | Iracema | 995.11 | 16.5 | 82.38 | 65.88 |
| `b02.shelf.book11.cover.title` | 1 | Crime e | 976.95 | 137.83 | 189.93 | 52.1 |
| `b02.shelf.book11.cover.title` | 2 | Castigo | 995.35 | 137.83 | 187.41 | 49.58 |
| `b02.shelf.book12.cover.title` | 1 | A Meta- | 976.95 | 259.17 | 313.43 | 54.26 |
| `b02.shelf.book12.cover.title` | 2 | morfose | 995.35 | 259.17 | 314.35 | 55.18 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Grade `repeat(3, minmax(0,1fr))`, gap 14 → colunas de 107,33. Capa 107,33 × 160, raio 4/9/9/4, borda 1,5, `overflow: hidden`, com a lombada de 7 em preto translúcido (a opacidade muda por livro: .10 a .22). A tábua: `left/right −5`, top 158,5, 11 de altura, raio 6, borda 1,5, sombra dura 0/3.
2. Capas em CSS (formas, não SVG): círculo e anel (Dom Casmurro), arco (Mrs. Dalloway, Senhora), anéis concêntricos (O Alienista), traços (Quincas Borba), porta (O Cortiço), meia-lua (Iracema), barra girada 24° pelo canto (Crime e Castigo), oval partido (A Metamorfose). Título Instrument Serif 19–24 `lh 0,9–0,95` e autor 6,5/700 ls 0,14em, em `left 15 · right 8 · bottom 12`.
3. Lendo (1ª prateleira): a fita coral 16 × 30 (`fitaMarcador`) sai 8 acima da capa, `right 12`; embaixo, a barra 40 × 7 (hachura 135° `#E4DACA`/`#FFFAF1`, borda 1,2, preenchimento `#FF552E`) e "62%" 12/800, gap 6.
4. Info 26 abaixo da capa (coluna, gap 3): título 14/700 `lh 1,2` e autor 12,5/500 `#5B544B` em uma linha com reticências. Etiquetas 11,5/700 em pílula (padding 4/9): Novo `#EFE7D7`/`#4A4238`; Lido `#E1EDD0`/`#2E5314` com o visto 12 (padding 4/9/4/7, gap 4); Quero ler `#ECE7FA`/`#3B2D86`. PDF: a etiqueta 9/800 ls 0,04em dentro da capa (`left 12 · bottom 9`, raio 6, borda 1,2).
5. A apostila (Teoria Literária) é outra capa: fundo `#FFFDF8`, "UNIDADE 2" 6,5/800, "Teoria / Literária" 13/800, seis linhas de texto falsas (3 de altura, `#DCD2C1`) com uma grifada (7 de altura, `#FED170`, `margin −2 0`) e, no lugar da etiqueta, o marca-texto 14 e "18 notas" 12/800.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- Cada capa tem formas em px dentro de uma caixa de largura fluida: as presas por `left`/`right` esticam com a coluna e as de `width` fixa não — a 360 o arco e a porta de O Cortiço invadem o título (abaixo). No app, as formas acompanham a largura da coluna como o CSS (não um desenho fixo de 107,33).
- A prancha ainda mostra Senhora ("Novo") e Frankenstein ("Quero ler"), que a revisão de consistência do design (`NOTAS.md`, itens 2 e 3) diz ter trocado por O Guarani e Crime e Castigo: a fixture da tela segue a prancha (D-34); a coerência com o mundo de referência (D-88) é pergunta da T14.
- A 4ª prateleira passa por baixo do degradê e da navegação (os livros 10–12 aparecem sem a info): no app a estante rola, e o fim da lista para acima da navegação (o recuo do shell, `shell_insets.dart`).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_002_biblioteca_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_002_biblioteca_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `b02.shelf.book1.cover.title` | texto passa (x) | 3.23 | 0 | **sim** | não |  |
| 360 | `b02.shelf.book1.info.author` | reticências (x) | 0 | 0 | **sim** | não |  |
| 360 | `b02.shelf.book3.cover.title` | texto passa (x) | 1.53 | 0 | **sim** | não |  |
| 360 | `b02.shelf.book5.info.author` | reticências (x) | 0 | 0 | **sim** | não |  |
| 360 | `b02.shelf.book7.info.source` | reticências (x) | 0 | 0 | **sim** | não |  |
| 360 | `b02.shelf.book8.info.author` | reticências (x) | 0 | 0 | **sim** | não |  |
| 360 | `b02.shelf.book9.cover.arch` | invade o vizinho (x) | 62 | 0 | **sim** | sim | vizinho `b02.shelf.book9.cover.textBlock` |
| 360 | `b02.shelf.book9.cover.door` | invade o vizinho (x) | 26 | 0 | **sim** | sim | vizinho `b02.shelf.book9.cover.textBlock` |

- A 360: fio de navalha em `b02.shelf.book1.info.title` linha 1 «Dom Casmurro»: sobra 0.82 px · sem palavra seguinte (D-275: a linha única quebra se crescer).
- A 360: fio de navalha em `b02.shelf.book4.cover.author` linha 1 «JOSÉ DE»: sobra 38.56 px · estouro com a próxima palavra 0.8 px.
- A 360: fio de navalha em `b02.shelf.book7.info.title` linha 1 «Teoria Literária»: sobra 0.85 px · sem palavra seguinte (D-275: a linha única quebra se crescer).
- A 360: fio de navalha em `b02.shelf.book9.cover.title` linha 1 «O»: sobra sem limite (não quebra ao crescer) · estouro com a próxima palavra 1 px.
- A 360: fio de navalha em `b02.shelf.book9.cover.author` linha 1 «ALUÍSIO»: sobra sem limite (não quebra ao crescer) · estouro com a próxima palavra 0.15 px.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `b02.shelf` |  | Livros |  |
| `b02.shelf.row1.plank` |  |  | aria-hidden=true |
| `b02.shelf.book1` |  | Dom Casmurro, Machado de Assis, 62% lido |  |
| `b02.shelf.book1.ribbon` |  |  | aria-hidden=true |
| `b02.shelf.book2` |  | Mrs. Dalloway, Virginia Woolf, 34% lido |  |
| `b02.shelf.book2.ribbon` |  |  | aria-hidden=true |
| `b02.shelf.book3` |  | Orgulho e Preconceito, Jane Austen, 81% lido |  |
| `b02.shelf.book3.ribbon` |  |  | aria-hidden=true |
| `b02.shelf.row2.plank` |  |  | aria-hidden=true |
| `b02.shelf.book4` |  | Senhora, José de Alencar, novo |  |
| `b02.shelf.book5` |  | O Alienista, Machado de Assis, PDF, lido |  |
| `b02.shelf.book5.info.tag.icon` |  |  | aria-hidden=true |
| `b02.shelf.book6` |  | Frankenstein, Mary Shelley, quero ler |  |
| `b02.shelf.row3.plank` |  |  | aria-hidden=true |
| `b02.shelf.book7` |  | Teoria Literária, apostila em PDF, 18 notas |  |
| `b02.shelf.book7.info.notes.icon` |  |  | aria-hidden=true |
| `b02.shelf.book8` |  | Quincas Borba, Machado de Assis, lido |  |
| `b02.shelf.book8.info.tag.icon` |  |  | aria-hidden=true |
| `b02.shelf.book9` |  | O Cortiço, Aluísio Azevedo, lido |  |
| `b02.shelf.book9.info.tag.icon` |  |  | aria-hidden=true |
| `b02.shelf.row4.plank` |  |  | aria-hidden=true |
| `b02.shelf.book10` |  | Iracema, José de Alencar |  |
| `b02.shelf.book11` |  | Crime e Castigo, Fiódor Dostoiévski |  |
| `b02.shelf.book12` |  | A Metamorfose, Franz Kafka |  |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `b02.shelf.row1.plank` | NeoBox |  |
| `b02.shelf.book1.cover` | NeoBox |  |
| `b02.shelf.book1.cover.spine` | NeoBox |  |
| `b02.shelf.book1.cover.circle` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book1.cover.ring` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book1.ribbon` | AppSvg(AppIllustrationsBiblioteca.fitaMarcador, size: 16×30) |  |
| `b02.shelf.book1.info.progress.bar` | HatchPainter (hachura 135°) dentro do contorno |  |
| `b02.shelf.book1.info.progress.fill` | NeoBox |  |
| `b02.shelf.book2.cover` | NeoBox |  |
| `b02.shelf.book2.cover.spine` | NeoBox |  |
| `b02.shelf.book2.cover.arch` | NeoBox |  |
| `b02.shelf.book2.ribbon` | AppSvg(AppIllustrationsBiblioteca.fitaMarcador, size: 16×30) |  |
| `b02.shelf.book2.info.progress.bar` | HatchPainter (hachura 135°) dentro do contorno |  |
| `b02.shelf.book2.info.progress.fill` | NeoBox |  |
| `b02.shelf.book3.cover` | NeoBox |  |
| `b02.shelf.book3.cover.spine` | NeoBox |  |
| `b02.shelf.book3.cover.ring` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book3.cover.dot` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book3.ribbon` | AppSvg(AppIllustrationsBiblioteca.fitaMarcador, size: 16×30) |  |
| `b02.shelf.book3.info.progress.bar` | HatchPainter (hachura 135°) dentro do contorno |  |
| `b02.shelf.book3.info.progress.fill` | NeoBox |  |
| `b02.shelf.row2.plank` | NeoBox |  |
| `b02.shelf.book4.cover` | NeoBox |  |
| `b02.shelf.book4.cover.spine` | NeoBox |  |
| `b02.shelf.book4.cover.archOutline` | NeoBox |  |
| `b02.shelf.book4.cover.arch` | NeoBox |  |
| `b02.shelf.book4.info.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.shelf.book5.cover` | NeoBox |  |
| `b02.shelf.book5.cover.spine` | NeoBox |  |
| `b02.shelf.book5.cover.ringOuter` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book5.cover.ringInner` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book5.cover.dot` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book5.cover.formatBadge` | NeoBox + AppText |  |
| `b02.shelf.book5.info.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.shelf.book5.info.tag.icon` | AppSvg(AppIconsBiblioteca.checkBold, size: 12) |  |
| `b02.shelf.book6.cover` | NeoBox |  |
| `b02.shelf.book6.cover.circle` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book6.cover.ring` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book6.info.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.shelf.row3.plank` | NeoBox |  |
| `b02.shelf.book7.cover` | NeoBox |  |
| `b02.shelf.book7.cover.lines.line1` | NeoBox |  |
| `b02.shelf.book7.cover.lines.line2` | NeoBox |  |
| `b02.shelf.book7.cover.lines.highlight` | NeoBox |  |
| `b02.shelf.book7.cover.lines.line3` | NeoBox |  |
| `b02.shelf.book7.cover.lines.line4` | NeoBox |  |
| `b02.shelf.book7.cover.lines.line5` | NeoBox |  |
| `b02.shelf.book7.cover.formatBadge` | NeoBox + AppText |  |
| `b02.shelf.book7.info.notes.icon` | AppSvg(AppIconsBiblioteca.highlighterBold, size: 14) |  |
| `b02.shelf.book8.cover` | NeoBox |  |
| `b02.shelf.book8.cover.spine` | NeoBox |  |
| `b02.shelf.book8.cover.bars.bar1` | NeoBox |  |
| `b02.shelf.book8.cover.bars.bar2` | NeoBox |  |
| `b02.shelf.book8.cover.bars.bar3` | NeoBox |  |
| `b02.shelf.book8.info.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.shelf.book8.info.tag.icon` | AppSvg(AppIconsBiblioteca.checkBold, size: 12) |  |
| `b02.shelf.book9.cover` | NeoBox |  |
| `b02.shelf.book9.cover.spine` | NeoBox |  |
| `b02.shelf.book9.cover.arch` | NeoBox |  |
| `b02.shelf.book9.cover.door` | NeoBox |  |
| `b02.shelf.book9.info.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `b02.shelf.book9.info.tag.icon` | AppSvg(AppIconsBiblioteca.checkBold, size: 12) |  |
| `b02.shelf.row4.plank` | NeoBox |  |
| `b02.shelf.book10.cover` | NeoBox |  |
| `b02.shelf.book10.cover.spine` | NeoBox |  |
| `b02.shelf.book10.cover.capsule` | NeoBox |  |
| `b02.shelf.book11.cover` | NeoBox |  |
| `b02.shelf.book11.cover.spine` | NeoBox |  |
| `b02.shelf.book11.cover.slash` | NeoBox | Transform: rotate(24deg) |
| `b02.shelf.book11.cover.circle` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book12.cover` | NeoBox |  |
| `b02.shelf.book12.cover.spine` | NeoBox |  |
| `b02.shelf.book12.cover.oval` | CircleIconButton / NeoBox circular |  |
| `b02.shelf.book12.cover.seam` | NeoBox |  |

## Interações

- Livro → os Detalhes (17 no papel, 17b no e-book e no PDF), nesta etapa (`AppRoutes.livro`).
- Segurar o livro (as opções) → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T14 (ROTEIRO §2b).

## Dados

- Cada livro: título curto (D-270), autor, formato (papel, e-book, PDF), status e, no Lendo, a porcentagem — e-book pela posição salva; papel pela última página anotada ÷ páginas (Orgulho e Preconceito: 344 de 424 = 81 %). Sem página no papel, a barra não tem dado: o que mostrar é pergunta da T14.
- Capas: as da fixture como widgets (como as da Início, `features/home/presentation/covers/`); com dados reais, a capa do catálogo ou a foto da pessoa (D-79).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L02.1** Prateleira: a grade de 3 e a tábua
- **L02.2** As 12 capas da fixture como widgets
- **L02.3** Info: título, autor, progresso, etiquetas e notas
- **L02.4** Rolagem e o fim por baixo da navegação
- **L02.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('b02.shelf'), todos os ids de `kRef02.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/002_biblioteca_390x1640@3x.png` no recorte da fase (y 463.5–1518.75) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef02w360` e `kRef02w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L02.1 Prateleira: a grade de 3 e a tábua
- [ ] L02.2 As 12 capas da fixture como widgets
- [ ] L02.3 Info: título, autor, progresso, etiquetas e notas
- [ ] L02.4 Rolagem e o fim por baixo da navegação
- [ ] L02.5 Verificação + relatório
- [ ] Geometria 161/161 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
