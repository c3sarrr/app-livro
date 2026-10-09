// G17.1 — o seletor de cor da tela 23 (L23.6, R13, R14), também usado pela folha "Outra cor" da tela 21 (D-178):
// - a roda de 124 (o `ColorWheelPainter`) com o cursor de 24 (aro 3 `#FFFAF1`, anel 1,5 e sombra dura 2/2 de tinta)
//   no tom e na intensidade da cor; tocar ou arrastar leva o cursor ao dedo, preso à borda (R13); se outro gesto
//   ganhar o toque (a página rolando, por exemplo), a cor de antes do toque volta, sem gravar;
// - BRILHO: o trilho de 16 com o degradê da tinta à cor com brilho 100 % e o botão de 26, que vai de −3 a +3 das
//   pontas do trilho, como no arquivo; com brilho 0 o tom e a intensidade ficam guardados (R13);
// - o campo hex de 42 com a amostra de 18 e o código (Figtree 15/800): tocar abre o teclado só com 0–9 e A–F; a cor
//   vale ao completar os 6 dígitos; Enter ou sair com o código incompleto volta ao da cor atual (R14). O pai sabe do
//   teclado por [onHexFocus] (o painel sobe — R14).
// Sem estado de cor além do HSV de agora: a cor vem de fora ([color]) e volta por [onChanged] (durante o arrasto) e
// [onChangeEnd] (ao soltar ou ao completar o código).
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/design_system/color/color_names.dart';
import '../../../core/design_system/color/hsv.dart';
import '../../../core/design_system/painters/color_wheel_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/tap_target.dart';
import 'reader_chrome_scope.dart';

/// A roda do arquivo (L23 nº da roda).
const double colorWheelSize = 124;

/// A altura do lado do seletor: BRILHO (11 × 1,2), 9, o trilho (16), 16 e o campo hex (42) — o campo termina na base
/// do lado, que fica centrado na roda.
const double colorPickerSideHeight = 11 * 1.2 + 9 + 16 + 16 + 42;

/// O cursor e o botão do brilho.
const double _cursor = 24;
const double _knob = 26;

/// O trilho do brilho e o campo hex.
const double _track = 16;
const double _hexHeight = 42;

/// Quanto a roda gira a cada "aumentar" do leitor de tela (R13).
const double wheelStepDegrees = 15;

/// Quanto o brilho anda a cada "aumentar" do leitor de tela (R13).
const double brightnessStep = 0.05;

