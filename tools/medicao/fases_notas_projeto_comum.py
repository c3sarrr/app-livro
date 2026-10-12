"""T13.12 — o que se repete nas notas escritas das fases L do projeto (as fontes, os dados, as ligações para telas de
outras etapas). Usado pelos módulos por etapa (`fases_notas_projeto_t14.py` … `_t18.py`), juntos em
`fases_notas_projeto.py`.
"""

FONTES = ('Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a '
          'Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só '
          'existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); '
          'a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o '
          '`tnum` entra onde a tabela diz.')

DADOS = ('Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; '
         'na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.')

VERIFICACAO = 'Verificação + relatório'


def sem_destino(etapa, onde):
    """A ligação para uma tela que é de outra etapa (ou que ainda não tem prancha, D-268): o texto padrão."""
    return (f'{onde}: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b '
            '(idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da '
            f'{etapa} (ROTEIRO §2b).')
