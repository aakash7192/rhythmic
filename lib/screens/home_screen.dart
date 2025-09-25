import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../theme.dart';
import '../widgets/tap_circle.dart';
import '../models/bpm_calculator.dart';
import 'instrument_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _pulseController;
  late AnimationController _timelineController;
  final BPMCalculator _bpmCalculator = BPMCalculator();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _bpmTextController = TextEditingController();

  bool _isRecording = false;
  int _tapCount = 0;
  String _recordingTimeLeft = "10";
  double _manualBPM = 0.0;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);

    _timelineController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Request focus when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _bpmCalculator.onBPMUpdate = (bpm, tapCount, timeLeft) {
      if (mounted) {
        setState(() {
          _manualBPM = bpm;
          _tapCount = tapCount;
          _recordingTimeLeft = timeLeft.toString();
        });
      }
    };

    _bpmCalculator.onRecordingComplete = (finalBPM, totalTaps) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _manualBPM = finalBPM;
          _bpmTextController.text = finalBPM.toStringAsFixed(1);
        });
        _startTimelineAnimation();
      }
    };
  }

  void _onTapCircle() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }

    _rippleController.forward().then((_) {
      _rippleController.reset();
    });

    if (!_isRecording) {
      setState(() {
        _isRecording = true;
        _tapCount = 0;
        _manualBPM = 0.0;
      });
      _bpmCalculator.startRecording();
    }

    _bpmCalculator.addTap();
  }

  void _startTimelineAnimation() {
    if (_manualBPM > 0) {
      _timelineController.repeat();
    }
  }

  void _onManualBPMChanged(String value) {
    final bpm = double.tryParse(value) ?? 0.0;
    setState(() {
      _manualBPM = bpm;
    });
    if (bpm > 0) {
      _timelineController.duration = Duration(milliseconds: (60000 / bpm).round());
      _startTimelineAnimation();
    } else {
      _timelineController.stop();
    }
  }

  void _resetRecording() {
    setState(() {
      _isRecording = false;
      _manualBPM = 0.0;
      _tapCount = 0;
      _recordingTimeLeft = "10";
    });
    _bpmTextController.clear();
    _timelineController.stop();
    _bpmCalculator.reset();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      _onTapCircle();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _pulseController.dispose();
    _timelineController.dispose();
    _bpmCalculator.dispose();
    _focusNode.dispose();
    _bpmTextController.dispose();
    super.dispose();
  }

  Widget _buildTimeline() {
    return AnimatedBuilder(
      animation: _timelineController,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final lineSpacing = _manualBPM > 0 ? (screenWidth / (_manualBPM / 15)).toDouble() : 0.0;
        final offset = (_timelineController.value * lineSpacing).toDouble();

        return SizedBox(
          height: 200,
          width: double.infinity,
          child: CustomPaint(
            painter: TimelinePainter(
              offset: offset,
              lineSpacing: lineSpacing,
              screenWidth: screenWidth,
              bpm: _manualBPM.toDouble(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rhythmic'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.library_music),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InstrumentPlayerScreen(),
                  ),
                );
              },
              tooltip: 'Instruments',
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.backgroundDark,
                Color(0xFF1A202C),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: TapCircle(
                          onTap: _onTapCircle,
                          rippleController: _rippleController,
                          pulseController: _pulseController,
                          isRecording: _isRecording,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isRecording) ...[
                              Text(
                                'Recording... ${_recordingTimeLeft}s left',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.accentPink,
                                ),
                              ),
                              Text(
                                'Taps: $_tapCount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ] else ...[
                              Text(
                                'Tap to measure BPM',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                              Text(
                                'Or use SPACE key',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _bpmTextController,
                          onChanged: _onManualBPMChanged,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentPink,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0.0',
                            hintStyle: TextStyle(color: AppTheme.textSecondary),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.primaryPurple),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.primaryPurple),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.accentPink),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'BPM',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _resetRecording,
                        icon: const Icon(Icons.refresh, size: 20),
                        color: AppTheme.textSecondary,
                        tooltip: 'Reset',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _manualBPM > 0
                    ? _buildTimeline()
                    : Center(
                        child: Text(
                          'Set BPM to see timeline',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final double offset;
  final double lineSpacing;
  final double screenWidth;
  final double bpm;

  TimelinePainter({
    required this.offset,
    required this.lineSpacing,
    required this.screenWidth,
    required this.bpm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bpm <= 0) return;

    final paint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.6)
      ..strokeWidth = 2;

    final accentPaint = Paint()
      ..color = AppTheme.accentPink
      ..strokeWidth = 3;

    final centerY = size.height / 2;

    if (lineSpacing > 0) {
      for (double x = -offset; x < screenWidth + lineSpacing; x += lineSpacing) {
        if (x >= 0 && x <= screenWidth) {
          final isAccent = ((x + offset) / lineSpacing) % 4 == 0;
          canvas.drawLine(
            Offset(x, centerY - 50),
            Offset(x, centerY + 50),
            isAccent ? accentPaint : paint,
          );
        }
      }
    }

    final centerLinePaint = Paint()
      ..color = AppTheme.textSecondary.withOpacity(0.6)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(screenWidth / 2, centerY - 80),
      Offset(screenWidth / 2, centerY + 80),
      centerLinePaint,
    );

    final centerX = screenWidth / 2;
    bool showPinkBar = false;

    for (double x = -offset; x < screenWidth + lineSpacing; x += lineSpacing) {
      if (x >= 0 && x <= screenWidth) {
        final distance = (x - centerX).abs();
        if (distance < 5) {
          showPinkBar = true;
          break;
        }
      }
    }

    if (showPinkBar) {
      final pinkBarPaint = Paint()
        ..color = AppTheme.accentPink
        ..strokeWidth = 4;

      canvas.drawLine(
        Offset(centerX, centerY - 40),
        Offset(centerX, centerY + 40),
        pinkBarPaint,
      );
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${bpm.toStringAsFixed(1)} BPM',
        style: const TextStyle(
          color: AppTheme.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(screenWidth / 2 - textPainter.width / 2, centerY + 70),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}