# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rhythmic is a Flutter-based rhythm and music app with two main features:
1. **BPM Calculator**: Detects rhythm through tap input with real-time BPM calculation and haptic feedback
2. **Instrument Player**: Virtual drum kit with interactive pads for playing drum sounds

## Development Commands

### Core Flutter Commands
```bash
# Get dependencies
flutter pub get

# Run the app (development)
flutter run

# Run tests
flutter test

# Build for web (with GitHub Pages support)
flutter build web --base-href /rhythmic/

# Analyze code
flutter analyze
```

### Deployment
- **Main branch**: Automatically deploys to GitHub Pages via `.github/workflows/deploy.yml`
- **Dev branch**: Development/staging branch
- Uses Flutter 3.32.8 in CI/CD

## Architecture

### App Structure
```
lib/
├── main.dart                      # App entry point, sets portrait orientation
├── theme.dart                     # Centralized theme with dark Material Design 3
├── models/
│   ├── bpm_calculator.dart        # Core BPM calculation logic with timer management
│   └── drum_pad.dart              # Data models for drum instruments and pads
├── screens/
│   ├── splash_screen.dart         # Animated splash with gradient background
│   ├── home_screen.dart           # Main BPM measurement interface
│   └── instrument_player_screen.dart # Virtual drum kit interface
└── widgets/
    ├── tap_circle.dart            # Interactive tap circle with animations
    └── drum_pad_widget.dart       # Individual drum pad with visual feedback
```

### Key Components

**BPMCalculator (`lib/models/bpm_calculator.dart`)**
- 10-second recording sessions with real-time BPM updates
- Uses callback functions for UI updates: `onBPMUpdate` and `onRecordingComplete`
- Dual calculation methods: real-time (time span based) and final (average interval based)
- Filters unrealistic intervals (>3 seconds) in final calculation

**Theme System (`lib/theme.dart`)**
- Material Design 3 dark theme with custom color palette
- Primary: Purple (#6366F1), Secondary: Pink (#EC4899), Tertiary: Teal (#14B8A6)
- Consistent typography and component theming

**Home Screen (`lib/screens/home_screen.dart`)**
- Dual input methods: tap circle and spacebar key
- Real-time BPM display with animation controllers for ripple and pulse effects
- Haptic feedback via `vibration` package
- State management for recording status, BPM, and tap count
- Navigation to Instrument Player via top-right menu button

**Instrument Player Screen (`lib/screens/instrument_player_screen.dart`)**
- Loads drum kit configurations from JSON files in assets
- Realistic drum kit layout with authentic drum shapes
- Visual feedback system with audio playback support
- Multiple instrument support with popup menu selection
- Custom drumstick cursor for enhanced user experience
- Web audio initialization with user gesture handling

**Drum Kit System (`assets/instruments/drums/`)**
- JSON-based instrument definitions with pad configurations
- SFZ file format support for future audio expansion
- Color-coded pads with MIDI note mappings
- Extensible architecture for adding new instruments

**Realistic Drum Kit UI (`lib/widgets/realistic_drum_kit.dart`)**
- Authentic drum kit layout mimicking real drum set arrangement
- Custom SVG-based drum shapes for each instrument type
- Animated visual feedback on drum hits
- Proper spatial arrangement (cymbals on top, kick/snare on bottom)
- Hit animations and press effects

**SVG Drum Shapes (`lib/widgets/svg_drum_shapes.dart`)**
- Custom painted drum components using Flutter CustomPainter
- Kick drum: Large bass drum with gradient shading
- Snare drum: Medium drum with snare wire details
- Hi-hats: Closed and open cymbal variations
- Toms: High and low tom drums with proper proportions
- Cymbals: Crash and ride cymbals with metallic appearance
- Drumsticks: Detailed wooden drumstick graphics

### Dependencies
- **vibration**: Haptic feedback on taps
- **flutter_native_splash**: Splash screen configuration
- **flutter_lints**: Dart/Flutter code analysis rules
- **just_audio**: Audio playback for drum sounds (configured for future implementation)

## Design Patterns

- **State Management**: StatefulWidget with callback pattern for BPM calculator communication
- **Animation**: Multiple AnimationControllers for ripple effects, pulsing, and transitions
- **Responsive Design**: Uses Expanded widgets with flex ratios for consistent layouts across devices
- **Theme Consistency**: All colors and styles centralized in `AppTheme` class

## Testing

- Basic widget test setup in `test/widget_test.dart` (currently uses default template)
- Use `flutter test` to run tests

## Platform Support

- **Primary**: Web (deployed to GitHub Pages)
- **Configured**: Android, iOS, Linux, macOS, Windows
- **Orientation**: Portrait only (enforced in `main.dart`)

## Key Implementation Details

- App uses `KeyboardListener` for spacebar input detection
- Timer-based recording with millisecond precision for BPM calculation
- Gradient backgrounds and shadows for visual depth
- Material Design 3 components with custom styling
- add current state