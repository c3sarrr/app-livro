// G20 (R7, D-208) — o alvo de toque que cresce por dentro: o nó semântico e a área de toque ganham o tamanho mínimo
// (48 — o guia do Android; cobre também os 44 do iOS), centrados no desenho, sem mudar o layout nem o que se vê.
// - o nó semântico junta o que está dentro (o rótulo e as ações do `Pressable`) e mede o tamanho mínimo;
// - o toque na área nova (fora do desenho) é entregue pelo [TapTargetScope] de cima — o app tem um na raiz: um pai
//   justo (uma fileira da altura do desenho) não deixaria o toque chegar ao alvo. Ele vai ao alvo mais perto (dois
//   vizinhos a menos de 48 repartem o vão no meio) que se vê ali, como se fosse na borda do desenho, a não ser que
//   alguém fique com o toque: o que está por cima do alvo (um véu, uma folha, outra rota) ou outro que pega toques ao
//   lado (um botão). Não contam o fundo e as molduras de quem contém o alvo, o que fica embaixo dele (a página, a
//   superfície da tinta) nem a rolagem ao lado (o corpo de um painel); o alvo coberto (a ilha embaixo do painel da
//   busca) fica de fora;
// - [hitLimit] corta a área de toque de cada lado; o nó semântico continua com o mínimo.
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// O tamanho mínimo de um alvo de toque (Android; o iOS pede 44).
const double minTapTarget = 48;

class TapTarget extends SingleChildRenderObjectWidget {
  const TapTarget({
    super.key,
    this.minSize = minTapTarget,
    this.hitLimit,
    this.role,
    required Widget super.child,
  });

  final double minSize;

  /// Quanto a área de toque pode passar do desenho, de cada lado (`null` = até o tamanho mínimo).
  final EdgeInsets? hitLimit;

  /// O papel do nó (a aba de um `tablist`): o nó que junta o de dentro não herda o papel dele.
  final SemanticsRole? role;

  @override
  RenderTapTarget createRenderObject(BuildContext context) =>
      RenderTapTarget(minSize: minSize, hitLimit: hitLimit, role: role);

  @override
  void updateRenderObject(BuildContext context, RenderTapTarget renderObject) {
    renderObject
      ..minSize = minSize
      ..hitLimit = hitLimit
      ..role = role;
  }
}

class RenderTapTarget extends RenderProxyBox {
  RenderTapTarget({required this._minSize, this.hitLimit, this._role});

  double _minSize;
  double get minSize => _minSize;
  set minSize(double v) {
    if (v == _minSize) return;
    _minSize = v;
    markNeedsSemanticsUpdate();
    // o retângulo do nó muda sem layout: quem refaz a geometria dele é o pai (um nó que não é limite de layout não
    // limpa a própria geometria)
    parent?.markNeedsSemanticsUpdate();
  }

  /// Quanto a área de toque pode passar do desenho, de cada lado (`null` = até o tamanho mínimo).
  EdgeInsets? hitLimit;

  SemanticsRole? _role;
  SemanticsRole? get role => _role;
  set role(SemanticsRole? v) {
    if (v == _role) return;
    _role = v;
    markNeedsSemanticsUpdate();
  }

  RenderTapTargetScope? _scope;

  /// O retângulo do tamanho mínimo, centrado no desenho.
  Rect get grown {
    final w = math.max(size.width, _minSize);
    final h = math.max(size.height, _minSize);
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: w,
      height: h,
    );
  }

  /// A área de toque: o retângulo do mínimo, cortado pelo [hitLimit].
  Rect get hitArea {
    final g = grown;
    final l = hitLimit;
    if (l == null) return g;
    return Rect.fromLTRB(
      math.max(g.left, -l.left),
      math.max(g.top, -l.top),
      math.min(g.right, size.width + l.right),
      math.min(g.bottom, size.height + l.bottom),
    );
  }

  /// A borda de baixo e a da direita ficam de fora do `contains` do filho: um fio para dentro.
  static const double _edge = 0.01;

  @override
  Rect get semanticBounds => grown;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..isMergingSemanticsOfDescendants = true;
    final r = _role;
    if (r != null) config.role = r;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (var p = parent; p != null; p = p.parent) {
      if (p is RenderTapTargetScope) {
        _scope = p.._targets.add(this);
        break;
      }
    }
  }

  @override
  void detach() {
    _scope?._targets.remove(this);
    _scope = null;
    super.detach();
  }

  /// O ponto do desenho mais perto de [position] (local): para onde o escopo leva o toque da área nova.
  Offset edgeFor(Offset position) => Offset(
    position.dx.clamp(0.0, math.max(0.0, size.width - _edge)),
    position.dy.clamp(0.0, math.max(0.0, size.height - _edge)),
  );
}

/// Entrega o toque da área nova dos [TapTarget] de dentro (o app tem um na raiz).
class TapTargetScope extends SingleChildRenderObjectWidget {
  const TapTargetScope({super.key, required Widget super.child});

  @override
  RenderTapTargetScope createRenderObject(BuildContext context) =>
      RenderTapTargetScope();
}

class RenderTapTargetScope extends RenderProxyBox {
  final Set<RenderTapTarget> _targets = {};

