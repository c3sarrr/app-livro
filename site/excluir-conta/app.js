// Liga a página (index.html) à lógica de exclusao.js. Sem bibliotecas, sem cookies, sem rastreamento.
import { CONFIG } from './config.js';
import { configurada, criarExclusao } from './exclusao.js';

const MENSAGENS = {
  email_invalido: 'Confira o e-mail digitado.',
  codigo_invalido: 'Código inválido ou vencido. Peça um novo.',
  muitas_tentativas: 'Muitas tentativas. Espere um pouco e tente de novo.',
  rede: 'Sem conexão. Tente de novo quando estiver online.',
  servidor: 'Não foi possível excluir agora. Tente de novo em alguns minutos.',
};

const $ = (id) => document.getElementById(id);

function aviso(texto, erro) {
  const el = $('aviso');
  el.textContent = texto;
  el.className = erro ? 'aviso erro' : 'aviso';
  el.hidden = !texto;
}

function ocupado(sim) {
  for (const b of document.querySelectorAll('button')) b.disabled = sim;
}

function iniciar() {
  if (!configurada(CONFIG)) {
    $('etapa-email').hidden = true;
    aviso(
      'Esta página ainda não está configurada. Para excluir a conta agora, use o app: Perfil → Excluir conta.',
      true,
    );
    return;
  }
  const exclusao = criarExclusao(CONFIG);

  $('form-email').addEventListener('submit', async (e) => {
    e.preventDefault();
    ocupado(true);
    aviso('', false);
    const r = await exclusao.pedirCodigo($('email').value);
    ocupado(false);
    if (r.erro) return aviso(MENSAGENS[r.erro], true);
    $('etapa-email').hidden = true;
    $('etapa-codigo').hidden = false;
    $('codigo').focus();
    aviso('Se existir uma conta com esse e-mail, enviamos um código de 6 dígitos para ele.', false);
  });

  $('form-codigo').addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!$('ciente').checked) return aviso('Marque que você entende que a exclusão é definitiva.', true);
    ocupado(true);
    aviso('', false);
    const r = await exclusao.excluir($('email').value, $('codigo').value);
    ocupado(false);
    if (r.erro) return aviso(MENSAGENS[r.erro], true);
    $('etapa-codigo').hidden = true;
    $('etapa-fim').hidden = false;
  });

  $('voltar').addEventListener('click', () => {
    $('etapa-codigo').hidden = true;
    $('etapa-email').hidden = false;
    aviso('', false);
  });
}

iniciar();
