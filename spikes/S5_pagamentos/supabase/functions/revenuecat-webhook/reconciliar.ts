// G02 · S5 — do estado ATUAL do assinante no RevenueCat (GET /v1/subscribers/{id}) para as linhas de
// billing.subscriptions e billing.entitlements (Anexo 04 §5). Função pura: não confia na ordem dos
// eventos — o evento só dá o contexto (id da transação, horário); quem decide é o estado atual.

export interface EntitlementRC {
  expires_date: string | null;
  grace_period_expires_date: string | null;
  product_identifier: string;
  purchase_date: string;
}

export interface AssinaturaRC {
  expires_date: string | null;
  purchase_date: string;
  original_purchase_date: string;
  period_type: string;
  store: string;
  is_sandbox: boolean;
  unsubscribe_detected_at: string | null;
  billing_issues_detected_at: string | null;
  grace_period_expires_date: string | null;
  refunded_at: string | null;
  auto_resume_date?: string | null;
  store_transaction_id?: string;
}

export interface AssinanteRC {
  subscriber: {
    original_app_user_id: string;
    entitlements: Record<string, EntitlementRC>;
    subscriptions: Record<string, AssinaturaRC>;
  };
}

export interface EventoRC {
  id: string;
  type: string;
  app_user_id?: string;
  product_id?: string;
  original_transaction_id?: string;
  event_timestamp_ms?: number;
  environment?: 'SANDBOX' | 'PRODUCTION';
  transferred_from?: string[];
  transferred_to?: string[];
}

export type Loja = 'app_store' | 'play_store' | 'promotional' | 'test_store';
export type Status =
  | 'active'
  | 'in_grace_period'
  | 'in_billing_retry'
  | 'cancelled'
  | 'expired'
  | 'paused'
  | 'refunded';

export interface Resultado {
  /** null = o usuário nunca teve o entitlement `pro` (nada a gravar). */
  ativoAte: Date | null;
  ambiente: 'sandbox' | 'production';
  assinatura: {
    loja: Loja;
    produto: string;
    periodo: 'trial' | 'intro' | 'normal' | 'promotional';
    status: Status;
    renova: boolean;
    inicio: Date;
    fim: Date;
    carenciaAte: Date | null;
    transacaoOriginal: string;
  } | null;
}

const LOJAS: Record<string, Loja> = {
  app_store: 'app_store',
  mac_app_store: 'app_store',
  play_store: 'play_store',
  promotional: 'promotional',
  test_store: 'test_store',
};

const d = (s: string | null | undefined) => (s ? new Date(s) : null);
const max = (a: Date | null, b: Date | null) => (!a ? b : !b ? a : a > b ? a : b);
const LONGE = new Date('9999-12-31T00:00:00Z'); // sem expiração (vitalício/promocional sem fim)

export class LojaNaoSuportada extends Error {}

export function reconciliar(a: AssinanteRC, ev: EventoRC, agora: Date, temLinha: boolean): Resultado {
  const ent = a.subscriber.entitlements['pro'];
  if (!ent) {
    // O RevenueCat não lista mais o entitlement: se já houve Pro, encerra agora; senão, nada.
    return { ativoAte: temLinha ? agora : null, ambiente: 'production', assinatura: null };
  }
  const sub = a.subscriber.subscriptions[ent.product_identifier];
  let ativoAte = ent.expires_date === null
    ? LONGE
    : max(d(ent.expires_date), d(ent.grace_period_expires_date))!;
  if (sub?.refunded_at && new Date(sub.refunded_at) < ativoAte) ativoAte = new Date(sub.refunded_at);
  if (!sub) {
    return { ativoAte, ambiente: 'production', assinatura: null };
  }
  const loja = LOJAS[sub.store];
  if (!loja) throw new LojaNaoSuportada(sub.store);
  const fim = d(sub.expires_date) ?? LONGE;
  const carencia = d(sub.grace_period_expires_date);
  const expirada = fim <= agora && !(carencia && carencia > agora);
  const status: Status = sub.refunded_at
    ? 'refunded'
    : sub.auto_resume_date
    ? 'paused'
    : carencia && carencia > agora && fim <= agora
    ? 'in_grace_period'
    : expirada && sub.billing_issues_detected_at
    ? 'in_billing_retry'
    : expirada
    ? 'expired'
    : sub.unsubscribe_detected_at
    ? 'cancelled'
    : 'active';
  const periodo = (['trial', 'intro', 'promotional'] as const).find((p) => p === sub.period_type) ?? 'normal';
  const transacaoOriginal = ev.product_id === ent.product_identifier && ev.original_transaction_id
    ? ev.original_transaction_id
    : sub.store_transaction_id ?? `${loja}:${ent.product_identifier}:${sub.original_purchase_date}`;
  return {
    ativoAte,
    ambiente: sub.is_sandbox ? 'sandbox' : 'production',
    assinatura: {
      loja,
      produto: ent.product_identifier,
      periodo,
      status,
      renova: !sub.unsubscribe_detected_at && !sub.refunded_at && !expirada,
      inicio: new Date(sub.purchase_date),
      fim,
      carenciaAte: carencia,
      transacaoOriginal,
    },
  };
}
