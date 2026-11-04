import 'package:flutter/material.dart';

/// The LiveCare brand mark: a bold infinity made of a left ring and a right
/// solid disc carrying a white medical cross.
class LiveCareLogo extends StatelessWidget {
  const LiveCareLogo({
    super.key,
    this.size = 34,
    this.markColor = const Color(0xFF1D63ED),
    this.markColor2 = const Color(0xFF3B82F6),
    this.crossColor = Colors.white,
  });

  final double size;
  final Color markColor;
  final Color markColor2;
  final Color crossColor;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(
          markColor: markColor,
          markColor2: markColor2,
          crossColor: crossColor,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({
    required this.markColor,
    required this.markColor2,
    required this.crossColor,
  });

  final Color markColor;
  final Color markColor2;
  final Color crossColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w * 0.5;
    final cy = size.height * 0.5;

    final r = w * 0.25; // lobe radius
    final stroke = w * 0.11; // ring thickness
    final d = w * 0.185; // centre offset of each lobe

    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [markColor2, markColor],
    ).createShader(Offset.zero & size);

    final leftCenter = Offset(cx - d, cy);
    final rightCenter = Offset(cx + d, cy);

    // Left lobe: a ring only (keeps a clean, round hole).
    canvas.drawCircle(
      leftCenter,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = shader,
    );

    // Right lobe: ring + filled interior -> a solid disc.
    canvas.drawCircle(
      rightCenter,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = shader,
    );
    canvas.drawCircle(rightCenter, r - stroke * 0.5, Paint()..shader = shader);

    // White medical cross inside the right disc.
    final discR = r + stroke * 0.5;
    final armHalf = discR * 0.50;
    final armThick = discR * 0.40;
    final rr = Radius.circular(armThick * 0.32);
    final cross = Paint()..color = crossColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: rightCenter, width: armHalf * 2, height: armThick),
        rr,
      ),
      cross,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: rightCenter, width: armThick, height: armHalf * 2),
        rr,
      ),
      cross,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) =>
      old.markColor != markColor ||
      old.markColor2 != markColor2 ||
      old.crossColor != crossColor;
}
