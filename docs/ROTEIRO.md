# ROTEIRO — o caminho único até o app pronto

> Criado em 10/10/2026 e refeito no mesmo dia, quando o projeto inteiro do Claude Design (128 telas) entrou em
> `docs/design/projeto/`. **Este é o único arquivo que define a ordem do projeto.** As fases G (prompt mestre) e T
> (`docs/progresso/PLANO_FIDELIDADE_TELAS.md`) estão juntas aqui, numa fila só, numerada por **etapa**. O §11 do prompt
> mestre e o §6 do plano de fidelidade viram histórico: o conteúdo das fases antigas continua lá, a ordem é esta.
> Onde estamos agora: `docs/STATUS.md`.
>
> Decisões do Cesar em 10/10/2026: **as abas primeiro** (Biblioteca, Livro, Scanner, Busca, Entrar e Onboarding,
> Perfil, antes do clube) e **as 128 telas na versão 1.0** (nada fica para depois).

## 1. Como usar (toda sessão)

1. Ler `CLAUDE.md`, `docs/STATUS.md` e este arquivo.
2. Fazer **só a etapa que o STATUS marca como próxima** (▶). Nunca pular, juntar ou inventar etapa.
3. Antes de escrever código: spec e plano em `docs/progresso/<ID>.md` e `<ID>_plano.md` (como na T03/T04), com as
   perguntas (§2b). A próxima decisão livre é a **D-267**.
4. **Subfases:** cada etapa é dividida em subfases numeradas (`T14.1`, `T14.2`…), uma por tela ou por seção grande de
   tela, cada uma com teste, commit próprio e o checklist dela. Antes de começar cada tela, perguntar o que for dessa
   tela (§2b).
5. **Qualidade máxima, nada simplificado:** tudo o que a prancha mostra existe no app e funciona de verdade, com dados
   reais, estados (carregando, vazio, erro, sem internet) e animações discretas onde o design indica. Se algo não puder
   ser feito como está, **perguntar**; nunca cortar, trocar por algo mais simples ou deixar "para depois" calado.
6. No fim: a definição de pronto (§4), o relatório, a frase de parada e **PARAR**.

Prompt para colar numa sessão nova do Claude Code:

```
Leia CLAUDE.md, docs/STATUS.md e docs/ROTEIRO.md. Execute a etapa que o STATUS marca como próxima, seguindo a spec
para onde o ROTEIRO aponta e a definição de pronto do ROTEIRO §4. Antes de escrever código, me mostre a spec e o
plano e faça as perguntas de decisão nova. Não comece outra etapa.
```

## 2. Fontes da verdade (nesta ordem)

1. **Visual, textos e números de cada tela:** o projeto completo do Claude Design em **`docs/design/projeto/`**
   (`CATALOGO.md` lista as 128 telas e o arquivo de cada uma; `NOTAS.md` traz as notas do design para o Flutter; a
   tela **00 · Mapa de navegação** mostra como as telas se ligam). Os três HTML antigos (`docs/design/LEIA-ME.md`)
   continuam como referência medida das telas que já foram feitas.
2. **Ordem e "pronto":** este ROTEIRO.
3. **Conteúdo de cada etapa:** onde a coluna "Spec" da §3 aponta.
4. **Regras de produto e dados:** os anexos de `handoff_v2/` e as decisões D-xx (plano de fidelidade §3,
   `handoff_v2/05_DECISOES_E_PERGUNTAS.md` e os relatórios das fases).

Se o projeto, um HTML antigo e qualquer outro texto discordarem: **parar e perguntar**. Tela que não está no projeto:
§5 (desenhar primeiro, no mesmo estilo, com aprovação).

## 2b. Perguntas e melhorias (como o agente conversa com o Cesar)

- **Perguntar sempre, em toda etapa:** no começo (junto da spec) e sempre que surgir uma escolha. Usar perguntas de
  múltipla escolha (a ferramenta de perguntas do Claude Code), com **a opção recomendada primeiro, marcada
  "(Recomendado)"**, e uma linha dizendo o que cada opção muda na tela.
