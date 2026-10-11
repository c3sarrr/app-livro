/** ISBN-10 ou ISBN-13 (com ou sem hífens) → ISBN-13 válido, ou null (mesma regra do pipeline e do app). */
export function normalizarIsbn(entrada: string): string | null {
  const s = entrada.replace(/[\s\-‐‑‒–—.]/g, '').toUpperCase();
  if (/^\d{9}[\dX]$/.test(s)) {
    let soma = 0;
    for (let i = 0; i < 9; i++) soma += (10 - i) * Number(s[i]);
    soma += s[9] === 'X' ? 10 : Number(s[9]);
    if (soma % 11 !== 0) return null;
    return comDigito('978' + s.slice(0, 9));
  }
  if (/^97[89]\d{10}$/.test(s)) return comDigito(s.slice(0, 12)) === s ? s : null;
  return null;
}

function comDigito(doze: string): string {
  let soma = 0;
  for (let i = 0; i < 12; i++) soma += Number(doze[i]) * (i % 2 === 0 ? 1 : 3);
  return doze + String((10 - (soma % 10)) % 10);
}
