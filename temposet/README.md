# TempoSet — Professional Metronome App

A production-ready Flutter mobile application for musicians. Features a precision metronome engine, song tempo library, setlist management, and live performance mode.

## Design
- **Dark theme** with cyan accent (`#25D1F4`) on dark blue-green (`#101F22`)
- **Space Grotesk** typography
- **4 main screens**: Metronome, Song Library, Setlists, Settings
- **Live Session mode** with tap tempo, beat visualization, and haptic feedback

## Architecture

```
lib/
├── main.dart                    # App entry point + bottom nav
├── models/
│   ├── song.dart                # Song data model
│   ├── setlist.dart             # Setlist + SetlistItem models
│   └── time_signature.dart      # Time signature model
├── services/
│   ├── audio_service.dart       # WAV generation + playback
│   ├── metronome_engine.dart    # Drift-compensated metronome
│   └── storage_service.dart     # SQLite CRUD + seed data
├── providers/
│   ├── song_provider.dart       # Song state management
│   ├── setlist_provider.dart    # Setlist state management
│   └── settings_provider.dart   # Settings persistence
├── screens/
│   ├── metronome_screen.dart    # Standalone metronome
│   ├── songs_screen.dart        # Song library with search/sort
│   ├── setlists_screen.dart     # Setlist management
│   ├── settings_screen.dart     # App settings
│   └── live_session_screen.dart # Live performance mode
├── widgets/
│   └── common_widgets.dart      # Reusable UI components
└── theme/
    ├── app_colors.dart          # Color palette
    ├── app_typography.dart      # Typography scale
    └── app_theme.dart           # ThemeData configuration
```

## Setup

```bash
# Get dependencies
cd temposet
flutter pub get

# Run on device
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

## Key Features
- **Precision Metronome**: 20-300 BPM with drift-compensated timing
- **Tap Tempo**: Averages last 3-8 taps with 2-second timeout
- **Song Library**: CRUD with search and multi-sort (BPM, date, title, artist)
- **Setlists**: Create, reorder, swipe-to-delete
- **Live Mode**: Song carousel, beat visualization, haptic feedback
- **Offline-first**: SQLite persistence, no cloud dependencies
- **Settings**: Metronome tones, haptic toggle, screen wake lock
