import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DeckStore
    @State private var showingAddDeck = false
    @State private var showingSettings = false
    @State private var backupMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background(for: colorScheme).ignoresSafeArea()

                List {
                    ForEach(store.decks) { deck in
                        NavigationLink(value: deck) {
                            DeckRow(deck: deck)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { offsets in
                        Task { await store.deleteDeck(at: offsets) }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Decks")
            .navigationDestination(for: Deck.self) { deck in
                DeckDetailView(deck: deck)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddDeck = true
                    } label: {
                        Label("Add Deck", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddDeck) {
            AddDeckView { name, summary in
                Task { await store.addDeck(name: name, summary: summary) }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(backupMessage: $backupMessage)
                .environmentObject(store)
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private struct DeckRow: View {
    let deck: Deck

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(deck.name)
                    .font(.headline.weight(.semibold))
                Text(deck.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Label("\(deck.dueCount) due", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if deck.currentStreak > 0 {
                        Label("\(deck.currentStreak)d streak", systemImage: "flame")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            Spacer()
            Text("\(deck.count)")
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.accentSoft, in: Capsule())
                .foregroundStyle(AppTheme.accent)
        }
        .padding(.vertical, 8)
        .subtleCard()
    }
}

#Preview {
    ContentView()
        .environmentObject(DeckStore())
}
