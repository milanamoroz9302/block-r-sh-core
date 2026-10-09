import 'package:flutter/material.dart';

/// Thin sci-fi corner brackets drawn around a surface.
class HudFramePainter extends CustomPainter {
  const HudFramePainter({
    required this.color,
    this.length = 18,
    this.stroke = 1.5,
    this.bottom = true,
  });

  final Color color;
  final double length;
  final double stroke;
  final bool bottom;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    const double inset = 6;
    final double l = length;

    canvas.drawLine(
        Offset(inset, inset), Offset(inset + l, inset), paint);
    canvas.drawLine(
        Offset(inset, inset), Offset(inset, inset + l), paint);

    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(size.width - inset - l, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(size.width - inset, inset + l), paint);

    if (!bottom) return;

    canvas.drawLine(Offset(inset, size.height - inset),
        Offset(inset + l, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset),
        Offset(inset, size.height - inset - l), paint);

    canvas.drawLine(Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset - l, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset, size.height - inset - l), paint);
  }

  @override
  bool shouldRepaint(HudFramePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.length != length ||
      oldDelegate.stroke != stroke ||
      oldDelegate.bottom != bottom;
}