- **Melhorias pequenas são bem-vindas, mas só com aprovação.** Se algo do design ficar pouco claro ou puder ficar
  melhor no celular (exemplo: o tempo da caneta pouco legível), propor como pergunta com:
  - o que muda e por quê, numa frase;
  - 2 ou 3 referências reais (Pinterest, Mobbin, Dribbble ou apps conhecidos), com link;
  - a opção **"Manter igual ao design"**, sempre presente.
- **O que nunca muda sem pedido explícito:** a identidade do design (cores, fontes, raios, sombras, estilo das
  ilustrações), a estrutura das telas e os textos principais. Melhoria é ajuste fino, não redesenho.
- **Melhoria aprovada:** vira decisão D-xx, entra em `docs/design/melhorias_aprovadas.md` (tela, o que mudou, a
  decisão, a referência) e os testes de fidelidade passam a medir a versão aprovada, como já foi feito na D-55.

## 3. Todas as etapas, em ordem

✅ feita · ▶ próxima · ⏳ na fila. Os números das telas são os do `docs/design/projeto/CATALOGO.md`.

| # | ID | O que entrega (telas do projeto) | Spec | Situação |
|---|---|---|---|---|
| 0 | G00–G22 | Base, banco local e nuvem, conta, sync do Pro, catálogo e scanner provisório, leitor (19–27b), grifos (25), social e clubes (só dados), Pro técnico | prompt mestre §6 · relatórios G | ✅ |
| 1 | T01 | Leitor: acertos das 23, 23b, 24, 24b | plano de fidelidade §5 | ✅ |
| 2 | T02 | Medição da Início e da revisão (sem tela nova) | plano de fidelidade §5 | ✅ |
| 3 | T03 | Início nova (01, 60) | plano de fidelidade §5 | ✅ |
| 4 | T04 | Cronômetro do livro de papel na Início (01b): mini-barra e folha mínima | plano de fidelidade §5 | ✅ |
| 5 | R00 | **Arrumação:** main em dia, cobertura das 128 telas, mapa de navegação, prova no celular, modo demonstração | este arquivo §7 | ▶ |
| 6 | T13 | **Medição do projeto:** a ferramenta de medição passa a ler os `.dc.html`; mede as telas das etapas 7–11 | modelo da T02 + §6b | ⏳ |
| 7 | T14 | **Biblioteca** (02), Biblioteca vazia (36), **Detalhes do livro** físico e e-book (17, 17b) | modelo da T03 | ⏳ |
| 8 | T15 | **Scanner** (03, 39, 40, 41, 42, 69, 69b), **Busca** (28, 28b, 28c), Adicionar à mão (28d) | modelo da T03 | ⏳ |
| 9 | T16 | **Entrada:** Abertura (35), Login (07), Cadastro (08), Entrar (09, 09b), Código (10), Nova senha (11), Onboarding (12, 13, 13b, 14, 15, 16), Início primeiro acesso (36a) | modelo da T03 | ⏳ |
| 10 | T17 | **Perfil** (05), Editar perfil (64, 65), **Ajustes** (06), Conta (58), Excluir conta (59), Privacidade (56), **Notificações** (30, 30b, 30c) | modelo da T03 | ⏳ |
| 11 | T18 | **Cronômetro** (18) e **Fim da sessão** (18b): substituem a folha mínima da T04 | modelo da T03 | ⏳ |
| 12 | T05 | Revisão dos grifos (61, 62, 63) e o cartão da Início ligado | plano de fidelidade §5 | ⏳ |
| 13 | T06 | Medição das 16 telas do clube (com a ferramenta da T13) | plano de fidelidade §5 | ⏳ |
| 14 | T07 | **Aba Clubes** (04) | plano de fidelidade §5 | ⏳ |
| 15 | T08 | Discussão da semana (31) | plano de fidelidade §5 | ⏳ |
| 16 | T09 | Membros (32) | plano de fidelidade §5 | ⏳ |
| 17 | T10 | Encontro (70, 71, 72, 73) | plano de fidelidade §5 | ⏳ |
| 18 | T11 | Enquete (47, 48, 49, 50, 102, 103, 104) | plano de fidelidade §5 | ⏳ |
| 19 | T12 | Criar clube e convite (33, 34) | plano de fidelidade §5 | ⏳ |
| 20 | T19 | **Pro:** topo A e B (83), Planos anual e mensal (83, 84), perfil bloqueado (85), estatísticas bloqueadas (86), Bem-vinda (87), Gerenciar assinatura (88). Sem elas o build de loja não vende (D-230) | modelo da T03 + Anexo 04 | ⏳ |
| 21 | T20 | **Perfil completo:** Resenhas (43, 46, 74, 75, 76), Grifos em mural (44), Listas (45, 66, 67, 68) | modelo da T03 | ⏳ |
| 22 | T21 | **Estatísticas** (29, 77, 78) e **Conquistas** (79, 80, 81, 82) | modelo da T03 | ⏳ |
| 23 | T22 | **Social:** perfil de outra pessoa (51, 52, 53, 54), Seguidores e Seguindo (89, 90, 91, 92), Pedidos para seguir (57), Quem vê (93, 94, 95, 96, 97), Bloqueadas (98, 99, 100), mensagem recolhida do clube (101) | modelo da T03 | ⏳ |
| 24 | T23 | **Convites** (105, 106, 107, 108, 109, 110, 111) | modelo da T03 | ⏳ |
| 25 | T24 | **Estados do app:** Sem internet (37), Erro (38) e a revisão de todos os vazios e erros | modelo da T03 | ⏳ |
| 26 | R01 | **Integração final:** nenhum placeholder, tudo ligado como o Mapa de navegação (00), fluxos ponta a ponta | este arquivo §8 | ⏳ |
| 27 | G23 | Notificações (push e lembretes, inclusive os da D-245) | prompt mestre §6 | ⏳ |
| 28 | G24 | Observabilidade e analytics | prompt mestre §6 | ⏳ |
| 29 | G25 | Segurança e LGPD (+ os dados novos das T no mapa) | prompt mestre §6 | ⏳ |
| 30 | G26 | Desempenho e carga (+ as RPCs novas) | prompt mestre §6 | ⏳ |
| 31 | G27 | CI/CD, ambientes e publicação nas lojas | prompt mestre §6 | ⏳ |
| 32 | G28 | QA final → **v1.0** | prompt mestre §6 | ⏳ |

