// G02 · S2 — operações de "servidor" usadas pelos cenários (como o webhook / pg_cron fariam).
import crypto from 'node:crypto';
import pg from 'pg';
import { TABELAS } from './esquema.mjs';

export class Servidor {
  constructor(conexao) {
    this.pool = new pg.Pool({ connectionString: conexao, max: 5 });
  }

  async q(sql, params) {
    return (await this.pool.query(sql, params)).rows;
  }

  async novoUsuario() {
    const id = crypto.randomUUID();
    await this.q('insert into auth.users (id, email) values ($1, $2)', [id, `${id}@spike.local`]);
    return id;
  }

  /** Pro ativo até agora + dias (como o webhook grava) e bucket concedido. */
  async darPro(uid, dias = 30, ambiente = 'production') {
    await this.q(
      `insert into billing.entitlements (user_id, entitlement, active_until, environment)
       values ($1, 'pro', now() + make_interval(days => $2), $3)
       on conflict (user_id, entitlement) do update set active_until = excluded.active_until,
         environment = excluded.environment, updated_at = now()`,
      [uid, dias, ambiente],
    );
    await this.q('select private.refresh_sync_access()');
  }

  /** Fim do Pro agora (cancelamento expirado ou reembolso): upload bloqueado na hora;
   *  o bucket continua concedido por 7 dias (refresh_sync_access). */
  async tirarPro(uid) {
    await this.q(
      `update billing.entitlements set active_until = now() - interval '1 second', updated_at = now()
        where user_id = $1 and entitlement = 'pro'`,
      [uid],
    );
    await this.q('select private.refresh_sync_access()');
  }

  /** Os 7 dias passaram: o refresh revoga o bucket. */
  async passarSeteDias(uid) {
    await this.q(
      `update billing.entitlements set active_until = now() - interval '8 days' where user_id = $1`,
      [uid],
    );
    await this.q('select private.refresh_sync_access()');
  }

  async bucketConcedido(uid) {
    const r = await this.q('select granted from billing.sync_access where user_id = $1', [uid]);
    return r[0]?.granted ?? false;
  }

  /** Purge da retenção de 12 meses: apaga os dados pessoais da nuvem. */
  async purgar(uid) {
    for (const t of [...TABELAS].reverse()) {
      await this.q(`delete from personal.${t} where user_id = $1`, [uid]);
    }
  }

  async contar(uid) {
    const r = {};
    for (const t of TABELAS) {
      r[t] = Number((await this.q(`select count(*)::int n from personal.${t} where user_id = $1`, [uid]))[0].n);
    }
    return r;
  }

  async linha(t, id) {
    return (await this.q(`select * from personal.${t} where id = $1`, [id]))[0];
  }

  async fechar() {
    await this.pool.end();
  }
}

export const total = (c) => Object.values(c).reduce((a, b) => a + b, 0);
