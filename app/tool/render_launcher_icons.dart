// Renders the launcher icon PNGs (API 24-25 fallback) and the 512 px Play
// Store icon from the same shapes as
// android/app/src/main/res/drawable/ic_launcher_foreground.xml.
//
// Run from app/:  flutter test tool/render_launcher_icons.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

const _background = ui.Color(0xFF0B0A09);
const _ring = ui.Color(0xFF8F897F);
const _ember = ui.Color(0xFFD9A441);

const _sizes = {
  'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
  'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
  'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
  'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
  'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  'store/play_icon_512.png': 512,
};

/// Paints the 108 unit foreground, cropped to its central 72 units.
void _paint(ui.Canvas canvas, double size, {required bool isRounded}) {
  final scale = size / 72;
  final bg = ui.Paint()..color = _background;
  final rect = ui.Rect.fromLTWH(0, 0, size, size);
  isRounded
      ? canvas.drawRRect(
          ui.RRect.fromRectAndRadius(rect, ui.Radius.circular(size * 0.18)),
          bg,
        )
      : canvas.drawRect(rect, bg);
  canvas
    ..save()
    ..scale(scale)
    ..translate(-18, -18)
    ..drawCircle(
      const ui.Offset(54, 56),
      24,
      ui.Paint()
        ..color = _ring
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3,
    )
    ..drawPath(
      ui.Path()
        ..moveTo(54, 36)
        ..cubicTo(58, 44, 64, 50, 64, 57)
        ..cubicTo(64, 63, 59.5, 67, 54, 67)
        ..cubicTo(48.5, 67, 44, 63, 44, 57)
        ..cubicTo(44, 50, 50, 44, 54, 36)
        ..close(),
      ui.Paint()..color = _ember,
    )
    ..restore();
}

void main() {
  test('render launcher icons', () async {
    for (final entry in _sizes.entries) {
      final size = entry.value.toDouble();
      final recorder = ui.PictureRecorder();
      _paint(ui.Canvas(recorder), size, isRounded: entry.value != 512);
      final image = await recorder.endRecording().toImage(
        entry.value,
        entry.value,
      );
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File(entry.key)..parent.createSync(recursive: true);
      file.writeAsBytesSync(png!.buffer.asUint8List());
    }
  });
}