Regras da fila:
- As 128 telas têm etapa. Não existe G29: o roteiro do prompt mestre acaba na G28.
- Etapa grande demais para uma sessão pode ser dividida em partes (T16a, T16b…), **só com pergunta**, registrando aqui.
- Trocar a ordem, juntar ou criar etapa: só com pergunta, e a mudança é registrada aqui.
- Etapa de tela que precisa de dado ou servidor novo faz o dado na mesma etapa (como a D-244): banco local, servidor,
  sync do Pro, pgTAP e o teste de privacidade do Grátis.

## 4. Definição de pronto (vale para toda etapa)

Uma etapa só termina quando:

1. **Spec e plano** escritos e aprovados; as decisões novas e as melhorias propostas perguntadas (§2b) e registradas (D-xx).
2. **Fidelidade** (etapas de tela): as 4 camadas do prompt mestre §7 contra a prancha (geometria, estilo, visual, texto).
2b. **Nada simplificado:** a auditoria anti-simplificação (v1 F13.4) passa na etapa: cada elemento da prancha
   existe, com o mesmo texto, estado e ação; o relatório lista qualquer diferença com a decisão que a aprovou.
3. **Suíte verde:** os comandos do prompt mestre §7 (format, analyze 0, `flutter test`, pgTAP e Deno quando houver).
4. **Ligada:** a tela nova entra **na rota de verdade, no lugar do placeholder**, com as ligações do Mapa de
   navegação (00), e `docs/NAVEGACAO.md` é atualizado (cada toque da prancha com destino e estado). Tela que existe
   só em teste não conta como pronta.
