// G02 · S3 — leitor de EPUB mínimo (Anexo 03 §4): container.xml → OPF → spine → blocos.
// Só o necessário para o spike: parágrafos e títulos com texto puro (sem estilos de trecho).
// O texto canônico de cada item do spine = textos dos blocos unidos por '\n' (offsets UTF-16).
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

enum TipoBloco { paragrafo, titulo }

class Bloco {
  Bloco(this.tipo, this.texto, {this.nivel = 0, this.ancora});

  final TipoBloco tipo;
  final String texto;
  final int nivel;

  /// `id` de um `<a>` dentro do bloco (o EPUB do Gutenberg marca os capítulos assim).
  final String? ancora;

  /// Offset do 1º caractere no texto canônico do item (preenchido por [ItemSpine]).
  int inicio = 0;

  bool get recuo => tipo == TipoBloco.paragrafo;
}

class ItemSpine {
  ItemSpine(this.href, this.blocos) {
    var pos = 0;
    for (final b in blocos) {
      b.inicio = pos;
      pos += b.texto.length + 1; // '\n' entre blocos
    }
    texto = blocos.map((b) => b.texto).join('\n');
  }

  final String href;
  final List<Bloco> blocos;
  late final String texto;
}

class Livro {
  Livro(this.titulo, this.itens);

  final String titulo;
  final List<ItemSpine> itens;

  int get caracteres => itens.fold(0, (s, i) => s + i.texto.length);
}

const _blocosHtml = {
  'p', 'div', 'li', 'blockquote', 'pre', 'td', 'th', //
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
};
final _espacos = RegExp(r'\s+');

Livro lerEpub(Uint8List bytes) {
  final zip = ZipDecoder().decodeBytes(bytes);
  String ler(String nome) {
    final f = zip.findFile(nome);
    if (f == null) throw FormatException('EPUB sem $nome');
    return utf8.decode(f.content);
  }

  final container = XmlDocument.parse(ler('META-INF/container.xml'));
  final opfPath = container
      .findAllElements('rootfile')
      .first
      .getAttribute('full-path')!;
  final base = opfPath.contains('/')
      ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
      : '';
  final opf = XmlDocument.parse(ler(opfPath));
  final manifesto = {
    for (final it in opf.findAllElements('item'))
      it.getAttribute('id')!: it.getAttribute('href')!,
  };
  final titulo = opf.findAllElements('dc:title').firstOrNull?.innerText ?? '';
  final itens = <ItemSpine>[];
  for (final ref in opf.findAllElements('itemref')) {
    final href = manifesto[ref.getAttribute('idref')]!;
    final doc = XmlDocument.parse(ler('$base${Uri.decodeFull(href)}'));
    final body = doc.findAllElements('body').firstOrNull;
    final blocos = <Bloco>[];
    if (body != null) _coletar(body, blocos);
    itens.add(ItemSpine(href, blocos));
  }
  return Livro(titulo, itens);
}

void _coletar(XmlElement el, List<Bloco> saida) {
  for (final filho in el.childElements) {
    final nome = filho.localName.toLowerCase();
    if (nome == 'style' || nome == 'script') continue;
    final temBlocoDentro = filho.descendantElements.any(
      (d) => _blocosHtml.contains(d.localName.toLowerCase()),
    );
    if (_blocosHtml.contains(nome) && !temBlocoDentro) {
      final buf = StringBuffer();
      _texto(filho, buf);
      final t = buf.toString().replaceAll(_espacos, ' ').trim();
      if (t.isEmpty) continue;
      final titulo = nome.length == 2 && nome.startsWith('h');
      final ancora = filho.descendantElements
          .where((d) => d.localName == 'a' && d.getAttribute('id') != null)
          .map((d) => d.getAttribute('id'))
          .firstOrNull;
      saida.add(
        Bloco(
          titulo ? TipoBloco.titulo : TipoBloco.paragrafo,
          t,
          nivel: titulo ? int.parse(nome.substring(1)) : 0,
          ancora: ancora,
        ),
      );
    } else {
      _coletar(filho, saida);
    }
  }
}

void _texto(XmlNode n, StringBuffer buf) {
  for (final c in n.children) {
    if (c is XmlText || c is XmlCDATA) {
      buf.write(c.value);
    } else if (c is XmlElement) {
      if (c.localName == 'br') {
        buf.write(' ');
      } else {
        _texto(c, buf);
      }
    }
  }
}
