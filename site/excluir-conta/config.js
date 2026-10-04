// Configuração PÚBLICA da página (a chave publishable do Supabase é pública; NUNCA a secreta).
// Preenchida na publicação (hospedagem: Q9). Com os marcadores <…>, a página avisa que não está pronta.
// Teste local: supabaseUrl 'http://127.0.0.1:54321' + a chave pública LOCAL, e a função delete-account
// com EXCLUSAO_WEB_ORIGEM = a origem desta página (ex.: http://127.0.0.1:8080).
export const CONFIG = {
  supabaseUrl: '<https://<ref-do-projeto>.supabase.co>',
  chavePublica: '<chave pública sb_publishable_…>',
};
