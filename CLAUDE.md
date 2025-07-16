# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
```bash
flutter pub get                        # Install dependencies
flutter run -d chrome                  # Run in Chrome browser
flutter run                           # Run on connected device/emulator
flutter build web --release           # Build for production web deployment
flutter analyze                       # Run static analysis
flutter test                          # Run all tests
flutter pub run build_runner build    # Generate Riverpod code
```

### Deployment
- **Netlify**: Already configured via `netlify.toml` with Flutter 3.19.0
- **Push to deploy**: `git push origin main` triggers Netlify deployment

## Architecture

This Flutter app follows a **feature-based architecture** with Riverpod for state management:

### State Management Pattern
- **Riverpod providers** in `lib/shared/providers/`
- Each provider manages a specific domain (scoring, timer, achievements, leaderboard)
- State classes use immutable patterns with `copyWith` methods
- Providers are accessed via `ref.watch()` in widgets

### Feature Structure
Each feature in `lib/features/` contains:
- `screens/` - Full page widgets
- `widgets/` - Reusable components for that feature

### Key Architectural Decisions

1. **Glassmorphism Design System**
   - All UI uses glass effects via `GlassContainer` widget
   - Animated gradient backgrounds throughout
   - Consistent blur and opacity values defined in theme

2. **Game Logic Flow**
   - Difficulty selection → Game screen → Score calculation → Achievement check
   - Timer runs during gameplay and affects scoring
   - Achievements unlock in real-time using overlay notifications

3. **Data Persistence**
   - Local storage via SharedPreferences for simple data
   - Hive for complex data structures
   - Firebase integration ready but implementation incomplete

4. **Scoring System**
   - Base points × difficulty multiplier × time bonus × streak multiplier
   - Daily limit of 15 games enforced in `ScoringProvider`
   - Perfect game bonus for no wrong guesses

### Important Implementation Details

- **Word Lists**: Categorized by difficulty in `lib/core/constants/word_list.dart`
- **Sarcastic Messages**: Pre-defined responses in `sarcastic_messages.dart`
- **Hangman Drawing**: Custom painted widget with 8 progressive stages
- **Achievement System**: 15+ achievements tracked across gameplay sessions
- **Leaderboard**: Mock data currently, Firebase integration prepared

### Known Issues
- `withOpacity` deprecation warnings (use `withValues()` instead)
- Test file references non-existent `MyApp` class
- Trackpad gesture issues on Flutter web (known Flutter issue)

### Development Tips
- When modifying game mechanics, update both the game screen and scoring provider
- Achievement unlocks should show the overlay animation
- Maintain consistent glass effect parameters across new widgets
- Use existing animation patterns (Flutter Animate) for new features