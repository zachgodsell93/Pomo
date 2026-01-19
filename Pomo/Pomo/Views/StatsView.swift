import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var historyManager = SessionHistoryManager.shared
    @ObservedObject var settings = SettingsManager.shared
    @State private var selectedFilter: DateFilterOption = .thisWeek
    @State private var showClearConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date Filter Picker
                filterPicker

                // Scoreboard Cards
                scoreboardSection

                // Charts
                if !dailyData.isEmpty {
                    sessionsChartSection
                    focusTimeChartSection
                } else {
                    emptyStateView
                }

                // Clear History Button
                clearHistorySection
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 400)
        .background(Theme.background)
        .alert("Clear History", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                historyManager.clearHistory()
            }
        } message: {
            Text("Are you sure you want to clear all session history? This cannot be undone.")
        }
    }

    // MARK: - Filter Picker

    var filterPicker: some View {
        Picker("Time Period", selection: $selectedFilter) {
            ForEach(DateFilterOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: - Scoreboard Section

    var scoreboardSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ScoreCard(
                title: "Total Focus Time",
                value: formatDuration(historyManager.totalFocusTime(for: selectedFilter)),
                icon: "clock.fill"
            )
            ScoreCard(
                title: "Completed Sessions",
                value: "\(historyManager.completedPomos(for: selectedFilter))",
                icon: "checkmark.circle.fill"
            )
            ScoreCard(
                title: "Average per Day",
                value: formatDuration(historyManager.averagePerDay(for: selectedFilter)),
                icon: "chart.line.uptrend.xyaxis"
            )
            ScoreCard(
                title: "Current Streak",
                value: "\(historyManager.currentStreak()) days",
                icon: "flame.fill"
            )
            ScoreCard(
                title: "Best Streak",
                value: "\(historyManager.bestStreak()) days",
                icon: "trophy.fill"
            )
            ScoreCard(
                title: "Avg Session",
                value: formatDuration(historyManager.averageSessionLength(for: selectedFilter)),
                icon: "timer"
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Sessions Chart

    var dailyData: [(date: Date, duration: TimeInterval, count: Int)] {
        historyManager.dailyFocusTotals(for: selectedFilter)
    }

    var sessionsChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sessions per Day")
                .font(.headline)
                .foregroundColor(Theme.timerText)

            Chart(dailyData, id: \.date) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Sessions", item.count)
                )
                .foregroundStyle(Theme.accent.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 150)
            .padding()
            .background(cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    // MARK: - Focus Time Chart

    var focusTimeChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Focus Time Trend (minutes)")
                .font(.headline)
                .foregroundColor(Theme.timerText)

            Chart(dailyData, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Minutes", item.duration / 60)
                )
                .foregroundStyle(Theme.secondaryAccent)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Minutes", item.duration / 60)
                )
                .foregroundStyle(Theme.secondaryAccent.opacity(0.2).gradient)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Minutes", item.duration / 60)
                )
                .foregroundStyle(Theme.accent)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 150)
            .padding()
            .background(cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    // MARK: - Empty State

    var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(Theme.secondaryAccent.opacity(0.5))

            Text("No sessions recorded")
                .font(.headline)
                .foregroundColor(Theme.timerText)

            Text("Complete focus sessions to see your statistics here.")
                .font(.subheadline)
                .foregroundColor(Theme.timerText.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Clear History

    var clearHistorySection: some View {
        Button(action: {
            showClearConfirmation = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Clear History")
            }
            .foregroundColor(.red)
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    var cardBackground: Color {
        settings.darkMode ? Color(hex: "#3d3d3d") : .white
    }

    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Score Card Component

struct ScoreCard: View {
    let title: String
    let value: String
    let icon: String

    @ObservedObject var settings = SettingsManager.shared

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.accent)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Theme.timerText)

            Text(title)
                .font(.caption)
                .foregroundColor(Theme.timerText.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(cardBackground)
        .cornerRadius(10)
    }

    var cardBackground: Color {
        settings.darkMode ? Color(hex: "#3d3d3d") : .white
    }
}

#Preview {
    StatsView()
}
