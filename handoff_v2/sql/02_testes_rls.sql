-- =====================================================================================
-- Testes de fumaça do esquema (rodar depois de 00 + 01, como superusuário).
-- Cada bloco imprime "OK NN …" (23 blocos) ou aborta com erro. Na G04 isto vira pgTAP (supabase/tests).
-- =====================================================================================
\set ON_ERROR_STOP on

-- Usuários: A = Pro, B = Grátis, C = Grátis
insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com');

do $$ begin
  assert (select count(*) from public.profiles) = 3, 'perfis automáticos';
  assert (select count(*) from public.profile_stats) = 3, 'estatísticas automáticas';
  raise notice 'OK 01 perfis criados pelo trigger do Auth';
end $$;

update public.profiles set handle = 'ana' where id = '00000000-0000-7000-8000-00000000000a';
update public.profiles set handle = 'bia' where id = '00000000-0000-7000-8000-00000000000b';
update public.profiles set handle = 'caio', visibility = 'private' where id = '00000000-0000-7000-8000-00000000000c';

-- A é Pro (como o webhook faria)
insert into billing.subscriptions (user_id, store, product_id, period_type, status, will_renew,
  current_period_starts_at, current_period_ends_at, original_transaction_id, environment, last_event_at)
values ('00000000-0000-7000-8000-00000000000a', 'play_store', 'booknest_pro_mensal', 'normal', 'active', true,
  now() - interval '3 days', now() + interval '27 days', 'GPA.1234', 'sandbox', now());
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '27 days');
select private.refresh_sync_access();

create or replace function pg_temp.as_user(p uuid) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, false);
end $$;

-- ---------------------------------------------------------------- sync (Pro grava, LWW)
set role authenticated;
select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');

select public.sync_apply_changes($j$[
 {"table":"user_books","op":"PUT","id":"01927a00-0000-7000-8000-000000000001","hlc":"0001726862400000-0000-dev1",
  "data":{"title":"Dom Casmurro","author_display":"Machado de Assis","format":"epub","status":"reading",
          "content_sha256":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
          "ref_pages_total":256,"ref_page_version":1,"chapters_total":148,
          "added_at":"2026-09-01T12:00:00Z","created_at":"2026-09-01T12:00:00Z","updated_at":"2026-09-01T12:00:00Z",
          "user_id":"00000000-0000-7000-8000-00000000000b"}},
 {"table":"annotations","op":"PUT","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862400000-0001-dev1",
  "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","kind":"highlight","group_id":"01927a00-0000-7000-8000-000000000201",
          "anchor":{"v":1,"spine":3,"start":120,"end":198,"quote":{"exact":"que eu conheço de vista e de chapéu."}},
          "ref_page":3,"chapter_index":0,"color":"#FED170","style":"fill","fill_height":"medium",
          "created_at":"2026-09-02T22:00:00Z","updated_at":"2026-09-02T22:00:00Z"}},
 {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-000000000301","hlc":"0001726862400000-0002-dev1",
  "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","started_at":"2026-09-20T19:30:00Z","ended_at":"2026-09-20T19:48:00Z",
          "active_seconds":1080,"source":"auto","created_at":"2026-09-20T19:48:00Z","updated_at":"2026-09-20T19:48:00Z"}}
]$j$::jsonb) as resultado_put;

do $$ begin
  assert (select count(*) from personal.user_books) = 1, 'A vê o próprio livro';
  assert (select user_id from personal.user_books) = '00000000-0000-7000-8000-00000000000a', 'dono imposto pelo servidor (spoof ignorado)';
  raise notice 'OK 02 Pro sincroniza; user_id falsificado foi trocado pelo do token';
end $$;

-- LWW: versão mais velha é ignorada, mais nova vence
select public.sync_apply_changes($j$[
 {"table":"annotations","op":"PATCH","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862300000-0000-dev2","data":{"color":"#FFC1C6"}}
]$j$::jsonb) as velho;
do $$ begin
  assert (select color from personal.annotations) = '#FED170', 'LWW: escrita antiga não sobrescreve';
end $$;
select public.sync_apply_changes($j$[
 {"table":"annotations","op":"PATCH","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862500000-0000-dev2","data":{"color":"#ABCF82"}}
]$j$::jsonb) as novo;
do $$ begin
  assert (select color from personal.annotations) = '#ABCF82', 'LWW: escrita nova vence';
  raise notice 'OK 03 last-writer-wins por version_hlc';
end $$;

