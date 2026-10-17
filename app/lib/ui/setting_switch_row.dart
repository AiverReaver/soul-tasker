import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A settings row with an on/off switch.
class SettingSwitchRow extends StatelessWidget {
  const SettingSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      value: value,
      activeThumbColor: context.palette.silk,
      onChanged: onChanged,
    );
  }
}
