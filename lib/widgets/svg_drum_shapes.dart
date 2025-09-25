import 'package:flutter/material.dart';
import 'dart:math' as math;

class SVGDrumShapes {
  // Kick Drum (Bass Drum) - Large circular drum
  static Widget kickDrum({
    required double size,
    required Color color,
    bool isPressed = false,
  }) {
    return CustomPaint(
      size: Size(size, size * 0.8),
      painter: _KickDrumPainter(
        color: color,
        isPressed: isPressed,
      ),
    );
  }

  // Snare Drum - Medium drum with snare wires
  static Widget snareDrum({
    required double size,
    required Color color,
    bool isPressed = false,
  }) {
    return CustomPaint(
      size: Size(size, size * 0.6),
      painter: _SnareDrumPainter(
        color: color,
        isPressed: isPressed,
      ),
    );
  }

  // Hi-Hat Closed
  static Widget hiHatClosed({
    required double size,
    required Color color,
    bool isPressed = false,
  }) {
    return CustomPaint(
      size: Size(size, size * 0.3),
      painter: _HiHatClosedPainter(
        color: color,
        isPressed: isPressed,
      ),
    );
  }

  // Hi-Hat Open
  static Widget hiHatOpen({
    required double size,
    required Color color,
    bool isPressed = false,
  }) {
    return CustomPaint(
      size: Size(size, size * 0.4),
      painter: _HiHatOpenPainter(
        color: color,
        isPressed: isPressed,
      ),
    );
  }

  // Tom Drums
  static Widget tom({
    required double size,
    required Color color,
    bool isPressed = false,
    bool isHigh = true,
  }) {
    return CustomPaint(
      size: Size(size, size * (isHigh ? 0.5 : 0.6)),
      painter: _TomPainter(
        color: color,
        isPressed: isPressed,
        isHigh: isHigh,
      ),
    );
  }

  // Crash Cymbal
  static Widget crashCymbal({
    required double size,
    required Color color,
    bool isPressed = false,
  }) {
    return CustomPaint(
      size: Size(size, size * 0.2),
      painter: _CrashCymbalPainter(
        color: color,
        isPressed: isPressed,
      ),
    );
  }

  // Ride Cymbal
  static Widget rideCymbal({
    required double size,
    required Color color,
    bool isPressed = false,
  }) {
    return CustomPaint(
      size: Size(size, size * 0.25),
      painter: _RideCymbalPainter(
        color: color,
        isPressed: isPressed,
      ),
    );
  }

  // Drumstick
  static Widget drumstick({
    required double size,
    required Color color,
    double angle = 0,
  }) {
    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: Size(size, size * 0.1),
        painter: _DrumstickPainter(color: color),
      ),
    );
  }
}

// Kick Drum Painter
class _KickDrumPainter extends CustomPainter {
  final Color color;
  final bool isPressed;

  _KickDrumPainter({required this.color, required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(3, 3),
        width: size.width,
        height: size.height,
      ),
      shadowPaint,
    );

