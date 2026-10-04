// G02 · S2 — um "aparelho": banco PowerSync (SQLite + núcleo Rust, o mesmo dos SDKs Dart/Kotlin/Swift),
// conector de upload pela RPC sync_apply_changes, rede própria (modo avião) e os fluxos do
// Anexo 02 §3.1: Grátis em localOnly, virar Pro, perder o Pro, voltar ao Pro.
import { PowerSyncDatabase } from '@powersync/node';
import { SignJWT } from 'jose';
import { esquema, TABELAS, listaColunas } from './esquema.mjs';
import { ddlBruto, enfileirarTudo, esquemaBruto } from './esquema_bruto.mjs';
import { Hlc } from './hlc.mjs';
import { Proxy } from './rede.mjs';

export const espera = (ms) => new Promise((r) => setTimeout(r, ms));

export async function aguardar(cond, { ms = 60000, passo = 100, msg = 'condição' } = {}) {
  const fim = Date.now() + ms;
  while (Date.now() < fim) {
    if (await cond()) return;
    await espera(passo);
  }
  throw new Error(`tempo esgotado esperando: ${msg}`);
}

export class Aparelho {
  constructor({ nome, uid, dir, ambiente, defasagemMs = 0, porteiro = true, modo = process.env.S2_MODO ?? 'bruto' }) {
    // modo 'bruto' = tabelas próprias (plano A', decisão); 'views' = localOnly ↔ synced (Anexo 02 §3.1)
    this.modo = modo;
    // porteiro: o conector confere o Pro no servidor ANTES de cada (re)conexão (o SDK reconecta sozinho
    // quando a rede volta) — sem direito ativo, não entrega credencial e avisa o app (aoPerderPro).
    this.porteiro = porteiro;
    this.aoPerderPro = null;
    this.nome = nome;
    this.uid = uid;
    this.dir = dir;
    this.amb = ambiente;
    this.hlc = new Hlc(nome, { defasagemMs });
    this.ev = { lotes: 0, aplicadas: 0, ignoradas: 0, recusadas: 0, errosRede: 0, errosServidor: 0, proRequired: 0, porteiroBarrou: 0, credenciais: 0 };
  }

  async abrir({ pro = false } = {}) {
    this.proxySync = await new Proxy(this.amb.portaServico).abrir();
    this.proxyApi = await new Proxy(this.amb.portaApi).abrir();
    this.logs = [];
    this.db = new PowerSyncDatabase({
      schema: this.modo === 'bruto' ? esquemaBruto() : esquema(pro),
      database: { dbFilename: `${this.nome}.db`, dbLocation: this.dir },
      // só erros no console; o resto fica guardado para diagnóstico
      logger: {
        log: (r) => {
          this.logs.push(r.message);
          // em modo avião os erros de rede são esperados: só conta
          if (r.level >= 50 && !this.aviao) console.error(`[${this.nome}] ${r.message}`, r.error ?? '');
        },
      },
    });
    await this.db.init();
    if (this.modo === 'bruto') {
      await this.db.writeTransaction(async (tx) => {
        for (const sql of ddlBruto()) await tx.execute(sql);
        await tx.execute("UPDATE app_kv SET valor = ? WHERE chave = 'sync'", [pro ? 'pro' : 'gratis']);
      });
    }
    this.pro = pro;
    return this;
  }

  modoAviao(ligado) {
    this.aviao = ligado;
    for (const p of [this.proxySync, this.proxyApi]) (ligado ? p.cortar() : p.religar());
  }

  get conexoesDeRede() {
    return this.proxySync.conexoes + this.proxyApi.conexoes + this.proxySync.recusadas + this.proxyApi.recusadas;
  }

  async token() {
    return new SignJWT({ role: 'authenticated' })
      .setProtectedHeader({ alg: 'HS256', kid: 'spike-s2' })
      .setSubject(this.uid)
      .setAudience('authenticated')
      .setIssuedAt()
      .setExpirationTime('1h')
      .sign(Buffer.from(this.amb.segredoB64, 'base64url'));
  }

  get conector() {
    return {
      fetchCredentials: async () => {
        if (this.porteiro && !(await this.podeConectar())) {
          // (sem rede, podeConectar lança → erro temporário → o SDK tenta de novo depois)
          this.ev.porteiroBarrou++;
          this.aoPerderPro?.();
          return null;
        }
        this.ev.credenciais++;
        return { endpoint: `http://127.0.0.1:${this.proxySync.porta}`, token: await this.token() };
      },
      uploadData: (db) => this.enviar(db),
    };
  }

  async rpc(nome, corpo) {
    const res = await fetch(`http://127.0.0.1:${this.proxyApi.porta}/rest/v1/rpc/${nome}`, {
      method: 'POST',
      headers: { authorization: `Bearer ${await this.token()}`, 'content-type': 'application/json' },
      body: JSON.stringify(corpo ?? {}),
    });
    return { status: res.status, corpo: await res.json() };
  }

