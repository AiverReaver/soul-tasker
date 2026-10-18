import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_tap_target.dart';

/// "All bosses · 2 active · 1 waiting": the way from Home to the full list.
class AllBossesRow extends StatelessWidget {
  const AllBossesRow({
    super.key,
    required this.active,
    required this.waiting,
    required this.onTap,
  });

  final int active;
  final int waiting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final label =
        'All bosses · $active active${waiting > 0 ? ' · $waiting waiting' : ''}';
    return GlassTapTarget(
      semanticLabel: label,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text('›', style: TextStyle(color: p.ash, fontSize: 22)),
        ],
      ),
    );
  }
}
