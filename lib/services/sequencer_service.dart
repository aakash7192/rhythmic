import 'package:flutter_sequencer/flutter_sequencer.dart';

class SequencerService {
  static final SequencerService _instance = SequencerService._internal();
  factory SequencerService() => _instance;
  SequencerService._internal();

  double _currentBPM = 120.0;
  bool _isInitialized = false;

  double get currentBPM => _currentBPM;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await FlutterSequencer.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize sequencer: $e');
      _isInitialized = false;
    }
  }

  Future<void> updateTempo(double bpm) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isInitialized) {
      try {
        _currentBPM = bpm;
        await FlutterSequencer.setTempo(bpm);
      } catch (e) {
        print('Failed to update tempo: $e');
      }
    }
  }

  Future<void> start() async {
    if (_isInitialized) {
      try {
        await FlutterSequencer.start();
      } catch (e) {
        print('Failed to start sequencer: $e');
      }
    }
  }

  Future<void> stop() async {
    if (_isInitialized) {
      try {
        await FlutterSequencer.stop();
      } catch (e) {
        print('Failed to stop sequencer: $e');
      }
    }
  }

  void dispose() {
    FlutterSequencer.dispose();
    _isInitialized = false;
  }
}