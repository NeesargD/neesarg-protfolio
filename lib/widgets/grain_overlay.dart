import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A subtle, static film-grain wash over the whole page.
///
/// A small noise tile is generated once, encoded to PNG, then tiled via a
/// standard [DecorationImage] (`ImageRepeat.repeat`) with a low [opacity].
/// Using the normal image-decoration path (rather than a CustomPaint +
/// ImageShader) keeps it cheap and avoids compositor quirks.
class GrainOverlay extends StatefulWidget {
  const GrainOverlay({super.key, this.opacity = 0.04});

  final double opacity;

  @override
  State<GrainOverlay> createState() => _GrainOverlayState();
}

class _GrainOverlayState extends State<GrainOverlay> {
  Uint8List? _png;

  @override
  void initState() {
    super.initState();
    _generateNoise();
  }

  Future<void> _generateNoise() async {
    const size = 160;
    final rnd = Random(7);
    final pixels = Uint8List(size * size * 4);
    for (var i = 0; i < size * size; i++) {
      final v = rnd.nextInt(256);
      final o = i * 4;
      pixels[o] = v;
      pixels[o + 1] = v;
      pixels[o + 2] = v;
      pixels[o + 3] = 255;
    }
    final image = await _decode(pixels, size);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (mounted && data != null) {
      setState(() => _png = data.buffer.asUint8List());
    }
  }

  Future<ui.Image> _decode(Uint8List pixels, int size) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      size,
      size,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final png = _png;
    if (png == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(png),
              repeat: ImageRepeat.repeat,
              opacity: widget.opacity,
            ),
          ),
        ),
      ),
    );
  }
}
