import { sql } from '../_shared/db.ts';
import { chavesDoAgendador } from '../_shared/env.ts';
import { criarHandler } from './handler.ts';

const chave = Deno.env.get('RESEND_API_KEY');
const remetente = Deno.env.get('BOOKNEST_EMAIL_FROM');

Deno.serve(criarHandler({
  chavesAceitas: chavesDoAgendador(),
  configurado: Boolean(chave && remetente),
  async reservar(limite) {
    return await sql()`select id, email, template, payload from private.claim_emails(${limite})` as never;
  },
  async concluir(id, erroTexto) {
    await sql()`select private.finish_email(${id}, ${erroTexto ?? null})`;
  },
  async enviar(para, assunto, texto) {
    const r = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${chave}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ from: remetente, to: [para], subject: assunto, text: texto }),
      signal: AbortSignal.timeout(8000),
    });
    if (!r.ok) throw new Error(`resend ${r.status}`);
  },
}));
