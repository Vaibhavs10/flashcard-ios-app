import SwiftUI

struct DeckDetailView: View {
    let deck: Deck
    @EnvironmentObject private var store: DeckStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var currentIndex: Int = 0
    @State private var showingBack: Bool = false
    @State private var showingAddCard: Bool = false

    private var liveDeck: Deck {
        store.decks.first(where: { $0.id == deck.id }) ?? deck
    }

    private var cards: [Card] { liveDeck.cards }

    var body: some View {
        ZStack {
            AppTheme.background(for: colorScheme).ignoresSafeArea()

            VStack(spacing: 20) {
                if cards.isEmpty {
                    ContentUnavailableView("No cards", systemImage: "square.stack.3d.up.slash", description: Text("Add a card to start studying."))
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(liveDeck.name)
                            .font(.title2.bold())
                        Text("Card \(currentIndex + 1) of \(cards.count)")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    CardView(card: cards[safe: currentIndex] ?? cards[0], showingBack: showingBack)
                        .onTapGesture { showingBack.toggle() }
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: cards)
                        .frame(maxHeight: 360)

                    HStack(spacing: 14) {
                        Button {
                            moveCard(-1)
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .disabled(currentIndex == 0)

                        Button {
                            showingBack.toggle()
                        } label: {
                            Label(showingBack ? "Show Front" : "Show Back", systemImage: "rectangle.on.rectangle")
                        }

                        Button {
                            moveCard(1)
                        } label: {
                            Label("Next", systemImage: "chevron.right")
                        }
                        .disabled(currentIndex >= cards.count - 1)
                    }
                    .buttonStyle(CapsuleButtonStyle())
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(liveDeck.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddCard = true
                } label: {
                    Label("Add Card", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddCardView { card in
                Task { await store.addCard(card, to: liveDeck) }
            }
        }
        .onChange(of: cards.count) { _ in
            currentIndex = min(currentIndex, max(cards.count - 1, 0))
        }
    }

    private func moveCard(_ offset: Int) {
        guard !cards.isEmpty else { return }
        let newIndex = currentIndex + offset
        currentIndex = min(max(newIndex, 0), cards.count - 1)
        showingBack = false
    }
}

private extension Array where Element == Card {
    subscript(safe index: Int) -> Card? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

#Preview {
    NavigationStack {
        DeckDetailView(deck: Deck(name: "Preview", summary: "", cards: DeckStore.seedData.first!.cards))
            .environmentObject(DeckStore())
    }
}
