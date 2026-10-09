// Liga a página (index.html) à lógica de painel.js. Sem bibliotecas, sem cookies, sem rastreamento.
import { CONFIG } from './config.js';
import { configurada, criarPainel, linhas } from './painel.js';

const MENSAGENS = {
  email_invalido: 'Confira o e-mail digitado.',
  codigo_invalido: 'Código inválido ou vencido. Peça um novo.',
  muitas_tentativas: 'Muitas tentativas. Espere um pouco e tente de novo.',
  rede: 'Sem conexão. Tente de novo quando estiver online.',
  servidor: 'O servidor não respondeu. Tente de novo em alguns minutos.',
  sessao: 'A sessão venceu. Entre de novo.',
  nao_moderador: 'Esta conta não modera.',
  ja_decidida: 'Outra pessoa já decidiu esta denúncia.',
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
    aviso('Esta página ainda não está configurada (config.js).', true);
    return;
  }
  const painel = criarPainel(CONFIG);

  async function carregar() {
    ocupado(true);
    const r = await painel.fila();
    ocupado(false);
    if (r.erro) {
      aviso(MENSAGENS[r.erro], true);
      if (r.erro === 'sessao') {
        $('etapa-fila').hidden = true;
        $('etapa-email').hidden = false;
      }
      return;
    }
    const itens = linhas(r.itens);
    $('contagem').textContent = itens.length === 1
      ? '1 denúncia aberta'
      : `${itens.length} denúncias abertas`;
    $('vazia').hidden = itens.length > 0;
    const lista = $('fila');
    lista.replaceChildren();
    for (const i of itens) {
      const no = $('modelo-item').content.firstElementChild.cloneNode(true);
      no.querySelector('.tipo').textContent = i.tipo;
      no.querySelector('.motivo').textContent = i.motivo;
      no.querySelector('.idade').textContent = i.idade;
      no.querySelector('.atrasada').hidden = !i.atrasada;
      if (i.atrasada) no.classList.add('vencida');
      no.querySelector('.texto').textContent = i.texto;
      const decidir = async (decisao) => {
        ocupado(true);
        const d = await painel.decidir(i.id, decisao, no.querySelector('.nota').value);
        ocupado(false);
        aviso(d.erro ? MENSAGENS[d.erro] : decisao === 'hide' ? 'Escondido.' : 'Mantido.', Boolean(d.erro));
        await carregar();
      };
      no.querySelector('.esconder').addEventListener('click', () => decidir('hide'));
      no.querySelector('.manter').addEventListener('click', () => decidir('dismiss'));
      lista.append(no);
    }
  }

  $('form-email').addEventListener('submit', async (e) => {
    e.preventDefault();
    ocupado(true);
    aviso('', false);
    const r = await painel.pedirCodigo($('email').value);
    ocupado(false);
    if (r.erro) return aviso(MENSAGENS[r.erro], true);
    $('etapa-email').hidden = true;
    $('etapa-codigo').hidden = false;
    $('codigo').focus();
    aviso('Se a conta existir, enviamos um código de 6 dígitos para o e-mail.', false);
  });

  $('form-codigo').addEventListener('submit', async (e) => {
    e.preventDefault();
    ocupado(true);
    aviso('', false);
    const r = await painel.entrar($('email').value, $('codigo').value);
    ocupado(false);
    if (r.erro) return aviso(MENSAGENS[r.erro], true);
    $('etapa-codigo').hidden = true;
    $('etapa-fila').hidden = false;
    await carregar();
  });

  $('voltar').addEventListener('click', () => {
    $('etapa-codigo').hidden = true;
    $('etapa-email').hidden = false;
    aviso('', false);
  });
  $('atualizar').addEventListener('click', () => carregar());
}

iniciar();
