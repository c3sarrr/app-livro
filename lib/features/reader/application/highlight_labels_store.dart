// G17 (D-40, D-177) — os rótulos das cores do marca-texto (`highlight_labels`, da conta: valem para todos os livros)
// e as contagens da tela 23b: os grifos vivos de cada cor em todos os livros do usuário. Salvar a folha "Rótulos":
// o rótulo que mudou fica na mesma linha, com versão nova; o que ficou vazio (só espaços conta como vazio) é apagado
// (tombstone); o que não existia nasce na ordem das cores; o igual não é regravado. Cada escrita pelo
// `LocalVersioning.write` (HLC; no Pro, a fila — como as outras pessoais).
import '../../../core/data/clock/hlc.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/data/model/record_meta.dart';
import '../../../core/design_system/color/color_names.dart';
import '../annotations/domain/highlight_label.dart';

/// O maior rótulo (o CHECK do banco).
const int highlightLabelMaxLength = 24;

/// Os rótulos por cor e os grifos de cada cor (`#RRGGBB` maiúsculo).
typedef HighlightLabelData = ({
  Map<String, String> labels,
  Map<String, int> counts,
});

final class HighlightLabelsStore {
  HighlightLabelsStore(this.db, this.versioning, {UuidV7Generator? ids})
    : _ids = ids ?? UuidV7Generator();

  final AppDatabase db;
  final LocalVersioning versioning;
  final UuidV7Generator _ids;

  Future<HighlightLabelData> load(String owner) async {
    final labels = await HighlightLabelsDao(db).forUser(owner);
    final counts = await AnnotationsDao(db).highlightCountsByColor(owner);
    return (
      labels: Map<String, String>.unmodifiable({
        for (final l in labels) l.color.toUpperCase(): l.label,
      }),
      counts: Map<String, int>.unmodifiable(counts),
    );
  }

  /// Grava os rótulos de [next] (cor → texto; vazio apaga).
  Future<void> save(String owner, Map<String, String> next) async {
    final dao = HighlightLabelsDao(db);
    final rows = {
      for (final l in await dao.forUser(owner)) l.color.toUpperCase(): l,
    };
    for (final MapEntry(key: color, value: raw) in next.entries) {
      final c = color.toUpperCase();
      final text = _cut(raw.trim());
      final old = rows[c];
      if (old == null) {
        if (text.isEmpty) continue;
        final id = _ids.next();
        final sort = markerColors.indexOf(c);
        await _write(
          id,
          (v, at) => dao.upsert(
            HighlightLabel(
              id: id,
              meta: RecordMeta(
                userId: owner,
                createdAt: at,
                updatedAt: at,
                version: v,
              ),
              color: c,
              label: text,
              sort: sort < 0 ? markerColors.length : sort,
            ),
          ),
        );
      } else if (text.isEmpty) {
        await _write(
          old.id,
          (v, at) => dao.upsert(old.copyWith(meta: old.meta.deleted(at, v))),
        );
      } else if (text != old.label) {
        await _write(
          old.id,
          (v, at) => dao.upsert(
            old.copyWith(meta: old.meta.edited(at, v), label: text),
          ),
        );
      }
    }
  }

  static String _cut(String s) {
    final runes = s.runes;
    return runes.length <= highlightLabelMaxLength
        ? s
        : String.fromCharCodes(runes.take(highlightLabelMaxLength)).trimRight();
  }

  Future<void> _write(String id, Future<void> Function(Hlc v, DateTime at) f) =>
      versioning.write(
        'highlight_labels',
        id,
        (v) => f(v, DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true)),
      );
}
