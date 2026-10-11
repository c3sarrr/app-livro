// S4 — referência do perfect-freehand 1.2.3 (npm) para conferir o porte em Dart.
// Uso: npm install perfect-freehand@1.2.3 && node ferramentas/gerar_referencia_pf.mjs > dados/pf_referencia.json
import { getStroke } from 'perfect-freehand';

function mulberry32(a) {
  return () => {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const r2 = v => Math.round(v * 100) / 100;

function traco(seed, n, comPressao) {
  const rnd = mulberry32(seed);
  const pts = [];
  let x = 40 + rnd() * 20, y = 60 + rnd() * 20, ang = rnd() * Math.PI * 2;
  for (let i = 0; i < n; i++) {
    ang += (rnd() - 0.5) * 0.9;
    const v = 2 + rnd() * 6;
    x += Math.cos(ang) * v; y += Math.sin(ang) * v;
    const p = comPressao ? r2(0.2 + 0.6 * rnd()) : undefined;
    pts.push(comPressao ? [r2(x), r2(y), p] : [r2(x), r2(y)]);
  }
  return pts;
}

const entradas = {
  curto1: [[10, 10]],
  curto2: [[10, 10], [30, 25]],
  canto: [[0, 0], [10, 0], [20, 0], [30, 0], [40, 0], [30, 1], [20, 2], [10, 3], [0, 4], [-10, 5]],
  livre_sem_pressao: traco(7, 120, false),
  livre_com_pressao: traco(11, 160, true),
  longo: traco(23, 600, true),
};
const opcoes = {
  padrao: {},
  esferografica: { size: 7.56, thinning: 0.1, smoothing: 0.5, streamline: 0.5 },
  tinteiro: { size: 7.56, thinning: 0.6, simulatePressure: false, end: { taper: true } },
  pincel: { size: 11.34, thinning: 0.85, smoothing: 0.5, start: { taper: 20 }, end: { taper: 30 } },
  completo_sem_cap: { size: 12, last: true, start: { cap: false }, end: { cap: false } },
};
const casos = [];
for (const [ne, e] of Object.entries(entradas)) {
  for (const [no, o] of Object.entries(opcoes)) {
    casos.push({ entrada: ne, opcoes: no, saida: getStroke(e, o) });
  }
}
console.log(JSON.stringify({ versao: '1.2.3', entradas, opcoes, casos }));
