import Foundation
import SwiftUI

@MainActor
final class DeckStore: ObservableObject {
    @Published private(set) var decks: [Deck] = []

    private let fileURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("decks.json")
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

    func deleteDeck(at offsets: IndexSet) async {
        decks.remove(atOffsets: offsets)
        await save()
    }

    func replace(_ deck: Deck) async {
        guard let index = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[index] = deck
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