  /// Quantos níveis abaixo de quem pega toques se procura a área rolável (o `Scrollable` e o seu viewport).
  static const int _scrollDepth = 16;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    final near = _candidates(position);
    if (near.isEmpty) return super.hitTest(result, position: position);
    final probe = BoxHitTestResult();
    hitTestChildren(probe, position: position);
    // no desenho de um alvo que se vê: o caminho comum
    if (probe.path.any((e) => e.target is RenderTapTarget)) {
      return super.hitTest(result, position: position);
    }
    for (final (target, own) in near) {
      // o desenho tem o ponto mas o toque comum não chegou a ele: coberto
      if (own.contains(position)) continue;
      if (_taken(probe, target)) continue;
      final edge = MatrixUtils.transformPoint(
        target.getTransformTo(this),
        target.edgeFor(target.globalToLocal(position, ancestor: this)),
      );
      final atEdge = BoxHitTestResult();
      hitTestChildren(atEdge, position: edge);
      // coberto na borda (a ilha embaixo do painel da busca)
      if (!atEdge.path.any((e) => identical(e.target, target))) continue;
      // o toque vai ao alvo como se fosse na borda do desenho (com os pais, as rolagens e as molduras de cima)
      return super.hitTest(result, position: edge);
    }
    return super.hitTest(result, position: position);
  }

  /// Os alvos cuja área de toque tem [position], do mais perto ao mais longe (o desenho de cada um, no escopo).
  List<(RenderTapTarget, Rect)> _candidates(Offset position) {
    final found = <(RenderTapTarget, Rect, double)>[];
    for (final t in _targets) {
      if (!t.attached || !t.hasSize || !_reachable(t)) continue;
      final m = t.getTransformTo(this);
      if (!MatrixUtils.transformRect(m, t.hitArea).contains(position)) {
        continue;
      }
      final own = MatrixUtils.transformRect(m, Offset.zero & t.size);
      found.add((t, own, _distance(own, position)));
    }
    found.sort((a, b) => a.$3.compareTo(b.$3));
    return [for (final (t, own, _) in found) (t, own)];
  }

  /// Alguém além do alvo fica com o toque em [probe]: o que está por cima dele ali (um véu, uma folha, outra rota) ou
  /// outro que pega toques ao lado (um botão sem [TapTarget]). Não contam quem contém o alvo (o fundo e as molduras),
  /// o que fica embaixo dele (a página, a superfície da tinta) nem a rolagem ao lado (o corpo de um painel).
  bool _taken(BoxHitTestResult probe, RenderTapTarget target) {
    final chain = <RenderObject, int>{};
    var depth = 0;
    for (RenderObject? p = target; p != null && p != this; p = p.parent) {
      chain[p] = depth++;
    }
    for (final e in probe.path) {
      final h = e.target;
      if (h is! RenderObject || identical(h, this) || chain.containsKey(h)) {
        continue;
      }
      // o ancestral comum, e o filho dele de cada lado
      var branch = h;
      RenderObject? p = h.parent;
      while (p != null && p != this && !chain.containsKey(p)) {
        branch = p;
        p = p.parent;
      }
      final at = p == null ? null : chain[p];
      // fora do escopo, ou dentro do próprio alvo (o que transborda do desenho)
      if (at == null || at == 0) continue;
      final targetBranch = chain.keys.elementAt(at - 1);
      final overlap = _boundsOf(branch).intersect(_boundsOf(targetBranch));
      if (overlap.width > 0.5 && overlap.height > 0.5) {
        if (_paintsAfter(p!, branch, targetBranch)) return true;
        continue;
      }
      if (_handles(h)) return true;
    }
    return false;
  }

  /// Pega toques: quem escuta o ponteiro (os gestos) ou o absorve — menos a rolagem, que só disputa o arrasto.
  bool _handles(Object h) {
    if (h is RenderAbsorbPointer) return h.absorbing;
    if (h is! RenderPointerListener) return false;
    RenderObject? o = h;
    for (var i = 0; i < _scrollDepth && o != null; i++) {
      if (o is RenderAbstractViewport) return false;
      o = o is RenderObjectWithChildMixin<RenderObject> ? o.child : null;
    }
    return true;
  }

  /// [later] é pintado depois de [earlier] (por cima): os dois são filhos de [parent].
  static bool _paintsAfter(
    RenderObject parent,
    RenderObject later,
    RenderObject earlier,
  ) {
    bool? after;
    parent.visitChildren((c) {
      if (after != null) return;
      if (identical(c, earlier)) after = true;
      if (identical(c, later)) after = false;
    });
    return after ?? false;
  }

  Rect _boundsOf(RenderObject o) =>
      MatrixUtils.transformRect(o.getTransformTo(this), o.paintBounds);

  /// O alvo não está escondido nem com os toques desligados no caminho até o escopo.
  bool _reachable(RenderTapTarget t) {
    for (var p = t.parent; p != null && p != this; p = p.parent) {
      if (p is RenderOffstage && p.offstage) return false;
      if (p is RenderIgnorePointer && p.ignoring) return false;
      if (p is RenderAbsorbPointer && p.absorbing) return false;
    }
    return true;
  }

  static double _distance(Rect r, Offset p) {
    final dx = math.max(math.max(r.left - p.dx, 0.0), p.dx - r.right);
    final dy = math.max(math.max(r.top - p.dy, 0.0), p.dy - r.bottom);
    return math.sqrt(dx * dx + dy * dy);
  }
}
