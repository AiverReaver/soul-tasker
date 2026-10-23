import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../ui/dust_vanish.dart';

/// How long the boss takes to turn to dust.
const kBossVanishDuration = Duration(milliseconds: 2400);

/// Darkens the screen and lets [name] dissolve into white-gold dust. Completes
/// when the boss is gone. Skipped when the system asks for reduced motion.
Future<void> showBossVanish(BuildContext context, String name) async {
  if (motionOf(context, kBossVanishDuration) == Duration.zero) return;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: context.palette.void_.withValues(alpha: 0.92),
    transitionDuration: Motion.quick,
    pageBuilder: (_, _, _) => _BossVanish(name: name),
  );
}

class _BossVanish extends StatefulWidget {
  const _BossVanish({required this.name});

  final String name;

  @override
  State<_BossVanish> createState() => _BossVanishState();
}

class _BossVanishState extends State<_BossVanish>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: kBossVanishDuration)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed && mounted) {
            Navigator.of(context).pop();
          }
        })
        ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => DustVanish(
            progress: Curves.easeIn.transform(_c.value),
            motes: 140,
            seed: widget.name.hashCode,
            child: Text(
              widget.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: context.palette.bone,
                shadows: [
                  Shadow(
                    color: context.palette.bone.withValues(alpha: 0.6),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
