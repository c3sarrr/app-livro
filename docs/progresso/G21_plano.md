# G21 — Social e clubes: plano de implementação

> **Para quem executa:** execução inline (superpowers:executing-plans), uma tarefa por vez, TDD: o teste falha
> (RED), o código mínimo passa (GREEN), commit pequeno. Passos com `- [ ]`.
> **Plano em duas etapas:** a G21.1 e a G21.2 (servidor) estão com o código completo. A G21.3 a G21.8 (app) estão com
> os arquivos, as assinaturas, as regras e a lista de testes; antes de começar a G21.3, este plano ganha o código
> completo delas (commit `docs(g21): o plano do app detalhado`), lendo o código do app daquele momento.

**Objetivo:** ligar o servidor social (G04–G06) ao app: o núcleo dos dados do clube que as pranchas 04, 31, 32 e
70–73 pedem, o social do prompt mestre, os 4 pontos já desenhados (ticket, faixa, chip, compartilhar), o sininho, a
moderação (D-52) e a Q29.

**Arquitetura:**
- **Servidor (Postgres):** 3 migrações. `g21_clubes_nucleo` (tabelas, gatilhos, políticas, RPCs de escrita e os 6
  resumos), `g21_moderacao_termos` (termos, bloqueio no clube, moderadores, e-mail do dia) e `g21_tempo_real` (avisos
  sem conteúdo em canais privados `club:<id>`). Os resumos são `security definer` em `public`, com `auth.uid()`
  conferido e o `EXECUTE` só para `authenticated` (o padrão da G04: `join_club`, `profile_preview`).
- **Edge Function `moderacao`** (Deno, conexão direta ao Postgres como as outras) + a página `site/moderacao/`.
- **App:** `lib/features/social/` e `lib/features/clubs/` (repositórios, regras puras, cache por dono em
  `social_cache`), ligados aos pontos que já existem por implementações novas das interfaces da G08/G15/G19.

**Pilha:**
- Supabase CLI 2.119, Postgres 17, pgTAP (`supabase test db`), Deno 2.9 (`deno test`);
- Flutter 3.47.2 / Dart 3.13.2, drift, flutter_riverpod 3, supabase_flutter 2.18 (Realtime Broadcast privado).

**Execução e ambiente:**
- Código escrito no espelho `/home/claude/g03/repo` e levado ao Windows por `enviar.py` (zip com nome novo a cada
  envio: o envio pelo mesmo caminho de antes pode levar o arquivo velho) + `tools/medicao/tmp/expandir.ps1`.
- **WSL acordado:** um `wsl.exe -d Ubuntu -u root -- sleep 43200` criado por `Win32_Process.Create` (fora da árvore do
  Desktop Commander). Sem ele, o WSL dorme entre os comandos e o Supabase local reinicia a cada chamada.
- **Servidor:** `tools/medicao/tmp/wsl.ps1 -Nome X -Cmd "..."` (log em `tmp\X.log`, código em `tmp\X.fim`). Cada
  rodada espera o banco (`docker inspect … healthy`), faz `supabase db reset` (saída filtrada: o reset imprime chaves
  locais) e `supabase test db`. Base em 09/10/2026: **21 arquivos, 524 testes verdes** depois do reset.
- **Arquivo incluído no pgTAP:** `\ir _mundo_clube.psql` funciona (a sonda passou): o `supabase test db` monta a pasta
  `supabase/tests/database/` e só roda os `*.test.sql`.
- **App:** `dart format`, `flutter analyze` e `flutter test <arquivo>` no Windows por `rodar.ps1`; integração por
  `integracao.ps1` (marca `integracao`).
- Commits pequenos: `msg_g21_NN.txt` + `commits_g21<letra>.ps1` (`novo_commit21.sh`), mensagem `tipo(escopo):
  descrição` em português com o rodapé `Co-Authored-By` e `Claude-Session`; leituras do git com
  `git --no-optional-locks`; nenhum `index.lock` fica.
- Spec: `docs/progresso/G21.md` (D-211…D-227, R1…R12), citada por §1…§7. Branch `feat/g21-social-clubes`, base
  `f553eb5` (a spec é o `573f5e7`; os arquivos do design, o `05502ab`).

**Ajuste da spec feito neste plano:** o `publish_progress` não leva a página (R9 e §1): o servidor não usa a página
publicada (o spoiler usa a do aparelho, R8; "Fala da pág. 201" é a página gravada na resposta). Menos dado pessoal
fora do aparelho. A spec é atualizada no commit do plano.

## Arquivos

| Arquivo | Responsabilidade | Tarefa |
|---|---|---|
| `supabase/tests/database/21_clubes_nucleo.test.sql` (novo) | tabelas, gatilhos, políticas e RPCs de escrita | 2–4 |
| `supabase/migrations/<carimbo>_g21_clubes_nucleo.sql` (novo) | §1: o núcleo do clube | 3–6 |
| `supabase/tests/database/_mundo_clube.psql` (novo) | o mundo das pranchas (seed de teste) | 5 |
| `supabase/tests/database/22_clubes_resumos.test.sql` (novo) | os 6 resumos, as relações e o bloqueio | 5–6 |
| `supabase/tests/database/03_clubes`, `10_politicas`, `90_privilegios` | colunas que saíram, políticas e privilégios novos | 7 |
| `tools/supabase/medir_clube.sql` (novo) | `EXPLAIN` dos resumos num clube grande | 7 |
| `supabase/migrations/<carimbo>_g21_moderacao_termos.sql` (novo) | termos, bloqueio no clube, moderadores, e-mail do dia | 8–9 |
| `supabase/tests/database/23_moderacao_termos.test.sql` (novo) | idem | 8–9 |
| `supabase/migrations/<carimbo>_g21_tempo_real.sql` + `24_tempo_real.test.sql` (novos) | avisos `club:<id>` | 10 |
| `supabase/functions/moderacao/` (novo), `email-sender/modelos.ts` | a função do painel; o modelo do e-mail | 11 |
| `site/moderacao/` (novo) | a página do painel | 12 |
| `lib/features/social/**`, `lib/features/clubs/**` (novos) | repositórios, regras, cache, pontos | 13–24 |
| `lib/features/home/presentation/covers/book_cover.dart` | Q29 | 25 |
| `docs/progresso/G21.md`, `RELATORIO_G21.md` | prova e relatório | 26 |

---

## G21.1 — Servidor: o núcleo do clube

### Tarefa 1: preparar

