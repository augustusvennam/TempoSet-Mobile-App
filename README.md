# TempoSet 🎵

A professional-grade metronome and setlist management app for musicians, built with Flutter.

---

## Overview

TempoSet is designed for live performers who need a reliable, low-latency metronome alongside a full song library and setlist management system. Whether you're rehearsing or on stage, TempoSet keeps your tempo locked in and your setlist organized.

---

## Features

### 🥁 Metronome
- **BPM range:** 20–300 with 0.1 precision
- **Multiple time signatures** (4/4, 3/4, 6/8, 5/4, and more)
- **Beat subdivisions:** Quarter, eighth, triplet, and sixteenth notes (♩ ♫ ³♪ ♬)
- **Accent on beat 1** — distinct click for the downbeat
- **Tap Tempo** — tap to derive your BPM from feel
- **Audio toggle** — mute/unmute without stopping the metronome
- **Visual beat indicator** — flashing beat dots synced to the engine

### 🎵 Song Library
- Store songs with:
  - Title, artist, genre
  - BPM, time signature, subdivision
  - Accent preference and personal notes
- Full CRUD (create, read, update, delete)
- Persistent storage using SQLite (`sqflite`)

### 📋 Setlists
- Create named setlists with icons
- Add/reorder songs within a setlist
- Per-song BPM override within a setlist
- Estimated duration per setlist (based on song count)

### 🎤 Live Session Mode
- Dedicated full-screen mode for live performance
- Horizontal song carousel with **ACTIVE / NEXT** indicators
- Auto-loads each song's BPM, time signature, subdivision, and accent settings
- Quick BPM ±1 nudge buttons
- Live tap tempo
- Audio and Accent toggles
- Screen stays awake during sessions (`wakelock_plus`)

### ⚙️ Settings
- App-wide preferences managed via `SettingsProvider`
- Stored persistently with `shared_preferences`

---

## Architecture

```
lib/
├── main.dart                  # App entry, providers, nav
├── models/
│   ├── song.dart              # Song data model (BPM, time sig, subdivision)
│   ├── setlist.dart           # Setlist + SetlistItem models
│   └── time_signature.dart    # Time signature value object
├── providers/
│   ├── song_provider.dart     # Song state management
│   ├── setlist_provider.dart  # Setlist state management
│   └── settings_provider.dart # App settings state
├── services/
│   ├── metronome_engine.dart  # Core timing engine (Timer.periodic)
│   ├── audio_service.dart     # WAV generation + SoLoud playback
│   └── storage_service.dart   # SQLite persistence layer
├── screens/
│   ├── metronome_screen.dart  # Main metronome UI
│   ├── songs_screen.dart      # Song library
│   ├── setlists_screen.dart   # Setlist list
│   ├── setlist_detail_screen.dart  # Setlist editor
│   ├── live_session_screen.dart    # Live performance mode
│   └── settings_screen.dart   # App settings
├── theme/
│   ├── app_colors.dart        # Color tokens (dark theme)
│   ├── app_theme.dart         # MaterialTheme config
│   └── app_typography.dart    # Text styles (Space Grotesk)
└── widgets/
    └── common_widgets.dart    # Shared UI components (BeatVisualizer, etc.)
```

---

## Tech Stack

| Layer | Package |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.1) |
| Audio Engine | `flutter_soloud ^4.0.4` |
| Database | `sqflite ^2.4.1` |
| State Management | `provider ^6.1.2` |
| Preferences | `shared_preferences ^2.3.4` |
| Screen Lock | `wakelock_plus ^1.2.10` |
| Font | Space Grotesk (Variable) |

---

## Audio Engine

TempoSet generates its own click sounds in-memory — no asset files required. The `AudioService` synthesizes a **sine wave with exponential decay** at runtime, writes it as a 16-bit WAV to the device's temp directory, and pre-loads it into SoLoud for ultra-low-latency playback.

- **Click tone:** 800 Hz, 30ms, amplitude 0.9
- **Accent tone:** 1200 Hz, 40ms, amplitude 1.0

The `MetronomeEngine` uses `Timer.periodic` to schedule beats, with audio triggered before UI updates to minimize perceptual latency.

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.11.1
- Android SDK (for Android builds)

### Run

```bash
cd temposet
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## Platform Support

| Platform | Status |
|---|---|
| Android | ✅ Supported |
| iOS | 🔧 In progress |
| Web | ❌ Not supported (audio engine is native) |

---

## License

This project is currently private and unlicensed. All rights reserved.
