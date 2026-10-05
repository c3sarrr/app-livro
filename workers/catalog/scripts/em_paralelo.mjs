// Roda `fazer` sobre os itens de um iterável (síncrono ou assíncrono) com no máximo `n` ao mesmo tempo.
// O primeiro erro para de pegar itens novos, espera os que estão em andamento e é relançado: quem chama nunca
// segue em frente (por exemplo, publicando os manifestos) com um item faltando — revisão 2, achado 1.
export async function emParalelo(itens, n, fazer) {
  const fonte = itens[Symbol.asyncIterator] ? itens[Symbol.asyncIterator]() : itens[Symbol.iterator]();
  let erro = null;
  let feitos = 0;
  async function trabalhador() {
    while (erro === null) {
      const proximo = await fonte.next();
      if (proximo.done) return;
      try {
        await fazer(proximo.value);
        feitos++;
      } catch (e) {
        if (erro === null) erro = e;
      }
    }
  }
  await Promise.all(Array.from({ length: n }, trabalhador));
  if (erro !== null) throw erro;
  return feitos;
}
