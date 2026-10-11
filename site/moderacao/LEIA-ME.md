# Painel de moderação (G21.2 — D-52, D-220)

Para quem modera: a fila de denúncias abertas, da mais antiga para a mais nova, com o conteúdo denunciado, a
idade e a marca de quem passou do prazo de 24 h. Cada denúncia: **Esconder** (o conteúdo some — `deleted_at`;
perfil: bio e foto limpas) ou **Manter** (só fecha a denúncia), com uma nota opcional.

- `index.html` + `estilo.css` + `app.js`: a página (sem bibliotecas, cookies ou rastreamento; CSP restrita).
- `painel.js`: a lógica (código por e-mail **sem criar conta** → a Edge Function `moderacao` com o JWT da
  própria conta, que só fica na memória da página). Testes: `deno test site/moderacao/`.
- `config.js`: URL do projeto e chave **pública** — preenchidas na publicação.

Quem modera fica em `private.moderators` (só o `service_role` mexe — pelo SQL do painel do Supabase):

```sql
insert into private.moderators (user_id) select id from auth.users where email = 'pessoa@exemplo.com';
```

Todo dia às 9h de Brasília, havendo denúncia aberta, cada pessoa da lista recebe um e-mail com as contagens
(`moderation_digest`, pela fila de e-mail). O envio de verdade depende do remetente (Q9).

Para publicar (pendente da **Q9 — hospedagem/domínio**):

1. Hospedar a pasta como site estático (HTTPS), fora da busca (`noindex`).
2. Preencher `config.js` (URL do `booknest-prod` e a chave publishable).
3. No projeto Supabase: o segredo da função `MODERACAO_WEB_ORIGEM` = a origem da página. Sem ele a função não
   libera CORS e o navegador bloqueia.
