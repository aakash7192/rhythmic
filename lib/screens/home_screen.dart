import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../theme.dart';
import '../widgets/tap_circle.dart';
import '../models/bpm_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _pulseController;
  final BPMCalculator _bpmCalculator = BPMCalculator();
  final FocusNode _focusNode = FocusNode();

  bool _isRecording = false;
  double _currentBPM = 0.0;
  int _tapCount = 0;
  String _recordingTimeLeft = "10";

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

    // Request focus when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _bpmCalculator.onBPMUpdate = (bpm, tapCount, timeLeft) {
      if (mounted) {
        setState(() {
          _currentBPM = bpm;
          _tapCount = tapCount;
          _recordingTimeLeft = timeLeft.toString();
        });
      }
    };

    _bpmCalculator.onRecordingComplete = (finalBPM, totalTaps) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _currentBPM = finalBPM;
        });
        _showResultDialog(finalBPM, totalTaps);
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
        _currentBPM = 0.0;
      });
      _bpmCalculator.startRecording();
    }

    _bpmCalculator.addTap();
  }

  void _showResultDialog(double bpm, int taps) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text(
            'Recording Complete!',
            style: TextStyle(color: AppTheme.textLight),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 48,
                color: AppTheme.primaryPurple,
              ),
              const SizedBox(height: 16),
              Text(
                '${bpm.toStringAsFixed(1)} BPM',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentPink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$taps taps in 10 seconds',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetRecording();
              },
              child: const Text(
                'Try Again',
                style: TextStyle(color: AppTheme.primaryPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetRecording() {
    setState(() {
      _isRecording = false;
      _currentBPM = 0.0;
      _tapCount = 0;
      _recordingTimeLeft = "10";
    });
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
    _bpmCalculator.dispose();
    _focusNode.dispose();
    super.dispose();
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
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRecording) ...[
                        Text(
                          'Recording...',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppTheme.accentPink,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_recordingTimeLeft}s left',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ] else ...[
                        Text(
                          'Tap to Start',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the circle or press SPACE to measure BPM',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: TapCircle(
                    onTap: _onTapCircle,
                    rippleController: _rippleController,
                    pulseController: _pulseController,
                    isRecording: _isRecording,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentBPM > 0) ...[
                      Text(
                        '${_currentBPM.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              color: AppTheme.accentPink,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Text(
                        'BPM',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Taps: $_tapCount',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ] else ...[
                      const Text(
                        '0.0',
                        style: TextStyle(
                          fontSize: 48,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'BPM',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (!_isRecording && _currentBPM > 0)
                      ElevatedButton.icon(
                        onPressed: _resetRecording,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                  ],
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