import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/features/tester_report/tester_report.dart';

// Stage 6 step 8: the release build is set up for the Play closed track.
// Reads files as text; no Gradle run.
void main() {
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();

  test('version is 0.7.0+N and kAppVersion matches (plan D9)', () {
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1)!;
    final match = RegExp(r'^0\.7\.0\+(\d+)$').firstMatch(version);

    expect(match, isNotNull, reason: 'version was $version');
    expect(int.parse(match!.group(1)!), greaterThanOrEqualTo(1));
    expect(kAppVersion, version);
  });

  test('release is signed from key.properties, never debug (plan D10)', () {
    final release = RegExp(
      r'release\s*\{[^}]*\}',
      multiLine: true,
    ).allMatches(gradle).map((m) => m.group(0)!).join('\n');

    expect(gradle, contains('key.properties'));
    expect(release, contains('signingConfigs.getByName("release")'));
    expect(
      gradle,
      isNot(contains('signingConfig = signingConfigs.getByName("debug")')),
    );
    expect(gradle, isNot(contains('TODO')));
  });

  test('target SDK is the Flutter default (36) or a literal at least 36', () {
    final target = RegExp(r'targetSdk\s*=\s*(\S+)').firstMatch(gradle)!;
    final value = target.group(1)!;
    if (value != 'flutter.targetSdkVersion') {
      expect(int.parse(value), greaterThanOrEqualTo(36));
    }
  });

  test('INTERNET and the two notification permissions, nothing else', () {
    final permissions = RegExp(r'uses-permission\s+android:name="([^"]+)"')
        .allMatches(manifest)
        .map((m) => m.group(1))
        .toSet();

    expect(permissions, {
      'android.permission.INTERNET',
      'android.permission.POST_NOTIFICATIONS',
      'android.permission.RECEIVE_BOOT_COMPLETED',
    });
  });

  test('traffic is encrypted: no cleartext, no user-added certificates', () {
    expect(manifest, isNot(contains('usesCleartextTraffic="true"')));
    expect(manifest, isNot(contains('networkSecurityConfig')));
    expect(
      File('lib/server_config.dart').readAsStringSync(),
      isNot(contains('http://')),
    );
  });

  test('the launcher icon is adaptive with a vector foreground (D14)', () {
    final adaptive = File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
    );
    expect(adaptive.existsSync(), isTrue);
    final xml = adaptive.readAsStringSync();
    expect(xml, contains('<adaptive-icon'));
    expect(xml, contains('@drawable/ic_launcher_foreground'));
    expect(xml, contains('@color/ic_launcher_background'));
    final foreground = File(
      'android/app/src/main/res/drawable/ic_launcher_foreground.xml',
    ).readAsStringSync();
    expect(foreground, contains('<vector'));
  });
}
