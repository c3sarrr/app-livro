// Entrega de arquivos do R2 com Range (retomada do download do catalog.db), ETag e If-Range.

export type Intervalo = { inicio: number; fim: number };

/** "bytes=N-", "bytes=N-M" ou "bytes=-K"; null = sem Range (ou Range que não tratamos: vários intervalos). */
export function lerRange(cabecalho: string | null, tamanho: number): Intervalo | 'invalido' | null {
  if (!cabecalho) return null;
  const m = /^bytes=(\d*)-(\d*)$/.exec(cabecalho.trim());
  if (!m) return null;
  const [, a, b] = m;
  if (a === '' && b === '') return 'invalido';
  if (a === '') {
    const k = Number(b);
    if (k === 0) return 'invalido';
    return { inicio: Math.max(0, tamanho - k), fim: tamanho - 1 };
  }
  const inicio = Number(a);
  const fim = b === '' ? tamanho - 1 : Math.min(Number(b), tamanho - 1);
  if (inicio >= tamanho || fim < inicio) return 'invalido';
  return { inicio, fim };
}

export async function servirArquivo(
  req: Request,
  bucket: R2Bucket,
  chave: string,
  tipo: string,
  cacheControl: string,
): Promise<Response> {
  const cabeca = await bucket.head(chave);
  if (!cabeca) return Response.json({ erro: 'nao_encontrado' }, { status: 404 });
  const etag = cabeca.httpEtag;
  const base: Record<string, string> = {
    'Content-Type': tipo,
    'Cache-Control': cacheControl,
    ETag: etag,
    'Accept-Ranges': 'bytes',
  };
  if (req.headers.get('If-None-Match') === etag) return new Response(null, { status: 304, headers: base });
  let intervalo = lerRange(req.headers.get('Range'), cabeca.size);
  const seIntervalo = req.headers.get('If-Range');
  if (intervalo && seIntervalo !== null && seIntervalo !== etag) intervalo = null; // arquivo mudou: manda inteiro
  if (intervalo === 'invalido') {
    return new Response(null, { status: 416, headers: { ...base, 'Content-Range': `bytes */${cabeca.size}` } });
  }
  const cabeca_ = req.method === 'HEAD';
  if (!intervalo) {
    const corpo = cabeca_ ? null : (await bucket.get(chave))?.body ?? null;
    return new Response(corpo, { status: 200, headers: { ...base, 'Content-Length': String(cabeca.size) } });
  }
  const tamanho = intervalo.fim - intervalo.inicio + 1;
  const corpo = cabeca_
    ? null
    : (await bucket.get(chave, { range: { offset: intervalo.inicio, length: tamanho } }))?.body ?? null;
  return new Response(corpo, {
    status: 206,
    headers: {
      ...base,
      'Content-Length': String(tamanho),
      'Content-Range': `bytes ${intervalo.inicio}-${intervalo.fim}/${cabeca.size}`,
    },
  });
}
