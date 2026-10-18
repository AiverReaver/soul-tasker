import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_tap_target.dart';
import 'needle_frame.dart';

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
    final counts =
        ' · $active active${waiting > 0 ? ' · $waiting waiting' : ''}';
    final label = 'All bosses$counts';
    final style = Theme.of(context).textTheme.bodyMedium;
    return GlassTapTarget(
      semanticLabel: label,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: NeedleFrame(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'All bosses',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: counts,
                          style: TextStyle(color: p.ash),
                        ),
                      ],
                    ),
                    style: style,
                  ),
                ),
                Text('›', style: TextStyle(color: p.ash, fontSize: 22)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
