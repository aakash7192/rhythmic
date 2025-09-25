import 'package:just_audio/just_audio.dart';

class WebAudioService {
  static final Map<String, AudioPlayer> _players = {};
  static bool _isInitialized = false;

  // Using open source drum samples - these are fallback URLs for demo
  static const Map<String, String> _drumSounds = {
    'kick': 'https://www.soundjay.com/buttons/sounds/beep-07a.wav',
    'snare': 'https://www.soundjay.com/buttons/sounds/beep-10.wav',
    'hihat_closed': 'https://www.soundjay.com/buttons/sounds/beep-03.wav',
    'hihat_open': 'https://www.soundjay.com/buttons/sounds/beep-04.wav',
    'tom_high': 'https://www.soundjay.com/buttons/sounds/beep-05.wav',
    'tom_low': 'https://www.soundjay.com/buttons/sounds/beep-06.wav',
    'crash': 'https://www.soundjay.com/buttons/sounds/beep-08.wav',
    'ride': 'https://www.soundjay.com/buttons/sounds/beep-09.wav',
  };

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Pre-create audio players for better performance
      for (final entry in _drumSounds.entries) {
        final player = AudioPlayer();
        _players[entry.key] = player;

        try {
          // Pre-load the audio
          await player.setUrl(entry.value);
          await player.setVolume(0.7); // Set reasonable volume
        } catch (e) {
          print('Warning: Could not pre-load ${entry.key}: $e');
          // Continue anyway, audio will load on first play
        }
      }

      _isInitialized = true;
      print('WebAudioService initialized successfully');
    } catch (e) {
      print('Error initializing WebAudioService: $e');
    }
  }

  static Future<void> playSound(String soundId) async {
    if (!_isInitialized) {
      await initialize();
    }

    final player = _players[soundId];
    final soundUrl = _drumSounds[soundId];

    if (player != null && soundUrl != null) {
      try {
        // Ensure the audio is loaded
        if (player.audioSource == null) {
          await player.setUrl(soundUrl);
        }

        // Reset position and play
        await player.seek(Duration.zero);
        await player.play();

        print('Playing sound: $soundId');
      } catch (e) {
        print('Error playing sound $soundId: $e');

        // Fallback: try to reload and play
        try {
          await player.setUrl(soundUrl);
          await player.play();
        } catch (e2) {
          print('Fallback also failed for $soundId: $e2');
        }
      }
    } else {
      print('No player or sound URL found for: $soundId');
    }
  }

  static Future<void> stopSound(String soundId) async {
    final player = _players[soundId];
    if (player != null) {
      try {
        await player.stop();
      } catch (e) {
        print('Error stopping sound $soundId: $e');
      }
    }
  }

  static Future<void> dispose() async {
    try {
      for (final player in _players.values) {
        await player.dispose();
      }
      _players.clear();
      _isInitialized = false;
      print('WebAudioService disposed');
    } catch (e) {
      print('Error disposing WebAudioService: $e');
    }
  }

  // Check if audio context needs user gesture (web requirement)
  static Future<bool> needsUserGesture() async {
    // On web, audio requires user gesture
    return true;
  }

  // Initialize with user gesture for web compatibility
  static Future<void> initializeWithUserGesture() async {
    try {
      // Play silent sound to unlock audio context
      final testPlayer = AudioPlayer();
      await testPlayer.setUrl('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmEcBjiN1fPSfiwEJ3fH8N2QQAoUX7Pp66pXFAlGnt/yv2IcBTiN1fTSfywEJ3bH8N2QQAkUX7Pp66tXFAlGnt/yv2IbBTiL1vTSfywEKHbH8N+QQQkUXrXp66xXFAlHnuDyv2IbBTiL1vXSfywEKHbH8N+QQQgVXbTq66pYEw==');
      await testPlayer.play();
      await testPlayer.stop();
      await testPlayer.dispose();

      await initialize();
    } catch (e) {
      print('Error in initializeWithUserGesture: $e');
      // Try normal initialization anyway
      await initialize();
    }
  }
}