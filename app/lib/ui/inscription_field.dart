import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../core/weathering.dart';
import 'ember_button.dart';
import 'needle_frame.dart';

/// "Inscription": one optional line on a relic. The
/// caller owns [controller]; [onSaved] is offered as a Save action when given.
class InscriptionField extends StatelessWidget {
  const InscriptionField({super.key, required this.controller, this.onSaved});

  final TextEditingController controller;
  final ValueChanged<String>? onSaved;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Inscription',
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${value.text.length} / $kInscriptionMax',
                style: text.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        NeedleFrame(
          tier: Cut.md,
          child: TextField(
            controller: controller,
            maxLength: kInscriptionMax,
            buildCounter: (
              _, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
            style: text.bodyMedium,
            cursorColor: p.silk,
            decoration: InputDecoration(
              hintText: 'A line to remember this by',
              hintStyle: TextStyle(color: p.ash),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (onSaved case final save?)
          Align(
            alignment: Alignment.centerRight,
            child: EmberButton(
              label: 'Save',
              onPressed: () => save(controller.text),
            ),
          ),
      ],
    );
  }
}
