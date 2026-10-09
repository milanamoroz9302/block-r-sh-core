import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Static full-canvas grain. Painted once (never repaints) — it gives the
/// loader frame enough high-frequency detail to stay visually distinct from
/// the flatter menu art.
class GrainPainter extends CustomPainter {
  const GrainPainter({this.points = 130000, this.seed = 0x9E3779B9});

  final int points;
  final int seed;

  static const List<Color> _tints = <Color>[
    Color(0x1A2F7EFF),
    Color(0x147C4BD2),
    Color(0x1435C5D0),
    Color(0x12F4F6FF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final int perPass = points ~/ _tints.length;
    int state = seed == 0 ? 1 : seed;

    int next() {
      state ^= (state << 13) & 0xFFFFFFFF;
      state ^= state >>> 17;
      state ^= (state << 5) & 0xFFFFFFFF;
      return state & 0xFFFFFFFF;
    }

    for (int pass = 0; pass < _tints.length; pass++) {
      final Float32List buffer = Float32List(perPass * 2);
      for (int i = 0; i < perPass; i++) {
        buffer[i * 2] = (next() / 4294967296.0) * size.width;
        buffer[i * 2 + 1] = (next() / 4294967296.0) * size.height;
      }
      final Paint paint = Paint()
        ..color = _tints[pass]
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.square;
      canvas.drawRawPoints(ui.PointMode.points, buffer, paint);
    }
  }

  @override
  bool shouldRepaint(GrainPainter oldDelegate) => false;
}
