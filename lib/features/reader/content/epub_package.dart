// G09.1 — pacote do EPUB (Anexo 03 §3–4): `META-INF/container.xml` → OPF → metadados (`dc:title`,
// `dc:creator`, `dc:language`, `dc:identifier` com ISBN), manifest, spine, capa, sumário (`nav`/`toc.ncx`)
// e layout (`rendition:layout`). EPUB 2 e 3. Os caminhos já saem resolvidos para nomes do ZIP.
import 'package:xml/xml.dart';

import '../../catalog/domain/isbn.dart';
import 'content_failure.dart';
import 'markup.dart';
import 'zip_reader.dart';

enum EpubLayout { reflowable, fixed }

final class EpubMetadata {
  const EpubMetadata({
    required this.title,
    required this.authors,
    this.language,
    this.isbn13,
  });

  /// Título principal (vazio se o OPF não tiver — quem importa usa o nome do arquivo).
  final String title;

  /// Autores (papel `aut` ou sem papel), na ordem do OPF.
  final List<String> authors;
  final String? language;

  /// O primeiro ISBN válido dos identificadores, como ISBN-13.
  final String? isbn13;
}

final class ManifestItem {
  const ManifestItem({
    required this.id,
    required this.path,
    required this.mediaType,
    required this.properties,
  });

  final String id;

  /// Caminho no ZIP.
  final String path;
  final String mediaType;
  final Set<String> properties;
}

final class SpineItem {
  const SpineItem({
    required this.path,
    required this.mediaType,
    required this.linear,
  });

  final String path;
  final String mediaType;

  /// `linear="no"` (notas, encartes) fica fora do texto global das páginas de referência (D-89).
  final bool linear;
}

final class EpubPackage {
  const EpubPackage({
    required this.version,
    required this.opfPath,
    required this.metadata,
    required this.manifest,
    required this.spine,
    required this.layout,
    this.coverPath,
    this.guideCoverPath,
    this.navPath,
    this.ncxPath,
  });

  final String version;
  final String opfPath;
  final EpubMetadata metadata;
  final Map<String, ManifestItem> manifest;
  final List<SpineItem> spine;
  final EpubLayout layout;

  /// Imagem da capa (`cover-image` do EPUB 3 ou `<meta name="cover">` do EPUB 2).
  final String? coverPath;

  /// XHTML da capa no `<guide>` (EPUB 2): a primeira imagem dele vira a capa quando não há [coverPath].
  final String? guideCoverPath;
  final String? navPath;
  final String? ncxPath;

  static const String _container = 'META-INF/container.xml';

