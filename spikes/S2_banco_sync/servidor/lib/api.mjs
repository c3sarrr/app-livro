// G02 · S2 — "PostgREST" mínimo: só as RPCs que o app usa no spike. Faz o que o PostgREST do
// Supabase faz: confere o JWT (HS256, aud=authenticated), entra no papel `authenticated`, põe as
// claims em request.jwt.claims e chama a função; erros do Postgres viram HTTP pelo SQLSTATE.
import http from 'node:http';
import pg from 'pg';
import { jwtVerify } from 'jose';

function status(sqlstate) {
  const c2 = sqlstate.slice(0, 2);
  if (sqlstate === 'P0001') return 400;
  if (c2 === '28') return 403;
  if (c2 === '53') return 503;
  if (['40', '55', '57', '58', 'XX'].includes(c2)) return 500;
  return 400;
}

export async function iniciarApi({ conexao, segredoB64, lockTimeoutMs = 2000 }) {
  const pool = new pg.Pool({ connectionString: conexao, max: 10 });
  const chave = Buffer.from(segredoB64, 'base64url');
  const metricas = { chamadas: 0, erros: 0, porStatus: {}, lotesMs: [] };
  const server = http.createServer(async (req, res) => {
    const responder = (st, corpo) => {
      metricas.porStatus[st] = (metricas.porStatus[st] ?? 0) + 1;
      res.writeHead(st, { 'content-type': 'application/json' });
      res.end(JSON.stringify(corpo));
    };
    try {
      const m = req.url.match(/^\/rest\/v1\/rpc\/(sync_apply_changes|my_entitlement)$/);
      if (req.method !== 'POST' || !m) return responder(404, { message: 'not found' });
      const token = (req.headers.authorization ?? '').replace(/^Bearer /, '');
      let claims;
      try {
        ({ payload: claims } = await jwtVerify(token, chave, { audience: 'authenticated' }));
      } catch {
        return responder(401, { message: 'JWT inválido' });
      }
      let corpo = '';
      for await (const ch of req) corpo += ch;
      const args = corpo ? JSON.parse(corpo) : {};
      metricas.chamadas++;
      const c = await pool.connect();
      try {
        await c.query('begin');
        await c.query('set local role authenticated');
        await c.query("select set_config('request.jwt.claims', $1, true)", [JSON.stringify(claims)]);
        await c.query(`set local lock_timeout = '${lockTimeoutMs}ms'`);
        const t0 = performance.now();
        const r =
          m[1] === 'sync_apply_changes'
            ? await c.query('select public.sync_apply_changes($1::jsonb) as r', [JSON.stringify(args.p_changes)])
            : await c.query('select public.my_entitlement() as r');
        await c.query('commit');
        if (m[1] === 'sync_apply_changes') metricas.lotesMs.push({ n: args.p_changes.length, ms: performance.now() - t0 });
        responder(200, r.rows[0].r);
      } catch (e) {
        await c.query('rollback').catch(() => {});
        metricas.erros++;
        responder(status(e.code ?? 'XX000'), { code: e.code, message: e.message });
      } finally {
        c.release();
      }
    } catch (e) {
      responder(500, { message: String(e) });
    }
  });
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  return {
    porta: server.address().port,
    metricas,
    async fechar() {
      await new Promise((r) => server.close(r));
      await pool.end();
    },
  };
}
