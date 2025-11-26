import SwiftUI

struct MainView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var settings = SettingsManager.shared
    @State private var isHovering = false
    @State private var isCompactMode = false
    
    var body: some View {
        Group {
            if isCompactMode {
                compactView
            } else {
                fullView
            }
        }
    }

    var compactView: some View {
        ZStack {
            Theme.background

            VStack(spacing: 8) {
                // Custom window controls
                HStack {
                    customWindowControls
                    Spacer()
                }
                .padding(.leading, 8)
                .padding(.top, 8)

                Spacer()

                // Just the timer
                Text(timerManager.timeString)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.timerText)

                Spacer()
            }
        }
        .frame(width: 200, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    var fullView: some View {
        ZStack {
            Theme.background

            // Main Content
            VStack(spacing: 15) {
                // Header/Phase
                Text(phaseText)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.secondaryAccent)
                    .padding(.top, 25)

                // Progress dots representing a cycle
                HStack(spacing: 8) {
                    ForEach(0..<settings.targetPomos, id: \.self) { index in
                        Circle()
                            .fill(index < (timerManager.completedPomos % settings.targetPomos) ? Theme.accent : Theme.accent.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 4)

                Spacer()

                // Timer Display Row
                HStack(spacing: 15) {
                    Button(action: {
                        timerManager.resetPhase()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Theme.secondaryAccent.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text(timerManager.timeString)
                        .font(.system(size: 90, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.timerText)
                        .minimumScaleFactor(0.5)

                    Button(action: {
                        timerManager.skip()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Theme.secondaryAccent.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)

                Spacer()

                // Controls
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        timerManager.togglePause()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 65, height: 65)
                            .shadow(radius: 5)

                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .id(timerManager.isRunning)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 25)
            }
            .frame(maxWidth: .infinity)

            // Custom window controls and settings - always visible overlay
            VStack {
                HStack {
                    customWindowControls
                    Spacer()
                    Menu {
                        Menu("Focus Length") {
                            Button(action: { updateFocusDuration(15 * 60) }) {
                                HStack {
                                    Text("15 mins")
                                    if settings.focusDuration == 15 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            Button(action: { updateFocusDuration(20 * 60) }) {
                                HStack {
                                    Text("20 mins")
                                    if settings.focusDuration == 20 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            Button(action: { updateFocusDuration(25 * 60) }) {
                                HStack {
                                    Text("25 mins")
                                    if settings.focusDuration == 25 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            Button(action: { updateFocusDuration(30 * 60) }) {
                                HStack {
                                    Text("30 mins")
                                    if settings.focusDuration == 30 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            Button(action: { updateFocusDuration(45 * 60) }) {
                                HStack {
                                    Text("45 mins")
                                    if settings.focusDuration == 45 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            Button(action: { updateFocusDuration(60 * 60) }) {
                                HStack {
                                    Text("60 mins")
                                    if settings.focusDuration == 60 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        Menu("Break Length") {
                            Button(action: { updateBreakDuration(5 * 60) }) {
                                HStack {
                                    Text("5 mins")
                                    if settings.breakDuration == 5 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            Button(action: { updateBreakDuration(10 * 60) }) {
                                HStack {
                                    Text("10 mins")
                                    if settings.breakDuration == 10 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            Button(action: { updateBreakDuration(15 * 60) }) {
                                HStack {
                                    Text("15 mins")
                                    if settings.breakDuration == 15 * 60 {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        Menu("Rounds") {
                            ForEach(1...10, id: \.self) { num in
                                Button(action: { settings.targetPomos = num }) {
                                    HStack {
                                        Text("\(num)")
                                        if settings.targetPomos == num {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        Divider()
                        Button("Quit Pomo") {
                            NSApplication.shared.terminate(nil)
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                    }
                    .tint(Theme.darkBlue)
                    .menuStyle(BorderlessButtonMenuStyle())
                    .opacity(isHovering ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isHovering)
                }
                .padding(.leading, 8)
                .padding(.trailing, 10)
                .padding(.top, 8) // Fine-tuned vertical alignment
                Spacer()
            }
        }
        .frame(width: 500, height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    var customWindowControls: some View {
        HStack(spacing: 8) {
            // Close button
            Button(action: {
                NSApp.sendAction(#selector(AppDelegate.toggleWindow), to: nil, from: nil)
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 12, height: 12)
                    .background(Circle().fill(Color.red))
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: isHovering)

            // Minimize to compact mode button
            Button(action: {
                toggleCompactMode()
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 12, height: 12)
                    .background(Circle().fill(Color.orange))
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
    }

    func toggleCompactMode() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isCompactMode.toggle()
        }

        // Resize the window
        if let window = NSApp.keyWindow {
            let newSize: NSSize
            if isCompactMode {
                newSize = NSSize(width: 200, height: 100)
            } else {
                newSize = NSSize(width: 500, height: 320)
            }

            let currentFrame = window.frame
            let newFrame = NSRect(
                x: currentFrame.origin.x,
                y: currentFrame.origin.y + (currentFrame.height - newSize.height),
                width: newSize.width,
                height: newSize.height
            )

            window.setFrame(newFrame, display: true, animate: true)
        }
    }

    func updateFocusDuration(_ newDuration: TimeInterval) {
        settings.focusDuration = newDuration
        // If currently in focus phase, update the timer immediately
        if timerManager.phase == .focus {
            timerManager.resetPhase()
        } else if timerManager.phase == .idle {
            // Update idle display as well
            timerManager.resetPhase()
        }
    }

    func updateBreakDuration(_ newDuration: TimeInterval) {
        settings.breakDuration = newDuration
        // If currently in break phase, update the timer immediately
        if timerManager.phase == .shortBreak {
            timerManager.resetPhase()
        }
    }
    
    var phaseText: String {
        switch timerManager.phase {
        case .idle: return "Ready to Focus"
        case .focus: return "Focus Session"
        case .shortBreak: return "Break Time"
        }
    }
}