    // Main drum body
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.6),
        color.withOpacity(0.8),
      ],
      stops: const [0.3, 0.7, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
    );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      paint,
    );

    // Rim
    final rimPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      rimPaint,
    );

    // Center logo area
    final logoPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.3, logoPaint);

    // Press effect
    if (isPressed) {
      final pressedPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        pressedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Snare Drum Painter
class _SnareDrumPainter extends CustomPainter {
  final Color color;
  final bool isPressed;

  _SnareDrumPainter({required this.color, required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(2, 2),
        width: size.width,
        height: size.height,
      ),
      shadowPaint,
    );

    // Main drum body
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.7),
        color.withOpacity(0.5),
      ],
      stops: const [0.2, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      paint,
    );

    // Snare wires pattern
    final wirePaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final startRadius = size.width * 0.3;
      final endRadius = size.width * 0.45;

      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );

      canvas.drawLine(start, end, wirePaint);
    }

    // Rim
    final rimPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      rimPaint,
    );

    // Press effect
    if (isPressed) {
      final pressedPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        pressedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Hi-Hat Closed Painter
class _HiHatClosedPainter extends CustomPainter {
  final Color color;
  final bool isPressed;

  _HiHatClosedPainter({required this.color, required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(1, 1),
        width: size.width,
        height: size.height,
      ),
      shadowPaint,
    );

    // Cymbal gradient
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.7),
        Colors.amber.withOpacity(0.8),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
      )
      ..style = PaintingStyle.fill;

    // Two cymbals slightly offset
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      paint,
    );

    // Highlight on top
    final highlightPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.2),
        width: size.width * 0.4,
        height: size.height * 0.4,
      ),
      highlightPaint,
    );

    // Press effect
    if (isPressed) {
      final pressedPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        pressedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Hi-Hat Open Painter
class _HiHatOpenPainter extends CustomPainter {
  final Color color;
  final bool isPressed;

  _HiHatOpenPainter({required this.color, required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Top cymbal (slightly raised)
    final topCenter = Offset(center.dx, center.dy - size.height * 0.15);
    _drawCymbal(canvas, topCenter, size, color);

    // Bottom cymbal
    _drawCymbal(canvas, center, size, color.withOpacity(0.8));

    // Press effect
    if (isPressed) {
      final pressedPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: topCenter, width: size.width, height: size.height),
        pressedPaint,
      );
    }
  }

  void _drawCymbal(Canvas canvas, Offset center, Size size, Color color) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(1, 1),
        width: size.width,
        height: size.height,
      ),
      shadowPaint,
    );

    // Cymbal gradient
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.6),
        Colors.amber.withOpacity(0.7),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Tom Painter
class _TomPainter extends CustomPainter {
  final Color color;
  final bool isPressed;
  final bool isHigh;

  _TomPainter({required this.color, required this.isPressed, required this.isHigh});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(2, 2),
        width: size.width,
        height: size.height,
      ),
      shadowPaint,
    );

    // Main tom body
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.6),
        color.withOpacity(0.8),
      ],
      stops: const [0.2, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      paint,
    );

    // Rim
    final rimPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      rimPaint,
    );

    // Press effect
    if (isPressed) {
      final pressedPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        pressedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Crash Cymbal Painter
class _CrashCymbalPainter extends CustomPainter {
  final Color color;
  final bool isPressed;

  _CrashCymbalPainter({required this.color, required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Create irregular cymbal shape
    final path = Path();
    final radius = math.min(size.width, size.height) / 2;

    for (int i = 0; i <= 360; i += 10) {
      final angle = (i * math.pi) / 180;
      final variation = math.sin(i * 6 * math.pi / 180) * 0.1;
      final currentRadius = radius * (1 + variation);

      final x = center.dx + math.cos(angle) * currentRadius;
      final y = center.dy + math.sin(angle) * currentRadius * 0.3; // Flattened

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Shadow
    final shadowPath = Path()..addPath(path, const Offset(2, 2));
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, shadowPaint);

    // Cymbal gradient
    final gradient = RadialGradient(
      colors: [
        const Color(0xFFFFD700).withOpacity(0.9),
        color.withOpacity(0.8),
        Colors.amber.withOpacity(0.6),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Press effect
    if (isPressed) {
      final pressedPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, pressedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ride Cymbal Painter
class _RideCymbalPainter extends CustomPainter {
  final Color color;
  final bool isPressed;

  _RideCymbalPainter({required this.color, required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(2, 2),
        width: size.width,
        height: size.height,
      ),
      shadowPaint,
    );

    // Cymbal body
    final gradient = RadialGradient(
      colors: [
        const Color(0xFFFFD700).withOpacity(0.8),
        color.withOpacity(0.7),
        Colors.amber.withOpacity(0.6),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      paint,
    );

    // Bell (center raised area)
    final bellPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size.width * 0.15, bellPaint);

    // Concentric rings
    final ringPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, size.width * 0.2 * i, ringPaint);
    }

    // Press effect
    if (isPressed) {
      final pressedPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        pressedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Drumstick Painter
class _DrumstickPainter extends CustomPainter {
  final Color color;

  _DrumstickPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Stick body
    final stickRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.3, size.width * 0.85, size.height * 0.4),
      const Radius.circular(8),
    );
    canvas.drawRRect(stickRect, paint);

    // Tip
    final tipPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.5),
      size.height * 0.25,
      tipPaint,
    );

    // Handle grip
    final gripPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final gripRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.35, size.width * 0.2, size.height * 0.3),
      const Radius.circular(4),
    );
    canvas.drawRRect(gripRect, gripPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}