5. **Vista no celular:** build instalado no Galaxy S22+ por USB, com capturas (`adb exec-out screencap -p`) de cada
   tela da etapa lado a lado com o PNG da prancha e o caminho "como chegar" em `docs/progresso/<ID>_celular.md`.
   Etapa sem tela nova escreve só "nada muda no celular" e o motivo.
6. **STATUS e cobertura atualizados:** última etapa, próxima, o que mudou no celular, commit; e as telas da etapa
   marcadas como feitas em `docs/design/projeto/COBERTURA.md`.
7. **Relatório** (modelo do prompt mestre §9) terminando com:
   `✅ ETAPA <n> · <ID> concluída — aguardando sua aprovação para a ETAPA <n+1> · <ID>.` E **PARAR**.
8. **Depois da aprovação:** merge `--ff-only` da branch da etapa na `main` (§6).

## 5. Tela que não está no projeto — desenhar primeiro, no mesmo estilo

As 128 telas do projeto são seguidas como estão. Quando o caminho pedir algo que o projeto não desenha (uma tela,
uma folha, um estado, um aviso), **pode ser criado**, assim:

1. **Perguntar** se a tela é mesmo necessária, com a opção recomendada primeiro.
2. **Pesquisar referências:** 3 a 5 exemplos reais (Pinterest, Mobbin, Dribbble ou apps conhecidos), com link.
3. **Desenhar a prancha antes do Flutter**, em HTML, **no mesmo estilo das outras** (as mesmas cores, fontes, bordas,
   sombras, raios, ícones e ilustrações; de preferência montada com pedaços de telas parecidas do projeto), em
   `docs/design/novas/<NN>_<nome>.html`, 390 px de largura.
4. **Mostrar a captura da prancha nova e as referências** e esperar o "sim" (pode ter ajustes).
5. Depois de aprovada, ela vale como as do projeto: entra no `CATALOGO` das novas (`docs/design/novas/LEIA-ME.md`),
   é medida e implementada com as mesmas 4 camadas de fidelidade.

Quando o projeto mudar no Claude Design: baixar a versão nova numa **pasta nova** (`docs/design/projeto_<data>/`),
comparar com a atual e perguntar o que muda. Os arquivos de `docs/design/projeto/` não se editam.

## 6. Git

- A base é a `main`. Cada etapa: branch `feat/<id>-<assunto>` **a partir da main**, commits pequenos por subfase.
- No fim, com a aprovação: `git checkout main && git merge --ff-only <branch>` e push. Nunca empilhar branch sobre
  branch (foi o que deixou a main 478 commits atrás até a T04).
- As branches antigas ficam como estão (não apagar).

## 6b. Medir telas do projeto (`.dc.html`)

Os arquivos de `docs/design/projeto/telas/` são o formato de origem do Claude Design: cada um renderiza com o
`dc-runtime.js` e as props padrão do próprio arquivo (`data-props`, como `{{brand}}`). A T13 adapta
`tools/medicao/` para renderizar esse formato no Chromium (390 × altura da tela no `CATALOGO.md`, fontes embutidas,
rede bloqueada) e gerar as mesmas saídas da T02 (layout, texto, estilos, PNG @1x/@2x/@3x, redlines, fases L). As
medições novas vão para `docs/design/medicao/projeto/` e `test/reference/projeto/`. Cada etapa de tela seguinte começa
medindo as suas telas com essa ferramenta, se a T13 ainda não mediu. Atenção: os `.dc.html` chamam `./support.js`, que não veio no
projeto (só o `dc-runtime.js`); a T13 descobre como renderizar sem ele ou pede o arquivo.

