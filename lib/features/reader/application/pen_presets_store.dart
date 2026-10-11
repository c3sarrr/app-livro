// G16.6 — o `pen_presets` da conta para o modo anotação: lido ao entrar no modo (sem linha ainda, o padrão das telas
// 22/23 — esferográfica, 1,2 mm, coral, Média) e gravado a cada troca de espessura, com HLC (vale para todos os livros;
// no Pro, a linha vai à fila como as outras pessoais).
import '../../../core/data/clock/hlc.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/model/record_meta.dart';
import '../annotations/domain/pen_presets.dart';

final class PenPresetsStore {
  PenPresetsStore(this.db, this.versioning, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalVersioning versioning;
  final DateTime Function() _now;

  /// O preset de [owner]; sem linha viva, o padrão (ainda não gravado: a versão vem na primeira gravação).
  Future<PenPresets> load(String owner) async {
    final p = await PenPresetsDao(db).forUser(owner);
    if (p != null && !p.meta.isDeleted) return p;
    final t = _now().toUtc();
    return PenPresets(
      id: owner,
      meta: RecordMeta(
        userId: owner,
        createdAt: t,
        updatedAt: t,
        version: Hlc(0, 0, 'local'),
      ),
    );
  }

  /// Grava [p] com uma versão nova (o `updated_at` da versão).
  Future<void> save(PenPresets p) =>
      versioning.write('pen_presets', p.id, (v) async {
        final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
        await PenPresetsDao(db).upsert(p.copyWith(meta: p.meta.edited(at, v)));
      });
}
