-- G22.6 (D-235): o other_sessions do my_account não conta a sessão que o Auth abre sozinho no cadastro por código
-- quando a confirmação de e-mail está desligada (ele cadastra com uma senha aleatória e entra, antes de mandar o
-- código; ninguém recebe essa sessão). O método dela é só "password", e o app não tem login por senha: sessão assim
-- não é outro aparelho. As demais (código, Google, Apple) continuam contando.
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
                          and (s.not_after is null or s.not_after > now())
                          and not (exists (select 1 from auth.mfa_amr_claims c
                                            where c.session_id = s.id and c.authentication_method = 'password')
                                   and not exists (select 1 from auth.mfa_amr_claims c
                                                    where c.session_id = s.id
                                                      and c.authentication_method <> 'password'))))
  from public.profiles p
  where p.id = (select auth.uid())
$$;

revoke execute on function public.my_account() from public, anon;
grant execute on function public.my_account() to authenticated, service_role;
