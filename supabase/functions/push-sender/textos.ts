// Texto do push por tipo de notificação (provisório até o design das notificações — G21).
import type { Mensagem } from './fcm.ts';

export type Pendente = {
  notification_id: string;
  type: string;
  actor_handle: string | null;
  club_name: string | null;
  payload: Record<string, unknown>;
  tokens: string[];
};

export function mensagem(n: Pendente): Mensagem {
  const quem = n.actor_handle ? `@${n.actor_handle}` : 'Alguém';
  const clube = n.club_name ?? 'seu clube';
  const corpo = (() => {
    switch (n.type) {
      case 'follow':
        return n.payload?.accepted
          ? `${quem} aceitou seu pedido para seguir`
          : `${quem} começou a seguir você`;
      case 'follow_request':
        return `${quem} quer seguir você`;
      case 'post_like':
        return `${quem} curtiu sua resenha`;
      case 'post_comment':
        return `${quem} comentou na sua resenha`;
      case 'club_reply':
        return `Nova resposta em ${clube}`;
      case 'club_meeting':
        return `O encontro de ${clube} é amanhã`;
      default:
        return 'Você tem uma novidade no BookNest';
    }
  })();
  return { titulo: 'BookNest', corpo, dados: { notification_id: n.notification_id, type: n.type } };
}
