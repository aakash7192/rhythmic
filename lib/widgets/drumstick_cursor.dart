import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrumstickCursor extends StatelessWidget {
  final Widget child;

  const DrumstickCursor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: Stack(
        children: [
          child,
          // Custom drumstick cursor overlay
          const Positioned.fill(
            child: IgnorePointer(
              child: _DrumstickCursorOverlay(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrumstickCursorOverlay extends StatefulWidget {
  const _DrumstickCursorOverlay();

  @override
  State<_DrumstickCursorOverlay> createState() => _DrumstickCursorOverlayState();
}

class _DrumstickCursorOverlayState extends State<_DrumstickCursorOverlay> {
  Offset _cursorPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        setState(() {
          _cursorPosition = event.position;
        });
      },
      child: Stack(
        children: [
          if (_cursorPosition != Offset.zero)
            Positioned(
              left: _cursorPosition.dx - 15,
              top: _cursorPosition.dy - 5,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: 0.3,
                  child: CustomPaint(
                    size: const Size(30, 6),
                    painter: _DrumstickPainter(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DrumstickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4513) // Brown color
      ..style = PaintingStyle.fill;

    // Stick body
    final stickRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.3, size.width * 0.85, size.height * 0.4),
      const Radius.circular(2),
    );
    canvas.drawRRect(stickRect, paint);

    // Tip
    final tipPaint = Paint()
      ..color = const Color(0xFFA0522D)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.5),
      size.height * 0.25,
      tipPaint,
    );

    // Handle grip
    final gripPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final gripRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.35, size.width * 0.2, size.height * 0.3),
      const Radius.circular(1),
    );
    canvas.drawRRect(gripRect, gripPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}