select public.sync_apply_changes($j$[
 {"table":"annotations","op":"DELETE","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862600000-0000-dev1"}
]$j$::jsonb) as apagar;
do $$ begin
  assert (select deleted_at is not null from personal.annotations), 'DELETE vira tombstone';
  raise notice 'OK 04 exclusão vira tombstone (deleted_at)';
end $$;

-- Grátis não sincroniza e não vê dados de A
select pg_temp.as_user('00000000-0000-7000-8000-00000000000b');
do $$ begin
  begin
    perform public.sync_apply_changes('[]'::jsonb);
    raise exception 'deveria falhar';
  exception when sqlstate 'P0001' then
    if sqlerrm <> 'pro_required' then raise; end if;
  end;
  assert (select count(*) from personal.user_books) = 0, 'B não vê livros de A';
  assert (select count(*) from personal.annotations) = 0, 'B não vê grifos de A';
  raise notice 'OK 05 Grátis bloqueado na sincronização e isolado dos dados de A';
end $$;

-- Tabela fora da lista branca → volta em "rejected" (o resto do lote segue)
select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');
do $$ declare r jsonb; begin
  r := public.sync_apply_changes('[{"table":"profiles","op":"PUT","id":"01927a00-0000-7000-8000-000000000999","hlc":"0001726862400000-0000-dev1","data":{}}]'::jsonb);
  assert (r -> 'rejected' -> 0 ->> 'code') = '22023' and (r ->> 'applied')::int = 0, 'tabela fora da lista recusada';
  raise notice 'OK 06 tabela fora da lista branca recusada';
end $$;

-- ---------------------------------------------------------------- clubes
select pg_temp.as_user('00000000-0000-7000-8000-00000000000b');
insert into public.clubs (owner_id, name, name_highlight, goal_chapter, goal_chapter_label)
values ('00000000-0000-7000-8000-00000000000b', 'Leitoras de Capitu', 'Capitu', 50, 'L');
do $$ begin
  begin
    insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000b', 'Segundo clube');
    raise exception 'deveria falhar';
  exception when sqlstate 'P0001' then
    if sqlerrm <> 'free_club_limit' then raise; end if;
  end;
  assert (select count(*) from public.club_members) = 1, 'dono virou membro';
  raise notice 'OK 07 Grátis cria 1 clube; dono entra como owner';
end $$;

select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');
insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000a', 'Clube 1 da Ana');
insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000a', 'Clube 2 da Ana');
do $$ begin
  assert (select count(*) from public.clubs where owner_id = '00000000-0000-7000-8000-00000000000a') = 2, 'Pro cria vários';
  assert (select count(*) from public.clubs where name = 'Leitoras de Capitu') = 0, 'A não vê clube por convite do qual não é membro';
  raise notice 'OK 08 Pro cria vários clubes; clube por convite invisível para não membros';
end $$;

-- convite: B cria, A entra, A responde post
select pg_temp.as_user('00000000-0000-7000-8000-00000000000b');
insert into public.club_invites (code, club_id, created_by, expires_at)
select 'CAPITU2026', id, '00000000-0000-7000-8000-00000000000b', now() + interval '7 days'
  from public.clubs where name = 'Leitoras de Capitu';
insert into public.club_posts (club_id, author_id, kind, chapter_index, ref_page, quote_text, quote_color, body)
select id, '00000000-0000-7000-8000-00000000000b', 'shared_highlight', 31, 152,
       'Capitu era Capitu, isto é, uma criatura mui particular, mais mulher do que eu era homem.', '#B6ACE4',
       'Levar para o encontro de quinta.'
  from public.clubs where name = 'Leitoras de Capitu';

reset role;
create temp table t_post as select id from public.club_posts;
grant select on t_post to authenticated;
set role authenticated;
select pg_temp.as_user('00000000-0000-7000-8000-00000000000c');
do $$ begin
  assert (select count(*) from public.club_posts) = 0, 'não membro não vê posts do clube';
  begin
    -- C conhece o id do post (vazou por outro meio) e tenta responder
    insert into public.club_post_replies (post_id, author_id, body)
    values ((select id from t_post), '00000000-0000-7000-8000-00000000000c', 'intrusa');
    raise exception 'deveria falhar';
  exception when others then
    if sqlerrm not like '%row-level security%' then raise; end if;
  end;
  raise notice 'OK 09 não membro não vê nem responde no clube (bloqueio por RLS)';
end $$;

select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');
select public.join_club('CAPITU2026') is not null as entrou;
-- o cliente não manda club_id (nem tem GRANT para isso): o trigger copia o do post
insert into public.club_post_replies (post_id, author_id, body)
select p.id, '00000000-0000-7000-8000-00000000000a', 'Concordo!'
  from public.club_posts p;
