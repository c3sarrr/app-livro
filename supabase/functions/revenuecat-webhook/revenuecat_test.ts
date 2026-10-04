import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { normalizarAssinante, normalizarAssinatura } from './revenuecat.ts';

const AGORA = Date.parse('2026-10-04T12:00:00Z');
const base = {
  purchase_date: '2026-09-20T12:00:00Z',
  original_purchase_date: '2026-08-20T12:00:00Z',
  period_type: 'normal',
  store: 'play_store',
  is_sandbox: false,
  store_transaction_id: 'GPA.1234-5678-9012-34567..2',
};

Deno.test('ativa: Play com o id da transação original (sem o sufixo da renovação)', () => {
  const a = normalizarAssinatura(
    'booknest_pro:mensal',
    { ...base, expires_date: '2026-10-20T12:00:00Z' },
    AGORA,
  )!;
  assertEquals(a.status, 'active');
  assertEquals(a.will_renew, true);
  assertEquals(a.original_transaction_id, 'GPA.1234-5678-9012-34567');
  assertEquals(a.environment, 'production');
  assertEquals(a.ends_at, '2026-10-20T12:00:00Z');
});

Deno.test('cancelada (desligou a renovação) continua até o fim do período', () => {
  const a = normalizarAssinatura('booknest_pro:mensal', {
    ...base,
    expires_date: '2026-10-20T12:00:00Z',
    unsubscribe_detected_at: '2026-10-01T00:00:00Z',
  }, AGORA)!;
  assertEquals([a.status, a.will_renew], ['cancelled', false]);
});

Deno.test('vencida com carência ativa = in_grace_period; sem carência = expired', () => {
  const vencida = {
    ...base,
    expires_date: '2026-10-01T12:00:00Z',
    billing_issues_detected_at: '2026-10-01T12:00:00Z',
  };
  assertEquals(
    normalizarAssinatura('p', { ...vencida, grace_period_expires_date: '2026-10-16T12:00:00Z' }, AGORA)!
      .status,
    'in_grace_period',
  );
  assertEquals(normalizarAssinatura('p', vencida, AGORA)!.status, 'expired');
});

Deno.test('problema de cobrança antes de vencer = in_billing_retry; pausa do Android = paused', () => {
  assertEquals(
    normalizarAssinatura('p', {
      ...base,
      expires_date: '2026-10-20T12:00:00Z',
      billing_issues_detected_at: '2026-10-03T00:00:00Z',
    }, AGORA)!
      .status,
    'in_billing_retry',
  );
  assertEquals(
    normalizarAssinatura('p', {
      ...base,
      expires_date: '2026-10-01T00:00:00Z',
      auto_resume_date: '2026-11-01T00:00:00Z',
    }, AGORA)!.status,
    'paused',
  );
});

Deno.test('reembolso = refunded, sem renovação', () => {
  const a = normalizarAssinatura('p', {
    ...base,
    expires_date: '2026-10-20T12:00:00Z',
    refunded_at: '2026-10-02T00:00:00Z',
  }, AGORA)!;
  assertEquals([a.status, a.will_renew], ['refunded', false]);
});

Deno.test('App Store: teste grátis em sandbox; cadeia identificada por produto + compra original', () => {
  const a = normalizarAssinatura('booknest_pro_anual', {
    ...base,
    store: 'app_store',
    period_type: 'trial',
    is_sandbox: true,
    store_transaction_id: '2000000999',
    expires_date: '2026-10-11T12:00:00Z',
  }, AGORA)!;
  assertEquals(a.period_type, 'trial');
  assertEquals(a.environment, 'sandbox');
  assertEquals(a.original_transaction_id, 'booknest_pro_anual@2026-08-20T12:00:00Z');
});

Deno.test('promocional sem data de fim e lojas que o app não vende', () => {
  const lista = normalizarAssinante({
    subscriptions: {
      rc_promo_pro_lifetime: { ...base, store: 'promotional', expires_date: null },
      web: { ...base, store: 'stripe', expires_date: '2026-12-01T00:00:00Z' },
    },
  }, AGORA);
  assertEquals(lista.length, 1);
  assertEquals([lista[0].store, lista[0].period_type, lista[0].status], [
    'promotional',
    'promotional',
    'active',
  ]);
  assertEquals(lista[0].ends_at, '9999-12-31T23:59:59Z');
  assertEquals(normalizarAssinante(null), []);
});
