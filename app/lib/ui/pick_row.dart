import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// One task offered for tomorrow's three: a checkbox row with its boss.
class PickRow extends StatelessWidget {
  const PickRow({
    super.key,
    required this.title,
    required this.bossTitle,
    required this.isSelected,
    required this.onChanged,
    this.isEnabled = true,
  });

  final String title;
  final String bossTitle;
  final bool isSelected;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: context.palette.silk,
      value: isSelected,
      onChanged: isEnabled ? (v) => onChanged(v ?? false) : null,
      title: Text(title, style: text.bodyMedium),
      subtitle: Text(
        bossTitle,
        style: text.bodyMedium?.copyWith(color: context.palette.ash),
      ),
    );
  }
}
