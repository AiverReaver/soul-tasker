import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import 'glass_surface.dart';
import 'thread_divider.dart';

/// A centred glass alert: a small [label], a serif [title], a thread, the
/// [body], then full-width action rows split by a key line. Tapping action
/// `i` pops `i`; the first is the default and wears the silk tint.
class GlassAlert extends StatelessWidget {
  const GlassAlert({
    super.key,
    this.title,
    this.body,
    this.content,
    required this.actions,
    this.label,
    this.onAction,
  }) : assert(body != null || content != null);

  final String? title;
  final String? body;

  /// Replaces [body] with a widget, such as framed rows.
  final Widget? content;

  /// Called with the action's index instead of popping the route.
  final ValueChanged<int>? onAction;
  final String? label;
  final List<String> actions;

  static const maxWidth = 334.0;
  static const rowHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Semantics(
      key: const ValueKey('glass-alert'),
      role: SemanticsRole.alertDialog,
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title ?? body,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: GlassSurface(
              shape: GlassShape.rounded(34),
              blur: 24,
              glintSize: 68,
              child: ColoredBox(
                color: p.shell.withValues(alpha: .62),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                      child: Column(
                        spacing: 14,
                        children: [
                          if (label != null)
                            Text(label!.toUpperCase(), style: text.labelSmall),
                          if (title != null) ...[
                            Text(
                              title!,
                              textAlign: TextAlign.center,
                              style: text.titleMedium!.copyWith(
                                fontSize: 30,
                                height: 34 / 30,
                              ),
                            ),
                            const ThreadDivider(),
                          ],
                          content ??
                              Text(
                                body!,
                                textAlign: TextAlign.center,
                                style: text.bodyMedium!.copyWith(color: p.ash),
                              ),
                        ],
                      ),
                    ),
                    for (final (i, action) in actions.indexed)
                      _row(context, i, action),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _act(BuildContext context, int i) =>
      onAction != null ? onAction!(i) : Navigator.of(context).pop(i);

  Widget _row(BuildContext context, int i, String action) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: action,
      onTap: () => _act(context, i),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _act(context, i),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: i == 0 ? p.silk.withValues(alpha: .28) : null,
            border: Border(top: BorderSide(color: p.glassKey, width: 1.5)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: rowHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
                child: Text(
                  action,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.bone,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a [GlassAlert] and returns the index of the action chosen, or null
/// if the user tapped outside.
Future<int?> showGlassAlert(
  BuildContext context, {
  required String title,
  required String body,
  required List<String> actions,
  String? label,
}) => showDialog<int>(
  context: context,
  barrierColor: context.palette.ink.withValues(alpha: .62),
  builder: (_) =>
      GlassAlert(title: title, body: body, label: label, actions: actions),
);