  /// Lê o pacote. Sem container/OPF, OPF malformado ou spine vazio → [ContentDamaged].
  static EpubPackage read(ZipReader zip) {
    final containerName = zip.find(_container);
    if (containerName == null) throw const ContentDamaged('epub_sem_container');
    final container = parseXmlDocument(
      zip.read(containerName, maxBytes: 1024 * 1024),
      reason: 'epub_container',
    );
    final rootfile = allNamed(
      container,
      'rootfile',
    ).map((e) => attr(e, 'full-path')).whereType<String>().firstOrNull;
    final opfPath = rootfile == null
        ? null
        : zip.find(resolveHref('', rootfile) ?? '');
    if (opfPath == null) throw const ContentDamaged('epub_sem_opf');
    final opf = parseXmlDocument(
      zip.read(opfPath, maxBytes: 8 * 1024 * 1024),
      reason: 'epub_opf',
    );
    final pkg = allNamed(opf, 'package').firstOrNull;
    if (pkg == null) throw const ContentDamaged('epub_opf');
    final base = dirOf(opfPath);
    final version = attr(pkg, 'version') ?? '2.0';

    final manifest = <String, ManifestItem>{};
    for (final it in allNamed(opf, 'item')) {
      final id = attr(it, 'id');
      final href = attr(it, 'href');
      final path = href == null ? null : resolveHref(base, href);
      if (id == null || path == null) continue;
      manifest.putIfAbsent(
        id,
        () => ManifestItem(
          id: id,
          path: zip.find(path) ?? path,
          mediaType: (attr(it, 'media-type') ?? '').trim().toLowerCase(),
          properties: {
            for (final p in (attr(it, 'properties') ?? '').split(
              RegExp(r'\s+'),
            ))
              if (p.isNotEmpty) p,
          },
        ),
      );
    }

    final spineEl = allNamed(opf, 'spine').firstOrNull;
    final spine = <SpineItem>[
      if (spineEl != null)
        for (final ref in childrenNamed(spineEl, 'itemref'))
          if (manifest[attr(ref, 'idref')] case final m?)
            SpineItem(
              path: m.path,
              mediaType: m.mediaType,
              linear:
                  (attr(ref, 'linear') ?? 'yes').trim().toLowerCase() != 'no',
            ),
    ];
    if (spine.isEmpty) throw const ContentDamaged('epub_spine_vazio');

    final metadataEl = allNamed(opf, 'metadata').firstOrNull;
    final metas = metadataEl == null
        ? const <XmlElement>[]
        : allNamed(metadataEl, 'meta').toList();
    String? refined(String id, String property) => metas
        .where(
          (m) =>
              attr(m, 'refines') == '#$id' && attr(m, 'property') == property,
        )
        .map(collapsedText)
        .firstOrNull;
    String? metaProperty(String property) => metas
        .where((m) => attr(m, 'property') == property)
        .map(collapsedText)
        .firstOrNull;

    final titles = metadataEl == null
        ? const <XmlElement>[]
        : allNamed(metadataEl, 'title').toList();
    final mainTitle =
        titles.where((t) {
          final id = attr(t, 'id');
          return id != null && refined(id, 'title-type') == 'main';
        }).firstOrNull ??
        titles.firstOrNull;

    final authors = <String>[];
    for (final c
        in metadataEl == null
            ? const <XmlElement>[]
            : allNamed(metadataEl, 'creator')) {
      final id = attr(c, 'id');
      final role = (id == null ? null : refined(id, 'role')) ?? attr(c, 'role');
      final name = collapsedText(c);
      if (name.isEmpty) continue;
      if (role == null || role.trim().toLowerCase() == 'aut') authors.add(name);
    }

    String? isbn;
    for (final idEl
        in metadataEl == null
            ? const <XmlElement>[]
            : allNamed(metadataEl, 'identifier')) {
      final v = collapsedText(idEl);
      final scheme = (attr(idEl, 'scheme') ?? '').toLowerCase();
      final looksIsbn =
          scheme == 'isbn' ||
          v.toLowerCase().contains('isbn') ||
          RegExp(r'^[\d\- ]{9,17}[\dXx]$').hasMatch(v);
      if (!looksIsbn) continue;
      isbn = normalizeIsbn(v.replaceAll(RegExp(r'[^0-9Xx]'), ''));
      if (isbn != null) break;
    }

    final language = metadataEl == null
        ? null
        : allNamed(
            metadataEl,
            'language',
          ).map(collapsedText).where((l) => l.isNotEmpty).firstOrNull;

    // capa: EPUB 3 (cover-image) → EPUB 2 (<meta name="cover" content="id">)
    final coverId = metas
        .where((m) => attr(m, 'name') == 'cover')
        .map((m) => attr(m, 'content'))
        .whereType<String>()
        .firstOrNull;
    final cover =
        manifest.values
            .where((m) => m.properties.contains('cover-image'))
            .firstOrNull ??
        (coverId == null ? null : manifest[coverId]);
    final guideCover = allNamed(opf, 'reference')
        .where((r) => (attr(r, 'type') ?? '').toLowerCase() == 'cover')
        .map((r) => attr(r, 'href'))
        .whereType<String>()
        .map((h) => resolveHref(base, h))
        .whereType<String>()
        .firstOrNull;

    final nav = manifest.values
        .where((m) => m.properties.contains('nav'))
        .firstOrNull;
    final tocId = spineEl == null ? null : attr(spineEl, 'toc');
    final ncx =
        (tocId == null ? null : manifest[tocId]) ??
        manifest.values
            .where((m) => m.mediaType == 'application/x-dtbncx+xml')
            .firstOrNull;

    final layout = metaProperty('rendition:layout') == 'pre-paginated'
        ? EpubLayout.fixed
        : EpubLayout.reflowable;

    return EpubPackage(
      version: version,
      opfPath: opfPath,
      metadata: EpubMetadata(
        title: mainTitle == null ? '' : collapsedText(mainTitle),
        authors: List.unmodifiable(authors),
        language: language,
        isbn13: isbn,
      ),
      manifest: Map.unmodifiable(manifest),
      spine: List.unmodifiable(spine),
      layout: layout,
      coverPath: cover?.path,
      guideCoverPath: guideCover == null
          ? null
          : zip.find(guideCover) ?? guideCover,
      navPath: nav?.path,
      ncxPath: ncx?.path,
    );
  }
}
