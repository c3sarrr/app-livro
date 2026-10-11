# G22 — Pro com RevenueCat: plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha
> (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.
> **Como na G21:** o servidor (G22.1) está com o código completo. O app (G22.2–G22.5) tem, por tarefa, os arquivos, as
> assinaturas, as decisões de encaixe e os testes; o código está nos commits de cada tarefa (o teste chega antes,
> falha no Windows e só então chega a implementação). Desvio registrado em `G22.md`.

**Objetivo:** comprar, restaurar e gerenciar o Pro no app com o RevenueCat (Test Store), confirmar no servidor na
hora ("conferir agora"), os gatilhos do paywall atrás da depuração, o aviso de sandbox e a prova num emulador.

**Arquitetura:**
- **Servidor:** uma Edge Function nova, `revenuecat-sync` (JWT da pessoa → API REST do RevenueCat →
  `private.rc_apply_subscriber`, a mesma do webhook), e a migração `g22_pro` (as contas de teste, o aviso no e-mail
  do dia, o `other_sessions` do `my_account`).
- **App:** `lib/features/billing/` com uma interface (`BillingGateway`) e duas implementações (o RevenueCat de
  verdade e o dublê dos testes); o `BillingController` junta o Pro da loja e o do servidor. O Pro do servidor
  continua no `AccountController` e liga o sync como hoje (G06).

**Pilha:**
- Supabase CLI 2.119, Postgres 17, pgTAP, Deno 2.9;
- Flutter 3.47.2 / Dart 3.13.2, flutter_riverpod 3, drift, supabase_flutter 2.18;
- `purchases_flutter` **10.14.0** (Anexo 04); `url_launcher` **6.3.2** (não está no projeto; a 6.3.3 saiu em 02/10,
  com 6 dias).

**Execução e ambiente:** o mesmo da G21 (`docs/progresso/G21_plano.md`, "Execução e ambiente"):
- espelho `/home/claude/g03/repo` → `enviar.py` → `expandir.ps1`;
- servidor pelo WSL (`wsl.ps1`): health, `supabase db reset` filtrado, `supabase test db`;
- app no Windows (`rodar.ps1`, `resumo.ps1`); integração por `integracao.ps1`;
- commits por `novo_commit22.sh` + `msg_g22_NN.txt` + `commits_g22<letra>.ps1`, em português, com o rodapé;
- **chaves:** `env/dev.json` (a da Test Store, para o emulador) e `supabase/functions/.env` (`REVENUECAT_API_KEY`)
  já estão no PC, fora do git. Nenhum script imprime chave; nenhuma chave entra na conversa.

Spec: `docs/progresso/G22.md` (D-228…D-234, R1…R8), citada por §1…§7. Branch `feat/g22-pro-revenuecat`, base
`53edeee` (a spec é o `0f9686b`).

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `supabase/migrations/<carimbo>_g22_pro.sql` (novo) | contas de teste, o aviso no e-mail do dia, `other_sessions` | 2 |
| `supabase/tests/database/26_pro_g22.test.sql` (novo) | idem, e a cota `pro_sync` | 1–2 |
| `supabase/functions/email-sender/modelos.ts` (+ teste) | a linha do sandbox no `moderation_digest` | 3 |
| `supabase/functions/revenuecat-sync/` (novo) | o "conferir agora" | 4 |
| `supabase/functions/revenuecat-webhook/*_test.ts` | a matriz do Anexo 04 §9 | 5 |
| `supabase/config.toml` | `[functions.revenuecat-sync] verify_jwt = true` | 4 |
| `pubspec.yaml`, `android/app/build.gradle*`, `AndroidManifest.xml` | o SDK e o que ele pede | 6 |
| `lib/features/billing/domain/billing_models.dart` (novo) | `ProPackage`, `ProCustomer`, `PurchaseOutcome`, `BillingFailure` | 7 |
| `lib/features/billing/domain/billing_rules.dart` (novo) | R4 (economia, teste), R6 (instrução), R8 (validade), os textos de estado | 7 |
| `lib/features/billing/data/billing_gateway.dart` (novo) | a interface | 8 |
| `lib/features/billing/data/revenuecat_gateway.dart` (novo) | o SDK → o domínio | 8 |
| `lib/features/billing/data/pro_server_api.dart` (novo) | `revenuecat-sync` e `my_entitlement` | 9 |
| `lib/features/billing/application/billing_controller.dart` (novo) | R1–R3, R5, R6, o estado `ProView`; o 2º aparelho | 10–12 |
| `lib/features/billing/application/billing_providers.dart` (novo) | as ligações, as chaves, nulo sem configuração | 10 |
| `lib/features/billing/application/paywall_triggers.dart` (novo) | R7 | 12 |
| `lib/core/config/app_env.dart`, `env/*.example.json` | as chaves do RevenueCat (já no modelo, ainda não no `AppEnv`); `TERMS_URL`, `PRIVACY_URL` | 10, 14 |
| `lib/features/account/presentation/account_block.dart` + `pro_rows.dart` (novo) | o Pro no Perfil (§5) | 13 |
| `lib/features/billing/presentation/pro_tech_screen.dart` (novo), `lib/app/router.dart`, `routes.dart` | `/_pro` | 14 |
| `lib/features/account/domain/account_summary.dart` | `otherSessions` (o `other_sessions` do `my_account`) | 12 |
| `lib/features/billing/data/paywall_counts.dart` (novo) | os números dos marcos, no banco do aparelho | 12 |
| `lib/features/billing/presentation/paywall_home_hook.dart` (novo), `lib/app/router.dart` | o gancho da Início (envolve a `HomeScreen` na rota, sem mudar a tela) | 12 |
| `test/features/billing/**` (novos), `test/features/account/privacy_free_test.dart` | a prova do app | 7–15 |
| `test/integracao/pro_test.dart` (novo) | o "conferir agora" de verdade | 16 |
| `tools/medicao/tmp/g22/` (fora do git) | o emulador e o roteiro da prova | 17 |
| `docs/design/estados_sem_design.md`, `docs/progresso/G22.md` | os textos sem prancha; a prova | 13, 18 |

---

## G22.1 — Servidor

### Tarefa 1: os testes da migração (RED)

**Arquivo:** `supabase/tests/database/26_pro_g22.test.sql` (novo).

- [ ] **Passo 1:** escrever o teste:

```sql
-- G22.1 — o servidor do Pro (docs/progresso/G22.md §1): as contas de teste (só o service_role), o aviso de sandbox no
-- e-mail do dia (D-48), o other_sessions do my_account (R7) e a cota do "conferir agora".
begin;
create extension if not exists pgtap with schema extensions;
select plan(14);

create function pg_temp.conta(n integer) returns uuid language sql immutable as $$
  select ('00000000-0000-7000-8000-0000000d' || lpad(n::text, 4, '0'))::uuid
$$;
insert into auth.users (id, email)
select pg_temp.conta(n), 'pro' || n || '@g22.teste' from generate_series(1, 3) n;
insert into private.moderators (user_id) values (pg_temp.conta(3));
create function pg_temp.sub(u uuid, env text, tid text) returns void language sql as $$
  insert into billing.subscriptions (user_id, store, product_id, period_type, status, will_renew,
    current_period_starts_at, current_period_ends_at, original_transaction_id, environment, last_event_at)
  values (u, 'test_store', 'booknest_pro_mensal', 'trial', 'active', true, now(), now() + interval '7 days', tid, env,
    now())
$$;

-- ------------------------------------------------------------ as contas de teste
select has_table('private', 'billing_test_accounts', 'a lista de contas de teste existe');
select is((select count(*)::int from information_schema.role_table_grants
            where table_schema = 'private' and table_name = 'billing_test_accounts'
              and grantee in ('anon', 'authenticated')), 0, 'só o service_role mexe na lista');

-- ------------------------------------------------------------ o aviso de sandbox no e-mail do dia (D-48)
-- o teste não depende do que a semente ou outro arquivo deixou (tudo volta no rollback)
delete from billing.subscriptions where environment = 'sandbox';
delete from private.email_outbox where template = 'moderation_digest';
select is(private.queue_moderation_digest(), 0, 'sem denúncia e sem sandbox: nenhum e-mail');

select pg_temp.sub(pg_temp.conta(1), 'sandbox', 'teste-1');
insert into private.billing_test_accounts (user_id, note) values (pg_temp.conta(1), 'revisão');
select is(private.queue_moderation_digest(), 0, 'sandbox de conta de teste não avisa');

select pg_temp.sub(pg_temp.conta(2), 'sandbox', 'comum-2');
select is(private.queue_moderation_digest(), 1, 'sandbox de conta comum: um e-mail para quem modera');
select is((select payload ->> 'sandbox_accounts' from private.email_outbox
            where template = 'moderation_digest' order by created_at desc limit 1), '1',
  'o e-mail diz quantas contas, não quais');
select is((select payload ->> 'open' from private.email_outbox
            where template = 'moderation_digest' order by created_at desc limit 1), '0',
  'e que não há denúncia aberta');
select ok((select payload::text not like '%' || pg_temp.conta(2)::text || '%' from private.email_outbox
            where template = 'moderation_digest' order by created_at desc limit 1), 'o id da conta não vai no e-mail');

update billing.subscriptions set updated_at = now() - interval '25 hours' where original_transaction_id = 'comum-2';
delete from private.email_outbox where template = 'moderation_digest';
select is(private.queue_moderation_digest(), 0, 'o sandbox de mais de 24 h já foi avisado');

-- ------------------------------------------------------------ other_sessions (R7)
insert into auth.sessions (id, user_id, created_at, updated_at)
values ('00000000-0000-7000-8000-00000e000001', pg_temp.conta(1), now(), now()),
       ('00000000-0000-7000-8000-00000e000002', pg_temp.conta(1), now(), now());
set local role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.conta(1), 'role', 'authenticated',
  'session_id', '00000000-0000-7000-8000-00000e000001')::text, true);
select is(public.my_account() ->> 'other_sessions', '1', 'uma outra sessão ativa (o 2º aparelho)');
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.conta(2), 'role', 'authenticated',
  'session_id', '00000000-0000-7000-8000-00000e000003')::text, true);
select is(public.my_account() ->> 'other_sessions', '0', 'conta com uma sessão só: nenhuma outra');
reset role;

-- ------------------------------------------------------------ a cota do "conferir agora"
select ok(private.consume_quota(pg_temp.conta(2), 'pro_sync', 30), '1ª chamada do dia passa');
select ok((select bool_and(private.consume_quota(pg_temp.conta(2), 'pro_sync', 30)) from generate_series(1, 29)),
  'até a 30ª passa');
select ok(not private.consume_quota(pg_temp.conta(2), 'pro_sync', 30), 'a 31ª é recusada');

select * from finish();
rollback;
```

- [ ] **Passo 2:** rodar (WSL: reset + `supabase test db supabase/tests/database/26_pro_g22.test.sql`). Esperado:
  FALHA (`private.billing_test_accounts` não existe; `other_sessions` nulo). As 3 da cota já passam (o
  `consume_quota` é da G03 e aceita qualquer chave): ficam como prova da chave `pro_sync`.

### Tarefa 2: a migração (GREEN)

**Arquivo:** `supabase/migrations/<carimbo>_g22_pro.sql` (novo; o carimbo depois de `20261009210000`).

- [ ] **Passo 1:** escrever a migração:

```sql
-- =====================================================================================
-- BookNest · G22 — o Pro (docs/progresso/G22.md §1): as contas de teste da D-48 e o aviso de compra sandbox em conta
-- comum no e-mail do dia; o other_sessions do my_account (o gatilho do 2º aparelho, R7).
-- =====================================================================================

create table private.billing_test_accounts (
  user_id  uuid primary key references auth.users(id) on delete cascade,
  note     text check (char_length(note) <= 200),
  added_at timestamptz not null default now()
);
alter table private.billing_test_accounts enable row level security;
revoke all on private.billing_test_accounts from public, anon, authenticated;
grant all on private.billing_test_accounts to service_role;

-- O e-mail do dia (D-221) passa a sair também quando uma conta comum (fora da lista) tem assinatura sandbox mexida nas
-- últimas 24 h (D-48). O e-mail leva só quantas contas.
create or replace function private.queue_moderation_digest() returns integer
language plpgsql security definer set search_path = '' as $$
declare v_open integer; v_breached integer; v_oldest timestamptz; v_sandbox integer; v_count integer;
begin
  select count(*), count(*) filter (where q.sla_breached), min(q.created_at)
    into v_open, v_breached, v_oldest from private.moderation_queue q;
  select count(distinct s.user_id) into v_sandbox
    from billing.subscriptions s
   where s.environment = 'sandbox' and s.updated_at > now() - interval '24 hours'
     and not exists (select 1 from private.billing_test_accounts t where t.user_id = s.user_id);
  if v_open = 0 and v_sandbox = 0 then return 0; end if;
  insert into private.email_outbox (user_id, template, payload)
  select m.user_id, 'moderation_digest',
         jsonb_build_object('open', v_open, 'breached', v_breached, 'oldest', v_oldest, 'sandbox_accounts', v_sandbox)
    from private.moderators m;
  get diagnostics v_count = row_count;
  return v_count;
end $$;

-- R7: quantas OUTRAS sessões ativas a conta tem (o session_id do JWT é a desta chamada). Nada da outra sessão sai.
create or replace function public.my_account() returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', p.id, 'handle', p.handle, 'display_name', p.display_name, 'visibility', p.visibility,
    'handle_provisional', p.handle ~ '^leitor_[0-9a-f]{12,23}$',
    'age_band', (select a.band from private.account_age a where a.user_id = p.id),
    'pro', private.user_is_pro(p.id),
    'other_sessions', (select count(*) from auth.sessions s
                        where s.user_id = p.id
                          and s.id is distinct from nullif((select auth.jwt()) ->> 'session_id', '')::uuid
                          and (s.not_after is null or s.not_after > now())))
  from public.profiles p
  where p.id = (select auth.uid())
$$;

revoke execute on function private.queue_moderation_digest() from public, anon, authenticated;
grant execute on function private.queue_moderation_digest() to service_role;
revoke execute on function public.my_account() from public, anon;
grant execute on function public.my_account() to authenticated, service_role;
```

  O `my_account` só foi escrito em `20261004201216_conta_e_idade.sql` (conferido: nenhuma migração depois o mudou); a
  versão acima é aquela mais o `other_sessions`. O `queue_moderation_digest` parte do da G21
  (`20261009190000_g21_moderacao_termos.sql`), com o mesmo agendamento (`booknest-moderacao-diaria`, que não muda).
  Conferir as colunas de `auth.sessions` no Postgres local (`\d auth.sessions`) antes de rodar: `not_after` existe
  no Auth atual; se não existir, tirar a condição e registrar em `G22.md`.

- [ ] **Passo 2:** rodar o `26` e a suíte inteira. Esperado: verde. O `14_conta_e_idade` lê campo a campo (não muda).
  O `90_privilegios` confere o esquema `private` inteiro: se ele listar tabelas, a nova entra na lista.
- [ ] **Passo 3:** `supabase db advisors` sem achados novos.
- [ ] **Passo 4:** commit `feat(servidor): as contas de teste, o aviso de sandbox e as outras sessões (G22.1)`.

### Tarefa 3: o modelo do e-mail (RED → GREEN)

**Arquivos:** `supabase/functions/email-sender/modelos.ts`, `handler_test.ts` (ou o teste dos modelos que já existe).

- [ ] **Passo 1:** os testes:
  - `{open: 2, breached: 1, sandbox_accounts: 0}` → o texto de hoje, sem linha de sandbox;
  - `{open: 0, breached: 0, sandbox_accounts: 3}` → assunto "3 contas comuns com compra de teste" e o texto
    "Nenhuma denúncia aberta.\n3 contas comuns tiveram compra de teste (sandbox) nas últimas 24 h. Confira se são
    da revisão das lojas e, se forem, coloque-as na lista de contas de teste.";
  - `{open: 1, breached: 0, sandbox_accounts: 1}` → o assunto das denúncias e as duas partes no texto ("1 conta
    comum teve…").
- [ ] **Passo 2:** RED (`deno test supabase/functions/email-sender`).
- [ ] **Passo 3:** no `case 'moderation_digest'`, montar as linhas: as denúncias (como hoje, ou "Nenhuma denúncia
  aberta." com `open = 0`) e, com `sandbox_accounts > 0`, a linha do sandbox (singular/plural). O assunto é o das
  denúncias quando `open > 0`; senão, o do sandbox.
- [ ] **Passo 4:** GREEN; `deno fmt --check`, `deno lint`. Commit `feat(email): o aviso de sandbox no e-mail do dia
  (G22.1, D-48)`.

### Tarefa 4: a Edge Function `revenuecat-sync` (RED → GREEN)

**Arquivos:** `supabase/functions/revenuecat-sync/handler.ts`, `handler_test.ts`, `index.ts` (novos);
`supabase/config.toml`.

- [ ] **Passo 1:** os testes (`handler_test.ts`), no padrão do `export-data`:

```ts
import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler, type Dependencias } from './handler.ts';

const USUARIO = '00000000-0000-7000-8000-00000000000a';
const ASSINANTE = {
  subscriptions: {
    booknest_pro_mensal: {
      store: 'test_store',
      purchase_date: '2026-10-09T12:00:00Z',
      expires_date: '2099-01-01T00:00:00Z',
      period_type: 'trial',
      is_sandbox: true,
    },
  },
};

function fakes(sobrescrever: Partial<Dependencias> = {}) {
  const chamadas: string[] = [];
  const d: Dependencias = {
    verificarJwt: (jwt) => Promise.resolve(jwt === 'jwt-valido' ? USUARIO : null),
    cota: (u) => {
      chamadas.push(`cota:${u}`);
      return Promise.resolve(true);
    },
    assinante: (u) => {
      chamadas.push(`assinante:${u}`);
      return Promise.resolve(ASSINANTE);
    },
    aplicar: (u, subs) => {
      chamadas.push(`aplicar:${u}:${subs.length}:${subs[0]?.environment}`);
      return Promise.resolve({ pro: true, active_until: '2099-01-01T00:00:00+00:00' });
    },
    agora: () => Date.parse('2026-10-09T12:00:01Z'),
    ...sobrescrever,
  };
  return { handler: criarHandler(d), chamadas };
}

const pedido = (jwt?: string, metodo = 'POST') =>
  new Request('http://local/revenuecat-sync', {
    method: metodo,
    headers: jwt ? { Authorization: `Bearer ${jwt}` } : {},
  });

Deno.test('sem sessão ou com sessão inválida → 401, sem ir ao RevenueCat', async () => {
  const { handler, chamadas } = fakes();
  assertEquals((await handler(pedido())).status, 401);
  assertEquals((await handler(pedido('outro'))).status, 401);
  assertEquals(chamadas, []);
});

Deno.test('só POST', async () => {
  const { handler } = fakes();
  assertEquals((await handler(pedido('jwt-valido', 'GET'))).status, 405);
});

Deno.test('aplica o estado da PRÓPRIA conta e devolve o Pro', async () => {
  const { handler, chamadas } = fakes();
  const r = await handler(pedido('jwt-valido'));
  assertEquals(r.status, 200);
  assertEquals(await r.json(), { pro: true, active_until: '2099-01-01T00:00:00+00:00' });
  assertEquals(chamadas, [`cota:${USUARIO}`, `assinante:${USUARIO}`, `aplicar:${USUARIO}:1:sandbox`]);
});

Deno.test('acima da cota do dia → 429, sem ir ao RevenueCat', async () => {
  const { handler, chamadas } = fakes({ cota: () => Promise.resolve(false) });
  assertEquals((await handler(pedido('jwt-valido'))).status, 429);
  assertEquals(chamadas.filter((c) => c.startsWith('assinante')), []);
});

Deno.test('o RevenueCat fora do ar → 502 (o app tenta de novo), nada aplicado', async () => {
  const { handler, chamadas } = fakes({ assinante: () => Promise.reject(new Error('RevenueCat respondeu 503')) });
  assertEquals((await handler(pedido('jwt-valido'))).status, 502);
  assertEquals(chamadas.filter((c) => c.startsWith('aplicar')), []);
});

Deno.test('a conta que não existe mais no app (unknown_user) → 404', async () => {
  // o que o banco levanta de verdade: `raise exception 'unknown_user' using errcode = 'P0001'` (revisao_g04)
  const e = Object.assign(new Error('unknown_user'), { code: 'P0001' });
  const { handler } = fakes({ aplicar: () => Promise.reject(e) });
  assertEquals((await handler(pedido('jwt-valido'))).status, 404);
});

Deno.test('assinante sem assinatura: aplica a lista vazia (tira o Pro)', async () => {
  const { handler, chamadas } = fakes({
    assinante: () => Promise.resolve({ subscriptions: {} }),
    aplicar: (u, subs) => {
      chamadas.push(`aplicar:${u}:${subs.length}`);
      return Promise.resolve({ pro: false, active_until: null });
    },
  });
  const r = await handler(pedido('jwt-valido'));
  assertEquals(await r.json(), { pro: false, active_until: null });
});
```

  O `codigoDoBanco` do `_shared/http.ts` devolve a mensagem para `P0001`, `22023` e `28000`: com o `unknown_user`
  devolve `'unknown_user'`.

- [ ] **Passo 2:** RED (`deno test supabase/functions/revenuecat-sync`).
- [ ] **Passo 3:** `handler.ts`:

```ts
// Edge Function `revenuecat-sync` ("conferir agora", D-229 — docs/progresso/G22.md §1): com a sessão da pessoa,
// busca o estado DELA na API do RevenueCat e aplica pelo mesmo SQL do webhook (private.rc_apply_subscriber), com a
// hora da busca (um estado mais velho que o último aplicado é ignorado pelo banco). Até 30 por dia por conta.
import { usuarioDoPedido } from '../_shared/auth.ts';
import { codigoDoBanco, erro, exigeMetodo, json } from '../_shared/http.ts';
import { type Assinatura, type AssinaturaRc, normalizarAssinante } from '../revenuecat-webhook/revenuecat.ts';

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  cota(userId: string): Promise<boolean>;
  assinante(appUserId: string): Promise<{ subscriptions?: Record<string, AssinaturaRc> } | null>;
  aplicar(
    userId: string,
    assinaturas: Assinatura[],
    buscadoEm: Date,
  ): Promise<{ pro: boolean; active_until: string | null }>;
  agora?: () => number;
};

export function criarHandler(d: Dependencias) {
  const agora = d.agora ?? Date.now;
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    const usuario = await usuarioDoPedido(req, d.verificarJwt);
    if (!usuario) return erro(401, 'nao_autenticado');
    if (!(await d.cota(usuario))) return erro(429, 'limite_diario');
    const buscadoEm = new Date(agora());
    let assinante;
    try {
      assinante = await d.assinante(usuario);
    } catch {
      return erro(502, 'revenuecat_indisponivel');
    }
    try {
      const r = await d.aplicar(usuario, normalizarAssinante(assinante, agora()), buscadoEm);
      return json(200, { pro: r.pro, active_until: r.active_until });
    } catch (e) {
      if (codigoDoBanco(e) === 'unknown_user') return erro(404, 'conta_inexistente');
      return erro(500, 'falha_ao_aplicar');
    }
  };
}
```

  `index.ts`: o `verificarJwt` do `_shared/supabase.ts`; a cota por `select private.consume_quota(${u}, 'pro_sync',
  30)`; o `assinante` igual ao do webhook (`GET /v1/subscribers/{id}`, `REVENUECAT_API_KEY`, 5 s); o `aplicar` por
  `select private.rc_apply_subscriber(${u}, ${json}, now(), ${buscadoEm}) as estado`. O retorno já é o
  `public.entitlement_of(u)`, `{pro, active_until}` (com `stale: true` quando o estado buscado é mais velho que o
  último aplicado: o handler devolve só `pro` e `active_until`, que são os atuais do banco).
- [ ] **Passo 4:** `config.toml`: `[functions.revenuecat-sync]` com `verify_jwt = true` (depois do webhook).
- [ ] **Passo 5:** GREEN; `deno fmt --check`, `deno lint`, `deno check */index.ts`. Commit
  `feat(pro): o "conferir agora" no servidor (G22.1, D-229)`.

### Tarefa 5: a matriz do webhook (Anexo 04 §9)

**Arquivo:** `supabase/functions/revenuecat-webhook/revenuecat_test.ts` (e `handler_test.ts` onde for do fluxo).

- [ ] **Passo 1:** um teste por caso, com o estado que a API do RevenueCat devolveria (o `normalizarAssinatura` é
  puro; o fluxo usa os dublês do `handler_test`):
  - compra mensal e anual (`period_type: normal`, `active`, `will_renew`);
  - teste grátis (`period_type: trial`);
  - cancelar (`unsubscribe_detected_at` → `cancelled`, sem renovar, ainda dentro do período);
  - expirar (`expires_date` no passado → `expired`);
  - carência (`grace_period_expires_date` no futuro com `expires_date` vencido → `in_grace_period`,
    `grace_ends_at`);
  - nova tentativa de cobrança (`billing_issues_detected_at`, não vencida → `in_billing_retry`);
  - trocar mensal → anual (evento `PRODUCT_CHANGE`; dois produtos no assinante: o mensal `cancelled`/`expired` e o
    anual `active`);
  - reembolso (evento `CANCELLATION` com `refunded_at` → `refunded`);
  - Test Store (`store: test_store`, `is_sandbox: true` → `environment: sandbox`);
  - a loja que o BookNest não vende (`stripe`) → ignorada;
  - restaurar em outro aparelho, a mesma conta (evento `RENEWAL`/`INITIAL_PURCHASE` repetido para o mesmo
    `app_user_id`): o mesmo estado, nenhuma linha nova;
  - restaurar noutra conta (`TRANSFER`): as duas contas buscadas e aplicadas (já existe: conferir e manter);
  - o evento de teste do painel (`TEST`): 200, sem buscar assinante nem aplicar (já existe:
    `handler_test.ts`, "evento de teste do painel…");
  - duplicado e fora de ordem: já existem ("evento repetido…", "a hora da busca…").

  Hoje são 19 testes (12 no `handler_test`, 7 no `revenuecat_test`). Os casos novos: compra mensal e anual
  (`period_type: normal`), Test Store, trocar mensal → anual, restaurar na mesma conta, e o teste grátis do Play
  (o que existe é o da App Store). Cada um no arquivo do assunto: o estado puro no `revenuecat_test`, o fluxo do
  evento no `handler_test`.
- [ ] **Passo 2:** rodar. Os casos que já passam ficam como prova; um que falhar é uma lacuna: corrigir o
  `revenuecat.ts` com o teste vermelho antes, e registrar em `G22.md`.
- [ ] **Passo 3:** commit `test(webhook): a matriz do Anexo 04 §9 (G22.1)`.

---

## G22.2 — App: a camada de compra

### Tarefa 6: o SDK no projeto

**Arquivos:** `pubspec.yaml`, `android/app/build.gradle(.kts)`, `android/app/src/main/AndroidManifest.xml`.

- [ ] **Passo 1:** `purchases_flutter: 10.14.0` e `url_launcher: 6.3.2` (versões exatas).
- [ ] **Passo 2:** o Android, pelo que o projeto já tem:
  - `minSdk = flutter.minSdkVersion` (o do Flutter 3.47 passa do mínimo do SDK, 21): não muda;
  - `android:launchMode="singleTop"` na `MainActivity`: é um dos dois que o RevenueCat pede (`standard` ou
    `singleTop`), para a compra não ser cancelada quando o app vai ao segundo plano: não muda;
  - `MainActivity : FlutterActivity`: só o `purchases_ui_flutter` (as telas prontas do RevenueCat, que não entram)
    exige `FlutterFragmentActivity`: não muda. A permissão `com.android.vending.BILLING` vem do manifest do SDK;
  - conferir estes três pontos no README e no CHANGELOG da 10.14.0 (pub.dev) antes de seguir; se algum mudar, mudar
    aqui com os testes nativos da G20 (`restauracao_nativa_test`, `orientacao_nativa_test`).
- [ ] **Passo 3:** `flutter pub get`, `flutter analyze`, a suíte do app verde e `flutter build apk --debug` (prova de
  que o Gradle aceita). Commit `build(pro): o SDK do RevenueCat (G22.2)`.

### Tarefa 7: o domínio e as regras (RED → GREEN)

**Arquivos:** `lib/features/billing/domain/billing_models.dart`, `billing_rules.dart`;
`test/features/billing/billing_rules_test.dart`.

Tipos:
- `enum ProPeriod { month, year }`;
- `ProPackage({id, period, priceString, price, currencyCode, trialDays})` — `trialDays` só quando elegível;
- `ProCustomer({active, activeUntil, willRenew, billingIssue, graceUntil, managementUrl, store, sandbox})` e
  `ProCustomer.none`;
- `sealed class PurchaseOutcome`: `Purchased(ProCustomer)`, `PurchaseCancelled()`, `PurchasePending()`;
- `sealed class BillingFailure`: `BillingOffline`, `StoreUnavailable`, `AlreadySubscribed`, `PurchaseNotAllowed`,
  `BillingNeedsAccount`, `BillingUnknown(code)`.

Regras (funções puras):
- `annualSavingsPercent(ProPackage month, ProPackage year)` → `int?` (R4: `floor((12·m − a) / (12·m) · 100)`; nulo
  com moedas diferentes ou preço ≤ 0);
- `trialLine(ProPackage p)` → `"7 dias grátis, depois R$ 9,99/mês"` ou nulo (R4);
- `proStatusLine(ProCustomer c, {required DateTime now})` → os textos da §3 (`dd/MM/yyyy`; carência "até 15/11");
- `localProValid(ProCustomer c, DateTime now)` → R8 (`activeUntil + 3 dias`);
- `manageInstruction(TargetPlatform p)` → R6.

- [ ] **Passo 1:** os testes, um por caso:
  - R4: mensal R$ 9,99 e anual R$ 79,99 → 33 %; moedas diferentes → nulo; anual mais caro → nulo;
  - R4: teste de 7 dias → "7 dias grátis, depois R$ 9,99/mês"; anual → "…/ano"; sem teste → nulo;
  - §3: os 4 estados (renova, desligada, carência, Grátis) com a data no fuso do aparelho;
  - R8: válido até `activeUntil + 3 dias`, inválido depois; `ProCustomer.none` nunca;
  - R6: Android e iOS.
- [ ] **Passo 2:** RED → **Passo 3:** o código → **Passo 4:** GREEN. Commit
  `feat(pro): o domínio e as regras da compra (G22.2)`.

### Tarefa 8: o gateway (RED → GREEN)

**Arquivos:** `lib/features/billing/data/billing_gateway.dart`, `revenuecat_gateway.dart`;
`test/features/billing/revenuecat_gateway_test.dart`.

Interface:

```dart
abstract interface class BillingGateway {
  Future<void> configure({required String appUserId});
  Future<ProCustomer> logIn(String appUserId);
  Future<void> logOut();
  /// Os pacotes da offering `default` (`$rc_monthly`, `$rc_annual`), com o teste só se elegível.
  Future<List<ProPackage>> packages();
  Future<PurchaseOutcome> purchase(String packageId);
  Future<ProCustomer> restore();
  Future<ProCustomer> customer();
  Stream<ProCustomer> customerUpdates();
}
```

`RevenueCatGateway`: o SDK atrás de uma fina camada (`PurchasesApi`, as chamadas estáticas do `Purchases.*` num
objeto), para o teste trocar o SDK por um falso sem plataforma:
- `CustomerInfo` → `ProCustomer`: o entitlement `pro` (`entitlements.active['pro']`), `expirationDate`,
  `willRenew`, `billingIssueDetectedAt`, o fim da carência (do `EntitlementInfo`, se a 10.14.0 expõe; senão,
  `activeUntil` vale a carência que o servidor calcula), `managementURL`, `store`, `isSandbox`;
- `PlatformException` → `BillingFailure` pelo `PurchasesErrorHelper.getErrorCode`:
  `purchaseCancelledError` → `PurchaseCancelled` (não é falha), `paymentPendingError` → `PurchasePending`,
  `networkError`/`offlineConnectionError` → `BillingOffline`, `storeProblemError` → `StoreUnavailable`,
  `productAlreadyPurchasedError` → `AlreadySubscribed`, `purchaseNotAllowedError` → `PurchaseNotAllowed`, o resto →
  `BillingUnknown(name)`;
- os pacotes: `offerings.current ?? offerings.all['default']`, só `$rc_monthly` e `$rc_annual`; a elegibilidade
  por `checkTrialOrIntroductoryPriceEligibility`.

- [ ] **Passo 1:** os testes com o `PurchasesApi` falso (os objetos do SDK montados com `fromJson`): a tradução do
  `CustomerInfo` (ativo, cancelado, carência, sem entitlement), de cada erro, dos pacotes (sem offering → lista vazia;
  o pacote vitalício ignorado), a elegibilidade.
- [ ] **Passo 2:** RED → **Passo 3:** o código → **Passo 4:** GREEN. Commit
  `feat(pro): o gateway do RevenueCat (G22.2)`.

### Tarefa 9: o servidor do Pro no app (RED → GREEN)

**Arquivos:** `lib/features/billing/data/pro_server_api.dart`; `test/features/billing/pro_server_api_test.dart`.

```dart
abstract interface class ProServerApi {
  /// O "conferir agora" (D-229): `revenuecat-sync`. Devolve o Pro do servidor.
  Future<ServerPro> syncNow();
  /// `my_entitlement`: o que o servidor sabe agora.
  Future<ServerPro> current();
}
typedef ServerPro = ({bool pro, DateTime? activeUntil});
```

`SupabaseProServerApi`: `functions.invoke('revenuecat-sync')` e `rpc('my_entitlement')`, pelo `socialCall` da G21
(sessão, tempo, falhas). `FunctionException` → 401 `SocialNeedsAccount`, 429 e 502 `SocialOffline` (tentar de
novo), o resto `SocialUnexpected('fn_<status>')`.

- [ ] **Passo 1:** os testes com o `FakeBackend` da conta (`test/features/account/support/fake_backend.dart`): a
  resposta 200 com e sem Pro, 401, 429, 502, sem rede; o `my_entitlement`.
- [ ] **Passo 2:** RED → **Passo 3:** o código → **Passo 4:** GREEN. Commit
  `feat(pro): o servidor do Pro no app (G22.2)`.

---

## G22.3 — O estado do Pro e os fluxos

### Tarefa 10: o `BillingController` — conta e estado (R1, R2, R8)

**Arquivos:** `lib/features/billing/application/billing_controller.dart`, `billing_providers.dart`;
`test/features/billing/billing_controller_test.dart`.

Estado:

```dart
sealed class ProView {}
final class ProUnavailable extends ProView {}          // sem chave/servidor, ou convidado (R1)
final class ProLoading extends ProView {}
final class ProReady extends ProView {
  ProReady({required this.customer, required this.serverPro, this.activating = false, this.notice});
  final ProCustomer customer;   // o da loja (a tela)
  final bool serverPro;         // o do servidor (o sync)
  final bool activating;        // "Ativando o Pro…" (R2)
  final String? notice;         // a pílula da última ação (R3, R5)
}
```

Encaixe:
- o `AppEnv` ganha `revenuecatKeyAndroid` e `revenuecatKeyIos` (`String.fromEnvironment` das duas chaves que o
  modelo do env já tem; `<…>` conta como vazio, pelo `_filled` que já existe);
- `billingGatewayProvider`: nulo sem `REVENUECAT_PUBLIC_KEY_*` (o env), no Windows e nos testes; nulo também em
  build de produção com chave `test_` (registra o motivo). A escolha é uma função pura,
  `billingKeyFor({required String android, required String ios, required TargetPlatform platform, required bool
  release})` → a chave ou nulo, para o teste cobrir o build de produção sem compilar um;
- o controller ouve o `accountControllerProvider`: `MemberView(userId)` → `configure`/`logIn(userId)`; trocou o
  `userId` → `logIn(novo)`; virou `GuestView` → `logOut` e `ProUnavailable`;
- `serverPro` vem do `summary.pro` da `MemberView`; quando o da loja é Pro e o do servidor não → R2 (abaixo);
- R2: `activating = true`, `syncNow()`; depois `current()` com recuo 1, 2, 4, 8, 16, 29 s (relógio injetado);
  confirmado → `AccountController.refresh()` (relê o resumo; o sync liga pela G06) e `activating = false`; não
  confirmou → a pílula "O Pro ainda não chegou ao servidor. A sincronização liga assim que ele confirmar." e outra
  tentativa no próximo `resumed` do app;
- `customerUpdates()` atualiza o `customer` (renovação, cancelamento);
- trocar de conta no meio (D-68): a ativação da conta antiga para (o `userId` conferido antes de cada passo).

- [ ] **Passo 1:** os testes com o `BillingGateway` e o `ProServerApi` falsos e um relógio de mentira:
  - convidado: nada configurado, `ProUnavailable`;
  - entrar: `logIn(id)` com o id do Supabase; trocar: `logIn(outro)`; sair: `logOut`;
  - a loja Pro e o servidor Grátis → `activating`, `syncNow`, o recuo até confirmar, `refresh()` uma vez;
  - nunca confirma → para em ≈ 60 s com a pílula; tenta de novo ao voltar ao app;
  - a conta troca durante a ativação → nada da antiga segue;
  - `customerUpdates` com cancelamento → o estado muda;
  - sem gateway (sem chave) → `ProUnavailable` e nenhuma chamada;
  - `billingKeyFor`: Android/iOS pela plataforma; vazio ou `<…>` (o modelo do env) → nulo; Windows → nulo;
    `release: true` com `test_…` → nulo; `release: false` com `test_…` → a chave.
- [ ] **Passo 2:** RED → **Passo 3:** o código → **Passo 4:** GREEN. Commit
  `feat(pro): o estado do Pro e a ativação (G22.3, R1, R2, R8)`.

### Tarefa 11: comprar, restaurar e gerenciar (R3, R5, R6)

**Arquivos:** `billing_controller.dart`; `test/features/billing/billing_actions_test.dart`.

- `purchase(ProPackage)`: convidado → "Entrar para assinar." (R1); `Purchased` → R2; `PurchaseCancelled` →
  sem pílula; `PurchasePending` → "Pagamento em análise. O Pro liga quando a loja aprovar."; `BillingOffline` →
  "Sem conexão. Tente de novo."; `AlreadySubscribed` → `restore()`; o resto → "Não deu certo. Tente de novo.";
- `restore()`: com Pro → R2 e "Compras restauradas."; sem → "Nenhuma assinatura encontrada nesta conta da loja.";
- `manage()`: a `managementUrl` pelo `url_launcher` (externo); sem ela, a instrução da R6 na pílula;
- uma ação por vez (o botão repetido não compra duas vezes).

- [ ] **Passo 1:** os testes de cada caso acima e o toque duplo. **Passo 2:** RED → **Passo 3:** o código →
  **Passo 4:** GREEN. Commit `feat(pro): comprar, restaurar e gerenciar (G22.3, R3, R5, R6)`.

---

## G22.4 — Os gatilhos

### Tarefa 12: `PaywallTriggers` (R7)

**Arquivos:**
- `lib/features/billing/application/paywall_triggers.dart` (o motor);
- `lib/features/billing/data/paywall_counts.dart` (os números dos marcos);
- `lib/features/billing/presentation/paywall_home_hook.dart` (o gancho) e `lib/app/router.dart` (a rota da Início
  passa a ser `PaywallHomeHook(child: HomeScreen())`; a `HomeScreen` não muda, nem os goldens dela);
- `lib/features/account/domain/account_summary.dart` (`otherSessions`, lido de `other_sessions`; ausente → 0, para
  o servidor antigo);
- `lib/features/billing/application/billing_controller.dart` (o 2º aparelho, abaixo);
- testes: `test/features/billing/paywall_triggers_test.dart`, `paywall_counts_test.dart`,
  `paywall_home_hook_test.dart`; o `account_summary` ganha o caso do `other_sessions` no teste que já existe.

```dart
enum PaywallReason { books10, highlights50, streak30, secondDevice, otherProfile, secondClub, fullStats }

final class PaywallTriggers {
  PaywallTriggers({required KvDao kv, required DateTime Function() now});
  /// Os espontâneos: os marcos ao mostrar a Início e o 2º aparelho ao entrar. Nulo = nada a mostrar.
  Future<PaywallReason?> onHomeShown(String owner, {required int books, required int highlights,
      required int streakDays, required bool pro});
  Future<PaywallReason?> onSignedIn(String owner, {required int otherSessions, required bool pro});
  /// Os de toque: sempre (fora do limite), menos para o Pro.
  PaywallReason? onTap(PaywallReason reason, {required bool pro});
  Future<void> shown(String owner, PaywallReason reason);   // grava o marco e a data (por dono)
  Future<void> resetForTests(String owner);                 // só a tela técnica usa
}
```

- as chaves no `local_kv`: `pro.gatilho.<dono>.ultimo` (a data do último espontâneo) e
  `pro.gatilho.<dono>.<motivo>` (o marco já mostrado);
- os números dos marcos (`PaywallCounts.of(owner)` → `({int books, int highlights, int streakDays})`), no banco do
  aparelho:
  - livros: `user_books` da conta com `deleted_at IS NULL` (na estante, lidos ou não);
  - grifos: `annotations` da conta com `kind = 'highlight'` e `deleted_at IS NULL`, contados por `group_id` (um
    grifo que atravessa páginas conta uma vez);
  - a sequência: a da Início (o mesmo caminho do `statsPublisherProvider` da G21: o `snapshot` do
    `SyncHomeRepository` ou o 1º valor do `watch`);
- `pro` para o motor = o do servidor (`summary.pro`) **ou** o da loja ainda válido sem rede (`localProValid`, R8);
- quem mostra: `paywallPresenterProvider` (`void Function(PaywallReason)`). Em depuração, abre
  `/_pro?motivo=<nome>`; no build de produção, não faz nada (D-230). O teste injeta o `debug`;
- o gancho da Início (`PaywallHomeHook`): uma vez por montagem, com a Início em dados e uma conta (`MemberView`),
  chama `onHomeShown`; com motivo, `shown` e o presenter. Nunca no leitor nem na 25: o gancho só envolve a Início;
- o 2º aparelho: nesta tarefa, o `BillingController` (da Tarefa 10) passa a chamar `onSignedIn` ao ver uma
  `MemberView` nova (entrar ou trocar de conta), com o `otherSessions` do resumo; com motivo, `shown` e o presenter
  (o teste no `billing_controller_test`: Grátis com `otherSessions = 1` → o presenter recebe `secondDevice`; Pro ou
  0 → nada).

- [ ] **Passo 1:** os testes:
  - 10 livros → `books10` uma vez; a 2ª vez, nada;
  - dois marcos no mesmo dia → só o 1º; o 2º depois de 7 dias;
  - o limite é por dono (a conta B não herda o limite da A);
  - Pro nunca vê;
  - `onSignedIn` com `otherSessions = 1` e Grátis → `secondDevice`; com 0 → nada;
  - `onTap` ignora o limite de 7 dias; Pro → nada;
  - `PaywallCounts`: livro apagado não conta; outra conta não conta; um grifo em duas páginas (o mesmo `group_id`)
    conta 1; nota e desenho não contam;
  - `AccountSummary.fromJson`: `other_sessions: 2` → 2; ausente → 0;
  - o gancho: em produção (`debug: false` injetado) não navega; em depuração abre `/_pro?motivo=books10`; a 2ª
    montagem no mesmo dia não abre de novo; o convidado não chama o motor.
- [ ] **Passo 2:** RED → **Passo 3:** o código → **Passo 4:** GREEN. Commit
  `feat(pro): os gatilhos do paywall (G22.4, R7)`.

---

## G22.5 — As telas sem prancha

### Tarefa 13: o Pro no Perfil (§5, D-231)

**Arquivos:** `lib/features/account/presentation/pro_rows.dart` (novo), `account_block.dart`;
`test/features/account/pro_rows_test.dart`; `docs/design/estados_sem_design.md`.

- [ ] **Passo 1:** antes de desenhar, ler o bloco da conta e os seus widgets (`account_widgets.dart`): as linhas
  novas usam os mesmos (a borda, a sombra, o texto). Não há prancha (CLAUDE.md): a seção nova do
  `estados_sem_design.md` lista os textos e o que cada estado mostra.
- [ ] **Passo 2:** os testes de widget com o `BillingController` sobrescrito: os 5 textos da §3; "Restaurar
  compras" sempre com conta; "Gerenciar assinatura" só com Pro; "Assinar (tela técnica)" só em depuração; convidado
  sem nada novo; a pílula depois de restaurar.
- [ ] **Passo 3:** RED → **Passo 4:** o código → **Passo 5:** GREEN. Commit
  `feat(pro): o Pro no bloco da conta (G22.5, D-231)`.

### Tarefa 14: a tela técnica `/_pro` (§5)

**Arquivos:** `lib/features/billing/presentation/pro_tech_screen.dart` (novo), `lib/app/router.dart`,
`lib/app/routes.dart` (`static const proTecnico = '/_pro';`); `test/features/billing/pro_tech_screen_test.dart`.

- a rota só existe com `kDebugMode` (como `/_ds`);
- convidado: só "Entrar para assinar." (R1), que leva à entrada da conta;
- conteúdo: o motivo, se veio de um gatilho ("Marco: 10 livros"), com "Agora não" (fecha; o gatilho já foi gravado
  ao abrir); os pacotes com o preço, o período, a economia e o teste (R4); o texto
  obrigatório das lojas antes do botão; os links do env (`TERMS_URL`, `PRIVACY_URL`; vazios → "Publicação pendente
  (Q9).") — as duas chaves entram no `AppEnv` e nos `env/*.example.json`; comprar, restaurar, gerenciar; o estado da
  loja e o do servidor lado a lado; "Conferir agora"; o simulador dos gatilhos (disparar cada um, zerar).

- [ ] **Passo 1:** os testes de widget com os falsos: os dois pacotes com "33 %" e o teste; o texto das lojas; a
  compra chama o controller; os links vazios; o simulador chama o motor; com `?motivo=books10`, "Marco: 10 livros" e
  "Agora não" fecha; o convidado vê só "Entrar para assinar.". **Passo 2:** RED → **Passo 3:** o código →
  **Passo 4:** GREEN. Commit `feat(pro): a tela técnica do Pro (G22.5)`.

### Tarefa 15: a privacidade do Grátis

**Arquivo:** `test/features/account/privacy_free_test.dart`.

- [ ] **Passo 1:** a lista `permitidosG22` (separada, como a da G21), com o motivo: `my_entitlement` e
  `revenuecat-sync` (só depois de comprar/restaurar). Os testes: o convidado e o Grátis sem compra não chamam o
  RevenueCat (o gateway falso conta as chamadas) nem o `revenuecat-sync`; o `my_account` com `other_sessions` não
  muda o que o Grátis manda.
- [ ] **Passo 2:** rodar (vermelho se algo novo chama) → ajustar → verde. Commit
  `test(pro): o que o Grátis manda com a G22 (G22.5)`.

---

## G22.6 — O emulador e a prova de ponta a ponta

### Tarefa 16: a integração com o Supabase local

**Arquivo:** `test/integracao/pro_test.dart` (marca `integracao`).

- a conta entra pelo código do Mailpit (como o `clube_test`);
- sem compra: `revenuecat-sync` devolve `{pro: false}` e nada muda no banco;
- com o estado da Test Store de verdade: depois da compra no emulador (Tarefa 17), o mesmo teste com a conta que
  comprou confirma `{pro: true}` e `billing.entitlements.environment = 'sandbox'` (o teste lê o id da conta de uma
  variável de ambiente, `BOOKNEST_PRO_CONTA`; sem ela, pula esse caso).

- [ ] **Passo 1:** escrever, rodar com `integracao.ps1` (as Edge Functions locais no ar: `supabase functions serve
  --env-file supabase/functions/.env`, ou `supabase stop`/`start`). Commit `test(pro): o "conferir agora" no
  Supabase local (G22.6)`.

### Tarefa 17: o emulador e a compra na Test Store

**Arquivos:** `tools/medicao/tmp/g22/` (fora do git): `emulador.ps1`, `roteiro_compra.md`.

- [ ] **Passo 1:** o emulador: `sdkmanager "system-images;android-35;google_apis_playstore;x86_64"` (a imagem com a
  Play Store, para o fluxo de compra da Test Store abrir), `avdmanager create avd -n booknest_g22 …`,
  `emulator -avd booknest_g22`. Conferir a aceleração (WHPX/HAXM) no Windows; sem ela, registrar e usar a imagem sem
  Play.
- [ ] **Passo 2:** `flutter run -d emulator-5554 --dart-define-from-file=env/dev.json` com o Supabase local no ar.
- [ ] **Passo 3:** a prova (capturas pelo `adb exec-out screencap`):
  1. entrar com uma conta de teste (código do Mailpit);
  2. o Perfil "Plano: Grátis";
  3. `/_pro`: os pacotes da Test Store com o preço, a economia e o teste;
  4. comprar o mensal (a folha da Test Store: "sucesso") → "Ativando o Pro…" → o servidor confirma → o Perfil "Pro
     até …" e o indicador do sync;
  5. comprar o anual com uma 2ª conta de teste;
  6. cancelar na folha da Test Store (uma compra que cancela) e uma que falha;
  7. restaurar depois de reinstalar o app (`adb uninstall` e `flutter run` de novo);
  8. a renovação comprimida (5 min) e a expiração depois de 5 renovações (o Perfil e o servidor);
  9. gerenciar.
- [ ] **Passo 4:** o que a Test Store não fizer (teste grátis, restaurar) vai para `roteiro_compra.md` da G27, com o
  caso coberto pelos payloads (Tarefa 5).

---

## G22.7 — Prova e relatório

### Tarefa 18: prova

- [ ] `dart format`, `flutter analyze` (0), a suíte inteira, `supabase test db`, `deno test` (funções e site),
  a integração inteira.
- [ ] Revisão independente (um agente que não escreveu o código) e as correções com teste.
- [ ] Mutação (`tools/medicao/tmp/mut/g22/`): R1–R8, a tradução das falhas, a migração (o aviso de sandbox, o
  `other_sessions`, a cota).
- [ ] Cobertura ≥ 90 % nos arquivos da fase; gitleaks nos commits e nas pastas.
- [ ] Capturas na conversa (§7); `G22.md` (Resultados, Revisão, Desvios, Pendências, Capturas, a lista fechada);
  `RELATORIO_G22.md` no projeto; "✅ FASE G22 concluída — aguardando sua aprovação para iniciar a FASE G23."
