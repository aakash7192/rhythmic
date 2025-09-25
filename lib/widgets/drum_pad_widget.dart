import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../theme.dart';
import '../models/drum_pad.dart';

class DrumPadWidget extends StatefulWidget {
  final DrumPad pad;
  final VoidCallback onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;

  const DrumPadWidget({
    super.key,
    required this.pad,
    required this.onTap,
    this.onTapDown,
    this.onTapUp,
  });

  @override
  State<DrumPadWidget> createState() => _DrumPadWidgetState();
}

class _DrumPadWidgetState extends State<DrumPadWidget>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Color _getPadColor() {
    try {
      return Color(int.parse(widget.pad.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryPurple;
    }
  }

  void _handleTapDown() async {
    setState(() {
      _isPressed = true;
    });

    _pressController.forward();
    _rippleController.forward().then((_) => _rippleController.reset());

    // Haptic feedback
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 30);
    }

    widget.onTapDown?.call();
  }

  void _handleTapUp() {
    setState(() {
      _isPressed = false;
    });

    _pressController.reverse();
    widget.onTapUp?.call();
  }

  void _handleTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final padColor = _getPadColor();

    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: () => _handleTapUp(),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: padColor.withOpacity(_isPressed ? 0.6 : 0.3),
                    blurRadius: _isPressed ? 15 : 8,
                    offset: Offset(0, _isPressed ? 3 : 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main pad background
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          padColor.withOpacity(0.9),
                          padColor.withOpacity(0.7),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),

                  // Ripple effect
                  AnimatedBuilder(
                    animation: _rippleController,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(
                                (1.0 - _rippleController.value) * 0.3,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Content
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pad name
                          Text(
                            widget.pad.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Key/Note info
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.pad.key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Pressed overlay
                  if (_isPressed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}