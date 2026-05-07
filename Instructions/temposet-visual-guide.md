# TempoSet - Visual Design Guide
## Companion Document to Agent Prompt

This document provides detailed visual breakdowns of each Stitch screen with exact measurements, spacing, and component specifications.

---

## Screen 1: Setlists

### Layout Measurements
```
┌───────────────────────────────────────┐
│  24px padding                         │
│  ┌─────────────────────┐  ┌──────┐   │
│  │ Setlists            │  │  +   │   │ 48x48px button
│  │ 28px bold           │  │      │   │
│  │                     │  └──────┘   │
│  │ Organize your...    │             │
│  │ 14px, cyan/70%      │             │
│  └─────────────────────┘             │
│  24px horizontal margin              │
├───────────────────────────────────────┤
│  16px vertical gap                   │
├───────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │
│  │ 🔍  Search your setlists...     │ │ 56px height
│  │     16px text, slate-400        │ │ 12px radius
│  └─────────────────────────────────┘ │
├───────────────────────────────────────┤
│  12px vertical gap                   │
├───────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │
│  │  ┌────┐                          │ │
│  │  │ 📅 │  Friday Night Gig    →  │ │
│  │  │56px│  18px bold white        │ │ Card height: auto
│  │  └────┘                          │ │ (min 88px)
│  │  16px   [12 Songs] ⏱ 45 mins   │ │
│  │  gap    cyan pill  14px gray    │ │
│  └─────────────────────────────────┘ │
│  8px vertical margin                 │
│  [Repeat for each setlist card...]  │
└───────────────────────────────────────┘
```

### Card Component Breakdown
```
Setlist Card:
├─ Container
│  ├─ Background: #1A2F33
│  ├─ Border: 1px solid rgba(37, 209, 244, 0.1)
│  ├─ Border radius: 12px
│  ├─ Padding: 16px all sides
│  └─ Margin: 24px horizontal, 8px vertical
│
├─ Icon Container (left)
│  ├─ Size: 56x56px
│  ├─ Background: #1E3E43
│  ├─ Border radius: 12px
│  ├─ Icon color: #25D1F4
│  └─ Icon size: 28px
│
├─ Content (center, flex-grow)
│  ├─ Title
│  │  ├─ Font: Space Grotesk, 18px, bold
│  │  ├─ Color: white
│  │  └─ Margin bottom: 8px
│  │
│  └─ Metadata Row
│     ├─ Song Count Pill
│     │  ├─ Background: #25D1F4
│     │  ├─ Text: black, 12px, semi-bold
│     │  ├─ Padding: 12px horizontal, 4px vertical
│     │  └─ Border radius: 9999px
│     │
│     ├─ 12px horizontal gap
│     │
│     └─ Duration
│        ├─ Clock icon: 16px, slate-400
│        ├─ Text: 14px, slate-400
│        └─ Align: baseline with pill
│
└─ Chevron (right)
   ├─ Icon: chevron_right
   ├─ Color: slate-500
   └─ Size: 24px
```

### Bottom Navigation Bar
```
Height: 64px + safe area inset
Background: #0A1518 (darker than screen)
Border top: 1px solid rgba(255, 255, 255, 0.05)

Items (evenly spaced):
┌──────────┬──────────┬──────────┬──────────┐
│METRONOME │  SONGS   │ SETLISTS │ SETTINGS │
│  timer   │   note   │   list   │   gear   │
│  icon    │   icon   │   icon   │   icon   │
│ inactive │ inactive │  ACTIVE  │ inactive │
└──────────┴──────────┴──────────┴──────────┘

Each item:
- Icon size: 24px
- Label: 11px, uppercase, letter-spacing: 0.5px
- Active: #25D1F4 with dot indicator
- Inactive: #64748B
- Tap area: 48x48px minimum
```

---

## Screen 2: Song Library

### Filter Chips Row
```
Horizontal scroll, no wrap
Height: 40px
Gap between chips: 8px
Padding: 16px horizontal

┌─────────────────┐  ┌─────────────┐  ┌─────────┐
│ BPM: High-Low ▾ │  │Recently Add…│  │Title A-Z│
│   ACTIVE CHIP   │  │   OUTLINE   │  │ OUTLINE │
└─────────────────┘  └─────────────┘  └─────────┘

Active Chip:
- Background: #25D1F4
- Text: black (#000000)
- Font: 14px, semi-bold
- Padding: 12px horizontal, 8px vertical
- Border radius: 9999px
- Dropdown chevron: 16px

Outline Chip:
- Background: transparent
- Border: 1.5px solid rgba(37, 209, 244, 0.5)
- Text: #25D1F4
- Same padding/radius as active
```

