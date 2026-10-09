// Textos dos e-mails (provisórios: o texto final depende do design, do domínio/remetente — Q9 — e
// da revisão jurídica da G25). Sempre em português do Brasil, sem dados pessoais além do necessário.

export type Email = { assunto: string; texto: string };

function dataBr(iso: unknown): string {
  const d = new Date(String(iso));
  return Number.isNaN(d.getTime())
    ? 'em breve'
    : d.toLocaleDateString('pt-BR', { timeZone: 'America/Sao_Paulo' });
}

export function montar(template: string, payload: Record<string, unknown>): Email | null {
  switch (template) {
    case 'retention_warning':
      return {
        assunto: 'Seus dados de leitura na nuvem serão apagados',
        texto: `Olá! Sua assinatura Pro terminou e guardamos seus dados de leitura na nuvem por 12 meses.\n` +
          `Eles serão apagados da nuvem em ${dataBr(payload.purge_after)}. No seu celular, nada muda.\n` +
          `Para manter a cópia na nuvem, é só voltar ao Pro antes dessa data.`,
      };
    case 'retention_purged':
      return {
        assunto: 'Seus dados de leitura foram apagados da nuvem',
        texto:
          'Como avisamos, apagamos da nuvem os seus dados de leitura (eles continuam no seu celular).\n' +
          'Se voltar ao Pro, o app envia tudo de novo a partir do celular.',
      };
    case 'welcome':
      return { assunto: 'Boas-vindas ao BookNest', texto: 'Que bom ter você por aqui. Boas leituras!' };
    case 'export_ready':
      return {
        assunto: 'Seus dados estão prontos',
        texto: 'A exportação dos seus dados terminou. Abra o app para baixar.',
      };
    case 'moderation_digest': {
      // D-221: o e-mail do dia para quem modera (o painel tem o resto). D-48: e quantas contas comuns (fora da
      // lista de contas de teste) tiveram compra sandbox nas últimas 24 h, sem dizer quais.
      const abertas = Number(payload.open ?? 0);
      const passaram = Number(payload.breached ?? 0);
      const sandbox = Number(payload.sandbox_accounts ?? 0);
      const quantas = `${abertas} ${abertas === 1 ? 'denúncia aberta' : 'denúncias abertas'}`;
      const denuncias = abertas > 0
        ? `Há ${quantas} desde ${dataBr(payload.oldest)}.\n` +
          (passaram > 0
            ? `${passaram} ${passaram === 1 ? 'passou' : 'passaram'} do prazo de 24 h.\n`
            : 'Nenhuma passou do prazo de 24 h.\n') +
          'Abra o painel de moderação para decidir.'
        : 'Nenhuma denúncia aberta.';
      const contas = sandbox === 1 ? '1 conta comum' : `${sandbox} contas comuns`;
      const linhaSandbox = sandbox === 1
        ? `${contas} teve compra de teste (sandbox) nas últimas 24 h. Confira se é da revisão das lojas e, se ` +
          'for, coloque-a na lista de contas de teste.'
        : `${contas} tiveram compra de teste (sandbox) nas últimas 24 h. Confira se são da revisão das lojas e, ` +
          'se forem, coloque-as na lista de contas de teste.';
      return {
        assunto: abertas > 0 || sandbox <= 0 ? `${quantas} na moderação` : `${contas} com compra de teste`,
        texto: sandbox > 0 ? `${denuncias}\n${linhaSandbox}` : denuncias,
      };
    }
    default:
      return null;
  }
}
