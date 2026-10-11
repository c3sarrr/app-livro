// G17 — uma sessão do modo anotação para os testes dos painéis (telas 23 e 23b): a página vazia, o pen_presets pedido,
// o repositório falso e os temporizadores na mão (a pílula das favoritas — D-175). Os ajustes gravados vão para
// [SessaoG17.gravados].
import 'dart:async';

import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_ink_repository.dart';
import 'personal_builders.dart';

final class _Ancoras implements AnnotationAnchors {
  @override
  String get sha => shaTeste;
  @override
  String? textOf(int spine) => null;
  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 159, chapterIndex: 31);
}

final class _Parado implements Timer {
  _Parado(this._cancelado);
  final void Function() _cancelado;
  @override
  void cancel() => _cancelado();
  @override
  bool get isActive => true;
  @override
  int get tick => 0;
}

final class SessaoG17 {
  SessaoG17._(this.sessao, this.gravados, this.temporizadores);

  final AnnotationSession sessao;
  final List<PenPresets> gravados;

  /// Os temporizadores pedidos (a duração e o que fazer), na ordem; os cancelados saem.
  final List<(Duration, void Function())> temporizadores;

  /// Dispara o temporizador de [duracao] mais antigo.
  void disparar(Duration duracao) {
    final i = temporizadores.indexWhere((t) => t.$1 == duracao);
    temporizadores.removeAt(i).$2();
  }
}

/// A sessão com [presets] (o padrão das telas 22/23/23b, sem nada); descartada no fim do teste.
SessaoG17 sessaoG17({PenPresets? presets}) {
  final gravados = <PenPresets>[];
  final temporizadores = <(Duration, void Function())>[];
  late final AnnotationSession s;
  s = AnnotationSession(
    geometry: InkPageGeometry.empty,
    anchors: _Ancoras(),
    drawings: const [],
    highlights: const [],
    presets: presets ?? presetsTeste(),
    repository: FakeInkRepository(),
    owner: usuarioTeste,
    userBookId: idTeste(1),
    startTimer: (d, f) {
      final t = (d, f);
      temporizadores.add(t);
      return _Parado(() => temporizadores.remove(t));
    },
    savePresets: (p) async => gravados.add(p),
  );
  addTearDown(s.dispose);
  return SessaoG17._(s, gravados, temporizadores);
}
