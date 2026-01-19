import Foundation
import Combine

struct SessionRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let type: SessionType

    enum SessionType: String, Codable {
        case focus, shortBreak
    }

    init(id: UUID = UUID(), date: Date = Date(), duration: TimeInterval, type: SessionType) {
        self.id = id
        self.date = date
        self.duration = duration
        self.type = type
    }
}

enum DateFilterOption: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case last6Months = "Last 6 Months"
    case last12Months = "Last 12 Months"
    case allTime = "All Time"

    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        switch self {
        case .today:
            return (startOfToday, now)

        case .thisWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return (startOfWeek, now)

        case .lastWeek:
            let startOfThisWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfThisWeek)!
            return (startOfLastWeek, startOfThisWeek)

        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return (startOfMonth, now)

        case .lastMonth:
            let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth)!
            return (startOfLastMonth, startOfThisMonth)

        case .last6Months:
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now)!
            return (sixMonthsAgo, now)

        case .last12Months:
            let twelveMonthsAgo = calendar.date(byAdding: .month, value: -12, to: now)!
            return (twelveMonthsAgo, now)

        case .allTime:
            return (Date.distantPast, now)
        }
    }
}

class SessionHistoryManager: ObservableObject {
    static let shared = SessionHistoryManager()

    private let defaults = UserDefaults.standard
    private let sessionsKey = "sessionHistory"

    @Published var sessions: [SessionRecord] = []

    private init() {
        loadSessions()
    }

    func addSession(duration: TimeInterval, type: SessionRecord.SessionType) {
        let record = SessionRecord(duration: duration, type: type)
        sessions.append(record)
        saveSessions()
    }

    func clearHistory() {
        sessions.removeAll()
        saveSessions()
    }

    func filtered(by option: DateFilterOption) -> [SessionRecord] {
        let range = option.dateRange
        return sessions.filter { $0.date >= range.start && $0.date <= range.end }
    }

    func focusSessions(for option: DateFilterOption) -> [SessionRecord] {
        filtered(by: option).filter { $0.type == .focus }
    }

    // MARK: - Stats Calculations

    func totalFocusTime(for option: DateFilterOption) -> TimeInterval {
        focusSessions(for: option).reduce(0) { $0 + $1.duration }
    }

    func completedPomos(for option: DateFilterOption) -> Int {
        focusSessions(for: option).count
    }

    func averageSessionLength(for option: DateFilterOption) -> TimeInterval {
        let sessions = focusSessions(for: option)
        guard !sessions.isEmpty else { return 0 }
        return totalFocusTime(for: option) / Double(sessions.count)
    }

    func averagePerDay(for option: DateFilterOption) -> TimeInterval {
        let sessions = focusSessions(for: option)
        guard !sessions.isEmpty else { return 0 }

        let range = option.dateRange
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: range.start, to: range.end).day ?? 1
        let dayCount = max(1, days)

        return totalFocusTime(for: option) / Double(dayCount)
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let dayStart = checkDate
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let hasFocusSession = sessions.contains { session in
                session.type == .focus && session.date >= dayStart && session.date < dayEnd
            }

            if hasFocusSession {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if streak == 0 {
                // Check if today has no sessions yet - don't break streak
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                let yesterdayStart = checkDate
                let yesterdayEnd = calendar.date(byAdding: .day, value: 1, to: yesterdayStart)!
                let hadSessionYesterday = sessions.contains { session in
                    session.type == .focus && session.date >= yesterdayStart && session.date < yesterdayEnd
                }
                if hadSessionYesterday {
                    streak += 1
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                } else {
                    break
                }
            } else {
                break
            }
        }

        return streak
    }

    func bestStreak() -> Int {
        let calendar = Calendar.current
        let focusDates = Set(sessions.filter { $0.type == .focus }.map { calendar.startOfDay(for: $0.date) })

        guard !focusDates.isEmpty else { return 0 }

        let sortedDates = focusDates.sorted()
        var maxStreak = 1
        var currentStreakCount = 1

        for i in 1..<sortedDates.count {
            let daysBetween = calendar.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            if daysBetween == 1 {
                currentStreakCount += 1
                maxStreak = max(maxStreak, currentStreakCount)
            } else {
                currentStreakCount = 1
            }
        }

        return maxStreak
    }

    // MARK: - Daily aggregation for charts

    func dailyFocusTotals(for option: DateFilterOption) -> [(date: Date, duration: TimeInterval, count: Int)] {
        let calendar = Calendar.current
        let sessions = focusSessions(for: option)

        var dailyData: [Date: (duration: TimeInterval, count: Int)] = [:]

        for session in sessions {
            let day = calendar.startOfDay(for: session.date)
            let existing = dailyData[day] ?? (0, 0)
            dailyData[day] = (existing.duration + session.duration, existing.count + 1)
        }

        return dailyData.map { (date: $0.key, duration: $0.value.duration, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Persistence

    private func loadSessions() {
        guard let data = defaults.data(forKey: sessionsKey) else { return }
        do {
            sessions = try JSONDecoder().decode([SessionRecord].self, from: data)
        } catch {
            print("Failed to decode session history: \(error)")
        }
    }

    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            defaults.set(data, forKey: sessionsKey)
        } catch {
            print("Failed to encode session history: \(error)")
        }
    }
}
