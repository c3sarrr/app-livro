// T02 — o conjunto de pranchas em medição (variável CONJUNTO; padrão: leitor) e os caminhos dele (conjuntos.json).
const fs = require('fs');
const path = require('path');

const RAIZ = path.resolve(__dirname, '..', '..');
const NOME = process.env.CONJUNTO || 'leitor';
const TODOS = JSON.parse(fs.readFileSync(path.join(__dirname, 'conjuntos.json'), 'utf8'));
if (!TODOS[NOME] || NOME.startsWith('_')) throw new Error(`CONJUNTO desconhecido: ${NOME}`);
const C = TODOS[NOME];

// Caminho absoluto da saída/entrada [chave] do conjunto, com [partes] a mais.
function caminho(chave, ...partes) {
  return path.join(RAIZ, ...C[chave].split('/'), ...partes);
}

module.exports = { NOME, C, RAIZ, caminho };
