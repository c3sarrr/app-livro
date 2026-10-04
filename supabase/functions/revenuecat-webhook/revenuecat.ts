// Normaliza o assinante da API REST do RevenueCat (GET /v1/subscribers/{app_user_id}) nas linhas de
// billing.subscriptions (Anexo 04 §5: não confiar na ordem dos eventos — reconciliar pelo estado).

export type AssinaturaRc = {
  expires_date: string | null;
  purchase_date: string;
  original_purchase_date?: string | null;
  period_type?: string | null;
  store: string;
  is_sandbox?: boolean;
  unsubscribe_detected_at?: string | null;
  billing_issues_detected_at?: string | null;
  grace_period_expires_date?: string | null;
  refunded_at?: string | null;
  auto_resume_date?: string | null;
  store_transaction_id?: string | null;
};

export type Assinatura = {
  store: 'app_store' | 'play_store' | 'promotional' | 'test_store';
  product_id: string;
  period_type: 'trial' | 'intro' | 'normal' | 'promotional';
  status: 'active' | 'in_grace_period' | 'in_billing_retry' | 'cancelled' | 'expired' | 'paused' | 'refunded';
  will_renew: boolean;
  starts_at: string;
  ends_at: string;
  grace_ends_at: string | null;
  original_transaction_id: string;
  environment: 'sandbox' | 'production';
};

const LOJAS: Record<string, Assinatura['store']> = {
  app_store: 'app_store',
  play_store: 'play_store',
  promotional: 'promotional',
  test_store: 'test_store',
};

/** Fim de uma assinatura vitalícia/sem data (promocional "lifetime"). */
const SEM_FIM = '9999-12-31T23:59:59Z';

function antes(a: string | null | undefined, agora: number): boolean {
  return a != null && Date.parse(a) <= agora;
}

export function normalizarAssinatura(
  productId: string,
  s: AssinaturaRc,
  agora = Date.now(),
): Assinatura | null {
  const store = LOJAS[s.store];
  if (!store) return null; // loja que o BookNest não vende (ex.: stripe): ignorada
  const fim = s.expires_date ?? SEM_FIM;
  const vencida = antes(fim, agora);
  const carenciaAtiva = s.grace_period_expires_date != null && !antes(s.grace_period_expires_date, agora);
  let status: Assinatura['status'];
  if (s.refunded_at) status = 'refunded';
  else if (vencida && carenciaAtiva) status = 'in_grace_period';
  else if (vencida && s.auto_resume_date) status = 'paused';
  else if (vencida) status = 'expired';
  else if (s.billing_issues_detected_at) status = 'in_billing_retry';
  else if (s.unsubscribe_detected_at) status = 'cancelled';
  else status = 'active';
  const periodo = s.period_type === 'trial' || s.period_type === 'intro'
    ? s.period_type
    : store === 'promotional'
    ? 'promotional'
    : 'normal';
  // A API v1 não traz o id da transação original. Play: o id da renovação é "<original>..N";
  // nas outras lojas, a cadeia é identificada por produto + data da compra original.
  const original = store === 'play_store' && s.store_transaction_id
    ? s.store_transaction_id.replace(/\.\.\d+$/, '')
    : `${productId}@${s.original_purchase_date ?? s.purchase_date}`;
  return {
    store,
    product_id: productId,
    period_type: periodo,
    status,
    will_renew: !s.unsubscribe_detected_at && !s.refunded_at && (!vencida || carenciaAtiva),
    starts_at: s.purchase_date,
    ends_at: fim,
    grace_ends_at: s.grace_period_expires_date ?? null,
    original_transaction_id: original,
    environment: s.is_sandbox ? 'sandbox' : 'production',
  };
}

export function normalizarAssinante(
  assinante: { subscriptions?: Record<string, AssinaturaRc> } | null | undefined,
  agora = Date.now(),
): Assinatura[] {
  const subs = assinante?.subscriptions ?? {};
  return Object.entries(subs)
    .map(([produto, s]) => normalizarAssinatura(produto, s, agora))
    .filter((x): x is Assinatura => x !== null);
}
