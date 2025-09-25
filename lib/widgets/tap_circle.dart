import 'package:flutter/material.dart';
import '../theme.dart';

class TapCircle extends StatelessWidget {
  final VoidCallback onTap;
  final AnimationController rippleController;
  final AnimationController pulseController;
  final bool isRecording;

  const TapCircle({
    super.key,
    required this.onTap,
    required this.rippleController,
    required this.pulseController,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse animation for when not recording
            if (!isRecording)
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (pulseController.value * 0.1),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryPurple.withOpacity(0.1),
                        border: Border.all(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Ripple effect animation
            AnimatedBuilder(
              animation: rippleController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue = (rippleController.value - delay).clamp(0.0, 1.0);

                    return Transform.scale(
                      scale: 1.0 + (animationValue * 1.5),
                      child: Opacity(
                        opacity: (1.0 - animationValue).clamp(0.0, 1.0),
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentPink,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            // Main tap circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isRecording
                      ? [
                          AppTheme.accentPink,
                          AppTheme.accentOrange,
                        ]
                      : [
                          AppTheme.primaryPurple,
                          AppTheme.accentTeal,
                        ],
                  stops: const [0.3, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? AppTheme.accentPink : AppTheme.primaryPurple)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isRecording ? Icons.radio_button_checked : Icons.touch_app,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

            // Recording indicator pulse
            if (isRecording)
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (pulseController.value * 0.2),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3 + (pulseController.value * 0.4)),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}