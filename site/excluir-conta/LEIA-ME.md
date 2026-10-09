# Página web de pedido de exclusão de conta (G05)

Exigência do Google Play (Política de dados do usuário — "exclusão de conta"): um link público onde a pessoa
pede a exclusão **sem precisar do app**. Este link vai no formulário "Segurança dos dados" do Play Console.

- `index.html` + `estilo.css` + `app.js`: a página (sem design ainda — D-21; sem bibliotecas, cookies ou
  rastreamento; CSP restrita).
- `exclusao.js`: a lógica (código por e-mail **sem criar conta** → `delete-account` com o JWT da própria
  conta). Testes: `deno test site/excluir-conta/`.
- `config.js`: URL do projeto e chave **pública** — preenchidas na publicação.

Fluxo: e-mail → `POST /auth/v1/otp` (`create_user: false`; a resposta é a mesma com ou sem conta) → código →
`POST /auth/v1/verify` → `POST /functions/v1/delete-account` `{confirmar: true}` (a mesma função do app:
RevenueCat → Storage → Auth, imediato).

Limites conhecidos:

- A página responde igual para e-mail com e sem conta (não revela quem usa o BookNest). A rota `/auth/v1/otp`
  do Supabase, chamada direto (fora da página, com `create_user: false`), ainda diferencia; se isso importar,
  o pedido do código passa por uma Edge Function que responde sempre igual (G25).
- A função `delete-account` confere a sessão no Auth (`getUser`): um token de sessão já encerrada não exclui a
  conta. Não exige login recente (`iat`) — o código do e-mail já é um login recente na página.

Para publicar (pendente da **Q9 — hospedagem/domínio**):

1. Hospedar a pasta como site estático (HTTPS).
2. Preencher `config.js` (URL do `booknest-prod` e a chave publishable).
3. No projeto Supabase: segredo da função `EXCLUSAO_WEB_ORIGEM` = a origem da página (ex.:
   `https://booknest.app.br`) — sem ele a função não libera CORS e o navegador bloqueia.
4. No Supabase Auth: o e-mail de código de acesso é o mesmo do app
   (`supabase/templates/codigo_de_acesso.html`).
