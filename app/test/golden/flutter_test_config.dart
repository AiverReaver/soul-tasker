import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's real fonts (and Material icons from the SDK) so goldens
/// show text, not the test font's boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<void> load(String family, Future<ByteData> bytes) =>
      (FontLoader(family)..addFont(bytes)).load();
  await load(
    'CormorantGaramond',
    rootBundle.load('assets/fonts/CormorantGaramond.ttf'),
  );
  await load(
    'HankenGrotesk',
    rootBundle.load('assets/fonts/HankenGrotesk.ttf'),
  );
  final icons = File(
    '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    await load(
      'MaterialIcons',
      Future.value(ByteData.sublistView(icons.readAsBytesSync())),
    );
  }
  await testMain();
}