do $$ begin
  assert (select replies_count from public.club_posts) = 1, 'contador de respostas';
  assert (select club_id from public.club_post_replies) = (select club_id from public.club_posts), 'club_id herdado do post';
  raise notice 'OK 10 convite, resposta, contador e club_id herdado';
end $$;

-- ---------------------------------------------------------------- perfis (Pro vê, Grátis só prévia)
select pg_temp.as_user('00000000-0000-7000-8000-00000000000b');
insert into public.posts (author_id, kind, body, rating) values ('00000000-0000-7000-8000-00000000000b', 'review', 'Capitu é o livro.', 5);
select pg_temp.as_user('00000000-0000-7000-8000-00000000000c');
insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000c', 'review', 'Perfil fechado.');

select pg_temp.as_user('00000000-0000-7000-8000-00000000000c');
do $$ begin
  assert (select count(*) from public.posts) = 1, 'C (Grátis) só vê os próprios posts';
  assert (public.profile_preview('bia') -> 'recent_posts' -> 0 ->> 'chars')::int = 17, 'prévia traz só o tamanho';
  assert (public.profile_preview('bia')::text not like '%Capitu é o livro%'), 'prévia não vaza o texto';
  raise notice 'OK 11 Grátis vê só a prévia (sem texto) dos outros perfis';
end $$;

select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');
do $$ begin
  assert (select count(*) from public.posts where author_id = '00000000-0000-7000-8000-00000000000b') = 1, 'Pro vê perfil aberto';
  assert (select count(*) from public.posts where author_id = '00000000-0000-7000-8000-00000000000c') = 0, 'Pro não vê perfil fechado sem aprovação';
end $$;
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000c');
do $$ begin
  assert (select status from public.follows) = 'pending', 'perfil fechado → pedido pendente';
end $$;
select pg_temp.as_user('00000000-0000-7000-8000-00000000000c');
update public.follows set status = 'accepted' where followee_id = '00000000-0000-7000-8000-00000000000c';
select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');
do $$ begin
  assert (select count(*) from public.posts where author_id = '00000000-0000-7000-8000-00000000000c') = 1, 'Pro vê perfil fechado depois de aceito';
  assert (select followers_count from public.profile_stats where user_id = '00000000-0000-7000-8000-00000000000c') = 1, 'contador de seguidores';
  raise notice 'OK 12 perfil fechado: pedido → aceite → Pro passa a ver; contadores';
end $$;

-- ---------------------------------------------------------------- busca, cota, estatísticas
reset role;
insert into catalog.editions (isbn13, title, source, source_license) values
  ('9788535910663', 'Dom Casmurro', 'openlibrary', 'CC0'),
  ('9788525406626', 'Memórias Póstumas de Brás Cubas', 'openlibrary', 'CC0');
set role authenticated;
select pg_temp.as_user('00000000-0000-7000-8000-00000000000b');
do $$ begin
  assert (select title from public.search_editions('memorias postumas') limit 1) = 'Memórias Póstumas de Brás Cubas', 'busca sem acento';
  raise notice 'OK 13 busca no catálogo por trigramas sem acento';
end $$;
reset role;
do $$ declare i int; ok boolean; begin
  for i in 1..30 loop
    ok := private.consume_quota('00000000-0000-7000-8000-00000000000b', 'isbn_externo', 30);
    assert ok, 'dentro da cota';
  end loop;
  assert not private.consume_quota('00000000-0000-7000-8000-00000000000b', 'isbn_externo', 30), 'cota estourada';
  raise notice 'OK 14 uso justo: 30 consultas externas/dia no Grátis';
end $$;

-- ---------------------------------------------------------------- ataques e contrato do PowerSync
set role authenticated;
select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');
do $$ begin
  begin
    update public.club_members set role = 'owner' where user_id = '00000000-0000-7000-8000-00000000000a';
    raise exception 'deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.posts (author_id, kind, body, likes_count) values ('00000000-0000-7000-8000-00000000000a', 'review', 'x', 1000000);
    raise exception 'deveria falhar';
  exception when insufficient_privilege then null;
  end;
  raise notice 'OK 15 sem escalada de papel no clube e sem contador forjado (GRANT por coluna)';
end $$;

reset role;
set role anon;
do $$ begin
  begin
    perform public.profile_preview('bia');
    raise exception 'deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    perform 1 from public.profiles limit 1;
    raise exception 'deveria falhar';
  exception when insufficient_privilege then null;
  end;
  raise notice 'OK 16 anon (chave pública) não lê perfis nem chama RPCs';
end $$;
reset role;

