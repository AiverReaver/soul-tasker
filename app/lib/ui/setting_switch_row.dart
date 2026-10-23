import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_switch.dart';

/// A settings row with a glass on/off switch. The whole row toggles it.
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
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => onChanged(!value),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinTarget),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ),
          GlassSwitch(value: value, onChanged: onChanged, semanticLabel: title),
        ],
      ),
    ),
  );
}
