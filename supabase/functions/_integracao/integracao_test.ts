// Integração das Edge Functions com o Supabase LOCAL (supabase start): Auth, Storage, banco,
// gateway, pg_cron/pg_net e o runtime das funções de verdade. Só roda com BOOKNEST_INTEGRACAO=1 e as
// variáveis do `supabase status -o env` (tools/supabase/testar_funcoes_local.sh). Nunca contra stg/prod.
import { deepStrictEqual as assertEquals, ok } from 'node:assert/strict';
import postgres from 'npm:postgres@3.4.9';
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';

// sem --allow-env (deno test comum) a integração fica ignorada em vez de falhar
const podeLerEnv = Deno.permissions.querySync({ name: 'env' }).state === 'granted';
const env = (nome: string) => (podeLerEnv ? Deno.env.get(nome) : undefined);
const ATIVO = env('BOOKNEST_INTEGRACAO') === '1';
const API = env('API_URL') ?? 'http://127.0.0.1:54321';
const PUB = env('PUBLISHABLE_KEY') ?? env('ANON_KEY') ?? '';
const SEC = env('SECRET_KEY') ?? env('SERVICE_ROLE_KEY') ?? '';
const DB = env('DB_URL') ?? '';
const WEBHOOK = env('REVENUECAT_WEBHOOK_AUTH') ?? '';
if (ATIVO && !/127\.0\.0\.1|localhost/.test(API + DB)) throw new Error('integração só no Supabase LOCAL');

const opcoes = { sanitizeOps: false, sanitizeResources: false, ignore: !ATIVO };
const sql = ATIVO ? postgres(DB, { prepare: false, max: 2 }) : null!;
const admin = ATIVO ? createClient(API, SEC, { auth: { persistSession: false } }) : null!;

async function novoUsuario(email: string) {
  const senha = crypto.randomUUID();
  const { data, error } = await admin.auth.admin.createUser({ email, password: senha, email_confirm: true });
  if (error) throw error;
  const cliente = createClient(API, PUB, { auth: { persistSession: false } });
  const s = await cliente.auth.signInWithPassword({ email, password: senha });
  if (s.error) throw s.error;
  return { id: data.user!.id, jwt: s.data.session!.access_token };
}
const chamar = (fn: string, init: RequestInit) =>
  fetch(`${API}/functions/v1/${fn}`, { method: 'POST', ...init });
const comJwt = (jwt: string, corpo: unknown) => ({
  headers: { Authorization: `Bearer ${jwt}`, apikey: PUB, 'Content-Type': 'application/json' },
  body: JSON.stringify(corpo),
});
const sufixo = Date.now();

Deno.test({
  ...opcoes,
  name: 'ebook-upload-url: Pro recebe URL assinada, sobe o arquivo e a cota é medida no Storage',
  fn: async () => {
    const u = await novoUsuario(`ebook-${sufixo}@exemplo.com`);
    const sha = 'b'.repeat(64);
    const livro = crypto.randomUUID();
    await sql`insert into billing.entitlements (user_id, entitlement, active_until) values (${u.id}, 'pro', now() + interval '30 days')`;
    await sql`insert into personal.user_books (id, user_id, title, author_display, format, status, content_sha256, added_at, created_at, updated_at, version_hlc)
            values (${livro}, ${u.id}, 'Livro', 'Autor', 'epub', 'reading', ${sha}, now(), now(), now(), '0001790000000000-0000-it')`;
    const r = await chamar(
      'ebook-upload-url',
      comJwt(u.jwt, { user_book_id: livro, sha256: sha, bytes: 1024 }),
    );
    assertEquals(r.status, 200);
    const j = await r.json();
    assertEquals(j.path, `${u.id}/${livro}/${sha}.epub`);
    const up = await createClient(API, PUB).storage.from('ebooks')
      .uploadToSignedUrl(j.path, j.token, new Blob([new Uint8Array(1024)], { type: 'application/epub+zip' }));
    ok(!up.error, String(up.error?.message));
    const [o] =
      await sql`select (metadata ->> 'size')::int as tamanho from storage.objects where bucket_id = 'ebooks' and name = ${j.path}`;
    assertEquals(o.tamanho, 1024);
    const outro = await novoUsuario(`ebook2-${sufixo}@exemplo.com`);
    await sql`insert into billing.entitlements (user_id, entitlement, active_until) values (${outro.id}, 'pro', now() + interval '30 days')`;
    const r2 = await chamar(
      'ebook-upload-url',
      comJwt(outro.jwt, { user_book_id: livro, sha256: sha, bytes: 1024 }),
    );
    assertEquals([r2.status, (await r2.json()).erro], [404, 'book_not_found']);
    const r3 = await chamar(
      'ebook-upload-url',
      comJwt('jwt.forjado.x', { user_book_id: livro, sha256: sha, bytes: 1024 }),
    );
    assertEquals(r3.status, 401);
    await r3.body?.cancel();
  },
});

