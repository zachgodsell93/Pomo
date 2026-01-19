import Cocoa
import SwiftUI

let app = NSApplication.shared

@MainActor
func setupApp() {
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory) // Hide from Dock, show only in Menu Bar (and floating windows)
}

MainActor.assumeIsolated {
    setupApp()
}

app.run()