### Song Card Component
```
┌─────────────────────────────────────────────┐
│  ┌────┐                                     │
│  │ ♪  │  Starlight                    122   │
│  │56px│  18px bold white            32px    │
│  └────┘                              bold   │
│  16px   Muse                          BPM   │
│  gap    15px, slate-400             12px    │
│         Alternative Rock             gray   │
│         14px, cyan                          │
└─────────────────────────────────────────────┘

Card styling:
- Same as Setlist card (#1A2F33 background, etc.)
- Right side: Align BPM number top-right
- BPM "label" directly below number
- Icon background: same teal (#1E3E43)
- Music note icon: #25D1F4, 28px
```

---

## Screen 3: Settings

### Radio Button Group (Metronome Tones)
```
┌───────────────────────────────────────────┐
│  ●  Classic Woodblock              ●     │
│     Traditional acoustic feel      ●     │
│                                     ●     │ Selected
│  ○  Digital Beep                   ○     │
│     Clean electronic pulse         ○     │ Unselected
└───────────────────────────────────────────┘

Each option:
- Height: auto (min 56px)
- Padding: 16px
- Background: transparent (selected: rgba(37, 209, 244, 0.05))
- Border: none (selected: 1px solid rgba(37, 209, 244, 0.3))
- Border radius: 12px

Radio indicator (right):
- Selected: filled circle, #25D1F4, 20px
- Unselected: outline circle, slate-500, 20px
- Inner dot (selected): 10px diameter
```

### Toggle Switch Component
```
┌─────────────────────────────────────────┐
│  📳  Haptic Feedback            [✓]     │
│      Vibrate on every beat              │
└─────────────────────────────────────────┘

Layout:
- Icon (left): 24x24px, slate-400
- Title: 16px, white, semi-bold
- Description: 14px, slate-400, below title
- Toggle (right): 52x32px

Toggle states:
ON:
- Track: #25D1F4
- Thumb: white, 28px diameter
- Position: right

OFF:
- Track: #334155 (slate-700)
- Thumb: white, 28px diameter
- Position: left
```

### Section Headers
```
METRONOME TONES
DEVICE BEHAVIOR
ABOUT

Styling:
- Font: 12px, bold
- Letter spacing: 1.5px
- Color: #25D1F4
- Text transform: uppercase
- Margin: 32px top, 16px bottom
```

---

## Screen 4: Live Session

### Huge BPM Display
```
        TEMPO
        ↓ 14px gray, uppercase
    
       124
    96px, bold, white, height: 1.0
    
       BPM
    16px, slate-400

Total vertical space: ~140px
Centered horizontally
```

### Beat Indicator Bars
```
┌──────────────────────────────────────┐
│  ████  ▁▁▁  ▁▁▁  ▁▁▁                │
│ ACTIVE  2    3    4                  │
└──────────────────────────────────────┘

Layout:
- Container width: screen width - 48px padding
- Height: 8px
- Gap between bars: 12px
- Each bar width: (container - gaps) / beat_count

Bar states:
Active (current beat):
- Background: #25D1F4
- Height: 8px
- Glow: BoxShadow(#25D1F4, blur: 8px)

Inactive:
- Background: rgba(37, 209, 244, 0.1)
- Border: 1px solid rgba(37, 209, 244, 0.3)
- Height: 8px

Animation:
- On beat: scale 1.0 → 1.2 → 1.0
- Duration: 100ms
- Easing: easeOutCubic
```

### Tempo Control Buttons
```
┌────────────────────────────────────┐
│                                    │
│  [ − ]     [  ⏸  ]      [ + ]     │
│  64px       96px         64px      │
│            GLOWING                 │
│                                    │
└────────────────────────────────────┘

Minus/Plus buttons:
- Size: 64x64px
- Background: #1A2F33
- Border: 1px solid rgba(37, 209, 244, 0.2)
- Border radius: 32px (circular)
- Icon: white, 32px

Pause/Play button (center):
- Size: 96x96px
- Background: #25D1F4
- Border radius: 48px
- Icon: black, 48px
- Shadow:
  BoxShadow(
    color: #25D1F4.withOpacity(0.4),
    blurRadius: 24px,
    spreadRadius: 0px,
  )
```