Deno.test({
  ...opcoes,
  name: 'G06 ebook-download-url: Pro baixa por URL curta; outra conta não; apagar o livro tira o arquivo',
  fn: async () => {
    const u = await novoUsuario(`ebook-dl-${sufixo}@exemplo.com`);
    const sha = 'd'.repeat(64);
    const livro = crypto.randomUUID();
    await sql`insert into billing.entitlements (user_id, entitlement, active_until) values (${u.id}, 'pro', now() + interval '30 days')`;
    await sql`insert into personal.user_books (id, user_id, title, author_display, format, status, content_sha256, added_at, created_at, updated_at, version_hlc)
            values (${livro}, ${u.id}, 'Livro', 'Autor', 'epub', 'reading', ${sha}, now(), now(), now(), '0001790000000000-0000-it')`;
    const r = await chamar(
      'ebook-upload-url',
      comJwt(u.jwt, { user_book_id: livro, sha256: sha, bytes: 2048 }),
    );
    const j = await r.json();
    const bytes = crypto.getRandomValues(new Uint8Array(2048));
    const up = await createClient(API, PUB).storage.from('ebooks')
      .uploadToSignedUrl(j.path, j.token, new Blob([bytes], { type: 'application/epub+zip' }));
    ok(!up.error, String(up.error?.message));
    // o app grava o caminho no livro (sincronização)
    await sql`update personal.user_books set storage_object_path = ${j.path}, version_hlc = '0001790000000001-0000-it' where id = ${livro}`;

    const d = await chamar('ebook-download-url', comJwt(u.jwt, { user_book_id: livro }));
    assertEquals(d.status, 200);
    const dj = await d.json();
    assertEquals([dj.path, dj.expires_in], [j.path, 300]);
    const baixado = new Uint8Array(await (await fetch(`${API}${dj.signed_path}`)).arrayBuffer());
    assertEquals(baixado, bytes);

    // o próprio dono não lê o bucket direto (sem política SELECT): nem gera link longo
    const cliente = createClient(API, PUB, {
      auth: { persistSession: false },
      global: { headers: { Authorization: `Bearer ${u.jwt}` } },
    });
    const longo = await cliente.storage.from('ebooks').createSignedUrl(j.path, 60 * 60 * 24 * 365);
    ok(longo.error, 'o cliente não pode gerar link assinado do e-book');

    const outro = await novoUsuario(`ebook-dl2-${sufixo}@exemplo.com`);
    await sql`insert into billing.entitlements (user_id, entitlement, active_until) values (${outro.id}, 'pro', now() + interval '30 days')`;
    const n = await chamar('ebook-download-url', comJwt(outro.jwt, { user_book_id: livro }));
    assertEquals([n.status, (await n.json()).erro], [404, 'book_not_found']);

    // apagar o livro (exclusão lógica que chega pela sincronização) → a função do agendador apaga o arquivo
    await sql`update personal.user_books set deleted_at = now(), version_hlc = '0001790000000002-0000-it' where id = ${livro}`;
    await sql`select private.invoke_edge_function('purge-storage')`;
    let restante = 1;
    for (let i = 0; i < 30 && restante > 0; i++) {
      await new Promise((ok) => setTimeout(ok, 500));
      const [o] =
        await sql`select count(*)::int as n from storage.objects where bucket_id = 'ebooks' and name = ${j.path}`;
      restante = o.n;
    }
    assertEquals(restante, 0);
    const [q] =
      await sql`select count(*)::int as n from private.ebook_object_deletions where path = ${j.path}`;
    assertEquals(q.n, 0);
  },
});

Deno.test({
  ...opcoes,
  name: 'export-data: o usuário baixa os próprios dados',
  fn: async () => {
    const u = await novoUsuario(`export-${sufixo}@exemplo.com`);
    const r = await chamar('export-data', comJwt(u.jwt, {}));
    assertEquals(r.status, 200);
    const j = await r.json();
    assertEquals([j.account.email, j.profile.id, j.format_version], [
      `export-${sufixo}@exemplo.com`,
      u.id,
      2,
    ]);
  },
});

