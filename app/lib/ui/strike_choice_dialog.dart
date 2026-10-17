import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'needle_frame.dart';

/// The moment a hold is complete: the player commits to the fight or admits
/// the attempt fell short. Pops true for Strike, false for Tried; tapping
/// outside pops null.
class StrikeChoiceDialog extends StatelessWidget {
  const StrikeChoiceDialog({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: NeedleFrame(
        tier: Cut.lg,
        edge: p.bone.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: Space.sm),
              Text('How did the strike land?', style: text.labelSmall),
              const SizedBox(height: Space.lg),
              Row(
                children: [
                  Expanded(
                    child: _Choice(
                      label: 'Tried',
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: _Choice(
                      label: 'Strike',
                      isSolid: true,
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.onTap,
    this.isSolid = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSolid;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return NeedleFrame(
      key: ValueKey('choice-$label'),
      tier: Cut.md,
      edge: isSolid ? p.silk : null,
      fill: isSolid ? p.silk : null,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTarget),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSolid ? p.onSilk : p.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
