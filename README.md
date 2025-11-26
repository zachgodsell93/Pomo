# Pomo

A minimalist Pomodoro timer for macOS, built with Swift (SwiftUI + AppKit).

## Features (MVP)
- **Floating Timer Window:** Always-on-top, minimalist design.
- **Menu Bar Integration:** Timer countdown visible in the menu bar.
- **Customizable:** Adjust Focus/Break durations and choose alert sounds.
- **Auto-start Break:** Optional setting to seamlessly transition phases.

## Structure
- `App`: Application lifecycle (AppDelegate) and entry point.
- `Model`: Logic for Timer and Settings management.
- `Views`: SwiftUI views for the Timer and Settings.
- `Utils`: Helper extensions and Theme definitions.

## Usage

### Running from Command Line
You can run the app directly using Swift Package Manager:

```bash
swift run
```

*Note: As a CLI-launched executable, the app will appear in the menu bar (top right). Look for the "Pomo" text or the countdown timer.*

### Building
To build the release version:

```bash
swift build -c release
```

## Color Palette
Based on the requested minimalist blue theme:
- Dark Blue (#03045e)
- Medium Blue (#0077b6)
- Light Blue (#00b4d8)
- Pale Blue (#90e0ef)
- Very Pale Blue (#caf0f8)