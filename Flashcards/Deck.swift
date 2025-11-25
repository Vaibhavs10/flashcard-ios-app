import Foundation

struct Deck: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var summary: String
    var cards: [Card] = []

    var count: Int { cards.count }
}
