import 'dart:async';

class BPMCalculator {
  static const int recordingDuration = 10; // seconds

  List<DateTime> _tapTimes = [];
  Timer? _recordingTimer;
  Timer? _updateTimer;
  bool _isRecording = false;
  int _secondsLeft = recordingDuration;

  Function(double bpm, int tapCount, int timeLeft)? onBPMUpdate;
  Function(double finalBPM, int totalTaps)? onRecordingComplete;

  void startRecording() {
    if (_isRecording) return;

    _isRecording = true;
    _secondsLeft = recordingDuration;
    _tapTimes.clear();

    // Update timer every second to show countdown
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsLeft--;
      if (_secondsLeft >= 0) {
        final currentBPM = _calculateCurrentBPM();
        onBPMUpdate?.call(currentBPM, _tapTimes.length, _secondsLeft);
      }
    });

    // Recording completion timer
    _recordingTimer = Timer(const Duration(seconds: recordingDuration), () {
      _stopRecording();
    });
  }

  void addTap() {
    if (!_isRecording) return;

    final now = DateTime.now();
    _tapTimes.add(now);

    // Immediately update BPM
    final currentBPM = _calculateCurrentBPM();
    onBPMUpdate?.call(currentBPM, _tapTimes.length, _secondsLeft);
  }

  double _calculateCurrentBPM() {
    if (_tapTimes.length < 2) return 0.0;

    // Calculate BPM based on all taps recorded so far
    final firstTap = _tapTimes.first;
    final lastTap = _tapTimes.last;

    final timeDifference = lastTap.difference(firstTap).inMilliseconds / 1000.0;
    if (timeDifference <= 0) return 0.0;

    final tapCount = _tapTimes.length - 1; // Intervals between taps
    final bpm = (tapCount / timeDifference) * 60.0;

    return bpm;
  }

  double _calculateFinalBPM() {
    if (_tapTimes.length < 2) return 0.0;

    // More accurate calculation for final result
    // Use average interval between consecutive taps
    double totalInterval = 0.0;
    int intervalCount = 0;

    for (int i = 1; i < _tapTimes.length; i++) {
      final interval = _tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds / 1000.0;
      if (interval > 0 && interval < 3.0) { // Filter out unrealistic intervals
        totalInterval += interval;
        intervalCount++;
      }
    }

    if (intervalCount == 0) return 0.0;

    final averageInterval = totalInterval / intervalCount;
    return 60.0 / averageInterval;
  }

  void _stopRecording() {
    if (!_isRecording) return;

    _isRecording = false;
    _recordingTimer?.cancel();
    _updateTimer?.cancel();

    final finalBPM = _calculateFinalBPM();
    onRecordingComplete?.call(finalBPM, _tapTimes.length);
  }

  void reset() {
    _recordingTimer?.cancel();
    _updateTimer?.cancel();
    _isRecording = false;
    _tapTimes.clear();
    _secondsLeft = recordingDuration;
  }

  void dispose() {
    _recordingTimer?.cancel();
    _updateTimer?.cancel();
  }

  bool get isRecording => _isRecording;
  int get tapCount => _tapTimes.length;
}