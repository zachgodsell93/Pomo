import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSPanel!
    var settingsWindow: NSWindow!
    var statusItem: NSStatusItem!
    var timerManager = TimerManager()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the Status Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "Pomo"
            button.action = #selector(statusBarClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        setupMenu() // We still setup the menu but don't assign it to statusItem.menu immediately
        setupMainWindow()
        
        // Observe timer to update Status Item
        timerManager.$timeRemaining
            .combineLatest(timerManager.$phase)
            .receive(on: RunLoop.main)
            .sink { [weak self] time, phase in
                self?.updateStatusItem(time: time, phase: phase)
            }
            .store(in: &cancellables)
    }

    func setupMainWindow() {
        let contentView = MainView(timerManager: timerManager)

        // Create the floating window (Panel) - borderless style
        // Size 500x320
        window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 320),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false)

        window.isFloatingPanel = true
        window.level = .floating // Always on top
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true

        window.titlebarAppearsTransparent = true

        window.titleVisibility = .hidden

        window.isMovableByWindowBackground = true

        

        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.title = "Pomo"
    }

    var contextMenu: NSMenu!

    func setupMenu() {
        contextMenu = NSMenu()
        
        contextMenu.addItem(NSMenuItem(title: "Toggle Timer Window", action: #selector(toggleWindow), keyEquivalent: "t"))
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(NSMenuItem(title: "Quit Pomo", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    @objc func statusBarClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp || (event.type == .leftMouseUp && event.modifierFlags.contains(.control)) {
            statusItem.menu = contextMenu
            statusItem.button?.performClick(nil) // Trigger menu
            statusItem.menu = nil // Clear it back so left click works next time
        } else {
            toggleWindow()
        }
    }
    
    @objc func toggleWindow() {
        if window.isVisible {
            window.close()
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 350),
                styleMask: [.titled, .closable],
                backing: .buffered, defer: false)
            settingsWindow.center()
            settingsWindow.setFrameAutosaveName("Settings")
            settingsWindow.contentView = NSHostingView(rootView: settingsView)
            settingsWindow.title = "Settings"
        }

        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func updateStatusItem(time: TimeInterval, phase: TimerPhase) {
        guard let button = statusItem.button else { return }
        
        // Calculate text
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let timeStr = String(format: "%02d:%02d", minutes, seconds)
        let text = NSAttributedString(string: timeStr, attributes: [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium),
            .foregroundColor: NSColor.white
        ])
        
        // Measure text
        let textSize = text.size()
        let padding: CGFloat = 8.0
        let imageSize = NSSize(width: textSize.width + (padding * 2), height: 22) // Standard menu bar height is ~22
        
        // Create Image
        let image = NSImage(size: imageSize)
        image.lockFocus()
        
        // Draw Background
        // Use light blue from Theme (#00b4d8). Converting to NSColor.
        // Theme.lightBlue is #00b4d8 -> R:0/255, G:180/255, B:216/255
        let bgColor = NSColor(srgbRed: 0/255, green: 180/255, blue: 216/255, alpha: 1.0)
        let bgPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: imageSize), xRadius: 4, yRadius: 4)
        bgColor.setFill()
        bgPath.fill()
        
        // Draw Text
        let textPoint = NSPoint(
            x: (imageSize.width - textSize.width) / 2,
            y: (imageSize.height - textSize.height) / 2 - 1 // Slight adjustment for vertical center
        )
        text.draw(at: textPoint)
        
        image.unlockFocus()
        image.isTemplate = false // Keep original colors
        
        button.image = image
        button.title = "" // Clear text since it's in the image
    }
}