  /** uploadData: lotes de ≤ 500 operações da fila CRUD → RPC. Recusas saem da fila e vão para
   *  sync_rejections; erro de rede/servidor (5xx) relança → o SDK tenta de novo (nada se perde). */
  async enviar(db) {
    for (;;) {
      const lote = await db.getCrudBatch(500);
      if (!lote) return;
      const ops = lote.crud.map((e) => ({
        table: e.table,
        op: e.op,
        id: e.id,
        data: e.opData ?? {},
        hlc: e.opData?.version_hlc ?? this.hlc.enviar(),
      }));
      let r;
      try {
        r = await this.rpc('sync_apply_changes', { p_changes: ops });
      } catch (e) {
        this.ev.errosRede++;
        throw e;
      }
      if (r.status === 400 && /pro_required/.test(r.corpo.message ?? '')) {
        this.ev.proRequired++;
        this.aoPerderPro?.();
        throw new Error('pro_required');
      }
      if (r.status !== 200) {
        this.ev.errosServidor++;
        throw new Error(`HTTP ${r.status} ${r.corpo.code ?? ''} ${r.corpo.message ?? ''}`);
      }
      const { applied, skipped, rejected } = r.corpo;
      if (rejected.length) {
        await db.writeTransaction(async (tx) => {
          for (const x of rejected) {
            await tx.execute(
              'insert into sync_rejections (id, tabela, linha_id, motivo, codigo, em, operacao) values (uuid(), ?, ?, ?, ?, ?, ?)',
              // guarda a OPERAÇÃO inteira: no próximo checkpoint o PowerSync volta a linha ao estado do
              // servidor (que não a tem) e ela some da tabela sincronizada — o reparo sai daqui
              [x.table, x.id, x.error, x.code, new Date().toISOString(), JSON.stringify(ops.find((o) => o.id === x.id && o.table === x.table))],
            );
          }
        });
      }
      this.ev.lotes++;
      this.ev.aplicadas += applied;
      this.ev.ignoradas += skipped;
      this.ev.recusadas += rejected.length;
      await lote.complete();
    }
  }

  async conectar() {
    await this.db.connect(this.conector, { retryDelayMs: 300, crudUploadThrottleMs: 20 });
  }

  async desconectar() {
    await this.db.disconnect();
  }

  async filaCrud() {
    return (await this.db.get('select count(*) as n from ps_crud')).n;
  }

  async remocoesIgnoradas() {
    return this.modo === 'bruto' ? (await this.db.get('select count(*) n from s2_remocoes_ignoradas')).n : 0;
  }

  async contar(prefixo = '') {
    const r = {};
    for (const t of TABELAS) r[t] = (await this.db.get(`select count(*) as n from ${prefixo}${t}`)).n;
    return r;
  }

  /** Grátis → Pro (Anexo 02 §3.1 item 2): troca o esquema (views), copia localOnly → sincronizadas
   *  numa transação (entram na fila como PUT) e só depois conecta. */
  async virarPro({ conectar = true } = {}) {
    if (this.modo === 'bruto') {
      await this.db.writeTransaction(async (tx) => {
        await tx.execute("UPDATE app_kv SET valor = 'pro' WHERE chave = 'sync'");
        for (const sql of enfileirarTudo()) await tx.execute(sql);
      });
      this.pro = true;
      if (conectar) await this.conectar();
      return;
    }
    await this.db.updateSchema(esquema(true));
    await this.db.writeTransaction(async (tx) => {
      for (const t of TABELAS) {
        const c = listaColunas(t).join(', ');
        await tx.execute(`insert into ${t} (${c}) select ${c} from inativa_local_${t}`);
        await tx.execute(`delete from inativa_local_${t}`);
      }
    });
    this.pro = true;
    if (conectar) await this.conectar();
  }

  /** Perder o Pro (item 3): desconecta JÁ, troca o esquema, copia sincronizadas → localOnly e só
   *  então limpa o estado do PowerSync (fila e buckets), preservando as localOnly. */
  async perderPro() {
    if (this.modo === 'bruto') {
      await this.db.disconnect();
      await this.db.execute("UPDATE app_kv SET valor = 'gratis' WHERE chave = 'sync'");
      await this.db.disconnectAndClear({ clearLocal: false }); // fila e buckets; as tabelas próprias ficam
      this.pro = false;
      return;
    }
    await this.db.disconnect();
    await this.db.updateSchema(esquema(false));
    await this.db.writeTransaction(async (tx) => {
      for (const t of TABELAS) {
        const c = listaColunas(t).join(', ');
        await tx.execute(`delete from ${t}`);
        await tx.execute(`insert into ${t} (${c}) select ${c} from inativa_sinc_${t}`);
      }
    });
    await this.db.disconnectAndClear({ clearLocal: false });
    this.pro = false;
  }

  /** Antes de conectar: nunca conectar sem direito ativo (o servidor decide). */
  async podeConectar() {
    const r = await this.rpc('my_entitlement');
    return r.status === 200 && r.corpo.pro === true;
  }

  async fechar() {
    await this.db.close();
    await this.proxySync.fechar();
    await this.proxyApi.fechar();
  }
}
