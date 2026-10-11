// Envio de push pelo FCM HTTP v1 (Android e iOS — ADR-010). A credencial é uma conta de serviço
// do Firebase (JSON no segredo FCM_SERVICE_ACCOUNT); o token de acesso OAuth 2 é obtido com um JWT
// RS256 assinado aqui (WebCrypto) e guardado até perto de expirar.

export type ContaDeServico = { project_id: string; client_email: string; private_key: string };
export type Buscar = typeof fetch;

function base64url(dados: Uint8Array | string): string {
  const bytes = typeof dados === 'string' ? new TextEncoder().encode(dados) : dados;
  let bin = '';
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function pemParaDer(pem: string): Uint8Array<ArrayBuffer> {
  const bin = atob(pem.replace(/-----(BEGIN|END) PRIVATE KEY-----/g, '').replace(/\s+/g, ''));
  const der = new Uint8Array(new ArrayBuffer(bin.length));
  for (let i = 0; i < bin.length; i++) der[i] = bin.charCodeAt(i);
  return der;
}

export async function jwtDaConta(sa: ContaDeServico, agoraSeg: number): Promise<string> {
  const cabecalho = base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const corpo = base64url(JSON.stringify({
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: agoraSeg,
    exp: agoraSeg + 3600,
  }));
  const chave = await crypto.subtle.importKey(
    'pkcs8',
    pemParaDer(sa.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const assinatura = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    chave,
    new TextEncoder().encode(`${cabecalho}.${corpo}`),
  );
  return `${cabecalho}.${corpo}.${base64url(new Uint8Array(assinatura))}`;
}

let cache: { token: string; expira: number } | null = null;

export async function tokenDeAcesso(
  sa: ContaDeServico,
  buscar: Buscar,
  agoraSeg = Math.floor(Date.now() / 1000),
): Promise<string> {
  if (cache && cache.expira - 60 > agoraSeg) return cache.token;
  const r = await buscar('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: await jwtDaConta(sa, agoraSeg),
    }),
    signal: AbortSignal.timeout(5000),
  });
  if (!r.ok) throw new Error(`oauth ${r.status}`);
  const j = await r.json();
  cache = { token: j.access_token, expira: agoraSeg + Number(j.expires_in ?? 3600) };
  return cache.token;
}

export function limparCache() {
  cache = null;
}

export type Mensagem = { titulo: string; corpo: string; dados: Record<string, string> };

/** 'ok', 'token_invalido' (o app foi desinstalado/o token mudou) ou lança em erro transitório. */
export async function enviar(
  projeto: string,
  acesso: string,
  token: string,
  m: Mensagem,
  buscar: Buscar,
): Promise<'ok' | 'token_invalido'> {
  const r = await buscar(`https://fcm.googleapis.com/v1/projects/${projeto}/messages:send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${acesso}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      message: {
        token,
        notification: { title: m.titulo, body: m.corpo },
        data: m.dados,
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default' } } },
      },
    }),
    signal: AbortSignal.timeout(5000),
  });
  if (r.ok) return 'ok';
  const status = (await r.json().catch(() => ({})))?.error?.status;
  if (
    r.status === 404 || status === 'UNREGISTERED' || status === 'NOT_FOUND' || status === 'INVALID_ARGUMENT'
  ) {
    return 'token_invalido';
  }
  throw new Error(`fcm ${r.status} ${status ?? ''}`.trim());
}
