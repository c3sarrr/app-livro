// node --test scripts/  (npm run test:scripts)
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { emParalelo } from './em_paralelo.mjs';

const pausa = (ms) => new Promise((r) => setTimeout(r, ms));

test('faz todos, com no máximo n ao mesmo tempo', async () => {
  let agora = 0;
  let pico = 0;
  const feitos = [];
  const n = await emParalelo(Array.from({ length: 50 }, (_, i) => i), 4, async (i) => {
    agora++;
    pico = Math.max(pico, agora);
    await pausa(i % 3);
    feitos.push(i);
    agora--;
  });
  assert.equal(n, 50);
  assert.equal(pico, 4);
  assert.deepEqual([...feitos].sort((a, b) => a - b), Array.from({ length: 50 }, (_, i) => i));
});

test('um erro no meio (com o gerador lento) chega a quem chamou e nada segue depois dele', async () => {
  // o cenário da revisão: a falha acontece enquanto o laço espera o gerador (readdir lento pela rede)
  async function* lento() {
    for (let i = 0; i < 200; i++) {
      if (i % 20 === 0) await pausa(5);
      yield i;
    }
  }
  let depois = false;
  const iniciados = new Set();
  await assert.rejects(
    (async () => {
      await emParalelo(lento(), 16, async (i) => {
        iniciados.add(i);
        await pausa(1);
        if (i === 37) throw new Error('put falhou');
      });
      depois = true; // "publicar os manifestos"
    })(),
    /put falhou/,
  );
  assert.equal(depois, false);
  await pausa(50);
  assert.ok(iniciados.size < 100, `depois do erro não começa item novo (${iniciados.size} começaram)`);
});

test('aceita iterável síncrono e lista vazia', async () => {
  assert.equal(await emParalelo([], 16, async () => {}), 0);
  assert.equal(await emParalelo(new Set([1, 2, 3]), 2, async () => {}), 3);
});