-- livro de C criado direto (superusuário) para o teste de referência cruzada
insert into personal.user_books (id, user_id, title, author_display, format, status, added_at, created_at, updated_at, version_hlc)
values ('01927a00-0000-7000-8000-0000000000c1', '00000000-0000-7000-8000-00000000000c', 'Livro da Caio', 'Autor', 'epub', 'reading',
        now(), now(), now(), '0001726862400000-0000-devc');

set role authenticated;
select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');
do $$ declare r jsonb; begin
  -- 1) posição apontando para o livro de outra pessoa → recusado pela FK composta
  r := public.sync_apply_changes($j$[
    {"table":"reading_positions","op":"PUT","id":"01927a00-0000-7000-8000-0000000000c1","hlc":"0001726862400000-0009-dev1",
     "data":{"locator":{"v":1},"ref_page":1,"chapter_index":0,"progression":0.1,"created_at":"2026-09-20T10:00:00Z","updated_at":"2026-09-20T10:00:00Z"}}
  ]$j$::jsonb);
  assert (r -> 'rejected' -> 0 ->> 'id') = '01927a00-0000-7000-8000-0000000000c1', 'referência cruzada recusada';
  -- 2) HLC no futuro distante
  r := public.sync_apply_changes($j$[
    {"table":"annotations","op":"PATCH","id":"01927a00-0000-7000-8000-000000000101","hlc":"9999999999999999-0000-dev1","data":{"color":"#FFC1C6"}}
  ]$j$::jsonb);
  assert (r -> 'rejected' -> 0 ->> 'error') = 'invalid_hlc', 'HLC do futuro recusado';
  -- 3) jsonb como texto (como o SQLite manda) + lote com 1 linha inválida que não trava as outras
  r := public.sync_apply_changes($j$[
    {"table":"bookmarks","op":"PUT","id":"01927a00-0000-7000-8000-000000000401","hlc":"0001726862700000-0000-dev1",
     "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","locator":"{\"v\":1,\"spine\":12,\"offset\":5321}",
             "ref_page":159,"chapter_index":31,"excerpt":"Retórica dos namorados, dá-me uma comparação exata e poética…",
             "created_at":"2026-09-20T22:00:00Z","updated_at":"2026-09-20T22:00:00Z"}},
    {"table":"pen_presets","op":"PUT","id":"00000000-0000-7000-8000-00000000000a","hlc":"0001726862700000-0001-dev1",
     "data":{"pen_color":"vermelho","created_at":"2026-09-20T22:00:00Z","updated_at":"2026-09-20T22:00:00Z"}}
  ]$j$::jsonb);
  assert (r ->> 'applied')::int = 1 and jsonb_array_length(r -> 'rejected') = 1, 'lote parcial: 1 aplicada, 1 recusada';
  assert (select jsonb_typeof(locator) from personal.bookmarks where id = '01927a00-0000-7000-8000-000000000401') = 'object', 'texto JSON virou objeto';
  -- 4) sessão: mudar started_at é proibido; sessão no futuro é recusada
  r := public.sync_apply_changes($j$[
    {"table":"reading_sessions","op":"PATCH","id":"01927a00-0000-7000-8000-000000000301","hlc":"0001726862800000-0000-dev1",
     "data":{"started_at":"2026-09-21T19:30:00Z"}},
    {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-000000000302","hlc":"0001726862800000-0001-dev1",
     "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","started_at":"2031-01-01T10:00:00Z","ended_at":"2031-01-01T10:20:00Z",
             "active_seconds":1200,"source":"auto","created_at":"2026-09-20T22:00:00Z","updated_at":"2026-09-20T22:00:00Z"}}
  ]$j$::jsonb);
  assert jsonb_array_length(r -> 'rejected') = 2, 'started_at imutável e sessão futura recusada';
  assert (select count(*) from personal.reading_sessions where id = '01927a00-0000-7000-8000-000000000301') = 1, 'sem linha duplicada';
  raise notice 'OK 17 referência cruzada, HLC futuro, JSON em texto, lote parcial e regras da sessão';
end $$;

-- clube público: entra sem convite; clube por convite não
reset role;
create temp table t_club as select id from public.clubs where name = 'Clube 2 da Ana';
grant select on t_club to authenticated;
set role authenticated;
select pg_temp.as_user('00000000-0000-7000-8000-00000000000a');
update public.clubs set privacy = 'public' where name = 'Clube 1 da Ana';
select pg_temp.as_user('00000000-0000-7000-8000-00000000000c');
select public.join_public_club((select id from public.clubs where name = 'Clube 1 da Ana'));
do $$ begin
  assert private.is_club_member((select id from public.clubs where name = 'Clube 1 da Ana')), 'C entrou no clube público';
  begin
    perform public.join_public_club((select id from t_club));      -- "Clube 2 da Ana" é por convite
    raise exception 'deveria falhar';
  exception when sqlstate 'P0001' then
    if sqlerrm <> 'club_not_public' then raise; end if;
  end;
  raise notice 'OK 18 clube público sem convite; clube por convite exige código';
