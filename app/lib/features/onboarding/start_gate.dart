import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';

/// The start of the app: onboarding the first time, [child] after that
/// (Stage 5 plan D11). Reads the stored setting once each time it opens, not
/// a cached stream, so finishing onboarding is seen at once.
class StartGate extends ConsumerStatefulWidget {
  const StartGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StartGate> createState() => _StartGateState();
}

class _StartGateState extends ConsumerState<StartGate> {
  late final Future<bool> _isOnboarded = ref
      .read(settingsDaoProvider)
      .read()
      .then((s) => s.onboarded);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboarded,
      builder: (context, snapshot) {
        final isOnboarded = snapshot.data;
        if (isOnboarded == null) return const Scaffold();
        if (isOnboarded) return widget.child;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/welcome');
        });
        return const Scaffold();
      },
    );
  }
}
