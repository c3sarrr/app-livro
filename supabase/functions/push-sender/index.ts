import { sql } from '../_shared/db.ts';
import { chavesDoAgendador } from '../_shared/env.ts';
import { type ContaDeServico, enviar, tokenDeAcesso } from './fcm.ts';
import { criarHandler } from './handler.ts';

const bruto = Deno.env.get('FCM_SERVICE_ACCOUNT');
const conta: ContaDeServico | null = bruto ? JSON.parse(bruto) : null;

Deno.serve(criarHandler({
  chavesAceitas: chavesDoAgendador(),
  configurado: conta !== null,
  async reservar(limite) {
    return await sql()`select notification_id, type, actor_handle, club_name, payload, tokens
                         from private.claim_pushes(${limite})` as never;
  },
  async enviar(token, m) {
    return enviar(conta!.project_id, await tokenDeAcesso(conta!, fetch), token, m, fetch);
  },
  async descartarToken(token) {
    await sql()`select private.drop_device_token(${token})`;
  },
}));
