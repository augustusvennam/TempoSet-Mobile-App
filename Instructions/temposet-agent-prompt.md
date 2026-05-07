# TempoSet Mobile App - Full Development Prompt for AI Agent

## Mission
Build a **production-ready Flutter mobile application** for TempoSet, a professional metronome app with song tempo storage and setlist management. Use the provided Stitch wireframes as the design foundation, implement all core features, and generate a testable APK for Android deployment.

---

## Project Context

### What You Have
1. **Stitch Wireframes** (4 complete screens exported)
   - Setlists screen
   - Song Library screen
   - Settings screen
   - Live Session screen (setlist playback mode)
   - **Design System**: Dark theme (#101f22 background), Space Grotesk font, cyan accent (#25d1f4)

2. **Product Specification Document**
   - Complete feature requirements
   - Data models for Song, Setlist, TimeSignature
   - Audio engine specifications (20-300 BPM precision)
   - User interaction flows

### What You Need to Build
A **fully functional Flutter mobile app** that:
- **Pixel-perfectly matches** the Stitch wireframe designs
- Implements a precision metronome engine (20-300 BPM, sample-accurate)
- Manages song library and setlists with SQLite local persistence
- Works completely offline (no cloud dependencies)
- Generates a production-ready APK for Android testing
- Includes live performance mode with tap tempo and beat visualization

---

## Stitch Export Files Reference

The uploaded `stitch_temposet.zip` contains the following wireframe screens:

```
stitch_temposet/
├── setlists/
│   ├── screen.png          ← Setlists management screen
│   └── code.html           ← Design system specs (colors, fonts)
├── song_library/
│   └── screen.png          ← Song library with search/filters
├── settings/
│   └── screen.png          ← App settings and preferences
└── live_setlist/
    └── screen.png          ← Live performance mode
```

**Design System Extracted from `code.html`:**
- **Primary Color**: `#25d1f4` (cyan/turquoise)
- **Background**: `#101f22` (dark blue-green)
- **Font**: Space Grotesk (sans-serif)
- **Framework**: Tailwind CSS classes used in original
- **Icons**: Material Symbols Outlined

**Before starting development**, extract and view all `screen.png` files to understand:
- Exact layout proportions
- Spacing between elements
- Icon styles and sizes
- Card designs and shadows
- Typography hierarchy
- Interactive states

---

## Development Workflow

### Phase 1: Project Setup & Architecture (30 minutes)
**Tasks:**
1. Initialize a new Flutter project with proper structure:
   ```
   temposet/
   ├── lib/
   │   ├── main.dart
   │   ├── models/
   │   │   ├── song.dart
   │   │   ├── setlist.dart
   │   │   └── time_signature.dart
   │   ├── services/
   │   │   ├── metronome_engine.dart
   │   │   ├── audio_service.dart
   │   │   └── storage_service.dart
   │   ├── screens/
   │   │   ├── metronome_screen.dart
   │   │   ├── songs_screen.dart
   │   │   ├── setlists_screen.dart
   │   │   └── settings_screen.dart
   │   ├── widgets/
   │   │   ├── beat_visualizer.dart
   │   │   ├── bpm_slider.dart
   │   │   └── song_card.dart
   │   └── theme/
   │       └── app_theme.dart
   ```

2. Configure `pubspec.yaml` with required dependencies:
   - `audioplayers` or `just_audio` - for metronome click sounds
   - `sqflite` - local database for songs/setlists
   - `path_provider` - file system access
   - `provider` or `riverpod` - state management
   - `shared_preferences` - settings persistence
   - `wakelock` - keep screen awake during playback

3. Set up Android build configuration:
   - Update `android/app/build.gradle` with proper version codes
   - Configure permissions in `AndroidManifest.xml` (WAKE_LOCK, VIBRATE)
   - Set minimum SDK version to 21 (Android 5.0)

**Deliverable**: Working project scaffold that compiles without errors

---

### Phase 2: Design System Implementation (45 minutes)

**EXACT Design Specifications from Stitch:**

**Color Palette:**
```dart
class AppColors {
  // Primary Colors (from Stitch code.html)
  static const Color primary = Color(0xFF25D1F4);      // Cyan accent
  static const Color backgroundDark = Color(0xFF101F22); // Very dark blue-green
  
  // UI Colors
  static const Color surface = Color(0xFF1A2F33);       // Slightly lighter cards
  static const Color textPrimary = Color(0xFFFFFFFF);   // White text
  static const Color textSecondary = Color(0xFF94A3B8); // Gray text (slate-400)
  static const Color textTertiary = Color(0xFF64748B);  // Darker gray (slate-500)
  
  // Accent variations
  static const Color primaryMuted = Color(0x1A25D1F4);  // 10% opacity primary
  static const Color primaryGlow = Color(0x3325D1F4);   // 20% opacity for glow
}
```

**Typography (Space Grotesk):**
```dart
class AppTypography {
  static const String fontFamily = 'Space Grotesk';
  
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Special: Large BPM display
  static const TextStyle hugeBPM = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );
}
```

**Component Specifications:**

1. **Cards/Containers:**
   - Background: `#1A2F33` (slightly lighter than screen background)
   - Border radius: `12px` (rounded-xl)
   - Padding: `16px` standard, `20px` for larger cards
   - Border: `1px solid rgba(37, 209, 244, 0.1)` subtle cyan outline

2. **Buttons:**
   - Primary (Add button): Cyan `#25D1F4`, rounded-xl (12px), 48x48 size
   - Large action buttons: Rounded-xl, min-height 56px
   - Icon buttons: 48x48 circular or rounded-xl squares

3. **Search Bars:**
   - Background: `rgba(37, 209, 244, 0.05)` very subtle cyan tint
   - Border: `1px solid rgba(37, 209, 244, 0.2)`
   - Rounded: 12px
   - Height: 56px
   - Placeholder: slate-400 color

4. **Bottom Navigation:**
   - Background: `#0A1518` (darker than main background)
   - Height: 64px + safe area
   - Icons: Material Symbols Outlined
   - Active state: Cyan `#25D1F4`
   - Inactive state: `#64748B` (slate-500)

5. **Chips/Pills:**
   - Cyan filled: `#25D1F4` background, black text
   - Outlined: Border `1px solid rgba(37, 209, 244, 0.5)`, cyan text
   - Rounded: full (9999px)
   - Padding: 8px horizontal, 4px vertical

**Create `lib/theme/app_theme.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: AppTypography.fontFamily,
      
      // Card theme
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.h1.copyWith(color: AppColors.textPrimary),
      ),
      
      // Bottom nav bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0A1518),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primary.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size(0, 56),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      
      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        background: AppColors.backgroundDark,
        surface: AppColors.surface,
      ),
    );
  }
}
```

**Font Asset Setup:**
Download Space Grotesk from Google Fonts and add to `pubspec.yaml`:
```yaml
fonts:
  - family: Space Grotesk
    fonts:
      - asset: fonts/SpaceGrotesk-Regular.ttf
      - asset: fonts/SpaceGrotesk-Medium.ttf
        weight: 500
      - asset: fonts/SpaceGrotesk-SemiBold.ttf
        weight: 600
      - asset: fonts/SpaceGrotesk-Bold.ttf
        weight: 700
```

**Icons:**
Use Material Symbols Outlined (already included in Flutter), matching the Stitch designs.

**Deliverable**: Complete theme system with exact Stitch color values and styling

---

### Phase 3: Core Metronome Engine (1-2 hours)

**Critical Requirements:**
- **Sample-accurate timing** - no drift over long sessions
- BPM range: 20-300 with 0.1 precision
- Multiple time signatures (4/4, 3/4, 6/8, 5/4, 7/8, etc.)
- Accent on downbeat with configurable volume
- Subdivisions: quarter, eighth, triplets, sixteenth notes

**Implementation approach:**

1. **Create `lib/services/metronome_engine.dart`:**
   ```dart
   class MetronomeEngine {
     Timer? _timer;
     int _currentBeat = 0;
     double _bpm = 120.0;
     TimeSignature _timeSignature = TimeSignature(4, 4);
     bool _isPlaying = false;
     
     final AudioService _audioService = AudioService();
     final StreamController<int> _beatStream = StreamController.broadcast();
     
     Stream<int> get beatStream => _beatStream.stream;
     
     void start() {
       if (_isPlaying) return;
       _isPlaying = true;
       _currentBeat = 0;
       _scheduleNextBeat();
     }
     
     void _scheduleNextBeat() {
       if (!_isPlaying) return;
       
       // Play click
       if (_currentBeat == 0) {
         _audioService.playAccent();
       } else {
         _audioService.playClick();
       }
       
       // Notify listeners
       _beatStream.add(_currentBeat);
       
       // Advance beat
       _currentBeat = (_currentBeat + 1) % _timeSignature.beatsPerBar;
       
       // Schedule next beat with precise timing
       final intervalMs = (60000 / _bpm).round();
       _timer = Timer(Duration(milliseconds: intervalMs), _scheduleNextBeat);
     }
     
     void stop() {
       _isPlaying = false;
       _timer?.cancel();
       _currentBeat = 0;
     }
     
     void setBPM(double bpm) {
       _bpm = bpm;
       if (_isPlaying) {
         stop();
         start();  // Restart with new tempo
       }
     }
   }
   ```

2. **Create `lib/services/audio_service.dart`:**
   - Generate or load click sound samples (440Hz for click, 880Hz for accent)
   - Use `audioplayers` with low-latency configuration
   - Pre-load sounds to avoid delays
   - Handle audio focus and interruptions properly

**Testing checklist:**
- [ ] Metronome maintains steady tempo for 5+ minutes without drift
- [ ] Tempo changes instantly when BPM adjusted
- [ ] Accent on beat 1 is clearly audible
- [ ] No clicks or pops in audio playback
- [ ] Works when app is in background
- [ ] Survives screen rotation

**Deliverable**: Rock-solid metronome engine with accurate timing

---

### Phase 4: Data Models & Persistence (1 hour)

**Implement data models from specification:**

1. **`lib/models/song.dart`:**
   ```dart
   class Song {
     final String id;
     String title;
     String artist;
     double bpm;
     TimeSignature timeSignature;
     String? notes;
     DateTime createdAt;
     DateTime updatedAt;
     
     Song({
       String? id,
       required this.title,
       this.artist = '',
       required this.bpm,
       required this.timeSignature,
       this.notes,
       DateTime? createdAt,
       DateTime? updatedAt,
     })  : id = id ?? Uuid().v4(),
           createdAt = createdAt ?? DateTime.now(),
           updatedAt = updatedAt ?? DateTime.now();
     
     Map<String, dynamic> toJson() => { /* ... */ };
     factory Song.fromJson(Map<String, dynamic> json) => /* ... */;
   }
   ```

2. **`lib/services/storage_service.dart`:**
   - Use SQLite (`sqflite`) for structured data
   - Create tables: `songs`, `setlists`, `setlist_items`
   - Implement CRUD operations with async/await
   - Add search/filter functionality
   - Handle migrations properly

**Database schema:**
```sql
CREATE TABLE songs (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  artist TEXT,
  bpm REAL NOT NULL,
  time_sig_beats INTEGER NOT NULL,
  time_sig_unit INTEGER NOT NULL,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE setlists (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE setlist_items (
  id TEXT PRIMARY KEY,
  setlist_id TEXT NOT NULL,
  song_id TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  override_bpm REAL,
  transition_type TEXT DEFAULT 'instant',
  FOREIGN KEY (setlist_id) REFERENCES setlists(id) ON DELETE CASCADE,
  FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
);
```

**Deliverable**: Full persistence layer with database operations

---

### Phase 5: Screen Implementation (3-4 hours)

**Build each screen following Stitch wireframes EXACTLY. Reference the provided screen.png files.**

---

#### 5.1 Setlists Screen (`setlists/screen.png`)

**Layout Structure:**
```
┌─────────────────────────────────┐
│ Setlists            [+]         │ Header + Add button
│ Organize your performances      │ Subtitle
├─────────────────────────────────┤
│ 🔍 Search your setlists...      │ Search bar
├─────────────────────────────────┤
│ ┌─┐  Friday Night Gig        → │
│ │📅│  12 Songs    ⏱ 45 mins    │ Setlist card
│ └─┘                             │
├─────────────────────────────────┤
│ ┌─┐  Sunday Service          → │
│ │⛪│  5 Songs     ⏱ 25 mins    │
│ └─┘                             │
├─────────────────────────────────┤
│ ┌─┐  Studio Session A        → │
│ │📸│  8 Songs     ⏱ 60 mins    │
│ └─┘                             │
├─────────────────────────────────┤
│ ┌─┐  Acoustic Lounge         → │
│ │🍸│  15 Songs    ⏱ 90 mins    │
│ └─┘                             │
├─────────────────────────────────┤
│                                 │
│ Swipe left on a setlist to     │ Help text
│ delete or edit                  │
│                                 │
└─────────────────────────────────┘
│ 🕐    🎵    📋    ⚙️           │ Bottom nav
│ METRONOME SONGS SETLISTS SETTINGS│
└─────────────────────────────────┘
```

**Component Details:**
- **Header**: "Setlists" (28px bold), subtitle "Organize your performances" (14px, cyan/70% opacity)
- **Add button**: 48x48 cyan circle, white + icon, top-right corner
- **Search bar**: 
  - Height: 56px
  - Background: `rgba(37, 209, 244, 0.05)`
  - Border: `1px solid rgba(37, 209, 244, 0.2)`
  - Placeholder: "Search your setlists..." in gray
  - Magnifying glass icon (cyan/50%)
  
- **Setlist cards**: Each card contains:
  - Left: 56x56 rounded square icon with themed symbol (calendar, church, camera, cocktail)
  - Icon background: `#1E3E43` (dark teal)
  - Icon color: Cyan `#25D1F4`
  - Title: White, 18px bold
  - Metadata row:
    - Song count: Cyan pill badge "X Songs"
    - Duration: Gray text with clock icon "Y mins"
  - Right: Chevron arrow (gray)
  - Card background: `#1A2F33`
  - Border: `1px solid rgba(37, 209, 244, 0.1)`
  - Padding: 16px
  - Margin: 12px horizontal, 8px vertical
  
- **Help text**: Bottom of list, gray, 14px, centered
- **Swipe actions**: Left swipe reveals Edit (blue) and Delete (red) buttons

**Bottom Navigation:**
- 4 tabs: Metronome (timer icon), Songs (music note), Setlists (list icon - ACTIVE), Settings (gear)
- Active tab: Cyan `#25D1F4` with dot indicator
- Inactive tabs: Gray `#64748B`
- Background: `#0A1518` (darker than screen)

**Implementation Code Skeleton:**
```dart
class SetlistsScreen extends StatefulWidget {
  @override
  _SetlistsScreenState createState() => _SetlistsScreenState();
}

class _SetlistsScreenState extends State<SetlistsScreen> {
  List<Setlist> setlists = [];
  TextEditingController searchController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Search bar
            _buildSearchBar(),
            // Setlist list
            Expanded(
              child: _buildSetlistList(),
            ),
            // Help text
            _buildHelpText(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24).copyWith(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Setlists', style: AppTypography.h1),
              SizedBox(height: 4),
              Text(
                'Organize your performances',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          _buildAddButton(),
        ],
      ),
    );
  }
  
  Widget _buildAddButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.add, color: AppColors.backgroundDark, size: 24),
    );
  }
  
  Widget _buildSetlistCard(Setlist setlist) {
    return Dismissible(
      key: Key(setlist.id),
      background: Container(/* Edit background */),
      secondaryBackground: Container(/* Delete background */),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Color(0xFF1E3E43),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForSetlist(setlist),
                color: AppColors.primary,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(setlist.name, style: AppTypography.h2),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPill('${setlist.songs.length} Songs'),
                      SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        '${setlist.totalDuration} mins',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.backgroundDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

---

#### 5.2 Song Library Screen (`song_library/screen.png`)

**Layout Structure:**
```
┌─────────────────────────────────┐
│ Song Library                [+] │ Header + Add button
├─────────────────────────────────┤
│ 🔍 Search title, artist or genre│ Search bar
├─────────────────────────────────┤
│ [BPM: High-Low ▾]  [Recently...] │ Filter chips
├─────────────────────────────────┤
│ ♪  Starlight              122   │
│    Muse                   BPM   │ Song card
│    Alternative Rock              │
├─────────────────────────────────┤
│ ♪  Midnight City          105   │
│    M83                    BPM   │
│    Synth-pop                     │
├─────────────────────────────────┤
│ ♪  Blinding Lights        171   │
│    The Weeknd             BPM   │
│    80s Pop                       │
└─────────────────────────────────┘
```

**Component Details:**
- **Header**: "Song Library" (28px bold), Add button (48x48 cyan circle)
- **Search bar**: Same style as Setlists, placeholder: "Search title, artist or genre..."
- **Filter chips** (horizontal scroll):
  - Active chip: Cyan filled background, black text
  - Inactive chips: Outlined (cyan border), cyan text
  - Options shown: "BPM: High-Low", "Recently Added", "Title A-Z"
  - Dropdown chevron on filter chips
  
- **Song cards**: Each contains:
  - Left: 56x56 music note icon (cyan on dark teal background)
  - Title: White, 18px bold
  - Artist: Gray, 15px
  - Genre: Cyan, 14px
  - Right: Large BPM number (cyan, 32px bold) with "BPM" label below in gray
  - Card styling: Same as setlist cards

**Example songs from wireframe:**
1. Starlight - Muse (Alternative Rock) - 122 BPM
2. Midnight City - M83 (Synth-pop) - 105 BPM
3. Blinding Lights - The Weeknd (80s Pop) - 171 BPM
4. Seven Nation Army - The White Stripes (Garage Rock) - 124 BPM
5. Clocks - Coldplay (Piano Rock) - 131 BPM
6. R U Mine? - Arctic Monkeys (Indie Rock) - 97 BPM

**Filter functionality:**
- BPM sorting: High-Low, Low-High
- Date sorting: Recently Added, Oldest First
- Alphabetical: Title A-Z, Artist A-Z
- Genre filtering (optional)

---

#### 5.3 Settings Screen (`settings/screen.png`)

**Layout Structure:**
```
┌─────────────────────────────────┐
│ ← Settings              Save    │ Header with back + save
├─────────────────────────────────┤
│ METRONOME TONES                 │ Section header
│                                 │
│ ● Classic Woodblock       ●     │ Radio option (selected)
│   Traditional acoustic feel     │
│                                 │
│ ○ Digital Beep            ○     │ Radio option
│   Clean electronic pulse        │
│                                 │
│ ○ Drum Rimshot            ○     │
│   Snare drum accent             │
│                                 │
│ ○ High-Pitch Synth        ○     │
│   Piercing lead sound           │
│                                 │
│ ○ Cowbell                 ○     │
│   More cowbell!                 │
├─────────────────────────────────┤
│ DEVICE BEHAVIOR                 │
│                                 │
│ 📳 Haptic Feedback       [✓]    │ Toggle ON
│    Vibrate on every beat        │
│                                 │
│ ▶️ Background Play       [✓]    │ Toggle ON
│    Keep tempo when app closed   │
│                                 │
│ 💡 Screen Always On      [ ]    │ Toggle OFF
│    Prevent device from sleeping │
├─────────────────────────────────┤
│ ABOUT                           │
│                                 │
│ Version            2.4.0 (Pro)  │ Read-only field
│ Support                      ↗  │ Link (external icon)
└─────────────────────────────────┘
```

**Component Details:**
- **Header**: Back arrow, "Settings" title, "Save" button (cyan)
- **Section headers**: Cyan, 12px, uppercase, bold, letter-spacing: 1.5px

**Metronome Tones** (radio group):
- 5 options, each with:
  - Radio button (cyan when selected)
  - Title (white, 16px)
  - Subtitle (gray, 14px)
  - Card background when selected: subtle cyan tint
  
**Device Behavior** (toggles):
- Each row:
  - Icon (left, 24x24)
  - Title (white, 16px)
  - Description (gray, 14px below title)
  - Toggle switch (right, cyan when ON)

**About section**:
- Simple two-column layout
- Label: Description pairs
- External link icon for Support

**Implementation considerations:**
- Save button should enable only when changes made
- Play sound preview when selecting metronome tone
- Persist settings to SharedPreferences

---

#### 5.4 Live Session Screen (`live_setlist/screen.png`)

**Layout Structure:**
```
┌─────────────────────────────────┐
│ ←  LIVE SESSION            ⋮    │ Header
│    Summer Tour 2024             │ Subtitle
├─────────────────────────────────┤
│ UPCOMING SONGS          3 / 12  │
│ ┌────────┐ ┌────────┐           │
│ │   ♪    │ │   ♪    │           │ Horizontal scroll
│ │Midnight│ │Wait for│           │
│ │  City  │ │the Mom │           │
│ │ ACTIVE │ │  NEXT  │           │
│ └────────┘ └────────┘           │
├─────────────────────────────────┤
│           TEMPO                 │
│                                 │
│           124                   │ Huge BPM display
│           BPM                   │
│                                 │
│     ████ ▁▁▁ ▁▁▁ ▁▁▁          │ Beat indicators
│                                 │
│  [−]      [⏸]      [+]         │ Tempo controls
│                                 │
│  ┌─────────────────────┐       │
│  │  👆 TAP TEMPO       │       │ Large tap button
│  └─────────────────────┘       │
│                                 │
│  [🔊]   [📳]   [📸]            │ Feature toggles
│  AUDIO  HAPTIC  FLASH           │
└─────────────────────────────────┘
│ 📋      ▶️      📚      ⚙️     │ Bottom nav
│Setlists  Live  Library Settings │
└─────────────────────────────────┘
```

**Component Details:**

**Header:**
- Back button, "LIVE SESSION" (cyan, uppercase), 3-dot menu
- Subtitle: Setlist name in gray

**Upcoming Songs carousel:**
- Horizontal scrollable cards
- Active song: Cyan background, black text, "ACTIVE" label
- Next song: Dark background, gray text, "NEXT" label
- Song counter: "3 / 12" (current / total)

**Tempo display:**
- "TEMPO" label (gray, uppercase)
- BPM number: 96px font, white, bold
- "BPM" label below in gray

**Beat indicators:**
- 4 rectangular bars (one per beat in 4/4 time)
- Current beat: Cyan, animated
- Other beats: Dark gray outline
- Width: Full screen minus padding
- Height: 8px

**Tempo controls:**
- Three circular buttons in a row:
  - Minus button: 64x64, dark background, minus icon
  - Pause/Play button: 96x96, cyan background with glow, pause icon
  - Plus button: 64x64, dark background, plus icon
- Pause button has cyan glow shadow

**Tap Tempo button:**
- Full width, 72px height
- White background
- Black text: "TAP TEMPO"
- Tap hand icon
- Rounded corners: 12px

**Feature toggle row:**
- Three square buttons (64x64 each)
- AUDIO (speaker icon): Inactive (dark)
- HAPTIC (vibration icon): Active (cyan background)
- FLASH (flashlight icon): Inactive (dark)
- Labels below each in uppercase

**Bottom Navigation:**
- Different from other screens: Setlists, Live (ACTIVE), Library, Settings
- "Live" tab active (cyan)

**Special behaviors:**
- Screen wake lock (prevent sleep)
- Visual metronome (beat bars animate)
- Haptic feedback on each beat
- Flash uses camera flash in sync with beats
- Swipe cards to skip songs
- Tap tempo averages last 4-8 taps

---

**Implementation Priority:**
1. Setlists screen (simpler, establishes pattern)
2. Song Library screen (CRUD operations)
3. Live Session screen (complex, metronome integration)
4. Settings screen (preferences, simple UI)

**Deliverable**: All 4 screens pixel-perfect, fully functional, matching Stitch designs

---

### Phase 6: Advanced Features (2 hours)

#### 6.1 Tap Tempo Algorithm
```dart
class TapTempoDetector {
  final List<DateTime> _tapTimes = [];
  final int _maxTaps = 8;
  final Duration _resetDuration = Duration(seconds: 2);
  
  double? onTap() {
    final now = DateTime.now();
    
    // Reset if too much time passed
    if (_tapTimes.isNotEmpty && 
        now.difference(_tapTimes.last) > _resetDuration) {
      _tapTimes.clear();
    }
    
    _tapTimes.add(now);
    if (_tapTimes.length > _maxTaps) {
      _tapTimes.removeAt(0);
    }
    
    // Need at least 2 taps
    if (_tapTimes.length < 2) return null;
    
    // Calculate average interval
    double totalMs = 0;
    for (int i = 1; i < _tapTimes.length; i++) {
      totalMs += _tapTimes[i].difference(_tapTimes[i-1]).inMilliseconds;
    }
    double avgMs = totalMs / (_tapTimes.length - 1);
    
    return 60000 / avgMs; // Convert to BPM
  }
}
```

#### 6.2 Setlist Playback (Live Mode)
**Create dedicated screen for live performance:**
- Full-screen current song display
- Large "Next" button to advance
- Auto-load next song tempo
- Optional: smooth tempo ramp (transition over X seconds)
- Prevent screen sleep

#### 6.3 Visual Beat Indicators
**Options:**
- Bouncing ball animation
- Pulsing circles (one per beat in measure)
- Progress bar that sweeps across measure
- Pendulum-style metronome swing

Use `AnimationController` for smooth 60fps animations.

**Deliverable**: Polished UX with all advanced features

---

### Phase 7: Testing & Quality Assurance (1 hour)

**Functional Tests:**
- [ ] Metronome plays at correct tempo across BPM range
- [ ] Accent clearly distinguishable on beat 1
- [ ] Songs save and load correctly
- [ ] Setlists can be created, edited, deleted
- [ ] Search filters songs properly
- [ ] App survives background/foreground transitions
- [ ] No crashes when rotating device
- [ ] Audio continues when screen locks

**Performance Tests:**
- [ ] App launches in <2 seconds
- [ ] Smooth 60fps animations
- [ ] No lag when adjusting BPM slider
- [ ] Database queries complete in <50ms

**Edge Cases:**
- [ ] Empty song library (show helpful empty state)
- [ ] Very long song/setlist names (truncate gracefully)
- [ ] Deleting song that's in a setlist (handle cascade)
- [ ] Playing setlist with 0 songs (show error)

**Deliverable**: Bug-free, production-ready app

---

### Phase 8: APK Generation & Deployment (30 minutes)

**Build signed APK for testing:**

1. **Update version in `pubspec.yaml`:**
   ```yaml
   version: 1.0.0+1
   ```

2. **Configure signing (for testing, use debug key):**
   ```bash
   # Generate debug APK (quick for testing)
   flutter build apk --debug
   
   # For release APK (requires keystore setup):
   # Create keystore first:
   keytool -genkey -v -keystore ~/temposet-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias temposet
   
   # Add to android/key.properties:
   storePassword=<password>
   keyPassword=<password>
   keyAlias=temposet
   storeFile=~/temposet-key.jks
   
   # Build release APK:
   flutter build apk --release
   ```

3. **Output location:**
   - Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
   - Release APK: `build/app/outputs/flutter-apk/app-release.apk`

4. **Generate APK with all architectures:**
   ```bash
   # Split APKs by architecture (smaller file size):
   flutter build apk --split-per-abi
   
   # This creates:
   # - app-armeabi-v7a-release.apk (32-bit ARM)
   # - app-arm64-v8a-release.apk (64-bit ARM)
   # - app-x86_64-release.apk (x86)
   ```

5. **Transfer to phone for testing:**
   ```bash
   # Via ADB:
   adb install build/app/outputs/flutter-apk/app-debug.apk
   
   # Or upload to file sharing service for manual install
   ```

**Deliverable**: Installable APK file ready for device testing

---

## Success Criteria

The completed app must:

✅ **Match Stitch designs** - pixel-perfect implementation of all 4 screens:
   - Setlists screen with search, cards, swipe actions
   - Song Library with filters, search, BPM sorting
   - Settings with tone selection and device behavior toggles
   - Live Session with tap tempo, beat visualization, song carousel

✅ **Accurate metronome** - maintains tempo without drift, 20-300 BPM range

✅ **Full CRUD** - create, read, update, delete songs and setlists

✅ **Offline-first** - works completely without internet, SQLite persistence

✅ **Smooth performance** - 60fps animations, instant UI responses, <2s startup

✅ **Live performance ready**:
   - Tap tempo functionality
   - Visual beat indicators (animated bars)
   - Screen wake lock during playback
   - Optional haptic feedback
   - Auto-advance through setlist songs

✅ **Production quality** - no crashes, handles edge cases gracefully

✅ **Installable APK** - successfully installs and runs on Android device (API 21+)

---

## Technical Constraints

**Must use:**
- Flutter SDK (stable channel, latest version)
- Dart 3.0+
- Material Design 3 components
- SQLite for persistence
- Native audio libraries for click sounds

**Must NOT use:**
- Web APIs or JavaScript
- Cloud services (app is 100% local)
- Deprecated Flutter packages

---

## Delivery Format

Provide the complete project as:

1. **Source code** - full Flutter project directory
2. **APK file** - ready to install on Android
3. **README.md** - with:
   - Setup instructions
   - Build commands
   - Architecture overview
   - Known limitations (if any)
4. **Build instructions** - step-by-step guide to regenerate APK

---

## Development Timeline Estimate

| Phase | Duration | Priority |
|-------|----------|----------|
| Setup & Architecture | 30 min | Critical |
| Design System | 45 min | Critical |
| Metronome Engine | 1-2 hrs | Critical |
| Data & Persistence | 1 hr | Critical |
| Screen Implementation | 3-4 hrs | Critical |
| Advanced Features | 2 hrs | High |
| Testing | 1 hr | High |
| APK Generation | 30 min | Critical |
| **TOTAL** | **9-11 hours** | - |

---

## Additional Context for Agent

**You are building this app for a musician** who needs:
- Reliable tempo during live performances
- Quick access to song tempos without fumbling
- Setlists that flow smoothly from song to song
- No internet dependency (venues often have poor signal)

**Think like a live performer:**
- Large, tappable buttons (easy to hit on stage)
- High contrast UI (readable in dim lighting)
- Minimal taps to accomplish tasks
- No accidental tempo changes (confirmation prompts where needed)

**Code quality standards:**
- Write clean, commented Dart code
- Use meaningful variable names
- Follow Flutter best practices
- Handle errors gracefully (try/catch, null safety)
- No hardcoded strings (use constants)
- Implement proper state management

---

## Reference Materials

1. **Stitch Project**: Project ID `6991330965710215654` (18 screens)
2. **Product Spec**: [See attached full specification document]
3. **Flutter Docs**: https://docs.flutter.dev
4. **Metronome Timing**: https://web.dev/audio-scheduling/

---

## Questions to Resolve During Development

If you encounter ambiguity, make sensible decisions guided by:

1. **Design ambiguity?** → Refer to Stitch wireframes as source of truth
2. **Feature ambiguity?** → Refer to product spec document
3. **Technical choice?** → Choose the most maintainable, performant option
4. **Edge case?** → Handle gracefully with user-friendly error messages

---

## Final Checklist Before Delivery

- [ ] All 18 Stitch screens implemented
- [ ] Metronome tested across full BPM range
- [ ] Songs CRUD fully functional
- [ ] Setlists CRUD fully functional
- [ ] App tested on physical Android device
- [ ] No console errors or warnings
- [ ] APK installs successfully
- [ ] App survives kill/restart (state persists)
- [ ] README.md includes all setup instructions
- [ ] Code is commented and clean

---

## Start Development Now

Begin with Phase 1 (Project Setup) and work through each phase sequentially. Focus on getting a working metronome first, then layer on songs, setlists, and polish.

**Remember**: This app will be used on stage during live performances. Reliability and simplicity are more important than fancy features.

🚀 **Let's build TempoSet!**

---

## Appendix A: Visual Design Reference

### Color Palette Quick Reference
```css
/* Primary */
--primary: #25D1F4          /* Cyan - buttons, accents, active states */
--primary-muted: #25D1F41A  /* 10% opacity - subtle backgrounds */
--primary-glow: #25D1F433   /* 20% opacity - button glows */

/* Backgrounds */
--bg-dark: #101F22          /* Main screen background */
--bg-surface: #1A2F33       /* Cards, elevated surfaces */
--bg-nav: #0A1518           /* Bottom navigation bar */
--icon-bg: #1E3E43          /* Icon container backgrounds */

/* Text */
--text-primary: #FFFFFF     /* Headings, primary content */
--text-secondary: #94A3B8   /* Subtext, descriptions (slate-400) */
--text-tertiary: #64748B    /* Inactive states (slate-500) */
```

### Component Spacing
- **XS**: 4px - tight spacing
- **S**: 8px - chip padding, small gaps
- **M**: 12px - card margins, standard gaps
- **L**: 16px - card padding, section spacing
- **XL**: 24px - screen margins, header padding

### Border Radius
- **Standard**: 12px - cards, buttons, inputs
- **Pills**: 9999px - badges, chips
- **Small**: 8px - small buttons

### Typography Scale (Space Grotesk)
- **H1**: 28px, Bold, -0.5 letter-spacing
- **H2**: 20px, Semi-bold
- **H3**: 18px, Semi-bold
- **Body**: 16px, Regular
- **Caption**: 14px, Regular
- **Small**: 12px, Semi-bold (section headers, UPPERCASE)
- **Huge BPM**: 96px, Bold (Live Session)

### Shadows & Glows
```dart
// Cyan button glow
BoxShadow(
  color: AppColors.primary.withOpacity(0.2),
  blurRadius: 12,
  offset: Offset(0, 4),
)

// Pause button glow (Live Session)
BoxShadow(
  color: AppColors.primary.withOpacity(0.4),
  blurRadius: 24,
  offset: Offset(0, 0),
)
```

---

## Appendix B: Screen-Specific Notes

### Setlists Screen
- **Icon variety**: Each setlist can have a different icon (calendar, church, camera, cocktail, etc.)
- **Icon implementation**: Use Material Icons or create custom icon mapping
- **Duration calculation**: Sum of all song durations in setlist
- **Swipe threshold**: Swipe left >30% of card width to trigger actions
- **Empty state**: Show "No setlists yet" with create button when list is empty

### Song Library Screen  
- **Filter chips**: Single-select for sort order (BPM, Date, Title), multi-select for genres
- **BPM display**: Right-aligned, large (32px), cyan color, with small "BPM" label below
- **Genre colors**: All genres use same cyan color for consistency
- **Load behavior**: Tap song → navigate to Live Session with that song loaded
- **Empty state**: Show "Add your first song" message

### Settings Screen
- **Sound preview**: When selecting a metronome tone, play a 4-beat sample
- **Toggle animations**: Smooth slide animation, 200ms duration
- **Save button**: Only enable when settings have changed (dirty state tracking)
- **Version display**: Right-aligned, gray text
- **Support link**: Opens default browser or email client

### Live Session Screen
- **Song cards**: 
  - Width: 200px each
  - Gap: 16px between cards
  - Snap scrolling: Cards snap to position
  - Auto-scroll: Active song always centered
  
- **Beat indicators**:
  - Count matches time signature (4 for 4/4, 3 for 3/4, etc.)
  - Animate: Scale up 20%, glow effect on beat
  - Duration: 100ms animation
  
- **Tap tempo**:
  - Visual feedback: Flash cyan on tap
  - Algorithm: Average of last 4-8 taps
  - Timeout: Reset after 2 seconds of no taps
  - Minimum taps: Require 3 taps before calculating BPM
  
- **Feature toggles**:
  - **AUDIO**: Mute/unmute click sounds
  - **HAPTIC**: Enable/disable vibration on beats
  - **FLASH**: Use camera flash as visual metronome (sync with beats)

---

## Appendix C: Example Data for Testing

### Sample Songs (include in initial database):
```dart
final sampleSongs = [
  Song(
    title: 'Starlight',
    artist: 'Muse',
    genre: 'Alternative Rock',
    bpm: 122,
    timeSignature: TimeSignature(4, 4),
  ),
  Song(
    title: 'Midnight City',
    artist: 'M83',
    genre: 'Synth-pop',
    bpm: 105,
    timeSignature: TimeSignature(4, 4),
  ),
  Song(
    title: 'Blinding Lights',
    artist: 'The Weeknd',
    genre: '80s Pop',
    bpm: 171,
    timeSignature: TimeSignature(4, 4),
  ),
  Song(
    title: 'Seven Nation Army',
    artist: 'The White Stripes',
    genre: 'Garage Rock',
    bpm: 124,
    timeSignature: TimeSignature(4, 4),
  ),
  Song(
    title: 'Clocks',
    artist: 'Coldplay',
    genre: 'Piano Rock',
    bpm: 131,
    timeSignature: TimeSignature(4, 4),
  ),
  Song(
    title: 'R U Mine?',
    artist: 'Arctic Monkeys',
    genre: 'Indie Rock',
    bpm: 97,
    timeSignature: TimeSignature(4, 4),
  ),
  Song(
    title: 'Take Five',
    artist: 'Dave Brubeck',
    genre: 'Jazz',
    bpm: 176,
    timeSignature: TimeSignature(5, 4),
  ),
  Song(
    title: 'Money',
    artist: 'Pink Floyd',
    genre: 'Progressive Rock',
    bpm: 120,
    timeSignature: TimeSignature(7, 4),
  ),
];
```

### Sample Setlists:
```dart
final sampleSetlists = [
  Setlist(
    name: 'Friday Night Gig',
    icon: 'calendar',
    songs: [sampleSongs[0], sampleSongs[1], ...], // 12 songs
  ),
  Setlist(
    name: 'Sunday Service',
    icon: 'church',
    songs: [sampleSongs[3], ...], // 5 songs
  ),
  Setlist(
    name: 'Studio Session A',
    icon: 'camera',
    songs: [...], // 8 songs
  ),
  Setlist(
    name: 'Acoustic Lounge',
    icon: 'cocktail',
    songs: [...], // 15 songs
  ),
];
```

---

## Appendix D: Known Limitations & Future Enhancements

### Known Limitations (v1.0):
- Single metronome tone (Classic Woodblock) - other tones are UI-only in settings
- No MIDI output
- No cloud sync (local-only)
- No song sharing between devices
- No audio import from music files

### Planned for v2.0:
- Multiple metronome sound packs
- Cloud backup and sync
- Bluetooth wearable integration (Soundbrenner compatibility)
- MIDI clock output
- Tempo automation (gradual BPM changes)
- Practice mode with loop sections
- Integration with Spotify/Apple Music for BPM detection

---

## Final Pre-Flight Checklist

Before generating the APK, verify:

### Functionality:
- [ ] All 4 screens render correctly
- [ ] Bottom navigation switches between screens
- [ ] Metronome starts/stops on button press
- [ ] BPM changes instantly when adjusted
- [ ] Tap tempo calculates BPM correctly
- [ ] Songs can be added/edited/deleted
- [ ] Setlists can be created/modified
- [ ] Live Session loads songs from setlist
- [ ] Beat indicators animate in sync
- [ ] Settings persist after app restart
- [ ] Database survives app kill/restart
- [ ] No memory leaks during long playback
- [ ] Screen stays awake during Live Session

### Design:
- [ ] Colors match Stitch exactly (#25D1F4, #101F22)
- [ ] Space Grotesk font loads properly
- [ ] All icons are Material Symbols Outlined
- [ ] Card shadows and borders match designs
- [ ] Button sizes match wireframes (48x48, 96x96)
- [ ] Typography sizes match specification
- [ ] Spacing/padding matches visual reference
- [ ] Bottom nav height and style correct
- [ ] Search bars have proper styling
- [ ] Pills/chips match design

### Performance:
- [ ] App launches in <2 seconds
- [ ] No frame drops during scrolling
- [ ] Metronome timing is rock-solid
- [ ] Animations run at 60fps
- [ ] Database queries complete quickly (<50ms)

### Edge Cases:
- [ ] Empty states show helpful messages
- [ ] Long song/setlist names truncate
- [ ] Deleting song in setlist handled gracefully
- [ ] Very fast/slow BPMs (20, 300) work
- [ ] Unusual time signatures (5/4, 7/8) work
- [ ] App handles orientation changes
- [ ] Headphone plug/unplug doesn't crash

---

**You are ready to build TempoSet!** 🎵

Use the Stitch wireframes as your north star. When in doubt, refer back to the `screen.png` files for exact visual specifications.

Good luck, and happy coding! 🚀
