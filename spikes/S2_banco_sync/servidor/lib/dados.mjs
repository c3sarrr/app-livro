// G02 · S2 — gera o "acervo" de um usuário: 10.000 linhas nas 10 tabelas pessoais, com as
// referências (livro → anotação, grifo → nota, camada de tinta → desenho) e sessões espalhadas
// pelas partições (histórica 2024–2025 + mensais 2026).
import crypto from 'node:crypto';

const iso = (ms) => new Date(ms).toISOString();

export function gerarAcervo({ uid, hlc, total = 10000, semente = 1 }) {
  let s = semente;
  const rnd = () => ((s = (s * 1103515245 + 12345) % 2147483648) / 2147483648);
  const agora = Date.now();
  const base = (extra = {}) => {
    const t = iso(agora - Math.floor(rnd() * 86400000));
    return { user_id: uid, created_at: t, updated_at: t, deleted_at: null, version_hlc: hlc.enviar(), ...extra };
  };
  const linhas = { user_books: [], reading_positions: [], reading_sessions: [], bookmarks: [], ink_layers: [],
    annotations: [], highlight_labels: [], reader_settings: [], pen_presets: [], reading_goals: [] };
  const livros = [];
  for (let i = 0; i < 60; i++) {
    const id = crypto.randomUUID();
    livros.push(id);
    linhas.user_books.push({ id, ...base({ title: `Livro ${i}`, author_display: 'Machado de Assis',
      format: 'epub', status: 'reading', content_sha256: crypto.createHash('sha256').update(id).digest('hex'),
      ref_pages_total: 256, ref_page_version: 1, chapters_total: 148, added_at: iso(agora) }) });
    linhas.reading_positions.push({ id, ...base({ locator: JSON.stringify({ v: 1, spine: 3, offset: i * 10 }),
      ref_page: 1 + (i % 256), chapter_index: i % 148, progression: (i / 60).toFixed(5), device_id: 'spike' }) });
  }
  const livro = () => livros[Math.floor(rnd() * livros.length)];
  for (const [cor, rot] of [['#FED170', 'lindo'], ['#C7B8F5', 'personagem'], ['#9FD8C2', 'ideia'], ['#F7A8A0', 'pro clube']]) {
    linhas.highlight_labels.push({ id: crypto.randomUUID(), ...base({ color: cor, label: rot, sort: 0 }) });
  }
  linhas.reader_settings.push({ id: uid, ...base({ font_step: 4, font_family: 'literata', paper: 'creme', line_spacing: 'medio', margins: 'media' }) });
  linhas.pen_presets.push({ id: uid, ...base({ pen_tip: 'ballpoint', pen_width_mm: '1.2', pen_color: '#FF552E',
    favorite_colors: JSON.stringify(['#FF552E', '#552CB7']), stroke_size: 'medium', highlighter_style: 'fill',
    highlighter_height: 'medium', highlighter_color: '#FED170' }) });
  linhas.reading_goals.push({ id: uid, ...base({ daily_minutes: 30, badge_target_days: 7 }) });
  for (let i = 0; i < 600; i++) {
    linhas.bookmarks.push({ id: crypto.randomUUID(), ...base({ user_book_id: livro(), locator: JSON.stringify({ v: 1, offset: i }),
      ref_page: 1 + (i % 256), chapter_index: i % 148, excerpt: 'Olhos de ressaca? Vá, de ressaca.' }) });
  }
  const camadas = [];
  for (let i = 0; i < 700; i++) {
    const id = crypto.randomUUID();
    const espaco = i % 3 === 0;
    const ub = livro();
    camadas.push({ id, ub });
    linhas.ink_layers.push({ id, ...base({ user_book_id: ub, kind: espaco ? 'space' : 'over_text',
      anchor: JSON.stringify({ v: 1, start: i, end: i + 5 }), space_lines: espaco ? 2 : null, collapsed: 0,
      strokes_b64: Buffer.from(crypto.randomBytes(400)).toString('base64'), stroke_count: 3, codec_version: 1 }) });
  }
  const grifos = [];
  const anot = (extra) => ({ id: crypto.randomUUID(), ...base({ source: 'selection', anchor: JSON.stringify({ v: 1, start: 10, end: 30 }),
    ref_page: 1 + Math.floor(rnd() * 256), chapter_index: Math.floor(rnd() * 148), ...extra }) });
  for (let i = 0; i < 3000; i++) {
    const a = anot({ user_book_id: livro(), kind: 'highlight', group_id: crypto.randomUUID(), color: '#FED170', style: 'fill', fill_height: 'medium' });
    grifos.push(a);
    linhas.annotations.push(a);
  }
  for (let i = 0; i < 1000; i++) {
    const g = grifos[i];
    linhas.annotations.push(anot({ user_book_id: g.user_book_id, kind: 'note', parent_id: g.id, group_id: g.group_id,
      note_text: `nota ${i}: aqueles olhos de Capitu, olhos de ressaca`, ref_page: g.ref_page }));
  }
  for (let i = 0; i < 700; i++) {
    const c = camadas[i];
    linhas.annotations.push(anot({ user_book_id: c.ub, kind: i % 7 < 4 ? 'drawing' : 'handwriting', source: 'ink',
      group_id: crypto.randomUUID(), ink_layer_id: c.id }));
  }
  const ja = Object.values(linhas).reduce((a, l) => a + l.length, 0);
  const inicio2025 = Date.parse('2025-03-01T00:00:00Z');
  for (let i = 0; i < total - ja; i++) {
    const ini = inicio2025 + Math.floor(rnd() * (agora - 86400000 - inicio2025));
    linhas.reading_sessions.push({ id: crypto.randomUUID(), ...base({ user_book_id: livro(), started_at: iso(ini),
      ended_at: iso(ini + 600000), active_seconds: 540, ref_page_from: 10, ref_page_to: 14, pages_viewed: 4,
      source: 'auto', device_id: 'spike' }) });
  }
  return linhas;
}

/** Insere o acervo pelas views (o app não sabe se a tabela é localOnly ou sincronizada). */
export async function gravarAcervo(db, linhas) {
  await db.writeTransaction(async (tx) => {
    for (const [t, ls] of Object.entries(linhas)) {
      for (const l of ls) {
        const cols = Object.keys(l);
        await tx.execute(`insert into ${t} (${cols.join(', ')}) values (${cols.map(() => '?').join(', ')})`, cols.map((c) => l[c]));
      }
    }
  });
}
