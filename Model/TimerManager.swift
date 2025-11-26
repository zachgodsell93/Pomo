import Foundation
import AppKit
import Combine

enum TimerPhase {
    case idle
    case focus
    case shortBreak
}

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 1500
    @Published var phase: TimerPhase = .idle
    @Published var isRunning: Bool = false
    @Published var completedPomos: Int = 0
    
    private var timer: Timer?
    private let settings = SettingsManager.shared
    
    var progress: Double {
        let totalTime: TimeInterval
        switch phase {
        case .focus: totalTime = settings.focusDuration
        case .shortBreak: totalTime = settings.breakDuration
        case .idle: return 1.0
        }
        return totalTime > 0 ? (totalTime - timeRemaining) / totalTime : 0
    }
    
    func startFocus() {
        phase = .focus
        timeRemaining = settings.focusDuration
        startTimer()
    }
    
    func startBreak() {
        phase = .shortBreak
        timeRemaining = settings.breakDuration
        startTimer()
    }
    
    func skip() {
        completePhase()
    }
    
    func resetPhase() {
        stop() // Stops and resets to focus default, wait, stop() resets to focus default.
        // We want to reset to *current* phase default.
        // Let's fix stop() or just do it here.
        isRunning = false
        timer?.invalidate()
        
        switch phase {
        case .focus: timeRemaining = settings.focusDuration
        case .shortBreak: timeRemaining = settings.breakDuration
        case .idle: 
            phase = .focus
            timeRemaining = settings.focusDuration
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        phase = .idle
        timeRemaining = settings.focusDuration
    }
    
    func togglePause() {
        if isRunning {
            timer?.invalidate()
            isRunning = false
        } else {
            if phase == .idle {
                startFocus()
            } else {
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            completePhase()
            return
        }
        timeRemaining -= 1
    }
    
    private func completePhase() {
        if phase != .idle { // Only play sound if finishing a real phase
             playSound()
        }
        
        timer?.invalidate()
        isRunning = false
        
        if phase == .focus {
            completedPomos += 1
            if settings.autoStartBreak {
                startBreak()
            } else {
                phase = .shortBreak
                timeRemaining = settings.breakDuration
            }
        } else if phase == .shortBreak {
            phase = .focus
            timeRemaining = settings.focusDuration
        } else {
             // Was idle, user skipped start? go to focus
             startFocus()
        }
    }
    
    private func playSound() {
        if let sound = NSSound(named: settings.selectedSound) {
            sound.play()
        }
    }
    
    // Formatted string for UI: "MM:SS"
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
