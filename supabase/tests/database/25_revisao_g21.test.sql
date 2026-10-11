-- G21 (revisão independente): o que o app publica sozinho volta dizendo se gravou — a 2ª no mesmo minuto é ignorada
-- e o app não pode marcar como publicada (R9, R10) — e as leitoras de antes da G21 ganham a cor da paleta.
begin;
create extension if not exists pgtap with schema extensions;
select plan(10);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-0000000000a1', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000b2', 'bia@exemplo.com');
insert into private.account_age (user_id, band, source)
select id, '18_plus', 'birthdate' from auth.users on conflict (user_id) do nothing;
insert into private.terms_acceptances (user_id, version) select id, private.terms_version() from auth.users
on conflict do nothing;

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

insert into public.clubs (id, owner_id, name) values
  ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000a1', 'Clube da Ana');
insert into public.club_members (club_id, user_id, joined_at) values
  ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000b2', now() + interval '1 second');

-- ---------------------------------------------------------------- R9: a posição no clube
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
set local role authenticated;
select is(public.publish_progress('00000000-0000-7000-8000-00000000f001', 0.5, 10), true, 'a 1ª publicação grava e diz');
select is(public.publish_progress('00000000-0000-7000-8000-00000000f001', 0.6, 12), false,
  'a 2ª no mesmo minuto não grava, e diz (o app não marca)');
reset role;
select results_eq(
  $$ select progress_ratio, progress_chapter from public.club_members
      where club_id = '00000000-0000-7000-8000-00000000f001' and user_id = '00000000-0000-7000-8000-0000000000b2' $$,
  $$ values (0.5::numeric, 10) $$, 'ficou a 1ª');

-- ---------------------------------------------------------------- R10: os números do perfil
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
set local role authenticated;
select is(public.publish_my_stats(3, 1, 1, 2), false, 'conta recém-criada: a linha nasceu agora, não grava, e diz');
reset role;
update public.profile_stats set updated_at = now() - interval '2 minutes'
 where user_id = '00000000-0000-7000-8000-0000000000b2';
set local role authenticated;
select is(public.publish_my_stats(3, 1, 1, 2), true, 'passado o minuto, grava e diz');
reset role;
select results_eq(
  $$ select books_read_total, books_read_year, reading_now, streak_days from public.profile_stats
      where user_id = '00000000-0000-7000-8000-0000000000b2' $$,
  $$ values (3, 1, 1, 2) $$, 'os 4 números');

-- ---------------------------------------------------------------- as cores de quem já era do clube
update public.club_members set color = null where club_id = '00000000-0000-7000-8000-00000000f001';
select is(private.backfill_member_colors(), 2, 'as duas sem cor ganham cor');
select results_eq(
  $$ select color from public.club_members where club_id = '00000000-0000-7000-8000-00000000f001'
      order by joined_at $$,
  $$ values ('#B6ACE4'), ('#ABCF82') $$, 'na ordem de chegada, a 1ª livre da paleta');
select is(private.backfill_member_colors(), 0, 'de novo, nada a fazer');
select ok(not has_function_privilege('authenticated', 'private.backfill_member_colors()', 'execute'),
  'o app não chama o preenchimento');

select * from finish();
rollback;
