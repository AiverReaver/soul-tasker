import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// A settings row showing a value; tapping it opens a way to change it.
class SettingValueRow extends StatelessWidget {
  const SettingValueRow({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: text.bodyMedium),
      trailing: Text(
        value,
        style: text.bodyMedium?.copyWith(color: context.palette.ash),
      ),
      onTap: onTap,
    );
  }
}
