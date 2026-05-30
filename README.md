# 🕌 QuranPlayer

A native iOS music player application built in SwiftUI that streams Quran recitations **per ayah (verse)** using the [Al-Quran Cloud API](https://alquran.cloud). Recited by **Mishary Rashid Alafasy**.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Browse** | Full list of all 114 Surahs with Arabic name, English name, ayah count, and revelation type |
| **Search** | Real-time search by surah name (English or Arabic) or number |
| **Per-Ayah Playback** | Each ayah plays as its own audio track — tap any verse to start |
| **Auto-advance** | Automatically plays the next ayah when the current one finishes |
| **Play / Pause / Resume** | Full standard playback controls |
| **Previous / Next** | Navigate between ayahs within the same surah |
| **Progress Bar** | Visual seek slider showing current position and total duration |
| **Seeking** | Drag the slider to jump to any point in an ayah |
| **Mini Player** | Persistent bottom bar with track info, time display, and controls |
| **Full Player** | Modal sheet with animated arabesque artwork, Arabic ayah text, and full controls |
| **Equalizer Animation** | Animated bars in the player badge while audio is playing |
| **Basmalah Banner** | Displayed at the top of each surah's ayah list (except At-Tawbah) |
| **Dark Mode** | App is fully dark-mode first with a gold/deep-navy color palette |
| **Splash Screen** | Launch screen shown on first open |

---

## 🏗 Architecture

This app follows **MVVM (Model-View-ViewModel)** with a clean protocol-driven service layer for maximum testability.

```
QuranPlayer/
├── Models/
│   └── QuranModel.swift          # Surah, AyahAudio, Track, PlaybackState
├── Services/
│   ├── QuranAPIService.swift     # Networking — fetches surahs & ayahs from API
│   └── AudioPlayerService.swift  # AVPlayer wrapper — playback engine
├── ViewModel/
│   └── PlayerViewModel.swift     # @MainActor ObservableObject — single source of truth
├── Views/
│   ├── ContentView.swift         # Root view — splash + library + mini player + sheet
│   ├── LibraryView.swift         # Surah list + search bar + AyahListView
│   ├── MiniPlayerView.swift      # Persistent bottom player bar
│   ├── FullPlayerView.swift      # Full-screen player modal
│   └── Extensions.swift          # Color(hex:), View.placeholder, Double.clamped
└── Tests/
    └── QuranPlayerTests.swift    # Unit tests for ViewModel, API, model, extensions
```

### State Management

State is managed entirely through **Combine + `@Published` properties** on `PlayerViewModel`, which is an `@MainActor ObservableObject`. All views observe it via `@EnvironmentObject`.

There is **no shared mutable global state** — views only read from the ViewModel and call its methods. All audio state flows upward from `AudioPlayerService` through Combine publishers.

```
AudioPlayerService  ──(Combine publishers)──▶  PlayerViewModel  ──(@Published)──▶  Views
QuranAPIService     ──(async/await)──────────▶  PlayerViewModel
```

---

## 🔌 API

**Base URL:** `https://api.alquran.cloud/v1`

| Endpoint | Usage |
|---|---|
| `GET /surah` | Fetch all 114 surahs (metadata only) |
| `GET /surah/{number}/ar.alafasy` | Fetch all ayahs + audio URLs for one surah |

**Audio CDN:** `https://cdn.islamic.network/quran/audio/128/ar.alafasy/{globalAyahNumber}.mp3`

The `audio` field is returned directly in each ayah object from the API response — no manual URL construction needed.

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| State Management | Combine + `@Published` / `@EnvironmentObject` |
| Audio Engine | `AVFoundation` (`AVPlayer`, `AVAudioSession`) |
| Networking | `URLSession` + `async/await` |
| Architecture | MVVM + Protocol-oriented Services |
| Testing | XCTest + `@testable import` |
| Minimum iOS | iOS 16.0 |

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 16.0+ device or simulator
- Internet connection (audio streams from CDN)

### Installation

```bash
git clone https://github.com/your-username/QuranPlayer.git
cd QuranPlayer
open QuranPlayer.xcodeproj
```

Then press **Run** (`Cmd+R`) in Xcode.

No external dependencies or package manager setup required — the project uses only Apple frameworks.

---

## 📂 Project Structure Details

```
QuranPlayer/
│
├── QuranPlayerApp.swift          # @main entry point
│
├── Models/
│   └── QuranModel.swift
│       ├── Surah                 # API model: 114 chapters
│       ├── AyahAudio             # API model: single verse with audio URL
│       ├── SurahAudioData        # API wrapper for /surah/{n}/ar.alafasy data field
│       ├── Track                 # Player domain model (init from AyahAudio + Surah)
│       └── PlaybackState         # Enum for audio state machine
│
├── Services/
│   ├── QuranAPIService.swift
│   │   ├── QuranAPIError         # Typed errors (invalidURL, network, decoding, server)
│   │   ├── QuranAPIServiceProtocol
│   │   ├── QuranAPIService       # Live implementation using URLSession
│   │   └── MockQuranAPIService   # Test double
│   │
│   └── AudioPlayerService.swift
│       ├── AudioPlayerServiceProtocol
│       ├── AudioPlayerService    # AVPlayer wrapper with Combine publishers
│       └── MockAudioPlayerService
│
├── ViewModel/
│   └── PlayerViewModel.swift     # @MainActor ObservableObject — all app state
│
├── Views/
│   ├── ContentView.swift         # Root: splash overlay + LibraryView + MiniPlayer + .sheet
│   ├── LibraryView.swift
│   │   ├── LibraryView           # NavigationView with surah list
│   │   ├── SurahRowView          # Single surah row with equalizer animation
│   │   ├── AyahListView          # List of ayahs for a surah (pushed via NavigationLink)
│   │   ├── AyahRowView           # Single ayah row with Arabic text
│   │   ├── SearchBarView         # Styled search input
│   │   └── EqualizerBarsView     # Animated bars for active surah
│   ├── MiniPlayerView.swift
│   │   ├── MiniPlayerView        # Bottom persistent bar
│   │   └── MiniEqualizerView     # Small animated equalizer
│   └── FullPlayerView.swift
│       ├── FullPlayerView        # Full modal player sheet
│       ├── SeekSliderView        # Custom drag-gesture seek bar
│       ├── ArabesqueOrnamentView # Rotating decorative SVG-like ornament
│       ├── ArabeskPetal          # Shape primitive for arabesque
│       └── ScaleButtonStyle      # Press-to-scale button animation
│
├── Extensions/
│   └── Extensions.swift
│       ├── Color(hex:)           # Hex string to SwiftUI Color
│       ├── View.placeholder      # ZStack-based placeholder overlay
│       └── Double.clamped(to:)   # Range-clamping utility
│
└── Tests/
    └── QuranPlayerTests.swift
```

---

## 🎨 Design Notes

- **Color palette:** Deep navy (`#0D0D1A`, `#12121F`) background with gold (`#C9A84C`, `#D4B15C`) accents — inspired by traditional Islamic manuscript aesthetics.
- **Typography:** SF Rounded for UI text; system Arabic fonts for Quran text.
- **Animations:** Spring-based transitions for the mini player appearance; rotating arabesque ornament in the full player; timer-driven equalizer bars.
- **No third-party UI libraries** — all components are built from SwiftUI primitives.

---

## ⚠️ Notes

- Audio files stream directly from `cdn.islamic.network` — an active internet connection is required.
- The app requests `.playback` `AVAudioSession` category so audio continues when the screen is locked.
- Surah **At-Tawbah (9)** intentionally omits the Basmalah banner per Islamic tradition.
- Ayah audio is cached in memory per surah session; switching surahs reloads the ayah list.

---

## 👤 Author

**Ardennata Winarno**  
Mobile App Technical Test — QuranPlayer
