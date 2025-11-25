import Foundation

import Foundation

enum CardKind: String, Codable, CaseIterable, Identifiable {
    case word
    case sentence

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .word: return "Word"
        case .sentence: return "Sentence"
        }
    }
    var promptLabel: String {
        switch self {
        case .word: return "Word"
        case .sentence: return "Sentence"
        }
    }
    var primaryLabel: String {
        switch self {
        case .word: return "Definition"
        case .sentence: return "Translation"
        }
    }
    var secondaryLabel: String {
        switch self {
        case .word: return "Example sentence"
        case .sentence: return "Notes (optional)"
        }
    }
}

enum ReviewQuality {
    case again, good, easy
}

struct Card: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var kind: CardKind
    var prompt: String        // word or sentence
    var primary: String?      // definition or translation
    var secondary: String?    // example sentence or notes

    // SRS fields
    var ease: Double = 2.5
    var interval: Int = 0               // days
    var repetitions: Int = 0
    var lapses: Int = 0
    var totalReviews: Int = 0
    var successfulReviews: Int = 0
    var createdAt: Date = Date()
    var lastReviewAt: Date?
    var due: Date = Date()              // next due date (start of day)

    // MARK: - Review
    mutating func applyReview(_ quality: ReviewQuality, today: Date = Date()) {
        let q: Double
        switch quality {
        case .again: q = 1
        case .good:  q = 3
        case .easy:  q = 5
        }

        totalReviews += 1
        if quality != .again { successfulReviews += 1 }

        if q < 3 {
            lapses += 1
            repetitions = 0
            interval = 1
        } else {
            ease = max(1.3, ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))
            repetitions += 1
            if repetitions == 1 {
                interval = 1
            } else if repetitions == 2 {
                interval = 6
            } else {
                interval = Int(round(Double(interval) * ease))
            }
        }

        let startOfDay = Calendar.current.startOfDay(for: today)
        due = startOfDay.addingTimeInterval(86400 * Double(interval))
        lastReviewAt = today
    }

    var isNew: Bool { totalReviews == 0 }

    func isDue(on date: Date = Date()) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return due <= startOfDay
    }

    var accuracy: Double {
        guard totalReviews > 0 else { return 0 }
        return Double(successfulReviews) / Double(totalReviews)
    }

    var hasBackContent: Bool {
        (primary?.isEmpty == false) || (secondary?.isEmpty == false)
    }

    // MARK: - Codable with backward compatibility
    enum CodingKeys: String, CodingKey {
        case id, kind, prompt, primary, secondary, ease, interval, repetitions, lapses, totalReviews, successfulReviews, createdAt, lastReviewAt, due
    }

    init(id: UUID = UUID(), kind: CardKind, prompt: String, primary: String?, secondary: String?) {
        self.id = id
        self.kind = kind
        self.prompt = prompt
        self.primary = primary
        self.secondary = secondary
        self.due = Calendar.current.startOfDay(for: Date())
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        kind = try container.decode(CardKind.self, forKey: .kind)
        prompt = try container.decode(String.self, forKey: .prompt)
        primary = try container.decodeIfPresent(String.self, forKey: .primary)
        secondary = try container.decodeIfPresent(String.self, forKey: .secondary)
        ease = try container.decodeIfPresent(Double.self, forKey: .ease) ?? 2.5
        interval = try container.decodeIfPresent(Int.self, forKey: .interval) ?? 0
        repetitions = try container.decodeIfPresent(Int.self, forKey: .repetitions) ?? 0
        lapses = try container.decodeIfPresent(Int.self, forKey: .lapses) ?? 0
        totalReviews = try container.decodeIfPresent(Int.self, forKey: .totalReviews) ?? 0
        successfulReviews = try container.decodeIfPresent(Int.self, forKey: .successfulReviews) ?? 0
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        lastReviewAt = try container.decodeIfPresent(Date.self, forKey: .lastReviewAt)
        due = try container.decodeIfPresent(Date.self, forKey: .due) ?? Calendar.current.startOfDay(for: Date())
    }
}
