import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';
import 'dart:math';

class AudioService {
  static final Map<String, AudioPlayer> _players = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Pre-create audio players for better performance
    const drumSounds = [
      'kick',
      'snare',
      'hihat_closed',
      'hihat_open',
      'tom_high',
      'tom_low',
      'crash',
      'ride'
    ];

    for (final sound in drumSounds) {
      final player = AudioPlayer();
      await _loadGeneratedSound(player, sound);
      _players[sound] = player;
    }

    _isInitialized = true;
  }

  static Future<void> _loadGeneratedSound(AudioPlayer player, String soundType) async {
    try {
      // Generate simple audio waveforms for different drum sounds
      final audioData = _generateDrumSound(soundType);

      // For web, we'll use data URLs
      // Note: This is a simplified approach. In production, you'd use actual audio files
      await player.setAudioSource(
        _createAudioSource(audioData, soundType),
      );
    } catch (e) {
      print('Error loading sound $soundType: $e');
    }
  }

  static AudioSource _createAudioSource(Uint8List audioData, String soundType) {
    // For now, we'll create a simple sine wave generator
    // In a real app, you would load actual audio files
    return _SineWaveAudioSource(soundType);
  }

  static Uint8List _generateDrumSound(String soundType) {
    // Generate different waveforms for different drum sounds
    final sampleRate = 44100;
    final duration = soundType.contains('crash') || soundType.contains('ride') ? 2.0 : 0.5;
    final samples = (sampleRate * duration).round();
    final audioData = Uint8List(samples * 2); // 16-bit samples

    for (int i = 0; i < samples; i++) {
      double amplitude = 0.3;
      double frequency;

      // Different frequencies and envelopes for different drums
      switch (soundType) {
        case 'kick':
          frequency = 60.0;
          amplitude *= _envelope(i / samples, 0.01, 0.3); // Quick attack, medium decay
          break;
        case 'snare':
          frequency = 200.0 + (Random().nextDouble() * 100 - 50); // Add some noise
          amplitude *= _envelope(i / samples, 0.001, 0.2);
          break;
        case 'hihat_closed':
          frequency = 8000.0 + (Random().nextDouble() * 2000 - 1000);
          amplitude *= _envelope(i / samples, 0.001, 0.1);
          break;
        case 'hihat_open':
          frequency = 6000.0 + (Random().nextDouble() * 2000 - 1000);
          amplitude *= _envelope(i / samples, 0.001, 0.3);
          break;
        case 'tom_high':
          frequency = 150.0;
          amplitude *= _envelope(i / samples, 0.01, 0.4);
          break;
        case 'tom_low':
          frequency = 80.0;
          amplitude *= _envelope(i / samples, 0.01, 0.5);
          break;
        case 'crash':
          frequency = 3000.0 + (Random().nextDouble() * 2000 - 1000);
          amplitude *= _envelope(i / samples, 0.001, 0.8);
          break;
        case 'ride':
          frequency = 2000.0 + (Random().nextDouble() * 1000 - 500);
          amplitude *= _envelope(i / samples, 0.001, 0.6);
          break;
        default:
          frequency = 440.0;
      }

      // Generate wave with some noise for realistic drum sound
      double sample = sin(2 * pi * frequency * i / sampleRate) * amplitude;

      // Add some noise for more realistic drum sounds
      if (soundType.contains('snare') || soundType.contains('hihat')) {
        sample += (Random().nextDouble() * 2 - 1) * amplitude * 0.3;
      }

      // Convert to 16-bit integer
      final intSample = (sample * 32767).round().clamp(-32768, 32767);

      // Store as little-endian 16-bit
      audioData[i * 2] = intSample & 0xFF;
      audioData[i * 2 + 1] = (intSample >> 8) & 0xFF;
    }

    return audioData;
  }

  static double _envelope(double position, double attack, double decay) {
    if (position < attack) {
      return position / attack; // Attack phase
    } else {
      return exp(-(position - attack) / decay); // Exponential decay
    }
  }

  static Future<void> playSound(String soundId) async {
    if (!_isInitialized) {
      await initialize();
    }

    final player = _players[soundId];
    if (player != null) {
      try {
        await player.seek(Duration.zero);
        await player.play();
      } catch (e) {
        print('Error playing sound $soundId: $e');
      }
    }
  }

  static Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _isInitialized = false;
  }
}

// Custom AudioSource for generated sine waves
class _SineWaveAudioSource extends StreamAudioSource {
  final String soundType;

  _SineWaveAudioSource(this.soundType);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // For simplicity, we'll return an empty stream
    // In a real implementation, you'd generate PCM data here
    return StreamAudioResponse(
      sourceLength: 44100 * 2, // 1 second at 44.1kHz
      contentLength: 44100 * 2,
      offset: start ?? 0,
      stream: Stream.empty(),
      contentType: 'audio/pcm',
    );
  }
}