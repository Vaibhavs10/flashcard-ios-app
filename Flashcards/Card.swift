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

struct Card: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var kind: CardKind
    var prompt: String        // word or sentence
    var primary: String?      // definition or translation
    var secondary: String?    // example sentence or notes

    var hasBackContent: Bool {
        (primary?.isEmpty == false) || (secondary?.isEmpty == false)
    }
}
