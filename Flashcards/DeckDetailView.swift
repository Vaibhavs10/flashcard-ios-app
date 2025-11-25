import SwiftUI

struct DeckDetailView: View {
    let deck: Deck
    @EnvironmentObject private var store: DeckStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var currentIndex: Int = 0
    @State private var showingBack: Bool = false
    @State private var showingAddCard: Bool = false
    @State private var randomOrder: Bool = false
    @State private var sessionStart: Date?

    private var liveDeck: Deck {
        store.decks.first(where: { $0.id == deck.id }) ?? deck
    }

    private var studyCards: [Card] {
        let due = store.dueCards(for: liveDeck)
        let fresh = store.newCards(for: liveDeck)
        let combined = due + fresh
        if randomOrder {
            return combined.shuffled()
        }
        return combined
    }

    var body: some View {
        ZStack {
            AppTheme.background(for: colorScheme).ignoresSafeArea()

            VStack(spacing: 20) {
                header

                if studyCards.isEmpty {
                    ContentUnavailableView("No cards due", systemImage: "square.stack.3d.up.slash", description: Text("Add or wait for cards to become due."))
                } else {
                    CardView(card: currentCard, showingBack: showingBack)
                        .onTapGesture { showingBack.toggle() }
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: studyCards)
                        .frame(maxHeight: 360)

                    Button {
                        haptic(.light)
                        showingBack.toggle()
                    } label: {
                        Label(showingBack ? "Show Front" : "Show Back", systemImage: "rectangle.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(CapsuleButtonStyle())
                    .keyboardShortcut(.space, modifiers: [])

                    gradeRow
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
        .onChange(of: studyCards.count) { _ in
            currentIndex = min(currentIndex, max(studyCards.count - 1, 0))
        }
        .onAppear {
            sessionStart = Date()
        }
        .onDisappear {
            if let start = sessionStart {
                let elapsed = Date().timeIntervalSince(start)
                Task { await store.recordStudyTime(elapsed, for: liveDeck) }
            }
        }
    }

    private func moveCard(_ offset: Int) {
        guard !studyCards.isEmpty else { return }
        let newIndex = currentIndex + offset
        currentIndex = min(max(newIndex, 0), studyCards.count - 1)
        showingBack = false
    }

    private var currentCard: Card {
        studyCards[safe: currentIndex] ?? studyCards.first!
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(liveDeck.name)
                    .font(.title2.bold())
                Spacer()
                Toggle(isOn: $randomOrder) {
                    Label("Shuffle", systemImage: "shuffle")
                        .labelStyle(.titleAndIcon)
                        .font(.caption.weight(.semibold))
                }
                .toggleStyle(.switch)
                .labelsHidden()
                .tint(AppTheme.accent)
                .accessibilityLabel("Shuffle cards")
            }

            HStack(spacing: 12) {
                StatPill(label: "Due", value: store.dueCards(for: liveDeck).count)
                StatPill(label: "New", value: store.newCards(for: liveDeck).count)
                StatPill(label: "Streak", value: liveDeck.currentStreak)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var gradeRow: some View {
        HStack(spacing: 12) {
            Button {
                haptic(.heavy)
                handleReview(.again)
            } label: {
                Label("Again", systemImage: "arrow.counterclockwise")
            }
            .tint(.red.opacity(0.8))
            .keyboardShortcut("1", modifiers: [])

            Button {
                haptic(.medium)
                handleReview(.good)
            } label: {
                Label("Good", systemImage: "checkmark")
            }
            .tint(.blue)
            .keyboardShortcut("2", modifiers: [])

            Button {
                haptic(.light)
                handleReview(.easy)
            } label: {
                Label("Easy", systemImage: "sparkles")
            }
            .tint(.green)
            .keyboardShortcut("3", modifiers: [])
        }
        .buttonStyle(CapsuleButtonStyle())
    }

    private func handleReview(_ quality: ReviewQuality) {
        Task {
            await store.review(card: currentCard, in: liveDeck, quality: quality)
            withAnimation {
                if currentIndex >= studyCards.count - 1 {
                    currentIndex = max(0, studyCards.count - 2)
                }
            }
            showingBack = false
        }
    }

    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
}

private extension Array where Element == Card {
    subscript(safe index: Int) -> Card? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

private struct StatPill: View {
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption)
            Text("\(value)")
                .font(.footnote.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.accentSoft, in: Capsule())
        .foregroundStyle(AppTheme.accent)
    }
}

#Preview {
    NavigationStack {
        DeckDetailView(deck: Deck(name: "Preview", summary: "", cards: DeckStore.seedData.first!.cards))
            .environmentObject(DeckStore())
    }
}