## 7. R00 · Arrumação (P/M)

Objetivo: tudo num lugar só, a `main` em dia, o que está pronto provado no celular, e um mapa claro do que falta.

- [ ] Ler este arquivo, o STATUS, o `docs/design/projeto/CATALOGO.md` e `NOTAS.md`, o plano de fidelidade (§2, §3)
      e a auditoria de telas (§5).
- [ ] **Git (com autorização):** `git checkout main && git merge --ff-only feat/t04-cronometro-papel` e push. Commitar
      este ROTEIRO, o STATUS, o `CLAUDE.md` e a pasta `docs/design/projeto/` na branch da R00. A partir daqui vale a §6.
- [ ] **`docs/design/projeto/COBERTURA.md`:** as 128 telas, cada uma com: rota no app, situação (✅ feita e igual ·
      🟠 feita, mas diferente do projeto · ⬜ não feita) e a etapa que faz.
- [ ] **As telas já feitas mudaram no projeto?** Renderizar a versão do projeto das telas da Início (01, 01b, 60) e
      do leitor (19–27b) e comparar com as referências medidas que os testes usam. Diferença → listar e perguntar
      (atualizar ou manter).
- [ ] **`docs/NAVEGACAO.md`**, a partir do Mapa de navegação (00) e do código (`lib/app/router.dart`, `routes.dart`, os
      `onTap`): (a) todas as rotas, com o que mostram hoje e a etapa que troca; (b) para cada tela pronta, cada
      elemento tocável → destino → estado: ✅ leva à tela certa · ⏸ sem ação por decisão (D-243 b) · 🟡 leva a
      placeholder; (c) "como chegar no celular", em passos.
- [ ] **Teste de integração** `integration_test/navegacao_test.dart`: percorre as 4 abas, o botão do scanner e cada
      ligação ✅, conferindo a tela de destino pela chave; lista os 🟡 (só falha por eles na R01).
- [ ] **Modo demonstração** (decisão nova **D-267**, perguntar antes): só em debug/profile, nunca no build de loja,
      uma opção que carrega o mundo de referência (as fixtures da Início, do leitor e do clube) no banco local do
      aparelho, para ver no celular as telas com os mesmos dados do design.
- [ ] **Prova no celular:** instalar no Galaxy S22+ e capturar cada tela pronta lado a lado com o PNG da prancha →
      `docs/progresso/R00_celular.md`.
- [ ] Atualizar `docs/design/LEIA-ME.md` (a pasta do projeto como fonte principal), STATUS, relatório, frase de parada.

## 8. R01 · Integração final (M)

Objetivo: o app inteiro ligado como o Mapa de navegação (00), sem nenhum caminho que termine num placeholder.

- [ ] Teste que **falha** se algum `PlaceholderScreen` for alcançável no build release; as rotas de depuração
      (`/_ds`, `/_pro`) fora do release.
- [ ] `COBERTURA.md` com as 128 telas ✅; `docs/NAVEGACAO.md` sem 🟡. Cada ⏸ (D-243 b) revisto: ligar ou perguntar.
- [ ] Fluxos ponta a ponta no aparelho (`integration_test`): primeiro uso (abertura → login → onboarding → scanner →
      ler → grifar → revisão); clube (criar → convite → discussão → encontro → enquete); social (perfil de outra
      pessoa → seguir → resenha); Pro (paywall → compra sandbox → sync em 2 aparelhos); conta (exportar, sair, excluir).
- [ ] Voltar (botão do Android e gesto) coerente em todas as rotas; links profundos abrindo a tela certa.
- [ ] Prova no celular com todas as telas; STATUS; relatório.

## 9. Depois da v1.0 (fora deste roteiro)

Entram como roteiros próprios só depois da G28, para não atrapalhar este:
- idiomas e moedas (textos em `.arb`, preços vindos das lojas);
- motion design e gamificação extra (estudo de referências; uma camada por cima das telas prontas).