### Tap Tempo Button
```
┌─────────────────────────────────────┐
│                                     │
│     👆   TAP TEMPO                  │
│    icon    16px bold                │
│                                     │
└─────────────────────────────────────┘

Styling:
- Width: screen width - 48px
- Height: 72px
- Background: white (#FFFFFF)
- Text color: black
- Border radius: 12px
- Tap icon: 24px, left of text
- Font: Space Grotesk, 16px, bold
- Shadow: subtle (rgba(0,0,0,0.1), blur: 8px)

Active state (on tap):
- Background flashes to #25D1F4
- Duration: 100ms
```

### Feature Toggle Row
```
┌──────────┬──────────┬──────────┐
│    🔊    │    📳    │    📸    │
│  AUDIO   │  HAPTIC  │  FLASH   │
│ inactive │  ACTIVE  │ inactive │
└──────────┴──────────┴──────────┘

Each button:
- Size: 64x64px
- Border radius: 12px
- Gap: 16px between buttons
- Centered row

Inactive:
- Background: #1A2F33
- Border: 1px solid rgba(37, 209, 244, 0.2)
- Icon: slate-400, 28px
- Label: slate-500, 11px, uppercase

Active:
- Background: #25D1F4
- Border: none
- Icon: black, 28px
- Label: white, 11px, uppercase
```

### Song Carousel Cards
```
Active Card:
┌─────────────┐
│             │
│      ♪      │  200px wide
│             │  160px tall
│ Midnight    │
│   City      │
│             │
│   ACTIVE    │  12px, black, uppercase
└─────────────┘
Background: #25D1F4
Text: black
Border radius: 12px
Shadow: glow effect

Next Card:
┌─────────────┐
│             │
│      ♪      │
│             │
│  Wait for   │
│  the Moment │
│             │
│    NEXT     │
└─────────────┘
Background: #1A2F33
Text: slate-400
Border: 1px solid rgba(37, 209, 244, 0.2)
Border radius: 12px

Spacing:
- Gap between cards: 16px
- Horizontal padding: 24px
- Snap scroll: enabled
- Show 1.5 cards on screen
```

---

## Typography Reference

### Font Weights
- **Regular (400)**: Body text, descriptions
- **Medium (500)**: Not used in current design
- **Semi-bold (600)**: Buttons, emphasized text, section headers
- **Bold (700)**: Headings, titles, BPM numbers

### Line Heights
- **Headings**: 1.2
- **Body**: 1.5
- **Huge BPM**: 1.0 (tight)
- **Buttons**: 1.0 (tight)

### Letter Spacing
- **Headings**: -0.5px (slightly tighter)
- **Normal**: 0px (default)
- **Uppercase labels**: +0.5px to +1.5px (looser)

---

## Animation Specifications

### Standard Transitions
- **Duration**: 200ms
- **Easing**: ease-out-cubic
- **Properties**: opacity, transform, background-color

### Beat Animations
- **Duration**: 100ms
- **Easing**: ease-out
- **Transform**: scale(1.0) → scale(1.2) → scale(1.0)

### Button Press
- **Duration**: 150ms
- **Easing**: ease-in-out
- **Transform**: scale(1.0) → scale(0.95) on press
- **Opacity**: 1.0 → 0.7 during press

### Card Swipe
- **Dismiss threshold**: 30% of card width
- **Snap back**: < 30%, duration 250ms
- **Fly out**: ≥ 30%, duration 300ms
- **Easing**: ease-out-cubic

---

## Accessibility Notes

### Minimum Touch Targets
- All interactive elements: 48x48dp minimum
- Exception: Inline text links (follow platform guidelines)

### Color Contrast Ratios
- White text on dark background: 15:1 (AAA)
- Cyan on dark background: 7:1 (AA)
- Gray text on dark background: 4.5:1 (AA for large text)

### Focus States
- All focusable elements should have visible focus ring
- Focus ring: 2px solid #25D1F4, 4px offset

---

## Responsive Considerations

### Screen Sizes
- **Minimum width**: 360px (small phones)
- **Maximum width**: 428px (large phones)
- **Centered layout**: Max 480px width, centered on tablets

### Safe Areas
- **Top**: Status bar + 8px
- **Bottom**: Home indicator + 8px
- **Sides**: 0px (content can bleed to edges)

### Orientation
- **Portrait only**: Lock to portrait orientation
- No landscape support needed for v1.0

---

This visual guide should be used alongside the Stitch wireframes to ensure pixel-perfect implementation. When measurements conflict, the wireframe images are the source of truth.
