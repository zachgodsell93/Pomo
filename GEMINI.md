# Pomo

A minimalist, menu-bar integrated Pomodoro timer for macOS.

## Project Overview

**Pomo** is a native macOS application built using Swift. It combines **AppKit** for system-level integration (menu bar, floating windows) with **SwiftUI** for the user interface. It is designed to be a lightweight, always-on-top productivity tool.

### Key Technologies
*   **Language:** Swift
*   **UI Frameworks:** SwiftUI (Views), AppKit (Window/Menu management)
*   **State Management:** Combine (`ObservableObject`, `@Published`), `UserDefaults`
*   **Build System:** Swift Package Manager

### Architecture
The project follows a hybrid architecture:
1.  **App Lifecycle (`AppDelegate.swift`):** Manages the application startup, the `NSStatusItem` (menu bar icon), and the lifecycle of the floating `NSPanel`. It acts as the bridge between the system and the SwiftUI views.
2.  **Model Layer (`TimerManager.swift`, `SettingsManager.swift`):** Contains the core business logic. `TimerManager` handles the countdown and phase states (Focus/Break), while `SettingsManager` persists user preferences.
3.  **View Layer (`MainView.swift`, `SettingsView.swift`):** Pure SwiftUI views that observe the model objects.
4.  **Styling (`Theme.swift`):** Centralized color palette and design constants.

## Building and Running

The project is structured as a Swift executable package.

### Prerequisites
*   macOS 11.0 or later
*   Swift 5.5 or later (Xcode Command Line Tools)

### Commands

**Run the application (Debug):**
```bash
swift run
```
*Note: The app will appear in the menu bar. The floating window may be toggled via the menu item or keyboard shortcut.*

**Build for Release:**
```bash
swift build -c release
```

**Clean Build Artifacts:**
```bash
swift package clean
```

## Development Conventions

*   **UI Implementation:** The UI is built programmatically using SwiftUI. `NSHostingView` is used to embed these views into AppKit windows.
*   **Window Management:** Windows are created and managed explicitly in `AppDelegate`. The main timer window is an `NSPanel` configured to be "floating" and "non-activating" to prevent it from stealing focus unnecessarily.
*   **State Propagation:**
    *   `TimerManager` is the single source of truth for the timer.
    *   It is injected into SwiftUI views (`@ObservedObject`).
    *   `AppDelegate` observes it via Combine to update the menu bar text.
*   **Persistence:** `UserDefaults` is used for simple configuration (durations, sound preferences).
*   **Styling:** Hardcoded colors should be avoided in views. Use the semantic colors defined in `Theme.swift` (e.g., `Theme.background`, `Theme.accent`).

## Directory Structure

*   `App`: Application entry point and delegate.
*   `Model`: Core logic and data.
*   `Views`: SwiftUI user interface components.
*   `Utils`: Helpers and extensions (Theme).
