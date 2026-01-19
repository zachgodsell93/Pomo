import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    @Published var focusDuration: TimeInterval {
        didSet { defaults.set(focusDuration, forKey: "focusDuration") }
    }
    
    @Published var breakDuration: TimeInterval {
        didSet { defaults.set(breakDuration, forKey: "breakDuration") }
    }
    
    @Published var autoStartBreak: Bool {
        didSet { defaults.set(autoStartBreak, forKey: "autoStartBreak") }
    }
    
    @Published var selectedSound: String {
        didSet { defaults.set(selectedSound, forKey: "selectedSound") }
    }
    
    @Published var targetPomos: Int {
        didSet { defaults.set(targetPomos, forKey: "targetPomos") }
    }

    @Published var darkMode: Bool {
        didSet { defaults.set(darkMode, forKey: "darkMode") }
    }

    init() {
        self.focusDuration = defaults.object(forKey: "focusDuration") as? TimeInterval ?? 1500 // 25 mins
        self.breakDuration = defaults.object(forKey: "breakDuration") as? TimeInterval ?? 300  // 5 mins
        self.autoStartBreak = defaults.bool(forKey: "autoStartBreak")
        self.selectedSound = defaults.string(forKey: "selectedSound") ?? "Ping"
        self.targetPomos = defaults.integer(forKey: "targetPomos")
        self.darkMode = defaults.bool(forKey: "darkMode")
        if self.targetPomos == 0 { self.targetPomos = 6 }
    }
}