/// O nome da cor (em minúsculas) ou o hex.
String colorLabel(String hex) => colorNameOf(hex) ?? hex;

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
    required this.onChangeEnd,
    this.onHexFocus,
    this.keyPrefix = 'ann.penPanel.picker',
  });

  /// A cor de agora (`#RRGGBB`).
  final String color;

  /// Durante o arrasto (não grava).
  final ValueChanged<String> onChanged;

  /// Ao soltar, ao tocar ou ao completar o código (grava).
  final ValueChanged<String> onChangeEnd;

  /// O campo hex ganhou (`true`) ou perdeu o foco.
  final ValueChanged<bool>? onHexFocus;

  /// O começo das chaves (`ann.penPanel.picker`, ou o da folha "Outra cor").
  final String keyPrefix;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Hsv _hsv = Hsv.fromHex(widget.color);
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode(debugLabel: 'hex');
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(ColorPicker old) {
    super.didUpdateWidget(old);
    // a cor que volta de fora é a mesma que mandamos: o HSV fica (o preto guarda o tom)
    if (widget.color != _hsv.toHex()) _hsv = Hsv.fromHex(widget.color);
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _focus.dispose();
    _code.dispose();
    super.dispose();
  }

  Key _k(String s) => ValueKey('${widget.keyPrefix}$s');

  /// A cor de antes do toque na roda ou no brilho (volta se outro gesto ganhar o toque).
  Hsv? _before;

  /// O dedo já subiu (o `Listener` vê o soltar antes dos reconhecedores).
  bool _lifted = false;

  void _set(Hsv c, {required bool end}) {
    if (end) _before = null;
    setState(() => _hsv = c);
    (end ? widget.onChangeEnd : widget.onChanged)(c.toHex());
  }

  /// O dedo desceu: guarda a cor de antes e mostra a do ponto.
  void _down(void Function() show) {
    _before = _hsv;
    show();
  }

  /// O arrasto desistiu. Com o dedo já solto, foi um toque disputado com outro gesto: vale a cor do ponto (R13). Com
  /// o dedo ainda na tela, outro gesto ganhou (a página rolando, por exemplo): a cor de antes volta, sem gravar.
  void _cancel() {
    final b = _before;
    _before = null;
    if (_lifted) return _set(_hsv, end: true);
    if (b != null && b != _hsv) _set(b, end: false);
  }

  /// Acompanha o dedo da roda e do brilho para o [_cancel].
  Widget _tracked(Widget child) => Listener(
    onPointerDown: (_) => _lifted = false,
    onPointerUp: (_) => _lifted = true,
    child: child,
  );

  // ---- roda -----------------------------------------------------------------------------------------------------

  void _wheelAt(Offset p, {bool end = false}) {
    final (h, s) = wheelHsvAt(p, colorWheelSize);
    _set(Hsv(h, s, _hsv.v), end: end);
  }

  void _wheelEnd() => _set(_hsv, end: true);

  void _turn(double degrees) {
    final h = (_hsv.h + degrees) % 360;
    _set(_hsv.withH(h < 0 ? h + 360 : h), end: true);
  }

  // ---- brilho ---------------------------------------------------------------------------------------------------

  /// O começo do botão (−3 da ponta de dentro do trilho) e quanto ele anda (o trilho de dentro + 6 − o botão).
  static double _knobStart() => AppStrokes.regular - 3;
  static double _knobTravel(double width) =>
      width - 2 * AppStrokes.regular + 6 - _knob;

  /// O brilho do ponto [x] do trilho de largura [width]: o centro do botão no dedo.
  double _brightnessAt(double x, double width) =>
      ((x - _knobStart() - _knob / 2) / _knobTravel(width)).clamp(0.0, 1.0);

  void _bright(double v, {bool end = false}) =>
      _set(_hsv.withV(v.clamp(0.0, 1.0)), end: end);

  // ---- hex ------------------------------------------------------------------------------------------------------

  void _startEditing() {
    setState(() {
      _editing = true;
      _code.value = TextEditingValue(
        text: _hsv.toHex(),
        selection: TextSelection.collapsed(offset: _hsv.toHex().length),
      );
    });
    widget.onHexFocus?.call(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _focusChanged() {
    if (!_focus.hasFocus && _editing) _stopEditing();
  }

  void _stopEditing() {
    if (!_editing) return;
    setState(() => _editing = false);
    widget.onHexFocus?.call(false);
  }

  void _typed(String text) {
    final hex = normalizeHex(text);
    if (hex == null || hex == _hsv.toHex()) return;
    _set(Hsv.fromHex(hex), end: true);
  }

  @override
  Widget build(BuildContext context) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    final hex = _hsv.toHex();
    final color = Color(_hsv.toArgb());
    final full = Color(_hsv.withV(1).toArgb());
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final surface = scope.tint(AppColors.surface);
    final at = wheelOffsetOf(_hsv, colorWheelSize);

    final wheel = Semantics(
      key: _k('.wheel'),
      slider: true,
      label: 'Roda de cores: tom e intensidade',
      value: colorLabel(hex),
      increasedValue: colorLabel(
        _hsv.withH((_hsv.h + wheelStepDegrees) % 360).toHex(),
      ),
      decreasedValue: colorLabel(
        _hsv.withH((_hsv.h - wheelStepDegrees + 360) % 360).toHex(),
      ),
      onIncrease: () => _turn(wheelStepDegrees),
      onDecrease: () => _turn(-wheelStepDegrees),
      child: _tracked(
        GestureDetector(
          excludeFromSemantics: true,
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => _down(() => _wheelAt(d.localPosition)),
          // o 1º trecho do arrasto chega no começo (`DragStartBehavior.start`), não num update
          onPanStart: (d) => _wheelAt(d.localPosition),
          onPanUpdate: (d) => _wheelAt(d.localPosition),
          onPanEnd: (_) => _wheelEnd(),
          onPanCancel: _cancel,
          child: SizedBox.square(
            dimension: colorWheelSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: ColorWheelPainter(border: p.border),
                  ),
                ),
                Positioned(
                  key: _k('.wheel.cursor'),
                  left: at.dx - _cursor / 2,
                  top: at.dy - _cursor / 2,
                  width: _cursor,
                  height: _cursor,
                  child: _Dot(
                    color: color,
                    ring: surface,
                    edge: p.border,
                    shadow: p.shadow,
                    hardShadow: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final percent = (_hsv.v * 100).round();
    String pct(double v) => '${(v.clamp(0.0, 1.0) * 100).round()} %';
    final brightness = LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        // G20 (R7): o trilho de 16 recebe o toque e o nó com 48 de altura, por dentro
        return TapTarget(
          child: Semantics(
            key: _k('.brightness'),
            slider: true,
            label: 'Brilho',
            value: '$percent %',
            increasedValue: pct(_hsv.v + brightnessStep),
            decreasedValue: pct(_hsv.v - brightnessStep),
            onIncrease: () => _bright(_hsv.v + brightnessStep, end: true),
            onDecrease: () => _bright(_hsv.v - brightnessStep, end: true),
            child: _tracked(
              GestureDetector(
                excludeFromSemantics: true,
                behavior: HitTestBehavior.opaque,
                onHorizontalDragDown: (d) =>
                    _down(() => _bright(_brightnessAt(d.localPosition.dx, w))),
                onHorizontalDragStart: (d) =>
                    _bright(_brightnessAt(d.localPosition.dx, w)),
                onHorizontalDragUpdate: (d) =>
                    _bright(_brightnessAt(d.localPosition.dx, w)),
                onHorizontalDragEnd: (_) => _bright(_hsv.v, end: true),
                onHorizontalDragCancel: _cancel,
                child: SizedBox(
                  height: _track,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.fromBorderSide(line),
                            gradient: LinearGradient(
                              colors: [
                                scope.tint(AppColors.ink),
                                scope.tint(full),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        key: _k('.brightness.knob'),
                        // de −3 a +3 das pontas de dentro do trilho (o `right: −3px` do arquivo)
                        left: _knobStart() + _hsv.v * _knobTravel(w),
                        top: (_track - _knob) / 2,
                        width: _knob,
                        height: _knob,
                        child: _Dot(
                          color: color,
                          ring: surface,
                          edge: p.border,
                          shadow: p.shadow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    final codeStyle = AppTextStyles.annHexValue.copyWith(color: p.title);
    final Widget code = _editing
        ? EditableText(
            key: _k('.hex.field'),
            controller: _code,
            focusNode: _focus,
            style: codeStyle,
            cursorColor: p.title,
            backgroundCursorColor: p.muted,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: const [HexCodeFormatter()],
            onChanged: _typed,
            onSubmitted: (_) {
              _focus.unfocus();
              _stopEditing();
            },
            onEditingComplete: () {},
          )
        : AppText(hex, key: _k('.hex.value'), style: codeStyle, maxLines: 1);

    final hexBox = TapTarget(
      child: Semantics(
        key: _k('.hex'),
        container: true,
        textField: true,
        label: 'Código da cor',
        value: hex,
        onTap: _editing ? null : _startEditing,
        child: ExcludeSemantics(
          excluding: !_editing,
          child: GestureDetector(
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTap: _editing ? null : _startEditing,
            child: Container(
              height: _hexHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: p.well,
                borderRadius: BorderRadius.circular(14),
                border: Border.fromBorderSide(line),
              ),
              child: Row(
                children: [
                  Container(
                    key: _k('.hex.swatch'),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.fromBorderSide(line),
                    ),
                  ),
                  const SizedBox(width: 9),
                  if (_editing) Expanded(child: code) else code,
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      key: _k(''),
      children: [
        wheel,
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            key: _k('.side'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                'BRILHO',
                key: _k('.brightnessLabel'),
                style: AppTextStyles.readerSheetLabel.copyWith(color: p.label),
                maxLines: 1,
              ),
              const SizedBox(height: 9),
              brightness,
              const SizedBox(height: 16),
              hexBox,
            ],
          ),
        ),
      ],
    );
  }
}

/// Só 0–9 e A–F, em maiúsculas, até 6, depois do "#" fixo (R14).
final class HexCodeFormatter extends TextInputFormatter {
  const HexCodeFormatter();

  static final RegExp _notHex = RegExp('[^0-9A-Fa-f]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(_notHex, '').toUpperCase();
    final text = '#${digits.length > 6 ? digits.substring(0, 6) : digits}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// O cursor da roda e o botão do brilho: o círculo na cor, o aro de 3 [ring] e o anel de 1,5 [edge] por fora; o
/// cursor ainda tem a sombra dura 2/2 do anel.
class _Dot extends StatelessWidget {
  const _Dot({
    required this.color,
    required this.ring,
    required this.edge,
    required this.shadow,
    this.hardShadow = false,
  });

  final Color color, ring, edge, shadow;
  final bool hardShadow;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(width: 3, color: ring),
      boxShadow: [
        if (hardShadow)
          BoxShadow(
            color: shadow,
            offset: const Offset(2, 2),
            spreadRadius: AppStrokes.regular,
          ),
        BoxShadow(color: edge, spreadRadius: AppStrokes.regular),
      ],
    ),
  );
}
