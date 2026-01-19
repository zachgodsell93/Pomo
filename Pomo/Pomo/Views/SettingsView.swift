import SwiftUI

enum SettingsTab: String, CaseIterable {
    case general = "General"
    case session = "Session"

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .session: return "timer"
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 150, ideal: 180)
        } detail: {
            switch selectedTab {
            case .general:
                GeneralSettingsView(settings: settings)
            case .session:
                SessionSettingsView(settings: settings)
            }
        }
        .frame(width: 550, height: 350)
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        Form {
            Section {
                Toggle("Dark Mode", isOn: $settings.darkMode)
            } header: {
                Text("Appearance")
            }

            Section {
                Button("Send Feedback...") {
                    sendFeedbackEmail()
                }
            } header: {
                Text("Support")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
    }

    func sendFeedbackEmail() {
        let email = "feedback@example.com" // TODO: Replace with your email
        let subject = "Pomo Feedback"
        let body = "Hi,\n\nI'd like to share some feedback about Pomo:\n\n"

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct SessionSettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Focus Duration")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { Int(settings.focusDuration / 60) },
                        set: { settings.focusDuration = Double($0) * 60 }
                    )) {
                        Text("15 mins").tag(15)
                        Text("20 mins").tag(20)
                        Text("25 mins").tag(25)
                        Text("30 mins").tag(30)
                        Text("45 mins").tag(45)
                        Text("60 mins").tag(60)
                    }
                    .frame(width: 120)
                }

                HStack {
                    Text("Break Duration")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { Int(settings.breakDuration / 60) },
                        set: { settings.breakDuration = Double($0) * 60 }
                    )) {
                        Text("5 mins").tag(5)
                        Text("10 mins").tag(10)
                        Text("15 mins").tag(15)
                    }
                    .frame(width: 120)
                }

                HStack {
                    Text("Rounds")
                    Spacer()
                    Picker("", selection: $settings.targetPomos) {
                        ForEach(1...10, id: \.self) { num in
                            Text("\(num)").tag(num)
                        }
                    }
                    .frame(width: 80)
                }
            } header: {
                Text("Durations")
            }

            Section {
                Toggle("Auto-start Break", isOn: $settings.autoStartBreak)
            } header: {
                Text("Behavior")
            }

            Section {
                HStack {
                    Text("Timer Complete Sound")
                    Spacer()
                    Picker("", selection: $settings.selectedSound) {
                        Text("Ping").tag("Ping")
                        Text("Basso").tag("Basso")
                        Text("Bottle").tag("Bottle")
                        Text("Frog").tag("Frog")
                        Text("Glass").tag("Glass")
                        Text("Hero").tag("Hero")
                        Text("Morse").tag("Morse")
                        Text("Pop").tag("Pop")
                        Text("Purr").tag("Purr")
                        Text("Sosumi").tag("Sosumi")
                        Text("Submarine").tag("Submarine")
                        Text("Tink").tag("Tink")
                    }
                    .frame(width: 120)
                }
            } header: {
                Text("Sound")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Session")
    }
}