- [ ] **Passo 1:** a spec sem a página no `publish_progress` (§1, a linha do `publish_progress`; R9: "a fração e o
  capítulo"). Commit junto com este plano: `docs(g21): o plano de implementação e o progresso sem a página`.
- [ ] **Passo 2:** o WSL acordado e a base verde (`supabase db reset` + `supabase test db`: 21 arquivos, 524 testes).

### Tarefa 2: os testes do núcleo (RED)

**Arquivo:** `supabase/tests/database/21_clubes_nucleo.test.sql` (novo)

- [ ] **Passo 1:** escrever o teste:

```sql
-- G21.1 — o núcleo do clube (docs/progresso/G21.md §1): o livro em semanas, um encontro por semana, a presença com
-- recado, as perguntas na ordem da anfitriã, as respostas em um nível, as curtidas, a cor de cada leitora, o
-- progresso publicado, o grifo compartilhado e as permissões (cada caso permitido com o negado ao lado).
begin;
create extension if not exists pgtap with schema extensions;
select plan(62);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-0000000000a1', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000b2', 'julia@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000c3', 'caio@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000d4', 'rafa@exemplo.com');
insert into private.account_age (user_id, band, source)
select id, '18_plus', 'birthdate' from auth.users on conflict (user_id) do nothing;
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-0000000000a1', 'pro', now() + interval '27 days');
insert into catalog.works (id, title) values ('00000000-0000-7000-8000-00000000e001', 'Dom Casmurro');
insert into catalog.editions (id, work_id, isbn13, title, pages, source) values
  ('00000000-0000-7000-8000-00000000e002', '00000000-0000-7000-8000-00000000e001', '9788535902778', 'Dom Casmurro', 256,
   'manual');

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
-- o Dom Casmurro em 6 semanas (caps. 1–25 … 126–148), às quintas 20h por 90 min, online, a partir de amanhã
create function pg_temp.clube(p_nome text) returns jsonb language sql as $$
  select jsonb_build_object(
    'name', p_nome, 'name_highlight', case when position('Capitu' in p_nome) > 0 then 'Capitu' end,
    'category', 'Clássicos brasileiros', 'privacy', 'invite',
    'meeting', jsonb_build_object('weekday', 4, 'time', '20:00', 'minutes', 90, 'mode', 'online',
                                  'timezone', 'America/Sao_Paulo'),
    'reading', jsonb_build_object('edition_id', '00000000-0000-7000-8000-00000000e002', 'starts_on', current_date + 1,
      'weeks', jsonb_build_array(
        jsonb_build_object('from', 1, 'to', 25), jsonb_build_object('from', 26, 'to', 50),
        jsonb_build_object('from', 51, 'to', 75), jsonb_build_object('from', 76, 'to', 100),
        jsonb_build_object('from', 101, 'to', 125), jsonb_build_object('from', 126, 'to', 148))))
$$;

create temp table t (club uuid, reading uuid) on commit drop;
create temp table t_code (code text) on commit drop;
create temp table t_q (id uuid, n int) on commit drop;
create temp table t_s (id uuid, quem text) on commit drop;
create temp table t_r (id uuid, quem text) on commit drop;
grant all on t, t_code, t_q, t_s, t_r to authenticated;

-- ---------------------------------------------------------------- create_club
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select lives_ok($$ insert into t (club) select public.create_club(pg_temp.clube('Leitoras de Capitu')) $$,
  'create_club cria o clube');
reset role;
update t set reading = (select r.id from public.club_readings r where r.club_id = t.club);
create temp table t_m on commit drop as
  select m.id, m.week_no from public.club_meetings m where m.reading_id = (select reading from t);
grant select on t_m to authenticated;

select is((select status from public.club_readings where id = (select reading from t)), 'current',
  'a leitura nasce atual');
select is((select work_id from public.club_readings where id = (select reading from t)),
  '00000000-0000-7000-8000-00000000e001'::uuid, 'a obra vem da edição (D-213)');
select results_eq(
  $$ select week_no, from_chapter, to_chapter from public.club_weeks where reading_id = (select reading from t)
      order by week_no $$,
  $$ values (1, 1, 25), (2, 26, 50), (3, 51, 75), (4, 76, 100), (5, 101, 125), (6, 126, 148) $$,
  'as 6 semanas contíguas');
select results_eq(
  $$ select week_no, extract(dow from starts_at at time zone 'America/Sao_Paulo')::int,
            to_char(starts_at at time zone 'America/Sao_Paulo', 'HH24:MI'),
            (extract(epoch from ends_at - starts_at) / 60)::int, until_chapter, mode
       from public.club_meetings where reading_id = (select reading from t) order by week_no $$,
  $$ values (1, 4, '20:00', 90, 25, 'online'), (2, 4, '20:00', 90, 50, 'online'), (3, 4, '20:00', 90, 75, 'online'),
            (4, 4, '20:00', 90, 100, 'online'), (5, 4, '20:00', 90, 125, 'online'),
            (6, 4, '20:00', 90, 148, 'online') $$,
  'um encontro por semana: quinta, 20h de Brasília, 90 min, até o fim da semana');
select is(
  (select array_agg((starts_at at time zone 'America/Sao_Paulo')::date - (current_date + 1) order by week_no)
     from public.club_meetings where reading_id = (select reading from t)),
  (select array_agg(((4 - extract(dow from current_date + 1)::int + 7) % 7) + 7 * k order by k)
     from generate_series(0, 5) k),
  'a 1ª quinta a partir do início e depois de 7 em 7 dias');
select is((select color from public.club_members where club_id = (select club from t) and role = 'owner'), '#B6ACE4',
  'a anfitriã ganha a 1ª cor da paleta');
select hasnt_column('public', 'clubs', 'goal_chapter', 'a meta do clube saiu: é a semana atual');

set local role authenticated;
select throws_ok(
  $$ select public.create_club(jsonb_set(pg_temp.clube('Buraco'), '{reading,weeks,1,from}', '27')) $$,
  '22023', 'invalid_weeks', 'semanas com buraco são recusadas');
select throws_ok(
  $$ select public.create_club(jsonb_set(pg_temp.clube('Treze'), '{reading,weeks}',
       (select jsonb_agg(jsonb_build_object('from', i, 'to', i)) from generate_series(1, 13) i))) $$,
  '22023', 'invalid_weeks', 'mais de 12 semanas são recusadas');
select throws_ok($$ select public.create_club(pg_temp.clube('Sem livro') #- '{reading,edition_id}') $$,
  '22023', 'invalid_book', 'sem livro, nada');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select lives_ok($$ select public.create_club(pg_temp.clube('Clube do Caio')) $$, 'o Grátis cria o 1º clube');
select throws_ok($$ select public.create_club(pg_temp.clube('Segundo do Caio')) $$,
  'P0001', 'free_club_limit', 'o Grátis não cria o 2º, nem pelo create_club');
select set_config('request.jwt.claims', '{"role": "authenticated"}', true);
select throws_ok($$ select public.create_club(pg_temp.clube('Sem conta')) $$,
  '28000', 'unauthenticated', 'sem conta, nada');

-- ---------------------------------------------------------------- convite
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select lives_ok($$ insert into t_code select public.create_invite((select club from t)) $$,
  'a anfitriã cria o convite');
select ok((select code ~ '^[A-Za-z0-9]{8,16}$' from t_code), 'o convite é um código');
select is((select max_uses from public.club_invites where code = (select code from t_code)), 12, 'até 12 pessoas');
select is((select expires_at from public.club_invites where code = (select code from t_code)),
  now() + interval '7 days', 'vale por 7 dias');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select throws_ok($$ select public.create_invite((select club from t)) $$, '42501', 'not_allowed',
  'só a anfitriã convida');
select is(public.join_club((select code from t_code)), (select club from t), 'a Júlia entra pelo convite');
select is((select color from public.club_members
            where club_id = (select club from t) and user_id = '00000000-0000-7000-8000-0000000000b2'),
  '#ABCF82', 'a 2ª leitora ganha a 2ª cor');
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select lives_ok($$ select public.revoke_invite((select code from t_code)) $$, 'a anfitriã desativa o convite');
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select throws_ok($$ select public.join_club((select code from t_code)) $$, 'P0001', 'invalid_invite',
  'convite desativado não entra');
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
delete from t_code;
insert into t_code select public.create_invite((select club from t), 1, 1);
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select is(public.join_club((select code from t_code)), (select club from t), 'o Rafa entra por outro convite');

-- ---------------------------------------------------------------- presença e recado
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select is(public.set_rsvp((select id from t_m where week_no = 2), 'vou', 'Saio tarde do trabalho na quinta.', 'host'),
  '{"vou": 1, "talvez": 0, "nao_vou": 0}'::jsonb, 'a Júlia vai; a contagem volta');
select is(public.set_rsvp((select id from t_m where week_no = 2), 'talvez'),
  '{"vou": 0, "talvez": 1, "nao_vou": 0}'::jsonb, 'mudar quando quiser');
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select is((select count(*)::int from public.meeting_notes), 0, 'o recado "Só a Ana" não aparece para as outras');
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select is((select body from public.meeting_notes), 'Saio tarde do trabalho na quinta.',
  'a anfitriã lê o recado (e mudar a presença sem recado não o apagou)');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select public.set_rsvp((select id from t_m where week_no = 2), 'vou', null, 'club');
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select is((select count(*)::int from public.meeting_notes), 1, 'o recado "O clube todo" aparece para as outras');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select public.set_rsvp((select id from t_m where week_no = 2), 'vou', '');
reset role;
select is((select count(*)::int from public.meeting_notes where user_id = '00000000-0000-7000-8000-0000000000b2'), 0,
  'recado vazio apaga');
update public.club_meetings set starts_at = now() - interval '3 hours', ends_at = now() - interval '90 minutes'
 where id = (select id from t_m where week_no = 1);
set local role authenticated;
select throws_ok($$ select public.set_rsvp((select id from t_m where week_no = 1), 'vou') $$,
  'P0001', 'meeting_over', 'encontro que já acabou não recebe presença');
select throws_ok($$ select public.set_rsvp((select id from t_m where week_no = 2), 'sim') $$,
  '22023', 'invalid_rsvp', 'resposta fora da lista');
select throws_like(
  $$ insert into public.meeting_rsvps (meeting_id, user_id, club_id, answer)
     values ((select id from t_m where week_no = 2), '00000000-0000-7000-8000-0000000000b2', (select club from t), 'vou') $$,
  '%permission denied%', 'a presença só pela RPC');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select throws_ok($$ select public.set_rsvp((select id from t_m where week_no = 2), 'vou') $$,
  '42501', 'not_member', 'quem não é do clube não responde');

-- ---------------------------------------------------------------- perguntas
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
insert into t_q select public.suggest_question((select club from t), 2, 'Os “olhos de ressaca”: é amor ou é medo?'), 1;
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
insert into t_q select public.suggest_question((select club from t), 2, 'Bentinho é um narrador confiável?'), 2;
select results_eq($$ select n, position, status, chapter_index from public.club_posts p join t_q using (id) order by n $$,
  $$ values (1, 1, 'open', 49), (2, 2, 'open', 49) $$, 'cada sugestão entra no fim da fila, aberta, até o cap. 50');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select throws_ok($$ select public.order_questions((select club from t), 2,
                     array[(select id from t_q where n = 2), (select id from t_q where n = 1)]) $$,
  '42501', 'not_allowed', 'só a anfitriã ordena');
select throws_ok($$ select public.suggest_question((select club from t), 9, 'Semana que não existe?') $$,
  '22023', 'invalid_week', 'só nas semanas da leitura');
select throws_like(
  $$ insert into public.club_posts (club_id, author_id, kind, chapter_index, body)
     values ((select club from t), '00000000-0000-7000-8000-0000000000b2', 'question', 0, 'pergunta direta') $$,
  '%row-level security%', 'a pergunta só pela RPC');
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select throws_ok($$ select public.order_questions((select club from t), 2, array[(select id from t_q where n = 2)]) $$,
  '22023', 'invalid_order', 'a ordem traz todas as perguntas da semana');
select lives_ok($$ select public.order_questions((select club from t), 2,
                     array[(select id from t_q where n = 2), (select id from t_q where n = 1)]) $$,
  'a anfitriã põe a dela primeiro');
select is((select position from public.club_posts where id = (select id from t_q where n = 2)), 1,
  'a pergunta da Ana virou a 1ª ("Pergunta da semana")');
select lives_ok($$ select public.set_question_status((select id from t_q where n = 2), 'discussed',
                     'Na contagem final, 7 acham que não, 2 acham que sim.') $$, 'a anfitriã marca a conversada');
select results_eq($$ select status, host_note from public.club_posts where id = (select id from t_q where n = 2) $$,
  $$ values ('discussed', 'Na contagem final, 7 acham que não, 2 acham que sim.') $$, 'o estado e a anotação');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select throws_ok($$ select public.set_question_status((select id from t_q where n = 1), 'postponed') $$,
  '42501', 'not_allowed', 'só a anfitriã marca');

-- ---------------------------------------------------------------- grifo compartilhado (D-217, D-219)
insert into t_s select public.share_highlight((select club from t), '…olhos de cigana oblíqua e dissimulada.',
  '#B6ACE4', 121, 25, 0.4727), 'julia';
select results_eq(
  $$ select kind, week_no, chapter_index, ref_page, spoiler_page, spoiler_ratio, quote_text
       from public.club_posts where id = (select id from t_s where quem = 'julia') $$,
  $$ values ('shared_highlight', 1, 24, 121, 121, 0.4727::numeric, '…olhos de cigana oblíqua e dissimulada.') $$,
  'o grifo: o trecho, a semana do capítulo, a página e a posição de quem compartilhou');
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
insert into t_s select public.share_highlight((select club from t), 'Olhos de cigana oblíqua e dissimulada',
  '#FFC1C6', 121, 25, 0.47), 'rafa';
select is((select count(distinct quote_key)::int from public.club_posts where id in (select id from t_s)), 1,
  'o mesmo trecho com outra pontuação e maiúscula dá a mesma chave (D-219)');
select throws_ok($$ select public.share_highlight((select club from t), '  ', '#B6ACE4', 121, 25, 0.47) $$,
  '22023', 'invalid_share', 'trecho vazio não vai');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select throws_ok($$ select public.share_highlight((select club from t), 'x', '#B6ACE4', 1, 1, 0) $$,
  '42501', 'not_member', 'quem não é do clube não compartilha');

-- ---------------------------------------------------------------- respostas em um nível
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
insert into public.club_post_replies (post_id, author_id, body, quote_text, quote_color, quote_page, spoiler_ratio,
                                      spoiler_page)
values ((select id from t_q where n = 2), '00000000-0000-7000-8000-0000000000a1',
        'Repara que quem fala dos “olhos de cigana” é o José Dias.', 'olhos de cigana oblíqua e dissimulada.',
        '#B6ACE4', 121, 0.6, 152);
reset role;
insert into t_r select id, 'ana' from public.club_post_replies where author_id = '00000000-0000-7000-8000-0000000000a1';
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select lives_ok($$ insert into public.club_post_replies (post_id, author_id, parent_reply_id, body)
                   values ((select id from t_q where n = 2), '00000000-0000-7000-8000-0000000000b2',
                           (select id from t_r where quem = 'ana'), 'Boa!') $$, 'responder a uma resposta');
select is((select replies_count from public.club_post_replies where id = (select id from t_r where quem = 'ana')), 1,
  'a resposta conta as filhas');
select is((select replies_count from public.club_posts where id = (select id from t_q where n = 2)), 2,
  'o post conta todas');
reset role;
insert into t_r select id, 'julia' from public.club_post_replies where author_id = '00000000-0000-7000-8000-0000000000b2';
set local role authenticated;
select throws_ok($$ insert into public.club_post_replies (post_id, author_id, parent_reply_id, body)
                    values ((select id from t_q where n = 2), '00000000-0000-7000-8000-0000000000b2',
                            (select id from t_r where quem = 'julia'), 'neta') $$,
  'P0001', 'reply_depth', 'um nível só');

-- ---------------------------------------------------------------- curtidas
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select lives_ok($$ insert into public.club_likes (target_type, target_id, user_id)
                   values ('post', (select id from t_s where quem = 'julia'), '00000000-0000-7000-8000-0000000000d4') $$,
  'curtir um post');
select is((select likes_count from public.club_posts where id = (select id from t_s where quem = 'julia')), 1,
  'o contador sobe');
select throws_ok($$ insert into public.club_likes (target_type, target_id, user_id)
                    values ('post', (select id from t_s where quem = 'julia'), '00000000-0000-7000-8000-0000000000d4') $$,
  '23505', null, 'curtir de novo não conta duas');
delete from public.club_likes where target_id = (select id from t_s where quem = 'julia');
select is((select likes_count from public.club_posts where id = (select id from t_s where quem = 'julia')), 0,
  'descurtir desce');
select lives_ok($$ insert into public.club_likes (target_type, target_id, user_id)
                   values ('reply', (select id from t_r where quem = 'ana'), '00000000-0000-7000-8000-0000000000d4') $$,
  'curtir uma resposta');
select is((select likes_count from public.club_post_replies where id = (select id from t_r where quem = 'ana')), 1,
  'o contador da resposta sobe');
select throws_like($$ insert into public.club_likes (target_type, target_id, user_id, club_id)
                      values ('post', (select id from t_s where quem = 'rafa'), '00000000-0000-7000-8000-0000000000d4',
                              (select club from t)) $$,
  '%permission denied%', 'o clube da curtida vem do servidor');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select throws_like($$ insert into public.club_likes (target_type, target_id, user_id)
                      values ('post', (select id from t_s where quem = 'julia'), '00000000-0000-7000-8000-0000000000c3') $$,
  '%row-level security%', 'quem não é do clube não curte');

-- ---------------------------------------------------------------- progresso e lido
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select lives_ok($$ select public.publish_progress((select club from t), 0.67, 34) $$, 'publicar o progresso');
select public.publish_progress((select club from t), 0.70, 36);
select results_eq(
  $$ select progress_ratio, progress_chapter from public.club_members
      where club_id = (select club from t) and user_id = '00000000-0000-7000-8000-0000000000b2' $$,
  $$ values (0.67::numeric, 34) $$, 'no mesmo minuto, a 2ª publicação não muda nada');
select throws_ok($$ select public.publish_progress((select club from t), 1.5, 1) $$,
  '22023', 'invalid_progress', 'fração fora de 0–1');
select throws_like($$ update public.club_members set progress_ratio = 0.99
                      where user_id = '00000000-0000-7000-8000-0000000000b2' $$,
  '%permission denied%', 'o progresso só pela RPC');
select lives_ok($$ select public.mark_club_read((select club from t)) $$, 'marcar o clube como lido');
select is((select last_read_post_at from public.club_members
            where club_id = (select club from t) and user_id = '00000000-0000-7000-8000-0000000000b2'), now(),
  'o lido é agora');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select throws_ok($$ select public.publish_progress((select club from t), 0.1, 1) $$,
  '42501', 'not_member', 'quem não é do clube não publica');

-- ---------------------------------------------------------------- sair
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
delete from public.club_members where club_id = (select club from t) and user_id = '00000000-0000-7000-8000-0000000000b2';
reset role;
select is((select count(*)::int from public.meeting_rsvps where user_id = '00000000-0000-7000-8000-0000000000b2'), 0,
  'quem sai leva a presença junto');

select * from finish();
rollback;
```

- [ ] **Passo 2:** contar as asserções e acertar o `plan(N)` (cada `select is/ok/…` é uma). Rodar
  `supabase db reset` + `supabase test db supabase/tests/database/21_clubes_nucleo.test.sql` e ver falhar
  (`function public.create_club(jsonb) does not exist`).

### Tarefa 3: a migração — tabelas, gatilhos e políticas

**Arquivo:** `supabase/migrations/<carimbo>_g21_clubes_nucleo.sql` (novo, por `supabase migration new g21_clubes_nucleo`)

- [ ] **Passo 1:** o cabeçalho e as tabelas:

```sql
-- =====================================================================================
-- BookNest · G21.1 — o núcleo do clube (docs/progresso/G21.md §1; D-211, D-213, D-214, D-218, D-219;
-- R4–R6, R11, R12).
-- - O livro do clube em semanas (club_readings, club_weeks). A meta do clube (goal_chapter) sai: passa a
--   ser a semana do próximo encontro.
-- - Um encontro por semana: club_meetings ganha a leitura, a semana, o fim e o modo. Presença
--   (meeting_rsvps) e recado (meeting_notes: "Só a Ana" / "O clube todo").
-- - Perguntas (club_posts 'question') na ordem da anfitriã; respostas em um nível; curtidas (club_likes);
--   a cor de cada leitora; o spoiler de cada post e resposta (D-218); a chave do trecho (D-219).
-- - As RPCs de escrita (quando a regra cruza tabelas) e os 6 resumos (uma ida por tela).
-- - O progresso e o "lido" passam a ser só pelas RPCs (publish_progress, mark_club_read).
-- =====================================================================================

-- 1. O livro do clube em semanas --------------------------------------------------------

create table public.club_readings (
  id          uuid primary key default private.uuid_generate_v7(),
  club_id     uuid not null references public.clubs(id) on delete cascade,
  work_id     uuid references catalog.works(id) on delete set null,
  edition_id  uuid references catalog.editions(id) on delete set null,
  status      text not null default 'current' check (status in ('current','next','done')),
  starts_on   date not null,
  weeks       integer not null check (weeks between 1 and 12),
  created_at  timestamptz not null default now()
);
create unique index club_readings_current_uq on public.club_readings (club_id) where status = 'current';
create index club_readings_club_idx on public.club_readings (club_id);
create index club_readings_work_idx on public.club_readings (work_id);
create index club_readings_edition_idx on public.club_readings (edition_id);

-- cap. N do clube = o N-º capítulo numerado do livro (D-214); os rótulos valem para livro sem numeração
create table public.club_weeks (
  reading_id    uuid not null references public.club_readings(id) on delete cascade,
  club_id       uuid not null references public.clubs(id) on delete cascade,   -- desnormalizado p/ RLS
  week_no       integer not null check (week_no between 1 and 12),
  from_chapter  integer not null check (from_chapter > 0),
  to_chapter    integer not null,
  from_label    text check (char_length(from_label) between 1 and 12),
  to_label      text check (char_length(to_label) between 1 and 12),
  primary key (reading_id, week_no),
  check (to_chapter >= from_chapter)
);
create index club_weeks_club_idx on public.club_weeks (club_id);

-- 2. O clube e a cor de cada leitora -------------------------------------------------------

alter table public.clubs
  drop column goal_chapter,
  drop column goal_chapter_label,
  add column category           text check (char_length(category) between 1 and 40),
  add column color              text not null default '#B6ACE4' check (color ~ '^#[0-9A-F]{6}$'),
  add column progress_colors    text not null default 'club' check (progress_colors in ('club','member')),
  add column spoiler_protection boolean not null default true,
  add column meeting_weekday    smallint check (meeting_weekday between 0 and 6),   -- 0 = domingo, como extract(dow)
  add column meeting_time       time,
  add column meeting_minutes    smallint check (meeting_minutes between 15 and 600),
  add column meeting_mode       text check (meeting_mode in ('online','presencial')),
  add column timezone           text not null default 'America/Sao_Paulo';
create trigger clubs_timezone before insert or update of timezone on public.clubs
  for each row execute function private.check_timezone();

alter table public.club_members add column color text check (color ~ '^#[0-9A-F]{6}$');

-- A cor da leitora (pranchas 04, 31 e 70): a 1ª da paleta que ninguém do clube usa; acabou a paleta,
-- recomeça pela ordem de chegada. O cliente não escolhe (sem GRANT).
create or replace function private.club_member_color() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_palette constant text[] := array['#B6ACE4','#ABCF82','#FED170','#FFC1C6','#FFFAF1','#058CD7','#F2A815'];
  v_count integer;
begin
  if new.color is not null then return new; end if;
  select u.p into new.color from unnest(v_palette) with ordinality as u(p, i)
   where not exists (select 1 from public.club_members m where m.club_id = new.club_id and m.color = u.p)
   order by u.i limit 1;
  if new.color is null then
    select count(*) into v_count from public.club_members m where m.club_id = new.club_id;
    new.color := v_palette[(v_count % array_length(v_palette, 1)) + 1];
  end if;
  return new;
end $$;
create trigger club_members_color before insert on public.club_members
  for each row execute function private.club_member_color();

-- 3. Encontros, presença e recado -----------------------------------------------------------

alter table public.club_meetings
  add column reading_id uuid,
  add column week_no    integer check (week_no between 1 and 12),
  add column ends_at    timestamptz,
  add column mode       text check (mode in ('online','presencial')),
  add constraint club_meetings_week_fk foreign key (reading_id, week_no)
    references public.club_weeks (reading_id, week_no) on delete cascade,
  add constraint club_meetings_ends_check check (ends_at is null or ends_at > starts_at);
create index club_meetings_week_idx on public.club_meetings (reading_id, week_no);

-- O encontro da semana vai até o fim dela (o lembrete que já existe continua igual) e é do mesmo clube.
create or replace function private.meeting_from_week() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.reading_id is not null then
    if not exists (select 1 from public.club_readings r where r.id = new.reading_id and r.club_id = new.club_id) then
      raise exception 'invalid_reading' using errcode = '22023';
    end if;
    select w.to_chapter into new.until_chapter from public.club_weeks w
     where w.reading_id = new.reading_id and w.week_no = new.week_no;
  end if;
  return new;
end $$;
create trigger club_meetings_from_week before insert or update of reading_id, week_no on public.club_meetings
  for each row execute function private.meeting_from_week();

create table public.meeting_rsvps (
  meeting_id  uuid not null references public.club_meetings(id) on delete cascade,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  club_id     uuid not null references public.clubs(id) on delete cascade,   -- desnormalizado p/ RLS
  answer      text not null check (answer in ('vou','talvez','nao_vou')),
  updated_at  timestamptz not null default now(),
  primary key (meeting_id, user_id)
);
create index meeting_rsvps_user_idx on public.meeting_rsvps (user_id);
create index meeting_rsvps_club_idx on public.meeting_rsvps (club_id, user_id);

-- O recado fica à parte: quem lê é diferente (o "Só a Ana" não pode vazar pela leitura das presenças).
create table public.meeting_notes (
  meeting_id  uuid not null references public.club_meetings(id) on delete cascade,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  club_id     uuid not null references public.clubs(id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 140),
  visibility  text not null default 'host' check (visibility in ('host','club')),
  updated_at  timestamptz not null default now(),
  primary key (meeting_id, user_id)
);
create index meeting_notes_user_idx on public.meeting_notes (user_id);
create index meeting_notes_club_idx on public.meeting_notes (club_id, user_id);

-- Quem sai do clube leva a presença e o recado junto (as contagens são das leitoras atuais).
create or replace function private.club_member_left() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  delete from public.meeting_rsvps where club_id = old.club_id and user_id = old.user_id;
  delete from public.meeting_notes where club_id = old.club_id and user_id = old.user_id;
  return null;
end $$;
create trigger club_members_left after delete on public.club_members
  for each row execute function private.club_member_left();

-- 4. Discussão: perguntas, respostas em um nível, spoiler e o mesmo trecho --------------------

-- Chave do trecho (D-219): o mesmo trecho com outra pontuação, maiúscula ou acento dá a mesma chave.
-- security definer: a coluna gerada roda como quem insere, e o f_unaccent não é dele.
create or replace function private.quote_key(p_text text) returns text
language sql immutable parallel safe security definer set search_path = '' as $$
  select case when p_text is null then null
              else md5(btrim(regexp_replace(lower(private.f_unaccent(p_text)), '[^a-z0-9]+', ' ', 'g'))) end
$$;

alter table public.club_posts drop constraint club_posts_kind_check;
alter table public.club_posts add constraint club_posts_kind_check
  check (kind in ('discussion','shared_highlight','question'));
alter table public.club_posts
  add column reading_id    uuid references public.club_readings(id) on delete cascade,
  add column week_no       integer check (week_no between 1 and 12),
  add column position      integer check (position > 0),
  add column status        text check (status in ('open','discussed','postponed')),
  add column host_note     text check (char_length(host_note) <= 280),
  add column likes_count   integer not null default 0,
  add column spoiler_ratio numeric(5,4) check (spoiler_ratio between 0 and 1),
  add column spoiler_page  integer check (spoiler_page > 0),
  add column quote_key     text generated always as (private.quote_key(quote_text)) stored,
  add constraint club_posts_question_check check (kind <> 'question' or deleted_at is not null
    or (body is not null and reading_id is not null and week_no is not null and status is not null));
create index club_posts_reading_week_idx on public.club_posts (reading_id, week_no) where deleted_at is null;
create index club_posts_same_passage_idx on public.club_posts (reading_id, quote_key)
  where kind = 'shared_highlight' and deleted_at is null;

-- A leitura do post é do mesmo clube.
create or replace function private.club_post_reading_check() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.reading_id is not null and not exists (
       select 1 from public.club_readings r where r.id = new.reading_id and r.club_id = new.club_id) then
    raise exception 'invalid_reading' using errcode = '22023';
  end if;
  return new;
end $$;
create trigger club_posts_reading_check before insert or update of reading_id on public.club_posts
  for each row execute function private.club_post_reading_check();

alter table public.club_post_replies
  add column parent_reply_id uuid references public.club_post_replies(id) on delete cascade,
  add column replies_count   integer not null default 0,
  add column likes_count     integer not null default 0,
  add column spoiler_ratio   numeric(5,4) check (spoiler_ratio between 0 and 1),
  add column spoiler_page    integer check (spoiler_page > 0),
  add column quote_text      text check (char_length(quote_text) <= 1200),
  add column quote_color     text check (quote_color ~ '^#[0-9A-F]{6}$'),
  add column quote_page      integer check (quote_page > 0);
create index club_post_replies_parent_idx on public.club_post_replies (parent_reply_id);
drop index public.club_post_replies_club_idx;
create index club_post_replies_club_idx on public.club_post_replies (club_id, created_at desc);

-- A resposta herda o club_id do post e vai a um nível só (a resposta de uma resposta, no mesmo post).
create or replace function private.club_reply_set_club() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_post uuid; v_grand uuid;
begin
  select p.club_id into new.club_id from public.club_posts p where p.id = new.post_id;
  if new.club_id is null then raise exception 'post_not_found' using errcode = 'P0001'; end if;
  if new.parent_reply_id is not null then
    select r.post_id, r.parent_reply_id into v_post, v_grand from public.club_post_replies r
     where r.id = new.parent_reply_id;
    if v_post is distinct from new.post_id or v_grand is not null then
      raise exception 'reply_depth' using errcode = 'P0001';
    end if;
  end if;
  return new;
end $$;

-- Os contadores de respostas: o post conta todas; a resposta, as filhas.
create or replace function private.club_replies_counter() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_delta integer; v_parent uuid := coalesce(new.parent_reply_id, old.parent_reply_id);
begin
  v_delta := (case when tg_op <> 'DELETE' and new.deleted_at is null then 1 else 0 end)
           - (case when tg_op <> 'INSERT' and old.deleted_at is null then 1 else 0 end);
  if v_delta <> 0 then
    update public.club_posts set replies_count = greatest(replies_count + v_delta, 0)
     where id = coalesce(new.post_id, old.post_id);
    if v_parent is not null then
      update public.club_post_replies set replies_count = greatest(replies_count + v_delta, 0) where id = v_parent;
    end if;
  end if;
  return null;
end $$;

-- 5. Curtidas ---------------------------------------------------------------------------

create table public.club_likes (
  target_type  text not null check (target_type in ('post','reply')),
  target_id    uuid not null,
  user_id      uuid not null references public.profiles(id) on delete cascade,
  club_id      uuid not null references public.clubs(id) on delete cascade,   -- vem do alvo (gatilho)
  created_at   timestamptz not null default now(),
  primary key (target_type, target_id, user_id)
);
create index club_likes_user_idx on public.club_likes (user_id);
create index club_likes_club_idx on public.club_likes (club_id);

create or replace function private.club_like_set_club() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.target_type = 'post' then
    select p.club_id into new.club_id from public.club_posts p where p.id = new.target_id and p.deleted_at is null;
  else
    select r.club_id into new.club_id from public.club_post_replies r
     where r.id = new.target_id and r.deleted_at is null;
  end if;
  if new.club_id is null then raise exception 'target_not_found' using errcode = 'P0001'; end if;
  return new;
end $$;
create trigger club_likes_set_club before insert on public.club_likes
  for each row execute function private.club_like_set_club();

create or replace function private.club_likes_counter() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_delta integer := case when tg_op = 'INSERT' then 1 else -1 end;
begin
  if coalesce(new.target_type, old.target_type) = 'post' then
    update public.club_posts set likes_count = greatest(likes_count + v_delta, 0)
     where id = coalesce(new.target_id, old.target_id);
  else
    update public.club_post_replies set likes_count = greatest(likes_count + v_delta, 0)
     where id = coalesce(new.target_id, old.target_id);
  end if;
  return null;
end $$;
create trigger club_likes_counter after insert or delete on public.club_likes
  for each row execute function private.club_likes_counter();

-- 6. Faixa etária e filtro de palavras nas tabelas novas ----------------------------------------

create trigger club_likes_require_age before insert on public.club_likes
  for each row execute function private.require_age_band();
create trigger meeting_rsvps_require_age before insert on public.meeting_rsvps
  for each row execute function private.require_age_band();
create trigger meeting_notes_require_age before insert on public.meeting_notes
  for each row execute function private.require_age_band();
create trigger meeting_notes_blocked_terms before insert or update of body on public.meeting_notes
  for each row execute function private.reject_blocked_terms();
```

- [ ] **Passo 2:** o filtro de palavras passa a olhar a categoria do clube e a anotação da anfitriã. Antes, conferir
  com `grep -n "reject_blocked_terms" supabase/migrations/*.sql` que a última definição é a da `moderacao`; recriar
  a função com o mesmo corpo e só estas duas linhas do `case` trocadas, e os dois gatilhos:

```sql
    when 'clubs'      then concat_ws(' ', v ->> 'name', v ->> 'category')
    when 'club_posts' then concat_ws(' ', v ->> 'body', v ->> 'host_note')
```

```sql
drop trigger clubs_blocked_terms on public.clubs;
create trigger clubs_blocked_terms before insert or update of name, category on public.clubs
  for each row execute function private.reject_blocked_terms();
drop trigger club_posts_blocked_terms on public.club_posts;
create trigger club_posts_blocked_terms before insert or update of body, host_note on public.club_posts
  for each row execute function private.reject_blocked_terms();
```

- [ ] **Passo 3:** as políticas:

```sql
-- 7. Políticas -----------------------------------------------------------------------------

alter table public.club_readings enable row level security;
alter table public.club_weeks enable row level security;
alter table public.meeting_rsvps enable row level security;
alter table public.meeting_notes enable row level security;
alter table public.club_likes enable row level security;

create policy club_readings_read on public.club_readings for select to authenticated
  using (private.is_club_member(club_id));
create policy club_weeks_read on public.club_weeks for select to authenticated
  using (private.is_club_member(club_id));
create policy meeting_rsvps_read on public.meeting_rsvps for select to authenticated
  using (private.is_club_member(club_id));
-- o recado: quem escreveu e a anfitriã leem sempre; o resto do clube, só os de "O clube todo"
create policy meeting_notes_read on public.meeting_notes for select to authenticated
  using (user_id = (select auth.uid()) or private.is_club_admin(club_id)
         or (visibility = 'club' and private.is_club_member(club_id)));
create policy club_likes_read on public.club_likes for select to authenticated
  using (private.is_club_member(club_id));
create policy club_likes_insert on public.club_likes for insert to authenticated
  with check (user_id = (select auth.uid()) and private.is_club_member(club_id));
create policy club_likes_delete on public.club_likes for delete to authenticated
  using (user_id = (select auth.uid()));

-- post direto: só discussão e grifo; a pergunta vem pela RPC (a posição e o estado são da anfitriã)
drop policy club_posts_insert on public.club_posts;
create policy club_posts_insert on public.club_posts for insert to authenticated
  with check (author_id = (select auth.uid()) and private.is_club_member(club_id)
              and kind in ('discussion','shared_highlight'));

-- o progresso e o lido passam a ser só pelas RPCs (com a validação e o limite)
drop policy club_members_update_self on public.club_members;
```

- [ ] **Passo 4:** rodar o 21: os testes de tabela, cor e permissão direta passam; os das RPCs ainda falham.

### Tarefa 4: a migração — RPCs de escrita

- [ ] **Passo 1:** acrescentar à migração:

```sql
-- 8. Escrita -------------------------------------------------------------------------------

-- Cria o clube com a leitura, as semanas e um encontro por semana (prancha 33), numa transação.
-- p: {"name", "name_highlight", "category", "color", "progress_colors", "privacy", "spoiler_protection",
--     "meeting": {"weekday", "time", "minutes", "mode", "timezone"},
--     "reading": {"work_id", "edition_id", "starts_on", "weeks": [{"from", "to", "from_label", "to_label"}]}}
-- As semanas vêm prontas do app (até 12, contíguas desde o cap. 1). O limite do Grátis, a faixa etária,
-- o filtro de palavras e os termos continuam nos gatilhos de clubs.
create or replace function public.create_club(p jsonb) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_me uuid := (select auth.uid());
  v_r jsonb := p -> 'reading';
  v_mt jsonb := coalesce(p -> 'meeting', '{}'::jsonb);
  v_weeks jsonb := v_r -> 'weeks';
  v_edition uuid := (v_r ->> 'edition_id')::uuid;
  v_work uuid := (v_r ->> 'work_id')::uuid;
  v_starts date := coalesce((v_r ->> 'starts_on')::date, current_date);
  v_tz text := coalesce(v_mt ->> 'timezone', 'America/Sao_Paulo');
  v_dow integer := (v_mt ->> 'weekday')::integer;
  v_time time := (v_mt ->> 'time')::time;
  v_minutes integer := coalesce((v_mt ->> 'minutes')::integer, 90);
  v_n integer; v_prev integer := 0; v_w jsonb; v_club uuid; v_reading uuid; v_first date; v_start timestamptz;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if v_r is null or jsonb_typeof(v_weeks) is distinct from 'array' then
    raise exception 'invalid_weeks' using errcode = '22023';
  end if;
  v_n := jsonb_array_length(v_weeks);
  if v_n not between 1 and 12 then raise exception 'invalid_weeks' using errcode = '22023'; end if;
  for v_w in select x from jsonb_array_elements(v_weeks) x loop
    if (v_w ->> 'from')::integer is distinct from v_prev + 1
       or (v_w ->> 'to')::integer is null or (v_w ->> 'to')::integer < v_prev + 1 then
      raise exception 'invalid_weeks' using errcode = '22023';
    end if;
    v_prev := (v_w ->> 'to')::integer;
  end loop;
  if v_edition is null and v_work is null then raise exception 'invalid_book' using errcode = '22023'; end if;
  if v_work is null then select e.work_id into v_work from catalog.editions e where e.id = v_edition; end if;

  insert into public.clubs (owner_id, name, name_highlight, category, color, progress_colors, privacy,
                            spoiler_protection, work_id, edition_id, meeting_weekday, meeting_time,
                            meeting_minutes, meeting_mode, timezone)
  values (v_me, p ->> 'name', p ->> 'name_highlight', p ->> 'category', coalesce(p ->> 'color', '#B6ACE4'),
          coalesce(p ->> 'progress_colors', 'club'), coalesce(p ->> 'privacy', 'invite'),
          coalesce((p ->> 'spoiler_protection')::boolean, true), v_work, v_edition, v_dow, v_time, v_minutes,
          v_mt ->> 'mode', v_tz)
  returning id into v_club;

  insert into public.club_readings (club_id, work_id, edition_id, status, starts_on, weeks)
  values (v_club, v_work, v_edition, 'current', v_starts, v_n)
  returning id into v_reading;

  insert into public.club_weeks (reading_id, club_id, week_no, from_chapter, to_chapter, from_label, to_label)
  select v_reading, v_club, w.n::integer, (w.v ->> 'from')::integer, (w.v ->> 'to')::integer,
         w.v ->> 'from_label', w.v ->> 'to_label'
    from jsonb_array_elements(v_weeks) with ordinality as w(v, n);

  -- um encontro por semana: o 1º dia do encontro a partir do início, na hora do clube, no fuso dele
  if v_dow is not null and v_time is not null then
    v_first := v_starts + ((v_dow - extract(dow from v_starts)::integer + 7) % 7);
    for i in 1 .. v_n loop
      v_start := ((v_first + (i - 1) * 7) + v_time) at time zone v_tz;
      insert into public.club_meetings (club_id, starts_at, ends_at, mode, timezone, reading_id, week_no, created_by)
      values (v_club, v_start, v_start + make_interval(mins => v_minutes), v_mt ->> 'mode', v_tz, v_reading, i, v_me);
    end loop;
  end if;
  return v_club;
end $$;

-- Convite da anfitriã: "vale por 7 dias · até 12 pessoas · dá para desativar" (prancha 34).
create or replace function public.create_invite(p_club uuid, p_days integer default 7, p_max_uses integer default 12)
returns text language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_code text;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_admin(p_club) then raise exception 'not_allowed' using errcode = '42501'; end if;
  if p_days is null or p_days not between 1 and 30 or p_max_uses is null or p_max_uses not between 1 and 100 then
    raise exception 'invalid_invite' using errcode = '22023';
  end if;
  insert into public.club_invites (club_id, created_by, expires_at, max_uses)
  values (p_club, v_me, now() + make_interval(days => p_days), p_max_uses)
  returning code into v_code;
  return v_code;
end $$;

create or replace function public.revoke_invite(p_code text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.uid()) is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  update public.club_invites i set expires_at = least(i.expires_at, now())
   where i.code = p_code and private.is_club_admin(i.club_id);
  if not found then raise exception 'not_allowed' using errcode = '42501'; end if;
end $$;

-- O progresso no clube (R9): a fração e o capítulo do clube; até 1 vez por minuto (a 2ª no mesmo minuto
-- não muda nada).
create or replace function public.publish_progress(p_club uuid, p_ratio numeric, p_chapter integer) returns void
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  if p_ratio is null or p_ratio < 0 or p_ratio > 1 or (p_chapter is not null and p_chapter < 0) then
    raise exception 'invalid_progress' using errcode = '22023';
  end if;
  update public.club_members
     set progress_ratio = round(p_ratio, 4), progress_chapter = p_chapter, progress_updated_at = now()
   where club_id = p_club and user_id = v_me
     and (progress_updated_at is null or progress_updated_at < now() - interval '1 minute');
end $$;

create or replace function public.mark_club_read(p_club uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  update public.club_members set last_read_post_at = now() where club_id = p_club and user_id = v_me;
  if not found then raise exception 'not_member' using errcode = '42501'; end if;
end $$;

-- Presença (pranchas 70 e 72). p_note: null = não mexe; '' = apaga; texto = grava.
-- p_visibility: null = não mexe (recado novo: "Só a Ana"). Devolve as contagens das leitoras atuais.
create or replace function public.set_rsvp(p_meeting uuid, p_answer text, p_note text default null,
  p_visibility text default null) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_mt public.club_meetings;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select * into v_mt from public.club_meetings where id = p_meeting;
  if not found or not private.is_club_member(v_mt.club_id) then
    raise exception 'not_member' using errcode = '42501';
  end if;
  if p_answer is null or p_answer not in ('vou','talvez','nao_vou')
     or (p_visibility is not null and p_visibility not in ('host','club')) then
    raise exception 'invalid_rsvp' using errcode = '22023';
  end if;
  if coalesce(v_mt.ends_at, v_mt.starts_at + interval '2 hours') <= now() then
    raise exception 'meeting_over' using errcode = 'P0001';
  end if;
  insert into public.meeting_rsvps (meeting_id, user_id, club_id, answer)
  values (p_meeting, v_me, v_mt.club_id, p_answer)
  on conflict (meeting_id, user_id) do update set answer = excluded.answer, updated_at = now();
  if p_note is not null and btrim(p_note) = '' then
    delete from public.meeting_notes where meeting_id = p_meeting and user_id = v_me;
  elsif p_note is not null then
    insert into public.meeting_notes as n (meeting_id, user_id, club_id, body, visibility)
    values (p_meeting, v_me, v_mt.club_id, btrim(p_note), coalesce(p_visibility, 'host'))
    on conflict (meeting_id, user_id) do update
      set body = excluded.body, visibility = coalesce(p_visibility, n.visibility), updated_at = now();
  elsif p_visibility is not null then
    update public.meeting_notes set visibility = p_visibility, updated_at = now()
     where meeting_id = p_meeting and user_id = v_me;
  end if;
  return private.rsvp_counts(p_meeting);
end $$;

-- Sugerir uma pergunta para a semana (prancha 70, "Sugerir uma pergunta"): entra no fim da fila, aberta.
create or replace function public.suggest_question(p_club uuid, p_week integer, p_body text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_reading uuid; v_to integer; v_pos integer; v_id uuid;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  select w.to_chapter into v_to from public.club_weeks w where w.reading_id = v_reading and w.week_no = p_week;
  if v_to is null then raise exception 'invalid_week' using errcode = '22023'; end if;
  if p_body is null or char_length(btrim(p_body)) not between 3 and 300 then
    raise exception 'invalid_question' using errcode = '22023';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('club_questions:' || v_reading::text || ':' || p_week, 0));
  select coalesce(max(q.position), 0) + 1 into v_pos from public.club_posts q
   where q.reading_id = v_reading and q.week_no = p_week and q.kind = 'question' and q.deleted_at is null;
  insert into public.club_posts (club_id, author_id, kind, chapter_index, reading_id, week_no, position, status, body)
  values (p_club, v_me, 'question', v_to - 1, v_reading, p_week, v_pos, 'open', btrim(p_body))
  returning id into v_id;
  return v_id;
end $$;

-- A ordem da anfitriã: a lista tem que trazer exatamente as perguntas da semana.
create or replace function public.order_questions(p_club uuid, p_week integer, p_ids uuid[]) returns void
language plpgsql security definer set search_path = '' as $$
declare v_reading uuid;
begin
  if (select auth.uid()) is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_admin(p_club) then raise exception 'not_allowed' using errcode = '42501'; end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  if (select coalesce(array_agg(q.id order by q.id), '{}') from public.club_posts q
       where q.reading_id = v_reading and q.week_no = p_week and q.kind = 'question' and q.deleted_at is null)
     is distinct from (select coalesce(array_agg(x order by x), '{}') from unnest(p_ids) x) then
    raise exception 'invalid_order' using errcode = '22023';
  end if;
  update public.club_posts q set position = o.n from unnest(p_ids) with ordinality as o(id, n) where q.id = o.id;
end $$;

-- Conversada, adiada ou aberta, com a anotação da anfitriã (prancha 73).
create or replace function public.set_question_status(p_question uuid, p_status text, p_note text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v_club uuid;
begin
  if (select auth.uid()) is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select q.club_id into v_club from public.club_posts q
   where q.id = p_question and q.kind = 'question' and q.deleted_at is null;
  if v_club is null or not private.is_club_admin(v_club) then raise exception 'not_allowed' using errcode = '42501'; end if;
  if p_status is null or p_status not in ('open','discussed','postponed') then
    raise exception 'invalid_status' using errcode = '22023';
  end if;
  update public.club_posts set status = p_status, host_note = nullif(btrim(coalesce(p_note, '')), '')
   where id = p_question;
end $$;

-- Compartilhar um grifo (D-217): o trecho, a cor, a página e o capítulo do clube; a fração é o spoiler
-- (D-218). A nota fica no aparelho. Devolve o id, que o app guarda em shared_club_post_id.
create or replace function public.share_highlight(p_club uuid, p_quote text, p_color text, p_page integer,
  p_chapter integer, p_ratio numeric) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_reading uuid; v_week integer; v_id uuid;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  if p_quote is null or char_length(btrim(p_quote)) not between 1 and 1200
     or p_color is null or upper(p_color) !~ '^#[0-9A-F]{6}$'
     or p_chapter is null or p_chapter < 1 or (p_page is not null and p_page < 1)
     or p_ratio is null or p_ratio < 0 or p_ratio > 1 then
    raise exception 'invalid_share' using errcode = '22023';
  end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  if v_reading is null then raise exception 'no_reading' using errcode = 'P0001'; end if;
  select w.week_no into v_week from public.club_weeks w
   where w.reading_id = v_reading and p_chapter between w.from_chapter and w.to_chapter;
  insert into public.club_posts (club_id, author_id, kind, chapter_index, ref_page, quote_text, quote_color,
                                 reading_id, week_no, spoiler_ratio, spoiler_page)
  values (p_club, v_me, 'shared_highlight', p_chapter - 1, p_page, btrim(p_quote), upper(p_color),
          v_reading, v_week, round(p_ratio, 4), p_page)
  returning id into v_id;
  return v_id;
end $$;
```

- [ ] **Passo 2:** as contagens de presença (usadas pelo `set_rsvp` e pelos resumos) entram antes das RPCs, na seção
  de ajudantes da Tarefa 6; para a Tarefa 4 rodar sozinha, escrever já o `private.rsvp_counts` daquela tarefa.
- [ ] **Passo 3:** os privilégios (seção 10 da Tarefa 6) entram já, para as RPCs serem chamáveis.
- [ ] **Passo 4:** rodar o 21 até todos passarem. Commit `feat(clubes): o núcleo do clube no servidor (G21.1)`
  com o teste e a migração.

### Tarefa 5: o mundo do clube e os testes dos resumos (RED)

**Arquivos:** `supabase/tests/database/_mundo_clube.psql`, `supabase/tests/database/22_clubes_resumos.test.sql` (novos)

- [ ] **Passo 1:** o mundo (os números das pranchas 04, 31, 32 e 70):

```sql
-- O mundo do clube (pranchas 04, 31, 32 e 70–73; docs/progresso/G21.md, Prova): as Leitoras de Capitu lendo o
-- Dom Casmurro em 6 semanas, vistas pela Marina. Datas relativas a now(): o encontro da semana 2 é daqui a 4 dias
-- ("em 4 dias"); a Marina leu tudo até 45 min atrás. Roda como postgres (sem RLS): dentro da transação do pgTAP
-- (\ir) ou antes da integração do app (psql).
-- Ids: 00000c10NNNN as leitoras (0001 Ana … 0011 Helô); 00000c200001 o clube; 00000c300001 a leitura;
-- 00000c4000NN os encontros (NN = a semana); 00000c5000NN as perguntas; 00000c6000NN os grifos;
-- 00000c7000NN as respostas da pergunta da semana 2; 00000c0a00NN o catálogo.

insert into catalog.authors (id, name) values ('00000000-0000-7000-8000-00000c0a0001', 'Machado de Assis');
insert into catalog.works (id, title) values ('00000000-0000-7000-8000-00000c0a0002', 'Dom Casmurro');
insert into catalog.work_authors (work_id, author_id)
values ('00000000-0000-7000-8000-00000c0a0002', '00000000-0000-7000-8000-00000c0a0001');
insert into catalog.editions (id, work_id, isbn13, title, pages, cover_ref, source) values
  ('00000000-0000-7000-8000-00000c0a0003', '00000000-0000-7000-8000-00000c0a0002', '9788535902778', 'Dom Casmurro',
   256, 'ol:8231432', 'manual'),
  ('00000000-0000-7000-8000-00000c0a0004', '00000000-0000-7000-8000-00000c0a0002', '9788508140912', 'Dom Casmurro',
   208, null, 'manual');

create function pg_temp.leitora(n integer) returns uuid language sql immutable as $$
  select ('00000000-0000-7000-8000-00000c10' || lpad(n::text, 4, '0'))::uuid
$$;

insert into auth.users (id, email)
select pg_temp.leitora(u.n::integer), u.e || '@mundo.clube'
  from unnest(array['ana','julia','marina','lu','rafa','bia','carol','dani','fe','gabi','helo']) with ordinality as u(e, n);
update public.profiles p set display_name = u.nome, handle = u.e || '_clube'
  from unnest(array['ana','julia','marina','lu','rafa','bia','carol','dani','fe','gabi','helo'],
              array['Ana','Júlia','Marina','Lu','Rafa','Bia','Carol','Dani','Fê','Gabi','Helô'])
       with ordinality as u(e, nome, n)
 where p.id = pg_temp.leitora(u.n::integer);
insert into private.account_age (user_id, band, source)
select pg_temp.leitora(n), '18_plus', 'birthdate' from generate_series(1, 11) n;

insert into public.clubs (id, owner_id, name, name_highlight, category, color, work_id, edition_id, privacy,
                          meeting_weekday, meeting_time, meeting_minutes, meeting_mode, timezone)
values ('00000000-0000-7000-8000-00000c200001', pg_temp.leitora(1), 'Leitoras de Capitu', 'Capitu',
        'Clássicos brasileiros', '#FFC1C6', '00000000-0000-7000-8000-00000c0a0002',
        '00000000-0000-7000-8000-00000c0a0003', 'invite', 4, '20:00', 90, 'online', 'America/Sao_Paulo');

-- as 11 leitoras na ordem de chegada (a Ana entrou pelo gatilho do clube), a cor e onde cada uma está (prancha 32)
update public.club_members set joined_at = now() - interval '30 days', progress_ratio = 0.64, progress_chapter = 30
 where club_id = '00000000-0000-7000-8000-00000c200001' and user_id = pg_temp.leitora(1);
insert into public.club_members (club_id, user_id, color, progress_ratio, progress_chapter, joined_at,
                                 last_read_post_at)
select '00000000-0000-7000-8000-00000c200001', pg_temp.leitora(v.n), v.cor, v.ratio, v.cap,
       now() - interval '30 days' + v.n * interval '1 hour',
       case when v.n = 3 then now() - interval '45 minutes' end
  from (values (2, '#ABCF82', 0.67, 34), (3, '#FED170', 0.62, 32), (4, '#FFC1C6', 0.63, 33),
               (5, '#FFFAF1', 0.78, 41), (6, '#058CD7', 0.58, 30), (7, '#FFC1C6', 0.55, 28),
               (8, '#FFFAF1', 0.46, 24), (9, '#F2A815', 0.40, 21), (10, '#ABCF82', 0.38, 20),
               (11, '#058CD7', 0.20, 10)) as v(n, cor, ratio, cap);

insert into public.club_readings (id, club_id, work_id, edition_id, status, starts_on, weeks)
values ('00000000-0000-7000-8000-00000c300001', '00000000-0000-7000-8000-00000c200001',
        '00000000-0000-7000-8000-00000c0a0002', '00000000-0000-7000-8000-00000c0a0003', 'current',
        current_date - 10, 6);
insert into public.club_weeks (reading_id, club_id, week_no, from_chapter, to_chapter)
select '00000000-0000-7000-8000-00000c300001', '00000000-0000-7000-8000-00000c200001', v.n, v.de, v.ate
  from (values (1, 1, 25), (2, 26, 50), (3, 51, 75), (4, 76, 100), (5, 101, 125), (6, 126, 148)) as v(n, de, ate);
insert into public.club_meetings (id, club_id, reading_id, week_no, starts_at, ends_at, mode, timezone, created_by)
select ('00000000-0000-7000-8000-00000c4000' || lpad(k::text, 2, '0'))::uuid, '00000000-0000-7000-8000-00000c200001',
       '00000000-0000-7000-8000-00000c300001', k, b.t + (k - 2) * interval '7 days',
       b.t + (k - 2) * interval '7 days' + interval '90 minutes', 'online', 'America/Sao_Paulo', pg_temp.leitora(1)
  from generate_series(1, 6) k,
       (select ((current_date + 4) + time '20:00') at time zone 'America/Sao_Paulo' as t) b;

-- "8 confirmadas · 3 talvez" (prancha 04): a Lu, a Dani e a Helô talvez
insert into public.meeting_rsvps (meeting_id, user_id, club_id, answer)
select '00000000-0000-7000-8000-00000c400002', pg_temp.leitora(n), '00000000-0000-7000-8000-00000c200001',
       case when n in (4, 8, 11) then 'talvez' else 'vou' end
  from generate_series(1, 11) n;

-- as perguntas: a da semana 1 (já conversada) e as 4 da semana 2 na ordem da Ana (prancha 70)
insert into public.club_posts (id, club_id, author_id, kind, chapter_index, reading_id, week_no, position, status,
                               body, created_at)
select ('00000000-0000-7000-8000-00000c5000' || lpad(v.n::text, 2, '0'))::uuid, '00000000-0000-7000-8000-00000c200001',
       pg_temp.leitora(v.quem), 'question', v.cap - 1, '00000000-0000-7000-8000-00000c300001', v.semana, v.pos, v.estado,
       v.texto, now() - v.quando
  from (values (1, 1, 25, 1, 1, 'discussed', 'O que vocês acharam do começo?', interval '12 days'),
               (2, 1, 50, 2, 1, 'open', 'Bentinho é um narrador confiável?', interval '3 days'),
               (3, 2, 50, 2, 2, 'open', 'Os “olhos de ressaca”: é amor ou é medo?', interval '3 days'),
               (4, 5, 50, 2, 3, 'open', 'O que o José Dias ganha mexendo na vida dos outros?', interval '2 days'),
               (5, 6, 50, 2, 4, 'open', 'Por que a Capitu sempre pensa mais rápido que o Bentinho?', interval '2 days'))
       as v(n, quem, cap, semana, pos, estado, texto, quando);

-- semana 1: 44 respostas na pergunta (de 11 a 7 dias atrás)
insert into public.club_post_replies (post_id, author_id, body, created_at)
select '00000000-0000-7000-8000-00000c500001', pg_temp.leitora((i % 11) + 1), 'Comentário ' || i || ' da semana 1.',
       now() - interval '11 days' + i * interval '2 hours'
  from generate_series(1, 44) i;

-- semana 2: as 12 respostas da pergunta da semana (prancha 31). Depois do lido da Marina (45 min): a Lu e as duas
-- filhas da Júlia = "3 novas"; a da Marina (20 min) é dela.
insert into public.club_post_replies (id, post_id, author_id, parent_reply_id, body, quote_text, quote_color,
                                      quote_page, spoiler_ratio, spoiler_page, created_at)
select ('00000000-0000-7000-8000-00000c7000' || lpad(v.n::text, 2, '0'))::uuid, '00000000-0000-7000-8000-00000c500002',
       pg_temp.leitora(v.quem),
       case when v.pai is not null then ('00000000-0000-7000-8000-00000c7000' || lpad(v.pai::text, 2, '0'))::uuid end,
       v.texto, v.trecho, v.cor, v.pag, v.ratio, v.spag, now() - v.quando
  from (values
    (1, 2, null::int, 'Acho que não. Ele conta tudo velho, sozinho e cheio de ciúme. A memória dele já chega torta.',
        null::text, null::text, null::int, 0.58, 149, interval '2 hours'),
    (2, 1, null, 'Repara que quem fala dos “olhos de cigana” é o José Dias, não o Bentinho. Ele só repete.',
        'olhos de cigana oblíqua e dissimulada.', '#B6ACE4', 121, 0.60, 154, interval '1 hour'),
    (3, 3, null, 'E depois ele mesmo inventa os “olhos de ressaca”. A imagem é dele!',
        'Olhos de ressaca? Vá, de ressaca.', '#FED170', 159, 0.62, 159, interval '20 minutes'),
    (4, 5, null, 'Esperem só até o capítulo do enterro, aí vocês vão entender por que eu acho que ele inventa metade.',
        null, null, null, 0.78, 201, interval '50 minutes'),
    (5, 4, null, 'Narrador de memória é sempre suspeito. Mas eu gosto de duvidar junto com ele.',
        null, null, null, 0.55, 141, interval '35 minutes'),
    (6, 6, null, 'Eu acredito nele até o capítulo da Capitu na janela.', null, null, null, 0.50, 128, interval '5 hours'),
    (7, 7, null, 'Ele é honesto sobre ser desonesto.', null, null, null, 0.52, 133, interval '4 hours 30 minutes'),
    (8, 8, null, 'Ainda não sei. Volto quando chegar no 50.', null, null, null, 0.40, 102, interval '4 hours'),
    (9, 9, null, 'Confiável para contar o que sentiu, não o que aconteceu.', null, null, null, 0.38, 97,
        interval '3 hours 30 minutes'),
    (10, 10, null, 'A pergunta é se algum narrador é confiável.', null, null, null, 0.36, 92, interval '3 hours'),
    (11, 1, 1, 'Concordo com a memória torta.', null, null, null, 0.60, 154, interval '30 minutes'),
    (12, 6, 1, 'E o ciúme pinta tudo.', null, null, null, 0.50, 128, interval '25 minutes'))
    as v(n, quem, pai, texto, trecho, cor, pag, ratio, spag, quando);

-- os grifos compartilhados: o trecho dos "olhos de cigana" por 7 leitoras (a Ana por último, ontem — o destaque da
-- prancha 04) e o "Capitu era Capitu" da Marina (o chip "Leitoras de Capitu · 3 respostas" da 25)
insert into public.club_posts (id, club_id, author_id, kind, chapter_index, ref_page, quote_text, quote_color,
                               reading_id, week_no, spoiler_ratio, spoiler_page, created_at)
select ('00000000-0000-7000-8000-00000c6000' || lpad(v.n::text, 2, '0'))::uuid, '00000000-0000-7000-8000-00000c200001',
       pg_temp.leitora(v.quem), 'shared_highlight', v.cap - 1, v.pag, v.trecho, v.cor,
       '00000000-0000-7000-8000-00000c300001', v.semana, v.ratio, v.pag, now() - v.quando
  from (values
    (1, 1, 25, 121, '…olhos de cigana oblíqua e dissimulada.', '#B6ACE4', 1, 0.47, interval '1 day'),
    (2, 2, 25, 121, 'olhos de cigana oblíqua e dissimulada', '#ABCF82', 1, 0.47, interval '3 days'),
    (3, 4, 25, 121, 'Olhos de cigana oblíqua e dissimulada.', '#FFC1C6', 1, 0.47, interval '3 days'),
    (4, 5, 25, 121, '"olhos de cigana oblíqua e dissimulada"', '#FFFAF1', 1, 0.47, interval '2 days 20 hours'),
    (5, 6, 25, 121, 'olhos de cigana, oblíqua e dissimulada', '#058CD7', 1, 0.47, interval '2 days 18 hours'),
    (6, 7, 25, 121, 'OLHOS DE CIGANA OBLÍQUA E DISSIMULADA', '#FFC1C6', 1, 0.47, interval '2 days 12 hours'),
    (7, 9, 25, 121, 'olhos de cigana obliqua e dissimulada...', '#F2A815', 1, 0.47, interval '2 days 6 hours'),
    (8, 3, 32, 152, 'Capitu era Capitu, isto é, uma criatura mui particular, mais mulher do que eu era homem.',
        '#FFC1C6', 2, 0.59, interval '2 days'))
    as v(n, quem, cap, pag, trecho, cor, semana, ratio, quando);

-- as respostas aos grifos: 4 no da Ana (prancha 04, 💬4) e 3 no da Marina (o chip da 25)
insert into public.club_post_replies (post_id, author_id, body, created_at)
select ('00000000-0000-7000-8000-00000c6000' || lpad(v.post::text, 2, '0'))::uuid, pg_temp.leitora(v.quem), v.texto,
       now() - v.quando
  from (values (1, 2, 'Esse trecho é o livro inteiro.', interval '20 hours'),
               (1, 4, 'O José Dias de novo!', interval '19 hours'),
               (1, 5, 'E a gente cai junto.', interval '18 hours'),
               (1, 6, 'Marquei também.', interval '17 hours'),
               (8, 1, 'Levar para o encontro de quinta.', interval '1 day 4 hours'),
               (8, 2, 'Essa frase!', interval '1 day 3 hours'),
               (8, 5, 'Mais mulher do que eu era homem, que frase.', interval '1 day 2 hours')) as v(post, quem, texto, quando);

-- as curtidas: ♥9 no grifo da Ana; na prancha 31, 9 na Júlia, 6 na Ana, 2 na Marina, 1 no Rafa e 4 na Lu
create function pg_temp.curtir(p_tipo text, p_alvo uuid, p_quantas integer, p_autora integer) returns void
language sql as $$
  insert into public.club_likes (target_type, target_id, user_id)
  select p_tipo, p_alvo, pg_temp.leitora(n) from generate_series(1, 11) n where n <> p_autora order by n limit p_quantas
$$;
select pg_temp.curtir('post', '00000000-0000-7000-8000-00000c600001', 9, 1);
select pg_temp.curtir('reply', '00000000-0000-7000-8000-00000c700001', 9, 2);
select pg_temp.curtir('reply', '00000000-0000-7000-8000-00000c700002', 6, 1);
select pg_temp.curtir('reply', '00000000-0000-7000-8000-00000c700003', 2, 3);
select pg_temp.curtir('reply', '00000000-0000-7000-8000-00000c700004', 1, 5);
select pg_temp.curtir('reply', '00000000-0000-7000-8000-00000c700005', 4, 4);
```

- [ ] **Passo 2:** o teste dos resumos, como a Marina:

```sql
-- G21.1 — os resumos do clube (docs/progresso/G21.md §1, R4–R6, R11, R12): cada número das pranchas 04, 31, 32 e
-- 70 sai do mundo do clube, e as telas concordam entre si (as mesmas 11 leitoras, o mesmo % do grupo, as mesmas
-- presenças, a mesma meta). O bloqueio some com o que a pessoa escreveu e as contagens descem junto (D-223).
begin;
create extension if not exists pgtap with schema extensions;
select plan(41);
\ir _mundo_clube.psql

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
create temp table r (nome text primary key, j jsonb) on commit drop;
grant all on r to authenticated;

set local role authenticated;
select pg_temp.como(pg_temp.leitora(3));   -- a Marina
insert into r values
  ('meus', public.my_clubs()),
  ('clube', public.club_overview('00000000-0000-7000-8000-00000c200001')),
  ('fio', public.week_thread('00000000-0000-7000-8000-00000c200001', 2)),
  ('encontro', public.meeting_overview('00000000-0000-7000-8000-00000c400002')),
  ('membros', public.club_members_overview('00000000-0000-7000-8000-00000c200001')),
  ('chips', public.club_post_summaries(array['00000000-0000-7000-8000-00000c600008',
                                             '00000000-0000-7000-8000-00000c600001',
                                             '00000000-0000-7000-8000-0000000000ff']::uuid[]));
create function pg_temp.x(p text) returns jsonb language sql as $$ select j from r where nome = p $$;
create function pg_temp.iniciais(p jsonb) returns text language sql as $$
  select string_agg(e ->> 'initial', '' order by o) from jsonb_array_elements(p) with ordinality as a(e, o)
$$;

-- ---------------------------------------------------------------- my_clubs (o ticket, a faixa, a folha)
select is(jsonb_array_length(pg_temp.x('meus')), 1, 'a Marina está num clube');
select is(pg_temp.x('meus') -> 0 ->> 'members_count', '11', '11 leitoras');
select is(pg_temp.x('meus') -> 0 -> 'participants',
  '[{"initial": "A", "color": "#B6ACE4"}, {"initial": "J", "color": "#ABCF82"}, {"initial": "L", "color": "#FFC1C6"}]',
  'as 3 primeiras sem mim: a anfitriã e depois a ordem de chegada (A J L)');
select is(pg_temp.x('meus') -> 0 -> 'me', '{"initial": "M", "color": "#FED170"}', 'eu: M, amarelo');
select is(pg_temp.x('meus') -> 0 -> 'reading' ->> 'title', 'Dom Casmurro', 'o livro');
select is(pg_temp.x('meus') -> 0 -> 'reading' ->> 'author', 'Machado de Assis', 'a autora do livro (o autor)');
select is(pg_temp.x('meus') -> 0 -> 'reading' -> 'isbns', '["9788508140912", "9788535902778"]',
  'os ISBN-13 das edições da obra (D-213)');
select is(pg_temp.x('meus') -> 0 -> 'reading' -> 'current_week',
  '{"no": 2, "from": 26, "to": 50, "from_label": null, "to_label": null}', 'a semana atual é a do próximo encontro (R4)');
select is(pg_temp.x('meus') -> 0 -> 'next_meeting' -> 'counts', '{"vou": 8, "talvez": 3, "nao_vou": 0}',
  '8 confirmadas · 3 talvez');
select is(pg_temp.x('meus') -> 0 -> 'next_meeting' ->> 'mine', 'vou', 'eu vou');
select is((pg_temp.x('meus') -> 0 ->> 'group_progress')::numeric, 0.5373, 'Grupo 54% (R5)');
select is((pg_temp.x('meus') -> 0 ->> 'my_progress')::numeric, 0.62, 'Você 62%');
select is(pg_temp.x('meus') -> 0 ->> 'unread', '3', '3 não lidas (R6)');

-- ---------------------------------------------------------------- club_overview (a 04)
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 0 ->> 'comments', '48', 'semana 1: 48 comentários');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 0 ->> 'new', '0', 'semana 1: nada novo');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 1 ->> 'new', '3', 'semana 2: 3 novos');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 1 -> 'question' ->> 'body',
  'Bentinho é um narrador confiável?', 'a pergunta da semana');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 1 -> 'question' -> 'author' ->> 'host', 'true',
  'PERGUNTA DA SEMANA · ANA (a anfitriã)');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 1 -> 'question' ->> 'replies', '12', '12 respostas');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 2 -> 'question', 'null', 'a semana 3 sem pergunta ainda');
select is(pg_temp.iniciais(pg_temp.x('clube') -> 'members'), 'RJALMBCDFGH', 'onde cada uma está, da mais à frente');
select is(pg_temp.x('clube') -> 'shared' -> 0 -> 'author' ->> 'name', 'Ana', 'Ana grifou em Dom Casmurro');
select is(pg_temp.x('clube') -> 'shared' -> 0 ->> 'same_passage', '7', '7 leitoras grifaram (R11)');
select is(pg_temp.x('clube') -> 'shared' -> 0 ->> 'likes', '9', '♥9');
select is(pg_temp.x('clube') -> 'shared' -> 0 ->> 'replies', '4', '💬4');

-- ---------------------------------------------------------------- week_thread (a 31)
select is(pg_temp.iniciais((select jsonb_agg(e -> 'author' order by o)
                              from jsonb_array_elements(pg_temp.x('fio') -> 'replies') with ordinality as a(e, o)
                             where o <= 5)),
  'JALMR', 'mais curtidas: Júlia 9, Ana 6, Lu 4, Marina 2, Rafa 1');
select is(pg_temp.x('fio') -> 'question' ->> 'new', '3', '12 respostas · 3 novas');
select is(pg_temp.x('fio') -> 'replies' -> 0 ->> 'replies', '2', 'a Júlia tem 2 respostas');
select is(pg_temp.x('fio') -> 'replies' -> 1 -> 'quote' ->> 'page', '121', 'a Ana cita a pág. 121');
select is(pg_temp.x('fio') -> 'replies' -> 4 -> 'spoiler', '{"page": 201, "ratio": 0.78}',
  'o Rafa fala da pág. 201 (D-218)');
select is(pg_temp.x('fio') -> 'replies' -> 3 -> 'author' ->> 'me', 'true', 'a da Marina é minha');
select is(jsonb_array_length(public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null,
            public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null, null, 3) -> 'next_cursor', 3)
            -> 'replies'), 3, 'a 2ª página continua de onde a 1ª parou');
select is((public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null,
            public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null, null, 3) -> 'next_cursor', 3)
            -> 'replies' -> 0 -> 'author' ->> 'name'), 'Marina', 'e começa pela Marina');
select is(pg_temp.iniciais((select jsonb_agg(e -> 'author' order by o) from jsonb_array_elements(
            public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'recent', '00000000-0000-7000-8000-00000c700001')
              -> 'replies') with ordinality as a(e, o))),
  'BA', 'as filhas da Júlia, das mais recentes');

-- ---------------------------------------------------------------- meeting_overview (a 70) e club_members_overview (a 32)
select is(pg_temp.iniciais(pg_temp.x('encontro') -> 'people' -> 'vou'), 'RJAMBCFG', 'vão: Rafa, Júlia, Ana, você…');
select is(pg_temp.iniciais(pg_temp.x('encontro') -> 'people' -> 'talvez'), 'LDH', 'talvez: Lu, Dani e Helô');
select is((select string_agg(left(e ->> 'body', 12), ' | ' order by o)
             from jsonb_array_elements(pg_temp.x('encontro') -> 'questions') with ordinality as a(e, o)),
  'Bentinho é u | Os “olhos de | O que o José | Por que a Ca', 'as perguntas na ordem da Ana');
select is(pg_temp.iniciais(pg_temp.x('membros') -> 'members'), 'RJALMBCDFGH', 'membros, da mais à frente');

-- ---------------------------------------------------------------- relações entre as telas
select is(jsonb_build_array(pg_temp.x('meus') -> 0 -> 'members_count', pg_temp.x('clube') -> 'club' -> 'members_count',
                            to_jsonb(jsonb_array_length(pg_temp.x('membros') -> 'members'))),
  '[11, 11, 11]', 'as mesmas 11 leitoras no ticket, na 04 e na 32');
select is(jsonb_build_array(pg_temp.x('clube') -> 'next_meeting' -> 'counts', pg_temp.x('encontro') -> 'meeting' -> 'counts'),
  '[{"vou": 8, "talvez": 3, "nao_vou": 0}, {"vou": 8, "talvez": 3, "nao_vou": 0}]', 'as mesmas presenças na 04 e na 70');
select is(jsonb_build_array(pg_temp.x('meus') -> 0 -> 'reading' -> 'current_week' -> 'to',
                            pg_temp.x('encontro') -> 'meeting' -> 'agenda' -> 'to'),
  '[50, 50]', 'a mesma meta: o cap. 50 no ticket, na faixa e na pauta');

-- ---------------------------------------------------------------- o chip da 25
select is(pg_temp.x('chips'), '[{"id": "00000000-0000-7000-8000-00000c600001", "club_id": "00000000-0000-7000-8000-00000c200001", "replies": 4, "club_name": "Leitoras de Capitu"}, {"id": "00000000-0000-7000-8000-00000c600008", "club_id": "00000000-0000-7000-8000-00000c200001", "replies": 3, "club_name": "Leitoras de Capitu"}]',
  '"Leitoras de Capitu · 3 respostas"; o post que não existe não volta');

-- ---------------------------------------------------------------- bloqueio (D-223, R12)
insert into public.user_blocks (blocker_id, blocked_id) values (pg_temp.leitora(3), pg_temp.leitora(5));
select is(public.week_thread('00000000-0000-7000-8000-00000c200001', 2) -> 'question' ->> 'replies', '11',
  'bloqueei o Rafa: 11 respostas');
select is(position('R' in pg_temp.iniciais((select jsonb_agg(e -> 'author' order by o) from jsonb_array_elements(
            public.week_thread('00000000-0000-7000-8000-00000c200001', 2) -> 'replies') with ordinality as a(e, o)))),
  0, 'a resposta do Rafa sumiu');
select is(public.club_overview('00000000-0000-7000-8000-00000c200001') -> 'shared' -> 0 ->> 'same_passage', '6',
  '6 leitoras grifaram (sem o Rafa)');
select is(public.club_overview('00000000-0000-7000-8000-00000c200001') -> 'shared' -> 0 ->> 'replies', '3',
  '💬3 (a do Rafa sumiu)');
select is(public.my_clubs() -> 0 ->> 'members_count', '11', 'as leitoras continuam 11 (bloqueio não tira do clube)');

-- ---------------------------------------------------------------- quem não é do clube
select pg_temp.como('00000000-0000-7000-8000-0000000000ff');
select throws_ok($$ select public.club_overview('00000000-0000-7000-8000-00000c200001') $$, '42501', 'not_member',
  'quem não é do clube não vê a 04');
select throws_ok($$ select public.meeting_overview('00000000-0000-7000-8000-00000c400002') $$, '42501', 'not_member',
  'nem o encontro');
select throws_ok($$ select public.week_thread('00000000-0000-7000-8000-00000c200001', 2) $$, '42501', 'not_member',
  'nem a discussão');
select is(public.club_post_summaries(array['00000000-0000-7000-8000-00000c600008']::uuid[]), '[]'::jsonb,
  'nem o chip');
select is(public.my_clubs(), '[]'::jsonb, 'sem clube, a lista vazia');
select set_config('request.jwt.claims', '{"role": "authenticated"}', true);
select throws_ok($$ select public.my_clubs() $$, '28000', 'unauthenticated', 'sem conta, nada');

select * from finish();
rollback;
```

- [ ] **Passo 3:** acertar o `plan(N)` e ver falhar (`function public.my_clubs() does not exist`).

### Tarefa 6: a migração — os resumos

- [ ] **Passo 1:** acrescentar à migração os ajudantes e os 6 resumos:

```sql
-- 9. Resumos (uma ida por tela) ----------------------------------------------------------------

create or replace function private.initial_of(p_name text) returns text
language sql immutable parallel safe set search_path = '' as $$
  select upper(left(btrim(coalesce(p_name, '')), 1))
$$;

-- Quem eu bloqueei e quem me bloqueou (D-223): some dos resumos.
create or replace function private.block_set(p_me uuid) returns uuid[]
language sql stable security definer set search_path = '' as $$
  select coalesce(array_agg(s.x), '{}') from (
    select b.blocked_id as x from public.user_blocks b where b.blocker_id = p_me
    union
    select b.blocker_id from public.user_blocks b where b.blocked_id = p_me) s
$$;

-- O próximo encontro da leitura: o primeiro que ainda não acabou (sem fim marcado, vale 2 h).
create or replace function private.next_meeting_id(p_reading uuid) returns uuid
language sql stable security definer set search_path = '' as $$
  select m.id from public.club_meetings m
   where m.reading_id = p_reading and coalesce(m.ends_at, m.starts_at + interval '2 hours') > now()
   order by m.starts_at limit 1
$$;

-- A semana atual (R4): a do próximo encontro; sem encontro à frente, a última.
create or replace function private.current_week_no(p_reading uuid) returns integer
language sql stable security definer set search_path = '' as $$
  select coalesce(
    (select m.week_no from public.club_meetings m where m.id = private.next_meeting_id(p_reading)),
    (select max(w.week_no) from public.club_weeks w where w.reading_id = p_reading))
$$;

create or replace function private.week_range_json(w public.club_weeks) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object('no', w.week_no, 'from', w.from_chapter, 'to', w.to_chapter,
                            'from_label', w.from_label, 'to_label', w.to_label)
$$;

-- Uma leitora nos resumos. Conta excluída: só {"deleted": true}.
create or replace function private.person_json(p_user uuid, p_club uuid, p_me uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select case when p_user is null then '{"deleted": true}'::jsonb else (
    select jsonb_build_object('id', pr.id, 'name', pr.display_name, 'initial', private.initial_of(pr.display_name),
                              'color', m.color, 'host', coalesce(m.role = 'owner', false), 'me', pr.id = p_me)
      from public.profiles pr
      left join public.club_members m on m.club_id = p_club and m.user_id = pr.id
     where pr.id = p_user) end
$$;

-- Respostas visíveis (R12): o contador menos as de quem está bloqueado.
create or replace function private.visible_replies(p_post uuid, p_count integer, p_blocks uuid[]) returns integer
language sql stable security definer set search_path = '' as $$
  select case when cardinality(p_blocks) = 0 then p_count else p_count - (
    select count(*)::integer from public.club_post_replies r
     where r.post_id = p_post and r.deleted_at is null and r.author_id = any(p_blocks)) end
$$;
create or replace function private.visible_children(p_reply uuid, p_count integer, p_blocks uuid[]) returns integer
language sql stable security definer set search_path = '' as $$
  select case when cardinality(p_blocks) = 0 then p_count else p_count - (
    select count(*)::integer from public.club_post_replies r
     where r.parent_reply_id = p_reply and r.deleted_at is null and r.author_id = any(p_blocks)) end
$$;

-- Não lidas (R6): posts e respostas de outras pessoas, não apagados nem bloqueados, depois de p_since.
-- Com p_reading e p_week: só os da semana.
create or replace function private.club_unread(p_club uuid, p_me uuid, p_since timestamptz, p_blocks uuid[],
  p_reading uuid default null, p_week integer default null) returns integer
language sql stable security definer set search_path = '' as $$
  select ((select count(*) from public.club_posts p
            where p.club_id = p_club and p.deleted_at is null and p.created_at > p_since
              and p.author_id is distinct from p_me and coalesce(p.author_id <> all(p_blocks), true)
              and (p_week is null or (p.reading_id = p_reading and p.week_no = p_week)))
        + (select count(*) from public.club_post_replies r join public.club_posts p on p.id = r.post_id
            where r.club_id = p_club and r.deleted_at is null and p.deleted_at is null and r.created_at > p_since
              and r.author_id <> p_me and r.author_id <> all(p_blocks)
              and coalesce(p.author_id <> all(p_blocks), true)
              and (p_week is null or (p.reading_id = p_reading and p.week_no = p_week))))::integer
$$;

-- % do grupo (R5): a média das frações publicadas.
create or replace function private.group_progress(p_club uuid) returns numeric
language sql stable security definer set search_path = '' as $$
  select round(avg(m.progress_ratio), 4) from public.club_members m
   where m.club_id = p_club and m.progress_ratio is not null
$$;

create or replace function private.rsvp_counts(p_meeting uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('vou', count(*) filter (where x.answer = 'vou'),
                            'talvez', count(*) filter (where x.answer = 'talvez'),
                            'nao_vou', count(*) filter (where x.answer = 'nao_vou'))
    from public.meeting_rsvps x
    join public.club_members cm on cm.club_id = x.club_id and cm.user_id = x.user_id
   where x.meeting_id = p_meeting
$$;

-- O livro da leitura (D-213: a obra, a edição e os ISBN-13 das edições da obra, até 50) e a semana atual.
create or replace function private.reading_json(p_reading uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', r.id, 'work_id', r.work_id, 'edition_id', r.edition_id,
    'isbns', coalesce((select jsonb_agg(x.isbn13 order by x.isbn13) from (
                         select e2.isbn13 from catalog.editions e2
                          where e2.isbn13 is not null
                            and (e2.id = r.edition_id or (r.work_id is not null and e2.work_id = r.work_id))
                          order by (e2.id = r.edition_id) desc, e2.isbn13 limit 50) x), '[]'::jsonb),
    'title', coalesce(e.title, w.title),
    'author', (select a.name from catalog.work_authors wa join catalog.authors a on a.id = wa.author_id
                where wa.work_id = r.work_id order by wa.position, a.name limit 1),
    'cover_ref', e.cover_ref, 'isbn13', e.isbn13, 'pages', e.pages, 'weeks', r.weeks,
    'current_week', (select private.week_range_json(cw) from public.club_weeks cw
                      where cw.reading_id = r.id and cw.week_no = private.current_week_no(r.id)))
    from public.club_readings r
    left join catalog.editions e on e.id = r.edition_id
    left join catalog.works w on w.id = r.work_id
   where r.id = p_reading
$$;

-- Um encontro: quando, o modo, a pauta (a semana), as contagens e a minha presença.
create or replace function private.meeting_json(p_meeting uuid, p_me uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', m.id, 'starts_at', m.starts_at, 'ends_at', m.ends_at, 'mode', m.mode, 'timezone', m.timezone,
    'location', m.location, 'week_no', m.week_no, 'weeks', r.weeks,
    'agenda', (select private.week_range_json(w) from public.club_weeks w
                where w.reading_id = m.reading_id and w.week_no = m.week_no),
    'counts', private.rsvp_counts(m.id),
    'mine', (select x.answer from public.meeting_rsvps x where x.meeting_id = m.id and x.user_id = p_me))
    from public.club_meetings m left join public.club_readings r on r.id = m.reading_id
   where m.id = p_meeting
$$;

create or replace function private.question_json(q public.club_posts, p_me uuid, p_blocks uuid[],
  p_since timestamptz) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('id', q.id, 'body', q.body, 'position', q.position, 'status', q.status,
    'host_note', q.host_note, 'week_no', q.week_no, 'author', private.person_json(q.author_id, q.club_id, p_me),
    'likes', q.likes_count, 'replies', private.visible_replies(q.id, q.replies_count, p_blocks),
    'new', (select count(*)::integer from public.club_post_replies r
             where r.post_id = q.id and r.deleted_at is null and r.created_at > p_since
               and r.author_id <> p_me and r.author_id <> all(p_blocks)))
$$;

create or replace function private.spoiler_json(p_ratio numeric, p_page integer) returns jsonb
language sql immutable set search_path = '' as $$
  select case when p_ratio is null then null else jsonb_build_object('ratio', p_ratio, 'page', p_page) end
$$;

create or replace function private.shared_json(p public.club_posts, p_me uuid, p_blocks uuid[]) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('id', p.id, 'author', private.person_json(p.author_id, p.club_id, p_me),
    'quote_text', p.quote_text, 'quote_color', p.quote_color, 'ref_page', p.ref_page,
    'chapter', p.chapter_index + 1, 'week_no', p.week_no, 'created_at', p.created_at,
    'same_passage', (select count(distinct s.author_id)::integer from public.club_posts s
                      where s.reading_id = p.reading_id and s.quote_key = p.quote_key and s.kind = 'shared_highlight'
                        and s.deleted_at is null and s.author_id <> all(p_blocks)),
    'likes', p.likes_count,
    'liked', exists (select 1 from public.club_likes l
                      where l.target_type = 'post' and l.target_id = p.id and l.user_id = p_me),
    'replies', private.visible_replies(p.id, p.replies_count, p_blocks),
    'spoiler', private.spoiler_json(p.spoiler_ratio, p.spoiler_page))
$$;

create or replace function private.reply_json(r public.club_post_replies, p_me uuid, p_blocks uuid[]) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('id', r.id, 'parent_id', r.parent_reply_id,
    'author', private.person_json(r.author_id, r.club_id, p_me), 'created_at', r.created_at, 'body', r.body,
    'likes', r.likes_count,
    'liked', exists (select 1 from public.club_likes l
                      where l.target_type = 'reply' and l.target_id = r.id and l.user_id = p_me),
    'replies', private.visible_children(r.id, r.replies_count, p_blocks),
    'quote', case when r.quote_text is null then null
                  else jsonb_build_object('text', r.quote_text, 'color', r.quote_color, 'page', r.quote_page) end,
    'spoiler', private.spoiler_json(r.spoiler_ratio, r.spoiler_page))
$$;

create or replace function private.week_card_json(w public.club_weeks, p_me uuid, p_blocks uuid[],
  p_since timestamptz) returns jsonb
language sql stable security definer set search_path = '' as $$
  select private.week_range_json(w) || jsonb_build_object(
    'comments', (select count(*)::integer from public.club_post_replies r join public.club_posts p on p.id = r.post_id
                  where p.reading_id = w.reading_id and p.week_no = w.week_no and p.deleted_at is null
                    and r.deleted_at is null and r.author_id <> all(p_blocks)
                    and coalesce(p.author_id <> all(p_blocks), true)),
    'new', private.club_unread(w.club_id, p_me, p_since, p_blocks, w.reading_id, w.week_no),
    'question', (select private.question_json(q, p_me, p_blocks, p_since) from public.club_posts q
                  where q.reading_id = w.reading_id and q.week_no = w.week_no and q.kind = 'question'
                    and q.deleted_at is null and coalesce(q.author_id <> all(p_blocks), true)
                  order by q.position nulls last, q.created_at, q.id limit 1))
$$;

-- Os meus clubes (o ticket da Início, a faixa do sumário, a folha "Compartilhar em…").
create or replace function public.my_clubs() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[];
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  v_blocks := private.block_set(v_me);
  return coalesce((
    select jsonb_agg(s.card order by s.activity desc nulls last, s.name)
      from (
        select c.name, la.activity, jsonb_build_object(
          'id', c.id, 'name', c.name, 'name_highlight', c.name_highlight, 'category', c.category, 'color', c.color,
          'role', mi.role, 'privacy', c.privacy, 'spoiler_protection', c.spoiler_protection,
          'members_count', (select count(*) from public.club_members x where x.club_id = c.id),
          'participants', coalesce((
             select jsonb_agg(jsonb_build_object('initial', private.initial_of(pr.display_name), 'color', p.color)
                              order by p.ord)
               from (select x.user_id, x.color,
                            row_number() over (order by (x.role = 'owner') desc, x.joined_at, x.user_id) as ord
                       from public.club_members x
                      where x.club_id = c.id and x.user_id <> v_me and x.user_id <> all(v_blocks)
                      order by ord limit 3) p
               join public.profiles pr on pr.id = p.user_id), '[]'::jsonb),
          'me', (select jsonb_build_object('initial', private.initial_of(pr.display_name), 'color', mi.color)
                   from public.profiles pr where pr.id = v_me),
          'reading', (select private.reading_json(r.id) from public.club_readings r
                       where r.club_id = c.id and r.status = 'current'),
          'next_meeting', (select private.meeting_json(private.next_meeting_id(r.id), v_me)
                            from public.club_readings r where r.club_id = c.id and r.status = 'current'),
          'my_progress', mi.progress_ratio,
          'group_progress', private.group_progress(c.id),
          'unread', private.club_unread(c.id, v_me, coalesce(mi.last_read_post_at, mi.joined_at), v_blocks),
          'last_activity_at', la.activity) as card
          from public.club_members mi
          join public.clubs c on c.id = mi.club_id
          left join lateral (
            select greatest(
              (select max(p.created_at) from public.club_posts p where p.club_id = c.id and p.deleted_at is null),
              (select max(r.created_at) from public.club_post_replies r
                where r.club_id = c.id and r.deleted_at is null)) as activity) la on true
         where mi.user_id = v_me) s), '[]'::jsonb);
end $$;

-- A 04.
create or replace function public.club_overview(p_club uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[]; v_m public.club_members; v_reading uuid;
        v_since timestamptz;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select * into v_m from public.club_members where club_id = p_club and user_id = v_me;
  if not found then raise exception 'not_member' using errcode = '42501'; end if;
  v_blocks := private.block_set(v_me);
  v_since := coalesce(v_m.last_read_post_at, v_m.joined_at);
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  return jsonb_build_object(
    'club', (select jsonb_build_object('id', c.id, 'name', c.name, 'name_highlight', c.name_highlight,
               'category', c.category, 'color', c.color, 'privacy', c.privacy, 'progress_colors', c.progress_colors,
               'spoiler_protection', c.spoiler_protection, 'role', v_m.role,
               'members_count', (select count(*) from public.club_members x where x.club_id = c.id))
               from public.clubs c where c.id = p_club),
    'reading', case when v_reading is not null then private.reading_json(v_reading) || jsonb_build_object(
      'weeks_list', (select jsonb_agg(private.week_card_json(w, v_me, v_blocks, v_since) order by w.week_no)
                       from public.club_weeks w where w.reading_id = v_reading)) end,
    'next_meeting', case when v_reading is not null then private.meeting_json(private.next_meeting_id(v_reading), v_me) end,
    'members', (select jsonb_agg(jsonb_build_object('user_id', x.user_id, 'initial', private.initial_of(pr.display_name),
                  'color', x.color, 'ratio', x.progress_ratio, 'me', x.user_id = v_me)
                  order by x.progress_ratio desc nulls last, x.joined_at)
                  from public.club_members x join public.profiles pr on pr.id = x.user_id where x.club_id = p_club),
    'my_progress', v_m.progress_ratio,
    'group_progress', private.group_progress(p_club),
    'unread', private.club_unread(p_club, v_me, v_since, v_blocks),
    'shared', coalesce((select jsonb_agg(private.shared_json(p, v_me, v_blocks) order by p.created_at desc, p.id desc)
                 from (select * from public.club_posts p
                        where p.club_id = p_club and p.kind = 'shared_highlight' and p.deleted_at is null
                          and coalesce(p.author_id <> all(v_blocks), true)
                        order by p.created_at desc, p.id desc limit 5) p), '[]'::jsonb));
end $$;

-- A 31: a pergunta da semana e as respostas (p_parent: as filhas de uma resposta), por keyset.
create or replace function public.week_thread(p_club uuid, p_week integer, p_order text default 'likes',
  p_parent uuid default null, p_cursor jsonb default null, p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[]; v_m public.club_members; v_reading uuid;
        v_q public.club_posts; v_rows jsonb; v_next jsonb;
        v_limit integer := least(greatest(coalesce(p_limit, 30), 1), 100);
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select * into v_m from public.club_members where club_id = p_club and user_id = v_me;
  if not found then raise exception 'not_member' using errcode = '42501'; end if;
  if p_order is null or p_order not in ('likes','recent') then
    raise exception 'invalid_order' using errcode = '22023';
  end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  if not exists (select 1 from public.club_weeks w where w.reading_id = v_reading and w.week_no = p_week) then
    raise exception 'invalid_week' using errcode = '22023';
  end if;
  v_blocks := private.block_set(v_me);
  select * into v_q from public.club_posts q
   where q.reading_id = v_reading and q.week_no = p_week and q.kind = 'question' and q.deleted_at is null
     and coalesce(q.author_id <> all(v_blocks), true)
   order by q.position nulls last, q.created_at, q.id limit 1;
  if v_q.id is not null then
    with page as (
      select r, row_number() over (order by case when p_order = 'likes' then r.likes_count end desc nulls last,
                                            r.created_at desc, r.id desc) as n
        from public.club_post_replies r
       where r.post_id = v_q.id and r.deleted_at is null and r.author_id <> all(v_blocks)
         and r.parent_reply_id is not distinct from p_parent
         and (p_cursor is null or case when p_order = 'likes'
               then (r.likes_count, r.created_at, r.id) < ((p_cursor ->> 'likes')::integer,
                     (p_cursor ->> 'created_at')::timestamptz, (p_cursor ->> 'id')::uuid)
               else (r.created_at, r.id) < ((p_cursor ->> 'created_at')::timestamptz, (p_cursor ->> 'id')::uuid) end)
       order by n limit v_limit + 1)
    select coalesce(jsonb_agg(private.reply_json(p.r, v_me, v_blocks) order by p.n) filter (where p.n <= v_limit),
                    '[]'::jsonb),
           case when max(p.n) > v_limit then (
             select jsonb_build_object('likes', (q.r).likes_count, 'created_at', (q.r).created_at, 'id', (q.r).id)
               from page q where q.n = v_limit) end
      into v_rows, v_next
      from page p;
  end if;
  return jsonb_build_object(
    'week', (select private.week_range_json(w) from public.club_weeks w
              where w.reading_id = v_reading and w.week_no = p_week),
    'question', case when v_q.id is not null then
      private.question_json(v_q, v_me, v_blocks, coalesce(v_m.last_read_post_at, v_m.joined_at)) end,
    'replies', coalesce(v_rows, '[]'::jsonb),
    'next_cursor', v_next);
end $$;

-- As 70, 72 e 73.
create or replace function public.meeting_overview(p_meeting uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[]; v_mt public.club_meetings; v_host boolean;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select * into v_mt from public.club_meetings where id = p_meeting;
  if not found or not private.is_club_member(v_mt.club_id) then
    raise exception 'not_member' using errcode = '42501';
  end if;
  v_blocks := private.block_set(v_me);
  v_host := private.is_club_admin(v_mt.club_id);
  return jsonb_build_object(
    'meeting', private.meeting_json(p_meeting, v_me) || jsonb_build_object(
       'club_id', v_mt.club_id,
       'club_name', (select c.name from public.clubs c where c.id = v_mt.club_id),
       'book_title', (select coalesce(e.title, w.title) from public.club_readings r
                        left join catalog.editions e on e.id = r.edition_id
                        left join catalog.works w on w.id = r.work_id where r.id = v_mt.reading_id)),
    'host', (select private.person_json(c.owner_id, c.id, v_me) from public.clubs c where c.id = v_mt.club_id),
    'mine', jsonb_build_object(
       'answer', (select x.answer from public.meeting_rsvps x where x.meeting_id = p_meeting and x.user_id = v_me),
       'note', (select jsonb_build_object('body', n.body, 'visibility', n.visibility) from public.meeting_notes n
                 where n.meeting_id = p_meeting and n.user_id = v_me)),
    'people', coalesce((select jsonb_object_agg(a.answer, a.people) from (
       select x.answer, jsonb_agg(private.person_json(x.user_id, x.club_id, v_me)
                                  || jsonb_build_object('ratio', cm.progress_ratio)
                                  order by cm.progress_ratio desc nulls last, cm.joined_at) as people
         from public.meeting_rsvps x
         join public.club_members cm on cm.club_id = x.club_id and cm.user_id = x.user_id
        where x.meeting_id = p_meeting group by x.answer) a), '{}'::jsonb),
    'questions', coalesce((select jsonb_agg(private.question_json(q, v_me, v_blocks, null)
                                            order by q.position nulls last, q.created_at, q.id)
       from public.club_posts q
      where q.reading_id = v_mt.reading_id and q.week_no = v_mt.week_no and q.kind = 'question'
        and q.deleted_at is null and coalesce(q.author_id <> all(v_blocks), true)), '[]'::jsonb),
    'notes', coalesce((select jsonb_agg(jsonb_build_object('author', private.person_json(n.user_id, n.club_id, v_me),
                                          'body', n.body, 'visibility', n.visibility) order by n.updated_at)
       from public.meeting_notes n
      where n.meeting_id = p_meeting and n.user_id <> v_me and n.user_id <> all(v_blocks)
        and (v_host or n.visibility = 'club')), '[]'::jsonb));
end $$;

-- A 32.
create or replace function public.club_members_overview(p_club uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_reading uuid; v_next uuid;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  v_next := private.next_meeting_id(v_reading);
  return jsonb_build_object(
    'next_meeting', private.meeting_json(v_next, v_me),
    'members', coalesce((select jsonb_agg(private.person_json(x.user_id, p_club, v_me) || jsonb_build_object(
         'role', x.role, 'ratio', x.progress_ratio,
         'rsvp', (select y.answer from public.meeting_rsvps y where y.meeting_id = v_next and y.user_id = x.user_id))
         order by x.progress_ratio desc nulls last, x.joined_at)
       from public.club_members x where x.club_id = p_club), '[]'::jsonb));
end $$;

-- O chip da 25: o clube e as respostas visíveis de cada post compartilhado (até 200 por ida).
create or replace function public.club_post_summaries(p_ids uuid[]) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[];
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if cardinality(p_ids) > 200 then raise exception 'too_many' using errcode = '22023'; end if;
  v_blocks := private.block_set(v_me);
  return coalesce((select jsonb_agg(jsonb_build_object('id', p.id, 'club_id', p.club_id, 'club_name', c.name,
                     'replies', private.visible_replies(p.id, p.replies_count, v_blocks)) order by p.id)
     from public.club_posts p
     join public.clubs c on c.id = p.club_id
     join public.club_members m on m.club_id = p.club_id and m.user_id = v_me
    where p.id = any(p_ids) and p.deleted_at is null), '[]'::jsonb);
end $$;
```

- [ ] **Passo 2:** os privilégios (o fim da migração):

```sql
-- 10. Privilégios -------------------------------------------------------------------------
revoke all on public.club_readings, public.club_weeks, public.meeting_rsvps, public.meeting_notes,
  public.club_likes from public, anon, authenticated;
grant select on public.club_readings, public.club_weeks, public.meeting_rsvps, public.meeting_notes,
  public.club_likes to authenticated;
grant insert (target_type, target_id, user_id) on public.club_likes to authenticated;
grant delete on public.club_likes to authenticated;
grant insert (category, color, progress_colors, spoiler_protection, meeting_weekday, meeting_time, meeting_minutes,
  meeting_mode, timezone) on public.clubs to authenticated;
grant update (category, color, progress_colors, spoiler_protection, meeting_weekday, meeting_time, meeting_minutes,
  meeting_mode, timezone) on public.clubs to authenticated;
revoke update on public.club_members from authenticated;
grant insert (reading_id, week_no, spoiler_ratio, spoiler_page) on public.club_posts to authenticated;
grant insert (parent_reply_id, spoiler_ratio, spoiler_page, quote_text, quote_color, quote_page)
  on public.club_post_replies to authenticated;
grant all on public.club_readings, public.club_weeks, public.meeting_rsvps, public.meeting_notes,
  public.club_likes to service_role;

revoke execute on function
  private.club_member_color(), private.meeting_from_week(), private.club_member_left(),
  private.club_post_reading_check(), private.club_like_set_club(), private.club_likes_counter(),
  private.initial_of(text), private.block_set(uuid), private.next_meeting_id(uuid), private.current_week_no(uuid),
  private.week_range_json(public.club_weeks), private.person_json(uuid, uuid, uuid),
  private.visible_replies(uuid, integer, uuid[]), private.visible_children(uuid, integer, uuid[]),
  private.club_unread(uuid, uuid, timestamptz, uuid[], uuid, integer), private.group_progress(uuid),
  private.rsvp_counts(uuid), private.reading_json(uuid), private.meeting_json(uuid, uuid),
  private.question_json(public.club_posts, uuid, uuid[], timestamptz), private.spoiler_json(numeric, integer),
  private.shared_json(public.club_posts, uuid, uuid[]), private.reply_json(public.club_post_replies, uuid, uuid[]),
  private.week_card_json(public.club_weeks, uuid, uuid[], timestamptz),
  public.create_club(jsonb), public.create_invite(uuid, integer, integer), public.revoke_invite(text),
  public.publish_progress(uuid, numeric, integer), public.mark_club_read(uuid),
  public.set_rsvp(uuid, text, text, text), public.suggest_question(uuid, integer, text),
  public.order_questions(uuid, integer, uuid[]), public.set_question_status(uuid, text, text),
  public.share_highlight(uuid, text, text, integer, integer, numeric),
  public.my_clubs(), public.club_overview(uuid), public.week_thread(uuid, integer, text, uuid, jsonb, integer),
  public.meeting_overview(uuid), public.club_members_overview(uuid), public.club_post_summaries(uuid[])
  from public, anon, authenticated;
-- a coluna gerada quote_key roda como quem insere
revoke execute on function private.quote_key(text) from public, anon;
grant execute on function private.quote_key(text) to authenticated, service_role;
grant execute on function
  public.create_club(jsonb), public.create_invite(uuid, integer, integer), public.revoke_invite(text),
  public.publish_progress(uuid, numeric, integer), public.mark_club_read(uuid),
  public.set_rsvp(uuid, text, text, text), public.suggest_question(uuid, integer, text),
  public.order_questions(uuid, integer, uuid[]), public.set_question_status(uuid, text, text),
  public.share_highlight(uuid, text, text, integer, integer, numeric),
  public.my_clubs(), public.club_overview(uuid), public.week_thread(uuid, integer, text, uuid, jsonb, integer),
  public.meeting_overview(uuid), public.club_members_overview(uuid), public.club_post_summaries(uuid[])
  to authenticated, service_role;
```

- [ ] **Passo 3:** rodar o 21 e o 22 até passarem. Commit `feat(clubes): os resumos do clube em uma ida por tela
  (G21.1)` com o mundo, o 22 e a migração.

### Tarefa 7: os testes antigos, a lista de políticas e privilégios, o EXPLAIN

**Arquivos:** `03_clubes`, `10_politicas`, `90_privilegios` (`supabase/tests/database/`), `tools/supabase/medir_clube.sql`

- [ ] **Passo 1:** `03_clubes`: o insert do clube sem `goal_chapter`/`goal_chapter_label` (as duas colunas e os dois
  valores saem da linha do OK 07).
- [ ] **Passo 2:** `10_politicas`: no `set_eq` das políticas, entram `club_readings_read`, `club_weeks_read`,
  `meeting_rsvps_read`, `meeting_notes_read`, `club_likes_read`, `club_likes_insert`, `club_likes_delete`; sai
  `club_members_update_self`. Os casos permitido/negado das políticas novas ficam no 21 (citados num comentário).
- [ ] **Passo 3:** `90_privilegios`: as 5 tabelas no SELECT de `authenticated`; `club_likes` no DELETE; as colunas:
  saem `clubs.goal_chapter`/`goal_chapter_label` (INSERT e UPDATE) e as 4 de UPDATE de `club_members`; entram as de
  INSERT/UPDATE de `clubs`, `club_posts`, `club_post_replies` e `club_likes` do Passo 2 da Tarefa 6; as funções: as
  16 RPCs para `authenticated` e o `private.quote_key(text)`.
- [ ] **Passo 4:** `supabase db reset` + `supabase test db` inteiro verde (21 + 2 arquivos).
- [ ] **Passo 5:** `supabase db advisors` (CLI 2.81.3+) sem achado novo de segurança.
- [ ] **Passo 6:** `tools/supabase/medir_clube.sql`: um clube com 50 leitoras, 6 semanas, 20 perguntas e 2.000
  respostas (gerado com `generate_series`), e o `EXPLAIN (ANALYZE, BUFFERS)` de `my_clubs`, `club_overview`,
  `week_thread` (as duas ordens) e `club_post_summaries` (200 ids), como uma leitora. Metas do Anexo 02 §10: o feed
  < 30 ms e as respostas < 20 ms. Rodar por `psql` no WSL e guardar os números no `G21.md`; se passar das metas,
  um índice ou a reescrita da consulta lenta, com o teste verde.
- [ ] **Passo 7:** commit `test(clubes): as políticas, os privilégios e a medição dos resumos (G21.1)`.

---

## G21.2 — Servidor: termos, bloqueio no clube, moderação e tempo real

### Tarefa 8: termos e bloqueio no clube (RED → GREEN)

**Arquivos:** `supabase/tests/database/23_moderacao_termos.test.sql`, migração `<carimbo>_g21_moderacao_termos.sql`

- [ ] **Passo 1:** o teste (as linhas abaixo são as asserções; o cabeçalho, os usuários e o `pg_temp.como` como no 21):
  - sem aceitar: `insert` em `posts`, `post_comments`, `club_posts` (discussão), `club_post_replies`, o
    `create_club`, o `suggest_question`, o `share_highlight` e o `set_rsvp` com recado → `P0001 terms_required`; o
    `set_rsvp` sem recado passa (presença não é publicação);
  - `my_terms()` → `{"version": "2026-10-provisorio", "accepted": false}`; `accept_terms('velha')` → `22023
    stale_terms`; `accept_terms('2026-10-provisorio')` → depois disso tudo acima passa; `my_terms` → `accepted:
    true`;
  - versão nova (`update private.settings … 'terms_version'`) → publicar volta a pedir `terms_required`;
  - o histórico: as duas versões aceitas ficam em `private.terms_acceptances`;
  - rotina do servidor (sem usuário no JWT) não é barrada;
  - bloqueio (D-223): A bloqueia B → A não vê os posts nem as respostas de B no clube (`select` direto) e B não vê
    os de A; a curtida de B some para A; B não responde a um post de A (`P0001 blocked`); desbloqueou, tudo volta.
- [ ] **Passo 2:** a migração:

```sql
-- =====================================================================================
-- BookNest · G21.2 — termos, bloqueio no clube e moderação (D-52; docs/progresso/G21.md §2; D-220–D-223).
-- =====================================================================================

-- Termos (D-222): quem não aceitou a versão atual não publica. A versão fica numa configuração do servidor.
create table private.settings (
  key         text primary key check (key ~ '^[a-z_]{3,40}$'),
  value       text not null,
  updated_at  timestamptz not null default now()
);
alter table private.settings enable row level security;   -- sem política: só service_role
insert into private.settings (key, value) values ('terms_version', '2026-10-provisorio');

create table private.terms_acceptances (     -- o histórico (LGPD): cada versão aceita, com a data
  user_id      uuid not null references auth.users(id) on delete cascade,
  version      text not null,
  accepted_at  timestamptz not null default now(),
  primary key (user_id, version)
);
alter table private.terms_acceptances enable row level security;

create or replace function private.terms_version() returns text
language sql stable security definer set search_path = '' as $$
  select s.value from private.settings s where s.key = 'terms_version'
$$;

create or replace function public.my_terms() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_version text := private.terms_version();
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  return jsonb_build_object('version', v_version, 'accepted', exists (
    select 1 from private.terms_acceptances t where t.user_id = v_me and t.version = v_version));
end $$;

create or replace function public.accept_terms(p_version text) returns void
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if p_version is distinct from private.terms_version() then
    raise exception 'stale_terms' using errcode = '22023';
  end if;
  insert into private.terms_acceptances (user_id, version) values (v_me, p_version) on conflict do nothing;
end $$;

-- Vale só para pedidos com usuário no JWT (como a faixa etária): rotinas do servidor não são barradas.
create or replace function private.require_terms() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is not null and not exists (
       select 1 from private.terms_acceptances t where t.user_id = v_me and t.version = private.terms_version()) then
    raise exception 'terms_required' using errcode = 'P0001',
      hint = 'Aceite as regras da comunidade para publicar.';
  end if;
  return new;
end $$;
create trigger posts_require_terms before insert on public.posts
  for each row execute function private.require_terms();
create trigger post_comments_require_terms before insert on public.post_comments
  for each row execute function private.require_terms();
create trigger clubs_require_terms before insert on public.clubs
  for each row execute function private.require_terms();
create trigger club_posts_require_terms before insert on public.club_posts
  for each row execute function private.require_terms();
create trigger club_post_replies_require_terms before insert on public.club_post_replies
  for each row execute function private.require_terms();
create trigger meeting_notes_require_terms before insert or update of body on public.meeting_notes
  for each row execute function private.require_terms();

-- Bloqueio dentro do clube (D-223): o que a pessoa bloqueada escreveu some nos dois sentidos.
drop policy club_posts_read on public.club_posts;
create policy club_posts_read on public.club_posts for select to authenticated
  using (private.is_club_member(club_id) and (deleted_at is null or author_id = (select auth.uid()))
         and (author_id is null or not private.is_blocked_between(author_id, (select auth.uid()))));
drop policy club_replies_read on public.club_post_replies;
create policy club_replies_read on public.club_post_replies for select to authenticated
  using (private.is_club_member(club_id) and (deleted_at is null or author_id = (select auth.uid()))
         and not private.is_blocked_between(author_id, (select auth.uid())));
drop policy club_likes_read on public.club_likes;
create policy club_likes_read on public.club_likes for select to authenticated
  using (private.is_club_member(club_id) and not private.is_blocked_between(user_id, (select auth.uid())));

-- não responde a quem está bloqueado (o post nem aparece; isto fecha o id adivinhado)
create or replace function private.club_reply_not_blocked() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_author uuid;
begin
  select p.author_id into v_author from public.club_posts p where p.id = new.post_id;
  if v_author is not null and private.is_blocked_between(v_author, new.author_id) then
    raise exception 'blocked' using errcode = 'P0001';
  end if;
  return new;
end $$;
create trigger club_post_replies_not_blocked before insert on public.club_post_replies
  for each row execute function private.club_reply_not_blocked();
```

  E os privilégios: `revoke execute` de `private.terms_version()`, `private.require_terms()`,
  `private.club_reply_not_blocked()`, `public.my_terms()` e `public.accept_terms(text)` para `public, anon,
  authenticated`; `grant execute` de `my_terms` e `accept_terms` para `authenticated, service_role`;
  `grant all on private.settings, private.terms_acceptances to service_role`.
- [ ] **Passo 3:** os testes que publicam passam a aceitar os termos no começo (como `postgres`, antes do `set local
  role`): `insert into private.terms_acceptances (user_id, version) select id, '2026-10-provisorio' from auth.users;`.
  Arquivos: `03`, `04`, `07`, `08`, `10`, `13`, `15`, `21` e o `_mundo_clube.psql` (este, no fim). Conferir com
  `grep -ln "insert into public.\(posts\|post_comments\|clubs\|club_posts\|club_post_replies\)\|create_club\|share_highlight\|suggest_question" supabase/tests/database/*`.
- [ ] **Passo 4:** `10_politicas` e `90_privilegios` com as políticas recriadas e as 2 RPCs. Tudo verde. Commit
  `feat(moderacao): os termos pelo servidor e o bloqueio dentro do clube (G21.2)`.

### Tarefa 9: moderadores e o e-mail do dia (RED → GREEN)

- [ ] **Passo 1:** no 23, as asserções:
  - `private.is_moderator(id)` falso para quem não está na lista e verdadeiro depois do `insert into
    private.moderators`;
  - `private.moderation_snapshot()` devolve a fila com o texto denunciado de cada tipo (post, comentário, post do
    clube, resposta, perfil, clube) e `sla_breached` para a denúncia de 25 h;
  - `private.queue_moderation_digest()` sem denúncia aberta → 0 e nada na fila de e-mail; com 3 abertas (1 passou de
    24 h) e 2 moderadores → 2 e-mails `moderation_digest` com `{"open": 3, "breached": 1}` e a data da mais antiga;
  - o agendamento `booknest-moderacao-diaria` existe com `0 12 * * *` (9h de Brasília).
- [ ] **Passo 2:** acrescentar à migração:

```sql
-- Quem modera (D-220): sem política, só o service_role mexe; a Edge Function `moderacao` confere aqui.
create table private.moderators (
  user_id   uuid primary key references auth.users(id) on delete cascade,
  added_at  timestamptz not null default now()
);
alter table private.moderators enable row level security;

create or replace function private.is_moderator(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from private.moderators m where m.user_id = p_user)
$$;

-- A fila com o conteúdo de cada denúncia (o painel mostra o texto para decidir).
create or replace function private.moderation_snapshot(p_limit integer default 100) returns jsonb
language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', q.id, 'target_type', q.target_type, 'target_id', q.target_id, 'reason', q.reason, 'details', q.details,
    'created_at', q.created_at, 'age_hours', floor(extract(epoch from q.age) / 3600)::integer,
    'sla_breached', q.sla_breached,
    'content', case q.target_type
      when 'post'            then (select concat_ws(' — ', p.quote_text, p.body) from public.posts p where p.id = q.target_id)
      when 'post_comment'    then (select c.body from public.post_comments c where c.id = q.target_id)
      when 'club_post'       then (select concat_ws(' — ', p.quote_text, p.body) from public.club_posts p where p.id = q.target_id)
      when 'club_post_reply' then (select r.body from public.club_post_replies r where r.id = q.target_id)
      when 'profile'         then (select concat_ws(' — ', p.display_name, p.bio) from public.profiles p where p.id = q.target_id)
      when 'club'            then (select concat_ws(' — ', c.name, c.category) from public.clubs c where c.id = q.target_id)
    end) order by q.created_at), '[]'::jsonb)
  from (select * from private.moderation_queue limit p_limit) q
$$;

-- O e-mail do dia (D-221): havendo denúncia aberta, um e-mail para cada pessoa que modera.
alter table private.email_outbox drop constraint email_outbox_template_check;
alter table private.email_outbox add constraint email_outbox_template_check
  check (template in ('retention_warning','retention_purged','welcome','export_ready','moderation_digest'));

create or replace function private.queue_moderation_digest() returns integer
language plpgsql security definer set search_path = '' as $$
declare v_open integer; v_breached integer; v_oldest timestamptz; v_count integer;
begin
  select count(*), count(*) filter (where q.sla_breached), min(q.created_at)
    into v_open, v_breached, v_oldest from private.moderation_queue q;
  if v_open = 0 then return 0; end if;
  insert into private.email_outbox (user_id, template, payload)
  select m.user_id, 'moderation_digest',
         jsonb_build_object('open', v_open, 'breached', v_breached, 'oldest', v_oldest)
    from private.moderators m;
  get diagnostics v_count = row_count;
  return v_count;
end $$;
select cron.schedule('booknest-moderacao-diaria', '0 12 * * *', $$select private.queue_moderation_digest()$$);
```

  Antes, conferir o nome do `check` do `template` com
  `select conname from pg_constraint where conrelid = 'private.email_outbox'::regclass`. Privilégios: `revoke
  execute` das 3 funções para `public, anon, authenticated`; `grant execute` delas e `grant all on
  private.moderators` para `service_role`.
- [ ] **Passo 3:** o `11_agendamentos` ganha o agendamento novo na lista. Tudo verde. Commit `feat(moderacao): a
  lista de quem modera, a fila com o conteúdo e o e-mail do dia (G21.2)`.

### Tarefa 10: o tempo real (RED → GREEN)

**Arquivos:** `supabase/tests/database/24_tempo_real.test.sql`, migração `<carimbo>_g21_tempo_real.sql`

- [ ] **Passo 1:** conferir a assinatura no banco local: `\df realtime.send` (esperado `realtime.send(payload jsonb,
  event text, topic text, private boolean default true)`); a política em `realtime.messages` é permitida (o
  changelog de 14/07/2026 trava criar objetos no esquema `realtime`, mas não as políticas).
- [ ] **Passo 2:** o teste: depois de uma resposta, uma curtida e um post no clube, `realtime.messages` tem os avisos
  no tópico `club:<id>` com `event = 'changed'`, `private = true` e `payload` sem texto (`{"t": "club_post_replies"}`);
  a atualização do contador não manda aviso; como membro, o `select` em `realtime.messages` daquele tópico com
  `set_config('realtime.topic', 'club:<id>', true)` vê os avisos; como quem não é do clube, nada; tópico inválido
  (`club:xyz`) não quebra a política (nada).
- [ ] **Passo 3:** a migração:

```sql
-- =====================================================================================
-- BookNest · G21.2 — o tempo real do clube (D-225; docs/progresso/G21.md §2). Um aviso sem conteúdo
-- ("mudou") no canal privado club:<id> a cada post, resposta ou curtida; o app relê o resumo. Só os
-- membros leem o tópico. Broadcast (escala melhor que o Postgres Changes); o app só abre o canal com
-- a 25 ou uma tela do clube aberta.
-- =====================================================================================

create or replace function private.club_ping() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  perform realtime.send(jsonb_build_object('t', tg_table_name), 'changed',
                        'club:' || coalesce(new.club_id, old.club_id)::text, true);
  return null;
end $$;
create trigger club_posts_ping after insert or update of body, deleted_at, status, position, host_note
  on public.club_posts for each row execute function private.club_ping();
create trigger club_post_replies_ping after insert or update of body, deleted_at
  on public.club_post_replies for each row execute function private.club_ping();
create trigger club_likes_ping after insert or delete on public.club_likes
  for each row execute function private.club_ping();

-- O membro do clube do tópico 'club:<uuid>' (o uuid é conferido antes do cast: tópico inválido = não).
create or replace function private.club_topic_member(p_topic text) returns boolean
language sql stable security definer set search_path = '' as $$
  select p_topic ~ '^club:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
     and private.is_club_member(substr(p_topic, 6)::uuid)
$$;
create policy club_pings_read on realtime.messages for select to authenticated
  using (realtime.messages.extension = 'broadcast' and private.club_topic_member((select realtime.topic())));

revoke execute on function private.club_ping(), private.club_topic_member(text) from public, anon, authenticated;
grant execute on function private.club_topic_member(text) to authenticated;
```

- [ ] **Passo 4:** `10_politicas` ganha `club_pings_read` (se o `set_eq` olha só os esquemas do app, um teste à
  parte no 24); `90_privilegios`, o `club_topic_member`. Tudo verde. Commit `feat(clubes): os avisos do clube em
  tempo real, só para membros (G21.2)`.

### Tarefa 11: a Edge Function `moderacao` e o modelo do e-mail (RED → GREEN)

**Arquivos:** `supabase/functions/moderacao/{handler.ts,handler_test.ts,index.ts}`, `email-sender/modelos.ts` e o
teste dele, `supabase/config.toml` (`[functions.moderacao]`, `verify_jwt = true`)

- [ ] **Passo 1:** os testes (`handler_test.ts`, com dependências falsas, no padrão do `email-sender`):
  - `OPTIONS` → 204 com `Access-Control-Allow-Origin` = a origem configurada; outra origem → sem o cabeçalho;
  - sem `Authorization` → 401 `nao_autorizado`; JWT inválido → 401;
  - usuário que não modera → 403 `nao_moderador`;
  - `GET` → 200 com a fila (`{"itens": [...]}`, o que veio de `fila()`);
  - `POST {"report": "<uuid>", "decision": "hide", "note": "..."}` → chama `decidir(report, 'hide', <id do
    moderador>, note)` e devolve 200; `decision` fora de `hide`/`dismiss` → 400 `decisao_invalida`; `report` que não
    é uuid → 400; `report_not_open` do banco → 409 `ja_decidida`;
  - outro método → 405.
  E no `modelos_test.ts`: `montar('moderation_digest', {"open": 3, "breached": 1, "oldest": "2026-10-08T12:00:00Z"})`
  → assunto "3 denúncias abertas na moderação" e o texto com "1 passou do prazo de 24 h" e "desde 08/10/2026".
- [ ] **Passo 2:** `handler.ts`:

```ts
// Edge Function `moderacao` (D-52, D-220): o painel de moderação (site/moderacao/) lê a fila e decide.
// Só quem está em private.moderators: o JWT é conferido pelo Auth e o id, na lista. Responde JSON
// (o domínio padrão das Edge Functions não serve HTML; a página é estática, em site/moderacao/).
import { usuarioDoPedido } from '../_shared/auth.ts';
import { erro, json } from '../_shared/http.ts';

export type Decisao = 'hide' | 'dismiss';

export type Dependencias = {
  origem: string; // a origem da página (CORS)
  verificar(jwt: string): Promise<string | null>;
  ehModerador(id: string): Promise<boolean>;
  fila(): Promise<unknown[]>;
  decidir(denuncia: string, decisao: Decisao, moderador: string, nota: string | null): Promise<void>;
};

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

export function criarHandler(d: Dependencias) {
  const cors = (req: Request): Record<string, string> =>
    req.headers.get('Origin') === d.origem
      ? {
        'Access-Control-Allow-Origin': d.origem,
        'Access-Control-Allow-Headers': 'authorization, content-type, apikey',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        Vary: 'Origin',
      }
      : { Vary: 'Origin' };
  const com = (req: Request, r: Response): Response => {
    for (const [k, v] of Object.entries(cors(req))) r.headers.set(k, v);
    return r;
  };

  return async (req: Request): Promise<Response> => {
    if (req.method === 'OPTIONS') return com(req, new Response(null, { status: 204 }));
    if (req.method !== 'GET' && req.method !== 'POST') return com(req, erro(405, 'metodo_nao_permitido'));
    const id = await usuarioDoPedido(req, d.verificar);
    if (!id) return com(req, erro(401, 'nao_autorizado'));
    if (!(await d.ehModerador(id))) return com(req, erro(403, 'nao_moderador'));
    if (req.method === 'GET') return com(req, json(200, { itens: await d.fila() }));
    let corpo: { report?: unknown; decision?: unknown; note?: unknown };
    try {
      corpo = await req.json();
    } catch {
      return com(req, erro(400, 'corpo_invalido'));
    }
    if (typeof corpo.report !== 'string' || !UUID.test(corpo.report)) return com(req, erro(400, 'denuncia_invalida'));
    if (corpo.decision !== 'hide' && corpo.decision !== 'dismiss') return com(req, erro(400, 'decisao_invalida'));
    const nota = typeof corpo.note === 'string' && corpo.note.trim() !== '' ? corpo.note.trim().slice(0, 500) : null;
    try {
      await d.decidir(corpo.report, corpo.decision, id, nota);
    } catch (x) {
      if (String(x).includes('report_not_open')) return com(req, erro(409, 'ja_decidida'));
      throw x;
    }
    return com(req, json(200, { ok: true }));
  };
}
```

  `index.ts` (o padrão do `delete-account` para o JWT e do `email-sender` para o banco):

```ts
import { sql } from '../_shared/db.ts';
import { criarHandler } from './handler.ts';
import { verificarJwt } from '../_shared/supabase.ts';

Deno.serve(criarHandler({
  origem: Deno.env.get('BOOKNEST_MODERACAO_ORIGEM') ?? 'http://localhost:8788',
  verificar: verificarJwt,
  async ehModerador(id) {
    const [r] = await sql()`select private.is_moderator(${id}::uuid) as ok`;
    return Boolean(r?.ok);
  },
  async fila() {
    const [r] = await sql()`select private.moderation_snapshot(200) as itens`;
    return (r?.itens ?? []) as unknown[];
  },
  async decidir(denuncia, decisao, moderador, nota) {
    await sql()`select private.moderate_report(${denuncia}::uuid, ${decisao}, ${moderador}, ${nota})`;
  },
}));
```

  Antes, conferir o nome da função do JWT em `_shared/supabase.ts` (a que o `delete-account` usa) e usar a mesma.
  O `moderate_report` guarda `p_moderator` como texto: vai o id de quem decidiu.
- [ ] **Passo 3:** o caso `moderation_digest` em `modelos.ts`:

```ts
    case 'moderation_digest': {
      const abertas = Number(payload.open ?? 0);
      const passaram = Number(payload.breached ?? 0);
      return {
        assunto: `${abertas} ${abertas === 1 ? 'denúncia aberta' : 'denúncias abertas'} na moderação`,
        texto: `Há ${abertas} ${abertas === 1 ? 'denúncia aberta' : 'denúncias abertas'} desde ${dataBr(payload.oldest)}.\n` +
          (passaram > 0
            ? `${passaram} ${passaram === 1 ? 'passou' : 'passaram'} do prazo de 24 h.\n`
            : 'Nenhuma passou do prazo de 24 h.\n') +
          'Abra o painel de moderação para decidir.',
      };
    }
```

- [ ] **Passo 4:** `deno test` (as funções) verde; `deno lint` e `deno fmt --check`. Commit `feat(moderacao): a
  função do painel e o e-mail do dia (G21.2)`.

### Tarefa 12: a página `site/moderacao/`

**Arquivos:** `site/moderacao/{index.html,app.js,estilo.css,config.js,LEIA-ME.md,painel_test.ts}` (o padrão do
`site/excluir-conta/`)

- [ ] **Passo 1:** o teste (`painel_test.ts`, Deno, com a lógica pura do `app.js` exportada como no
  `exclusao_test.ts`): a fila vira linhas na ordem da mais antiga; a que passou de 24 h ganha a marca "passou do
  prazo"; "Esconder" e "Manter" mandam `POST` com `decision` `hide`/`dismiss` e a nota; a resposta 409 vira "Outra
  pessoa já decidiu"; 403 vira "Esta conta não modera".
- [ ] **Passo 2:** a página: entrar por e-mail (código de 6 dígitos, `signInWithOtp` + `verifyOtp` do
  `@supabase/supabase-js@2.58.0` pelo cdn.jsdelivr com a versão fixa e `integrity`), a fila, os dois botões e a
  nota. O `config.js` traz só a URL e a chave **pública** (como o `excluir-conta`). Estilo neo-brutalista do app
  (borda 1,5 preta, sombra dura, Figtree/Bricolage do Google Fonts).
- [ ] **Passo 3:** `deno test site/moderacao` verde; a página aberta no navegador contra o Supabase local, com uma
  denúncia de verdade (captura para a conversa). Commit `feat(moderacao): a página do painel (G21.2)`.

---

## G21.3 a G21.8 — o app (contratos; o código completo entra antes da G21.3)

### Tarefa 13: as falhas e a conversão dos erros (G21.3)

- `lib/features/social/domain/social_failure.dart`:
  `sealed class SocialFailure` com `Offline`, `TermsRequired`, `FreeClubLimit`, `InvalidInvite`, `Blocked`,
  `NotAllowed` (42501), `RateLimited`, `NotFound`, `ServerFailure(String code)`.
- `SocialFailure fromPostgrest(PostgrestException e)`: pelo `message` do Postgres (`terms_required`,
  `free_club_limit`, `invalid_invite`, `blocked`, `not_member`/`not_allowed` → `NotAllowed`) e pelo `code`;
  `SocketException`/`ClientException` → `Offline`.
- Testes: cada código da migração vira a falha certa; um erro desconhecido vira `ServerFailure` com o código.

### Tarefa 14: `ClubsRepository` (G21.3)

- `lib/features/clubs/data/clubs_repository.dart`: `abstract interface class ClubsRepository` e
  `SupabaseClubsRepository`, um método por RPC da §1 (`myClubs`, `overview`, `weekThread`, `meeting`, `members`,
  `postSummaries`, `createClub`, `createInvite`, `revokeInvite`, `joinByCode`, `joinPublic`, `leave`,
  `publishProgress`, `markRead`, `setRsvp`, `suggestQuestion`, `orderQuestions`, `setQuestionStatus`,
  `shareHighlight`, `like`/`unlike`, `reply`, `report`), devolvendo os modelos de `lib/features/clubs/domain/`
  (`ClubCard`, `ClubReading`, `ClubWeek`, `MeetingSummary`, `Person`, `ThreadReply`, …) ou `SocialFailure`.
- Provider nulo sem cliente (o padrão do `community_catalog_api.dart`).
- Testes com o `FakeBackend` (`test/support/`): o corpo de cada RPC, a conversão de cada JSON do mundo do clube (o
  JSON do pgTAP 22 vira fixture `test/fixtures/clube/*.json`, gerado do banco local e conferido) e cada falha.

### Tarefa 15: os repositórios do social (G21.3)

- `ProfileRepository` (meu perfil; o de outra pessoa: Pro → tabelas, Grátis → `profile_preview`), `FollowRepository`,
  `BlockRepository`, `PostRepository` (posts, comentários, curtidas), `ReportRepository`, `TermsRepository`
  (`my_terms`, `accept_terms`), `NotificationsRepository` (contagem com `count: exact` e `head`, marcar lidas).
- Testes: o Grátis nunca recebe texto de resenha (o JSON da prévia não tem `body`), o Pro recebe; seguir perfil
  fechado vira pedido; bloquear e desbloquear; denunciar cada tipo.

### Tarefa 16: `ClubPings` (G21.3)

- `lib/features/clubs/data/club_pings.dart`: abre `client.channel('club:<id>', opts: RealtimeChannelConfig(private:
  true))`, escuta o evento `changed` e emite um `Stream<String>` (o id do clube) com 2 s de espera para juntar
  avisos seguidos; `close()` fecha os canais. Conferir na hora a API do `supabase_flutter` instalado
  (`RealtimeChannelConfig`, `setAuth`).
- Testes: com um canal falso, 3 avisos em 1 s viram 1 releitura; fechar não emite mais.

### Tarefa 17: as regras R1–R12 (G21.4)

`lib/features/clubs/domain/`:
- R1 `bookMatchesReading({editionId, isbn13}, ClubReading)`;
- R2 `clubChapterLabel(numerals, n, toLabel)` e `clubChapterOf(numerals, chapterIndex)` (sobre `chapterNumerals` e a
  contagem do `homeChapter`, D-206);
- R3 `ticketClub(clubs, readingBook)`; R4 vem do servidor (`current_week`); R5 e R6 vêm do servidor (o app só
  formata: 0,5373 → "54%");
- R7 `weekOpenFor(week, myClubChapter, currentWeek)`; R8 `isAhead(spoilerRatio, myRatio, protection)`;
- R9 `shouldPublish(last, now)`; R10 `statsDue(lastPublished, now)`; R11 e R12 vêm do servidor.
- Testes de tabela para cada uma (o Dom Casmurro real para R2: cap. 50 → "L", o XXXII → 32).

### Tarefa 18: o cache e a atualização (G21.4)

- `lib/features/clubs/data/clubs_cache.dart`: `clubes:<dono>`, `inicio.clube:<dono>` (o JSON do
  `CachedClubTicketSource`, com `until_chapter` = o fim da semana atual), `clube.posts:<dono>`,
  `notificacoes:<dono>`; sem clube, a chave do ticket sai.
- `ClubsSync`: ao abrir e ao voltar ao app (com conta e rede), `my_clubs` + a contagem de notificações; erro de rede
  mantém o cache.
- Testes: o JSON escrito é lido de volta pelo `CachedClubTicketSource` com os números do mundo (A J, 11, 54 %, 62 %,
  3, a quinta); trocar de conta não mostra o clube da outra (D-68).

### Tarefa 19: o ticket e o sininho (G21.5)

- O provider do ticket continua o `CachedClubTicketSource`; o `ClubsSync` entra no ciclo de vida do app.
- O `unreadNotifications` da Início vem de `notificacoes:<dono>`; o ponto aparece com > 0.
- Testes: a Início com o cache do mundo mostra o ticket (golden da G08 inalterado) e o ponto do sininho.

### Tarefa 20: a faixa do sumário (G21.5)

- `ReaderClubGoal` ganha `goalLabel` (o `to_label` do clube); `ClubsReaderClubSource` (R1 no cache);
  `toc_view._club()` troca `leaves[goal - 1]` pela R2 e o "faltam N" pela mesma contagem.
- Testes: com o Dom Casmurro real no XXXII, "Até o cap. L · faltam 18"; livro sem numeração, a folha e o rótulo do
  clube; sem clube, a faixa some (como hoje).

### Tarefa 21: o chip, o "Só do clube" e o tempo real na 25 (G21.5)

- `ClubsHighlightsClubSource.clubOf` lê `clube.posts:<dono>`; ao abrir a 25, uma ida de `club_post_summaries` com
  os `shared_club_post_id` e o `ClubPings` dos clubes deles; cada aviso relê; fechar a 25 fecha os canais.
- Testes: "Leitoras de Capitu · 3 respostas"; um aviso muda para 4; o "Só do clube" mostra só os compartilhados;
  fechar a 25 não deixa canal aberto.

### Tarefa 22: compartilhar no clube (G21.5)

- O `_shareToClub` da 25 segue os 7 casos da §5 (as pílulas, "Já está em…", a folha "Antes de publicar", a folha
  "Compartilhar em…"); o id volta para `annotations.shared_club_post_id`.
- As duas folhas novas no estilo das folhas do leitor; entram no `docs/design/estados_sem_design.md`.
- Testes: cada caso da §5; a nota não vai no pedido (D-217); offline não chama nada.

### Tarefa 23: o progresso, os números e a privacidade do Grátis (G21.6)

- `ProgressPublisher` (R9) no `lifecycle` do leitor e ao fechar; `StatsPublisher` (R10) ao abrir.
- A lista do `privacy_free_test.dart` ganha as 7 entradas da §6, cada uma com o motivo; o teste novo: Grátis sem
  clube lê, grifa e abre a 25 sem nenhuma chamada nova.

### Tarefa 24: integração com o Supabase local (G21.8, preparada aqui)

- `test/integracao/clube_test.dart` (marca `integracao`): o `_mundo_clube.psql` carregado por `psql` antes; a
  Marina entra; o ticket, a faixa e o chip com os números do mundo; compartilhar um grifo; a resposta de outra
  leitora chega pelo tempo real; o termo exigido; o bloqueio.

### Tarefa 25: Q29 (G21.7, D-224)

- `GeneratedCoverArt`: medir a palavra mais longa com o `TextPainter` na largura útil; se não cabe, a fonte desce
  até caber (mínimo 60 % do tamanho do desenho). Testes: "Dom Casmurro" na capa do herói fica inteiro; os goldens
  das capas geradas que já existem iguais (ou a diferença no relatório).

### Tarefa 26: prova e relatório (G21.8)

- `supabase test db`, `deno test`, `dart format`, `flutter analyze`, `flutter test`, a integração;
- revisão independente (agente que não escreveu o código), mutação (R1–R12 e as funções SQL dos resumos), cobertura
  ≥ 90 % nos arquivos da fase, gitleaks;
- as capturas da §Prova; `docs/progresso/G21.md` (Resultados, Revisão, Desvios, Pendências, Capturas) e
  `RELATORIO_G21.md`; a linha final "✅ FASE G21 concluída — aguardando sua aprovação para iniciar a FASE G22."
