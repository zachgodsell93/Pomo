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

            HStack(spacing: 0) {
                // Left Pagination Panel
                VStack(spacing: 12) {
                    Spacer()
                    // Display dots representing a cycle
                    ForEach(0..<settings.targetPomos, id: \.self) { index in
                        Circle()
                            .fill(index < (timerManager.completedPomos % settings.targetPomos) ? Theme.accent : Theme.accent.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                    Spacer()
                }
                .frame(width: 50)
                .background(Theme.background.brightness(-0.02))

                // Main Content
                VStack(spacing: 20) {
                    // Header/Phase
                    Text(phaseText)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.secondaryAccent)
                        .padding(.top, 30)

                    Spacer()

                    // Timer Display Row
                    HStack(spacing: 20) {
                        Button(action: {
                            timerManager.resetPhase()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.secondaryAccent.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Text(timerManager.timeString)
                            .font(.system(size: 80, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.timerText)
                            .minimumScaleFactor(0.5)

                        Button(action: {
                            timerManager.skip()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.secondaryAccent.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)

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
                                .frame(width: 60, height: 60)
                                .shadow(radius: 5)

                            Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                                .id(timerManager.isRunning)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
            }

            // Custom window controls and settings - always visible overlay
            VStack {
                HStack {
                    customWindowControls
                    Spacer()
                    settingsButton
                }
                .padding(.leading, 8)
                .padding(.trailing, 10)
                .padding(.top, 8)
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
                NSApp.keyWindow?.close()
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

    var settingsButton: some View {
        Button(action: {
            NSApp.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
        }) {
            Image(systemName: "gearshape.fill")
                .renderingMode(.original)
                .font(.system(size: 16))
                .foregroundColor(Theme.darkBlue)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isHovering ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isHovering)
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
    
    var phaseText: String {
        switch timerManager.phase {
        case .idle: return "Ready to Focus"
        case .focus: return "Focus Session"
        case .shortBreak: return "Break Time"
        }
    }
}
