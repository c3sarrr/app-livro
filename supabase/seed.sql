-- Dados do ambiente LOCAL (supabase db reset). Nunca dados reais; nada aqui vai para stg/prod.
-- Por enquanto vazio: os testes pgTAP criam os próprios dados dentro de transações.
select 1;

-- G22 (D-237): no Supabase local, a Test Store do RevenueCat dá Pro a qualquer conta (a prova no aparelho cria contas
-- novas). Na produção a chave fica desligada e só as contas de private.billing_test_accounts ganham Pro por ela.
update private.billing_config set test_store_grants_pro = true;
