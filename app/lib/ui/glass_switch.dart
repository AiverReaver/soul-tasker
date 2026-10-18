import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_surface.dart';
import 'glass_tap_target.dart';

/// A 52 × 32 glass track with a diamond knob. Off: ash knob at 8. On: the
/// track tints silk and the bone knob sits at 30.
class GlassSwitch extends StatelessWidget {
  const GlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;

  static const knobMove = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GlassTapTarget(
      key: const ValueKey('glass-switch-target'),
      semanticLabel: semanticLabel,
      toggled: value,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: GlassSurface(
        shape: const GlassShape.stadium(),
        isTinted: value,
        child: SizedBox(
          width: 52,
          height: 32,
          child: Stack(
            children: [
              AnimatedPositioned(
                key: const ValueKey('glass-switch-knob'),
                duration: knobMove,
                curve: Curves.easeOutBack,
                left: value ? 30 : 8,
                top: 8,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: p.glassKey, width: 1.5),
                    ),
                    child: SizedBox.square(
                      dimension: 14,
                      child: ColoredBox(
                        key: const ValueKey('glass-switch-diamond'),
                        color: value ? p.bone : p.ash,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
