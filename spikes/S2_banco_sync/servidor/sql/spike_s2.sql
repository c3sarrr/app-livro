-- G02 · S2 — complementos do banco local do spike (não vão para as migrations da G04 sem revisão).
-- Publicação lógica para o PowerSync: tabelas pessoais + billing.sync_access (parâmetro do stream).
-- ACHADO do S2: o serviço 1.27 RECUSA publish_via_partition_root (PSYNC_S1143). Publicando a tabela
-- particionada sem essa opção, cada partição chega com o próprio nome (reading_sessions_2026_09…) e o
-- stream junta todas com o curinga "reading_sessions_%" (partições novas entram sozinhas).
create publication powersync for table
  personal.user_books, personal.reading_positions, personal.reading_sessions, personal.bookmarks,
  personal.ink_layers, personal.annotations, personal.highlight_labels, personal.reader_settings,
  personal.pen_presets, personal.reading_goals, billing.sync_access;
