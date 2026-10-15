import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../data/enums.dart';
import 'ember_button.dart';

/// "What did this fight make of you?": one optional line on a relic. The
/// caller owns [controller]; [onSaved] is offered as a Save action when given.
class InscriptionField extends StatelessWidget {
  const InscriptionField({super.key, required this.controller, this.onSaved});

  final TextEditingController controller;
  final ValueChanged<String>? onSaved;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('What did this fight make of you?', style: text.titleMedium),
        const SizedBox(height: Space.sm),
        TextField(
          controller: controller,
          maxLength: kInscriptionMax,
          style: text.bodyMedium,
          cursorColor: kEmber,
          decoration: const InputDecoration(
            hintText: 'One line, if you like.',
            hintStyle: TextStyle(color: kTextMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kAshDim),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kEmber),
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
