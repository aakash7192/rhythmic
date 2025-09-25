import 'package:flutter/material.dart';
import '../models/drum_pad.dart';
import '../theme.dart';
import 'svg_drum_shapes.dart';

class RealisticDrumKit extends StatefulWidget {
  final DrumInstrument instrument;
  final Function(String) onDrumHit;

  const RealisticDrumKit({
    super.key,
    required this.instrument,
    required this.onDrumHit,
  });

  @override
  State<RealisticDrumKit> createState() => _RealisticDrumKitState();
}

class _RealisticDrumKitState extends State<RealisticDrumKit>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _hitAnimations = {};
  final Map<String, bool> _isPressed = {};

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for each drum pad
    for (final pad in widget.instrument.pads) {
      _hitAnimations[pad.id] = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
      _isPressed[pad.id] = false;
    }
  }

  @override
  void dispose() {
    for (final controller in _hitAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDrumHit(String padId) {
    setState(() {
      _isPressed[padId] = true;
    });

    _hitAnimations[padId]?.forward().then((_) {
      _hitAnimations[padId]?.reverse();
      if (mounted) {
        setState(() {
          _isPressed[padId] = false;
        });
      }
    });

    widget.onDrumHit(padId);
  }

  Color _getPadColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Background with subtle drum kit silhouette
          _buildBackground(),

          // Drum kit layout
          _buildDrumKitLayout(),

          // Floating drumsticks (decorative)
          _buildDrumsticks(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            AppTheme.backgroundDark.withOpacity(0.3),
            AppTheme.backgroundDark.withOpacity(0.8),
            AppTheme.backgroundDark,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildDrumKitLayout() {
    return Column(
      children: [
        // Top row: Cymbals and Hi-Hats
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crash Cymbal
              Expanded(
                child: _buildDrumPad('crash', alignment: Alignment.topLeft),
              ),
              // Hi-Hats
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildDrumPad('hihat_open', alignment: Alignment.topCenter)),
                    Expanded(child: _buildDrumPad('hihat_closed', alignment: Alignment.center)),
                  ],
                ),
              ),
              // Ride Cymbal
              Expanded(
                child: _buildDrumPad('ride', alignment: Alignment.topRight),
              ),
            ],
          ),
        ),

        // Middle row: Toms
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              // High Tom
              Expanded(child: _buildDrumPad('tom_high', alignment: Alignment.center)),
              const SizedBox(width: 20),
              // Low Tom
              Expanded(child: _buildDrumPad('tom_low', alignment: Alignment.center)),
              const SizedBox(width: 20),
            ],
          ),
        ),

        // Bottom row: Kick and Snare
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Kick Drum (larger)
              Expanded(
                flex: 2,
                child: _buildDrumPad('kick', alignment: Alignment.bottomCenter, isLarge: true),
              ),
              // Snare Drum
              Expanded(
                flex: 1,
                child: _buildDrumPad('snare', alignment: Alignment.bottomRight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrumPad(String padId, {required Alignment alignment, bool isLarge = false}) {
    final pad = widget.instrument.pads.firstWhere(
      (p) => p.id == padId,
      orElse: () => widget.instrument.pads.first,
    );

    final color = _getPadColor(pad.color);
    final isPressed = _isPressed[padId] ?? false;
    final baseSize = isLarge ? 120.0 : 80.0;

    return AnimatedBuilder(
      animation: _hitAnimations[padId]!,
      builder: (context, child) {
        final animationValue = _hitAnimations[padId]!.value;
        final scale = 1.0 + (animationValue * 0.1);

        return Align(
          alignment: alignment,
          child: GestureDetector(
            onTapDown: (_) => _onDrumHit(padId),
            child: Transform.scale(
              scale: scale,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: baseSize * 1.2,
                  maxHeight: baseSize * 1.2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drum shape
                    _buildDrumShape(padId, baseSize, color, isPressed),

                    // Label
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pad.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrumShape(String padId, double size, Color color, bool isPressed) {
    switch (padId) {
      case 'kick':
        return SVGDrumShapes.kickDrum(size: size, color: color, isPressed: isPressed);
      case 'snare':
        return SVGDrumShapes.snareDrum(size: size, color: color, isPressed: isPressed);
      case 'hihat_closed':
        return SVGDrumShapes.hiHatClosed(size: size, color: color, isPressed: isPressed);
      case 'hihat_open':
        return SVGDrumShapes.hiHatOpen(size: size, color: color, isPressed: isPressed);
      case 'tom_high':
        return SVGDrumShapes.tom(size: size, color: color, isPressed: isPressed, isHigh: true);
      case 'tom_low':
        return SVGDrumShapes.tom(size: size, color: color, isPressed: isPressed, isHigh: false);
      case 'crash':
        return SVGDrumShapes.crashCymbal(size: size, color: color, isPressed: isPressed);
      case 'ride':
        return SVGDrumShapes.rideCymbal(size: size, color: color, isPressed: isPressed);
      default:
        return SVGDrumShapes.tom(size: size, color: color, isPressed: isPressed);
    }
  }

  Widget _buildDrumsticks() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Left drumstick
            Positioned(
              left: 50,
              top: 100,
              child: Transform.rotate(
                angle: 0.3,
                child: SVGDrumShapes.drumstick(
                  size: 80,
                  color: Colors.brown.withOpacity(0.3),
                ),
              ),
            ),
            // Right drumstick
            Positioned(
              right: 60,
              top: 120,
              child: Transform.rotate(
                angle: -0.2,
                child: SVGDrumShapes.drumstick(
                  size: 75,
                  color: Colors.brown.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom cursor for drumstick pointer
class DrumstickCursor extends MouseRegion {
  const DrumstickCursor({
    super.key,
    required super.child,
  }) : super(cursor: SystemMouseCursors.click);
}

// Extension to add drumstick cursor easily
extension DrumstickCursorExtension on Widget {
  Widget withDrumstickCursor() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: this,
    );
  }
}