Deno.test({
  ...opcoes,
  name: 'agendador ponta a ponta: pg_net → gateway → purge-storage apaga a pasta da fila',
  fn: async () => {
    const u = await novoUsuario(`purge-${sufixo}@exemplo.com`);
    const caminho = `${u.id}/x/${'c'.repeat(64)}.pdf`;
    const up = await admin.storage.from('ebooks').upload(
      caminho,
      new Blob([new Uint8Array(10)], { type: 'application/pdf' }),
    );
    ok(!up.error, String(up.error?.message));
    await sql`select private.queue_storage_purge(${u.id}, 'retention')`;
    await sql`select private.invoke_edge_function('purge-storage')`;
    let feito = false;
    for (let i = 0; i < 30 && !feito; i++) {
      await new Promise((ok) => setTimeout(ok, 500));
      const [q] =
        await sql`select done_at is not null as feito from private.storage_purge_queue where user_id = ${u.id}`;
      feito = q.feito;
    }
    ok(feito, 'a fila não foi processada pela função chamada pelo pg_net');
    const [o] =
      await sql`select count(*)::int as n from storage.objects where bucket_id = 'ebooks' and name = ${caminho}`;
    assertEquals(o.n, 0);
  },
});

Deno.test({
  ...opcoes,
  name: 'funções do agendador recusam chave errada e, sem provedor configurado, não gastam a fila',
  fn: async () => {
    for (const fn of ['email-sender', 'push-sender', 'purge-storage']) {
      const r = await chamar(fn, { headers: { apikey: 'chave-errada' } });
      assertEquals([fn, r.status], [fn, 401]);
      await r.body?.cancel();
    }
    const [k] =
      await sql`select decrypted_secret as k from vault.decrypted_secrets where name = 'booknest_scheduler_key'`;
    for (const fn of ['email-sender', 'push-sender']) {
      const r = await chamar(fn, { headers: { apikey: k.k } });
      assertEquals([fn, r.status], [fn, 503]); // sem RESEND_API_KEY / FCM_SERVICE_ACCOUNT no local
      await r.body?.cancel();
    }
  },
});

Deno.test({
  ...opcoes,
  name: 'revenuecat-webhook: segredo errado 401; evento de teste registrado e processado',
  fn: async () => {
    const errado = await chamar('revenuecat-webhook', {
      headers: { Authorization: 'Bearer outro' },
      body: '{}',
    });
    assertEquals(errado.status, 401);
    await errado.body?.cancel();
    const id = `it-${sufixo}`;
    const r = await chamar('revenuecat-webhook', {
      headers: { Authorization: WEBHOOK, 'Content-Type': 'application/json' },
      body: JSON.stringify({ api_version: '1.0', event: { id, type: 'TEST', app_user_id: 'qualquer' } }),
    });
    assertEquals([r.status, (await r.json()).status], [200, 'ignorado']);
    const [e] =
      await sql`select processed_at is not null as ok from billing.webhook_events where event_id = ${id}`;
    ok(e.ok);
  },
});

Deno.test({
  ...opcoes,
  name: 'delete-account: exclui a conta de quem pede (Auth + banco em cascata)',
  fn: async () => {
    const u = await novoUsuario(`delete-${sufixo}@exemplo.com`);
    const sem = await chamar('delete-account', comJwt(u.jwt, {}));
    assertEquals(sem.status, 400);
    await sem.body?.cancel();
    const r = await chamar('delete-account', comJwt(u.jwt, { confirmar: true }));
    assertEquals([r.status, (await r.json()).excluida], [200, true]);
    const [p] = await sql`select count(*)::int as n from public.profiles where id = ${u.id}`;
    assertEquals(p.n, 0);
    const [q] = await sql`select reason from private.storage_purge_queue where user_id = ${u.id}`;
    assertEquals(q.reason, 'account_deleted');
  },
});

Deno.test({
  ...opcoes,
  name: 'isbn-lookup: consulta de verdade (BrasilAPI) e cota registrada',
  fn: async () => {
    const u = await novoUsuario(`isbn-${sufixo}@exemplo.com`);
    const r = await chamar('isbn-lookup', comJwt(u.jwt, { isbn: '978-85-359-1066-7' }));
    ok([200, 404, 503].includes(r.status), `status ${r.status}`);
    await r.body?.cancel();
    const [c] =
      await sql`select used from private.quota_usage where user_id = ${u.id} and quota_key = 'isbn_externo'`;
    assertEquals(c.used, 1);
  },
});

Deno.test({
  ...opcoes,
  name: '(fecha a conexão)',
  fn: async () => {
    await sql.end();
  },
});
