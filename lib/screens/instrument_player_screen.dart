import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../theme.dart';
import '../models/drum_pad.dart';
import '../widgets/realistic_drum_kit.dart';
import '../widgets/drumstick_cursor.dart' as cursor;
import '../services/web_audio_service.dart';

class InstrumentPlayerScreen extends StatefulWidget {
  const InstrumentPlayerScreen({super.key});

  @override
  State<InstrumentPlayerScreen> createState() => _InstrumentPlayerScreenState();
}

class _InstrumentPlayerScreenState extends State<InstrumentPlayerScreen> {
  List<DrumInstrument> _instruments = [];
  DrumInstrument? _currentInstrument;
  bool _isLoading = true;
  bool _isAudioInitialized = false;
  bool _needsUserGesture = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInstruments();
    _checkAudioRequirements();
  }

  Future<void> _checkAudioRequirements() async {
    try {
      _needsUserGesture = await WebAudioService.needsUserGesture();
    } catch (e) {
      print('Error checking audio requirements: $e');
    }
  }

  Future<void> _loadInstruments() async {
    try {
      final String response = await rootBundle.loadString('assets/instruments/drums/instruments.json');
      final List<dynamic> data = json.decode(response);

      setState(() {
        _instruments = data.map((json) => DrumInstrument.fromJson(json)).toList();
        _isLoading = false;
      });

      // Load the first instrument by default
      if (_instruments.isNotEmpty) {
        await _loadInstrument(_instruments.first);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load instruments: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInstrument(DrumInstrument instrument) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      setState(() {
        _currentInstrument = instrument;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load instrument: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeAudio() async {
    if (_isAudioInitialized) return;

    try {
      setState(() => _isLoading = true);

      // Initialize with user gesture for web compatibility
      await WebAudioService.initializeWithUserGesture();

      setState(() {
        _isAudioInitialized = true;
        _needsUserGesture = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio initialized! You can now play drum sounds.'),
            backgroundColor: AppTheme.primaryPurple,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize audio: $e';
        _isLoading = false;
      });
    }
  }

  void _playSound(String padId) async {
    // Initialize audio if needed (this handles user gesture requirement)
    if (!_isAudioInitialized && _needsUserGesture) {
      await _initializeAudio();
      return; // Audio will be initialized, user can try again
    }

    try {
      await WebAudioService.playSound(padId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing $padId: $e'),
            backgroundColor: AppTheme.accentOrange,
            duration: const Duration(milliseconds: 1000),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Audio service handles its own cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return cursor.DrumstickCursor(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Instruments'),
          centerTitle: true,
          actions: [
            if (_instruments.isNotEmpty)
              PopupMenuButton<DrumInstrument>(
                icon: const Icon(Icons.music_note),
                onSelected: _loadInstrument,
                itemBuilder: (context) => _instruments.map((instrument) {
                  return PopupMenuItem(
                    value: instrument,
                    child: ListTile(
                      title: Text(instrument.name),
                      subtitle: Text(instrument.description),
                      trailing: _currentInstrument?.id == instrument.id
                          ? const Icon(Icons.check, color: AppTheme.accentPink)
                          : null,
                    ),
                  );
                }).toList(),
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
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryPurple),
            SizedBox(height: 16),
            Text(
              'Loading instruments...',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.accentOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.textLight,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInstruments,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentInstrument == null) {
      return const Center(
        child: Text(
          'No instruments available',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        // Instrument Info
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: AppTheme.surfaceDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _currentInstrument!.name,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentInstrument!.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Audio initialization or instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: AppTheme.surfaceDark.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: !_isAudioInitialized && _needsUserGesture
                  ? Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.volume_off,
                              color: AppTheme.accentOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Audio needs to be initialized for web browsers.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _initializeAudio,
                          icon: const Icon(Icons.volume_up),
                          label: const Text('Enable Audio'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPink,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          _isAudioInitialized ? Icons.volume_up : Icons.info_outline,
                          color: _isAudioInitialized ? AppTheme.accentPink : AppTheme.accentTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isAudioInitialized
                                ? 'Audio ready! Tap the drum pads below to play sounds.'
                                : 'Tap the drum pads below to play sounds.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Realistic Drum Kit
        Expanded(
          flex: 4,
          child: RealisticDrumKit(
            instrument: _currentInstrument!,
            onDrumHit: _playSound,
          ),
        ),
      ],
    );
  }
}