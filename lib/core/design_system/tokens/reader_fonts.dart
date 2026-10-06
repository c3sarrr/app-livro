// A família do texto do livro (G10) num lugar só, para o leitor (`reader_typography.dart`, que a reexporta) e para a
// interface que mostra uma letra do livro (o "a" do Sublinhar — G13), sem o design system depender do leitor.

/// Família do texto do livro (G10 registra a Literata; Lora, Figtree e Atkinson entram na G14).
const String readerFontFamily = 'LiterataVF';

/// Subconjuntos da Literata, na ordem do `unicode-range` do arquivo de design.
const List<String> readerFontFallback = [
  'LiterataVFExt',
  'LiterataVFVi',
  'LiterataVFCyr',
  'LiterataVFCyrExt',
  'LiterataVFGr',
  'LiterataVFGrExt',
];
