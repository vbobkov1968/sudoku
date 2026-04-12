# Sudoku App — Project Context

## Project Overview

This is a **cross-platform Sudoku application** currently in the planning/architecture phase. The project aims to deliver a native-quality Sudoku experience across **macOS, Windows, Linux, and Android** from a single codebase.

### Tech Stack (Planned)
- **Framework:** Flutter 3.24+ (Dart)
- **State Management:** Riverpod or Bloc (TBD)
- **Local Database:** Isar or Drift (TBD)
- **Localization:** `flutter_localizations` + `.arb` files (RU/EN)
- **CI/CD:** GitHub Actions + Fastlane

### Architecture (Planned)
The project will follow a clean modular structure:
```
core/         — Game logic: generator, validator, undo/redo, notes
data/         — Persistence: Isar/Drift models, repositories
presentation/ — UI: screens, widgets, responsive layouts
```

## Key Files

| File | Description |
|------|-------------|
| **Sudoku Requirements.md** | Full MVP requirements: platform support, functional/non-functional requirements, UX specs, technical constraints. Defines supported platforms (macOS 12+, Windows 10/11, Ubuntu 22.04+/Fedora 38+, Android 10+). |
| **Sudoku Implementation Plan.md** | User Story Map with task breakdown, critical path analysis, parallelization matrix, and a task status tracker with dates and assignees. |

## MVP Feature Set

Core features for the initial release:
- 9×9 grid with 3×3 block visual separation
- Puzzle generation with guaranteed unique solution
- Difficulty levels (Easy/Medium/Hard/Expert)
- Input via virtual numpad, physical keyboard, or click/tap
- Note/candidate mode (up to 9 candidates per cell)
- Undo/Redo (≥50 steps)
- Real-time conflict highlighting
- Auto-save on app lifecycle changes
- Win detection and victory screen
- Responsive layout (desktop sidebar / mobile bottom sheet)
- Full offline operation
- i18n: Russian and English

## Getting Started (When Development Begins)

### Prerequisites
- Flutter SDK 3.24+
- Dart SDK
- Platform toolchains (Xcode for macOS, Android SDK, etc.)

### Project Setup
```bash
# Create the Flutter project (Task 1.1)
flutter create sudoku --org com.sudoku
cd sudoku

# Run on your preferred platform
flutter run -d macos      # macOS
flutter run -d windows    # Windows
flutter run -d linux      # Linux
flutter run -d android    # Android
```

### Testing
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Building
```bash
# Desktop
flutter build macos
flutter build windows
flutter build linux

# Android
flutter build appbundle   # .aab for Play Store
```

## Development Conventions (Planned)

- **TDD approach** for core logic (generator, validator, undo stack)
- **Unit test coverage target:** >80%
- **E2E tests** required on at least 2 platforms
- **Animations:** ≤200ms, no blocking animations
- **Accessibility:** TalkBack/VoiceOver/NVDA support, contrast ≥4.5:1, scalable elements
- **Keyboard navigation:** Arrows, Enter, Space, Backspace, number keys
- **Code separation:** `core` ↔ `presentation` ↔ `data` layers must remain decoupled

## Next Steps

The project is at the planning stage. The first development task is **Task 1.1**: Initialize the Flutter project with the `core/`, `data/`, `presentation/` architecture. Refer to the Implementation Plan's Task Status Tracker for the full roadmap and current statuses.
