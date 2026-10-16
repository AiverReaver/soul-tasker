import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// The moment a hold is complete: the player commits to the fight or admits
/// the attempt fell short. Pops true for Strike, false for Tried; tapping
/// outside pops null.
class StrikeChoiceDialog extends StatelessWidget {
  const StrikeChoiceDialog({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: kDust.withValues(alpha: 0.35)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: kDust.withValues(alpha: 0.12), blurRadius: 40),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, textAlign: TextAlign.center, style: text.titleMedium),
              const SizedBox(height: Space.lg),
              Row(
                children: [
                  Expanded(
                    child: _Choice(
                      label: 'Tried',
                      color: kTextMuted,
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: _Choice(
                      label: 'Strike',
                      color: kDust,
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
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(kMinTarget),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.6)),
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(label),
    );
  }
}
