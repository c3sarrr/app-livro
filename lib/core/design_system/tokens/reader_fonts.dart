// A família do texto do livro (G10) num lugar só, para o leitor (`reader_typography.dart`, que a reexporta) e para a
// interface que mostra uma letra do livro (o "a" do Sublinhar — G13), sem o design system depender do leitor.

/// Família do texto do livro na Literata (a padrão — G10, D-18).
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

/// Famílias do texto do livro além da Literata (G14, D-18): os arquivos completos do google/fonts, registrados com
/// nomes próprios do livro (a `Figtree` estática da interface continua separada).
const String readerLoraFamily = 'LoraBook';
const String readerFigtreeFamily = 'FigtreeBook';
const String readerAtkinsonFamily = 'AtkinsonBook';
