# ⚡ Stryde — Offline-First Running Tracker

**Stryde** is a high-performance, athletic, offline-first mobile running & walking tracker built with Flutter and Dart using Clean Architecture (Feature-First). Designed with a high-contrast athletic aesthetic, electric neon accents, and tabular typography for rock-solid in-run readability.

Developed by **Maaafiqs Dev**.

---

## 📲 Download & Install APK

Download the latest pre-compiled release APK directly to your Android device:
- 📦 **[Download Stryde v1.0.0 Release APK (Direct)](https://github.com/maaafiqs/stryde-running-app/releases/download/v1.0.0/stryde-v1.0.0-release.apk)** *(Android 8.0+ / arm64-v8a, armeabi-v7a, x86_64)*
- 🏷️ **[View GitHub Release v1.0.0](https://github.com/maaafiqs/stryde-running-app/releases/tag/v1.0.0)**

---

## 🎨 Visual Identity & Brand System

- **Background:** `#0B0E14` (Deep Onyx)
- **Card Surfaces:** `#151A23` (Dark Slate Card)
- **Primary Accent:** `#C6FF00` (Electric Lime / Neon Green)
- **Secondary Accent:** `#00E676` (Neon Mint) & `#FF5252` (Stop / Alert)
- **Typography:** Material 3 with `FontFeature.tabularFigures()` on all real-time counters (distance, pace, timers) to eliminate visual number jittering.

---

## 🚀 Key Features

1. **Live GPS Run Tracker:**
   - Real-time dark CartoDB tile map with glowing electric neon polylines.
   - High-contrast HUD displaying Distance (KM), Current Pace, Duration, Avg Pace, Elevation Gain, and Estimated Calories.
   - **Intelligent Auto-Pause:** Detects resting runner speed (< 0.8 m/s) and auto-resumes once running speed (> 1.2 m/s) is detected.
   - **Slide to Finish:** Prevents accidental run terminations caused by sweat or screen touches.

2. **Offline-First Persistence (Drift ORM):**
   - High-speed local SQLite database saving thousands of raw GPS track points, elevation data, speeds, and full activity sessions without requiring cloud dependencies.

3. **Core Geolocation & GPS Drift Filter:**
   - Discards inaccurate readings (`accuracy > 20m`).
   - Filters out stationary GPS jitter (`displacement < 2m` when stationary).
   - Real-time Haversine distance calculations and automated 1.0 km split pace tracking.

4. **Background Tracking & WakeLock:**
   - Foreground Service notification on Android status bar with live distance, elapsed time, and pace.
   - Screen wake lock keeping the display active during running sessions.

5. **Detailed Activity Breakdown:**
   - Interactive zoomable route map with Start & Finish markers.
   - Interactive Elevation & Speed Profile curves powered by `fl_chart`.
   - 1.0 km Split Pace breakdown table with overflow-proof responsive layout and relative performance progress bars.
   - **Shareable Activity Card (Strava-Style):** Instant high-res PNG image generator with optional vector route and transparent sticker mode for social media sharing.
   - **Interactive Shoe Breakdown:** Detailed mileage tracking per session, lifespan progress bar, and ability to link/switch shoes retroactively.

6. **Gear Mileage Tracker:**
   - Tracks the lifespan of your running shoes.
   - Automatically increments assigned shoe mileage after each finished run or walk.
   - Visual progress bar warning when approaching the default 700 km retirement threshold.

7. **Modes, Themes & Settings:**
   - **Dual Activity Modes:** Run (Lari) and Casual Walk (Jalan Santai) with customized pace, speed, and step metrics.
   - **Theme Engine:** Dark Mode (OLED-optimized), Light Mode (high daylight contrast), and System theme support.
   - **Settings Screen:** Integrated settings hub with developer attribution (*developed by Maaafiqs Dev*).

8. **Analytics & 60-Day Consistency Heatmap:**
   - Lifetime distance, total activities, and average pace summaries.
   - Weekly volume bar chart (Monday to Sunday).
   - 60-day running consistency calendar heatmap.

---

## 📁 Feature-First Clean Architecture

```
lib/
├── main.dart                             # Entry point, ProviderScope & system UI
├── core/
│   ├── database/                         # Drift ORM schema (Activities, TrackPoints, Shoes)
│   ├── models/                           # Core domain entities (SplitPace)
│   ├── services/                         # GPS drift filter, Haversine, permissions, background service
│   ├── theme/                            # Material 3 dark theme, neon colors, tabular typography
│   └── utils/                            # GPX exporter & formatting utilities
└── features/
    ├── home/                             # Bottom navigation shell
    ├── tracker/                          # Live run HUD, dark CartoDB map, slide-to-finish
    ├── history/                          # Activity feed, detail view, fl_chart, share card
    ├── gear/                             # Running shoe mileage tracker (700 km limit)
    └── analytics/                        # Lifetime stats, weekly bar charts & heatmap
```

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** Flutter 3.44+ / Dart 3.12+
- **State Management:** `flutter_riverpod` (Modern NotifierProvider)
- **Local Database:** `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`
- **Geolocation & Background:** `geolocator`, `flutter_background_service`, `wakelock_plus`
- **Maps & Geospatial:** `flutter_map`, `latlong2`
- **Charts & UI:** `fl_chart`, `lucide_icons_flutter`
- **Utilities & Export:** `intl`, `share_plus`, `screenshot`

---

## 🧪 Testing & Verification

Run tests:
```bash
flutter test
```
Run static analysis:
```bash
flutter analyze
```

---

## 🏃 Getting Started

1. Clone repository:
   ```bash
   git clone https://github.com/maaafiqs/stryde-running-app.git
   cd stryde-running-app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate Drift database code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run on your Android/iOS device:
   ```bash
   flutter run
   ```
