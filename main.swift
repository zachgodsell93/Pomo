import Cocoa
import SwiftUI

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // Hide from Dock, show only in Menu Bar (and floating windows)

app.run()