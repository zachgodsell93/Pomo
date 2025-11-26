import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Durations Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Durations (Minutes)")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Focus")
                        .frame(width: 80, alignment: .leading)
                    Spacer()
                    TextField("25", value: Binding(
                        get: { settings.focusDuration / 60 },
                        set: { settings.focusDuration = $0 * 60 }
                    ), formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                }

                HStack {
                    Text("Break")
                        .frame(width: 80, alignment: .leading)
                    Spacer()
                    TextField("5", value: Binding(
                        get: { settings.breakDuration / 60 },
                        set: { settings.breakDuration = $0 * 60 }
                    ), formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                }

                HStack {
                    Text("Rounds")
                        .frame(width: 80, alignment: .leading)
                    Spacer()
                    Stepper("\(settings.targetPomos)", value: $settings.targetPomos, in: 1...12)
                        .frame(width: 100)
                }
            }

            Divider()

            // Behavior Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Behavior")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Toggle("Auto-start Break", isOn: $settings.autoStartBreak)
            }

            Divider()

            // Sound Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Sound")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Timer Complete")
                        .frame(width: 120, alignment: .leading)
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
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 350, height: 350)
    }
}