end $$;

-- prévia de perfil fechado não mostra os posts recentes para quem não é seguidor aceito
select pg_temp.as_user('00000000-0000-7000-8000-00000000000b');
do $$ begin
  assert jsonb_array_length(public.profile_preview('caio') -> 'recent_posts') = 0, 'perfil fechado sem metadados de posts';
  raise notice 'OK 19 prévia de perfil fechado não expõe posts';
end $$;

-- ---------------------------------------------------------------- partições e retenção
reset role;
select private.ensure_session_partitions(2);
do $$ begin
  assert to_regclass(format('personal.reading_sessions_%s', to_char(now(), 'YYYY_MM'))) is not null, 'partição do mês';
  assert to_regclass('personal.reading_sessions_default') is null, 'sem partição default';
  raise notice 'OK 20 partições mensais das sessões (sem default)';
end $$;

update billing.entitlements set active_until = now() - interval '13 months'
 where user_id = '00000000-0000-7000-8000-00000000000a';
select private.refresh_sync_access();
select private.run_retention();
do $$ begin
  assert (select count(*) from personal.user_books where user_id = '00000000-0000-7000-8000-00000000000a') = 1, 'ainda não apaga: aviso primeiro';
  assert (select count(*) from private.email_outbox where template = 'retention_warning') = 1, 'aviso enfileirado';
  assert not (select granted from billing.sync_access where user_id = '00000000-0000-7000-8000-00000000000a'), 'sync revogado (passou da folga de 7 dias)';
end $$;
update private.account_lifecycle set warning_sent_at = now() - interval '31 days'
 where user_id = '00000000-0000-7000-8000-00000000000a';
select private.run_retention();
do $$ begin
  assert (select count(*) from personal.user_books where user_id = '00000000-0000-7000-8000-00000000000a') = 0, 'apagado 30 dias após o aviso';
  assert (select count(*) from personal.reading_sessions where user_id = '00000000-0000-7000-8000-00000000000a') = 0, 'sessões em cascata';
  assert (select count(*) from personal.user_books where user_id = '00000000-0000-7000-8000-00000000000c') = 1, 'dados de outro usuário intactos';
  assert (select count(*) from private.email_outbox where template = 'retention_purged') = 1, 'e-mail de exclusão enfileirado';
  raise notice 'OK 21 retenção: aviso ≥ 30 dias antes, depois purge; revogação do sync';
end $$;

-- exclusão de conta do dono: o clube passa para outro membro (posts dos outros ficam)
delete from auth.users where id = '00000000-0000-7000-8000-00000000000b';
do $$ begin
  assert (select owner_id from public.clubs where name = 'Leitoras de Capitu') = '00000000-0000-7000-8000-00000000000a', 'Ana herdou o clube';
  assert (select role from public.club_members m join public.clubs c on c.id = m.club_id
           where c.name = 'Leitoras de Capitu' and m.user_id = '00000000-0000-7000-8000-00000000000a') = 'owner', 'papel owner';
  assert (select count(*) from public.club_post_replies) = 1, 'resposta da Ana continua';
  raise notice 'OK 22 exclusão de conta transfere o clube e preserva o conteúdo dos outros';
end $$;

-- folga de 7 dias no bucket do PowerSync e partição criada sob demanda
insert into auth.users (id, email) values ('00000000-0000-7000-8000-00000000000d', 'duda@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000d', 'pro', now() - interval '2 days');
select private.refresh_sync_access();
do $$ begin
  assert (select granted from billing.sync_access where user_id = '00000000-0000-7000-8000-00000000000d'), 'bucket mantido na folga';
  assert not private.can_sync('00000000-0000-7000-8000-00000000000d'), 'mas upload já bloqueado';
end $$;
drop table if exists personal.reading_sessions_2026_01;
select private.ensure_session_partition_for('2026-01-15T12:00:00Z');
do $$ begin
  assert to_regclass('personal.reading_sessions_2026_01') is not null, 'partição criada sob demanda';
  raise notice 'OK 23 folga de 7 dias no bucket (upload bloqueado na hora) e partição sob demanda';
end $$;

select 'TODOS OS TESTES PASSARAM' as resultado;
