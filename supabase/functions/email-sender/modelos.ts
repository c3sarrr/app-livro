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
    default:
      return null;
  }
}
