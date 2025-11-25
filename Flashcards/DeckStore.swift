import Foundation
import SwiftUI

@MainActor
final class DeckStore: ObservableObject {
    @Published private(set) var decks: [Deck] = []

    private let fileURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("decks.json")
    }()
    private let backupFolder: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = documents.appendingPathComponent("Backups", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }()

    init() {
        Task { await load() }
    }

    func load() async {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Deck].self, from: data) {
            await MainActor.run { self.decks = decoded }
        } else {
            await MainActor.run { self.decks = Self.seedData }
            await save()
        }
    }

    func addDeck(name: String, summary: String) async {
        var newDeck = Deck(name: name, summary: summary, cards: [])
        newDeck.cards.append(contentsOf: sampleCards(for: newDeck))
        decks.append(newDeck)
        await save()
    }

    func addCard(_ card: Card, to deck: Deck) async {
        guard let index = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[index].cards.append(card)
        await save()
    }

    func updateCard(_ card: Card, in deck: Deck) async {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }),
              let cardIndex = decks[deckIndex].cards.firstIndex(where: { $0.id == card.id }) else { return }
        decks[deckIndex].cards[cardIndex] = card
        await save()
    }

    func review(card: Card, in deck: Deck, quality: ReviewQuality) async {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }),
              let cardIndex = decks[deckIndex].cards.firstIndex(where: { $0.id == card.id }) else { return }

        var updatedCard = decks[deckIndex].cards[cardIndex]
        updatedCard.applyReview(quality)
        decks[deckIndex].cards[cardIndex] = updatedCard
        decks[deckIndex].markStudied()
        await save()
    }

    func recordStudyTime(_ seconds: TimeInterval, for deck: Deck) async {
        guard let idx = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[idx].addStudyTime(seconds)
        await save()
    }

    func deleteDeck(at offsets: IndexSet) async {
        decks.remove(atOffsets: offsets)
        await save()
    }

    func replace(_ deck: Deck) async {
        guard let index = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[index] = deck
        await save()
    }

    func dueCards(for deck: Deck, today: Date = Date()) -> [Card] {
        let start = Calendar.current.startOfDay(for: today)
        return deck.cards.filter { $0.due <= start }
    }

    func newCards(for deck: Deck) -> [Card] {
        deck.cards.filter { $0.isNew }
    }

    func createBackup() async throws -> URL {
        guard let data = try? JSONEncoder().encode(decks) else {
            throw NSError(domain: "backup", code: 0, userInfo: [NSLocalizedDescriptionKey: "Encode failed"])
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let filename = "decks-\(formatter.string(from: Date())).json"
        let url = backupFolder.appendingPathComponent(filename)
        try data.write(to: url, options: [.atomic])
        return url
    }

    func listBackups() -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: backupFolder, includingPropertiesForKeys: nil))?
            .sorted(by: { $0.lastPathComponent > $1.lastPathComponent }) ?? []
    }

    func restore(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([Deck].self, from: data)
        decks = decoded
        await save()
    }

    private func save() async {
        guard let data = try? JSONEncoder().encode(decks) else { return }
        do {
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save decks: \(error)")
        }
    }
}

extension DeckStore {
    static var seedData: [Deck] {
        [
            Deck(
                name: "Daily Words",
                summary: "Mix of new vocabulary",
                cards: [
                    Card(kind: .word, prompt: "ubiquitous", primary: "present, appearing, or found everywhere", secondary: "Smartphones are ubiquitous in modern life."),
                    Card(kind: .word, prompt: "cogent", primary: "clear, logical, and convincing", secondary: "She presented a cogent argument for renewable energy.")
                ]
            ),
            Deck(
                name: "Spanish Sentences",
                summary: "Everyday phrases",
                cards: [
                    Card(kind: .sentence, prompt: "¿Dónde está la estación?", primary: "Where is the station?", secondary: "Use when asking for directions."),
                    Card(kind: .sentence, prompt: "Me gustaría un café, por favor.", primary: "I would like a coffee, please.", secondary: "Polite ordering phrase.")
                ]
            )
        ]
    }

    func sampleCards(for deck: Deck) -> [Card] { [] }
}
