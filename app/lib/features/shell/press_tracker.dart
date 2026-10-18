import 'package:material_ui/material_ui.dart';

/// Holds the "is it pressed" flag glass controls need for their 1.04 press.
/// The stateless widgets in `lib/ui/` take [isPressed] and report press
/// changes; this thin container sits between them.
class PressTracker extends StatefulWidget {
  const PressTracker({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    bool isPressed,
    ValueChanged<bool> onPressChanged,
  )
  builder;

  @override
  State<PressTracker> createState() => _PressTrackerState();
}

class _PressTrackerState extends State<PressTracker> {
  bool _pressed = false;

  void _set(bool v) {
    if (v != _pressed) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _pressed, _set);
}
