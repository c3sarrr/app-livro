# BookNest (app_livros) — regras para agentes

- **Comece sempre por:** `docs/STATUS.md` (onde estamos e qual é a próxima etapa) e `docs/ROTEIRO.md` (a ordem
  única de tudo, fases G e T juntas, e a definição de pronto). Só o ROTEIRO define a ordem; o §11 do prompt mestre e
  o §6 do `docs/progresso/PLANO_FIDELIDADE_TELAS.md` são histórico (o conteúdo das fases continua lá).
- **Telas:** antes de construir, mudar ou conferir qualquer tela, leia a prancha dela no projeto completo do design,
  `docs/design/projeto/` (`CATALOGO.md` diz o arquivo de cada uma das 128 telas; `NOTAS.md` traz as notas do design
  para o Flutter; a tela 00 é o Mapa de navegação). Os HTML antigos de `docs/design/LEIA-ME.md` são a referência
  medida das telas já feitas. Se as fontes discordam, pergunte antes (ROTEIRO §2).
- **Etapas:** uma por vez, a que o STATUS marca como próxima. A spec de cada uma está onde o ROTEIRO aponta; spec,
  plano e resultado ficam em `docs/progresso/`. Decisão nova só com pergunta. Pronto = ROTEIRO §4: inclui ligar a
  tela na navegação de verdade, ver no celular e atualizar o STATUS.
- **Perguntas e melhorias (ROTEIRO §2b):** perguntar em toda etapa, em múltipla escolha com a opção recomendada
  primeiro. Melhoria pequena além do design só como proposta, com 2–3 referências e a opção "Manter igual ao design";
  aplicar só depois de aprovada. A identidade do design não muda.
- **Qualidade máxima:** nada simplificado. Tudo que a prancha mostra existe e funciona com dados reais e todos os
  estados; o que não der para fazer igual, pergunte. Cada etapa em subfases (uma por tela), com commit e teste.
- **Tela que falta no projeto:** pode ser criada (ROTEIRO §5): perguntar, buscar 3–5 referências (Pinterest, Mobbin,
  Dribbble), desenhar a prancha em HTML no mesmo estilo das outras em `docs/design/novas/`, mostrar e esperar o "sim"
  antes do Flutter.
- **Não mexer:** `design_handoff/`, `handoff_v2/`, `docs/design/referencia/` e `docs/design/projeto/` (leitura, sim).
