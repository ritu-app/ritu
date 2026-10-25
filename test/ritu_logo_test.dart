import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onboarding logo corners are clear of the light page color', () async {
    final data = await rootBundle.load('assets/images/ritu_logo.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final bytes = (await image.toByteData())!;

    int channel(int x, int y, int component) =>
        bytes.getUint8((y * image.width + x) * 4 + component);

    for (final point in [
      (0, 0),
      (image.width - 1, 0),
      (0, image.height - 1),
      (image.width - 1, image.height - 1),
    ]) {
      expect(channel(point.$1, point.$2, 3), 0);
    }

    final cx = image.width ~/ 2;
    final cy = image.height ~/ 2;
    expect(channel(cx, cy, 0), 0x5F);
    expect(channel(cx, cy, 1), 0x8F);
    expect(channel(cx, cy, 2), 0x7A);
    expect(channel(cx, cy, 3), 255);
  });
}
