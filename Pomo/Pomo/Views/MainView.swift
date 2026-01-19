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
                    .font(.system(size: 54, weight: .light, design: .monospaced))
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
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 380, geometry.size.height / 250)

            ZStack {
                Theme.background

                // Main Content
                VStack(spacing: 8 * scale) {
                    // Header/Phase
                    Text(phaseText)
                        .font(.system(size: 18 * scale, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.secondaryAccent)
                        .padding(.top, 15 * scale)

                    // Progress dots representing sessions (focus and break)
                    HStack(spacing: 6 * scale) {
                        ForEach(0..<timerManager.totalSessions, id: \.self) { index in
                            let isFocus = timerManager.isSessionFocus(at: index)
                            let isCurrent = index == timerManager.currentSessionIndex
                            let isCompleted = index < timerManager.currentSessionIndex

                            if isFocus {
                                // Focus sessions: circles
                                Circle()
                                    .fill(isCompleted || isCurrent ? Theme.accent : Theme.accent.opacity(0.3))
                                    .frame(width: 10 * scale, height: 10 * scale)
                                    .overlay(
                                        Circle()
                                            .stroke(Theme.accent, lineWidth: isCurrent ? 2 * scale : 0)
                                            .frame(width: 14 * scale, height: 14 * scale)
                                    )
                            } else {
                                // Break sessions: smaller rectangles
                                RoundedRectangle(cornerRadius: 2 * scale)
                                    .fill(isCompleted || isCurrent ? Theme.secondaryAccent : Theme.secondaryAccent.opacity(0.3))
                                    .frame(width: 6 * scale, height: 6 * scale)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2 * scale)
                                            .stroke(Theme.secondaryAccent, lineWidth: isCurrent ? 2 * scale : 0)
                                            .frame(width: 10 * scale, height: 10 * scale)
                                    )
                            }
                        }
                    }

                    Spacer()

                    // Timer Display Row
                    HStack(spacing: 12 * scale) {
                        Button(action: {
                            timerManager.goBack()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24 * scale, weight: .bold))
                                .foregroundColor(Theme.secondaryAccent.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Text(timerManager.timeString)
                            .font(.system(size: 100 * scale, weight: .light, design: .monospaced))
                            .foregroundColor(Theme.timerText)
                            .minimumScaleFactor(0.5)

                        Button(action: {
                            timerManager.skip()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24 * scale, weight: .bold))
                                .foregroundColor(Theme.secondaryAccent.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 10 * scale)

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
                                .frame(width: 60 * scale, height: 60 * scale)
                                .shadow(radius: 5)

                            Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 26 * scale))
                                .foregroundColor(.white)
                                .id(timerManager.isRunning)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 15 * scale)
                }
                .frame(maxWidth: .infinity)

            // Custom window controls and settings - always visible overlay
            VStack {
                HStack {
                    customWindowControls
                    Spacer()

                    // Stats button
                    Button(action: {
                        NSApp.sendAction(#selector(AppDelegate.openStats), to: nil, from: nil)
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(Theme.timerText)
                    .opacity(isHovering ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isHovering)

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
                        Button(action: { settings.darkMode.toggle() }) {
                            HStack {
                                Text("Dark Mode")
                                if settings.darkMode {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Divider()
                        Button("Settings...") {
                            NSApp.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
                        }
                        Button("Send Feedback...") {
                            sendFeedbackEmail()
                        }
                        Divider()
                        Button("Quit Pomo") {
                            NSApplication.shared.terminate(nil)
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                    }
                    .tint(Theme.timerText)
                    .menuStyle(BorderlessButtonMenuStyle())
                    .opacity(isHovering ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isHovering)
                }
                .padding(.leading, 6)
                .padding(.trailing, 8)
                .padding(.top, 6)
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
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
                newSize = NSSize(width: 380, height: 250)
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

    func sendFeedbackEmail() {
        let email = "zach@zachgodsell.com" // TODO: Replace with your email
        let subject = "Pomo Feedback"
        let body = "Hi,\n\nI'd like to share some feedback about Pomo:\n\n"

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            NSWorkspace.shared.open(url)
        }
    }
}
