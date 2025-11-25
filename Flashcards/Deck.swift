import Foundation

struct Deck: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var summary: String
    var cards: [Card] = []

    // Meta
    var timeSpentSeconds: TimeInterval = 0
    var lastStudyDay: Date?
    var currentStreak: Int = 0

    var count: Int { cards.count }
    var dueCount: Int { cards.filter { $0.isDue() }.count }
    var newCount: Int { cards.filter { $0.isNew }.count }
    var reviewCount: Int { cards.filter { !$0.isNew }.count }
    var averageEase: Double {
        guard !cards.isEmpty else { return 0 }
        return cards.map { $0.ease }.reduce(0, +) / Double(cards.count)
    }
    var accuracy: Double {
        let total = cards.reduce(0) { $0 + $1.totalReviews }
        guard total > 0 else { return 0 }
        let ok = cards.reduce(0) { $0 + $1.successfulReviews }
        return Double(ok) / Double(total)
    }

    mutating func addStudyTime(_ seconds: TimeInterval) {
        timeSpentSeconds += seconds
    }

    mutating func markStudied(on date: Date = Date()) {
        let day = Calendar.current.startOfDay(for: date)
        if let last = lastStudyDay {
            let diff = Calendar.current.dateComponents([.day], from: last, to: day).day ?? 0
            if diff == 1 { currentStreak += 1 }
            else if diff > 1 { currentStreak = 1 }
        } else {
            currentStreak = 1
        }
        lastStudyDay = day
    }

    // Codable defaults for backward compatibility
    enum CodingKeys: String, CodingKey {
        case id, name, summary, cards, timeSpentSeconds, lastStudyDay, currentStreak
    }

    init(id: UUID = UUID(), name: String, summary: String, cards: [Card] = []) {
        self.id = id
        self.name = name
        self.summary = summary
        self.cards = cards
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        summary = try container.decode(String.self, forKey: .summary)
        cards = try container.decodeIfPresent([Card].self, forKey: .cards) ?? []
        timeSpentSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .timeSpentSeconds) ?? 0
        lastStudyDay = try container.decodeIfPresent(Date.self, forKey: .lastStudyDay)
        currentStreak = try container.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
    }
}
